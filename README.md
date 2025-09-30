# RvrseUI v2.1

A **modern, professional, lightweight** UI framework for Roblox scripts with glassmorphism, spring animations, notification controls, and mobile-first responsive design.

**Flow**: Boot library → Create Window → Tabs → Sections → Elements (buttons, toggles, dropdowns, keybinds, sliders, notifications).

Includes a **LockGroup system** to coordinate "master" controls with dependent elements (e.g., Aura + Target All master that locks per-enemy toggles).

## ✨ Features

### 🔔 NEW in v2.1: Revolutionary Controls
- **Notification Bell Toggle**: 🔔/🔕 Professional 50x20px pill in header for instant mute/unmute
- **Mini Theme Toggle**: 🌙/🌞 Switch between Dark/Light themes with one click
- **Professional Tooltips**: Hover feedback system for all header controls
- **Glowing Animations**: Pulsing glow effects on active notification bell
- **Enhanced Glass**: True 95% transparency with white tinting and edge shine

### 🎨 Modern Design
- **True Glassmorphism**: 93-97% transparent elements with professional glass appearance
- **Spring Animations**: Smooth micro-interactions with Snappy, Bounce, and Smooth easing
- **Material Ripple Effects**: Touch-responsive ripple animations on buttons
- **Gradients & Shadows**: Elevated depth with subtle shadow layers and accent gradients
- **Modern Color Palette**: Indigo accents, refined dark/light themes with proper text hierarchy
- **Animated Glows**: Pulsing stroke effects on interactive elements

### 📱 Mobile-First Responsive
- **Auto-Scaling**: Detects mobile/tablet and adjusts window dimensions (380x520 mobile, 580x480 desktop)
- **Touch-Optimized**: 44px minimum tap targets, drag-to-move header
- **Mobile Chip**: Floating re-open button for hidden UI on mobile
- **Smooth Scrolling**: Auto-sizing canvas with slim scrollbars

### 🚀 Advanced Features
- **Notification Control**: Global bell toggle silences all notifications instantly
- **Drag-to-Reposition**: Click and drag window header to move UI anywhere
- **Dual Theme System**: Runtime theme switching with header pill or API
- **LockGroup System**: Master toggles control dependent element states
- **Animated Notifications**: Toast system with slide-in/fade-out animations (can be muted!)
- **Loading Splash**: Animated loading bar with configurable title/subtitle
- **Version Badge**: Display framework version in header
- **Interactive Tooltips**: Hover feedback on all header controls

### 🧩 Component Library
- **Button**: Material ripple effect, hover states, lock support
- **Toggle**: iOS-style switch with spring animation, controls/respects locks
- **Dropdown**: Cycle through values with hover feedback
- **Keybind**: Interactive key capture with visual feedback
- **Slider**: Draggable thumb with gradient fill, real-time value updates
- **Notifications**: 4 types (info, success, warn, error) with icon indicators

### 🎛 Developer Experience
- **Familiar API**: Rayfield-style creation pattern
- **Zero Boilerplate**: Single-file `loadstring()` loader
- **Type Hints**: Clear API with consistent naming
- **Lightweight**: ~1100 lines, optimized for performance

## 🚀 Quick Start

### Copy & Paste Demo (Full Showcase)

