# RvrseUI Configuration System Guide

**Version**: 2.3.0 "Persistence"
**Release**: September 30, 2025

---

## 📋 Table of Contents
1. [Quick Start](#quick-start)
2. [Setup Guide](#setup-guide)
3. [API Reference](#api-reference)
4. [Examples](#examples)
5. [Best Practices](#best-practices)
6. [Troubleshooting](#troubleshooting)

---

## Quick Start

```lua
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

-- Step 1: Enable configuration saving
local Window = RvrseUI:CreateWindow({
  Name = "My Script",
  ConfigurationSaving = true,           -- ✅ Enable config system
  FileName = "MyScript_Config.json"     -- Optional: custom file name
})

-- Step 2: Create elements with Flag parameter
local Tab = Window:CreateTab({ Title = "Settings" })
local Section = Tab:CreateSection("Player")

Section:CreateSlider({
  Text = "Walk Speed",
  Min = 16,
  Max = 100,
  Default = 16,
  Flag = "WalkSpeed",  -- 🔑 Unique identifier for saving
  OnChanged = function(speed)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = speed
  end
})

Section:CreateToggle({
  Text = "Auto Farm",
  State = false,
  Flag = "AutoFarm",  -- 🔑 Unique identifier for saving
  OnChanged = function(enabled)
    _G.AutoFarm = enabled
  end
})

-- Step 3: Load configuration at the END of your script
RvrseUI:LoadConfiguration()  -- Restores all saved settings
```

**That's it!** Settings now automatically save and restore.

---

## Setup Guide

### Step 1: Enable Configuration Saving

Add these parameters to `CreateWindow()`:

```lua
local Window = RvrseUI:CreateWindow({
  Name = "Game Script",

  -- Configuration parameters
  ConfigurationSaving = true,                    -- Enable config system
  FileName = "GameScript_Config.json",           -- Custom file name (optional)

  -- Other parameters
  Icon = "game",
  Theme = "Dark",
  ToggleUIKeybind = "K"
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `ConfigurationSaving` | boolean | `false` | Enable/disable config system |
| `FileName` | string | `"RvrseUI_Config.json"` | Config file name |

**File Location**: Saved in workspace folder (where `writefile()` saves)

---

### Step 2: Add Flag to Elements

Add a unique `Flag` parameter to each element you want to save:

```lua
-- Slider with Flag
Section:CreateSlider({
  Text = "Walk Speed",
  Min = 16,
  Max = 100,
  Default = 16,
  Flag = "WalkSpeed",  -- 🔑 IMPORTANT: Unique identifier
  OnChanged = function(speed)
    -- Your code here
  end
})

-- Toggle with Flag
Section:CreateToggle({
  Text = "Fly Mode",
  State = false,
  Flag = "FlyMode",  -- 🔑 IMPORTANT: Unique identifier
  OnChanged = function(enabled)
    -- Your code here
  end
})

-- Dropdown with Flag
Section:CreateDropdown({
  Text = "Farm Mode",
  Values = { "Fast", "Balanced", "Slow" },
  Default = "Balanced",
  Flag = "FarmMode",  -- 🔑 IMPORTANT: Unique identifier
  OnChanged = function(mode)
    -- Your code here
  end
})
```

**Supported Elements**:
- ✅ Toggle, Slider, Dropdown, Keybind
- ✅ TextBox, ColorPicker
- ✅ Label, Paragraph (read-only)

---

### Step 3: Load Configuration

Place this at the **END** of your script:

```lua
-- Load saved configuration
RvrseUI:LoadConfiguration()
```

This automatically restores all saved settings.

---

## API Reference

### Methods

#### RvrseUI:SaveConfiguration()
Manually save current configuration.

```lua
local success, message = RvrseUI:SaveConfiguration()

if success then
  print("Config saved successfully")
else
  print("Save failed:", message)
end
```

**Returns**:
- `success` (boolean): True if save succeeded
- `message` (string): Success/error message

**When Called**:
- Automatically after 1 second of inactivity (auto-save)
- Manually via this method

---

#### RvrseUI:LoadConfiguration()
Load saved configuration and apply to elements.

```lua
local success, message = RvrseUI:LoadConfiguration()

if success then
  print("Loaded:", message)  -- "Loaded 5 elements"
else
  print("No config found:", message)
end
```

**Returns**:
- `success` (boolean): True if load succeeded
- `message` (string): Count of loaded elements or error

**Best Practice**: Call at the END of your script

---

#### RvrseUI:DeleteConfiguration()
Delete saved configuration file.

```lua
local success, message = RvrseUI:DeleteConfiguration()

if success then
  print("Config deleted")
else
  print("Delete failed:", message)
end
```

**Returns**:
- `success` (boolean): True if delete succeeded
- `message` (string): Success/error message

---

#### RvrseUI:ConfigurationExists()
Check if configuration file exists.

```lua
local exists = RvrseUI:ConfigurationExists()

if exists then
  print("Config file found")
else
  print("No config file")
end
```

**Returns**:
- `exists` (boolean): True if file exists

---

## Examples

### Example 1: Basic Configuration

```lua
local RvrseUI = loadstring(game:HttpGet("..."))()

-- Enable config
local Window = RvrseUI:CreateWindow({
  ConfigurationSaving = true,
  FileName = "BasicConfig.json"
})

local Tab = Window:CreateTab({ Title = "Settings" })
local Section = Tab:CreateSection("Options")

-- Create elements with Flag
Section:CreateSlider({
  Text = "Speed",
  Flag = "Speed",
  OnChanged = function(v)
    _G.Speed = v
  end
})

Section:CreateToggle({
  Text = "Enabled",
  Flag = "Enabled",
  OnChanged = function(v)
    _G.Enabled = v
  end
})

-- Load at end
RvrseUI:LoadConfiguration()
```

---

### Example 2: Game Script with Auto-Save

```lua
local RvrseUI = loadstring(game:HttpGet("..."))()

local Window = RvrseUI:CreateWindow({
  Name = "Game Script",
  ConfigurationSaving = true,
  FileName = "GameScript.json"
})

-- Player Tab
local PlayerTab = Window:CreateTab({ Title = "Player" })
local PlayerSection = PlayerTab:CreateSection("Enhancements")

PlayerSection:CreateSlider({
  Text = "Walk Speed",
  Min = 16,
  Max = 100,
  Default = 16,
  Flag = "WalkSpeed",
  OnChanged = function(speed)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
      char.Humanoid.WalkSpeed = speed
    end
  end
})

PlayerSection:CreateSlider({
  Text = "Jump Power",
  Min = 50,
  Max = 200,
  Default = 50,
  Flag = "JumpPower",
  OnChanged = function(power)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
      char.Humanoid.JumpPower = power
    end
  end
})

PlayerSection:CreateToggle({
  Text = "Fly Mode",
  State = false,
  Flag = "FlyMode",
  OnChanged = function(enabled)
    if enabled then
      -- Enable fly
    else
      -- Disable fly
    end
  end
})

-- Combat Tab
local CombatTab = Window:CreateTab({ Title = "Combat" })
local CombatSection = CombatTab:CreateSection("Settings")

CombatSection:CreateToggle({
  Text = "Auto Attack",
  Flag = "AutoAttack",
  OnChanged = function(v) _G.AutoAttack = v end
})

CombatSection:CreateDropdown({
  Text = "Target Mode",
  Values = { "Closest", "Lowest HP", "Highest HP" },
  Flag = "TargetMode",
  OnChanged = function(v) _G.TargetMode = v end
})

CombatSection:CreateKeybind({
  Text = "Combat Toggle",
  Default = Enum.KeyCode.C,
  Flag = "CombatKey",
  OnChanged = function(key)
    print("Combat key set to:", key.Name)
  end
})

-- Load saved config
RvrseUI:LoadConfiguration()
```

---

### Example 3: Manual Save/Load UI

```lua
local ConfigSection = Tab:CreateSection("Configuration")

-- Manual save button
ConfigSection:CreateButton({
  Text = "💾 Save Configuration",
  Callback = function()
    local success, msg = RvrseUI:SaveConfiguration()
    RvrseUI:Notify({
      Title = success and "Saved" or "Error",
      Message = msg or "Configuration saved",
      Type = success and "success" or "error",
      Duration = 3
    })
  end
})

-- Manual load button
ConfigSection:CreateButton({
  Text = "📂 Load Configuration",
  Callback = function()
    local success, msg = RvrseUI:LoadConfiguration()
    RvrseUI:Notify({
      Title = success and "Loaded" or "Error",
      Message = msg or "No config found",
      Type = success and "success" or "warn",
      Duration = 3
    })
  end
})

-- Delete config button
ConfigSection:CreateButton({
  Text = "🗑 Delete Configuration",
  Callback = function()
    local success, msg = RvrseUI:DeleteConfiguration()
    RvrseUI:Notify({
      Title = "Deleted",
      Message = "Configuration removed",
      Type = "info",
      Duration = 2
    })
  end
})

-- Check status button
ConfigSection:CreateButton({
  Text = "📊 Config Status",
  Callback = function()
    local exists = RvrseUI:ConfigurationExists()
    local count = 0
    for _ in pairs(RvrseUI.Flags) do count = count + 1 end

    print("Config file exists:", exists)
    print("Flagged elements:", count)
  end
})
```

---

## Best Practices

### 1. Unique Flag Names
Always use unique Flag names to avoid conflicts:

```lua
-- ✅ GOOD: Unique, descriptive names
Flag = "PlayerWalkSpeed"
Flag = "CombatAutoAttack"
Flag = "UIThemeDark"

-- ❌ BAD: Generic names that might conflict
Flag = "Speed"
Flag = "Toggle1"
Flag = "Value"
```

### 2. Descriptive Flag Names
Use descriptive names for better readability:

```lua
-- ✅ GOOD: Clear and descriptive
Flag = "FarmingSpeed"
Flag = "AutoCollectEnabled"
Flag = "NotificationVolume"

-- ❌ BAD: Unclear abbreviations
Flag = "FS"
Flag = "ACE"
Flag = "NV"
```

### 3. Flag Naming Convention
Use consistent naming convention:

```lua
-- Option 1: PascalCase
Flag = "WalkSpeed"
Flag = "AutoFarm"

-- Option 2: snake_case
Flag = "walk_speed"
Flag = "auto_farm"

-- Option 3: Prefixed
Flag = "player_walk_speed"
Flag = "combat_auto_attack"
```

### 4. Custom File Names
Use descriptive file names for multi-script projects:

```lua
-- Different scripts, different configs
CreateWindow({ FileName = "BloxFruits_Config.json" })
CreateWindow({ FileName = "PetSimulator_Config.json" })
CreateWindow({ FileName = "TowerDefense_Config.json" })
```

### 5. Load at the End
Always load configuration **AFTER** creating all elements:

```lua
-- ✅ GOOD: Load after everything is created
local Window = RvrseUI:CreateWindow({ ConfigurationSaving = true })
-- ... create all elements ...
RvrseUI:LoadConfiguration()  -- Load at end

-- ❌ BAD: Loading too early
local Window = RvrseUI:CreateWindow({ ConfigurationSaving = true })
RvrseUI:LoadConfiguration()  -- Elements don't exist yet!
-- ... create elements ...
```

---

## Troubleshooting

### Configuration Not Saving

**Problem**: Changes aren't being saved.

**Solution**:
1. Check if `ConfigurationSaving` is enabled in `CreateWindow()`
2. Verify elements have `Flag` parameter
3. Wait 1 second after changes (auto-save debounce)
4. Check executor supports `writefile()`

```lua
-- Debug: Check if saving is enabled
print("Config saving:", RvrseUI.ConfigurationSaving)  -- Should be true
print("Config file:", RvrseUI.ConfigurationFileName)  -- Should be your filename
```

---

### Configuration Not Loading

**Problem**: Settings aren't restored on startup.

**Solution**:
1. Ensure `RvrseUI:LoadConfiguration()` is at the END
2. Check if config file exists: `RvrseUI:ConfigurationExists()`
3. Verify Flag names match exactly
4. Check executor supports `readfile()` and `isfile()`

```lua
-- Debug: Check what's being loaded
if RvrseUI:ConfigurationExists() then
  print("Config file found")
  local success, msg = RvrseUI:LoadConfiguration()
  print("Load result:", success, msg)
else
  print("No config file found")
end
```

---

### Executor Compatibility

**Problem**: Configuration doesn't work on some executors.

**Required Functions**:
- `writefile()` - Save config
- `readfile()` - Load config
- `isfile()` - Check if exists
- `delfile()` - Delete config

**Test Compatibility**:
```lua
print("writefile:", type(writefile))  -- Should be "function"
print("readfile:", type(readfile))    -- Should be "function"
print("isfile:", type(isfile))        -- Should be "function"
print("delfile:", type(delfile))      -- Should be "function"
```

If any show "nil", your executor doesn't support that function.

---

### Flag Conflicts

**Problem**: Multiple elements share the same Flag name.

**Solution**: Use unique Flag names for each element.

```lua
-- ❌ BAD: Conflict
Section:CreateSlider({ Flag = "Speed", ... })  -- Player speed
Section:CreateSlider({ Flag = "Speed", ... })  -- Enemy speed (CONFLICT!)

-- ✅ GOOD: Unique names
Section:CreateSlider({ Flag = "PlayerSpeed", ... })
Section:CreateSlider({ Flag = "EnemySpeed", ... })
```

---

### Auto-Save Delay

**Problem**: Changes take 1 second to save.

**Explanation**: This is intentional debouncing to prevent excessive file writes.

**Manual Save**: If you need immediate save:
```lua
RvrseUI:SaveConfiguration()  -- Save immediately
```

---

## Configuration File Format

The configuration is saved as JSON for human readability:

```json
{
  "WalkSpeed": 50,
  "JumpPower": 100,
  "FlyMode": true,
  "AutoAttack": false,
  "TargetMode": "Closest",
  "CombatKey": {
    "Name": "C",
    "Value": 99
  },
  "PlayerName": "CoderRvrse",
  "AccentColor": {
    "R": 0.38823529411764707,
    "G": 0.4,
    "B": 0.9450980392156862
  }
}
```

**Location**: Workspace folder (where `writefile()` saves)

**Editing**: You can manually edit the JSON file if needed.

---

## Advanced Usage

### Conditional Configuration

```lua
-- Only save in certain conditions
local saveButton = Section:CreateButton({
  Text = "Save Config",
  Callback = function()
    if game.PlaceId == 123456 then  -- Only in specific game
      RvrseUI:SaveConfiguration()
    end
  end
})
```

---

### Multiple Configurations

```lua
-- Save/load different configs
local function savePreset(name)
  RvrseUI.ConfigurationFileName = name .. "_Config.json"
  RvrseUI:SaveConfiguration()
end

local function loadPreset(name)
  RvrseUI.ConfigurationFileName = name .. "_Config.json"
  RvrseUI:LoadConfiguration()
end

-- Usage
Section:CreateButton({
  Text = "Save Preset 1",
  Callback = function() savePreset("Preset1") end
})

Section:CreateButton({
  Text = "Load Preset 1",
  Callback = function() loadPreset("Preset1") end
})
```

---

### Configuration Export

```lua
-- Get configuration as table
local config = RvrseUI._configCache

-- Print all saved values
for flag, value in pairs(config) do
  print(flag, "=", value)
end
```

---

## Demo Script

Run the complete configuration demo:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/CONFIG_DEMO.lua"))()
```

**Features**:
- 11 flagged elements across 5 tabs
- Manual save/load/delete buttons
- Configuration status checker
- Complete testing suite
- Step-by-step guide

---

## Summary

### 3-Step Setup
1. `CreateWindow({ ConfigurationSaving = true })`
2. Add `Flag = "Name"` to elements
3. Call `RvrseUI:LoadConfiguration()` at end

### Auto-Save Triggers
- Toggle click → auto-save
- Slider drag → auto-save
- Dropdown select → auto-save
- Keybind change → auto-save
- TextBox focus lost → auto-save
- ColorPicker click → auto-save

### Methods
- `SaveConfiguration()` - Save config
- `LoadConfiguration()` - Load config
- `DeleteConfiguration()` - Delete config
- `ConfigurationExists()` - Check existence

### Benefits
- ✅ Automatic persistence
- ✅ User-friendly experience
- ✅ Professional scripts
- ✅ Easy setup
- ✅ JSON storage

---

**Version**: 2.3.0 "Persistence"
**Hash**: 7F5E2B9C
**GitHub**: https://github.com/CoderRvrse/RvrseUI
