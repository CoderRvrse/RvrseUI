-- init.lua
-- Main entry point for RvrseUI modular architecture
-- This file aggregates all modules and exposes the public API

-- ============================================
-- ROBLOX SERVICES
-- ============================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

-- ============================================
-- IMPORT ALL MODULES
-- ============================================
local Version = require(script.src.Version)
local Debug = require(script.src.Debug)
local Obfuscation = require(script.src.Obfuscation)
local Theme = require(script.src.Theme)
local Animator = require(script.src.Animator)
local State = require(script.src.State)
local Config = require(script.src.Config)
local UIHelpers = require(script.src.UIHelpers)
local Icons = require(script.src.Icons)
local LucideIcons = require(script.src.LucideIcons)
local Notifications = require(script.src.Notifications)
local Hotkeys = require(script.src.Hotkeys)
local KeySystem = require(script.src.KeySystem)
local WindowManager = require(script.src.WindowManager)
local Particles = require(script.src.Particles)
local TabBuilder = require(script.src.TabBuilder)
local SectionBuilder = require(script.src.SectionBuilder)
local WindowBuilder = require(script.src.WindowBuilder)
local Overlay = require(script.src.Overlay)

local Elements = {
	Button = require(script.src.Elements.Button),
	Toggle = require(script.src.Elements.Toggle),
	Dropdown = require(script.src.Elements.Dropdown),
	Slider = require(script.src.Elements.Slider),
	Keybind = require(script.src.Elements.Keybind),
	TextBox = require(script.src.Elements.TextBox),
	ColorPicker = require(script.src.Elements.ColorPicker),
	Label = require(script.src.Elements.Label),
	Paragraph = require(script.src.Elements.Paragraph),
	Divider = require(script.src.Elements.Divider),
	FilterableList = require(script.src.Elements.FilterableList),
	DropdownLegacy = require(script.src.Elements.DropdownLegacy)
}

-- ============================================
-- INITIALIZE MODULES
-- ============================================

-- Initialize Obfuscation first (generates names on init)
Obfuscation:Initialize()

-- Initialize Theme
Theme:Initialize()

-- Initialize Animator with TweenService
Animator:Initialize(TweenService)

-- Initialize State
State:Initialize()

-- Prepare lightweight logger for configuration module
local function configLogger(...)
	if Debug and Debug.Print then
		Debug:Print(...)
	else
		print("[RvrseUI]", ...)
	end
end

-- Initialize configuration module with required dependencies
Config:Init({
	State = State,
	Theme = Theme,
	dprintf = configLogger
})

-- Initialize UIHelpers with services
UIHelpers:Initialize({
	Animator = Animator,
	Theme = Theme,
	Icons = Icons,
	PlayerGui = PlayerGui
})

-- Initialize LucideIcons (needs HttpService for fetching SVGs)
LucideIcons:Initialize({
	HttpService = HttpService,
	Debug = Debug
})

