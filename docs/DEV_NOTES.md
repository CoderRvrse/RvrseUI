# RvrseUI - Developer Notes & Changelog

**Internal documentation for developers and contributors.**

For user documentation, see [README.md](README.md).
For build system and architecture, see [CLAUDE.md](CLAUDE.md).

---

## 📋 Version History & Changelog

### v4.3.1 (2025-10-20)

#### 🎮 Token Icon Customization (Controller Chip)
- **What's new:** The minimize chip uses the shared Lucide resolver and exposes full customization hooks.
- **Global API:** `RvrseUI:SetTokenIcon(icon, opts)` / `GetTokenIcon()` – update color, fallback glyph, or reset to defaults without touching source.
- **Per-window API:** `Window:SetTokenIcon(icon, opts)` / `GetTokenIcon()` – override icons on a per-hub basis (e.g., themed executors).
- **Config keys:** `TokenIcon`, `TokenIconColor`, and `TokenIconFallback` (aliases `ControllerIcon*`) can be passed to `CreateWindow`.
- **Theme aware:** When `UseThemeColor` or no color override is provided, the chip auto-adopts the active accent on theme switches.
- **QA checklist:** Rebuild (`lua tools/build.lua`), run `examples/test-lucide-icons.lua`, minimize/restore to verify sprite + fallback, then test `RvrseUI:SetTokenIcon("lucide://sparkles")` in Studio.

### v4.3.2 (2025-10-21)

#### 💾 Auto Hydration of Config Flags
- **Problem solved:** Saved configs restored UI values but did not re-run `OnChanged` callbacks, forcing
  every script to write bespoke hydration logic.
- **Core change:** `Config:LoadConfiguration` now queues each restored flag and calls the element’s
  new `Hydrate(value)` helper once the load finishes.
- **Elements updated:** Slider, Toggle, ColorPicker, TextBox (with optional `FireOnConfigLoad = false`
  escape hatch). Additional elements can adopt the same pattern over time.
- **Docs & tooling:** README updated with guidance; `examples/test-config-hydration.lua` showcases the
  flow; AGENTS.md quality gate now reminds authors to opt out only when they plan to manually hydrate.
- **QA checklist:**
  1. Run the hydration example, adjust values, `SaveConfiguration`, restart, and confirm printed
     callbacks fire immediately on load.
  2. Verify opt-out (`FireOnConfigLoad = false`) skips the automatic callback and that scripts reapply
     state manually when doing so.
  3. Confirm no duplicate callback is fired when users adjust values post-load (Set with silent update
     remains default).

### v4.3.0 (2025-10-20)

#### 🚨 Critical Alert: Lucide Sprite Sheet Load Failure
- **Symptom:** Console shows `❌ Failed to load Lucide icons sprite sheet` followed by repeated `[LUCIDE] ⚠️ Sprite sheet not loaded, using fallback...`
- **Cause:** `RvrseUI.lua` was rebuilt without embedding `_G.RvrseUI_LucideIconsData` (usually because the build script was skipped or an older bundle was pushed).
- **Fix Workflow (DO NOT SKIP):**
  1. Run `lua tools/build.lua` from repo root to regenerate `RvrseUI.lua`.
  2. Open the output and confirm the header reads v4.3.0+ and that `_G.RvrseUI_LucideIconsData` appears near the bottom.
  3. Execute `examples/test-lucide-icons.lua`; expect `[LUCIDE] ✅ Sprite sheet data loaded successfully` with zero fallback warnings.
  4. Commit the updated `src/` files *and* `RvrseUI.lua`, then push. Never ship source-only or bundle-only changes.
- **Reminder:** This outage already occurred three times. Treat the error as a release blocker—halt merges until the checklist passes.

### v4.0.4 (2025-10-18)

#### 🎯 CRITICAL FIX: Complete Drag System Rewrite - Back to Basics!
- **Problem:** Window and controller chip "kicked away" from cursor during drag
- **Root Cause:** Overcomplicated drag logic with AbsolutePosition/AnchorPoint math introduced offset bugs
- **Solution:** Replaced ~600 lines of complex code with ~140 lines of classic Roblox drag pattern
- **Result:** No jumps, no offset drift, cursor stays glued to grab point! ✅

