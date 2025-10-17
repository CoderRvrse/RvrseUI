# UI Helper Function Restrictions & Best Practices

> **Purpose:** This document defines strict rules for using UIHelpers functions to prevent critical bugs like the v4.0.1 shadow() blocking issue.

---

## 📚 Available UI Helpers

RvrseUI provides 6 core UI helper functions in `src/UIHelpers.lua`:

1. **corner(inst, radius)** - Adds UICorner with specified radius
2. **stroke(inst, color, thickness)** - Adds UIStroke border
3. **gradient(inst, rotation, colors)** - Adds UIGradient
4. **padding(inst, all)** - Adds UIPadding with uniform insets
5. **shadow(inst, transparency, size)** - Adds shadow ImageLabel (⚠️ DANGEROUS!)
6. **createTooltip(parent, text)** - Creates tooltip TextLabel

---

## 1. corner() Helper ✅ SAFE

### Function Signature
```lua
UIHelpers.corner(inst, radius)
```

### Purpose
Adds a `UICorner` to the instance for rounded corners.

### Parameters
- `inst` (Instance) - The Frame/ImageLabel/TextButton to add corners to
- `radius` (number) - Corner radius in pixels (default: 12)

### Usage Rules
- ✅ **Safe to use on ANY element**
- ✅ No restrictions
- ✅ No side effects

### Examples
```lua
-- Small radius for buttons
corner(button, 8)

-- Medium radius for cards
corner(card, 12)

-- Large radius for panels
corner(panel, 16)

-- Pill shape (half of height)
corner(toggle, 15)  -- For 30px high toggle
```

### Common Pitfalls
- ⚠️ Using radius larger than element height creates unexpected shapes
- 💡 For pill shapes, use `radius = height / 2`

---

## 2. stroke() Helper ✅ SAFE

### Function Signature
```lua
UIHelpers.stroke(inst, color, thickness)
```

### Purpose
Adds a `UIStroke` border to the instance.

### Parameters
- `inst` (Instance) - The Frame/ImageLabel/TextButton to add stroke to
- `color` (Color3) - Border color (default: pal3.Border)
- `thickness` (number) - Border thickness in pixels (default: 1)

### Usage Rules
- ✅ **Safe to use on ANY element**
- ✅ No restrictions
- ✅ **PREFERRED alternative to shadow() for overlay panels!**

### Examples
```lua
-- Subtle border for cards
stroke(card, pal3.Border, 1)

-- Accent border for active elements
stroke(activeButton, pal3.Accent, 2)

-- Thick border for overlay panels (INSTEAD of shadow!)
stroke(pickerPanel, pal3.Accent, 2)

-- No border (use transparency)
local borderStroke = stroke(element, Color3.new(1,1,1), 1)
borderStroke.Transparency = 1
```

### Best Practices
- Use `stroke()` instead of `shadow()` for overlay panels
- Thickness 1-2px for most elements
- Thickness 3-4px for emphasis/focus states

---

## 3. gradient() Helper ✅ SAFE

### Function Signature
```lua
UIHelpers.gradient(inst, rotation, colors)
```

### Purpose
Adds a `UIGradient` to the instance.

### Parameters
- `inst` (Instance) - The Frame/ImageLabel/TextButton to add gradient to
- `rotation` (number) - Gradient rotation in degrees (default: 0)
- `colors` (table) - Array of Color3 values for gradient stops

### Usage Rules
- ✅ **Safe to use on ANY element**
- ✅ No restrictions
- ⚠️ Performance: Avoid on elements with frequent color changes

### Examples
```lua
-- Horizontal gradient (left to right)
gradient(background, 0, {
    Color3.fromRGB(120, 80, 255),  -- Purple (left)
    Color3.fromRGB(255, 80, 150)   -- Pink (right)
})

-- Vertical gradient (top to bottom)
gradient(bar, 90, {
    pal3.Accent,
    pal3.AccentDark
})

-- Diagonal gradient
gradient(button, 45, {
    Color3.fromRGB(255, 100, 100),
    Color3.fromRGB(255, 200, 100),
    Color3.fromRGB(100, 255, 100)
})
```

### Performance Notes
- Gradients are cheap to create but expensive to animate
- Avoid updating gradient colors in Heartbeat loops
- Use TweenService for smooth gradient transitions

---

## 4. padding() Helper ✅ SAFE

