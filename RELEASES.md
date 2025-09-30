# RvrseUI Release History

## Version 2.3.5 "Buttery Smooth" - Premium Slider UX
**Release Date**: September 30, 2025
**Build**: 20250930
**Hash**: `D4F7B9E2`
**Channel**: Stable

### 🎨 UX Overhaul - Premium Slider Feel

The slider has been completely overhauled with premium interactions that feel **buttery smooth** and responsive. Every interaction now provides satisfying visual and tactile feedback.

---

#### ✨ Grow-on-Grab Animation

The thumb now **grows when you grab it**, providing immediate visual feedback that you're in control:

**Sizes**:
- **Default**: 18px (resting state)
- **Hover**: 20px (preview of grab)
- **Dragging**: 24px (active, grabbed state)

**Springs Used**:
- Grab: `Animator.Spring.Snappy` (0.2s Back) - punchy, responsive
- Release: `Animator.Spring.Bounce` (0.4s Elastic) - satisfying bounce back

```lua
-- When grabbed
Animator:Tween(thumb, {Size = UDim2.new(0, 24, 0, 24)}, Animator.Spring.Snappy)

-- When released
local targetSize = hovering and 20 or 18
Animator:Tween(thumb, {Size = UDim2.new(0, targetSize, 0, targetSize)}, Animator.Spring.Bounce)
```

---

#### ✨ Glow Effect on Active

When dragging, an **accent-colored glow ring** appears around the thumb:

**Glow Ring**:
- Color: Accent theme color
- Thickness: 3px stroke
- Transparency: 30%
- Animates in with `Animator.Spring.Smooth`

**Behavior**:
- Appears instantly when grab starts
- Fades out when released
- Subtle 1px glow remains on hover

```lua
-- Glow stroke animation
glowStroke.Color = pal3.Accent
glowStroke.Thickness = 0  -- Hidden by default

-- On grab
Animator:Tween(glowStroke, {Thickness = 3}, Animator.Spring.Smooth)

-- On release
Animator:Tween(glowStroke, {Thickness = hovering and 1 or 0}, Animator.Spring.Fast)
```

---

#### 🎯 Enhanced Interaction States

**1. Resting State** (18px):
- Subtle shadow (40% transparency, 4px blur)
- Clean white thumb on track

**2. Hover State** (20px):
- Thumb grows slightly
- Previews the grab interaction
- Prepares user for click

**3. Dragging State** (24px):
- Thumb at maximum size
- Accent glow ring at 3px
- Buttery smooth movement

**4. Release State**:
- Bouncy shrink animation
- Returns to hover size if still hovering
- Glow fades out smoothly

---

#### 🎨 Visual Improvements

**Track**:
- Height: 6px → **8px** (better hit area, easier to click)
- Corner radius: 3px → **4px** (matches new proportions)

**Thumb**:
- Default size: 16px → **18px** (more substantial)
- Corner radius: 8px → **9px** (perfect circle at all sizes)
- Shadow: 50% → **40%** transparency, 3px → **4px** size (deeper shadow)

**Fill**:
- Gradient remains (Accent → AccentHover)
- Animates with `Animator.Spring.Smooth` (was Fast)
- Buttery smooth fill animation as you drag

---

#### ⚡ Performance Optimizations

**Hover State Tracking**:
```lua
local hovering = false

track.MouseEnter:Connect(function()
  hovering = true
  -- Grow to 20px
end)

track.MouseLeave:Connect(function()
  if dragging then return end  -- Don't shrink if dragging!
  hovering = false
  -- Shrink to 18px
end)
```

**Smart Release Sizing**:
```lua
-- Release returns to hover size if mouse still over track
local targetSize = hovering and 20 or 18
```

This prevents jarring size changes if you release while still hovering.

---

#### 🎯 Animation Timeline

**User Hovers**:
1. Thumb: 18px → 20px (`Fast` 0.15s)
2. Glow ring: 18px → 20px (`Fast` 0.15s)

**User Grabs**:
1. Thumb: 20px → 24px (`Snappy` 0.2s with Back easing)
2. Glow: 0px → 3px stroke (`Smooth` 0.3s)
3. Value updates as user drags

**User Drags**:
1. Thumb position: Follows mouse (`Snappy` 0.2s)
2. Fill: Expands/shrinks (`Smooth` 0.3s)
3. Glow: Remains at 3px

**User Releases**:
1. Thumb: 24px → 20px or 18px (`Bounce` 0.4s Elastic)
2. Glow: 3px → 1px or 0px (`Fast` 0.15s)
3. Satisfying bounce-back feel

---

