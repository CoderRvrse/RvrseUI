# RvrseUI Releases

## Version 4.8.0 "Free Pass" - A Free Key Button, Built In
**Release Date**: October 23, 2026
**Build**: 20261023a
**Hash**: `LVMFREE80`
**Channel**: Stable

- **The key window can now hand out a free 24-hour key, paid for by ads.** One button walks the whole way: it asks the licence server for an ad link, copies it to the clipboard (an executor cannot open a browser), then watches for the key by itself and fills it in. The player types nothing.
- **No hub has to build or configure any of this.** Any hub that already sets `KeySettings.License` gets the button. The free routes are worked out from the endpoint the hub already has, so there is no second URL to set, and a server with free keys switched off answers `off`, which makes the button take itself away. Opt out with `License.FreeKey = false` - which makes no server call at all.
- **A device that still holds a live free key is handed it straight back**, with no ad run, so a reinstall does not cost a player anything and keys cannot be farmed.
- The key goes through the ordinary validate path, so saving, webhooks and the `OnKeyValid` callback behave exactly as they do for a key somebody typed.
- Tapping the button again checks immediately, for anyone who does not want to wait for the next poll. It stops checking after five minutes and says so.
- New: `KeySystem:StartFreeKey(license)` and `KeySystem:ClaimFreeKey(code, license)` for anyone driving this themselves.
- Gate: a `freekey` scenario in `node tests/headless/license_run.js` covers every answer the server can give, a reply that is not JSON, and the opt-out making no call.

## Version 4.7.1 "Asked Once" - No Double Check
**Release Date**: October 18, 2026
**Build**: 20261018b
**Hash**: `LVMKEY71`
**Channel**: Stable

- A full-lock LUAVM-Rvrse build cannot start until the license server answers VALID: that answer is literally what decrypts it. The build now leaves the answer in `getgenv().LUAVM_LICENSE_OK`, and the key window takes its word for it, so a licensed launch asks the server **once** instead of twice.
- Only a receipt for the same key, marked `VALID` and under five minutes old, is trusted. A stale, mismatched, unstamped or non-VALID receipt falls back to a real server call exactly as before, and a build made before this change simply re-checks, as it always did.
- This is a front door, not a lock, and is not meant to be one: the script is already running by the time a key window appears, and the real lock is full-lock's encryption. A forged receipt skips the front door, not the lock.
- New gate: `node tests/headless/license_run.js` drives the key window and counts the calls it makes to the server, so a change that quietly re-checks every launch fails the build.

## Version 4.7.0 "Licensed Keys" - Server-Checked Keys
**Release Date**: October 18, 2026
**Build**: 20261018a
**Hash**: `LVMKEY70`
**Channel**: Stable

- `KeySettings.License = { Endpoint = "...", BuildId = "...", Secret = nil }` makes the key window ask a LUAVM-Rvrse license server instead of checking a key list written into the file. The server decides, so the valid keys never ship with the hub, and it enforces expiry, bans and one device per key.
- It is Method 0 inside `ValidateKey`, so `SaveKey`, `WebhookURL`, `MaxAttempts`, `OnKeyValid`, `OnKeyInvalid`, `OnAttemptsExhausted` and the Get-Key button all keep working. Answers map to plain reasons: `Licensed (1h left)`, `This key has expired`, `This key is banned`, `Invalid key or wrong device`, `Could not reach the license server`.
- One key covers both the window and a full-lock build: the device id is computed exactly as the LUAVM loader computes it, and a key already in `getgenv().LUAVM_LICENSE_KEY` is checked silently so a buyer never types it twice.
- **The key box is paste-proof.** A pasted key carries junk no one can see (a trailing newline, a non-breaking space, a smart dash from autocorrect), and a server that compares exactly then refuses a perfectly good key. `CleanKey` strips all of it before any check sees the key; `RepairKey` only runs after a real rejection, so it can never alter an accepted key.
## Version 4.6.0 "On Top, Mouse Free" - Always On Top
**Release Date**: October 11, 2026
**Build**: 20261011b
**Hash**: `0NT0PM5E`
**Channel**: Stable

