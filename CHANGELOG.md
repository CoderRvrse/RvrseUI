# RvrseUI v3.0.1 Changelog

**Release Date**: October 10, 2025  
**Build**: 20251010  
**Hash**: `Q1W2E3R4`  
**Codename**: Configuration Hotfix

---

## 🎯 Summary

v3.0.1 delivers a focused hotfix for the configuration persistence pipeline. The Config module now initializes alongside State and Theme, restoring the debug logging hooks that guard save/load execution. This resolves the `attempt to call a nil value` failure seen when loading configurations immediately after window creation.

---

## 🔧 Fixes

- Ensured `Config:Init` runs during bootstrap so `dprintf` and module references are available before the first save/load call.
- Added a lightweight logger fallback so executors without debug mode still see meaningful messages.
- Refreshed README badges, build headers, and version metadata to match v3.0.1.

---

## 🔎 Validation

- Manual regression in a live executor: Save / Load / Delete configuration flows execute without stack traces.
- Verified auto-save debounce continues to function with the new initialization order.
- Confirmed version metadata aligns across `RvrseUI.lua`, `src/Version.lua`, `VERSION.json`, and documentation.

---

# Legacy Release Notes

## RvrseUI v2.3.1 Complete Changelog

**Release Date**: September 30, 2025
**Build**: 20250930
**Hash**: `8A4F6D3E`
**Codename**: Persistence+

---

## 🎯 Summary

v2.3.1 brings critical fixes and enhancements to the configuration system, UI elements, and documentation. This release focuses on improving user experience with folder-based configuration organization, fixing the dropdown menu, and repositioning the version badge.

---

## ✨ New Features

### 1. Configuration Folder Support

**Table Format with FolderName**

```lua
-- NEW: Table format with folder organization
local Window = RvrseUI:CreateWindow({
  ConfigurationSaving = {
    Enabled = true,
    FolderName = "BigHub",     -- Optional: Creates folder automatically
    FileName = "PlayerConfig"   -- Saved as: BigHub/PlayerConfig.json
  }
})

-- OLD: Boolean format (still supported)
local Window = RvrseUI:CreateWindow({
  ConfigurationSaving = true,
  FileName = "Config.json"
})
```

**Features**:
- Automatic folder creation via `makefolder()`
- Organize configs by hub/game
- Backward compatible with boolean format
- Files save to: `workspace/FolderName/FileName.json`

**Use Cases**:
- Multiple hubs/games: `"BloxFruits/Config"`, `"PetSim/Config"`
- Organized structure: `"Hubs/BigHub/Settings"`
- Clean workspace folder

---

## 🔧 Bug Fixes

### 1. Dropdown Menu Complete Rewrite

**Problem**: Dropdown was cycling through values like a button instead of showing a list

**Solution**: Complete rewrite to proper dropdown list

**Before**:
```
Click button → cycles to next value
[Button] "Option 1" → Click → "Option 2" → Click → "Option 3"
```

**After**:
```
Click button → shows dropdown list with all options
[Button "Option 1" ▼]
       ↓ (click)
┌─────────────┐
│ Option 1 ✓  │ ← highlighted
│ Option 2    │
│ Option 3    │
│ Option 4    │
│ Option 5    │
└─────────────┘
```

**New Features**:
- ✅ Real dropdown list with all options visible
- ✅ Arrow indicator: ▼ (closed) / ▲ (open)
- ✅ ScrollingFrame for many options (max 160px height)
- ✅ Selected option highlighted
- ✅ Hover effects on dropdown options
- ✅ Click outside dropdown to close
- ✅ Smooth animations
- ✅ Proper option selection UX

**Implementation**:
- ScrollingFrame with UIListLayout
- Each option is a clickable TextButton
- Dropdown list positioned below button
- ZIndex management for layering
- Input detection for outside clicks

---

### 2. Version Badge Position

**Problem**: Version badge was too large and not positioned well

**Solution**: Made smaller and repositioned

| Property | Before | After |
|----------|--------|-------|
| **Size** | 50x18 | 42x16 |
| **Position X** | 8 | -4 |
| **Position Y** | -26 | -20 |
| **Text Size** | 9px | 8px |
| **Border Radius** | 8px | 6px |

**Changes**:
- Smaller badge (42x16 instead of 50x18)
- More left/outside (-4 instead of 8)
- Lower down (-20 instead of -26)
- Smaller text (8px instead of 9px)
- Less obtrusive appearance

---

## 🔄 API Changes

### Configuration Methods

All configuration methods now support folder paths:

```lua
-- Save with folder
RvrseUI:SaveConfiguration()  -- Saves to FolderName/FileName.json

-- Load with folder
RvrseUI:LoadConfiguration()  -- Loads from FolderName/FileName.json

-- Delete with folder
RvrseUI:DeleteConfiguration()  -- Deletes FolderName/FileName.json

-- Check existence with folder
RvrseUI:ConfigurationExists()  -- Checks FolderName/FileName.json
```

### Dropdown Methods

Enhanced Refresh method:

```lua
-- Refresh dropdown with new values
Dropdown:Refresh({ "New", "Values", "List" })

-- Now properly rebuilds dropdown list with all options
```

---

## 📝 Documentation Updates

### README.md - Complete Overhaul

**Changes**:
- Updated to v2.3.1 throughout
- Removed outdated v2.2.0 references
- Added configuration folder examples
- Documented fixed dropdown
- Cleaner structure with navigation
- All code examples updated

**New Sections**:
- Quick Start with 3 examples
- Configuration System (3-step guide)
- All 12 elements documented
- Complete examples section
- Troubleshooting guide

