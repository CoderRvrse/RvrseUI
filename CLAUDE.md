# RvrseUI – Maintainer Notes (v3.0.4)

## Configuration Persistence Lockdown
- Save/load now routes through the live `RvrseUI` context (`src/Config.lua`) so every flagged element serializes correctly.  
- Theme cache (`_savedTheme`) is synced back to the active window; do not strip this hand-off.  
- Boolean `ConfigurationSaving = true` reuses the last profile by splitting `folder/file.json`; keep this parsing intact.  
- `ConfigurationSaving.AutoSave = false` disables background writes; keep `_autoSave` guard in sync if you extend persistence.  
- Profiles tab auto-injects when configuration saving is enabled; customise via `ConfigurationManager` or disable it entirely when embedding bespoke controls.  
- When touching persistence code, verify the executor supports `writefile/readfile/isfile` and rerun a full save → load cycle with all 12 elements.

### Profiles Tab behaviours
- Dropdown always re-scans on open and after Save/Save As/Delete; do not reintroduce cached lists.  
- `SetConfigProfile` now updates the in-memory context and `_lastContext`; keep this when adding profile shortcuts.  
- Deleting the active profile clears selection and labels—ensure any future UI also handles this case.  
- Auto-save toggle mirrors `RvrseUI:SetAutoSaveEnabled`; avoid writing alternate toggles that bypass the guard.

## Minimize Chip Alignment
- Chip drag now respects `ScreenGui.IgnoreGuiInset` and clamps using camera viewport size. If you change the host container, update the inset logic in `WindowBuilder` accordingly.

## Overlay Layer & Dropdowns
- `init.lua` provisions `RvrseUI_Overlay`; reuse it for any future popovers so stacking order stays predictable.  
- Dropdown element default is `Overlay = true`; set `Overlay = false` for legacy inline menus.  
- Overlay mode requires the blocker to close menus—preserve `ensureBlocker()` and `setOpen(false)` patterns when extending.  
- When adding new overlay elements, clamp to `OverlayLayer.ZIndex` ≥ 200 to keep them above the base window.

## Hotkey Pipeline
- `Hotkeys:Initialize` immediately wires `InputBegan` and prevents double hookups. Ensure any future hotkey changes toggle `_initialized` carefully.

## Debug & Version helpers
- `Debug.printf` is relied on throughout `WindowBuilder`; keep it exported when refactoring the debug module.  
- `Version` exposes fields via metatable—always update `Version.Data` rather than reassigning properties directly.

## Quick Validation Checklist
1. Toggle each element flag, call `SaveConfiguration`, restart script, confirm values restore.  
2. If auto-save is disabled, ensure manual saves still write expected profiles.  
3. Minimize to the 🎮 chip, drag around edges, restore, then destroy via `Escape`.  
4. Open dropdowns on top of dense layouts and verify overlay blockers close them.  
5. Confirm `ToggleUIKeybind` still acts globally after any hotkey changes.  
6. Run docs build (README badge/version) when bumping releases.