### 📊 Version Info
```lua
RvrseUI.Version = {
  Major = 2,
  Minor = 3,
  Patch = 5,
  Full = "2.3.5",
  Hash = "D4F7B9E2"
}
```

---

## Version 2.3.4 "Clean Layout" - Tab Bar Spacing Fix
**Release Date**: September 30, 2025
**Build**: 20250930
**Hash**: `C7E9F2A5`
**Channel**: Stable

### 🎨 Layout Fix - Tab Bar Visual Separation

#### Problem
The tab bar was positioned too close to the left edge (12px), causing visual clutter and overlap with the version badge below it. The tab buttons appeared to "hit" or clash with the version pill, creating an unprofessional, cramped appearance.

#### Solution
Increased the tab bar's left margin to create **clear visual space** above the version badge:

**Tab Bar Position**: Changed from `(0, 12, 0, 60)` → `(0, 54, 0, 60)`
- **Left margin**: 12px → **54px** (+42px additional space)
- Creates a clean vertical column for the version badge in the bottom-left

**Tab Bar Width**: Adjusted from `-24` → `-66`
- Compensates for the increased left margin (54px left + 12px right = 66px total)
- Maintains proper right-side spacing

---

### Visual Impact

**Before (v2.3.3)**:
```
┌─────────────────────────────┐
│  [Tab1] [Tab2] [Tab3]      │  ← Tabs start at 12px
│                             │
│                             │
│  v2.3.3                     │  ← Badge at 8px (visual clash)
└─────────────────────────────┘
```

**After (v2.3.4)**:
```
┌─────────────────────────────┐
│             [Tab1] [Tab2]   │  ← Tabs start at 54px
│                             │
│                             │
│  v2.3.4                     │  ← Badge at 8px (clean separation)
└─────────────────────────────┘
```

---

### Benefits
✅ **Clear visual separation** between tabs and version badge
✅ **No visual clutter** or overlap
✅ **Professional spatial hierarchy** - version badge has its own dedicated space
✅ **Clean, readable layout** across all screen sizes
✅ **Tabs appear properly aligned** without interfering with UI chrome

---

### Technical Details
```lua
-- Tab bar positioning
tabBar.Position = UDim2.new(0, 54, 0, 60)   -- Was: (0, 12, 0, 60)
tabBar.Size = UDim2.new(1, -66, 0, 40)      -- Was: (1, -24, 0, 40)

-- Version badge (unchanged, but now has clear space above)
versionBadge.Position = UDim2.new(0, 8, 1, -24)
versionBadge.Size = UDim2.new(0, 38, 0, 14)
```

---

### 📊 Version Info
```lua
RvrseUI.Version = {
  Major = 2,
  Minor = 3,
  Patch = 4,
  Full = "2.3.4",
  Hash = "C7E9F2A5"
}
```

---

## Version 2.3.3 "Clean UI" - Version Badge Containment Fix
**Release Date**: September 30, 2025
**Build**: 20250930
**Hash**: `A1B8E4D7`
**Channel**: Stable

### 🎨 UI Fix - Version Badge Fully Contained

#### Problem
The version badge (v2.x.x pill) was positioned at `UDim2.new(0, -4, 1, -20)`, causing it to:
- **Hang 4px outside** the left edge of the panel
- **Overlap panel border lines**
- Look visually inconsistent and unprofessional

#### Solution
Repositioned and resized the version badge to be **fully contained** within the panel:

**Position**: Changed from `(0, -4, 1, -20)` → `(0, 8, 1, -24)`
- **8px inset from left edge** (was hanging -4px outside)
- **8px inset from bottom edge** (24px from bottom = 8px gap + 14px height + 2px for stroke)

**Size**: Reduced from `42x16` → `38x14`
- Smaller, more refined pill appearance
- Better proportions for contained layout

**Text Size**: Reduced from `8px` → `7px`
- Matches smaller badge size
- Maintains readability

**Corner Radius**: Reduced from `6px` → `5px`
- Proportional to smaller size
- Cleaner pill shape

---

### Visual Comparison

**Before (v2.3.2)**:
```lua
Position = UDim2.new(0, -4, 1, -20)  -- Hanging outside
Size = UDim2.new(0, 42, 0, 16)
TextSize = 8
CornerRadius = 6
```

**After (v2.3.3)**:
```lua
Position = UDim2.new(0, 8, 1, -24)   -- Fully contained with 8px insets
Size = UDim2.new(0, 38, 0, 14)
TextSize = 7
CornerRadius = 5
```

---

### Benefits
✅ Badge never touches or overlaps panel borders
✅ Consistent 8px spacing from panel edges
✅ Cleaner, more professional appearance
✅ Works across all screen sizes and breakpoints
✅ No visual clutter or overlap issues