**Removed**:
- Verbose descriptions
- Outdated version info
- Duplicate content
- Wall-of-text sections

---

## 🐛 Known Issues (None)

All known issues from v2.3.0 have been resolved:
- ✅ Dropdown now works properly (FIXED)
- ✅ Version badge positioned correctly (FIXED)
- ✅ Configuration supports folders (ADDED)

---

## 🔄 Migration Guide

### From v2.3.0 to v2.3.1

**No breaking changes!** All v2.3.0 code works in v2.3.1.

**Optional: Update to new config format**

```lua
-- OLD (v2.3.0)
local Window = RvrseUI:CreateWindow({
  ConfigurationSaving = true,
  FileName = "MyConfig.json"
})

-- NEW (v2.3.1) - Recommended
local Window = RvrseUI:CreateWindow({
  ConfigurationSaving = {
    Enabled = true,
    FolderName = "MyHub",    -- NEW: Folder support
    FileName = "MyConfig"     -- No .json needed
  }
})
```

**Both formats work!** Choose based on your needs:
- Simple scripts: Use boolean format
- Multiple hubs: Use table format with FolderName

---

## 📦 File Changes

### Modified Files

1. **RvrseUI.lua** (+350 lines)
   - Added folder support to SaveConfiguration
   - Added folder support to LoadConfiguration
   - Added folder support to DeleteConfiguration
   - Added folder support to ConfigurationExists
   - Complete dropdown rewrite
   - Version badge repositioning
   - Version updated to 2.3.1

2. **VERSION.json** (+25 lines)
   - Version updated to 2.3.1
   - Hash updated to 8A4F6D3E
   - Changelog added for v2.3.1

3. **RELEASES.md** (+95 lines)
   - v2.3.1 release notes added
   - Detailed dropdown fix documentation
   - Configuration folder examples

4. **README.md** (Complete rewrite)
   - 634 lines of clean content
   - Updated to v2.3.1
   - All examples updated
   - Better structure

### New Files

None - All changes were updates to existing files

---

## 🧪 Testing

### Tested Scenarios

✅ **Configuration Folders**:
- Folder creation with makefolder()
- Save to folder path
- Load from folder path
- Delete from folder path
- Backward compatibility with boolean format

✅ **Dropdown Menu**:
- Open/close dropdown list
- Select option from list
- Scroll through many options
- Click outside to close
- Hover effects
- Selected highlighting
- Arrow indicator toggling

✅ **Version Badge**:
- Smaller size display
- Position (-4, -20)
- Text readability at 8px
- Hover tooltip functionality

---

## 💡 Examples

### Configuration with Folders

```lua
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

-- Organize by hub
local Window = RvrseUI:CreateWindow({
  Name = "Blox Fruits Script",
  ConfigurationSaving = {
    Enabled = true,
    FolderName = "BloxFruits",   -- Creates BloxFruits folder
    FileName = "Settings"         -- Saves as BloxFruits/Settings.json
  }
})

-- Create elements with Flags
local Tab = Window:CreateTab({ Title = "Main" })
local Section = Tab:CreateSection("Settings")

Section:CreateSlider({
  Text = "Farm Speed",
  Min = 1,
  Max = 10,
  Default = 5,
  Flag = "FarmSpeed",
  OnChanged = function(speed)
    _G.FarmSpeed = speed
  end
})

-- Load config (from BloxFruits/Settings.json)
RvrseUI:LoadConfiguration()
```

### Using New Dropdown

```lua
Section:CreateDropdown({
  Text = "Farm Mode",
  Values = {
    "Fast",
    "Normal",
    "Slow",
    "Very Slow",
    "Ultra Slow",
    "Custom"
  },
  Default = "Normal",
  Flag = "FarmMode",
  OnChanged = function(mode)
    print("Farm mode:", mode)
  end
})

-- Now clicking shows a proper dropdown list!
-- Can scroll if more than 5 options
-- Click any option to select
```

---

## 🎯 Upgrade Instructions

### Quick Update

```lua
-- Simply update the loadstring URL (it auto-updates)
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()
```

### Verify Version

```lua
print(RvrseUI.Version.Full)  -- Should print: 2.3.1
print(RvrseUI.Version.Hash)  -- Should print: 8A4F6D3E
```

### Optional: Migrate to Folder Config

```lua
-- If you want to use folders (optional)
ConfigurationSaving = {
  Enabled = true,
  FolderName = "YourHub",     -- Add this
  FileName = "YourConfig"     -- Update this
}
```

---

## 📊 Statistics

### Code Changes
- **Files Modified**: 4 (RvrseUI.lua, VERSION.json, RELEASES.md, README.md)
- **Lines Added**: +470
- **Lines Removed**: -27
- **Net Change**: +443 lines

### Features Added
- Configuration folder support
- Dropdown list UI
- Version badge repositioning

### Bugs Fixed
- Dropdown cycling issue (replaced with proper list)
- Version badge positioning (smaller and better placed)

---

## 🙏 Credits

**Developer**: CoderRvrse
**Assistant**: Claude Code
**Version**: 2.3.1 "Persistence+"
**Release**: September 30, 2025

---

## 🔗 Links

- **Repository**: https://github.com/CoderRvrse/RvrseUI
- **Raw Script**: https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua
- **Issues**: https://github.com/CoderRvrse/RvrseUI/issues
- **Documentation**: [README.md](README.md), [CONFIG_GUIDE.md](CONFIG_GUIDE.md)

---

**End of v2.3.1 Changelog**
