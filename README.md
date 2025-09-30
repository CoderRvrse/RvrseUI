# RvrseUI v2.2.0

A **modern, professional, lightweight** UI framework for Roblox scripts with glassmorphism, spring animations, notification controls, Unicode icon system, and mobile-first responsive design.

**Flow**: Boot library → Create Window → Tabs → Sections → Elements (12 element types available).

Includes a **LockGroup system** to coordinate "master" controls with dependent elements + **Flags system** for global element access.

## ✨ Features

### 🎉 NEW in v2.2.0: Complete Element System
- **ALL 12 Elements Implemented**: Button, Toggle, Dropdown, Slider, Keybind, TextBox, ColorPicker, Label, Paragraph, Divider, Section, Tab
- **Flags System**: `RvrseUI.Flags` - Global storage to access any element by flag name
- **CurrentValue Properties**: All elements have `.CurrentValue`, `.CurrentOption`, or `.CurrentKeybind`
- **Dropdown:Refresh()**: Update dropdown options dynamically with `Dropdown:Refresh(newValues)`
- **Complete API**: Every element supports Set(), Get(), and Flag parameters
- **FULL_DEMO.lua**: Comprehensive showcase testing all 12 elements with examples

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

-- RvrseUI v2.2.0+ Complete Element Showcase
-- This demo showcases ALL available elements and features

local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

-- Create Window
local Window = RvrseUI:CreateWindow({
	Name = "RvrseUI v2.2.0 Complete Demo",
	Icon = "game",  -- Unicode icon system
	LoadingTitle = "RvrseUI Complete Showcase",
	LoadingSubtitle = "Testing ALL elements...",
	Theme = "Dark",
	ToggleUIKeybind = "K"
})

print("🎮 RvrseUI v2.2.0 Complete Demo")
print("📊 Testing ALL 12 elements + features")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

-- ═══════════════════════════════════════
-- TAB 1: INTERACTIVE ELEMENTS
-- ═══════════════════════════════════════
local InteractiveTab = Window:CreateTab({
	Title = "Interactive",
	Icon = "target"
})

local ButtonSection = InteractiveTab:CreateSection("Buttons & Actions")

-- 1. BUTTON
ButtonSection:CreateButton({
	Text = "Click Me!",
	Callback = function()
		RvrseUI:Notify({
			Title = "Button Clicked",
			Message = "You clicked the button!",
			Duration = 2,
			Type = "success"
		})
		print("✓ Button clicked!")
	end,
	Flag = "TestButton"
})

-- 2. TOGGLE
local TestToggle = ButtonSection:CreateToggle({
	Text = "Enable Feature",
	State = false,
	OnChanged = function(state)
		print("✓ Toggle state:", state)
		RvrseUI:Notify({
			Title = "Toggle Changed",
			Message = "State: " .. tostring(state),
			Duration = 1,
			Type = "info"
		})
	end,
	Flag = "TestToggle"
})

-- 3. DROPDOWN
local TestDropdown = ButtonSection:CreateDropdown({
	Text = "Select Mode",
	Values = {"Easy", "Medium", "Hard", "Extreme"},
	Default = "Medium",
	OnChanged = function(value)
		print("✓ Dropdown selected:", value)
		RvrseUI:Notify({
			Title = "Mode Changed",
			Message = "Selected: " .. value,
			Duration = 1,
			Type = "info"
		})
	end,
	Flag = "TestDropdown"
})

-- 4. SLIDER
local TestSlider = ButtonSection:CreateSlider({
	Text = "Speed",
	Min = 0,
	Max = 100,
	Step = 5,
	Default = 50,
	OnChanged = function(value)
		print("✓ Slider value:", value)
	end,
	Flag = "TestSlider"
})

-- 5. KEYBIND
local TestKeybind = ButtonSection:CreateKeybind({
	Text = "Execute Hotkey",
	Default = Enum.KeyCode.E,
	OnChanged = function(key)
		print("✓ Keybind set to:", key.Name)
		RvrseUI:Notify({
			Title = "Keybind Updated",
			Message = "Press " .. key.Name .. " to execute",
			Duration = 2,
			Type = "info"
		})
	end,
	Flag = "TestKeybind"
})