**The Simple Pattern:**
```lua
-- Store starting positions
local dragStart = input.Position
local startPos = frame.Position

-- Calculate delta and apply
local delta = input.Position - dragStart
frame.Position = UDim2.new(
    startPos.X.Scale,
    startPos.X.Offset + delta.X,
    startPos.Y.Scale,
    startPos.Y.Offset + delta.Y
)
```

**What Was Removed:**
- ❌ AbsolutePosition calculations and GUI inset handling
- ❌ AnchorPoint math and coordinate space conversions
- ❌ Size locking systems and hover animation blocking
- ✅ Kept: Animation blocking during minimize/restore tweens

**Metrics:**
- 65% code reduction (400 lines → 140 lines)
- Simpler is better!

**Files Modified:**
- `src/WindowBuilder.lua` - Lines 319-382 (window drag), 1177-1257 (chip drag)
- `RvrseUI.lua` - Rebuilt monolith
- `SIMPLE_DRAG_REFERENCE.lua` - Created reference implementation

---

### v4.0.3 (2025-10-17)

#### 🎉 CRITICAL FIX: Multi-Select Dropdown Blocker Now Works!
- **Fixed Modern Dropdown** - Multi-select now closes properly when clicking outside! ✅
- **Root Cause:** **Lua closure upvalue capture bug** - closures capture VALUES not references
- **The Bug:** Wrapper function `closeDropdown()` captured `setOpen` as `nil` at definition time
- **The Fix:** Use inline anonymous functions created at connection point (inside `setOpen` body)
- **Evidence:** Logs showed `setOpen` was `function` when connecting, but `nil` when handler fired!
- **Result:** Dropdown blocker now works perfectly - clicks close the dropdown as expected

**Before (Broken):**
```lua
local setOpen
local function closeDropdown() return setOpen end  -- Captures nil!
setOpen = function() end  -- Too late, closeDropdown has nil
```

**After (Fixed):**
```lua
local setOpen
setOpen = function()
    Connect(function() return setOpen end)  -- Captures current scope!
end
```

**Testing:**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/examples/test-dropdown-simple.lua"))()
```
✅ Select multiple colors
✅ Click outside the dropdown (on dimmed area)
✅ Dropdown closes successfully!

---

### v4.0.2 (2025-10-16)

#### Previous Fixes
- **Error Fixed:** `:3853: attempt to call a nil value` when closing multi-select dropdown
- **Root Cause:** Function scoping issue - `setOpen()` called before being declared
- **Solution:** Added forward declaration `local setOpen` before blocker creation
- **DropdownLegacy Note:** Does NOT support multi-select (single-select only)

---

### v4.0.1 (2025-10-15)

#### 🚨 Shadow Helper Blocking Overlays
- **Fixed ColorPicker** - Removed shadow() causing gray box to cover entire screen
- **Fixed Dropdown (both versions)** - Removed shadow() on dropdown menus
- **Root Cause:** `UIHelpers.shadow()` creates ImageLabel 40px larger than parent
- **Solution:** Disabled shadow() for ALL overlay elements, use stroke() instead

**Elements Fixed:**
- `ColorPicker.lua:196` - `shadow(pickerPanel, 0.7, 20)` → DISABLED
- `Dropdown.lua:180` - `shadow(dropdownList, 0.6, 16)` → DISABLED
- `DropdownLegacy.lua:91` - `shadow(dropdownList, 0.6, 16)` → DISABLED

**Rule:** Never use `shadow()` on overlay panels or dropdown menus!

---

### v4.0.0 (2025-10-10) - Phase 2 Release

#### Phase 2 Features
- **🎨 Advanced ColorPicker** - Full RGB/HSV sliders + Hex input (NOW WORKING!)
- **📋 Dropdown Multi-Select** - Checkboxes, SelectAll/ClearAll methods
- **🔐 KeySystem Integration** - Advanced key validation with lockout protection
- **🔄 100% Rayfield API Compatible** - Migrate from Rayfield with zero changes!

#### Critical Bug Fixes (v4.0)
- **✅ Fixed Flag System** - Now uses `RvrseUI.Flags` (not `Window.Flags`)
- **✅ Fixed Config Loading** - Values now restore correctly on startup
- **✅ Fixed Dropdown Pre-selection** - `CurrentOption` now works perfectly

#### What Makes RvrseUI Different
- ✅ **Actually works** - Configs save and load correctly
- ✅ **Clear documentation** - No confusing references
- ✅ **Production tested** - Used in real hubs
- ✅ **Rayfield compatible** - Drop-in replacement

---

## 🔧 Technical Implementation Notes

### Drag System Architecture (v4.0.4)

**Classic Roblox Pattern - The ONLY way to do drag:**
```lua
local dragging = false
local dragStart = nil
local startPos = nil

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position      -- Store mouse start
        startPos = frame.Position       -- Store frame start
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
```

**Why This Works:**
- Roblox's UDim2 system handles ALL coordinate transformations
- `input.Position` is screen-space, `UDim2` is UI-space - Roblox converts automatically
- Simple delta calculation: `currentMouse - startMouse = howMuchToMove`
- Apply that movement to where the frame started: `startFrame + movement = newFrame`
- **NO MATH NEEDED!** Just subtraction and addition!

**NEVER:**
- ❌ Use AbsolutePosition for drag logic (it's for reading, not calculating)
- ❌ Do AnchorPoint math (UDim2 system handles it)
- ❌ Calculate GUI inset (not needed with this pattern)
- ❌ Convert coordinate spaces (stay in input.Position space)
- ❌ Lock sizes during drag (not needed)
- ❌ Disable hover animations (not needed)

See `SIMPLE_DRAG_REFERENCE.lua` for the canonical pattern.

---

### Lua Closure Upvalue Capture (v4.0.3)

**Critical Bug Pattern:**
```lua
local setOpen  -- Forward declaration (setOpen = nil at this point)

