# Lucide Icons Integration Guide

**Version:** 4.3.0
**Added:** 2025-10-18
**Icons Available:** 500+
**Website:** https://lucide.dev/icons

---

## 📖 Overview

RvrseUI now supports **Lucide icons** - a beautiful, consistent icon library with 500+ professionally designed icons. Use them in any UI element via the `lucide://` protocol.

## 🎯 Quick Start

```lua
local Window = RvrseUI:CreateWindow({
    Title = "My Window",
    Icon = "lucide://home"  -- 🏠 Renders Lucide sprite (Unicode fallback if missing)
})

local Tab = Window:CreateTab({
    Title = "Settings",
    Icon = "lucide://settings"  -- ⚙ Sprite with themed tint
})

Section:CreateButton({
    Text = "Download",
    Icon = "lucide://download",  -- ⬇ Sprite lane reserved in buttons
    Callback = function()
        print("Downloading...")
    end
})
```

## 🔍 How It Works

### Icon Resolution Chain

When you use `Icon = "lucide://home"`, RvrseUI resolves it in this order:

1. **Check LucideIcons.AssetMap** - User-uploaded Roblox assets (if configured)
2. **Check LucideIcons.UnicodeFallbacks** - Built-in Unicode mappings (100+ icons)
3. **Display icon name as text** - Fallback if no mapping exists

### Why Unicode Fallbacks?

Roblox **does not support SVG rendering** natively. Since Lucide icons are SVG-based, we provide Unicode emoji/symbol equivalents for compatibility.

**Pros:**
- ✅ Works immediately, no setup required
- ✅ 100+ common icons pre-mapped
- ✅ Zero performance impact
- ✅ Cross-platform compatible

**Cons:**
- ❌ Limited visual customization (uses system fonts)
- ❌ Not pixel-perfect to Lucide originals
- ❌ Some complex icons have no Unicode equivalent

## 🎨 Supported Icon Formats

RvrseUI supports **5 icon formats** (all work in all elements):

| Format | Example | Description |
|--------|---------|-------------|
| **Lucide** | `"lucide://home"` | Lucide icon (Unicode fallback or asset) |
| **Built-in Unicode** | `"icon://trophy"` | RvrseUI's 190+ Unicode library |
| **Direct Emoji** | `"🏠"` | Any emoji or Unicode character |
| **Roblox Asset URL** | `"rbxassetid://123"` | Direct Roblox image asset |
| **Asset ID Number** | `123456789` | Roblox asset ID as number |

## 📚 Common Lucide Icons

### Navigation & UI
```lua
"lucide://home"       -- 🏠 Home
"lucide://menu"       -- ☰ Menu
"lucide://search"     -- 🔍 Search
"lucide://settings"   -- ⚙ Settings
"lucide://x"          -- ✕ Close
"lucide://check"      -- ✓ Check
```

### Arrows
```lua
"lucide://arrow-up"      -- ↑
"lucide://arrow-down"    -- ↓
"lucide://arrow-left"    -- ←
"lucide://arrow-right"   -- →
"lucide://chevron-up"    -- ▲
"lucide://chevron-down"  -- ▼
```

### Actions
```lua
"lucide://plus"       -- +
"lucide://minus"      -- -
"lucide://edit"       -- ✎
"lucide://trash"      -- 🗑
"lucide://save"       -- 💾
"lucide://download"   -- ⬇
"lucide://upload"     -- ⬆
"lucide://refresh-cw" -- ↻
```

### Status
```lua
"lucide://alert-triangle" -- ⚠ Warning
"lucide://info"           -- ℹ Info
"lucide://check-circle"   -- ✓ Success
"lucide://x-circle"       -- ✕ Error
```

### User & Social
```lua
"lucide://user"           -- 👤 User
"lucide://users"          -- 👥 Users
"lucide://message-circle" -- 💬 Message
"lucide://mail"           -- ✉ Mail
```

### Objects
```lua
"lucide://lock"           -- 🔒 Lock
"lucide://unlock"         -- 🔓 Unlock
"lucide://key"            -- 🔑 Key
"lucide://shield"         -- 🛡 Shield
"lucide://heart"          -- ❤ Heart
"lucide://star"           -- ⭐ Star
```

**See full list:** https://lucide.dev/icons (500+ icons available)

## 🚀 Advanced: Custom Asset Mapping

For **pixel-perfect icons**, upload Lucide SVGs as Roblox ImageAssets:

### Step 1: Convert SVG to PNG
1. Go to https://lucide.dev/icons
2. Download the icon as SVG
3. Convert to PNG using: https://cloudconvert.com/svg-to-png
4. Recommended size: 512x512 or 1024x1024

### Step 2: Upload to Roblox
1. Open Roblox Studio
2. Go to View → Asset Manager
3. Click "Import Asset"
4. Upload your PNG file
5. Get the **Asset ID** (e.g., `123456789`)

### Step 3: Map in RvrseUI
Edit `src/LucideIcons.lua`:

```lua
LucideIcons.AssetMap = {
    ["home"] = 123456789,      -- Your uploaded home icon
    ["settings"] = 987654321,  -- Your uploaded settings icon
    ["arrow-right"] = 555444333,
    -- Add more...
}
```

