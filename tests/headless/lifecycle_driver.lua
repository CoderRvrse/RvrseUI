-- rvrseui_lifecycle_driver.lua — appended after roblox_mock.lua by the harness runner
-- Builds RvrseUI windows with EVERY element, closes them each supported way,
-- and fails if anything RvrseUI made is still running or still on screen.
-- Works against old builds (no lifecycle API) and new ones (OnClose etc.):
-- scenarios that need the v4.5.0 lifecycle API FAIL on builds without it.
-- SCENARIOS: x,destroy,rvrseui,escape,two,overlays,reopen,togglesoff,track,selecttab,quiet,mobile,ontop,ontop_hidden,ontop_coregui,ontop_playergui,discord
local H = { fails = {} }

function H.check(ok, what)
	if not ok then table.insert(H.fails, what) end
	return ok
end

function H.log(fmt, ...)
	M.nativePrint("H " .. string.format(fmt, ...))
end

function H.loadRvrseUI()
	local f = assert(loadstring(RVRSEUI_SRC, "=RvrseUI"))
	return f()
end

-- every element, with the verified field names (examples/RvrseUI-API.md)
function H.buildWindow(RvrseUI, name, extraCfg)
	local cfg = { Name = name, Icon = "lucide://layout-dashboard", Theme = "Dark", ToggleUIKeybind = "K" }
	for k, v in pairs(extraCfg or {}) do cfg[k] = v end
	local W = RvrseUI:CreateWindow(cfg)
	local T = W:CreateTab({ Title = "Main", Icon = "lucide://home" })
	local S = T:CreateSection("Everything")
	local ui = { calls = {} }
	local function log(key, v)
		table.insert(ui.calls, key .. "=" .. tostring(v))
	end
	ui.button = S:CreateButton({ Text = "Button", Callback = function() log("button", true) end })
	ui.toggle = S:CreateToggle({ Text = "Toggle", State = false, Flag = name .. "_t", OnChanged = function(v) log("toggle", v) end })
	ui.slider = S:CreateSlider({ Text = "Slider", Min = 0, Max = 100, Default = 50, Increment = 1, Flag = name .. "_s", OnChanged = function() end })
	ui.dropdown = S:CreateDropdown({ Text = "Dropdown", Values = { "A", "B", "C" }, Flag = name .. "_d", OnChanged = function() end })
	ui.keybind = S:CreateKeybind({ Text = "Keybind", Default = Enum.KeyCode.E, Flag = name .. "_k", OnChanged = function() end })
	ui.textbox = S:CreateTextBox({ Text = "TextBox", Placeholder = "type", Flag = name .. "_tb", OnEnter = function() end })
	ui.color = S:CreateColorPicker({ Text = "Color", Default = Color3.fromRGB(124, 93, 250), Flag = name .. "_c", OnChanged = function() end })
	S:CreateLabel({ Text = "Label" })
	S:CreateParagraph({ Text = "Paragraph" })
	S:CreateDivider()
	if S.CreateFilterableList then
		S:CreateFilterableList({ Text = "List", PlaceholderText = "filter", Items = { { Text = "One" }, { Text = "Two" } }, OnItemClick = function() end })
	end
	local T2 = W:CreateTab({ Title = "Second", Icon = "lucide://settings" })
	ui.toggle2 = T2:CreateSection("More"):CreateToggle({ Text = "Second toggle", State = true, Flag = name .. "_t2", OnChanged = function(v) log("toggle2", v) end })
	ui.tab1, ui.tab2 = T, T2
	return W, ui
end

-- first instance under the UI roots matching pred
function H.find(pred)
	for _, root in ipairs({ M.PlayerGui, M.CoreGui }) do
		for _, d in ipairs(M.descendants(root)) do
			if pred(d, M.D[d]) then return d end
		end
	end
	return nil
end

-- the X that sits next to THIS window's title
function H.findClose(name)
	local title = H.find(function(_, dd) return dd.className == "TextLabel" and dd.props.Text == name end)
	if not title then return nil end
	for _, sib in ipairs(M.D[M.D[title].props.Parent].children) do
		if M.D[sib].props.Name == "CloseButton" then return sib end
	end
	return nil
end

-- an element's card frame (Toggle listens for clicks on the card itself)
function H.findCard(text)
	local lbl = H.find(function(_, dd) return dd.className == "TextLabel" and dd.props.Text == text end)
	return lbl and M.D[lbl].props.Parent or nil
end

-- the button next to an element's label (e.g. the ColorPicker preview)
function H.findButtonBesideLabel(text)
	local lbl = H.find(function(_, dd) return dd.className == "TextLabel" and dd.props.Text == text end)
	if not lbl then return nil end
	for _, sib in ipairs(M.D[M.D[lbl].props.Parent].children) do
		if M.D[sib].className == "TextButton" then return sib end
	end
	return nil
end

-- the window's root frame (the topmost frame under the ScreenGui holding its title)
function H.windowRoot(name)
	local node = H.find(function(_, dd) return dd.className == "TextLabel" and dd.props.Text == name end)
	while node do
		local parent = M.D[node].props.Parent
		if not parent or M.isA(M.D[parent].className, "LayerCollector") then break end
		node = parent
	end
	return node
end

-- the widget (a button or a text box) next to an element's label
function H.widgetBesideLabel(text)
	local lbl = H.find(function(_, dd) return dd.className == "TextLabel" and dd.props.Text == text end)
	if not lbl then return nil, nil end
	for _, sib in ipairs(M.D[M.D[lbl].props.Parent].children) do
		local class = M.D[sib].className
		if class == "TextButton" or class == "TextBox" then return lbl, sib end
	end
	return lbl, nil
end

-- the tab page (ScrollingFrame) holding the element with this label
function H.pageOf(text)
	local inst = H.findCard(text)
	while inst and M.D[inst].className ~= "ScrollingFrame" do
		inst = M.D[inst].props.Parent
	end
	return inst
end

-- how many tab buttons are marked active (exactly 1 while a window is open)
function H.activeTabCount()
	local n = 0
	for _, root in ipairs({ M.PlayerGui, M.CoreGui }) do
		for _, d in ipairs(M.descendants(root)) do
			local dd = M.D[d]
			if dd.className == "TextButton" and dd.attributes and dd.attributes.Active == true then n += 1 end
		end
	end
	return n
end

function H.guiCount()
	local n = 0
	for _, root in ipairs({ M.PlayerGui, M.CoreGui, H.hidden }) do
		for _, c in ipairs(M.D[root].children) do
			-- GameHud = the game's own screen in the ontop_playergui scenario
			if M.D[c].className == "ScreenGui" and M.D[c].props.Name ~= "GameHud" then n += 1 end
		end
	end
	return n
end

