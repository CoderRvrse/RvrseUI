# RvrseUI

Production-ready Roblox UI toolkit built in Luau with modular architecture, persistent themes, and a polished desktop/mobile experience.

![Version](https://img.shields.io/badge/version-4.0.0-blue) ![Channel](https://img.shields.io/badge/channel-Stable-purple) ![Status](https://img.shields.io/badge/status-production%20ready-success) ![License](https://img.shields.io/badge/license-MIT-green)

---

## Stability Snapshot · October&nbsp;2025
- Window minimization now enforces clipping, so the Profiles tab no longer spills its body frame while shrinking.
- All sections default to the restored inline `DropdownLegacy` renderer; the experimental overlay path requires `UseModernDropdown = true`.
- Profiles command center validated end-to-end for listing, saving, loading, deleting, and auto-save toggles with live logging.

## Quick Start

### Requirements
- Roblox experience with client-side (LocalScript) execution.
- Luau runtime (Roblox 2024+) with `HttpGet` enabled when loading from GitHub.
- Optional: executor with `writefile`/`readfile` for configuration persistence.

### Install
```lua
local VERSION = "v4.0.0"
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
- **Profiles Command Center**: Built-in "Profiles" tab for refreshing, loading, saving, cloning, deleting configs, and toggling auto-save.
- **Dropdown / Overlay System**: Inline `DropdownLegacy` renderer is the default for stability; opt into the overlay path with `UseModernDropdown` when a blocking layer is required.
- **Modular Build**: 26 focused modules compiled into `RvrseUI.lua` for `loadstring` usage.

---

## Dropdown Implementation Policy
- `SectionBuilder:CreateDropdown` always routes to `DropdownLegacy` unless you explicitly pass `UseModernDropdown = true`.
- The overlay-based renderer remains available for future work, but treat it as experimental and guard new usages behind reviews.
- Do not edit either dropdown module without coordinating with maintainers; the current legacy configuration is the verified production path.
- The Profiles tab confirms the inline renderer works with refresh callbacks, profile counts, and blocker-free animations across tabs.

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
| `ConfigurationManager` | bool/table | `true` | Controls the auto-injected Profiles tab. Set to `false` to disable, or provide `{ TabName = "Profiles", Icon = "folder" }` to customize. |
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
- Tune the injected "Profiles" tab via `ConfigurationManager = { TabName = "Profiles", Icon = "folder", DropdownPlaceholder = "Select profile" }` or set it to `false` to provide your own UI.
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

## Profiles & Snapshot Workflow

When `ConfigurationSaving` is enabled the UI injects a "Profiles" tab that keeps configurations in sync with disk:

- **Refresh** – Re-scans the profiles folder on command and whenever the dropdown opens, so external changes appear immediately.
- **Load Selected** – Executes `SetConfigProfile` + `LoadConfigByName` for the chosen entry and reapplies all flags/theme.
- **Save Current** – Persists the active profile (`ConfigurationFileName`) using the live element state.
- **Save As** – Writes a new profile name, refreshes the list, and optionally clears the input field.
- **Delete Profile** – Removes the selected profile and clears the active selection if it was in use.
- **Auto Save Toggle** – Mirrors `RvrseUI:SetAutoSaveEnabled` for quick snapshot freezes.

Set `ConfigurationManager = false` to supply your own controls, or override labels/icons via `ConfigurationManager = { TabName = "Profiles", Icon = "folder", DropdownPlaceholder = "Select profile" }`.

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
    Overlay = true, -- default; set to false for inline expansion
    OnChanged = function(mode)
        print("Mode set to", mode)
    end,
    Flag = "SelectedMode"
})
-- overlay dropdowns reparent into the global overlay layer and close when clicking the blocker

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
- `src/` contains the authoritative modules (`Theme`, `Animator`, `WindowBuilder`, element factories, etc.) that power both the modular loader (`init.lua`) and the bundled monolith.
- `init.lua` is still the source of truth for wiring services, configuration, overlay creation, and notification setup. The monolith now embeds the same bootstrap so both entry-points initialise identically.
- `WindowBuilder` enforces temporary clipping during minimize/restore to keep tab bodies from escaping the frame—do not remove this guard without validating the shrink animation.
- `RvrseUI.lua` is generated; never hand-edit it. After touching any file in `src/` (or `init.lua`), run `node build.js` to rebuild the bundle. A Lua fallback (`lua build.lua`) exists for environments without Node.
- The build scripts now scope every module in a `do ... end` block and hydrate shared singletons (`DEFAULT_HOST`, overlay frame, notifications, hotkeys) before exposing the public API, preventing cross-module leakage.
- Keep `VERSION.json`, `README.md`, and `CLAUDE.md` consistent with each release; the push guard expects the version badge and metadata to match.
- Legacy documentation, deep-dive reports, and historical tests remain archived under `docs/__archive/` for reference.

### Monolith ↔ Modular Workflow
1. Edit modules under `src/` (or the public API in `init.lua`).
2. Run `node build.js` (or `lua build.lua`) to regenerate `RvrseUI.lua`.
3. Verify runtime in Roblox/your executor using the rebuilt monolith.
4. Commit both the source changes and the regenerated `RvrseUI.lua` together so GitHub consumers stay in sync with `main`.
5. When testing persistence, remember that the compiled bundle now creates/retains the default `ScreenGui` + overlay globally—destroying them in your scripts requires calling `RvrseUI:Destroy()` to match the cached handles.

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
