# RvrseUI - Complete UI Architecture Documentation

> **Purpose:** This document provides a complete map of RvrseUI's GUI tree, layer hierarchy, parenting rules, and how every element fits together. Use this as the **single source of truth** when debugging overlay issues, element visibility problems, or adding new features.

---

## 🏗️ Complete GUI Tree Structure

```
PlayerGui (CoreGui)
│
├─── RvrseUI_Host (ScreenGui) ──────────────────┐ DisplayOrder = 999
│    │                                           │ IgnoreGuiInset = true
│    │                                           │ ResetOnSpawn = false
│    │                                           │ ZIndexBehavior = Sibling
│    │
│    ├─── [Window1] (Frame) ─────────────────┐  ZIndex = 100
│    │    │ Name: "Window_{WindowName}"       │  Position: UDim2.new(0.5, 0, 0.5, 0)
│    │    │ Size: 580x480                     │  AnchorPoint: (0.5, 0.5)
│    │    │                                   │
│    │    ├─── Header (Frame) ─────────────┐  ZIndex = 1 (relative)
│    │    │    ├─── Icon (TextLabel)        │  Position: (0, 12, 0, 0)
│    │    │    ├─── Title (TextLabel)       │  Position: (0, 36, 0, 0)
│    │    │    ├─── MinimizeBtn (TextButton)│  Position: (1, -52, 0, 0)
│    │    │    └─── CloseBtn (TextButton)   │  Position: (1, -12, 0, 0)
│    │    │                                   │
│    │    ├─── Content (Frame) ────────────┐  ZIndex = 1 (relative)
│    │    │    │ Position: (0, 10, 0, 52)   │  ClipsDescendants = true
│    │    │    │                             │
│    │    │    ├─── TabRail (Frame) ───────┐  Position: (0, 0, 0, 0)
│    │    │    │    └─── [Tab Buttons]      │  Size: 80x428
│    │    │    │                             │
│    │    │    └─── Body (Frame) ──────────┐  Position: (0, 80, 0, 0)
│    │    │         │ Size: 472x396         │  ClipsDescendants = true
│    │    │         │                        │
│    │    │         └─── [TabPage] (ScrollingFrame) ─┐
│    │    │              │ Name: "TabPage_{TabTitle}" │
│    │    │              │                             │
│    │    │              └─── [Sections] (Frame) ────┐
│    │    │                   │                        │
│    │    │                   └─── [Elements] ───────┐
│    │    │                        ├─── Button (Frame)  ZIndex = 1
│    │    │                        ├─── Toggle (Frame)  ZIndex = 1
│    │    │                        ├─── Slider (Frame)  ZIndex = 1
│    │    │                        ├─── Keybind (Frame) ZIndex = 1
│    │    │                        ├─── TextBox (Frame) ZIndex = 1
│    │    │                        ├─── Label (Frame)   ZIndex = 1
│    │    │                        ├─── Paragraph (Frame) ZIndex = 1
│    │    │                        ├─── Divider (Frame) ZIndex = 1
│    │    │                        │
│    │    │                        ├─── Dropdown (Frame) ────────┐
│    │    │                        │    │ ZIndex = 1              │
│    │    │                        │    │                         │
│    │    │                        │    └─── [Menu in Overlay]   │ → See Overlay Layer
│    │    │                        │
│    │    │                        └─── ColorPicker (Frame) ─────┐
│    │    │                             │ ZIndex = 1              │
│    │    │                             │                         │
│    │    │                             └─── [Panel in Overlay]  │ → See Overlay Layer
│    │    │
│    │    └─── ControllerChip (Frame) ──┐  Hidden by default
│    │         │ Name: "ControllerChip"  │  Shows when minimized
│    │         │ Size: 40x40             │  Draggable
│    │         │ AnchorPoint: (0.5, 0.5) │  ZIndex = 5000
│    │         └─── Icon: "🎮"           │
│    │
│    └─── [Window2, Window3...] (More windows)
│
│
└─── RvrseUI_Overlay (ScreenGui) ───────────────┐ DisplayOrder = 20000 ⭐ CRITICAL
     │ Name: "RvrseUI_Overlay"                   │ IgnoreGuiInset = true
     │                                           │ ResetOnSpawn = false
     │                                           │ ZIndexBehavior = Sibling
     │
     ├─── RvrseUI_OverlayLayer (Frame) ────────┐ ZIndex = 20000 ⭐ CRITICAL
     │    │ Name: "RvrseUI_OverlayLayer"        │ Size: (1, 0, 1, 0) - Full screen
     │    │ BackgroundTransparency = 1          │ Position: (0, 0, 0, 0)
     │    │ Parent: RvrseUI_Overlay             │
     │    │                                     │
     │    ├─── Blocker (Frame) ────────────────┐ ZIndex = 4999 (when shown)
     │    │    │ Name: "OverlayBlocker"         │ Size: (1, 0, 1, 0) - Full screen
     │    │    │ BackgroundColor3: (0,0,0)      │ Transparency: 0.45
     │    │    │ Visible: false (shown on demand)│
     │    │    └─── (Clicks close overlays)     │
     │    │
     │    ├─── Dropdown Menus ─────────────────┐ ZIndex = 5000
     │    │    │ Parented here when Overlay=true│
     │    │    │                                 │
     │    │    └─── [DropdownMenu] (Frame) ────┐
     │    │         ├─── SearchBox (if enabled) │
     │    │         └─── Options (ScrollingFrame)
     │    │              └─── [Option Buttons]  │
     │    │
     │    ├─── ColorPicker Panels ──────────────┐ ZIndex = 5000 ⭐ THIS IS THE ISSUE
     │    │    │ Should be parented here!       │
     │    │    │                                 │
     │    │    └─── [ColorPickerPanel] (Frame) ┐
     │    │         ├─── RGB Section            │
     │    │         │    ├─── R Slider          │
     │    │         │    ├─── G Slider          │
     │    │         │    └─── B Slider          │
     │    │         ├─── HSV Section            │
     │    │         │    ├─── H Slider          │
     │    │         │    ├─── S Slider          │
     │    │         │    └─── V Slider          │
     │    │         └─── Hex Input (TextBox)    │
     │    │
     │    └─── Notifications ────────────────────┐ ZIndex = 10000
     │         │ Position: Top-right corner      │
     │         │                                  │
     │         └─── [Toast] (Frame) ─────────────┐
     │              ├─── Icon (TextLabel)        │
     │              ├─── Title (TextLabel)       │
     │              └─── Message (TextLabel)     │
     │
     └─── (Future overlay elements here)
```

