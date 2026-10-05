-- roblox_mock.lua — a headless fake Roblox client for running the REAL RvrseUI.lua
-- (and hubs built on it) in the offline `luau` CLI. See run_rvrseui_harness.ps1.
--
-- The trace-diff mock answers "does the VM behave like native?" by making every
-- member callable. This one answers "does this code behave on Roblox?", so it is
-- deliberately strict where the real engine is strict and faithful where
-- lifecycle bugs hide:
--   * unknown members error ("X is not a valid member of Frame") like Roblox
--   * Instance:Destroy() fires Destroying, destroys children, locks Parent and
--     DISCONNECTS every connection on the instance — like Roblox
--   * every connection records who made it (debug.info source: "RvrseUI", "Hub")
--     and which signal it is on, so tests can count what survives a close
--   * a virtual-time scheduler (task.*, wait, tweens, Heartbeat frames)
-- Everything lives in the single table `M` so the run file's main chunk stays
-- far below Luau's 200-locals limit and hub code can't capture mock locals.
local M = {
	env = getfenv(1),
	nativeTypeof = typeof,
	now = 0,
	frame = 0,
	conns = {}, -- every connection ever made (see M.liveConns)
	errors = {}, -- uncaught errors in threads/handlers
	warnings = {},
	prints = {},
	echo = true,
	D = setmetatable({}, { __mode = "k" }), -- instance -> private data
}

-- ════════════════════════════════════════════════════════════════════
-- scheduler (virtual time)
-- ════════════════════════════════════════════════════════════════════
M.sleeping = {} -- { co, wake, start, args }
M.deferred = {} -- { co, args }
M.cancelled = setmetatable({}, { __mode = "k" })

function M.reportError(err, co)
	local tb = co and debug.traceback(co, tostring(err)) or tostring(err)
	table.insert(M.errors, tb)
	if M.echo then print("MOCK ERROR: " .. tb) end
end

function M.resume(co, ...)
	if M.cancelled[co] or coroutine.status(co) == "dead" then return end
	local ok, err = coroutine.resume(co, ...)
	if not ok then M.reportError(err, co) end
end

function M.toThread(f)
	if type(f) == "thread" then return f end
	assert(type(f) == "function", "invalid argument #1 to 'spawn' (function or thread expected)")
	return coroutine.create(f)
end

M.task = {}
function M.task.spawn(f, ...)
	local co = M.toThread(f)
	M.resume(co, ...)
	return co
end
function M.task.defer(f, ...)
	local co = M.toThread(f)
	table.insert(M.deferred, { co = co, args = table.pack(...) })
	return co
end
function M.task.delay(t, f, ...)
	local co = M.toThread(f)
	table.insert(M.sleeping, { co = co, wake = M.now + math.max(tonumber(t) or 0, 0), start = M.now, args = table.pack(...), delayed = true })
	return co
end
function M.task.wait(t)
	local co = coroutine.running()
	if not coroutine.isyieldable() then error("attempt to yield across metamethod/C-call boundary", 2) end
	t = math.max(tonumber(t) or 0, 1 / 60)
	table.insert(M.sleeping, { co = co, wake = M.now + t, start = M.now })
	return coroutine.yield()
end
function M.task.cancel(co)
	M.cancelled[co] = true
	pcall(coroutine.close, co)
end
function M.task.synchronize() end
function M.task.desynchronize() end

function M.runDeferred()
	local guard = 0
	while #M.deferred > 0 do
		guard += 1
		if guard > 10000 then M.reportError("deferred-thread storm (>10000 in one frame)") break end
		local q = M.deferred
		M.deferred = {}
		for _, e in ipairs(q) do M.resume(e.co, table.unpack(e.args, 1, e.args.n)) end
	end
end

function M.wakeSleepers()
	local due = {}
	local keep = {}
	for _, s in ipairs(M.sleeping) do
		if s.wake <= M.now + 1e-9 then table.insert(due, s) else table.insert(keep, s) end
	end
	M.sleeping = keep
	table.sort(due, function(a, b) return a.wake < b.wake end)
	for _, s in ipairs(due) do
		if s.delayed then
			M.resume(s.co, table.unpack(s.args, 1, s.args.n))
		else
			M.resume(s.co, M.now - s.start, M.now)
		end
		M.runDeferred()
	end
end

-- One frame: RenderStepped -> Stepped -> Heartbeat -> resume waits -> deferred.
function M.step(dt)
	dt = dt or 1 / 60
	M.now += dt
	M.frame += 1
	M.runDeferred()
	M.fire(M.RunService, "RenderStepped", dt)
	M.fire(M.RunService, "PreRender", dt)
	M.fire(M.RunService, "Stepped", M.now, dt)
	M.fire(M.RunService, "PreSimulation", dt)
	M.fire(M.RunService, "Heartbeat", dt)
	M.fire(M.RunService, "PostSimulation", dt)
	for _, fn in pairs(M.renderSteps) do
		local co = coroutine.create(fn)
		M.resume(co, dt)
	end
	M.wakeSleepers()
	M.runDeferred()
end

function M.run(seconds, dt)
	dt = dt or 1 / 60
	local target = M.now + (seconds or 0)
	repeat M.step(dt) until M.now >= target - 1e-9
end

-- Run `fn` in a scheduler thread and pump frames until it finishes (or times out).
function M.runThread(fn, timeout)
	local co = coroutine.create(fn)
	M.resume(co)
	local limit = M.now + (timeout or 120)
	while coroutine.status(co) ~= "dead" and M.now < limit do M.step() end
	return coroutine.status(co) == "dead"
end

-- ════════════════════════════════════════════════════════════════════
-- signals & connections
-- ════════════════════════════════════════════════════════════════════
M.SignalMT = { __index = {} }
M.ConnMT = { __index = {} }
M.SignalMT.__tostring = function(s) return "Signal " .. s._name end
M.ConnMT.__tostring = function() return "Connection" end

function M.newSignal(owner, name)
	return setmetatable({ _owner = owner, _name = name, _list = {}, _waiters = {} }, M.SignalMT)
end

local function M_ownerLabel(owner)
	local d = owner and M.D[owner]
	if d then return d.className .. ":" .. tostring(d.props.Name) end
	return tostring(owner)
end
M.ownerLabel = M_ownerLabel

function M.SignalMT.__index:Connect(fn)
	if type(fn) ~= "function" then error("Attempt to connect failed: Passed value is not a function", 2) end
	local c = setmetatable({ Connected = true, _sig = self, _fn = fn }, M.ConnMT)
	table.insert(self._list, c)
	local src = debug.info(2, "s") or "?"
	local line = debug.info(2, "l") or 0
	c._rec = {
		conn = c,
		signal = self._name,
		owner = self._owner,
		ownerLabel = M_ownerLabel(self._owner),
		global = M.D[self._owner] ~= nil and M.D[self._owner].isService == true,
		src = src,
		where = src .. ":" .. tostring(line),
		frame = M.frame,
	}
	table.insert(M.conns, c._rec)
	return c
end
M.SignalMT.__index.connect = M.SignalMT.__index.Connect
function M.SignalMT.__index:Once(fn)
	local c
	c = self:Connect(function(...)
		c:Disconnect()
		return fn(...)
	end)
	c._rec.src = debug.info(2, "s") or "?"
	return c
end
function M.SignalMT.__index:ConnectParallel(fn) return self:Connect(fn) end
function M.SignalMT.__index:Wait()
	local co = coroutine.running()
	if not coroutine.isyieldable() then error("attempt to yield across metamethod/C-call boundary", 2) end
	table.insert(self._waiters, co)
	return coroutine.yield()
end
function M.ConnMT.__index:Disconnect()
	if not self.Connected then return end
	self.Connected = false
	local list = self._sig._list
	for i, c in ipairs(list) do
		if c == self then table.remove(list, i) break end
	end
end
M.ConnMT.__index.disconnect = M.ConnMT.__index.Disconnect

-- Engine-side fire: each handler runs in its own thread (Immediate signal mode).
function M.fireSignal(sig, ...)
	for _, c in ipairs(table.clone(sig._list)) do
		if c.Connected then
			local co = coroutine.create(c._fn)
			M.resume(co, ...)
		end
	end
	if #sig._waiters > 0 then
		local w = sig._waiters
		sig._waiters = {}
		for _, co in ipairs(w) do M.resume(co, ...) end
	end
end

function M.signalOf(inst, name)
	local d = M.D[inst]
	local s = d.signals[name]
	if not s then
		s = M.newSignal(inst, name)
		d.signals[name] = s
	end
	return s
end

function M.fire(inst, name, ...)
	local d = M.D[inst]
	if d and d.signals[name] then M.fireSignal(d.signals[name], ...) end
end

