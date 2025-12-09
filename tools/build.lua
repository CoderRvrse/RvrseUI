-- tools/build.lua
-- Pure Luau build script that reconstructs the RvrseUI monolith

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
    "src/Elements/FilterableList.lua",
    "src/SectionBuilder.lua",
    "src/TabBuilder.lua",
    "src/WindowBuilder.lua"
}

local HEADER = [[-- RvrseUI v4.4.0 | Modern Professional UI Framework
-- Compiled from modular architecture on ]] .. os.date("!%Y-%m-%dT%H:%M:%SZ") .. [[

-- Features: Lucide icon system, Organic Particle System, Unified Dropdowns, ColorPicker, Key System, Spring Animations, FilterableList
-- API: CreateWindow → CreateTab → CreateSection → {All 11 Elements}
-- Extras: Spore Bubble particles, Notify system, Theme switcher, LockGroup, Drag-to-move, Config persistence

-- 🏗️ ARCHITECTURE: This file is compiled from 31 modular files
-- Source: https://github.com/CoderRvrse/RvrseUI/tree/main/src
-- For modular version, use: require(script.init) instead of this file
]]

local SERVICES = [[
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

-- ============================================
-- MODULE TABLE INITIALIZATION
-- Using _G explicit assignment for maximum executor compatibility
-- This ensures modules persist across all executor sandboxing methods
-- ============================================
_G._RvrseUI_Modules = _G._RvrseUI_Modules or {}
local _M = _G._RvrseUI_Modules

_M.Version = _M.Version or {}
_M.Debug = _M.Debug or {}
_M.Obfuscation = _M.Obfuscation or {}
_M.Icons = _M.Icons or {}
_M.LucideIcons = _M.LucideIcons or {}
_M.Theme = _M.Theme or {}
_M.Animator = _M.Animator or {}
_M.State = _M.State or {}
_M.UIHelpers = _M.UIHelpers or {}
_M.Config = _M.Config or {}
_M.WindowManager = _M.WindowManager or {}
_M.Hotkeys = _M.Hotkeys or {}
_M.Notifications = _M.Notifications or {}
_M.Overlay = _M.Overlay or {}
_M.KeySystem = _M.KeySystem or {}
_M.Particles = _M.Particles or {}
_M.Button = _M.Button or {}
_M.Toggle = _M.Toggle or {}
_M.Dropdown = _M.Dropdown or {}
_M.Slider = _M.Slider or {}
_M.Keybind = _M.Keybind or {}
_M.TextBox = _M.TextBox or {}
_M.ColorPicker = _M.ColorPicker or {}
_M.Label = _M.Label or {}
_M.Paragraph = _M.Paragraph or {}
_M.Divider = _M.Divider or {}
_M.FilterableList = _M.FilterableList or {}
_M.SectionBuilder = _M.SectionBuilder or {}
_M.TabBuilder = _M.TabBuilder or {}
_M.WindowBuilder = _M.WindowBuilder or {}
_M.Elements = _M.Elements or {}

-- Create local references for convenience
local Version = _M.Version
local Debug = _M.Debug
local Obfuscation = _M.Obfuscation
local Icons = _M.Icons
local LucideIcons = _M.LucideIcons
local Theme = _M.Theme
local Animator = _M.Animator
local State = _M.State
local UIHelpers = _M.UIHelpers
local Config = _M.Config
local WindowManager = _M.WindowManager
local Hotkeys = _M.Hotkeys
local Notifications = _M.Notifications
local Overlay = _M.Overlay
local KeySystem = _M.KeySystem
local Particles = _M.Particles
local Button = _M.Button
local Toggle = _M.Toggle
local Dropdown = _M.Dropdown
local Slider = _M.Slider
local Keybind = _M.Keybind
local TextBox = _M.TextBox
local ColorPicker = _M.ColorPicker
local Label = _M.Label
local Paragraph = _M.Paragraph
local Divider = _M.Divider
local FilterableList = _M.FilterableList
local SectionBuilder = _M.SectionBuilder
local TabBuilder = _M.TabBuilder
local WindowBuilder = _M.WindowBuilder
local Elements = _M.Elements
]]

local INIT_SECTION = [[
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
    Divider = Divider,
    FilterableList = FilterableList
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
]]

