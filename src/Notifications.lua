-- =========================
-- Notifications Module
-- =========================
-- Extracted from RvrseUI.lua (lines 1066-1179)
-- Provides toast notification system with animations and priority support

local Notifications = {}

-- Helper functions (must be passed as dependencies)
local corner, stroke

-- Dependencies
local Theme, Animator, host

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

	-- Icon
	local iconMap = { success = "✓", error = "✕", warn = "⚠", info = "ℹ" }
	local iconText = Instance.new("TextLabel")
	iconText.BackgroundTransparency = 1
	iconText.Position = UDim2.new(0, 16, 0, 0)
	iconText.Size = UDim2.new(0, 32, 0, 32)
	iconText.Font = Enum.Font.GothamBold
	iconText.TextSize = 18
	iconText.Text = iconMap[opt.Type] or "ℹ"
	iconText.TextColor3 = accentColor
	iconText.Parent = card

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
	-- Store dependencies for Notify function
	-- deps contains: host, Theme, Animator, UIHelpers
	-- These are accessed directly in RvrseUI:Notify() via closure
end

return Notifications