---

## 📊 ZIndex Layer Map

| Layer | ZIndex | Purpose | Elements |
|-------|--------|---------|----------|
| **Base UI** | 100 | Main window container | Window frames |
| **Window Content** | 1 (relative) | Tabs, sections, elements | All inline elements |
| **Blocker** | 4999 | Semi-transparent click blocker | Closes dropdowns/pickers |
| **Overlay Elements** | 5000 | Dropdown menus, color pickers | Floating panels |
| **Controller Chip** | 5000 | Minimized window chip | Draggable 🎮 button |
| **Notifications** | 10000 | Toast notifications | Top-right toasts |
| **Overlay Container** | 20000 | Root overlay ScreenGui | RvrseUI_Overlay |

### ZIndex Rules

1. **DisplayOrder trumps ZIndex** - `RvrseUI_Overlay` (DisplayOrder=20000) always renders above `RvrseUI_Host` (DisplayOrder=999)
2. **Siblings use ZIndex** - Within same parent, higher ZIndex renders on top
3. **Relative ZIndex** - Elements inside windows use relative ZIndex (1-10)
4. **Blocker is below overlays** - ZIndex 4999 < 5000, so menus/pickers render above blocker

---

## 🎯 Element Parenting Rules

### Inline Elements (Parent to TabPage)
These elements are **always parented to the Section**, which is inside the TabPage:

- ✅ Button
- ✅ Toggle
- ✅ Slider
- ✅ Keybind
- ✅ TextBox
- ✅ Label
- ✅ Paragraph
- ✅ Divider

**Why?** They scroll with the tab content.

### Overlay Elements (Parent to Overlay Layer)
These elements have **floating panels** that must parent to `RvrseUI_OverlayLayer`:

- ✅ **Dropdown** (when `Overlay = true`)
  - Base element: Parented to Section
  - Menu panel: Parented to **OverlayLayer**

- ✅ **ColorPicker** (when `Advanced = true`)
  - Base element: Parented to Section
  - Picker panel: Parented to **OverlayLayer** ⭐ **THIS IS THE BUG**

**Why?** Floating panels need to render above all other UI, not get clipped by scrolling frames.

### Notification Elements (Parent to Overlay Layer)
- ✅ **Toast notifications**
  - Always parented to **OverlayLayer**
  - ZIndex = 10000 (above everything)

---

## 🔧 Overlay System Deep Dive

### How Overlay Works

```lua
-- 1. Overlay is initialized in bootstrap (init.lua or build scripts)
Overlay:Initialize()

-- 2. Creates RvrseUI_Overlay ScreenGui
local overlayGui = Instance.new("ScreenGui")
overlayGui.Name = "RvrseUI_Overlay"
overlayGui.DisplayOrder = 20000  -- Above main UI
overlayGui.IgnoreGuiInset = true
overlayGui.ResetOnSpawn = false
overlayGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
overlayGui.Parent = game.CoreGui or game.Players.LocalPlayer.PlayerGui

-- 3. Creates overlay layer Frame
local overlayLayer = Instance.new("Frame")
overlayLayer.Name = "RvrseUI_OverlayLayer"
overlayLayer.Size = UDim2.new(1, 0, 1, 0)  -- Full screen
overlayLayer.Position = UDim2.new(0, 0, 0, 0)
overlayLayer.BackgroundTransparency = 1  -- Invisible
overlayLayer.ZIndex = 20000
overlayLayer.Parent = overlayGui
```

### Getting Overlay Layer Reference

**CRITICAL:** Every element that needs overlay access must get the layer reference:

```lua
-- In WindowBuilder, deps is assembled:
local deps = {
    -- ... other dependencies ...
    OverlayLayer = overlayLayer,  -- ⭐ CRITICAL: Pass the actual Frame
    Overlay = Overlay,            -- The service module
}

-- In Dropdown.Create():
local overlayLayer = dependencies.OverlayLayer  -- Get Frame reference

-- In ColorPicker.Create():
local baseOverlayLayer = dependencies.OverlayLayer  -- Get Frame reference
```

### Blocker System

```lua
-- Show blocker (called by Dropdown/ColorPicker when opening)
Overlay:ShowBlocker({
    Transparency = 0.45,  -- 45% black
    ZIndex = 4999,        -- Below overlay elements (5000)
})

-- Hide blocker (called when closing)
Overlay:HideBlocker(false)
```

---

## 🐛 Common Issues & Solutions

### Issue 1: Dropdown Menu Not Visible
**Symptom:** Menu opens but nothing shows, or menu is clipped

**Cause:** Menu parented to Section instead of OverlayLayer

**Fix:**
```lua
-- ❌ WRONG
menu.Parent = f  -- Element card

-- ✅ CORRECT
menu.Parent = dependencies.OverlayLayer  -- Overlay layer
```

### Issue 2: ColorPicker Panel Not Visible
**Symptom:** Gray box shows but no sliders, or panel invisible

**Causes:**
1. Panel parented to element card instead of OverlayLayer
2. ClipsDescendants = true with Size = (320, 0)
3. BackgroundTransparency not set (defaults to 1)
4. Panel.Visible = false and never set to true

**Fix:**
```lua
-- ✅ CORRECT INITIALIZATION
pickerPanel.Parent = baseOverlayLayer or f  -- Prefer overlay
pickerPanel.BackgroundTransparency = 0  -- Fully opaque
pickerPanel.Size = UDim2.new(0, 320, 0, 0)  -- Start collapsed
pickerPanel.ClipsDescendants = false  -- Don't clip during animation
pickerPanel.Visible = false  -- Start hidden

-- ✅ CORRECT OPENING
pickerPanel.Visible = true  -- Show first
pickerPanel.Size = UDim2.new(0, 320, 0, 0)  -- Start at 0
task.spawn(function()
    task.wait(0.05)  -- Let layout calculate
    Animator:Tween(pickerPanel, {
        Size = UDim2.new(0, 320, 0, 380)  -- Animate to full height
    }, Animator.Spring.Gentle)
end)
```

