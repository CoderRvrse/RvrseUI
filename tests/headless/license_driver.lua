-- license_driver.lua — appended after roblox_mock.lua by license_run.js
-- Checks the LUAVM-Rvrse license bridge inside the key window:
--   * a full-lock build has already proved the key to the server (that answer
--     is what decrypted it), so its receipt is taken at its word and the
--     window makes NO second server call;
--   * anything doubtful about that receipt — wrong key, stale, no time stamp,
--     not VALID — falls back to a real server call, exactly as before.
-- Every scenario counts the calls the window makes, so a regression that
-- quietly re-checks every launch fails here.
-- SCENARIOS: receipt,noreceipt,stale,wrongkey,badstatus,unit,freekey,keywindow,keyfooter,dummyparity,savedkey,adlink,adlink_meta
local H = { fails = {} }

function H.check(ok, what)
	if not ok then
		table.insert(H.fails, what)
	end
	return ok
end

function H.log(fmt, ...)
	M.nativePrint("H " .. string.format(fmt, ...))
end

local KEY = "RVRSE-ABCDE-FGHJK-LMNPQ"
local OTHER_KEY = "RVRSE-ZZZZZ-YYYYY-XXXXX"
local VALID_BODY = '{"status":"VALID","tier":"premium","expires_in_seconds":2592000}'

-- Count every call the key window makes to the license server. The executor
-- requester lives in getgenv(), which is where KeySystem looks first.
local calls = 0
local function installHttp(body)
	calls = 0
	M.genv.request = function(req)
		calls = calls + 1
		H.log("server asked: %s", tostring(req and req.Url))
		return { StatusCode = 200, Body = body or VALID_BODY }
	end
end

local function freshReceipt(key, extra)
	local r = {
		status = "VALID",
		key = key,
		build_id = "testbuild",
		tier = "premium",
		expires_in_seconds = 2592000,
		at = os.time(),
	}
	for k, v in pairs(extra or {}) do
		r[k] = v
	end
	return r
end

local function hubSettings()
	return {
		Name = "LicenseTest",
		KeySystem = true,
		KeySettings = {
			Title = "Licensed",
			SaveKey = false,
			License = {
				Endpoint = "https://license.invalid/api/v1/licensing/validate",
				BuildId = "testbuild",
			},
		},
	}
end

local function runProcess()
	local saidOk, saidMsg
	local ok = KeySystem:Process(hubSettings(), function(v, m)
		saidOk, saidMsg = v, m
	end)
	return ok, saidOk, saidMsg
end

-- Load the build. KeySystem is a global in the bundle, so it is reachable
-- here once RvrseUI has run.
local RvrseUI = assert(loadstring(RVRSEUI_SRC, "=RvrseUI"))()
H.check(type(KeySystem) == "table", "the build exposes KeySystem")
H.check(type(KeySystem.ReadLicenseReceipt) == "function", "this build has ReadLicenseReceipt")

if H_SCENARIO == "receipt" then
	-- The case this whole change is about: a full-lock launch costs one call,
	-- not two.
	installHttp()
	M.genv.LUAVM_LICENSE_KEY = KEY
	M.genv.LUAVM_LICENSE_OK = freshReceipt(KEY)
	local ok, saidOk, saidMsg = runProcess()
	H.check(ok == true, "the window let the licensed buyer in")
	H.check(saidOk == true, "the hub was told the key is good")
	H.check(calls == 0, "no server call was made (it made " .. calls .. ")")
	H.log("message: %s", tostring(saidMsg))

elseif H_SCENARIO == "noreceipt" then
	-- No full-lock receipt (a plain VM or source build): ask the server, once.
	installHttp()
	M.genv.LUAVM_LICENSE_KEY = KEY
	M.genv.LUAVM_LICENSE_OK = nil
	local ok = runProcess()
	H.check(ok == true, "the window let the buyer in after asking the server")
	H.check(calls == 1, "the server was asked exactly once (it made " .. calls .. ")")

elseif H_SCENARIO == "stale" then
	-- A receipt from an earlier session must not stand in for a fresh check.
	installHttp()
	M.genv.LUAVM_LICENSE_KEY = KEY
	M.genv.LUAVM_LICENSE_OK = freshReceipt(KEY, { at = os.time() - 600 })
	local ok = runProcess()
	H.check(ok == true, "a stale receipt still ends in a working launch")
	H.check(calls == 1, "a stale receipt is re-checked (calls: " .. calls .. ")")

