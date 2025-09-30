# RvrseUI v2.1.5+ - Fixes Documentation

## Overview

This document covers all the fixes implemented to address theme switching, keybind system, and Lucide icon support issues.

---

## 🎨 Fix #1: Dark/Light Theme Switching

### Problem
The theme toggle pill (🌙/🌞) in the header wasn't updating UI elements when switching between Dark and Light themes. Elements remained in their original theme colors.

### Solution
Updated the theme toggle click handler to manually refresh ALL UI elements when theme changes:

**Updated Elements on Theme Switch:**
- Theme toggle button itself
- Glass overlay
- Root window
- Header
- Notification bell toggle
- Close button
- Body container
- All tabs (buttons, indicators, scrollbars)
- All tab icons (image-based)

**Code Location:** `RvrseUI.lua` lines ~798-856

**How It Works:**
```lua
themeToggle.MouseButton1Click:Connect(function()
	local newTheme = Theme.Current == "Dark" and "Light" or "Dark"
	Theme:Switch(newTheme)
	local newPal = Theme:Get()

	-- Update every UI element with new palette colors
	-- ...
end)
```

### Testing
1. Load the UI
2. Click the 🌙/🌞 pill in the top-right area of the header
3. Observe: All colors, icons, and elements update instantly

---

## ⌨️ Fix #2: UI Visibility Keybind System

### Problem
The keybind system for toggling UI visibility wasn't clearly documented, and users were unsure if it was working correctly.

### Solution
**The keybind system was already functional**, but we've verified and clarified its behavior:

**How It Works:**
- Global keybind set via `ToggleUIKeybind` in `CreateWindow()`
- Default key: `"K"` (can be string or `Enum.KeyCode`)
- Toggles visibility of ALL registered windows
- Can be changed at runtime using `RvrseUI.UI:BindToggleKey(key)`

**Code Location:** `RvrseUI.lua` lines 514-527, 546-547

**Usage:**
```lua
-- Set at window creation
local Window = RvrseUI:CreateWindow({
	Name = "My Script",
	ToggleUIKeybind = "K"  -- or Enum.KeyCode.K
})

-- Change at runtime
RvrseUI.UI:BindToggleKey(Enum.KeyCode.H)
```

### Testing
1. Load the UI with default keybind (K)
2. Press K → UI hides
3. Press K again → UI shows
4. Use a keybind element to change the key
5. Press new key → UI toggles with new keybind

---

## 🚫 Fix #3: Theme Control Restricted to Topbar Pill Only

### Problem
The `WindowAPI:SetTheme()` method allowed programmatic theme changes, which could conflict with the topbar pill toggle and cause confusion.

### Solution
**Removed `WindowAPI:SetTheme()` method entirely.**

**Rationale:**
- Theme should be controlled by the user via the UI pill only
- Prevents script conflicts with user preferences
- Simplifies the API and reduces confusion
- Theme pill is the single source of truth

**Code Location:** `RvrseUI.lua` line 1014

**Before:**
```lua
function WindowAPI:SetTheme(mode)
	Theme:Switch(mode)
	pal = Theme:Get()
end
```

**After:**
```lua
-- SetTheme removed - theme switching is now exclusively controlled by the topbar pill toggle
```

### Impact
**Breaking Change:** If your code used `Window:SetTheme()`, you must remove those calls. Theme is now controlled exclusively via the topbar UI pill.

---

## 🎨 Fix #4: Lucide Icon Support

### Problem
RvrseUI only supported emoji strings and Roblox asset IDs. There was no integration with the Lucide icon library (like Rayfield has).

### Solution
**Added full Lucide icon support with 80+ common icons.**

**Features:**
- ✓ Lucide icon names (string): `"home"`, `"settings"`, `"shield"`, etc.
- ✓ Roblox asset IDs (number): `4483362458`
- ✓ Emoji/text (string): `"🎮"`, `"⚙️"`
- ✓ Auto-detection of icon type
- ✓ Proper theming (icons change color with theme)

**Code Location:** `RvrseUI.lua` lines 123-250

**Supported Icon Formats:**
1. **Lucide icon name** (string): `Icon = "home"`
2. **Roblox asset ID** (number): `Icon = 4483362458`
3. **Emoji/text** (string): `Icon = "🎮"`

**How It Works:**
```lua
local function resolveLucideIcon(icon)
	-- Numbers → Roblox asset ID
	if typeof(icon) == "number" then
		return "rbxassetid://" .. icon, "image"
	end

	-- Strings → Check Lucide library
	if typeof(icon) == "string" then
		local iconName = icon:lower()
		if LucideIcons[iconName] then
			return LucideIcons[iconName], "image"  -- Lucide icon
		end
		return icon, "text"  -- Emoji/text
	end
end
```

### Usage Examples

#### Window Icon
```lua
-- Lucide icon
local Window = RvrseUI:CreateWindow({ Icon = "settings" })

-- Roblox asset ID
local Window = RvrseUI:CreateWindow({ Icon = 4483362458 })

-- Emoji
local Window = RvrseUI:CreateWindow({ Icon = "🎮" })
```