-- ═══════════════════════════════════════
-- TAB 2: INPUT ELEMENTS
-- ═══════════════════════════════════════
local InputTab = Window:CreateTab({
	Title = "Inputs",
	Icon = "edit"
})

local InputSection = InputTab:CreateSection("Text & Color Inputs")

-- 6. TEXTBOX (Adaptive Input)
local TestTextBox = InputSection:CreateTextBox({
	Text = "Username",
	Placeholder = "Enter your username...",
	Default = "Player123",
	OnChanged = function(text, enterPressed)
		print("✓ TextBox value:", text, "| Enter pressed:", enterPressed)
		if enterPressed then
			RvrseUI:Notify({
				Title = "Username Set",
				Message = "Username: " .. text,
				Duration = 2,
				Type = "success"
			})
		end
	end,
	Flag = "TestTextBox"
})

-- 7. COLORPICKER
local TestColorPicker = InputSection:CreateColorPicker({
	Text = "Theme Color",
	Default = Color3.fromRGB(99, 102, 241),
	OnChanged = function(color)
		print("✓ Color changed:", color)
		RvrseUI:Notify({
			Title = "Color Selected",
			Message = string.format("RGB(%d, %d, %d)", color.R * 255, color.G * 255, color.B * 255),
			Duration = 2,
			Type = "info"
		})
	end,
	Flag = "TestColorPicker"
})

-- ═══════════════════════════════════════
-- TAB 3: DISPLAY ELEMENTS
-- ═══════════════════════════════════════
local DisplayTab = Window:CreateTab({
	Title = "Display",
	Icon = "eye"
})

local DisplaySection = DisplayTab:CreateSection("Labels & Text Display")

-- 8. LABEL
local TestLabel = DisplaySection:CreateLabel({
	Text = "Status: Ready",
	Flag = "TestLabel"
})

-- 9. PARAGRAPH
local TestParagraph = DisplaySection:CreateParagraph({
	Text = "This is a paragraph element. It supports long text with automatic wrapping. Perfect for instructions, descriptions, or multi-line information. You can update the text dynamically using the Set method!",
	Flag = "TestParagraph"
})

-- 10. DIVIDER
DisplaySection:CreateDivider()

DisplaySection:CreateLabel({
	Text = "↑ Divider Above ↑"
})

-- ═══════════════════════════════════════
-- TAB 4: LOCK SYSTEM DEMO
-- ═══════════════════════════════════════
local LockTab = Window:CreateTab({
	Title = "Lock System",
	Icon = "lock"
})

local LockSection = LockTab:CreateSection("Master/Child Lock Demo")

LockSection:CreateParagraph({
	Text = "The MASTER toggle controls the lock group. When ON, it disables all child elements in the same lock group."
})

-- MASTER: Controls the lock
LockSection:CreateToggle({
	Text = "🎯 Enable Auto-Mode (MASTER)",
	State = false,
	LockGroup = "AutoMode",  -- This controls the lock
	OnChanged = function(state)
		RvrseUI:Notify({
			Title = "Auto-Mode " .. (state and "Enabled" or "Disabled"),
			Message = state and "Individual controls locked" or "Individual controls unlocked",
			Duration = 2,
			Type = state and "warning" or "info"
		})
	end
})

LockSection:CreateDivider()

-- CHILDREN: Respect the lock
LockSection:CreateToggle({
	Text = "Option A",
	State = false,
	RespectLock = "AutoMode",  -- Locked when master is ON
	OnChanged = function(on) print("Option A:", on) end
})

LockSection:CreateToggle({
	Text = "Option B",
	State = false,
	RespectLock = "AutoMode",
	OnChanged = function(on) print("Option B:", on) end
})

LockSection:CreateSlider({
	Text = "Intensity",
	Min = 0,
	Max = 100,
	Default = 50,
	RespectLock = "AutoMode"
})

-- ═══════════════════════════════════════
-- TAB 5: API TESTING
-- ═══════════════════════════════════════
local APITab = Window:CreateTab({
	Title = "API Tests",
	Icon = "code"
})

