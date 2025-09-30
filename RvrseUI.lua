-- RvrseUI v2.0 | Modern Professional UI Framework
-- Features: Glassmorphism, Spring Animations, Mobile-First Responsive, Touch-Optimized
-- API: CreateWindow → CreateTab → CreateSection → {CreateButton, CreateToggle, CreateDropdown, CreateKeybind, CreateSlider}
-- Extras: Notify system, Theme switcher, LockGroup system, Drag-to-move, Auto-scaling

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")
local Mouse = LP:GetMouse()

local RvrseUI = {}
RvrseUI.DEBUG = false
RvrseUI.Version = "2.1.0"
RvrseUI.NotificationsEnabled = true  -- Global notification toggle

-- Debug print helper (only prints when DEBUG = true)
local function dprintf(...)
	if RvrseUI.DEBUG then
		print("[RvrseUI]", ...)
	end
end

-- =========================
-- Modern Theme System
-- =========================
local Theme = {}
Theme.Palettes = {
	Dark = {
		-- Glassmorphic backgrounds
		Bg = Color3.fromRGB(10, 10, 14),
		Glass = Color3.fromRGB(18, 18, 24),
		Card = Color3.fromRGB(26, 26, 32),
		Elevated = Color3.fromRGB(32, 32, 40),

		-- Text hierarchy
		Text = Color3.fromRGB(245, 245, 250),
		TextSub = Color3.fromRGB(160, 165, 180),
		TextMuted = Color3.fromRGB(110, 115, 130),

		-- Accents & states
		Accent = Color3.fromRGB(99, 102, 241),  -- Modern indigo
		AccentHover = Color3.fromRGB(129, 140, 248),
		Success = Color3.fromRGB(34, 197, 94),
		Warning = Color3.fromRGB(251, 191, 36),
		Error = Color3.fromRGB(239, 68, 68),
		Info = Color3.fromRGB(59, 130, 246),

		-- Borders & dividers
		Border = Color3.fromRGB(45, 45, 55),
		Divider = Color3.fromRGB(35, 35, 43),

		-- Interactive states
		Hover = Color3.fromRGB(38, 38, 48),
		Active = Color3.fromRGB(48, 48, 60),
		Disabled = Color3.fromRGB(70, 70, 82),
	},
	Light = {
		Bg = Color3.fromRGB(250, 250, 252),
		Glass = Color3.fromRGB(255, 255, 255),
		Card = Color3.fromRGB(255, 255, 255),
		Elevated = Color3.fromRGB(248, 248, 250),

		Text = Color3.fromRGB(15, 15, 20),
		TextSub = Color3.fromRGB(75, 80, 95),
		TextMuted = Color3.fromRGB(130, 135, 150),

		Accent = Color3.fromRGB(79, 70, 229),
		AccentHover = Color3.fromRGB(99, 102, 241),
		Success = Color3.fromRGB(22, 163, 74),
		Warning = Color3.fromRGB(245, 158, 11),
		Error = Color3.fromRGB(220, 38, 38),
		Info = Color3.fromRGB(37, 99, 235),

		Border = Color3.fromRGB(220, 220, 230),
		Divider = Color3.fromRGB(235, 235, 242),

		Hover = Color3.fromRGB(245, 245, 250),
		Active = Color3.fromRGB(235, 235, 245),
		Disabled = Color3.fromRGB(200, 200, 210),
	}
}
Theme.Current = "Dark"
function Theme:Get() return self.Palettes[self.Current] end
function Theme:Switch(mode)
	if self.Palettes[mode] then
		self.Current = mode
		-- Trigger theme refresh
		if RvrseUI._themeListeners then
			for _, fn in ipairs(RvrseUI._themeListeners) do
				pcall(fn)
			end
		end
	end
end

-- =========================
-- Animation System (Spring-based)
-- =========================
local Animator = {}
Animator.Spring = {
	Smooth = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Snappy = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Bounce = TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
	Fast = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
}

function Animator:Tween(obj, props, info)
	info = info or self.Spring.Smooth
	local tween = TweenService:Create(obj, info, props)
	tween:Play()
	return tween
end

function Animator:Scale(obj, scale, info)
	return self:Tween(obj, {Size = UDim2.new(scale, obj.Size.X.Offset, scale, obj.Size.Y.Offset)}, info)
end

function Animator:Ripple(parent, x, y)
	local pal = Theme:Get()
	local ripple = Instance.new("Frame")
	ripple.Name = "Ripple"
	ripple.AnchorPoint = Vector2.new(0.5, 0.5)
	ripple.Position = UDim2.new(0, x, 0, y)
	ripple.Size = UDim2.new(0, 0, 0, 0)
	ripple.BackgroundColor3 = pal.Accent
	ripple.BackgroundTransparency = 0.5
	ripple.BorderSizePixel = 0
	ripple.ZIndex = 100
	ripple.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = ripple

	local size = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2
	local tween = TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, size, 0, size),
		BackgroundTransparency = 1
	})
	tween:Play()
	tween.Completed:Connect(function() ripple:Destroy() end)
end