### Issue 3: Element Clipped by ScrollingFrame
**Symptom:** Overlay element gets cut off when scrolling

**Cause:** Element parented inside ClipsDescendants container

**Fix:** Parent floating panels to OverlayLayer, not the element card

### Issue 4: Blocker Doesn't Close Menu
**Symptom:** Clicking blocker does nothing

**Cause:** Blocker ZIndex too high (above menu) or connection not set up

**Fix:**
```lua
-- ✅ CORRECT BLOCKER SETUP
overlayBlocker = Overlay:ShowBlocker({
    Transparency = 0.45,
    ZIndex = 4999,  -- Below menu (5000)
})
overlayBlockerConnection = overlayBlocker.MouseButton1Click:Connect(function()
    closeMenuFunction()
end)
```

### Issue 5: Multiple Overlays Conflict
**Symptom:** Opening one overlay breaks another

**Cause:** Blocker shared between elements without proper cleanup

**Fix:**
```lua
-- Disconnect old blocker before creating new one
if overlayBlockerConnection then
    overlayBlockerConnection:Disconnect()
    overlayBlockerConnection = nil
end
```

---

## 📐 Element Positioning Rules

### Window Positioning
```lua
-- Windows are centered on screen
Window.AnchorPoint = Vector2.new(0.5, 0.5)
Window.Position = UDim2.new(0.5, 0, 0.5, 0)
Window.Size = UDim2.new(0, 580, 0, 480)
```

### Dropdown Menu Positioning
```lua
-- Position relative to dropdown button
menu.Position = UDim2.new(0, button.AbsolutePosition.X, 0, button.AbsolutePosition.Y + button.AbsoluteSize.Y + 4)
menu.Size = UDim2.new(0, button.AbsoluteSize.X, 0, 0)  -- Start collapsed
```

### ColorPicker Panel Positioning
```lua
-- Position to the right of the color preview button
pickerPanel.Position = UDim2.new(1, -(320 + 6), 0.5, 52)
-- Explanation:
-- X: 1 (right edge) - 326 pixels = Aligns to right side of element
-- Y: 0.5 (middle) + 52 pixels = Positions below element
```

### Notification Positioning
```lua
-- Top-right corner with padding
toast.AnchorPoint = Vector2.new(1, 0)
toast.Position = UDim2.new(1, -12, 0, 12 + (index * (toastHeight + 8)))
```

---

## 🔍 Debugging Checklist

When an overlay element isn't visible, check these **in order**:

### Step 1: Check Parent
```lua
print("Parent:", element.Parent)
-- Should be: RvrseUI_OverlayLayer (for overlay elements)
-- NOT: Window, TabPage, Section, or element card
```

### Step 2: Check Visibility
```lua
print("Visible:", element.Visible)
print("Transparency:", element.BackgroundTransparency)
-- Visible should be true
-- Transparency should be 0 (opaque) or low value
```

### Step 3: Check Size
```lua
print("Size:", element.Size)
print("AbsoluteSize:", element.AbsoluteSize)
-- Height should be > 0 when open
-- If height = 0, element is collapsed
```

### Step 4: Check ZIndex
```lua
print("ZIndex:", element.ZIndex)
print("Parent ZIndex:", element.Parent.ZIndex)
-- Should be >= 5000 for overlay elements
-- Parent (OverlayLayer) should be 20000
```

### Step 5: Check Position
```lua
print("Position:", element.Position)
print("AbsolutePosition:", element.AbsolutePosition)
-- Should be on-screen (0-screenWidth, 0-screenHeight)
-- If negative or > screen size, element is off-screen
```

### Step 6: Check ClipsDescendants
```lua
print("ClipsDescendants:", element.ClipsDescendants)
-- Should be false for panels with dynamic height
-- If true with Size.Y = 0, children are clipped
```

