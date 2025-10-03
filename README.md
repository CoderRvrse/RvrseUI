# RvrseUI v2.11.0

<div align="center">

**A modern, professional UI framework for Roblox with named config profiles, auto-load system, theme persistence, minimize to controller, and rebindable hotkeys.**

[![Version](https://img.shields.io/badge/version-2.11.0-blue.svg)](https://github.com/CoderRvrse/RvrseUI)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Roblox](https://img.shields.io/badge/platform-Roblox-red.svg)](https://www.roblox.com)

[Features](#-features) • [Quick Start](#-quick-start) • [Documentation](#-documentation) • [Examples](#-examples) • [What's New](#-whats-new)

</div>

> **⚠️ IMPORTANT**: Always use the cache buster (`.. tick()`) when loading to get the latest version and avoid cached errors!

> **🚀 NEW in v2.8.0**: Named config profiles + auto-load! Just set `ConfigurationSaving = true` and your last config loads automatically!

---

## 🎯 Features

### 🎨 Theme Persistence (v2.7.0+) **FIXED!**
- **Saved Theme Wins**: Theme persists correctly across sessions
- **Smart Precedence**: saved > cfg.Theme > default "Dark"
- **Pill Icon Sync**: 🌙/🌞 icon always matches current theme
- **Auto-Save**: Theme saves when you toggle the pill button
- **GPT-5 Verified**: Comprehensive logging to ensure persistence works
- **First-Run Default**: Set Theme parameter for initial run only
- **Hotkey State Fix**: Minimize/restore works perfectly with toggle key

### 🎮 Minimize to Controller (v2.5.0+)
- **Premium Animations**: 40-particle flow effect on minimize/restore
- **Gaming Controller Chip**: Click 🎮 to restore window
- **Draggable Controller**: Drag chip anywhere, position remembered
- **Boundary Clamping**: Controller never goes off-screen
- **Position Memory**: Window and controller remember last positions
- **Smooth Transitions**: Window rotates and shrinks into chip
- **Rotating Shine**: Premium gradient shine effect on chip
- **State Preserved**: All GUI state maintained on restore
- **Theme Support**: Works flawlessly in Dark/Light modes

### ✨ Complete Element System (12 Elements)
- **Interactive**: Button, Toggle, Dropdown, Slider, Keybind
- **Input**: TextBox, ColorPicker
- **Display**: Label, Paragraph, Divider
- **Structure**: Section, Tab, Window

### 💾 Configuration System (v2.8.0+) **REVOLUTIONARY!**
- **Auto-Load**: Just `ConfigurationSaving = true` - last config loads automatically!
- **Named Profiles**: `ConfigurationSaving = "MyHub"` for multiple configs
- **Theme Guaranteed**: Last theme ALWAYS loads correctly
- **No Setup Needed**: Blank config = auto-load last used
- **SaveConfigAs(name)**: Create multiple profiles on-the-fly
- **LoadConfigByName(name)**: Switch between profiles
- **Last Config Tracker**: `RvrseUI/_last_config.json` remembers everything

### 🎨 Modern UI Design
- **Glassmorphism**: 93-97% transparent elements
- **Spring Animations**: Smooth micro-interactions
- **Material Ripple**: Touch-responsive effects
- **Dark/Light Themes**: Runtime theme switching

### 📱 Mobile-First
- **Auto-Scaling**: 380x520 (mobile) → 580x480 (desktop)
- **Touch-Optimized**: 44px tap targets
- **Responsive**: Works on all devices

### 🔧 Advanced Features
- **Lock Groups**: Master/child control relationships
- **Flags System**: Global element access
- **Notifications**: Priority-based toast system
- **Drag-to-Move**: Repositionable windows

---

## 🚀 Quick Start

### Installation

```lua
-- ⚠️ ALWAYS use cache buster to get latest version!
local RvrseUI = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua?" .. tick()
))()
```

### Basic Example

```lua
-- Create Window
local Window = RvrseUI:CreateWindow({
  Name = "My Script",
  Icon = "game",
  Theme = "Dark"
})

-- Create Tab
local MainTab = Window:CreateTab({
  Title = "Main",
  Icon = "home"
})

-- Create Section
local PlayerSection = MainTab:CreateSection("Player")

-- Add Elements
PlayerSection:CreateSlider({
  Text = "Walk Speed",
  Min = 16,
  Max = 100,
  Default = 16,
  OnChanged = function(speed)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = speed
  end
})

PlayerSection:CreateToggle({
  Text = "Auto Farm",
  State = false,
  OnChanged = function(enabled)
    print("Auto Farm:", enabled)
  end
})
```

### With Configuration Saving (v2.8.0 - Auto-Load!)

```lua
-- 🚀 NEW: Auto-load last config (recommended!)
local Window = RvrseUI:CreateWindow({
  Name = "My Script",
  ConfigurationSaving = true  -- That's it! Auto-loads last used config + theme
})

-- OR: Named profile
local Window = RvrseUI:CreateWindow({
  Name = "My Script",
  ConfigurationSaving = "MyHub"  -- Saves to RvrseUI/Configs/MyHub.json
})

-- OR: Classic format (still works)
local Window = RvrseUI:CreateWindow({
  Name = "My Script",
  ConfigurationSaving = {
    Enabled = true,
    FolderName = "MyHub",      -- Optional: organize by folder
    FileName = "PlayerConfig"   -- Saved as: MyHub/PlayerConfig.json
  }
})

-- Add elements with Flags
PlayerSection:CreateSlider({
  Text = "Walk Speed",
  Flag = "WalkSpeed",  -- 🔑 Unique identifier
  OnChanged = function(speed)
    -- Settings auto-save after 1 second
  end
})

-- Auto-load happens automatically! No need to call LoadConfiguration()
```

---

## 📚 Documentation

### All 12 Elements

#### Button
```lua
Section:CreateButton({
  Text = "Click Me",
  Callback = function()
    print("Clicked!")
  end
})
```

#### Toggle
```lua
Section:CreateToggle({
  Text = "Enable Feature",
  State = false,
  Flag = "MyToggle",  -- Optional: for saving
  OnChanged = function(enabled)
    print(enabled)
  end
})
```

#### Slider
```lua
Section:CreateSlider({
  Text = "Speed",
  Min = 0,
  Max = 100,
  Step = 1,
  Default = 50,
  Flag = "MySlider",
  OnChanged = function(value)
    print(value)
  end
})
```

#### Dropdown (v2.3.1 - Fixed!)
```lua
Section:CreateDropdown({
  Text = "Mode",
  Values = { "Easy", "Normal", "Hard" },
  Default = "Normal",
  Flag = "GameMode",
  OnChanged = function(mode)
    print(mode)
  end
})
```
**NEW**: Real dropdown list with scrolling!

#### Keybind
```lua
Section:CreateKeybind({
  Text = "Toggle Key",
  Default = Enum.KeyCode.E,
  Flag = "ToggleKey",
  OnChanged = function(key)
    print(key.Name)
  end
})
```

#### TextBox
```lua
Section:CreateTextBox({
  Text = "Username",
  Placeholder = "Enter name...",
  Default = "",
  Flag = "Username",
  OnChanged = function(text, enterPressed)
    print(text)
  end
})
```

#### ColorPicker
```lua
Section:CreateColorPicker({
  Text = "Theme Color",
  Default = Color3.fromRGB(99, 102, 241),
  Flag = "ThemeColor",
  OnChanged = function(color)
    print(color)
  end
})
```

#### Label
```lua
Section:CreateLabel({
  Text = "Status: Ready"
})
```

#### Paragraph
```lua
Section:CreateParagraph({
  Text = "This is a longer text block that wraps automatically."
})
```

#### Divider
```lua
Section:CreateDivider()
```

---

## 🎯 Configuration System

### Setup (3 Steps)

**Step 1**: Enable in CreateWindow
```lua
local Window = RvrseUI:CreateWindow({
  ConfigurationSaving = {
    Enabled = true,
    FolderName = "BigHub",     -- Optional folder
    FileName = "Config"         -- File name (without .json)
  }
})
```

**Step 2**: Add Flag to elements
```lua
Section:CreateSlider({
  Text = "Walk Speed",
  Flag = "WalkSpeed",  -- 🔑 Required for saving
  OnChanged = function(speed)
    -- Your code
  end
})
```

**Step 3**: Load at bottom
```lua
RvrseUI:LoadConfiguration()  -- Restores saved settings
```

### Configuration Methods

```lua
-- Manual save
RvrseUI:SaveConfiguration()

-- Load saved config
RvrseUI:LoadConfiguration()

-- Delete config
RvrseUI:DeleteConfiguration()

-- Check if exists
local exists = RvrseUI:ConfigurationExists()
```

---

## 💡 Examples

### Complete Script with Config (Production-Ready, No Errors!)

> ✅ **This example works perfectly** - tested and verified with v2.11.0!
> 📁 **Full version**: See [SIMPLE_TEST.lua](SIMPLE_TEST.lua) for complete demo
> 🎨 **Theme Note**: Theme parameter is first-run default only - saved theme takes precedence!
> 🔑 **Hotkey Note**: Use `IsUIToggle = true` in keybind to make it rebindable from settings!

```lua
-- Load RvrseUI with cache buster (always gets latest!)
local RvrseUI = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua?" .. tick()
))()

-- Create window with configuration saving
local Window = RvrseUI:CreateWindow({
  Name = "Simple Test Hub",
  Icon = "🎮",
  LoadingTitle = "Simple Test Hub",
  LoadingSubtitle = "Loading features...",
  Theme = "Dark",  -- Used ONLY on first run (saved theme wins after that)
  ToggleUIKeybind = "K",
  ConfigurationSaving = {
    Enabled = true,
    FolderName = "SimpleTestHub",  -- Saves to: SimpleTestHub/Config.json
    FileName = "Config.json"
  }
})

-- Main Tab
local MainTab = Window:CreateTab({ Title = "Main", Icon = "⚙" })

-- Player Section
local PlayerSection = MainTab:CreateSection("Player Features")

-- Speed Slider (with auto-save via Flag)
PlayerSection:CreateSlider({
  Text = "Walk Speed",
  Min = 16,
  Max = 100,
  Step = 2,
  Default = 16,
  Flag = "WalkSpeed",  -- Auto-saves when changed!
  OnChanged = function(speed)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("Humanoid") then
      player.Character.Humanoid.WalkSpeed = speed
    end
  end
})

-- Fly Toggle (with auto-save)
PlayerSection:CreateToggle({
  Text = "Enable Flying",
  State = false,
  Flag = "FlyEnabled",
  OnChanged = function(enabled)
    if enabled then
      RvrseUI:Notify({
        Title = "Flight Enabled",
        Message = "You can now fly!",
        Duration = 2,
        Type = "success"
      })
    else
      RvrseUI:Notify({
        Title = "Flight Disabled",
        Duration = 1,
        Type = "warn"
      })
    end
  end
})

-- Combat Section with Lock Groups
local CombatSection = MainTab:CreateSection("Combat Features")

-- Master Toggle (locks child toggles when ON)
CombatSection:CreateToggle({
  Text = "🎯 Auto Farm (MASTER)",
  State = false,
  LockGroup = "AutoFarm",  -- Locks all toggles with RespectLock = "AutoFarm"
  OnChanged = function(enabled)
    if enabled then
      RvrseUI:Notify({
        Title = "Auto Farm Started",
        Message = "Individual farms are now locked",
        Duration = 2,
        Type = "success"
      })
    end
  end
})

-- Child Toggles (locked when master is ON)
CombatSection:CreateToggle({
  Text = "Farm Coins",
  State = false,
  RespectLock = "AutoFarm",  -- Becomes disabled when AutoFarm master is ON
  Flag = "FarmCoins",
  OnChanged = function(on) print("Farm Coins:", on) end
})

-- Settings Tab
local SettingsTab = Window:CreateTab({ Title = "Settings", Icon = "🔧" })

-- Controls Section with rebindable UI toggle
local ControlsSection = SettingsTab:CreateSection("Controls")

ControlsSection:CreateKeybind({
  Text = "Toggle UI Hotkey",
  Default = Enum.KeyCode.K,
  Flag = "UIToggleKey",  -- 💾 Saves to config
  IsUIToggle = true,  -- 🔑 Makes this keybind control the UI toggle!
  OnChanged = function(key)
    RvrseUI:Notify({
      Title = "Hotkey Updated",
      Message = "Press " .. key.Name .. " to toggle UI",
      Duration = 2,
      Type = "success"
    })
  end
})

ControlsSection:CreateKeybind({
  Text = "Destroy UI Key (Backspace)",
  Default = Enum.KeyCode.Backspace,
  Flag = "UIDestroyKey",  -- 💾 Saves to config
  IsUIEscape = true,  -- 🔑 Makes this the destroy/close key!
  OnChanged = function(key)
    RvrseUI:Notify({
      Title = "Destroy Key Updated",
      Message = "Press " .. key.Name .. " to destroy UI",
      Duration = 2,
      Type = "success"
    })
  end
})

local ConfigSection = SettingsTab:CreateSection("Configuration")

-- Manual Save Button
ConfigSection:CreateButton({
  Text = "💾 Save Configuration",
  Callback = function()
    local success, message = RvrseUI:SaveConfiguration()
    if success then
      RvrseUI:Notify({
        Title = "Config Saved",
        Message = "Settings saved successfully!",
        Duration = 2,
        Type = "success"
      })
    end
  end
})

-- Load Button
ConfigSection:CreateButton({
  Text = "📂 Load Configuration",
  Callback = function()
    local success, message = RvrseUI:LoadConfiguration()
    RvrseUI:Notify({
      Title = success and "Config Loaded" or "Load Failed",
      Message = message,
      Duration = 2,
      Type = success and "success" or "warn"
    })
  end
})

-- 🔧 IMPORTANT: Call Window:Show() to load config and display UI
-- This MUST be called AFTER all tabs, sections, and elements are created!
Window:Show()

-- Welcome notification
RvrseUI:Notify({
  Title = "Script Loaded",
  Message = "Press K to toggle UI. All features working!",
  Duration = 4,
  Type = "success"
})
```

### Lock Groups (Master/Child)

```lua
-- Master toggle controls children
Section:CreateToggle({
  Text = "🎯 Auto Target All (MASTER)",
  State = false,
  LockGroup = "AutoTarget",  -- Controls the lock
  OnChanged = function(enabled)
    print("Master:", enabled)
  end
})

-- Child toggles locked when master is ON
Section:CreateToggle({
  Text = "Target: Bandit",
  State = false,
  RespectLock = "AutoTarget",  -- Respects the lock
  OnChanged = function(enabled)
    print("Bandit:", enabled)
  end
})
```

### Flags System

```lua
-- Create element with Flag
local SpeedSlider = Section:CreateSlider({
  Text = "Speed",
  Flag = "PlayerSpeed"
})

-- Access via API methods
SpeedSlider:Set(50)
print(SpeedSlider:Get())  -- 50

-- Access via Flags table
RvrseUI.Flags["PlayerSpeed"]:Set(75)
print(RvrseUI.Flags["PlayerSpeed"]:Get())  -- 75
```

### Notifications

```lua
RvrseUI:Notify({
  Title = "Success",
  Message = "Operation completed",
  Type = "success",        -- success, error, warn, info
  Priority = "high",       -- critical, high, normal, low
  Duration = 3
})
```

---

## 🎨 Themes

### Switch Themes

```lua
-- Via CreateWindow
local Window = RvrseUI:CreateWindow({
  Theme = "Dark"  -- or "Light"
})

-- Runtime switching
Theme:Switch("Light")
Theme:Switch("Dark")
```

### Theme Colors

**Dark Theme** (Default):
- Accent: Indigo (#6366F1)
- Background: Dark transparent
- Text: White hierarchy

**Light Theme**:
- Accent: Blue (#3B82F6)
- Background: Light transparent
- Text: Dark hierarchy

---

## 🔧 API Reference

### Window Methods

```lua
Window:CreateTab({ Title = "Tab", Icon = "home" })
Window:SetIcon("trophy")
Window:Destroy()
```

### Tab Methods

```lua
Tab:CreateSection("Section Name")
Tab:SetIcon("star")
```

### Section Methods

```lua
Section:CreateButton({...})
Section:CreateToggle({...})
Section:CreateSlider({...})
Section:CreateDropdown({...})
Section:CreateKeybind({...})
Section:CreateTextBox({...})
Section:CreateColorPicker({...})
Section:CreateLabel({...})
Section:CreateParagraph({...})
Section:CreateDivider()

Section:Update("New Title")
Section:SetVisible(false)
```

### Element Methods (All Elements)

```lua
Element:Set(value)           -- Set value
Element:Get()                -- Get value
Element:SetVisible(false)    -- Hide element
Element.CurrentValue         -- Direct value access
```

### Configuration Methods

```lua
RvrseUI:SaveConfiguration()      -- Returns (success, message)
RvrseUI:LoadConfiguration()      -- Returns (success, message)
RvrseUI:DeleteConfiguration()    -- Returns (success, message)
RvrseUI:ConfigurationExists()    -- Returns boolean
```

### Notification Methods

```lua
RvrseUI:Notify({
  Title = "Title",
  Message = "Message",
  Type = "success",      -- success, error, warn, info
  Priority = "normal",   -- critical, high, normal, low
  Duration = 3
})
```

---

## 📊 What's New

### v2.8.0 - Named Config Profiles + Auto-Load (Current Release)
- 🚀 **Auto-Load System**: `ConfigurationSaving = true` auto-loads last config!
- 🚀 **Named Profiles**: `ConfigurationSaving = "ProfileName"` for multiple configs
- 🚀 **Theme Guaranteed**: Last theme ALWAYS loads from `_last_config.json`
- 📂 **New Methods**: `SaveConfigAs(name)`, `LoadConfigByName(name)`, `GetLastConfig()`
- 📂 **Last Config Tracker**: `RvrseUI/_last_config.json` stores last used config + theme
- 🎯 **No Setup Required**: Blank config automatically loads last used settings

### v2.7.2 - Pill Sync Fix
- 🎯 **Pill Icon Sync**: 🌙/🌞 icon now matches loaded theme on startup
- 🔧 **syncPillFromTheme()**: Called via task.defer after UI build

### v2.7.1 - GPT-5 Verification Logging
- 🔍 **Diagnostic Logging**: Comprehensive path/instance/value verification
- 📊 **Save Verification**: Logs save path, key, instance, readback after write
- 📊 **Load Verification**: Logs load path, instance, value from disk
- 📊 **Pre-Load Verification**: Confirms CreateWindow pre-load path and value
- 🎯 **Instance Tracking**: Verifies config instance identity across save/load
- 💡 **Based on GPT-5 Analysis**: Finds persistence path/instance/key mismatches

### v2.7.0 - Theme Persistence Fix
- 🚨 **MAJOR FIX**: Saved theme now loads BEFORE cfg.Theme evaluation
- ✅ **Pill Icon Fixed**: 🌙/🌞 icon matches theme state on startup
- 🎯 **Smart Precedence**: saved > cfg.Theme > default "Dark"
- 💡 **First-Run Default**: Theme parameter only used when no saved theme exists

### v2.6.3 - Dirty-Save Protocol
- ✅ **Theme._dirty Flag**: Prevents accidental theme saves during boot
- 🎯 **Theme:Apply()**: Initialization (doesn't mark dirty)
- 🎯 **Theme:Switch()**: User action (marks dirty, triggers save)

### v2.6.0 - Theme Persistence + Boundary Clamping
- 💾 **Theme Auto-Save**: Theme saves when changed via pill toggle
- 💾 **Theme Loading**: Saved theme loads from config on startup
- 🎮 **Controller Boundaries**: Chip can't go off-screen (math.clamp)

### v2.5.2 - Rotating Shine Fix
- ✨ **Rotating Shine**: Premium gradient effect on controller chip
- 🐛 **ImageColor3 Fix**: UIStroke uses Color property, not ImageColor3

### v2.5.0 - Minimize to Controller
- 🎮 **Minimize Button**: ➖ button in header
- 🎮 **Controller Chip**: 🎮 gaming controller for minimized state
- 🌊 **Particle Flow**: 40 particles flow between window and chip
- 🎨 **Premium Animations**: Rotation, scaling, bounce effects

---

## 🎬 Demo Scripts

### Full Demo (All 12 Elements)
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/FULL_DEMO.lua"))()
```

### Configuration Demo
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/CONFIG_DEMO.lua"))()
```

### v2.2.2 Enhancements Demo
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/TEST_v2.2.2_ENHANCEMENTS.lua"))()
```

---

## 📖 Additional Documentation

- **[CONFIG_GUIDE.md](CONFIG_GUIDE.md)** - Complete configuration system guide
- **[ELEMENTS_DOCS.md](ELEMENTS_DOCS.md)** - Detailed element documentation
- **[CLAUDE.md](CLAUDE.md)** - AI-readable codebase documentation
- **[RELEASES.md](RELEASES.md)** - Full version history

---

## 🐛 Troubleshooting

### Configuration not saving?
1. Check if `ConfigurationSaving` is enabled
2. Verify elements have `Flag` parameter
3. Ensure executor supports `writefile()`
4. Wait 1 second for auto-save debounce

### Elements not loading?
1. Ensure `RvrseUI:LoadConfiguration()` is at the **END** of your script
2. Check if config file exists with `RvrseUI:ConfigurationExists()`
3. Verify Flag names match exactly

### Dropdown not working?
**Fixed in v2.3.1!** Update to latest version for proper dropdown list.

---

## 🤝 Contributing

Issues and pull requests are welcome at [GitHub Repository](https://github.com/CoderRvrse/RvrseUI).

---

## 📜 License

MIT License - See [LICENSE](LICENSE) file for details.

---

## 🙏 Credits

**Developer**: CoderRvrse
**Framework**: RvrseUI
**Version**: 2.7.1 "GPT-5 Verification Logging + Theme Persistence"
**Build**: 20251001

Built with ❤️ for the Roblox scripting community.

---

<div align="center">

**[⬆ Back to Top](#rvrseui-v271)**

Made with 🤖 [Claude Code](https://claude.com/claude-code)

</div>