elseif H_SCENARIO == "wrongkey" then
	-- A receipt for a different key proves nothing about this one.
	installHttp()
	M.genv.LUAVM_LICENSE_KEY = KEY
	M.genv.LUAVM_LICENSE_OK = freshReceipt(OTHER_KEY)
	local ok = runProcess()
	H.check(ok == true, "a mismatched receipt still ends in a working launch")
	H.check(calls == 1, "a receipt for another key is ignored (calls: " .. calls .. ")")

elseif H_SCENARIO == "badstatus" then
	-- Only VALID counts. Anything else goes to the server.
	installHttp()
	M.genv.LUAVM_LICENSE_KEY = KEY
	M.genv.LUAVM_LICENSE_OK = freshReceipt(KEY, { status = "EXPIRED" })
	local ok = runProcess()
	H.check(ok == true, "a non-VALID receipt still ends in a working launch")
	H.check(calls == 1, "a non-VALID receipt is ignored (calls: " .. calls .. ")")

elseif H_SCENARIO == "unit" then
	local function reads(receipt, key)
		return KeySystem:ReadLicenseReceipt(key or KEY, { LUAVM_LICENSE_OK = receipt })
	end

	H.check(KeySystem:ReadLicenseReceipt(KEY, nil) == false, "no environment: refused")
	H.check(KeySystem:ReadLicenseReceipt(KEY, {}) == false, "no receipt at all: refused")
	H.check(reads("not a table") == false, "a receipt that is not a table: refused")
	H.check(reads(freshReceipt(KEY)) == true, "a good fresh receipt: accepted")
	H.check(reads(freshReceipt(KEY, { status = "BANNED" })) == false, "status BANNED: refused")
	-- Built inline, not through freshReceipt: a missing field cannot be
	-- expressed by overriding one with nil.
	H.check(reads({ status = "VALID", key = KEY, expires_in_seconds = 2592000 }) == false,
		"an older build that leaves no time stamp: refused")
	H.check(reads(freshReceipt(KEY, { at = os.time() - 600 })) == false, "ten minutes old: refused")
	H.check(reads(freshReceipt(KEY, { at = os.time() - 120 })) == true, "two minutes old: accepted")
	H.check(reads(freshReceipt(KEY, { at = os.time() + 30 })) == true, "a clock 30s ahead: accepted")
	H.check(reads(freshReceipt(KEY, { at = os.time() + 600 })) == false, "a stamp from the future: refused")
	H.check(reads(freshReceipt(KEY, { key = "" })) == false, "an empty key in the receipt: refused")
	H.check(reads(freshReceipt(OTHER_KEY)) == false, "a receipt for another key: refused")

	-- The same paste-proofing the typed key gets: a receipt whose key arrived
	-- with a trailing newline is still the same key.
	H.check(reads(freshReceipt(KEY .. "\n")) == true, "receipt key with a trailing newline: accepted")
	H.check(reads(freshReceipt(KEY), KEY .. " ") == true, "set key with a trailing space: accepted")

	-- The buyer should still see how long they have left.
	local ok, msg = reads(freshReceipt(KEY))
	H.check(ok == true and type(msg) == "string" and msg:find("Licensed") ~= nil, "it says Licensed")
	H.check(type(msg) == "string" and msg:find("30d") ~= nil, "it says how long is left (" .. tostring(msg) .. ")")

	-- A receipt with no expiry at all is a lifetime key: still accepted.
	local okLife, msgLife = reads({ status = "VALID", key = KEY, at = os.time() })
	H.check(okLife == true, "a lifetime receipt: accepted")
	H.check(msgLife == "Licensed", "a lifetime receipt says plain Licensed (" .. tostring(msgLife) .. ")")

