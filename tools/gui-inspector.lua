-- RvrseUI GUI Inspector & Debugger
-- Comprehensive tool to visualize, debug, and understand the entire GUI tree

local Inspector = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Create inspector window
function Inspector:Create()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    -- Create inspector ScreenGui
    local inspectorGui = Instance.new("ScreenGui")
    inspectorGui.Name = "RvrseUI_Inspector"
    inspectorGui.DisplayOrder = 99999  -- Above everything
    inspectorGui.ResetOnSpawn = false
    inspectorGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    inspectorGui.Parent = playerGui

    -- Main inspector window
    local window = Instance.new("Frame")
    window.Name = "InspectorWindow"
    window.Size = UDim2.new(0, 900, 0, 600)
    window.Position = UDim2.new(0.5, -450, 0.5, -300)
    window.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    window.BorderSizePixel = 0
    window.Parent = inspectorGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = window

    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.ZIndex = -1
    shadow.Image = "rbxasset://textures/ui/Controls/DropShadow/DropShadow.png"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(12, 12, 52, 52)
    shadow.Parent = window

    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    header.BorderSizePixel = 0
    header.Parent = window

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "🔍 RvrseUI GUI Inspector"
    title.Parent = header

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    closeBtn.BorderSizePixel = 0
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Text = "✕"
    closeBtn.Parent = header

    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 6)
    closeBtnCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        inspectorGui:Destroy()
    end)

    -- Content area (split view)
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -60)
    content.Position = UDim2.new(0, 10, 0, 50)
    content.BackgroundTransparency = 1
    content.Parent = window

    -- Left panel: Tree view
    local treePanel = Instance.new("ScrollingFrame")
    treePanel.Name = "TreePanel"
    treePanel.Size = UDim2.new(0.4, -10, 1, 0)
    treePanel.Position = UDim2.new(0, 0, 0, 0)
    treePanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    treePanel.BorderSizePixel = 0
    treePanel.ScrollBarThickness = 6
    treePanel.CanvasSize = UDim2.new(0, 0, 0, 0)
    treePanel.Parent = content

    local treePanelCorner = Instance.new("UICorner")
    treePanelCorner.CornerRadius = UDim.new(0, 8)
    treePanelCorner.Parent = treePanel

    local treeLayout = Instance.new("UIListLayout")
    treeLayout.Padding = UDim.new(0, 2)
    treeLayout.SortOrder = Enum.SortOrder.LayoutOrder
    treeLayout.Parent = treePanel

    -- Right panel: Details view
    local detailsPanel = Instance.new("ScrollingFrame")
    detailsPanel.Name = "DetailsPanel"
    detailsPanel.Size = UDim2.new(0.6, -10, 1, 0)
    detailsPanel.Position = UDim2.new(0.4, 10, 0, 0)
    detailsPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    detailsPanel.BorderSizePixel = 0
    detailsPanel.ScrollBarThickness = 6
    detailsPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
    detailsPanel.Parent = content

    local detailsPanelCorner = Instance.new("UICorner")
    detailsPanelCorner.CornerRadius = UDim.new(0, 8)
    detailsPanelCorner.Parent = detailsPanel

    local detailsLayout = Instance.new("UIListLayout")
    detailsLayout.Padding = UDim.new(0, 4)
    detailsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    detailsLayout.Parent = detailsPanel

    -- Make window draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return {
        Window = window,
        TreePanel = treePanel,
        DetailsPanel = detailsPanel,
        TreeLayout = treeLayout,
        DetailsLayout = detailsLayout
    }
end

-- Get color for element type
function Inspector:GetElementColor(className)
    local colors = {
        ScreenGui = Color3.fromRGB(100, 150, 255),
        Frame = Color3.fromRGB(150, 100, 255),
        ScrollingFrame = Color3.fromRGB(255, 150, 100),
        TextLabel = Color3.fromRGB(100, 255, 150),
        TextButton = Color3.fromRGB(255, 100, 150),
        TextBox = Color3.fromRGB(150, 255, 100),
        ImageLabel = Color3.fromRGB(255, 200, 100),
        ImageButton = Color3.fromRGB(100, 200, 255),
    }
    return colors[className] or Color3.fromRGB(150, 150, 150)
end

