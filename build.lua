#!/usr/bin/env lua
-- build.lua
-- Compiles all modular files from src/ into a single RvrseUI.lua file
-- Usage: lua build.lua

print("🔨 RvrseUI v3.0.0 Build Script")
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
local header = [[-- RvrseUI v3.0.0 | Modern Professional UI Framework
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

	-- Remove "local X = {}" declarations that will conflict
	content = content:gsub("local ([A-Z][A-Za-z]+) = %{%}", "")

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
