// tools/build.js
// Node.js build script that reconstructs the RvrseUI monolith
// Equivalent to tools/build.lua for systems without Lua installed

const fs = require('fs');
const path = require('path');

const Modules = [
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
    "src/Layers.lua",
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
];

// The header is BUILT, not typed. It used to be a hardcoded `v4.5.2` plus
// `new Date()`, which caused two separate problems:
//
//   1. The shipped library announced itself as 4.5.2 for five releases.
//   2. A wall-clock timestamp makes the build unreproducible, so every rebuild
//      shows as a change and `git diff` can never answer "does the committed
//      monolith actually match its sources?" -- which is the one question that
//      would have caught the first problem.
//
// Both now come from VERSION.json, so the same sources always produce the same
// bytes and `node tools/build.js && git diff --exit-code RvrseUI.lua` is a
// real check.
function buildHeader() {
    const v = JSON.parse(fs.readFileSync('VERSION.json', 'utf8')).version;
    return `-- RvrseUI v${v.full} | Modern Professional UI Framework
-- Compiled from modular architecture (build ${v.build})

-- Features: Lucide icon system, Organic Particle System, Unified Dropdowns, ColorPicker, Key System, Spring Animations, FilterableList, Lifecycle API
-- API: CreateWindow → CreateTab → CreateSection → {All 11 Elements}
-- Extras: Spore Bubble particles, Notify system, Theme switcher, LockGroup, Drag-to-move, Config persistence

-- 🏗️ ARCHITECTURE: This file is compiled from 31 modular files
-- Source: https://github.com/CoderRvrse/RvrseUI/tree/main/src
-- For modular version, use: require(script.init) instead of this file
`;
}

const SERVICES = `
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

const INIT_SECTION = `
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

-- Where RvrseUI's screens live: PlayerGui at the top orders (AlwaysOnTop moves them)
Layers:Initialize({
    UIS = UIS,
    RunService = RS,
    GuiService = GuiService,
    PlayerGui = PlayerGui,
    CoreGui = CoreGui,
    Debug = Debug
})

local DEFAULT_HOST = Instance.new("ScreenGui")
DEFAULT_HOST.Name = Obfuscation.getObfuscatedName("gui")
DEFAULT_HOST.ResetOnSpawn = false
DEFAULT_HOST.IgnoreGuiInset = true
DEFAULT_HOST.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Layers:Mount(DEFAULT_HOST, Layers.HOST)

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
    PlayerGui = Layers:GetParent(),
    DisplayOrder = Layers.OVERLAY,
    Layers = Layers,
    OverlayFrame = DEFAULT_OVERLAY,
    Debug = Debug
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
    UIS = UIS,
    Debug = Debug
})

WindowManager:Initialize()

KeySystem:Initialize({
    Theme = Theme,
    Animator = Animator,
    UIHelpers = UIHelpers,
    Debug = Debug,
    Obfuscation = Obfuscation,
    -- The key window names the build it belongs to, so a player can read it
    -- back when something is wrong.
    Version = Version,
    -- ...and draws the SAME Discord mark the main window draws. Without this
    -- the key window had no icon set to reach and fell back to a bare dot,
    -- while the main window showed a real mark two windows apart.
    Icons = Icons
})

Particles:Initialize({
    Theme = Theme,
    RunService = RS
})
`;

const API_SECTION = `
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
        Layers = Layers,
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
        Layers:Mount(DEFAULT_HOST, Layers.HOST)

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
    -- Close every window: each fires its OnClose callbacks and releases what it
    -- started; the last one also removes the shared host, overlay, hotkeys and
    -- particle loop. With no window open, remove those shared pieces now.
    local open = {}
    for _, window in ipairs(self._windows) do
        table.insert(open, window)
    end
    for _, window in ipairs(open) do
        if type(window) == "table" and type(window.Destroy) == "function" then
            window:Destroy("rvrseui-destroy")
        end
    end
    if #open == 0 then
        WindowBuilder:TeardownShared({
            RvrseUI = self,
            Host = DEFAULT_HOST,
            Overlay = Overlay,
            Layers = Layers,
            Hotkeys = Hotkeys,
            Particles = Particles
        })
    end
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
`;

function sanitizeModule(modulePath, contents) {
    // Remove leading comment line
    contents = contents.replace(/^--[^\n]*\n/, '');

    // Convert local Module = {} to Module = {}
    contents = contents.replace(/^local ([A-Z][A-Za-z0-9_]*) = \{\}/gm, '$1 = {}');

    // Remove conflicting local RvrseUI declarations
    contents = contents.replace(/^local RvrseUI.*\n/gm, '-- [Removed conflicting local RvrseUI]\n');

    // Remove trailing return statements
    contents = contents.replace(/\nreturn [A-Z][A-Za-z0-9_]*\s*$/, '\n');

    // Special handling for lucide-icons-data
    if (modulePath.includes('lucide-icons-data.lua')) {
        // Remove comment lines and --!nocheck directive, then strip 'return' keyword
        // The file format is: comment lines, --!nocheck, empty line, return {...}
        let sanitized = contents
            .replace(/^--[^\n]*\n/gm, '')  // Remove all comment lines
            .replace(/^\s+/, '')            // Trim leading whitespace
            .replace(/^return\s*/, '');     // Remove the return keyword
        return `
-- ========================
-- lucide-icons-data Module
-- ========================

_G.RvrseUI_LucideIconsData = ${sanitized}
`;
    }

    const moduleName = path.basename(modulePath, '.lua');
    const marker = `
-- ========================
-- ${moduleName} Module
-- ========================

