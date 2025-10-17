-- Legacy dropdown implementation restored from 2025-10-09 backup.
-- Provides inline dropdown behaviour without overlay layers for comparison/debugging.

local DropdownLegacy = {}

function DropdownLegacy.Create(o, dependencies)
	o = o or {}

	local card = dependencies.card
	local corner = dependencies.corner
	local stroke = dependencies.stroke
	local shadow = dependencies.shadow
	local pal3 = dependencies.pal3
	local Animator = dependencies.Animator
	local RvrseUI = dependencies.RvrseUI
	local UIS = dependencies.UIS

	local values = {}
	for _, v in ipairs(o.Values or {}) do
		values[#values + 1] = v
	end

	local maxHeight = o.MaxHeight or 160
	local itemHeight = o.ItemHeight or 32
	local dropdownHeight = 0
	local idx = 1

	if o.Default then
		for i, v in ipairs(values) do
			if v == o.Default then
				idx = i
				break
			end
		end
	end

	local f = card(48)
	f.ClipsDescendants = false

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, -140, 1, 0)
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = pal3.Text
	lbl.Text = o.Text or "Dropdown"
	lbl.Parent = f

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

local dropdownWidth = btn.Size.X.Offset

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

	local dropdownList = Instance.new("Frame")
	dropdownList.Name = "DropdownList"
	dropdownList.BackgroundColor3 = pal3.Elevated
	dropdownList.BorderSizePixel = 0
dropdownList.Position = UDim2.new(1, -(dropdownWidth + 6), 0.5, 40)
dropdownList.Size = UDim2.new(0, dropdownWidth, 0, 0)
	dropdownList.Visible = false
	dropdownList.ZIndex = 100
	dropdownList.ClipsDescendants = true
	dropdownList.Parent = f
	corner(dropdownList, 8)
	stroke(dropdownList, pal3.Accent, 1)
	-- shadow(dropdownList, 0.6, 16)  -- ⚠️ DISABLED: Shadows on dropdown menus can cause visual issues

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

	local dropdownPadding = Instance.new("UIPadding")
	dropdownPadding.PaddingTop = UDim.new(0, 4)
	dropdownPadding.PaddingBottom = UDim.new(0, 4)
	dropdownPadding.PaddingLeft = UDim.new(0, 4)
	dropdownPadding.PaddingRight = UDim.new(0, 4)
	dropdownPadding.Parent = dropdownScroll

	local dropdownOpen = false
	local optionButtons = {}

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

	local function updateButtonText()
		if values[idx] then
			btn.Text = tostring(values[idx])
		else
			btn.Text = o.PlaceholderText or "Select"
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

	local function rebuildOptions(newValues)
	if newValues then
		table.clear(values)
		for _, val in ipairs(newValues) do
			values[#values + 1] = val
		end
		if #values == 0 then
			idx = 0
		else
			idx = math.clamp(idx, 1, #values)
		end
	end

		for _, child in ipairs(dropdownScroll:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		table.clear(optionButtons)

		dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, #values * itemHeight)
		dropdownHeight = math.min(#values * itemHeight, maxHeight)

		for i, value in ipairs(values) do
			local optionBtn = Instance.new("TextButton")
			optionBtn.Name = "Option_" .. i
			optionBtn.Size = UDim2.new(1, -8, 0, itemHeight - 4)
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
				dropdownOpen = false
				arrow.Text = "▼"

			Animator:Tween(dropdownList, {
				Size = UDim2.new(0, dropdownWidth, 0, 0)
			}, Animator.Spring.Fast)

				task.delay(0.15, function()
					if dropdownList and dropdownList.Parent then
						dropdownList.Visible = false
					end
				end)

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

		updateButtonText()
		updateHighlight()
	end

	rebuildOptions()
	visual()

	local function toggleDropdown()
		if locked() then
			return
		end

	if not dropdownOpen then
		if o.OnRefresh then
			local newValues = o.OnRefresh()
			if type(newValues) == "table" then
				rebuildOptions(newValues)
			end
		elseif o.RefreshOnOpen then
			rebuildOptions()
		end

		if o.OnOpen then
			o.OnOpen()
		end

		dropdownOpen = true
		arrow.Text = "▲"

		dropdownList.Size = UDim2.new(0, dropdownWidth, 0, 0)
		dropdownList.Visible = true
		dropdownList.ZIndex = 100

		print(string.format("[DropdownLegacy] opening '%s' with %d options", o.Text or "Dropdown", #values))

		if #values == 0 then
			print("[DropdownLegacy] no options available, skipping expand")
			dropdownOpen = false
			arrow.Text = "▼"
			dropdownList.Visible = false
			return
		end

		Animator:Tween(dropdownList, {
			Size = UDim2.new(0, dropdownWidth, 0, dropdownHeight)
		}, Animator.Spring.Snappy)
	else
		dropdownOpen = false
		arrow.Text = "▼"

		Animator:Tween(dropdownList, {
			Size = UDim2.new(0, dropdownWidth, 0, 0)
		}, Animator.Spring.Fast)

		task.delay(0.15, function()
			if dropdownList and dropdownList.Parent then
				dropdownList.Visible = false
			end
		end)

		if o.OnClose then
			o.OnClose()
		end
	end
end

	btn.MouseButton1Click:Connect(toggleDropdown)

	UIS.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if not dropdownOpen then return end

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
				toggleDropdown()
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
				idx = #values > 0 and 1 or 0
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
			rebuildOptions(newValues)
			visual()
		end,

		SetVisible = function(_, visible)
			f.Visible = visible
		end,

		CurrentOption = values[idx],
		SetOpen = function(_, state)
			if state then
				if not dropdownOpen then
					toggleDropdown()
				end
			else
				if dropdownOpen then
					toggleDropdown()
				end
			end
		end
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = dropdownAPI
	end

	return dropdownAPI
end

return DropdownLegacy
