-- Dropdown Element Module
-- Provides in-flow or overlay dropdown with dynamic data refresh support

local Dropdown = {}

function Dropdown.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local corner = dependencies.corner
	local stroke = dependencies.stroke
	local shadow = dependencies.shadow
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
	for _, v in ipairs(o.Values or {}) do
		table.insert(values, v)
	end

	local maxHeight = o.MaxHeight or 240  -- Increased to 240 for better visibility
	local itemHeight = 40  -- Increased to 40 for better touch targets
	local placeholder = o.PlaceholderText or "Select"
	local DROPDOWN_BASE_Z = 3000
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
			hostGui = Instance.new("ScreenGui")
			hostGui.Name = "RvrseUI_DropdownHost"
			hostGui.ResetOnSpawn = false
			hostGui.IgnoreGuiInset = true
			hostGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			hostGui.DisplayOrder = 2000000
			hostGui.Parent = playerGui
			fallbackOverlayGui = hostGui
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
	shadow(dropdownList, 0.6, 16)

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
	dropdownLayout.Padding = UDim.new(0, 4)  -- Increased from 2 to 4 for better spacing
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
	local idx = 1

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
		-- Always show overlay blocker for dropdown
		if OverlayService then
			overlayBlocker = OverlayService:ShowBlocker({
				Transparency = 0.45,
				ZIndex = DROPDOWN_BASE_Z - 2,
			})
			if overlayBlockerConnection then
				overlayBlockerConnection:Disconnect()
			end
			overlayBlockerConnection = overlayBlocker.MouseButton1Click:Connect(function()
				setOpen(false)
			end)
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
				overlayBlocker.MouseButton1Click:Connect(function()
					setOpen(false)
				end)
			elseif overlayBlocker.Parent ~= layer then
				overlayBlocker.Parent = layer
			end
			overlayBlocker.Visible = true
			overlayBlocker.Active = true
			overlayBlocker.Modal = true
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

	local function updateButtonText()
		if values[idx] then
			btn.Text = tostring(values[idx])
		else
			btn.Text = placeholder
		end
	end

	local function updateHighlight()
		for i, optionBtn in ipairs(optionButtons) do
			if i == idx then
				optionBtn.BackgroundColor3 = pal3.Accent
				optionBtn.BackgroundTransparency = 0.8
				optionBtn.TextColor3 = pal3.Accent
			else
				optionBtn.BackgroundColor3 = pal3.Card
				optionBtn.BackgroundTransparency = 0
				optionBtn.TextColor3 = pal3.Text
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

	local function applyOverlayZIndex(layer)
		layer = layer or currentOverlayLayer()
		local overlayBaseZ = layer and layer.ZIndex or 0
		local blockerZ = overlayBlocker and overlayBlocker.ZIndex or overlayBaseZ
		local dropdownZ = math.max(overlayBaseZ + 2, blockerZ + 1, DROPDOWN_BASE_Z)
		dropdownList.ZIndex = dropdownZ
		dropdownScroll.ZIndex = dropdownZ + 1
		updateOptionZIndices(dropdownScroll.ZIndex + 1)
	end

	local function positionDropdown(width, height, skipCreate)
		height = height or dropdownHeight
		width = width or math.max(btn.AbsoluteSize.X, inlineWidth)

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

	local setOpen -- forward declaration

	local function rebuildOptions()

		for _, child in ipairs(dropdownScroll:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		table.clear(optionButtons)
		-- Calculate proper height: items + spacing + padding
		local spacingPerItem = 4  -- From UIListLayout.Padding
		local totalItemsHeight = (#values * itemHeight) + ((#values - 1) * spacingPerItem)
		local paddingTotal = 8 + 8  -- Top + Bottom padding (4+4 each side, doubled for Frame + Scroll)


		dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, totalItemsHeight + 8)  -- Add 8 for scroll padding
		dropdownHeight = math.min(totalItemsHeight + paddingTotal, maxHeight)


		if #values == 0 then
			idx = 0
		else
			if idx < 1 or idx > #values then
				idx = 1
			end
		end
		updateButtonText()

		for i, value in ipairs(values) do
			local optionBtn = Instance.new("TextButton")
			optionBtn.Name = "Option_" .. i
			optionBtn.Size = UDim2.new(1, -8, 0, 36)  -- Match itemHeight (40 - 4 for padding)
			optionBtn.BackgroundColor3 = i == idx and pal3.Accent or pal3.Card
			optionBtn.BackgroundTransparency = i == idx and 0.8 or 0
			optionBtn.BorderSizePixel = 0
			optionBtn.Font = Enum.Font.GothamMedium  -- Changed to Medium for better readability
			optionBtn.TextSize = 14  -- Increased from 13 to 14 for clarity
			optionBtn.TextColor3 = i == idx and pal3.Accent or pal3.Text
			optionBtn.Text = tostring(value)
			optionBtn.AutoButtonColor = false
			optionBtn.LayoutOrder = i
			optionBtn.ZIndex = dropdownScroll.ZIndex + 1
			optionBtn.Parent = dropdownScroll
			corner(optionBtn, 6)

			optionBtn.MouseButton1Click:Connect(function()
				if locked() then return end
				idx = i
				updateButtonText()
				updateHighlight()
				setOpen(false)

				if o.OnChanged then
					task.spawn(o.OnChanged, value)
				end
				if o.Flag then RvrseUI:_autoSave() end
			end)

			optionBtn.MouseEnter:Connect(function()
				if i ~= idx then
					Animator:Tween(optionBtn, {BackgroundColor3 = pal3.Hover}, Animator.Spring.Fast)
				end
			end)

			optionBtn.MouseLeave:Connect(function()
				if i ~= idx then
					Animator:Tween(optionBtn, {BackgroundColor3 = pal3.Card}, Animator.Spring.Fast)
				end
			end)

			optionButtons[i] = optionBtn
		end

		updateHighlight()
	end

	rebuildOptions()
	visual()

	function setOpen(state)
		if locked() then
			return
		end

		if state == dropdownOpen then
			if state then
				positionDropdown(math.max(btn.AbsoluteSize.X, inlineWidth, 150), dropdownHeight, true)
			end
			return
		end

		dropdownOpen = state
		arrow.Text = dropdownOpen and "▲" or "▼"

		if dropdownOpen then
			if o.OnOpen then
				o.OnOpen()
			end

			-- Calculate proper dropdown height
			local spacingPerItem = 4
			local totalItemsHeight = (#values * itemHeight) + ((#values - 1) * spacingPerItem)
			local paddingTotal = 8 + 8

			dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, totalItemsHeight + 8)
			dropdownHeight = math.min(totalItemsHeight + paddingTotal, maxHeight)

			-- Ensure minimum height if there are items
			if #values > 0 then
				dropdownHeight = math.max(dropdownHeight, itemHeight + paddingTotal)
			end

			showOverlayBlocker()

			local targetWidth = math.max(btn.AbsoluteSize.X, inlineWidth, 150)  -- Minimum 150px width
			positionDropdown(targetWidth, dropdownHeight)

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
		-- Refresh dropdown values before opening (for dynamic config lists)
		if not dropdownOpen then
			-- If a refresh callback is provided, use it to get new values
			if o.OnRefresh then
				local newValues = o.OnRefresh()
				if newValues and type(newValues) == "table" then
					values = {}
					for _, val in ipairs(newValues) do
						table.insert(values, val)
					end
					rebuildOptions()
				else
					warn("[Dropdown] OnRefresh returned invalid data: " .. tostring(type(newValues)))
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


	local dropdownAPI = {
		Set = function(_, v, suppressCallback)
			local foundIndex
			if v ~= nil then
				for i, val in ipairs(values) do
					if val == v then
						foundIndex = i
						break
					end
				end
			end

			if foundIndex then
				idx = foundIndex
			else
				if #values > 0 then
					idx = 1
				else
					idx = 0
				end
			end

			updateButtonText()
			updateHighlight()
			visual()

			if not suppressCallback and o.OnChanged and values[idx] then
				task.spawn(o.OnChanged, values[idx])
			end
		end,

		Get = function()
			return values[idx]
		end,

		Refresh = function(_, newValues)
			if newValues then
				values = {}
				for _, val in ipairs(newValues) do
					values[#values + 1] = val
				end
				idx = 1
			end
			rebuildOptions()
			visual()
			if dropdownOpen then
				positionDropdown(nil, dropdownHeight)
			end
		end,

		SetVisible = function(_, visible)
			f.Visible = visible
		end,

		CurrentOption = values[idx],
		SetOpen = function(_, state)
			setOpen(state and true or false)
		end
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = dropdownAPI
	end

	return dropdownAPI
end

return Dropdown