-- Live connections, optionally filtered: { src = "RvrseUI", global = true }
function M.liveConns(filter)
	local out = {}
	for _, r in ipairs(M.conns) do
		if r.conn.Connected then
			local ok = true
			if filter then
				if filter.src ~= nil and r.src ~= filter.src then ok = false end
				if filter.global ~= nil and r.global ~= filter.global then ok = false end
				if filter.since ~= nil and r.frame < filter.since then ok = false end
			end
			if ok then table.insert(out, r) end
		end
	end
	return out
end

-- ════════════════════════════════════════════════════════════════════
-- datatypes
-- ════════════════════════════════════════════════════════════════════
M.typeNames = setmetatable({}, { __mode = "k" }) -- metatable -> typeof name

local function M_dt(name, mt)
	mt.__type = name
	M.typeNames[mt] = name
	return mt
end

-- UDim
M.UDimMT = M_dt("UDim", {})
M.UDimMT.__index = function(u, k) return nil end
function M.UDim(s, o) return setmetatable({ Scale = s or 0, Offset = o or 0 }, M.UDimMT) end
M.UDimMT.__add = function(a, b) return M.UDim(a.Scale + b.Scale, a.Offset + b.Offset) end
M.UDimMT.__sub = function(a, b) return M.UDim(a.Scale - b.Scale, a.Offset - b.Offset) end
M.UDimMT.__eq = function(a, b) return a.Scale == b.Scale and a.Offset == b.Offset end
M.UDimMT.__tostring = function(u) return u.Scale .. ", " .. u.Offset end

-- UDim2
M.UDim2MT = M_dt("UDim2", {})
M.UDim2MT.__index = function(u, k)
	if k == "Width" then return rawget(u, "X") end
	if k == "Height" then return rawget(u, "Y") end
	if k == "Lerp" then
		return function(a, b, t)
			return M.UDim2(
				a.X.Scale + (b.X.Scale - a.X.Scale) * t, a.X.Offset + (b.X.Offset - a.X.Offset) * t,
				a.Y.Scale + (b.Y.Scale - a.Y.Scale) * t, a.Y.Offset + (b.Y.Offset - a.Y.Offset) * t)
		end
	end
	error(tostring(k) .. " is not a valid member of UDim2", 2)
end
function M.UDim2(xs, xo, ys, yo)
	if M.nativeTypeof(xs) == "table" and getmetatable(xs) == M.UDimMT then
		return setmetatable({ X = xs, Y = xo }, M.UDim2MT)
	end
	return setmetatable({ X = M.UDim(xs, xo), Y = M.UDim(ys, yo) }, M.UDim2MT)
end
M.UDim2MT.__add = function(a, b) return setmetatable({ X = a.X + b.X, Y = a.Y + b.Y }, M.UDim2MT) end
M.UDim2MT.__sub = function(a, b) return setmetatable({ X = a.X - b.X, Y = a.Y - b.Y }, M.UDim2MT) end
M.UDim2MT.__eq = function(a, b) return a.X == b.X and a.Y == b.Y end
M.UDim2MT.__tostring = function(u) return "{" .. tostring(u.X) .. "}, {" .. tostring(u.Y) .. "}" end

-- Vector2 / Vector3 (tables with full arithmetic; `typeof` reports the Roblox name)
local function M_vecType(name, n)
	local mt = M_dt(name, {})
	local ctor
	local axes = n == 2 and { "X", "Y" } or { "X", "Y", "Z" }
	local function make(...)
		local v = { ... }
		local o = {}
		for i, a in ipairs(axes) do o[a] = v[i] or 0 end
		return setmetatable(o, mt)
	end
	ctor = make
	local function map2(a, b, f)
		local r = {}
		for i, ax in ipairs(axes) do
			local av = type(a) == "number" and a or a[ax]
			local bv = type(b) == "number" and b or b[ax]
			r[i] = f(av, bv)
		end
		return make(table.unpack(r))
	end
	mt.__add = function(a, b) return map2(a, b, function(x, y) return x + y end) end
	mt.__sub = function(a, b) return map2(a, b, function(x, y) return x - y end) end
	mt.__mul = function(a, b) return map2(a, b, function(x, y) return x * y end) end
	mt.__div = function(a, b) return map2(a, b, function(x, y) return x / y end) end
	mt.__unm = function(a) return map2(a, -1, function(x, y) return x * y end) end
	mt.__eq = function(a, b)
		for _, ax in ipairs(axes) do if a[ax] ~= b[ax] then return false end end
		return true
	end
	mt.__tostring = function(v)
		local p = {}
		for _, ax in ipairs(axes) do table.insert(p, tostring(v[ax])) end
		return table.concat(p, ", ")
	end
	local methods = {}
	function methods.Dot(a, b)
		local s = 0
		for _, ax in ipairs(axes) do s += a[ax] * b[ax] end
		return s
	end
	function methods.Lerp(a, b, t) return a + (b - a) * t end
	function methods.Abs(a) return map2(a, 0, function(x) return math.abs(x) end) end
	function methods.Floor(a) return map2(a, 0, function(x) return math.floor(x) end) end
	function methods.Ceil(a) return map2(a, 0, function(x) return math.ceil(x) end) end
	function methods.Max(a, b) return map2(a, b, math.max) end
	function methods.Min(a, b) return map2(a, b, math.min) end
	function methods.FuzzyEq(a, b, eps)
		eps = eps or 1e-5
		for _, ax in ipairs(axes) do if math.abs(a[ax] - b[ax]) > eps then return false end end
		return true
	end
	if n == 3 then
		function methods.Cross(a, b)
			return make(a.Y * b.Z - a.Z * b.Y, a.Z * b.X - a.X * b.Z, a.X * b.Y - a.Y * b.X)
		end
	else
		function methods.Cross(a, b) return a.X * b.Y - a.Y * b.X end
	end
	mt.__index = function(v, k)
		if k == "Magnitude" then return math.sqrt(methods.Dot(v, v)) end
		if k == "Unit" then
			local m = math.sqrt(methods.Dot(v, v))
			if m == 0 then return v end
			return v / m
		end
		local lower = type(k) == "string" and #k == 1 and k:upper()
		if lower and rawget(v, lower) ~= nil then return rawget(v, lower) end
		if methods[k] then return methods[k] end
		error(tostring(k) .. " is not a valid member of " .. name, 2)
	end
	local lib = { new = ctor }
	lib.zero = make(0, 0, 0)
	lib.one = make(1, 1, 1)
	lib.xAxis = make(1, 0, 0)
	lib.yAxis = make(0, 1, 0)
	if n == 3 then lib.zAxis = make(0, 0, 1) end
	return lib, mt
end
M.Vector2, M.Vector2MT = M_vecType("Vector2", 2)
M.Vector3, M.Vector3MT = M_vecType("Vector3", 3)
M.V2 = M.Vector2.new
M.V3 = M.Vector3.new

-- Color3
M.Color3MT = M_dt("Color3", {})
local function M_c3(r, g, b) return setmetatable({ R = r or 0, G = g or 0, B = b or 0 }, M.Color3MT) end
M.Color3 = { new = M_c3 }
function M.Color3.fromRGB(r, g, b) return M_c3((r or 0) / 255, (g or 0) / 255, (b or 0) / 255) end
function M.Color3.fromHSV(h, s, v)
	local i = math.floor(h * 6)
	local f = h * 6 - i
	local p, q, t = v * (1 - s), v * (1 - f * s), v * (1 - (1 - f) * s)
	i = i % 6
	if i == 0 then return M_c3(v, t, p) elseif i == 1 then return M_c3(q, v, p)
	elseif i == 2 then return M_c3(p, v, t) elseif i == 3 then return M_c3(p, q, v)
	elseif i == 4 then return M_c3(t, p, v) end
	return M_c3(v, p, q)
end
function M.Color3.toHSV(c)
	local r, g, b = c.R, c.G, c.B
	local mx, mn = math.max(r, g, b), math.min(r, g, b)
	local h, s, v = 0, 0, mx
	local d = mx - mn
	if mx ~= 0 then s = d / mx end
	if d ~= 0 then
		if mx == r then h = (g - b) / d + (g < b and 6 or 0)
		elseif mx == g then h = (b - r) / d + 2
		else h = (r - g) / d + 4 end
		h /= 6
	end
	return h, s, v
end
function M.Color3.fromHex(hex)
	hex = tostring(hex):gsub("#", "")
	return M.Color3.fromRGB(tonumber(hex:sub(1, 2), 16) or 0, tonumber(hex:sub(3, 4), 16) or 0, tonumber(hex:sub(5, 6), 16) or 0)
