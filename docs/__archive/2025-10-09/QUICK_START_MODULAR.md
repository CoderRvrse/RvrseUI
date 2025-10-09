# Quick Start Guide - Modular RvrseUI

## For Developers

### Using the Modular Version

#### **Option 1: Roblox Studio (ModuleScript)**

1. **Setup Structure**:
   ```
   ReplicatedStorage/
   └── RvrseUI/              (ModuleScript)
       ├── init              (Script - paste init.lua content)
       └── src/              (Folder)
           ├── Version       (ModuleScript)
           ├── Debug         (ModuleScript)
           ├── Theme         (ModuleScript)
           ├── ... (all other modules)
           └── Elements/     (Folder)
               ├── Button    (ModuleScript)
               ├── Toggle    (ModuleScript)
               └── ... (all elements)
   ```

2. **Usage**:
   ```lua
   local RvrseUI = require(game.ReplicatedStorage.RvrseUI)

   local Window = RvrseUI:CreateWindow({Name = "My Script"})
   local Tab = Window:CreateTab({Title = "Main"})
   local Section = Tab:CreateSection("Controls")

   Section:CreateButton({
       Text = "Click Me",
       Callback = function()
           print("Hello, modular world!")
       end
   })
   ```

#### **Option 2: Loadstring (Single File)**

1. **Bundle all modules** into single file:
   ```bash
   # (You need a bundler script for this)
   ./bundle.sh  # Creates dist/RvrseUI.lua
   ```

2. **Host on GitHub** and load:
   ```lua
   local RvrseUI = loadstring(game:HttpGet(
       "https://raw.githubusercontent.com/YourName/RvrseUI/main/dist/RvrseUI.lua"
   ))()

   local Window = RvrseUI:CreateWindow({Name = "Remote Script"})
   ```

---

## Module Reference

### **Core Systems**
- **Version** - Version info and constants
- **Debug** - Debug logging (enable with `RvrseUI:EnableDebug(true)`)
- **Obfuscation** - Stealth name generation
- **Theme** - Dark/Light theme management
- **Animator** - Animation presets (Smooth, Snappy, Bounce, Fast)
- **State** - Lock group state (master/child toggles)
- **Config** - Configuration persistence
- **UIHelpers** - Utility functions (corner, stroke, padding, shadow, etc.)
- **Icons** - Icon resolution (Lucide, Roblox assets, emoji)

### **Components**
- **Notifications** - Toast notification system
- **Hotkeys** - Keyboard input (toggle, escape keys)
- **WindowManager** - Window lifecycle management

### **Builders**
- **WindowBuilder** - Creates main window (header, tabs, body, splash, controller chip)
- **TabBuilder** - Creates tabs with icons
- **SectionBuilder** - Creates sections and delegates to elements

### **Elements**
- **Button** - Clickable buttons with ripple effect
- **Toggle** - iOS-style switches (master/child locks)
- **Dropdown** - Production dropdown with scrolling list
- **Slider** - Premium slider with grow-on-grab
- **Keybind** - Interactive key capture
- **TextBox** - Text input fields
- **ColorPicker** - Color cycling picker
- **Label** - Simple text labels
- **Paragraph** - Multi-line text with auto-wrapping
- **Divider** - Visual separator lines

---

## API Quick Reference

### **Creating UI**
```lua
local RvrseUI = require(script.RvrseUI)

-- Window
local Window = RvrseUI:CreateWindow({
    Name = "Script Name",
    Icon = "🎮",  -- emoji, Lucide name, or rbxassetid
    Theme = "Dark",  -- "Dark" or "Light"
    ConfigurationSaving = true,  -- Enable config persistence
    ToggleUIKeybind = "K",  -- Key to toggle UI
    EscapeKey = "Backspace"  -- Key to destroy UI
})

-- Tab
local Tab = Window:CreateTab({
    Title = "Main",
    Icon = "home"  -- emoji, Lucide, or asset
})

-- Section
local Section = Tab:CreateSection("Section Title")

-- Elements
local MyButton = Section:CreateButton({
    Text = "Click",
    Callback = function() print("Clicked!") end,
    Flag = "MyButton"  -- Global access via RvrseUI.Flags["MyButton"]
})

local MyToggle = Section:CreateToggle({
    Text = "Enable",
    State = false,
    OnChanged = function(state) print(state) end,
    Flag = "MyToggle",
    LockGroup = "Master"  -- Controls children
})

local ChildToggle = Section:CreateToggle({
    Text = "Option",
    RespectLock = "Master"  -- Disabled when Master is ON
})

local MyDropdown = Section:CreateDropdown({
    Text = "Mode",
    Values = {"Easy", "Medium", "Hard"},
    Default = "Medium",
    OnChanged = function(value) print(value) end
})

local MySlider = Section:CreateSlider({
    Text = "Speed",
    Min = 0,
    Max = 100,
    Step = 5,
    Default = 50,
    OnChanged = function(value) print(value) end
})
```

### **Notifications**
```lua
RvrseUI:Notify({
    Title = "Success",
    Message = "Operation complete",
    Duration = 3,  -- seconds
    Type = "success"  -- success, error, warn, info
})
```

### **Configuration**
```lua
-- Save current state
RvrseUI:SaveConfiguration()

-- Load saved state
RvrseUI:LoadConfiguration()

-- Named profiles
RvrseUI:SetConfigProfile("MyProfile")

-- List all profiles
local profiles = RvrseUI:ListProfiles()

-- Delete profile
RvrseUI:DeleteProfile("OldProfile")
```