---

### 📊 Version Info
```lua
RvrseUI.Version = {
  Major = 2,
  Minor = 3,
  Patch = 3,
  Full = "2.3.3",
  Hash = "A1B8E4D7"
}
```

---

## Version 2.3.2 "Dropdown++" - Production-Grade Dropdown Fix
**Release Date**: September 30, 2025
**Build**: 20250930
**Hash**: `F9D2A8C1`
**Channel**: Stable

### 🔧 Critical Fix - Production-Grade Dropdown Rewrite

#### ✅ FIXED: Dropdown Spacing & Expansion

The dropdown menu now properly expands with an **8px gap** below the button, creating smooth visual spacing for the dropdown list to appear.

**Technical Implementation**:
- Set `f.ClipsDescendants = false` on card (CRITICAL fix)
- Dropdown positioned at `UDim2.new(1, -136, 0.5, 40)` (below button with gap)
- Starts at 0 height, animates to full height using `Animator:Tween()`
- Smooth expand/collapse animations with `Animator.Spring.Snappy`

---

#### ✅ FIXED: Dropdown Selection Functionality

All dropdown options are now **fully clickable** and work correctly:

**What Was Fixed**:
- Option click handlers now properly update selection
- `idx` variable correctly updated on click
- Button text updates to show selected value
- OnChanged callback fires with correct value
- Visual highlighting updates for all options
- Dropdown closes after selection with animation

**How It Works**:
```lua
optionBtn.MouseButton1Click:Connect(function()
  if locked() then return end

  idx = i  -- Update selection
  btn.Text = tostring(value)  -- Update button text

  -- Update all option visuals
  for j, obtn in ipairs(optionButtons) do
    if j == i then
      obtn.BackgroundColor3 = pal3.Accent
      obtn.BackgroundTransparency = 0.8
      obtn.TextColor3 = pal3.Accent
    else
      obtn.BackgroundColor3 = pal3.Card
      obtn.BackgroundTransparency = 0
      obtn.TextColor3 = pal3.Text
    end
  end

  -- Close dropdown
  dropdownOpen = false
  arrow.Text = "▼"
  Animator:Tween(dropdownList, {Size = UDim2.new(0, 130, 0, 0)}, Animator.Spring.Fast)

  -- Trigger callback
  if o.OnChanged then task.spawn(o.OnChanged, value) end
  if o.Flag then RvrseUI:_autoSave() end
end)
```

---

#### 🎨 Visual & UX Improvements

1. **Smooth Animations**:
   - Expand: Animates from 0 to full height (max 160px)
   - Collapse: Animates from full height to 0
   - Uses `Animator.Spring.Snappy` for responsive feel

2. **Selected Option Highlighting**:
   - Selected option: Accent color background (80% transparent)
   - Selected option text: Accent color
   - Non-selected options: Card background, Text color

3. **Hover Effects**:
   - Options change to Hover color when mouse enters
   - Reverts to Card color when mouse leaves
   - Selected option maintains Accent color

4. **Arrow Indicator**:
   - Closed: ▼
   - Open: ▲
   - Flips instantly on click

5. **Enhanced ZIndex**:
   - Dropdown: 100
   - ScrollingFrame: 101
   - Options: 102
   - Ensures dropdown appears above all other elements

6. **Visual Depth**:
   - Accent-colored border stroke (1px)
   - Shadow effect (16px blur, 60% transparency)
   - Professional elevation appearance

---

#### ⚡ Performance Optimizations

- Proper event handler cleanup
- Optimized option button creation loop
- Debounced click outside detection (0.05s delay for AbsolutePosition updates)
- Efficient `optionButtons` array for quick visual updates

---

#### 🔄 Refresh Method Enhancement

The `Refresh()` method now properly rebuilds all options:

```lua
dropdownAPI.Refresh = function(_, newValues)
  if newValues then
    values = newValues
    idx = 1
    btn.Text = tostring(values[idx] or "Select")

    -- Rebuild all options
    for _, child in ipairs(dropdownScroll:GetChildren()) do
      if child:IsA("TextButton") then child:Destroy() end
    end

    table.clear(optionButtons)
    dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, #values * itemHeight)
    dropdownHeight = math.min(#values * itemHeight, maxHeight)

    -- Recreate all option buttons with proper event handlers
    for i, value in ipairs(values) do
      -- Full option button creation with click handlers
    end
  end
  visual()
end
```

---

### 📊 Version Info
```lua
RvrseUI.Version = {
  Major = 2,
  Minor = 3,
  Patch = 2,
  Full = "2.3.2",
  Hash = "F9D2A8C1"
}
```

