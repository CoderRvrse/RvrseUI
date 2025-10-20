-- Particles.lua
-- RvrseUI "Spore Bubble" Particle System
-- GPU-cheap organic particle effects with Perlin noise drift

local Particles = {}
local deps
local TweenService

-- Configuration
local Config = {
	Enabled = true,
	Density = "med", -- "low" | "med" | "high"
	Blend = "alpha", -- "alpha" | "additive"
	DebugLog = false,
}

-- Particle pool and state
local particlePool = {}
local activeParticles = {}
local particleLayer = nil
local updateConnection = nil
local isPlaying = false
local currentState = "idle" -- "idle" | "expand" | "collapse" | "dragging"

-- Performance tracking
local lastFPS = 60
local lastFrameTime = 0
local adaptiveDensityMultiplier = 1

-- Perlin noise implementation (3D)
local PerlinNoise = {}
local permutation = {}

-- Initialize Perlin permutation table
local function initPerlin()
	-- Standard Perlin permutation
	local p = {
		151,160,137,91,90,15,131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,
		8,99,37,240,21,10,23,190,6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,
		35,11,32,57,177,33,88,237,149,56,87,174,20,125,136,171,168,68,175,74,165,71,
		134,139,48,27,166,77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,
		55,46,245,40,244,102,143,54,65,25,63,161,1,216,80,73,209,76,132,187,208,89,
		18,169,200,196,135,130,116,188,159,86,164,100,109,198,173,186,3,64,52,217,226,
		250,124,123,5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,
		189,28,42,223,183,170,213,119,248,152,2,44,154,163,70,221,153,101,155,167,43,
		172,9,129,22,39,253,19,98,108,110,79,113,224,232,178,185,112,104,218,246,97,
		228,251,34,242,193,238,210,144,12,191,179,162,241,81,51,145,235,249,14,239,
		107,49,192,214,31,181,199,106,157,184,84,204,176,115,121,50,45,127,4,150,254,
		138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
	}

	-- Duplicate the permutation table
	for i = 0, 255 do
		permutation[i] = p[i + 1]
		permutation[i + 256] = p[i + 1]
	end
end

-- Fade function for Perlin noise (6t^5 - 15t^4 + 10t^3)
local function fade(t)
	return t * t * t * (t * (t * 6 - 15) + 10)
end

-- Linear interpolation
local function lerp(t, a, b)
	return a + t * (b - a)
end

-- Gradient function
local function grad(hash, x, y, z)
	local h = hash % 16
	local u = h < 8 and x or y
	local v = h < 4 and y or (h == 12 or h == 14) and x or z
	return ((h % 2 == 0) and u or -u) + ((h % 4 < 2) and v or -v)
end

-- Perlin noise function (returns -1 to 1)
function PerlinNoise.noise(x, y, z)
	-- Find unit cube that contains point
	local X = math.floor(x) % 256
	local Y = math.floor(y) % 256
	local Z = math.floor(z) % 256

	-- Find relative x, y, z of point in cube
	x = x - math.floor(x)
	y = y - math.floor(y)
	z = z - math.floor(z)

	-- Compute fade curves
	local u = fade(x)
	local v = fade(y)
	local w = fade(z)

	-- Hash coordinates of cube corners
	local A = permutation[X] + Y
	local AA = permutation[A] + Z
	local AB = permutation[A + 1] + Z
	local B = permutation[X + 1] + Y
	local BA = permutation[B] + Z
	local BB = permutation[B + 1] + Z

	-- Blend results from 8 corners
	return lerp(w,
		lerp(v,
			lerp(u, grad(permutation[AA], x, y, z), grad(permutation[BA], x - 1, y, z)),
			lerp(u, grad(permutation[AB], x, y - 1, z), grad(permutation[BB], x - 1, y - 1, z))
		),
		lerp(v,
			lerp(u, grad(permutation[AA + 1], x, y, z - 1), grad(permutation[BA + 1], x - 1, y, z - 1)),
			lerp(u, grad(permutation[AB + 1], x, y - 1, z - 1), grad(permutation[BB + 1], x - 1, y - 1, z - 1))
		)
	)
end