elseif H_SCENARIO == "freekey" then
	-- Free keys paid for by ads. Every answer the licence server can give has
	-- to be mapped, a reply that is not JSON must not take the window down,
	-- and the opt-out must not touch the network at all.
	local lastUrl, hits = nil, 0
	local function answers(body)
		lastUrl, hits = nil, 0
		M.genv.request = function(req)
			hits = hits + 1
			lastUrl = req and req.Url
			return { StatusCode = 200, Body = body }
		end
	end
	local lic = {
		Endpoint = "https://license.invalid/api/v1/licensing/validate",
		BuildId = "testbuild",
	}

	H.check(type(KeySystem.StartFreeKey) == "function", "this build has StartFreeKey")
	H.check(type(KeySystem.ClaimFreeKey) == "function", "this build has ClaimFreeKey")

	-- The free routes are worked out from the endpoint the hub already sets,
	-- so no hub ever has to be told a second URL.
	answers('{"status":"go","loot_url":"https://loot.invalid/x?puid=abc","code":"abc","poll_after":5}')
	local status, data = KeySystem:StartFreeKey(lic)
	H.check(status == "go", "a go answer starts a run (got " .. tostring(status) .. ")")
	H.check(data ~= nil and data.code == "abc", "the code comes back")
	H.check(data ~= nil and data.loot_url == "https://loot.invalid/x?puid=abc", "the link comes back")
	H.check(lastUrl == "https://license.invalid/api/v1/free/start",
		"it asked the free route beside validate (asked " .. tostring(lastUrl) .. ")")

	-- A device that still holds a live free key skips the ads entirely.
	answers('{"status":"ready","key":"RVRSE-FREE1-FREE2-FREE3"}')
	local st2, d2 = KeySystem:StartFreeKey(lic)
	H.check(st2 == "ready", "a device with a live key is handed it straight back")
	H.check(d2 ~= nil and d2.key == "RVRSE-FREE1-FREE2-FREE3", "that key comes back")

	answers('{"status":"off"}')
	H.check(KeySystem:StartFreeKey(lic) == "off", "a server without free keys says off")

	answers('{"status":"slow_down"}')
	H.check(KeySystem:StartFreeKey(lic) == "slow_down", "the rate limit is passed through")

	answers('not json at all')
	H.check(KeySystem:StartFreeKey(lic) == "error", "a reply that is not JSON is an error, not a crash")

	answers('{"status":"go","code":"abc"}')
	H.check(KeySystem:StartFreeKey(lic) == "error", "a go with no link is an error")

	-- Opting out has to cost nothing: no call, and the window shows no button.
	answers('{"status":"go","loot_url":"https://loot.invalid/x","code":"abc"}')
	H.check(KeySystem:StartFreeKey({ Endpoint = lic.Endpoint, FreeKey = false }) == "off",
		"FreeKey = false says off")
	H.check(hits == 0, "FreeKey = false makes no server call (made " .. hits .. ")")

	-- Claiming the key the ads paid for.
	answers('{"status":"waiting"}')
	H.check(KeySystem:ClaimFreeKey("abc", lic) == "waiting", "waiting is passed through")
	H.check(lastUrl == "https://license.invalid/api/v1/free/claim",
		"claim uses the claim route (asked " .. tostring(lastUrl) .. ")")

	answers('{"status":"ready","key":"RVRSE-AAAAA-BBBBB-CCCCC"}')
	local cs, ck = KeySystem:ClaimFreeKey("abc", lic)
	H.check(cs == "ready", "a finished run hands over a key")
	H.check(ck == "RVRSE-AAAAA-BBBBB-CCCCC", "the key comes back whole")

	answers('{"status":"expired"}')
	H.check(KeySystem:ClaimFreeKey("abc", lic) == "expired", "a stale code says expired")

	answers('{"status":"ready"}')
	H.check(KeySystem:ClaimFreeKey("abc", lic) == "error", "ready with no key is an error")

	answers('{"status":"waiting"}')
	H.check(KeySystem:ClaimFreeKey("", lic) == "error", "no code is refused")
	H.check(hits == 0, "no code means no server call (made " .. hits .. ")")