---

## Version 2.3.1 "Persistence+" - Config Folders & Dropdown Fix
**Release Date**: September 30, 2025
**Build**: 20250930
**Hash**: `8A4F6D3E`
**Channel**: Stable

### 🔧 Enhancement Release - UI Fixes & Config Improvements

#### ✨ NEW: Configuration Folder Support

Now supports table format with folder organization:

```lua
local Window = RvrseUI:CreateWindow({
  ConfigurationSaving = {
    Enabled = true,
    FolderName = "BigHub",     -- Creates folder automatically
    FileName = "PlayerConfig"  -- Saves as BigHub/PlayerConfig.json
  }
})
```

**Features**:
- Automatic folder creation via `makefolder()`
- Organize configs by hub/game
- Backward compatible with old boolean format
- Path: `FolderName/FileName.json`

**Old Format Still Works**:
```lua
ConfigurationSaving = true,
FileName = "Config.json"
```

---

#### 🎨 FIXED: Version Badge Position

Version badge is now smaller and positioned better:

**Before**: 50x18 at (8, -26) with 9px text
**After**: 42x16 at (-4, -20) with 8px text

- More outside to the left
- Lower down
- Smaller and cleaner
- Less obtrusive

---

#### 🔽 FIXED: Dropdown Menu

Dropdown now works like a real dropdown instead of cycling:

**Features**:
- Click to show all options in a list
- Arrow indicator (▼ closed, ▲ open)
- Scrollable list (max 160px height)
- Selected option highlighted
- Hover effects on options
- Click outside to close
- Proper option selection

**Before**: Clicked to cycle through values (confusing)
**After**: Clicks to open list, select any option directly (intuitive)

**Example**:
```lua
Section:CreateDropdown({
  Text = "Game Mode",
  Values = { "Easy", "Normal", "Hard", "Expert", "Master" },
  Default = "Normal",
  OnChanged = function(mode)
    print("Selected:", mode)
  end
})
```

Now clicking shows a proper dropdown list with all 5 options visible/scrollable!

---

### 📊 Version Info
```lua
RvrseUI.Version = {
  Major = 2,
  Minor = 3,
  Patch = 1,
  Full = "2.3.1",
  Hash = "8A4F6D3E"
}
```

---

## Version 2.3.0 "Persistence" - Configuration System
**Release Date**: September 30, 2025
**Build**: 20250930
**Hash**: `7F5E2B9C`
**Channel**: Stable

### 💾 Major Release - Complete Configuration System

Automatically save and restore your UI settings across script reloads!

#### Quick Start
```lua
-- Enable configuration saving
local Window = RvrseUI:CreateWindow({
  ConfigurationSaving = true,
  FileName = "MyScript_Config.json"
})

-- Add Flag to elements you want to save
Section:CreateSlider({ Flag = "WalkSpeed", ... })
Section:CreateToggle({ Flag = "AutoFarm", ... })

-- Load at bottom of script
RvrseUI:LoadConfiguration()
```

#### New Methods
- `RvrseUI:SaveConfiguration()` - Save all flagged elements
- `RvrseUI:LoadConfiguration()` - Restore saved settings
- `RvrseUI:DeleteConfiguration()` - Remove saved config
- `RvrseUI:ConfigurationExists()` - Check if config exists

#### Features
- ✅ Auto-save after 1 second of inactivity
- ✅ All flagged elements supported
- ✅ JSON storage (human-readable)
- ✅ Debounced saves (prevent spam)
- ✅ Complete persistence

#### Demo
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/CONFIG_DEMO.lua"))()
```

---

## Version 2.2.2 "Nexus Pro" - Dynamic UI Control
**Release Date**: September 30, 2025
**Build**: 20250930
**Hash**: `4DD9E8A6`
**Channel**: Stable

### 🎯 Enhancement Release - Complete Dynamic Control

#### New Methods Added
1. **Element:SetVisible(bool)** - Added to ALL 12 elements
   - Button, Toggle, Dropdown, Slider, Keybind
   - TextBox, ColorPicker
   - Label, Paragraph, Divider
   - Programmatic show/hide control for every UI element

2. **Notification Priority System**
   ```lua
   RvrseUI:Notify({
     Title = "Critical Alert",
     Message = "Urgent issue detected",
     Priority = "critical",  -- critical, high, normal (default), low
     Type = "error",
     Duration = 5
   })
   ```
   - Priority levels: `critical`, `high`, `normal` (default), `low`
   - Higher priority notifications appear at bottom (most visible position)
   - Uses LayoutOrder for proper stacking

3. **Section:Update(title)** - Change section headers dynamically
   ```lua
   local MySection = Tab:CreateSection("Initial Title")
   MySection:Update("New Title")
   ```

4. **Section:SetVisible(visible)** - Hide/show entire sections
   ```lua
   MySection:SetVisible(false)  -- Hide section
   MySection:SetVisible(true)   -- Show section
   ```

5. **Tab:SetIcon(icon)** - Change tab icons at runtime
   ```lua
   local MyTab = Window:CreateTab({ Title = "Main", Icon = "home" })
   MyTab:SetIcon("settings")  -- Change to settings icon
   MyTab:SetIcon("trophy")    -- Change to trophy icon
   ```

6. **Window:SetIcon(icon)** - Change window icon at runtime
   ```lua
   Window:SetIcon("game")
   Window:SetIcon("trophy")
   ```

### 📋 Complete API Enhancement Example
```lua
-- Create elements
local MySection = Tab:CreateSection("Player Features")
local SpeedToggle = MySection:CreateToggle({ Text = "Speed Boost" })

