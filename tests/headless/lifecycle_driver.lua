-- rvrseui_lifecycle_driver.lua — appended after roblox_mock.lua by the harness runner
-- Builds RvrseUI windows with EVERY element, closes them each supported way,
-- and fails if anything RvrseUI made is still running or still on screen.
-- Works against old builds (no lifecycle API) and new ones (OnClose etc.):
-- scenarios that need the v4.5.0 lifecycle API FAIL on builds without it.
-- SCENARIOS: x,destroy,rvrseui,escape,two,overlays,reopen,togglesoff,track,selecttab
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
	for _, root in ipairs({ M.PlayerGui, M.CoreGui }) do
		for _, c in ipairs(M.D[root].children) do
			if M.D[c].className == "ScreenGui" then n += 1 end
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
local wantsLifecycle = H_SCENARIO == "reopen" or H_SCENARIO == "togglesoff" or H_SCENARIO == "track" or H_SCENARIO == "overlays"
local okBuild = M.runThread(function()
	S.RvrseUI = H.loadRvrseUI()
	local extra = nil
	if H_SCENARIO == "togglesoff" then
		extra = { TurnOffTogglesOnClose = true, ConfigurationSaving = { Enabled = true, FolderName = "H", FileName = "h.json" } }
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
