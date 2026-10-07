# RvrseUI Releases

## Version 4.5.1 "Jump To" - Select Tab
**Release Date**: October 7, 2026  
**Build**: 20261007a  
**Hash**: `S3L7T4B1`  
**Channel**: Stable

### Highlights
- **`Window:SelectTab(target)`** switches tabs from code, the same as clicking the tab. `target` is one of:
  - a position: `Window:SelectTab(1)` is the first tab created, `2` the second, and so on;
  - a tab Title: `Window:SelectTab("Settings")`;
  - the tab itself: `Window:SelectTab(SettingsTab)`.

  It returns `true` when a tab was selected. A target that matches no tab prints one warning and returns `false`; it never errors, and it returns `false` once the window is closed.
- **Fix**: the method did not exist before, so a script that called it stopped with `attempt to call a nil value`. `Window:SelectTab(1)` is a common last line in hubs ported from other UI libraries; the window was already on screen, but nothing after that line ran.
- **Quieter console**: the ColorPicker's diagnostic lines print only when debug is on (`RvrseUI:EnableDebug(true)`). Live on `main` since October 7, first listed here.

### Verification
- `node tests/headless/run.js`: new `selecttab` scenario (10 scenarios in all). Position, Title and tab object each switch the page, exactly one tab stays marked active, seven kinds of bad target return `false` with one warning each and no error, and a call after close returns `false`. The scenario fails on the v4.5.0 file.

## Version 4.5.0 "No Trace" - Clean Close
**Release Date**: October 5, 2026  
**Build**: 20261005a  
**Hash**: `L1F3C7Y5`  
**Channel**: Stable

### Highlights
- **Closing really closes**: the X button, `Window:Destroy()`, `RvrseUI:Destroy()` and the destroy key now share one teardown that releases everything RvrseUI started. v4.3.31 left ~38 live connections (input listeners for every Slider/Dropdown/Keybind/ColorPicker slider, window/chip drag, two per-frame Heartbeats) and the overlay ScreenGui behind; v4.5.0 leaves none.
- **One window at a time**: closing one window no longer wipes every other RvrseUI window on screen. The last window to close still removes the shared host, overlay, hotkeys and particle loop.
- **Lifecycle API for scripts**:
  - `Window:OnClose(fn)` or `CreateWindow({ OnClose = fn })` — runs once, with the reason (`"close-button"`, `"destroy"`, `"destroy-key"`, `"rvrseui-destroy"`).
  - `Window:Track(item)` — connections, threads, Instances or cleanup functions released on close.
  - `Window:IsDestroyed()`.
  - `CreateWindow({ TurnOffTogglesOnClose = true })` — ON toggles run their own `OnChanged(false)` on close; per-toggle `TurnOffOnClose` overrides. Saved configs keep the ON state.
- **Build fixed**: `tools/build.js` / `tools/build.lua` wrap every module in `do ... end` again. The 4.4.x builds skipped that, so WindowBuilder's private `local Theme, Obfuscation, ...` shadowed the real modules and the file died at load (`attempt to index nil with 'Initialize'`). Both scripts now produce identical output.
- **FilterableList is live** (it never shipped in a working 4.4.x build). Global search (4.4.1) stays removed.

### Verification
- `node tests/headless/run.js` (new): runs the real `RvrseUI.lua` in a strict Roblox mock — 9 scenarios (X, `Window:Destroy`, `RvrseUI:Destroy`, destroy key, two windows, close with dropdown + color picker open, reopen after close, `TurnOffTogglesOnClose` + config saving, `Window:Track`) → 0 connections, 0 ScreenGuis, 0 errors after close.

---

## Version 4.4.1 "Quick Find" - Global Search
**Release Date**: December 9, 2025  
**Build**: 20251209b  
**Hash**: `G2S8R5C1`  
**Channel**: Stable

### Highlights
- **Global Search**: Added a search button to the window header (next to minimize) with Ctrl+F keyboard shortcut!
- Real-time search across all tabs, sections, and elements with debounced input.
- Click search results to navigate directly to the element and highlight it.
- Results show element type, path (Tab > Section), and icon preview.
- Press Escape to close the search overlay.

### 📊 Technical Details
```lua
Version = {
  Major = 4,
  Minor = 4,
  Patch = 1,
  Build = "20251209b",
  Full = "4.4.1",
  Hash = "G2S8R5C1",
  Channel = "Stable"
}
```

