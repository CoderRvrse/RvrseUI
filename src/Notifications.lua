-- =========================
-- Notifications Module
-- =========================
-- Extracted from RvrseUI.lua (lines 1066-1179)
-- Provides toast notification system with animations and priority support

local Notifications = {}

-- Helper functions (must be passed as dependencies)
local corner, stroke

-- Dependencies
local Theme, Animator, host, Icons

-- Module state
local notifyRoot
local RvrseUI -- Reference to main RvrseUI table for NotificationsEnabled flag

-- Initialize the notifications module
function Notifications:Init(dependencies)
	-- Extract dependencies
	Theme = dependencies.Theme
	Animator = dependencies.Animator
	host = dependencies.host
	RvrseUI = dependencies.RvrseUI
	corner = dependencies.corner
	stroke = dependencies.stroke
	Icons = dependencies.Icons

	-- Obfuscated name generation (same as main module)
	local obfuscatedName = "NotifyRoot_" .. tostring(math.random(10000, 99999))

	-- Create notification root container
	notifyRoot = Instance.new("Frame")
	notifyRoot.Name = obfuscatedName  -- 🔐 Dynamic obfuscation: Changes every launch
	notifyRoot.BackgroundTransparency = 1
	notifyRoot.AnchorPoint = Vector2.new(1, 1)
	notifyRoot.Position = UDim2.new(1, -8, 1, -8)
	notifyRoot.Size = UDim2.new(0, 300, 1, -16)  -- Reduced from 340 to 300 for small screens
	notifyRoot.ZIndex = 15000  -- Higher than everything else for notifications
	notifyRoot.Parent = host

	local notifyLayout = Instance.new("UIListLayout")
	notifyLayout.Padding = UDim.new(0, 8)
	notifyLayout.FillDirection = Enum.FillDirection.Vertical
	notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	notifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	notifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
	notifyLayout.Parent = notifyRoot

	return self
end