-- Create tree node
function Inspector:CreateTreeNode(element, depth, parent, onSelect)
    local node = Instance.new("TextButton")
    node.Name = "TreeNode_" .. element.Name
    node.Size = UDim2.new(1, -10, 0, 24)
    node.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    node.BorderSizePixel = 0
    node.AutoButtonColor = false
    node.Font = Enum.Font.GothamMedium
    node.TextSize = 12
    node.TextColor3 = Color3.fromRGB(200, 200, 200)
    node.TextXAlignment = Enum.TextXAlignment.Left
    node.Text = string.rep("  ", depth) .. "▸ " .. element.Name .. " [" .. element.ClassName .. "]"
    node.Parent = parent

    local nodeCorner = Instance.new("UICorner")
    nodeCorner.CornerRadius = UDim.new(0, 4)
    nodeCorner.Parent = node

    local colorBar = Instance.new("Frame")
    colorBar.Size = UDim2.new(0, 3, 1, 0)
    colorBar.Position = UDim2.new(0, depth * 16, 0, 0)
    colorBar.BackgroundColor3 = self:GetElementColor(element.ClassName)
    colorBar.BorderSizePixel = 0
    colorBar.Parent = node

    local colorBarCorner = Instance.new("UICorner")
    colorBarCorner.CornerRadius = UDim.new(1, 0)
    colorBarCorner.Parent = colorBar

    node.MouseButton1Click:Connect(function()
        onSelect(element)
        -- Highlight selected
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            end
        end
        node.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    end)

    node.MouseEnter:Connect(function()
        if node.BackgroundColor3 ~= Color3.fromRGB(50, 50, 60) then
            node.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        end
    end)

    node.MouseLeave:Connect(function()
        if node.BackgroundColor3 ~= Color3.fromRGB(50, 50, 60) then
            node.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        end
    end)

    return node
end

-- Create detail row
function Inspector:CreateDetailRow(label, value, color, parent)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -10, 0, 22)
    row.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    row.BorderSizePixel = 0
    row.Parent = parent

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 4)
    rowCorner.Parent = row

    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.4, 0, 1, 0)
    labelText.Position = UDim2.new(0, 8, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Font = Enum.Font.GothamBold
    labelText.TextSize = 11
    labelText.TextColor3 = Color3.fromRGB(150, 150, 150)
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Text = label
    labelText.Parent = row

    local valueText = Instance.new("TextLabel")
    valueText.Size = UDim2.new(0.6, -8, 1, 0)
    valueText.Position = UDim2.new(0.4, 0, 0, 0)
    valueText.BackgroundTransparency = 1
    valueText.Font = Enum.Font.GothamMedium
    valueText.TextSize = 11
    valueText.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    valueText.TextXAlignment = Enum.TextXAlignment.Right
    valueText.Text = value
    valueText.TextWrapped = true
    valueText.Parent = row

    return row
end

-- Build tree recursively
function Inspector:BuildTree(element, depth, parent, onSelect)
    if not element then return end

    -- Create node for this element
    self:CreateTreeNode(element, depth, parent, onSelect)

    -- Recursively create nodes for children
    for _, child in ipairs(element:GetChildren()) do
        self:BuildTree(child, depth + 1, parent, onSelect)
    end
end

-- Show element details
function Inspector:ShowDetails(element, detailsPanel)
    -- Clear existing details
    for _, child in ipairs(detailsPanel:GetChildren()) do
        if child:IsA("Frame") and child.Name == "DetailRow" then
            child:Destroy()
        end
    end

    if not element then return end

    -- Header
    local header = Instance.new("TextLabel")
    header.Name = "DetailRow"
    header.Size = UDim2.new(1, -10, 0, 30)
    header.BackgroundTransparency = 1
    header.Font = Enum.Font.GothamBold
    header.TextSize = 14
    header.TextColor3 = Color3.fromRGB(255, 255, 255)
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Text = "📋 " .. element.Name
    header.Parent = detailsPanel

    -- Basic info
    self:CreateDetailRow("ClassName", element.ClassName, Color3.fromRGB(100, 200, 255), detailsPanel).Name = "DetailRow"
    self:CreateDetailRow("Parent", element.Parent and element.Parent.Name or "nil", Color3.fromRGB(255, 150, 100), detailsPanel).Name = "DetailRow"

    -- Position
    if element:IsA("GuiObject") then
        local pos = element.Position
        self:CreateDetailRow("Position", string.format("{%.2f, %d}, {%.2f, %d}",
            pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset),
            Color3.fromRGB(255, 200, 100), detailsPanel).Name = "DetailRow"

        local absPos = element.AbsolutePosition
        self:CreateDetailRow("AbsolutePosition", string.format("(%d, %d)", absPos.X, absPos.Y),
            Color3.fromRGB(255, 200, 100), detailsPanel).Name = "DetailRow"

        -- Size
        local size = element.Size
        self:CreateDetailRow("Size", string.format("{%.2f, %d}, {%.2f, %d}",
            size.X.Scale, size.X.Offset, size.Y.Scale, size.Y.Offset),
            Color3.fromRGB(150, 255, 150), detailsPanel).Name = "DetailRow"

        local absSize = element.AbsoluteSize
        self:CreateDetailRow("AbsoluteSize", string.format("(%d, %d)", absSize.X, absSize.Y),
            Color3.fromRGB(150, 255, 150), detailsPanel).Name = "DetailRow"

        -- Visibility
        self:CreateDetailRow("Visible", tostring(element.Visible),
            element.Visible and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100),
            detailsPanel).Name = "DetailRow"

        -- Transparency
        if element.BackgroundTransparency then
            self:CreateDetailRow("BackgroundTransparency", string.format("%.2f", element.BackgroundTransparency),
                element.BackgroundTransparency == 1 and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 255, 100),
                detailsPanel).Name = "DetailRow"
        end

        -- Color
        if element.BackgroundColor3 then
            local c = element.BackgroundColor3
            self:CreateDetailRow("BackgroundColor3", string.format("RGB(%d, %d, %d)", c.R * 255, c.G * 255, c.B * 255),
                element.BackgroundColor3, detailsPanel).Name = "DetailRow"
        end

        -- ZIndex
        self:CreateDetailRow("ZIndex", tostring(element.ZIndex), Color3.fromRGB(200, 150, 255), detailsPanel).Name = "DetailRow"

        -- ClipsDescendants
        if element:IsA("Frame") or element:IsA("ScrollingFrame") then
            self:CreateDetailRow("ClipsDescendants", tostring(element.ClipsDescendants),
                element.ClipsDescendants and Color3.fromRGB(255, 200, 100) or Color3.fromRGB(100, 255, 100),
                detailsPanel).Name = "DetailRow"
        end

        -- AnchorPoint
        local anchor = element.AnchorPoint
        self:CreateDetailRow("AnchorPoint", string.format("(%.2f, %.2f)", anchor.X, anchor.Y),
            Color3.fromRGB(200, 200, 255), detailsPanel).Name = "DetailRow"
    end

    -- ScreenGui specific
    if element:IsA("ScreenGui") then
        self:CreateDetailRow("DisplayOrder", tostring(element.DisplayOrder), Color3.fromRGB(255, 150, 255), detailsPanel).Name = "DetailRow"
        self:CreateDetailRow("ZIndexBehavior", tostring(element.ZIndexBehavior), Color3.fromRGB(255, 150, 255), detailsPanel).Name = "DetailRow"
        self:CreateDetailRow("IgnoreGuiInset", tostring(element.IgnoreGuiInset), Color3.fromRGB(255, 150, 255), detailsPanel).Name = "DetailRow"
    end

    -- Update canvas size
    detailsPanel.CanvasSize = UDim2.new(0, 0, 0, detailsPanel.UIListLayout.AbsoluteContentSize.Y + 10)