function H.census(tag)
	local live = M.liveConns({ src = "RvrseUI" })
	local global, perFrame = 0, 0
	for _, r in ipairs(live) do
		if r.global then global += 1 end
		if r.signal == "Heartbeat" or r.signal == "RenderStepped" then perFrame += 1 end
	end
	H.log("%-14s | RvrseUI connections live=%d (on services=%d, per-frame=%d) | ScreenGuis=%d | errors=%d",
		tag, #live, global, perFrame, H.guiCount(), #M.errors)
	return live
end

function H.dumpLeaks(live)
	local seen, keys = {}, {}
	for _, r in ipairs(live) do
		local key = r.where .. " " .. r.ownerLabel .. "." .. r.signal
		if not seen[key] then table.insert(keys, key) end
		seen[key] = (seen[key] or 0) + 1
	end
	table.sort(keys)
	for _, k in ipairs(keys) do H.log("  LEAK x%d %s", seen[k], k) end
end

function H.hasLifecycle(W)
	return type(W) == "table" and type(W.OnClose) == "function" and type(W.IsDestroyed) == "function" and type(W.Track) == "function"
end

function H.errorsSince(n, tag)
	for i = n + 1, #M.errors do H.log("%s ERROR %s", tag, (M.errors[i]:gsub("\n", " | "))) end
	return #M.errors - n
end

-- everything RvrseUI made must be gone
function H.assertClean(tag)
	local after = H.census(tag)
	H.dumpLeaks(after)
	H.check(#after == 0, #after .. " RvrseUI connection(s) still alive after every window closed")
	H.check(H.guiCount() == 0, H.guiCount() .. " RvrseUI ScreenGui(s) still on screen after close")
end

function H.close(how, W, name, RvrseUI)
	M.runThread(function()
		if how == "x" then
			local x = H.findClose(name)
			if H.check(x ~= nil, "could not find the X for " .. name) then M.click(x) end
		elseif how == "destroy" then
			if H.check(type(W.Destroy) == "function", "Window:Destroy missing") then W:Destroy() end
		elseif how == "rvrseui" then
			RvrseUI:Destroy()
		elseif how == "escape" then
			M.keyPress(Enum.KeyCode.Backspace, false)
		end
	end, 10)
	M.run(2)
end

-- ── run ────────────────────────────────────────────────────────────
M.echo = false -- RvrseUI is chatty; errors are still collected in M.errors
local S = { closeCalls = { 0, 0 } }
-- "mobile": a touch-only phone held sideways (750x381), set up before anything is built.
local MOBILE_INSET = 36 -- what the mock's GuiService:GetGuiInset() says
local function setScreen(w, h)
	M.Viewport = M.V2(w, h)
	local cam = workspace.CurrentCamera
	if cam then M.D[cam].props.ViewportSize = M.V2(w, h) end
end
if H_SCENARIO == "mobile" then
	local p = M.D[M.UserInputService].props
	p.TouchEnabled, p.MouseEnabled, p.KeyboardEnabled = true, false, false
	setScreen(750, 381)
end
-- "ontop*": where RvrseUI's screens go. ontop = the default (PlayerGui, top
-- orders). The others ask for CreateWindow{ AlwaysOnTop = true }: ontop_hidden =
-- an executor with a hidden folder (gethui), ontop_coregui = one without (CoreGui
-- writable), ontop_playergui = a plain game script (CoreGui refused).
local ONTOP = H_SCENARIO == "ontop" or H_SCENARIO == "ontop_hidden" or H_SCENARIO == "ontop_coregui" or H_SCENARIO == "ontop_playergui"
if ONTOP then
	-- a game screen already at the largest order: RvrseUI must not go "one above"
	-- it (Roblox wraps that round to the very bottom)
	local greedy = Instance.new("ScreenGui")
	greedy.Name = "GameHud"
	greedy.DisplayOrder = 2147483647
	greedy.Parent = M.PlayerGui
end
if H_SCENARIO == "ontop_hidden" then
	H.hidden = Instance.new("Folder")
	H.hidden.Name = "HiddenUI"
	H.hidden.Parent = M.CoreGui
	gethui = function() return H.hidden end
elseif H_SCENARIO == "ontop_playergui" then
	M.coreGuiLocked = true
end
-- What the badge copies in this run, and the blurple it is drawn in.
local H_INVITE = "https://discord.gg/harness-test"
local BLURPLE = Color3.fromRGB(88, 101, 242)

local wantsLifecycle = H_SCENARIO == "reopen" or H_SCENARIO == "togglesoff" or H_SCENARIO == "track" or H_SCENARIO == "overlays"
local okBuild = M.runThread(function()
	S.RvrseUI = H.loadRvrseUI()
	local extra = nil
	if H_SCENARIO == "togglesoff" then
		extra = { TurnOffTogglesOnClose = true, ConfigurationSaving = { Enabled = true, FolderName = "H", FileName = "h.json" } }
	elseif ONTOP and H_SCENARIO ~= "ontop" then
		extra = { AlwaysOnTop = true }
	elseif H_SCENARIO == "discord" then
		extra = { DiscordInvite = H_INVITE }
	end
	S.W1, S.ui1 = H.buildWindow(S.RvrseUI, "Harness Hub A", extra)
	if H.hasLifecycle(S.W1) then S.W1:OnClose(function(reason) S.closeCalls[1] += 1 S.reason1 = reason end) end
	S.W1:Show()
	if H_SCENARIO == "two" then
		S.W2, S.ui2 = H.buildWindow(S.RvrseUI, "Harness Hub B")
		if H.hasLifecycle(S.W2) then S.W2:OnClose(function() S.closeCalls[2] += 1 end) end
		S.W2:Show()
	end
end, 60)
H.check(okBuild, "building the window(s) did not finish")
M.run(2)
H.log("RvrseUI %s | lifecycle API: %s", tostring(S.RvrseUI and S.RvrseUI.Version and S.RvrseUI.Version.Full or "?"), tostring(H.hasLifecycle(S.W1)))
H.check(H.errorsSince(0, "BUILD") == 0, "error(s) while building")
local built = H.census("built")
if H_SCENARIO ~= "mobile" then
	-- v4.5.2 fits the window to the screen: a desktop screen still gets the 580x480 window.
	local root = H.windowRoot("Harness Hub A")
	local size = root and root.AbsoluteSize
	H.check(size ~= nil and size.X == 580 and size.Y == 480,
		"desktop window is " .. (size and (size.X .. "x" .. size.Y) or "missing") .. " (want 580x480)")
end
H.check(#built > 0, "no RvrseUI connections at all (harness is not seeing RvrseUI)")
if wantsLifecycle then H.check(H.hasLifecycle(S.W1), "this build has no lifecycle API (Window:OnClose/Track/IsDestroyed)") end
local errorsAtBuild = #M.errors

if H_SCENARIO == "two" then
	H.close("x", S.W1, "Harness Hub A")
	H.census("A closed")
	H.check(H.findClose("Harness Hub B") ~= nil, "closing window A also removed window B")
	if H.hasLifecycle(S.W2) then
		H.check(S.W2:IsDestroyed() == false, "window B reports destroyed after closing A")
		H.check(S.closeCalls[2] == 0, "window B's OnClose fired when A closed")
	end
	-- B still works: its toggle responds
	local before = #S.ui2.calls
	local bToggle = H.findCard("Toggle")
	M.runThread(function() if bToggle then M.click(bToggle) end end, 5)
	M.run(0.5)
	H.check(bToggle ~= nil and #S.ui2.calls > before, "window B's toggle stopped working after A closed")
	H.close("x", S.W2, "Harness Hub B")
elseif H_SCENARIO == "overlays" then
	-- close while the dropdown list and the color-picker panel are OPEN (they
	-- live in the overlay layer, outside the window)
	M.runThread(function()
		S.ui1.dropdown:SetOpen(true)
		local preview = H.findButtonBesideLabel("Color")
		if H.check(preview ~= nil, "could not find the ColorPicker preview") then M.click(preview) end
	end, 5)
	M.run(1)
	H.census("overlays open")
	H.close("x", S.W1, "Harness Hub A")
elseif H_SCENARIO == "reopen" then
	H.close("x", S.W1, "Harness Hub A")
	H.census("first closed")
	H.check(H.guiCount() == 0, "shared ScreenGuis survived the first close")
	-- same RvrseUI, brand-new window: shared services must come back
	M.runThread(function()
		S.W3, S.ui3 = H.buildWindow(S.RvrseUI, "Harness Hub C")
		S.W3:Show()
	end, 30)
	M.run(2)
	H.census("reopened")
	H.check(H.findClose("Harness Hub C") ~= nil, "a window created after closing the first one is not on screen")
	local tgl = H.findCard("Toggle")
	M.runThread(function() if tgl then M.click(tgl) end end, 5)
	M.run(0.5)
	H.check(table.find(S.ui3.calls, "toggle=true") ~= nil, "the reopened window's toggle does not work")
	M.keyPress(Enum.KeyCode.K, false) -- hotkeys must be listening again
	M.run(1)
	H.close("x", S.W3, "Harness Hub C")
elseif H_SCENARIO == "togglesoff" then
	-- turn the first toggle ON by clicking it (toggle2 starts ON)
	local tgl = H.findCard("Toggle")
	M.runThread(function() if H.check(tgl ~= nil, "toggle button not found") then M.click(tgl) end end, 5)
	M.run(1)
	H.check(table.find(S.ui1.calls, "toggle=true") ~= nil, "clicking the toggle did not turn it on")
	local savedBefore = M.files["H/h.json"]
	S.ui1.calls = {}
	H.close("x", S.W1, "Harness Hub A")
	local offs = {}
	for _, c in ipairs(S.ui1.calls) do offs[c] = (offs[c] or 0) + 1 end
	H.log("callbacks fired on close: %s", table.concat(S.ui1.calls, ", "))
	H.check(offs["toggle=false"] == 1, "ON toggle 'Toggle' did not get exactly one OnChanged(false) on close")
	H.check(offs["toggle2=false"] == 1, "ON toggle 'Second toggle' did not get exactly one OnChanged(false) on close")
	H.check(offs["toggle=true"] == nil and offs["toggle2=true"] == nil, "a toggle was turned ON during close")
	H.check(S.RvrseUI:IsAutoSaveEnabled() == true, "closing switched the user's Auto Save preference off")
	local savedAfter = M.files["H/h.json"]
	if not H.check(savedBefore ~= nil, "config was never saved (autosave after the click)") then
		for _, p in ipairs(M.prints) do
			if p:find("FS") or p:find("Save") or p:find("onfig") then H.log("  rvrseui: %s", p) end
		end
		local files = {}
		for k in pairs(M.files) do table.insert(files, k) end
		H.log("  files: %s", table.concat(files, ", "))
		H.log("  RvrseUI.ConfigurationSaving=%s file=%s folder=%s autosave=%s",
			tostring(S.RvrseUI.ConfigurationSaving), tostring(S.RvrseUI.ConfigurationFileName),
			tostring(S.RvrseUI.ConfigurationFolderName), tostring(S.RvrseUI.AutoSaveEnabled))
		M.runThread(function()
			local ok, msg = S.RvrseUI:SaveConfiguration()
			H.log("  manual SaveConfiguration() -> %s %s", tostring(ok), tostring(msg))
		end, 5)
	end
	if savedBefore and savedAfter then
		local data = M.json.decode(savedAfter)
		H.check(data["Harness Hub A_t"] == true, "saved config lost the toggle's ON state after close (" .. tostring(data["Harness Hub A_t"]) .. ")")
	end
elseif H_SCENARIO == "track" then
	local hits = { input = 0, beat = 0, loop = 0, fn = 0 }
	M.runThread(function()
		S.cInput = S.W1:Track(game:GetService("UserInputService").InputBegan:Connect(function() hits.input += 1 end))
		S.cBeat = S.W1:Track(game:GetService("RunService").Heartbeat:Connect(function() hits.beat += 1 end))
		S.loop = S.W1:Track(task.spawn(function()
			while true do
				hits.loop += 1
				task.wait(0.1)
			end
		end))
		S.W1:Track(function() hits.fn += 1 end)
		S.part = S.W1:Track(Instance.new("Part", workspace))
	end, 5)
	M.run(1)
	H.check(hits.beat > 0 and hits.loop > 0, "tracked items were not running before close")
	H.close("x", S.W1, "Harness Hub A")
	local beat, loop = hits.beat, hits.loop
	M.run(1)
	M.keyPress(Enum.KeyCode.F, false)
	H.check(S.cInput.Connected == false and S.cBeat.Connected == false, "a tracked connection is still connected after close")
	H.check(hits.beat == beat and hits.loop == loop and hits.input == 0, "tracked work still ran after close")
	H.check(hits.fn == 1, "tracked cleanup function ran " .. hits.fn .. " times (want 1)")
	H.check(S.part.Parent == nil, "tracked Instance was not destroyed")
	-- registering after close releases immediately / fires immediately
	local late = 0
	M.runThread(function()
		S.W1:Track(function() late += 1 end)
		S.W1:OnClose(function(reason) late += 10 S.lateReason = reason end)
	end, 5)
	M.run(0.2)
	H.check(late == 11, "late Track/OnClose after close did not run right away (" .. late .. ")")
	H.check(S.lateReason == "close-button", "late OnClose got reason " .. tostring(S.lateReason))
elseif H_SCENARIO == "selecttab" then
	-- Window:SelectTab(position | Title | tab object) switches tabs like a click
	local W, ui = S.W1, S.ui1
	local hasSelectTab = type(W.SelectTab) == "function"
	H.check(hasSelectTab, "this build has no Window:SelectTab")
	if hasSelectTab then
		local main, second = H.pageOf("Toggle"), H.pageOf("Second toggle")
		H.check(main ~= nil and second ~= nil and main ~= second, "could not find the two tab pages")
		local function showing()
			return (M.D[main].props.Visible and "main" or "") .. (M.D[second].props.Visible and "second" or "")
		end
		local function try(target, wantResult, wantShowing, what)
			local ok, result
			M.runThread(function() ok, result = pcall(W.SelectTab, W, target) end, 5)
			M.run(0.5)
			H.check(ok, what .. " raised: " .. tostring(result))
			H.check(result == wantResult, what .. " returned " .. tostring(result) .. " (want " .. tostring(wantResult) .. ")")
			H.check(showing() == wantShowing, what .. " left '" .. showing() .. "' showing (want " .. wantShowing .. ")")
			H.check(H.activeTabCount() == 1, what .. " left " .. H.activeTabCount() .. " tabs marked active (want 1)")
		end
		H.check(showing() == "main", "the first tab is not the one showing at start ('" .. showing() .. "')")
		try(2, true, "second", "SelectTab(2)")
		try(1, true, "main", "SelectTab(1)")
		try("Second", true, "second", 'SelectTab("Second")')
		try(ui.tab1, true, "main", "SelectTab(first tab object)")
		try(ui.tab2, true, "second", "SelectTab(second tab object)")
		try(ui.tab2, true, "second", "SelectTab(the tab already showing)")
		-- a target that matches no tab: no error, false, the showing tab stays, one warning each
		local warnings = #M.warnings
		try(99, false, "second", "SelectTab(99)")
		try(0, false, "second", "SelectTab(0)")
		try(1.5, false, "second", "SelectTab(1.5)")
		try("Nope", false, "second", 'SelectTab("Nope")')
		try({}, false, "second", "SelectTab({})")
		try(nil, false, "second", "SelectTab(nil)")
		try(true, false, "second", "SelectTab(true)")
		H.check(#M.warnings - warnings == 7, "7 bad targets gave " .. (#M.warnings - warnings) .. " warnings (want 7)")
	end
	H.close("x", W, "Harness Hub A")
	if hasSelectTab then
		local okLate, late = pcall(W.SelectTab, W, 1)
		H.check(okLate and late == false, "SelectTab after close: " .. tostring(okLate) .. ", " .. tostring(late) .. " (want no error, false)")
	end
elseif H_SCENARIO == "mobile" then
	-- v4.5.2: everything of the window is on a phone's screen, below Roblox's top
	-- bar: sideways (750x381), then the phone turned upright (381x750).
	local function box(inst)
		local p, s = inst.AbsolutePosition, inst.AbsoluteSize
		return p.X, p.Y, p.X + s.X, p.Y + s.Y
	end
	local function fits(tag)
		local root = H.windowRoot("Harness Hub A")
		if not H.check(root ~= nil, tag .. ": no window root") then return 0, 0 end
		local x0, y0, x1, y1 = box(root)
		local v = M.Viewport
		H.log("mobile %-9s| screen %dx%d | window x %d..%d y %d..%d (%dx%d)", tag, v.X, v.Y, x0, x1, y0, y1, x1 - x0, y1 - y0)
		H.check(x0 >= 0 and x1 <= v.X and y0 >= MOBILE_INSET and y1 <= v.Y, tag .. ": the window is not all on the screen below the top bar")
		return x1 - x0, y1 - y0
	end
	local w, h = fits("sideways")
	H.check(w == 580 and h == 381 - MOBILE_INSET - 16, ("sideways: window %dx%d (want 580x%d)"):format(w, h, 381 - MOBILE_INSET - 16))
	do -- centred in the room below the top bar: the same gap above and below
		local _, y0, _, y1 = box(H.windowRoot("Harness Hub A"))
		H.check(math.abs((y0 - MOBILE_INSET) - (M.Viewport.Y - y1)) <= 1,
			("sideways: not centred below the top bar (gap above %d, below %d)"):format(y0 - MOBILE_INSET, M.Viewport.Y - y1))
	end
	-- the key button can be seen: its highlight gradient is off while idle
	local _, keyBtn = H.widgetBesideLabel("Keybind")
	local keyGradient = keyBtn and keyBtn:FindFirstChildOfClass("UIGradient")
	H.check(keyGradient ~= nil and keyGradient.Enabled == false, "the key button is hidden by its highlight gradient")
	-- a tap on the colour swatch: all of the panel is on the screen
	local preview = H.findButtonBesideLabel("Color")
	M.runThread(function() if preview then M.click(preview) end end, 5)
	M.run(1.5)
	local panel = H.find(function(inst, dd) return dd.props.Name == "ColorPickerPanel" and inst.Visible end)
	if H.check(panel ~= nil, "the colour panel did not open") then
		local scale = panel:FindFirstChildOfClass("UIScale")
		local s = scale and scale.Scale or 1
		local x0, y0, x1, y1 = box(panel)
		local cy, half = (y0 + y1) / 2, (y1 - y0) * s / 2
		H.log("mobile panel   | %dx%d at scale %.2f: y %d..%d", x1 - x0, y1 - y0, s, cy - half, cy + half)
		H.check(cy - half >= 0 and cy + half <= M.Viewport.Y and x1 <= M.Viewport.X, "the colour panel runs off the screen")
	end
	M.runThread(function() if preview then M.click(preview) end end, 5)
	M.run(1)
	-- turned upright: the screen changes size and the window is fitted again
	setScreen(381, 750)
	local function sizesChanged()
		for _, d in pairs(M.D) do
			local sig = d.propSignals and d.propSignals.AbsoluteSize
			if sig then M.fireSignal(sig) end
		end
	end
	M.runThread(sizesChanged, 5)
	M.run(0.5)
	M.runThread(sizesChanged, 5) -- and the cards follow the window
	M.run(0.5)
	w, h = fits("upright")
	H.check(w == 381 - 16 and h == 520, ("upright: window %dx%d (want %dx520)"):format(w, h, 381 - 16))
	-- no control covers its own label, and each label keeps some room
	for _, text in ipairs({ "Dropdown", "TextBox", "Keybind" }) do
		local lbl, widget = H.widgetBesideLabel(text)
		if H.check(lbl ~= nil and widget ~= nil, text .. ": label or widget not found") then
			local lx0, _, lx1 = box(lbl)
			local wx0 = box(widget)
			H.log("mobile %-9s| label %d..%d, widget from %d", text, lx0, lx1, wx0)
			H.check(lx1 - lx0 >= 40 and lx1 <= wx0, text .. ": the label is covered by its widget, or squeezed under 40px")
		end
	end
	-- a new window where the last one was left, in the very top-left corner:
	-- it is kept on the screen, below the top bar
	S.RvrseUI._lastWindowPosition = UDim2.fromOffset(0, 0)
	local okSecond = M.runThread(function()
		S.W2 = H.buildWindow(S.RvrseUI, "Harness Hub B")
		if H.hasLifecycle(S.W2) then S.W2:OnClose(function() S.closeCalls[2] += 1 end) end
		S.W2:Show()
	end, 60)
	M.run(1)
	local second = okSecond and H.windowRoot("Harness Hub B")
	if H.check(second ~= nil, "the second window was not built") then
		local x0, y0 = box(second)
		H.log("mobile second  | left where the last was (0,0): now at %d,%d", x0, y0)
		H.check(x0 >= 0 and y0 >= MOBILE_INSET, "a window put where the last one was left sits in the top bar")
		H.close("x", S.W2, "Harness Hub B")
	end

	-- The footer bar has to be BIGGER on a phone than on a desktop, because the
	-- pointer is a thumb. This is the case that prompted the whole redesign: the
	-- old pair of tiles were 16 and 14 pixels tall on every device, and on a real
	-- phone they were reported as "too hard click and read". The desktop sizes
	-- are checked in the `discord` scenario; this is the one that matters.
	local footerHalf = nil
	local mobileRoot = H.windowRoot("Harness Hub A")
	if mobileRoot then
		for _, d in ipairs(M.descendants(mobileRoot)) do
			local dd = M.D[d]
			if dd.className == "TextButton"
				and type(dd.props.Text) == "string"
				and dd.props.Text:match("^v%d+%.%d+%.%d+$") ~= nil then
				footerHalf = d
			end
		end
	end
	H.check(footerHalf ~= nil, "mobile: the window has no version chip")
	local fs = footerHalf and footerHalf.AbsoluteSize
	H.check(fs ~= nil and fs.Y >= 26, string.format(
		"mobile: the footer is only %d tall -- a thumb needs more than a mouse does",
		fs and fs.Y or -1))
	H.log("mobile footer  | version chip %dx%d (desktop is 52x22)", fs.X, fs.Y)

	-- THE INVITE DRAWER HAS TO STAY ON THE SCREEN, IN BOTH ORIENTATIONS.
	--
	-- It normally hangs below the window, which is fine on a desktop and fine
	-- on a phone held upright. Held SIDEWAYS there are about eight pixels
	-- between the window and the bottom of the screen, so a drawer that always
	-- dropped downward would open almost entirely off-screen -- and to the
	-- player that is indistinguishable from a button that does nothing. It is
	-- also the single most likely thing to be wrong on a real Android or iOS
	-- device while every desktop check passes, which is exactly why it is here.
	local mobileBadge = nil
	if mobileRoot then
		for _, d in ipairs(M.descendants(mobileRoot)) do
			if M.D[d].className == "TextButton" and M.D[d].props.BackgroundColor3 == BLURPLE then
				mobileBadge = d
			end
		end
	end
	H.check(mobileBadge ~= nil, "mobile: the window has no Discord badge")

	local mobileDrawer = nil
	if mobileBadge then
		for _, kid in ipairs(M.D[M.D[mobileBadge].props.Parent].children) do
			local kd = M.D[kid]
			if kd.className == "TextLabel" and type(kd.props.Text) == "string"
				and kd.props.Text:find("discord.gg", 1, true) then
				mobileDrawer = kid
			end
		end
	end
	H.check(mobileDrawer ~= nil, "mobile: the Discord badge has no invite drawer")

	-- `want` is "down" or "up": the DIRECTION matters, not only that the drawer
	-- landed somewhere visible. Opening upward is always on-screen, so a change
	-- that made it open upward everywhere would pass every other check here
	-- while quietly undoing the drop-down the bar was redesigned around.
	local function drawerOnScreen(tag, want)
		-- A phone sends no MouseEnter, so the TAP is the only way it ever opens.
		M.click(mobileBadge)
		M.run(1)
		local p, sz = mobileDrawer.AbsolutePosition, mobileDrawer.AbsoluteSize
		local v = M.Viewport
		H.check(sz.Y >= 18, ("%s: tapping the badge did not open the drawer (%d tall)"):format(tag, sz.Y))
		H.check(p.Y >= 0 and p.Y + sz.Y <= v.Y, ("%s: the drawer is off the screen vertically "
			.. "(y %d..%d, screen is %d tall)"):format(tag, p.Y, p.Y + sz.Y, v.Y))
		H.check(p.X >= 0 and p.X + sz.X <= v.X, ("%s: the drawer runs off the side "
			.. "(x %d..%d, screen is %d wide)"):format(tag, p.X, p.X + sz.X, v.X))
		local _, barTop, _, barBottom = box(M.D[mobileBadge].props.Parent)
		local _, _, _, windowBottom = box(mobileRoot)
	local went = p.Y >= barBottom and "down" or "up"
		H.log("mobile drawer  | %-8s drawer %dx%d at y %d..%d (bar %d..%d, window ends %d, screen %d) -> %s",
			tag, sz.X, sz.Y, p.Y, p.Y + sz.Y, barTop, barBottom, windowBottom, v.Y,
			went == "down" and "dropped DOWN" or "flipped UP")
		H.check(went == want, ("%s: the drawer went %s, wanted %s -- with %d pixels below the "
			.. "window and a %d-tall drawer, %s is the only way it stays on screen")
			:format(tag, went, want, v.Y - windowBottom, sz.Y, want))
	end

	-- Upright there is room below, so it must drop DOWN and hang outside the bar.
	drawerOnScreen("upright", "down")

	-- and the cramped one: turned sideways, the window very nearly fills the
	-- screen top to bottom.
	setScreen(750, 381)
	M.runThread(sizesChanged, 5)
	M.run(0.5)
	M.runThread(sizesChanged, 5)
	M.run(0.5)
	drawerOnScreen("sideways", "up")
	H.close("x", S.W1, "Harness Hub A")
elseif ONTOP then
	-- v4.6.0: RvrseUI's screens sit at the top orders (PlayerGui by default, the
	-- hidden folder / CoreGui when asked, stepping aside for Roblox's Esc menu
	-- there), free the mouse while a window is on screen, and draw their own
	-- pointer when the game hid the real one.
	local TOP = 2147483647
	local HOST = TOP - 2
	local want = ({ ontop = M.PlayerGui, ontop_hidden = H.hidden, ontop_coregui = M.CoreGui, ontop_playergui = M.PlayerGui })[H_SCENARIO]
	local wantName = ({ ontop = "PlayerGui", ontop_hidden = "the hidden folder", ontop_coregui = "CoreGui", ontop_playergui = "PlayerGui" })[H_SCENARIO]
	local function named(name)
		return H.find(function(_, dd) return dd.props.Name == name end)
	end
	local function shown(inst)
		return inst ~= nil and inst.Visible == true
	end
	local root = H.windowRoot("Harness Hub A")
	local host = root and root.Parent
	local popovers = named("RvrseUI_Popovers")
	local unlock = named("MouseUnlock")
	local ui = M.D[M.UserInputService].props

	-- where
	H.check(host ~= nil and host.Parent == want, "window screen is in " .. tostring(host and host.Parent and host.Parent.Name) .. " (want " .. wantName .. ")")
	H.check(host ~= nil and host.DisplayOrder == HOST, "window screen order " .. tostring(host and host.DisplayOrder) .. " (want " .. HOST .. ")")
	H.check(popovers ~= nil and popovers.Parent == want, "popovers screen is not in " .. wantName)
	H.check(popovers ~= nil and popovers.DisplayOrder > HOST and popovers.DisplayOrder < TOP,
		"popovers order " .. tostring(popovers and popovers.DisplayOrder) .. " (want above the windows, below " .. TOP .. ")")

	-- the mouse: free while the window is on screen, given back when it goes
	H.check(unlock ~= nil and unlock.Parent == host, "no MouseUnlock button in the window's screen")
	H.check(unlock ~= nil and unlock.Modal == true, "window open but MouseUnlock.Modal is not on")
	H.check(named("RvrseUI_Cursor") == nil, "a pointer screen exists while the game shows its own pointer")

	-- the pointer: the game hides it (first-person) -> ours follows the mouse
	ui.MouseIconEnabled = false
	M.mouseLocation = M.V2(321, 123)
	M.run(0.2)
	local cursorGui = named("RvrseUI_Cursor")
	local pointer = cursorGui and named("Pointer")
	H.check(cursorGui ~= nil and cursorGui.Parent == want, "no pointer screen in " .. wantName .. " after the game hid the pointer")
	H.check(cursorGui ~= nil and cursorGui.DisplayOrder == TOP, "pointer screen order " .. tostring(cursorGui and cursorGui.DisplayOrder) .. " (want " .. TOP .. ")")
	H.check(shown(pointer), "game hid the pointer, window open, but RvrseUI's pointer is not shown")
	local function at(x, y)
		return pointer ~= nil and pointer.Position.X.Offset == x and pointer.Position.Y.Offset == y
	end
	H.check(at(321, 123), "pointer is not at the mouse (321,123)")
	M.mouseLocation = M.V2(40, 300)
	M.run(0.2)
	H.check(at(40, 300), "pointer did not follow the mouse to (40,300)")
	H.check(popovers == nil or popovers.DisplayOrder < TOP, "popovers climbed to the pointer's order (wrap risk)")
	ui.MouseIconEnabled = true
	M.run(0.2)
	H.check(not shown(pointer), "game shows its pointer again but RvrseUI's is still drawn (two pointers)")
	ui.MouseIconEnabled = false
	M.run(0.2)

	-- minimised: the mouse goes back to the game and our pointer goes away
	local frameConns = function()
		local n = 0
		for _, r in ipairs(M.liveConns({ src = "RvrseUI" })) do
			if r.signal == "RenderStepped" then n += 1 end
		end
		return n
	end
	local loopsOpen = frameConns()
	M.keyPress(Enum.KeyCode.K, false)
	M.run(1)
	H.check(root ~= nil and root.Visible == false, "toggle key did not minimise the window")
	H.check(unlock ~= nil and unlock.Modal == false, "window minimised but the mouse is still held free")
	H.check(not shown(pointer), "window minimised but RvrseUI's pointer is still drawn")
	H.check(frameConns() == loopsOpen - 1, "pointer loop still running while minimised (" .. frameConns() .. " vs " .. loopsOpen .. " open)")
	M.keyPress(Enum.KeyCode.K, false)
	M.run(1)
	H.check(root ~= nil and root.Visible == true and unlock ~= nil and unlock.Modal == true, "restored window did not free the mouse again")
	H.check(shown(pointer), "restored window did not show RvrseUI's pointer again")

	-- a touch screen (no mouse): nothing is freed, nothing is drawn
	ui.MouseEnabled = false
	M.keyPress(Enum.KeyCode.K, false)
	M.run(1)
	M.keyPress(Enum.KeyCode.K, false)
	M.run(1)
	H.check(unlock ~= nil and unlock.Modal == false, "no mouse on this device but MouseUnlock.Modal is on")
	H.check(not shown(pointer), "no mouse on this device but RvrseUI's pointer is drawn")
	ui.MouseEnabled = true
	M.keyPress(Enum.KeyCode.K, false)
	M.run(1)
	M.keyPress(Enum.KeyCode.K, false)
	M.run(1)
	H.check(unlock ~= nil and unlock.Modal == true and shown(pointer), "mouse back but the window did not free it / draw the pointer")

	-- Roblox's Esc menu. Out of PlayerGui RvrseUI is above it: every screen steps
	-- aside, then comes back. In PlayerGui the menu is above anyway: nothing moves.
	local screens = { host, popovers, cursorGui }
	local wantHidden = want ~= M.PlayerGui and #screens or 0
	M.fire(M.GuiService, "MenuOpened")
	M.run(0.2)
	local hidden = 0
	for _, g in ipairs(screens) do if g and g.Enabled == false then hidden += 1 end end
	H.check(hidden == wantHidden, hidden .. "/" .. #screens .. " RvrseUI screens stepped aside for the Esc menu (want " .. wantHidden .. ")")
	M.fire(M.GuiService, "MenuClosed")
	M.run(0.2)
	local back = 0
	for _, g in ipairs(screens) do if g and g.Enabled == true then back += 1 end end
	H.check(back == #screens, back .. "/" .. #screens .. " RvrseUI screens on after the Esc menu")
	H.log("ontop          | in %s | window %d, popovers %d, pointer %d | Modal %s | pointer at %d,%d | Esc menu hid %d",
		wantName, host and host.DisplayOrder or -1, popovers and popovers.DisplayOrder or -1,
		cursorGui and cursorGui.DisplayOrder or -1, tostring(unlock and unlock.Modal),
		pointer and pointer.Position.X.Offset or -1, pointer and pointer.Position.Y.Offset or -1, hidden)
	H.close("x", S.W1, "Harness Hub A")
	H.check(named("RvrseUI_Cursor") == nil, "pointer screen left behind after close")
elseif H_SCENARIO == "quiet" then
	-- Diagnostic lines must stay silent unless RvrseUI:EnableDebug(true) is on.
	-- With it off, RvrseUI prints NOTHING. It used to be allowed three "status"
	-- lines, but a status line is still a line in every hub user's console --
	-- "UI visible - all settings applied" was showing up (twice) in real
	-- players' output. They now go through Debug.printf, and the two genuine
	-- failures go through warn(), so this list is deliberately empty: any print
	-- at all with debug off is a regression.
	local STATUS = {}
	local function noise(from)
		local found = {}
		for i = from + 1, #M.prints do
			local status = false
			for _, text in ipairs(STATUS) do
				if M.prints[i]:find(text, 1, true) then status = true end
			end
			if not status then table.insert(found, M.prints[i]) end
		end
		return found
	end
	local function tagged(from, tag)
		local n = 0
		for i = from + 1, #M.prints do
			if M.prints[i]:find(tag, 1, true) then n += 1 end
		end
		return n
	end
	-- what used to print: a list opened and shut, the colour panel opened and
	-- shut, the toggle key (minimise, then restore)
	local function use()
		local preview = H.findButtonBesideLabel("Color")
		H.check(preview ~= nil, "could not find the ColorPicker preview")
		M.runThread(function()
			S.ui1.dropdown:SetOpen(true)
			S.ui1.dropdown:SetOpen(false)
			if preview then M.click(preview) end
		end, 5)
		M.run(1)
		M.runThread(function() if preview then M.click(preview) end end, 5)
		M.run(1)
		M.keyPress(Enum.KeyCode.K, false)
		M.run(1)
		M.keyPress(Enum.KeyCode.K, false)
		M.run(1)
	end
	local function quiet(from, what)
		local found = noise(from)
		for i = 1, math.min(#found, 5) do H.log("  NOISE %s: %s", what, (found[i]:gsub("\n", " "))) end
		H.check(#found == 0, #found .. " line(s) printed " .. what .. " with debug off (want 0)")
		return #found
	end
	H.check(type(S.RvrseUI.EnableDebug) == "function" and S.RvrseUI:IsDebugEnabled() == false, "debug is not off by default")
	local atBuild = quiet(0, "while building")
	local mark = #M.prints
	use()
	local inUse = quiet(mark, "while using the UI")
	-- switched on: the same actions DO report (the lines are gated, not gone)
	S.RvrseUI:EnableDebug(true)
	mark = #M.prints
	use()
	local overlayOn, hotkeyOn = tagged(mark, "[OVERLAY]"), tagged(mark, "[HOTKEY]")
	H.check(overlayOn > 0, "debug on: opening a list printed no [OVERLAY] line")
	H.check(hotkeyOn > 0, "debug on: the toggle key printed no [HOTKEY] line")
	-- and off again: silent again, also through the destroy key
	S.RvrseUI:EnableDebug(false)
	mark = #M.prints
	use()
	H.close("escape", S.W1, "Harness Hub A", S.RvrseUI)
	local afterOff = quiet(mark, "after debug was switched off again")
	H.log("quiet          | debug off: build=%d use=%d | debug on: overlay=%d hotkey=%d | off again + destroy key=%d",
		atBuild, inUse, overlayOn, hotkeyOn, afterOff)
elseif H_SCENARIO == "discord" then
	-- The footer bar: the Discord badge and the version chip, in ONE box, side
	-- by side.
	--
	-- They started life as two separate tiles stacked in the corner, 16 and 14
	-- pixels tall, and on a real phone they were unreadable and nearly
	-- unhittable. So the checks here are mostly about SIZE and ARRANGEMENT:
	-- those are the things that were wrong, and nothing else in the suite looks
	-- at them. A badge that works perfectly and cannot be pressed is still broken.
	local function inWindow(windowName, pred)
		local root = H.windowRoot(windowName)
		if not root then return nil end
		for _, d in ipairs(M.descendants(root)) do
			if pred(d, M.D[d]) then return d end
		end
		return nil
	end
	local function discordIn(windowName)
		return inWindow(windowName, function(_, dd)
			return dd.className == "TextButton" and dd.props.BackgroundColor3 == BLURPLE
		end)
	end
	local function versionIn(windowName)
		return inWindow(windowName, function(_, dd)
			return dd.className == "TextButton"
				and type(dd.props.Text) == "string"
				and dd.props.Text:match("^v%d+%.%d+%.%d+$") ~= nil
		end)
	end
	-- Absolute geometry is COMPUTED by the mock and read off the instance, not
	-- stored in props -- M.D[d].props.AbsolutePosition is simply nil.
	local function box(d)
		return d.AbsolutePosition, d.AbsoluteSize
	end

	local badge = discordIn("Harness Hub A")
	local version = versionIn("Harness Hub A")
	H.check(badge ~= nil, "the window names an invite but has no Discord badge")
	H.check(version ~= nil, "the window has no version chip")

	-- ONE box. This is the whole point of the change: two tiles floating in the
	-- corner read as debris, a single bar reads as part of the window.
	H.check(M.D[badge].props.Parent == M.D[version].props.Parent,
		"the Discord badge and the version chip are not in the same box")

	-- Side by side, not stacked and not overlapping.
	local bp, bs = box(badge)
	local vp, vs = box(version)
	H.check(bp ~= nil and vp ~= nil, "the harness could not measure the footer")
	H.check(math.abs(bp.Y - vp.Y) <= 1, string.format(
		"the two halves are at y %d and %d -- they are stacked, not side by side",
		bp.Y, vp.Y))
	H.check(bp.X + bs.X <= vp.X + 1, string.format(
		"the Discord half (x %d..%d) overlaps the version chip (x %d..%d)",
		bp.X, bp.X + bs.X, vp.X, vp.X + vs.X))

	-- Big enough to press with a thumb, and to read. The old pair were 16 and
	-- 14 tall, which is what prompted all of this.
	H.check(bs.Y >= 20 and vs.Y >= 20, string.format(
		"the footer is only %dx%d / %dx%d -- too small to hit",
		bs.X, bs.Y, vs.X, vs.Y))
	H.check(bs.X >= 24, string.format("the Discord half is %d wide, too narrow to hit", bs.X))
	H.check(vs.X >= 40, string.format("the version chip is %d wide, too narrow to read", vs.X))

	-- Inside the window, at the bottom.
	local rp, rs = box(H.windowRoot("Harness Hub A"))
	H.check(bp.X >= rp.X and bp.Y + bs.Y <= rp.Y + rs.Y + 1,
		"the footer is not inside the window")
	H.check(bp.Y > rp.Y + rs.Y / 2, "the footer is not in the bottom half of the window")

	-- Something has to actually be DRAWN in the Discord half: its own glyph, or
	-- an image it holds. Counting children does not work (corner/stroke add one
	-- each, and so does the joiner), and counting TextLabels underneath does not
	-- either, because createTooltip parents the TOOLTIP to the button.
	local drawsSomething = (M.D[badge].props.Text or "") ~= ""
	for _, kid in ipairs(M.D[badge].children) do
		local kd = M.D[kid]
		if kd.className == "ImageLabel" and (kd.props.Image or "") ~= "" then
			drawsSomething = true
		end
	end
	H.check(drawsSomething, "the Discord badge draws nothing at all -- no icon and no glyph")

	-- The drawer: it must be SHUT until you touch the badge, drop DOWN out of
	-- the bar when you do, show the actual address, and shut again when you
	-- leave. A drawer that is always open is no better than the cramped corner
	-- it replaced, and one that never opens is the state this whole change
	-- exists to get out of -- so both ends are checked, not just the open one.
	local drawer = nil
	for _, kid in ipairs(M.D[M.D[badge].props.Parent].children) do
		local kd = M.D[kid]
		if kd.className == "TextLabel" and type(kd.props.Text) == "string"
			and kd.props.Text:find("discord.gg", 1, true) then
			drawer = kid
		end
	end
	H.check(drawer ~= nil, "the Discord badge has no invite drawer")

	local function drawerHeight() return drawer.AbsoluteSize.Y end
	H.check(drawerHeight() <= 1 and M.D[drawer].props.BackgroundTransparency == 1,
		string.format("the drawer is already open at rest (%d tall)", drawerHeight()))

	M.fire(badge, "MouseEnter")
	M.run(2)
	local openH = drawerHeight()
	H.check(openH >= 18, string.format(
		"hovering the Discord badge opened the drawer to only %d -- it did not drop down", openH))
	H.check(M.D[drawer].props.BackgroundTransparency < 1, "the open drawer is invisible")
	H.check(M.D[drawer].props.Text:find(H_INVITE:gsub("^https://", ""), 1, true) ~= nil,
		"the open drawer does not show the invite, it says: " .. tostring(M.D[drawer].props.Text))

	-- DOWN and OUT: below the bar, hanging past the bottom of the window.
	-- Nothing clips it (root and content both set ClipsDescendants = false),
	-- and there are only 8 pixels between the bar and the edge, so if it ever
	-- starts being clipped this is what notices.
	local fp, fs = box(M.D[badge].props.Parent)
	H.check(drawer.AbsolutePosition.Y >= fp.Y + fs.Y, string.format(
		"the drawer opens at y %d but the bar ends at y %d -- it is not dropping DOWN",
		drawer.AbsolutePosition.Y, fp.Y + fs.Y))
	local wp, ws = box(H.windowRoot("Harness Hub A"))
	H.check(drawer.AbsolutePosition.Y + openH > wp.Y + ws.Y, string.format(
		"the drawer ends at y %d, inside the window (bottom %d) -- it is not hanging OUT",
		drawer.AbsolutePosition.Y + openH, wp.Y + ws.Y))

	M.fire(badge, "MouseLeave")
	M.run(2)
	H.check(drawerHeight() <= 1, string.format(
		"the drawer stayed %d tall after the pointer left", drawerHeight()))

	-- Each half does its own job. The tap has to open the drawer AS WELL as
	-- copy: a phone never sends MouseEnter, so the tap is the only chance the
	-- player gets to be told it worked.
	M.clipboard = nil
	M.click(badge)
	M.run(2)
	H.check(M.clipboard == H_INVITE, "clicking the Discord badge put " ..
		tostring(M.clipboard) .. " on the clipboard, not the invite")
	H.check(drawerHeight() >= 18, string.format(
		"tapping the badge left the drawer %d tall -- a phone gets no hover, so the "
		.. "tap is the only feedback there is", drawerHeight()))
	H.check(M.D[drawer].props.Text:lower():find("copied", 1, true) ~= nil,
		"after copying, the drawer does not say so: " .. tostring(M.D[drawer].props.Text))

	-- A hub that names NOTHING carries the library's own invite. The expected
	-- value is read back out of the source rather than written here, because a
	-- second copy of the invite in the tests is just the drift bug again, one
	-- file further along.
	local DEFAULT = RVRSEUI_SRC:match('local DEFAULT_DISCORD_INVITE = "([^"]*)"')
	H.check(DEFAULT ~= nil,
		"could not find DEFAULT_DISCORD_INVITE in the source -- did it get renamed?")
	H.check(DEFAULT:match("^https://discord%.gg/%w+$") ~= nil,
		"the library default is " .. tostring(DEFAULT) .. ", which is not a Discord invite link")

	local W2 = nil
	local okSecond = M.runThread(function()
		W2 = (H.buildWindow(S.RvrseUI, "Harness Hub B"))
		W2:Show()
	end, 60)
	H.check(okSecond, "building the second window did not finish")
	M.run(2)
	local badge2 = discordIn("Harness Hub B")
	H.check(badge2 ~= nil, "a hub that named no invite got no badge at all")
	M.clipboard = nil
	M.click(badge2)
	M.run(2)
	H.check(M.clipboard == DEFAULT, "a hub that named no invite copied " ..
		tostring(M.clipboard) .. ", not the library default " .. tostring(DEFAULT))

	-- And a hub can refuse it outright. THE VERSION CHIP MUST SURVIVE THAT:
	-- opting out of the Discord badge must not cost the window its version
	-- chip, which every build has always had and now shares a box with.
	local W3 = nil
	local okThird = M.runThread(function()
		W3 = (H.buildWindow(S.RvrseUI, "Harness Hub C", { DiscordInvite = false }))
		W3:Show()
	end, 60)
	H.check(okThird, "building the third window did not finish")
	M.run(2)
	H.check(discordIn("Harness Hub C") == nil,
		"a hub that set DiscordInvite = false still shows a Discord badge")
	local v3 = versionIn("Harness Hub C")
	H.check(v3 ~= nil, "opting out of the Discord badge also removed the version chip")
	local v3p, v3s = box(v3)
	H.check(v3s.Y >= 20 and v3s.X >= 40, string.format(
		"with no Discord half the version chip is %dx%d -- too small", v3s.X, v3s.Y))

	H.log("discord        | one box: discord %dx%d at x %d, version %dx%d at x %d (same y) | "
		.. "hub invite copied | no invite = default (%s) | false = no badge, chip survives %dx%d",
		bs.X, bs.Y, bp.X, vs.X, vs.Y, vp.X, DEFAULT, v3s.X, v3s.Y)
	-- A tap arms a timer that shuts the drawer a couple of seconds later. If
	-- the player closes the hub in between -- which is exactly what someone
	-- does after copying an invite -- that timer still fires, on a window that
	-- no longer exists. This project has shipped a hook onto a dead field
	-- before and heard about it from users, so prove the timer is harmless
	-- rather than assuming the guard is right: tap, close, then sit through
	-- longer than the timer and require that nothing threw.
	local errorsBeforeTimer = #M.errors
	M.click(badge2)
	M.run(0.2)
	H.close("x", W2, "Harness Hub B")
	M.run(4)
	H.check(H.errorsSince(errorsBeforeTimer, "DRAWER-TIMER") == 0,
		"the drawer's close timer threw after its window was destroyed")

	H.close("x", W3, "Harness Hub C")
	H.close("x", S.W1, "Harness Hub A", S.RvrseUI)
else
	H.close(H_SCENARIO, S.W1, "Harness Hub A", S.RvrseUI)
end

H.check(H.errorsSince(errorsAtBuild, "CLOSE") == 0, "error(s) while closing")
H.assertClean("after close")
if H.hasLifecycle(S.W1) then
	H.check(S.W1:IsDestroyed() == true, "Window:IsDestroyed() is false after close")
	H.check(S.closeCalls[1] == 1, "OnClose fired " .. S.closeCalls[1] .. " times (want 1)")
	if S.W2 then H.check(S.closeCalls[2] == 1, "window B OnClose fired " .. S.closeCalls[2] .. " times (want 1)") end
	local wantReason = ({ x = "close-button", destroy = "destroy", rvrseui = "rvrseui-destroy", escape = "destroy-key" })[H_SCENARIO]
	if wantReason then H.check(S.reason1 == wantReason, "OnClose reason " .. tostring(S.reason1) .. " (want " .. wantReason .. ")") end
end

-- a second close (and hotkeys after close) must be harmless
local errorsBeforeAgain = #M.errors
M.runThread(function()
	if S.W1.Destroy then S.W1:Destroy() end
	S.RvrseUI:Destroy()
end, 10)
M.keyPress(Enum.KeyCode.K, false)
M.keyPress(Enum.KeyCode.Backspace, false)
M.run(1)
H.check(H.errorsSince(errorsBeforeAgain, "CLOSE-AGAIN") == 0, "closing again / pressing hotkeys after close errored")
if H.hasLifecycle(S.W1) then H.check(S.closeCalls[1] == 1, "OnClose fired again on the second close") end

if #H.fails == 0 then
	M.nativePrint("HARNESS RESULT PASS")
else
	for _, f in ipairs(H.fails) do M.nativePrint("H FAIL " .. f) end
	M.nativePrint("HARNESS RESULT FAIL")
end
