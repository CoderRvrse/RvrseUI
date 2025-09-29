# RvrseUI

A lightweight, Rayfield-style UI framework for Roblox scripts.

**Flow**: Boot library → Create Window → Tabs → Sections → Elements (buttons, toggles, dropdowns, keybinds, notifications).

Includes a **LockGroup system** to coordinate "master" controls with dependent elements (e.g., Aura + Target All master that locks per-enemy toggles).

## ✨ Features

- **Familiar API**: Rayfield-style creation (`CreateWindow` → `CreateTab` → `CreateSection` → `CreateButton`/`Toggle`/`Dropdown`/`Keybind`).
- **LockGroup System**: One toggle can lock/disable a set of other controls (e.g. master aura locks per-enemy toggles).
- **Notifications**: In-UI toast system (info, success, warn, error).
- **Keybind Rebinding**: Built-in hotkey toggling for UI visibility.
- **Theming**: Dark / Light.
- **Zero Boilerplate**: Single file loader; works with `loadstring(game:HttpGet(...))()`.

## 🚀 Quick Start

```lua
-- Load the library (from your repo)
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

-- Create a window
local Window = RvrseUI:CreateWindow({
  Name                 = "RvrseUI Example Window",
  Icon                 = 0,           -- Roblox image id or string icon; 0 = none
  LoadingTitle         = "RvrseUI Interface Suite",
  LoadingSubtitle      = "RvrseUI",
  ShowText             = "RvrseUI",   -- mobile hint to reopen UI
  Theme                = "Dark",      -- "Dark" | "Light"
  ToggleUIKeybind      = "K",         -- press K to show/hide UI
  DisableRvrseUIPrompts = false,
  DisableBuildWarnings  = false,
})

-- Add a tab & section
local Tab    = Window:CreateTab({ Title = "Overview", Icon = "ℹ" })
local Sect   = Tab:CreateSection("Welcome")

-- Elements
Sect:CreateButton({
  Text = "Hello",
  Callback = function()
    RvrseUI:Notify({ Title="Hi", Message="Welcome to RvrseUI", Duration=2, Type="info" })
  end
})

Sect:CreateToggle({
  Text = "Master Toggle",
  State = false,
  LockGroup = "AuraAll",    -- this toggle CONTROLS lock state for group "AuraAll"
  OnChanged = function(on)
    -- wire your game logic here
  end
})
```

## 📦 Booting the Library

```lua
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()
```

The library returns a module table with constructors and utility helpers.

## 🪟 Window

```lua
local Window = RvrseUI:CreateWindow({
  Name                 = "RvrseUI Example Window",
  Icon                 = 0,            -- number (Roblox) or string (icon), 0 = none
  LoadingTitle         = "RvrseUI Interface Suite",
  LoadingSubtitle      = "RvrseUI",
  ShowText             = "RvrseUI",
  Theme                = "Dark",       -- "Dark" | "Light"
  ToggleUIKeybind      = "K",          -- string "K" or Enum.KeyCode
  DisableRvrseUIPrompts = false,
  DisableBuildWarnings  = false,
})
```

### Window Methods

- `CreateTab({ Title: string, Icon: string|number? })` → Tab

## 🗂 Tabs & Sections

```lua
local Tab      = Window:CreateTab({ Title = "Controls", Icon = "★" })
local Section  = Tab:CreateSection("Master Mode")
```

### Tab Methods

- `CreateSection(title: string)` → Section

## 🔘 Elements

### Button

```lua
Section:CreateButton({
  Text = "Apply Settings",
  Callback = function() end
})
```

### Toggle

```lua
Section:CreateToggle({
  Text      = "Aura + Target All (MASTER)",
  State     = false,
  LockGroup = "AuraAll",     -- this toggle CONTROLS the lock for a named group
  OnChanged = function(on) end
})
```

### Toggle (Respect Lock)

```lua
Section:CreateToggle({
  Text        = "Enable: Bunny",
  State       = true,
  RespectLock = "AuraAll",   -- becomes locked while the named LockGroup is ON
  OnChanged   = function(on) end
})
```

### Dropdown

```lua
Section:CreateDropdown({
  Text      = "Mode",
  Values    = { "Standard", "Aggressive", "Passive" },
  Default   = "Standard",
  OnChanged = function(v) end
})
```

### Keybind

```lua
Section:CreateKeybind({
  Text      = "Toggle UI Keybind",
  Default   = Enum.KeyCode.K,    -- or "K"
  OnChanged = function(keyCode)
    -- the library also auto-binds the UI visibility toggle
  end
})
```

## 🔒 Lock Groups

**Goal**: One control (e.g., Aura + Target All) should lock related controls (e.g., per-enemy toggles).

- **To CREATE/CONTROL a lock**: pass `LockGroup = "GroupName"` to a toggle. When ON → lock active.
- **To RESPECT a lock**: pass `RespectLock = "GroupName"` to any element. It will:
  - visually enter a locked state (disabled) while the lock is ON
  - ignore user input until the lock is OFF again

Internally, RvrseUI manages a shared state map of `GroupName` → boolean and will re-render element states on changes.

## 🔔 Notifications

```lua
RvrseUI:Notify({
  Title    = "Saved",
  Message  = "Preferences applied.",
  Duration = 2.0,
  Type     = "info"  -- "info" | "success" | "warn" | "error"
})
```

## 🎛 Demo Script

A full demo (window → tabs → sections → elements, master lock + per-enemy toggles, dropdown, keybind, toasts) is coming soon.

It uses this loader:

```lua
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()
```

## 🧩 Integrating With Your Systems

1. Wire your game logic in each element's `OnChanged`/`Callback`.
2. For master/child patterns (e.g., Aura+All vs per-enemy toggles):
   - Set `LockGroup = "AuraAll"` on the master toggle.
   - Set `RespectLock = "AuraAll"` on each per-enemy toggle.
   - In your game script, listen to the master toggle's `OnChanged` and update your runtime state.

## 🎨 Themes

- Set at window creation: `Theme = "Dark"` or `"Light"`.
- You can expose a future `RvrseUI:SetTheme(themeName)` if you want hot-swapping; the base skin supports both palettes.

## ⌨️ UI Visibility Keybind

- Set at window creation with `ToggleUIKeybind`. The value can be `"K"` or `Enum.KeyCode.K`.
- Users can rebind via a Keybind element in your Preferences tab (see demo).

## 🧾 License

MIT

## 🗺 Roadmap

- [ ] Sliders, color pickers, textbox inputs
- [ ] Persisted user themes & element states
- [ ] Built-in layout presets (compact / spacious)
- [ ] Optional JSON schema for declarative UI

## 🙌 Credits

Designed and implemented by **Rvrse**.

UX/API inspired by Rayfield's mental model, reimagined for custom workflow and lock-group logic.