-- Octave Perlin noise (multiple frequencies)
function PerlinNoise.octave(x, y, z, octaves, persistence)
	local total = 0
	local frequency = 1
	local amplitude = 1
	local maxValue = 0

	for i = 1, octaves do
		total = total + PerlinNoise.noise(x * frequency, y * frequency, z * frequency) * amplitude
		maxValue = maxValue + amplitude
		amplitude = amplitude * persistence
		frequency = frequency * 2
	end

	return total / maxValue
end

-- Particle size distribution (60% small, 30% medium, 10% large)
local function randomParticleSize()
	local roll = math.random()
	if roll < 0.6 then
		-- Small: 3-8px
		return math.random(3, 8)
	elseif roll < 0.9 then
		-- Medium: 9-16px
		return math.random(9, 16)
	else
		-- Large: 18-28px
		return math.random(18, 28)
	end
end

-- HSL to RGB conversion
local function hslToRgb(h, s, l)
	local r, g, b

	if s == 0 then
		r, g, b = l, l, l
	else
		local function hue2rgb(p, q, t)
			if t < 0 then t = t + 1 end
			if t > 1 then t = t - 1 end
			if t < 1/6 then return p + (q - p) * 6 * t end
			if t < 1/2 then return q end
			if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
			return p
		end

		local q = l < 0.5 and l * (1 + s) or l + s - l * s
		local p = 2 * l - q
		r = hue2rgb(p, q, h + 1/3)
		g = hue2rgb(p, q, h)
		b = hue2rgb(p, q, h - 1/3)
	end

	return Color3.new(r, g, b)
end

local function lerpColor(a, b, alpha)
	alpha = math.clamp(alpha or 0.5, 0, 1)
	return Color3.new(
		a.R + (b.R - a.R) * alpha,
		a.G + (b.G - a.G) * alpha,
		a.B + (b.B - a.B) * alpha
	)
end

-- RGB to HSL conversion
local function rgbToHsl(color)
	local r, g, b = color.R, color.G, color.B
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local h, s, l = 0, 0, (max + min) / 2

	if max ~= min then
		local d = max - min
		s = l > 0.5 and d / (2 - max - min) or d / (max + min)

		if max == r then
			h = (g - b) / d + (g < b and 6 or 0)
		elseif max == g then
			h = (b - r) / d + 2
		else
			h = (r - g) / d + 4
		end

		h = h / 6
	end

	return h, s, l
end

-- Jitter accent color (±6° hue, ±8% lightness)
local function jitterColor(baseColor)
	local h, s, l = rgbToHsl(baseColor)

	-- Jitter hue ±6° (±6/360 = ±0.01667)
	h = h + (math.random() * 0.03334 - 0.01667)
	if h < 0 then h = h + 1 end
	if h > 1 then h = h - 1 end

	-- Jitter lightness ±8%
	l = math.clamp(l + (math.random() * 0.16 - 0.08), 0, 1)

	return hslToRgb(h, s, l)
end

-- Create particle instance (pooled)
local function createParticleInstance()
	local particle = Instance.new("Frame")
	particle.BorderSizePixel = 0
	particle.BackgroundTransparency = 1
	particle.ZIndex = 50 -- Below content (100+) but above glass background

	-- Rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0) -- Perfect circle
	corner.Parent = particle

	-- Optional gradient for larger particles (soft bloom)
	local gradient = Instance.new("UIGradient")
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3), -- Center more opaque
		NumberSequenceKeypoint.new(1, 1)    -- Edges transparent (bloom effect)
	})
	gradient.Parent = particle

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1
	stroke.Transparency = 0.65
	stroke.Parent = particle

	return particle
end

local function createBurstBubble(themePalette, zIndex)
	local bubble = Instance.new("Frame")
	bubble.Name = "FlightBubble"
	bubble.AnchorPoint = Vector2.new(0.5, 0.5)
	bubble.BackgroundTransparency = 1
	bubble.BorderSizePixel = 0
	bubble.ZIndex = (zIndex or 50) + 5

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = bubble

	local gradient = Instance.new("UIGradient")
	gradient.Rotation = math.random(0, 360)
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, themePalette.Accent),
		ColorSequenceKeypoint.new(1, lerpColor(themePalette.Accent, themePalette.Secondary, 0.35))
	})
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.15),
		NumberSequenceKeypoint.new(1, 0.95)
	})
	gradient.Parent = bubble

	local stroke = Instance.new("UIStroke")
	stroke.Color = lerpColor(themePalette.Accent, themePalette.BorderGlow or themePalette.Secondary, 0.2)
	stroke.Thickness = 1
	stroke.Transparency = 0.25
	stroke.Parent = bubble

	return bubble, gradient, stroke
