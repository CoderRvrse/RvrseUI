--[[
    SIMPLE ROBLOX DRAG PATTERN - Reference Implementation

    This is the CLASSIC drag pattern that "just works" in every Roblox GUI.
    No fancy math, no animations, no size changes - just simple offset calculation.
]]

-- Services
local UIS = game:GetService("UserInputService")

-- The frame you want to drag
local dragFrame = script.Parent

-- Drag state
local dragging = false
local dragInput
local dragStart
local startPos

-- Helper to update position
local function update(input)
    local delta = input.Position - dragStart
    dragFrame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

-- Start dragging
dragFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = dragFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

-- Track input changes
dragFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or
       input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

-- Update position during drag
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

--[[
    KEY POINTS:
    1. No AbsolutePosition calculations - just use Position directly
    2. No GUI inset handling - let Roblox handle it
    3. No AnchorPoint math - works with any anchor
    4. No offset caching - recalculate delta every frame
    5. Delta = current - start, applied to original position

    This pattern works because:
    - We store the STARTING Position (in UDim2 format)
    - We store the STARTING mouse Position (in Vector2 format)
    - Every frame we calculate: current mouse - start mouse = delta
    - Apply delta to starting Position = new Position
    - No coordinate space conversion needed!
]]