```lua
-- ============================================
-- RvrseUI v2.0 - Complete Feature Demo
-- Copy this entire script to test all features
-- ============================================

local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

-- Create main window with modern styling
local Window = RvrseUI:CreateWindow({
  Name = "RvrseUI Demo",
  Icon = "🎨",
  LoadingTitle = "RvrseUI v2.0",
  LoadingSubtitle = "Loading modern interface...",
  Theme = "Dark",
  ToggleUIKeybind = "K"
})

-- ==================== TAB 1: SHOWCASE ====================
local ShowcaseTab = Window:CreateTab({ Title = "Showcase", Icon = "✨" })

-- Welcome Section
local WelcomeSection = ShowcaseTab:CreateSection("Welcome to RvrseUI v2.0")

WelcomeSection:CreateButton({
  Text = "🎉 Click Me - Test Ripple Effect!",
  Callback = function()
    RvrseUI:Notify({
      Title = "Success!",
      Message = "You just experienced material ripple animations!",
      Duration = 3,
      Type = "success"
    })
  end
})

-- Interactive Demo Section
local DemoSection = ShowcaseTab:CreateSection("Interactive Elements")

local speedValue = 50
local flyEnabled = false

local speedSlider = DemoSection:CreateSlider({
  Text = "Movement Speed",
  Min = 0,
  Max = 200,
  Step = 5,
  Default = 50,
  OnChanged = function(value)
    speedValue = value
    RvrseUI:Notify({
      Title = "Speed Updated",
      Message = "New speed: " .. value,
      Duration = 1,
      Type = "info"
    })
  end
})

local flyToggle = DemoSection:CreateToggle({
  Text = "Enable Flying",
  State = false,
  OnChanged = function(enabled)
    flyEnabled = enabled
    if enabled then
      RvrseUI:Notify({
        Title = "Flight Enabled",
        Message = "You can now fly at speed " .. speedValue,
        Duration = 2,
        Type = "success"
      })
    else
      RvrseUI:Notify({
        Title = "Flight Disabled",
        Message = "Flying mode deactivated",
        Duration = 2,
        Type = "warn"
      })
    end
  end
})

local modeDropdown = DemoSection:CreateDropdown({
  Text = "Movement Mode",
  Values = { "Walk", "Run", "Sprint", "Teleport" },
  Default = "Walk",
  OnChanged = function(mode)
    RvrseUI:Notify({
      Title = "Mode Changed",
      Message = "Now using: " .. mode,
      Duration = 2,
      Type = "info"
    })
  end
})

-- ==================== TAB 2: LOCK SYSTEM DEMO ====================
local LockTab = Window:CreateTab({ Title = "Lock System", Icon = "🔒" })

local LockDemoSection = LockTab:CreateSection("Master/Child Controls")

-- Master toggle that controls a lock group
LockDemoSection:CreateToggle({
  Text = "🎯 MASTER: Enable All Features",
  State = false,
  LockGroup = "AllFeatures",  -- This CONTROLS the lock
  OnChanged = function(enabled)
    if enabled then
      RvrseUI:Notify({
        Title = "Master Enabled",
        Message = "All features unlocked! Individual controls are now disabled.",
        Duration = 3,
        Type = "success"
      })
    else
      RvrseUI:Notify({
        Title = "Master Disabled",
        Message = "Individual controls re-enabled.",
        Duration = 2,
        Type = "warn"
      })
    end
  end
})

-- Child controls that respect the lock
LockDemoSection:CreateToggle({
  Text = "Feature A (Locked by Master)",
  State = true,
  RespectLock = "AllFeatures",  -- This RESPECTS the lock
  OnChanged = function(on)
    print("Feature A:", on)
  end
})

LockDemoSection:CreateToggle({
  Text = "Feature B (Locked by Master)",
  State = false,
  RespectLock = "AllFeatures",
  OnChanged = function(on)
    print("Feature B:", on)
  end
})

LockDemoSection:CreateButton({
  Text = "Execute Feature (Locked by Master)",
  RespectLock = "AllFeatures",
  Callback = function()
    RvrseUI:Notify({
      Title = "Feature Executed",
      Message = "This only works when master is OFF!",
      Duration = 2,
      Type = "success"
    })
  end
})

-- ==================== TAB 3: SETTINGS ====================
local SettingsTab = Window:CreateTab({ Title = "Settings", Icon = "⚙" })

local ThemeSection = SettingsTab:CreateSection("Appearance")

ThemeSection:CreateDropdown({
  Text = "UI Theme",
  Values = { "Dark", "Light" },
  Default = "Dark",
  OnChanged = function(theme)
    Window:SetTheme(theme)
    RvrseUI:Notify({
      Title = "Theme Changed",
      Message = "Switched to " .. theme .. " mode",
      Duration = 2,
      Type = "info"
    })
  end
})

local KeybindSection = SettingsTab:CreateSection("Keybinds")

KeybindSection:CreateKeybind({
  Text = "Toggle UI Visibility",
  Default = Enum.KeyCode.K,
  OnChanged = function(key)
    RvrseUI:Notify({
      Title = "Keybind Updated",
      Message = "Press " .. key.Name .. " to toggle UI",
      Duration = 2,
      Type = "info"
    })
  end
})

KeybindSection:CreateKeybind({
  Text = "Emergency Stop",
  Default = Enum.KeyCode.X,
  OnChanged = function(key)
    print("Emergency stop bound to:", key.Name)
  end
})

-- ==================== TAB 4: NOTIFICATIONS ====================
local NotifyTab = Window:CreateTab({ Title = "Notifications", Icon = "🔔" })

local NotifySection = NotifyTab:CreateSection("Test Notification System")

NotifySection:CreateButton({
  Text = "✓ Success Notification",
  Callback = function()
    RvrseUI:Notify({
      Title = "Success!",
      Message = "Operation completed successfully with smooth animations!",
      Duration = 3,
      Type = "success"
    })
  end
})

NotifySection:CreateButton({
  Text = "ℹ Info Notification",
  Callback = function()
    RvrseUI:Notify({
      Title = "Information",
      Message = "This is an informational message with blue accent.",
      Duration = 3,
      Type = "info"
    })
  end
})

NotifySection:CreateButton({
  Text = "⚠ Warning Notification",
  Callback = function()
    RvrseUI:Notify({
      Title = "Warning!",
      Message = "This action may have consequences. Proceed with caution.",
      Duration = 3,
      Type = "warn"
    })
  end
})

NotifySection:CreateButton({
  Text = "✕ Error Notification",
  Callback = function()
    RvrseUI:Notify({
      Title = "Error!",
      Message = "Something went wrong. Please check your settings.",
      Duration = 3,
      Type = "error"
    })
  end
})

-- Final welcome message
RvrseUI:Notify({
  Title = "🎉 RvrseUI v2.0 Loaded!",
  Message = "Explore all tabs to see modern features in action. Press K to toggle!",
  Duration = 5,
  Type = "success"
})
```

