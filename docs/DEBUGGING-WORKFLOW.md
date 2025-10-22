# RvrseUI Debugging Workflow

## 🎯 Purpose

This document provides a **step-by-step workflow** for debugging GUI issues in RvrseUI using the new Inspector tool.

---

## 🔧 Tools Available

### 1. **GUI Inspector** (`tools/gui-inspector.lua`)
- Visual tree view of entire GUI hierarchy
- Detailed property viewer
- Click elements to inspect them
- Shows Position, Size, Visibility, Transparency, ZIndex, Parent

### 2. **Debug Logs** (in ColorPicker and other elements)
- Console output showing initialization
- Shows when elements are created
- Shows when functions are called

### 3. **UI Architecture Doc** (`docs/UI-ARCHITECTURE.md`)
- Reference guide for GUI structure
- ZIndex layer map
- Parenting rules
- Common issues and solutions

---

## 🚨 Critical Alert: Lucide Sprite Sheet Not Loading

If testers report logs like:

```
⚠️ [RvrseUI] ❌ Failed to load Lucide icons sprite sheet
[LUCIDE] ⚠️ Sprite sheet not loaded, using fallback for: sparkles
```

execute this fix immediately:

1. Run `lua tools/build.lua` in the repo root to regenerate `RvrseUI.lua`. The build injects `_G.RvrseUI_LucideIconsData`; without it, every icon falls back to text.
2. Inspect the regenerated `RvrseUI.lua` and confirm both the v4.3.0 header and the `_G.RvrseUI_LucideIconsData` blob exist.
3. Launch `examples/test-lucide-icons.lua` in Studio/executor and watch the console. Only proceed if you see `[LUCIDE] ✅ Sprite sheet data loaded successfully`.
4. Commit and push the updated monolith together with any source changes.

Do **not** allow a release to proceed while the console still shows fallback warnings—this issue has already resurfaced three times when rebuild steps were skipped.

---

## 📋 Debugging ColorPicker Panel (Current Issue)

### Step 1: Load Test Script

```lua
-- In Roblox console:
loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/examples/test-colorpicker-simple.lua"))()
```

**Expected Output:**
```
[ColorPicker] Creating ColorPicker, Advanced = true
[ColorPicker] OverlayLayer from deps: Frame
[ColorPicker] OverlayService: table
[ColorPicker] Panel created:
  Parent: Frame
  Parent Name: RvrseUI_OverlayLayer
  ... (more logs)
```

### Step 2: Launch GUI Inspector

```lua
-- In Roblox console:
loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/tools/launch-inspector.lua"))()
```

**You should see:**
- Inspector window appears (draggable)
- Left panel: Tree view of all GUI elements
- Right panel: Details view (empty until you click)

### Step 3: Find ColorPickerPanel in Tree

1. Look for `RvrseUI_Overlay` in the tree
2. Expand it (if collapsed)
3. Look for `RvrseUI_OverlayLayer`
4. Look for `ColorPickerPanel` under it

**What to check:**
- ✅ Does `ColorPickerPanel` exist?
- ✅ Is it under `RvrseUI_OverlayLayer`?
- ❌ Is it under a different parent (like the element card)?

### Step 4: Inspect ColorPickerPanel Properties

Click `ColorPickerPanel` in the tree view.

**Right panel should show:**
```
ClassName: Frame
Parent: RvrseUI_OverlayLayer  ← CRITICAL: Should be OverlayLayer!
Position: {1, -326}, {0.5, 52}
AbsolutePosition: (X, Y)  ← Should be on-screen
Size: {0, 320}, {0, 0}  ← Collapsed initially
AbsoluteSize: (320, 0)
Visible: false  ← Should be true when open
BackgroundTransparency: 0  ← Should be opaque
BackgroundColor3: RGB(...)
ZIndex: 5000  ← Should be high
ClipsDescendants: false  ← Should be false!
AnchorPoint: (0, 0)
```

### Step 5: Click ColorPicker Preview Circle

1. Close inspector (or move it aside)
2. Click the orange circle in the test UI
3. Watch console for debug logs

