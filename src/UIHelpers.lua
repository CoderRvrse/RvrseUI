-- =========================
-- RvrseUI UIHelpers Module
-- =========================
-- Helper functions for creating UI elements
-- Extracted from RvrseUI.lua (lines 919-1032)

local TweenService = game:GetService("TweenService")

local UIHelpers = {}

-- Convert string or EnumItem to KeyCode
function UIHelpers.coerceKeycode(k)
	if typeof(k) == "EnumItem" and k.EnumType == Enum.KeyCode then return k end
	if typeof(k) == "string" and #k > 0 then
		local up = k:upper():gsub("%s", "")
		if Enum.KeyCode[up] then return Enum.KeyCode[up] end
	end
	return Enum.KeyCode.K
end

-- Add UICorner to instance
function UIHelpers.corner(inst, r)
	local c = Instance.new("UICorner")
	if typeof(r) == "UDim" then
		c.CornerRadius = r
	elseif r == "pill" or r == "full" then
		c.CornerRadius = UDim.new(1, 0)
	elseif typeof(r) == "number" then
		c.CornerRadius = UDim.new(0, r)
	else
		c.CornerRadius = UDim.new(0, 12)
	end
	c.Parent = inst
	return c
end

-- Add UIStroke to instance
-- Theme parameter is optional - if provided, uses Theme:Get().Border as default color
function UIHelpers.stroke(inst, color, thickness, Theme)
	local s = Instance.new("UIStroke")
	if color then
		s.Color = color
	elseif Theme then
		s.Color = Theme:Get().Border
	else
		s.Color = Color3.fromRGB(45, 45, 55)  -- Fallback default
	end
	s.Thickness = thickness or 1.5  -- Increased from 1 to 1.5 for crispness
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.LineJoinMode = Enum.LineJoinMode.Round
	s.Parent = inst
	return s
end

-- Add UIGradient to instance
function UIHelpers.gradient(inst, rotation, colors)
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

-- Add UIPadding to instance
function UIHelpers.padding(inst, all)
	local p = Instance.new("UIPadding")
	local u = UDim.new(0, all or 12)
	p.PaddingTop = u
	p.PaddingBottom = u
	p.PaddingLeft = u
	p.PaddingRight = u
	p.Parent = inst
	return p
end

-- Add shadow effect using ImageLabel
function UIHelpers.shadow(inst, transparency, size)
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

-- Create tooltip for element
function UIHelpers.createTooltip(parent, text)
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
	UIHelpers.corner(tooltip, 6)

	local tooltipStroke = Instance.new("UIStroke")
	tooltipStroke.Color = Color3.fromRGB(60, 60, 70)
	tooltipStroke.Thickness = 1
	tooltipStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	tooltipStroke.LineJoinMode = Enum.LineJoinMode.Round
	tooltipStroke.Parent = tooltip

	return tooltip
end

-- Add glow effect to instance
function UIHelpers.addGlow(inst, color, intensity)
	-- Add glow effect using UIStroke
	local glow = Instance.new("UIStroke")
	glow.Name = "Glow"
	glow.Color = color or Color3.fromRGB(99, 102, 241)
	glow.Thickness = 0
	glow.Transparency = 0.5
	glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	glow.LineJoinMode = Enum.LineJoinMode.Round
	glow.Parent = inst

	-- Animate glow
	local glowTween = TweenService:Create(glow, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
		Thickness = intensity or 2,
		Transparency = 0.2
	})
	glowTween:Play()

	return glow
end

-- Add glass/gloss effect to cards and panels
function UIHelpers.addGloss(inst, Theme)
	local pal = Theme and Theme:Get() or {}

	-- Vertical gloss gradient overlay
	local gloss = Instance.new("Frame")
	gloss.Name = "Gloss"
	gloss.BackgroundTransparency = 1
	gloss.BorderSizePixel = 0
	gloss.Size = UDim2.new(1, 0, 0.5, 0)  -- Top half of panel
	gloss.Position = UDim2.new(0, 0, 0, 0)
	gloss.ZIndex = inst.ZIndex + 1
	gloss.Parent = inst

	local glossGradient = Instance.new("UIGradient")
	glossGradient.Rotation = 90  -- Vertical
	glossGradient.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.92),  -- Subtle highlight at top
		NumberSequenceKeypoint.new(1, 1)      -- Fade to transparent
	}
	glossGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, pal.GlossTop or Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, pal.GlossBottom or Color3.fromRGB(120, 120, 160))
	}
	glossGradient.Parent = gloss

	return gloss
end

-- Initialize method (called by init.lua)
function UIHelpers:Initialize(deps)
	-- UIHelpers is ready to use
	-- Dependencies (Animator, Theme, Icons, PlayerGui) are passed but not stored
	-- Helper functions are self-contained and don't need initialization
end

-- Put text on the player's clipboard, using whichever name their executor
-- gives the function.
--
-- Roblox cannot open a browser, so copying is the only way to hand somebody a
-- link they can actually follow. Every executor spells this differently and
-- some expose it only on getgenv(), so try the lot and report honestly whether
-- any of them worked -- a button that silently does nothing is worse than one
-- that says it could not.
function UIHelpers.copyText(text)
	if type(text) ~= "string" or text == "" then
		return false
	end
	-- Everywhere the function might live, in the order worth trying.
	--
	-- Read with plain indexing inside a pcall, NOT rawget: executors commonly
	-- serve these through a metatable on the script environment, and rawget
	-- walks straight past one -- which looks exactly like "this executor cannot
	-- copy" on an executor that can. getgenv/getfenv may not exist at all, so
	-- even fetching the environment is wrapped.
	local envs = {}
	local ok, env = pcall(function() return getgenv() end)
	if ok and type(env) == "table" then
		envs[#envs + 1] = env
	end
	ok, env = pcall(function() return getfenv(0) end)
	if ok and type(env) == "table" then
		envs[#envs + 1] = env
	end
	envs[#envs + 1] = _G

	for _, e in ipairs(envs) do
		for _, name in ipairs({ "setclipboard", "toclipboard", "set_clipboard" }) do
			local okRead, fn = pcall(function() return e[name] end)
			if okRead and type(fn) == "function" and pcall(fn, text) then
				return true
			end
		end
	end
	return false
end

return UIHelpers
