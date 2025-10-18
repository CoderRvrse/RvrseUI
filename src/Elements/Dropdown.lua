-- Dropdown Element Module
-- Modern multi-select overlay dropdown system (unified as of v4.1.0)
-- Users can select multiple items or just one by clicking once

local Dropdown = {}

function Dropdown.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local corner = dependencies.corner
	local stroke = dependencies.stroke
	local pal3 = dependencies.pal3
	local Animator = dependencies.Animator
	local RvrseUI = dependencies.RvrseUI
	local UIS = dependencies.UIS
	local baseOverlayLayer = dependencies.OverlayLayer
	local OverlayService = dependencies.Overlay

	if OverlayService and not baseOverlayLayer then
		baseOverlayLayer = OverlayService:GetLayer()
	end

	-- Settings
	local values = {}
	local sourceValues = o.Values or {}
	for _, v in ipairs(sourceValues) do
		table.insert(values, v)
	end

	local selectedValues = {}  -- Always use multi-select mode

	-- Initialize selectedValues from CurrentOption
	if o.CurrentOption and type(o.CurrentOption) == "table" then
		for _, val in ipairs(o.CurrentOption) do
			table.insert(selectedValues, val)
		end
	end

	local maxHeight = o.MaxHeight or 240
	local itemHeight = 40
	local placeholder = o.PlaceholderText or "Select items"
	local DROPDOWN_BASE_Z = 3000
	local minDropdownWidth = 200  -- Minimum dropdown width
	local maxDropdownWidth = 400  -- Maximum dropdown width
	local fallbackOverlayLayer
	local fallbackOverlayGui

	local function currentOverlayLayer()
		if baseOverlayLayer and baseOverlayLayer.Parent then
			return baseOverlayLayer
		end
		if fallbackOverlayLayer and fallbackOverlayLayer.Parent then
			return fallbackOverlayLayer
		end
		return nil
	end

	local function resolveOverlayLayer()
		if o.Overlay == false then
			return nil
		end

		local layer = currentOverlayLayer()
		if layer then
			return layer
		end

		local player
		local ok, result = pcall(function()
			return game:GetService("Players").LocalPlayer
		end)
		if ok then
			player = result
		end
		if not player then
			return nil
		end

		local playerGui = player:FindFirstChildOfClass("PlayerGui")
		if not playerGui then
			local okWait, gui = pcall(function()
				return player:WaitForChild("PlayerGui", 1)
			end)
			if okWait then
				playerGui = gui
			end
		end

		if not playerGui then
			return nil
		end

		local hostGui = fallbackOverlayGui
		if not hostGui or not hostGui.Parent then
			-- Calculate highest DisplayOrder to ensure dropdown is on top
			local maxDisplayOrder = 0
			for _, gui in ipairs(playerGui:GetChildren()) do
				if gui:IsA("ScreenGui") then
					maxDisplayOrder = math.max(maxDisplayOrder, gui.DisplayOrder)
				end
			end

			hostGui = Instance.new("ScreenGui")
			hostGui.Name = "RvrseUI_DropdownHost"
			hostGui.ResetOnSpawn = false
			hostGui.IgnoreGuiInset = true
			hostGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			hostGui.DisplayOrder = maxDisplayOrder + 1000  -- Always on top
			hostGui.Parent = playerGui
			fallbackOverlayGui = hostGui

			if dependencies.Debug and dependencies.Debug.IsEnabled() then
				dependencies.Debug.printf("[Dropdown] Created fallback ScreenGui with DisplayOrder=%d (max was %d)",
					hostGui.DisplayOrder, maxDisplayOrder)
			end
		end

		local layerFrame = fallbackOverlayLayer
		if not layerFrame or not layerFrame.Parent then
			layerFrame = Instance.new("Frame")
			layerFrame.Name = "DropdownLayer"
			layerFrame.BackgroundTransparency = 1
			layerFrame.BorderSizePixel = 0
			layerFrame.ClipsDescendants = false
			layerFrame.Size = UDim2.new(1, 0, 1, 0)
			layerFrame.ZIndex = DROPDOWN_BASE_Z - 10
			layerFrame.Parent = hostGui
			fallbackOverlayLayer = layerFrame
		end

		return layerFrame
	end

	-- Base card
	local f = card(48)
	f.ClipsDescendants = false

	-- Label
	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, -140, 1, 0)
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = pal3.Text
	lbl.Text = o.Text or "Dropdown"
	lbl.Parent = f

	-- Trigger button
	local btn = Instance.new("TextButton")
	btn.AnchorPoint = Vector2.new(1, 0.5)
	btn.Position = UDim2.new(1, -6, 0.5, 0)
	btn.Size = UDim2.new(0, 130, 0, 32)
	btn.BackgroundColor3 = pal3.Card
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 13
	btn.TextColor3 = pal3.Text
	btn.AutoButtonColor = false
	btn.ZIndex = 2
	btn.Parent = f
	corner(btn, 8)
	stroke(btn, pal3.Border, 1)

	local arrow = Instance.new("TextLabel")
	arrow.BackgroundTransparency = 1
	arrow.AnchorPoint = Vector2.new(1, 0.5)
	arrow.Position = UDim2.new(1, -8, 0.5, 0)
	arrow.Size = UDim2.new(0, 16, 0, 16)
	arrow.Font = Enum.Font.GothamBold
	arrow.TextSize = 12
	arrow.TextColor3 = pal3.TextSub
	arrow.Text = "▼"
	arrow.ZIndex = 3
	arrow.Parent = btn

	-- Dropdown list container
	local dropdownList = Instance.new("Frame")
	dropdownList.Name = "DropdownList"
	dropdownList.BackgroundColor3 = pal3.Elevated
	dropdownList.BorderSizePixel = 0
	dropdownList.Position = UDim2.new(1, -(btn.Size.X.Offset + 6), 0.5, 40)
	dropdownList.Size = UDim2.new(0, btn.Size.X.Offset, 0, 0)
	dropdownList.Visible = false
	dropdownList.ZIndex = 100
	dropdownList.ClipsDescendants = false
	dropdownList.Parent = f
	corner(dropdownList, 8)
	stroke(dropdownList, pal3.Accent, 1)

	local dropdownScroll = Instance.new("ScrollingFrame")
	dropdownScroll.BackgroundTransparency = 1
	dropdownScroll.BorderSizePixel = 0
	dropdownScroll.Size = UDim2.new(1, -8, 1, -8)
	dropdownScroll.Position = UDim2.new(0, 4, 0, 4)
	dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	dropdownScroll.ScrollBarThickness = 4
	dropdownScroll.ScrollBarImageColor3 = pal3.Accent
	dropdownScroll.ZIndex = 101
	dropdownScroll.Parent = dropdownList

	local dropdownLayout = Instance.new("UIListLayout")
	dropdownLayout.FillDirection = Enum.FillDirection.Vertical
	dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
	dropdownLayout.Padding = UDim.new(0, 4)
	dropdownLayout.Parent = dropdownScroll

	-- Add padding inside dropdown scroll
	local dropdownPadding = Instance.new("UIPadding")
	dropdownPadding.PaddingTop = UDim.new(0, 4)
	dropdownPadding.PaddingBottom = UDim.new(0, 4)
	dropdownPadding.PaddingLeft = UDim.new(0, 4)
	dropdownPadding.PaddingRight = UDim.new(0, 4)
	dropdownPadding.Parent = dropdownScroll

	local inlineParent = dropdownList.Parent
	local inlineWidth = btn.Size.X.Offset
	local dropdownHeight = 0

	local overlayBlocker
	local overlayBlockerConnection
	local blockerActive = false
	local dropdownOpen = false
	local optionButtons = {}
	local dropdownAPI = {}
	local setOpen  -- Forward declaration for blocker click handler

	local function locked()
		return o.RespectLock and RvrseUI.Store:IsLocked(o.RespectLock)
	end

	local function visual()
		local isLocked = locked()
		btn.AutoButtonColor = not isLocked
		lbl.TextTransparency = isLocked and 0.5 or 0
		btn.TextTransparency = isLocked and 0.5 or 0
		arrow.TextTransparency = isLocked and 0.5 or 0
	end

	local function showOverlayBlocker()
		if OverlayService then
			overlayBlocker = OverlayService:ShowBlocker({
				Transparency = 0.45,
				ZIndex = DROPDOWN_BASE_Z - 2,
				Modal = false,
			})
		else
			local layer = resolveOverlayLayer()
			if not layer then
				return
			end

			if not overlayBlocker or not overlayBlocker.Parent then
				overlayBlocker = Instance.new("TextButton")
				overlayBlocker.Name = "DropdownOverlayBlocker"
				overlayBlocker.AutoButtonColor = false
				overlayBlocker.Text = ""
				overlayBlocker.BackgroundColor3 = Color3.new(0, 0, 0)
				overlayBlocker.BackgroundTransparency = 0.55
				overlayBlocker.BorderSizePixel = 0
				overlayBlocker.Size = UDim2.new(1, 0, 1, 0)
				overlayBlocker.ZIndex = DROPDOWN_BASE_Z - 2
				overlayBlocker.Visible = false
				overlayBlocker.Parent = layer
				-- Connect inline function to close dropdown
				overlayBlocker.MouseButton1Click:Connect(function()
					if setOpen then
						setOpen(false)
					end
				end)
			elseif overlayBlocker.Parent ~= layer then
				overlayBlocker.Parent = layer
			end
			overlayBlocker.Visible = true
			overlayBlocker.Active = false
			overlayBlocker.Modal = false
			overlayBlocker.ZIndex = DROPDOWN_BASE_Z - 2
		end

		blockerActive = true
	end

	local function hideOverlayBlocker(force)
		if not blockerActive then
			return
		end

		if OverlayService then
			if overlayBlockerConnection then
				overlayBlockerConnection:Disconnect()
				overlayBlockerConnection = nil
			end
			OverlayService:HideBlocker(force)
		elseif overlayBlocker then
			overlayBlocker.Visible = false
			overlayBlocker.Active = false
			overlayBlocker.Modal = false
		end

		blockerActive = false
	end

	local function updateCurrentOption()
		dropdownAPI.CurrentOption = selectedValues
	end

	local function updateButtonText()
		local count = #selectedValues
		if count == 0 then
			btn.Text = placeholder
		elseif count == 1 then
			btn.Text = tostring(selectedValues[1])
		else
			btn.Text = count .. " selected"
		end
		updateCurrentOption()
	end

	local function isValueSelected(value)
		for _, v in ipairs(selectedValues) do
			if v == value then
				return true
			end
		end
		return false
	end

	local function updateHighlight()
		for i, optionBtn in ipairs(optionButtons) do
			local value = values[i]
			local selected = isValueSelected(value)

			if selected then
				optionBtn.BackgroundColor3 = pal3.Accent
				optionBtn.BackgroundTransparency = 0.8
			else
				optionBtn.BackgroundColor3 = pal3.Card
				optionBtn.BackgroundTransparency = 0
			end

			local textLabel = optionBtn:FindFirstChild("TextLabel", true)
			if textLabel then
				textLabel.TextColor3 = selected and pal3.Accent or pal3.Text
			end

			local checkbox = optionBtn:FindFirstChild("Checkbox", true)
			if checkbox then
				checkbox.Text = selected and "☑" or "☐"
				checkbox.TextColor3 = selected and pal3.Accent or pal3.TextSub
			end
		end
	end

	local function updateOptionZIndices(base)
		for _, optionBtn in ipairs(optionButtons) do
			optionBtn.ZIndex = base
		end
	end

	local function collapseInline()
		dropdownList.Parent = inlineParent
		dropdownList.ZIndex = DROPDOWN_BASE_Z
		dropdownScroll.ZIndex = DROPDOWN_BASE_Z + 1
		updateOptionZIndices(dropdownScroll.ZIndex + 1)
		dropdownList.Position = UDim2.new(1, -(inlineWidth + 6), 0.5, 40)
		dropdownList.Size = UDim2.new(0, inlineWidth, 0, dropdownList.Size.Y.Offset)
	end

	local function calculateOptimalWidth()
		-- Create a temporary TextLabel to measure text width
		local tempLabel = Instance.new("TextLabel")
		tempLabel.Font = Enum.Font.GothamMedium
		tempLabel.TextSize = 14
		tempLabel.Text = ""
		tempLabel.Parent = nil

		local maxTextWidth = 0

		-- Measure all values
		for _, value in ipairs(values) do
			tempLabel.Text = tostring(value)
			local textBounds = tempLabel.TextBounds
			maxTextWidth = math.max(maxTextWidth, textBounds.X)
		end

		tempLabel:Destroy()

		-- Calculate total width needed:
		-- 4px (left padding) + 32px (checkbox) + 8px (spacing) + text + 12px (right padding)
		local totalWidth = 4 + 32 + 8 + maxTextWidth + 12

		-- Clamp between min and max
		totalWidth = math.clamp(totalWidth, minDropdownWidth, maxDropdownWidth)

		return totalWidth
	end

	local function applyOverlayZIndex(layer)
		layer = layer or currentOverlayLayer()
		local overlayBaseZ = layer and layer.ZIndex or 0
		local blockerZ = overlayBlocker and overlayBlocker.ZIndex or overlayBaseZ

		-- Find maximum ZIndex in the layer to ensure dropdown is on top
		local maxZInLayer = overlayBaseZ
		if layer then
			for _, child in ipairs(layer:GetDescendants()) do
				if child:IsA("GuiObject") then
					maxZInLayer = math.max(maxZInLayer, child.ZIndex)
				end
			end
		end

		local dropdownZ = math.max(maxZInLayer + 10, overlayBaseZ + 2, blockerZ + 1, DROPDOWN_BASE_Z)
		dropdownList.ZIndex = dropdownZ
		dropdownScroll.ZIndex = dropdownZ + 1
		updateOptionZIndices(dropdownScroll.ZIndex + 1)

		if dependencies.Debug and dependencies.Debug.IsEnabled() then
			dependencies.Debug.printf("[Dropdown] Applied overlay ZIndex: dropdown=%d, scroll=%d (max in layer was %d)",
				dropdownZ, dropdownZ + 1, maxZInLayer)
		end
	end

	local function positionDropdown(width, height, skipCreate)
		height = height or dropdownHeight
		-- Use calculated optimal width if not provided
		if not width then
			local optimalWidth = calculateOptimalWidth()
			width = math.max(btn.AbsoluteSize.X, inlineWidth, optimalWidth)
		end

		local layer = skipCreate and currentOverlayLayer() or resolveOverlayLayer()

		if layer then
			dropdownList.Parent = layer
			applyOverlayZIndex(layer)

			local overlayOffset = layer.AbsolutePosition
			local buttonPos = btn.AbsolutePosition
			local buttonSize = btn.AbsoluteSize
			local screenSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)

			local dropdownX = buttonPos.X - overlayOffset.X + buttonSize.X - width
			local dropdownY = buttonPos.Y - overlayOffset.Y + buttonSize.Y + 4

			local minX = -overlayOffset.X + 4
			local maxX = screenSize.X - width - overlayOffset.X - 4
			local minY = -overlayOffset.Y + buttonSize.Y
			local maxY = screenSize.Y - height - overlayOffset.Y - 4

			dropdownX = math.clamp(dropdownX, minX, math.max(minX, maxX))
			dropdownY = math.clamp(dropdownY, minY, math.max(minY, maxY))

			dropdownList.Position = UDim2.fromOffset(dropdownX, dropdownY)
		else
			dropdownList.Parent = inlineParent
			dropdownList.ZIndex = DROPDOWN_BASE_Z
			dropdownScroll.ZIndex = DROPDOWN_BASE_Z + 1
			updateOptionZIndices(dropdownScroll.ZIndex + 1)
			dropdownList.Position = UDim2.new(1, -(width + 6), 0.5, 40)
		end

		dropdownList.Size = UDim2.new(0, width, 0, height)
		return width
	end

	local function rebuildOptions()
		for _, child in ipairs(dropdownScroll:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		table.clear(optionButtons)
		local spacingPerItem = 4
		local totalItemsHeight = (#values * itemHeight) + ((#values - 1) * spacingPerItem)
		local paddingTotal = 8 + 8

		dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, totalItemsHeight + 8)
		dropdownHeight = math.min(totalItemsHeight + paddingTotal, maxHeight)

		updateButtonText()

		for i, value in ipairs(values) do
			local optionBtn = Instance.new("TextButton")
			optionBtn.Name = "Option_" .. i
			optionBtn.Size = UDim2.new(1, -8, 0, 36)
			local selected = isValueSelected(value)
			optionBtn.BackgroundColor3 = selected and pal3.Accent or pal3.Card
			optionBtn.BackgroundTransparency = selected and 0.8 or 0
			optionBtn.BorderSizePixel = 0
			optionBtn.Text = ""
			optionBtn.AutoButtonColor = false
			optionBtn.LayoutOrder = i
			optionBtn.ZIndex = dropdownScroll.ZIndex + 1
			optionBtn.Parent = dropdownScroll
			corner(optionBtn, 6)

			-- Icon column (fixed width for checkbox)
			local iconFrame = Instance.new("Frame")
			iconFrame.Name = "IconColumn"
			iconFrame.BackgroundTransparency = 1
			iconFrame.Size = UDim2.new(0, 32, 1, 0)
			iconFrame.Position = UDim2.new(0, 4, 0, 0)
			iconFrame.ZIndex = optionBtn.ZIndex + 1
			iconFrame.Parent = optionBtn

			local checkbox = Instance.new("TextLabel")
			checkbox.Name = "Checkbox"
			checkbox.BackgroundTransparency = 1
			checkbox.Size = UDim2.new(1, 0, 1, 0)
			checkbox.Position = UDim2.new(0, 0, 0, 0)
			checkbox.Font = Enum.Font.GothamBold
			checkbox.TextSize = 16
			checkbox.Text = selected and "☑" or "☐"
			checkbox.TextColor3 = selected and pal3.Accent or pal3.TextSub
			checkbox.TextXAlignment = Enum.TextXAlignment.Center
			checkbox.TextYAlignment = Enum.TextYAlignment.Center
			checkbox.ZIndex = iconFrame.ZIndex + 1
			checkbox.Parent = iconFrame

			-- Text column (flexible width)
			local textFrame = Instance.new("Frame")
			textFrame.Name = "TextColumn"
			textFrame.BackgroundTransparency = 1
			textFrame.Size = UDim2.new(1, -44, 1, 0)
			textFrame.Position = UDim2.new(0, 40, 0, 0)
			textFrame.ZIndex = optionBtn.ZIndex + 1
			textFrame.Parent = optionBtn

			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			textLabel.BackgroundTransparency = 1
			textLabel.Size = UDim2.new(1, 0, 1, 0)
			textLabel.Position = UDim2.new(0, 0, 0, 0)
			textLabel.Font = Enum.Font.GothamMedium
			textLabel.TextSize = 14
			textLabel.Text = tostring(value)
			textLabel.TextColor3 = selected and pal3.Accent or pal3.Text
			textLabel.TextXAlignment = Enum.TextXAlignment.Left
			textLabel.TextYAlignment = Enum.TextYAlignment.Center
			textLabel.TextTruncate = Enum.TextTruncate.AtEnd
			textLabel.TextWrapped = false
			textLabel.ZIndex = textFrame.ZIndex + 1
			textLabel.Parent = textFrame

			optionBtn.MouseButton1Click:Connect(function()
				if locked() then return end

				-- Toggle selection
				local found = false
				for k, v in ipairs(selectedValues) do
					if v == value then
						table.remove(selectedValues, k)
						found = true
						break
					end
				end

				if not found then
					table.insert(selectedValues, value)
				end

				updateButtonText()
				updateHighlight()

				if o.OnChanged then
					task.spawn(o.OnChanged, selectedValues)
				end
				if o.Flag then RvrseUI:_autoSave() end
			end)

			optionBtn.MouseEnter:Connect(function()
				if not isValueSelected(value) then
					Animator:Tween(optionBtn, {BackgroundColor3 = pal3.Hover}, Animator.Spring.Fast)
				end
			end)

			optionBtn.MouseLeave:Connect(function()
				if not isValueSelected(value) then
					Animator:Tween(optionBtn, {BackgroundColor3 = pal3.Card}, Animator.Spring.Fast)
				end
			end)

			optionButtons[i] = optionBtn
		end

		updateHighlight()
	end

	rebuildOptions()
	visual()

	-- Connect blocker click handler (called AFTER blocker is created)
	local function connectBlockerHandler()
		if overlayBlocker and OverlayService then
			if overlayBlockerConnection then
				overlayBlockerConnection:Disconnect()
			end

			overlayBlockerConnection = overlayBlocker.MouseButton1Click:Connect(function()
				if setOpen then
					setOpen(false)
				end
			end)
		end
	end

	setOpen = function(state)
		if locked() then
			return
		end

		if state == dropdownOpen then
			if state then
				local optimalWidth = calculateOptimalWidth()
				positionDropdown(math.max(btn.AbsoluteSize.X, inlineWidth, optimalWidth), dropdownHeight, true)
			end
			return
		end

		dropdownOpen = state
		arrow.Text = dropdownOpen and "▲" or "▼"

		if dropdownOpen then
			if o.OnOpen then
				o.OnOpen()
			end

			local spacingPerItem = 4
			local totalItemsHeight = (#values * itemHeight) + ((#values - 1) * spacingPerItem)
			local paddingTotal = 8 + 8

			dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, totalItemsHeight + 8)
			dropdownHeight = math.min(totalItemsHeight + paddingTotal, maxHeight)

			if #values > 0 then
				dropdownHeight = math.max(dropdownHeight, itemHeight + paddingTotal)
			end

			showOverlayBlocker()
			connectBlockerHandler()

			-- Calculate optimal width based on content
			local optimalWidth = calculateOptimalWidth()
			local targetWidth = math.max(btn.AbsoluteSize.X, inlineWidth, optimalWidth)
			positionDropdown(targetWidth, dropdownHeight)

			-- Diagnostic logging for render order debugging
			if dependencies.Debug and dependencies.Debug.IsEnabled() then
				local parent = dropdownList
				local clipPath = {}
				while parent do
					if parent:IsA("ScreenGui") then
						dependencies.Debug.printf("[Dropdown] ScreenGui '%s': DisplayOrder=%d", parent.Name, parent.DisplayOrder)
						break
					elseif parent:IsA("GuiObject") then
						table.insert(clipPath, string.format("%s (ZIndex=%d, Clips=%s)",
							parent.Name, parent.ZIndex, tostring(parent.ClipsDescendants)))
					end
					parent = parent.Parent
				end
				if #clipPath > 0 then
					dependencies.Debug.printf("[Dropdown] Hierarchy: %s", table.concat(clipPath, " → "))
				end
				dependencies.Debug.printf("[Dropdown] List ZIndex=%d, Scroll ZIndex=%d, Blocker ZIndex=%d",
					dropdownList.ZIndex, dropdownScroll.ZIndex,
					overlayBlocker and overlayBlocker.ZIndex or 0)
			end

			dropdownList.Visible = true
			dropdownScroll.CanvasPosition = Vector2.new(0, 0)
		else
			local layer = currentOverlayLayer()
			local targetWidth = layer and math.max(btn.AbsoluteSize.X, inlineWidth) or inlineWidth
			dropdownList.Visible = false
			dropdownList.Size = UDim2.new(0, targetWidth, 0, 0)
			collapseInline()
			hideOverlayBlocker(false)
			if o.OnClose then
				o.OnClose()
			end
		end
	end

	-- Toggle dropdown on button click
	btn.MouseButton1Click:Connect(function()
		if not dropdownOpen then
			if o.OnRefresh then
				local newValues = o.OnRefresh()
				if newValues and type(newValues) == "table" then
					values = {}
					for _, val in ipairs(newValues) do
						table.insert(values, val)
					end
					rebuildOptions()
				end
			elseif o.RefreshOnOpen then
				rebuildOptions()
			end
		end

		setOpen(not dropdownOpen)
	end)

	-- Close when clicking outside (inline mode)
	UIS.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if not dropdownOpen then return end
			if currentOverlayLayer() then return end

			task.wait(0.05)
			if not btn:IsDescendantOf(game) then
				return
			end

			local mousePos = UIS:GetMouseLocation()
			local dropdownPos = dropdownList.AbsolutePosition
			local dropdownSize = dropdownList.AbsoluteSize
			local btnPos = btn.AbsolutePosition
			local btnSize = btn.AbsoluteSize

			local inDropdown = mousePos.X >= dropdownPos.X and mousePos.X <= dropdownPos.X + dropdownSize.X and
				mousePos.Y >= dropdownPos.Y and mousePos.Y <= dropdownPos.Y + dropdownSize.Y

			local inButton = mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X and
				mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y

			if not inDropdown and not inButton then
				setOpen(false)
			end
		end
	end)

	btn.MouseEnter:Connect(function()
		if not locked() then
			Animator:Tween(btn, {BackgroundColor3 = pal3.Hover}, Animator.Spring.Fast)
		end
	end)
	btn.MouseLeave:Connect(function()
		if not locked() then
			Animator:Tween(btn, {BackgroundColor3 = pal3.Card}, Animator.Spring.Fast)
		end
	end)

	table.insert(RvrseUI._lockListeners, visual)

	f.Destroying:Connect(function()
		if dropdownOpen then
			hideOverlayBlocker(true)
			dropdownOpen = false
		end
	end)

	-- Build dropdownAPI methods
	dropdownAPI.Set = function(_, v, suppressCallback)
		-- For multi-select, v should be an array
		if type(v) == "table" then
			selectedValues = {}
			for _, val in ipairs(v) do
				table.insert(selectedValues, val)
			end
		else
			selectedValues = {}
		end

		updateButtonText()
		updateHighlight()
		visual()

		if not suppressCallback and o.OnChanged then
			task.spawn(o.OnChanged, selectedValues)
		end
	end

	dropdownAPI.Get = function()
		return selectedValues
	end

	dropdownAPI.Refresh = function(_, newValues)
		if newValues then
			values = {}
			for _, val in ipairs(newValues) do
				values[#values + 1] = val
			end
		end
		rebuildOptions()
		visual()
		if dropdownOpen then
			positionDropdown(nil, dropdownHeight)
		end
	end

	dropdownAPI.SetVisible = function(_, visible)
		f.Visible = visible
	end

	dropdownAPI.SetOpen = function(_, state)
		setOpen(state and true or false)
	end

	-- Multi-select methods
	dropdownAPI.SelectAll = function(_)
		selectedValues = {}
		for _, val in ipairs(values) do
			table.insert(selectedValues, val)
		end
		updateButtonText()
		updateHighlight()
		if o.OnChanged then
			task.spawn(o.OnChanged, selectedValues)
		end
		if o.Flag then RvrseUI:_autoSave() end
	end

	dropdownAPI.ClearAll = function(_)
		selectedValues = {}
		updateButtonText()
		updateHighlight()
		if o.OnChanged then
			task.spawn(o.OnChanged, selectedValues)
		end
		if o.Flag then RvrseUI:_autoSave() end
	end

	-- Always returns selected values as table
	dropdownAPI.CurrentOption = selectedValues

	if o.Flag then
		RvrseUI.Flags[o.Flag] = dropdownAPI
	end

	return dropdownAPI
end

return Dropdown