-- ❌ BROKEN - closeDropdown captures setOpen's CURRENT value (nil)
local function closeDropdown()
    if setOpen then  -- This captures nil from line above!
        setOpen(false)
    end
end

-- Later...
setOpen = function(state)  -- Assigned here, but closeDropdown already has nil!
    showOverlayBlocker()
    overlayBlocker.MouseButton1Click:Connect(closeDropdown)  -- Handler has nil!
end
```

**Fix - Use Inline Anonymous Functions:**
```lua
local setOpen  -- Forward declaration

setOpen = function(state)
    showOverlayBlocker()

    -- ✅ CORRECT - Create closure at connection point, INSIDE setOpen body
    overlayBlocker.MouseButton1Click:Connect(function()
        if setOpen then  -- Captures setOpen from CURRENT scope (exists!)
            setOpen(false)
        end
    end)
end
```

**Rules:**
- ❌ NEVER define wrapper functions early that reference forward-declared variables
- ✅ ALWAYS use inline anonymous functions created at the connection point
- ✅ ALWAYS create closures INSIDE the function body where the variable is assigned

---

### UIHelpers.shadow() Restriction (v4.0.1)

**NEVER use `shadow()` helper on overlay panels or dropdown menus!**

The `shadow()` helper creates an ImageLabel that extends **40px beyond the parent element**. For overlay panels (ColorPicker, Dropdown), this created a **giant gray box covering the entire screen**. Shadow ZIndex = parent.ZIndex - 1, blocking ALL UI below it.

**Rules:**
- ✅ USE shadow() ONLY on small inline elements (< 60px, ZIndex < 100)
  - Button elements, Toggle thumbs, Slider thumbs
- ❌ NEVER use shadow() on:
  - Overlay panels (ColorPicker, Dropdown, Modals)
  - Large containers (> 100px)
  - Elements with high ZIndex (> 100)
  - Scrolling frames, Popup elements

**Alternative:** Use `stroke()` for visual definition on overlay panels.

---

## 🐛 Known Issues & Gotchas

### Flag System Confusion
**Issue:** Users forget to add `Flag` parameter and wonder why settings don't save.
**Solution:** Clear documentation in README.md section "Configuration System (THE MOST IMPORTANT SECTION!)".

### Window.Flags vs RvrseUI.Flags
**Issue:** `Window.Flags` doesn't exist - must use `RvrseUI.Flags`.
**Solution:** Documented in troubleshooting section.

### Window:Show() Timing
**Issue:** Config doesn't load if `Window:Show()` called too early.
**Solution:** ALWAYS call `Window:Show()` LAST after creating all elements.

### Dropdown CurrentOption Format
**Issue:** Rayfield uses `{"Option"}` table format, users expect string.
**Solution:** Full Rayfield compatibility maintained.

---

## 📊 Code Metrics

### Build Statistics (v4.0.4)
- **Total Modules:** 28
- **Total Lines (compiled):** ~5,500 lines in RvrseUI.lua
- **File Size:** ~260 KB (RvrseUI.lua monolith)
- **Element Count:** 10 UI elements
- **Drag System:** 140 lines (down from 400 - 65% reduction)

### Module Breakdown
- **Foundation:** 3 modules (Version, Debug, Obfuscation)
- **Data:** 2 modules (Icons, Theme)
- **Systems:** 3 modules (Animator, State, UIHelpers)
- **Services:** 6 modules (Config, WindowManager, Hotkeys, Notifications, Overlay, KeySystem)
- **Elements:** 10 modules (Button, Toggle, Dropdown, DropdownLegacy, Slider, Keybind, TextBox, ColorPicker, Label, Paragraph, Divider)
- **Builders:** 3 modules (SectionBuilder, TabBuilder, WindowBuilder)

---

## 🧪 Testing Checklist

### Before Release
- [ ] Toggle each element flag, call `SaveConfiguration`, restart script, confirm values restore
- [ ] If auto-save is disabled, ensure manual saves still write expected profiles
- [ ] Minimize to the 🎮 chip, drag around edges, restore, then destroy via `Escape`
- [ ] Open dropdowns on top of dense layouts and verify overlay blockers close them
- [ ] Confirm `ToggleUIKeybind` still acts globally after any hotkey changes
- [ ] Test drag systems (window header + controller chip) with debug logging
- [ ] Verify multi-select dropdown blocker closes on click outside
- [ ] Test ColorPicker advanced mode (RGB/HSV/Hex all in sync)
- [ ] Test KeySystem validation (valid/invalid keys, lockout behavior)
- [ ] Run docs build (README badge/version) when bumping releases

### Drag System Testing
```lua
-- Enable debug mode to see drag logging
RvrseUI:EnableDebug(true)

