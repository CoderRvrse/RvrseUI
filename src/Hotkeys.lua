-- Hotkeys Module
-- Manages global UI toggle/destroy hotkeys with minimize state tracking
-- Dependencies: UserInputService, coerceKeycode utility

local UIS = game:GetService("UserInputService")

local Hotkeys = {}
Hotkeys.UI = {
	_toggleTargets = {},
	_windowData = {},
	_key = Enum.KeyCode.K,
	_escapeKey = Enum.KeyCode.Escape
}
Hotkeys._initialized = false

-- Diagnostic lines: silent unless RvrseUI:EnableDebug(true) is on
local function dprint(...)
	local dbg = Hotkeys.Debug
	if dbg and dbg.IsEnabled and dbg:IsEnabled() then
		print(...)
	end
end

-- Utility: Convert string/KeyCode to Enum.KeyCode
local function coerceKeycode(k)
	if typeof(k) == "EnumItem" and k.EnumType == Enum.KeyCode then return k end
	if typeof(k) == "string" and #k > 0 then
		local up = k:upper():gsub("%s", "")
		if Enum.KeyCode[up] then return Enum.KeyCode[up] end
	end
	return Enum.KeyCode.K
end

-- Register a window frame for hotkey control
-- windowData: { isMinimized (function/bool), minimizeFunction, restoreFunction, destroyFunction }
function Hotkeys.UI:RegisterToggleTarget(frame, windowData)
	self._toggleTargets[frame] = true
	if windowData then
		self._windowData[frame] = windowData
	end
end

-- Remove a closed window so hotkeys never touch it again
function Hotkeys.UI:UnregisterToggleTarget(frame)
	self._toggleTargets[frame] = nil
	self._windowData[frame] = nil
end

-- Bind the toggle/minimize key (default: K)
function Hotkeys.UI:BindToggleKey(key)
	self._key = coerceKeycode(key or "K")
end

-- Bind the destroy key (default: Escape)
function Hotkeys.UI:BindEscapeKey(key)
	self._escapeKey = coerceKeycode(key or "Escape")
end

function Hotkeys:RegisterToggleTarget(frame, windowData)
	return self.UI:RegisterToggleTarget(frame, windowData)
end

function Hotkeys:UnregisterToggleTarget(frame)
	return self.UI:UnregisterToggleTarget(frame)
end

function Hotkeys:BindToggleKey(key)
	return self.UI:BindToggleKey(key)
end

function Hotkeys:BindEscapeKey(key)
	return self.UI:BindEscapeKey(key)
end

local function handleToggle(self)
	dprint("\n========== [HOTKEY DEBUG] ==========")
	dprint("[HOTKEY] Toggle key processed:", self.UI._key.Name)

	for f in pairs(self.UI._toggleTargets) do
		if f and f.Parent then
			local windowData = self.UI._windowData and self.UI._windowData[f]
			dprint("[HOTKEY] Window found:", f.Name)
			dprint("[HOTKEY] Has windowData:", windowData ~= nil)

			if windowData then
				dprint("[HOTKEY] Has isMinimized function:", windowData.isMinimized ~= nil)
				dprint("[HOTKEY] Has minimizeFunction:", windowData.minimizeFunction ~= nil)
				dprint("[HOTKEY] Has restoreFunction:", windowData.restoreFunction ~= nil)
			end

			if windowData and windowData.isMinimized then
				local minimized
				if type(windowData.isMinimized) == "function" then
					minimized = windowData.isMinimized()
				else
					minimized = (windowData.isMinimized == true)
				end

				dprint("[HOTKEY] Current state - isMinimized:", minimized, "| f.Visible:", f.Visible)

				if minimized == true then
					dprint("[HOTKEY] ✅ ACTION: RESTORE (chip → full window)")
					if windowData.restoreFunction then
						windowData.restoreFunction()
					else
						warn("[RvrseUI] Hotkeys: restoreFunction missing")
					end
				else
					if f.Visible then
						dprint("[HOTKEY] ✅ ACTION: MINIMIZE (full window → chip)")
						if windowData.minimizeFunction then
							windowData.minimizeFunction()
						else
							warn("[RvrseUI] Hotkeys: minimizeFunction missing")
						end
					else
						dprint("[HOTKEY] ✅ ACTION: SHOW (hidden → visible)")
						f.Visible = true
					end
				end
			else
				dprint("[HOTKEY] ⚠️ No minimize tracking - using simple toggle")
				f.Visible = not f.Visible
			end
		end
	end
	dprint("========================================\n")
end

function Hotkeys:ToggleAllWindows()
	handleToggle(self)
end

-- Initialize hotkey listeners
function Hotkeys:Init()
	if self._initialized then
		return
	end
	self._initialized = true

	self._inputConnection = UIS.InputBegan:Connect(function(io, gpe)
		if gpe then return end

		-- ESC KEY: DESTROY the UI completely
		if io.KeyCode == self.UI._escapeKey then
			dprint("\n========== [DESTROY KEY] ==========")
			dprint("[DESTROY] Escape key pressed - destroying UI")

			-- Snapshot first: each destroyFunction unregisters its window
			local targets = {}
			for f in pairs(self.UI._toggleTargets) do
				table.insert(targets, f)
			end
			for _, f in ipairs(targets) do
				if f and f.Parent then
					local windowData = self.UI._windowData and self.UI._windowData[f]
					if windowData and windowData.destroyFunction then
						dprint("[DESTROY] Calling destroy function")
						windowData.destroyFunction()
					else
						dprint("[DESTROY] No destroy function - hiding UI")
						f.Visible = false
					end
				end
			end
			dprint("========================================\n")
			return
		end

		-- TOGGLE KEY: Toggle/Minimize the UI
		if io.KeyCode == self.UI._key then
			handleToggle(self)
		end
	end)
end

-- Stop listening once the last window is gone (Init() starts it again)
function Hotkeys:Teardown()
	if self._inputConnection then
		self._inputConnection:Disconnect()
		self._inputConnection = nil
	end
	table.clear(self.UI._toggleTargets)
	table.clear(self.UI._windowData)
	self._initialized = false
end

-- Initialize method (called by init.lua)
function Hotkeys:Initialize(deps)
	-- Hotkeys system is ready to use
	-- deps contains: UserInputService, WindowManager
	-- Input listeners are set up when BindToggleKey is called
	self.Debug = deps and deps.Debug or self.Debug
	self:Init()
end

return Hotkeys
