# Repository Cleanup Plan

## 📊 Current State Analysis

### ✅ Keep in Root (Active/Important):
- `README.md` - Main documentation
- `LICENSE` - License file
- `CLAUDE.md` - AI maintainer guide (current)
- `VERSION.json` - Version metadata
- `CHANGELOG.md` - Version history
- `RvrseUI.lua` - **Production build (main)**
- `init.lua` - Modular entry point
- `build.js` - **Active build script**
- `build.lua` - **Active Lua fallback**
- `src/` - **Source code directory**
- `.gitignore`, `.git/`, `.vscode/`, `.claude/` - Config dirs

### 📁 Archive to docs/__archive/2025-10-16/:
1. **Old Documentation:**
   - `REDESIGN_V4.md` (Oct 10)
   - `REDESIGN_PROGRESS.md` (Oct 10)
   - `REDESIGN_COMPLETE_PHASE1.md` (Oct 10)
   - `TRANSFORMATION_COMPLETE.md` (Oct 10)
   - `WINDOW_CHROME_COMPLETE.md` (Oct 10)

2. **Old Build Scripts:**
   - `BUILD_MONOLITHIC.js` (Oct 9 - superseded by build.js)

3. **Old Verification Files:**
   - `INITIALIZE_VERIFICATION.txt` (Oct 9)
   - `VERSION_CHECK.lua` (Sep 30 - not used)

4. **Backup Files:**
   - `RvrseUI_BACKUP_v2.8.4.lua` (Oct 2)

### 📌 Move to docs/ (Current Phase Docs):
- `PHASE2_COMPLETION.md` → `docs/PHASE2_COMPLETION.md`
- `PHASE2_QUICK_REFERENCE.md` → `docs/PHASE2_QUICK_REFERENCE.md`

### 📝 Rename (Better Organization):
- `-- ⚠️ Development only - Use for testing.lua` → `examples/phase2-test.lua`

## 🎯 Ideal Root Structure After Cleanup:

```
RvrseUI/
├── .git/                           # Git metadata
├── .github/                        # GitHub workflows (future)
├── .vscode/                        # VSCode settings
├── .claude/                        # Claude Code commands
├── docs/                           # Documentation
│   ├── PHASE2_COMPLETION.md       # Phase 2 docs
│   ├── PHASE2_QUICK_REFERENCE.md  # Phase 2 reference
│   └── __archive/                 # Historical docs
│       ├── 2025-10-09/            # Pre-Phase 2
│       └── 2025-10-16/            # Today's cleanup
├── examples/                       # Example scripts
│   └── phase2-test.lua            # Phase 2 test suite
├── src/                           # Source modules
│   └── Elements/                  # All elements
├── .gitignore                     # Git ignore rules
├── build.js                       # Node.js build script
├── build.lua                      # Lua fallback build
├── CHANGELOG.md                   # Version history
├── CLAUDE.md                      # Maintainer guide
├── init.lua                       # Modular entry point
├── LICENSE                        # MIT License
├── README.md                      # Main docs
├── RvrseUI.lua                    # Production build
└── VERSION.json                   # Version metadata
```

## 🗂️ Actions to Take:

1. Create `docs/__archive/2025-10-16/`
2. Move old docs to archive
3. Create `examples/` directory
4. Move test file to examples
5. Move Phase 2 docs to docs/
6. Delete obsolete files
7. Update README with new structure
8. Commit cleanup
