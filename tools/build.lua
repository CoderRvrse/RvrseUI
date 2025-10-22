-- tools/build.lua
-- Pure Luau packer that replaces the legacy Node/standalone scripts.

local Modules = {
    "src/Version.lua",
    "src/Debug.lua",
    "src/Obfuscation.lua",
    "src/Icons.lua",
    "src/LucideIcons.lua",
    "src/lucide-icons-data.lua",
    "src/Theme.lua",
    "src/Animator.lua",
    "src/State.lua",
    "src/UIHelpers.lua",
    "src/Config.lua",
    "src/WindowManager.lua",
    "src/Hotkeys.lua",
    "src/Notifications.lua",
    "src/Overlay.lua",
    "src/KeySystem.lua",
    "src/Particles.lua",
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
    "src/SectionBuilder.lua",
    "src/TabBuilder.lua",
    "src/WindowBuilder.lua"
}

local HEADER = table.concat({
    "-- RvrseUI v4.3.7 | Modern Professional UI Framework",
    "-- Compiled from modular architecture on " .. os.date("!%Y-%m-%dT%H:%M:%SZ"),
    "",
    "-- Features: Lucide icon system, Organic Particle System, Unified Dropdowns, ColorPicker, Key System, Spring Animations",
    "-- API: CreateWindow → CreateTab → CreateSection → {All 10 Elements}",
    "-- Extras: Spore Bubble particles, Notify system, Theme switcher, LockGroup, Drag-to-move, Config persistence",
    "",
    "-- 🏗️ ARCHITECTURE: This file is compiled from 30 modular files",
    "-- Source: https://github.com/CoderRvrse/RvrseUI/tree/main/src",
    "-- For modular version, use: require(script.init) instead of this file",
    ""
}, "\n")

local SERVICES = table.concat({
    "local TweenService = game:GetService(\"TweenService\")",
    "local Players = game:GetService(\"Players\")",
    "local UIS = game:GetService(\"UserInputService\")",
    "local RS = game:GetService(\"RunService\")",
    "local GuiService = game:GetService(\"GuiService\")",
    "local HttpService = game:GetService(\"HttpService\")",
    "local CoreGui = game:GetService(\"CoreGui\")",
    "",
    "local LP = Players.LocalPlayer",
    "local PlayerGui = LP:WaitForChild(\"PlayerGui\")",
    "local Mouse = LP:GetMouse()",
    "",
    "local RvrseUI = {}",
    ""
}, "\n")

local function readFile(path)
    local file = io.open(path, "r")
    if not file then
        error("Failed to read file: " .. path)
    end
    local contents = file:read("*all")
    file:close()
    return contents
end

local function writeFile(path, contents)
    local file = io.open(path, "w")
    if not file then
        error("Failed to write output: " .. path)
    end
    file:write(contents)
    file:close()
end

local function sanitizeModule(path, contents)
    contents = contents:gsub("^%-%-[^\n]*\n", "")
    contents = contents:gsub("^local ([A-Z][A-Za-z0-9_]*) = %{%}", "%1 = {}")
    contents = contents:gsub("^local RvrseUI.-\n", "-- [Removed conflicting local RvrseUI]\n")

    if path:match("lucide%-icons%-data%.lua$") then
        local sanitized = contents:gsub("^return%s*", "")
        return table.concat({
            "\n-- ========================",
            "-- lucide-icons-data Module",
            "-- ========================\n",
            "_G.RvrseUI_LucideIconsData = " .. sanitized .. "\n"
        }, "\n")
    end

    local moduleName = path:match("([^/]+)%.lua$")
    return table.concat({
        "\n-- ========================",
        ("-- %s Module"):format(moduleName),
        "-- ========================\n",
        contents,
        ""
    }, "\n")
end

local function buildBundle()
    local buffer = { HEADER, SERVICES }

    for _, modulePath in ipairs(Modules) do
        print(string.format("Packing %s", modulePath))
        local contents = readFile(modulePath)
        table.insert(buffer, sanitizeModule(modulePath, contents))
    end

    local output = table.concat(buffer, "\n")
    writeFile("RvrseUI.lua", output)
    print("✅ Packed modules into RvrseUI.lua")
end

buildBundle()