### Verification Checklist
- Search button visible in window header (magnifying glass icon).
- Ctrl+F opens search overlay.
- Typing filters all elements across all tabs.
- Clicking a result navigates to and highlights the element.
- Escape closes the search.

---

## Version 4.4.0 "Dynamic Lists" - Live Filter
**Release Date**: December 9, 2025  
**Build**: 20251209a  
**Hash**: `F1L7R4B9`  
**Channel**: Stable

### Highlights
- **NEW ELEMENT**: FilterableList - Live-filterable scrollable lists with real-time search!
- Built-in search input with debounced filtering.
- Perfect for item fetchers, player lists, teleport locations.

---

## Version 4.3.31 "Holo Brand" - Iconic Identity
**Release Date**: December 2, 2025  
**Build**: 20251202e  
**Hash**: `F8A2C9D4`  
**Channel**: Stable

### Highlights
- Added a custom SVG favicon with a neon 'R' logo to fix 404 errors and brand the browser tab.
- Updated `index.html` to link the new SVG favicon.

### 📊 Technical Details
```lua
Version = {
  Major = 4,
  Minor = 3,
  Patch = 31,
  Build = "20251202e",
  Full = "4.3.31",
  Hash = "F8A2C9D4",
  Channel = "Stable"
}
```

### Verification Checklist
- Browser tab shows a neon "R" icon.
- No more 404 errors for favicon in console.
- Footer/hero badges show v4.3.31.

---

## Version 4.3.30 "Holo Audio" - Sonic Control
**Release Date**: December 2, 2025  
**Build**: 20251202d  
**Hash**: `E5F8A2C9`  
**Channel**: Stable

### Highlights
- Added native video controls to the hero showcase so users can unmute and replay the video manually.
- Clarified autoplay behavior: video must start muted to bypass browser blocking policies.

### 📊 Technical Details
```lua
Version = {
  Major = 4,
  Minor = 3,
  Patch = 30,
  Build = "20251202d",
  Full = "4.3.30",
  Hash = "E5F8A2C9",
  Channel = "Stable"
}
```

### Verification Checklist
- Video player shows controls (play/pause, volume, fullscreen).
- Video still autoplays muted on load.
- Footer/hero badges show v4.3.30.

---

## Version 4.3.29 "Holo Split" - Neon Drift
**Release Date**: December 2, 2025  
**Build**: 20251202c  
**Hash**: `B2D5F8A1`  
**Channel**: Stable

### Highlights
- Background bubbles now feature a dual-tone split: Cyan on the left, Magenta on the right, matching the RvrseUI banner aesthetic.
- Updated bubble shimmer and glow effects to respect the new color variables.
- Bumped version metadata to v4.3.29.

### 📊 Technical Details
```lua
Version = {
  Major = 4,
  Minor = 3,
  Patch = 29,
  Build = "20251202c",
  Full = "4.3.29",
  Hash = "B2D5F8A1",
  Channel = "Stable"
}
```

### Verification Checklist
- Bubbles on the left are Cyan, bubbles on the right are Magenta.
- Footer/hero badges show v4.3.29.

---

## Version 4.3.28 "Holo Stream" - Showcase Flight
**Release Date**: December 2, 2025  
**Build**: 20251202b  
**Hash**: `9F6C1E3B`  
**Channel**: Stable

### Highlights
- Hero section now plays `RvrseUI.mp4` inline with autoplay/loop so visitors immediately view the UI in action.
- Bubble field background received more nodes, shimmer animation, and varied speeds to feel alive instead of static.
- Updated all metadata references to v4.3.28 to align with the release guard.

### 📊 Technical Details
```lua
Version = {
  Major = 4,
  Minor = 3,
  Patch = 28,
  Build = "20251202b",
  Full = "4.3.28",
  Hash = "9F6C1E3B",
  Channel = "Stable"
}
```

### Verification Checklist
- Hero video autoplays muted/looping and falls back to download link if unsupported.
- Bubble field shows varied bubble sizes with shimmer.
- Footer/hero badges show v4.3.28.

---

## Version 4.3.27 "Holo Glide" - Neon Scroll Suite
**Release Date**: December 2, 2025  
**Build**: 20251202a  
**Hash**: `C1E8D4A6`  
**Channel**: Stable