### Step 7: Check ScreenGui
```lua
local overlayGui = game.CoreGui:FindFirstChild("RvrseUI_Overlay")
    or game.Players.LocalPlayer.PlayerGui:FindFirstChild("RvrseUI_Overlay")
print("Overlay ScreenGui exists:", overlayGui ~= nil)
print("DisplayOrder:", overlayGui and overlayGui.DisplayOrder)
-- DisplayOrder should be 20000
```

---

## 🛠️ How to Add New Overlay Elements

### Template for New Overlay Element

```lua
function NewElement.Create(o, dependencies)
    -- 1. Extract overlay layer reference
    local baseOverlayLayer = dependencies.OverlayLayer
    local OverlayService = dependencies.Overlay

    -- 2. Create base element (goes in Section)
    local f = dependencies.card(48)
    f.Parent = dependencies.sectionContent

    -- 3. Create overlay panel (goes in OverlayLayer)
    local panel = Instance.new("Frame")
    panel.Name = "NewElementPanel"
    panel.BackgroundColor3 = dependencies.pal3.Elevated
    panel.BackgroundTransparency = 0  -- ⭐ CRITICAL
    panel.Size = UDim2.new(0, 300, 0, 0)  -- Start collapsed
    panel.Position = UDim2.new(0.5, 0, 0.5, 0)
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Visible = false
    panel.ZIndex = 5000  -- ⭐ CRITICAL
    panel.ClipsDescendants = false  -- ⭐ CRITICAL
    panel.Parent = baseOverlayLayer  -- ⭐ CRITICAL: Use overlay layer!

    -- 4. Add corner/stroke/shadow
    dependencies.corner(panel, 12)
    dependencies.stroke(panel, dependencies.pal3.Accent, 2)
    dependencies.shadow(panel, 0.7, 20)

    -- 5. Open/close logic
    local function setPanelOpen(state)
        if state then
            -- Show blocker
            local blocker = OverlayService:ShowBlocker({
                Transparency = 0.45,
                ZIndex = 4999,
            })
            blocker.MouseButton1Click:Connect(function()
                setPanelOpen(false)
            end)

            -- Show panel
            panel.Visible = true
            panel.Size = UDim2.new(0, 300, 0, 0)

            -- Animate
            task.spawn(function()
                task.wait(0.05)
                dependencies.Animator:Tween(panel, {
                    Size = UDim2.new(0, 300, 0, 200)
                }, dependencies.Animator.Spring.Gentle)
            end)
        else
            -- Hide blocker
            OverlayService:HideBlocker(false)

            -- Hide panel
            dependencies.Animator:Tween(panel, {
                Size = UDim2.new(0, 300, 0, 0)
            }, dependencies.Animator.Spring.Snappy)

            task.delay(0.3, function()
                panel.Visible = false
            end)
        end
    end

    -- 6. Cleanup on destroy
    f.Destroying:Connect(function()
        setPanelOpen(false)
    end)

    return elementAPI
end
```

### Critical Points Checklist

- [ ] Panel parented to `baseOverlayLayer` (NOT `f`)
- [ ] `BackgroundTransparency = 0` explicitly set
- [ ] `ZIndex = 5000` set
- [ ] `ClipsDescendants = false` set
- [ ] Start with `Size = (..., 0)` (height = 0)
- [ ] Set `Visible = true` before animating
- [ ] Use `task.spawn()` for animation
- [ ] Blocker ZIndex = 4999 (below panel)
- [ ] Cleanup blocker on destroy

---

## 📚 Module Dependency Chain

```
WindowBuilder
    ↓ (creates deps table)
    ├─→ TabBuilder
    │       ↓ (passes deps)
    │       └─→ SectionBuilder
    │               ↓ (passes deps)
    │               └─→ Elements (Button, Toggle, Dropdown, ColorPicker, etc.)
    │                       ↓ (accesses deps.OverlayLayer)
    │                       └─→ Creates overlay panels
    │
    └─→ deps = {
            OverlayLayer = overlayLayer,  -- ⭐ Frame reference
            Overlay = Overlay,            -- Service module
            Theme = Theme,
            Animator = Animator,
            // ... etc
        }
```

**CRITICAL:** `deps.OverlayLayer` must be the **actual Frame** reference, not the Overlay service module.

---

## 🎨 Visual Layer Diagram