end

-- Get particle from pool or create new one
local function acquireParticle()
	local particle
	if #particlePool > 0 then
		particle = table.remove(particlePool)
	else
		particle = createParticleInstance()
	end
	return particle
end

-- Return particle to pool
local function releaseParticle(particle)
	if particle and particle.Parent then
		particle.Parent = nil
		particle.BackgroundTransparency = 1
		table.insert(particlePool, particle)
	end
end

-- Spawn a new active particle
local function spawnParticle(bounds)
	if not particleLayer or not particleLayer.Parent then return end

	local particle = acquireParticle()
	if not particle then return end

	-- Random size with distribution
	local size = randomParticleSize()

	-- Random spawn position (padding 12-16px inside bounds)
	local padding = math.random(12, 16)

	-- Validate bounds are large enough for particles
	local minX = padding
	local maxX = bounds.X - padding - size
	local minY = padding
	local maxY = bounds.Y - padding - size

	-- Skip spawning if bounds are too small (e.g., during animations)
	if maxX <= minX or maxY <= minY then
		releaseParticle(particle)
		return
	end

	local x = math.random(minX, maxX)
	local y = maxY -- Start near bottom

	-- Particle data
	local data = {
		instance = particle,
		size = size,
		x = x,
		y = y,
		lifetime = math.random() * (5.2 - 2.8) + 2.8, -- 2.8-5.2s
		age = 0,

		-- Velocity (upward with noise)
		baseVelY = -math.random(12, 28), -- gentler float speed
		velX = 0,
		velY = 0,

		-- Noise offsets (for Perlin)
		noiseOffsetX = math.random() * 1000,
		noiseOffsetY = math.random() * 1000,
		noiseOffsetZ = math.random() * 1000,

		-- Opacity (0.15-0.35 base)
		baseOpacity = math.random() * (0.35 - 0.15) + 0.15,
		currentOpacity = 0,

		-- Color with jitter
		color = jitterColor(deps.Theme:Get().Accent),

		-- Easing timings
		fadeInDuration = math.random() * (0.18 - 0.12) + 0.12, -- 120-180ms
		fadeOutDuration = math.random() * (0.22 - 0.18) + 0.18, -- 180-220ms
	}

	-- Setup instance
	particle.Size = UDim2.new(0, size, 0, size)
	particle.Position = UDim2.new(0, x, 0, y)
	particle.BackgroundColor3 = lerpColor(data.color, deps.Theme:Get().Primary or data.color, 0.2)
	particle.BackgroundTransparency = 1 - data.currentOpacity

	local stroke = particle:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Thickness = data.size <= 10 and 0.75 or (data.size <= 18 and 1 or 1.25)
		stroke.Transparency = 0.45
		stroke.Color = lerpColor(data.color, deps.Theme:Get().BorderGlow or data.color, 0.35)
	end
	particle.Parent = particleLayer

	table.insert(activeParticles, data)
end