-- Dynamic visibility control
SpeedToggle:SetVisible(false)  -- Hide element
task.wait(2)
SpeedToggle:SetVisible(true)   -- Show element

-- Dynamic section control
MySection:Update("Advanced Player Features")  -- Update title
MySection:SetVisible(false)  -- Hide entire section

-- Priority notifications
RvrseUI:Notify({
  Title = "System Critical",
  Priority = "critical",
  Type = "error",
  Duration = 10
})
```

### 📊 Version Info
```lua
RvrseUI.Version = {
  Major = 2,
  Minor = 2,
  Patch = 2,
  Full = "2.2.2",
  Hash = "4DD9E8A6"
}
```

---

## Version 2.2.1 "Mobile Optimize" - Multi-Device Enhancement
**Release Date**: September 30, 2025
**Build**: 20250930
**Hash**: `3BC2BDD5`
**Channel**: Stable

### 📱 Mobile Notification Improvements
- Reduced notification width from 340px to 300px for small screens
- Adjusted padding from -16 to -8 for better mobile layout
- Enhanced compatibility across all device sizes

---

## Version 2.2.0 "Nexus" - Complete Element System
**Release Date**: September 30, 2025
**Build**: 20250930
**Hash**: `2A68C9C3`
**Channel**: Stable

### 🎉 MAJOR RELEASE - All 12 Elements Implemented

---

## Version 2.1.7 "Aurora" - Unicode Icon System
**Release Date**: September 30, 2025
**Build**: 20250930
**Hash**: `08B730DF`
**Channel**: Stable

### 🎨 Major Update - Universal Icons
- **Unicode Icon System** - Replaced Lucide asset IDs with universal Unicode/emoji icons
  - **150+ icons** that work everywhere without external dependencies
  - Mix of emojis (🏠 ⚙ 👤) and Unicode symbols (✓ ✕ ⚠)
  - **Roblox-specific icons**: Robux, Premium, Verified (using `utf8.char`)
  - Categories: Navigation, Actions, Media, Status, User, Security, Currency, Items, Files, Tech, Nature, Games, Combat, UI Elements
  - Simple usage: `Icon = "home"`, `Icon = "settings"`, `Icon = "user"`
  - **Backward compatible**: Still supports custom Roblox asset IDs and direct emojis

### ✨ Icon Categories & Examples
```lua
-- Navigation & UI
Icon = "home"      -- 🏠
Icon = "settings"  -- ⚙
Icon = "menu"      -- ☰

-- Security & Currency
Icon = "lock"      -- 🔒
Icon = "robux"     -- (Roblox Robux symbol)
Icon = "premium"   -- (Roblox Premium symbol)

-- Actions & Media
Icon = "play"      -- ▶
Icon = "edit"      -- ✎
Icon = "trash"     -- 🗑

-- Combat & Games
Icon = "sword"     -- ⚔
Icon = "target"    -- 🎯
Icon = "trophy"    -- 🏆
```

### 🔧 Technical Changes
- Renamed `resolveLucideIcon()` to `resolveIcon()`
- Replaced `LucideIcons` table with `UnicodeIcons` table
- No more broken/inaccessible asset IDs
- All icons render instantly (no asset loading)
- Full theme integration maintained

### 📊 Version Info
```lua
RvrseUI.Version = {
  Major = 2,
  Minor = 1,
  Patch = 7,
  Build = "20250930",
  Full = "2.1.7",
  Hash = "08B730DF",
  Channel = "Stable"
}
```

### 📥 Download
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()
```

---

## Version 2.1.6 "Aurora" - Tab Overflow Fix
**Release Date**: September 30, 2025
**Build**: 20250930
**Hash**: `A8D3FBC5`
**Channel**: Stable