**Expected Console Output:**
```
[ColorPicker] setPickerOpen called, state = true
[ColorPicker] Opening panel...
[ColorPicker] Showing blocker...
[ColorPicker] Blocker shown: Frame
[ColorPicker] Setting panel visible...
[ColorPicker] Panel state after visible:
  Visible: true  ← Should be true!
  Size: {0, 320},{0, 0}
  AbsoluteSize: 320, 0
  Parent: Frame
[ColorPicker] Layout calculated, targetHeight = 380
[ColorPicker] Starting animation to height: 380
[ColorPicker] Animation started
[ColorPicker] Panel opened successfully
```

### Step 6: Re-Inspect ColorPickerPanel (After Opening)

1. Click 🔄 Refresh in inspector
2. Find `ColorPickerPanel` again
3. Check properties again

**Now it should show:**
```
Visible: true  ← Changed from false
Size: {0, 320}, {0, 380}  ← Should animate to 380!
AbsoluteSize: (320, 380)  ← Full height
```

### Step 7: Analyze Findings

Compare the properties **before** and **after** clicking:

| Property | Before Click | After Click | Expected After |
|----------|-------------|-------------|----------------|
| Visible | false | ??? | **true** |
| Size.Y.Offset | 0 | ??? | **380** |
| AbsoluteSize.Y | 0 | ??? | **380** |
| Parent | ??? | ??? | **RvrseUI_OverlayLayer** |

**Common Issues:**

1. **Panel stays `Visible = false`**
   - Fix: Check `setPickerOpen` is being called
   - Fix: Check no errors in console

2. **Panel's `Size` doesn't change**
   - Fix: Animation not working
   - Fix: Check `Animator:Tween` is running

3. **Panel parented to wrong element**
   - Fix: `baseOverlayLayer` is nil
   - Fix: Need to pass `OverlayLayer` in deps

4. **Panel off-screen**
   - Fix: Check `AbsolutePosition`
   - Fix: Adjust `Position` calculation

---

## 🔍 General Debugging Workflow

### For ANY GUI Issue:

#### Step 1: Check Console Logs
```
F9 in Roblox → Console tab
Look for [ElementName] logs
Check for warnings/errors
```

#### Step 2: Launch Inspector
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/tools/launch-inspector.lua"))()
```

#### Step 3: Find Element in Tree
- Navigate tree structure
- Look for element by name
- Check if it exists at all

#### Step 4: Inspect Properties
- Click element in tree
- View all properties in detail panel
- Compare with expected values

#### Step 5: Check Common Issues
- [ ] **Parent** - Is it correct?
- [ ] **Visible** - Is it true?
- [ ] **Size** - Is it > 0?
- [ ] **Position** - Is it on-screen?
- [ ] **Transparency** - Is it visible (not 1)?
- [ ] **ZIndex** - Is it high enough?
- [ ] **ClipsDescendants** - Should be false for overlays

#### Step 6: Check Parent Chain
```
Element
  → Parent
    → Parent's Parent
      → etc. up to ScreenGui
