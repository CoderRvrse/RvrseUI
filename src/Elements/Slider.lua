-- Slider Element Module v4.0
-- Gradient-filled slider with glowing thumb
-- Complete redesign for RvrseUI v4.0

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
	local Theme = dependencies.Theme

	local minVal = o.Min or 0
	local maxVal = o.Max or 100
	local step = o.Step or 1
	local value = o.Default or minVal
	local range = maxVal - minVal
	if range == 0 then
		range = 1
	end
	local baseLabelText = o.Text or "Slider"

	local f = card(64) -- Taller for modern layout
	local fireOnConfigLoad = o.FireOnConfigLoad ~= false

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, -60, 0, 22)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 15
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = pal3.Text
	lbl.Text = string.format("%s: %s", baseLabelText, tostring(value))
	lbl.Parent = f

	-- Value display (right-aligned)
	local valueLbl = Instance.new("TextLabel")
	valueLbl.BackgroundTransparency = 1
	valueLbl.AnchorPoint = Vector2.new(1, 0)
	valueLbl.Position = UDim2.new(1, -6, 0, 0)
	valueLbl.Size = UDim2.new(0, 50, 0, 22)
	valueLbl.Font = Enum.Font.GothamBold
	valueLbl.TextSize = 14
	valueLbl.TextXAlignment = Enum.TextXAlignment.Right
	valueLbl.TextColor3 = pal3.Accent
	valueLbl.Text = tostring(value)
	valueLbl.Parent = f

	-- Track (thicker for better interaction)
	local track = Instance.new("Frame")
	track.Position = UDim2.new(0, 0, 0, 32)
	track.Size = UDim2.new(1, 0, 0, 10)
	track.BackgroundColor3 = pal3.Card
	track.BorderSizePixel = 0
	track.Parent = f
	corner(track, 5)

	-- Track border glow
	local trackStroke = Instance.new("UIStroke")
	trackStroke.Color = pal3.BorderGlow
	trackStroke.Thickness = 1
	trackStroke.Transparency = 0.7
	trackStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	trackStroke.Parent = track

	-- Vibrant gradient fill
	local fill = Instance.new("Frame")
	local initialRatio = range > 0 and ((value - minVal) / range) or 0
	fill.Size = UDim2.new(initialRatio, 0, 1, 0)
	fill.BackgroundColor3 = pal3.Accent
	fill.BorderSizePixel = 0
	fill.ZIndex = 2
	fill.Parent = track
	corner(fill, 5)

	-- Multi-color gradient on fill
	local fillGradient = Instance.new("UIGradient")
	fillGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, pal3.Primary),
		ColorSequenceKeypoint.new(0.5, pal3.Accent),
		ColorSequenceKeypoint.new(1, pal3.Secondary),
	}
	fillGradient.Rotation = 0 -- Horizontal gradient
	fillGradient.Parent = fill

	-- Premium thumb with glow
	local thumb = Instance.new("Frame")
	thumb.AnchorPoint = Vector2.new(0.5, 0.5)
	thumb.Position = UDim2.new(initialRatio, 0, 0.5, 0)
	thumb.Size = UDim2.new(0, 22, 0, 22) -- Larger for modern look
	thumb.BackgroundColor3 = Color3.new(1, 1, 1)
	thumb.BorderSizePixel = 0
	thumb.ZIndex = 4
	thumb.Parent = track
	corner(thumb, 11)
	shadow(thumb, 0.5, 5) -- Enhanced shadow

	-- Glowing stroke around thumb
	local glowStroke = Instance.new("UIStroke")
	glowStroke.Color = pal3.Accent
	glowStroke.Thickness = 0
	glowStroke.Transparency = 0.2
	glowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	glowStroke.Parent = thumb

	local dragging = false
	local hovering = false

	local suffix = o.Suffix or ""

	local function updateLabelText(newValue)
		local displayValue = suffix ~= "" and (tostring(newValue) .. suffix) or tostring(newValue)
		lbl.Text = string.format("%s: %s", baseLabelText, displayValue)
		valueLbl.Text = displayValue
	end

	local function update(inputPos)
		local relativeX = math.clamp((inputPos.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		value = math.round((minVal + relativeX * range) / step) * step
		value = math.clamp(value, minVal, maxVal)
		local snappedRatio = range > 0 and ((value - minVal) / range) or 0
		updateLabelText(value)

		-- Ultra-smooth animations
		Animator:Tween(fill, {Size = UDim2.new(snappedRatio, 0, 1, 0)}, Animator.Spring.Butter)
		Animator:Tween(thumb, {Position = UDim2.new(snappedRatio, 0, 0.5, 0)}, Animator.Spring.Glide)

		if o.OnChanged then task.spawn(o.OnChanged, value) end
		if o.Flag then RvrseUI:_autoSave() end
	end

	-- Enhanced hover effects
	track.MouseEnter:Connect(function()
		if RvrseUI.Store:IsLocked(o.RespectLock) then return end
		hovering = true

		-- Thumb grows
		Animator:Tween(thumb, {Size = UDim2.new(0, 24, 0, 24)}, Animator.Spring.Snappy)

		-- Subtle glow appears
		Animator:Tween(glowStroke, {Thickness = 2}, Animator.Spring.Snappy)

		-- Track border brightens
		Animator:Tween(trackStroke, {Transparency = 0.4}, Animator.Spring.Lightning)
	end)

	track.MouseLeave:Connect(function()
		if dragging then return end
		hovering = false

		-- Thumb shrinks
		Animator:Tween(thumb, {Size = UDim2.new(0, 22, 0, 22)}, Animator.Spring.Bounce)

		-- Glow fades
		Animator:Tween(glowStroke, {Thickness = 0}, Animator.Spring.Snappy)

		-- Track restores
		Animator:Tween(trackStroke, {Transparency = 0.7}, Animator.Spring.Snappy)
	end)

	-- Dragging: GROW, GLOW, and vibrant feedback
	track.InputBegan:Connect(function(io)
		if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
			if RvrseUI.Store:IsLocked(o.RespectLock) then return end
			dragging = true

			-- GROW: Thumb expands dramatically
			Animator:Tween(thumb, {Size = UDim2.new(0, 28, 0, 28)}, Animator.Spring.Pop)

			-- GLOW: Strong accent ring
			Animator:Tween(glowStroke, {Thickness = 4}, Animator.Spring.Snappy)

			-- Track glows brighter
			Animator:Tween(trackStroke, {
				Thickness = 2,
				Transparency = 0.2
			}, Animator.Spring.Lightning)

			-- Value label pulses
			Animator:Pulse(valueLbl, 1.1, Animator.Spring.Lightning)

			update(io.Position)
		end
	end)

	track.InputEnded:Connect(function(io)
		if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
			dragging = false

			-- SHRINK: Return to hover or normal size with bounce
			local targetSize = hovering and 24 or 22
			Animator:Tween(thumb, {Size = UDim2.new(0, targetSize, 0, targetSize)}, Animator.Spring.Bounce)

			-- GLOW: Fade to hover or off
			local targetThickness = hovering and 2 or 0
			Animator:Tween(glowStroke, {Thickness = targetThickness}, Animator.Spring.Glide)

			-- Track restores
			Animator:Tween(trackStroke, {
				Thickness = 1,
				Transparency = hovering and 0.4 or 0.7
			}, Animator.Spring.Snappy)
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

	local sliderAPI

	local function setValueDirect(newValue)
		value = math.clamp(newValue, minVal, maxVal)
		local relativeX = range > 0 and ((value - minVal) / range) or 0
		updateLabelText(value)
		fill.Size = UDim2.new(relativeX, 0, 1, 0)
		thumb.Position = UDim2.new(relativeX, 0, 0.5, 0)
		if sliderAPI then
			sliderAPI.CurrentValue = value
		end
	end

	sliderAPI = {
	Set = function(_, v, fireCallback)
		if v == nil then
			return
		end
		setValueDirect(v)
			if fireCallback and o.OnChanged then
				task.spawn(o.OnChanged, sliderAPI.CurrentValue)
			end
		end,
		SetRange = function(_, newMin, newMax, newStep)
			-- Rayfield-compatible SetRange method
			-- Update min/max/step at runtime and recalculate current value
			minVal = newMin or minVal
			maxVal = newMax or maxVal
			step = newStep or step
			range = maxVal - minVal
			if range == 0 then
				range = 1
			end
			-- Clamp current value to new range
			value = math.clamp(value, minVal, maxVal)
			setValueDirect(value)
		end,
		SetSuffix = function(_, newSuffix)
			-- Rayfield-compatible SetSuffix method
			-- Update the suffix displayed after the value (e.g., "%", " items", " HP")
			suffix = newSuffix or ""
			updateLabelText(value)
		end,
		Get = function() return value end,
		SetVisible = function(_, visible)
			f.Visible = visible
		end,
		Hydrate = function(_, overrideValue)
			if not fireOnConfigLoad then
				return
			end
			if o.OnChanged then
				task.spawn(o.OnChanged, overrideValue ~= nil and overrideValue or sliderAPI.CurrentValue)
			end
		end,
		CurrentValue = value
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = sliderAPI
	end

	return sliderAPI
end

return Slider