-- Test window header drag
-- 1. Click anywhere on the header
-- 2. Drag - cursor should stay locked to exact grab point
-- 3. Check console for: "[DRAG] Cached offset: X=..., Y=..."

-- Test controller chip drag
-- 1. Minimize window
-- 2. Click on 🎮 chip
-- 3. Drag - chip should follow cursor perfectly from grab point
-- 4. Check console for: "[CHIP DRAG] Cached grab offset: X=..., Y=..."
```

---

## 🔄 Version Bump Process

**When releasing a new version, update ALL these files:**

```bash
# 1. VERSION.json
{
  "version": {
    "patch": 4,           # Increment
    "full": "4.0.4",      # Update
    "build": "20251018",  # YYYYMMDD
    "hash": "R9B4K3X7"    # New random hash
  },
  "changelog": {
    "4.0.4": {            # Add new entry
      "changes": [...]
    }
  }
}

# 2. README.md
![Version](https://img.shields.io/badge/version-4.0.4-blue)
![Build](https://img.shields.io/badge/build-260KB-orange)

# 3. CLAUDE.md (header)
# RvrseUI – Maintainer Notes (v4.0.4)

# 4. src/Version.lua
Version.Data = {
  Patch = 4,
  Full = "4.0.4",
  Build = "20251018",
  Hash = "R9B4K3X7"
}

# 5. tools/build.lua and tools/build.lua (version banners)
console.log('🔨 RvrseUI v4.0.4 Build Script');
const header = `-- RvrseUI v4.0.4 | Modern Professional UI Framework

# 6. Rebuild
lua tools/build.lua

# 7. Commit everything together
git add VERSION.json README.md CLAUDE.md DEV_NOTES.md src/Version.lua tools/build.lua tools/build.lua RvrseUI.lua
git commit -m "chore: bump version to v4.0.4"
git push origin main
```

**⚠️ The pre-push hook will block if version files are inconsistent!**

---

## 📚 Additional Developer Resources

- **Architecture & Build System:** [CLAUDE.md](CLAUDE.md)
- **User Documentation:** [README.md](README.md)
- **Version History:** [VERSION.json](VERSION.json) (changelog section)
- **Archived Tests:** `docs/__archive/2025-10-09/TEST_ALL_FEATURES.lua`
- **GitHub Repository:** https://github.com/CoderRvrse/RvrseUI
- **GitHub Issues:** https://github.com/CoderRvrse/RvrseUI/issues

---

**Last Updated:** 2025-10-18 (v4.0.4 - Drag System Rewrite)
