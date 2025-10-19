# 📁 Repository Structure

## Root Directory

```
RvrseUI/
├── 📂 .vscode/              VSCode editor settings
├── 📂 .claude/              Claude Code commands
├── 📂 docs/                 📚 Documentation
├── 📂 examples/             🧪 Example scripts & tests
├── 📂 src/                  💻 Source code (modules)
│
├── 📄 build.js              🔨 Build script (Node.js)
├── 📄 build.lua             🔨 Build script (Lua fallback)
├── 📄 CHANGELOG.md          📝 Version history
├── 📄 CLAUDE.md             🤖 AI maintainer guide
├── 📄 init.lua              🚀 Modular entry point
├── 📄 LICENSE               ⚖️ MIT License
├── 📄 README.md             📖 Main documentation
├── 📄 RvrseUI.lua           📦 Production build (monolith)
└── 📄 VERSION.json          🏷️ Version metadata
```

---

## 📂 Directory Details

### `/src/` - Source Code
**The source of truth for all modules**

```
src/
├── Version.lua           # Version metadata
├── Debug.lua             # Debug logging system
├── Obfuscation.lua       # Name obfuscation
├── Theme.lua             # Dark/Light themes
├── Animator.lua          # Spring animations
├── State.lua             # Global state management
├── Config.lua            # Persistence system
├── Icons.lua             # Icon library
├── UIHelpers.lua         # UI utilities
├── Notifications.lua     # Toast notifications
├── Hotkeys.lua           # Hotkey management
├── WindowManager.lua     # Window coordination
├── Overlay.lua           # Overlay layer
├── WindowBuilder.lua     # Window construction
├── TabBuilder.lua        # Tab construction
├── SectionBuilder.lua    # Section construction
└── Elements/             # UI Elements (10 total)
    ├── Button.lua
    ├── Toggle.lua
    ├── Dropdown.lua
    ├── Slider.lua
    ├── Keybind.lua
    ├── TextBox.lua
    ├── ColorPicker.lua   # ✨ Phase 2: RGB/HSV/Hex
    ├── Label.lua
    ├── Paragraph.lua
    └── Divider.lua
```

**⚠️ Important:** Always edit files in `src/`, never `RvrseUI.lua` directly!

---

### `/docs/` - Documentation
**All project documentation and guides**

```
docs/
├── README.md                    # Documentation index
├── PHASE2_COMPLETION.md         # Phase 2 full guide
├── PHASE2_QUICK_REFERENCE.md    # Phase 2 quick ref
└── __archive/                   # Historical docs
    ├── 2025-10-09/              # Pre-Phase 2
    └── 2025-10-16/              # Cleanup docs
```

---

### `/examples/` - Examples & Tests
**Example scripts and test suites**

```
examples/
├── README.md           # Examples index
└── phase2-test.lua     # Phase 2 feature tests
```

**Load remotely:**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/examples/phase2-test.lua"))()
```

---

## 🔧 Build System

### Source Files → Monolith
```bash
# Edit source
vim src/Elements/ColorPicker.lua

# Build monolith
node build.js

# Test compiled
# Load RvrseUI.lua in Roblox

# Commit both
git add src/Elements/ColorPicker.lua RvrseUI.lua
git commit -m "feat: update ColorPicker"
```

### Build Scripts
- **`build.js`** - Primary build script (Node.js, preferred)
- **`build.lua`** - Fallback build script (Pure Lua)

Both produce the same output: `RvrseUI.lua` (228 KB)

---

## 📖 Key Files

### User Documentation
- **`README.md`** - Main project documentation
- **`CHANGELOG.md`** - Version history and updates
- **`LICENSE`** - MIT License

### Developer Documentation
- **`CLAUDE.md`** - AI maintainer guide (architecture, patterns, rules)
- **`DIRECTORY.md`** - This file (repository structure)
- **`VERSION.json`** - Version metadata and changelog

### Entry Points
- **`RvrseUI.lua`** - Production build (use this in Roblox)
- **`init.lua`** - Modular entry point (development)

---

## 🚀 Quick Start Paths

### For Users:
1. Read [README.md](./README.md)
2. Load `RvrseUI.lua` in your script
3. Check [examples/](./examples/) for usage

### For Contributors:
1. Read [CLAUDE.md](./CLAUDE.md)
2. Edit files in `src/`
3. Run `node build.js`
4. Test and commit

### For AI Assistants:
1. **Read [CLAUDE.md](./CLAUDE.md) first** (architecture and rules)
2. Check [DIRECTORY.md](./DIRECTORY.md) (this file)
3. Review source in `src/`
4. Follow documented workflows

---

## 📊 File Counts

- **Source Files:** 26 modules
- **Build Output:** 1 monolith (228 KB)
- **Documentation:** 4 active docs
- **Examples:** 1 test suite
- **Total Lines:** ~6,000 lines of Lua

---

## 🗑️ What's NOT in Root

**Archived (in `docs/__archive/`):**
- Old redesign documentation
- Historical build scripts
- Version check utilities
- Backup files

**Ignored (in `.gitignore`):**
- `*.backup.lua`
- `*.old.lua`
- `*.tmp`
- Node modules
- Test outputs

---

## 🔍 Finding Things

### "Where is the ColorPicker source?"
→ `src/Elements/ColorPicker.lua`

### "Where is the Phase 2 documentation?"
→ `docs/PHASE2_COMPLETION.md`

### "Where can I find examples?"
→ `examples/` directory

### "How do I build?"
→ Run `node build.js` or `lua build.lua`

### "What's the production file?"
→ `RvrseUI.lua` (228 KB monolith)

### "Where are old docs?"
→ `docs/__archive/`

---

**Last Updated:** 2025-10-16
**Structure Version:** 2.0 (Post-Cleanup)