local API_SECTION = [[
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
        Overlay = Overlay,
        KeySystem = KeySystem,
        Particles = Particles,
        Debug = Debug,
        Obfuscation = Obfuscation,
        Hotkeys = Hotkeys,
        Version = Version,
        Elements = Elements,
        OverlayLayer = DEFAULT_OVERLAY,
        UIS = UIS,
        GuiService = GuiService,
        RS = RS,
        RunService = RS,
        PlayerGui = PlayerGui,
        HttpService = HttpService
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

function RvrseUI:Destroy()
    for _, window in ipairs(self._windows) do
        if window.Destroy then window:Destroy() end
    end
    if self.UI._toggleTargets then table.clear(self.UI._toggleTargets) end
    if self._lockListeners then table.clear(self._lockListeners) end
    if self._themeListeners then table.clear(self._themeListeners) end
    print("[RvrseUI] All interfaces destroyed")
end

function RvrseUI:ToggleVisibility()
    self.UI:ToggleAllWindows()
end

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

function RvrseUI:SetTheme(themeName)
    Theme:Switch(themeName)
    if self.ConfigurationSaving then self:_autoSave() end
end

function RvrseUI:GetTheme()
    return Theme.Current
end

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

Notifications:SetContext(RvrseUI)
]]

local function readFile(path)
    local file = io.open(path, "r")
    if not file then
        error("Failed to read module: " .. path)
    end
    local contents = file:read("*all")
    file:close()
    return contents
end

local function writeFile(path, contents)
    local file = io.open(path, "w")
    if not file then
        error("Failed to write file: " .. path)
    end
    file:write(contents)
    file:close()
end

local function sanitizeModule(modulePath, contents)
    -- Remove ALL leading comment lines and blank lines (some modules have multiple)
    while contents:sub(1, 2) == "--" or contents:sub(1, 1) == "\n" or contents:sub(1, 1) == "\r" do
        contents = contents:gsub("^%-%-[^\n]*\n", "")
        contents = contents:gsub("^%s*\n", "")
    end
    
    -- Only remove local declarations for the EXACT modules we forward-declared
    -- This prevents stripping internal locals like PerlinNoise, Config (in Particles.lua), etc.
    -- Search ANYWHERE in the file since some modules have code before the declaration
    local forwardDeclaredModules = {
        "Version", "Debug", "Obfuscation", "Icons", "LucideIcons", "Theme",
        "Animator", "State", "UIHelpers", "Config", "WindowManager", "Hotkeys",
        "Notifications", "Overlay", "KeySystem", "Particles", "Button", "Toggle",
        "Dropdown", "Slider", "Keybind", "TextBox", "ColorPicker", "Label",
        "Paragraph", "Divider", "FilterableList", "SectionBuilder", "TabBuilder",
        "WindowBuilder", "Elements"
    }
    
    -- Replace module declarations anywhere in the file (but only exact matches with empty {})
    for _, mod in ipairs(forwardDeclaredModules) do
        local pattern = "\nlocal " .. mod .. " = %{%}%s*\n"
        contents = contents:gsub(pattern, "\n-- [Using pre-declared " .. mod .. "]\n")
        -- Also match at very start of content
        local startPattern = "^local " .. mod .. " = %{%}%s*\n"
        contents = contents:gsub(startPattern, "-- [Using pre-declared " .. mod .. "]\n")
    end
    
    contents = contents:gsub("^local RvrseUI.-\n", "-- [Removed conflicting local RvrseUI]\n")
    contents = contents:gsub("\nreturn %u%w*%s*$", "\n")

    if modulePath:match("lucide%-icons%-data%.lua$") then
        -- Remove comment lines (--...) and --!nocheck directive, then strip 'return' keyword
        -- The file format is: comment lines, --!nocheck, empty line, return {...}
        local sanitized = contents
            :gsub("^%-%-[^\n]*\n", "")  -- Remove first comment line
            :gsub("^%-%-[^\n]*\n", "")  -- Remove second comment line (--!nocheck)
            :gsub("^%s+", "")           -- Trim leading whitespace
            :gsub("^return%s*", "")     -- Remove the return keyword
        return "\n-- ========================\n-- lucide-icons-data Module\n-- ========================\n\n_G.RvrseUI_LucideIconsData = " .. sanitized .. "\n"
    end

    local moduleName = modulePath:match("([^/]+)%.lua$")
    local marker = "\n-- ========================\n-- " .. moduleName .. " Module\n-- ========================\n\n"
    return marker .. contents .. "\n"
end

local function build()
    local buffer = {HEADER, SERVICES}

    for _, modulePath in ipairs(Modules) do
        print("Packing " .. modulePath)
        local contents = readFile(modulePath)
        table.insert(buffer, sanitizeModule(modulePath, contents))
    end

    table.insert(buffer, INIT_SECTION)
    table.insert(buffer, API_SECTION)
    table.insert(buffer, "\nreturn RvrseUI\n")

    local output = table.concat(buffer, "\n")
    writeFile("RvrseUI.lua", output)
    print("✅ Packed modules into RvrseUI.lua")
end

build()