end
M.Color3MT.__index = function(c, k)
	if k == "Lerp" then
		return function(a, b, t) return M_c3(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t) end
	end
	if k == "ToHSV" then return M.Color3.toHSV end
	if k == "ToHex" then
		return function(a)
			return string.format("%02X%02X%02X", math.floor(a.R * 255 + 0.5), math.floor(a.G * 255 + 0.5), math.floor(a.B * 255 + 0.5))
		end
	end
	error(tostring(k) .. " is not a valid member of Color3", 2)
end
M.Color3MT.__eq = function(a, b) return a.R == b.R and a.G == b.G and a.B == b.B end
M.Color3MT.__tostring = function(c) return c.R .. ", " .. c.G .. ", " .. c.B end

-- sequences, ranges, tween info, rect, font
local function M_simple(name, fields)
	local mt = M_dt(name, {})
	mt.__index = function(_, k) error(tostring(k) .. " is not a valid member of " .. name, 2) end
	return function(...)
		local args = { ... }
		local o = {}
		for i, f in ipairs(fields) do o[f] = args[i] end
		return setmetatable(o, mt)
	end, mt
end
M.ColorSequenceKeypoint = { new = (M_simple("ColorSequenceKeypoint", { "Time", "Value" })) }
M.NumberSequenceKeypoint = {}
do
	local mk = M_simple("NumberSequenceKeypoint", { "Time", "Value", "Envelope" })
	M.NumberSequenceKeypoint.new = function(t, v, e) return mk(t, v, e or 0) end
end
local function M_seq(name, kpLib, isValue)
	local mt = M_dt(name, {})
	mt.__index = function(_, k) error(tostring(k) .. " is not a valid member of " .. name, 2) end
	return {
		new = function(a, b)
			local kps
			if type(a) == "table" and getmetatable(a) == nil then
				kps = a
			elseif b ~= nil then
				kps = { kpLib.new(0, a), kpLib.new(1, b) }
			else
				kps = { kpLib.new(0, a), kpLib.new(1, a) }
			end
			return setmetatable({ Keypoints = kps }, mt)
		end,
	}
end
M.ColorSequence = M_seq("ColorSequence", M.ColorSequenceKeypoint)
M.NumberSequence = M_seq("NumberSequence", M.NumberSequenceKeypoint)
M.NumberRange = { new = function(a, b) return (M_simple("NumberRange", { "Min", "Max" }))(a, b or a) end }
do
	local mk = M_simple("TweenInfo", { "Time", "EasingStyle", "EasingDirection", "RepeatCount", "Reverses", "DelayTime" })
	M.TweenInfo = {
		new = function(t, s, d, rc, rev, dl)
			return mk(t or 1, s or M.Enum.EasingStyle.Quad, d or M.Enum.EasingDirection.Out, rc or 0, rev or false, dl or 0)
		end,
	}
end
do
	local mt = M_dt("Rect", {})
	mt.__index = function(r, k)
		if k == "Width" then return r.Max.X - r.Min.X end
		if k == "Height" then return r.Max.Y - r.Min.Y end
		error(tostring(k) .. " is not a valid member of Rect", 2)
	end
	M.Rect = {
		new = function(a, b, c, d)
			if type(a) == "number" or a == nil then
				return setmetatable({ Min = M.V2(a or 0, b or 0), Max = M.V2(c or 0, d or 0) }, mt)
			end
			return setmetatable({ Min = a, Max = b }, mt)
		end,
	}
end
do
	local mk = M_simple("Font", { "Family", "Weight", "Style" })
	M.Font = {
		new = function(f, w, s) return mk(f, w or M.Enum.FontWeight.Regular, s or M.Enum.FontStyle.Normal) end,
		fromEnum = function(e) return mk("rbxasset://fonts/families/" .. tostring(e.Name) .. ".json", M.Enum.FontWeight.Regular, M.Enum.FontStyle.Normal) end,
		fromName = function(n) return mk("rbxasset://fonts/families/" .. n .. ".json", M.Enum.FontWeight.Regular, M.Enum.FontStyle.Normal) end,
	}
end
-- CFrame: just enough for hubs (position + identity rotation).
do
	local mt = M_dt("CFrame", {})
	local function mk(x, y, z) return setmetatable({ X = x or 0, Y = y or 0, Z = z or 0 }, mt) end
	mt.__index = function(cf, k)
		if k == "Position" or k == "p" then return M.V3(cf.X, cf.Y, cf.Z) end
		if k == "LookVector" then return M.V3(0, 0, -1) end
		if k == "RightVector" then return M.V3(1, 0, 0) end
		if k == "UpVector" then return M.V3(0, 1, 0) end
		if k == "Rotation" then return mk(0, 0, 0) end
		error(tostring(k) .. " is not a valid member of CFrame", 2)
	end
	mt.__add = function(a, v) return mk(a.X + v.X, a.Y + v.Y, a.Z + v.Z) end
	mt.__sub = function(a, v) return mk(a.X - v.X, a.Y - v.Y, a.Z - v.Z) end
	mt.__mul = function(a, b)
		if getmetatable(b) == mt then return mk(a.X + b.X, a.Y + b.Y, a.Z + b.Z) end
		return M.V3(a.X + b.X, a.Y + b.Y, a.Z + b.Z)
	end
	M.CFrame = {
		new = function(x, y, z)
			if type(x) == "table" then return mk(x.X, x.Y, x.Z) end
			return mk(x, y, z)
		end,
		identity = mk(0, 0, 0),
		lookAt = function(p) return mk(p.X, p.Y, p.Z) end,
		Angles = function() return mk(0, 0, 0) end,
		fromEulerAnglesXYZ = function() return mk(0, 0, 0) end,
	}
end

-- ════════════════════════════════════════════════════════════════════
-- Enum (invalid item names error, like Roblox, for the enums we list)
-- ════════════════════════════════════════════════════════════════════
M.EnumItemMT = M_dt("EnumItem", {})
M.EnumItemMT.__tostring = function(e) return "Enum." .. e.EnumType._name .. "." .. e.Name end
M.EnumItemMT.__index = function(e, k)
	if k == "IsA" then return function(self, t) return self.EnumType._name == t end end
	error(tostring(k) .. " is not a valid member of EnumItem", 2)
end
M.EnumTypeMT = M_dt("Enum", {})
M.EnumTypeMT.__tostring = function(t) return t._name end
M.KnownEnumItems = {
	KeyCode = "Unknown Backspace Tab Clear Return Pause Escape Space QuotedDouble Hash Dollar Percent Ampersand Quote LeftParenthesis RightParenthesis Asterisk Plus Comma Minus Period Slash Zero One Two Three Four Five Six Seven Eight Nine Colon Semicolon LessThan Equals GreaterThan Question At LeftBracket BackSlash RightBracket Caret Underscore Backquote A B C D E F G H I J K L M N O P Q R S T U V W X Y Z LeftCurly Pipe RightCurly Tilde Delete KeypadZero KeypadOne KeypadTwo KeypadThree KeypadFour KeypadFive KeypadSix KeypadSeven KeypadEight KeypadNine KeypadPeriod KeypadDivide KeypadMultiply KeypadMinus KeypadPlus KeypadEnter KeypadEquals Up Down Right Left Insert Home End PageUp PageDown LeftShift RightShift LeftMeta RightMeta LeftAlt RightAlt LeftControl RightControl CapsLock NumLock ScrollLock LeftSuper RightSuper Mode Compose Help Print SysReq Break Menu Power Euro Undo F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12 F13 F14 F15 ButtonX ButtonY ButtonA ButtonB ButtonR1 ButtonL1 ButtonR2 ButtonL2 ButtonR3 ButtonL3 ButtonStart ButtonSelect DPadLeft DPadRight DPadUp DPadDown Thumbstick1 Thumbstick2 MouseLeftButton MouseRightButton MouseMiddleButton",
	UserInputType = "MouseButton1 MouseButton2 MouseButton3 MouseWheel MouseMovement Touch Keyboard Focus Accelerometer Gyro Gamepad1 Gamepad2 Gamepad3 Gamepad4 Gamepad5 Gamepad6 Gamepad7 Gamepad8 TextInput InputMethod None",
	UserInputState = "Begin Change End Cancel None",
}
M.Enum = setmetatable({}, {
	__index = function(t, typeName)
		local known
		if M.KnownEnumItems[typeName] then
			known = {}
			for w in M.KnownEnumItems[typeName]:gmatch("%S+") do known[w] = true end
		end
		local et = setmetatable({ _name = typeName, _known = known, _n = 0, _items = {} }, M.EnumTypeMT)
		rawset(t, typeName, et)
		return et
	end,
})
M.EnumTypeMT.__index = function(et, item)
	if item == "GetEnumItems" then
		return function(self)
			local out = {}
			if self._known then for name in pairs(self._known) do table.insert(out, self[name]) end end
			table.sort(out, function(a, b) return a.Value < b.Value end)
			return out
		end
	end
	if item == "FromName" then return function(self, n) return self[n] end end
	local known = rawget(et, "_known")
	if known and not known[item] then
		error(tostring(item) .. " is not a valid member of \"Enum." .. rawget(et, "_name") .. "\"", 2)
	end
	local n = rawget(et, "_n") + 1
	rawset(et, "_n", n)
	local e = setmetatable({ Name = item, Value = n, EnumType = et }, M.EnumItemMT)
	rawset(et, item, e)
	return e
