# RvrseUI Releases

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