-- Update all active particles (called per frame)
local function updateParticles(dt)
	if not particleLayer or not particleLayer.Parent then return end

	local bounds = particleLayer.AbsoluteSize
	local time = tick()

	-- Track FPS for adaptive density
	if lastFrameTime > 0 then
		local frameDelta = time - lastFrameTime
		lastFPS = 1 / frameDelta

		-- Reduce density if FPS drops below 50
		if lastFPS < 50 then
			adaptiveDensityMultiplier = math.max(0.3, adaptiveDensityMultiplier - 0.01)
		elseif lastFPS > 55 then
			adaptiveDensityMultiplier = math.min(1.0, adaptiveDensityMultiplier + 0.005)
		end
	end
	lastFrameTime = time

	-- Update each particle
	for i = #activeParticles, 1, -1 do
		local data = activeParticles[i]
		data.age = data.age + dt

		-- Remove expired particles
		if data.age >= data.lifetime then
			releaseParticle(data.instance)
			table.remove(activeParticles, i)
		else
			-- Perlin noise for lateral curl (scale time for smooth motion)
			local noiseScale = 0.5 -- Lower = smoother, larger waves
			local noiseTime = time * noiseScale

			local noiseX = PerlinNoise.octave(
				data.noiseOffsetX + noiseTime,
				data.noiseOffsetY,
				data.noiseOffsetZ,
				2, -- 2 octaves
				0.5 -- persistence
			)

			local noiseY = PerlinNoise.octave(
				data.noiseOffsetX,
				data.noiseOffsetY + noiseTime,
				data.noiseOffsetZ,
				2,
				0.5
			)

			-- Apply noise to velocity (±8-18 px/s lateral, ±6 px/s vertical)
			data.velX = noiseX * (math.random() * (18 - 8) + 8)
			data.velY = data.baseVelY + noiseY * 6

			-- Update position
			data.x = data.x + data.velX * dt
			data.y = data.y + data.velY * dt

			-- Wrap horizontally if out of bounds
			if data.x < -data.size then
				data.x = bounds.X + data.size
			elseif data.x > bounds.X + data.size then
				data.x = -data.size
			end

			-- Opacity easing (cubic in on spawn, cubic out on death)
			local opacityAlpha
			if data.age < data.fadeInDuration then
				-- Fade in (cubic in: t^3)
				local t = data.age / data.fadeInDuration
				opacityAlpha = t * t * t
			elseif data.age > data.lifetime - data.fadeOutDuration then
				-- Fade out (cubic out: 1 - (1-t)^3)
				local t = (data.lifetime - data.age) / data.fadeOutDuration
				opacityAlpha = 1 - (1 - t) * (1 - t) * (1 - t)
			else
				-- Full opacity
				opacityAlpha = 1
			end

			data.currentOpacity = data.baseOpacity * opacityAlpha

			-- Update instance
			data.instance.Position = UDim2.new(0, data.x, 0, data.y)
			data.instance.BackgroundTransparency = 1 - data.currentOpacity

			local stroke = data.instance:FindFirstChildOfClass("UIStroke")
			if stroke then
				stroke.Transparency = math.clamp(0.2 + (1 - opacityAlpha) * 0.8, 0.2, 1)
			end

			local gradient = data.instance:FindFirstChildOfClass("UIGradient")
			if gradient then
				gradient.Rotation = (gradient.Rotation + data.velX * dt * 1.8) % 360
			end

			-- Additive blend (brighten color for additive effect)
			if Config.Blend == "additive" then
				local bright = 1.3
				data.instance.BackgroundColor3 = Color3.new(
					math.min(1, data.color.R * bright),
					math.min(1, data.color.G * bright),
					math.min(1, data.color.B * bright)
				)
			else
				data.instance.BackgroundColor3 = data.color
			end
		end
	end
end

-- Calculate adaptive particle count based on screen size
local function calculateParticleCount(state)
	if not particleLayer or not particleLayer.Parent then return 0 end

	local bounds = particleLayer.AbsoluteSize
	local pixelArea = bounds.X * bounds.Y

	-- Base density (particles per 100,000 pixels)
	local densityMap = {
		low = 0.5,
		med = 1.0,
		high = 1.5
	}

	local density = densityMap[Config.Density] or 1.0
	local baseCount = math.floor((pixelArea / 100000) * density * 60) -- 60 particles at med density for ~600x400 window

	-- State multipliers
	local stateMultiplier = 1.0
	if state == "expand" then
		stateMultiplier = 1.3 -- +30% burst on expand
	elseif state == "dragging" then
		stateMultiplier = 0.5 -- 50% throttle during drag
	elseif state == "idle" then
		stateMultiplier = 0.1 -- 10% trickle while idle
	end

	-- Apply adaptive density (reduces if FPS drops)
	local finalCount = math.floor(baseCount * stateMultiplier * adaptiveDensityMultiplier)

	-- Clamp (40-80 desktop, 20-40 mobile approximation)
	local isMobile = pixelArea < 300000 -- Rough mobile detection
	local minCount = isMobile and 20 or 40
	local maxCount = isMobile and 40 or 80

	return math.clamp(finalCount, minCount, maxCount)
