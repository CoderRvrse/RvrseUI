# RvrseUI v2.1.5 "Aurora" - Critical Fixes Release

**Release Date:** September 30, 2025
**Build:** 20250930
**Hash:** `F9D4E7B3`
**Channel:** Stable

---

## 🔧 Critical Fixes

### 1. **Theme Switching System - FIXED** ✅
**Problem:** Dark/Light theme toggle button (🌙/🌞) wasn't updating UI elements.

**Solution:**
- Complete theme refresh system implemented
- Updates ALL UI elements when theme changes:
  - Root window, header, body
  - All tabs (buttons, indicators, scrollbars)
  - All icons (proper color theming)
  - Control buttons (close, bell, theme pill)
  - Glass overlay effect

**Impact:** Theme switching now works perfectly with instant visual feedback across the entire UI.

---

### 2. **UI Visibility Keybind - VERIFIED** ✅
**Status:** Already working correctly, now properly documented.

**Features:**
- Global keybind set via `ToggleUIKeybind` in `CreateWindow()`
- Default: `"K"` key
- Supports string (`"K"`) or `Enum.KeyCode.K` format
- Can be changed at runtime via `RvrseUI.UI:BindToggleKey(key)`
- Works with all registered windows

**Usage:**
```lua
-- Set initial keybind
local Window = RvrseUI:CreateWindow({
	ToggleUIKeybind = "K"
})

-- Change at runtime
RvrseUI.UI:BindToggleKey(Enum.KeyCode.H)
```

---

### 3. **Theme Control Restriction - ENFORCED** 🚫
**Change:** Removed `WindowAPI:SetTheme()` method.

**Rationale:**
- Theme should only be controlled by the user via the topbar pill (🌙/🌞)
- Prevents script conflicts with user preferences
- Simplifies API and reduces confusion
- Single source of truth

**Breaking Change:**
```lua
-- ❌ NO LONGER WORKS
Window:SetTheme("Light")

-- ✅ USE THIS INSTEAD
-- User clicks the 🌙/🌞 pill in the header
```

---

### 4. **Lucide Icon Support - ADDED** ✨
**New Feature:** Full integration with Lucide icon library (80+ icons).

**Supported Formats:**
1. **Lucide icon names** (string): `Icon = "home"`
2. **Roblox asset IDs** (number): `Icon = 4483362458`
3. **Emoji/text** (string): `Icon = "🎮"`

**Where It Works:**
- Window icons (`CreateWindow({ Icon = "settings" })`)
- Tab icons (`CreateTab({ Icon = "home" })`)

**Examples:**
```lua
-- Lucide icon
local Tab1 = Window:CreateTab({ Title = "Home", Icon = "home" })

-- Roblox asset ID
local Tab2 = Window:CreateTab({ Title = "Settings", Icon = 4483362458 })

-- Emoji
local Tab3 = Window:CreateTab({ Title = "Profile", Icon = "🎮" })
```

**Available Lucide Icons:**
- **Navigation:** home, settings, menu, search, grid, layout, list
- **Actions:** edit, trash, download, upload, play, pause, rewind
- **Security:** lock, unlock, shield, eye, eye-off
- **Users:** user, users, heart, star, bell
- **Files:** folder, file, code, database, server
- **Media:** camera, image, calendar, clock, timer
- **Nature:** sun, moon, cloud, wind, droplet
- **And 50+ more!**

Full list: See `LucideIcons` table in `RvrseUI.lua` or `FIXES_DOCUMENTATION.md`

---

## 📊 Technical Details

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

**Lines Changed:**
- Theme system: ~60 lines modified
- Lucide icons: ~130 lines added
- SetTheme removal: 4 lines removed
- Total: ~194 lines changed

**Files Added:**
- `TEST_FIXES.lua` - Comprehensive test script
- `FIXES_DOCUMENTATION.md` - Detailed fix documentation
- `CHANGELOG_v2.1.5.md` - This file

---

## 🧪 Testing

**Use the test script:**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/TEST_FIXES.lua"))()
```

**Test Checklist:**
- [x] Theme switching (🌙/🌞 pill)
- [x] UI keybind toggle (default: K)
- [x] Lucide icons in tabs
- [x] Roblox asset IDs in tabs
- [x] Emoji icons in tabs
- [x] Icon color changes with theme
- [x] Global visibility methods

---

## 📥 Download

```lua
-- Latest stable version (v2.1.5)
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()
```

---

## 🔄 Migration from v2.1.4

### Breaking Changes

**1. WindowAPI:SetTheme() Removed**

```lua
-- ❌ OLD (v2.1.4)
Window:SetTheme("Light")

-- ✅ NEW (v2.1.5)
-- User clicks 🌙/🌞 pill in header
-- No programmatic API
```

### New Features

**1. Lucide Icons**

```lua
-- NEW: Use Lucide icon names
Window:CreateTab({ Title = "Home", Icon = "home" })
Window:CreateTab({ Title = "Settings", Icon = "settings" })

-- STILL WORKS: Roblox asset IDs
Window:CreateTab({ Title = "Settings", Icon = 4483362458 })

-- STILL WORKS: Emojis
Window:CreateTab({ Title = "Profile", Icon = "🎮" })
```

---

## 🐛 Bug Fixes

| Issue | Status | Fix |
|-------|--------|-----|
| Theme switching not updating UI | ✅ Fixed | Manual refresh of all elements |
| Keybind system unclear | ✅ Documented | Added clear documentation |
| Theme control conflicts | ✅ Fixed | Removed programmatic API |
| Limited icon support | ✅ Fixed | Added Lucide library |

---

## 📚 Documentation

- **Full Fix Documentation:** `FIXES_DOCUMENTATION.md`
- **Test Script:** `TEST_FIXES.lua`
- **API Reference:** `README.md`
- **Project Instructions:** `CLAUDE.md`

---

## 🙏 Credits

**Developer:** Rvrse
**Fixes by:** Claude Code (Anthropic)
**Lucide Icons:** Lucide + Latte Softworks
**Inspired by:** Rayfield UI Library

---

## 📞 Support

**Issues:** https://github.com/CoderRvrse/RvrseUI/issues
**Repository:** https://github.com/CoderRvrse/RvrseUI

---

## 🎉 What's Next?

Planned for future releases:
- [ ] Color picker element
- [ ] Textbox input element
- [ ] Multi-select dropdown
- [ ] More Lucide icons (200+ total)
- [ ] Custom theme builder API
- [ ] Persistent settings (save/load)

---

**RvrseUI v2.1.5** - Modern. Professional. Fixed. 🚀