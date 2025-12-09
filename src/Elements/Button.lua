-- Button Element Module v4.0
-- Next-gen vibrant button with gradient background and glow effects
-- Complete redesign for RvrseUI v4.0

local Button = {}

function Button.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local pal3 = dependencies.pal3
	local UIS = dependencies.UIS
	local Animator = dependencies.Animator
	local RvrseUI = dependencies.RvrseUI
	local Theme = dependencies.Theme
	local Icons = dependencies.Icons
	local isLightTheme = Theme and Theme.Current == "Light"

	-- Create container with gradient background
	local f = card(48) -- Slightly taller for modern look
	f.BackgroundColor3 = pal3.Card
	f.BackgroundTransparency = isLightTheme and 0 or 0.2

	-- Add gradient background
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, pal3.Primary),
		ColorSequenceKeypoint.new(0.5, pal3.Accent),
		ColorSequenceKeypoint.new(1, pal3.Secondary),
	}
	gradient.Rotation = 45
	gradient.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.7),
		NumberSequenceKeypoint.new(1, 0.7),
	}
	gradient.Parent = f

	-- Add glowing border
	local stroke = Instance.new("UIStroke")
	stroke.Color = pal3.BorderGlow
	stroke.Thickness = 1
	stroke.Transparency = 0.5
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.LineJoinMode = Enum.LineJoinMode.Round
	stroke.Parent = f

	-- Main button
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.AutoButtonColor = false
	btn.Text = ""
	btn.Parent = f

	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "Content"
	contentFrame.BackgroundTransparency = 1
	contentFrame.Size = UDim2.new(1, 0, 1, 0)
	contentFrame.Parent = btn

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "ButtonLabel"
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(1, -8, 1, 0)
	textLabel.Position = UDim2.new(0, 4, 0, 0)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = 15
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextColor3 = o.TextColor or pal3.TextBright
	textLabel.Text = o.Text or "Button"
	textLabel.TextWrapped = false
	textLabel.Parent = contentFrame

	local cardPadding = f:FindFirstChildOfClass("UIPadding")
	local basePadLeft = cardPadding and cardPadding.PaddingLeft.Offset or 0

	local ICON_MARGIN = 12
	local ICON_SIZE = 24

	local iconHolder = Instance.new("Frame")
	iconHolder.BackgroundTransparency = 1
	iconHolder.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
	iconHolder.AnchorPoint = Vector2.new(0, 0.5)
	iconHolder.Position = UDim2.new(0, math.max(0, ICON_MARGIN - basePadLeft), 0.5, 0)
	iconHolder.ClipsDescendants = true
	iconHolder.Visible = false
	iconHolder.ZIndex = textLabel.ZIndex + 1
	iconHolder.Parent = contentFrame

	local iconInstance = nil
	local defaultIconColor = o.IconColor or pal3.TextBright
	local defaultTextColor = textLabel.TextColor3
	local currentIcon = o.Icon
	local currentText = textLabel.Text
	local isHovering = false

	local function updateTextPadding(hasIcon)
		if hasIcon then
			local leftInset = ICON_MARGIN + ICON_SIZE + 6
			local relativeOffset = math.max(0, leftInset - basePadLeft)
			textLabel.Position = UDim2.new(0, relativeOffset, 0, 0)
			textLabel.Size = UDim2.new(1, -(relativeOffset + 8), 1, 0)
		else
			textLabel.Position = UDim2.new(0, 4, 0, 0)
			textLabel.Size = UDim2.new(1, -8, 1, 0)
		end
	end

	local function destroyIcon()
		if iconInstance then
			iconInstance:Destroy()
			iconInstance = nil
		end
		for _, child in ipairs(iconHolder:GetChildren()) do
			child:Destroy()
		end
		iconHolder.Visible = false
		updateTextPadding(false)
	end

	local function tweenIconColor(color, spring)
		if not iconInstance then return end
		local props
		if iconInstance:IsA("ImageLabel") then
			props = {ImageColor3 = color}
		else
			props = {TextColor3 = color}
		end
		Animator:Tween(iconInstance, props, spring)
	end

	local function setIconTransparency(amount)
		if not iconInstance then return end
		if iconInstance:IsA("ImageLabel") then
			iconInstance.ImageTransparency = amount
		else
			iconInstance.TextTransparency = amount
		end
	end

	local function setIcon(icon)
		currentIcon = icon
		o.Icon = icon
		destroyIcon()
		if not icon or not Icons then
			return
		end

		local iconValue, iconType = Icons:Resolve(icon)
		if iconType == "image" and type(iconValue) == "string" then
			local iconImage = Instance.new("ImageLabel")
			iconImage.BackgroundTransparency = 1
			iconImage.AnchorPoint = Vector2.new(0.5, 0.5)
			iconImage.Position = UDim2.new(0.5, 0, 0.5, 0)
			iconImage.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
			iconImage.Image = iconValue
			iconImage.ImageColor3 = defaultIconColor
			iconImage.ZIndex = iconHolder.ZIndex
			iconImage.Parent = iconHolder
			iconInstance = iconImage
		elseif iconType == "sprite" and type(iconValue) == "table" then
			local iconImage = Instance.new("ImageLabel")
			iconImage.BackgroundTransparency = 1
			iconImage.AnchorPoint = Vector2.new(0.5, 0.5)
			iconImage.Position = UDim2.new(0.5, 0, 0.5, 0)
			iconImage.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
			iconImage.Image = "rbxassetid://" .. iconValue.id
			iconImage.ImageRectSize = iconValue.imageRectSize
			iconImage.ImageRectOffset = iconValue.imageRectOffset
			iconImage.ImageColor3 = defaultIconColor
			iconImage.ZIndex = iconHolder.ZIndex
			iconImage.Parent = iconHolder
			iconInstance = iconImage
		elseif iconValue and iconType == "text" then
			local iconText = Instance.new("TextLabel")
			iconText.BackgroundTransparency = 1
			iconText.AnchorPoint = Vector2.new(0.5, 0.5)
			iconText.Position = UDim2.new(0.5, 0, 0.5, 0)
			iconText.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
			iconText.Font = Enum.Font.GothamBold
			iconText.TextSize = 18
			iconText.TextColor3 = defaultIconColor
			iconText.Text = tostring(iconValue)
			iconText.TextWrapped = false
			iconText.TextXAlignment = Enum.TextXAlignment.Center
			iconText.TextYAlignment = Enum.TextYAlignment.Center
			iconText.ZIndex = iconHolder.ZIndex
			iconText.Parent = iconHolder
			iconInstance = iconText
		end

		if iconInstance then
			iconHolder.Visible = true
			updateTextPadding(true)
		else
			updateTextPadding(false)
		end
	end

	updateTextPadding(false)
	setIcon(currentIcon)

	-- Click handler with enhanced effects
	btn.MouseButton1Click:Connect(function()
		if RvrseUI.Store:IsLocked(o.RespectLock) then return end

		-- Multi-effect combo: ripple + shimmer + pulse
		local absPos = btn.AbsolutePosition
		local mousePos = UIS:GetMouseLocation()

		-- Gradient ripple
		Animator:Ripple(btn, mousePos.X - absPos.X, mousePos.Y - absPos.Y, Theme)

		-- Shimmer sweep effect
		Animator:Shimmer(f, Theme)

		-- Quick pulse
		Animator:Pulse(f, 1.02, Animator.Spring.Lightning)

		-- Flash the border
		Animator:Tween(stroke, {Transparency = 0}, Animator.Spring.Lightning)
		task.delay(0.12, function()
			Animator:Tween(stroke, {Transparency = 0.5}, Animator.Spring.Snappy)
		end)

		if o.Callback then task.spawn(o.Callback) end
	end)

	-- Enhanced hover effects
	btn.MouseEnter:Connect(function()
		isHovering = true

		-- Brighten gradient (set directly - can't tween NumberSequence)
		gradient.Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 0.4),
			NumberSequenceKeypoint.new(1, 0.4),
		}

		-- Glow the border
		Animator:Tween(stroke, {
			Thickness = 2,
			Transparency = 0.2
		}, Animator.Spring.Snappy)

		-- Brighten text/icon
		Animator:Tween(textLabel, {TextColor3 = pal3.Shimmer}, Animator.Spring.Lightning)
		tweenIconColor(pal3.Shimmer, Animator.Spring.Lightning)

		-- Add glow effect
		Animator:Glow(f, 0.3, 0.4, Theme)
	end)

	btn.MouseLeave:Connect(function()
		isHovering = false

		-- Restore gradient (set directly - can't tween NumberSequence)
		gradient.Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 0.7),
			NumberSequenceKeypoint.new(1, 0.7),
		}

		-- Restore border
		Animator:Tween(stroke, {
			Thickness = 1,
			Transparency = 0.5
		}, Animator.Spring.Snappy)

		-- Restore text/icon color
		Animator:Tween(textLabel, {TextColor3 = defaultTextColor}, Animator.Spring.Snappy)
		tweenIconColor(defaultIconColor, Animator.Spring.Snappy)
	end)

	-- Lock state listener with visual feedback
	table.insert(RvrseUI._lockListeners, function()
		local locked = RvrseUI.Store:IsLocked(o.RespectLock)

		if locked then
			-- Desaturate and dim
			textLabel.TextTransparency = 0.5
			gradient.Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0.9),
				NumberSequenceKeypoint.new(1, 0.9),
			}
			stroke.Transparency = 0.8
			setIconTransparency(0.5)
		else
			-- Restore to normal or hover state
			textLabel.TextTransparency = 0
			setIconTransparency(0)
			if isHovering then
				gradient.Transparency = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 0.4),
					NumberSequenceKeypoint.new(1, 0.4),
				}
				stroke.Transparency = 0.2
			else
				gradient.Transparency = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 0.7),
					NumberSequenceKeypoint.new(1, 0.7),
				}
				stroke.Transparency = 0.5
			end
		end
	end)

	-- Public API
	local buttonAPI = {
		Set = function(_, text, interactText)
			-- Rayfield-compatible Set method
			-- text: Main button text (required)
			-- interactText: Optional secondary text (not used in current design)
			if text then
				textLabel.Text = text
				currentText = text
			end
			-- interactText parameter reserved for future use (Rayfield compatibility)
		end,
		SetText = function(_, txt)
			-- Legacy method - kept for backwards compatibility
			textLabel.Text = txt
			currentText = txt
		end,
		SetVisible = function(_, visible)
			f.Visible = visible
		end,
		Trigger = function(_)
			-- Programmatically trigger the button
			if o.Callback and not RvrseUI.Store:IsLocked(o.RespectLock) then
				task.spawn(o.Callback)
			end
		end,
		SetIcon = function(_, icon)
			currentIcon = icon
			setIcon(icon)
			return currentIcon
		end,
		GetIcon = function()
			return currentIcon
		end,
		CurrentValue = currentText
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = buttonAPI
	end

	-- Register for global search
	local registerSearchableElement = dependencies.registerSearchableElement
	if registerSearchableElement then
		registerSearchableElement({
			text = o.Text or "Button",
			icon = o.Icon,
			elementType = "Button",
			path = (dependencies.tabTitle or "Tab") .. " > " .. (dependencies.sectionTitle or "Section"),
			frame = f,
			callback = o.Callback,
			tabData = dependencies.tabData
		})
	end

	return buttonAPI
end

return Button
