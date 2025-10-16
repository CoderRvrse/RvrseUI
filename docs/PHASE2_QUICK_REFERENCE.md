# Phase 2 Quick Reference Card

## 🎨 Advanced ColorPicker

### Basic Usage
```lua
local picker = Section:CreateColorPicker({
  Text = "Color",
  Default = Color3.fromRGB(88, 101, 242),
  Advanced = true,  -- RGB/HSV/Hex panel
  Flag = "MyColor",
  OnChanged = function(color) end
})
```

### Methods
```lua
picker:Set(Color3.new(1, 0, 0))    -- Update color
local c = picker:Get()             -- Get Color3
picker:SetVisible(false)           -- Hide
```

---

## 📋 Dropdown Multi-Select

### Rayfield API (100% Compatible)
```lua
local dd = Section:CreateDropdown({
  Text = "Options",
  Options = {"A", "B", "C"},           -- Rayfield: Options
  CurrentOption = {"A", "B"},          -- Pre-select (table)
  MultipleOptions = true,              -- Rayfield: MultipleOptions
  Callback = function(Options)         -- Parameter: Options (table)
    print(Options[1])                  -- Access first item
  end
})
```

### RvrseUI API (Also Works)
```lua
local dd = Section:CreateDropdown({
  Text = "Options",
  Values = {"A", "B", "C"},            -- RvrseUI: Values
  MultiSelect = true,                  -- RvrseUI: MultiSelect
  OnChanged = function(selected)       -- Parameter: selected (table)
    print(#selected)                   -- Count items
  end
})
```

### Methods
```lua
dd:Set({"A", "C"})                     -- Update selection
dd:Get()                               -- Returns {"A", "C"}
dd:Refresh({"X", "Y", "Z"})            -- Update options
dd:SelectAll()                         -- Select all (multi-select)
dd:ClearAll()                          -- Clear all (multi-select)
dd:SetOpen(true)                       -- Open dropdown
print(dd.CurrentOption[1])             -- Property access
```

---

## 🔄 Migration Guide

### From Rayfield → RvrseUI
**No changes needed!** Just replace the library:
```lua
-- Change this:
local Rayfield = loadstring(...)()
local Window = Rayfield:CreateWindow(...)

-- To this:
local RvrseUI = loadstring(...)()
local Window = RvrseUI:CreateWindow(...)

-- All Rayfield dropdown code works as-is! ✅
```

---

## 💡 Examples

### Multi-Select Weapons
```lua
local weapons = Section:CreateDropdown({
  Text = "Equip Weapons",
  Options = {"Sword", "Bow", "Staff", "Axe", "Dagger"},
  CurrentOption = {"Sword", "Bow"},  -- Start with 2
  MultipleOptions = true,
  Callback = function(equipped)
    game.ReplicatedStorage.EquipWeapons:FireServer(equipped)
  end
})

-- Later: Equip all weapons
weapons:SelectAll()

-- Or equip specific set
weapons:Set({"Sword", "Dagger"})
```

### Single-Select Difficulty
```lua
local difficulty = Section:CreateDropdown({
  Text = "Game Difficulty",
  Options = {"Easy", "Normal", "Hard", "Expert"},
  CurrentOption = {"Normal"},  -- Default to Normal
  MultipleOptions = false,
  Callback = function(Options)
    local selected = Options[1]
    game.ReplicatedStorage.SetDifficulty:FireServer(selected)
  end
})
```

### Theme Color Picker
```lua
local theme = Section:CreateColorPicker({
  Text = "UI Theme",
  Default = Color3.fromRGB(88, 101, 242),  -- Discord Blurple
  Advanced = true,
  Flag = "ThemeColor",
  OnChanged = function(color)
    -- Update all UI elements
    for _, element in pairs(UIElements) do
      element.BackgroundColor3 = color
    end
  end
})
```

---

## ⚙️ Configuration Persistence

Both elements support **automatic saving** via Flags:

```lua
-- This dropdown saves/loads automatically
CreateDropdown({
  Text = "Auto-Save Example",
  Options = {"A", "B", "C"},
  CurrentOption = {"A"},
  Flag = "MyDropdown",  -- Enables auto-save
  MultipleOptions = true
})

-- Values persist across sessions! 🎉
```

---

## 🐛 Troubleshooting

### ColorPicker panel not showing?
- Ensure `Advanced = true` is set
- Check if overlay layer exists
- Try clicking the preview circle

### Dropdown multi-select not working?
- Verify `MultipleOptions = true` or `MultiSelect = true`
- Check if `CurrentOption` is a table (not a string)
- Ensure callback receives table parameter

### CurrentOption property is empty?
```lua
-- ❌ Wrong (immediately after creation)
local dd = Section:CreateDropdown({...})
print(dd.CurrentOption)  -- May be empty!

-- ✅ Correct (check in callback or after Set)
dd:Set({"Option 1"})
print(dd.CurrentOption)  -- {"Option 1"}
```

---

## 📚 Full Documentation
See [PHASE2_COMPLETION.md](./PHASE2_COMPLETION.md) for complete details.

---

**Quick Links:**
- 🎨 ColorPicker: [src/Elements/ColorPicker.lua](./src/Elements/ColorPicker.lua)
- 📋 Dropdown: [src/Elements/Dropdown.lua](./src/Elements/Dropdown.lua)
- 🧪 Tests: [-- ⚠️ Development only - Use for testing.lua](./-- ⚠️ Development only - Use for testing.lua)
- 📦 Build: [RvrseUI.lua](./RvrseUI.lua) (228 KB)
