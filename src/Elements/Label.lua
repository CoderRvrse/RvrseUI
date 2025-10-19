-- Label Element Module v4.0
-- Clean label with optional gradient text
-- Minimal redesign for RvrseUI v4.0

local Label = {}

function Label.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local pal3 = dependencies.pal3
	local RvrseUI = dependencies.RvrseUI
	local Icons = dependencies.Icons

	local f = card(36) -- Slightly taller

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, -8, 1, 0)
	lbl.Position = UDim2.new(0, 4, 0, 0)
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = pal3.TextSub -- Subtle color for labels
	lbl.Text = o.Text or "Label"
	lbl.TextWrapped = true
	lbl.Parent = f

	local ICON_MARGIN = 12
	local ICON_SIZE = 24

	local iconHolder = Instance.new("Frame")
	iconHolder.BackgroundTransparency = 1
	iconHolder.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
	iconHolder.AnchorPoint = Vector2.new(0, 0.5)
	iconHolder.Position = UDim2.new(0, ICON_MARGIN, 0.5, 0)
	iconHolder.ClipsDescendants = true
	iconHolder.Visible = false
	iconHolder.Parent = f

	local iconInstance = nil
	local defaultIconColor = o.IconColor or pal3.TextSub
	local currentIcon = o.Icon

	local function updateLabelPadding(hasIcon)
		if hasIcon then
			local leftInset = ICON_MARGIN + ICON_SIZE + 6
			lbl.Position = UDim2.new(0, leftInset, 0, 0)
			lbl.Size = UDim2.new(1, -(leftInset + 4), 1, 0)
		else
			lbl.Position = UDim2.new(0, 4, 0, 0)
			lbl.Size = UDim2.new(1, -8, 1, 0)
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
		updateLabelPadding(false)
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
			local img = Instance.new("ImageLabel")
			img.BackgroundTransparency = 1
			img.AnchorPoint = Vector2.new(0.5, 0.5)
			img.Position = UDim2.new(0.5, 0, 0.5, 0)
			img.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
			img.Image = iconValue
			img.ImageColor3 = defaultIconColor
			img.Parent = iconHolder
			iconInstance = img
		elseif iconType == "sprite" and type(iconValue) == "table" then
			local img = Instance.new("ImageLabel")
			img.BackgroundTransparency = 1
			img.AnchorPoint = Vector2.new(0.5, 0.5)
			img.Position = UDim2.new(0.5, 0, 0.5, 0)
			img.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
			img.Image = "rbxassetid://" .. iconValue.id
			img.ImageRectSize = iconValue.imageRectSize
			img.ImageRectOffset = iconValue.imageRectOffset
			img.ImageColor3 = defaultIconColor
			img.Parent = iconHolder
			iconInstance = img
		elseif iconValue and iconType == "text" then
			local txt = Instance.new("TextLabel")
			txt.BackgroundTransparency = 1
			txt.AnchorPoint = Vector2.new(0.5, 0.5)
			txt.Position = UDim2.new(0.5, 0, 0.5, 0)
			txt.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
			txt.Font = Enum.Font.GothamBold
			txt.TextSize = 18
			txt.TextColor3 = defaultIconColor
			txt.Text = tostring(iconValue)
			txt.TextXAlignment = Enum.TextXAlignment.Center
			txt.TextYAlignment = Enum.TextYAlignment.Center
			txt.Parent = iconHolder
			iconInstance = txt
		end

		if iconInstance then
			iconHolder.Visible = true
			updateLabelPadding(true)
		end
	end

	updateLabelPadding(false)
	setIcon(o.Icon)

	local labelAPI = {
		Set = function(_, txt)
			lbl.Text = txt
		end,
		Get = function()
			return lbl.Text
		end,
		SetVisible = function(_, visible)
			f.Visible = visible
		end,
		SetIcon = function(_, icon)
			setIcon(icon)
			return currentIcon
		end,
		GetIcon = function()
			return currentIcon
		end,
		CurrentValue = lbl.Text
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = labelAPI
	end

	return labelAPI
end

return Label
