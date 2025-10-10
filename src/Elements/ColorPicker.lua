-- ColorPicker Element Module v4.0
-- Modern color picker with gradient preview circle
-- Complete redesign for RvrseUI v4.0

local ColorPicker = {}

function ColorPicker.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local corner = dependencies.corner
	local stroke = dependencies.stroke
	local pal3 = dependencies.pal3
	local Animator = dependencies.Animator
	local RvrseUI = dependencies.RvrseUI
	local Theme = dependencies.Theme

	local f = card(48) -- Taller for modern look

	local defaultColor = o.Default or pal3.Accent
	local currentColor = defaultColor

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, -90, 1, 0)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 15
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = pal3.Text
	lbl.Text = o.Text or "Color"
	lbl.Parent = f

	-- Circular preview button (modern design)
	local preview = Instance.new("TextButton")
	preview.AnchorPoint = Vector2.new(1, 0.5)
	preview.Position = UDim2.new(1, -6, 0.5, 0)
	preview.Size = UDim2.new(0, 40, 0, 40) -- Circular
	preview.BackgroundColor3 = currentColor
	preview.BorderSizePixel = 0
	preview.Text = ""
	preview.AutoButtonColor = false
	preview.Parent = f
	corner(preview, 20) -- Full circle

	-- Glowing stroke
	local previewStroke = Instance.new("UIStroke")
	previewStroke.Color = pal3.Border
	previewStroke.Thickness = 2
	previewStroke.Transparency = 0.4
	previewStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	previewStroke.Parent = preview

	-- Simple color cycling demo (you can implement full color picker UI)
	local colors = {
		Color3.fromRGB(255, 0, 0),    -- Red
		Color3.fromRGB(255, 127, 0),  -- Orange
		Color3.fromRGB(255, 255, 0),  -- Yellow
		Color3.fromRGB(0, 255, 0),    -- Green
		Color3.fromRGB(0, 127, 255),  -- Blue
		Color3.fromRGB(139, 0, 255),  -- Purple
		Color3.fromRGB(255, 255, 255),-- White
		Color3.fromRGB(0, 0, 0),      -- Black
	}
	local colorIdx = 1

	preview.MouseButton1Click:Connect(function()
		if RvrseUI.Store:IsLocked(o.RespectLock) then return end
		colorIdx = (colorIdx % #colors) + 1
		currentColor = colors[colorIdx]

		-- Smooth color transition
		Animator:Tween(preview, {BackgroundColor3 = currentColor}, Animator.Spring.Snappy)

		-- Pulse effect
		Animator:Pulse(preview, 1.15, Animator.Spring.Bounce)

		-- Border flashes the new color
		Animator:Tween(previewStroke, {
			Color = currentColor,
			Thickness = 3
		}, Animator.Spring.Lightning)

		task.delay(0.2, function()
			Animator:Tween(previewStroke, {
				Color = pal3.Border,
				Thickness = 2
			}, Animator.Spring.Glide)
		end)

		if o.OnChanged then
			task.spawn(o.OnChanged, currentColor)
		end
		if o.Flag then RvrseUI:_autoSave() end
	end)

	preview.MouseEnter:Connect(function()
		-- Glow on hover
		Animator:Tween(previewStroke, {
			Thickness = 3,
			Transparency = 0.2
		}, Animator.Spring.Snappy)

		Animator:Glow(preview, 0.4, 0.5, Theme)
	end)

	preview.MouseLeave:Connect(function()
		-- Restore
		Animator:Tween(previewStroke, {
			Thickness = 2,
			Transparency = 0.4
		}, Animator.Spring.Snappy)
	end)

	table.insert(RvrseUI._lockListeners, function()
		local locked = RvrseUI.Store:IsLocked(o.RespectLock)
		lbl.TextTransparency = locked and 0.5 or 0
	end)

	local colorpickerAPI = {
		Set = function(_, color)
			currentColor = color
			preview.BackgroundColor3 = color
		end,
		Get = function()
			return currentColor
		end,
		SetVisible = function(_, visible)
			f.Visible = visible
		end,
		CurrentValue = currentColor
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = colorpickerAPI
	end

	return colorpickerAPI
end

return ColorPicker
