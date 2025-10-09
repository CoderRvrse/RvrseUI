-- Hotkeys Module
-- Manages global UI toggle/destroy hotkeys with minimize state tracking
-- Dependencies: UserInputService, coerceKeycode utility

local UIS = game:GetService("UserInputService")

local Hotkeys = {}
Hotkeys.UI = { _toggleTargets = {}, _windowData = {}, _key = Enum.KeyCode.K }

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

-- Initialize hotkey listeners
function Hotkeys:Init()
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
			print("\n========== [HOTKEY DEBUG] ==========")
			print("[HOTKEY] Toggle key pressed:", io.KeyCode.Name)

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
						-- CRITICAL FIX: Properly evaluate isMinimized as boolean
						local minimized
						if type(windowData.isMinimized) == "function" then
							minimized = windowData.isMinimized()  -- Call function to get boolean
						else
							minimized = (windowData.isMinimized == true)  -- Ensure boolean comparison
						end

						print("[HOTKEY] Current state - isMinimized:", minimized, "| f.Visible:", f.Visible)

						-- Now minimized is guaranteed to be a boolean (true/false)
						if minimized == true then
							-- Window is minimized to chip, RESTORE it
							print("[HOTKEY] ✅ ACTION: RESTORE (chip → full window)")
							if windowData.restoreFunction then
								windowData.restoreFunction()
							else
								print("[HOTKEY] ❌ ERROR: restoreFunction missing!")
							end
						else
							-- Window is NOT minimized (minimized == false)
							if f.Visible then
								-- Window is visible and open, MINIMIZE it
								print("[HOTKEY] ✅ ACTION: MINIMIZE (full window → chip)")
								if windowData.minimizeFunction then
									windowData.minimizeFunction()
								else
									print("[HOTKEY] ❌ ERROR: minimizeFunction missing!")
								end
							else
								-- Window is hidden, SHOW it
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
	end)
end

-- Initialize method (called by init.lua)
function Hotkeys:Initialize(deps)
	-- Hotkeys system is ready to use
	-- deps contains: UserInputService, WindowManager
	-- Input listeners are set up when BindToggleKey is called
end

return Hotkeys