### Function Signature
```lua
UIHelpers.padding(inst, all)
```

### Purpose
Adds uniform `UIPadding` to all sides of the instance.

### Parameters
- `inst` (Instance) - The Frame/ScrollingFrame to add padding to
- `all` (number) - Padding in pixels for all sides (default: 12)

### Usage Rules
- ✅ **Safe to use on ANY element**
- ✅ No restrictions
- ⚠️ Affects element's usable space for children

### Examples
```lua
-- Standard padding for cards
padding(card, 12)

-- Tight padding for compact layouts
padding(listItem, 6)

-- Wide padding for panels
padding(panel, 20)

-- No padding
padding(container, 0)
```

### Best Practices
- Use consistent padding values throughout the UI (6, 12, 16, 20)
- Consider padding when calculating element sizes
- For non-uniform padding, create UIPadding manually:
```lua
local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 20)
pad.PaddingBottom = UDim.new(0, 10)
pad.PaddingLeft = UDim.new(0, 12)
pad.PaddingRight = UDim.new(0, 12)
pad.Parent = inst
```

---

## 5. shadow() Helper 🚨 DANGEROUS!

### ⚠️ CRITICAL WARNING: RESTRICTED USE ONLY!

### Function Signature
```lua
UIHelpers.shadow(inst, transparency, size)
```

### Purpose
Adds a shadow `ImageLabel` behind the instance for depth effect.

### Parameters
- `inst` (Instance) - The Frame/ImageLabel to add shadow to
- `transparency` (number) - Shadow transparency (default: 0.8, 0=opaque, 1=invisible)
- `size` (number) - Shadow blur size in pixels (default: 4)

### How It Works (THE PROBLEM!)
```lua
function UIHelpers.shadow(inst, transparency, size)
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, (size or 4) * 2, 1, (size or 4) * 2)
    --                       ^^^  ^^^^^^^^^^^^  ^^^  ^^^^^^^^^^^^
    --                       100%  + OVERFLOW   100%  + OVERFLOW
    shadow.ZIndex = inst.ZIndex - 1  -- Just below parent!
    shadow.Parent = inst  -- ⚠️ CHILD OF THE ELEMENT!
    return shadow
end
```

### The Math

| Element Size | Shadow Size (size=20) | Overflow | Result |
|--------------|----------------------|----------|--------|
| 50×48px (Button) | 70×68px | +20px | ✅ OK - Small overflow |
| 26×26px (Toggle) | 32×32px | +6px | ✅ OK - Tiny overflow |
| 320×456px (ColorPicker) | 400×536px | +80px | ❌ BLOCKS SCREEN! |
| 280×240px (Dropdown) | 360×308px | +80px | ❌ BLOCKS SCREEN! |

### STRICT USAGE RULES

#### ✅ SAFE to use shadow() ONLY when ALL conditions are true:

1. **Element is small** (< 60px in BOTH dimensions)
2. **Element is inline** (NOT in overlay layer)
3. **Element ZIndex is low** (< 100)
4. **Parent has ClipsDescendants = true** (shadow can't overflow) OR
5. **You've tested with element at maximum size**

#### ❌ NEVER use shadow() on:

| Element Type | Why It's Dangerous | Alternative |
|--------------|-------------------|-------------|
| **Overlay Panels** | Shadow blocks entire screen | Use `stroke()` |
| **ColorPicker Panel** | 320×456px → 400×536px shadow | `stroke(panel, pal3.Accent, 2)` |
| **Dropdown Menus** | 280×240px → 360×308px shadow | `stroke(menu, pal3.Border, 1)` |
| **Modals/Popups** | High ZIndex makes shadow block UI | `stroke()` + pal3.Elevated color |
| **Scrolling Frames** | Shadow extends beyond scroll area | Use container stroke |
| **Large Containers** | > 100px creates huge shadow | `stroke()` for definition |

### Elements Currently Using shadow() (v4.0.1)

| File | Line | Element | Size | Status |
|------|------|---------|------|--------|
| Toggle.lua | 72 | `shadow(dot, 0.5, 3)` | 26×26px | ✅ SAFE (small inline) |
| Slider.lua | 103 | `shadow(thumb, 0.5, 5)` | 22×22px | ✅ SAFE (small inline) |
| ColorPicker.lua | 196 | ~~shadow(pickerPanel)~~ | 320×456px | ❌ DISABLED (blocked screen) |
| Dropdown.lua | 180 | ~~shadow(dropdownList)~~ | 280×240px | ❌ DISABLED (blocked screen) |
| DropdownLegacy.lua | 91 | ~~shadow(dropdownList)~~ | 280×200px | ❌ DISABLED (visual issues) |

### Safe Examples ✅
```lua
-- Small button shadow (SAFE)
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 50, 0, 48)
button.ZIndex = 2
shadow(button, 0.8, 4)  -- Shadow: 58×56px, ZIndex 1 ✅

-- Toggle thumb shadow (SAFE)
local thumb = Instance.new("Frame")
thumb.Size = UDim2.new(0, 26, 0, 26)
thumb.ZIndex = 5
shadow(thumb, 0.5, 3)  -- Shadow: 32×32px, ZIndex 4 ✅
```

### Dangerous Examples ❌
```lua
-- ❌ DON'T DO THIS - ColorPicker panel
local pickerPanel = Instance.new("Frame")
pickerPanel.Size = UDim2.new(0, 320, 0, 456)
pickerPanel.ZIndex = 200
shadow(pickerPanel, 0.7, 20)  -- Shadow: 400×536px, ZIndex 199 ❌
-- Result: GIANT GRAY BOX COVERING ENTIRE SCREEN!

-- ❌ DON'T DO THIS - Dropdown menu
local dropdownList = Instance.new("Frame")
dropdownList.Size = UDim2.new(0, 280, 0, 240)
dropdownList.ZIndex = 100
shadow(dropdownList, 0.6, 16)  -- Shadow: 360×308px, ZIndex 99 ❌
-- Result: GRAY BOX BLOCKING MAIN UI!
```

### Correct Alternatives ✅
```lua
-- ✅ DO THIS - Use stroke() for overlay panels
local pickerPanel = Instance.new("Frame")
pickerPanel.Size = UDim2.new(0, 320, 0, 456)
pickerPanel.ZIndex = 200
-- shadow(pickerPanel, 0.7, 20)  -- ❌ DISABLED
stroke(pickerPanel, pal3.Accent, 2)  -- ✅ Clean border
corner(pickerPanel, 12)  -- ✅ Rounded corners

-- ✅ DO THIS - Use stroke() for dropdown menus
local dropdownList = Instance.new("Frame")
dropdownList.Size = UDim2.new(0, 280, 0, 240)
dropdownList.ZIndex = 100
-- shadow(dropdownList, 0.6, 16)  -- ❌ DISABLED
stroke(dropdownList, pal3.Border, 1)  -- ✅ Subtle border
corner(dropdownList, 8)  -- ✅ Rounded corners
```

### Checklist Before Using shadow()

Before adding `shadow(element, transparency, size)` to ANY code:

- [ ] Is element size < 60px in BOTH width AND height?
- [ ] Is element inline (parented to card, NOT overlay layer)?
- [ ] Is element ZIndex < 100?
- [ ] Have you tested element at maximum expanded size?
- [ ] Have you verified shadow doesn't extend beyond visible area?
- [ ] Have you checked parent's ClipsDescendants property?
- [ ] Is there a stroke() alternative that would work instead?

**If ANY answer is NO → DO NOT USE shadow()! Use stroke() instead.**

---

## 6. createTooltip() Helper ✅ SAFE (with notes)

### Function Signature
```lua
UIHelpers.createTooltip(parent, text)
```

### Purpose
Creates a tooltip TextLabel that appears on hover.

### Parameters
- `parent` (Instance) - The element to attach tooltip to
- `text` (string) - Tooltip text content

### Usage Rules
- ✅ Safe to use on most elements
- ⚠️ Tooltips may be clipped if parent has ClipsDescendants = true
- ⚠️ Position may be off-screen on edge elements

### Examples
```lua
-- Standard tooltip
local tooltip = createTooltip(button, "Click to save")

-- Show/hide on hover
button.MouseEnter:Connect(function()
    tooltip.Visible = true
end)

button.MouseLeave:Connect(function()
    tooltip.Visible = false
end)
```

### Best Practices
- Keep tooltip text short (< 40 characters)
- Position tooltips carefully near screen edges
- Consider mobile users (no hover events on touch devices)

---

## 🎯 Quick Reference: Helper Safety Matrix

| Helper | Inline Elements | Overlay Panels | Large Containers | Performance | Restrictions |
|--------|----------------|----------------|------------------|-------------|--------------|
| **corner()** | ✅ SAFE | ✅ SAFE | ✅ SAFE | ⚡ Fast | None |
| **stroke()** | ✅ SAFE | ✅ SAFE | ✅ SAFE | ⚡ Fast | **Preferred for overlays** |
| **gradient()** | ✅ SAFE | ✅ SAFE | ✅ SAFE | ⚡ Fast (static) | Avoid frequent updates |
| **padding()** | ✅ SAFE | ✅ SAFE | ✅ SAFE | ⚡ Fast | Affects child layout |
| **shadow()** | ✅ SAFE (if small) | ❌ DANGEROUS | ❌ DANGEROUS | ⚡ Fast | **See restrictions!** |
| **createTooltip()** | ✅ SAFE | ⚠️ May clip | ⚠️ May clip | ⚡ Fast | Check ClipsDescendants |

---

## 📋 Element Implementation Checklist

When creating a new element or modifying an existing one:

### Step 1: Determine Element Type
- [ ] Is this an inline element (parented to card)?
- [ ] Is this an overlay element (parented to OverlayLayer)?
- [ ] What is the maximum size this element can reach?
- [ ] What ZIndex range will this element use?

### Step 2: Choose Helpers
- [ ] Use `corner()` for rounded corners (always safe)
- [ ] Use `stroke()` for borders (always safe, preferred for overlays)
- [ ] Use `padding()` for internal spacing (always safe)
- [ ] Use `gradient()` for color transitions (safe, avoid frequent updates)
- [ ] **NEVER use `shadow()` on overlay panels or large elements!**
- [ ] Consider `createTooltip()` for help text (check clipping)

### Step 3: Test
- [ ] Test element at minimum size
- [ ] Test element at maximum size
- [ ] Test element in overlay mode (if applicable)
- [ ] Verify no visual glitches or blocking issues
- [ ] Check on different screen sizes

### Step 4: Document
- [ ] Add comments explaining why helpers were chosen
- [ ] Note any restrictions or special cases
- [ ] Document shadow() alternatives used

---

## 🔧 Migration Guide: Removing shadow() from Elements

If you find `shadow()` being used on overlay elements or large containers:

### Step 1: Identify the Problem
```lua
-- Find shadow() calls in element code
grep -n "shadow(" src/Elements/*.lua
```

### Step 2: Determine Element Type
- Is this element ever used in overlay mode?
- What is the maximum size of this element?
- What is the typical ZIndex?

### Step 3: Replace with stroke()
```lua
-- ❌ BEFORE
shadow(pickerPanel, 0.7, 20)

-- ✅ AFTER
-- shadow(pickerPanel, 0.7, 20)  -- ❌ DISABLED: Shadow too large for overlay panels!
stroke(pickerPanel, pal3.Accent, 2)  -- Use stroke for visual definition
```

### Step 4: Test
- Verify element still has visual definition
- Check that no gray boxes appear
- Confirm element is fully interactive

### Step 5: Commit
```bash
git add src/Elements/ElementName.lua
git commit -m "fix(element): disable shadow() on overlay panel

- Removed shadow() call (was blocking screen with oversized ImageLabel)
- Replaced with stroke() for visual definition
- Tested: No gray box, fully interactive"
```

---

## 📚 Related Documentation

- **[UI-ARCHITECTURE.md](UI-ARCHITECTURE.md#-critical-ui-helper-restrictions)** - Full shadow() bug documentation
- **[CLAUDE.md](../CLAUDE.md#-critical-warning-uihelpersshadow-restriction)** - Maintainer warnings
- **[DEBUGGING-WORKFLOW.md](DEBUGGING-WORKFLOW.md)** - Debugging overlay issues
- **examples/test-colorpicker-shadow-fix.lua** - Verification test for shadow removal

---

## 🚨 Red Flags

**If you see ANY of these, STOP and review:**

1. `shadow(element, ...)` where element.Size > 100px
2. `shadow(panel, ...)` where panel.Parent = OverlayLayer
3. `shadow(menu, ...)` on any dropdown or popup
4. `shadow(container, ...)` on ScrollingFrame or large Frame
5. `shadow(element, ...)` where element.ZIndex > 100

**Always ask:** "Could I use `stroke()` instead?"

---

**Last Updated:** 2025-10-17 (v4.0.1)
**Critical Bug Fix:** Shadow helper blocking overlay panels