end

-- Particle spawn loop (spawns particles over time)
local spawnTimer = 0
local spawnRate = 0.05 -- Spawn every 50ms

local function spawnLoop(dt)
	if not isPlaying or not particleLayer or not particleLayer.Parent then return end

	spawnTimer = spawnTimer + dt

	if spawnTimer >= spawnRate then
		spawnTimer = 0

		local bounds = particleLayer.AbsoluteSize
		local targetCount = calculateParticleCount(currentState)

		-- Spawn particles to reach target count
		if #activeParticles < targetCount then
			local toSpawn = math.min(3, targetCount - #activeParticles) -- Spawn up to 3 per tick
			for i = 1, toSpawn do
				spawnParticle(bounds)
			end
		end
	end
end

-- Decorative burst used for window open/close transitions
local function emitFlightBurst(options)
	if not TweenService then
		return
	end

	options = options or {}
	local layer = options.layer or particleLayer
	local boundsFrame = options.boundsFrame or layer

	if not layer or not layer.Parent or not boundsFrame or not boundsFrame.Parent then
		return
	end

	local palette = deps.Theme:Get()
	local absBoundsSize = boundsFrame.AbsoluteSize

	if absBoundsSize.X < 8 or absBoundsSize.Y < 8 then
		return
	end

	local layerOrigin = layer.AbsolutePosition
	local boundsOrigin = boundsFrame.AbsolutePosition

	local mode = options.mode or "expand"
	local count = options.count or (mode == "expand" and 14 or 10)
	local durationMin = options.durationMin or 0.85
	local durationMax = options.durationMax or 1.2
	local verticalTravel = absBoundsSize.Y * (mode == "collapse" and 0.35 or 0.55)

	if mode == "chip" then
		count = options.count or 8
		durationMin = options.durationMin or 0.7
		durationMax = options.durationMax or 1.05
		verticalTravel = absBoundsSize.Y * 0.6
	end

	for _ = 1, count do
		local bubble, gradient, stroke = createBurstBubble(palette, layer.ZIndex)

		local baseSize = math.random(9, 22)
		if mode == "expand" then
			baseSize = baseSize + math.random(-2, 6)
		else
			baseSize = baseSize + math.random(-4, 2)
		end

		local startX = boundsOrigin.X + math.random() * absBoundsSize.X
		local startY
		if mode == "collapse" then
			startY = boundsOrigin.Y + math.random() * (absBoundsSize.Y * 0.6)
		elseif mode == "chip" then
			startY = boundsOrigin.Y + math.random() * absBoundsSize.Y * 0.8
		else
			startY = boundsOrigin.Y + absBoundsSize.Y - math.random() * (absBoundsSize.Y * 0.25)
		end

		local relativeStartX = startX - layerOrigin.X
		local relativeStartY = startY - layerOrigin.Y

		bubble.Size = UDim2.fromOffset(baseSize, baseSize)
		bubble.Position = UDim2.fromOffset(relativeStartX, relativeStartY)
		bubble.BackgroundTransparency = 1
		bubble.Parent = layer

		local accent = palette.Accent or Color3.fromRGB(255, 255, 255)
		local secondary = palette.Secondary or accent
		local glow = palette.BorderGlow or accent

		if gradient then
			gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, accent),
				ColorSequenceKeypoint.new(1, lerpColor(accent, secondary, 0.4))
			})
			gradient.Rotation = math.random(0, 360)
		end

		if stroke then
			stroke.Thickness = baseSize <= 12 and 0.8 or (baseSize <= 18 and 1 or 1.35)
			stroke.Transparency = 0.15
			stroke.Color = lerpColor(accent, glow, 0.35)
		end

		local driftX = (math.random() - 0.5) * absBoundsSize.X * 0.18
		local driftY = -verticalTravel - math.random(28, 72)
		if mode == "collapse" then
			driftX = driftX * 0.6
			driftY = driftY * 0.7
		elseif mode == "chip" then
			driftX = driftX * 0.4
			driftY = driftY * 0.5
		end

		local endPosition = UDim2.fromOffset(relativeStartX + driftX, relativeStartY + driftY)
		local endSize
		if mode == "expand" then
			endSize = UDim2.fromOffset(baseSize * 1.2, baseSize * 1.4)
		elseif mode == "chip" then
			endSize = UDim2.fromOffset(baseSize * 1.05, baseSize * 1.15)
		else
			endSize = UDim2.fromOffset(baseSize * 1.2, baseSize * 1.15)
		end
		local motionDuration = math.random() * (durationMax - durationMin) + durationMin

		local fadeIn = TweenService:Create(bubble, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.35
		})

		local moveTween = TweenService:Create(bubble, TweenInfo.new(motionDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Position = endPosition,
			Size = endSize
		})

		local fadeOutDelay = motionDuration * 0.55
		local fadeOutDuration = motionDuration - fadeOutDelay

		local fadeOut = TweenService:Create(bubble, TweenInfo.new(fadeOutDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, fadeOutDelay), {
			BackgroundTransparency = 1
		})

		local strokeFade
		if stroke then
			strokeFade = TweenService:Create(stroke, TweenInfo.new(fadeOutDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, fadeOutDelay), {
				Transparency = 1
			})
		end

		fadeIn:Play()
		moveTween:Play()
		fadeOut:Play()
		if strokeFade then
			strokeFade:Play()
		end

		if gradient then
			local rotationTarget = gradient.Rotation + math.random(-35, 35)
			local rotationTween = TweenService:Create(gradient, TweenInfo.new(motionDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				Rotation = rotationTarget
			})
			rotationTween:Play()
		end

		moveTween.Completed:Connect(function()
			if bubble then
				bubble:Destroy()
			end
		end)
	end