```

Make sure no parent has:
- `Visible = false`
- `BackgroundTransparency = 1` (if no other visible children)
- `ClipsDescendants = true` (if child is outside bounds)

#### Step 7: Check ScreenGui
- Find root ScreenGui in tree
- Check `DisplayOrder` (higher = on top)
- Check `ZIndexBehavior` (should be Sibling)
- Check `Enabled` (should be true)

---

## 📊 Inspector Features Reference

### Tree View (Left Panel)
- **Color bars**: Show element type
  - Blue: ScreenGui
  - Purple: Frame
  - Orange: ScrollingFrame
  - Green: TextLabel
  - Pink: TextButton
  - Lime: TextBox
  - Yellow: ImageLabel
  - Light Blue: ImageButton
- **Indentation**: Shows hierarchy depth
- **[ClassName]**: Shows element type
- **Click**: Select element to see details

### Details View (Right Panel)
Shows all properties for selected element:
- **Basic**: ClassName, Parent
- **Position**: Position, AbsolutePosition
- **Size**: Size, AbsoluteSize
- **Visibility**: Visible, BackgroundTransparency
- **Color**: BackgroundColor3 (RGB)
- **Layering**: ZIndex
- **Clipping**: ClipsDescendants (for Frames)
- **Anchor**: AnchorPoint
- **ScreenGui**: DisplayOrder, ZIndexBehavior, IgnoreGuiInset

### Window Controls
- **Drag**: Click and drag header to move
- **Close**: Red ✕ button (top right)
- **Refresh**: 🔄 button (top right) - Rescan GUI tree

---

## 💡 Tips & Tricks

### Tip 1: Use Refresh After Changes
If you modify the GUI (click buttons, open menus), click 🔄 Refresh to update the tree.

### Tip 2: Check AbsoluteSize vs Size
- `Size` is what you set (Scale + Offset)
- `AbsoluteSize` is actual pixels on screen
- If `AbsoluteSize = (0, 0)`, element is invisible even if `Visible = true`

### Tip 3: Check Parent's ClipsDescendants
If parent has `ClipsDescendants = true`, child elements outside parent bounds are invisible.

### Tip 4: ZIndex Only Matters for Siblings
Elements in different parents use their parent's ZIndex, not their own.

### Tip 5: DisplayOrder Trumps ZIndex
ScreenGui with higher DisplayOrder always renders on top, regardless of ZIndex.

---

## 🚨 Red Flags (Common Issues)

### 🔴 Element exists but invisible
- [ ] Check `Visible = true`
- [ ] Check `BackgroundTransparency < 1`
- [ ] Check `Size > {0,0},{0,0}`
- [ ] Check `Position` is on-screen
- [ ] Check parent's `Visible = true`
- [ ] Check parent's `ClipsDescendants`

### 🔴 Element not in tree
- [ ] Check if it was created at all
- [ ] Check console for errors during creation
- [ ] Check if it was destroyed immediately

### 🔴 Wrong parent
- [ ] Check where element is parented
- [ ] Should overlay elements parent to `RvrseUI_OverlayLayer`
- [ ] Should inline elements parent to `Section` or `TabPage`

### 🔴 Element behind other elements
- [ ] Check ZIndex (higher = on top)
- [ ] Check ScreenGui DisplayOrder
- [ ] Check if blocker is covering it

### 🔴 Animation not working
- [ ] Check Size before/after animation
- [ ] Check console for animation errors
- [ ] Check if `Animator:Tween` is being called

---

## 📝 Checklist Template

Use this when debugging:

```
Element Name: _______________________
Issue: _______________________

□ Element exists in tree
□ Parent is correct: _______________________
□ Visible: _______
□ Size: _______ x _______
□ AbsoluteSize: _______ x _______
□ Position on-screen: _______
□ BackgroundTransparency: _______
□ ZIndex: _______
□ ClipsDescendants: _______
□ Parent's Visible: _______
□ Parent's ClipsDescendants: _______
□ ScreenGui DisplayOrder: _______

Console logs:
_______________________
_______________________
_______________________

Conclusion:
_______________________
```

---

## 🎓 Example: Debugging Dropdown Menu

**Issue:** Dropdown menu not showing when clicked

**Step 1: Console Logs**
```
[Dropdown] Creating menu...
[Dropdown] Menu parent: Section_Content  ← ❌ Should be OverlayLayer!
```

**Step 2: Inspector**
- Find `DropdownMenu` in tree
- Parent shows: `Section_Content`
- Parent's `ClipsDescendants = true`
- Menu is outside parent bounds → Clipped!

**Step 3: Fix**
```lua
-- Change parent from Section to OverlayLayer
menu.Parent = dependencies.OverlayLayer  -- Not dependencies.sectionContent!
```

**Step 4: Test**
- Rebuild RvrseUI
- Test again
- Menu now shows correctly

---

## 🔗 Related Documentation

- [UI Architecture](UI-ARCHITECTURE.md) - Complete GUI tree reference
- [CLAUDE.md](../CLAUDE.md) - Developer maintainer guide
- [README.md](../README.md) - User documentation

---

**Use this workflow whenever you encounter GUI visibility issues!**
