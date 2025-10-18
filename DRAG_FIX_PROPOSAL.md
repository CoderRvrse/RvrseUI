# 🔧 RvrseUI Drag System Rebuild Proposal

## 🐛 Root Cause Summary

The drag offset bug stems from **three fundamental issues**:

### 1. **Implicit vs Explicit AnchorPoints**
```lua
-- CURRENT (BROKEN)
local root = Instance.new("Frame")
root.Size = UDim2.new(0, 580, 0, 480)
root.Position = UDim2.fromOffset(centerX, centerY)
-- ❌ AnchorPoint defaults to (0, 0) but never explicitly set
-- ❌ Code assumes it's (0, 0) but can't guarantee it
```

**Fix:** Always set AnchorPoint explicitly
```lua
-- FIXED
local root = Instance.new("Frame")
root.AnchorPoint = Vector2.new(0, 0)  -- ✅ EXPLICIT top-left
root.Size = UDim2.new(0, 580, 0, 480)
root.Position = UDim2.fromOffset(centerX, centerY)
```

### 2. **Chip Size Changes During Drag Session**
```lua
-- CURRENT (BROKEN)
controllerChip.MouseEnter:Connect(function()
    Animator:Tween(controllerChip, {
        Size = UDim2.new(0, 60, 0, 60)  -- ❌ Grows during hover
    }, Animator.Spring.Fast)
end)

controllerChip.InputBegan:Connect(function(io)
    -- Offset calculated here using CURRENT size
    chipCenterOffset = pointer - chipCenter  -- ❌ But size might change!
end)
```

**Fix:** Lock size during drag, restore after release
```lua
-- FIXED
local isDragging = false
local lockedSize = nil

controllerChip.InputBegan:Connect(function(io)
    isDragging = true
    lockedSize = controllerChip.Size  -- ✅ Freeze size
    controllerChip.Size = UDim2.new(0, 50, 0, 50)  -- ✅ Force to base size

    -- Now calculate offset with guaranteed 50x50
    local chipCenter = Vector2.new(
        controllerChip.AbsolutePosition.X + 25,  -- ✅ Half of locked 50
        controllerChip.AbsolutePosition.Y + 25
    )
    chipCenterOffset = pointer - chipCenter
end)

controllerChip.InputEnded:Connect(function(io)
    isDragging = false
    if lockedSize then
        controllerChip.Size = lockedSize  -- ✅ Restore hover size
    end
end)
```

### 3. **Coordinate Space Mixing**
```lua
-- CURRENT (BROKEN)
local function getPointerPosition(inputObject)
    if inputObject and inputObject.UserInputType == Enum.UserInputType.Touch then
        return Vector2.new(inputObject.Position.X, inputObject.Position.Y)
    end
    return UIS:GetMouseLocation()
end

-- ❌ GetMouseLocation() returns screen space INCLUDING inset
-- ❌ But AbsolutePosition might or might not include inset depending on IgnoreGuiInset
```

**Fix:** Normalize all coordinates to same space
```lua
-- FIXED
local function getPointerPosition(inputObject)
    local pointer
    if inputObject and inputObject.UserInputType == Enum.UserInputType.Touch then
        pointer = Vector2.new(inputObject.Position.X, inputObject.Position.Y)
    else
        pointer = UIS:GetMouseLocation()
    end

    -- ✅ Always subtract inset to get "GUI space" coordinates
    local inset = GuiService:GetGuiInset()
    return pointer - Vector2.new(inset.X, inset.Y)
end

-- Now when calculating offset:
local pointer = getPointerPosition(io)  -- ✅ GUI space
local topLeft = root.AbsolutePosition   -- ✅ Also GUI space (always)
local offset = pointer - topLeft        -- ✅ Consistent!
```

---

## 🛠️ Complete Rebuild Plan

### Phase 1: Fix Window Root Frame
```lua
-- src/WindowBuilder.lua line 247
local root = Instance.new("Frame")
root.Name = Obfuscation.getObfuscatedName("window")
root.AnchorPoint = Vector2.new(0, 0)  -- ✅ NEW: Explicit top-left anchor
root.Size = UDim2.new(0, baseWidth, 0, baseHeight)
-- ... rest stays same
```

### Phase 2: Fix Header Drag Offset Calculation
```lua
-- src/WindowBuilder.lua line 382-407
header.InputBegan:Connect(function(io)
    if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        activeDragInput = io

        -- ✅ Get pointer in GUI space (inset-adjusted)
        local pointer = getPointerPosition(io)

        -- ✅ Window top-left is ALWAYS AbsolutePosition (because AnchorPoint = 0,0)
        local topLeft = root.AbsolutePosition

        -- ✅ Offset is simply pointer - topLeft
        dragPointerOffset = pointer - topLeft
        headerLastPointer = pointer

        Debug.printf("[DRAG] Mouse down at GUI space: (%.1f, %.1f)", pointer.X, pointer.Y)
        Debug.printf("[DRAG] Window top-left: (%.1f, %.1f)", topLeft.X, topLeft.Y)
        Debug.printf("[DRAG] Cached offset: X=%.2f, Y=%.2f", dragPointerOffset.X, dragPointerOffset.Y)
    end
end)
```

