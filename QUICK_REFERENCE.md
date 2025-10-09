# RvrseUI v3.0.0 - Quick Reference Card

## 🚀 Production Install (Copy-Paste Ready)

```lua
-- ✅ RECOMMENDED: Pinned version with error handling
local chunk, err = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/CoderRvrse/RvrseUI/v3.0.0/RvrseUI.lua", true
))
if not chunk then error("[RvrseUI] " .. tostring(err)) end
local RvrseUI = chunk()
```

---

## 🐛 Getting "attempt to call a nil value" Error?

**This means loadstring returned nil (compile failed).**

### Quick Fix:
Use the **diagnostic loader** to see what went wrong:

```lua
local url = "https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/DIAGNOSTIC_LOADER.lua"
local RvrseUI = loadstring(game:HttpGet(url, true))()
```

This will print **exactly** what failed:
- ❌ HTML response (rate limit/404)
- ❌ Empty/short body (network issue)
- ❌ Parse error (syntax issue)

### Common Causes:
1. **GitHub rate limit** → HTML page returned → Wait 5 minutes
2. **Typo in URL** → 404 page returned → Check URL carefully
3. **Network timeout** → Empty response → Retry

---

## 📖 Complete Example (30 Seconds)

```lua
-- Load framework
local chunk, err = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/CoderRvrse/RvrseUI/v3.0.0/RvrseUI.lua", true
))
if not chunk then error(err) end
local RvrseUI = chunk()

-- Create window with auto-save
local Window = RvrseUI:CreateWindow({
  Name = "My Script",
  ConfigurationSaving = true  -- Auto-loads last config + theme
})

-- Create tab and section
local Tab = Window:CreateTab({ Title = "Main", Icon = "home" })
local Section = Tab:CreateSection("Player")

-- Add interactive elements
Section:CreateSlider({
  Text = "Walk Speed",
  Min = 16,
  Max = 100,
  Default = 16,
  Flag = "Speed",
  OnChanged = function(speed)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = speed
  end
})

Section:CreateToggle({
  Text = "Auto Farm",
  State = false,
  Flag = "AutoFarm",
  OnChanged = function(enabled)
    print("Auto Farm:", enabled)
  end
})

-- ⚠️ CRITICAL: Show the window (loads config + displays UI)
Window:Show()
```

---

## 🎨 All 12 Elements (Quick Syntax)

```lua
-- Interactive elements
Section:CreateButton({ Text = "...", Callback = function() end })
Section:CreateToggle({ Text = "...", State = false, OnChanged = function(state) end })
Section:CreateDropdown({ Text = "...", Values = {...}, Default = "...", OnChanged = function(v) end })
Section:CreateSlider({ Text = "...", Min = 0, Max = 100, Default = 50, OnChanged = function(v) end })
Section:CreateKeybind({ Text = "...", Default = Enum.KeyCode.E, OnChanged = function(key) end })

-- Input elements
Section:CreateTextBox({ Text = "...", Placeholder = "...", Default = "...", OnChanged = function(text) end })
Section:CreateColorPicker({ Text = "...", Default = Color3.new(1,0,0), OnChanged = function(color) end })

-- Display elements
Section:CreateLabel({ Text = "..." })
Section:CreateParagraph({ Text = "Multi-line text..." })
Section:CreateDivider()

-- Structure
local Tab = Window:CreateTab({ Title = "...", Icon = "..." })
local Section = Tab:CreateSection("Section Name")
```

---

## 💾 Configuration System

### Auto-Load (Simplest)
```lua
local Window = RvrseUI:CreateWindow({
  Name = "My Script",
  ConfigurationSaving = true  -- Auto-loads last used config
})
```

### Named Profiles
```lua
local Window = RvrseUI:CreateWindow({
  Name = "My Script",
  ConfigurationSaving = "PlayerHub"  -- Saves to RvrseUI/Configs/PlayerHub.json
})
```

### Classic Format
```lua
local Window = RvrseUI:CreateWindow({
  Name = "My Script",
  ConfigurationSaving = {
    Enabled = true,
    FolderName = "MyHub",
    FileName = "Config.json"  -- Saves to MyHub/Config.json
  }
})
```

### Access Saved Values
```lua
-- Via Flags system
local speed = RvrseUI.Flags["Speed"]:Get()
RvrseUI.Flags["AutoFarm"]:Set(true)

-- Via element references
local slider = Section:CreateSlider({ Flag = "Speed", ... })
slider:Set(50)
print(slider:Get())  -- Returns: 50
print(slider.CurrentValue)  -- Also returns: 50
```

---

## 🎨 Theme System

```lua
-- Set initial theme (first run only, saved theme wins after)
local Window = RvrseUI:CreateWindow({
  Theme = "Dark"  -- or "Light"
})

-- Switch theme programmatically
Window:SetTheme("Light")  -- Changes theme and saves to config

-- Access theme colors in your code
local theme = RvrseUI.Theme:Get()
local accentColor = theme.Accent  -- Color3.fromRGB(99, 102, 241)
```

---

## 🔒 Lock Groups (Master/Child Controls)

