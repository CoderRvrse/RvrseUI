-- =========================
-- RvrseUI Animator Module
-- =========================
-- Handles spring-based animations and tweening
-- Extracted from RvrseUI.lua (lines 852-895)

local TweenService = game:GetService("TweenService")

local Animator = {}

-- Spring animation presets
Animator.Spring = {
	Smooth = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Snappy = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Bounce = TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
	Fast = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
}

-- Generic tween function
function Animator:Tween(obj, props, info)
	info = info or self.Spring.Smooth
	local tween = TweenService:Create(obj, info, props)
	tween:Play()
	return tween
end

-- Scale animation helper
function Animator:Scale(obj, scale, info)
	return self:Tween(obj, {Size = UDim2.new(scale, 0, scale, 0)}, info or self.Spring.Snappy)
end

-- Material ripple effect
function Animator:Ripple(parent, x, y, Theme)
	local ripple = Instance.new("Frame")
	ripple.Name = "Ripple"
	ripple.AnchorPoint = Vector2.new(0.5, 0.5)
	ripple.Position = UDim2.new(0, x, 0, y)
	ripple.Size = UDim2.new(0, 0, 0, 0)
	ripple.BackgroundColor3 = Theme and Theme:Get().Accent or Color3.fromRGB(255, 255, 255)
	ripple.BackgroundTransparency = 0.5
	ripple.BorderSizePixel = 0
	ripple.ZIndex = 100
	ripple.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = ripple

	-- Expand and fade out
	self:Tween(ripple, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1}, self.Spring.Fast)
	task.delay(0.15, function()
		ripple:Destroy()
	end)
end

return Animator
