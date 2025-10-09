#!/usr/bin/env node
// build.js
// Compiles all modular files from src/ into a single RvrseUI.lua file
// Usage: node build.js

const fs = require('fs');
const path = require('path');

console.log('🔨 RvrseUI v3.0.2 Build Script');
console.log('='.repeat(52));

// Header for compiled file
const header = `-- RvrseUI v3.0.2 | Modern Professional UI Framework
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

	// Remove "local X = {}" declarations that will conflict
	content = content.replace(/local ([A-Z][A-Za-z]+) = \{\}/g, '');

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