`;
    // Every module runs inside its own do...end block (as the v4.3.x monolith
    // did), so a module's private top-level locals stay private. Without it,
    // WindowBuilder's `local Theme, Animator, ... Obfuscation` (all nil until
    // CreateWindow) shadow the real module tables for everything after it and
    // the monolith dies at load: "attempt to index nil with 'Initialize'" —
    // the v4.4.x executor breakage.
    return marker + 'do\n' + contents.replace(/\s+$/, '') + '\nend\n';
}

// --------------------------------------------------------------------------
// Numbers the docs quote about the build, GENERATED rather than remembered.
//
// The site sat at "v4.6.0" and "BUILD SIZE 491 KB" for four releases while the
// library went to 4.10.0 and 567 KB, because both were typed by hand and there
// was nothing anywhere to notice. This banner said v4.5.2 for the same reason.
//
// Anything on a page that restates a fact the build already knows will drift.
// The fix is not to be more careful; it is to stop having two copies. These
// are written from the source of truth on every build, and `--check` fails
// without writing, so a gate can catch a stale page in a pull request.
// --------------------------------------------------------------------------
function docStats() {
    const version = JSON.parse(fs.readFileSync('VERSION.json', 'utf8')).version.full;
    const sizeKB = Math.round(fs.statSync('RvrseUI.lua').size / 1024);
    // Counted from the source, so adding an element updates the page by itself.
    const section = fs.readFileSync('src/SectionBuilder.lua', 'utf8');
    const elements = new Set(
        [...section.matchAll(/function\s+SectionAPI:Create([A-Za-z]+)/g)].map(m => m[1])
    ).size;
    return { version, sizeKB, elements };
}

// Each rule is anchored to the markup AROUND the number, never to the number
// itself: a pattern loose enough to find "567 KB" anywhere would eventually
// rewrite something else that happened to look like it.
function docRules(st) {
    return [
        {
            file: 'docs/index.html',
            subs: [
                [/(<span class="hero-badge">v)[\d.]+/, `$1${st.version}`],
                [/(<p>RvrseUI v)[\d.]+/, `$1${st.version}`],
                [/(<span>Build Size<\/span>\s*<strong>)[^<]*/, `$1${st.sizeKB} KB`],
                [/(<span>Elements<\/span>\s*<strong>)[^<]*/, `$1${st.elements}`],
            ],
        },
        {
            file: 'README.md',
            subs: [[/(\*\*Current release: v)[\d.]+/, `$1${st.version}`]],
        },
    ];
}

function syncDocs(check) {
    const st = docStats();
    let stale = [];

    for (const { file, subs } of docRules(st)) {
        let text;
        try {
            text = fs.readFileSync(file, 'utf8');
        } catch {
            continue; // the docs are not required to be present to build
        }
        let out = text;
        for (const [pattern, replacement] of subs) {
            if (!pattern.test(out)) {
                // A rule that matches nothing is itself a bug: the markup moved
                // and this stopped protecting anything, silently.
                console.error(`❌ ${file}: nothing matched ${pattern} — the markup changed, fix tools/build.js`);
                process.exit(1);
            }
            out = out.replace(pattern, replacement);
        }
        if (out !== text) {
            stale.push(file);
            if (!check) fs.writeFileSync(file, out, 'utf8');
        }
    }

    if (check) {
        if (stale.length) {
            console.error(`❌ docs are stale: ${stale.join(', ')}`);
            console.error(`   expected v${st.version}, ${st.sizeKB} KB, ${st.elements} elements`);
            console.error('   run: node tools/build.js');
            process.exit(1);
        }
        console.log(`✅ docs match the build (v${st.version}, ${st.sizeKB} KB, ${st.elements} elements)`);
        return;
    }
    console.log(
        stale.length
            ? `📝 docs updated: ${stale.join(', ')} (v${st.version}, ${st.sizeKB} KB, ${st.elements} elements)`
            : `📝 docs already matched (v${st.version}, ${st.sizeKB} KB, ${st.elements} elements)`
    );
}

function build() {
    const declared = JSON.parse(fs.readFileSync('VERSION.json', 'utf8')).version.full;
    console.log(`🔨 RvrseUI v${declared} Build Script (Node.js)`);
    console.log('==========================================');

    const buffer = [buildHeader(), SERVICES];

    for (const modulePath of Modules) {
        console.log(`Packing ${modulePath}`);
        try {
            const contents = fs.readFileSync(modulePath, 'utf8');
            buffer.push(sanitizeModule(modulePath, contents));
        } catch (err) {
            console.error(`❌ Failed to read ${modulePath}: ${err.message}`);
            process.exit(1);
        }
    }

    buffer.push(INIT_SECTION);
    buffer.push(API_SECTION);
    buffer.push('\nreturn RvrseUI\n');

    const output = buffer.join('\n');

    try {
        fs.writeFileSync('RvrseUI.lua', output, 'utf8');
        const stats = fs.statSync('RvrseUI.lua');
        const sizeKB = Math.round(stats.size / 1024);
        console.log('==========================================');
        console.log(`✅ Packed ${Modules.length} modules into RvrseUI.lua`);
        console.log(`📦 File size: ${sizeKB} KB`);
    } catch (err) {
        console.error(`❌ Failed to write RvrseUI.lua: ${err.message}`);
        process.exit(1);
    }

    syncDocs(false);
}

// `node tools/build.js --check` verifies the docs without building or writing
// anything, which is what a gate should run.
if (process.argv.includes('--check')) {
    syncDocs(true);
} else {
    build();
}
