# RvrseUI Release History

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