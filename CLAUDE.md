# RvrseUI – Maintainer Notes (v3.0.3)

## Configuration Persistence Lockdown
- Save/load now routes through the live `RvrseUI` context (`src/Config.lua`) so every flagged element serializes correctly.  
- Theme cache (`_savedTheme`) is synced back to the active window; do not strip this hand-off.  
- Boolean `ConfigurationSaving = true` reuses the last profile by splitting `folder/file.json`; keep this parsing intact.  
- `ConfigurationSaving.AutoSave = false` disables background writes; keep `_autoSave` guard in sync if you extend persistence.
- Profiles tab auto-injects when configuration saving is enabled; expose toggles via `ConfigurationManager = false` if a consumer wants a bare UI.
- When touching persistence code, verify the executor supports `writefile/readfile/isfile` and rerun a full save → load cycle with all 12 elements.

## Minimize Chip Alignment
- Chip drag now respects `ScreenGui.IgnoreGuiInset` and clamps using camera viewport size. If you change the host container, update the inset logic in `WindowBuilder` accordingly.

## Hotkey Pipeline
- `Hotkeys:Initialize` immediately wires `InputBegan` and prevents double hookups. Ensure any future hotkey changes toggle `_initialized` carefully.

## Quick Validation Checklist
1. Toggle each element flag, call `SaveConfiguration`, restart script, confirm values restore.  
2. If auto-save is disabled, ensure manual saves still write expected profiles.  
3. Minimize to the 🎮 chip, drag around edges, restore, then destroy via `Escape`.  
4. Confirm `ToggleUIKeybind` still acts globally after any hotkey changes.  
5. Run docs build (README badge/version) when bumping releases.
