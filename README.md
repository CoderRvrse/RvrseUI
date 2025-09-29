# RvrseUI v2.0

A **modern, professional, lightweight** UI framework for Roblox scripts with glassmorphism, spring animations, and mobile-first responsive design.

**Flow**: Boot library → Create Window → Tabs → Sections → Elements (buttons, toggles, dropdowns, keybinds, sliders, notifications).

Includes a **LockGroup system** to coordinate "master" controls with dependent elements (e.g., Aura + Target All master that locks per-enemy toggles).

## ✨ Features

### 🎨 Modern Design
- **Glassmorphism/Acrylic Effects**: Frosted glass blur backgrounds with layered transparency
- **Spring Animations**: Smooth micro-interactions with Snappy, Bounce, and Smooth easing
- **Material Ripple Effects**: Touch-responsive ripple animations on buttons
- **Gradients & Shadows**: Elevated depth with subtle shadow layers and accent gradients
- **Modern Color Palette**: Indigo accents, refined dark/light themes with proper text hierarchy

### 📱 Mobile-First Responsive
- **Auto-Scaling**: Detects mobile/tablet and adjusts window dimensions (380x520 mobile, 580x480 desktop)
- **Touch-Optimized**: 44px minimum tap targets, drag-to-move header
- **Mobile Chip**: Floating re-open button for hidden UI on mobile
- **Smooth Scrolling**: Auto-sizing canvas with slim scrollbars

### 🚀 Advanced Features
- **Drag-to-Reposition**: Click and drag window header to move UI anywhere
- **Theme Switcher**: Runtime theme switching with `Window:SetTheme("Dark"/"Light")`
- **LockGroup System**: Master toggles control dependent element states
- **Animated Notifications**: Toast system with slide-in/fade-out animations
- **Loading Splash**: Animated loading bar with configurable title/subtitle
- **Version Badge**: Display framework version in header

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

```lua
-- Load the library
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

-- Create a window
local Window = RvrseUI:CreateWindow({
  Name                 = "RvrseUI v2.0",
  Icon                 = "🎨",          -- Roblox asset ID or emoji
  LoadingTitle         = "RvrseUI Interface Suite",
  LoadingSubtitle      = "Professional UI Framework",
  ShowText             = "RvrseUI",    -- Mobile chip text
  Theme                = "Dark",       -- "Dark" | "Light"
  ToggleUIKeybind      = "K",          -- Press K to toggle
  DisableRvrseUIPrompts = false,
  DisableBuildWarnings  = false,
})

-- Add a tab & section
local Tab  = Window:CreateTab({ Title = "Overview", Icon = "ℹ" })
local Sect = Tab:CreateSection("Getting Started")

-- Add elements
Sect:CreateButton({
  Text = "Hello World",
  Callback = function()
    RvrseUI:Notify({
      Title = "Welcome",
      Message = "Modern UI loaded successfully!",
      Duration = 2,
      Type = "success"
    })
  end
})

Sect:CreateToggle({
  Text = "Master Mode",
  State = false,
  LockGroup = "MainGroup",  -- This toggle CONTROLS the lock
  OnChanged = function(on)
    print("Master toggle:", on)
  end
})

Sect:CreateSlider({
  Text = "Speed",
  Min = 0,
  Max = 100,
  Step = 1,
  Default = 50,
  OnChanged = function(value)
    print("Speed:", value)
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