```lua
-- MASTER: Controls the lock
Section:CreateToggle({
  Text = "Auto Mode (Master)",
  LockGroup = "AutoMode"  -- When ON, locks all children
})

-- CHILDREN: Respect the lock
Section:CreateToggle({
  Text = "Option A",
  RespectLock = "AutoMode"  -- Disabled when master is ON
})

Section:CreateSlider({
  Text = "Speed",
  RespectLock = "AutoMode"  -- Also disabled
})
```

---

## 🔔 Notifications

```lua
RvrseUI:Notify({
  Title = "Success!",
  Message = "Operation completed",
  Duration = 3,  -- seconds
  Type = "success"  -- "success", "error", "warn", "info"
})
```

---

## 🎮 Minimize to Controller

Built-in by default! Features:
- Click header minimize button (➖) to shrink to controller chip
- Drag controller chip anywhere on screen
- Click 🎮 chip to restore window
- 40-particle flow animation on minimize/restore
- Position remembered across sessions

---

## ⚙️ Advanced Features

### Custom Toggle Keybind
```lua
local Window = RvrseUI:CreateWindow({
  ToggleUIKeybind = "K"  -- Press K to hide/show entire UI
})
```

### Window Methods
```lua
Window:Show()  -- Display window + load config (REQUIRED at end)
Window:SetTheme("Light")  -- Change theme
Window:SaveConfig()  -- Manual save
Window:LoadConfig()  -- Manual load
Window:Minimize()  -- Shrink to controller
Window:Restore()  -- Restore from controller
```

### Element Methods
```lua
-- All elements support:
element:Set(value)  -- Set value (triggers callback)
element:Get()  -- Get current value

-- All elements have:
element.CurrentValue  -- Current value (no callback)

-- Examples:
toggle:Set(true)  -- Enable toggle
slider:Set(75)  -- Set slider to 75
dropdown:Set("Option2")  -- Select option
label:Set("New text")  -- Update label text
```

---

## 📚 Documentation Links

- **[README.md](README.md)** - Complete documentation
- **[INSTALL_VARIANTS.md](INSTALL_VARIANTS.md)** - All install patterns + error handling
- **[MODULAR_ARCHITECTURE.md](MODULAR_ARCHITECTURE.md)** - Architecture deep-dive
- **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Testing instructions
- **[DIAGNOSTIC_LOADER.lua](DIAGNOSTIC_LOADER.lua)** - Debug loadstring failures

---

## 🆘 Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `attempt to call a nil value` (line 3) | loadstring returned nil | Use [DIAGNOSTIC_LOADER.lua](DIAGNOSTIC_LOADER.lua) to see exact error |
| `attempt to call missing method 'Initialize'` | Old cached version | Use pinned v3.0.0 URL, clear cache |
| UI not showing | Forgot `Window:Show()` | Add `Window:Show()` at end of script |
| Config not loading | Window:Show() not called | Call `Window:Show()` AFTER creating elements |
| Theme not persisting | Using old version | Update to v3.0.0, ensure ConfigurationSaving enabled |

---

## 🏗️ Architecture (v3.0.0)

RvrseUI is now **modular** but distributed as a **single compiled file** for loadstring usage:

- **Development**: Use `src/` directory + `init.lua` (26 modules)
- **Production**: Use `RvrseUI.lua` (116 KB, all modules inlined)

**Both versions are 100% API compatible.**

### Module Structure:
```
src/
├── Version.lua (metadata)
├── Debug.lua (logging)
├── Obfuscation.lua (random names)
├── Icons.lua (183 icon mappings)
├── Theme.lua (Dark/Light palettes)
├── Animator.lua (spring animations)
├── State.lua (Flags, Locks)
├── UIHelpers.lua (corner, stroke, padding, etc.)
├── Config.lua (save/load system)
├── Notifications.lua (toast system)
├── Hotkeys.lua (global keybinds)
├── WindowManager.lua (ScreenGui lifecycle)
├── WindowBuilder.lua (window structure)
├── TabBuilder.lua (tab buttons + pages)
├── SectionBuilder.lua (section containers)
└── Elements/
    ├── Button.lua
    ├── Toggle.lua
    ├── Dropdown.lua
    ├── Slider.lua
    ├── Keybind.lua
    ├── TextBox.lua
    ├── ColorPicker.lua
    ├── Label.lua
    ├── Paragraph.lua
    └── Divider.lua
```

---

## ✅ Best Practices

1. **Always pin to version tag** (`v3.0.0`) for production scripts
2. **Always add error handling** to loadstring
3. **Always call `Window:Show()`** at the end
4. **Use Flags** for elements you need to access later
5. **Enable ConfigurationSaving** to persist user settings
6. **Use LockGroup/RespectLock** for master/child relationships
7. **Test with DIAGNOSTIC_LOADER** if you get errors

---

**Version**: 3.0.0
**Build**: 20251009
**Hash**: M6D8A3L1
**Channel**: Stable
**Size**: 116 KB (4,231 lines)
**Modules**: 26 (compiled into single file)