### Step 4: Rebuild
```bash
node build.js
```

Now `"lucide://home"` will use your custom asset instead of Unicode fallback!

## 📝 Examples

### Window with Lucide Icons
```lua
local Window = RvrseUI:CreateWindow({
    Title = "My Game Hub",
    Icon = "lucide://gamepad",
    Theme = "Dark"
})

local HomeTab = Window:CreateTab({
    Title = "Home",
    Icon = "lucide://home"
})

local SettingsTab = Window:CreateTab({
    Title = "Settings",
    Icon = "lucide://settings"
})
```

### Buttons with Status Icons
```lua
Section:CreateButton({
    Text = "Success",
    Icon = "lucide://check-circle",
    Callback = function()
        RvrseUI:Notify("lucide://check-circle", "Success!", 2)
    end
})

Section:CreateButton({
    Text = "Warning",
    Icon = "lucide://alert-triangle",
    Callback = function()
        RvrseUI:Notify("lucide://alert-triangle", "Warning!", 2)
    end
})

Section:CreateButton({
    Text = "Error",
    Icon = "lucide://x-circle",
    Callback = function()
        RvrseUI:Notify("lucide://x-circle", "Error!", 2)
    end
})
```

### Toggles with Action Icons
```lua
Section:CreateToggle({
    Text = "Enable Notifications",
    Icon = "lucide://bell",
    Default = true,
    Callback = function(value)
        print("Notifications:", value)
    end
})

Section:CreateToggle({
    Text = "Auto-Save",
    Icon = "lucide://save",
    Default = false,
    Callback = function(value)
        print("Auto-save:", value)
    end
})
```

### Dropdown with Direction Icon
```lua
Section:CreateDropdown({
    Text = "Select Server",
    Icon = "lucide://globe",
    Options = {"NA East", "NA West", "EU", "Asia"},
    Default = "NA East",
    Callback = function(value)
        print("Server:", value)
    end
})
```

## 🔧 Technical Details

### Module Architecture
- **LucideIcons.lua** (287 lines) - Icon resolution system
- **Icons.lua** (updated) - Added `lucide://` protocol support
- **Dependencies:** HttpService (for future SVG fetching)

### Icon Resolution Logic
```lua
-- In Icons:Resolve()
local lucideName = icon:match("^lucide://(.+)")
if lucideName and deps.LucideIcons then
    local value, type = deps.LucideIcons:Get(lucideName)
    -- Returns: (assetID, "image") or (unicode, "text")
end
```

### Unicode Fallback Table
```lua
LucideIcons.UnicodeFallbacks = {
    ["home"] = "🏠",
    ["settings"] = "⚙",
    ["arrow-right"] = "→",
    -- 100+ more...
}
```

## 📊 Statistics

- **Total Lucide Icons:** 500+
- **Unicode Fallbacks:** 100+ pre-mapped
- **Module Size:** 287 lines
- **Compiled Size:** +106 KB (272 KB total)
- **Performance:** Zero runtime cost (direct table lookup)

## 🧪 Testing

### Quick Test
```lua
-- Load simple test
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/examples/test-lucide-simple.lua"
))()
```

### Comprehensive Demo
```lua
-- Load full demo (300+ lines)
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/examples/test-lucide-icons.lua"
))()
```

## ❓ FAQ

**Q: Why not render SVGs directly?**
A: Roblox doesn't support SVG rendering. We use Unicode fallbacks for maximum compatibility.

**Q: Can I use any Lucide icon?**
A: Yes! All 500+ icons work. Icons without Unicode fallbacks will display as text.

**Q: How do I add more Unicode fallbacks?**
A: Edit `src/LucideIcons.lua` → `LucideIcons.UnicodeFallbacks` table, then rebuild.

**Q: Do Lucide icons work in notifications?**
A: Yes! All icon formats work in `RvrseUI:Notify()`.

**Q: Can I mix icon formats?**
A: Yes! Use `lucide://`, `icon://`, emojis, and asset IDs freely.

**Q: What happens if an icon doesn't exist?**
A: It displays the icon name as text (e.g., "my-icon" if no fallback).

## 🔗 Resources

- **Lucide Website:** https://lucide.dev/icons
- **Icon Browser:** https://lucide.dev/icons (search & filter)
- **Test Scripts:**
  - [test-lucide-simple.lua](../examples/test-lucide-simple.lua)
  - [test-lucide-icons.lua](../examples/test-lucide-icons.lua)
- **Source Code:**
  - [src/LucideIcons.lua](../src/LucideIcons.lua)
  - [src/Icons.lua](../src/Icons.lua)

## 🎉 Summary

RvrseUI v4.3.0 brings **500+ Lucide icons** to your UI with a simple `lucide://` protocol:

✅ **Easy to use** - Just add `Icon = "lucide://name"`
✅ **Zero setup** - Works immediately with Unicode fallbacks
✅ **Fully compatible** - All elements, all themes, all platforms
✅ **Extensible** - Upload custom assets for pixel-perfect icons
✅ **Well documented** - Complete examples and guides

**Happy icon hunting!** 🎨