#### Tab Icon
```lua
-- Lucide icon
local Tab = Window:CreateTab({ Title = "Main", Icon = "home" })

-- Roblox asset ID
local Tab = Window:CreateTab({ Title = "Main", Icon = 4483362458 })

-- Emoji
local Tab = Window:CreateTab({ Title = "Main", Icon = "⚙️" })
```

### Supported Lucide Icons (80+)

**Navigation & UI:**
- home, settings, menu, search, grid, layout, list
- chevron-right, chevron-left, chevron-down, chevron-up
- plus, minus, x, check

**Users & Social:**
- user, users, heart, star, bell, gift, award, trophy, crown

**Actions & Controls:**
- edit, trash, download, upload, play, pause, rewind, fast-forward
- skip-forward, skip-back, maximize, minimize, volume, volume-2, volume-x

**Security & Status:**
- lock, unlock, shield, eye, eye-off, alert-circle, alert-triangle, info

**Files & Data:**
- folder, file, code, database, hard-drive, server, cpu, package, box

**Media & Content:**
- camera, image, bookmark, calendar, clock, watch, timer, flag, tag

**Communication:**
- link, paperclip, at-sign, hash, command

**Nature & Weather:**
- sun, moon, cloud, umbrella, droplet, wind, feather

**Other:**
- compass, map, target, crosshair, aperture, terminal, bluetooth, wifi
- battery, power, plug, zap, activity, filter, sliders, percent, dollar-sign

**Full list:** See `LucideIcons` table in `RvrseUI.lua` lines 128-224

### Testing
1. Create a tab with Lucide icon: `Icon = "home"`
2. Create a tab with asset ID: `Icon = 4483362458`
3. Create a tab with emoji: `Icon = "🎮"`
4. Switch theme using the pill
5. Observe: All icons update colors correctly

---

## 📝 Summary of Changes

| Fix | Status | Breaking Change | Lines Changed |
|-----|--------|-----------------|---------------|
| Theme switching | ✅ Fixed | No | ~60 lines |
| Keybind system | ✅ Verified | No | 0 lines (already working) |
| Theme control restriction | ✅ Fixed | **Yes** | 4 lines removed |
| Lucide icon support | ✅ Added | No | ~130 lines added |

---

## 🔄 Migration Guide

### Breaking Change: Window:SetTheme() Removed

**Before (v2.1.4 and earlier):**
```lua
local Window = RvrseUI:CreateWindow({ Theme = "Dark" })

-- Programmatically change theme
Window:SetTheme("Light")
```

**After (v2.1.5+):**
```lua
local Window = RvrseUI:CreateWindow({ Theme = "Dark" })

-- Theme can ONLY be changed via the topbar pill toggle
-- User clicks 🌙/🌞 button to switch
```

**Why?**
- User control over theme preference
- Prevents script conflicts
- Single source of truth (the UI pill)
- Cleaner API

---

## 🧪 Testing Checklist

Use the provided `TEST_FIXES.lua` file to test all fixes:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_REPO/RvrseUI/main/TEST_FIXES.lua"))()
```

**Test Cases:**
- [ ] Theme switching works (all elements update)
- [ ] Press K to toggle UI visibility
- [ ] Change keybind via keybind element
- [ ] Lucide icons display correctly in tabs
- [ ] Roblox asset IDs display correctly in tabs
- [ ] Emojis display correctly in tabs
- [ ] Icons change color when theme switches
- [ ] Window icons work (Lucide/asset/emoji)
- [ ] Global visibility methods work (`SetVisibility`, `ToggleVisibility`)

---

## 📚 API Reference

### Theme System

**Theme Switching:**
- User-controlled via 🌙/🌞 pill in header
- No programmatic API (by design)
- Initial theme set in `CreateWindow({ Theme = "Dark" })`

### Keybind System

**Set Initial Keybind:**
```lua
local Window = RvrseUI:CreateWindow({
	ToggleUIKeybind = "K"  -- string or Enum.KeyCode
})
```

**Change Keybind at Runtime:**
```lua
RvrseUI.UI:BindToggleKey(Enum.KeyCode.H)
```

### Icon System

**Window Icon:**
```lua
local Window = RvrseUI:CreateWindow({
	Icon = "settings"    -- Lucide
	-- or
	Icon = 4483362458   -- Roblox asset ID
	-- or
	Icon = "🎮"          -- Emoji
})
```

**Tab Icon:**
```lua
local Tab = Window:CreateTab({
	Title = "Main",
	Icon = "home"       -- Lucide
	-- or
	Icon = 4483362458  -- Roblox asset ID
	-- or
	Icon = "⚙️"         -- Emoji
})
```

---

## 🐛 Known Issues

None. All reported issues have been resolved.

---

## 📞 Support

If you encounter any issues with these fixes:

1. Check the test script: `TEST_FIXES.lua`
2. Verify you're using v2.1.5 or later
3. Review this documentation
4. Report issues: https://github.com/CoderRvrse/RvrseUI/issues

---

**Last Updated:** 2025-09-30
**Version:** 2.1.5+
**Author:** Rvrse (with Claude Code)