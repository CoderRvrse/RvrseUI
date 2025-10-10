-- =========================
-- RvrseUI Animator Module v4.0
-- =========================
-- Next-generation animation system with buttery-smooth transitions
-- Redesigned for maximum responsiveness across PC, mobile, and console

local TweenService = game:GetService("TweenService")

local Animator = {}

-- 🎬 Advanced spring animation presets - Ultra smooth and responsive
Animator.Spring = {
	-- Ultra-smooth for premium feel
	Butter = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),

	-- Snappy and responsive
	Snappy = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),

	-- Bouncy with personality
	Bounce = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),

	-- Lightning fast for instant feedback
	Lightning = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

	-- Smooth glide for large movements
	Glide = TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),

	-- Spring-back effect
	Spring = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),

	-- Expo for dramatic entrances
	Expo = TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),

	-- Quick pop-in
	Pop = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0, 0.5),
}

-- 🎯 Generic tween function - The foundation of all animations
function Animator:Tween(obj, props, info)
	info = info or self.Spring.Butter
	local tween = TweenService:Create(obj, info, props)
	tween:Play()
	return tween
end

-- 📏 Scale animation helper with customizable pivot
function Animator:Scale(obj, scale, info)
	return self:Tween(obj, {Size = UDim2.new(scale, 0, scale, 0)}, info or self.Spring.Pop)
end

-- 💫 Material ripple effect with gradient glow
function Animator:Ripple(parent, x, y, Theme)
	local palette = Theme and Theme:Get() or {}

	local ripple = Instance.new("Frame")
	ripple.Name = "Ripple"
	ripple.AnchorPoint = Vector2.new(0.5, 0.5)
	ripple.Position = UDim2.new(0, x, 0, y)
	ripple.Size = UDim2.new(0, 0, 0, 0)
	ripple.BackgroundColor3 = palette.Accent or Color3.fromRGB(236, 72, 153)
	ripple.BackgroundTransparency = 0.3
	ripple.BorderSizePixel = 0
	ripple.ZIndex = 100
	ripple.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = ripple

	-- Add gradient for extra flair
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, palette.Primary or Color3.fromRGB(138, 43, 226)),
		ColorSequenceKeypoint.new(0.5, palette.Accent or Color3.fromRGB(236, 72, 153)),
		ColorSequenceKeypoint.new(1, palette.Secondary or Color3.fromRGB(0, 229, 255)),
	}
	gradient.Parent = ripple

	-- Expand and fade with smooth easing
	self:Tween(ripple, {
		Size = UDim2.new(1.5, 0, 1.5, 0),
		BackgroundTransparency = 1
	}, self.Spring.Lightning)

	task.delay(0.15, function()
		ripple:Destroy()
	end)
end

-- ✨ Shimmer effect for highlights
function Animator:Shimmer(obj, Theme)
	local palette = Theme and Theme:Get() or {}

	local shimmer = Instance.new("Frame")
	shimmer.Name = "Shimmer"
	shimmer.AnchorPoint = Vector2.new(0, 0.5)
	shimmer.Position = UDim2.new(-0.5, 0, 0.5, 0)
	shimmer.Size = UDim2.new(0.3, 0, 1, 0)
	shimmer.BackgroundColor3 = palette.Shimmer or Color3.fromRGB(255, 255, 255)
	shimmer.BackgroundTransparency = 0.7
	shimmer.BorderSizePixel = 0
	shimmer.ZIndex = 150
	shimmer.Rotation = 15
	shimmer.Parent = obj

	local gradient = Instance.new("UIGradient")
	gradient.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.3),
		NumberSequenceKeypoint.new(1, 1),
	}
	gradient.Parent = shimmer

	-- Sweep across
	self:Tween(shimmer, {Position = UDim2.new(1.5, 0, 0.5, 0)}, self.Spring.Glide)

	task.delay(0.4, function()
		shimmer:Destroy()
	end)
end

-- 🌊 Pulse animation for attention
function Animator:Pulse(obj, scale, info)
	scale = scale or 1.05
	info = info or self.Spring.Bounce

	local originalSize = obj.Size
	self:Tween(obj, {Size = originalSize * scale}, info)

	task.delay(info.Time, function()
		self:Tween(obj, {Size = originalSize}, info)
	end)
end

-- 🎨 Glow effect animation
function Animator:Glow(obj, intensity, duration, Theme)
	local palette = Theme and Theme:Get() or {}
	intensity = intensity or 0.3
	duration = duration or 0.4

	local glow = Instance.new("UIStroke")
	glow.Name = "Glow"
	glow.Color = palette.Glow or Color3.fromRGB(168, 85, 247)
	glow.Thickness = 0
	glow.Transparency = 1
	glow.Parent = obj

	-- Fade in glow
	self:Tween(glow, {
		Thickness = 3,
		Transparency = intensity
	}, TweenInfo.new(duration * 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))

	-- Fade out glow
	task.delay(duration * 0.5, function()
		self:Tween(glow, {
			Thickness = 0,
			Transparency = 1
		}, TweenInfo.new(duration * 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))

		task.delay(duration * 0.5, function()
			glow:Destroy()
		end)
	end)
end

-- 🚀 Slide in animation
function Animator:SlideIn(obj, direction, distance, info)
	direction = direction or "Bottom"
	distance = distance or 50
	info = info or self.Spring.Spring

	local originalPosition = obj.Position
	local startOffset = Vector2.new(0, 0)

	if direction == "Top" then
		startOffset = Vector2.new(0, -distance)
	elseif direction == "Bottom" then
		startOffset = Vector2.new(0, distance)
	elseif direction == "Left" then
		startOffset = Vector2.new(-distance, 0)
	elseif direction == "Right" then
		startOffset = Vector2.new(distance, 0)
	end

	obj.Position = originalPosition + UDim2.fromOffset(startOffset.X, startOffset.Y)
	self:Tween(obj, {Position = originalPosition}, info)
end

-- 🎭 Fade in animation
function Animator:FadeIn(obj, startTransparency, info)
	startTransparency = startTransparency or 1
	info = info or self.Spring.Glide

	obj.BackgroundTransparency = startTransparency
	self:Tween(obj, {BackgroundTransparency = 0}, info)
end

-- Initialize method (called by init.lua)
function Animator:Initialize(tweenService)
	-- Animator is ready to use
	-- TweenService is already imported at module level (line 7)
	-- Spring presets are defined at module load time
end

return Animator
