# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RvrseUI v2.3.7 is a modern, professional UI framework for Roblox (Luau), featuring glassmorphism, premium slider UX, spring animations, and mobile-first responsive design. It provides a **complete component library** with 12 element types, configuration persistence, theming, lock groups, flags system, and CurrentValue properties for Roblox game scripts.

**Runtime Environment**: Roblox LocalScript (client-side execution)

**Current Version**: v2.3.7 (Build: 20250930, Hash: F2C6B8D4)

**Element Count**: 12 (Button, Toggle, Dropdown, Slider, Keybind, TextBox, ColorPicker, Label, Paragraph, Divider, Section, Tab)

**Key Features**:
- ✅ Configuration System (v2.3.0+) - Auto-save with folder support
- ✅ Premium Slider UX (v2.3.5) - Grow-on-grab, glow effects, buttery smooth
- ✅ Production Dropdown (v2.3.2) - Proper list with scrolling, click-outside-to-close
- ✅ Tab Bar Spacing Fix (v2.3.4) - Clean layout with proper version badge spacing
- ✅ All Critical Bugs Fixed (v2.3.6-2.3.7) - Theme switching, variable names, function ordering

**⚠️ IMPORTANT - Cache Busting**:
Always use cache buster when loading to avoid cached versions:
```lua
local RvrseUI = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua?" .. tick()
))()
```
The `.. tick()` ensures Roblox fetches the latest version instead of using cached data.

## Architecture

### Core Structure (Single-File Design)

The framework (`RvrseUI.lua`, ~2830 lines) is organized into distinct architectural layers:

