#!/usr/bin/env lua
-- build.lua
-- Compiles all modular files from src/ into a single RvrseUI.lua file
-- Usage: lua build.lua

print("🔨 RvrseUI v3.0.4 Build Script")
print("=" .. string.rep("=", 50))

local function readFile(path)
	local file = io.open(path, "r")
	if not file then
		error("Failed to read file: " .. path)
	end
	local content = file:read("*all")
	file:close()
	return content
end

local function writeFile(path, content)
	local file = io.open(path, "w")
	if not file then
		error("Failed to write file: " .. path)
	end
	file:write(content)
	file:close()
end

-- Header for compiled file
local header = [[-- RvrseUI v3.0.4 | Modern Professional UI Framework
-- Compiled from modular architecture on ]] .. os.date("%Y-%m-%d %H:%M:%S") .. [[

-- Features: Glassmorphism, Spring Animations, Mobile-First Responsive, Touch-Optimized
-- API: CreateWindow → CreateTab → CreateSection → {All 12 Elements}
-- Extras: Notify system, Theme switcher, LockGroup system, Drag-to-move, Auto-scaling

-- 🏗️ ARCHITECTURE: This file is compiled from 26 modular files
-- Source: https://github.com/CoderRvrse/RvrseUI/tree/main/src
-- For modular version, use: require(script.init) instead of this file

]]

-- Roblox services (needed at top)
local services = [[
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")
local Mouse = LP:GetMouse()

local RvrseUI = {}

]]

print("📂 Reading module files...")

-- Order matters! Dependencies must be loaded first
local moduleOrder = {
	-- Foundation
	"src/Version.lua",
	"src/Debug.lua",
	"src/Obfuscation.lua",

	-- Data
	"src/Icons.lua",
	"src/Theme.lua",

	-- Systems
	"src/Animator.lua",
	"src/State.lua",
	"src/UIHelpers.lua",

	-- Services
	"src/Config.lua",
	"src/WindowManager.lua",
	"src/Hotkeys.lua",
	"src/Notifications.lua",

	-- Elements
	"src/Elements/Button.lua",
	"src/Elements/Toggle.lua",
	"src/Elements/Dropdown.lua",
	"src/Elements/Slider.lua",
	"src/Elements/Keybind.lua",
	"src/Elements/TextBox.lua",
	"src/Elements/ColorPicker.lua",
	"src/Elements/Label.lua",
	"src/Elements/Paragraph.lua",
	"src/Elements/Divider.lua",

	-- Builders (must be after elements)
	"src/SectionBuilder.lua",
	"src/TabBuilder.lua",
	"src/WindowBuilder.lua",
}

local compiledModules = {}

for i, modulePath in ipairs(moduleOrder) do
	local fileName = modulePath:match("([^/]+)%.lua$")
	print(string.format("  [%d/%d] %s", i, #moduleOrder, fileName))

	local content = readFile(modulePath)

	-- Remove module header comments (lines starting with --)
	content = content:gsub("^%-%-[^\n]*\n", "")
	content = content:gsub("\n%-%-[^\n]*\n", "\n")

	-- For ALL modules, we need to keep their local declarations
	-- but convert them to global assignments since we're compiling into one file
	-- Convert "local ModuleName = {}" to "ModuleName = {}"
	content = content:gsub("^local ([A-Z][A-Za-z]+) = %{%}", "%1 = {}")

	-- Remove conflicting local RvrseUI declarations that would shadow the main one
	content = content:gsub("^local RvrseUI.-\n", "-- [Removed conflicting local RvrseUI]\n")

	-- Remove "return X" at end of modules
	content = content:gsub("\nreturn [A-Z][A-Za-z]+%s*$", "")
	content = content:gsub("\nreturn [A-Z][A-Za-z]+\n*$", "")

	-- Add module marker comment
	local marker = "\n-- ========================\n"
	marker = marker .. "-- " .. fileName:gsub("%.lua$", "") .. " Module\n"
	marker = marker .. "-- ========================\n"

	table.insert(compiledModules, marker .. content)
end

print("\n✅ All modules read successfully!")

-- Combine everything
print("\n🔧 Compiling final file...")

local finalCode = header .. services

-- Add all module code
for _, moduleCode in ipairs(compiledModules) do
	finalCode = finalCode .. moduleCode .. "\n"
end

-- Add RvrseUI API wrapper (extracted from init.lua)
local rvrseUIAPI = [[

-- ============================================
-- MAIN RVRSEUI TABLE & PUBLIC API
-- ============================================

RvrseUI.Version = Version
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

-- Configuration settings
RvrseUI.ConfigurationSaving = false
RvrseUI.ConfigurationFileName = nil
RvrseUI.ConfigurationFolderName = nil
RvrseUI.AutoSaveEnabled = true

-- Create Window (main entry point)
function RvrseUI:CreateWindow(cfg)
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
		Debug = Debug,
		Obfuscation = Obfuscation,
		Hotkeys = Hotkeys,
		Version = Version,
		Elements = Elements,
		OverlayLayer = nil,
		UIS = UIS,
		GuiService = GuiService,
		RS = RS,
		PlayerGui = PlayerGui,
		HttpService = game:GetService("HttpService")
	}

	TabBuilder:Initialize(deps)
	SectionBuilder:Initialize(deps)
	WindowBuilder:Initialize(deps)

	local host = PlayerGui:FindFirstChild(Obfuscation.getObfuscatedName("gui"))
	if not host then
		host = Instance.new("ScreenGui")
		host.Name = Obfuscation.getObfuscatedName("gui")
		host.ResetOnSpawn = false
		host.IgnoreGuiInset = true
		host.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		host.DisplayOrder = 999
		host.Parent = PlayerGui
	end

	return WindowBuilder:CreateWindow(self, cfg, host)
end

-- Notifications
function RvrseUI:Notify(options)
	if not self.NotificationsEnabled then return end
	return Notifications:Notify(options)
end

-- Destroy all UI
function RvrseUI:Destroy()
	for _, window in ipairs(self._windows) do
		if window.Destroy then window:Destroy() end
	end
	if self.UI._toggleTargets then table.clear(self.UI._toggleTargets) end
	if self._lockListeners then table.clear(self._lockListeners) end
	if self._themeListeners then table.clear(self._themeListeners) end
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
		task.defer(function() self:SaveConfiguration() end)
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
	if self.ConfigurationSaving then self:_autoSave() end
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
		if window.Minimize then window:Minimize() end
	end
end

function RvrseUI:RestoreAll()
	for _, window in ipairs(self._windows) do
		if window.Restore then window:Restore() end
	end
end

-- Provide notifications module with RvrseUI context
Notifications:SetContext(RvrseUI)
]]

finalCode = finalCode .. rvrseUIAPI

-- Add final return statement
finalCode = finalCode .. "\n-- Return the framework\nreturn RvrseUI\n"

-- Write to RvrseUI.lua
print("💾 Writing to RvrseUI.lua...")
writeFile("RvrseUI.lua", finalCode)

-- Get file size
local file = io.open("RvrseUI.lua", "r")
local size = file:seek("end")
file:close()

print("\n" .. string.rep("=", 52))
print("✅ BUILD COMPLETE!")
print(string.rep("=", 52))
print(string.format("📦 Output: RvrseUI.lua (%d KB)", math.floor(size / 1024)))
print("📊 Modules compiled: " .. #moduleOrder)
print("🚀 Ready for production use!")
print("\nTest with: lua test_compiled.lua")
print("Or load in Roblox: loadstring(game:HttpGet(...))()")
