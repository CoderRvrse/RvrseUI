# RvrseUI Codex-5 Agent Guide

**Always default to Lucide icons (`lucide://...`) for every element unless a user explicitly requests
an emoji or asset ID.**

Use this playbook when building user-facing menus with the monolithic `RvrseUI.lua` bundle.

---

## 1. Core Architecture Standard (Non-Negotiable)

All Lua authored for this project **must** follow the Modular Namespace + `getgenv()` pattern. No
exceptions. Static logic lives inside a single module table; dynamic state belongs in the executor
environment.

### 1.1 Modular Namespace (Static Logic)

- Declare **one** top-level local table (e.g., `local MyScript = {}`) to hold services, config, and
  all functions.
- Cache Roblox services once at module creation time; do not re-call `GetService` inside hot paths.
- Expose routines as methods (`function MyScript:DoThing() ... end`) to keep scope disciplined.

```lua
local MyScript = {}

MyScript.Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService")
}

MyScript.Config = {
    LOOP_DELAY = 0.1,
    BLACKLIST = { Boss = true, Spectator = true } -- hash-set form
}
```

### 1.2 getgenv() for Dynamic State

- `_G` usage is forbidden. Anything dynamic (toggles, counters, colors) is stored in `getgenv()`.
- Initialize values defensively so existing sessions retain their state:

```lua
local env = getgenv()
env.AuraEnabled = env.AuraEnabled or false
env.AccentColor = env.AccentColor or Color3.fromRGB(255, 120, 60)
```

- When UI elements mutate state, they **must** read/write through `env`:

```lua
section:CreateToggle({
    Text = "Aura",
    Icon = "lucide://sparkles",
    Default = env.AuraEnabled,
    Flag = "AuraToggle",
    OnChanged = function(isOn)
        env.AuraEnabled = isOn
    end
})
```

- Loops reference `env` every iteration so they can be halted externally:

```lua
function MyScript:AuraLoop()
    while env.AuraEnabled do
        task.wait(self.Config.LOOP_DELAY)
        self:Pulse()
    end
end
```

### 1.3 Entry Point Discipline

- Provide a single initializer (e.g., `function MyScript:Init() ... end`).
- Create / wire UI inside `Init`, then start loops using `task.spawn(function() self:AuraLoop() end)`
  so toggles can disable them.
- Final line of every script calls the initializer: `MyScript:Init()`.

### 1.4 Illegal Patterns (for reference)

- Multiple root locals for services, helpers, etc.
- Tables named `State` or similar holding dynamic flags.
- Any `_G` usage.
- Loops that capture a copy of the state (e.g., `local enabled = env.AuraEnabled`) and never read
  `env` again.

---

## 2. Performance & Optimization Mandate

- **Hot path awareness:** Anything inside `while`/`RunService` loops or events must be minimal.
- **Do it once:** Cache services, objects, and expensive lookups before the loop begins. Example:

```lua
function MyScript:TrackTargets()
    local players = self.Services.Players
    while env.Targeting do
        task.wait(self.Config.LOOP_DELAY)
        for _, plr in players:GetPlayers() do
            if not self.Config.BLACKLIST[plr.Name] then
                self:HandleTarget(plr)
            end
        end
    end
end
```

- **Hash sets over arrays:** store membership checks as `{ [Name] = true }` for O(1) lookups.
- **No per-iteration service calls:** never call `GetService`, `FindFirstChild`, etc., inside the
  hot loop unless cached.

---

## 3. Resilience & Defensive Programming Mandate

- Wrap all external calls (`FireServer`, `InvokeServer`, `DataStore`) in `pcall`.
- Filter expected harmless errors so logs stay clean.
- Use descriptive warnings only for critical failures.

```lua
function MyScript:SafeInvoke(remote, ...)
    local ok, result = pcall(remote.InvokeServer, remote, ...)
    if not ok then
        local msg = tostring(result)
        if not string.find(msg, "Network Ownership") then
            warn("[CRITICAL] Remote failed: " .. msg)
        end
        return nil
    end
    return result
end
```

- Guard long-running threads with `task.spawn` and state checks so they can exit gracefully.

---

## 4. RvrseUI Bootstrap Checklist

1. Load the latest monolith:
   ```lua
   local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()
   ```
2. Create the window with required metadata (icon overrides optional but recommended):
   ```lua
   local window = RvrseUI:CreateWindow({
       Name = "My Hub",
       Theme = "Dark",              -- "Dark" or "Light"
       ToggleUIKeybind = "K",
       TokenIcon = "lucide://gamepad-2",
       TokenIconColor = nil,
       TokenIconFallback = "🎮",
       ConfigurationSaving = {
           Enabled = true,
           FolderName = "MyHub",
           FileName = "Config.json"
       }
   })
   ```
