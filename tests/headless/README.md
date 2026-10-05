# Headless lifecycle test

Runs the built `RvrseUI.lua` outside Roblox, in a strict fake Roblox client, and checks that closing a window
leaves nothing behind.

```bash
node tools/build.js              # build RvrseUI.lua first
node tests/headless/run.js       # all scenarios against ./RvrseUI.lua
node tests/headless/run.js RvrseUI.lua x,two
```

Needs the [`luau` CLI](https://github.com/luau-lang/luau/releases) on `PATH` (or `LUAU=/path/to/luau`).

## What it checks

`lifecycle_driver.lua` builds a window with every element, then closes it. A scenario passes only if, after
closing, there are **0 live connections made by RvrseUI**, **0 RvrseUI ScreenGuis**, and **no errors**, and
`OnClose` fired exactly once with the right reason.

| Scenario | What it does |
|---|---|
| `x` | click the window's X |
| `destroy` | `Window:Destroy()` |
| `rvrseui` | `RvrseUI:Destroy()` |
| `escape` | press the destroy key (Backspace) |
| `two` | two windows; closing A must leave B working, then close B |
| `overlays` | close while a Dropdown list and the ColorPicker panel are open |
| `reopen` | close, then open a new window with the same RvrseUI (shared services come back), close again |
| `togglesoff` | `TurnOffTogglesOnClose` + config saving: ON toggles get one `OnChanged(false)`, saved config keeps ON, Auto Save stays on |
| `track` | `Window:Track` connections, a loop thread, a cleanup function and an Instance are all released |

## The mock (`roblox_mock.lua`)

Strict where the engine is strict, so it catches real bugs:

- reading or calling a member that doesn't exist errors (`X is not a valid member of Frame`)
- `Instance:Destroy()` fires `Destroying`, destroys children, locks `Parent` and disconnects every connection
- every connection records the chunk that made it (`RvrseUI`), so leaks are reported with their line
- virtual-time `task.*`, `wait`, tweens and `RunService` frames

It is a model, not Roblox: layout (`AbsoluteSize` etc.) is approximate and rendering doesn't exist. Test on a real
client before releasing; use this to catch lifecycle and build regressions first.
