-- Simple GUI Inspector - Direct console output
-- No UI, just prints everything to console

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("\n" .. string.rep("=", 80))
print("🔍 RvrseUI Simple Inspector")
print(string.rep("=", 80))

-- Find RvrseUI elements
local host = playerGui:FindFirstChild("RvrseUI_Host")
local overlay = playerGui:FindFirstChild("RvrseUI_Overlay") or game.CoreGui:FindFirstChild("RvrseUI_Overlay")

print("\n📦 Found RvrseUI Elements:")
print("  RvrseUI_Host:", host and "✅ Found" or "❌ Not found")
print("  RvrseUI_Overlay:", overlay and "✅ Found" or "❌ Not found")

-- Function to print element details
local function printElement(element, depth)
    local indent = string.rep("  ", depth)

    print(indent .. "├─ " .. element.Name .. " [" .. element.ClassName .. "]")

    if element:IsA("GuiObject") then
        print(indent .. "│  ├─ Visible: " .. tostring(element.Visible))
        print(indent .. "│  ├─ Size: " .. tostring(element.Size))
        print(indent .. "│  ├─ AbsoluteSize: " .. tostring(element.AbsoluteSize))
        print(indent .. "│  ├─ Position: " .. tostring(element.Position))
        print(indent .. "│  ├─ AbsolutePosition: " .. tostring(element.AbsolutePosition))

        if element.BackgroundTransparency then
            print(indent .. "│  ├─ BackgroundTransparency: " .. string.format("%.2f", element.BackgroundTransparency))
        end

        if element.BackgroundColor3 then
            local c = element.BackgroundColor3
            print(indent .. "│  ├─ BackgroundColor3: RGB(" ..
                math.floor(c.R * 255) .. ", " ..
                math.floor(c.G * 255) .. ", " ..
                math.floor(c.B * 255) .. ")")
        end

        print(indent .. "│  ├─ ZIndex: " .. tostring(element.ZIndex))

        if element:IsA("Frame") or element:IsA("ScrollingFrame") then
            print(indent .. "│  ├─ ClipsDescendants: " .. tostring(element.ClipsDescendants))
        end
    end

    if element:IsA("ScreenGui") then
        print(indent .. "│  ├─ DisplayOrder: " .. tostring(element.DisplayOrder))
        print(indent .. "│  ├─ ZIndexBehavior: " .. tostring(element.ZIndexBehavior))
        print(indent .. "│  ├─ IgnoreGuiInset: " .. tostring(element.IgnoreGuiInset))
    end

    print(indent .. "│  └─ Parent: " .. (element.Parent and element.Parent.Name or "nil"))
end

-- Recursive tree print
local function printTree(element, depth, maxDepth)
    if not element then return end
    if depth > maxDepth then return end

    printElement(element, depth)

    -- Print children
    for _, child in ipairs(element:GetChildren()) do
        printTree(child, depth + 1, maxDepth)
    end
end

-- Scan Host
if host then
    print("\n" .. string.rep("=", 80))
    print("📦 RvrseUI_Host Tree:")
    print(string.rep("=", 80))
    printTree(host, 0, 3)  -- Max depth 3 to avoid spam
end

-- Scan Overlay
if overlay then
    print("\n" .. string.rep("=", 80))
    print("📦 RvrseUI_Overlay Tree:")
    print(string.rep("=", 80))
    printTree(overlay, 0, 4)  -- Max depth 4 for overlay
end

-- Find ColorPickerPanel specifically
print("\n" .. string.rep("=", 80))
print("🎨 Searching for ColorPickerPanel...")
print(string.rep("=", 80))

local function findColorPicker(parent)
    if not parent then return nil end

    for _, child in ipairs(parent:GetDescendants()) do
        if child.Name == "ColorPickerPanel" then
            return child
        end
    end
    return nil
end

local colorPickerPanel = findColorPicker(overlay) or findColorPicker(host)

if colorPickerPanel then
    print("\n✅ FOUND ColorPickerPanel!")
    print("\n📋 Detailed Properties:")
    printElement(colorPickerPanel, 0)

    print("\n👶 Children of ColorPickerPanel:")
    for i, child in ipairs(colorPickerPanel:GetChildren()) do
        print("  " .. i .. ". " .. child.Name .. " [" .. child.ClassName .. "]")
    end
else
    print("\n❌ ColorPickerPanel NOT FOUND in the GUI tree!")
    print("   This means the panel was never created, or was destroyed.")
end

-- Summary
print("\n" .. string.rep("=", 80))
print("📊 Summary:")
print(string.rep("=", 80))
print("  Host elements:", host and #host:GetChildren() or 0)
print("  Overlay elements:", overlay and #overlay:GetChildren() or 0)
print("  ColorPickerPanel:", colorPickerPanel and "Found" or "NOT FOUND")

if colorPickerPanel then
    print("\n✅ Check the ColorPickerPanel properties above!")
    print("   Key things to verify:")
    print("   - Parent should be: RvrseUI_OverlayLayer or similar")
    print("   - Visible should be: true (when open)")
    print("   - Size should be: {0, 320}, {0, 380} (when open)")
    print("   - BackgroundTransparency should be: 0 (opaque)")
    print("   - ZIndex should be: 5000 or higher")
else
    print("\n⚠️  ColorPickerPanel doesn't exist!")
    print("   Possible reasons:")
    print("   1. ColorPicker wasn't created (check earlier logs)")
    print("   2. Advanced mode is disabled")
    print("   3. Panel was destroyed immediately")
    print("   4. Error during panel creation")
end

print("\n" .. string.rep("=", 80))
print("✅ Inspection complete! Scroll up to see the tree.")
print(string.rep("=", 80) .. "\n")