-- Create a notification
function Notifications:Notify(opt)
	-- Check if notifications are enabled
	if RvrseUI and not RvrseUI.NotificationsEnabled then return end

	opt = opt or {}
	if typeof(opt) ~= "table" then
		opt = { Title = tostring(opt) }
	end
	local pal = Theme:Get()

	-- Notification card
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 72)
	card.BackgroundColor3 = pal.Card
	card.BorderSizePixel = 0
	card.Parent = notifyRoot
	corner(card, 12)
	stroke(card, pal.Border, 1)

	-- Priority system: Higher priority = lower LayoutOrder = appears at bottom (most visible)
	-- Priority levels: "critical" = 1, "high" = 2, "normal" = 3 (default), "low" = 4
	local priorityMap = { critical = 1, high = 2, normal = 3, low = 4 }
	card.LayoutOrder = priorityMap[opt.Priority] or 3

	-- Accent stripe
	local typeColors = {
		success = pal.Success,
		error = pal.Error,
		warn = pal.Warning,
		info = pal.Info
	}
	local accentColor = typeColors[opt.Type] or pal.Info

	local stripe = Instance.new("Frame")
	stripe.Size = UDim2.new(0, 4, 1, 0)
	stripe.BackgroundColor3 = accentColor
	stripe.BorderSizePixel = 0
	stripe.Parent = card
	corner(stripe, 2)

	-- Icon container
	local iconHolder = Instance.new("Frame")
	iconHolder.BackgroundTransparency = 1
	iconHolder.Size = UDim2.new(0, 32, 0, 32)
	iconHolder.AnchorPoint = Vector2.new(0, 0.5)
	iconHolder.Position = UDim2.new(0, 16, 0.5, 0)
	iconHolder.Parent = card

	local iconColor = opt.IconColor or accentColor
	local iconResolved = false

	if opt.Icon and Icons then
		local iconValue, iconType = Icons:Resolve(opt.Icon)

		if iconType == "image" and type(iconValue) == "string" then
			local iconImage = Instance.new("ImageLabel")
			iconImage.BackgroundTransparency = 1
			iconImage.Size = UDim2.new(1, 0, 1, 0)
			iconImage.Image = iconValue
			iconImage.ImageColor3 = iconColor
			iconImage.Parent = iconHolder
			iconResolved = true
		elseif iconType == "sprite" and type(iconValue) == "table" then
			local iconImage = Instance.new("ImageLabel")
			iconImage.BackgroundTransparency = 1
			iconImage.Size = UDim2.new(1, 0, 1, 0)
			iconImage.Image = "rbxassetid://" .. iconValue.id
			iconImage.ImageRectSize = iconValue.imageRectSize
			iconImage.ImageRectOffset = iconValue.imageRectOffset
			iconImage.ImageColor3 = iconColor
			iconImage.Parent = iconHolder
			iconResolved = true
		elseif iconValue and iconType == "text" then
			local iconText = Instance.new("TextLabel")
			iconText.BackgroundTransparency = 1
			iconText.Size = UDim2.new(1, 0, 1, 0)
			iconText.Font = Enum.Font.GothamBold
			iconText.TextSize = 18
			iconText.Text = iconValue
			iconText.TextColor3 = iconColor
			iconText.Parent = iconHolder
			iconResolved = true
		end
	end

	if not iconResolved then
		local iconMap = { success = "✓", error = "✕", warn = "⚠", info = "ℹ" }
		local fallback = opt.Icon or iconMap[opt.Type] or "ℹ"

		local iconText = Instance.new("TextLabel")
		iconText.BackgroundTransparency = 1
		iconText.Size = UDim2.new(1, 0, 1, 0)
		iconText.Font = Enum.Font.GothamBold
		iconText.TextSize = 18
		iconText.Text = fallback
		iconText.TextColor3 = iconColor
		iconText.Parent = iconHolder
	end

	-- Title
	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 52, 0, 12)
	title.Size = UDim2.new(1, -64, 0, 20)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.TextColor3 = pal.Text
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = opt.Title or "Notification"
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.Parent = card

	-- Message
	if opt.Message and #opt.Message > 0 then
		local msg = Instance.new("TextLabel")
		msg.BackgroundTransparency = 1
		msg.Position = UDim2.new(0, 52, 0, 34)
		msg.Size = UDim2.new(1, -64, 0, 30)
		msg.Font = Enum.Font.Gotham
		msg.TextSize = 12
		msg.TextColor3 = pal.TextSub
		msg.TextXAlignment = Enum.TextXAlignment.Left
		msg.TextYAlignment = Enum.TextYAlignment.Top
		msg.TextWrapped = true
		msg.Text = opt.Message
		msg.Parent = card
	end

	-- Animations
	card.Position = UDim2.new(1, 20, 0, 0)
	card.BackgroundTransparency = 1
	stripe.Size = UDim2.new(0, 0, 1, 0)

	Animator:Tween(card, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}, Animator.Spring.Snappy)
	Animator:Tween(stripe, {Size = UDim2.new(0, 4, 1, 0)}, Animator.Spring.Smooth)

	-- Auto-dismiss
	local dur = tonumber(opt.Duration) or 3
	task.delay(dur, function()
		if card and card.Parent then
			Animator:Tween(card, {Position = UDim2.new(1, 20, 0, 0), BackgroundTransparency = 1}, Animator.Spring.Fast)
			Animator:Tween(stripe, {Size = UDim2.new(0, 0, 1, 0)}, Animator.Spring.Fast)
			task.wait(0.2)
			card:Destroy()
		end
	end)
end

-- Initialize method (called by init.lua)
function Notifications:Initialize(deps)
	if not deps then return end

	local helpers = deps.UIHelpers

	local cornerFn = deps.corner
	if helpers and helpers.corner then
		cornerFn = function(inst, radius)
            -- delegate to helper for consistent styling
			return helpers.corner(inst, radius)
		end
	elseif not cornerFn then
		cornerFn = function(inst, radius)
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(0, radius or 12)
			c.Parent = inst
			return c
		end
	end

	local strokeFn = deps.stroke
	if helpers and helpers.stroke then
		strokeFn = function(inst, color, thickness)
			return helpers.stroke(inst, color, thickness, deps.Theme)
		end
	elseif not strokeFn then
		strokeFn = function(inst, color, thickness)
			local s = Instance.new("UIStroke")
			s.Color = color or (deps.Theme and deps.Theme:Get().Border) or Color3.fromRGB(45, 45, 55)
			s.Thickness = thickness or 1
			s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			s.LineJoinMode = Enum.LineJoinMode.Round
			s.Parent = inst
			return s
		end
	end

	self:Init({
		Theme = deps.Theme,
		Animator = deps.Animator,
		host = deps.host,
		RvrseUI = deps.RvrseUI,
		corner = cornerFn,
		stroke = strokeFn,
		Icons = deps.Icons
	})
end

function Notifications:SetContext(rvrseUI)
	RvrseUI = rvrseUI
end

return Notifications
