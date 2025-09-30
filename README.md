# RvrseUI v2.1.5

A **modern, professional, lightweight** UI framework for Roblox scripts with glassmorphism, spring animations, notification controls, Lucide icon support, and mobile-first responsive design.

**Flow**: Boot library → Create Window → Tabs → Sections → Elements (buttons, toggles, dropdowns, keybinds, sliders, notifications).

Includes a **LockGroup system** to coordinate "master" controls with dependent elements (e.g., Aura + Target All master that locks per-enemy toggles).

## ✨ Features

### 🔔 NEW in v2.1.5: Critical Fixes + Lucide Icons
- **Theme Switching Fixed**: Dark/Light theme toggle now updates ALL UI elements instantly
- **Lucide Icon Support**: 80+ icons from Lucide library (string names like `"home"`, `"settings"`)
- **Multiple Icon Formats**: Supports Lucide names, Roblox asset IDs, and emojis
- **Theme-Aware Icons**: Icons automatically change color with theme
- **Keybind System Verified**: UI visibility toggle working correctly (default: K)

### 🔔 Features from v2.1: Revolutionary Controls
- **Close Button**: ✕ Professional close button in top right - completely destroys UI with no trace
- **Notification Bell Toggle**: 🔔/🔕 Professional 50x20px pill in header for instant mute/unmute
- **Mini Theme Toggle**: 🌙/🌞 Switch between Dark/Light themes with one click
- **Version Badge**: Bottom left corner badge showing version info (clickable for details)
- **Professional Tooltips**: Hover feedback system for all header controls
- **Glowing Animations**: Pulsing glow effects on active notification bell
- **Enhanced Glass**: True 95% transparency with white tinting and edge shine
- **Complete Cleanup**: Close button and `Destroy()` method remove all UI elements, connections, and listeners

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
- **Icons**: Lucide library (80+ icons), Roblox asset IDs, emojis - all supported

### 🎛 Developer Experience
- **Familiar API**: Rayfield-style creation pattern
- **Zero Boilerplate**: Single-file `loadstring()` loader
- **Type Hints**: Clear API with consistent naming
- **Lightweight**: ~1100 lines, optimized for performance

## 🚀 Quick Start

### Copy & Paste Demo (Full Showcase)