elseif H_SCENARIO == "adlink" or H_SCENARIO == "adlink_meta" then
	-- The ad link has to reach the CLIPBOARD, because that is the only way it
	-- reaches the player: Roblox cannot open a browser, and the window does not
	-- print the link. If the copy silently fails, the player is looking at
	-- "I am done - check now" with nothing to have been done, and no error
	-- anywhere says so. They lose the key and we hear "free keys are broken".
	--
	-- The second half is the regression that prompted this test. The search for
	-- the executor's clipboard function used to read the environment with
	-- rawget, which walks straight past a metatable -- and serving globals
	-- through a metatable on getgenv() is a normal thing for an executor to do.
	-- On one of those, every player saw "could not copy" on an executor that
	-- copies perfectly well.
	local LOOT = "https://loot.invalid/ad?puid=xyz"
	local function keyWindow()
		local W
		local co = coroutine.create(function()
			W = RvrseUI:CreateWindow({
				Name = "AdLinkTest",
				KeySystem = true,
				KeySettings = {
					Title = "AdLinkTest",
					SaveKey = false,
					KickOnFailure = false,
					License = {
						Endpoint = "https://license.invalid/api/v1/licensing/validate",
						FreeKey = true,
					},
				},
			})
		end)
		M.resume(co)
		M.run(3)
		return W
	end
	local function freeButton()
		for _, root in ipairs({ M.PlayerGui, M.CoreGui }) do
			for _, d in ipairs(M.descendants(root)) do
				if M.D[d].props.Name == "FreeKeyButton" then return d end
			end
		end
		return nil
	end

	-- The server offers a run and hands over a link.
	M.genv.request = function(req)
		if req and req.Url and req.Url:find("/free/start", 1, true) then
			return { StatusCode = 200, Body = '{"status":"go","loot_url":"' .. LOOT ..
				'","code":"abc","poll_after":5,"expires_in":14400}' }
		end
		return { StatusCode = 200, Body = '{"status":"pending"}' }
	end

	-- adlink_meta is the regression case: the SAME clipboard function, moved so
	-- that the ONLY way to reach it is through a metatable on getgenv(). It gets
	-- a process of its own because a key window cannot be taken down again from
	-- the outside, and a second window in the same run would find the FIRST
	-- window's button -- which polls instead of starting, copies nothing, and
	-- would fail for a reason that has nothing to do with the clipboard.
	if H_SCENARIO == "adlink_meta" then
		local realSet = M.env.setclipboard
		H.check(type(realSet) == "function", "the harness has no setclipboard to hide")
		M.env.setclipboard, M.env.toclipboard, M.env.set_clipboard = nil, nil, nil
		M.genv.setclipboard, M.genv.toclipboard, M.genv.set_clipboard = nil, nil, nil
		setmetatable(M.genv, { __index = { setclipboard = realSet } })
	end

	keyWindow()
	local btn = freeButton()
	H.check(btn ~= nil, "the key window has no free key button to press")
	M.clipboard = nil
	M.click(btn)
	M.run(4)

	if H_SCENARIO == "adlink_meta" then
		H.check(M.clipboard == LOOT,
			"an executor that serves setclipboard through a metatable got " ..
			tostring(M.clipboard) .. " -- the clipboard search is reading with rawget again")
		H.log("adlink_meta    | ad link copied when the executor serves setclipboard "
			.. "through a metatable")
	else
		H.check(M.clipboard == LOOT, "pressing the free key button put " ..
			tostring(M.clipboard) .. " on the clipboard, not the ad link")
		H.log("adlink         | ad link reached the clipboard")
	end