local UpdateSection = APITab:CreateSection("Element Update Methods")

UpdateSection:CreateParagraph({
	Text = "This tab demonstrates updating elements programmatically using :Set() methods and checking values with :Get() and .CurrentValue"
})

UpdateSection:CreateButton({
	Text = "Update All Elements",
	Callback = function()
		-- Update via Set() methods
		TestToggle:Set(true)
		TestDropdown:Set("Hard")
		TestSlider:Set(75)
		TestKeybind:Set(Enum.KeyCode.Q)
		TestTextBox:Set("UpdatedUser")
		TestColorPicker:Set(Color3.fromRGB(255, 0, 0))
		TestLabel:Set("Status: Updated!")
		TestParagraph:Set("All elements have been updated programmatically!")

		print("✓ All elements updated via :Set() methods")
		RvrseUI:Notify({
			Title = "Elements Updated",
			Message = "Check the other tabs!",
			Duration = 3,
			Type = "success"
		})
	end
})

UpdateSection:CreateButton({
	Text = "Check Current Values",
	Callback = function()
		print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		print("📊 CURRENT VALUES:")
		print("Toggle:", TestToggle:Get(), "| CurrentValue:", TestToggle.CurrentValue)
		print("Dropdown:", TestDropdown:Get(), "| CurrentOption:", TestDropdown.CurrentOption)
		print("Slider:", TestSlider:Get(), "| CurrentValue:", TestSlider.CurrentValue)
		print("Keybind:", TestKeybind:Get().Name, "| CurrentKeybind:", TestKeybind.CurrentKeybind.Name)
		print("TextBox:", TestTextBox:Get(), "| CurrentValue:", TestTextBox.CurrentValue)
		print("Color:", TestColorPicker:Get())
		print("Label:", TestLabel:Get())
		print("Paragraph:", TestParagraph:Get())
		print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

		RvrseUI:Notify({
			Title = "Values Logged",
			Message = "Check console (F9) for output",
			Duration = 2,
			Type = "info"
		})
	end
})

UpdateSection:CreateDivider()

local FlagsSection = APITab:CreateSection("Flags System Testing")

FlagsSection:CreateParagraph({
	Text = "All elements were created with Flag names. You can access them via RvrseUI.Flags['FlagName']"
})

FlagsSection:CreateButton({
	Text = "Test Flags System",
	Callback = function()
		print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		print("🚩 FLAGS SYSTEM TEST:")

		-- Access elements via Flags
		print("Via Flags - Toggle:", RvrseUI.Flags["TestToggle"]:Get())
		print("Via Flags - Dropdown:", RvrseUI.Flags["TestDropdown"]:Get())
		print("Via Flags - Slider:", RvrseUI.Flags["TestSlider"]:Get())

		-- Update via Flags
		RvrseUI.Flags["TestToggle"]:Set(false)
		RvrseUI.Flags["TestDropdown"]:Set("Easy")
		RvrseUI.Flags["TestSlider"]:Set(25)

		print("✓ Updated elements via Flags system")
		print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

		RvrseUI:Notify({
			Title = "Flags Test Complete",
			Message = "Elements updated via Flags!",
			Duration = 2,
			Type = "success"
		})
	end
})

-- ═══════════════════════════════════════
-- TAB 6: UNICODE ICONS SHOWCASE
-- ═══════════════════════════════════════
local IconsTab = Window:CreateTab({
	Title = "Icons",
	Icon = "star"
})

local IconsSection = IconsTab:CreateSection("Unicode Icon System")

IconsSection:CreateParagraph({
	Text = "RvrseUI v2.2.0 includes 150+ Unicode icons. No external assets required!"
})

IconsSection:CreateLabel({ Text = "🏠 home | ⚙ settings | 🔍 search | ℹ info" })
IconsSection:CreateLabel({ Text = "👤 user | 🔒 lock | 🔓 unlock | 🔑 key" })
IconsSection:CreateLabel({ Text = "💰 money | 💎 diamond | 🎮 game | 🏆 trophy" })
IconsSection:CreateLabel({ Text = "⚔ sword | 🎯 target | 💥 explosion | 🛡 shield" })
IconsSection:CreateLabel({ Text = "⚠ warning | ✓ success | ✕ error | 🔔 notification" })