3. Build tabs/sections/elements, wiring `env` state for all dynamic behavior.
4. Call `window:Show()` **after** everything is constructed.
5. Use `RvrseUI.Flags` for cross-element state; never invent parallel flag systems.
6. Flagged elements now auto-fire `OnChanged` after config load. Opt out only when necessary with
   `FireOnConfigLoad = false` on the element definition.

---

## 5. Lucide Icon Rules

- Use the `lucide://` scheme for every icon (tabs, buttons, labels, notifications).
- Valid example strings: `"lucide://home"`, `"lucide://settings"`, `"lucide://box"`.
- Never supply emojis unless the user explicitly asks for them.
- When the icon isn’t known, consult <https://lucide.dev/icons/> and map the kebab-case name.
- For fallbacks, rely on the system defaults—don’t inject raw Unicode unless required.

## 6. Tab Construction Patterns

Use the same shape for every tab: icon-only rail entry plus at least one section. Example for
five tabs (`Home`, `Looting`, `Settings`, `Mob`, `Aimbot`):

```lua
local homeTab = window:CreateTab({ Title = "Home", Icon = "lucide://home" })
local lootingTab = window:CreateTab({ Title = "Looting", Icon = "lucide://treasure-chest" })
local settingsTab = window:CreateTab({ Title = "Settings", Icon = "lucide://settings" })
local mobTab = window:CreateTab({ Title = "Mob", Icon = "lucide://users" })
local aimbotTab = window:CreateTab({ Title = "Aimbot", Icon = "lucide://crosshair" })
```

### Section Boilerplate

For each tab, create at least one section. Favor concise naming and add a divider for structure.

```lua
local mainSection = homeTab:CreateSection("Main Controls")
mainSection:CreateDivider("Loadout")        -- labelled divider
mainSection:CreateButton({
    Text = "Activate",
    Icon = "lucide://flash",
    Callback = function()
        -- logic
    end
})
```

**Divider options:**
- `section:CreateDivider()` → simple line
- `section:CreateDivider("Label")` → line with text

---

## 7. Element Cheat Sheet

> All element factories accept an `Icon` key that supports `lucide://` identifiers.

| Element | Constructor | Required Keys | Optional Keys |
|---------|-------------|---------------|---------------|
| Button | `Section:CreateButton` | `Text`, `Callback` | `Icon`, `Locked`, `Flag`, `Tooltip`, `ThemeSync` |
| Toggle | `Section:CreateToggle` | `Text`, `Default` (bool), `OnChanged` | `Icon`, `Flag`, `Locked`, `Tooltip` |
| Slider | `Section:CreateSlider` | `Text`, `Min`, `Max`, `Default`, `OnChanged` | `Icon`, `Flag`, `Suffix`, `Increment` |
| Dropdown | `Section:CreateDropdown` | `Text`, `Values`, `Flag`, `OnChanged` | `Icon`, `Multi`, `Placeholder`, `Overlay` |
| Color Picker | `Section:CreateColorPicker` | `Text`, `Default`, `OnChanged` | `Icon`, `Flag`, `LockAlpha` |
| Text Box | `Section:CreateTextBox` | `Text`, `Placeholder`, `OnChanged` | `Icon`, `ClearTextOnFocus`, `Numeric` |
| Label | `Section:CreateLabel` | `Text` | `Icon`, `Secondary` |
| Paragraph | `Section:CreateParagraph` | `Title`, `Content` | `Icon` |
| Divider | `Section:CreateDivider` | — | `Text` |
| Keybind | `Section:CreateKeybind` | `Text`, `Default`, `OnChanged` | `Icon`, `Flag`, `AllowGameProcessed` |
| Notification | `RvrseUI:Notify` | `Title` or `Message` | `Icon`, `Duration`, `Type` |

**Element Flags:**
- When persistence is required, supply `Flag = "UniqueName"`. The configuration system saves/restores automatically.
- Cross-element communication uses `RvrseUI.Flags["UniqueName"]:Set(...)` / `:Get()`.

---

## 8. Skeleton Generator (Codex-5 Macro)

To build a quick multi-tab hub, follow this order:

1. **Tabs** (in array order):
   ```lua
   local tabs = {
       { id = "home", title = "Home", icon = "lucide://home" },
       { id = "looting", title = "Looting", icon = "lucide://treasure-chest" },
       { id = "settings", title = "Settings", icon = "lucide://settings" },
       { id = "mob", title = "Mob", icon = "lucide://users" },
       { id = "aimbot", title = "Aimbot", icon = "lucide://crosshair" }
   }

   local sections = {}
   for _, tabInfo in ipairs(tabs) do
       local tab = window:CreateTab({ Title = tabInfo.title, Icon = tabInfo.icon })
       local section = tab:CreateSection(tabInfo.title .. " Options")
       section:CreateDivider(tabInfo.title .. " Controls")
       sections[tabInfo.id] = section
   end
   ```
2. **Populate elements** using helper functions. Example for a slider + dropdown + color picker:
   ```lua
   sections.home:CreateSlider({
       Text = "Master Volume",
       Min = 0,
       Max = 100,
       Default = 50,
       Icon = "lucide://volume-2",
       Flag = "MasterVolume",
       OnChanged = function(value)
           -- apply volume logic
       end
   })

   sections.home:CreateDropdown({
       Text = "Profile",
       Values = { "Default", "Aggressive", "Stealth" },
       Default = "Default",
       Icon = "lucide://layers",
       Flag = "ProfilePreset",
       OnChanged = function(option)
           -- swap preset
       end
   })

   sections.home:CreateColorPicker({
       Text = "Accent Color",
       Default = Color3.fromRGB(255, 120, 60),
       Icon = "lucide://palette",
       Flag = "AccentColor",
       OnChanged = function(color)
           -- update UI accent
       end
   })
   ```
3. Add a concluding button/toggle per tab as requested.

---

## 9. Notifications & Toasts

- Always gate notifications behind `RvrseUI.NotificationsEnabled`.
- Use Lucide icons for categories: `"lucide://check"`, `"lucide://shield-alert"`, `"lucide://info"`.

```lua
RvrseUI:Notify({
    Title = "Loot Collected",
    Message = "+150 Gold",
    Icon = "lucide://coins",
    Duration = 3,
    Type = "success"
})
```

---

## 10. Finishing Moves & Quality Gate

Complete the following before calling the build done. Think of it as a two-pass sweep:

### 10.1 Structural Wrap-Up

- `window:Show()` (or equivalent) is called once, after the UI tree is assembled.
- Hotkeys rebound if the design needs non-default keys (`RvrseUI.UI:BindToggleKey`, etc.).
- Config persistence tested: run `RvrseUI:SaveConfiguration()` inside a protected block and print
  actionable feedback on failure.
- Token icon preference set if required (`RvrseUI:SetTokenIcon(...)`).
- Long-running loops launched with `task.spawn` and controlled by `env` flags.

### 10.2 Error-Prevention Sweep

Basic review (catch the usual footguns):
- All blocks closed (`end`, `)`), comparisons use `==`, method calls keep the colon `:`.
- Strings concatenated with `..`, tables comma-separated, temporary variables marked `local`.
- No indexing of potential `nil` without a guard; Lua’s 1-based indexing respected.

Advanced review (resilience/perf):
- `getgenv()` backs every mutable flag; no latent globals or module-level `State` tables.
- Closures created in loops capture loop values correctly (`local item = value` before callbacks).
- Hot paths avoid repeat service lookups or heavy function call chains; cache first, loop after.
- Remote calls and other risky operations wrapped in `pcall`, with noisy-but-expected errors filtered.
- Hash-set tables used for membership tests; `pairs` vs `ipairs` chosen deliberately; multiple-return
  helpers consumed intentionally.
- If `FireOnConfigLoad` was set to `false`, confirm you manually hydrate that flag post-load so
  gameplay state matches UI state.

Only when both passes are green do we proceed with deployment or handoff.

---

## 11. Troubleshooting Checklist

- **Lucide fallbacks in console?** Ensure the latest `RvrseUI.lua` was built (look for `_G.RvrseUI_LucideIconsData`).
- **Token icon didn’t change?** Confirm `window:SetTokenIcon` was called *after* `CreateWindow` and before `window:Show()`.
- **Dropdown clipping?** The modern system uses an overlay; make sure you’re invoking `CreateDropdown`, not the legacy `DropdownLegacy`.
- **Auto-save not working?** Verify each element uses `Flag` and that `ConfigurationSaving.Enabled` is true.
- **Menu flickers on minimize restore?** Never tween `controllerChip` manually—use provided APIs only.

---

## 12. Sample Generation Prompt (for debugging Codex-5)

> “Generate a Roblox Lua script using `RvrseUI` that loads the monolith, creates five tabs (Home, Looting, Settings, Mob, Aimbot) with Lucide icons, adds a slider, dropdown, color picker, and divider in each tab, then shows the window and saves the configuration.”

Use this as the canonical end-to-end validation whenever behavior drifts.

---

**End of AGENTS.md — keep untracked.**