```
┌─────────────────────────────────────────┐
│  DisplayOrder 20000 (RvrseUI_Overlay)   │  ← Notifications, Overlays
│  ┌───────────────────────────────────┐  │
│  │ ZIndex 10000: Notifications       │  │
│  │ ZIndex 5000:  Dropdowns, Pickers  │  │
│  │ ZIndex 4999:  Blocker             │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
           ↑ Renders on top ↑

┌─────────────────────────────────────────┐
│  DisplayOrder 999 (RvrseUI_Host)        │  ← Main UI
│  ┌───────────────────────────────────┐  │
│  │ ZIndex 5000: Controller Chip      │  │
│  │ ZIndex 100:  Window Frame         │  │
│  │   ZIndex 1:  Window Content       │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

---

## ✅ Current Status: ColorPicker Issue

### The Problem
ColorPicker panel is **not showing** when clicked. Logs show:
- `visible=false`
- `alpha=0.00`
- Panel exists but invisible

### Root Cause Analysis
```lua
-- Current code (BROKEN):
pickerPanel.Parent = baseOverlayLayer or f  -- Falls back to f?

-- baseOverlayLayer might be nil!
-- If nil, panel parents to f (element card)
-- Element card is inside ClipsDescendants ScrollingFrame
-- Panel gets clipped!
```

### Required Fix
1. **Verify `baseOverlayLayer` is not nil**
2. **Debug parenting** to ensure panel goes to overlay
3. **Check size animation** is running
4. **Verify transparency** is 0

### Next Steps
- [ ] Add debug prints to ColorPicker.Create()
- [ ] Verify deps.OverlayLayer exists
- [ ] Check panel.Parent after creation
- [ ] Add fallback error if OverlayLayer missing

---

## 🚨 CRITICAL: UI Helper Restrictions

### The Shadow Helper Problem

**NEVER use `shadow()` helper on overlay panels or large dropdown menus!**

### What Happened (v4.0.1 Critical Bug)

The `UIHelpers.shadow()` function creates an `ImageLabel` that extends **beyond the parent element bounds**:

```lua
-- UIHelpers.lua:74-88
function UIHelpers.shadow(inst, transparency, size)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, (size or 4) * 2, 1, (size or 4) * 2)
    --                       ^^^  ^^^^^^^^^^^^  ^^^  ^^^^^^^^^^^^
    --                       100%  + OVERFLOW   100%  + OVERFLOW
    shadow.ZIndex = inst.ZIndex - 1  -- Just below parent
    shadow.Parent = inst  -- ⚠️ PARENTED TO THE ELEMENT!
    return shadow
end
```

### The Math (ColorPicker Example)

```
ColorPickerPanel:    320px × 456px (overlay panel)
shadow(panel, 0.7, 20):
  Size = UDim2.new(1, 40, 1, 40)
  Result = 400px × 536px  ← SHADOW EXTENDS 40PX BEYOND PANEL!