### Highlights
- **Game screens no longer cover RvrseUI.** Its screens sat in PlayerGui at DisplayOrder 999 (100 in `init.lua`), so any game screen above that drew over the window and took its clicks. They now use the three largest orders (windows 2147483645, lists and colour panels 2147483646, the pointer 2147483647). They stay in PlayerGui, where hubs already out there look for the window (the X button, to hook their own shutdown).
- **New: `CreateWindow{ AlwaysOnTop = true }`** moves RvrseUI's screens into the executor's hidden folder (`gethui`), else CoreGui. Roblox draws those above every PlayerGui screen whatever its order, and the game's own scripts can't see them. While Roblox's own Esc menu is open RvrseUI steps aside there, and comes back when it closes. Where neither folder takes a screen (a plain game script) the screens stay in PlayerGui.
  **A hub that asks for it must use `Window:OnClose` for its shutdown**: a search of PlayerGui for the X button no longer finds it. That is why it is off by default.
- **No more wrap-round.** 2147483647 is the largest DisplayOrder and one more wraps to the very bottom; the dropdown / colour-panel screen and the dropdown fallback screen now stop below it.
- **The mouse is free in first-person games** while a window is on screen (an invisible `Modal` button: Roblox unlocks the mouse and locks it again when the window is minimised or closed; the game's mouse settings are never written). Only on a device with a mouse: a touch screen behaves exactly as before.
- **RvrseUI's own pointer**: where the game hid the pointer, RvrseUI draws Roblox's own arrow at the mouse while a window is on screen, above everything.
- `CreateWindow{ UnlockMouse = false }` leaves the mouse and the pointer to the game.

### Verification
- `node tests/headless/run.js`: new `ontop`, `ontop_hidden`, `ontop_coregui` and `ontop_playergui` scenarios (17 in all), each beside a game screen already at 2147483647: where the screens are (PlayerGui by default even when CoreGui is writable; the hidden folder / CoreGui / PlayerGui when `AlwaysOnTop` is asked for), their orders, the mouse freed while open and given back when minimised, nothing freed or drawn without a mouse, the pointer drawn only when the game hid its own and following the mouse, the Esc menu step-aside outside PlayerGui only, nothing left after close. `ontop` FAILS on 4.5.2 (16 checks); 15 of 16 mutations of the change are caught (the 16th is a second guard that the first already covers).
- LUAVM-Rvrse `run_autoshutdown_tests.ps1`: a first design that moved the screens out of PlayerGui by default FAILED it (a hub that hooks its shutdown on the X in PlayerGui never restored the world). With PlayerGui as the default it passes.
- Roblox Studio: CoreGui above a PlayerGui screen at 2147483647 (click test); a DisplayOrder set to 2147483657 is stored as -2147483648; writing `MouseBehavior` back on change leaves it locked at the end of every render step (120/120 frames), hence the Modal button.

## Version 4.5.2 "Fits Anywhere" - Phone Fit
**Release Date**: October 11, 2026
**Build**: 20261011a
**Hash**: `M0B1L3F7`
**Channel**: Stable

### Highlights
- **The window fits the screen.** It asks for 580x480 (a touch screen held upright: 380x520) and takes at most the room below Roblox's top bar. On a phone held sideways (about 750x381) the old fixed 380x520 window was tall and narrow, ran 140px off the bottom and sat in the top bar; now it is 580 wide, all of it on the screen. It is fitted again when the screen changes size, and it can't be dragged off the screen. A desktop still gets 580x480.
- **Labels are never covered.** On a narrow card the dropdown button, text box and key button give way; every control label is cut with "..." instead of running under its control.
- **Text cards are as tall as their text.** Paragraph and Label used to guess 50 characters a line and cut the text on phones.
- **Colour picker panel**: on the right of the screen, centred top to bottom, drawn smaller on a short screen. It used to start 52px below the middle and run off the bottom (on desktops too). Its rows are in order again (RGB, HSV, Hex Code).
- **Dropdown lists** near the bottom of the screen stay on it (they ran off by the top bar's height).
- **Keybind button can be seen.** Its highlight gradient hid it until clicked. On a touch screen with no keyboard a tap no longer waits for a key forever.
- **New**: `ColorPicker:SetOpen(state)`, like a dropdown's `SetOpen`.

### Verification
- `node tests/headless/run.js`: new `mobile` scenario (12 scenarios in all): the window fits a 750x381 sideways phone below the top bar and is centred there, the colour panel opens on the screen, the key button is not hidden, turned upright (381x750) the window is fitted again and no control covers its label, a window opened where the last one was left lands below the top bar; every other scenario checks a desktop still gets 580x480. It FAILS on 4.5.1 (8 checks); 11 of 11 mutations of the fix are caught.
- Roblox Studio, Device emulator on a phone (750x381, touch only): window, labels, paragraph, key button, colour panel and dropdown list all on the screen.

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
