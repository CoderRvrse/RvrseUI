# RvrseUI Dropdown - THE CORRECT WAY

**CRITICAL:** This document defines the ONE CORRECT way to create dropdowns in RvrseUI.

---

## ⚠️ THE ONLY PARAMETERS TO USE

### For SINGLE-Select Dropdown:
```lua
Section:CreateDropdown({
    Text = "Select Weapon",
    Options = {"Sword", "Bow", "Staff"},
    CurrentOption = {"Sword"},           -- Pre-select (always use table format!)
    MultipleOptions = false,             -- Single-select (this is the default)
    Flag = "WeaponChoice",
    OnChanged = function(value)
        print("Selected:", value)        -- Returns single string value
    end
})
```

### For MULTI-Select Dropdown:
```lua
Section:CreateDropdown({
    Text = "Select Items",
    Options = {"Item1", "Item2", "Item3"},
    CurrentOption = {"Item1", "Item2"},  -- Pre-select multiple (always table!)
    MultipleOptions = true,              -- ✅ THIS ENABLES MULTI-SELECT!
    Flag = "SelectedItems",
    OnChanged = function(selected)
        -- selected is an ARRAY: {"Item1", "Item3"}
        print("Selected:", table.concat(selected, ", "))
    end
})
```

---

## 🔑 Key Rules

### 1. Parameter Name: `MultipleOptions`
- ✅ **CORRECT:** `MultipleOptions = true` (for multi-select)
- ✅ **CORRECT:** `MultipleOptions = false` (for single-select, but optional since false is default)
- ⚠️ **ALSO WORKS (but not recommended):** `MultiSelect = true` (legacy RvrseUI alias)

**Use `MultipleOptions` for consistency with Rayfield API!**

### 2. Options List: `Options`
- ✅ **CORRECT:** `Options = {"A", "B", "C"}`
- ⚠️ **ALSO WORKS (but not recommended):** `Values = {"A", "B", "C"}` (legacy alias)

**Use `Options` for consistency with Rayfield API!**

### 3. CurrentOption Format
- ✅ **ALWAYS use table format:** `CurrentOption = {"Option1"}`
- ✅ **For multi-select:** `CurrentOption = {"Option1", "Option2"}`
- ❌ **NEVER use string:** `CurrentOption = "Option1"` (this will break!)

**Rayfield uses table format `{"value"}` - we maintain compatibility!**

### 4. Callback Parameter
- **Single-select:** Callback receives a **single string value**
  ```lua
  OnChanged = function(value)
      print(value)  -- "Sword"
  end
  ```

- **Multi-select:** Callback receives an **array of strings**
  ```lua
  OnChanged = function(selected)
      print(table.concat(selected, ", "))  -- "Item1, Item3"
  end
  ```

---

## 🚫 Common Mistakes

### ❌ WRONG: Mixing parameter names
```lua
-- DON'T DO THIS!
Section:CreateDropdown({
    Values = {...},           -- ❌ Use Options instead
    MultiSelect = true,       -- ❌ Use MultipleOptions instead
})
```

### ❌ WRONG: Using string for CurrentOption
```lua
-- DON'T DO THIS!
Section:CreateDropdown({
    CurrentOption = "Sword",  -- ❌ Must be table: {"Sword"}
})
```

### ❌ WRONG: Forgetting MultipleOptions for multi-select
```lua
-- DON'T DO THIS!
Section:CreateDropdown({
    Options = {"A", "B", "C"},
    -- ❌ Missing MultipleOptions = true!
    -- This will be single-select by default!
})
```

---

## ✅ COMPLETE EXAMPLES

### Example 1: Single-Select Weapon Dropdown
```lua
local weaponDropdown = Section:CreateDropdown({
    Text = "Choose Weapon",
    Options = {"Sword", "Bow", "Staff", "Axe"},
    CurrentOption = {"Sword"},
    MultipleOptions = false,  -- Single-select (optional, false is default)
    Flag = "PlayerWeapon",
    OnChanged = function(weapon)
        print("Equipped:", weapon)  -- "Sword"
        equipWeapon(weapon)
    end
})

-- Later: Change selection programmatically
weaponDropdown:Set("Bow")
```