### 🔧 Critical Fix
- **Tab Bar Overflow** - Complete fix for tab overflow when many tabs are created
  - Converted tab bar Frame to ScrollingFrame
  - Horizontal scrolling with auto-sizing canvas
  - Tabs stay within UI bounds regardless of count
  - Smooth elastic scrolling behavior
  - Scrollbar styled to match glassmorphic theme (4px thin bar)
  - Theme switching updates scrollbar color
  - Touch and mouse wheel support

### 🎨 Visual Improvements
- Subtle scrollbar (4px thickness, 50% transparency)
- Scrollbar automatically hides when not needed (ElasticBehavior.WhenScrollable)
- Consistent theme integration across all UI elements

### 📊 Technical Details
```lua
RvrseUI.Version = {
  Major = 2,
  Minor = 1,
  Patch = 6,
  Build = "20250930",
  Full = "2.1.6",
  Hash = "A8D3FBC5",
  Channel = "Stable"
}
```

### 📥 Download
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()
```

---

## Version 2.1.5 "Aurora" - Critical Fixes Release
**Release Date**: September 30, 2025
**Build**: 20250930
**Hash**: `F9D4E7B3`
**Channel**: Stable

### 🔧 Critical Fixes
- **Theme Switching System** - Complete fix for Dark/Light theme toggle
  - All UI elements now update correctly when switching themes
  - Updates: root window, header, body, tabs, icons, control buttons, glass overlay
  - Instant visual feedback across entire UI
- **Keybind System** - Verified working correctly (default: K)
  - Global keybind for UI visibility toggle
  - Supports runtime rebinding via `RvrseUI.UI:BindToggleKey(key)`
- **Theme Control Restriction** - Removed `WindowAPI:SetTheme()` method
  - Theme now controlled exclusively by topbar pill (🌙/🌞)
  - Prevents script conflicts with user preferences

### ✨ Major New Feature: Lucide Icon Support
- **80+ Lucide Icons** now available
- **Multiple icon formats supported:**
  - Lucide icon names (string): `Icon = "home"`
  - Roblox asset IDs (number): `Icon = 4483362458`
  - Emoji/text (string): `Icon = "🎮"`
- **Auto-detection** of icon type
- **Theme-aware** icons (colors change with theme)
- **Works in:** Window icons and Tab icons

### 📚 Documentation & Testing
- Added `TEST_FIXES.lua` - Comprehensive test script
- Added `FIXES_DOCUMENTATION.md` - Detailed fix documentation
- Added `CHANGELOG_v2.1.5.md` - Release notes

### 📊 Technical Details
```lua
RvrseUI.Version = {
  Major = 2,
  Minor = 1,
  Patch = 5,
  Build = "20250930",
  Full = "2.1.5",
  Hash = "F9D4E7B3",
  Channel = "Stable"
}
```

### 📥 Download
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()
```

### ⚠️ Breaking Changes
- **WindowAPI:SetTheme() removed** - Theme switching now exclusively via topbar pill

---

## Version 2.1.4 "Aurora" - UI Layout Refinements
**Release Date**: September 29, 2025
**Build**: 20250929
**Hash**: `E8B3C9A2`
**Channel**: Stable

### 🎨 UI Fixes & Polish
- **Fixed Header Control Positioning**: Close | Bell | Theme (proper spacing, no overlap)
- **Close Button**: Repositioned to far right at `(1, -12)` - 32x32px
- **Bell Toggle**: Repositioned to `(1, -52)` - reduced to 32x24px
- **Theme Toggle**: Repositioned to `(1, -92)` - reduced to 32x24px
- **Version Badge**: Smaller 50x18px (was 70x24px), font size 9 (was 10)
- **Code Cleanup**: Removed duplicate close button code

### ✨ Visual Improvements
- All header controls properly aligned with 8px spacing
- Version badge more discreet and better proportioned
- Professional layout with no overlapping elements
- Tighter, cleaner UI appearance

### 📊 Technical Details
```lua
RvrseUI.Version = {
  Major = 2,
  Minor = 1,
  Patch = 4,
  Build = "20250929",
  Full = "2.1.4",
  Hash = "E8B3C9A2",
  Channel = "Stable"
}
```