### Minimal Example (Just the Basics)

```lua
-- Quick minimal setup
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

local Window = RvrseUI:CreateWindow({ Name = "My Script", Theme = "Dark" })
local Tab = Window:CreateTab({ Title = "Main" })
local Section = Tab:CreateSection("Controls")

Section:CreateButton({
  Text = "Execute",
  Callback = function()
    print("Button clicked!")
  end
})

Section:CreateToggle({
  Text = "Enable Feature",
  State = false,
  OnChanged = function(enabled)
    print("Toggle:", enabled)
  end
})
```

## 📦 Installation

```lua
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()
```

The library returns a module table with constructors and utility helpers.

## 🪟 Window API

```lua
local Window = RvrseUI:CreateWindow({
  Name                 = "Window Title",
  Icon                 = 0,            -- number (Roblox asset) or string (emoji), 0 = none
  LoadingTitle         = "Loading...",
  LoadingSubtitle      = "Please wait",
  ShowText             = "RvrseUI",    -- Mobile chip text
  Theme                = "Dark",       -- "Dark" | "Light"
  ToggleUIKeybind      = "K",          -- string "K" or Enum.KeyCode.K
  DisableRvrseUIPrompts = false,
  DisableBuildWarnings  = false,
})
```

### Window Methods

- `Window:SetTitle(title)` - Update window title
- `Window:Show()` - Show window
- `Window:Hide()` - Hide window
- `Window:SetTheme("Dark"/"Light")` - Switch theme at runtime
- `Window:CreateTab({ Title: string, Icon: string? })` → Tab

## 🗂 Tabs & Sections

```lua
local Tab      = Window:CreateTab({ Title = "Controls", Icon = "⚙" })
local Section  = Tab:CreateSection("Main Settings")
```

### Tab Methods

- `Tab:CreateSection(title: string)` → Section

## 🔘 Elements

### Button

```lua
Section:CreateButton({
  Text = "Execute",
  RespectLock = "GroupName",  -- Optional: disabled when lock active
  Callback = function()
    -- Your code here
  end
})
```

**Features**: Material ripple effect, hover animation, lock support

### Toggle

```lua
Section:CreateToggle({
  Text = "Enable Feature",
  State = false,
  LockGroup = "MyGroup",      -- Optional: this toggle CONTROLS the lock
  RespectLock = "OtherGroup", -- Optional: this toggle RESPECTS another lock
  OnChanged = function(on)
    print("Toggled:", on)
  end
})
```

**Features**: iOS-style switch, spring animations, dual lock modes

**API**:
- `toggle:Set(boolean)` - Set state programmatically
- `toggle:Get()` → boolean - Get current state
- `toggle:Refresh()` - Force visual update

### Dropdown

```lua
Section:CreateDropdown({
  Text = "Mode",
  Values = { "Standard", "Aggressive", "Passive" },
  Default = "Standard",
  RespectLock = "GroupName",  -- Optional
  OnChanged = function(value)
    print("Selected:", value)
  end
})
```

**Features**: Cycle through values, hover states, lock support

**API**:
- `dropdown:Set(value)` - Select specific value
- `dropdown:Get()` → value - Get current selection

### Keybind

```lua
Section:CreateKeybind({
  Text = "Toggle Key",
  Default = Enum.KeyCode.E,   -- or "E"
  RespectLock = "GroupName",  -- Optional
  OnChanged = function(keyCode)
    print("Key changed:", keyCode.Name)
  end
})
```

**Features**: Interactive key capture, visual feedback, lock support