### **Global Element Access (Flags)**
```lua
-- Create with Flag
local Toggle = Section:CreateToggle({
    Text = "Feature",
    Flag = "FeatureToggle"
})

-- Access anywhere
RvrseUI.Flags["FeatureToggle"]:Set(true)
print(RvrseUI.Flags["FeatureToggle"]:Get())  -- true
print(RvrseUI.Flags["FeatureToggle"].CurrentValue)  -- true
```

### **Lock Groups**
```lua
-- Master toggle (controls the lock)
Section:CreateToggle({
    Text = "Auto Mode",
    LockGroup = "AutoMode"  -- When ON, locks children
})

-- Child elements (respect the lock)
Section:CreateSlider({
    Text = "Speed",
    RespectLock = "AutoMode"  -- Disabled when AutoMode is ON
})

Section:CreateDropdown({
    Text = "Target",
    RespectLock = "AutoMode"  -- Also disabled
})
```

### **Window Methods**
```lua
Window:SetTitle("New Title")
Window:SetIcon("🔥")
Window:Show()  -- Display UI (loads config first)
Window:Hide()  -- Hide UI
Window:Destroy()  -- Destroy completely
```

### **Element Methods**
```lua
-- All elements have:
element:Set(value)  -- Set value (triggers OnChanged)
element:Get()  -- Get current value
element:SetVisible(bool)  -- Show/hide element

-- Element-specific:
Toggle:Refresh()  -- Update visual
Dropdown:Refresh(newValues)  -- Update options list
```

### **Theme Management**
```lua
RvrseUI:SetTheme("Light")  -- Switch theme
local current = RvrseUI:GetTheme()  -- Get current theme name
```

### **Version Info**
```lua
local info = RvrseUI:GetVersionInfo()
print(info.Full)  -- "2.13.0"
print(info.Build)  -- "20251008"
print(info.Hash)  -- "ABC123"
```

---

## Common Patterns

### **Full Example**
```lua
local RvrseUI = require(script.RvrseUI)

local Window = RvrseUI:CreateWindow({
    Name = "Game Script",
    Theme = "Dark",
    ConfigurationSaving = true
})

local MainTab = Window:CreateTab({Title = "Main", Icon = "⚡"})
local SettingsTab = Window:CreateTab({Title = "Settings", Icon = "⚙"})

-- Player Section
local PlayerSection = MainTab:CreateSection("Player")

PlayerSection:CreateSlider({
    Text = "Walk Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    OnChanged = function(speed)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = speed
    end,
    Flag = "WalkSpeed"
})

PlayerSection:CreateToggle({
    Text = "Infinite Jump",
    State = false,
    OnChanged = function(enabled)
        -- Infinite jump logic here
    end,
    Flag = "InfJump"
})

-- Combat Section with Lock System
local CombatSection = MainTab:CreateSection("Combat")

CombatSection:CreateToggle({
    Text = "Auto Attack (Master)",
    LockGroup = "AutoAttack"
})

CombatSection:CreateToggle({
    Text = "Target: Players",
    RespectLock = "AutoAttack"
})

CombatSection:CreateToggle({
    Text = "Target: NPCs",
    RespectLock = "AutoAttack"
})

-- Settings Section
local ThemeSection = SettingsTab:CreateSection("Appearance")

ThemeSection:CreateDropdown({
    Text = "Theme",
    Values = {"Dark", "Light"},
    Default = "Dark",
    OnChanged = function(theme)
        RvrseUI:SetTheme(theme)
    end
})

-- Show UI (loads config and displays)
Window:Show()

-- Notifications
RvrseUI:Notify({
    Title = "Script Loaded",
    Message = "Press K to toggle UI",
    Duration = 4,
    Type = "success"
})
```

---

## Debugging

### **Enable Debug Mode**
```lua
RvrseUI:EnableDebug(true)

-- Now all dprintf() calls will print
-- Shows config loading, theme switching, etc.
```

### **Check Module Loading**
```lua
-- All modules print on successful load:
-- [RvrseUI] ✅ Modular architecture loaded successfully
-- [RvrseUI] 📦 Version: 2.13.0
```

---

## Migration from Monolithic

**No changes needed!** The modular version is 100% API compatible.

```lua
-- Old code (still works)
local RvrseUI = require(script.RvrseUI)  -- Now loads init.lua
local Window = RvrseUI:CreateWindow({Name = "Test"})

-- Same API, same behavior, just better organized code
```

---

## File Structure Reference

```
RvrseUI/
├── init.lua                    # Entry point (load this)
│
└── src/
    ├── Version.lua            # Version constants
    ├── Debug.lua              # Debug system
    ├── Obfuscation.lua       # Stealth names
    ├── Theme.lua              # Theme management
    ├── Animator.lua           # Animations
    ├── State.lua              # Lock state
    ├── Config.lua             # Configuration
    ├── UIHelpers.lua          # UI utilities
    ├── Icons.lua              # Icon resolution
    ├── Notifications.lua      # Toast system
    ├── Hotkeys.lua            # Keyboard input
    ├── WindowManager.lua      # Window lifecycle
    ├── WindowBuilder.lua      # Window creation
    ├── TabBuilder.lua         # Tab creation
    ├── SectionBuilder.lua     # Section creation
    │
    └── Elements/              # Element modules
        ├── Button.lua
        ├── Toggle.lua
        ├── Dropdown.lua
        ├── Slider.lua
        ├── Keybind.lua
        ├── TextBox.lua
        ├── ColorPicker.lua
        ├── Label.lua
        ├── Paragraph.lua
        └── Divider.lua
```

---

## Support

- **Documentation**: See `README.md` and `CLAUDE.md`
- **Examples**: Check `FULL_DEMO.lua` and `SIMPLE_TEST.lua`
- **Elements Guide**: Read `src/Elements/README.md`
- **Config Guide**: See `CONFIG_GUIDE.md`

---

**Happy Coding!** 🚀
