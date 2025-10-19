# Documentation

## 📁 Directory Structure

```
docs/
├── README.md (this file)
├── CHANGELOG.md - Version history and release notes
├── DEV_NOTES.md - Development notes and decisions
├── DIRECTORY.md - Repository file structure guide
│
├── archived/ - Historical documentation (kept for reference)
│   ├── README.md
│   ├── DRAG_FIX_PROPOSAL.md - v4.0.4 drag system analysis
│   ├── DRAG_TEST_HUB.lua - Drag debugging harness
│   ├── DROPDOWN_*.md - Dropdown fix documentation (v4.1.0)
│   └── ...
│
├── references/ - Canonical implementations (source of truth)
│   ├── README.md
│   └── SIMPLE_DRAG_REFERENCE.lua - Standard drag pattern
│
├── DEBUGGING-WORKFLOW.md - Debugging methodology
├── HELPER-RESTRICTIONS.md - UIHelpers usage rules
├── UI-ARCHITECTURE.md - Complete UI system architecture
│
├── PHASE2_COMPLETION.md - Phase 2 completion guide
├── PHASE2_QUICK_REFERENCE.md - Quick reference card
│
└── __archive/ - Complete historical snapshots
    ├── 2025-10-09/ - Pre-Phase 2 docs
    └── 2025-10-16/ - Repository cleanup docs
```

## 📚 Key Documentation

### For Users
- **[README.md](../README.md)** - Main project README (installation, quick start, API)
- **[VERSION.json](../VERSION.json)** - Changelog with all features/fixes
- **[examples/](../examples/)** - Working code examples

### For Developers
- **[CLAUDE.md](../CLAUDE.md)** - Maintainer guide & critical warnings
- **[UI-ARCHITECTURE.md](./UI-ARCHITECTURE.md)** - System architecture deep dive
- **[DEBUGGING-WORKFLOW.md](./DEBUGGING-WORKFLOW.md)** - How to debug issues
- **[HELPER-RESTRICTIONS.md](./HELPER-RESTRICTIONS.md)** - UIHelpers usage rules

### For AI Assistants
- **[CLAUDE.md](../CLAUDE.md)** - Complete AI assistant guide
  - Critical warnings (drag, shadow, closures, particles)
  - Build system rules
  - Version bump checklist
  - Common pitfalls

## 🗂️ Organization Principles

### `archived/`
- Historical documentation superseded by current docs
- Kept for context and learning from past mistakes
- NOT actively maintained

### `references/`
- Canonical "source of truth" implementations
- Copy these patterns exactly when implementing features
- Actively maintained and tested

### `__archive/`
- Complete historical snapshots from major milestones
- Immutable - never modified after creation
- Useful for understanding evolution of the codebase

---

**Last Updated:** 2025-10-18