### Example 2: Multi-Select Game Modes
```lua
local modesDropdown = Section:CreateDropdown({
    Text = "Select Game Modes",
    Options = {"TDM", "CTF", "King of the Hill", "FFA"},
    CurrentOption = {"TDM", "FFA"},
    MultipleOptions = true,  -- ✅ MULTI-SELECT ENABLED
    Flag = "GameModes",
    OnChanged = function(modes)
        print("Modes:", table.concat(modes, ", "))  -- "TDM, FFA, CTF"

        -- Loop through selected modes
        for _, mode in ipairs(modes) do
            print("Selected mode:", mode)
        end
    end
})

-- API Methods for multi-select
modesDropdown:SelectAll()         -- Select all options
modesDropdown:ClearAll()          -- Clear all selections
modesDropdown:Set({"TDM", "CTF"}) -- Set specific selections
```

### Example 3: Dynamic Options Refresh
```lua
local playerDropdown = Section:CreateDropdown({
    Text = "Select Player",
    Options = {},  -- Start empty
    MultipleOptions = false,
    Flag = "TargetPlayer"
})

-- Update options when players join/leave
game.Players.PlayerAdded:Connect(function()
    local playerNames = {}
    for _, player in ipairs(game.Players:GetPlayers()) do
        table.insert(playerNames, player.Name)
    end
    playerDropdown:Refresh(playerNames)
end)
```

---

## 🔄 Rayfield Compatibility

**RvrseUI is 100% compatible with Rayfield dropdown syntax!**

This Rayfield code works as-is in RvrseUI:

```lua
-- Rayfield code (no changes needed!)
local Dropdown = Tab:CreateDropdown({
   Name = "Dropdown Example",          -- RvrseUI uses "Text" but accepts "Name"
   Options = {"Option 1","Option 2"},  -- ✅ Supported
   CurrentOption = {"Option 1"},       -- ✅ Supported
   MultipleOptions = false,            -- ✅ Supported
   Flag = "Dropdown1",
   Callback = function(Options)        -- ✅ Supported (called "OnChanged" in RvrseUI)
      print(Options[1])
   end,
})

-- All Rayfield methods work
Dropdown:Refresh({"New1", "New2"})
Dropdown:Set({"Option 2"})
print(Dropdown.CurrentOption[1])
```

**Just change `loadstring()` URL and you're done!**

---

## 📊 Parameter Reference Table

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `Text` | string | ✅ Yes | - | Dropdown label |
| `Options` | table | ✅ Yes | `{}` | List of options |
| `CurrentOption` | table | ❌ No | `{}` | Pre-selected options (always table!) |
| `MultipleOptions` | boolean | ❌ No | `false` | Enable multi-select mode |
| `Flag` | string | ⚠️ Recommended | `nil` | Save/load identifier |
| `OnChanged` | function | ⚠️ Recommended | `nil` | Callback when selection changes |
| `MaxHeight` | number | ❌ No | `240` | Max dropdown menu height |
| `PlaceholderText` | string | ❌ No | `"Select"` | Placeholder when nothing selected |
| `Overlay` | boolean | ❌ No | `true` | Use overlay layer (recommended) |

**Legacy aliases (not recommended but supported):**
- `Values` → Use `Options` instead
- `MultiSelect` → Use `MultipleOptions` instead
- `Name` → Use `Text` instead (Rayfield compatibility)
- `Callback` → Use `OnChanged` instead (Rayfield compatibility)

---

## 🐛 Troubleshooting

### Issue: "Multi-select not working, only selecting one item"
**Solution:** You forgot `MultipleOptions = true`

### Issue: "CurrentOption not working, nothing pre-selected"
**Solution:** Use table format: `CurrentOption = {"Value"}` not `CurrentOption = "Value"`

### Issue: "Callback receives table for single-select"
**Solution:** Set `MultipleOptions = false` (or remove it, false is default)

### Issue: "Options not showing up"
**Solution:** Ensure `Options` is a table of strings: `Options = {"A", "B", "C"}`

---

## ✅ Quick Checklist

Before you create a dropdown, verify:

- [ ] Using `Options` parameter (not `Values`)
- [ ] Using `MultipleOptions` parameter (not `MultiSelect`)
- [ ] `CurrentOption` is a **table** (not string)
- [ ] `MultipleOptions = true` if you want multi-select
- [ ] Callback handles correct type (string for single, array for multi)
- [ ] Added `Flag` parameter for save/load functionality

---

**Last Updated:** 2025-10-18 (v4.0.4)

**See Also:**
- [README.md](README.md) - Full user documentation
- [DEV_NOTES.md](DEV_NOTES.md) - Developer notes and changelog
