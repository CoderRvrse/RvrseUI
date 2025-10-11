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
	local OverlayLayer = dependencies.OverlayLayer
	local OverlayService = dependencies.Overlay

	if OverlayService and not OverlayLayer then
		OverlayLayer = OverlayService:GetLayer()
	end

	-- Settings
	local values = {}
	for _, v in ipairs(o.Values or {}) do
		table.insert(values, v)
	end

	local maxHeight = o.MaxHeight or 160
	local itemHeight = 32
	local placeholder = o.PlaceholderText or "Select"
	local useOverlay = OverlayLayer ~= nil and o.Overlay ~= false

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
	dropdownLayout.Padding = UDim.new(0, 2)
	dropdownLayout.Parent = dropdownScroll

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
		if not useOverlay then
			return
		end

		if OverlayService then
			overlayBlocker = OverlayService:ShowBlocker({ Transparency = 0.45 })
			if overlayBlockerConnection then
				overlayBlockerConnection:Disconnect()
			end
			overlayBlockerConnection = overlayBlocker.MouseButton1Click:Connect(function()
				setOpen(false)
			end)
		else
			if not overlayBlocker or not overlayBlocker.Parent then
				overlayBlocker = Instance.new("TextButton")
				overlayBlocker.Name = "DropdownOverlayBlocker"
				overlayBlocker.AutoButtonColor = false
				overlayBlocker.Text = ""
				overlayBlocker.BackgroundColor3 = Color3.new(0, 0, 0)
				overlayBlocker.BackgroundTransparency = 0.55
				overlayBlocker.BorderSizePixel = 0
				overlayBlocker.Size = UDim2.new(1, 0, 1, 0)
				overlayBlocker.ZIndex = 900
				overlayBlocker.Visible = false
				overlayBlocker.Parent = OverlayLayer
				overlayBlocker.MouseButton1Click:Connect(function()
					setOpen(false)
				end)
			end
			overlayBlocker.Visible = true
			overlayBlocker.Active = true
			overlayBlocker.Modal = true
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

	local function collapseInline()
		dropdownList.Parent = inlineParent
		dropdownList.ZIndex = 100
		dropdownScroll.ZIndex = 101
		dropdownList.Position = UDim2.new(1, -(inlineWidth + 6), 0.5, 40)
		dropdownList.Size = UDim2.new(0, inlineWidth, 0, dropdownList.Size.Y.Offset)
	end

	local function repositionOverlay(width)
		width = width or math.max(btn.AbsoluteSize.X, inlineWidth)
		dropdownList.Parent = OverlayLayer
		dropdownList.ZIndex = 200
		dropdownScroll.ZIndex = 201
		local absPos = btn.AbsolutePosition
		dropdownList.Position = UDim2.fromOffset(absPos.X, absPos.Y + btn.AbsoluteSize.Y + 6)
		dropdownList.Size = UDim2.new(0, width, 0, dropdownList.Size.Y.Offset)
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
		dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, #values * itemHeight)
		dropdownHeight = math.min(#values * itemHeight, maxHeight)

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
			optionBtn.Size = UDim2.new(1, -8, 0, 28)
			optionBtn.BackgroundColor3 = i == idx and pal3.Accent or pal3.Card
			optionBtn.BackgroundTransparency = i == idx and 0.8 or 0
			optionBtn.BorderSizePixel = 0
			optionBtn.Font = Enum.Font.Gotham
			optionBtn.TextSize = 12
			optionBtn.TextColor3 = i == idx and pal3.Accent or pal3.Text
			optionBtn.Text = tostring(value)
			optionBtn.AutoButtonColor = false
			optionBtn.LayoutOrder = i
			optionBtn.ZIndex = 102
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
			if state and useOverlay then
				repositionOverlay()
			end
			return
		end

		dropdownOpen = state
		arrow.Text = dropdownOpen and "▲" or "▼"

		if dropdownOpen then
			if o.OnOpen then
				o.OnOpen()
			end

			dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, #values * itemHeight)
			dropdownHeight = math.min(#values * itemHeight, maxHeight)

			if useOverlay then
				showOverlayBlocker()
				local width = repositionOverlay()
				dropdownList.Size = UDim2.new(0, width, 0, 0)
			else
				collapseInline()
				dropdownList.Size = UDim2.new(0, inlineWidth, 0, 0)
			end

			dropdownList.Visible = true
			local targetWidth = useOverlay and math.max(btn.AbsoluteSize.X, inlineWidth) or inlineWidth
			Animator:Tween(dropdownList, {
				Size = UDim2.new(0, targetWidth, 0, dropdownHeight)
			}, Animator.Spring.Snappy)
		else
			local targetWidth = useOverlay and math.max(btn.AbsoluteSize.X, inlineWidth) or inlineWidth
			Animator:Tween(dropdownList, {
				Size = UDim2.new(0, targetWidth, 0, 0)
			}, Animator.Spring.Fast)

			task.delay(0.15, function()
				if dropdownList then
					dropdownList.Visible = false
					collapseInline()
					dropdownList.Size = UDim2.new(0, inlineWidth, 0, 0)
					if useOverlay then
						hideOverlayBlocker(false)
					end
					if o.OnClose then
						o.OnClose()
					end
				end
			end)
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
			if useOverlay then return end

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
				if useOverlay then
					repositionOverlay()
				end
				dropdownList.Size = UDim2.new(0, useOverlay and math.max(btn.AbsoluteSize.X, inlineWidth) or inlineWidth, 0, dropdownHeight)
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
