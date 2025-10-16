# Examples

This directory contains example scripts and test suites for RvrseUI.

## 📝 Files

### [phase2-test.lua](./phase2-test.lua)
**Phase 2 Feature Test Suite**

Comprehensive test script demonstrating:
- Advanced ColorPicker with RGB/HSV/Hex controls
- Dropdown Multi-Select with checkboxes
- Rayfield API compatibility examples
- All Phase 2 features and API methods

**Usage:**
```lua
-- Load from GitHub (always latest)
loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/examples/phase2-test.lua"))()
```

**Features Tested:**
- ✅ ColorPicker RGB sliders (0-255)
- ✅ ColorPicker HSV sliders (H: 0-360°, S/V: 0-100%)
- ✅ ColorPicker Hex input (#RRGGBB)
- ✅ Dropdown multi-select with checkboxes
- ✅ Dropdown single-select
- ✅ Rayfield API syntax (Options, CurrentOption, MultipleOptions)
- ✅ RvrseUI API syntax (Values, MultiSelect)
- ✅ Configuration persistence
- ✅ All element methods (Set, Get, SelectAll, ClearAll)

---

## 🚀 Running Examples

### In Roblox Executor:
```lua
-- Load example directly
loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/examples/phase2-test.lua"))()
```

### In Roblox Studio:
1. Create a LocalScript in StarterPlayer > StarterPlayerScripts
2. Copy the example code into the script
3. Run the game (F5)

---

## 📚 More Resources

- [Phase 2 Documentation](../docs/PHASE2_COMPLETION.md)
- [Quick Reference](../docs/PHASE2_QUICK_REFERENCE.md)
- [Main README](../README.md)

---

**Note:** These examples are for testing and demonstration purposes. Use them as templates for your own projects!
