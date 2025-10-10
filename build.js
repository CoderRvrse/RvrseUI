#!/usr/bin/env node
// build.js
// Compiles all modular files from src/ into a single RvrseUI.lua file
// Usage: node build.js

const fs = require('fs');
const path = require('path');

console.log('🔨 RvrseUI v3.0.4 Build Script');
console.log('='.repeat(52));

// Header for compiled file
const header = `-- RvrseUI v3.0.4 | Modern Professional UI Framework
-- Compiled from modular architecture on ${new Date().toISOString()}

-- Features: Glassmorphism, Spring Animations, Mobile-First Responsive, Touch-Optimized
-- API: CreateWindow → CreateTab → CreateSection → {All 12 Elements}
-- Extras: Notify system, Theme switcher, LockGroup system, Drag-to-move, Auto-scaling

-- 🏗️ ARCHITECTURE: This file is compiled from 26 modular files
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
	console.log(`  [${i + 1}/${moduleOrder.length}] ${fileName}`);

	let content = fs.readFileSync(modulePath, 'utf8');

	// Remove module header comments (lines starting with --)
	content = content.replace(/^--[^\n]*\n/gm, '');

	// For ALL modules, we need to keep their local declarations
	// but convert them to global assignments since we're compiling into one file
	// Exception: Keep the table initialization, just remove "local"
	content = content.replace(/^local ([A-Z][A-Za-z]+) = \{\}/gm, '$1 = {}');

	// Remove "return X" at end of modules
	content = content.replace(/\nreturn [A-Z][A-Za-z]+\s*$/g, '');
	content = content.replace(/\nreturn [A-Z][A-Za-z]+\n*$/g, '');

	// Add module marker comment
	const moduleName = fileName.replace('.lua', '');
	const marker = `\n-- ========================\n-- ${moduleName} Module\n-- ========================\n`;

	compiledModules.push(marker + content);
}

console.log('\n✅ All modules read successfully!');

// Combine everything
console.log('\n🔧 Compiling final file...');

let finalCode = header + services;

// Add all module code
for (const moduleCode of compiledModules) {
	finalCode += moduleCode + '\n';
}

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
	Debug.enabled = enabled
end

function RvrseUI:IsDebugEnabled()
	return Debug.enabled
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
