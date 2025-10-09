-- Slider Element Module
-- Part of RvrseUI v2.13.0 Modular Architecture
-- Extracted from RvrseUI.lua (lines 3355-3522)

local Slider = {}

function Slider.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local corner = dependencies.corner
	local shadow = dependencies.shadow
	local gradient = dependencies.gradient
	local pal3 = dependencies.pal3
	local Animator = dependencies.Animator
	local RvrseUI = dependencies.RvrseUI
	local UIS = dependencies.UIS

	local minVal = o.Min or 0
	local maxVal = o.Max or 100
	local step = o.Step or 1
	local value = o.Default or minVal

	local f = card(56)

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, 0, 0, 20)
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = pal3.Text
	lbl.Text = (o.Text or "Slider") .. ": " .. value
	lbl.Parent = f

	-- Track (taller for better hit area)
	local track = Instance.new("Frame")
	track.Position = UDim2.new(0, 0, 0, 28)
	track.Size = UDim2.new(1, 0, 0, 8)  -- Increased from 6 to 8 for better feel
	track.BackgroundColor3 = pal3.Border
	track.BorderSizePixel = 0
	track.Parent = f
	corner(track, 4)

	-- Fill with animated gradient
	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((value - minVal) / (maxVal - minVal), 0, 1, 0)
	fill.BackgroundColor3 = pal3.Accent
	fill.BorderSizePixel = 0
	fill.Parent = track
	corner(fill, 4)
	gradient(fill, 90, {pal3.Accent, pal3.AccentHover})

	-- Premium thumb with glow
	local thumb = Instance.new("Frame")
	thumb.AnchorPoint = Vector2.new(0.5, 0.5)
	thumb.Position = UDim2.new((value - minVal) / (maxVal - minVal), 0, 0.5, 0)
	thumb.Size = UDim2.new(0, 18, 0, 18)  -- Slightly larger default (was 16)
	thumb.BackgroundColor3 = Color3.new(1, 1, 1)
	thumb.BorderSizePixel = 0
	thumb.ZIndex = 3
	thumb.Parent = track
	corner(thumb, 9)
	shadow(thumb, 0.4, 4)  -- Enhanced shadow

	-- Accent glow ring (hidden by default)
	local glowRing = Instance.new("Frame")
	glowRing.AnchorPoint = Vector2.new(0.5, 0.5)
	glowRing.Position = UDim2.new(0.5, 0, 0.5, 0)
	glowRing.Size = UDim2.new(0, 18, 0, 18)  -- Same as thumb
	glowRing.BackgroundTransparency = 1
	glowRing.BorderSizePixel = 0
	glowRing.ZIndex = 2
	glowRing.Parent = thumb

	local glowStroke = Instance.new("UIStroke")
	glowStroke.Color = pal3.Accent
	glowStroke.Thickness = 0
	glowStroke.Transparency = 0.3
	glowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	glowStroke.Parent = glowRing
	corner(glowRing, 12)

	local dragging = false
	local hovering = false

	local function update(inputPos)
		local relativeX = math.clamp((inputPos.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		value = math.round((minVal + relativeX * (maxVal - minVal)) / step) * step
		value = math.clamp(value, minVal, maxVal)

		lbl.Text = (o.Text or "Slider") .. ": " .. value

		-- Buttery smooth animations
		Animator:Tween(fill, {Size = UDim2.new(relativeX, 0, 1, 0)}, Animator.Spring.Smooth)
		Animator:Tween(thumb, {Position = UDim2.new(relativeX, 0, 0.5, 0)}, Animator.Spring.Snappy)

		if o.OnChanged then task.spawn(o.OnChanged, value) end
		if o.Flag then RvrseUI:_autoSave() end
	end

	-- Hover effects
	track.MouseEnter:Connect(function()
		if RvrseUI.Store:IsLocked(o.RespectLock) then return end
		hovering = true
		-- Subtle hover: thumb grows slightly
		Animator:Tween(thumb, {Size = UDim2.new(0, 20, 0, 20)}, Animator.Spring.Fast)
		Animator:Tween(glowRing, {Size = UDim2.new(0, 20, 0, 20)}, Animator.Spring.Fast)
	end)

	track.MouseLeave:Connect(function()
		if dragging then return end  -- Don't shrink if dragging
		hovering = false
		-- Return to normal size
		Animator:Tween(thumb, {Size = UDim2.new(0, 18, 0, 18)}, Animator.Spring.Fast)
		Animator:Tween(glowRing, {Size = UDim2.new(0, 18, 0, 18)}, Animator.Spring.Fast)
		Animator:Tween(glowStroke, {Thickness = 0}, Animator.Spring.Fast)
	end)

	-- Dragging: GROW and GLOW
	track.InputBegan:Connect(function(io)
		if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
			if RvrseUI.Store:IsLocked(o.RespectLock) then return end
			dragging = true

			-- GROW: Thumb expands on grab
			Animator:Tween(thumb, {Size = UDim2.new(0, 24, 0, 24)}, Animator.Spring.Snappy)
			Animator:Tween(glowRing, {Size = UDim2.new(0, 24, 0, 24)}, Animator.Spring.Snappy)

			-- GLOW: Accent ring appears
			Animator:Tween(glowStroke, {Thickness = 3}, Animator.Spring.Smooth)

			update(io.Position)
		end
	end)

	track.InputEnded:Connect(function(io)
		if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
			dragging = false

			-- SHRINK: Return to hover size if still hovering, else normal
			local targetSize = hovering and 20 or 18
			Animator:Tween(thumb, {Size = UDim2.new(0, targetSize, 0, targetSize)}, Animator.Spring.Bounce)
			Animator:Tween(glowRing, {Size = UDim2.new(0, targetSize, 0, targetSize)}, Animator.Spring.Bounce)

			-- GLOW FADE: Ring disappears
			Animator:Tween(glowStroke, {Thickness = hovering and 1 or 0}, Animator.Spring.Fast)
		end
	end)

	UIS.InputChanged:Connect(function(io)
		if dragging and (io.UserInputType == Enum.UserInputType.MouseMovement or io.UserInputType == Enum.UserInputType.Touch) then
			update(io.Position)
		end
	end)

	table.insert(RvrseUI._lockListeners, function()
		local locked = RvrseUI.Store:IsLocked(o.RespectLock)
		lbl.TextTransparency = locked and 0.5 or 0
		track.BackgroundTransparency = locked and 0.5 or 0
		fill.BackgroundTransparency = locked and 0.5 or 0
	end)

	local sliderAPI = {
		Set = function(_, v)
			value = math.clamp(v, minVal, maxVal)
			local relativeX = (value - minVal) / (maxVal - minVal)
			lbl.Text = (o.Text or "Slider") .. ": " .. value
			fill.Size = UDim2.new(relativeX, 0, 1, 0)
			thumb.Position = UDim2.new(relativeX, 0, 0.5, 0)
		end,
		Get = function() return value end,
		SetVisible = function(_, visible)
			f.Visible = visible
		end,
		CurrentValue = value
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = sliderAPI
	end

	return sliderAPI
end

return Slider