elseif H_SCENARIO == "keywindow" then
	-- The key window is a window like any other: it has to fit the screen,
	-- move, close, and take everything it started away with it.
	--
	-- Closing it is also the only way out of a key-gated hub, so the window
	-- the hub is handed back must report that close AT ONCE: that call is
	-- what arms a hub's shutdown. While it was a no-op, a player who closed
	-- the key screen left the hub's own loops running with nothing able to
	-- stop them.
	local function find(pred)
		for _, root in ipairs({ M.PlayerGui, M.CoreGui }) do
			for _, d in ipairs(M.descendants(root)) do
				if pred(d, M.D[d]) then return d end
			end
		end
		return nil
	end
	local function named(name)
		return find(function(_, d) return d.props.Name == name end)
	end
	
	-- A touch phone held upright: 381 across, where the window asks for 500.
	local ui = M.D[M.UserInputService].props
	ui.TouchEnabled, ui.MouseEnabled, ui.KeyboardEnabled = true, false, false
	M.Viewport = M.V2(381, 750)
	if workspace.CurrentCamera then
		M.D[workspace.CurrentCamera].props.ViewportSize = M.V2(381, 750)
	end
	
	-- Every key is refused here, and free keys are off: this scenario is
	-- about the window, and the free button would start a watcher.
	M.genv.request = function()
		return { StatusCode = 200, Body = '{"status":"INVALID"}' }
	end
	
	-- Let the library settle whatever it starts on its own first, so the count
	-- below is the KEY WINDOW's doing and nothing else.
	M.run(1)
	local mark = M.frame
	local W, came_back = nil, false
	local co = coroutine.create(function()
		W = RvrseUI:CreateWindow({
			Name = "KeyWindowTest",
			KeySystem = true,
			KeySettings = {
				Title = "KeyWindowTest",
				SaveKey = false,
				KickOnFailure = false,
				License = {
					Endpoint = "https://license.invalid/api/v1/licensing/validate",
					FreeKey = false,
				},
			},
		})
		came_back = true
	end)
	M.resume(co)
	M.run(2)
	
	local container = named("Container")
	local header = named("Header")
	local closeBtn = named("CloseButton")
	H.check(container ~= nil, "the key window opened")
	H.check(closeBtn ~= nil, "the key window has an X")
	H.check(header ~= nil and M.D[header].props.Active == true,
		"the header takes drag input (Active)")
	
	-- It fits the phone it is on: 500 wide does not.
	local scale = find(function(_, d) return d.className == "UIScale" end)
	H.check(scale ~= nil, "the key window has a UIScale to fit the screen with")
	if scale and container then
		local factor = M.D[scale].props.Scale
		local wide = M.D[container].props.Size.X.Offset * factor
		H.check(wide <= 381,
			string.format("it fits across a 381 phone (%d wide, scale %.2f)", wide, factor))
		H.log("fit: %d wide at scale %.2f", wide, factor)
	end
	
	-- Closing it leaves nothing of it behind.
	if closeBtn then
		M.click(closeBtn)
		M.run(2)
	end
	H.check(came_back == true, "CreateWindow came back once the window was closed")
	H.check(container == nil or M.D[container].destroyed == true,
		"the key screen is gone")
	local leaked = #M.liveConns({ since = mark })
	H.check(leaked == 0, leaked .. " connection(s) left running after the key window closed")
	
	-- THE SHUTDOWN. The hub hooks the window it was given; that hook has to
	-- run, because there is no later close to wait for.
	local fired, reason = 0, nil
	H.check(type(W) == "table", "a window object came back")
	if type(W) == "table" and type(W.OnClose) == "function" then
		W:OnClose(function(r)
			fired = fired + 1
			reason = r
		end)
	end
	H.check(fired == 1, "OnClose fired at once (" .. fired .. ") -- this is what arms a hub's shutdown")
	H.check(reason == KeySystem.ClosedReason,
		"it says the player closed the window, not that a key was refused (said " .. tostring(reason) .. ")")
	