### 📥 Download
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()
```

---

## Version 2.1.3 "Aurora" - Global UI Control Methods
**Release Date**: September 29, 2025
**Build**: 20250929
**Hash**: `D7A2E5F4`
**Channel**: Stable

### 🌐 Major Feature: Global UI Management
- **RvrseUI:Destroy()**: Destroy ALL UI windows from anywhere in your code
- **RvrseUI:ToggleVisibility()**: Instantly hide/show entire interface
- **RvrseUI:SetVisibility(bool)**: Explicitly control UI visibility
- **Multi-Window Support**: Works seamlessly with multiple windows
- **Instant Response**: Uses ScreenGui.Enabled for zero-delay visibility toggle

### 🎮 Use Cases
```lua
-- Destroy everything (no trace remaining)
RvrseUI:Destroy()

-- Quick hide/show for screenshots
RvrseUI:ToggleVisibility()

-- Hide during cutscenes
RvrseUI:SetVisibility(false)

-- Show after event
RvrseUI:SetVisibility(true)
```

### ✨ Benefits
- Control UI from any script context
- Works across all windows simultaneously
- Perfect for game events, cinematics, screenshots
- Returns boolean status for validation
- Maintains all window-specific destroy methods

### 📊 Technical Details
```lua
RvrseUI.Version = {
  Major = 2,
  Minor = 1,
  Patch = 3,
  Build = "20250929",
  Full = "2.1.3",
  Hash = "D7A2E5F4",
  Channel = "Stable"
}

-- Global methods available
RvrseUI:Destroy()              -- Returns: bool
RvrseUI:ToggleVisibility()     -- Returns: bool (new state)
RvrseUI:SetVisibility(visible) -- Returns: bool (success)
```

### 📥 Download
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()
```

---

## Version 2.1.2 "Aurora" - Complete Destruction System
**Release Date**: September 29, 2025
**Build**: 20250929
**Hash**: `C3F8A6E9`
**Channel**: Stable

### 🗑️ Major Feature: Complete UI Cleanup
- **Close Button Destruction**: Clicking X button completely destroys the ScreenGui
- **Window:Destroy() Method**: Programmatically destroy UI from scripts
- **Full Cleanup**: Removes all connections, listeners, and references
- **No Trace Remaining**: ScreenGui, toggle targets, lock listeners, theme listeners all cleared
- **Smooth Fade Out**: Beautiful animation before destruction
- **Console Confirmation**: Logs destruction confirmation message

### 🧹 What Gets Cleaned Up
- ScreenGui host (all UI elements)
- Toggle target references
- Lock group listeners
- Theme change listeners
- All event connections

### 📊 Technical Details
```lua
RvrseUI.Version = {
  Major = 2,
  Minor = 1,
  Patch = 2,
  Build = "20250929",
  Full = "2.1.2",
  Hash = "C3F8A6E9",
  Channel = "Stable"
}

-- Destroy UI completely
Window:Destroy()
-- Output: [RvrseUI] Interface destroyed - All traces removed
```

### 📥 Download
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()
```

---

## Version 2.1.1 "Aurora" - UI Control Refinements
**Release Date**: September 29, 2025
**Build**: 20250929
**Hash**: `B9E4D7F1`
**Channel**: Stable

### ✨ New Features
- **Close Button**: Professional X button in top right corner of header
- **Repositioned Version Badge**: Now in bottom left corner with accent border
- **Enhanced UX**: Both controls have hover tooltips and smooth animations

### 🎨 Improvements
- Version badge moved to bottom left for better visibility
- Close button with ripple animation and fade effect
- Version badge now has accent stroke border
- All controls maintain glassmorphic design language

### 📊 Technical Details
```lua
RvrseUI.Version = {
  Major = 2,
  Minor = 1,
  Patch = 1,
  Build = "20250929",
  Full = "2.1.1",
  Hash = "B9E4D7F1",
  Channel = "Stable"
}
```

### 📥 Download
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()
```

---

## Version 2.1.0 "Aurora" - Revolutionary Controls
**Release Date**: January 29, 2025
**Build**: 20250129
**Hash**: `A7F3E8C2`
**Channel**: Stable

### 🔔 Major Features
- **Notification Bell Toggle**: Global mute/unmute control with 🔔/🔕 icons
- **Mini Theme Switcher**: One-click theme toggle with 🌙/🌞 icons
- **Professional Tooltips**: Hover feedback on all header controls
- **Enhanced Glass Effects**: True 95% transparency with white tinting
- **Animated Glows**: Pulsing stroke effects on active elements
- **Version System**: Comprehensive versioning with hash verification

### ✨ Improvements
- Glass overlay now 95% transparent (up from 30%)
- Version badge is clickable with detailed info popup
- Theme switching triggers glass overlay update
- Notification bell has animated glow when enabled
- All header controls have hover tooltips

### 🐛 Bug Fixes
- Fixed `Enum.Font.GothamMono` → `Enum.Font.Code` (keybind font error)
- Improved keycode parser with whitespace handling
- Added debug helper function for development

