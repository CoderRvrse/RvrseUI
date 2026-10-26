-- WindowManager Module
-- Manages the root ScreenGui host and global window operations
-- Dependencies: CoreGui, PlayerGui, NameObfuscator

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

local WindowManager = {}

-- Diagnostic lines: silent unless RvrseUI:EnableDebug(true) is on
local function dprint(...)
	local dbg = WindowManager.Debug
	if dbg and dbg.IsEnabled and dbg:IsEnabled() then
		print(...)
	end
end

-- Initialize the WindowManager with dependencies
function WindowManager:Init(obfuscatedNames)
	self._host = nil
	self._windows = {}
	self._obfuscatedNames = obfuscatedNames

	-- Create root ScreenGui host
	self:CreateHost()

	return self._host
end

-- Create the root ScreenGui container
function WindowManager:CreateHost()
	local host = Instance.new("ScreenGui")
	host.Name = self._obfuscatedNames.host  -- Dynamic obfuscation: Changes every launch
	host.ResetOnSpawn = false
	host.IgnoreGuiInset = false  -- CRITICAL: false to respect topbar, prevents offset
	host.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	host.DisplayOrder = 999999999  -- Maximum DisplayOrder to stay on top of everything

	-- Try to parent to CoreGui (requires permission), fallback to PlayerGui
	local success = pcall(function()
		host.Parent = CoreGui
	end)

	if not success then
		warn("[RvrseUI] No CoreGui access, using PlayerGui (may render under some Roblox UI)")
		host.Parent = PlayerGui
	else
		dprint("[RvrseUI] Successfully mounted to CoreGui - guaranteed on top!")
	end

	-- Store global reference for destruction and visibility control
	self._host = host

	return host
end

-- Register a window with the manager
function WindowManager:RegisterWindow(window)
	table.insert(self._windows, window)
end

-- Global destroy method - destroys ALL UI
function WindowManager:Destroy()
	if self._host and self._host.Parent then
		-- Fade out animation for all windows
		for _, window in pairs(self._windows) do
			if window and window.Destroy then
				pcall(function() window:Destroy() end)
			end
		end

		-- Wait for animations
		task.wait(0.3)

		-- Destroy host
		self._host:Destroy()

		-- Clear all references
		table.clear(self._windows)

		dprint("[RvrseUI] All interfaces destroyed - No trace remaining")
		return true
	end
	return false
end

-- Global visibility toggle - hides/shows ALL windows
function WindowManager:ToggleVisibility()
	if self._host and self._host.Parent then
		self._host.Enabled = not self._host.Enabled
		return self._host.Enabled
	end
	return false
end

-- Set visibility explicitly
function WindowManager:SetVisibility(visible)
	if self._host and self._host.Parent then
		self._host.Enabled = visible
		return true
	end
	return false
end

-- Get the host ScreenGui
function WindowManager:GetHost()
	return self._host
end

-- Get all registered windows
function WindowManager:GetWindows()
	return self._windows
end

-- Clear specific listeners (for cleanup)
function WindowManager:ClearListeners(lockListeners, themeListeners, toggleTargets)
	if toggleTargets then
		table.clear(toggleTargets)
	end
	if lockListeners then
		table.clear(lockListeners)
	end
	if themeListeners then
		table.clear(themeListeners)
	end
end

-- Initialize method (called by init.lua)
-- opts is optional so older callers keep working; it carries Debug so this
-- module's diagnostic lines can be gated like every other module's.
function WindowManager:Initialize(opts)
	self.Debug = (opts and opts.Debug) or self.Debug
	-- WindowManager is ready to use
	-- _host and _windows will be set when CreateHost is called
end

return WindowManager
