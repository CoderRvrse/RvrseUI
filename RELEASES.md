# RvrseUI Release History

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