#### 1. **Theme System** (lines 22-90)
- **Modern dual palette**: Dark (indigo accent #6366F1) and Light themes
- **Extensive color tokens**: Bg, Glass, Card, Elevated (backgrounds); Text, TextSub, TextMuted (hierarchy); Accent, AccentHover, Success, Warning, Error, Info (states); Border, Divider, Hover, Active, Disabled (interactive)
- **Runtime switching**: `Theme:Switch(mode)` triggers `_themeListeners` for live updates
- **Access via** `Theme:Get()` → returns current palette table

#### 2. **Animation System** (lines 92-138)
- **Animator module**: Centralizes all TweenService operations
- **Spring presets**: `Smooth` (0.3s Quad), `Snappy` (0.2s Back), `Bounce` (0.4s Elastic), `Fast` (0.15s Sine)
- **Animator:Tween(obj, props, info)**: Generic tweening with spring presets
- **Animator:Ripple(parent, x, y)**: Material ripple effect for button clicks (expands + fades out)

#### 3. **State Management** (lines 140-157)
- **RvrseUI.Store**: Global state manager for lock groups
- **SetLocked(group, bool)**: Activates/deactivates lock, broadcasts to `_lockListeners`
- **IsLocked(group)**: Checks if a named lock group is active
- **Lock system**: Enables master/child UI relationships (e.g., "Enable All" toggle disables individual controls)

#### 4. **Utility Functions** (lines 159-227)
- **coerceKeycode(k)**: Converts string → Enum.KeyCode
- **corner(inst, r)**: Adds UICorner with radius (default 12px)
- **stroke(inst, color, thickness)**: Adds UIStroke for borders
- **gradient(inst, rotation, colors)**: Adds UIGradient from color array
- **padding(inst, all)**: Adds UIPadding uniformly
- **shadow(inst, transparency, size)**: Simulates elevation shadow using ImageLabel

#### 5. **Host & Notifications** (lines 229-347)
- **host**: Root ScreenGui (`RvrseUI_v2`, DisplayOrder 999)
- **notifyRoot**: Bottom-right stacked notification container with UIListLayout
- **RvrseUI:Notify(opt)**: Creates animated toast cards with:
  - Type-specific icons (✓ success, ✕ error, ⚠ warn, ℹ info)
  - Slide-in animation (from right + fade in)
  - Auto-dismiss after `Duration` seconds (slide-out + fade out)

#### 6. **UI Toggle System** (lines 349-373)
- **RvrseUI.UI:RegisterToggleTarget(frame)**: Tracks windows for visibility toggle
- **RvrseUI.UI:BindToggleKey(key)**: Sets global keybind (default: K)
- **UIS.InputBegan listener**: Toggles all registered windows on keypress

#### 7. **Listeners** (lines 371-373)
- **_lockListeners**: Array of callbacks triggered when any lock state changes
- **_themeListeners**: Array of callbacks triggered on theme switch

#### 8. **Window Builder** (lines 375-1139)
The main factory function `RvrseUI:CreateWindow(cfg)` creates the window hierarchy:

**Window → Tabs → Sections → Elements**

- **Window** (lines 391-621): Root frame, glassmorphic overlay, draggable header, version badge, tabbar, body, splash screen with loading bar, mobile chip
- **Tab** (lines 623-700): Tab button with underline indicator + scrollable page
- **Section** (lines 703-1125): Section header + container with elements
- **Elements**:
  - **Button** (750-785): Material ripple effect, hover animation, lock support
  - **Toggle** (788-864): iOS-style switch with spring animation, dual lock modes (LockGroup = controls, RespectLock = respects)
  - **Dropdown** (867-946): Cycles through values, hover states
  - **Keybind** (949-1024): Interactive key capture with accent feedback
  - **Slider** (1027-1122): Draggable thumb with gradient fill, smooth animations

### Key Patterns

**Mobile-First Responsive** (lines 391-394):
- Auto-detects mobile: `UIS.TouchEnabled and not UIS.MouseEnabled`
- Scales window: 380x520 (mobile) vs 580x480 (desktop)
- Touch-optimized: All inputs support `MouseButton1` + `Touch`

**Drag-to-Move** (lines 434-453):
- Header captures `InputBegan`/`InputEnded`/`InputChanged`
- Tracks delta from `dragStart` to update `root.Position`

**Lock Pattern**:
1. **Controller**: `LockGroup = "Name"` → when toggle ON, sets lock active
2. **Responder**: `RespectLock = "Name"` → becomes disabled while lock active
3. Elements register with `_lockListeners` for visual refresh

**Tab Activation** (lines 668-693):
- Deactivates all tabs (hide page, dim button, hide indicator)
- Activates clicked tab (show page, brighten button, animate indicator)

**Theme System**:
- Elements use `Theme:Get()` at creation for current palette
- For live updates, register in `_themeListeners` (not widely implemented yet)

## API Usage

### Complete Example

```lua
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

-- Create window
local Window = RvrseUI:CreateWindow({
  Name = "Game Script",
  Icon = "🎮",
  LoadingTitle = "Game Script v1.0",
  LoadingSubtitle = "Loading features...",
  Theme = "Dark",
  ToggleUIKeybind = "K"
})

-- Create tabs
local MainTab = Window:CreateTab({ Title = "Main", Icon = "⚙" })
local SettingsTab = Window:CreateTab({ Title = "Settings", Icon = "🔧" })

-- Main tab sections
local PlayerSection = MainTab:CreateSection("Player Enhancements")

local speedSlider = PlayerSection:CreateSlider({
  Text = "Walk Speed",
  Min = 16,
  Max = 100,
  Step = 2,
  Default = 16,
  OnChanged = function(speed)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = speed
    RvrseUI:Notify({
      Title = "Speed Changed",
      Message = "Walk speed set to " .. speed,
      Duration = 1,
      Type = "info"
    })
  end
})

local flyToggle = PlayerSection:CreateToggle({
  Text = "Enable Flying",
  State = false,
  OnChanged = function(enabled)
    if enabled then
      -- Enable fly logic here
      RvrseUI:Notify({ Title = "Flight Enabled", Type = "success", Duration = 2 })
    else
      -- Disable fly logic here
      RvrseUI:Notify({ Title = "Flight Disabled", Type = "warn", Duration = 2 })
    end
  end
})

-- Combat section with lock system
local CombatSection = MainTab:CreateSection("Combat Features")

local masterToggle = CombatSection:CreateToggle({
  Text = "🎯 Auto Target All (MASTER)",
  State = false,
  LockGroup = "AutoTarget",  -- Controls the lock
  OnChanged = function(enabled)
    if enabled then
      -- Enable auto-target for all enemies
      RvrseUI:Notify({
        Title = "Auto Target Enabled",
        Message = "Targeting all enemies. Individual controls locked.",
        Duration = 3,
        Type = "success"
      })
    end
  end
})

-- Individual enemy toggles (locked when master is ON)
CombatSection:CreateToggle({
  Text = "Target: Bandit",
  State = false,
  RespectLock = "AutoTarget",
  OnChanged = function(on) print("Targeting Bandit:", on) end
})

CombatSection:CreateToggle({
  Text = "Target: Guard",
  State = false,
  RespectLock = "AutoTarget",
  OnChanged = function(on) print("Targeting Guard:", on) end
})

-- Settings tab
local ThemeSection = SettingsTab:CreateSection("Appearance")

ThemeSection:CreateDropdown({
  Text = "Theme",
  Values = { "Dark", "Light" },
  Default = "Dark",
  OnChanged = function(theme)
    Window:SetTheme(theme)
    RvrseUI:Notify({
      Title = "Theme Changed",
      Message = "UI theme set to " .. theme,
      Duration = 2,
      Type = "info"
    })
  end
})

local KeybindSection = SettingsTab:CreateSection("Controls")

KeybindSection:CreateKeybind({
  Text = "Toggle UI",
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

-- Notifications
RvrseUI:Notify({
  Title = "Script Loaded",
  Message = "Press K to toggle UI. Explore all features!",
  Duration = 4,
  Type = "success"
})

-- Using element methods
speedSlider:Set(32)  -- Set speed to 32
flyToggle:Set(true)  -- Enable fly toggle
local currentSpeed = speedSlider:Get()  -- Get current speed value
```

### Minimal Example

```lua
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

local Window = RvrseUI:CreateWindow({ Name = "Quick Script" })
local Tab = Window:CreateTab({ Title = "Main" })
local Section = Tab:CreateSection("Controls")

Section:CreateButton({
  Text = "Execute",
  Callback = function()
    print("Executed!")
  end
})
```

## Modifying the Framework

### Adding a New Element Type

1. **Define element function** in Section API (after line 1122):
   ```lua
   function SectionAPI:CreateTextbox(o)
     o = o or {}
     local f = card(44)
     -- Build UI using primitives: Instance.new, corner(), stroke(), padding()
     -- Add interaction logic with :Connect()
     -- Register lock listener if o.RespectLock exists
     return { Set = function(_, v) end, Get = function() end }
   end
   ```

2. **Use helper functions**:
   - `card(height)` → creates elevated frame with border/corner
   - `corner(inst, r)`, `stroke(inst, color, thickness)`, `padding(inst, all)`
   - `Animator:Tween(obj, props, info)` for smooth animations

3. **Lock support pattern**:
   ```lua
   table.insert(RvrseUI._lockListeners, function()
     local locked = RvrseUI.Store:IsLocked(o.RespectLock)
     -- Update visual state (e.g., textTransparency = locked and 0.5 or 0)
   end)
   ```

### Modifying Theme Colors

Edit `Theme.Palettes.Dark` / `.Light` tables (lines 24-76):
```lua
Dark = {
  Accent = Color3.fromRGB(99, 102, 241),  -- Change accent color
  Success = Color3.fromRGB(34, 197, 94),   -- etc.
  -- Add new tokens as needed
}
```

Access in code: `local pal = Theme:Get(); pal.Accent`

### Adjusting Animations

Modify `Animator.Spring` presets (lines 96-100):
```lua
Smooth = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
```

Or pass custom TweenInfo:
```lua
Animator:Tween(obj, {Size = UDim2.new(1,0,1,0)}, TweenInfo.new(0.5, Enum.EasingStyle.Bounce))
```

### Layout Changes

- **Window size**: line 399 (`UDim2.new(0, baseWidth, 0, baseHeight)`)
- **Header height**: line 423 (`UDim2.new(1, 0, 0, 52)`)
- **Tab bar**: line 508 (`Size = UDim2.new(1, -24, 0, 40)`)
- **Body position**: line 524 (`Position = UDim2.new(0, 12, 0, 108)`)

## Testing

Since this is a Roblox framework, testing requires Roblox Studio:

1. **Create test environment**:
   - Open Roblox Studio → New Baseplate
   - Insert LocalScript in `StarterPlayer.StarterPlayerScripts` or `StarterGui`

2. **Load framework**:
   ```lua
   -- Option A: ModuleScript in ReplicatedStorage
   local RvrseUI = require(game.ReplicatedStorage.RvrseUI)

   -- Option B: loadstring (for published version)
   local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()
   ```

3. **Create test UI**:
   ```lua
   local Window = RvrseUI:CreateWindow({Name = "Test"})
   local Tab = Window:CreateTab({Title = "Test"})
   local Section = Tab:CreateSection("Elements")
   Section:CreateButton({Text = "Test", Callback = function() print("Clicked!") end})
   ```

4. **Run game** (F5) and interact with UI

### Mobile Testing

- In Studio: Test → Device → Phone (to simulate mobile viewport)
- Or use Roblox Player on actual mobile device

## Performance Considerations

- **Single-file design**: ~1140 lines, loads instantly with `loadstring()`
- **Minimal instance creation**: Reuses primitives, no deep cloning
- **Efficient animations**: TweenService pooling, spring presets avoid stuttering
- **Lock system**: O(1) lookup via table, broadcasts only on change
- **Theme system**: Palettes stored as tables, no per-frame calculations

## Common Issues

**Dragging not working**:
- Ensure header has proper input handling (lines 436-453)
- Check `ClipsDescendants = false` on root (line 405)

**Locks not updating**:
- Verify `LockGroup` vs `RespectLock` usage (controller vs responder)
- Check element registered in `_lockListeners` (use `table.insert`)

**Theme not applying**:
- Ensure `Theme:Get()` called inside element creation
- For live updates, implement `_themeListeners` registration

**Mobile scaling issues**:
- Verify `isMobile` detection (line 392)
- Check baseWidth/baseHeight logic (lines 393-394)

## Luau Type Safety

The original framework did not use `--!strict` mode. When adding features:
- Use `typeof()` for runtime type checks (e.g., line 462-463)
- Coerce types explicitly: `o = o or {}` (e.g., line 751)
- Optional: Add type annotations for better IDE support (not currently implemented)

## Dependencies

- **Roblox Services**: Players, UserInputService, TweenService, RunService (imported lines 6-9)
- **No external libraries**: Fully self-contained single-file framework
## COMPLETE ELEMENT REFERENCE (v2.2.0)
# RvrseUI v2.2.0 - Complete Element Documentation

## ALL 12 ELEMENTS

### 1. BUTTON
**Purpose**: Clickable action trigger

**API**:
```lua
local MyButton = Section:CreateButton({
	Text = "Click Me",
	Callback = function()
		print("Button clicked!")
	end,
	Flag = "MyButton",  -- Optional: Access via RvrseUI.Flags["MyButton"]
	RespectLock = "GroupName"  -- Optional: Disabled when lock active
})

-- Methods
MyButton:SetText("New Text")
-- Properties
MyButton.CurrentValue  -- Button text
```

### 2. TOGGLE
**Purpose**: On/Off switch with iOS-style animation

**API**:
```lua
local MyToggle = Section:CreateToggle({
	Text = "Enable Feature",
	State = false,  -- Initial state
	OnChanged = function(state)
		print("Toggle:", state)
	end,
	Flag = "MyToggle",
	LockGroup = "GroupName",  -- Optional: Controls lock (master)
	RespectLock = "GroupName"  -- Optional: Respects lock (child)
})

-- Methods
MyToggle:Set(true)  -- Set state
MyToggle:Get()  -- Get state
MyToggle:Refresh()  -- Update visual
-- Properties
MyToggle.CurrentValue  -- Current boolean state
```

###3. DROPDOWN
**Purpose**: Cycle through value options

**API**:
```lua
local MyDropdown = Section:CreateDropdown({
	Text = "Select Mode",
	Values = {"Easy", "Medium", "Hard"},
	Default = "Medium",
	OnChanged = function(value)
		print("Selected:", value)
	end,
	Flag = "MyDropdown",
	RespectLock = "GroupName"
})

-- Methods
MyDropdown:Set("Hard")  -- Set value (triggers callback)
MyDropdown:Get()  -- Get current value
MyDropdown:Refresh({"New", "Values"})  -- Update options list
-- Properties
MyDropdown.CurrentOption  -- Current selected value
```

### 4. SLIDER
**Purpose**: Numeric value selection with draggable thumb

**API**:
```lua
local MySlider = Section:CreateSlider({
	Text = "Speed",
	Min = 0,
	Max = 100,
	Step = 5,
	Default = 50,
	OnChanged = function(value)
		print("Slider:", value)
	end,
	Flag = "MySlider",
	RespectLock = "GroupName"
})

-- Methods
MySlider:Set(75)  -- Set value
MySlider:Get()  -- Get value
-- Properties
MySlider.CurrentValue  -- Current numeric value
```

### 5. KEYBIND
**Purpose**: Interactive key capture

**API**:
```lua
local MyKeybind = Section:CreateKeybind({
	Text = "Execute Hotkey",
	Default = Enum.KeyCode.E,
	OnChanged = function(key)
		print("Keybind set to:", key.Name)
	end,
	Flag = "MyKeybind",
	RespectLock = "GroupName"
})

-- Methods
MyKeybind:Set(Enum.KeyCode.Q)  -- Set keybind (triggers callback)
MyKeybind:Get()  -- Get KeyCode
-- Properties
MyKeybind.CurrentKeybind  -- Current Enum.KeyCode
```

### 6. TEXTBOX (Adaptive Input)
**Purpose**: Text input field

**API**:
```lua
local MyTextBox = Section:CreateTextBox({
	Text = "Username",
	Placeholder = "Enter username...",
	Default = "Player123",
	OnChanged = function(text, enterPressed)
		print("Text:", text, "Enter:", enterPressed)
	end,
	Flag = "MyTextBox",
	RespectLock = "GroupName"
})

-- Methods
MyTextBox:Set("NewText")  -- Set text
MyTextBox:Get()  -- Get text
-- Properties
MyTextBox.CurrentValue  -- Current text string
```

### 7. COLORPICKER
**Purpose**: Color selection (cycles through 8 presets)

**API**:
```lua
local MyColorPicker = Section:CreateColorPicker({
	Text = "Theme Color",
	Default = Color3.fromRGB(99, 102, 241),
	OnChanged = function(color)
		print("Color:", color)
	end,
	Flag = "MyColorPicker",
	RespectLock = "GroupName"
})

-- Methods
MyColorPicker:Set(Color3.fromRGB(255, 0, 0))  -- Set color
MyColorPicker:Get()  -- Get Color3
-- Properties
MyColorPicker.CurrentValue  -- Current Color3
```

### 8. LABEL
**Purpose**: Simple text display

**API**:
```lua
local MyLabel = Section:CreateLabel({
	Text = "Status: Ready",
	Flag = "MyLabel"
})

-- Methods
MyLabel:Set("Status: Updated")  -- Update text
MyLabel:Get()  -- Get text
-- Properties
MyLabel.CurrentValue  -- Current text
```

### 9. PARAGRAPH
**Purpose**: Multi-line text with auto-wrapping

**API**:
```lua
local MyParagraph = Section:CreateParagraph({
	Text = "This is a long paragraph with multiple lines...",
	Flag = "MyParagraph"
})

-- Methods
MyParagraph:Set("New paragraph text")  -- Update text (auto-resizes)
MyParagraph:Get()  -- Get text
-- Properties
MyParagraph.CurrentValue  -- Current text
```

### 10. DIVIDER
**Purpose**: Visual separator line

**API**:
```lua
local MyDivider = Section:CreateDivider()

-- Methods
MyDivider:SetColor(Color3.fromRGB(255, 255, 255))  -- Change color
```

### 11. SECTION
**Purpose**: Container for elements within a tab

**API**:
```lua
local MySection = Tab:CreateSection("Section Title")

-- Then create elements:
MySection:CreateButton({...})
MySection:CreateToggle({...})
MySection:CreateDropdown({...})
MySection:CreateSlider({...})
MySection:CreateKeybind({...})
MySection:CreateTextBox({...})
MySection:CreateColorPicker({...})
MySection:CreateLabel({...})
MySection:CreateParagraph({...})
MySection:CreateDivider()
```

### 12. TAB
**Purpose**: Top-level navigation container

**API**:
```lua
local MyTab = Window:CreateTab({
	Title = "Main",
	Icon = "home"  -- Unicode icon name, asset ID, or emoji
})

-- Then create sections:
local Section1 = MyTab:CreateSection("Section 1")
local Section2 = MyTab:CreateSection("Section 2")
```

## GLOBAL SYSTEMS

### Flags System
Access any flagged element globally:
```lua
-- Create with Flag
local Toggle = Section:CreateToggle({ Text = "Test", Flag = "MyToggle" })

-- Access anywhere
RvrseUI.Flags["MyToggle"]:Set(true)
RvrseUI.Flags["MyToggle"]:Get()  -- Returns: true
```

### Lock Groups
Master/Child control relationships:
```lua
-- MASTER: Controls the lock
Section:CreateToggle({
	Text = "Auto Mode (MASTER)",
	LockGroup = "AutoMode"  -- When ON, locks children
})

-- CHILDREN: Respect the lock
Section:CreateToggle({
	Text = "Option A",
	RespectLock = "AutoMode"  -- Disabled when master is ON
})

Section:CreateSlider({
	Text = "Speed",
	RespectLock = "AutoMode"  -- Also disabled
})
```

### CurrentValue Properties
Check element values without callbacks:
```lua
print(MyToggle.CurrentValue)  -- boolean
print(MyDropdown.CurrentOption)  -- string
print(MySlider.CurrentValue)  -- number
print(MyKeybind.CurrentKeybind)  -- Enum.KeyCode
print(MyTextBox.CurrentValue)  -- string
print(MyColorPicker.CurrentValue)  -- Color3
print(MyLabel.CurrentValue)  -- string
```

### Dropdown:Refresh()
Update dropdown options dynamically:
```lua
local Dropdown = Section:CreateDropdown({
	Values = {"Easy", "Medium", "Hard"}
})

-- Later, refresh with new values:
Dropdown:Refresh({"Beginner", "Intermediate", "Expert", "Master"})
```

## COMPLETE EXAMPLE

```lua
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

local Window = RvrseUI:CreateWindow({ Name = "Test", Icon = "game" })
local Tab = Window:CreateTab({ Title = "Main", Icon = "home" })
local Section = Tab:CreateSection("Elements")

-- 1. Button
Section:CreateButton({
	Text = "Click",
	Callback = function() print("Clicked!") end,
	Flag = "Btn"
})

-- 2. Toggle
local Toggle = Section:CreateToggle({
	Text = "Enable",
	State = false,
	OnChanged = function(s) print(s) end,
	Flag = "Tgl"
})

-- 3. Dropdown
local Dropdown = Section:CreateDropdown({
	Text = "Mode",
	Values = {"A", "B", "C"},
	Default = "B",
	OnChanged = function(v) print(v) end,
	Flag = "Drop"
})

-- 4. Slider
local Slider = Section:CreateSlider({
	Text = "Value",
	Min = 0,
	Max = 100,
	Default = 50,
	OnChanged = function(v) print(v) end,
	Flag = "Slide"
})

-- 5. Keybind
local Keybind = Section:CreateKeybind({
	Text = "Hotkey",
	Default = Enum.KeyCode.E,
	OnChanged = function(k) print(k.Name) end,
	Flag = "Key"
})

-- 6. TextBox
local TextBox = Section:CreateTextBox({
	Text = "Name",
	Placeholder = "Enter...",
	Default = "User",
	OnChanged = function(t) print(t) end,
	Flag = "Text"
})

-- 7. ColorPicker
local ColorPicker = Section:CreateColorPicker({
	Text = "Color",
	Default = Color3.fromRGB(255, 0, 0),
	OnChanged = function(c) print(c) end,
	Flag = "Color"
})

-- 8. Label
local Label = Section:CreateLabel({
	Text = "Status: OK",
	Flag = "Label"
})

-- 9. Paragraph
local Para = Section:CreateParagraph({
	Text = "Long text here...",
	Flag = "Para"
})

-- 10. Divider
Section:CreateDivider()

-- Update elements
Toggle:Set(true)
Dropdown:Set("C")
Slider:Set(75)
Label:Set("Status: Updated")

-- Check values
print(Toggle:Get())  -- true
print(Toggle.CurrentValue)  -- true
print(Dropdown.CurrentOption)  -- "C"
print(Slider.CurrentValue)  -- 75

-- Access via Flags
RvrseUI.Flags["Tgl"]:Set(false)
print(RvrseUI.Flags["Drop"]:Get())  -- "C"

-- Refresh dropdown
Dropdown:Refresh({"X", "Y", "Z"})
```