end

-- ════════════════════════════════════════════════════════════════════
-- instances
-- ════════════════════════════════════════════════════════════════════
M.Supers = {
	Frame = "GuiObject", ScrollingFrame = "GuiObject", TextLabel = "GuiObject", TextBox = "GuiObject",
	ImageLabel = "GuiObject", ViewportFrame = "GuiObject", CanvasGroup = "GuiObject",
	TextButton = "GuiButton", ImageButton = "GuiButton", GuiButton = "GuiObject",
	GuiObject = "GuiBase2d", LayerCollector = "GuiBase2d", GuiBase2d = "Instance",
	ScreenGui = "LayerCollector", BillboardGui = "LayerCollector", SurfaceGui = "LayerCollector",
	UIStroke = "UIComponent", UICorner = "UIComponent", UIGradient = "UIComponent", UIPadding = "UIComponent",
	UIScale = "UIComponent", UIAspectRatioConstraint = "UIConstraint", UISizeConstraint = "UIConstraint",
	UITextSizeConstraint = "UIConstraint", UIConstraint = "UIComponent",
	UIListLayout = "UIGridStyleLayout", UIGridLayout = "UIGridStyleLayout", UIPageLayout = "UIGridStyleLayout",
	UIGridStyleLayout = "UILayout", UILayout = "UIComponent", UIFlexItem = "UIComponent", UIComponent = "UIBase", UIBase = "Instance",
	Part = "BasePart", MeshPart = "BasePart", BasePart = "PVInstance", Model = "PVInstance", PVInstance = "Instance",
	Workspace = "Model", PlayerGui = "BasePlayerGui", BasePlayerGui = "Instance",
	BodyVelocity = "BodyMover", BodyGyro = "BodyMover", BodyPosition = "BodyMover", BodyMover = "Instance",
	Highlight = "Instance", Folder = "Instance", Humanoid = "Instance", Player = "Instance", Camera = "Instance",
	Tween = "TweenBase", TweenBase = "Instance", LocalScript = "Script", Script = "LuaSourceContainer", LuaSourceContainer = "Instance",
}
function M.isA(className, target)
	if target == "Instance" then return true end
	local c = className
	while c do
		if c == target then return true end
		c = M.Supers[c]
	end
	return false
end

local W, B = M.Color3.new(1, 1, 1), M.Color3.new(0, 0, 0)
M.Defaults = {
	Instance = { Archivable = true },
	GuiBase2d = { AutoLocalize = true },
	GuiObject = {
		Active = false, AnchorPoint = M.V2(0, 0), BackgroundColor3 = M.Color3.fromRGB(163, 162, 165),
		BackgroundTransparency = 0, BorderColor3 = M.Color3.fromRGB(27, 42, 53), BorderSizePixel = 1,
		ClipsDescendants = false, Interactable = true, LayoutOrder = 0, Position = M.UDim2(0, 0, 0, 0),
		Rotation = 0, Selectable = false, Size = M.UDim2(0, 100, 0, 100), Visible = true, ZIndex = 1,
		SelectionOrder = 0, NextSelectionUp = false, NextSelectionDown = false,
		NextSelectionLeft = false, NextSelectionRight = false, SelectionImageObject = false,
	},
	GuiButton = { AutoButtonColor = true, Modal = false, Selected = false, Selectable = true },
	TextLabel = { Text = "Label" }, TextButton = { Text = "Button" }, TextBox = { Text = "TextBox" },
	ImageLabel = {
		Image = "", ImageColor3 = W, ImageTransparency = 0, ImageRectOffset = M.V2(0, 0),
		ImageRectSize = M.V2(0, 0), SliceScale = 1, TileSize = M.UDim2(1, 0, 1, 0),
	},
	ScrollingFrame = {
		CanvasSize = M.UDim2(0, 0, 2, 0), CanvasPosition = M.V2(0, 0), ScrollBarThickness = 12,
		ScrollBarImageColor3 = M.Color3.fromRGB(0, 0, 0), ScrollBarImageTransparency = 0,
		ScrollingEnabled = true, TopImage = "", MidImage = "", BottomImage = "",
	},
	LayerCollector = { Enabled = true, ResetOnSpawn = true },
	ScreenGui = { IgnoreGuiInset = false, DisplayOrder = 0 },
	UIStroke = { Color = B, Thickness = 1, Transparency = 0, Enabled = true },
	UICorner = { CornerRadius = M.UDim(0, 8) },
	UIGradient = { Color = M.ColorSequence.new(W), Transparency = M.NumberSequence.new(0), Rotation = 0, Offset = M.V2(0, 0), Enabled = true },
	UIPadding = { PaddingTop = M.UDim(0, 0), PaddingBottom = M.UDim(0, 0), PaddingLeft = M.UDim(0, 0), PaddingRight = M.UDim(0, 0) },
	UIScale = { Scale = 1 },
	UIGridStyleLayout = {},
	UIListLayout = { Padding = M.UDim(0, 0), Wraps = false },
	UIGridLayout = { CellPadding = M.UDim2(0, 5, 0, 5), CellSize = M.UDim2(0, 100, 0, 100) },
	UISizeConstraint = { MinSize = M.V2(0, 0), MaxSize = M.V2(math.huge, math.huge) },
	UITextSizeConstraint = { MinTextSize = 1, MaxTextSize = 100 },
	UIAspectRatioConstraint = { AspectRatio = 1 },
	BasePart = { Anchored = false, CanCollide = true, CanTouch = true, CanQuery = true, Transparency = 0, Size = M.V3(4, 1, 2), Color = M.Color3.fromRGB(163, 162, 165) },
	Humanoid = { WalkSpeed = 16, JumpPower = 50, JumpHeight = 7.2, UseJumpPower = true, Health = 100, MaxHealth = 100, HipHeight = 2, PlatformStand = false, Sit = false, AutoRotate = true },
	Camera = { FieldOfView = 70, ViewportSize = M.V2(1920, 1080) },
	Workspace = { Gravity = 196.2, FallenPartsDestroyHeight = -500, DistributedGameTime = 0 },
	Player = { DisplayName = "MockPlayer", UserId = 1, AccountAge = 365 },
	Highlight = { Enabled = true, FillTransparency = 0.5, OutlineTransparency = 0, FillColor = W, OutlineColor = W },
	BodyMover = {},
	Folder = {},
	Tween = {},
}
-- text-ish defaults shared by TextLabel/TextButton/TextBox
M.TextDefaults = {
	TextColor3 = M.Color3.fromRGB(27, 42, 53), TextSize = 14, TextTransparency = 0, TextStrokeTransparency = 1,
	TextStrokeColor3 = B, TextWrapped = false, TextScaled = false, RichText = false, LineHeight = 1,
	MaxVisibleGraphemes = -1, TextFits = true, Font = "<enum:Font.Legacy>", TextXAlignment = "<enum:TextXAlignment.Center>",
	TextYAlignment = "<enum:TextYAlignment.Center>", TextTruncate = "<enum:TextTruncate.None>",
	PlaceholderText = "", PlaceholderColor3 = M.Color3.fromRGB(178, 178, 178), ClearTextOnFocus = true,
	MultiLine = false, TextEditable = true, CursorPosition = 1, SelectionStart = -1, ShowNativeInput = true,
}
M.EnumDefaults = {
	-- property = "Type.Item" resolved lazily (Enum is defined above)
	AutomaticSize = "AutomaticSize.None", SizeConstraint = "SizeConstraint.RelativeXY", BorderMode = "BorderMode.Outline",
	ZIndexBehavior = "ZIndexBehavior.Sibling", ScaleType = "ScaleType.Stretch", ResampleMode = "ResamplerMode.Default",
	ScrollingDirection = "ScrollingDirection.XY", ElasticBehavior = "ElasticBehavior.WhenScrollable",
	AutomaticCanvasSize = "AutomaticSize.None", VerticalScrollBarInset = "ScrollBarInset.None",
	HorizontalScrollBarInset = "ScrollBarInset.None", ApplyStrokeMode = "ApplyStrokeMode.Contextual",
	LineJoinMode = "LineJoinMode.Round", FillDirection = "FillDirection.Vertical",
	HorizontalAlignment = "HorizontalAlignment.Left", VerticalAlignment = "VerticalAlignment.Top",
	SortOrder = "SortOrder.Name", ScreenInsets = "ScreenInsets.CoreUISafeInsets", Style = "ButtonStyle.Custom",
}
M.Events = {}
for w in ([[Changed ChildAdded ChildRemoved DescendantAdded DescendantRemoving AncestryChanged Destroying AttributeChanged
	InputBegan InputChanged InputEnded MouseEnter MouseLeave MouseMoved MouseWheelForward MouseWheelBackward
	TouchTap TouchLongPress TouchPan TouchPinch TouchRotate TouchSwipe SelectionGained SelectionLost
	Activated MouseButton1Click MouseButton1Down MouseButton1Up MouseButton2Click MouseButton2Down MouseButton2Up
	FocusLost Focused ReturnPressedFromOnScreenKeyboard
	Died StateChanged Running Jumping HealthChanged MoveToFinished Touched TouchEnded Seated FreeFalling
	CharacterAdded CharacterRemoving CharacterAppearanceLoaded Chatted Idled PlayerAdded PlayerRemoving
	JumpRequest TouchStarted TouchMoved TextBoxFocused TextBoxFocusReleased WindowFocused WindowFocusReleased LastInputTypeChanged
	Heartbeat RenderStepped Stepped PreRender PreAnimation PreSimulation PostSimulation
	Completed Button1Down Button1Up Button2Down Button2Up Move Idle KeyDown KeyUp WheelForward WheelBackward
	MenuOpened MenuClosed]]):gmatch("%S+") do
	M.Events[w] = true