**API**:
- `keybind:Set(KeyCode)` - Set key programmatically

### Slider

```lua
Section:CreateSlider({
  Text = "Speed",
  Min = 0,
  Max = 100,
  Step = 1,
  Default = 50,
  RespectLock = "GroupName",  -- Optional
  OnChanged = function(value)
    print("Value:", value)
  end
})
```

**Features**: Gradient fill, draggable thumb with shadow, smooth animations, lock support

**API**:
- `slider:Set(value)` - Set value programmatically
- `slider:Get()` → value - Get current value

## 🔒 Lock Groups

**Purpose**: Coordinate master/child control relationships (e.g., "Enable All" disables individual toggles)

### Creating a Lock Controller

```lua
-- This toggle CONTROLS the lock state
Section:CreateToggle({
  Text = "Master: Enable All",
  State = false,
  LockGroup = "AllEnemies",  -- When ON → locks "AllEnemies" group
  OnChanged = function(on) end
})
```

### Respecting a Lock

```lua
-- These elements are DISABLED when "AllEnemies" lock is active
Section:CreateToggle({
  Text = "Enemy: Bandit",
  State = true,
  RespectLock = "AllEnemies",  -- Becomes locked/disabled
  OnChanged = function(on) end
})

Section:CreateButton({
  Text = "Attack Bandit",
  RespectLock = "AllEnemies",  -- Also locked
  Callback = function() end
})
```

### How It Works

1. **LockGroup** = "Name" → This element **controls** the lock (toggle ON = lock active)
2. **RespectLock** = "Name" → This element **respects** the lock (becomes disabled while locked)
3. Internally managed by `RvrseUI.Store:SetLocked(group, bool)` / `IsLocked(group)`
4. All locked elements show visual feedback (dimmed text, disabled interaction)

## 🔔 Notifications

```lua
RvrseUI:Notify({
  Title    = "Saved",
  Message  = "Settings saved successfully!",
  Duration = 3.0,              -- seconds
  Type     = "success"         -- "info" | "success" | "warn" | "error"
})
```

**Features**:
- Slide-in/fade-out animations
- Colored accent stripe + icon
- Auto-dismiss after duration
- Stacks vertically in bottom-right

## 🎨 Themes

### Built-in Themes

**Dark Theme** (default):
- Modern indigo accent (#6366F1)
- Deep backgrounds with glassmorphism
- High contrast text hierarchy

**Light Theme**:
- Clean white cards
- Subtle shadows and borders
- Softer accent colors

### Theme Switching

```lua
-- At window creation
local Window = RvrseUI:CreateWindow({ Theme = "Light" })

-- At runtime
Window:SetTheme("Dark")
Window:SetTheme("Light")
```

## ⌨️ UI Visibility Keybind

```lua
-- Set at window creation
local Window = RvrseUI:CreateWindow({ ToggleUIKeybind = "K" })

-- Or rebind via keybind element
Section:CreateKeybind({
  Text = "Toggle UI",
  Default = Enum.KeyCode.K,
  OnChanged = function(key)
    -- Automatically rebinds the UI toggle key
  end
})
```

## 📱 Mobile Support

RvrseUI v2.0 automatically detects mobile/tablet devices and:
- Scales window to 380x520 (vs 580x480 desktop)
- Optimizes touch targets (48px minimum)
- Shows floating mobile chip when UI is hidden
- Supports touch drag-to-move on header

## 🎯 Advanced Usage

### Manual Lock Control

```lua
-- Manually set lock state (without toggle)
RvrseUI.Store:SetLocked("MyGroup", true)

-- Check lock state
local isLocked = RvrseUI.Store:IsLocked("MyGroup")
```

### Theme Listeners

```lua
-- React to theme changes (internal use)
table.insert(RvrseUI._themeListeners, function()
  print("Theme changed!")
end)
```

## 🗺 Roadmap

- [ ] Color picker element
- [ ] Textbox input element
- [ ] Multi-select dropdown
- [ ] Persistent settings (save/load to JSON)
- [ ] Search/filter for sections
- [ ] Collapsible sections (accordion)
- [ ] Custom theme builder API
- [ ] Window resize handles
- [ ] Notification action buttons

## 🧾 License

MIT

## 🙌 Credits

**Designed and implemented by Rvrse**

UX/API inspired by Rayfield's mental model, redesigned with modern 2025 UI/UX best practices:
- Glassmorphism from Fluent Design System
- Spring animations from iOS/Material Design
- Mobile-first responsive patterns
- Professional indigo accent palette

---

**RvrseUI v2.0** - Modern. Lightweight. Professional.