end

-- Main update loop (RunService heartbeat)
local function onHeartbeat(dt)
	if not Config.Enabled or not isPlaying then return end

	spawnLoop(dt)
	updateParticles(dt)
end

-- Public API
function Particles:Initialize(dependencies)
	deps = dependencies
	TweenService = dependencies.TweenService or game:GetService("TweenService")
	initPerlin()

	if Config.DebugLog then
		print("[Particles] Initialized with Perlin noise")
	end
end

function Particles:SetLayer(layer)
	particleLayer = layer

	if Config.DebugLog then
		print("[Particles] Layer set:", layer and "active" or "nil")
	end
end

function Particles:EmitFlightBurst(options)
	emitFlightBurst(options)
end

function Particles:Play(state)
	if not Config.Enabled then return end

	currentState = state or "idle"
	isPlaying = true

	-- Start update loop if not already running
	if not updateConnection then
		updateConnection = deps.RunService.Heartbeat:Connect(onHeartbeat)
	end

	if Config.DebugLog then
		local count = calculateParticleCount(currentState)
		print(string.format("[Particles] Playing - State: %s | Target count: %d | FPS: %.1f",
			currentState, count, lastFPS))
	end
end

function Particles:Stop(fastFade)
	isPlaying = false

	-- Fast fade: reduce lifetime to trigger fade-out
	if fastFade then
		for _, data in ipairs(activeParticles) do
			data.lifetime = math.min(data.lifetime, data.age + data.fadeOutDuration)
		end
	end

	-- Clear all particles after fade
	task.delay(fastFade and 0.25 or 0, function()
		for i = #activeParticles, 1, -1 do
			releaseParticle(activeParticles[i].instance)
			table.remove(activeParticles, i)
		end
	end)

	if Config.DebugLog then
		print("[Particles] Stopped - Fast fade:", fastFade or false)
	end
end

function Particles:SetState(state)
	currentState = state or "idle"

	if Config.DebugLog then
		print("[Particles] State changed:", currentState)
	end
end

function Particles:SetConfig(key, value)
	if Config[key] ~= nil then
		Config[key] = value

		if Config.DebugLog then
			print("[Particles] Config updated:", key, "=", value)
		end
	end
end

function Particles:GetConfig(key)
	return Config[key]
end

function Particles:GetStats()
	return {
		activeCount = #activeParticles,
		pooledCount = #particlePool,
		fps = lastFPS,
		densityMultiplier = adaptiveDensityMultiplier,
		state = currentState,
		isPlaying = isPlaying
	}
end

return Particles
