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

function Hotkeys:BindToggleKey(key)
	return self.UI:BindToggleKey(key)
end

function Hotkeys:BindEscapeKey(key)
	return self.UI:BindEscapeKey(key)
end

local function handleToggle(self)
	print("\n========== [HOTKEY DEBUG] ==========")
	print("[HOTKEY] Toggle key processed:", self.UI._key.Name)

	for f in pairs(self.UI._toggleTargets) do
		if f and f.Parent then
			local windowData = self.UI._windowData and self.UI._windowData[f]
			print("[HOTKEY] Window found:", f.Name)
			print("[HOTKEY] Has windowData:", windowData ~= nil)

			if windowData then
				print("[HOTKEY] Has isMinimized function:", windowData.isMinimized ~= nil)
				print("[HOTKEY] Has minimizeFunction:", windowData.minimizeFunction ~= nil)
				print("[HOTKEY] Has restoreFunction:", windowData.restoreFunction ~= nil)
			end

			if windowData and windowData.isMinimized then
				local minimized
				if type(windowData.isMinimized) == "function" then
					minimized = windowData.isMinimized()
				else
					minimized = (windowData.isMinimized == true)
				end

				print("[HOTKEY] Current state - isMinimized:", minimized, "| f.Visible:", f.Visible)

				if minimized == true then
					print("[HOTKEY] ✅ ACTION: RESTORE (chip → full window)")
					if windowData.restoreFunction then
						windowData.restoreFunction()
					else
						print("[HOTKEY] ❌ ERROR: restoreFunction missing!")
					end
				else
					if f.Visible then
						print("[HOTKEY] ✅ ACTION: MINIMIZE (full window → chip)")
						if windowData.minimizeFunction then
							windowData.minimizeFunction()
						else
							print("[HOTKEY] ❌ ERROR: minimizeFunction missing!")
						end
					else
						print("[HOTKEY] ✅ ACTION: SHOW (hidden → visible)")
						f.Visible = true
					end
				end
			else
				print("[HOTKEY] ⚠️ No minimize tracking - using simple toggle")
				f.Visible = not f.Visible
			end
		end
	end
	print("========================================\n")
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

	UIS.InputBegan:Connect(function(io, gpe)
		if gpe then return end

		-- ESC KEY: DESTROY the UI completely
		if io.KeyCode == self.UI._escapeKey then
			print("\n========== [DESTROY KEY] ==========")
			print("[DESTROY] Escape key pressed - destroying UI")

			for f in pairs(self.UI._toggleTargets) do
				if f and f.Parent then
					local windowData = self.UI._windowData and self.UI._windowData[f]
					if windowData and windowData.destroyFunction then
						print("[DESTROY] Calling destroy function")
						windowData.destroyFunction()
					else
						print("[DESTROY] No destroy function - hiding UI")
						f.Visible = false
					end
				end
			end
			print("========================================\n")
			return
		end

		-- TOGGLE KEY: Toggle/Minimize the UI
		if io.KeyCode == self.UI._key then
			handleToggle(self)
		end
	end)
end

-- Initialize method (called by init.lua)
function Hotkeys:Initialize(deps)
	-- Hotkeys system is ready to use
	-- deps contains: UserInputService, WindowManager
	-- Input listeners are set up when BindToggleKey is called
	self:Init()
end

return Hotkeys
