# RvrseUI

Modern Roblox UI toolkit built in Luau with modular architecture, persistent themes, and a polished desktop/mobile experience.

![Version](https://img.shields.io/badge/version-3.0.3-blue) ![License](https://img.shields.io/badge/license-MIT-green)

---

## Quick Start

### Requirements
- Roblox experience with client-side (LocalScript) execution.
- Luau runtime (Roblox 2024+) with `HttpGet` enabled when loading from GitHub.
- Optional: executor with `writefile`/`readfile` for configuration persistence.

### Install
```lua
local VERSION = "v3.0.3"
local SOURCE = string.format(
    "https://raw.githubusercontent.com/CoderRvrse/RvrseUI/%s/RvrseUI.lua",
    VERSION
)
local chunk, err = loadstring(game:HttpGet(SOURCE, true))
if not chunk then error(err, 0) end
local RvrseUI = chunk()
```

### Minimal Window Example
```lua
local Window = RvrseUI:CreateWindow({
    Name = "RvrseUI Demo",
    Theme = "Dark",
    ToggleUIKeybind = "K",
    ConfigurationSaving = true,
    LoadingTitle = "Demo Hub",
    LoadingSubtitle = "Initializing"
})

local MainTab = Window:CreateTab({ Title = "Main", Icon = "home" })
local PlayerSection = MainTab:CreateSection("Player")

PlayerSection:CreateSlider({
    Text = "Walk Speed",
    Min = 16,
    Max = 100,
    Step = 2,
    Default = 16,
    OnChanged = function(value)
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChildOfClass("Humanoid") then
            character.Humanoid.WalkSpeed = value
        end
    end,
    Flag = "WalkSpeed"
})

Window:Show()
```

---

## Feature Highlights
- **Glassmorphism + Spring Animations**: Consistent palette and motion courtesy of `Theme` and `Animator` modules.
- **Responsive Layout**: Automatically sizes for desktop, tablet, and mobile and ships with a controller chip when minimized.
- **Config Persistence**: Named profiles, automatic auto-save, and manual `SaveConfiguration` / `LoadConfiguration` helpers.
- **Lock & Flag Systems**: `State.Locks` keeps related controls in sync while `RvrseUI.Flags` exposes live element handles.
- **Hotkey Management**: Global toggle/destroy keys with runtime rebinding and minimize awareness.
- **Notification Stack**: Priority toasts rendered above the UI via the `Notifications` module.
- **Modular Build**: 26 focused modules compiled into `RvrseUI.lua` for `loadstring` usage.

---

## Configuration Reference

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `Name` | string | `"RvrseUI"` | Window title and profile identifier. |
| `Icon` | string | `nil` | Icon name or asset id for window badge. |
| `LoadingTitle` | string | `Name` | Title text for splash card. |
| `LoadingSubtitle` | string | `"Loading..."` | Subtitle under splash title. |
| `Theme` | string | `"Dark"` | Initial palette (`"Dark"` or `"Light"`). Saved theme overrides on next launch. |
| `ToggleUIKeybind` | string/Enum | `"K"` | Key that toggles the interface. |
| `EscapeKey` | string/Enum | `Enum.KeyCode.Backspace` | Key that destroys the UI. |
| `ConfigurationSaving` | bool/string/table | `false` | `true` auto-saves last profile, string creates named profile, or table `{ Enabled = true, FileName = "name.json", FolderName = "Folder" }`. |
| `AutoSave` | bool (table only) | `true` | Include inside `ConfigurationSaving` table to disable background writes: `{ Enabled = true, FileName = "Config.json", AutoSave = false }`. |
| `Container` | string/Instance | `nil` | Target ScreenGui parent (`"PlayerGui"`, `"CoreGui"`, etc. or Instance). |
| `DisplayOrder` | number | `100000` | Display order applied when `Container` is overridden. |
| `ShowText` | string | `"RvrseUI"` | Label shown on the mobile chip. |
| `DisableBuildWarnings` | boolean | `false` | Suppresses startup success notification. |
| `DisableRvrseUIPrompts` | boolean | `false` | Suppresses hotkey reminder toast. |

### Configuration Tips
- When `ConfigurationSaving` is truthy, element `Flag` values and dirty theme selections are written to JSON using executor `writefile` support.
- Use `RvrseUI:SaveConfiguration()` and `RvrseUI:LoadConfiguration()` to manage profiles manually.
- v3.0.3 routes save/load through the active window context so every flagged element persists; avoid modifying `src/Config.lua` unless you replicate this behaviour.
- Set `ConfigurationSaving.AutoSave = false` if you want to manually save without overwriting your last profile on every flag change.
- Call `RvrseUI:SetAutoSaveEnabled(false)` at runtime to pause auto-save temporarily.
- Call `Window:Show()` after building tabs/sections so saved settings apply before the UI becomes visible.

### Example Config Table
```lua
local profile = {
    Name = "Utility Hub",
    Theme = "Light",
    ToggleUIKeybind = Enum.KeyCode.LeftControl,
    EscapeKey = Enum.KeyCode.Backspace,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "RvrseUI/Profiles",
        FileName = "utility.json",
        AutoSave = false -- Optional: disable background writes
    },
    DisableBuildWarnings = true,
    LoadingTitle = "Utility Hub",
    LoadingSubtitle = "Applying saved tweaks"
}
local Window = RvrseUI:CreateWindow(profile)
```

---

## Element Catalog

| Element | Factory | Notes |
| --- | --- | --- |
| Button | `Section:CreateButton` | Ripple feedback, optional callback. |
| Toggle | `Section:CreateToggle` | Supports `LockGroup` and `RespectLock` for gating child controls. |
| Dropdown | `Section:CreateDropdown` | Scrollable list with optional default and callback. |
| Slider | `Section:CreateSlider` | Numeric slider with min/max/step and smooth tweening. |
| Keybind | `Section:CreateKeybind` | Captures keycodes, integrates with config saving via `Flag`. |
| TextBox | `Section:CreateTextBox` | Single-line input with optional placeholder and enter detection. |
| ColorPicker | `Section:CreateColorPicker` | Simple color cycle preview with callback and `Flag`. |
| Label | `Section:CreateLabel` | Static copy for status lines. |
| Paragraph | `Section:CreateParagraph` | Multi-line description block. |
| Divider | `Section:CreateDivider` | Spacing component. |
| Section | `Tab:CreateSection` | Groups elements, exposes `Update` and `SetVisible`. |
| Tab | `Window:CreateTab` | Adds tab button + scrollable page with icon support. |

### Element Usage Snippets
```lua
PlayerSection:CreateToggle({
    Text = "Enable Flight",
    State = false,
    LockGroup = "Flight",
    OnChanged = function(active)
        print("Flight toggled", active)
    end,
    Flag = "FlightEnabled"
})

PlayerSection:CreateDropdown({
    Text = "Gamemode",
    Values = {"Story", "Arcade", "Challenge"},
    Default = "Story",
    OnChanged = function(mode)
        print("Mode set to", mode)
    end,
    Flag = "SelectedMode"
})

PlayerSection:CreateKeybind({
    Text = "Dash Key",
    Default = Enum.KeyCode.Q,
    OnChanged = function(key)
        print("Dash key =>", key.Name)
    end,
    Flag = "DashKey"
})
```

### Lock Group Example
```lua
local LockTab = Window:CreateTab({ Title = "Automation", Icon = "lock" })
local LockSection = LockTab:CreateSection("Automation Controls")

LockSection:CreateToggle({
    Text = "Master Switch",
    LockGroup = "Automation",
    OnChanged = function(state)
        RvrseUI:Notify({
            Title = state and "Automation On" or "Automation Off",
            Message = state and "Child controls locked" or "Child controls unlocked",
            Type = state and "warning" or "info"
        })
    end,
    Flag = "AutomationMaster"
})

LockSection:CreateSlider({
    Text = "Automation Speed",
    Min = 1,
    Max = 10,
    Default = 5,
    RespectLock = "Automation",
    Flag = "AutomationSpeed"
})
```

---

## Public API Summary

### Window API
- `CreateWindow(configTable)` → window handle.
- `Window:CreateTab({ Title = string, Icon = string? })` → tab handle.
- `Window:Show()` displays the UI after splash/config load.
- `Window:SetTitle(newTitle)`, `Window:SetIcon(newIcon)` for runtime tweaks.
- `Window:Destroy()` tears down the host ScreenGui and clears listeners.

### Tab API
- `Tab:CreateSection(title)` → section handle.
- `Tab:SetIcon(icon)` to update the badge.
- Tabs automatically hide/show when toggled; you typically operate via sections.

### Section API
- Element factories: `CreateButton`, `CreateToggle`, `CreateDropdown`, `CreateSlider`, `CreateKeybind`, `CreateTextBox`, `CreateColorPicker`, `CreateLabel`, `CreateParagraph`, `CreateDivider`.
- `Section:Update(newTitle)` and `Section:SetVisible(boolean)` manage headings.

### Global Helpers
- `RvrseUI:Notify({ Title, Message, Type, Priority, Duration })` enqueues a toast.
- `RvrseUI:SaveConfiguration()` / `LoadConfiguration()` handle persistence.
- `RvrseUI:GetVersionInfo()` returns the active version table.
- `RvrseUI:SetTheme("Dark"|"Light")` switches palettes and triggers auto-save if enabled.

---

## Theme & Notifications
- Theme palettes live in `src/Theme.lua` with `Dark` and `Light` dictionaries.
- `Theme:Switch` flips palettes and marks them dirty so the config writer persists the choice.
- Notifications are rendered in a dedicated ScreenGui stack with priority ordering (`critical`, `high`, `normal`, `low`).
- Use notifications sparingly—`DisableBuildWarnings` and `DisableRvrseUIPrompts` disable the built-in startup toasts if you prefer a silent boot.

---

## Compatibility & Limits
- Client-side only: intended for Roblox `LocalScript` usage.
- UI is responsive for desktop, tablet, and mobile; console is not officially supported.
- Notifications and toast stacking require `TweenService` (standard in Roblox).
- Theme persistence and configuration saving require an executor exposing `readfile`/`writefile` APIs; otherwise the UI runs without persistence.

---

## Development Notes
- `init.lua` wires services, builders, and elements for modular consumption.
- `src/` contains 26 focused modules (Theme, Animator, Hotkeys, WindowBuilder, individual elements, etc.).
- `RvrseUI.lua` is the generated single-file build for `loadstring` consumers.
- `build.js` / `build.lua` rebuild the monolithic bundle from `src/`.
- Legacy documentation, deep-dive reports, and historical tests now live under `docs/__archive/` for reference.

### Testing & Validation
- Use Roblox Studio or an executor to run manual smoke tests with your own scripts.
- The previous comprehensive demo (`TEST_ALL_FEATURES.lua`) is archived at `docs/__archive/2025-10-09/TEST_ALL_FEATURES.lua` and can be run directly if you need end-to-end coverage.

---

## Versioning & Releases
- Version metadata is defined in `VERSION.json` and mirrored inside `RvrseUI.lua`.
- Release notes are tracked in [`CHANGELOG.md`](CHANGELOG.md).
- Follow semantic versioning: breaking changes bump Major, new features bump Minor, fixes bump Patch.

---

## License & Support
- Licensed under the MIT License (see [`LICENSE`](LICENSE)).
- Issues and pull requests: [https://github.com/CoderRvrse/RvrseUI](https://github.com/CoderRvrse/RvrseUI).
- For archived documentation, browse `docs/__archive/`.
