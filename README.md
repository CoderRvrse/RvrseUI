# RvrseUI v4.0.4

**Modern, Production-Ready Roblox UI Library** with Advanced ColorPicker, Multi-Select Dropdowns, Key System, and 100% Rayfield API Compatibility

![Version](https://img.shields.io/badge/version-4.0.4-blue) ![Status](https://img.shields.io/badge/status-production%20ready-success) ![License](https://img.shields.io/badge/license-MIT-green) ![Build](https://img.shields.io/badge/build-260KB-orange)

---

## 🚀 Quick Start (30 Seconds)

```lua
-- Load RvrseUI
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

-- Create window
local Window = RvrseUI:CreateWindow({
    Name = "My Hub",
    Theme = "Dark",
    ToggleUIKeybind = "K",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MyHub",
        FileName = "Config.json"
    }
})

-- Create a tab
local Tab = Window:CreateTab({ Title = "Main", Icon = "⚙" })
local Section = Tab:CreateSection("Player")

-- Add a slider that SAVES automatically
Section:CreateSlider({
    Text = "Walk Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Flag = "WalkSpeed",  -- 🔑 This makes it save/load automatically!
    OnChanged = function(speed)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = speed
    end
})

-- CRITICAL: Call Window:Show() LAST!
Window:Show()  -- This loads saved config THEN shows UI
```

**🎯 Try it now in your executor!**

---

## 📋 Table of Contents

1. [Features](#-features)
2. [Installation](#-installation)
3. [Configuration System](#-configuration-system-the-most-important-section)
4. [All Elements Guide](#-all-elements-complete-guide)
5. [Advanced Features](#-advanced-features)
6. [Dynamic Updates](#-dynamic-updates--element-api-methods)
7. [API Reference](#-api-reference)
8. [Troubleshooting](#-troubleshooting)
9. [Examples](#-examples)
10. [Rayfield Migration](#-rayfield-migration-guide)

---

## 🎯 Features

### UI Elements (10 Total)
- **Button** - Click actions with ripple effects
- **Toggle** - On/off switches with lock groups
- **Slider** - Numeric values with live preview
- **Dropdown** - Single OR multi-select lists
- **ColorPicker** - RGB/HSV/Hex OR simple presets
- **Keybind** - Capture keyboard inputs
- **TextBox** - Text input fields
- **Label** - Static text
- **Paragraph** - Multi-line text blocks
- **Divider** - Visual separators

### System Features
- **✅ Configuration Persistence** - Auto-save/load with profiles
- **✅ Theme System** - Dark/Light modes with smooth transitions
- **✅ Notification System** - Toast messages with priorities
- **✅ Hotkey Manager** - Global toggle/destroy keys
- **✅ Lock Groups** - Master/slave control relationships
- **✅ Spring Animations** - Smooth, physics-based motion
- **✅ Mobile Support** - Responsive design + controller chip
- **✅ Flag System** - Direct element value access
- **✅ Key System** - Built-in authentication with HWID/User ID validation

---

## 📦 Installation

### Method 1: Direct Load (Recommended)
```lua
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()
```

### Method 2: Version-Specific
```lua
local version = "v4.0.4"
local url = string.format("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/%s/RvrseUI.lua", version)
local RvrseUI = loadstring(game:HttpGet(url))()
```

### Method 3: Local Module (Roblox Studio)
1. Copy `RvrseUI.lua` content
2. Create ModuleScript in ReplicatedStorage
3. Paste content and name it "RvrseUI"
4. Require it: `local RvrseUI = require(game.ReplicatedStorage.RvrseUI)`

---

## 🔧 Configuration System (THE MOST IMPORTANT SECTION!)

### ⚠️ CRITICAL: Understanding the Flag System

**The #1 confusion point:** How do saves/loads work?

**Answer: Use the `Flag` parameter!**

```lua
-- ❌ WRONG - This won't save
Section:CreateSlider({
    Text = "Walk Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    OnChanged = function(speed)
        -- Value changes here, but never saves
    end
})

-- ✅ CORRECT - This saves automatically
Section:CreateSlider({
    Text = "Walk Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Flag = "WalkSpeed",  -- 🔑 ADD THIS!
    OnChanged = function(speed)
        -- Value changes AND saves automatically
    end
})
```

### How Flags Work (Read This Carefully!)

1. **Without `Flag`**: Element works, but value is never saved
2. **With `Flag`**: Element value auto-saves when changed
3. **Access saved value**: `RvrseUI.Flags["WalkSpeed"]:Get()`
4. **Set value programmatically**: `RvrseUI.Flags["WalkSpeed"]:Set(50)`

### Complete Configuration Example

```lua
local Window = RvrseUI:CreateWindow({
    -- 📌 BASIC SETTINGS
    Name = "My Hub",                    -- Window title
    Icon = "🎮",                        -- Window icon (emoji or asset ID)
    Theme = "Dark",                     -- "Dark" or "Light"

    -- 📌 HOTKEYS
    ToggleUIKeybind = "K",              -- Press K to toggle UI
    EscapeKey = Enum.KeyCode.Backspace, -- Press Backspace to destroy UI

    -- 📌 CONFIGURATION PERSISTENCE (CRITICAL!)
    ConfigurationSaving = {
        Enabled = true,                 -- Turn on save/load
        FolderName = "MyHub",          -- Creates: workspace/MyHub/
        FileName = "Config.json",       -- File: MyHub/Config.json
        AutoSave = true                 -- Auto-save on every change (optional)
    },

    -- 📌 PROFILES TAB (OPTIONAL)
    ConfigurationManager = {
        Enabled = true,                 -- Show "Profiles" tab
        TabName = "Profiles",          -- Tab name
        Icon = "📁"                    -- Tab icon
    },

    -- 📌 LOADING SCREEN
    LoadingTitle = "My Hub",
    LoadingSubtitle = "Loading features...",

    -- 📌 ADVANCED (OPTIONAL)
    DisableBuildWarnings = false,      -- Hide startup notification
    Container = "PlayerGui",            -- Where to place UI
    DisplayOrder = 100000               -- Z-index
})
```

### Configuration Save Locations

**Where are configs saved?**
- Synapse X: `workspace/`
- Script-Ware: `workspace/`
- Krnl: `workspace/`
- Other executors: Check your executor's `writefile` directory

**File structure:**
```
workspace/
└── MyHub/              ← FolderName
    ├── Config.json     ← FileName (default profile)
    ├── Profile1.json   ← Saved profile
    └── Profile2.json   ← Another profile
```

### Manual Save/Load

```lua
-- Save current configuration
local success, message = RvrseUI:SaveConfiguration()
if success then
    print("✅ Config saved:", message)
end

-- Load configuration
local success, message = RvrseUI:LoadConfiguration()
if success then
    print("✅ Config loaded:", message)
end

-- Toggle auto-save
RvrseUI:SetAutoSaveEnabled(false)  -- Pause auto-save
RvrseUI:SetAutoSaveEnabled(true)   -- Resume auto-save
```

---

## 📚 All Elements (Complete Guide)

### 1. Button

**What it does:** Clickable button that triggers a callback

```lua
local myButton = Section:CreateButton({
    Text = "Click Me",                  -- Button label
    Callback = function()
        print("Button clicked!")
    end
})

-- API Methods
myButton:Set("New Text")               -- Change button text
```

**Use case:** Actions that don't need state (teleport, reset character, etc.)

---

### 2. Toggle

**What it does:** On/Off switch with state persistence

```lua
local myToggle = Section:CreateToggle({
    Text = "Enable Flight",
    State = false,                     -- Initial state (default: false)
    Flag = "FlightEnabled",            -- 🔑 Saves automatically!
    OnChanged = function(enabled)
        if enabled then
            print("Flight ON")
        else
            print("Flight OFF")
        end
    end
})

-- API Methods
myToggle:Set(true, silent)             -- Set state (silent = don't trigger callback)
local state = myToggle:Get()           -- Get current state
```

**Use case:** Features that can be on or off (ESP, flight, speed hacks)

---

### 3. Slider

**What it does:** Numeric value selector with visual feedback

```lua
local mySlider = Section:CreateSlider({
    Text = "Walk Speed",
    Min = 16,                          -- Minimum value
    Max = 100,                         -- Maximum value
    Step = 2,                          -- Increment (optional, default: 1)
    Default = 16,                      -- Starting value
    Suffix = " studs/s",              -- Text after value (optional)
    Flag = "WalkSpeed",                -- 🔑 Saves automatically!
    OnChanged = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})

-- API Methods
mySlider:Set(50)                       -- Set value
mySlider:SetRange(0, 200, 10)         -- Change min/max/step
mySlider:SetSuffix(" mph")            -- Change suffix
local value = mySlider:Get()          -- Get current value
```

**Use case:** Any numeric setting (speed, jump power, FOV, brightness)

---

### 4. Dropdown

**What it does:** List of options (single OR multiple selection)

#### Single-Select (Standard)
```lua
local myDropdown = Section:CreateDropdown({
    Text = "Select Weapon",
    Values = {"Sword", "Bow", "Staff", "Axe"},

    CurrentOption = {"Sword"},      -- Pre-select (optional)
    MultiSelect = false,             -- Single-select mode (default)
    Flag = "SelectedWeapon",         -- 🔑 Saves automatically!
    OnChanged = function(selected)
        -- ALWAYS receives a table, even in single-select!
        print("Weapon:", selected[1])  -- Access first item
        -- Or use table.concat:
        print("Weapon:", table.concat(selected, ", "))
    end
})

-- API Methods
myDropdown:Set("Bow")                              -- Change selection
myDropdown:Refresh({"New", "Options", "List"})     -- Update options
local weapon = myDropdown:Get()                    -- Get selected value
```

#### Multi-Select
```lua
local multiDropdown = Section:CreateDropdown({
    Text = "Select Game Modes",
    Values = {"TDM", "CTF", "KotH", "FFA"},

    CurrentOption = {"TDM", "FFA"},  -- Pre-select multiple!
    MultiSelect = true,               -- Enable multi-select
    TruncationMode = "singleLine",    -- "singleLine" (ellipsis) or "twoLine" (wrap)
    Flag = "GameModes",               -- 🔑 Saves as array!
    OnChanged = function(selected)
        -- selected is an ARRAY: {"TDM", "FFA", "KotH"}
        print("Selected:", table.concat(selected, ", "))
    end
})

-- API Methods
multiDropdown:Set({"TDM", "CTF"})                 -- Set multiple
multiDropdown:SelectAll()                          -- Select all options
multiDropdown:ClearAll()                           -- Clear all selections
local selected = multiDropdown:Get()               -- Returns array
print(#selected, "modes selected")                 -- Count selections
```

**Use case:**
- Single-select: Weapon, difficulty, game mode
- Multi-select: Select multiple features to enable

**TruncationMode (optional):**
- `"singleLine"` (default) - Long labels truncate with ellipsis (...)
- `"twoLine"` - Labels can wrap to 2 lines, then truncate

This prevents long text from overlapping icons and cramming together.

> **Note:** RvrseUI is Rayfield-compatible. Rayfield parameters `Options` and `MultipleOptions` also work.

---

### 5. ColorPicker

**What it does:** Color selector with advanced controls

#### Simple Mode (8 Preset Colors)
```lua
local simpleColor = Section:CreateColorPicker({
    Text = "Theme Color",
    Default = Color3.fromRGB(255, 0, 0),           -- Red
    Advanced = false,                               -- Simple mode
    Flag = "ThemeColor",                            -- 🔑 Saves automatically!
    OnChanged = function(color)
        print("Color:", color)
    end
})
```

#### Advanced Mode (RGB/HSV/Hex Sliders)
```lua
local advancedColor = Section:CreateColorPicker({
    Text = "Custom Color",
    Default = Color3.fromRGB(88, 101, 242),        -- Discord Blurple
    Advanced = true,                                -- Advanced mode (default)
    Flag = "CustomColor",                           -- 🔑 Saves automatically!
    OnChanged = function(color)
        -- Update UI elements
        game.StarterGui.ScreenGui.Frame.BackgroundColor3 = color
    end
})

-- Advanced mode includes:
-- • RGB sliders (0-255)
-- • HSV sliders (H: 0-360, S/V: 0-100%)
-- • Hex input (#RRGGBB)
-- • Live preview circle
-- • All modes stay in sync!
```

**API Methods:**
```lua
advancedColor:Set(Color3.fromRGB(255, 0, 255))    -- Set color
local color = advancedColor:Get()                  -- Get current color
```

**Use case:** Theme customization, ESP colors, UI tinting

---

### 6. Keybind

**What it does:** Captures keyboard input for hotkeys

```lua
local myKeybind = Section:CreateKeybind({
    Text = "Dash Key",
    Default = Enum.KeyCode.Q,                      -- Default key
    Flag = "DashKey",                               -- 🔑 Saves automatically!
    OnChanged = function(key)
        print("Dash key changed to:", key.Name)
    end,

    -- Special flags (optional):
    IsUIToggle = true,    -- Makes this control UI toggle key
    IsUIEscape = true     -- Makes this control UI destroy key
})

-- API Methods
myKeybind:Set(Enum.KeyCode.E)                     -- Change key
local key = myKeybind:Get()                        -- Get current key
```

**Use case:** Rebindable hotkeys for features

---

### 7. TextBox

**What it does:** Single-line text input

```lua
local myTextBox = Section:CreateTextBox({
    Text = "Player Name",
    PlaceholderText = "Enter name...",             -- Hint text
    Default = "Guest",                              -- Starting value
    Flag = "PlayerName",                            -- 🔑 Saves automatically!
    OnChanged = function(text)
        print("Text changed:", text)
    end,
    OnEnter = function(text)
        print("Enter pressed:", text)
    end
})

-- API Methods
myTextBox:Set("NewValue")                          -- Set text
local text = myTextBox:Get()                       -- Get current text
```

**Use case:** Username input, custom messages, search fields

---

### 8. Label

**What it does:** Static text display

```lua
local myLabel = Section:CreateLabel({
    Text = "Status: Ready"
})

-- API Methods
myLabel:Set("Status: Active")                      -- Update text
```

**Use case:** Status messages, instructions, headers

---

### 9. Paragraph

**What it does:** Multi-line text block

```lua
Section:CreateParagraph({
    Text = "Welcome to My Hub!\n\nFeatures:\n• Auto Farm\n• ESP\n• Speed Hack"
})
```

**Use case:** Descriptions, changelogs, instructions

---

### 10. Divider

**What it does:** Visual separator between elements

```lua
Section:CreateDivider()
```

**Use case:** Organize sections visually

---

## 🔥 Advanced Features

### Lock Groups (Master/Slave Controls)

**Problem:** Some settings conflict with each other
**Solution:** Lock groups automatically disable conflicting options

```lua
-- Scenario: Auto Farm should disable manual farming options

-- Master toggle
Section:CreateToggle({
    Text = "🎯 Auto Farm (Master)",
    LockGroup = "AutoFarm",           -- Creates the lock
    Flag = "AutoFarmMaster"
})

-- These get disabled when master is ON:
Section:CreateToggle({
    Text = "Manual Farm Coins",
    RespectLock = "AutoFarm",        -- Obeys the lock
    Flag = "ManualCoins"
})

Section:CreateSlider({
    Text = "Farm Speed",
    Min = 1,
    Max = 10,
    RespectLock = "AutoFarm",        -- Slider also obeys lock!
    Flag = "FarmSpeed"
})
```

**When master is ON:**
- All child controls become disabled (grayed out)
- Prevents users from creating conflicting settings
- Automatically re-enables when master turns OFF

---

### 🔐 Key System (Authentication)

**Protect your hub with a key system!** RvrseUI includes built-in key validation with multiple authentication methods, Discord webhook logging, and 100% Rayfield compatibility.

#### Basic Key System (Rayfield Compatible)

```lua
local Window = RvrseUI:CreateWindow({
    Name = "Protected Hub",

    -- Enable key system
    KeySystem = true,

    KeySettings = {
        -- UI Configuration
        Title = "My Hub - Authentication",
        Subtitle = "Enter your key to continue",
        Note = "Visit myhub.gg/key to get a key",

        -- Simple key validation
        Key = "MySecretKey123",  -- Single key (Rayfield compatible)

        -- OR multiple keys
        -- Keys = {"VIPKey2024", "AdminKey999", "DevKey123"},

        -- Save key locally
        SaveKey = true,
        FileName = "MyHubKey",

        -- Security settings
        MaxAttempts = 3,         -- Attempts before kick
        KickOnFailure = true     -- Kick player if validation fails
    }
})

-- If execution reaches here, key was validated successfully!
```

#### Advanced Validation Methods

**1. Multiple Valid Keys**
```lua
KeySettings = {
    Keys = {"VIPKey2024", "AdminKey999", "TrialKey"},
    SaveKey = true,
    FileName = "License"
}
```

**2. Remote Key Fetching (Pastebin/GitHub)**
```lua
KeySettings = {
    GrabKeyFromSite = true,
    Key = "https://pastebin.com/raw/YourKeyHere",  -- Fetches key from URL
    SaveKey = true
}
```

**3. HWID/User ID Whitelist**
```lua
KeySettings = {
    Whitelist = {
        "123456789",           -- User ID
        "HWID-ABC123",         -- Hardware ID
        "ManualOverride"       -- Manual key
    },
    MaxAttempts = 3
}
```

**4. Custom Validator Function**
```lua
KeySettings = {
    Validator = function(inputKey)
        -- Example: Key changes daily
        local dailyKey = "KEY-" .. os.date("%Y%m%d")
        if inputKey == dailyKey then
            return true
        end

        -- Or validate against external API
        local success, response = pcall(function()
            return game:HttpGet("https://api.example.com/validate?key=" .. inputKey)
        end)

        return success and response == "valid"
    end,
    SaveKey = false  -- Don't save since key changes
}
```

#### Discord Webhook Logging

Log all key attempts to Discord:

```lua
KeySettings = {
    Keys = {"SecretKey2024"},

    -- Discord webhook URL
    WebhookURL = "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE",

    MaxAttempts = 3
}
```

**Webhook sends:**
- Username & User ID
- Input key
- Validation result (success/failure)
- Timestamp
- Attempts remaining

#### "Get Key" Button

Add a button to help users get keys:

```lua
KeySettings = {
    Note = "Click below to get your key",

    NoteButton = {
        Text = "🔑 Get Key",
        Callback = function()
            -- Copy link to clipboard
            setclipboard("https://myhub.gg/getkey")

            RvrseUI:Notify({
                Title = "Link Copied!",
                Message = "Key shop link copied to clipboard",
                Type = "success"
            })
        end
    },

    Keys = {"PremiumKey2024"}
}
```

#### Custom Callbacks

React to key validation events:

```lua
KeySettings = {
    Keys = {"TestKey123"},

    -- Called when valid key entered
    OnKeyValid = function(validKey)
        print("✓ User authenticated with:", validKey)

        RvrseUI:Notify({
            Title = "Welcome!",
            Message = "Access granted",
            Type = "success"
        })
    end,

    -- Called when invalid key entered
    OnKeyInvalid = function(invalidKey, attemptsLeft)
        warn("Failed attempt:", invalidKey, "- Remaining:", attemptsLeft)
    end,

    -- Called when attempts exhausted
    OnAttemptsExhausted = function()
        print("⚠️ User ran out of attempts")
        -- Custom action (e.g., redirect to purchase page)
    end,

    KickOnFailure = false  -- Handle manually in callbacks
}
```

---

### Notification System

```lua
-- Basic notification
RvrseUI:Notify({
    Title = "Success!",
    Message = "Action completed",
    Duration = 3,                    -- Seconds (optional, default: 4)
    Type = "success"                 -- "success", "info", "warn", "error"
})

-- With priority
RvrseUI:Notify({
    Title = "CRITICAL ERROR",
    Message = "Something went wrong!",
    Type = "error",
    Priority = "critical",           -- "critical", "high", "normal", "low"
    Duration = 10
})
```

**Types:**
- `success` - Green, checkmark icon
- `info` - Blue, info icon
- `warn` - Yellow, warning icon
- `error` - Red, error icon

---

### Theme System

```lua
-- Switch theme
RvrseUI:SetTheme("Light")          -- "Dark" or "Light"

-- Theme auto-saves if ConfigurationSaving is enabled!
```

---

### Flag System (Direct Access)

**Access any element's value directly:**

```lua
-- Get value from any flagged element
local speed = RvrseUI.Flags["WalkSpeed"]:Get()

-- Set value programmatically
RvrseUI.Flags["WalkSpeed"]:Set(50)

-- Check if flag exists
if RvrseUI.Flags["WalkSpeed"] then
    print("Walk speed element exists!")
end

-- IMPORTANT: Use RvrseUI.Flags, NOT Window.Flags!
```

---

## 🔄 Dynamic Updates & Element API Methods

**All elements can be updated programmatically after creation!**

### Common Methods (All Elements)

```lua
-- Show/hide elements dynamically
element:SetVisible(true)   -- Show the element
element:SetVisible(false)  -- Hide the element

-- Get/set current value (most elements)
local value = element:Get()  -- Get current value
element:Set(newValue)        -- Set new value
```

### Real-World Update Examples

#### Live Player Stats Display

```lua
-- Create status labels
local coinsLabel = Section:CreateLabel({ Text = "Coins: 0" })
local levelLabel = Section:CreateLabel({ Text = "Level: 1" })

-- Update loop
game:GetService("RunService").Heartbeat:Connect(function()
    coinsLabel:Set("Coins: " .. tostring(playerCoins))
    levelLabel:Set("Level: " .. tostring(playerLevel))
end)
```

#### Dynamic Dropdown Based on Game State

```lua
local weaponDropdown = Section:CreateDropdown({
    Text = "Equip Weapon",
    Values = {},
    Flag = "EquippedWeapon"
})

-- Function to update available weapons
local function updateWeaponList()
    local inventory = getPlayerInventory()  -- Your inventory function
    weaponDropdown:Refresh(inventory)
end

-- Update when inventory changes
game.Players.LocalPlayer.Inventory.ChildAdded:Connect(updateWeaponList)
```

#### Using RvrseUI.Flags for Cross-Element Updates

```lua
-- Create elements with flags
local speedSlider = Section:CreateSlider({
    Text = "Walk Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Flag = "WalkSpeed"  -- Accessible via RvrseUI.Flags
})

local resetButton = Section:CreateButton({
    Text = "Reset to Default",
    OnClick = function()
        -- Access any flagged element via RvrseUI.Flags
        RvrseUI.Flags["WalkSpeed"]:Set(16)

        -- You can update multiple elements at once
        if RvrseUI.Flags["JumpPower"] then
            RvrseUI.Flags["JumpPower"]:Set(50)
        end
        if RvrseUI.Flags["GodMode"] then
            RvrseUI.Flags["GodMode"]:Set(false)
        end
    end
})
```

---

## 📖 API Reference

### Window API

```lua
local Window = RvrseUI:CreateWindow(config)

-- Methods
Window:CreateTab({ Title = "Main", Icon = "⚙" })
Window:Show()                        -- CRITICAL: Call this LAST!
Window:SetTitle("New Title")
Window:SetIcon("🎮")
Window:Destroy()
```

### Tab API

```lua
local Tab = Window:CreateTab({ Title = "Main", Icon = "⚙" })

-- Methods
Tab:CreateSection("Section Name")
Tab:SetIcon("🔧")
```

### Section API

```lua
local Section = Tab:CreateSection("Player Features")

-- Element Factories
Section:CreateButton(config)
Section:CreateToggle(config)
Section:CreateSlider(config)
Section:CreateDropdown(config)
Section:CreateColorPicker(config)
Section:CreateKeybind(config)
Section:CreateTextBox(config)
Section:CreateLabel(config)
Section:CreateParagraph(config)
Section:CreateDivider()

-- Methods
Section:SetVisible(true/false)
Section:Update("New Section Title")
```

### Global API

```lua
RvrseUI:Notify(config)                -- Show notification
RvrseUI:SaveConfiguration()           -- Manual save
RvrseUI:LoadConfiguration()           -- Manual load
RvrseUI:SetTheme("Dark"/"Light")     -- Switch theme
RvrseUI:SetAutoSaveEnabled(bool)     -- Toggle auto-save
RvrseUI:EnableDebug(true)            -- Enable debug logging
RvrseUI:GetVersionInfo()             -- Get version info
RvrseUI.Flags                        -- Access all flagged elements
```

---

## 🐛 Troubleshooting

### "My settings aren't saving!"

**Problem:** Values reset when you reload
**Solution:** Add `Flag` parameter to your elements!

```lua
-- ❌ NO FLAG = NO SAVE
Section:CreateSlider({
    Text = "Speed",
    Min = 16,
    Max = 100
})

-- ✅ FLAG = AUTO-SAVE
Section:CreateSlider({
    Text = "Speed",
    Min = 16,
    Max = 100,
    Flag = "WalkSpeed"  -- ADD THIS!
})
```

### "attempt to index nil with 'Flags'"

**Problem:** Using `Window.Flags` instead of `RvrseUI.Flags`
**Solution:** Change all references:

```lua
-- ❌ WRONG
if Window.Flags then
    local speed = Window.Flags["WalkSpeed"]:Get()
end

-- ✅ CORRECT
if RvrseUI.Flags then
    local speed = RvrseUI.Flags["WalkSpeed"]:Get()
end
```

### "Config loaded but values didn't restore"

**Problem:** Not calling `Window:Show()` after creating elements
**Solution:** Always call `Window:Show()` LAST!

```lua
-- Create window
local Window = RvrseUI:CreateWindow(config)

-- Create all tabs, sections, elements...
local Tab = Window:CreateTab(...)
local Section = Tab:CreateSection(...)
Section:CreateSlider(...)

-- ✅ CRITICAL: Call Show() LAST!
Window:Show()  -- This loads config THEN shows UI
```

### "Dropdown multi-select not working"

**Problem:** Forgot to enable multi-select mode
**Solution:** Set `MultiSelect = true`:

```lua
-- ✅ CORRECT - Multi-select dropdown
Section:CreateDropdown({
    Text = "Select Items",
    Values = {"Item1", "Item2", "Item3"},
    MultiSelect = true,      -- MUST BE TRUE for multi-select!
    CurrentOption = {"Item1"},
    Flag = "MyDropdown",
    OnChanged = function(selected)
        -- selected is an ARRAY: {"Item1", "Item3"}
        print("Selected:", table.concat(selected, ", "))
    end
})

-- ❌ WRONG - This creates single-select
Section:CreateDropdown({
    Values = {...},
    -- Missing MultiSelect = true!
})
```

### "ColorPicker panel not showing"

**Problem:** `Advanced = false` or not set
**Solution:** Set `Advanced = true`:

```lua
Section:CreateColorPicker({
    Text = "Color",
    Advanced = true,  -- Enables RGB/HSV/Hex panel
    Default = Color3.fromRGB(255, 0, 0)
})
```

---

## 💡 Examples

### Complete Hub Example

```lua
-- Load RvrseUI
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

-- Create window
local Window = RvrseUI:CreateWindow({
    Name = "My Game Hub",
    Icon = "🎮",
    Theme = "Dark",
    ToggleUIKeybind = "K",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MyGameHub",
        FileName = "Config.json"
    },
    LoadingTitle = "My Game Hub",
    LoadingSubtitle = "Loading features..."
})

-- Main Tab
local MainTab = Window:CreateTab({ Title = "Main", Icon = "⚙" })
local PlayerSection = MainTab:CreateSection("Player")

-- Walk Speed with save
PlayerSection:CreateSlider({
    Text = "Walk Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Flag = "WalkSpeed",
    OnChanged = function(speed)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = speed
    end
})

-- Jump Power with save
PlayerSection:CreateSlider({
    Text = "Jump Power",
    Min = 50,
    Max = 200,
    Default = 50,
    Flag = "JumpPower",
    OnChanged = function(power)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = power
    end
})

-- Infinite Jump toggle
PlayerSection:CreateToggle({
    Text = "Infinite Jump",
    State = false,
    Flag = "InfiniteJump",
    OnChanged = function(enabled)
        -- Implementation here
        if enabled then
            RvrseUI:Notify({
                Title = "Infinite Jump",
                Message = "Enabled!",
                Type = "success"
            })
        end
    end
})

-- Combat Tab
local CombatTab = Window:CreateTab({ Title = "Combat", Icon = "⚔️" })
local CombatSection = CombatTab:CreateSection("Auto Farm")

-- Master toggle with lock group
CombatSection:CreateToggle({
    Text = "🎯 Auto Farm (Master)",
    State = false,
    LockGroup = "AutoFarm",
    Flag = "AutoFarmMaster",
    OnChanged = function(enabled)
        RvrseUI:Notify({
            Title = enabled and "Auto Farm Started" or "Auto Farm Stopped",
            Message = enabled and "Individual farms locked" or "Manual control restored",
            Type = enabled and "success" or "info"
        })
    end
})

-- Child toggles
CombatSection:CreateToggle({
    Text = "Farm Coins",
    State = false,
    RespectLock = "AutoFarm",
    Flag = "FarmCoins"
})

CombatSection:CreateToggle({
    Text = "Farm XP",
    State = false,
    RespectLock = "AutoFarm",
    Flag = "FarmXP"
})

-- Settings Tab
local SettingsTab = Window:CreateTab({ Title = "Settings", Icon = "🔧" })
local ThemeSection = SettingsTab:CreateSection("Appearance")

-- Theme color picker
ThemeSection:CreateColorPicker({
    Text = "Theme Color",
    Default = Color3.fromRGB(88, 101, 242),
    Advanced = true,
    Flag = "ThemeColor",
    OnChanged = function(color)
        -- Apply to UI elements
    end
})

-- CRITICAL: Show window LAST!
Window:Show()

-- Welcome message
RvrseUI:Notify({
    Title = "Welcome!",
    Message = "Press K to toggle UI",
    Duration = 5,
    Type = "success"
})
```

---

## 🔄 Rayfield Compatibility

**Migrating from Rayfield?** RvrseUI is 100% API-compatible. Your existing Rayfield code will work as-is - just change the loadstring URL.

---

## 📚 Additional Resources

- **[Developer Notes](DEV_NOTES.md)** - Version history, changelog, and technical notes
- **[Build System Documentation](CLAUDE.md)** - Architecture and maintainer guide
- **[GitHub Repository](https://github.com/CoderRvrse/RvrseUI)** - Source code and issues

---

## ⚖️ License

MIT License - See [LICENSE](LICENSE) file

---

## 🔗 Links

- **GitHub Repository:** [CoderRvrse/RvrseUI](https://github.com/CoderRvrse/RvrseUI)
- **Issues:** [Report bugs here](https://github.com/CoderRvrse/RvrseUI/issues)
- **Loadstring:** `https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua`

---

## 💬 Support

**Confused? Check these first:**
1. ✅ Did you add `Flag` to save values?
2. ✅ Did you call `Window:Show()` LAST?
3. ✅ Are you using `RvrseUI.Flags` (not `Window.Flags`)?
4. ✅ Did you enable `ConfigurationSaving`?

**Still stuck? Open an issue on GitHub with:**
- Your code (simplified example)
- What you expected
- What actually happened
- Any error messages

---

**Made with ❤️ by CoderRvrse**

**Version 4.0.4** • **Build 260KB** • **28 Modules** • **Production Ready**
