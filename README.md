# RvrseUI v4.0.4

**Modern, Production-Ready Roblox UI Library** with RGB/HSV ColorPicker, Multi-Select Dropdowns, and 100% Rayfield API Compatibility

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

1. [What's New in v4.0](#-whats-new-in-v40)
2. [Features](#-features)
3. [Installation](#-installation)
4. [Configuration System (IMPORTANT!)](#-configuration-system-the-most-important-section)
5. [All Elements Guide](#-all-elements-complete-guide)
6. [Dynamic Updates & Element API Methods](#-dynamic-updates--element-api-methods)
7. [Advanced Features](#-advanced-features)
8. [API Reference](#-api-reference)
9. [Troubleshooting](#-troubleshooting)
10. [Examples](#-examples)

---

## ✨ What's New in v4.0.4 (Latest)

### 🎯 CRITICAL FIX: Complete Drag System Rewrite - Back to Basics!
- **Problem:** Window and controller chip "kicked away" from cursor during drag
- **Root Cause:** Overcomplicated drag logic with AbsolutePosition/AnchorPoint math introduced offset bugs
- **Solution:** Replaced ~600 lines of complex code with ~140 lines of classic Roblox drag pattern
- **Result:** No jumps, no offset drift, cursor stays glued to grab point! ✅

**The Simple Pattern:**
```lua
-- Store starting positions
local dragStart = input.Position
local startPos = frame.Position

-- Calculate delta and apply
local delta = input.Position - dragStart
frame.Position = UDim2.new(
    startPos.X.Scale,
    startPos.X.Offset + delta.X,
    startPos.Y.Scale,
    startPos.Y.Offset + delta.Y
)
```

**What Was Removed:**
- ❌ AbsolutePosition calculations and GUI inset handling
- ❌ AnchorPoint math and coordinate space conversions
- ❌ Size locking systems and hover animation blocking
- ✅ Kept: Animation blocking during minimize/restore tweens

**65% code reduction** (400 lines → 140 lines) - simpler is better!

---

## Previous Updates (v4.0.3)

### 🎉 CRITICAL FIX: Multi-Select Dropdown Blocker Now Works!
- **Fixed Modern Dropdown** - Multi-select now closes properly when clicking outside! ✅
- **Root Cause:** **Lua closure upvalue capture bug** - closures capture VALUES not references
- **The Bug:** Wrapper function `closeDropdown()` captured `setOpen` as `nil` at definition time
- **The Fix:** Use inline anonymous functions created at connection point (inside `setOpen` body)
- **Evidence:** Logs showed `setOpen` was `function` when connecting, but `nil` when handler fired!
- **Result:** Dropdown blocker now works perfectly - clicks close the dropdown as expected

**Before (Broken):**
```lua
local setOpen
local function closeDropdown() return setOpen end  -- Captures nil!
setOpen = function() end  -- Too late, closeDropdown has nil
```

**After (Fixed):**
```lua
local setOpen
setOpen = function()
    Connect(function() return setOpen end)  -- Captures current scope!
end
```

### 🧪 Test Multi-Select Dropdown
Run this test to verify multi-select works:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/examples/test-dropdown-simple.lua"))()
```
✅ Select multiple colors
✅ Click outside the dropdown (on dimmed area)
✅ Dropdown closes successfully!

### Previous Fixes (v4.0.2)
- **Error Fixed:** `:3853: attempt to call a nil value` when closing multi-select dropdown
- **Root Cause:** Function scoping issue - `setOpen()` called before being declared
- **Solution:** Added forward declaration `local setOpen` before blocker creation
- **DropdownLegacy Note:** Does NOT support multi-select (single-select only)

### 🚨 v4.0.1: Shadow Helper Blocking Overlays
- **Fixed ColorPicker** - Removed shadow() causing gray box to cover entire screen
- **Fixed Dropdown (both versions)** - Removed shadow() on dropdown menus
- **Root Cause:** `UIHelpers.shadow()` creates ImageLabel 40px larger than parent
- **Solution:** Disabled shadow() for ALL overlay elements, use stroke() instead

### Phase 2 Features (v4.0)
- **🎨 Advanced ColorPicker** - Full RGB/HSV sliders + Hex input (NOW WORKING!)
- **📋 Dropdown Multi-Select** - Checkboxes, SelectAll/ClearAll methods
- **🔐 KeySystem Integration** - Advanced key validation with lockout protection
- **🔄 100% Rayfield API Compatible** - Migrate from Rayfield with zero changes!

### Critical Bug Fixes (v4.0)
- **✅ Fixed Flag System** - Now uses `RvrseUI.Flags` (not `Window.Flags`)
- **✅ Fixed Config Loading** - Values now restore correctly on startup
- **✅ Fixed Dropdown Pre-selection** - `CurrentOption` now works perfectly

### What Makes RvrseUI Different
- ✅ **Actually works** - Configs save and load correctly
- ✅ **Clear documentation** - No confusing references
- ✅ **Production tested** - Used in real hubs
- ✅ **Rayfield compatible** - Drop-in replacement

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

---

## 📦 Installation

### Method 1: Direct Load (Recommended)
```lua
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()
```

### Method 2: Version-Specific
```lua
local version = "v4.0.2"
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
else
    print("❌ Save failed:", message)
end

-- Load configuration
local success, message = RvrseUI:LoadConfiguration()
if success then
    print("✅ Config loaded:", message)
else
    print("❌ Load failed:", message)
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

#### Advanced: Lock Groups (Master/Slave Controls)

```lua
-- Master toggle that locks children when ON
Section:CreateToggle({
    Text = "🎯 Auto Farm (MASTER)",
    State = false,
    LockGroup = "AutoFarm",            -- Creates lock group
    Flag = "AutoFarmMaster"
})

-- Child toggle that gets disabled when master is ON
Section:CreateToggle({
    Text = "Farm Coins",
    State = false,
    RespectLock = "AutoFarm",          -- Respects the lock group
    Flag = "FarmCoins"
})

-- When "Auto Farm (MASTER)" is ON:
-- → "Farm Coins" becomes disabled (grayed out)
-- → Prevents conflicting settings
```

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

### 4. Dropdown (NEW: Multi-Select!)

**What it does:** List of options (single OR multiple selection)

#### Single-Select (Standard)
```lua
local myDropdown = Section:CreateDropdown({
    Text = "Select Weapon",
    Values = {"Sword", "Bow", "Staff", "Axe"},     -- Options
    -- OR use Rayfield syntax:
    Options = {"Sword", "Bow", "Staff", "Axe"},    -- Same thing!

    CurrentOption = {"Sword"},                      -- Pre-select (optional)
    MultiSelect = false,                            -- Single-select mode
    Flag = "SelectedWeapon",                        -- 🔑 Saves automatically!
    OnChanged = function(value)
        print("Weapon:", value)  -- Returns single value
    end
})

-- API Methods
myDropdown:Set("Bow")                              -- Change selection
myDropdown:Refresh({"New", "Options", "List"})     -- Update options
local weapon = myDropdown:Get()                    -- Get selected value
print(myDropdown.CurrentOption[1])                 -- Rayfield compatibility
```

#### Multi-Select (Phase 2 Feature!)
```lua
local multiDropdown = Section:CreateDropdown({
    Text = "Select Game Modes",
    Options = {"TDM", "CTF", "KotH", "FFA"},       -- Options
    CurrentOption = {"TDM", "FFA"},                 -- Pre-select multiple!
    MultipleOptions = true,                         -- Multi-select mode
    Flag = "GameModes",                             -- 🔑 Saves as array!
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

---

### 5. ColorPicker (NEW: RGB/HSV/Hex!)

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

**Protect your hub with a key system!** RvrseUI includes a built-in key validation system with multiple authentication methods, Discord webhook logging, and 100% Rayfield compatibility.

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

#### Complete KeySettings Reference

```lua
KeySettings = {
    -- UI Configuration
    Title = "string",              -- Modal title
    Subtitle = "string",           -- Modal subtitle
    Note = "string",               -- Instruction text
    NoteButton = {                 -- Optional "Get Key" button
        Text = "string",
        Callback = function() end
    },

    -- Validation Method (choose one or combine)
    Key = "string",                -- Single key (Rayfield compatible)
    Keys = {"key1", "key2"},       -- Multiple keys (RvrseUI extension)
    Whitelist = {"id1", "id2"},    -- HWID/User ID whitelist
    Validator = function(key)      -- Custom function
        return boolean
    end,

    -- Remote Fetching
    GrabKeyFromSite = false,       -- Fetch from URL
    -- Key = "https://pastebin.com/raw/ABC",

    -- Security
    SaveKey = true,                -- Save validated key locally
    FileName = "string",           -- Saved key filename
    MaxAttempts = 3,               -- Attempts before kick
    KickOnFailure = true,          -- Kick on failure

    -- Logging
    WebhookURL = "string",         -- Discord webhook (optional)

    -- Callbacks (optional)
    OnKeyValid = function(key) end,
    OnKeyInvalid = function(key, attempts) end,
    OnAttemptsExhausted = function() end
}
```

#### Key System Flow

1. **User loads hub** → Key system UI appears (blocks execution)
2. **Check saved key** → If valid saved key exists, skip UI
3. **User enters key** → Validation runs
4. **Valid key** → UI closes, hub loads, key saved (if SaveKey=true)
5. **Invalid key** → Shake animation, attempts decrease
6. **Out of attempts** → Kick player (if KickOnFailure=true)

#### Rayfield Migration

**Your existing Rayfield key system code works as-is!**

```lua
-- This Rayfield code works in RvrseUI:
KeySystem = true,
KeySettings = {
    Title = "Untitled",
    Subtitle = "Key System",
    Note = "No method of obtaining the key is provided",
    FileName = "Key",
    SaveKey = true,
    GrabKeyFromSite = false,
    Key = {"Hello"}  -- Rayfield uses table for Key
}
```

**RvrseUI improvements you can add:**
- `Keys` array for clearer multi-key syntax
- `Whitelist` for HWID/User ID validation
- `Validator` function for custom logic
- `WebhookURL` for Discord logging
- `NoteButton` for "Get Key" actions
- `OnKeyValid`/`OnKeyInvalid` callbacks
- Better themed UI with animations

#### Testing Lockout Behavior

**Example: Test invalid key attempts and graceful failure handling**

```lua
-- ✅ Final Test Script - Test Invalid Keys
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

-- Enable debug to see validation flow
RvrseUI:EnableDebug(true)

local Window = RvrseUI:CreateWindow({
    Name = "Lockout Test Hub",
    Icon = "🔐",
    Theme = "Dark",

    KeySystem = true,
    KeySettings = {
        Title = "Test Lockout System",
        Subtitle = "Try entering invalid keys",
        Note = "You have 3 attempts to enter the correct key",

        -- Correct key for testing
        Keys = {"CorrectKey123"},

        -- Lockout settings
        MaxAttempts = 3,
        KickOnFailure = true,  -- Will kick after 3 failed attempts

        -- Callbacks to see what's happening
        OnKeyValid = function(key)
            print("✓ Valid key entered:", key)
        end,

        OnKeyInvalid = function(key, attemptsLeft)
            print("✗ Invalid key:", key)
            print("Attempts remaining:", attemptsLeft)
        end,

        OnAttemptsExhausted = function()
            print("⚠️ Out of attempts! User will be kicked.")
        end
    }
})

-- This code only runs if key was validated successfully
local Tab = Window:CreateTab({ Title = "Main", Icon = "⚙️" })
local Section = Tab:CreateSection("Welcome")

Section:CreateLabel({ Text = "✓ Access granted!" })

Window:Show()
```

**What happens when testing:**

1. **Enter 3 wrong keys** → Lockout triggers
2. **Key system destroys UI** → Clean exit
3. **Player is kicked** → `game.Players.LocalPlayer:Kick()`
4. **Script doesn't crash** → Dummy window returned to prevent nil errors

**Console output example:**
```
[KeySystem] Validation failed: Invalid key (2 attempts remaining)
[KeySystem] Validation failed: Invalid key (1 attempt remaining)
[KeySystem] Validation failed: Invalid key (0 attempts remaining)
⚠️ Out of attempts! User will be kicked.
[RvrseUI] Key validation failed - Window creation blocked
[KeySystem] Player kicked due to failed validation
```

**Graceful Failure Design:**
- Window creation returns a **dummy object** (not `nil`) when validation fails
- Dummy object has all methods (CreateTab, CreateSection, etc.) that do nothing
- Prevents `attempt to index nil` errors in user scripts
- Allows scripts to complete without crashing, even after lockout

#### Example: Production Hub with Key System

```lua
local Hub = RvrseUI:CreateWindow({
    Name = "My Premium Hub",
    Icon = "🎮",
    Theme = "Dark",

    -- Configuration
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MyHub",
        FileName = "Config.json"
    },

    -- Key System (blocks until validated)
    KeySystem = true,
    KeySettings = {
        Title = "My Hub - Premium Access",
        Subtitle = "Enter your license key",
        Note = "Purchase a key at myhub.gg/shop",
        NoteButton = {
            Text = "🛒 Buy Key",
            Callback = function()
                setclipboard("https://myhub.gg/shop")
            end
        },

        -- Validation
        Keys = {"PREMIUM-2024", "VIP-ACCESS"},

        -- OR whitelist your testers
        -- Whitelist = {"123456", "789012"},

        -- Security
        SaveKey = true,
        FileName = "License",
        MaxAttempts = 3,
        KickOnFailure = true,

        -- Logging
        WebhookURL = "https://discord.com/api/webhooks/YOUR_WEBHOOK",

        -- Callbacks
        OnKeyValid = function(key)
            RvrseUI:Notify({
                Title = "Welcome!",
                Message = "License validated: " .. key,
                Type = "success",
                Duration = 5
            })
        end
    }
})

-- Rest of your hub (only runs if key validated)
local Tab = Hub:CreateTab({ Title = "Main", Icon = "⚙️" })
-- ... your features here

Hub:Show()
```

**See [examples/key-system-example.lua](examples/key-system-example.lua) for more examples!**

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

**Priorities:**
- `critical` - Shows immediately, stays longest
- `high` - Shows above normal
- `normal` - Default
- `low` - Shows below others

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
-- Window.Flags doesn't exist and will cause errors!
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

**Problem:** Using wrong parameter names
**Solution:** Use `MultipleOptions` or `MultiSelect`:

```lua
-- ✅ Rayfield syntax
CreateDropdown({
    Options = {...},
    MultipleOptions = true  -- Rayfield API
})

-- ✅ RvrseUI syntax
CreateDropdown({
    Values = {...},
    MultiSelect = true      -- RvrseUI API
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

### "UI not visible after calling Show()"

**Problem:** ScreenGui parent issue
**Solution:** Check Container setting:

```lua
RvrseUI:CreateWindow({
    Name = "Test",
    Container = "PlayerGui",  -- Try "CoreGui" if PlayerGui fails
    DisplayOrder = 999999    -- Higher z-index
})
```

---

## 🔄 Dynamic Updates & Element API Methods

**All elements can be updated programmatically after creation!** Every element returns an API object with methods to modify its state, appearance, and behavior at runtime.

### Common Methods (All Elements)

Every element supports these methods:

```lua
-- Show/hide elements dynamically
element:SetVisible(true)   -- Show the element
element:SetVisible(false)  -- Hide the element

-- Get/set current value (most elements)
local value = element:Get()  -- Get current value
element:Set(newValue)        -- Set new value
```

---

### 📋 Complete Element API Reference

#### 1. Button

```lua
local button = Section:CreateButton({
    Text = "Click Me",
    OnClick = function() print("Clicked!") end
})

-- Methods:
button:Set("New Text")              -- Update button text
button:SetText("Legacy method")     -- Alternative text update
button:Trigger()                    -- Programmatically trigger click
button:SetVisible(true/false)       -- Show/hide button

-- Properties:
print(button.CurrentValue)          -- Current button text
```

#### 2. Toggle

```lua
local toggle = Section:CreateToggle({
    Text = "Feature Toggle",
    State = false,
    Flag = "MyToggle"
})

-- Methods:
toggle:Set(true)                    -- Enable toggle
toggle:Set(false)                   -- Disable toggle
local state = toggle:Get()          -- Get current state (boolean)
toggle:Refresh()                    -- Refresh visual state
toggle:SetVisible(true/false)       -- Show/hide toggle

-- Properties:
print(toggle.CurrentValue)          -- Current state (boolean)
```

#### 3. Slider

```lua
local slider = Section:CreateSlider({
    Text = "Volume",
    Min = 0,
    Max = 100,
    Default = 50,
    Suffix = "%",
    Flag = "Volume"
})

-- Methods:
slider:Set(75)                      -- Set slider to 75
local value = slider:Get()          -- Get current value (number)
slider:SetRange(0, 200, 5)          -- Update min/max/step at runtime
slider:SetSuffix(" dB")             -- Change suffix display
slider:SetVisible(true/false)       -- Show/hide slider

-- Properties:
print(slider.CurrentValue)          -- Current value (number)

-- Example: Dynamic range based on game mode
if hardMode then
    slider:SetRange(0, 50, 1)  -- Limit max to 50 in hard mode
else
    slider:SetRange(0, 200, 5) -- Allow up to 200 in normal mode
end
```

#### 4. Dropdown

```lua
local dropdown = Section:CreateDropdown({
    Text = "Select Weapon",
    Values = {"Sword", "Bow", "Staff"},
    Default = "Sword",
    Flag = "Weapon"
})

-- Methods:
dropdown:Set("Bow")                 -- Single-select: set value
dropdown:Set({"Sword", "Staff"})    -- Multi-select: set values
local selection = dropdown:Get()    -- Get current selection
dropdown:Refresh({"New1", "New2"})  -- Update options list
dropdown:SetOpen(true)              -- Open dropdown menu
dropdown:SetOpen(false)             -- Close dropdown menu
dropdown:SelectAll()                -- Select all (multi-select only)
dropdown:ClearAll()                 -- Clear all (multi-select only)
local isMulti = dropdown:IsMultiSelect() -- Check if multi-select mode
dropdown:SetVisible(true/false)     -- Show/hide dropdown

-- Properties:
print(dropdown.CurrentOption)       -- Current selection as table

-- Example: Refresh dropdown with discovered items
local foundWeapons = {"Sword", "Bow", "Staff", "Legendary Axe"}
dropdown:Refresh(foundWeapons)
dropdown:Set("Legendary Axe")
```

#### 5. ColorPicker

```lua
local colorPicker = Section:CreateColorPicker({
    Text = "Theme Color",
    Default = Color3.fromRGB(88, 101, 242),
    Advanced = true,
    Flag = "ThemeColor"
})

-- Methods:
colorPicker:Set(Color3.fromRGB(255, 0, 0))  -- Set to red
local color = colorPicker:Get()              -- Get current Color3
colorPicker:SetVisible(true/false)           -- Show/hide color picker

-- Properties:
print(colorPicker.CurrentValue)              -- Current Color3

-- Example: Apply color to UI elements
colorPicker:Set(Color3.fromRGB(0, 255, 0))
local currentColor = colorPicker:Get()
frame.BackgroundColor3 = currentColor
```

#### 6. Keybind

```lua
local keybind = Section:CreateKeybind({
    Text = "Toggle UI",
    Default = Enum.KeyCode.K,
    Flag = "ToggleKey"
})

-- Methods:
keybind:Set(Enum.KeyCode.H)         -- Change keybind to H
local key = keybind:Get()           -- Get current KeyCode
keybind:SetVisible(true/false)      -- Show/hide keybind

-- Properties:
print(keybind.CurrentKeybind)       -- Current KeyCode

-- Example: Update keybind based on user preference
if VIPPlayer then
    keybind:Set(Enum.KeyCode.F1)  -- VIP gets F1
else
    keybind:Set(Enum.KeyCode.K)   -- Regular users get K
end
```

#### 7. TextBox

```lua
local textbox = Section:CreateTextBox({
    Text = "Enter Name",
    Default = "Player",
    PlaceholderText = "Type here...",
    Flag = "PlayerName"
})

-- Methods:
textbox:Set("NewName")              -- Set textbox content
local text = textbox:Get()          -- Get current text
textbox:SetVisible(true/false)      -- Show/hide textbox

-- Properties:
print(textbox.CurrentValue)         -- Current text value

-- Example: Update textbox with player's actual name
textbox:Set(game.Players.LocalPlayer.Name)
```

#### 8. Label

```lua
local label = Section:CreateLabel({
    Text = "Status: Idle"
})

-- Methods:
label:Set("Status: Active")         -- Update label text
local text = label:Get()            -- Get current text
label:SetVisible(true/false)        -- Show/hide label

-- Properties:
print(label.CurrentValue)           -- Current label text

-- Example: Live status updates
while true do
    label:Set("Coins: " .. tostring(playerCoins))
    wait(1)
end
```

#### 9. Paragraph

```lua
local paragraph = Section:CreateParagraph({
    Text = "Welcome to the hub!\nEnjoy your stay."
})

-- Methods:
paragraph:Set("New multi-line text\nLine 2\nLine 3")  -- Update text (auto-resizes)
local text = paragraph:Get()                          -- Get current text
paragraph:SetVisible(true/false)                      -- Show/hide paragraph

-- Properties:
print(paragraph.CurrentValue)                         -- Current paragraph text

-- Example: Dynamic changelog display
local changelog = "Version 2.0\n• Added auto-farm\n• Fixed bugs"
paragraph:Set(changelog)
```

#### 10. Divider

```lua
local divider = Section:CreateDivider()

-- Methods:
divider:SetColor(Color3.fromRGB(255, 0, 0))  -- Set divider color
divider:SetVisible(true/false)               -- Show/hide divider

-- Example: Themed dividers
divider:SetColor(Color3.fromRGB(88, 101, 242))  -- Match theme
```

---

### 🎯 Real-World Update Examples

#### Example 1: Live Player Stats Display

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

#### Example 2: Dynamic Dropdown Based on Game State

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
game.Players.LocalPlayer.Inventory.ChildRemoved:Connect(updateWeaponList)
```

#### Example 3: Conditional Slider Range

```lua
local speedSlider = Section:CreateSlider({
    Text = "Walk Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Flag = "WalkSpeed"
})

-- Admin mode toggle
local adminToggle = Section:CreateToggle({
    Text = "Admin Mode",
    State = false,
    OnChanged = function(enabled)
        if enabled then
            speedSlider:SetRange(16, 500, 5)  -- Allow super speed
            speedSlider:SetSuffix(" (ADMIN)")
        else
            speedSlider:SetRange(16, 100, 1)  -- Normal limits
            speedSlider:SetSuffix("")
        end
    end
})
```

#### Example 4: Button State Updates

```lua
local farmButton = Section:CreateButton({
    Text = "Start Auto Farm",
    OnClick = function()
        if farming then
            stopFarming()
            farmButton:Set("Start Auto Farm")
        else
            startFarming()
            farmButton:Set("⏸ Stop Auto Farm")
        end
        farming = not farming
    end
})
```

#### Example 5: Using RvrseUI.Flags for Cross-Element Updates

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

## 📝 Additional Resources

- **[Phase 2 Documentation](docs/PHASE2_COMPLETION.md)** - Complete Phase 2 feature guide
- **[Quick Reference](docs/PHASE2_QUICK_REFERENCE.md)** - Developer quick reference
- **[Repository Structure](DIRECTORY.md)** - How the project is organized
- **[Changelog](CHANGELOG.md)** - Version history
- **[Examples Directory](examples/)** - More example scripts

---

## 🤝 Rayfield Migration Guide

**Switching from Rayfield? Good news: You don't need to change your code!**

RvrseUI is 100% compatible with Rayfield's dropdown API:

```lua
-- This Rayfield code works as-is in RvrseUI:
local Dropdown = Tab:CreateDropdown({
   Name = "Dropdown Example",           -- RvrseUI uses "Text" but accepts "Name"
   Options = {"Option 1","Option 2"},   -- ✅ Supported
   CurrentOption = {"Option 1"},        -- ✅ Supported
   MultipleOptions = false,             -- ✅ Supported
   Flag = "Dropdown1",
   Callback = function(Options)         -- ✅ Supported
      print(Options[1])
   end,
})

-- All Rayfield methods work:
Dropdown:Refresh({"New1", "New2"})      -- ✅ Works
Dropdown:Set({"Option 2"})              -- ✅ Works
print(Dropdown.CurrentOption[1])        -- ✅ Works
```

**Just change the library load line and you're done!**

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

**Version 4.0.0** • **Build 228KB** • **26 Modules** • **Production Ready**