-- Initialize Icons (needs LucideIcons for lucide:// protocol)
Icons:Initialize({
	LucideIcons = LucideIcons
})

-- Create host ScreenGui for notifications and windows
local host = Instance.new("ScreenGui")
host.Name = Obfuscation.getObfuscatedName("gui")
host.ResetOnSpawn = false
host.IgnoreGuiInset = true
host.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
host.DisplayOrder = 100
host.Parent = PlayerGui

Overlay:Initialize({
	PlayerGui = PlayerGui,
	DisplayOrder = host.DisplayOrder + 10,
	Debug = Debug
})
local overlayLayer = Overlay:GetLayer()

-- Initialize Notifications with host
Notifications:Initialize({
	host = host,
	Theme = Theme,
	Animator = Animator,
	UIHelpers = UIHelpers,
	Icons = Icons
})

-- Initialize Hotkeys with services
Hotkeys:Initialize({
	UIS = UserInputService
})

-- Initialize WindowManager
WindowManager:Initialize()

-- Initialize KeySystem (needs dependencies)
KeySystem:Initialize({
	Theme = Theme,
	Animator = Animator,
	UIHelpers = UIHelpers,
	Debug = Debug,
	Obfuscation = Obfuscation
})

-- Initialize Particles (needs Theme and RunService)
Particles:Initialize({
	Theme = Theme,
	RunService = RunService
})

-- Prepare dependency injection object
local deps = {
	Theme = Theme,
	Animator = Animator,
	State = State,
	Config = Config,
	UIHelpers = UIHelpers,
	Icons = Icons,
	TabBuilder = TabBuilder,
	SectionBuilder = SectionBuilder,
	WindowManager = WindowManager,
	Notifications = Notifications,
	KeySystem = KeySystem,
	Particles = Particles,
	Debug = Debug,
	Obfuscation = Obfuscation,
	Hotkeys = Hotkeys,
	Version = Version,
	Elements = Elements,
	OverlayLayer = overlayLayer,
	Overlay = Overlay,

	-- Services
	UIS = UserInputService,
	GuiService = GuiService,
	RS = RunService,
	RunService = RunService,
	PlayerGui = PlayerGui,
	HttpService = HttpService,
	TweenService = TweenService
}

-- Initialize builders with dependencies
TabBuilder:Initialize(deps)
SectionBuilder:Initialize(deps)
WindowBuilder:Initialize(deps)

-- ============================================
-- MAIN RVRSEUI TABLE
-- ============================================
local RvrseUI = {}

-- Version information
RvrseUI.Version = Version

-- Public state
RvrseUI.NotificationsEnabled = true
RvrseUI.Flags = {}
RvrseUI.Store = State
RvrseUI.UI = Hotkeys

-- Internal state
RvrseUI._windows = {}
RvrseUI._lockListeners = {}
RvrseUI._themeListeners = {}
RvrseUI._savedTheme = nil
RvrseUI._lastWindowPosition = nil
RvrseUI._controllerChipPosition = nil
RvrseUI._obfuscatedNames = Obfuscation.getObfuscatedNames()
RvrseUI._tokenIcon = "lucide://gamepad-2"
RvrseUI._tokenIconColor = nil
RvrseUI._tokenIconFallback = "🎮"

-- Configuration settings
RvrseUI.ConfigurationSaving = false
RvrseUI.ConfigurationFileName = nil
RvrseUI.ConfigurationFolderName = nil
RvrseUI.AutoSaveEnabled = true

local function isIconLike(value)
	if typeof(value) == "string" then
		if value:match("^lucide://") or value:match("^icon://") or value:match("^rbxassetid://") or value:match("^rbxasset://") then
			return true
		end

		local success, length = pcall(utf8.len, value)
		if success and length and length <= 2 then
			return true
		end
	elseif typeof(value) == "number" then
		return true
	end

	return false
end

-- ============================================
-- PUBLIC API METHODS
-- ============================================

-- Create Window (main entry point)
function RvrseUI:CreateWindow(cfg)
	return WindowBuilder:CreateWindow(self, cfg, host)
end

-- Notifications
function RvrseUI:Notify(options, message, duration, notifType)
	if not self.NotificationsEnabled then return end

	local payload

	if typeof(options) == "table" then
		if table.clone then
			payload = table.clone(options)
		else
			payload = {}
			for k, v in pairs(options) do
				payload[k] = v
			end
		end
	else
		payload = {}

		if isIconLike(options) then
			payload.Icon = options
		elseif typeof(options) == "string" then
			payload.Title = options
		elseif typeof(options) == "number" then
			payload.Duration = options
		end

		if typeof(message) == "table" then
			for k, v in pairs(message) do
				payload[k] = v
			end
		elseif typeof(message) == "string" then
			if payload.Icon and not payload.Title then
				payload.Title = message
			elseif payload.Title then
				payload.Message = message
			else
				payload.Title = message
			end
		elseif typeof(message) == "number" then
			payload.Duration = message
		end

		if typeof(duration) == "number" then
			payload.Duration = duration
		elseif typeof(duration) == "string" then
			payload.Type = duration
		end

		if typeof(notifType) == "string" then
			payload.Type = notifType
		elseif typeof(notifType) == "number" then
			payload.Duration = notifType
		end

		if not payload.Title then
			payload.Title = payload.Message or "Notification"
			if payload.Message == payload.Title then
				payload.Message = nil
			end
		end
	end

	payload.Type = payload.Type or "info"

	return Notifications:Notify(payload)
end

function RvrseUI:SetTokenIcon(icon, opts)
	opts = opts or {}

	if opts.Reset then
		self._tokenIcon = "lucide://gamepad-2"
		self._tokenIconColor = nil
		self._tokenIconFallback = "🎮"
	else
		if icon ~= nil then
			self._tokenIcon = icon
		end

		if opts.Color ~= nil then
			if opts.Color == false then
				self._tokenIconColor = nil
			else
				self._tokenIconColor = opts.Color
			end
		end

		if opts.UseThemeColor then
			self._tokenIconColor = nil
		end

		if opts.Fallback ~= nil then
			self._tokenIconFallback = opts.Fallback
		end
	end

	for _, window in ipairs(self._windows) do
		if window and window.SetTokenIcon then
			local windowIcon = self._tokenIcon
			if windowIcon == nil then
				windowIcon = nil
			elseif windowIcon == false then
				windowIcon = false
			end

			local windowOpts = {
				Fallback = self._tokenIconFallback
			}

			if opts.Reset then
				windowOpts.Reset = true
			end

			if self._tokenIconColor then
				windowOpts.Color = self._tokenIconColor
			else
				windowOpts.UseThemeColor = true
			end

			window:SetTokenIcon(windowIcon, windowOpts)
		end
	end

	return self._tokenIcon, self._tokenIconColor, self._tokenIconFallback
end

function RvrseUI:GetTokenIcon()
	return self._tokenIcon, self._tokenIconColor, self._tokenIconFallback
end

-- Destroy all UI
function RvrseUI:Destroy()
	if host and host.Parent then
		host:Destroy()
	end

	if self.UI._toggleTargets then
		table.clear(self.UI._toggleTargets)
	end
	if self._lockListeners then
		table.clear(self._lockListeners)
	end
	if self._themeListeners then
		table.clear(self._themeListeners)
	end

	print("[RvrseUI] All interfaces destroyed")
end

-- Toggle UI visibility
function RvrseUI:ToggleVisibility()
	self.UI:ToggleAllWindows()
end

-- Configuration Management
function RvrseUI:SaveConfiguration()
	return Config:SaveConfiguration(self)
end

function RvrseUI:LoadConfiguration()
	return Config:LoadConfiguration(self)
end

function RvrseUI:SaveConfigAs(profileName)
	return Config:SaveConfigAs(profileName, self)
end

function RvrseUI:LoadConfigByName(profileName)
	return Config:LoadConfigByName(profileName, self)
end

function RvrseUI:_autoSave()
    if self.ConfigurationSaving and Config.AutoSaveEnabled and self.AutoSaveEnabled then
		task.defer(function()
			self:SaveConfiguration()
		end)
	end
end

function RvrseUI:GetLastConfig()
	return Config:GetLastConfig()
end

function RvrseUI:SetConfigProfile(profileName)
	return Config:SetConfigProfile(self, profileName)
end

function RvrseUI:ListProfiles()
	return Config:ListProfiles()
end

function RvrseUI:DeleteProfile(profileName)
	return Config:DeleteProfile(profileName)
end

function RvrseUI:SetAutoSaveEnabled(enabled)
    local state = Config:SetAutoSave(enabled)
    self.AutoSaveEnabled = state
    return state
end

function RvrseUI:IsAutoSaveEnabled()
    return self.AutoSaveEnabled
end

-- Provide notifications module with RvrseUI context for toggle checks
Notifications:SetContext(RvrseUI)

-- Version Information
function RvrseUI:GetVersionInfo()
	return {
		Full = Version.Full,
		Major = Version.Major,
		Minor = Version.Minor,
		Patch = Version.Patch,
		Build = Version.Build,
		Hash = Version.Hash,
		Channel = Version.Channel
	}
end

function RvrseUI:GetVersionString()
	return Version.Full
end

-- Theme Management
function RvrseUI:SetTheme(themeName)
	Theme:Switch(themeName)
	if self.ConfigurationSaving then
		self:_autoSave()
	end
end

function RvrseUI:GetTheme()
	return Theme.Current
end

-- Debug Methods
function RvrseUI:EnableDebug(enabled)
	if Debug then
		if Debug.SetEnabled then
			Debug:SetEnabled(enabled)
		else
			local flag = enabled and true or false
			Debug.Enabled = flag
			Debug.enabled = flag
		end
	end
end

function RvrseUI:IsDebugEnabled()
	if Debug then
		if Debug.IsEnabled then
			return Debug:IsEnabled()
		end
		return not not (Debug.Enabled or Debug.enabled)
	end
	return false
end

-- Window Management
function RvrseUI:GetWindows()
	return self._windows
end

function RvrseUI:MinimizeAll()
	for _, window in ipairs(self._windows) do
		if window.Minimize then
			window:Minimize()
		end
	end
end

function RvrseUI:RestoreAll()
	for _, window in ipairs(self._windows) do
		if window.Restore then
			window:Restore()
		end
	end
end

-- ============================================
-- INITIALIZATION COMPLETE
-- ============================================

print("[RvrseUI] ✅ Modular architecture loaded successfully")
print("[RvrseUI] 📦 Version:", Version.Full)
print("[RvrseUI] 🔨 Build:", Version.Build)
print("[RvrseUI] 🔑 Hash:", Version.Hash)
print("[RvrseUI] 📡 Channel:", Version.Channel)

return RvrseUI