end

function M.defaultFor(className, k)
	local c = className
	while c do
		local t = M.Defaults[c]
		if t and t[k] ~= nil then return t[k], true end
		c = M.Supers[c]
	end
	if (className == "TextLabel" or className == "TextButton" or className == "TextBox") and M.TextDefaults[k] ~= nil then
		local v = M.TextDefaults[k]
		if type(v) == "string" and v:sub(1, 6) == "<enum:" then
			local ty, it = v:match("<enum:(%w+)%.(%w+)>")
			return M.Enum[ty][it], true
		end
		return v, true
	end
	if M.EnumDefaults[k] and (M.isA(className, "GuiBase2d") or M.isA(className, "UIBase")) then
		local ty, it = M.EnumDefaults[k]:match("(%w+)%.(%w+)")
		return M.Enum[ty][it], true
	end
	return nil, false
end

-- Computed read-only geometry (approximate layout: enough for code that reads it).
M.Viewport = M.V2(1920, 1080)
function M.absSize(inst)
	local d = M.D[inst]
	if not d then return M.V2(0, 0) end
	if M.isA(d.className, "LayerCollector") then return M.Viewport end
	if not M.isA(d.className, "GuiObject") then return M.V2(0, 0) end
	local parent = d.props.Parent
	local ps = parent and M.absSize(parent) or M.Viewport
	local s = inst.Size
	return M.V2(ps.X * s.X.Scale + s.X.Offset, ps.Y * s.Y.Scale + s.Y.Offset)
end
function M.absPos(inst)
	local d = M.D[inst]
	if not d or not M.isA(d.className, "GuiObject") then return M.V2(0, 0) end
	local parent = d.props.Parent
	local pp = parent and M.absPos(parent) or M.V2(0, 0)
	local ps = parent and M.absSize(parent) or M.Viewport
	local p, me, ap = inst.Position, M.absSize(inst), inst.AnchorPoint
	return M.V2(pp.X + ps.X * p.X.Scale + p.X.Offset - ap.X * me.X, pp.Y + ps.Y * p.Y.Scale + p.Y.Offset - ap.Y * me.Y)
end
M.Computed = {
	AbsoluteSize = M.absSize,
	AbsolutePosition = M.absPos,
	AbsoluteRotation = function() return 0 end,
	AbsoluteWindowSize = M.absSize,
	AbsoluteCanvasSize = function(inst) return M.absSize(inst) end,
	AbsoluteContentSize = function(inst)
		local d = M.D[inst]
		local parent = d.props.Parent
		if not parent then return M.V2(0, 0) end
		local w, h = 0, 0
		for _, c in ipairs(M.D[parent].children) do
			if M.isA(M.D[c].className, "GuiObject") and c.Visible then
				local s = M.absSize(c)
				w = math.max(w, s.X)
				h += s.Y
			end
		end
		return M.V2(w, h)
	end,
	TextBounds = function(inst)
		local t = tostring(inst.Text or "")
		local n = utf8.len(t) or #t
		return M.V2(n * inst.TextSize * 0.5, inst.TextSize)
	end,
	ContentText = function(inst) return (tostring(inst.Text or ""):gsub("<[^>]->", "")) end,
}

M.InstMT = { __type = "Instance" }
M.typeNames[M.InstMT] = "Instance"

function M.fullName(inst)
	local parts = {}
	local cur = inst
	while cur and M.D[cur] and M.D[cur].className ~= "DataModel" do
		table.insert(parts, 1, tostring(M.D[cur].props.Name))
		cur = M.D[cur].props.Parent
	end
	return table.concat(parts, ".")
end

function M.notMember(inst, k, level)
	local d = M.D[inst]
	error(("%s is not a valid member of %s \"%s\""):format(tostring(k), d.className, M.fullName(inst)), level or 3)
end

M.InstMT.__index = function(self, k)
	local d = M.D[self]
	local v = d.props[k]
	if v ~= nil then return v end
	if k == "Parent" then return nil end
	local m = (d.methods and d.methods[k]) or M.Methods[k]
	if m then return m end
	if M.Events[k] then return M.signalOf(self, k) end
	if M.Computed[k] then return M.Computed[k](self) end
	local def, has = M.defaultFor(d.className, k)
	if has then return def end
	for _, c in ipairs(d.children) do
		if M.D[c].props.Name == k then return c end
	end
	M.notMember(self, k)
end

M.InstMT.__newindex = function(self, k, v)
	local d = M.D[self]
	if k == "Parent" then return M.setParent(self, v) end
	if M.Methods[k] or M.Events[k] or (d.methods and d.methods[k]) then
		error(("%s is not a valid member of %s \"%s\""):format(tostring(k), d.className, M.fullName(self)), 2)
	end
	if M.Computed[k] then
		error(("Unable to assign property %s. Property is read only"):format(tostring(k)), 2)
	end
	if d.readonly and d.readonly[k] then
		error(("Unable to assign property %s. Property is read only"):format(tostring(k)), 2)
	end
	local old = d.props[k]
	d.props[k] = v
	if old ~= v then
		M.fire(self, "Changed", k)
		if d.propSignals[k] then M.fireSignal(d.propSignals[k]) end
	end
end
M.InstMT.__tostring = function(self) return tostring(M.D[self].props.Name) end

function M.new(className, parent, opts)
	local o = setmetatable({}, M.InstMT)
	M.D[o] = {
		className = className,
		props = { Name = className, ClassName = className },
		children = {},
		signals = {},
		propSignals = {},
		attributes = {},
		destroyed = false,
		isService = opts and opts.service or false,
		methods = opts and opts.methods,
		readonly = { ClassName = true },
	}
	if parent ~= nil then o.Parent = parent end
	M.instanceCount = (M.instanceCount or 0) + 1
	return o
end

function M.descendants(inst, out)
	out = out or {}
	for _, c in ipairs(M.D[inst].children) do
		table.insert(out, c)
		M.descendants(c, out)
	end
	return out
end

function M.setParent(self, parent)
	local d = M.D[self]
	if d.parentLocked then
		error(("The Parent property of %s is locked, current parent: NULL, new parent %s"):format(
			tostring(d.props.Name), parent and tostring(M.D[parent].props.Name) or "NULL"), 3)
	end
	if parent ~= nil and (type(parent) ~= "table" or not M.D[parent]) then
		error("Unable to assign property Parent. Object expected, got " .. M.nativeTypeof(parent), 3)
	end
	if parent == self then error("Attempt to set " .. tostring(d.props.Name) .. " as its own parent", 3) end
	local old = d.props.Parent
	if old == parent then return end
	if old then
		local oc = M.D[old].children
		for i, c in ipairs(oc) do
			if c == self then table.remove(oc, i) break end
		end
		M.fire(old, "ChildRemoved", self)
	end
	d.props.Parent = parent
	if parent then
		table.insert(M.D[parent].children, self)
		M.fire(parent, "ChildAdded", self)
	end
	M.fire(self, "AncestryChanged", self, parent)
	for _, desc in ipairs(M.descendants(self)) do M.fire(desc, "AncestryChanged", self, parent) end
	M.fire(self, "Changed", "Parent")
	if d.propSignals.Parent then M.fireSignal(d.propSignals.Parent) end
