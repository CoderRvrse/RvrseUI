# RvrseUI Dropdown - THE CORRECT WAY

**CRITICAL:** This document defines the ONE CORRECT way to create dropdowns in RvrseUI.

---

## ⚠️ THE ONLY PARAMETERS TO USE

### For SINGLE-Select Dropdown:
```lua
Section:CreateDropdown({
    Text = "Select Weapon",
    Values = {"Sword", "Bow", "Staff"},
    CurrentOption = {"Sword"},      -- Pre-select (always use table format!)
    MultiSelect = false,             -- Single-select (this is the default)
    Flag = "WeaponChoice",
    OnChanged = function(value)
        print("Selected:", value)   -- Returns single string value
    end
})
```

### For MULTI-Select Dropdown:
```lua
Section:CreateDropdown({
    Text = "Select Items",
    Values = {"Item1", "Item2", "Item3"},
    CurrentOption = {"Item1", "Item2"},  -- Pre-select multiple (always table!)
    MultiSelect = true,                   -- ✅ THIS ENABLES MULTI-SELECT!
    Flag = "SelectedItems",
    OnChanged = function(selected)
        -- selected is an ARRAY: {"Item1", "Item3"}
        print("Selected:", table.concat(selected, ", "))
    end
})
```

---

## 🔑 Key Rules

### 1. Parameter Name: `MultiSelect`
- ✅ **CORRECT:** `MultiSelect = true` (for multi-select)
- ✅ **CORRECT:** `MultiSelect = false` (for single-select, but optional since false is default)
- ⚠️ **ALSO WORKS:** `MultipleOptions = true` (Rayfield compatibility alias)

**Use `MultiSelect` - this is the RvrseUI native parameter!**

### 2. Options List: `Values`
- ✅ **CORRECT:** `Values = {"A", "B", "C"}`
- ⚠️ **ALSO WORKS:** `Options = {"A", "B", "C"}` (Rayfield compatibility alias)

**Use `Values` - this is the RvrseUI native parameter!**

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

### ❌ WRONG: Using Rayfield parameter names
```lua
-- DON'T DO THIS! (This works but uses Rayfield aliases)
Section:CreateDropdown({
    Options = {...},           -- ❌ Use Values instead
    MultipleOptions = true,    -- ❌ Use MultiSelect instead
})
```

### ❌ WRONG: Using string for CurrentOption
```lua
-- DON'T DO THIS!
Section:CreateDropdown({
    CurrentOption = "Sword",  -- ❌ Must be table: {"Sword"}
})
```

### ❌ WRONG: Forgetting MultiSelect for multi-select
```lua
-- DON'T DO THIS!
Section:CreateDropdown({
    Values = {"A", "B", "C"},
    -- ❌ Missing MultiSelect = true!
    -- This will be single-select by default!
})
```

---

## ✅ COMPLETE EXAMPLES

### Example 1: Single-Select Weapon Dropdown
```lua
local weaponDropdown = Section:CreateDropdown({
    Text = "Choose Weapon",
    Values = {"Sword", "Bow", "Staff", "Axe"},
    CurrentOption = {"Sword"},
    MultiSelect = false,  -- Single-select (optional, false is default)
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
    Values = {"TDM", "CTF", "King of the Hill", "FFA"},
    CurrentOption = {"TDM", "FFA"},
    MultiSelect = true,  -- ✅ MULTI-SELECT ENABLED
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
    Values = {},  -- Start empty
    MultiSelect = false,
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

**RvrseUI is 100% compatible with Rayfield.** Rayfield parameter names `Options` and `MultipleOptions` work as aliases, but we recommend using the native RvrseUI parameters (`Values` and `MultiSelect`) for consistency.

---

## 📊 Parameter Reference Table

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `Text` | string | ✅ Yes | - | Dropdown label |
| `Values` | table | ✅ Yes | `{}` | List of options |
| `CurrentOption` | table | ❌ No | `{}` | Pre-selected options (always table!) |
| `MultiSelect` | boolean | ❌ No | `false` | Enable multi-select mode |
| `Flag` | string | ⚠️ Recommended | `nil` | Save/load identifier |
| `OnChanged` | function | ⚠️ Recommended | `nil` | Callback when selection changes |
| `MaxHeight` | number | ❌ No | `240` | Max dropdown menu height |
| `PlaceholderText` | string | ❌ No | `"Select"` | Placeholder when nothing selected |
| `Overlay` | boolean | ❌ No | `true` | Use overlay layer (recommended) |

**Rayfield compatibility aliases (supported but not recommended):**
- `Options` → Native RvrseUI uses `Values`
- `MultipleOptions` → Native RvrseUI uses `MultiSelect`
- `Name` → Native RvrseUI uses `Text`
- `Callback` → Native RvrseUI uses `OnChanged`

---

## 🐛 Troubleshooting

### Issue: "Multi-select not working, only selecting one item"
**Solution:** You forgot `MultiSelect = true`

### Issue: "CurrentOption not working, nothing pre-selected"
**Solution:** Use table format: `CurrentOption = {"Value"}` not `CurrentOption = "Value"`

### Issue: "Callback receives table for single-select"
**Solution:** Set `MultiSelect = false` (or remove it, false is default)

### Issue: "Options not showing up"
**Solution:** Ensure `Values` is a table of strings: `Values = {"A", "B", "C"}`

---

## ✅ Quick Checklist

Before you create a dropdown, verify:

- [ ] Using `Values` parameter (RvrseUI native)
- [ ] Using `MultiSelect` parameter (RvrseUI native)
- [ ] `CurrentOption` is a **table** (not string)
- [ ] `MultiSelect = true` if you want multi-select
- [ ] Callback handles correct type (string for single, array for multi)
- [ ] Added `Flag` parameter for save/load functionality

---

**Last Updated:** 2025-10-18 (v4.0.4)

**See Also:**
- [README.md](README.md) - Full user documentation
- [DEV_NOTES.md](DEV_NOTES.md) - Developer notes and changelog
