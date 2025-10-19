# Reference Documentation

This directory contains **canonical reference implementations** and best practices. These are the "source of truth" for specific patterns.

## Contents

### Drag System
- **SIMPLE_DRAG_REFERENCE.lua** - The canonical Roblox drag pattern (see CLAUDE.md Warning #1)
  - Classic delta calculation (no AbsolutePosition math)
  - Works with any AnchorPoint value
  - Zero drift, perfect cursor lock
  - **Always use this pattern for drag implementations!**

## Why References?

These files represent **proven, battle-tested patterns** that should be copied exactly when implementing similar features. They are:
- **Minimal** - No unnecessary complexity
- **Correct** - Verified to work in production
- **Documented** - Explain why they work
- **Canonical** - The official way to do something

## Adding New References

When adding a reference file:
1. Ensure it's a minimal, complete example
2. Add inline comments explaining WHY (not just what)
3. Test it thoroughly in production
4. Link it from CLAUDE.md if it's a critical pattern
5. Update this README

---

*Last updated: 2025-10-18*