elseif H_SCENARIO == "keyfooter" then
	-- The key window's footer: the Discord badge and the build chip.
	--
	-- Two things are being proved, and the second is the point. The first is
	-- that the badge and the chip are there and do what they say. The second is
	-- that the invite is INHERITED: the hub names DiscordInvite once, on
	-- CreateWindow, and the key window honours it WITHOUT it being repeated in
	-- KeySettings. If that ever stops working, a hub author has to name the
	-- invite twice, and the day they update one and not the other the two
	-- windows start handing players different links -- which nobody reports,
	-- they just stop finding the Discord.
	local function find(pred)
		for _, root in ipairs({ M.PlayerGui, M.CoreGui }) do
			for _, d in ipairs(M.descendants(root)) do
				if pred(d, M.D[d]) then return d end
			end
		end
		return nil
	end
	local function named(name)
		return find(function(_, d) return d.props.Name == name end)
	end

	-- Read the version off the library rather than writing it here: a second
	-- copy in the tests is the drift bug again, one file further along.
	local VER = tostring(RvrseUI:GetVersionString()):match("%d+%.%d+%.%d+")
	H.check(VER ~= nil, "could not read RvrseUI's version out of the library")

	local HUB_INVITE = "https://discord.gg/keyfooter-test"
	local BUILD = "4dfd04209ec5b7fa"

	M.genv.request = function()
		return { StatusCode = 200, Body = '{"status":"INVALID"}' }
	end
	M.run(1)

	local co = coroutine.create(function()
		RvrseUI:CreateWindow({
			Name = "KeyFooterTest",
			-- named ONCE, here, and never mentioned in KeySettings below
			DiscordInvite = HUB_INVITE,
			KeySystem = true,
			KeySettings = {
				Title = "KeyFooterTest",
				SaveKey = false,
				KickOnFailure = false,
				License = {
					Endpoint = "https://license.invalid/api/v1/licensing/validate",
					BuildId = BUILD,
					FreeKey = false,
				},
			},
		})
	end)
	M.resume(co)
	M.run(2)

	local chip = named("BuildChip")
	local badge = named("DiscordBadge")
	H.check(named("Container") ~= nil, "the key window opened")
	H.check(chip ~= nil, "the key window has no build chip -- nobody can say which build they are on")
	H.check(badge ~= nil, "the key window has no Discord badge")

	-- The chip names BOTH builds, because they answer different questions.
	local chipText = chip and M.D[chip].props.Text or ""
	H.check(chipText:find(VER, 1, true) ~= nil, string.format(
		"the chip says %q, which does not name RvrseUI's version (%s)", chipText, VER))
	H.check(chipText:find(BUILD:sub(1, 8), 1, true) ~= nil, string.format(
		"the chip says %q, which does not name the hub build %s -- that id is what "
		.. "decides whether a key may open this hub at all", chipText, BUILD:sub(1, 8)))

	-- It has to be big enough to hit and to read, same as the main window's.
	-- AbsoluteSize is computed and read off the INSTANCE; M.D[d].props.AbsoluteSize
	-- is simply nil.
	local cs = chip.AbsoluteSize
	H.check(cs.X > 0 and cs.Y >= 18, string.format(
		"the build chip is %dx%d -- too small to hit or read", cs.X, cs.Y))
	local needed = math.ceil(#chipText * M.D[chip].props.TextSize * 0.55)
	H.check(cs.X >= needed, string.format(
		"the build chip is %d wide but %q at text size %d needs about %d",
		cs.X, chipText, M.D[chip].props.TextSize, needed))

	-- THE INHERITANCE. KeySettings never mentioned an invite.
	M.clipboard = nil
	M.click(badge)
	M.run(1)
	H.check(M.clipboard == HUB_INVITE, string.format(
		"tapping the key window's badge put %s on the clipboard, not the hub's own "
		.. "invite (%s) -- the key window is not inheriting DiscordInvite, so a hub "
		.. "author now has to name it twice", tostring(M.clipboard), HUB_INVITE))

	-- The chip hands over the whole line, because an 11px chip read aloud is
	-- how a support thread gets the build wrong.
	M.clipboard = nil
	M.click(chip)
	M.run(1)
	local copied = tostring(M.clipboard)
	H.check(copied:find(VER, 1, true) ~= nil and copied:find(BUILD, 1, true) ~= nil,
		"tapping the chip copied " .. copied .. " -- it must carry the full version AND "
		.. "the whole hub build id, not the 8 characters the chip shows")

	H.log("keyfooter      | chip %q (%dx%d) | badge copied the hub's own invite | "
		.. "chip copied the full line", chipText, cs.X, cs.Y)

elseif H_SCENARIO == "dummyparity" then
	-- When a key is refused, or the player closes the key window, CreateWindow
	-- hands the hub a DUMMY window so its script does not explode. That only
	-- works if the dummy can do everything a real window can.
	--
	-- It could not. SelectTab was missing, and on a real device (2026-10-28)
	-- closing the key screen printed:
	--
	--   [RvrseUI] Key system: key window closed - window not opened
	--   hub errored on startup: attempt to call missing method 'SelectTab'
	--
	-- Every hub that calls Window:SelectTab died right there -- and anything
	-- it meant to do afterwards, INCLUDING ARMING ITS SHUTDOWN, never ran. So
	-- the crash did not just lose a tab; it lost the no-trace shutdown too.
	local function find(pred)
		for _, root in ipairs({ M.PlayerGui, M.CoreGui }) do
			for _, d in ipairs(M.descendants(root)) do
				if pred(d, M.D[d]) then return d end
			end
		end
		return nil
	end
	
	-- 1. A REAL window, and every method it offers.
	local real = RvrseUI:CreateWindow({ Name = "RealWindow" })
	H.check(type(real) == "table", "a real window was built")
	local realMethods = {}
	local realCount = 0
	if type(real) == "table" then
		for k, v in pairs(real) do
			if type(v) == "function" then
				realMethods[k] = true
				realCount = realCount + 1
			end
		end
	end
	H.check(realCount > 0, "the real window exposes methods to compare against")
	if real and real.Destroy then real:Destroy() end
	M.run(2)
	
	-- 2. The DUMMY, got the way a player gets one: by closing the key window.
	M.genv.request = function()
		return { StatusCode = 200, Body = '{"status":"INVALID"}' }
	end
	local dummy
	local co = coroutine.create(function()
		dummy = RvrseUI:CreateWindow({
			Name = "KeyGated",
			KeySystem = true,
			KeySettings = {
				Title = "KeyGated",
				SaveKey = false,
				KickOnFailure = false,
				License = { Endpoint = "https://license.invalid/v", FreeKey = false },
			},
		})
	end)
	M.resume(co)
	M.run(2)
	local closeBtn = find(function(_, d) return d.props.Name == "CloseButton" end)
	if closeBtn then
		M.click(closeBtn)
		M.run(2)
	end
	H.check(type(dummy) == "table", "a dummy window came back after the key window closed")
	
	-- 3. Parity. This is the whole point.
	local missing = {}
	if type(dummy) == "table" then
		for name in pairs(realMethods) do
			if type(dummy[name]) ~= "function" then
				table.insert(missing, name)
			end
		end
	end
	table.sort(missing)
	H.check(#missing == 0,
		"the dummy window is missing " .. #missing .. " method(s) a real window has: "
		.. table.concat(missing, ", ")
		.. " -- a hub calling one of these CRASHES when a player closes the key window")
	H.log("compared %d real window methods, all present on the dummy", realCount)
	
	-- 4. And they have to be CALLABLE, not merely present.
	if type(dummy) == "table" then
		local failed = {}
		for name in pairs(realMethods) do
			if type(dummy[name]) == "function" then
				local ok = pcall(function() return dummy[name](dummy) end)
				if not ok then table.insert(failed, name) end
			end
		end
		table.sort(failed)
		H.check(#failed == 0,
			"these dummy methods raise when called: " .. table.concat(failed, ", "))
	end
	
elseif H_SCENARIO == "savedkey" then
	-- A REMEMBERED KEY MUST STILL TELL THE HUB.
	--
	-- Every way a key succeeds calls OnKeyValid -- a typed key does, and so
	-- does the getgenv one-key bridge -- except the saved-key path, which
	-- returned true and said nothing. Anything a hub hangs on OnKeyValid
	-- therefore worked on a player's FIRST launch and silently did nothing on
	-- every launch after it, once SaveKey had remembered the key.
	--
	-- That is not hypothetical: the UniversalHub key gate sets
	-- getgenv().LUAVM_LICENSE_KEY from OnKeyValid and then loads the hub. On a
	-- second launch it never heard, never loaded, and left the player looking
	-- at an empty window.
	M.files["RvrseUI/KeySystem/SavedKeyTest.key"] = "RVRSE-SAVED-KEY-0001"

	local asked = {}
	M.genv.request = function(req)
		asked[#asked + 1] = req.Url
		return { StatusCode = 200, Body = '{"status":"VALID","tier":"free"}' }
	end

	local told, toldKey = 0, nil
	local co = coroutine.create(function()
		RvrseUI:CreateWindow({
			Name = "SavedKeyTest",
			KeySystem = true,
			KeySettings = {
				Title = "SavedKeyTest",
				SaveKey = true,
				FileName = "SavedKeyTest",
				License = { Endpoint = "https://license.invalid/api/v1/licensing/validate" },
				OnKeyValid = function(k)
					told = told + 1
					toldKey = k
				end,
			},
		})
	end)
	M.resume(co)
	M.run(3)

	H.check(#asked > 0, "the saved key was checked with the server")
	H.check(told == 1,
		"OnKeyValid fired for the remembered key (" .. told .. ") -- a hub that "
		.. "hangs anything on it must hear about EVERY way a key succeeds")
	H.check(toldKey == "RVRSE-SAVED-KEY-0001",
		"it was told the key itself, not something else (" .. tostring(toldKey) .. ")")

else
	H.check(false, "unknown scenario " .. tostring(H_SCENARIO))
end

if #H.fails == 0 then
	M.nativePrint("HARNESS RESULT PASS")
else
	for _, f in ipairs(H.fails) do
		M.nativePrint("H FAIL: " .. f)
	end
	M.nativePrint("HARNESS RESULT FAIL")
end