### Highlights
- Replaced default browser scrollbars with neon, rounded rails across the entire site so long docs feel native to the cyber UI.
- Mini code panes now use matching low-profile scrollbars, keeping demo snippets premium even when the content overflows.
- Updated hero/footer badges and metadata to v4.3.27 for push guard compliance.

### 📊 Technical Details
```lua
Version = {
  Major = 4,
  Minor = 3,
  Patch = 27,
  Build = "20251202a",
  Full = "4.3.27",
  Hash = "C1E8D4A6",
  Channel = "Stable"
}
```

### Verification Checklist
- Observe neon scrollbar on the main page + code blocks (Chrome, Edge, etc.).
- Hero badge + footer show v4.3.27.
- No regression in scroll performance or layout spacing.

---

## Version 4.3.26 "Nav Pulse" - Neon Flight Deck
**Release Date**: December 1, 2025  
**Build**: 20251201c  
**Hash**: `F4D1B7E9`  
**Channel**: Stable

### Highlights
- Top navigation now rides inside a glowing capsule with animated underlines and scroll-based compression so the site feels like an executor flight deck.
- Added a floating "Back to top" control that fades in after long scrolls and snaps users back to the hero with smooth animation.
- Rebuilt the developer doc area into three tactical steps (boot, persist, gate) with bulletproof copy so builders know exactly how to deploy RvrseUI.

### 📊 Technical Details
```lua
Version = {
  Major = 4,
  Minor = 3,
  Patch = 26,
  Build = "20251201c",
  Full = "4.3.26",
  Hash = "F4D1B7E9",
  Channel = "Stable"
}
```

### Verification Checklist
- Scroll down: nav condenses and "Back to top" button fades in.
- Doc section shows Step 01–03 cards with copy buttons + context bullets.
- Footer + hero badge display v4.3.26.

---

## Version 4.3.25 "Holo Cards" - Docs Neon Enhancements
**Release Date**: December 1, 2025  
**Build**: 20251201b  
**Hash**: `A8E5C9B2`  
**Channel**: Stable

### Highlights
- Element demo tiles received taller padding, tighter typography, and more generous code wells so long snippets stay readable on desktop and mobile.
- Every snippet on the site (quick start, demos, doc playbooks) now ships with a neon copy button plus JS helper for instant clipboard access.
- Copy feedback uses the same glow palette with temporary "Copied" state so users know their command is ready to paste.
- Visible release references (hero badge + footer) updated to v4.3.25 to mirror repository metadata.

### 📊 Technical Details
```lua
Version = {
  Major = 4,
  Minor = 3,
  Patch = 25,
  Build = "20251201b",
  Full = "4.3.25",
  Hash = "A8E5C9B2",
  Channel = "Stable"
}
```

### Verification Checklist
- Copy buttons appear on the quick start block, each element tile, and all developer doc snippets.
- Copy buttons flip to "Copied" for ~1.6 seconds after use, then reset automatically.
- `docs/index.html` and `docs/styles.css` load without console errors and remain responsive across breakpoints.

---

## Version 4.3.24 "Nebula Docs" - Docs Microsite Launch
**Release Date**: December 1, 2025  
**Build**: 20251201a  
**Hash**: `D2F7A5C1`  
**Channel**: Stable

### Highlights
- GitHub Pages microsite replaces the long-form README with a polished hero, quick-start snippet, and resource navigation.
- Element reference tiles now include copy/paste ready demos so developers can grab snippets immediately.
- New developer-doc playbooks show how to boot the library, wire configuration profiles, and enable the key system in three quick steps.
- README slimmed down to the banner, docs link, and loadstring so the repo points users straight to the site.

### 📊 Technical Details
```lua
Version = {
  Major = 4,
  Minor = 3,
  Patch = 24,
  Build = "20251201a",
  Full = "4.3.24",
  Hash = "D2F7A5C1",
  Channel = "Stable"
}
```

### Verification Checklist
- Pages source is set to `main` / `docs` in GitHub settings.
- README banner points to https://coderrvrse.github.io/RvrseUI/.
- `docs/index.html` renders hero, quick-start tile, demo cards, and developer-doc section without missing assets.

---

For historical notes prior to v4.3.24 see `docs/CHANGELOG.md` and the archive under `docs/__archive/`.