-- =========================
-- Store (Locks & State)
-- =========================
RvrseUI.Store = {
	_locks = {},
}
function RvrseUI.Store:SetLocked(group, isLocked)
	if not group then return end
	self._locks[group] = isLocked and true or false
	if RvrseUI._lockListeners then
		for _, fn in ipairs(RvrseUI._lockListeners) do
			pcall(fn)
		end
	end
end
function RvrseUI.Store:IsLocked(group)
	return group and self._locks[group] == true
end

-- =========================
-- Utility Functions
-- =========================
local function coerceKeycode(k)
	if typeof(k) == "EnumItem" and k.EnumType == Enum.KeyCode then return k end
	if typeof(k) == "string" and #k > 0 then
		local up = k:upper():gsub("%s", "")
		if Enum.KeyCode[up] then return Enum.KeyCode[up] end
	end
	return Enum.KeyCode.K
end

local function corner(inst, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 12)
	c.Parent = inst
	return c
end

local function stroke(inst, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme:Get().Border
	s.Thickness = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = inst
	return s
end

local function gradient(inst, rotation, colors)
	local g = Instance.new("UIGradient")
	g.Rotation = rotation or 0
	if colors then
		local colorSeq = {}
		for i, c in ipairs(colors) do
			table.insert(colorSeq, ColorSequenceKeypoint.new((i-1)/(#colors-1), c))
		end
		g.Color = ColorSequence.new(colorSeq)
	end
	g.Parent = inst
	return g
end

local function padding(inst, all)
	local p = Instance.new("UIPadding")
	local u = UDim.new(0, all or 12)
	p.PaddingTop = u
	p.PaddingBottom = u
	p.PaddingLeft = u
	p.PaddingRight = u
	p.Parent = inst
	return p
end

local function shadow(inst, transparency, size)
	-- Simulated shadow using ImageLabel
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.BackgroundTransparency = 1
	shadow.Position = UDim2.new(0.5, 0, 0.5, size or 4)
	shadow.Size = UDim2.new(1, (size or 4) * 2, 1, (size or 4) * 2)
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = transparency or 0.8
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(24, 24, 24, 24)
	shadow.ZIndex = inst.ZIndex - 1
	shadow.Parent = inst
	return shadow
end

local function createTooltip(parent, text)
	local tooltip = Instance.new("TextLabel")
	tooltip.Name = "Tooltip"
	tooltip.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	tooltip.BackgroundTransparency = 0.1
	tooltip.BorderSizePixel = 0
	tooltip.Size = UDim2.new(0, 0, 0, 24)
	tooltip.AutomaticSize = Enum.AutomaticSize.X
	tooltip.Position = UDim2.new(0.5, 0, 1, 4)
	tooltip.AnchorPoint = Vector2.new(0.5, 0)
	tooltip.Font = Enum.Font.Gotham
	tooltip.TextSize = 12
	tooltip.TextColor3 = Color3.fromRGB(255, 255, 255)
	tooltip.Text = "  " .. text .. "  "
	tooltip.Visible = false
	tooltip.ZIndex = 1000
	tooltip.Parent = parent
	corner(tooltip, 6)

	local tooltipStroke = Instance.new("UIStroke")
	tooltipStroke.Color = Color3.fromRGB(60, 60, 70)
	tooltipStroke.Thickness = 1
	tooltipStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	tooltipStroke.Parent = tooltip

	return tooltip
end

local function addGlow(inst, color, intensity)
	-- Add glow effect using UIStroke
	local glow = Instance.new("UIStroke")
	glow.Name = "Glow"
	glow.Color = color or Color3.fromRGB(99, 102, 241)
	glow.Thickness = 0
	glow.Transparency = 0.5
	glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	glow.Parent = inst

	-- Animate glow
	local glowTween = TweenService:Create(glow, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
		Thickness = intensity or 2,
		Transparency = 0.2
	})
	glowTween:Play()

	return glow
end

-- =========================
-- Root Host
-- =========================
local host = Instance.new("ScreenGui")
host.Name = "RvrseUI_v2"
host.ResetOnSpawn = false
host.IgnoreGuiInset = true
host.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
host.DisplayOrder = 999
host.Parent = PlayerGui

-- =========================
-- Notification System
-- =========================
local notifyRoot = Instance.new("Frame")
notifyRoot.Name = "NotifyStack"
notifyRoot.BackgroundTransparency = 1
notifyRoot.AnchorPoint = Vector2.new(1, 1)
notifyRoot.Position = UDim2.new(1, -16, 1, -16)
notifyRoot.Size = UDim2.new(0, 340, 1, -32)
notifyRoot.Parent = host

local notifyLayout = Instance.new("UIListLayout")
notifyLayout.Padding = UDim.new(0, 8)
notifyLayout.FillDirection = Enum.FillDirection.Vertical
notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
notifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifyLayout.Parent = notifyRoot

function RvrseUI:Notify(opt)
	-- Check if notifications are enabled
	if not RvrseUI.NotificationsEnabled then return end

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

-- =========================
-- UI Toggle System
-- =========================
RvrseUI.UI = { _toggleTargets = {}, _key = Enum.KeyCode.K }
function RvrseUI.UI:RegisterToggleTarget(frame)
	self._toggleTargets[frame] = true
end
function RvrseUI.UI:BindToggleKey(key)
	self._key = coerceKeycode(key or "K")
end

UIS.InputBegan:Connect(function(io, gpe)
	if gpe then return end
	if io.KeyCode == RvrseUI.UI._key then
		for f in pairs(RvrseUI.UI._toggleTargets) do
			if f and f.Parent then
				f.Visible = not f.Visible
			end
		end
	end
end)

-- Listeners
RvrseUI._lockListeners = {}
RvrseUI._themeListeners = {}

-- =========================
-- Window Builder
-- =========================
function RvrseUI:CreateWindow(cfg)
	cfg = cfg or {}
	local pal = Theme:Get()

	if cfg.Theme and Theme.Palettes[cfg.Theme] then
		Theme.Current = cfg.Theme
		pal = Theme:Get()
	end

	local name = cfg.Name or "RvrseUI"
	local toggleKey = coerceKeycode(cfg.ToggleUIKeybind or "K")
	self.UI:BindToggleKey(toggleKey)

	-- Detect mobile/tablet
	local isMobile = UIS.TouchEnabled and not UIS.MouseEnabled
	local baseWidth = isMobile and 380 or 580
	local baseHeight = isMobile and 520 or 480

	-- Root window (glassmorphic)
	local root = Instance.new("Frame")
	root.Name = "Window_" .. name:gsub("%s", "")
	root.Size = UDim2.new(0, baseWidth, 0, baseHeight)
	root.Position = UDim2.new(0.5, -baseWidth/2, 0.5, -baseHeight/2)
	root.BackgroundColor3 = pal.Bg
	root.BackgroundTransparency = 0.05
	root.BorderSizePixel = 0
	root.Visible = true
	root.ClipsDescendants = false
	root.Parent = host
	corner(root, 16)
	stroke(root, pal.Border, 1.5)
	self.UI:RegisterToggleTarget(root)

	-- Enhanced Glassmorphic overlay (93-97% transparency)
	local glassOverlay = Instance.new("Frame")
	glassOverlay.Size = UDim2.new(1, 0, 1, 0)
	glassOverlay.BackgroundColor3 = Theme.Current == "Dark"
		and Color3.fromRGB(255, 255, 255)
		or Color3.fromRGB(245, 245, 250)
	glassOverlay.BackgroundTransparency = 0.95  -- 95% transparent for true glass effect
	glassOverlay.BorderSizePixel = 0
	glassOverlay.ZIndex = root.ZIndex - 1
	glassOverlay.Parent = root
	corner(glassOverlay, 16)

	-- Glass edge shine
	local glassShine = Instance.new("UIStroke")
	glassShine.Color = Color3.fromRGB(255, 255, 255)
	glassShine.Transparency = 0.7
	glassShine.Thickness = 1
	glassShine.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	glassShine.Parent = glassOverlay

	-- Header bar
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 52)
	header.BackgroundColor3 = pal.Elevated
	header.BackgroundTransparency = 0.3
	header.BorderSizePixel = 0
	header.Parent = root
	corner(header, 16)
	stroke(header, pal.Divider, 1)

	-- Header gradient
	gradient(header, 90, {pal.Elevated, pal.Card})

	-- Drag to move (header)
	local dragging, dragStart, startPos
	header.InputBegan:Connect(function(io)
		if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = io.Position
			startPos = root.Position
		end
	end)
	header.InputEnded:Connect(function(io)
		if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UIS.InputChanged:Connect(function(io)
		if dragging and (io.UserInputType == Enum.UserInputType.MouseMovement or io.UserInputType == Enum.UserInputType.Touch) then
			local delta = io.Position - dragStart
			root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	-- Icon
	local iconHolder = Instance.new("Frame")
	iconHolder.BackgroundTransparency = 1
	iconHolder.Position = UDim2.new(0, 16, 0.5, -16)
	iconHolder.Size = UDim2.new(0, 32, 0, 32)
	iconHolder.Parent = header

	if typeof(cfg.Icon) == "number" and cfg.Icon ~= 0 then
		local img = Instance.new("ImageLabel")
		img.BackgroundTransparency = 1
		img.Image = "rbxassetid://" .. cfg.Icon
		img.Size = UDim2.new(1, 0, 1, 0)
		img.Parent = iconHolder
		corner(img, 8)
	elseif typeof(cfg.Icon) == "string" and cfg.Icon ~= "" then
		local iconTxt = Instance.new("TextLabel")
		iconTxt.BackgroundTransparency = 1
		iconTxt.Font = Enum.Font.GothamBold
		iconTxt.TextSize = 20
		iconTxt.TextColor3 = pal.Accent
		iconTxt.Text = cfg.Icon
		iconTxt.Size = UDim2.new(1, 0, 1, 0)
		iconTxt.Parent = iconHolder
	end

	-- Title
	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 56, 0, 0)
	title.Size = UDim2.new(1, -120, 1, 0)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.TextColor3 = pal.Text
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = name
	title.Parent = header

	-- Notification Bell Toggle (Revolutionary!)
	local bellToggle = Instance.new("TextButton")
	bellToggle.Name = "BellToggle"
	bellToggle.AnchorPoint = Vector2.new(1, 0.5)
	bellToggle.Position = UDim2.new(1, -16, 0.5, 0)
	bellToggle.Size = UDim2.new(0, 50, 0, 24)
	bellToggle.BackgroundColor3 = pal.Elevated
	bellToggle.BorderSizePixel = 0
	bellToggle.Font = Enum.Font.GothamBold
	bellToggle.TextSize = 14
	bellToggle.Text = "🔔"
	bellToggle.TextColor3 = pal.Success
	bellToggle.AutoButtonColor = false
	bellToggle.Parent = header
	corner(bellToggle, 12)
	stroke(bellToggle, pal.Border, 1)
	addGlow(bellToggle, pal.Success, 1.5)

	local bellTooltip = createTooltip(bellToggle, "Notifications: ON")

	bellToggle.MouseEnter:Connect(function()
		bellTooltip.Visible = true
		Animator:Tween(bellToggle, {BackgroundColor3 = pal.Hover}, Animator.Spring.Fast)
	end)
	bellToggle.MouseLeave:Connect(function()
		bellTooltip.Visible = false
		Animator:Tween(bellToggle, {BackgroundColor3 = pal.Elevated}, Animator.Spring.Fast)
	end)

	bellToggle.MouseButton1Click:Connect(function()
		RvrseUI.NotificationsEnabled = not RvrseUI.NotificationsEnabled
		if RvrseUI.NotificationsEnabled then
			bellToggle.Text = "🔔"
			bellToggle.TextColor3 = pal.Success
			bellTooltip.Text = "  Notifications: ON  "
			-- Re-add glow
			if bellToggle:FindFirstChild("Glow") then
				bellToggle.Glow:Destroy()
			end
			addGlow(bellToggle, pal.Success, 1.5)
		else
			bellToggle.Text = "🔕"
			bellToggle.TextColor3 = pal.Error
			bellTooltip.Text = "  Notifications: OFF  "
			-- Remove glow
			if bellToggle:FindFirstChild("Glow") then
				bellToggle.Glow:Destroy()
			end
		end
		Animator:Ripple(bellToggle, 25, 12)
	end)

	-- Theme Toggle Pill (Mini Professional)
	local themeToggle = Instance.new("TextButton")
	themeToggle.Name = "ThemeToggle"
	themeToggle.AnchorPoint = Vector2.new(1, 0.5)
	themeToggle.Position = UDim2.new(1, -74, 0.5, 0)
	themeToggle.Size = UDim2.new(0, 50, 0, 24)
	themeToggle.BackgroundColor3 = pal.Elevated
	themeToggle.BorderSizePixel = 0
	themeToggle.Font = Enum.Font.GothamBold
	themeToggle.TextSize = 14
	themeToggle.Text = Theme.Current == "Dark" and "🌙" or "🌞"
	themeToggle.TextColor3 = pal.Accent
	themeToggle.AutoButtonColor = false
	themeToggle.Parent = header
	corner(themeToggle, 12)
	stroke(themeToggle, pal.Border, 1)

	local themeTooltip = createTooltip(themeToggle, "Theme: " .. Theme.Current)

	themeToggle.MouseEnter:Connect(function()
		themeTooltip.Visible = true
		Animator:Tween(themeToggle, {BackgroundColor3 = pal.Hover}, Animator.Spring.Fast)
	end)
	themeToggle.MouseLeave:Connect(function()
		themeTooltip.Visible = false
		Animator:Tween(themeToggle, {BackgroundColor3 = pal.Elevated}, Animator.Spring.Fast)
	end)

	themeToggle.MouseButton1Click:Connect(function()
		local newTheme = Theme.Current == "Dark" and "Light" or "Dark"
		Theme:Switch(newTheme)
		pal = Theme:Get()

		themeToggle.Text = newTheme == "Dark" and "🌙" or "🌞"
		themeToggle.TextColor3 = pal.Accent
		themeTooltip.Text = "  Theme: " .. newTheme .. "  "

		-- Update glass overlay
		glassOverlay.BackgroundColor3 = newTheme == "Dark"
			and Color3.fromRGB(255, 255, 255)
			or Color3.fromRGB(245, 245, 250)

		Animator:Ripple(themeToggle, 25, 12)

		RvrseUI:Notify({
			Title = "Theme Changed",
			Message = "Switched to " .. newTheme .. " mode",
			Duration = 2,
			Type = "info"
		})
	end)

	-- Version badge
	local versionBadge = Instance.new("TextLabel")
	versionBadge.BackgroundColor3 = pal.Accent
	versionBadge.BackgroundTransparency = 0.9
	versionBadge.Position = UDim2.new(1, -132, 0.5, -10)
	versionBadge.Size = UDim2.new(0, 50, 0, 20)
	versionBadge.Font = Enum.Font.GothamMedium
	versionBadge.TextSize = 10
	versionBadge.TextColor3 = pal.Accent
	versionBadge.Text = "v" .. RvrseUI.Version
	versionBadge.Parent = header
	corner(versionBadge, 6)

	-- Tab bar (horizontal)
	local tabBar = Instance.new("Frame")
	tabBar.BackgroundTransparency = 1
	tabBar.Position = UDim2.new(0, 12, 0, 60)
	tabBar.Size = UDim2.new(1, -24, 0, 40)
	tabBar.Parent = root

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.Padding = UDim.new(0, 8)
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Parent = tabBar

	-- Body container
	local body = Instance.new("Frame")
	body.BackgroundColor3 = pal.Card
	body.BackgroundTransparency = 0.5
	body.BorderSizePixel = 0
	body.Position = UDim2.new(0, 12, 0, 108)
	body.Size = UDim2.new(1, -24, 1, -120)
	body.Parent = root
	corner(body, 12)
	stroke(body, pal.Border, 1)

	-- Splash screen
	local splash = Instance.new("Frame")
	splash.BackgroundColor3 = pal.Card
	splash.BorderSizePixel = 0
	splash.Position = UDim2.new(0, 12, 0, 108)
	splash.Size = UDim2.new(1, -24, 1, -120)
	splash.ZIndex = 999
	splash.Parent = root
	corner(splash, 12)

	local splashTitle = Instance.new("TextLabel")
	splashTitle.BackgroundTransparency = 1
	splashTitle.Position = UDim2.new(0, 24, 0, 24)
	splashTitle.Size = UDim2.new(1, -48, 0, 32)
	splashTitle.Font = Enum.Font.GothamBold
	splashTitle.TextSize = 22
	splashTitle.TextColor3 = pal.Text
	splashTitle.TextXAlignment = Enum.TextXAlignment.Left
	splashTitle.Text = cfg.LoadingTitle or name
	splashTitle.Parent = splash

	local splashSub = Instance.new("TextLabel")
	splashSub.BackgroundTransparency = 1
	splashSub.Position = UDim2.new(0, 24, 0, 60)
	splashSub.Size = UDim2.new(1, -48, 0, 22)
	splashSub.Font = Enum.Font.Gotham
	splashSub.TextSize = 14
	splashSub.TextColor3 = pal.TextSub
	splashSub.TextXAlignment = Enum.TextXAlignment.Left
	splashSub.Text = cfg.LoadingSubtitle or "Loading..."
	splashSub.Parent = splash

	-- Loading bar
	local loadingBar = Instance.new("Frame")
	loadingBar.BackgroundColor3 = pal.Border
	loadingBar.BorderSizePixel = 0
	loadingBar.Position = UDim2.new(0, 24, 0, 100)
	loadingBar.Size = UDim2.new(1, -48, 0, 4)
	loadingBar.Parent = splash
	corner(loadingBar, 2)

	local loadingFill = Instance.new("Frame")
	loadingFill.BackgroundColor3 = pal.Accent
	loadingFill.BorderSizePixel = 0
	loadingFill.Size = UDim2.new(0, 0, 1, 0)
	loadingFill.Parent = loadingBar
	corner(loadingFill, 2)
	gradient(loadingFill, 90, {pal.Accent, pal.AccentHover})

	Animator:Tween(loadingFill, {Size = UDim2.new(1, 0, 1, 0)}, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
	task.delay(0.9, function()
		if splash and splash.Parent then
			Animator:Tween(splash, {BackgroundTransparency = 1}, Animator.Spring.Fast)
			task.wait(0.2)
			splash.Visible = false
		end
	end)

	-- Mobile chip
	local chip = Instance.new("TextButton")
	chip.Text = cfg.ShowText or "RvrseUI"
	chip.Font = Enum.Font.GothamMedium
	chip.TextSize = 13
	chip.TextColor3 = pal.Text
	chip.BackgroundColor3 = pal.Card
	chip.Size = UDim2.new(0, 120, 0, 36)
	chip.AnchorPoint = Vector2.new(1, 0)
	chip.Position = UDim2.new(1, -16, 0, 16)
	chip.Visible = false
	chip.Parent = host
	corner(chip, 18)
	stroke(chip, pal.Border, 1)

	local function setHidden(hidden)
		root.Visible = not hidden
		chip.Visible = hidden
	end

	chip.MouseButton1Click:Connect(function() setHidden(false) end)

	-- Tab management
	local activePage
	local tabs = {}

	local WindowAPI = {}
	function WindowAPI:SetTitle(t) title.Text = t or name end
	function WindowAPI:Show() setHidden(false) end
	function WindowAPI:Hide() setHidden(true) end
	function WindowAPI:SetTheme(mode)
		Theme:Switch(mode)
		pal = Theme:Get()
	end

	function WindowAPI:CreateTab(t)
		t = t or {}
		local pal2 = Theme:Get()

		-- Tab button
		local tabBtn = Instance.new("TextButton")
		tabBtn.AutoButtonColor = false
		tabBtn.BackgroundColor3 = pal2.Card
		tabBtn.BackgroundTransparency = 0.7
		tabBtn.Size = UDim2.new(0, 100, 1, 0)
		tabBtn.Font = Enum.Font.GothamMedium
		tabBtn.TextSize = 13
		tabBtn.TextColor3 = pal2.TextSub
		tabBtn.Text = ((t.Icon and t.Icon .. " ") or "") .. (t.Title or "Tab")
		tabBtn.Parent = tabBar
		corner(tabBtn, 8)

		local tabIndicator = Instance.new("Frame")
		tabIndicator.BackgroundColor3 = pal2.Accent
		tabIndicator.BorderSizePixel = 0
		tabIndicator.Position = UDim2.new(0, 0, 1, -3)
		tabIndicator.Size = UDim2.new(0, 0, 0, 3)
		tabIndicator.Visible = false
		tabIndicator.Parent = tabBtn
		corner(tabIndicator, 2)

		-- Tab page (scrollable)
		local page = Instance.new("ScrollingFrame")
		page.BackgroundTransparency = 1
		page.BorderSizePixel = 0
		page.Position = UDim2.new(0, 8, 0, 8)
		page.Size = UDim2.new(1, -16, 1, -16)
		page.ScrollBarThickness = 6
		page.ScrollBarImageColor3 = pal2.Border
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.Visible = false
		page.Parent = body

		local pageLayout = Instance.new("UIListLayout")
		pageLayout.Padding = UDim.new(0, 12)
		pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		pageLayout.Parent = page

		-- Tab activation
		local function activateTab()
			for _, tabData in ipairs(tabs) do
				tabData.page.Visible = false
				tabData.btn.BackgroundTransparency = 0.7
				tabData.btn.TextColor3 = pal2.TextSub
				tabData.indicator.Visible = false
			end
			page.Visible = true
			tabBtn.BackgroundTransparency = 0
			tabBtn.TextColor3 = pal2.Text
			tabIndicator.Visible = true
			Animator:Tween(tabIndicator, {Size = UDim2.new(1, 0, 0, 3)}, Animator.Spring.Snappy)
			activePage = page
		end

		tabBtn.MouseButton1Click:Connect(activateTab)
		tabBtn.MouseEnter:Connect(function()
			if page.Visible == false then
				Animator:Tween(tabBtn, {BackgroundTransparency = 0.4}, Animator.Spring.Fast)
			end
		end)
		tabBtn.MouseLeave:Connect(function()
			if page.Visible == false then
				Animator:Tween(tabBtn, {BackgroundTransparency = 0.7}, Animator.Spring.Fast)
			end
		end)

		table.insert(tabs, {btn = tabBtn, page = page, indicator = tabIndicator})

		if not activePage then
			activateTab()
		end

		local TabAPI = {}

		function TabAPI:CreateSection(sectionTitle)
			local pal3 = Theme:Get()

			-- Section header
			local sectionHeader = Instance.new("Frame")
			sectionHeader.BackgroundTransparency = 1
			sectionHeader.Size = UDim2.new(1, 0, 0, 28)
			sectionHeader.Parent = page

			local sectionLabel = Instance.new("TextLabel")
			sectionLabel.BackgroundTransparency = 1
			sectionLabel.Size = UDim2.new(1, 0, 1, 0)
			sectionLabel.Font = Enum.Font.GothamBold
			sectionLabel.TextSize = 14
			sectionLabel.TextColor3 = pal3.TextMuted
			sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
			sectionLabel.Text = sectionTitle or "Section"
			sectionLabel.Parent = sectionHeader

			-- Section container
			local container = Instance.new("Frame")
			container.BackgroundTransparency = 1
			container.Size = UDim2.new(1, 0, 0, 0)
			container.AutomaticSize = Enum.AutomaticSize.Y
			container.Parent = page

			local containerLayout = Instance.new("UIListLayout")
			containerLayout.Padding = UDim.new(0, 8)
			containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
			containerLayout.Parent = container

			local function card(height)
				local c = Instance.new("Frame")
				c.BackgroundColor3 = pal3.Elevated
				c.BackgroundTransparency = 0.3
				c.BorderSizePixel = 0
				c.Size = UDim2.new(1, 0, 0, height)
				c.Parent = container
				corner(c, 10)
				stroke(c, pal3.Border, 1)
				padding(c, 12)
				return c
			end

			local SectionAPI = {}

			-- Button
			function SectionAPI:CreateButton(o)
				o = o or {}
				local f = card(44)

				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1, 0, 1, 0)
				btn.BackgroundTransparency = 1
				btn.Font = Enum.Font.GothamMedium
				btn.TextSize = 14
				btn.TextColor3 = pal3.Text
				btn.Text = o.Text or "Button"
				btn.AutoButtonColor = false
				btn.Parent = f

				btn.MouseButton1Click:Connect(function()
					if RvrseUI.Store:IsLocked(o.RespectLock) then return end
					local absPos = btn.AbsolutePosition
					local mousePos = UIS:GetMouseLocation()
					Animator:Ripple(btn, mousePos.X - absPos.X, mousePos.Y - absPos.Y)
					if o.Callback then task.spawn(o.Callback) end
				end)

				btn.MouseEnter:Connect(function()
					Animator:Tween(f, {BackgroundTransparency = 0.1}, Animator.Spring.Fast)
				end)
				btn.MouseLeave:Connect(function()
					Animator:Tween(f, {BackgroundTransparency = 0.3}, Animator.Spring.Fast)
				end)

				table.insert(RvrseUI._lockListeners, function()
					local locked = RvrseUI.Store:IsLocked(o.RespectLock)
					btn.TextTransparency = locked and 0.5 or 0
				end)

				return { SetText = function(_, txt) btn.Text = txt end }
			end

			-- Toggle
			function SectionAPI:CreateToggle(o)
				o = o or {}
				local f = card(44)

				local lbl = Instance.new("TextLabel")
				lbl.BackgroundTransparency = 1
				lbl.Size = UDim2.new(1, -60, 1, 0)
				lbl.Font = Enum.Font.GothamMedium
				lbl.TextSize = 14
				lbl.TextXAlignment = Enum.TextXAlignment.Left
				lbl.TextColor3 = pal3.Text
				lbl.Text = o.Text or "Toggle"
				lbl.Parent = f

				local shell = Instance.new("Frame")
				shell.AnchorPoint = Vector2.new(1, 0.5)
				shell.Position = UDim2.new(1, 0, 0.5, 0)
				shell.Size = UDim2.new(0, 48, 0, 26)
				shell.BackgroundColor3 = pal3.Border
				shell.BorderSizePixel = 0
				shell.Parent = f
				corner(shell, 13)

				local dot = Instance.new("Frame")
				dot.Size = UDim2.new(0, 22, 0, 22)
				dot.Position = UDim2.new(0, 2, 0.5, -11)
				dot.BackgroundColor3 = Color3.new(1, 1, 1)
				dot.BorderSizePixel = 0
				dot.Parent = shell
				corner(dot, 11)
				shadow(dot, 0.6, 2)

				local state = o.State == true
				local controlsGroup = o.LockGroup
				local respectGroup = o.RespectLock

				local function lockedNow()
					return respectGroup and RvrseUI.Store:IsLocked(respectGroup)
				end

				local function visual()
					local locked = lockedNow()
					local targetColor = locked and pal3.Disabled or (state and pal3.Success or pal3.Border)
					local targetPos = state and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)

					Animator:Tween(shell, {BackgroundColor3 = targetColor}, Animator.Spring.Smooth)
					Animator:Tween(dot, {Position = targetPos}, Animator.Spring.Snappy)
					lbl.TextTransparency = locked and 0.5 or 0
				end
				visual()

				f.InputBegan:Connect(function(io)
					if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
						if lockedNow() then return end
						state = not state
						visual()
						if controlsGroup then
							RvrseUI.Store:SetLocked(controlsGroup, state)
						end
						if o.OnChanged then task.spawn(o.OnChanged, state) end
					end
				end)

				table.insert(RvrseUI._lockListeners, visual)

				return {
					Set = function(_, v)
						state = v and true or false
						visual()
						if controlsGroup then
							RvrseUI.Store:SetLocked(controlsGroup, state)
						end
					end,
					Get = function() return state end,
					Refresh = visual
				}
			end

			-- Dropdown
			function SectionAPI:CreateDropdown(o)
				o = o or {}
				local f = card(48)

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
				btn.Position = UDim2.new(1, 0, 0.5, 0)
				btn.Size = UDim2.new(0, 130, 0, 32)
				btn.BackgroundColor3 = pal3.Card
				btn.BorderSizePixel = 0
				btn.Font = Enum.Font.Gotham
				btn.TextSize = 13
				btn.TextColor3 = pal3.Text
				btn.AutoButtonColor = false
				btn.Parent = f
				corner(btn, 8)
				stroke(btn, pal3.Border, 1)

				local values = o.Values or {}
				local idx = 1
				for i, v in ipairs(values) do
					if v == o.Default then
						idx = i
						break
					end
				end
				btn.Text = tostring(values[idx] or "Select")

				local function locked()
					return o.RespectLock and RvrseUI.Store:IsLocked(o.RespectLock)
				end

				local function visual()
					btn.AutoButtonColor = not locked()
					lbl.TextTransparency = locked() and 0.5 or 0
				end
				visual()

				btn.MouseButton1Click:Connect(function()
					if locked() then return end
					idx = (idx % #values) + 1
					btn.Text = tostring(values[idx])
					if o.OnChanged then task.spawn(o.OnChanged, values[idx]) end
				end)

				btn.MouseEnter:Connect(function()
					if not locked() then
						Animator:Tween(btn, {BackgroundColor3 = pal3.Hover}, Animator.Spring.Fast)
					end
				end)
				btn.MouseLeave:Connect(function()
					Animator:Tween(btn, {BackgroundColor3 = pal3.Card}, Animator.Spring.Fast)
				end)

				table.insert(RvrseUI._lockListeners, visual)

				return {
					Set = function(_, v)
						for i, val in ipairs(values) do
							if val == v then
								idx = i
								break
							end
						end
						btn.Text = tostring(values[idx])
						visual()
					end,
					Get = function() return values[idx] end
				}
			end

			-- Keybind
			function SectionAPI:CreateKeybind(o)
				o = o or {}
				local f = card(44)

				local lbl = Instance.new("TextLabel")
				lbl.BackgroundTransparency = 1
				lbl.Size = UDim2.new(1, -140, 1, 0)
				lbl.Font = Enum.Font.GothamMedium
				lbl.TextSize = 14
				lbl.TextXAlignment = Enum.TextXAlignment.Left
				lbl.TextColor3 = pal3.Text
				lbl.Text = o.Text or "Keybind"
				lbl.Parent = f

				local btn = Instance.new("TextButton")
				btn.AnchorPoint = Vector2.new(1, 0.5)
				btn.Position = UDim2.new(1, 0, 0.5, 0)
				btn.Size = UDim2.new(0, 130, 0, 32)
				btn.BackgroundColor3 = pal3.Card
				btn.BorderSizePixel = 0
				btn.Font = Enum.Font.Code
				btn.TextSize = 12
				btn.TextColor3 = pal3.Text
				btn.Text = (o.Default and o.Default.Name) or "Set Key"
				btn.AutoButtonColor = false
				btn.Parent = f
				corner(btn, 8)
				stroke(btn, pal3.Border, 1)

				local capturing = false

				btn.MouseButton1Click:Connect(function()
					if RvrseUI.Store:IsLocked(o.RespectLock) then return end
					capturing = true
					btn.Text = "Press any key..."
					btn.TextColor3 = pal3.Accent
				end)

				UIS.InputBegan:Connect(function(io, gpe)
					if gpe or not capturing then return end
					if io.KeyCode ~= Enum.KeyCode.Unknown then
						capturing = false
						btn.Text = io.KeyCode.Name
						btn.TextColor3 = pal3.Text
						if o.OnChanged then task.spawn(o.OnChanged, io.KeyCode) end
					end
				end)

				btn.MouseEnter:Connect(function()
					if not capturing then
						Animator:Tween(btn, {BackgroundColor3 = pal3.Hover}, Animator.Spring.Fast)
					end
				end)
				btn.MouseLeave:Connect(function()
					if not capturing then
						Animator:Tween(btn, {BackgroundColor3 = pal3.Card}, Animator.Spring.Fast)
					end
				end)

				table.insert(RvrseUI._lockListeners, function()
					local locked = RvrseUI.Store:IsLocked(o.RespectLock)
					lbl.TextTransparency = locked and 0.5 or 0
					btn.AutoButtonColor = not locked
				end)

				if o.Default and o.OnChanged then
					task.spawn(o.OnChanged, o.Default)
				end

				return {
					Set = function(_, key)
						btn.Text = (key and key.Name) or "Set Key"
						if o.OnChanged and key then o.OnChanged(key) end
					end
				}
			end

			-- Slider
			function SectionAPI:CreateSlider(o)
				o = o or {}
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

				local track = Instance.new("Frame")
				track.Position = UDim2.new(0, 0, 0, 28)
				track.Size = UDim2.new(1, 0, 0, 6)
				track.BackgroundColor3 = pal3.Border
				track.BorderSizePixel = 0
				track.Parent = f
				corner(track, 3)

				local fill = Instance.new("Frame")
				fill.Size = UDim2.new((value - minVal) / (maxVal - minVal), 0, 1, 0)
				fill.BackgroundColor3 = pal3.Accent
				fill.BorderSizePixel = 0
				fill.Parent = track
				corner(fill, 3)
				gradient(fill, 90, {pal3.Accent, pal3.AccentHover})

				local thumb = Instance.new("Frame")
				thumb.AnchorPoint = Vector2.new(0.5, 0.5)
				thumb.Position = UDim2.new((value - minVal) / (maxVal - minVal), 0, 0.5, 0)
				thumb.Size = UDim2.new(0, 16, 0, 16)
				thumb.BackgroundColor3 = Color3.new(1, 1, 1)
				thumb.BorderSizePixel = 0
				thumb.ZIndex = 2
				thumb.Parent = track
				corner(thumb, 8)
				shadow(thumb, 0.5, 3)

				local dragging = false

				local function update(inputPos)
					local relativeX = math.clamp((inputPos.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					value = math.round((minVal + relativeX * (maxVal - minVal)) / step) * step
					value = math.clamp(value, minVal, maxVal)

					lbl.Text = (o.Text or "Slider") .. ": " .. value
					Animator:Tween(fill, {Size = UDim2.new(relativeX, 0, 1, 0)}, Animator.Spring.Fast)
					Animator:Tween(thumb, {Position = UDim2.new(relativeX, 0, 0.5, 0)}, Animator.Spring.Fast)

					if o.OnChanged then task.spawn(o.OnChanged, value) end
				end

				track.InputBegan:Connect(function(io)
					if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
						if RvrseUI.Store:IsLocked(o.RespectLock) then return end
						dragging = true
						update(io.Position)
					end
				end)

				track.InputEnded:Connect(function(io)
					if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
						dragging = false
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
				end)

				return {
					Set = function(_, v)
						value = math.clamp(v, minVal, maxVal)
						local relativeX = (value - minVal) / (maxVal - minVal)
						lbl.Text = (o.Text or "Slider") .. ": " .. value
						fill.Size = UDim2.new(relativeX, 0, 1, 0)
						thumb.Position = UDim2.new(relativeX, 0, 0.5, 0)
					end,
					Get = function() return value end
				}
			end

			return SectionAPI
		end

		return TabAPI
	end

	-- Welcome notifications
	if not cfg.DisableBuildWarnings then
		RvrseUI:Notify({Title = "RvrseUI v2.0", Message = "Modern UI loaded successfully", Duration = 2, Type = "success"})
	end
	if not cfg.DisableRvrseUIPrompts then
		RvrseUI:Notify({Title = "Tip", Message = "Press " .. toggleKey.Name .. " to toggle UI", Duration = 3, Type = "info"})
	end

	return WindowAPI
end

return RvrseUI