### Phase 3: Fix Chip Drag with Size Locking
```lua
-- src/WindowBuilder.lua line 1264-1341
local chipDragging = false
local chipBaseSizeX = 50  -- ✅ Constant base size
local chipBaseSizeY = 50
local chipLockedSize = nil

-- Start chip drag
controllerChip.InputBegan:Connect(function(io)
    if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
        chipDragging = true
        chipActiveDragInput = io

        -- ✅ LOCK size to base before calculating offset
        chipLockedSize = controllerChip.Size
        controllerChip.Size = UDim2.new(0, chipBaseSizeX, 0, chipBaseSizeY)

        -- ✅ Wait one frame for size to apply
        task.wait()

        local pointer = getPointerPosition(io)
        chipInitialPointer = pointer
        chipLastPointer = pointer

        -- ✅ Calculate center with LOCKED base size
        local halfWidth = chipBaseSizeX / 2
        local halfHeight = chipBaseSizeY / 2
        local chipCenter = Vector2.new(
            controllerChip.AbsolutePosition.X + halfWidth,
            controllerChip.AbsolutePosition.Y + halfHeight
        )

        -- ✅ Offset from pointer to center
        chipCenterOffset = pointer - chipCenter

        Debug.printf("[CHIP DRAG] Size locked to: %.0f x %.0f", chipBaseSizeX, chipBaseSizeY)
        Debug.printf("[CHIP DRAG] Chip center: (%.1f, %.1f)", chipCenter.X, chipCenter.Y)
        Debug.printf("[CHIP DRAG] Offset: X=%.2f, Y=%.2f", chipCenterOffset.X, chipCenterOffset.Y)
    end
end)

-- End chip drag
controllerChip.InputEnded:Connect(function(io)
    if chipDragging and io == chipActiveDragInput then
        chipDragging = false
        chipActiveDragInput = nil

        -- ✅ Restore original size (might be 60x60 from hover)
        if chipLockedSize then
            controllerChip.Size = chipLockedSize
            chipLockedSize = nil
        end

        -- Save position...
        RvrseUI._controllerChipPosition = { ... }
    end
end)
```

### Phase 4: Disable Hover During Drag
```lua
-- src/WindowBuilder.lua line 1298-1309
controllerChip.MouseEnter:Connect(function()
    if not chipDragging then  -- ✅ NEW: Don't grow during drag
        Animator:Tween(controllerChip, {
            Size = UDim2.new(0, 60, 0, 60)
        }, Animator.Spring.Fast)
    end
end)

controllerChip.MouseLeave:Connect(function()
    if not chipDragging then  -- ✅ NEW: Don't shrink during drag
        Animator:Tween(controllerChip, {
            Size = UDim2.new(0, 50, 0, 50)
        }, Animator.Spring.Fast)
    end
end)
```

---

## 🧪 Testing Checklist

After implementing all fixes:

1. ✅ Fresh window drag (normal case)
   - Click header → drag → no jump

2. ✅ Hover over chip → drag
   - Chip grows to 60x60 → click → size locks to 50x50 → drag → no jump

3. ✅ Minimize → restore → drag
   - Window animates → restores → drag header → no jump

4. ✅ Minimize → hover chip → drag chip
   - Chip visible → hover (60x60) → click → locks to 50x50 → drag → no jump

5. ✅ Multiple minimize/restore cycles
   - Repeat 10 times → drag after each restore → no jump

6. ✅ Edge cases
   - Drag near screen edges → clamping works
   - Different DPI scales → no jump
   - Touch input → same behavior as mouse

---

## 📊 Expected Results

**Before Fix:**
```
[CHIP DRAG] Mouse down at: (450.0, 300.0)
[CHIP DRAG] Chip at hover size: 60 x 60
[CHIP DRAG] Calculated center: (480.0, 330.0)  ← WRONG! Using 60x60
[CHIP DRAG] Offset: X=-30.0, Y=-30.0
... first movement ...
[CHIP DRAG] New center: (455.0, 305.0)  ← Size changed back to 50x50!
❌ JUMP: chip kicks out 5px in each direction
```

**After Fix:**
```
[CHIP DRAG] Mouse down at: (450.0, 300.0)
[CHIP DRAG] Size locked to: 50 x 50  ← ✅ FORCED to base size
[CHIP DRAG] Chip center: (475.0, 325.0)  ← ✅ Using locked 50x50
[CHIP DRAG] Offset: X=-25.0, Y=-25.0
... first movement ...
[CHIP DRAG] New center: (475.0, 325.0)  ← ✅ Still 50x50, no change
✅ NO JUMP: offset stays valid
```

---

## 🚀 Implementation Priority

1. **HIGH PRIORITY** - Fix chip size locking (Phase 3)
   - This is the most visible bug (chip jumps on drag)

2. **MEDIUM PRIORITY** - Fix coordinate space (Phase 2)
   - Subtle bug that only shows up in certain inset configurations

3. **LOW PRIORITY** - Add explicit AnchorPoint (Phase 1)
   - Defensive coding, no visible bug currently

4. **LOW PRIORITY** - Disable hover during drag (Phase 4)
   - Nice-to-have, prevents edge case issues