```lua
-- ============================================
-- RvrseUI v2.1.5 - Complete Feature Demo
-- Copy this entire script to test all features
-- Tests: Theme switching, Lucide icons, Roblox asset IDs, emojis
-- ============================================

local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

-- Create main window with Lucide icon
local Window = RvrseUI:CreateWindow({
  Name = "RvrseUI v2.1.5",
  Icon = "settings",  -- NEW: Lucide icon support!
  LoadingTitle = "RvrseUI v2.1.5",
  LoadingSubtitle = "Loading with Lucide icons...",
  Theme = "Dark",
  ToggleUIKeybind = "K"
})

-- ==================== TAB 1: LUCIDE ICONS ====================
local LucideTab = Window:CreateTab({ Title = "Lucide Icons", Icon = "home" })  -- Lucide icon

-- Lucide Icons Section
local LucideSection = LucideTab:CreateSection("Lucide Icon Library (80+ icons)")

LucideSection:CreateButton({
  Text = "ℹ️ What are Lucide Icons?",
  Callback = function()
    RvrseUI:Notify({
      Title = "Lucide Icons",
      Message = "Professional icon library with 80+ icons. Use string names like 'home', 'settings', 'shield'",
      Duration = 5,
      Type = "info"
    })
  end
})

LucideSection:CreateButton({
  Text = "✅ Test Theme Switching",
  Callback = function()
    RvrseUI:Notify({
      Title = "Theme Switching",
      Message = "Click the 🌙/🌞 pill in the header! All icons and colors will update instantly.",
      Duration = 4,
      Type = "success"
    })
  end
})

-- ==================== TAB 2: ROBLOX ASSET IDs ====================
local AssetTab = Window:CreateTab({ Title = "Asset IDs", Icon = 4483362458 })  -- Roblox asset ID (number)

local AssetSection = AssetTab:CreateSection("Roblox Asset ID Icons")

AssetSection:CreateButton({
  Text = "ℹ️ How to use Asset IDs?",
  Callback = function()
    RvrseUI:Notify({
      Title = "Asset IDs",
      Message = "Use any Roblox image asset ID as a number. Example: Icon = 4483362458",
      Duration = 4,
      Type = "info"
    })
  end
})

AssetSection:CreateButton({
  Text = "Test Asset Icon Tab",
  Callback = function()
    RvrseUI:Notify({
      Title = "Asset Icons Work!",
      Message = "This tab's icon is from Roblox asset ID 4483362458",
      Duration = 3,
      Type = "success"
    })
  end
})

-- ==================== TAB 3: EMOJI ICONS ====================
local EmojiTab = Window:CreateTab({ Title = "Emojis", Icon = "🎨" })  -- Emoji (string)

local EmojiSection = EmojiTab:CreateSection("Emoji & Text Icons")

EmojiSection:CreateButton({
  Text = "ℹ️ How to use Emojis?",
  Callback = function()
    RvrseUI:Notify({
      Title = "Emoji Icons",
      Message = "Use any emoji or text string. Example: Icon = '🎨' or Icon = '⚙️'",
      Duration = 4,
      Type = "info"
    })
  end
})

EmojiSection:CreateButton({
  Text = "Test Emoji Tab",
  Callback = function()
    RvrseUI:Notify({
      Title = "Emoji Icons Work!",
      Message = "This tab uses 🎨 emoji as its icon",
      Duration = 3,
      Type = "success"
    })
  end
})

-- ==================== TAB 4: INTERACTIVE DEMO ====================
local ShowcaseTab = Window:CreateTab({ Title = "Interactive", Icon = "zap" })  -- Another Lucide icon

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

-- ==================== TAB 5: MORE LUCIDE ICONS ====================
local MoreIconsTab = Window:CreateTab({ Title = "More Icons", Icon = "grid" })  -- Lucide grid icon

local MoreIconsSection = MoreIconsTab:CreateSection("Popular Lucide Icons")

-- Showcase different Lucide icons
local lucideExamples = {
	{icon = "shield", name = "Shield (security)"},
	{icon = "lock", name = "Lock (secured)"},
	{icon = "unlock", name = "Unlock (open)"},
	{icon = "target", name = "Target (aim)"},
	{icon = "zap", name = "Zap (power)"},
	{icon = "star", name = "Star (favorite)"},
	{icon = "heart", name = "Heart (like)"},
	{icon = "bell", name = "Bell (notifications)"},
	{icon = "search", name = "Search (find)"},
	{icon = "code", name = "Code (programming)"},
}

for _, example in ipairs(lucideExamples) do
	MoreIconsSection:CreateButton({
		Text = example.icon .. " - " .. example.name,
		Callback = function()
			RvrseUI:Notify({
				Title = "Icon: " .. example.icon,
				Message = example.name .. "\nUsage: Icon = '" .. example.icon .. "'",
				Duration = 3,
				Type = "info"
			})
		end
	})
end

-- ==================== TAB 6: LOCK SYSTEM DEMO ====================
local LockTab = Window:CreateTab({ Title = "Lock System", Icon = "lock" })  -- Lucide lock icon

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

-- ==================== TAB 7: SETTINGS ====================
local SettingsTab = Window:CreateTab({ Title = "Settings", Icon = "sliders" })  -- Lucide sliders icon

local ThemeSection = SettingsTab:CreateSection("Appearance")

ThemeSection:CreateButton({
  Text = "ℹ️ Theme Control Info",
  Callback = function()
    RvrseUI:Notify({
      Title = "Theme Switching",
      Message = "Click the 🌙/🌞 pill in the header to switch themes. All UI elements update instantly!",
      Duration = 5,
      Type = "info"
    })
  end
})

ThemeSection:CreateButton({
  Text = "🎨 Test Theme Change",
  Callback = function()
    RvrseUI:Notify({
      Title = "Theme Instructions",
      Message = "Look at the header! Click the 🌙 or 🌞 pill button to switch themes.",
      Duration = 4,
      Type = "success"
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

-- ==================== TAB 8: NOTIFICATIONS ====================
local NotifyTab = Window:CreateTab({ Title = "Notifications", Icon = "bell" })  -- Lucide bell icon

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
  Title = "🎉 RvrseUI v2.1.5 Loaded!",
  Message = "✅ Lucide icons\n✅ Roblox asset IDs\n✅ Emoji icons\n✅ Theme switching\nPress K to toggle UI!",
  Duration = 6,
  Type = "success"
})

print("===========================================")
print("RvrseUI v2.1.5 Demo Loaded")
print("===========================================")
print("Icon Formats Tested:")
print("✓ Tab 1: Lucide icon (home)")
print("✓ Tab 2: Roblox asset ID (4483362458)")
print("✓ Tab 3: Emoji (🎨)")
print("✓ Tab 4: Lucide icon (zap)")
print("✓ Tab 5: Lucide icon (grid)")
print("✓ Tab 6: Lucide icon (lock)")
print("✓ Tab 7: Lucide icon (sliders)")
print("✓ Tab 8: Lucide icon (bell)")
print("===========================================")
print("Theme Switching: Click 🌙/🌞 pill in header")
print("UI Toggle: Press K key")
print("===========================================")
```

