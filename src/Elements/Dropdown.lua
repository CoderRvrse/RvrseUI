-- Dropdown Element Module
-- Part of RvrseUI v2.13.0 Modular Architecture
-- Extracted from RvrseUI.lua (lines 2856-3246)

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

	-- Calculate dropdown height
	local values = o.Values or {}
	local maxHeight = 160
	local itemHeight = 32
	local dropdownHeight = math.min(#values * itemHeight, maxHeight)

	-- Create card with DISABLED clipping (CRITICAL for dropdown overflow)
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

	-- Dropdown arrow indicator
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

	local idx = 1
	for i, v in ipairs(values) do
		if v == o.Default then
			idx = i
			break
		end
	end
	btn.Text = tostring(values[idx] or "Select")

	-- Dropdown list container (positioned BELOW the button with 8px gap)
	local dropdownList = Instance.new("Frame")
	dropdownList.Name = "DropdownList"
	dropdownList.BackgroundColor3 = pal3.Elevated
	dropdownList.BorderSizePixel = 0
	dropdownList.Position = UDim2.new(1, -136, 0.5, 40)  -- Below button with gap
	dropdownList.Size = UDim2.new(0, 130, 0, 0)  -- Start at 0 height for animation
	dropdownList.Visible = false
	dropdownList.ZIndex = 100
	dropdownList.ClipsDescendants = true
	dropdownList.Parent = f
	corner(dropdownList, 8)
	stroke(dropdownList, pal3.Accent, 1)

	-- Shadow for dropdown
	shadow(dropdownList, 0.6, 16)

	local dropdownScroll = Instance.new("ScrollingFrame")
	dropdownScroll.BackgroundTransparency = 1
	dropdownScroll.BorderSizePixel = 0
	dropdownScroll.Size = UDim2.new(1, -8, 1, -8)
	dropdownScroll.Position = UDim2.new(0, 4, 0, 4)
	dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, #values * itemHeight)
	dropdownScroll.ScrollBarThickness = 4
	dropdownScroll.ScrollBarImageColor3 = pal3.Accent
	dropdownScroll.ZIndex = 101
	dropdownScroll.Parent = dropdownList

	local dropdownLayout = Instance.new("UIListLayout")
	dropdownLayout.FillDirection = Enum.FillDirection.Vertical
	dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
	dropdownLayout.Padding = UDim.new(0, 2)
	dropdownLayout.Parent = dropdownScroll

local dropdownOpen = false
local optionButtons = {}
local inlineParent = dropdownList.Parent
local overlayBlocker
local inlineWidth = btn.Size.X.Offset
local useOverlay = OverlayLayer ~= nil and (o.Overlay ~= false)
local setOpen
local function ensureBlocker()
	if overlayBlocker or not useOverlay then
		return
	end
	overlayBlocker = Instance.new("TextButton")
	overlayBlocker.Name = "DropdownOverlayBlocker"
	overlayBlocker.BackgroundTransparency = 1
	overlayBlocker.BorderSizePixel = 0
	overlayBlocker.Text = ""
	overlayBlocker.AutoButtonColor = false
	overlayBlocker.Size = UDim2.new(1, 0, 1, 0)
	overlayBlocker.Position = UDim2.new(0, 0, 0, 0)
	overlayBlocker.ZIndex = 190
	overlayBlocker.Visible = false
	overlayBlocker.Parent = OverlayLayer
	overlayBlocker.MouseButton1Click:Connect(function()
		if dropdownOpen and setOpen then
			setOpen(false)
		end
	end)
end

	-- Create option buttons
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

		optionButtons[i] = optionBtn

		optionBtn.MouseButton1Click:Connect(function()
			local function locked()
				return o.RespectLock and RvrseUI.Store:IsLocked(o.RespectLock)
			end

			if locked() then return end

			-- Update selection
			idx = i
			btn.Text = tostring(value)

			-- Update all option visuals
			for j, obtn in ipairs(optionButtons) do
				if j == i then
					obtn.BackgroundColor3 = pal3.Accent
					obtn.BackgroundTransparency = 0.8
					obtn.TextColor3 = pal3.Accent
				else
					obtn.BackgroundColor3 = pal3.Card
					obtn.BackgroundTransparency = 0
					obtn.TextColor3 = pal3.Text
				end
			end

			setOpen(false)

			-- Trigger callback
			if o.OnChanged then
				task.spawn(function()
					o.OnChanged(value)
				end)
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
	end

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
	visual()

	local function positionOverlay()
		local width = btn.AbsoluteSize.X
		if width <= 0 then
			width = inlineWidth
		end
		if useOverlay and OverlayLayer then
			local absPos = btn.AbsolutePosition
			dropdownList.Parent = OverlayLayer
			dropdownList.ZIndex = 200
			dropdownScroll.ZIndex = 201
			dropdownList.Position = UDim2.fromOffset(absPos.X, absPos.Y + btn.AbsoluteSize.Y + 6)
			dropdownList.Size = UDim2.new(0, width, 0, dropdownList.Size.Y.Offset)
		else
			dropdownList.Parent = inlineParent
			dropdownList.ZIndex = 100
			dropdownScroll.ZIndex = 101
			dropdownList.Position = UDim2.new(1, -136, 0.5, 40)
		end
		return width
	end

	function setOpen(state)
	if locked() then return end
if state == dropdownOpen then
	if not state then
		return
	end
else
	dropdownOpen = state
end
arrow.Text = dropdownOpen and "▲" or "▼"

		dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, #values * itemHeight)
		dropdownHeight = math.min(#values * itemHeight, maxHeight)

		if dropdownOpen then
			local width = positionOverlay()
			if useOverlay and OverlayLayer then
				ensureBlocker()
				if overlayBlocker then
					overlayBlocker.Visible = true
					overlayBlocker.Parent = OverlayLayer
				end
			else
				dropdownList.Size = UDim2.new(0, inlineWidth, 0, 0)
			end
			dropdownList.Visible = true
			local targetWidth = useOverlay and btn.AbsoluteSize.X or inlineWidth
			if targetWidth <= 0 then targetWidth = inlineWidth end
			Animator:Tween(dropdownList, {
				Size = UDim2.new(0, targetWidth, 0, dropdownHeight)
			}, Animator.Spring.Snappy)
		else
			local width = useOverlay and btn.AbsoluteSize.X or inlineWidth
			if width <= 0 then width = inlineWidth end
			Animator:Tween(dropdownList, {
				Size = UDim2.new(0, width, 0, 0)
			}, Animator.Spring.Fast)
			task.delay(0.15, function()
				if dropdownList then
					dropdownList.Visible = false
					if useOverlay and OverlayLayer then
						dropdownList.Parent = inlineParent
						dropdownList.Position = UDim2.new(1, -136, 0.5, 40)
						dropdownList.Size = UDim2.new(0, 130, 0, 0)
						if overlayBlocker then
							overlayBlocker.Visible = false
							overlayBlocker.Parent = OverlayLayer
						end
					end
				end
			end)
		end
	end

	btn.MouseButton1Click:Connect(function()
		setOpen(not dropdownOpen)
	end)

	-- Close dropdown when clicking outside
	UIS.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if not dropdownOpen then return end
			if useOverlay and OverlayLayer then
				return
			end

			task.wait(0.05)  -- Small delay to ensure AbsolutePosition is updated

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

	local dropdownAPI = {
		Set = function(_, v)
			for i, val in ipairs(values) do
				if val == v then
					idx = i
					break
				end
			end
			btn.Text = tostring(values[idx])

			-- Update dropdown options highlighting
			for j, obtn in ipairs(optionButtons) do
				if j == idx then
					obtn.BackgroundColor3 = pal3.Accent
					obtn.BackgroundTransparency = 0.8
					obtn.TextColor3 = pal3.Accent
				else
					obtn.BackgroundColor3 = pal3.Card
					obtn.BackgroundTransparency = 0
					obtn.TextColor3 = pal3.Text
				end
			end

			visual()
			if o.OnChanged then task.spawn(o.OnChanged, values[idx]) end
			if o.Flag then RvrseUI:_autoSave() end  -- Auto-save on Set
		end,
		Get = function() return values[idx] end,
		Refresh = function(_, newValues)
			if newValues then
				values = newValues
				idx = 1
				btn.Text = tostring(values[idx] or "Select")

				-- Rebuild dropdown options
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

					optionButtons[i] = optionBtn

					optionBtn.MouseButton1Click:Connect(function()
						if locked() then return end
						idx = i
						btn.Text = tostring(value)

						for j, obtn in ipairs(optionButtons) do
							if j == i then
								obtn.BackgroundColor3 = pal3.Accent
								obtn.BackgroundTransparency = 0.8
								obtn.TextColor3 = pal3.Accent
							else
								obtn.BackgroundColor3 = pal3.Card
								obtn.BackgroundTransparency = 0
								obtn.TextColor3 = pal3.Text
							end
						end

						setOpen(false)

						if o.OnChanged then task.spawn(o.OnChanged, value) end
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
			end
			if dropdownOpen then
				setOpen(true)
			end
		end
		visual()
	end,
		SetVisible = function(_, visible)
			f.Visible = visible
		end,
		CurrentOption = values[idx]
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = dropdownAPI
	end

	return dropdownAPI
end

return Dropdown
