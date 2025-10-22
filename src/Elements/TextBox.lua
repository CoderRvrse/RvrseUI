-- TextBox Element Module v4.0
-- Modern input with glowing underline and gradient focus
-- Complete redesign for RvrseUI v4.0

local TextBox = {}

function TextBox.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local corner = dependencies.corner
	local stroke = dependencies.stroke
	local pal3 = dependencies.pal3
	local Animator = dependencies.Animator
	local RvrseUI = dependencies.RvrseUI
	local Theme = dependencies.Theme
	local isLightTheme = Theme and Theme.Current == "Light"
	local baseTransparency = isLightTheme and 0 or 0.3
	local focusTransparency = isLightTheme and 0 or 0.1

	local f = card(52) -- Taller for modern look
	local fireOnConfigLoad = o.FireOnConfigLoad ~= false

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, -260, 1, 0)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 15
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = pal3.Text
	lbl.Text = o.Text or "Input"
	lbl.Parent = f

	-- Modern input container
	local inputBox = Instance.new("TextBox")
	inputBox.AnchorPoint = Vector2.new(1, 0.5)
	inputBox.Position = UDim2.new(1, -8, 0.5, 0)
	inputBox.Size = UDim2.new(0, 240, 0, 36)
	inputBox.BackgroundColor3 = pal3.Card
	inputBox.BackgroundTransparency = baseTransparency
	inputBox.BorderSizePixel = 0
	inputBox.Font = Enum.Font.GothamMedium
	inputBox.TextSize = 14
	inputBox.TextColor3 = pal3.TextBright
	inputBox.PlaceholderText = o.Placeholder or "Enter text..."
	inputBox.PlaceholderColor3 = pal3.TextMuted
	inputBox.Text = o.Default or ""
	inputBox.ClearTextOnFocus = false
	inputBox.Parent = f
	corner(inputBox, "pill")

	-- Subtle border (default state)
	local borderStroke = Instance.new("UIStroke")
	borderStroke.Color = pal3.Border
	borderStroke.Thickness = 1
	borderStroke.Transparency = 0.6
	borderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	borderStroke.LineJoinMode = Enum.LineJoinMode.Round
	borderStroke.Parent = inputBox

	-- Gradient underline (glows on focus)
	local underline = Instance.new("Frame")
	underline.AnchorPoint = Vector2.new(0.5, 1)
	underline.Position = UDim2.new(0.5, 0, 1, 0)
	underline.Size = UDim2.new(0, 0, 0, 3)
	underline.BackgroundColor3 = pal3.Accent
	underline.BorderSizePixel = 0
	underline.ZIndex = 5
	underline.Parent = inputBox
	corner(underline, 2)

	-- Gradient on underline
	local underlineGradient = Instance.new("UIGradient")
	underlineGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, pal3.Primary),
		ColorSequenceKeypoint.new(0.5, pal3.Accent),
		ColorSequenceKeypoint.new(1, pal3.Secondary),
	}
	underlineGradient.Rotation = 0
	underlineGradient.Parent = underline

	local currentValue = inputBox.Text
	local isFocused = false

	-- Focus: Glow and expand underline
	inputBox.Focused:Connect(function()
		isFocused = true

		-- Background brightens
	Animator:Tween(inputBox, {BackgroundTransparency = focusTransparency}, Animator.Spring.Lightning)

		-- Border glows
		Animator:Tween(borderStroke, {
			Color = pal3.Accent,
			Thickness = 2,
			Transparency = 0.3
		}, Animator.Spring.Snappy)

		-- Underline expands from center
		Animator:Tween(underline, {Size = UDim2.new(1, 0, 0, 3)}, Animator.Spring.Spring)

		-- Label brightens
		Animator:Tween(lbl, {TextColor3 = pal3.TextBright}, Animator.Spring.Lightning)

		-- Add shimmer effect
		Animator:Shimmer(inputBox, Theme)
	end)

	-- Blur: Restore
	inputBox.FocusLost:Connect(function(enterPressed)
		isFocused = false
		currentValue = inputBox.Text

		-- Background dims
	Animator:Tween(inputBox, {BackgroundTransparency = baseTransparency}, Animator.Spring.Snappy)

		-- Border restores
		Animator:Tween(borderStroke, {
			Color = pal3.Border,
			Thickness = 1,
			Transparency = 0.6
		}, Animator.Spring.Snappy)

		-- Underline collapses
		Animator:Tween(underline, {Size = UDim2.new(0, 0, 0, 3)}, Animator.Spring.Glide)

		-- Label restores
		Animator:Tween(lbl, {TextColor3 = pal3.Text}, Animator.Spring.Snappy)

		if o.OnChanged then
			task.spawn(o.OnChanged, currentValue, enterPressed)
		end
		if o.Flag then RvrseUI:_autoSave() end
	end)

	table.insert(RvrseUI._lockListeners, function()
		local locked = RvrseUI.Store:IsLocked(o.RespectLock)
		lbl.TextTransparency = locked and 0.5 or 0
		inputBox.TextEditable = not locked
	end)

	local textboxAPI = {
	Set = function(_, txt, fireCallback)
		local textValue = txt ~= nil and tostring(txt) or ""
		inputBox.Text = textValue
		currentValue = textValue
		if fireCallback and o.OnChanged then
			task.spawn(o.OnChanged, currentValue, false)
		end
	end,
		Get = function()
			return currentValue
		end,
		SetVisible = function(_, visible)
			f.Visible = visible
		end,
		Hydrate = function(_, overrideValue)
			if not fireOnConfigLoad then
				return
			end
			if o.OnChanged then
				task.spawn(o.OnChanged, overrideValue or currentValue, false)
			end
		end,
		CurrentValue = currentValue
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = textboxAPI
	end

	return textboxAPI
end

return TextBox
