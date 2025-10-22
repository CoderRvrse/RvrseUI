#!/usr/bin/env node
// build.js
// Compiles all modular files from src/ into a single RvrseUI.lua file
// Usage: node build.js

const fs = require('fs');
const path = require('path');

console.log('🔨 RvrseUI v4.3.5 Build Script');
console.log('='.repeat(52));

// Header for compiled file
const header = `-- RvrseUI v4.3.5 | Modern Professional UI Framework
-- Compiled from modular architecture on ${new Date().toISOString()}

-- Features: Lucide icon system, Organic Particle System, Unified Dropdowns, ColorPicker, Key System, Spring Animations
-- API: CreateWindow → CreateTab → CreateSection → {All 10 Elements}
-- Extras: Spore Bubble particles, Notify system, Theme switcher, LockGroup, Drag-to-move, Config persistence

-- 🏗️ ARCHITECTURE: This file is compiled from 30 modular files
-- Source: https://github.com/CoderRvrse/RvrseUI/tree/main/src
-- For modular version, use: require(script.init) instead of this file

`;

// Roblox services (needed at top)
const services = `
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")
local Mouse = LP:GetMouse()

local RvrseUI = {}

`;

console.log('📂 Reading module files...');

// Order matters! Dependencies must be loaded first
const moduleOrder = [
	// Foundation
	'src/Version.lua',
	'src/Debug.lua',
	'src/Obfuscation.lua',

	// Data
	'src/Icons.lua',
	'src/LucideIcons.lua',  // ⭐ NEW: Lucide icon library integration
	'src/lucide-icons-data.lua',
	'src/Theme.lua',

	// Systems
	'src/Animator.lua',
	'src/State.lua',
	'src/UIHelpers.lua',

	// Services
	'src/Config.lua',
	'src/WindowManager.lua',
	'src/Hotkeys.lua',
	'src/Notifications.lua',
	'src/Overlay.lua',  // ⭐ CRITICAL: Must be included for ColorPicker!
	'src/KeySystem.lua',
	'src/Particles.lua',  // ⭐ NEW: Organic particle system with Perlin noise

	// Elements
	'src/Elements/Button.lua',
	'src/Elements/Toggle.lua',
	'src/Elements/Dropdown.lua',
	'src/Elements/Slider.lua',
	'src/Elements/Keybind.lua',
	'src/Elements/TextBox.lua',
	'src/Elements/ColorPicker.lua',
	'src/Elements/Label.lua',
	'src/Elements/Paragraph.lua',
	'src/Elements/Divider.lua',

	// Builders (must be after elements)
	'src/SectionBuilder.lua',
	'src/TabBuilder.lua',
	'src/WindowBuilder.lua',
];

const compiledModules = [];

for (let i = 0; i < moduleOrder.length; i++) {
	const modulePath = moduleOrder[i];
	const fileName = path.basename(modulePath);
	const moduleName = fileName.replace('.lua', '');
	console.log(`  [${i + 1}/${moduleOrder.length}] ${fileName}`);

	let content = fs.readFileSync(modulePath, 'utf8');

	// Special handling for lucide sprite sheet data: inject as global table
	if (fileName === 'lucide-icons-data.lua') {
		const marker = `\n-- ========================\n-- ${moduleName} Module\n-- ========================\n`;
		const sanitized = content.trim().replace(/return\s+/, '');
		const globalAssignment = `\n-- Set Lucide sprite data as global for executor/monolith environments\n_G.RvrseUI_LucideIconsData = ${sanitized}\n`;
		compiledModules.push(marker + globalAssignment);
		continue;
	}

	// Remove module header comments (lines starting with --)
	content = content.replace(/^--[^\n]*\n/gm, '');

	// For ALL modules, we need to keep their local declarations
	// but convert them to global assignments since we're compiling into one file
	// Exception: Keep the table initialization, just remove "local"
	content = content.replace(/^local ([A-Z][A-Za-z]+) = \{\}/gm, '$1 = {}');

	// Remove conflicting local RvrseUI declarations that would shadow the main one
	// These appear in modules that reference RvrseUI but we handle via dependencies
	content = content.replace(/^local RvrseUI.*$/gm, '-- [Removed conflicting local RvrseUI]');

	// Remove "return X" at end of modules
	content = content.replace(/\nreturn [A-Z][A-Za-z]+\s*$/g, '');
	content = content.replace(/\nreturn [A-Z][A-Za-z]+\n*$/g, '');

	// Add module marker comment
	const marker = `\n-- ========================\n-- ${moduleName} Module\n-- ========================\n`;

	const indented = content
		.replace(/\s+$/, '') // trim trailing whitespace to keep wrapping clean
		.split('\n')
		.map(line => '\t' + line)
		.join('\n');

	const wrapped = `\ndo\n${indented}\nend\n`;

	compiledModules.push(marker + wrapped);
}

console.log('\n✅ All modules read successfully!');

// Combine everything
console.log('\n🔧 Compiling final file...');

let finalCode = header + services;

// Add all module code
for (const moduleCode of compiledModules) {
	finalCode += moduleCode + '\n';
}

