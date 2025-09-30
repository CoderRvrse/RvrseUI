# Version Update Checklist

This guide ensures consistent version updates before pushing to main.

## 📋 Pre-Push Checklist

Before pushing to `main`, update these 3 files:

### 1. **RvrseUI.lua** (Lines 21-29)
```lua
RvrseUI.Version = {
	Major = 2,        -- Breaking changes
	Minor = 1,        -- New features (backward compatible)
	Patch = 1,        -- Bug fixes only
	Build = "YYYYMMDD",  -- Today's date: YYYYMMDD
	Full = "2.1.1",      -- "Major.Minor.Patch"
	Hash = "B9E4D7F1",   -- 8-char hex (generate new)
	Channel = "Stable"   -- Stable, Beta, or Dev
}
```

**When to increment:**
- **Major**: Breaking API changes, complete rewrites
- **Minor**: New features, new components (backward compatible)
- **Patch**: Bug fixes, small improvements, UI tweaks

### 2. **VERSION.json** (Lines 2-16 + Changelog)
```json
{
  "version": {
    "major": 2,
    "minor": 1,
    "patch": 1,
    "full": "2.1.1",
    "build": "YYYYMMDD",
    "hash": "B9E4D7F1",
    "channel": "Stable"
  },
  "release": {
    "date": "YYYY-MM-DD",
    "name": "Release Name",
    "codename": "Codename",
    "notes": "Brief summary"
  }
}
```

**Also add to changelog section:**
```json
"changelog": {
  "2.1.1": {
    "date": "YYYY-MM-DD",
    "hash": "B9E4D7F1",
    "changes": [
      "Change 1",
      "Change 2"
    ]
  }
}
```

### 3. **RELEASES.md** (Top of file)
Add new release section at the top:

```markdown
## Version X.Y.Z "Codename" - Release Name
**Release Date**: Month DD, YYYY
**Build**: YYYYMMDD
**Hash**: `ABCD1234`
**Channel**: Stable

### ✨ New Features
- Feature 1
- Feature 2

### 🎨 Improvements
- Improvement 1

### 🐛 Bug Fixes
- Fix 1

### 📊 Technical Details
```lua
RvrseUI.Version = { ... }
```
```

**Also update:**
- Version History Summary table
- Expected Hashes list

## 🔢 Hash Generation

Generate a unique 8-character hash for each release:
```bash
# Option 1: From git commit
git rev-parse --short=8 HEAD | tr 'a-z' 'A-Z'

# Option 2: Random hex
openssl rand -hex 4 | tr 'a-z' 'A-Z'

# Option 3: From date + random
echo "$(date +%Y%m%d)$RANDOM" | md5sum | cut -c1-8 | tr 'a-z' 'A-Z'
```

## 📅 Build Date Format

Always use `YYYYMMDD` format:
```bash
date +%Y%m%d
# Example: 20250929
```

## 🚀 Quick Update Command

```bash
# Get today's date
BUILD_DATE=$(date +%Y%m%d)
echo "Build: $BUILD_DATE"

# Generate hash
NEW_HASH=$(openssl rand -hex 4 | tr 'a-z' 'A-Z')
echo "Hash: $NEW_HASH"

# Update files manually with these values
```

## ⚙️ Git Pre-Push Hook

The pre-push hook (`.git/hooks/pre-push`) will:
- Warn if VERSION.json, RELEASES.md, or RvrseUI.lua weren't updated
- Show today's build date
- Ask for confirmation before pushing

## 📝 Commit Message Format

```
🔖 Release vX.Y.Z - Release Name

- Change 1
- Change 2
- Change 3

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## ✅ Verification

After updating, verify:
```lua
local RvrseUI = loadstring(game:HttpGet("..."))()
local info = RvrseUI:GetVersionInfo()
print("Version:", info.Version)  -- "2.1.1"
print("Hash:", info.Hash)        -- "B9E4D7F1"
```

---

**Last Updated**: September 29, 2025