end

function M.disconnectAll(inst)
	local d = M.D[inst]
	for _, s in pairs(d.signals) do
		for _, c in ipairs(table.clone(s._list)) do c:Disconnect() end
	end
	for _, s in pairs(d.propSignals) do
		for _, c in ipairs(table.clone(s._list)) do c:Disconnect() end
	end
end

M.Methods = {}
local Mth = M.Methods
function Mth.Destroy(self)
	local d = M.D[self]
	if d.destroyed then return end
	M.fire(self, "Destroying")
	d.destroyed = true
	for _, c in ipairs(table.clone(d.children)) do Mth.Destroy(c) end
	if d.props.Parent ~= nil then M.setParent(self, nil) end
	d.parentLocked = true
	M.disconnectAll(self)
end
function Mth.Remove(self) M.setParent(self, nil) end
function Mth.ClearAllChildren(self)
	for _, c in ipairs(table.clone(M.D[self].children)) do Mth.Destroy(c) end
end
function Mth.Clone(self)
	local d = M.D[self]
	local c = M.new(d.className)
	for k, v in pairs(d.props) do
		if k ~= "Parent" and k ~= "ClassName" then M.D[c].props[k] = v end
	end
	for _, ch in ipairs(d.children) do Mth.Clone(ch).Parent = c end
	return c
end
function Mth.GetChildren(self) return table.clone(M.D[self].children) end
function Mth.GetDescendants(self) return M.descendants(self) end
function Mth.FindFirstChild(self, name, recursive)
	for _, c in ipairs(M.D[self].children) do
		if M.D[c].props.Name == name then return c end
	end
	if recursive then
		for _, c in ipairs(M.D[self].children) do
			local f = Mth.FindFirstChild(c, name, true)
			if f then return f end
		end
	end
	return nil
end
function Mth.FindFirstChildOfClass(self, cls)
	for _, c in ipairs(M.D[self].children) do
		if M.D[c].className == cls then return c end
	end
	return nil
end
function Mth.FindFirstChildWhichIsA(self, cls, recursive)
	for _, c in ipairs(M.D[self].children) do
		if M.isA(M.D[c].className, cls) then return c end
	end
	if recursive then
		for _, c in ipairs(M.D[self].children) do
			local f = Mth.FindFirstChildWhichIsA(c, cls, true)
			if f then return f end
		end
	end
	return nil
end
function Mth.FindFirstAncestor(self, name)
	local p = M.D[self].props.Parent
	while p do
		if M.D[p].props.Name == name then return p end
		p = M.D[p].props.Parent
	end
	return nil
end
function Mth.FindFirstAncestorOfClass(self, cls)
	local p = M.D[self].props.Parent
	while p do
		if M.D[p].className == cls then return p end
		p = M.D[p].props.Parent
	end
	return nil
end
function Mth.FindFirstAncestorWhichIsA(self, cls)
	local p = M.D[self].props.Parent
	while p do
		if M.isA(M.D[p].className, cls) then return p end
		p = M.D[p].props.Parent
	end
	return nil
end
function Mth.WaitForChild(self, name, timeout)
	local c = Mth.FindFirstChild(self, name)
	if c or not coroutine.isyieldable() then return c end
	local deadline = M.now + (timeout or 5)
	while M.now < deadline do
		M.task.wait()
		c = Mth.FindFirstChild(self, name)
		if c then return c end
	end
	if not timeout then
		M.warn(("Infinite yield possible on '%s:WaitForChild(\"%s\")'"):format(M.fullName(self), name))
	end
	return nil
end
function Mth.IsA(self, cls) return M.isA(M.D[self].className, cls) end
function Mth.IsDescendantOf(self, anc)
	local p = M.D[self].props.Parent
	while p do
		if p == anc then return true end
		p = M.D[p].props.Parent
	end
	return false
end
function Mth.IsAncestorOf(self, desc) return Mth.IsDescendantOf(desc, self) end
function Mth.GetFullName(self) return M.fullName(self) end
function Mth.GetPropertyChangedSignal(self, prop)
	local d = M.D[self]
	local s = d.propSignals[prop]
	if not s then
		s = M.newSignal(self, "GetPropertyChangedSignal(" .. tostring(prop) .. ")")
		d.propSignals[prop] = s
	end
	return s
end
function Mth.GetAttribute(self, n) return M.D[self].attributes[n] end
function Mth.SetAttribute(self, n, v)
	M.D[self].attributes[n] = v
	M.fire(self, "AttributeChanged", n)
end
function Mth.GetAttributes(self) return table.clone(M.D[self].attributes) end
function Mth.GetAttributeChangedSignal(self, n) return Mth.GetPropertyChangedSignal(self, "@" .. tostring(n)) end
function Mth.TweenPosition(self, pos) self.Position = pos return true end
function Mth.TweenSize(self, size) self.Size = size return true end
function Mth.TweenSizeAndPosition(self, size, pos) self.Size = size self.Position = pos return true end
function Mth.CaptureFocus(self) M.focused = self M.fire(self, "Focused") end
function Mth.ReleaseFocus(self, enter)
	if M.focused == self then M.focused = nil end
	M.fire(self, "FocusLost", enter == true, nil)
end
function Mth.IsFocused(self) return M.focused == self end
function Mth.GetChildrenOfClass(self, cls)
	local out = {}
	for _, c in ipairs(M.D[self].children) do if M.D[c].className == cls then table.insert(out, c) end end
	return out
end

M.Instance = {
	new = function(className, parent)
		if type(className) ~= "string" then error("invalid argument #1 to 'new' (string expected)", 2) end
		if className == "Tween" or className == "Player" or className == "DataModel" then
			error("Unable to create an Instance of type \"" .. className .. "\"", 2)
		end
		return M.new(className, parent)
	end,
}

-- ════════════════════════════════════════════════════════════════════
-- the world: DataModel + services
-- ════════════════════════════════════════════════════════════════════
M.game = M.new("DataModel")
M.D[M.game].props.Name = "Game"
M.services = {}
function M.service(name, methods)
	local s = M.new(name, nil, { service = true, methods = methods })
	M.D[s].props.Name = name
	M.setParent(s, M.game)
	M.services[name] = s
	return s
end

M.renderSteps = {}
M.Players = M.service("Players", {
	GetPlayers = function() return { M.LocalPlayer } end,
	GetPlayerByUserId = function(_, id) return id == 1 and M.LocalPlayer or nil end,
	GetPlayerFromCharacter = function(_, ch) return ch == M.LocalPlayer.Character and M.LocalPlayer or nil end,
})
M.UserInputService = M.service("UserInputService", {
	GetMouseLocation = function() return M.mouseLocation end,
	IsKeyDown = function(_, kc) return M.keysDown[kc] == true end,
	IsMouseButtonPressed = function() return false end,
	GetFocusedTextBox = function() return M.focused end,
	GetKeysPressed = function() return {} end,
	GetLastInputType = function() return M.Enum.UserInputType.MouseMovement end,
	GetStringForKeyCode = function(_, kc) return kc.Name end,
	GetMouseDelta = function() return M.V2(0, 0) end,
	GetConnectedGamepads = function() return {} end,
	GetNavigationGamepads = function() return {} end,
})
do
	local p = M.D[M.UserInputService].props
	p.TouchEnabled, p.MouseEnabled, p.KeyboardEnabled, p.GamepadEnabled = false, true, true, false
	p.MouseIconEnabled, p.MouseDeltaSensitivity = true, 1
	p.MouseBehavior = M.Enum.MouseBehavior.Default