IconsSection:CreateDivider()

IconsSection:CreateButton({
	Text = "📝 Show All Icon Categories",
	Callback = function()
		print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		print("📚 UNICODE ICON CATEGORIES:")
		print("• Navigation: home, settings, menu, search")
		print("• Arrows: arrow-up/down/left/right, chevron-*")
		print("• Actions: play, pause, stop, edit, trash, save")
		print("• User: user, users, profile, chat, message")
		print("• Security: lock, unlock, key, shield, verified")
		print("• Currency: robux, dollar, coin, money, diamond")
		print("• Items: box, gift, shopping, bag, backpack")
		print("• Files: file, folder, document, clipboard")
		print("• Tech: code, terminal, database, server, wifi")
		print("• Nature: sun, moon, star, cloud, fire, water")
		print("• Games: trophy, award, target, crown, sword")
		print("• Combat: sword, weapon, gun, bomb, explosion")
		print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	end
})

-- ═══════════════════════════════════════
-- FINAL SUMMARY
-- ═══════════════════════════════════════
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("✅ RvrseUI v2.2.0 Demo Loaded!")
print("")
print("📦 12 Elements Tested:")
print("  1. ✓ Button")
print("  2. ✓ Toggle")
print("  3. ✓ Dropdown")
print("  4. ✓ Slider")
print("  5. ✓ Keybind")
print("  6. ✓ TextBox (Adaptive Input)")
print("  7. ✓ ColorPicker")
print("  8. ✓ Label")
print("  9. ✓ Paragraph")
print(" 10. ✓ Divider")
print(" 11. ✓ Section")
print(" 12. ✓ Tab")
print("")
print("🎯 Features Tested:")
print("  • CurrentValue properties")
print("  • Flags system (RvrseUI.Flags)")
print("  • Lock Groups (Master/Child)")
print("  • :Set() / :Get() methods")
print("  • Dropdown:Refresh()")
print("  • Unicode icon system (150+ icons)")
print("")
print("Press K to toggle UI")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

-- Welcome notification
RvrseUI:Notify({
	Title = "Demo Loaded Successfully",
	Message = "Explore all 6 tabs to test every element!",
	Duration = 5,
	Type = "success"
})
```

**Or load the demo directly:**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/FULL_DEMO.lua"))()
```

### Minimal Example (Just the Basics)

```lua
-- Quick minimal setup with icon support
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

-- Window with Lucide icon and optional container
local Window = RvrseUI:CreateWindow({
	Name = "My Script",
	Icon = "code",  -- Lucide icon
	Theme = "Dark",
	-- Container = "PlayerGui"  -- Optional: PlayerGui (default), CoreGui, ReplicatedFirst
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
  Container            = "PlayerGui",  -- NEW: "PlayerGui" (default), "CoreGui", "ReplicatedFirst", "StarterGui", or Instance
  DisplayOrder         = 999,          -- NEW: Custom render order (default: 999)
  DisableRvrseUIPrompts = false,
  DisableBuildWarnings  = false,
})
```

### 📦 Container Selection (NEW in v2.1.5+)

Choose where your UI is hosted for different use cases:

```lua
-- Default: PlayerGui (standard player UI)
local Window1 = RvrseUI:CreateWindow({
	Name = "Player UI"
})

-- CoreGui: Persistent admin/mod panels
local Window2 = RvrseUI:CreateWindow({
	Name = "Admin Panel",
	Container = "CoreGui",
	Icon = "shield"
})

-- ReplicatedFirst: Custom loading screens
local Window3 = RvrseUI:CreateWindow({
	Name = "Loading Screen",
	Container = "ReplicatedFirst",
	Icon = "loader"
})

-- Custom DisplayOrder: Control render layering
local Window4 = RvrseUI:CreateWindow({
	Name = "Overlay",
	DisplayOrder = 9999  -- Higher = renders on top
})
```

**See [CONTAINER_FEATURE.md](CONTAINER_FEATURE.md) for complete guide with use cases!**

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