const initSection = `
-- ============================================
-- MODULE INITIALIZATION (compiled from init.lua)
-- ============================================

Obfuscation:Initialize()
Theme:Initialize()
Animator:Initialize(TweenService)
State:Initialize()

local function configLogger(...)
	if Debug and Debug.Print then
		Debug:Print(...)
	else
		print("[RvrseUI]", ...)
	end
end

Config:Init({
	State = State,
	Theme = Theme,
	dprintf = configLogger
})

UIHelpers:Initialize({
	Animator = Animator,
	Theme = Theme,
	Icons = Icons,
	PlayerGui = PlayerGui
})

LucideIcons:Initialize({
	HttpService = HttpService,
	Debug = Debug
})

Icons:Initialize({
	LucideIcons = LucideIcons
})

Elements = {
	Button = Button,
	Toggle = Toggle,
	Dropdown = Dropdown,
	Slider = Slider,
	Keybind = Keybind,
	TextBox = TextBox,
	ColorPicker = ColorPicker,
	Label = Label,
	Paragraph = Paragraph,
	Divider = Divider
}

RvrseUI.NotificationsEnabled = true

local DEFAULT_HOST = Instance.new("ScreenGui")
DEFAULT_HOST.Name = Obfuscation.getObfuscatedName("gui")
DEFAULT_HOST.ResetOnSpawn = false
DEFAULT_HOST.IgnoreGuiInset = true
DEFAULT_HOST.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
DEFAULT_HOST.DisplayOrder = 999
DEFAULT_HOST.Parent = PlayerGui

local DEFAULT_OVERLAY = Instance.new("Frame")
DEFAULT_OVERLAY.Name = "RvrseUI_Overlay"
DEFAULT_OVERLAY.BackgroundTransparency = 1
DEFAULT_OVERLAY.BorderSizePixel = 0
DEFAULT_OVERLAY.ClipsDescendants = false
DEFAULT_OVERLAY.Visible = false
DEFAULT_OVERLAY.ZIndex = 20000
DEFAULT_OVERLAY.Size = UDim2.new(1, 0, 1, 0)
DEFAULT_OVERLAY.Parent = DEFAULT_HOST

-- Initialize Overlay service
Overlay:Initialize({
	PlayerGui = PlayerGui,
	DisplayOrder = DEFAULT_HOST.DisplayOrder + 10,
	OverlayFrame = DEFAULT_OVERLAY
})

Notifications:Initialize({
	host = DEFAULT_HOST,
	Theme = Theme,
	Animator = Animator,
	UIHelpers = UIHelpers,
	RvrseUI = RvrseUI,
	Icons = Icons
})

Hotkeys:Initialize({
	UIS = UIS
})

WindowManager:Initialize()

KeySystem:Initialize({
	Theme = Theme,
	Animator = Animator,
	UIHelpers = UIHelpers,
	Debug = Debug,
	Obfuscation = Obfuscation
})

Particles:Initialize({
	Theme = Theme,
	RunService = RS
})
`;

finalCode += initSection + '\n';

// Add RvrseUI API wrapper (extracted from init.lua lines 162-350)
const rvrseUIAPI = `
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
		Overlay = Overlay,  -- ⭐ CRITICAL: Pass Overlay service!
		KeySystem = KeySystem,
		Particles = Particles,  -- ⭐ NEW: Organic particle system
		Debug = Debug,
		Obfuscation = Obfuscation,
		Hotkeys = Hotkeys,
		Version = Version,
		Elements = Elements,
		OverlayLayer = DEFAULT_OVERLAY,
		UIS = UIS,
		GuiService = GuiService,
		RS = RS,
		RunService = RS,  -- Alias for compatibility
		PlayerGui = PlayerGui,
		HttpService = game:GetService("HttpService")
	}

	TabBuilder:Initialize(deps)
	SectionBuilder:Initialize(deps)
	WindowBuilder:Initialize(deps)

	if not DEFAULT_HOST or not DEFAULT_HOST.Parent then
		DEFAULT_HOST = Instance.new("ScreenGui")
		DEFAULT_HOST.Name = Obfuscation.getObfuscatedName("gui")
		DEFAULT_HOST.ResetOnSpawn = false
		DEFAULT_HOST.IgnoreGuiInset = true
		DEFAULT_HOST.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		DEFAULT_HOST.DisplayOrder = 999
		DEFAULT_HOST.Parent = PlayerGui

		DEFAULT_OVERLAY = Instance.new("Frame")
		DEFAULT_OVERLAY.Name = "RvrseUI_Overlay"
		DEFAULT_OVERLAY.BackgroundTransparency = 1
		DEFAULT_OVERLAY.BorderSizePixel = 0
		DEFAULT_OVERLAY.ClipsDescendants = false
		DEFAULT_OVERLAY.Visible = false
		DEFAULT_OVERLAY.ZIndex = 20000
		DEFAULT_OVERLAY.Size = UDim2.new(1, 0, 1, 0)
		DEFAULT_OVERLAY.Parent = DEFAULT_HOST

		Notifications:Initialize({
			host = DEFAULT_HOST,
			Theme = Theme,
			Animator = Animator,
			UIHelpers = UIHelpers,
			RvrseUI = RvrseUI,
			Icons = Icons
		})
	end

	return WindowBuilder:CreateWindow(self, cfg, DEFAULT_HOST)
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
`;

finalCode += rvrseUIAPI;

// Add final return statement
finalCode += '\n-- Return the framework\nreturn RvrseUI\n';

// Write to RvrseUI.lua
console.log('💾 Writing to RvrseUI.lua...');
fs.writeFileSync('RvrseUI.lua', finalCode, 'utf8');

// Get file size
const stats = fs.statSync('RvrseUI.lua');
const sizeKB = Math.floor(stats.size / 1024);

console.log('\n' + '='.repeat(52));
console.log('✅ BUILD COMPLETE!');
console.log('='.repeat(52));
console.log(`📦 Output: RvrseUI.lua (${sizeKB} KB)`);
console.log(`📊 Modules compiled: ${moduleOrder.length}`);
console.log('🚀 Ready for production use!');
console.log('\nLoad in Roblox: loadstring(game:HttpGet(...))()');