end

-- Scan for RvrseUI elements
function Inspector:ScanRvrseUI()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    local elements = {
        Host = playerGui:FindFirstChild("RvrseUI_Host"),
        Overlay = playerGui:FindFirstChild("RvrseUI_Overlay") or game.CoreGui:FindFirstChild("RvrseUI_Overlay"),
    }

    return elements
end

-- Main inspector
function Inspector:Run()
    print("🔍 RvrseUI GUI Inspector Starting...")

    local ui = self:Create()

    -- Scan for RvrseUI
    local rvrseElements = self:ScanRvrseUI()

    print("Found RvrseUI elements:")
    print("  Host:", rvrseElements.Host)
    print("  Overlay:", rvrseElements.Overlay)

    -- Build tree
    if rvrseElements.Host then
        self:BuildTree(rvrseElements.Host, 0, ui.TreePanel, function(element)
            self:ShowDetails(element, ui.DetailsPanel)
        end)
    end

    if rvrseElements.Overlay then
        self:BuildTree(rvrseElements.Overlay, 0, ui.TreePanel, function(element)
            self:ShowDetails(element, ui.DetailsPanel)
        end)
    end

    -- Update canvas size
    ui.TreePanel.CanvasSize = UDim2.new(0, 0, 0, ui.TreeLayout.AbsoluteContentSize.Y + 10)

    -- Add refresh button
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(0, 80, 0, 30)
    refreshBtn.Position = UDim2.new(1, -90, 0, 5)
    refreshBtn.AnchorPoint = Vector2.new(1, 0)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    refreshBtn.BorderSizePixel = 0
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.TextSize = 12
    refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshBtn.Text = "🔄 Refresh"
    refreshBtn.Parent = ui.Window:FindFirstChild("Header")

    local refreshCorner = Instance.new("UICorner")
    refreshCorner.CornerRadius = UDim.new(0, 6)
    refreshCorner.Parent = refreshBtn

    refreshBtn.MouseButton1Click:Connect(function()
        -- Clear tree
        for _, child in ipairs(ui.TreePanel:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        -- Rebuild
        local newElements = self:ScanRvrseUI()
        if newElements.Host then
            self:BuildTree(newElements.Host, 0, ui.TreePanel, function(element)
                self:ShowDetails(element, ui.DetailsPanel)
            end)
        end
        if newElements.Overlay then
            self:BuildTree(newElements.Overlay, 0, ui.TreePanel, function(element)
                self:ShowDetails(element, ui.DetailsPanel)
            end)
        end

        ui.TreePanel.CanvasSize = UDim2.new(0, 0, 0, ui.TreeLayout.AbsoluteContentSize.Y + 10)
    end)

    print("✅ Inspector ready! Click elements to see details.")
end

return Inspector
