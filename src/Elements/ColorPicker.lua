-- ColorPicker Element Module
-- Part of RvrseUI v2.13.0 Modular Architecture
-- Extracted from RvrseUI.lua (lines 3704-3789)

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

	local f = card(44)

	local defaultColor = o.Default or Color3.fromRGB(255, 255, 255)
	local currentColor = defaultColor

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, -80, 1, 0)
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = pal3.Text
	lbl.Text = o.Text or "Color"
	lbl.Parent = f

	local preview = Instance.new("TextButton")
	preview.AnchorPoint = Vector2.new(1, 0.5)
	preview.Position = UDim2.new(1, 0, 0.5, 0)
	preview.Size = UDim2.new(0, 64, 0, 32)
	preview.BackgroundColor3 = currentColor
	preview.BorderSizePixel = 0
	preview.Text = ""
	preview.AutoButtonColor = false
	preview.Parent = f
	corner(preview, 8)
	stroke(preview, pal3.Border, 2)

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
		preview.BackgroundColor3 = currentColor
		if o.OnChanged then
			task.spawn(o.OnChanged, currentColor)
		end
		if o.Flag then RvrseUI:_autoSave() end  -- Auto-save on change
	end)

	preview.MouseEnter:Connect(function()
		Animator:Tween(preview, {BackgroundTransparency = 0.2}, Animator.Spring.Fast)
	end)

	preview.MouseLeave:Connect(function()
		Animator:Tween(preview, {BackgroundTransparency = 0}, Animator.Spring.Fast)
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