end
M.RunService = M.service("RunService", {
	IsStudio = function() return false end,
	IsClient = function() return true end,
	IsServer = function() return false end,
	IsRunning = function() return true end,
	IsEdit = function() return false end,
	BindToRenderStep = function(_, name, _, fn) M.renderSteps[name] = fn end,
	UnbindFromRenderStep = function(_, name) M.renderSteps[name] = nil end,
})
M.TweenService = M.service("TweenService", {
	Create = function(_, inst, info, goals)
		if type(inst) ~= "table" or not M.D[inst] then error("Unable to cast value to Object", 2) end
		local tw = M.new("Tween", nil, {
			methods = {
				Play = function(self)
					local d = M.D[self]
					if d.playing then return end
					d.playing = true
					d.props.PlaybackState = M.Enum.PlaybackState.Playing
					for k, v in pairs(d.goals) do
						if not M.D[d.target].destroyed then d.target[k] = v end
					end
					d.token = (d.token or 0) + 1
					local token = d.token
					M.task.delay((d.info.Time or 0) + (d.info.DelayTime or 0), function()
						if d.token == token and d.playing then
							d.playing = false
							d.props.PlaybackState = M.Enum.PlaybackState.Completed
							M.fire(self, "Completed", M.Enum.PlaybackState.Completed)
						end
					end)
				end,
				Cancel = function(self)
					local d = M.D[self]
					if d.playing then
						d.playing = false
						d.props.PlaybackState = M.Enum.PlaybackState.Cancelled
						M.fire(self, "Completed", M.Enum.PlaybackState.Cancelled)
					end
				end,
				Pause = function(self)
					M.D[self].playing = false
					M.D[self].props.PlaybackState = M.Enum.PlaybackState.Paused
				end,
			},
		})
		local d = M.D[tw]
		d.target, d.info, d.goals = inst, info, goals
		d.props.Instance, d.props.TweenInfo, d.props.PlaybackState = inst, info, M.Enum.PlaybackState.Begin
		return tw
	end,
	GetValue = function(_, a) return a end,
})
-- tiny JSON (HttpService:JSONEncode/JSONDecode). Like Roblox: Roblox datatypes
-- (Color3, EnumItem, Instance, ...) encode as null; cyclic tables error.
M.json = {}
function M.json.encode(v, seen)
	local t = type(v)
	if v == nil then return "null" end
	if t == "table" and getmetatable(v) ~= nil then return "null" end
	if t == "table" then
		seen = seen or {}
		if seen[v] then error("tables cannot be cyclic", 0) end
		seen[v] = true
	end
	if t == "boolean" then return tostring(v) end
	if t == "number" then
		if v ~= v or v == math.huge or v == -math.huge then return "null" end
		if math.floor(v) == v and math.abs(v) < 1e15 then return string.format("%d", v) end
		return string.format("%.14g", v)
	end
	if t == "string" then
		return '"' .. v:gsub('[%c"\\]', function(c)
			local map = { ['"'] = '\\"', ["\\"] = "\\\\", ["\n"] = "\\n", ["\r"] = "\\r", ["\t"] = "\\t" }
			return map[c] or string.format("\\u%04x", c:byte())
		end) .. '"'
	end
	if t == "table" then
		if #v > 0 or next(v) == nil then
			local out = {}
			for i = 1, #v do out[i] = M.json.encode(v[i], seen) end
			seen[v] = nil -- shared (non-cyclic) references are fine
			return "[" .. table.concat(out, ",") .. "]"
		end
		local keys = {}
		for k in pairs(v) do table.insert(keys, tostring(k)) end
		table.sort(keys)
		local out = {}
		for _, k in ipairs(keys) do
			local val = v[k]
			if val == nil then val = v[tonumber(k)] end
			table.insert(out, M.json.encode(k) .. ":" .. M.json.encode(val, seen))
		end
		seen[v] = nil
		return "{" .. table.concat(out, ",") .. "}"
	end
	error("Can't convert to JSON: " .. M.nativeTypeof(v), 3)
end
function M.json.decode(s)
	local i = 1
	local function ws() i = s:find("[^ \t\r\n]", i) or #s + 1 end
	local val
	local function str()
		i += 1
		local out = {}
		while true do
			local c = s:sub(i, i)
			if c == "" then error("Can't parse JSON", 0) end
			if c == '"' then i += 1 break end
			if c == "\\" then
				local n = s:sub(i + 1, i + 1)
				local map = { n = "\n", r = "\r", t = "\t", b = "\b", f = "\f", ['"'] = '"', ["\\"] = "\\", ["/"] = "/" }
				if n == "u" then
					table.insert(out, utf8.char(tonumber(s:sub(i + 2, i + 5), 16)))
					i += 6
				else
					table.insert(out, map[n] or n)
					i += 2
				end
			else
				table.insert(out, c)
				i += 1
			end
		end
		return table.concat(out)
	end
	function val()
		ws()
		local c = s:sub(i, i)
		if c == "{" then
			i += 1
			local o = {}
			ws()
			if s:sub(i, i) == "}" then i += 1 return o end
			while true do
				ws()
				local k = str()
				ws()
				i += 1 -- :
				o[k] = val()
				ws()
				local sep = s:sub(i, i)
				i += 1
				if sep == "}" then return o end
			end
		elseif c == "[" then
			i += 1
			local a = {}
			ws()
			if s:sub(i, i) == "]" then i += 1 return a end
			while true do
				table.insert(a, val())
				ws()
				local sep = s:sub(i, i)
				i += 1
				if sep == "]" then return a end
			end
		elseif c == '"' then
			return str()
		elseif s:sub(i, i + 3) == "true" then i += 4 return true
		elseif s:sub(i, i + 4) == "false" then i += 5 return false
		elseif s:sub(i, i + 3) == "null" then i += 4 return nil
		end
		local num = s:match("^-?%d+%.?%d*[eE]?[-+]?%d*", i)
		if not num or num == "" then error("Can't parse JSON", 0) end
		i += #num
		return tonumber(num)
	end
	return val()