### 📊 Technical Details
```lua
RvrseUI.Version = {
  Major = 2,
  Minor = 1,
  Patch = 0,
  Build = "20250129",
  Full = "2.1.0",
  Hash = "A7F3E8C2",
  Channel = "Stable"
}
```

### 📥 Download
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()
```

---

## Version 2.0.0 "Phoenix" - Complete Modern Redesign
**Release Date**: January 28, 2025
**Build**: 20250128
**Hash**: `F36F3A8`
**Channel**: Stable

### 🎨 Major Redesign
- Complete UI overhaul with modern glassmorphism
- Spring-based animation system (Smooth, Snappy, Bounce, Fast)
- Material ripple effects on buttons
- Mobile-first responsive design
- Modern indigo color palette (#6366F1)

### 🧩 New Components
- **Slider**: Draggable thumb with gradient fill
- **Enhanced Toggle**: iOS-style switch with spring animation
- **Improved Dropdown**: Hover states and smooth transitions
- **Better Keybind**: Interactive key capture
- **Animated Notifications**: Slide-in/fade-out effects

### 📱 Mobile Support
- Auto-detection of mobile/tablet devices
- Adaptive window sizing (380x520 mobile, 580x480 desktop)
- Touch-optimized inputs (44px minimum tap targets)
- Drag-to-move header support
- Floating mobile chip for UI re-open

### 🚀 Advanced Features
- LockGroup system for master/child controls
- Runtime theme switching
- Animated loading splash screen
- Version badge in header
- Drag-to-reposition windows

---

## Version History Summary

| Version | Date | Hash | Codename | Key Feature |
|---------|------|------|----------|-------------|
| 2.1.7 | 2025-09-30 | 08B730DF | Aurora | Unicode Icon System |
| 2.1.6 | 2025-09-30 | A8D3FBC5 | Aurora | Tab Overflow Fix |
| 2.1.5 | 2025-09-30 | F9D4E7B3 | Aurora | Critical Fixes + Lucide |
| 2.1.4 | 2025-09-29 | E8B3C9A2 | Aurora | UI Layout Polish |
| 2.1.3 | 2025-09-29 | D7A2E5F4 | Aurora | Global UI Control |
| 2.1.2 | 2025-09-29 | C3F8A6E9 | Aurora | Complete Destruction |
| 2.1.1 | 2025-09-29 | B9E4D7F1 | Aurora | UI Controls |
| 2.1.0 | 2025-01-29 | A7F3E8C2 | Aurora | Notification Controls |
| 2.0.0 | 2025-01-28 | F36F3A8 | Phoenix | Modern Redesign |

---

## Hash Verification

### How to Verify Your Version
```lua
local RvrseUI = loadstring(game:HttpGet("..."))()
local info = RvrseUI:GetVersionInfo()

print("Version:", info.Version)
print("Build:", info.Build)
print("Hash:", info.Hash)
print("Channel:", info.Channel)
```

### Expected Hashes
- **v2.1.7**: `08B730DF`
- **v2.1.6**: `A8D3FBC5`
- **v2.1.5**: `F9D4E7B3`
- **v2.1.4**: `E8B3C9A2`
- **v2.1.3**: `D7A2E5F4`
- **v2.1.2**: `C3F8A6E9`
- **v2.1.1**: `B9E4D7F1`
- **v2.1.0**: `A7F3E8C2`
- **v2.0.0**: `F36F3A8`

If your hash doesn't match, you may have:
- A modified/tampered version
- An outdated cached version
- A different release channel (Beta/Dev)

### Check for Updates
Visit: https://github.com/CoderRvrse/RvrseUI/releases

---

## Breaking Changes

### v2.1.0
- None (fully backward compatible)

### v2.0.0
- Complete API redesign from v1.x
- New naming: `CreateButton` → `CreateButton` (consistent `Create` prefix)
- Theme system restructured with new color tokens
- Removed: Label element (use Button with empty callback)
- Changed: Version from string to table structure

---

## Migration Guide

### From v1.x to v2.0+
```lua
-- Old (v1.x)
Section:AddButton("Text", callback)
Section:AddToggle("Text", state, callback)

-- New (v2.0+)
Section:CreateButton({ Text = "Text", Callback = callback })
Section:CreateToggle({ Text = "Text", State = state, OnChanged = callback })
```

---

## Support

- **Issues**: https://github.com/CoderRvrse/RvrseUI/issues
- **Discussions**: https://github.com/CoderRvrse/RvrseUI/discussions
- **Documentation**: See README.md and CLAUDE.md

---

**RvrseUI** - Modern. Professional. Lightweight.

MIT License | Created by Rvrse