### Minimal Example (Just the Basics)

```lua
-- Quick minimal setup with icon support
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

-- Window with Lucide icon
local Window = RvrseUI:CreateWindow({
	Name = "My Script",
	Icon = "code",  -- Lucide icon
	Theme = "Dark"
})

-- Tab with Lucide icon
local Tab = Window:CreateTab({
	Title = "Main",
	Icon = "home"  -- Another Lucide icon
})

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

-- Global UI control examples
Section:CreateButton({
  Text = "Hide UI",
  Callback = function()
    RvrseUI:SetVisibility(false)
  end
})

Section:CreateButton({
  Text = "Toggle UI",
  Callback = function()
    RvrseUI:ToggleVisibility()
  end
})

Section:CreateButton({
  Text = "Destroy UI",
  Callback = function()
    RvrseUI:Destroy()  -- Completely removes all UI
  end
})
```

## 📦 Installation

```lua
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()
```

The library returns a module table with constructors and utility helpers.

### 🔍 Version Verification

Check your version and verify integrity:

```lua
-- Get version info
local info = RvrseUI:GetVersionInfo()
print("Version:", info.Version)    -- "2.1.0"
print("Build:", info.Build)        -- "20250129"
print("Hash:", info.Hash)          -- "A7F3E8C2"
print("Channel:", info.Channel)    -- "Stable"

-- Get formatted version string
print(RvrseUI:GetVersionString())  -- "v2.1.0 (20250129)"

-- Click version badge in UI for detailed popup
```

**Latest Release**: v2.1.5 "Aurora" | Hash: `F9D4E7B3` | Build: `20250930`

See [RELEASES.md](RELEASES.md) for full changelog and version history.

## 🪟 Window API

```lua
local Window = RvrseUI:CreateWindow({
  Name                 = "Window Title",
  Icon                 = "settings",   -- Lucide icon, Roblox asset ID (number), emoji (string), or 0 for none
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
- `Window:Destroy()` - **Completely destroy THIS window** (cleans up ScreenGui, connections, listeners)
- `Window:CreateTab({ Title: string, Icon: string|number? })` → Tab

**Note:** `Window:SetTheme()` has been removed in v2.1.5. Theme switching is now controlled exclusively by the topbar pill (🌙/🌞).

### Global RvrseUI Methods

These methods work across ALL windows:

```lua
-- Destroy ALL UI completely (no trace remaining)
RvrseUI:Destroy()

-- Toggle visibility of ALL windows (hide/show)
local isVisible = RvrseUI:ToggleVisibility()

-- Set visibility explicitly
RvrseUI:SetVisibility(true)   -- Show all
RvrseUI:SetVisibility(false)  -- Hide all
```

**Use Cases**:
- `RvrseUI:Destroy()` - When player wants to completely unload the UI
- `RvrseUI:ToggleVisibility()` - Quick hide/show for screenshots or gameplay
- `RvrseUI:SetVisibility(false)` - Hide UI during specific game events

## 🗂 Tabs & Sections

```lua
-- Tab with Lucide icon
local Tab1 = Window:CreateTab({ Title = "Home", Icon = "home" })

-- Tab with Roblox asset ID
local Tab2 = Window:CreateTab({ Title = "Settings", Icon = 4483362458 })

-- Tab with emoji
local Tab3 = Window:CreateTab({ Title = "Profile", Icon = "⚙" })

local Section = Tab1:CreateSection("Main Settings")
```

### Icon Support (NEW in v2.1.5)

**Three ways to specify icons:**
1. **Lucide icon name** (string): `Icon = "home"`, `"settings"`, `"shield"`, etc.
   - 80+ icons available from Lucide library
   - See [FIXES_DOCUMENTATION.md](FIXES_DOCUMENTATION.md) for full list
2. **Roblox asset ID** (number): `Icon = 4483362458`
3. **Emoji/text** (string): `Icon = "🎮"`, `"⚙️"`

Icons automatically change color with theme switching.

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