end
M.HttpService = M.service("HttpService", {
	JSONEncode = function(_, v) return M.json.encode(v) end,
	JSONDecode = function(_, s) return M.json.decode(s) end,
	GenerateGUID = function(_, wrap)
		M.guid = (M.guid or 0) + 1
		local g = string.format("00000000-0000-4000-8000-%012d", M.guid)
		return wrap == false and g or "{" .. g .. "}"
	end,
	UrlEncode = function(_, s) return (tostring(s):gsub("[^%w%-_%.~]", function(c) return string.format("%%%02X", c:byte()) end)) end,
})
M.GuiService = M.service("GuiService", {
	GetGuiInset = function() return M.V2(0, 36), M.V2(0, 0) end,
	IsTenFootInterface = function() return false end,
})
M.D[M.GuiService].props.MenuIsOpen = false
M.CoreGui = M.service("CoreGui")
M.StarterGui = M.service("StarterGui", {
	SetCore = function() end,
	GetCore = function() return nil end,
	SetCoreGuiEnabled = function() end,
	GetCoreGuiEnabled = function() return true end,
})
M.service("ReplicatedFirst")
M.service("ReplicatedStorage")
M.service("Lighting")
M.service("SoundService")
M.service("Teams")
M.service("ContentProvider", { PreloadAsync = function() end })
M.service("TextService", {
	GetTextSize = function(_, text, size) return M.V2(#tostring(text) * size * 0.5, size) end,
})
M.service("RbxAnalyticsService", { GetClientId = function() return "MOCK-CLIENT-ID-0001" end })
M.service("MarketplaceService", {
	GetProductInfo = function() return { Name = "Mock Place", Creator = { Name = "Mock" } } end,
	UserOwnsGamePassAsync = function() return false end,
})
M.service("TeleportService")
M.service("VirtualUser", { CaptureController = function() end, ClickButton2 = function() end, Button2Down = function() end, Button2Up = function() end })

M.Workspace = M.new("Workspace", nil, { service = true })
M.D[M.Workspace].props.Name = "Workspace"
M.setParent(M.Workspace, M.game)
M.services.Workspace = M.Workspace
M.Camera = M.new("Camera", M.Workspace)
M.D[M.Workspace].props.CurrentCamera = M.Camera
M.D[M.Camera].props.CFrame = M.CFrame.new(0, 10, 0)

M.LocalPlayer = M.new("Player", M.Players, {
	methods = {
		GetMouse = function() return M.Mouse end,
		Kick = function() M.kicked = true end,
		GetFriendsOnline = function() return {} end,
		IsInGroup = function() return false end,
		GetRankInGroup = function() return 0 end,
	},
})
M.D[M.LocalPlayer].props.Name = "MockPlayer"
M.D[M.Players].props.LocalPlayer = M.LocalPlayer
M.PlayerGui = M.new("PlayerGui", M.LocalPlayer)
M.new("Backpack", M.LocalPlayer)
M.Character = M.new("Model", M.Workspace)
M.D[M.Character].props.Name = "MockPlayer"
M.Humanoid = M.new("Humanoid", M.Character, {
	methods = {
		GetState = function() return M.Enum.HumanoidStateType.Running end,
		ChangeState = function() end,
		SetStateEnabled = function() end,
		GetStateEnabled = function() return true end,
		Move = function() end,
		MoveTo = function() end,
		LoadAnimation = function() return { Play = function() end, Stop = function() end } end,
		GetPlayingAnimationTracks = function() return {} end,
		UnequipTools = function() end,
		TakeDamage = function() end,
	},
})
M.D[M.Humanoid].props.MoveDirection = M.V3(0, 0, 0)
M.RootPart = M.new("Part", M.Character)
M.D[M.RootPart].props.Name = "HumanoidRootPart"
M.D[M.RootPart].props.CFrame = M.CFrame.new(0, 3, 0)
M.D[M.RootPart].props.Position = M.V3(0, 3, 0)
M.D[M.RootPart].props.AssemblyLinearVelocity = M.V3(0, 0, 0)
M.D[M.RootPart].props.Velocity = M.V3(0, 0, 0)
M.D[M.LocalPlayer].props.Character = M.Character

M.Mouse = M.new("Mouse")
M.D[M.Mouse].props.X, M.D[M.Mouse].props.Y = 0, 0
M.D[M.Mouse].props.Hit = M.CFrame.new(0, 0, 0)
M.mouseLocation = M.V2(0, 0)
M.keysDown = {}

M.D[M.game].methods = {
	GetService = function(_, name)
		local s = M.services[name]
		if not s then
			if type(name) ~= "string" then error("Unable to cast value to std::string", 2) end
			s = M.service(name)
		end
		return s
	end,
	FindService = function(_, name) return M.services[name] end,
	IsLoaded = function() return true end,
	HttpGet = function(_, url) return M.httpGet(url) end,
	HttpGetAsync = function(_, url) return M.httpGet(url) end,
	BindToClose = function() end,
}
M.D[M.game].methods.getService = M.D[M.game].methods.GetService
M.D[M.game].props.PlaceId = 1818
M.D[M.game].props.GameId = 1818
M.D[M.game].props.JobId = "mock-job"
M.D[M.game].props.Loaded = M.newSignal(M.game, "Loaded")

-- URL -> source. The runner registers RvrseUI under its raw URLs.
M.httpRoutes = {}
function M.httpGet(url)
	for pattern, body in pairs(M.httpRoutes) do
		if tostring(url):find(pattern, 1, true) then return body end
	end
	error("HttpGet blocked by mock (no route): " .. tostring(url), 3)
end

-- ════════════════════════════════════════════════════════════════════
-- input simulation helpers (used by drivers)
-- ════════════════════════════════════════════════════════════════════
M.InputMT = { __type = "InputObject" }
M.typeNames[M.InputMT] = "InputObject"
function M.input(fields)
	local o = M.new("InputObject")
	local p = M.D[o].props
	p.UserInputType = fields.UserInputType or M.Enum.UserInputType.None
	p.UserInputState = fields.UserInputState or M.Enum.UserInputState.Begin
	p.KeyCode = fields.KeyCode or M.Enum.KeyCode.Unknown
	p.Position = fields.Position or M.V3(0, 0, 0)
	p.Delta = fields.Delta or M.V3(0, 0, 0)
	M.D[o].isInput = true
	return o
end
function M.keyPress(keyCode, gameProcessed)
	local io = M.input({ UserInputType = M.Enum.UserInputType.Keyboard, KeyCode = keyCode })
	M.keysDown[keyCode] = true
	M.fire(M.UserInputService, "InputBegan", io, gameProcessed == true)
	io.UserInputState = M.Enum.UserInputState.End
	M.keysDown[keyCode] = nil
	M.fire(M.UserInputService, "InputEnded", io, gameProcessed == true)
end
function M.click(button)
	local d = M.D[button]
	if not d or d.destroyed then error("click on destroyed/unknown instance", 2) end
	local io = M.input({ UserInputType = M.Enum.UserInputType.MouseButton1 })
	M.fire(button, "InputBegan", io)
	M.fire(button, "MouseButton1Down", 0, 0)
	M.fire(button, "MouseButton1Up", 0, 0)
	M.fire(button, "MouseButton1Click")
	M.fire(button, "Activated", io, 1)
	io.UserInputState = M.Enum.UserInputState.End
	M.fire(button, "InputEnded", io)
end
function M.findAll(root, pred)
	local out = {}
	for _, d in ipairs(M.descendants(root)) do
		if pred(d, M.D[d]) then table.insert(out, d) end
	end
	return out
end

-- ════════════════════════════════════════════════════════════════════
-- executor-ish globals + install
-- ════════════════════════════════════════════════════════════════════
M.genv = {}
M.files = {}
M.folders = {}
function M.warn(...)
	local parts = {}
	for i = 1, select("#", ...) do parts[i] = tostring((select(i, ...))) end
	local msg = table.concat(parts, " ")
	table.insert(M.warnings, msg)
	if M.echo then print("WARN: " .. msg) end
end
M.nativePrint = print
function M.print(...)
	local parts = {}
	for i = 1, select("#", ...) do parts[i] = tostring((select(i, ...))) end
	local msg = table.concat(parts, "\t")
	table.insert(M.prints, msg)
	if M.echo then M.nativePrint(msg) end
end

function M.typeof(v)
	local t = type(v)
	if t == "table" then
		local mt = getmetatable(v)
		if mt == M.InstMT then
			local d = M.D[v]
			if d and d.isInput then return "InputObject" end
			return "Instance"
		end
		if mt == M.SignalMT then return "RBXScriptSignal" end
		if mt == M.ConnMT then return "RBXScriptConnection" end
		if mt and M.typeNames[mt] then return M.typeNames[mt] end
		if v == M.Enum then return "Enums" end
	end
	return M.nativeTypeof(v)
end

M.nativeLoadstring = loadstring
M.chunkNames = {}
function M.loadstring(src, chunkname)
	local name = chunkname or M.chunkNames[src] or "=loadstring"
	local f, err = M.nativeLoadstring(src, name)
	return f, err
end

do
	local E = M.env
	E.game, E.Game = M.game, M.game
	E.workspace, E.Workspace = M.Workspace, M.Workspace
	E.Instance, E.Enum = M.Instance, M.Enum
	E.UDim, E.UDim2 = { new = M.UDim }, {
		new = M.UDim2,
		fromOffset = function(x, y) return M.UDim2(0, x or 0, 0, y or 0) end,
		fromScale = function(x, y) return M.UDim2(x or 0, 0, y or 0, 0) end,
	}
	E.Vector2, E.Vector3, E.Color3, E.CFrame = M.Vector2, M.Vector3, M.Color3, M.CFrame
	E.ColorSequence, E.ColorSequenceKeypoint = M.ColorSequence, M.ColorSequenceKeypoint
	E.NumberSequence, E.NumberSequenceKeypoint = M.NumberSequence, M.NumberSequenceKeypoint
	E.NumberRange, E.TweenInfo, E.Rect, E.Font = M.NumberRange, M.TweenInfo, M.Rect, M.Font
	E.Random = {
		new = function(seed)
			local state = seed or 1
			local r = {}
			function r:NextNumber(a, b)
				state = (state * 1103515245 + 12345) % 2147483648
				local x = state / 2147483648
				a, b = a or 0, b or 1
				return a + (b - a) * x
			end
			function r:NextInteger(a, b) return math.floor(self:NextNumber(a, b + 1)) end
			return r
		end,
	}
	E.typeof = M.typeof
	E.task = M.task
	E.wait = function(t) return M.task.wait(t) end
	E.spawn = function(f) return M.task.defer(f) end
	E.delay = function(t, f) return M.task.delay(t, f) end
	E.tick = function() return M.now end
	E.time = function() return M.now end
	E.elapsedTime = function() return M.now end
	E.os = setmetatable({ clock = function() return M.now end }, { __index = os })
	E.warn = M.warn
	E.print = M.print
	E.shared = {}
	E._G = {} -- on Roblox _G is an EMPTY shared table (and the VM checks _G first)
	E.getgenv = function() return M.genv end
	E.getrenv = function() return E._G end
	E.identifyexecutor = function() return "RvrseMock", "1.0" end
	E.getexecutorname = E.identifyexecutor
	E.setclipboard = function(s) M.clipboard = s end
	E.loadstring = M.loadstring
	E.newcclosure = function(f) return f end
	E.cloneref = function(x) return x end
	E.readfile = function(p)
		if M.files[p] == nil then error("file does not exist: " .. tostring(p), 2) end
		return M.files[p]
	end
	E.writefile = function(p, s) M.files[p] = tostring(s) end
	E.appendfile = function(p, s) M.files[p] = (M.files[p] or "") .. tostring(s) end
	E.isfile = function(p) return M.files[p] ~= nil end
	E.isfolder = function(p) return M.folders[p] == true end
	E.makefolder = function(p) M.folders[p] = true end
	E.delfile = function(p) M.files[p] = nil end
	E.listfiles = function(dir)
		local out = {}
		for p in pairs(M.files) do
			if p:sub(1, #dir + 1) == dir .. "/" then table.insert(out, p) end
		end
		table.sort(out)
		return out
	end
	E.settings = function() return { Rendering = { QualityLevel = 1 } } end
	E.UserSettings = function()
		return { GetService = function() return { SavedQualityLevel = 1, MasterVolume = 1 } end }
	end
end

return M