Shadow ZIndex = 199 (panel ZIndex - 1 = 200 - 1)
Result: GIANT GRAY BOX COVERING ENTIRE SCREEN
```

### Why This Happened

1. **Shadow was designed for small inline elements** (buttons, toggles, sliders)
   - Button: 50×48px → Shadow: 70×68px ✅ OK (20px overflow)
   - Toggle thumb: 26×26px → Shadow: 32×32px ✅ OK (6px overflow)

2. **NOT designed for large overlay panels**
   - ColorPicker panel: 320×456px → Shadow: 400×536px ❌ BLOCKS SCREEN
   - Dropdown menu: 280×240px → Shadow: 360×308px ❌ BLOCKS SCREEN

3. **Shadow ZIndex is always parent.ZIndex - 1**
   - For overlay elements with high ZIndex (200), shadow gets ZIndex 199
   - This puts shadow ABOVE everything except the panel itself
   - Shadow blocks ALL UI elements below it

### Elements Affected (Fixed in v4.0.1)

| Element | Shadow Usage | Status | Fix Applied |
|---------|-------------|--------|-------------|
| **ColorPicker.lua** | `shadow(pickerPanel, 0.7, 20)` | ❌ CRITICAL | Line 196 - Disabled |
| **Dropdown.lua** | `shadow(dropdownList, 0.6, 16)` | ❌ CRITICAL | Line 180 - Disabled |
| **DropdownLegacy.lua** | `shadow(dropdownList, 0.6, 16)` | ⚠️ MINOR | Line 91 - Disabled |
| Toggle.lua | `shadow(dot, 0.5, 3)` | ✅ OK | Small inline element |
| Slider.lua | `shadow(thumb, 0.5, 5)` | ✅ OK | Small inline element |

### Strict Rules for shadow() Helper

#### ✅ SAFE to use shadow() on:
- **Small inline elements** (< 60px in any dimension)
  - Button elements
  - Toggle thumbs/switches
  - Slider thumbs
  - Small icons/badges
- **Elements with ClipsDescendants = true** (shadow can't overflow)
- **Elements that never use overlay mode**

#### ❌ NEVER use shadow() on:
- **Overlay panels** (ColorPicker, Dropdown, Modals, Tooltips)
- **Large containers** (> 100px in any dimension)
- **Dropdown menus** (even inline ones - shadow looks weird)
- **Popup elements** (anything that appears above other UI)
- **Scrolling frames** (shadow extends beyond scroll area)
- **Elements with high ZIndex** (> 100)

### Alternative: Use Stroke Instead

For overlay panels, use `stroke()` helper for visual definition:

```lua
-- ❌ DON'T DO THIS (blocks entire screen)
shadow(pickerPanel, 0.7, 20)

-- ✅ DO THIS (clean border, no blocking)
stroke(pickerPanel, pal3.Accent, 2)
corner(pickerPanel, 12)
```

### Checklist Before Using shadow()

Before adding `shadow(element)` to ANY new element:

- [ ] Is this element < 60px in both dimensions?
- [ ] Is this element inline (never uses overlay)?
- [ ] Is ClipsDescendants = true on the parent?
- [ ] Is ZIndex < 100?
- [ ] Have I tested with the element fully expanded?
- [ ] Have I verified shadow doesn't extend beyond visible area?

**If ANY answer is NO → DO NOT USE SHADOW!**

### How We Found This Bug

1. User reported gray/dark box covering ColorPicker sliders
2. Created visual debug test with color-coded layers (RED/GREEN/BLUE/YELLOW)
3. Gray box was NOT on the color-coded list
4. User: "this gray color is not even on the list this is deffenitly bigger then we think"
5. Audited ColorPicker.lua → Found `shadow(pickerPanel, 0.7, 20)` on line 196
6. Traced to UIHelpers.shadow() creating 400×536px ImageLabel
7. Fixed by disabling shadow() for all overlay elements

### Testing for Shadow Issues

**Symptoms:**
- Gray or dark box appears when opening overlay element
- Box covers entire screen or large portion of UI
- Can't interact with sliders/options even though they're rendered
- Element looks fine when inspected, but is blocked by transparent layer

**Diagnosis:**
```lua
-- Check for Shadow element in overlay
local panel = overlayLayer:FindFirstChild("ColorPickerPanel")
if panel then
    local shadow = panel:FindFirstChild("Shadow")
    if shadow then
        warn("SHADOW FOUND! Size:", shadow.Size, "ZIndex:", shadow.ZIndex)
    end
end
```

**Fix:**
```lua
-- Comment out shadow() call
-- shadow(pickerPanel, 0.7, 20)  -- ❌ DISABLED: Shadow too large for overlay panels!
```

### Related Files

- **UIHelpers.lua** - Defines shadow() helper (lines 74-88)
- **ColorPicker.lua** - Fixed shadow usage (line 196)
- **Dropdown.lua** - Fixed shadow usage (line 180)
- **DropdownLegacy.lua** - Fixed shadow usage (line 91)
- **examples/test-colorpicker-shadow-fix.lua** - Verification test
- **examples/README-VISUAL-DEBUG.md** - Debug guide documenting the bug

### Commits

- `f48410e` - fix(colorpicker): disable shadow on overlay panel
- `4415d67` - test: add shadow fix verification test
- `d235737` - docs: update visual debug guide with shadow bug resolution

---

**This document should be the FIRST place any AI or developer looks when debugging overlay issues!**
