-- RvrseUI v3.0.4 | Modern Professional UI Framework
-- Compiled from modular architecture on 2025-10-10T12:08:05.701Z

-- Features: Glassmorphism, Spring Animations, Mobile-First Responsive, Touch-Optimized
-- API: CreateWindow → CreateTab → CreateSection → {All 12 Elements}
-- Extras: Notify system, Theme switcher, LockGroup system, Drag-to-move, Auto-scaling

-- 🏗️ ARCHITECTURE: This file is compiled from 26 modular files
-- Source: https://github.com/CoderRvrse/RvrseUI/tree/main/src
-- For modular version, use: require(script.init) instead of this file


local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")
local Mouse = LP:GetMouse()

local RvrseUI = {}


-- ========================
-- Version Module
-- ========================



Version.Data = {
	Major = 3,
	Minor = 0,
	Patch = 3,
	Build = "20251011",  -- YYYYMMDD format
	Full = "3.0.3",
	Hash = "N8P4Q6R2",  -- Release hash for integrity verification
	Channel = "Stable"   -- Stable, Beta, Dev
}

function Version:GetString()
	return string.format("v%s (%s)", self.Data.Full, self.Data.Build)
end

function Version:GetInfo()
	return {
		Version = self.Data.Full,
		Build = self.Data.Build,
		Hash = self.Data.Hash,
		Channel = self.Data.Channel,
		IsLatest = true  -- Will be checked against GitHub API in future
	}
end

function Version:Check(onlineVersion)
	-- Compare version with online version (for future update checker)
	if not onlineVersion then return "unknown" end
	local current = (self.Data.Major * 10000) + (self.Data.Minor * 100) + self.Data.Patch
	local online = (onlineVersion.Major * 10000) + (onlineVersion.Minor * 100) + onlineVersion.Patch
	if current < online then return "outdated"
	elseif current > online then return "ahead"
	else return "latest" end
end

setmetatable(Version, {
	__index = function(_, key)
		return Version.Data[key]
	end,
	__newindex = function(_, key, value)
		if Version.Data[key] ~= nil then
			Version.Data[key] = value
		else
			rawset(Version, key, value)
		end
	end
})


-- ========================
-- Debug Module
-- ========================



Debug.Enabled = true  -- Global debug toggle

function Debug:Print(...)
	if self.Enabled then
		print("[RvrseUI]", ...)
	end
end

Debug.Log = Debug.Print

function Debug.printf(fmt, ...)
	if not Debug.Enabled then
		return
	end

	if type(fmt) == "string" and select("#", ...) > 0 then
		local ok, message = pcall(string.format, fmt, ...)
		if ok then
			Debug:Print(message)
			return
		end
	end

	Debug:Print(fmt, ...)
end


-- ========================
-- Obfuscation Module
-- ========================



Obfuscation._seed = tick() * math.random(1, 999999)  -- Unique seed per session
Obfuscation._cache = {}  -- Cache generated names to avoid duplicates

local namePatterns = {
	-- Looks like internal Roblox systems
	{"_", "Core", "System", "Module", "Service", "Handler", "Manager", "Controller"},
	{"UI", "GUI", "Frame", "Panel", "Widget", "Component", "Element"},
	{"Test", "Debug", "Dev", "Internal", "Util", "Helper", "Proxy"},
	{"Data", "Config", "State", "Cache", "Buffer", "Queue", "Stack"},
	-- Technical suffixes
	{"Ref", "Impl", "Inst", "Obj", "Node", "Item", "Entry"},
	-- Random chars/numbers for uniqueness
	{"A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "L", "M", "N", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"},
	{"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}
}

function Obfuscation:GetRandom(category)
	local words = namePatterns[category]
	self._seed = (self._seed * 9301 + 49297) % 233280
	local index = math.floor((self._seed / 233280) * #words) + 1
	return words[index]
end

function Obfuscation:GetChar()
	return self:GetRandom(6)
end

function Obfuscation:GetNum()
	return self:GetRandom(7)
end

function Obfuscation:Generate(hint)
	-- Update seed for randomness
	self._seed = (self._seed * 9301 + 49297) % 233280
	local rand = self._seed / 233280

	-- Pick random pattern
	local patterns = {
		function() return "_" .. self:GetRandom(1) .. self:GetRandom(7) .. self:GetRandom(5) end,  -- _CoreTest3Ref
		function() return self:GetRandom(2) .. "_" .. self:GetRandom(2) .. self:GetRandom(5) .. self:GetNum() end,  -- UI_GUIObj5
		function() return "_" .. self:GetRandom(3) .. self:GetRandom(2) .. self:GetNum() .. self:GetChar() end,  -- _DevUI3A
		function() return self:GetRandom(4) .. self:GetRandom(2) .. "_" .. self:GetNum() .. self:GetChar() end,  -- DataUI_7K
		function() return "_" .. self:GetChar() .. self:GetNum() .. self:GetRandom(2) .. self:GetRandom(3) end,  -- _M4UIInternal
	}

	local name
	local attempts = 0
	repeat
		local pattern = patterns[math.floor(rand * #patterns) + 1]
		name = pattern()
		attempts = attempts + 1
		-- Update rand for next attempt
		self._seed = (self._seed * 9301 + 49297) % 233280
		rand = self._seed / 233280
	until (not self._cache[name]) or attempts > 10

	self._cache[name] = true
	return name
end

function Obfuscation:GenerateSet()
	return {
		host = self:Generate("host"),
		notifyRoot = self:Generate("notify"),
		window = self:Generate("window"),
		chip = self:Generate("chip"),
		badge = self:Generate("badge"),
		customHost = self:Generate("custom")
	}
end

function Obfuscation:Initialize()
	-- Reset seed and cache for new session
	self._seed = tick() * math.random(1, 999999)
	self._cache = {}
end

function Obfuscation.getObfuscatedName(hint)
	return Obfuscation:Generate(hint)
end

function Obfuscation.getObfuscatedNames()
	return Obfuscation:GenerateSet()
end


-- ========================
-- Icons Module
-- ========================



Icons.UnicodeIcons = {
	-- Navigation & UI
	["home"] = "🏠",
	["settings"] = "⚙",
	["menu"] = "☰",
	["search"] = "🔍",
	["info"] = "ℹ",
	["help"] = "❓",
	["close"] = "✕",
	["x"] = "✕",
	["check"] = "✓",
	["checkmark"] = "✓",

	-- Arrows
	["arrow-up"] = "↑",
	["arrow-down"] = "↓",
	["arrow-left"] = "←",
	["arrow-right"] = "→",
	["chevron-up"] = "▲",
	["chevron-down"] = "▼",
	["chevron-left"] = "◀",
	["chevron-right"] = "▶",
	["caret-up"] = "˄",
	["caret-down"] = "˅",

	-- Actions
	["plus"] = "+",
	["minus"] = "-",
	["add"] = "➕",
	["remove"] = "➖",
	["edit"] = "✎",
	["pencil"] = "✎",
	["trash"] = "🗑",
	["delete"] = "🗑",
	["save"] = "💾",
	["download"] = "⬇",
	["upload"] = "⬆",
	["refresh"] = "↻",
	["reload"] = "⟳",

	-- Media Controls
	["play"] = "▶",
	["pause"] = "⏸",
	["stop"] = "⏹",
	["skip-forward"] = "⏭",
	["skip-back"] = "⏮",
	["fast-forward"] = "⏩",
	["rewind"] = "⏪",
	["volume"] = "🔊",
	["volume-high"] = "🔊",
	["volume-low"] = "🔉",
	["volume-mute"] = "🔇",

	-- Status & Alerts
	["success"] = "✓",
	["error"] = "✕",
	["warning"] = "⚠",
	["alert"] = "⚠",
	["bell"] = "🔔",
	["notification"] = "🔔",
	["flag"] = "⚑",

	-- User & Social
	["user"] = "👤",
	["users"] = "👥",
	["profile"] = "👤",
	["team"] = "👥",
	["chat"] = "💬",
	["message"] = "✉",
	["mail"] = "✉",

	-- Security
	["lock"] = "🔒",
	["unlock"] = "🔓",
	["key"] = "🔑",
	["shield"] = "🛡",
	["verified"] = utf8.char(0xE000),  -- Roblox Verified
	["premium"] = utf8.char(0xE001),   -- Roblox Premium

	-- Currency & Economy
	["robux"] = utf8.char(0xE002),     -- Roblox Robux
	["dollar"] = "$",
	["coin"] = "🪙",
	["money"] = "💰",
	["diamond"] = "💎",
	["gem"] = "💎",

	-- Items & Objects
	["box"] = "📦",
	["package"] = "📦",
	["gift"] = "🎁",
	["shopping"] = "🛒",
	["cart"] = "🛒",
	["bag"] = "🎒",
	["backpack"] = "🎒",

	-- Files & Data
	["file"] = "📄",
	["folder"] = "📁",
	["document"] = "📄",
	["page"] = "📃",
	["clipboard"] = "📋",
	["link"] = "🔗",

	-- Tech & System
	["code"] = "⌨",
	["terminal"] = "⌨",
	["command"] = "⌘",
	["database"] = "🗄",
	["server"] = "🖥",
	["cpu"] = "⚙",
	["hard-drive"] = "💾",
	["wifi"] = "📶",
	["signal"] = "📶",
	["bluetooth"] = "🔵",
	["battery"] = "🔋",
	["power"] = "⚡",
	["plug"] = "🔌",

	-- Nature & Weather
	["sun"] = "☀",
	["moon"] = "🌙",
	["star"] = "⭐",
	["cloud"] = "☁",
	["rain"] = "🌧",
	["snow"] = "❄",
	["fire"] = "🔥",
	["water"] = "💧",
	["droplet"] = "💧",
	["wind"] = "💨",

	-- Emotions & Symbols
	["heart"] = "❤",
	["like"] = "👍",
	["dislike"] = "👎",
	["smile"] = "😊",
	["sad"] = "😢",
	["angry"] = "😠",

	-- Games & Activities
	["trophy"] = "🏆",
	["award"] = "🏅",
	["medal"] = "🏅",
	["target"] = "🎯",
	["crosshair"] = "⊕",
	["crown"] = "👑",
	["game"] = "🎮",
	["controller"] = "🎮",

	-- Combat & Weapons
	["sword"] = "⚔",
	["weapon"] = "⚔",
	["gun"] = "🔫",
	["bomb"] = "💣",
	["explosion"] = "💥",

	-- UI Elements
	["maximize"] = "⛶",
	["minimize"] = "⚊",
	["window"] = "❐",
	["grid"] = "▦",
	["list"] = "☰",
	["layout"] = "▦",
	["sliders"] = "🎚",
	["filter"] = "⚗",

	-- Misc
	["eye"] = "👁",
	["eye-open"] = "👁",
	["eye-closed"] = "⚊",
	["camera"] = "📷",
	["image"] = "🖼",
	["calendar"] = "📅",
	["clock"] = "🕐",
	["timer"] = "⏲",
	["hourglass"] = "⏳",
	["map"] = "🗺",
	["compass"] = "🧭",
	["pin"] = "📍",
	["location"] = "📍",
	["bookmark"] = "🔖",
	["tag"] = "🏷",
}

function Icons:Resolve(icon)
	-- If it's a number, it's a Roblox asset ID
	if typeof(icon) == "number" then
		return "rbxassetid://" .. icon, "image"
	end

	-- If it's a string
	if typeof(icon) == "string" then
		-- Check if it's a named icon from our Unicode library
		local iconName = icon:lower():gsub("icon://", "")
		if self.UnicodeIcons[iconName] then
			return self.UnicodeIcons[iconName], "text"
		end

		-- Check if it's already a rbxassetid
		if icon:match("^rbxassetid://") then
			return icon, "image"
		end

		-- Otherwise, treat as emoji/text (user provided)
		return icon, "text"
	end

	return nil, nil
end

function Icons:Initialize()
	-- Icons table is ready to use, no initialization needed
	-- UnicodeIcons are defined at module load time
end

function Icons.resolveIcon(icon)
	return Icons:Resolve(icon)
end


-- ========================
-- Theme Module
-- ========================



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
		-- Backgrounds - Clean, modern white with subtle depth
		Bg = Color3.fromRGB(245, 247, 250),        -- Soft blue-gray background
		Glass = Color3.fromRGB(255, 255, 255),     -- Pure white glass
		Card = Color3.fromRGB(252, 253, 255),      -- Slightly off-white cards
		Elevated = Color3.fromRGB(248, 250, 252),  -- Elevated elements

		-- Text - Strong contrast for readability
		Text = Color3.fromRGB(17, 24, 39),         -- Almost black, high contrast
		TextSub = Color3.fromRGB(75, 85, 99),      -- Medium gray for secondary
		TextMuted = Color3.fromRGB(156, 163, 175), -- Light gray for muted

		-- Accent - Vibrant indigo (matches Dark theme)
		Accent = Color3.fromRGB(99, 102, 241),     -- Bright indigo
		AccentHover = Color3.fromRGB(79, 70, 229), -- Deeper indigo on hover
		Success = Color3.fromRGB(16, 185, 129),    -- Bright green
		Warning = Color3.fromRGB(245, 158, 11),    -- Warm orange
		Error = Color3.fromRGB(239, 68, 68),       -- Bright red
		Info = Color3.fromRGB(59, 130, 246),       -- Sky blue

		-- Borders - Subtle but visible
		Border = Color3.fromRGB(209, 213, 219),    -- Clear gray borders
		Divider = Color3.fromRGB(229, 231, 235),   -- Lighter dividers

		-- Interactive states - Clear visual feedback
		Hover = Color3.fromRGB(243, 244, 246),     -- Light hover
		Active = Color3.fromRGB(229, 231, 235),    -- Pressed state
		Disabled = Color3.fromRGB(209, 213, 219),  -- Disabled gray
	}
}

Theme.Current = "Dark"
Theme._dirty = false  -- Dirty flag: true if user changed theme in-session
Theme._listeners = {}  -- Theme change listeners

function Theme:Get()
	return self.Palettes[self.Current]
end

function Theme:Apply(mode, Debug)
	if self.Palettes[mode] then
		self.Current = mode
		if Debug then
			Debug:Print("Theme applied:", mode)
		end
	end
end

function Theme:Switch(mode, Debug)
	if self.Palettes[mode] then
		self.Current = mode
		self._dirty = true  -- Mark dirty when user changes theme
		if Debug then
			Debug:Print("Theme switched (dirty=true):", mode)
		end
		-- Trigger theme refresh
		for _, fn in ipairs(self._listeners) do
			pcall(fn)
		end
	end
end

function Theme:RegisterListener(callback)
	table.insert(self._listeners, callback)
end

function Theme:ClearListeners()
	self._listeners = {}
end

function Theme:Initialize()
	-- Theme is ready to use, no initialization needed
	-- Palettes are defined at module load time
end


-- ========================
-- Animator Module
-- ========================

local TweenService = game:GetService("TweenService")



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
	return self:Tween(obj, {Size = UDim2.new(scale, 0, scale, 0)}, info or self.Spring.Snappy)
end

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

function Animator:Initialize(tweenService)
	-- Animator is ready to use
	-- TweenService is already imported at module level (line 7)
	-- Spring presets are defined at module load time
end


-- ========================
-- State Module
-- ========================



State.Flags = {}

State.Locks = {
	_locks = {},
	_listeners = {}
}

function State:SetLocked(group, isLocked)
	return self.Locks:SetLocked(group, isLocked)
end

function State:IsLocked(group)
	return self.Locks:IsLocked(group)
end

function State:RegisterLockListener(callback)
	return self.Locks:RegisterListener(callback)
end

function State:ClearLockListeners()
	return self.Locks:ClearListeners()
end

function State.Locks:SetLocked(group, isLocked)
	if not group then return end
	self._locks[group] = isLocked and true or false
	-- Trigger all lock listeners
	for _, fn in ipairs(self._listeners) do
		pcall(fn)
	end
end

function State.Locks:IsLocked(group)
	return group and self._locks[group] == true
end

function State.Locks:RegisterListener(callback)
	table.insert(self._listeners, callback)
end

function State.Locks:ClearListeners()
	self._listeners = {}
end

function State:Initialize()
	-- State is ready to use, no initialization needed
	-- Flags and Locks are defined at module load time
end


-- ========================
-- UIHelpers Module
-- ========================

local TweenService = game:GetService("TweenService")



function UIHelpers.coerceKeycode(k)
	if typeof(k) == "EnumItem" and k.EnumType == Enum.KeyCode then return k end
	if typeof(k) == "string" and #k > 0 then
		local up = k:upper():gsub("%s", "")
		if Enum.KeyCode[up] then return Enum.KeyCode[up] end
	end
	return Enum.KeyCode.K
end

function UIHelpers.corner(inst, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 12)
	c.Parent = inst
	return c
end

function UIHelpers.stroke(inst, color, thickness, Theme)
	local s = Instance.new("UIStroke")
	if color then
		s.Color = color
	elseif Theme then
		s.Color = Theme:Get().Border
	else
		s.Color = Color3.fromRGB(45, 45, 55)  -- Fallback default
	end
	s.Thickness = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = inst
	return s
end

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
	tooltipStroke.Parent = tooltip

	return tooltip
end

function UIHelpers.addGlow(inst, color, intensity)
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

function UIHelpers:Initialize(deps)
	-- UIHelpers is ready to use
	-- Dependencies (Animator, Theme, Icons, PlayerGui) are passed but not stored
	-- Helper functions are self-contained and don't need initialization
end


-- ========================
-- Config Module
-- ========================



local State = nil
local Theme = nil
local dprintf = nil

local HttpService = game:GetService("HttpService")


Config.ConfigurationSaving = false  -- Enabled via CreateWindow
Config.ConfigurationFileName = nil  -- Set via CreateWindow
Config.ConfigurationFolderName = nil  -- Optional folder name
Config._configCache = {}  -- In-memory config cache
Config._lastSaveTime = nil  -- Debounce timestamp
Config._lastContext = nil  -- Most recent RvrseUI instance used for persistence
Config.AutoSaveEnabled = true  -- Auto-save flag (can be disabled via configuration)


local FileApi = {
	readfile = type(readfile) == "function" and readfile or nil,
	writefile = type(writefile) == "function" and writefile or nil,
	isfile = type(isfile) == "function" and isfile or nil,
	isfolder = type(isfolder) == "function" and isfolder or nil,
	makefolder = type(makefolder) == "function" and makefolder or nil,
	delfile = type(delfile) == "function" and delfile or nil,
	listfiles = type(listfiles) == "function" and listfiles or nil
}

local function fsCall(name, ...)
	local fn = FileApi[name]
	if not fn then
		return false, string.format("%s unavailable in this executor", name)
	end

	local ok, result = pcall(fn, ...)
	if not ok then
		return false, result
	end
	return true, result
end

local function fsSupports(name)
	return FileApi[name] ~= nil
end

local function traceFsSupport(tag)
	if not dprintf then
		return
	end

	dprintf(string.format(
		"[FS] %s support | readfile:%s writefile:%s isfile:%s isfolder:%s makefolder:%s",
		tag,
		fsSupports("readfile") and "✅" or "⛔",
		fsSupports("writefile") and "✅" or "⛔",
		fsSupports("isfile") and "✅" or "⛔",
		fsSupports("isfolder") and "✅" or "⛔",
		fsSupports("makefolder") and "✅" or "⛔"
	))
end

local function trim(str)
	return (str:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function normalizeProfileName(name)
	if not name then return nil end
	local trimmed = trim(tostring(name))
	if trimmed == "" then return nil end
	trimmed = trimmed:gsub("[\\/:*?\"<>|]", "_")
	trimmed = trimmed:gsub("%.json$", "")
	return trimmed
end

local function ensureFolderExists(folder)
	if not folder or folder == "" then
		return
	end
	if fsSupports("isfolder") then
		local existsOk, existsOrErr = fsCall("isfolder", folder)
		if existsOk and not existsOrErr and fsSupports("makefolder") then
			fsCall("makefolder", folder)
		end
	end
end

local function contains(list, value)
	for _, v in ipairs(list) do
		if v == value then
			return true
		end
	end
	return false
end

local function resolveFullPath(folder, fileName)
	if folder and folder ~= "" then
		return folder .. "/" .. fileName
	end
	return fileName
end


function Config:Init(dependencies)
	State = dependencies.State
	Theme = dependencies.Theme
	dprintf = dependencies.dprintf or function() end
	self._lastContext = nil
	self.AutoSaveEnabled = true

	traceFsSupport("Init")

	return self
end


function Config:SaveConfiguration(context)
	if context ~= nil then
		self._lastContext = context
	elseif self._lastContext then
		context = self._lastContext
	end

	if not self.ConfigurationSaving or not self.ConfigurationFileName then
		return false, "Configuration saving not enabled"
	end

	if not (fsSupports("writefile") and fsSupports("readfile")) then
		if dprintf then
			dprintf("[FS] Save aborted - writefile/readfile unavailable")
		end
		return false, "Executor does not expose writefile/readfile"
	end

	local config = {}

	local flagSource = {}
	if context and context.Flags then
		flagSource = context.Flags
	elseif State and State.Flags then
		flagSource = State.Flags
	end

	for flagName, element in pairs(flagSource) do
		if element.Get then
			local success, value = pcall(element.Get, element)
			if success then
				config[flagName] = value
			end
		end
	end

	dprintf("=== THEME SAVE DEBUG ===")
	dprintf("Theme exists?", Theme ~= nil)
	if Theme then
		dprintf("Theme.Current:", Theme.Current)
		dprintf("Theme._dirty:", Theme._dirty)
	end

	if Theme and Theme.Current and Theme._dirty then
		config._RvrseUI_Theme = Theme.Current
		dprintf("✅ Saved theme to config (dirty):", config._RvrseUI_Theme)
		Theme._dirty = false
	else
		dprintf("Theme not saved (not dirty or unavailable)")
		if self._configCache and self._configCache._RvrseUI_Theme then
			config._RvrseUI_Theme = self._configCache._RvrseUI_Theme
			dprintf("Preserving existing saved theme:", config._RvrseUI_Theme)
		end
	end

	self._configCache = config
	local configKeys = {}
	for k in pairs(config) do table.insert(configKeys, k) end
	dprintf("Config keys being saved:", table.concat(configKeys, ", "))

	local fullPath = self.ConfigurationFileName
	if self.ConfigurationFolderName then
		if fsSupports("isfolder") then
			local existsOk, existsOrErr = fsCall("isfolder", self.ConfigurationFolderName)
			if existsOk then
				if not existsOrErr and fsSupports("makefolder") then
					local createOk, createErr = fsCall("makefolder", self.ConfigurationFolderName)
					if not createOk and dprintf then
						dprintf("[FS] makefolder failed:", createErr)
					end
				end
			elseif dprintf then
				dprintf("[FS] isfolder failed:", existsOrErr)
			end
		elseif dprintf then
			dprintf("[FS] isfolder unavailable - skipping folder creation probe")
		end
		fullPath = self.ConfigurationFolderName .. "/" .. self.ConfigurationFileName
	end

	dprintf("?? SAVE VERIFICATION")
	dprintf("SAVE PATH:", fullPath)
	dprintf("SAVE KEY: _RvrseUI_Theme =", config._RvrseUI_Theme or "nil")
	dprintf("CONFIG INSTANCE:", tostring(self))

	local success, err = pcall(function()
		local jsonData = HttpService:JSONEncode(config)
		FileApi.writefile(fullPath, jsonData)
	end)

	if success then
		if fsSupports("readfile") then
			local readOk, rawOrErr = fsCall("readfile", fullPath)
			if readOk and rawOrErr then
				local decodeOk, readbackData = pcall(HttpService.JSONDecode, HttpService, rawOrErr)
				if decodeOk and typeof(readbackData) == "table" then
					dprintf("READBACK AFTER SAVE: _RvrseUI_Theme =", readbackData._RvrseUI_Theme or "nil")
					if readbackData._RvrseUI_Theme ~= config._RvrseUI_Theme then
						warn("?? READBACK MISMATCH! Expected:", config._RvrseUI_Theme, "Got:", readbackData._RvrseUI_Theme)
					end
				elseif dprintf then
					dprintf("[FS] Readback decode failed:", readbackData)
				end
			elseif dprintf then
				dprintf("[FS] Readback skipped:", rawOrErr)
			end
		elseif dprintf then
			dprintf("[FS] Readback skipped - readfile unavailable")
		end

		self:SaveLastConfig(fullPath, config._RvrseUI_Theme or "Dark")

		dprintf("Configuration saved:", self.ConfigurationFileName)
		return true, "Configuration saved successfully"
	else
		warn("[RvrseUI] Failed to save configuration:", err)
		return false, err
	end
end


function Config:LoadConfiguration(context)
	if context ~= nil then
		self._lastContext = context
	elseif self._lastContext then
		context = self._lastContext
	end

	if not self.ConfigurationSaving or not self.ConfigurationFileName then
		return false, "Configuration saving not enabled"
	end

	-- Build full file path with optional folder
	local fullPath = self.ConfigurationFileName
	if self.ConfigurationFolderName then
		fullPath = self.ConfigurationFolderName .. "/" .. self.ConfigurationFileName
	end

	-- GPT-5 VERIFICATION: Print load path and instance FIRST
	dprintf("🔍 LOAD VERIFICATION")
	dprintf("LOAD PATH:", fullPath)
	dprintf("CONFIG INSTANCE:", tostring(self))

	if not fsSupports("readfile") then
		if dprintf then
			dprintf("[FS] Load aborted - readfile unavailable")
		end
		return false, "Executor does not expose readfile"
	end

	if fsSupports("isfile") then
		local existsOk, existsOrErr = fsCall("isfile", fullPath)
		if not existsOk then
			dprintf("File existence check failed:", existsOrErr)
			return false, existsOrErr
		end
		if not existsOrErr then
			dprintf("No configuration to load or error:", existsOrErr)
			dprintf("VALUE AT LOAD: nil (no file)")
			return false, "No saved configuration found"
		end
	end

	local readOk, rawOrErr = fsCall("readfile", fullPath)
	if not readOk then
		dprintf("Read failed:", rawOrErr)
		return false, rawOrErr
	end

	local decodeOk, result = pcall(HttpService.JSONDecode, HttpService, rawOrErr)
	if not decodeOk then
		dprintf("JSON decode failed:", result)
		return false, result
	end

	-- GPT-5 VERIFICATION: Print the actual value loaded from disk
	dprintf("VALUE AT LOAD: _RvrseUI_Theme =", result._RvrseUI_Theme or "nil")

	-- Apply configuration to all flagged elements
	dprintf("=== THEME LOAD DEBUG ===")
	dprintf("Config loaded, checking for _RvrseUI_Theme...")

	local loadedCount = 0
	local flagSource = {}
	if context and context.Flags then
		flagSource = context.Flags
	elseif State and State.Flags then
		flagSource = State.Flags
	end

	for flagName, value in pairs(result) do
		-- Skip internal RvrseUI settings (start with _RvrseUI_)
		if flagName:sub(1, 9) == "_RvrseUI_" then
			dprintf("Found internal setting:", flagName, "=", value)
			-- Handle theme loading
			if flagName == "_RvrseUI_Theme" and (value == "Dark" or value == "Light") then
				-- Store theme to apply when window is created
				if context then
					context._savedTheme = value
					dprintf("✅ Saved theme found and stored:", value)
					dprintf("context._savedTheme is now:", context._savedTheme)
				else
					State._savedTheme = value
					dprintf("✅ Saved theme stored on State:", value)
					dprintf("State._savedTheme is now:", State._savedTheme)
				end
			end
		elseif flagSource[flagName] and flagSource[flagName].Set then
			local setSuccess = pcall(flagSource[flagName].Set, flagSource[flagName], value)
			if setSuccess then
				loadedCount = loadedCount + 1
			end
		end
	end

	self._configCache = result
	dprintf(string.format("Configuration loaded: %d elements restored", loadedCount))

	return true, string.format("Loaded %d elements", loadedCount)
end


function Config:_autoSave()
	if self.ConfigurationSaving and self.AutoSaveEnabled then
		-- Debounce saves (max once per second)
		if not self._lastSaveTime or (tick() - self._lastSaveTime) > 1 then
			self._lastSaveTime = tick()
			task.spawn(function()
				self:SaveConfiguration(self._lastContext)
			end)
		end
	end
end

function Config:SetAutoSave(enabled)
	self.AutoSaveEnabled = enabled ~= false
	return self.AutoSaveEnabled
end


function Config:DeleteConfiguration()
	if not self.ConfigurationFileName then
		return false, "No configuration file specified"
	end

	-- Build full file path with optional folder
	local fullPath = self.ConfigurationFileName
	if self.ConfigurationFolderName then
		fullPath = self.ConfigurationFolderName .. "/" .. self.ConfigurationFileName
	end
	if not (fsSupports("isfile") and fsSupports("delfile")) then
		return false, "Executor does not expose isfile/delfile"
	end

	local existsOk, existsOrErr = fsCall("isfile", fullPath)
	if not existsOk then
		return false, existsOrErr
	end
	if not existsOrErr then
		return false, "Configuration file not found"
	end

	local deleteOk, deleteErr = fsCall("delfile", fullPath)
	if deleteOk then
		self._configCache = {}
		return true, "Configuration deleted"
	else
		return false, deleteErr
	end
end


function Config:ConfigurationExists()
	if not self.ConfigurationFileName then
		return false
	end

	-- Build full file path with optional folder
	local fullPath = self.ConfigurationFileName
	if self.ConfigurationFolderName then
		fullPath = self.ConfigurationFolderName .. "/" .. self.ConfigurationFileName
	end

	if not fsSupports("isfile") then
		return false
	end

	local existsOk, existsOrErr = fsCall("isfile", fullPath)
	return existsOk and existsOrErr or false
end


function Config:GetLastConfig()
	local lastConfigPath = "RvrseUI/_last_config.json"

	if not (fsSupports("isfile") and fsSupports("readfile")) then
		dprintf("[FS] Last config probe skipped - filesystem unavailable")
		return nil, nil
	end

	local existsOk, existsOrErr = fsCall("isfile", lastConfigPath)
	if not existsOk then
		dprintf("Last config isfile failed:", existsOrErr)
		return nil, nil
	end
	if not existsOrErr then
		dprintf("📂 No last config found")
		return nil, nil
	end

	local readOk, rawOrErr = fsCall("readfile", lastConfigPath)
	if not readOk then
		dprintf("Last config read failed:", rawOrErr)
		return nil, nil
	end

	local decodeOk, data = pcall(HttpService.JSONDecode, HttpService, rawOrErr)
	if decodeOk and data then
		dprintf("📂 Last config found:", data.lastConfig, "Theme:", data.lastTheme)
		return data.lastConfig, data.lastTheme
	end

	dprintf("📂 No last config found")
	return nil, nil
end


function Config:SaveLastConfig(configName, theme)
	local lastConfigPath = "RvrseUI/_last_config.json"

	if fsSupports("isfolder") and fsSupports("makefolder") then
		local existsOk, existsOrErr = fsCall("isfolder", "RvrseUI")
		if existsOk and not existsOrErr then
			fsCall("makefolder", "RvrseUI")
		elseif not existsOk and dprintf then
			dprintf("[FS] isfolder('RvrseUI') failed:", existsOrErr)
		end
	elseif dprintf then
		dprintf("[FS] Skipping folder ensure - isfolder/makefolder unavailable")
	end

	if not fsSupports("writefile") then
		return false
	end

	local data = {
		lastConfig = configName,
		lastTheme = theme,
		timestamp = os.time()
	}

	local writeOk, writeErr = fsCall("writefile", lastConfigPath, HttpService:JSONEncode(data))

	if writeOk then
		dprintf("📂 Saved last config reference:", configName, "Theme:", theme)
	else
		warn("[RvrseUI] Failed to save last config:", writeErr)
	end

	return writeOk
end


function Config:LoadConfigByName(configName, context)
	if not configName or configName == "" then
		return false, "Config name required"
	end

	local profileName = normalizeProfileName(configName)
	if not profileName then
		return false, "Config name required"
	end

	local originalFileName = self.ConfigurationFileName
	local originalFolderName = self.ConfigurationFolderName

	self.ConfigurationFileName = profileName .. ".json"
	self.ConfigurationFolderName = originalFolderName or "RvrseUI/Configs"

	local success, message = self:LoadConfiguration(context or self._lastContext)

	-- Restore original config names
	self.ConfigurationFileName = originalFileName
	self.ConfigurationFolderName = originalFolderName

	return success, message
end


function Config:SaveConfigAs(configName, context)
	if not configName or configName == "" then
		return false, "Config name required"
	end

	local profileName = normalizeProfileName(configName)
	if not profileName then
		return false, "Config name required"
	end

	local originalFileName = self.ConfigurationFileName
	local originalFolderName = self.ConfigurationFolderName

	self.ConfigurationFileName = profileName .. ".json"
	self.ConfigurationFolderName = originalFolderName or "RvrseUI/Configs"

	ensureFolderExists(self.ConfigurationFolderName)

	local success, message = self:SaveConfiguration(context or self._lastContext)

	if success then
		-- Save this as the last used config
		self:SaveLastConfig(
			self.ConfigurationFolderName .. "/" .. self.ConfigurationFileName,
			Theme and Theme.Current or "Dark"
		)
	end

	-- Restore original config names
	self.ConfigurationFileName = originalFileName
	self.ConfigurationFolderName = originalFolderName

	return success, message
end


function Config:ListProfiles()
	local profiles = {}
	local warning = nil

	if not self.ConfigurationFolderName or self.ConfigurationFolderName == "" then
		if self.ConfigurationFileName then
			table.insert(profiles, self.ConfigurationFileName)
		end
		return profiles
	end

	if not fsSupports("listfiles") then
		warning = "Executor does not expose listfiles"
		if self.ConfigurationFileName then
			table.insert(profiles, self.ConfigurationFileName)
		end
		return profiles, warning
	end

	ensureFolderExists(self.ConfigurationFolderName)
	local listOk, entries = fsCall("listfiles", self.ConfigurationFolderName)
	if listOk and type(entries) == "table" then
		for _, raw in ipairs(entries) do
			local name = raw:match("([^/\\]+)$")
			if name and name:sub(-5) == ".json" then
				table.insert(profiles, name)
			end
		end
	else
		warning = entries
	end

	if self.ConfigurationFileName and not contains(profiles, self.ConfigurationFileName) then
		table.insert(profiles, self.ConfigurationFileName)
	end

	table.sort(profiles)
	return profiles, warning
end


function Config:SetConfigProfile(context, profileName)
	local normalized = normalizeProfileName(profileName)
	if not normalized then
		return false, "Profile name required"
	end

	local folder = self.ConfigurationFolderName or "RvrseUI/Configs"
	ensureFolderExists(folder)

	self.ConfigurationSaving = true
	self.ConfigurationFolderName = folder
	self.ConfigurationFileName = normalized .. ".json"

	if context then
		self._lastContext = context
		context.ConfigurationSaving = true
		context.ConfigurationFolderName = folder
		context.ConfigurationFileName = self.ConfigurationFileName
		context.AutoSaveEnabled = self.AutoSaveEnabled
	end

	self:SaveLastConfig(
		resolveFullPath(folder, self.ConfigurationFileName),
		Theme and Theme.Current or "Dark"
	)

	return true, self.ConfigurationFileName
end


function Config:DeleteProfile(profileName)
	local normalized = normalizeProfileName(profileName)
	if not normalized then
		return false, "Profile name required"
	end

	local fileName = normalized .. ".json"
	local folder = self.ConfigurationFolderName
	local fullPath = resolveFullPath(folder, fileName)

	if not (fsSupports("isfile") and fsSupports("delfile")) then
		return false, "Executor does not expose isfile/delfile"
	end

	local existsOk, existsOrErr = fsCall("isfile", fullPath)
	if not existsOk then
		return false, existsOrErr
	end
	if not existsOrErr then
		return false, "Profile not found"
	end

	local deleteOk, deleteErr = fsCall("delfile", fullPath)
	if not deleteOk then
		return false, deleteErr
	end

	if self.ConfigurationFileName == fileName then
		self.ConfigurationFileName = nil
	end

	return true, "Profile deleted"
end


-- ========================
-- WindowManager Module
-- ========================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")



function WindowManager:Init(obfuscatedNames)
	self._host = nil
	self._windows = {}
	self._obfuscatedNames = obfuscatedNames

	-- Create root ScreenGui host
	self:CreateHost()

	return self._host
end

function WindowManager:CreateHost()
	local host = Instance.new("ScreenGui")
	host.Name = self._obfuscatedNames.host  -- Dynamic obfuscation: Changes every launch
	host.ResetOnSpawn = false
	host.IgnoreGuiInset = false  -- CRITICAL: false to respect topbar, prevents offset
	host.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	host.DisplayOrder = 999999999  -- Maximum DisplayOrder to stay on top of everything

	-- Try to parent to CoreGui (requires permission), fallback to PlayerGui
	local success = pcall(function()
		host.Parent = CoreGui
	end)

	if not success then
		warn("[RvrseUI] No CoreGui access, using PlayerGui (may render under some Roblox UI)")
		host.Parent = PlayerGui
	else
		print("[RvrseUI] Successfully mounted to CoreGui - guaranteed on top!")
	end

	-- Store global reference for destruction and visibility control
	self._host = host

	return host
end

function WindowManager:RegisterWindow(window)
	table.insert(self._windows, window)
end

function WindowManager:Destroy()
	if self._host and self._host.Parent then
		-- Fade out animation for all windows
		for _, window in pairs(self._windows) do
			if window and window.Destroy then
				pcall(function() window:Destroy() end)
			end
		end

		-- Wait for animations
		task.wait(0.3)

		-- Destroy host
		self._host:Destroy()

		-- Clear all references
		table.clear(self._windows)

		print("[RvrseUI] All interfaces destroyed - No trace remaining")
		return true
	end
	return false
end

function WindowManager:ToggleVisibility()
	if self._host and self._host.Parent then
		self._host.Enabled = not self._host.Enabled
		return self._host.Enabled
	end
	return false
end

function WindowManager:SetVisibility(visible)
	if self._host and self._host.Parent then
		self._host.Enabled = visible
		return true
	end
	return false
end

function WindowManager:GetHost()
	return self._host
end

function WindowManager:GetWindows()
	return self._windows
end

function WindowManager:ClearListeners(lockListeners, themeListeners, toggleTargets)
	if toggleTargets then
		table.clear(toggleTargets)
	end
	if lockListeners then
		table.clear(lockListeners)
	end
	if themeListeners then
		table.clear(themeListeners)
	end
end

function WindowManager:Initialize()
	-- WindowManager is ready to use
	-- _host and _windows will be set when CreateHost is called
end


-- ========================
-- Hotkeys Module
-- ========================

local UIS = game:GetService("UserInputService")


Hotkeys.UI = {
	_toggleTargets = {},
	_windowData = {},
	_key = Enum.KeyCode.K,
	_escapeKey = Enum.KeyCode.Escape
}
Hotkeys._initialized = false

local function coerceKeycode(k)
	if typeof(k) == "EnumItem" and k.EnumType == Enum.KeyCode then return k end
	if typeof(k) == "string" and #k > 0 then
		local up = k:upper():gsub("%s", "")
		if Enum.KeyCode[up] then return Enum.KeyCode[up] end
	end
	return Enum.KeyCode.K
end

function Hotkeys.UI:RegisterToggleTarget(frame, windowData)
	self._toggleTargets[frame] = true
	if windowData then
		self._windowData[frame] = windowData
	end
end

function Hotkeys.UI:BindToggleKey(key)
	self._key = coerceKeycode(key or "K")
end

function Hotkeys.UI:BindEscapeKey(key)
	self._escapeKey = coerceKeycode(key or "Escape")
end

function Hotkeys:RegisterToggleTarget(frame, windowData)
	return self.UI:RegisterToggleTarget(frame, windowData)
end

function Hotkeys:BindToggleKey(key)
	return self.UI:BindToggleKey(key)
end

function Hotkeys:BindEscapeKey(key)
	return self.UI:BindEscapeKey(key)
end

local function handleToggle(self)
	print("\n========== [HOTKEY DEBUG] ==========")
	print("[HOTKEY] Toggle key processed:", self.UI._key.Name)

	for f in pairs(self.UI._toggleTargets) do
		if f and f.Parent then
			local windowData = self.UI._windowData and self.UI._windowData[f]
			print("[HOTKEY] Window found:", f.Name)
			print("[HOTKEY] Has windowData:", windowData ~= nil)

			if windowData then
				print("[HOTKEY] Has isMinimized function:", windowData.isMinimized ~= nil)
				print("[HOTKEY] Has minimizeFunction:", windowData.minimizeFunction ~= nil)
				print("[HOTKEY] Has restoreFunction:", windowData.restoreFunction ~= nil)
			end

			if windowData and windowData.isMinimized then
				local minimized
				if type(windowData.isMinimized) == "function" then
					minimized = windowData.isMinimized()
				else
					minimized = (windowData.isMinimized == true)
				end

				print("[HOTKEY] Current state - isMinimized:", minimized, "| f.Visible:", f.Visible)

				if minimized == true then
					print("[HOTKEY] ✅ ACTION: RESTORE (chip → full window)")
					if windowData.restoreFunction then
						windowData.restoreFunction()
					else
						print("[HOTKEY] ❌ ERROR: restoreFunction missing!")
					end
				else
					if f.Visible then
						print("[HOTKEY] ✅ ACTION: MINIMIZE (full window → chip)")
						if windowData.minimizeFunction then
							windowData.minimizeFunction()
						else
							print("[HOTKEY] ❌ ERROR: minimizeFunction missing!")
						end
					else
						print("[HOTKEY] ✅ ACTION: SHOW (hidden → visible)")
						f.Visible = true
					end
				end
			else
				print("[HOTKEY] ⚠️ No minimize tracking - using simple toggle")
				f.Visible = not f.Visible
			end
		end
	end
	print("========================================\n")
end

function Hotkeys:ToggleAllWindows()
	handleToggle(self)
end

function Hotkeys:Init()
	if self._initialized then
		return
	end
	self._initialized = true

	UIS.InputBegan:Connect(function(io, gpe)
		if gpe then return end

		-- ESC KEY: DESTROY the UI completely
		if io.KeyCode == self.UI._escapeKey then
			print("\n========== [DESTROY KEY] ==========")
			print("[DESTROY] Escape key pressed - destroying UI")

			for f in pairs(self.UI._toggleTargets) do
				if f and f.Parent then
					local windowData = self.UI._windowData and self.UI._windowData[f]
					if windowData and windowData.destroyFunction then
						print("[DESTROY] Calling destroy function")
						windowData.destroyFunction()
					else
						print("[DESTROY] No destroy function - hiding UI")
						f.Visible = false
					end
				end
			end
			print("========================================\n")
			return
		end

		-- TOGGLE KEY: Toggle/Minimize the UI
		if io.KeyCode == self.UI._key then
			handleToggle(self)
		end
	end)
end

function Hotkeys:Initialize(deps)
	-- Hotkeys system is ready to use
	-- deps contains: UserInputService, WindowManager
	-- Input listeners are set up when BindToggleKey is called
	self:Init()
end


-- ========================
-- Notifications Module
-- ========================



local corner, stroke

local Theme, Animator, host

local notifyRoot
local RvrseUI -- Reference to main RvrseUI table for NotificationsEnabled flag

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
		stroke = strokeFn
	})
end

function Notifications:SetContext(rvrseUI)
	RvrseUI = rvrseUI
end


-- ========================
-- Button Module
-- ========================



function Button.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local pal3 = dependencies.pal3
	local UIS = dependencies.UIS
	local Animator = dependencies.Animator
	local RvrseUI = dependencies.RvrseUI

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

	local currentText = btn.Text

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

	local buttonAPI = {
		SetText = function(_, txt)
			btn.Text = txt
			currentText = txt
		end,
		SetVisible = function(_, visible)
			f.Visible = visible
		end,
		CurrentValue = currentText
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = buttonAPI
	end

	return buttonAPI
end


-- ========================
-- Toggle Module
-- ========================



function Toggle.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local corner = dependencies.corner
	local shadow = dependencies.shadow
	local pal3 = dependencies.pal3
	local Animator = dependencies.Animator
	local RvrseUI = dependencies.RvrseUI

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
			if o.Flag then RvrseUI:_autoSave() end  -- Auto-save on change
		end
	end)

	table.insert(RvrseUI._lockListeners, visual)

	local toggleAPI = {
		Set = function(_, v)
			state = v and true or false
			visual()
			if controlsGroup then
				RvrseUI.Store:SetLocked(controlsGroup, state)
			end
		end,
		Get = function() return state end,
		Refresh = visual,
		SetVisible = function(_, visible)
			f.Visible = visible
		end,
		CurrentValue = state
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = toggleAPI
	end

	return toggleAPI
end


-- ========================
-- Dropdown Module
-- ========================



function Dropdown.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local corner = dependencies.corner
	local stroke = dependencies.stroke
	local shadow = dependencies.shadow
	local pal3 = dependencies.pal3
	local Animator = dependencies.Animator
	local RvrseUI = dependencies.RvrseUI
	local UIS = dependencies.UIS
	local OverlayLayer = dependencies.OverlayLayer

	-- Settings
	local values = {}
	for _, v in ipairs(o.Values or {}) do
		table.insert(values, v)
	end

	local maxHeight = o.MaxHeight or 160
	local itemHeight = 32
	local placeholder = o.PlaceholderText or "Select"
	local useOverlay = OverlayLayer ~= nil and o.Overlay ~= false

	-- Base card
	local f = card(48)
	f.ClipsDescendants = false

	-- Label
	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, -140, 1, 0)
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = pal3.Text
	lbl.Text = o.Text or "Dropdown"
	lbl.Parent = f

	-- Trigger button
	local btn = Instance.new("TextButton")
	btn.AnchorPoint = Vector2.new(1, 0.5)
	btn.Position = UDim2.new(1, -6, 0.5, 0)
	btn.Size = UDim2.new(0, 130, 0, 32)
	btn.BackgroundColor3 = pal3.Card
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 13
	btn.TextColor3 = pal3.Text
	btn.AutoButtonColor = false
	btn.ZIndex = 2
	btn.Parent = f
	corner(btn, 8)
	stroke(btn, pal3.Border, 1)

	local arrow = Instance.new("TextLabel")
	arrow.BackgroundTransparency = 1
	arrow.AnchorPoint = Vector2.new(1, 0.5)
	arrow.Position = UDim2.new(1, -8, 0.5, 0)
	arrow.Size = UDim2.new(0, 16, 0, 16)
	arrow.Font = Enum.Font.GothamBold
	arrow.TextSize = 12
	arrow.TextColor3 = pal3.TextSub
	arrow.Text = "▼"
	arrow.ZIndex = 3
	arrow.Parent = btn

	-- Dropdown list container
	local dropdownList = Instance.new("Frame")
	dropdownList.Name = "DropdownList"
	dropdownList.BackgroundColor3 = pal3.Elevated
	dropdownList.BorderSizePixel = 0
	dropdownList.Position = UDim2.new(1, -(btn.Size.X.Offset + 6), 0.5, 40)
	dropdownList.Size = UDim2.new(0, btn.Size.X.Offset, 0, 0)
	dropdownList.Visible = false
	dropdownList.ZIndex = 100
	dropdownList.ClipsDescendants = false
	dropdownList.Parent = f
	corner(dropdownList, 8)
	stroke(dropdownList, pal3.Accent, 1)
	shadow(dropdownList, 0.6, 16)

	local dropdownScroll = Instance.new("ScrollingFrame")
	dropdownScroll.BackgroundTransparency = 1
	dropdownScroll.BorderSizePixel = 0
	dropdownScroll.Size = UDim2.new(1, -8, 1, -8)
	dropdownScroll.Position = UDim2.new(0, 4, 0, 4)
	dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	dropdownScroll.ScrollBarThickness = 4
	dropdownScroll.ScrollBarImageColor3 = pal3.Accent
	dropdownScroll.ZIndex = 101
	dropdownScroll.Parent = dropdownList

	local dropdownLayout = Instance.new("UIListLayout")
	dropdownLayout.FillDirection = Enum.FillDirection.Vertical
	dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
	dropdownLayout.Padding = UDim.new(0, 2)
	dropdownLayout.Parent = dropdownScroll

	local inlineParent = dropdownList.Parent
	local inlineWidth = btn.Size.X.Offset
	local dropdownHeight = 0

	local overlayBlocker
	local dropdownOpen = false
	local optionButtons = {}
	local idx = 1

	local function locked()
		return o.RespectLock and RvrseUI.Store:IsLocked(o.RespectLock)
	end

	local function visual()
		local isLocked = locked()
		btn.AutoButtonColor = not isLocked
		lbl.TextTransparency = isLocked and 0.5 or 0
		btn.TextTransparency = isLocked and 0.5 or 0
		arrow.TextTransparency = isLocked and 0.5 or 0
	end

	local function ensureBlocker()
		if not useOverlay then
			return
		end

		if overlayBlocker and overlayBlocker.Parent then
			return
		end

		overlayBlocker = Instance.new("TextButton")
		overlayBlocker.Name = "DropdownOverlayBlocker"
		overlayBlocker.BackgroundTransparency = 1
		overlayBlocker.BorderSizePixel = 0
		overlayBlocker.AutoButtonColor = false
		overlayBlocker.Text = ""
		overlayBlocker.Size = UDim2.new(1, 0, 1, 0)
		overlayBlocker.Position = UDim2.new(0, 0, 0, 0)
		overlayBlocker.ZIndex = 190
		overlayBlocker.Visible = false
		overlayBlocker.Parent = OverlayLayer
		overlayBlocker.MouseButton1Click:Connect(function()
			if dropdownOpen then
				dropdownOpen = false
				arrow.Text = "▼"
				if o.OnClose then
					o.OnClose()
				end
				Animator:Tween(dropdownList, {
					Size = UDim2.new(0, math.max(btn.AbsoluteSize.X, inlineWidth), 0, 0)
				}, Animator.Spring.Fast)
				task.delay(0.15, function()
					if dropdownList then
						dropdownList.Visible = false
						dropdownList.Parent = inlineParent
						dropdownList.ZIndex = 100
						dropdownScroll.ZIndex = 101
						dropdownList.Position = UDim2.new(1, -(inlineWidth + 6), 0.5, 40)
						dropdownList.Size = UDim2.new(0, inlineWidth, 0, 0)
						if overlayBlocker then
							overlayBlocker.Visible = false
						end
					end
				end)
			end
		end)
	end

	local function updateButtonText()
		if values[idx] then
			btn.Text = tostring(values[idx])
		else
			btn.Text = placeholder
		end
	end

	local function updateHighlight()
		for i, optionBtn in ipairs(optionButtons) do
			if i == idx then
				optionBtn.BackgroundColor3 = pal3.Accent
				optionBtn.BackgroundTransparency = 0.8
				optionBtn.TextColor3 = pal3.Accent
			else
				optionBtn.BackgroundColor3 = pal3.Card
				optionBtn.BackgroundTransparency = 0
				optionBtn.TextColor3 = pal3.Text
			end
		end
	end

	local function collapseInline()
		dropdownList.Parent = inlineParent
		dropdownList.ZIndex = 100
		dropdownScroll.ZIndex = 101
		dropdownList.Position = UDim2.new(1, -(inlineWidth + 6), 0.5, 40)
		dropdownList.Size = UDim2.new(0, inlineWidth, 0, dropdownList.Size.Y.Offset)
	end

	local function repositionOverlay(width)
		width = width or math.max(btn.AbsoluteSize.X, inlineWidth)
		dropdownList.Parent = OverlayLayer
		dropdownList.ZIndex = 200
		dropdownScroll.ZIndex = 201
		local absPos = btn.AbsolutePosition
		dropdownList.Position = UDim2.fromOffset(absPos.X, absPos.Y + btn.AbsoluteSize.Y + 6)
		dropdownList.Size = UDim2.new(0, width, 0, dropdownList.Size.Y.Offset)
		return width
	end

	local setOpen -- forward declaration

	local function rebuildOptions()
		for _, child in ipairs(dropdownScroll:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		table.clear(optionButtons)
		dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, #values * itemHeight)
		dropdownHeight = math.min(#values * itemHeight, maxHeight)

		if #values == 0 then
			idx = 0
		else
			if idx < 1 or idx > #values then
				idx = 1
			end
		end
		updateButtonText()

		for i, value in ipairs(values) do
			local optionBtn = Instance.new("TextButton")
			optionBtn.Name = "Option_" .. i
			optionBtn.Size = UDim2.new(1, -8, 0, 28)
			optionBtn.BackgroundColor3 = i == idx and pal3.Accent or pal3.Card
			optionBtn.BackgroundTransparency = i == idx and 0.8 or 0
			optionBtn.BorderSizePixel = 0
			optionBtn.Font = Enum.Font.Gotham
			optionBtn.TextSize = 12
			optionBtn.TextColor3 = i == idx and pal3.Accent or pal3.Text
			optionBtn.Text = tostring(value)
			optionBtn.AutoButtonColor = false
			optionBtn.LayoutOrder = i
			optionBtn.ZIndex = 102
			optionBtn.Parent = dropdownScroll
			corner(optionBtn, 6)

			optionBtn.MouseButton1Click:Connect(function()
				if locked() then return end
				idx = i
				updateButtonText()
				updateHighlight()
				setOpen(false)

				if o.OnChanged then
					task.spawn(o.OnChanged, value)
				end
				if o.Flag then RvrseUI:_autoSave() end
			end)

			optionBtn.MouseEnter:Connect(function()
				if i ~= idx then
					Animator:Tween(optionBtn, {BackgroundColor3 = pal3.Hover}, Animator.Spring.Fast)
				end
			end)

			optionBtn.MouseLeave:Connect(function()
				if i ~= idx then
					Animator:Tween(optionBtn, {BackgroundColor3 = pal3.Card}, Animator.Spring.Fast)
				end
			end)

			optionButtons[i] = optionBtn
		end

		updateHighlight()
	end

	rebuildOptions()
	visual()

	function setOpen(state)
		if locked() then
			return
		end

		if state == dropdownOpen then
			if state and useOverlay then
				repositionOverlay()
			end
			return
		end

		dropdownOpen = state
		arrow.Text = dropdownOpen and "▲" or "▼"

		if dropdownOpen then
			if o.OnOpen then
				o.OnOpen()
			end

			dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, #values * itemHeight)
			dropdownHeight = math.min(#values * itemHeight, maxHeight)

			if useOverlay then
				ensureBlocker()
				if overlayBlocker then
					overlayBlocker.Visible = true
				end
				local width = repositionOverlay()
				dropdownList.Size = UDim2.new(0, width, 0, 0)
			else
				collapseInline()
				dropdownList.Size = UDim2.new(0, inlineWidth, 0, 0)
			end

			dropdownList.Visible = true
			local targetWidth = useOverlay and math.max(btn.AbsoluteSize.X, inlineWidth) or inlineWidth
			Animator:Tween(dropdownList, {
				Size = UDim2.new(0, targetWidth, 0, dropdownHeight)
			}, Animator.Spring.Snappy)
		else
			local targetWidth = useOverlay and math.max(btn.AbsoluteSize.X, inlineWidth) or inlineWidth
			Animator:Tween(dropdownList, {
				Size = UDim2.new(0, targetWidth, 0, 0)
			}, Animator.Spring.Fast)

			task.delay(0.15, function()
				if dropdownList then
					dropdownList.Visible = false
					collapseInline()
					dropdownList.Size = UDim2.new(0, inlineWidth, 0, 0)
					if overlayBlocker then
						overlayBlocker.Visible = false
					end
					if o.OnClose then
						o.OnClose()
					end
				end
			end)
		end
	end

	-- Toggle dropdown on button click
	btn.MouseButton1Click:Connect(function()
		setOpen(not dropdownOpen)
	end)

	-- Close when clicking outside (inline mode)
	UIS.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if not dropdownOpen then return end
			if useOverlay then return end

			task.wait(0.05)
			if not btn:IsDescendantOf(game) then
				return
			end

			local mousePos = UIS:GetMouseLocation()
			local dropdownPos = dropdownList.AbsolutePosition
			local dropdownSize = dropdownList.AbsoluteSize
			local btnPos = btn.AbsolutePosition
			local btnSize = btn.AbsoluteSize

			local inDropdown = mousePos.X >= dropdownPos.X and mousePos.X <= dropdownPos.X + dropdownSize.X and
				mousePos.Y >= dropdownPos.Y and mousePos.Y <= dropdownPos.Y + dropdownSize.Y

			local inButton = mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X and
				mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y

			if not inDropdown and not inButton then
				setOpen(false)
			end
		end
	end)

	btn.MouseEnter:Connect(function()
		if not locked() then
			Animator:Tween(btn, {BackgroundColor3 = pal3.Hover}, Animator.Spring.Fast)
		end
	end)
	btn.MouseLeave:Connect(function()
		if not locked() then
			Animator:Tween(btn, {BackgroundColor3 = pal3.Card}, Animator.Spring.Fast)
		end
	end)

	table.insert(RvrseUI._lockListeners, visual)

	local dropdownAPI = {
		Set = function(_, v, suppressCallback)
			local foundIndex
			if v ~= nil then
				for i, val in ipairs(values) do
					if val == v then
						foundIndex = i
						break
					end
				end
			end

			if foundIndex then
				idx = foundIndex
			else
				if #values > 0 then
					idx = 1
				else
					idx = 0
				end
			end

			updateButtonText()
			updateHighlight()
			visual()

			if not suppressCallback and o.OnChanged and values[idx] then
				task.spawn(o.OnChanged, values[idx])
			end
		end,

		Get = function()
			return values[idx]
		end,

		Refresh = function(_, newValues)
			if newValues then
				values = {}
				for _, val in ipairs(newValues) do
					values[#values + 1] = val
				end
				idx = 1
			end
			rebuildOptions()
			visual()
			if dropdownOpen then
				if useOverlay then
					repositionOverlay()
				end
				dropdownList.Size = UDim2.new(0, useOverlay and math.max(btn.AbsoluteSize.X, inlineWidth) or inlineWidth, 0, dropdownHeight)
			end
		end,

		SetVisible = function(_, visible)
			f.Visible = visible
		end,

		CurrentOption = values[idx],
		SetOpen = function(_, state)
			setOpen(state and true or false)
		end
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = dropdownAPI
	end

	return dropdownAPI
end


-- ========================
-- Slider Module
-- ========================



function Slider.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local corner = dependencies.corner
	local shadow = dependencies.shadow
	local gradient = dependencies.gradient
	local pal3 = dependencies.pal3
	local Animator = dependencies.Animator
	local RvrseUI = dependencies.RvrseUI
	local UIS = dependencies.UIS

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

	-- Track (taller for better hit area)
	local track = Instance.new("Frame")
	track.Position = UDim2.new(0, 0, 0, 28)
	track.Size = UDim2.new(1, 0, 0, 8)  -- Increased from 6 to 8 for better feel
	track.BackgroundColor3 = pal3.Border
	track.BorderSizePixel = 0
	track.Parent = f
	corner(track, 4)

	-- Fill with animated gradient
	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((value - minVal) / (maxVal - minVal), 0, 1, 0)
	fill.BackgroundColor3 = pal3.Accent
	fill.BorderSizePixel = 0
	fill.Parent = track
	corner(fill, 4)
	gradient(fill, 90, {pal3.Accent, pal3.AccentHover})

	-- Premium thumb with glow
	local thumb = Instance.new("Frame")
	thumb.AnchorPoint = Vector2.new(0.5, 0.5)
	thumb.Position = UDim2.new((value - minVal) / (maxVal - minVal), 0, 0.5, 0)
	thumb.Size = UDim2.new(0, 18, 0, 18)  -- Slightly larger default (was 16)
	thumb.BackgroundColor3 = Color3.new(1, 1, 1)
	thumb.BorderSizePixel = 0
	thumb.ZIndex = 3
	thumb.Parent = track
	corner(thumb, 9)
	shadow(thumb, 0.4, 4)  -- Enhanced shadow

	-- Accent glow ring (hidden by default)
	local glowRing = Instance.new("Frame")
	glowRing.AnchorPoint = Vector2.new(0.5, 0.5)
	glowRing.Position = UDim2.new(0.5, 0, 0.5, 0)
	glowRing.Size = UDim2.new(0, 18, 0, 18)  -- Same as thumb
	glowRing.BackgroundTransparency = 1
	glowRing.BorderSizePixel = 0
	glowRing.ZIndex = 2
	glowRing.Parent = thumb

	local glowStroke = Instance.new("UIStroke")
	glowStroke.Color = pal3.Accent
	glowStroke.Thickness = 0
	glowStroke.Transparency = 0.3
	glowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	glowStroke.Parent = glowRing
	corner(glowRing, 12)

	local dragging = false
	local hovering = false

	local function update(inputPos)
		local relativeX = math.clamp((inputPos.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		value = math.round((minVal + relativeX * (maxVal - minVal)) / step) * step
		value = math.clamp(value, minVal, maxVal)

		lbl.Text = (o.Text or "Slider") .. ": " .. value

		-- Buttery smooth animations
		Animator:Tween(fill, {Size = UDim2.new(relativeX, 0, 1, 0)}, Animator.Spring.Smooth)
		Animator:Tween(thumb, {Position = UDim2.new(relativeX, 0, 0.5, 0)}, Animator.Spring.Snappy)

		if o.OnChanged then task.spawn(o.OnChanged, value) end
		if o.Flag then RvrseUI:_autoSave() end
	end

	-- Hover effects
	track.MouseEnter:Connect(function()
		if RvrseUI.Store:IsLocked(o.RespectLock) then return end
		hovering = true
		-- Subtle hover: thumb grows slightly
		Animator:Tween(thumb, {Size = UDim2.new(0, 20, 0, 20)}, Animator.Spring.Fast)
		Animator:Tween(glowRing, {Size = UDim2.new(0, 20, 0, 20)}, Animator.Spring.Fast)
	end)

	track.MouseLeave:Connect(function()
		if dragging then return end  -- Don't shrink if dragging
		hovering = false
		-- Return to normal size
		Animator:Tween(thumb, {Size = UDim2.new(0, 18, 0, 18)}, Animator.Spring.Fast)
		Animator:Tween(glowRing, {Size = UDim2.new(0, 18, 0, 18)}, Animator.Spring.Fast)
		Animator:Tween(glowStroke, {Thickness = 0}, Animator.Spring.Fast)
	end)

	-- Dragging: GROW and GLOW
	track.InputBegan:Connect(function(io)
		if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
			if RvrseUI.Store:IsLocked(o.RespectLock) then return end
			dragging = true

			-- GROW: Thumb expands on grab
			Animator:Tween(thumb, {Size = UDim2.new(0, 24, 0, 24)}, Animator.Spring.Snappy)
			Animator:Tween(glowRing, {Size = UDim2.new(0, 24, 0, 24)}, Animator.Spring.Snappy)

			-- GLOW: Accent ring appears
			Animator:Tween(glowStroke, {Thickness = 3}, Animator.Spring.Smooth)

			update(io.Position)
		end
	end)

	track.InputEnded:Connect(function(io)
		if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
			dragging = false

			-- SHRINK: Return to hover size if still hovering, else normal
			local targetSize = hovering and 20 or 18
			Animator:Tween(thumb, {Size = UDim2.new(0, targetSize, 0, targetSize)}, Animator.Spring.Bounce)
			Animator:Tween(glowRing, {Size = UDim2.new(0, targetSize, 0, targetSize)}, Animator.Spring.Bounce)

			-- GLOW FADE: Ring disappears
			Animator:Tween(glowStroke, {Thickness = hovering and 1 or 0}, Animator.Spring.Fast)
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
		track.BackgroundTransparency = locked and 0.5 or 0
		fill.BackgroundTransparency = locked and 0.5 or 0
	end)

	local sliderAPI = {
		Set = function(_, v)
			value = math.clamp(v, minVal, maxVal)
			local relativeX = (value - minVal) / (maxVal - minVal)
			lbl.Text = (o.Text or "Slider") .. ": " .. value
			fill.Size = UDim2.new(relativeX, 0, 1, 0)
			thumb.Position = UDim2.new(relativeX, 0, 0.5, 0)
		end,
		Get = function() return value end,
		SetVisible = function(_, visible)
			f.Visible = visible
		end,
		CurrentValue = value
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = sliderAPI
	end

	return sliderAPI
end


-- ========================
-- Keybind Module
-- ========================



function Keybind.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local corner = dependencies.corner
	local stroke = dependencies.stroke
	local pal3 = dependencies.pal3
	local Animator = dependencies.Animator
	local RvrseUI = dependencies.RvrseUI
	local UIS = dependencies.UIS

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
	local currentKey = o.Default

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
			currentKey = io.KeyCode
			btn.Text = io.KeyCode.Name
			btn.TextColor3 = pal3.Text

			-- SPECIAL: If this keybind is for UI toggle, update the global toggle key
			if o.Flag == "_UIToggleKey" or o.IsUIToggle then
				RvrseUI.UI:BindToggleKey(io.KeyCode)
				print("[KEYBIND] UI Toggle key updated to:", io.KeyCode.Name)
			end

			-- SPECIAL: If this keybind is for escape/close, update the escape key
			if o.Flag == "_UIEscapeKey" or o.IsUIEscape then
				RvrseUI.UI:BindEscapeKey(io.KeyCode)
				print("[KEYBIND] UI Escape key updated to:", io.KeyCode.Name)
			end

			if o.OnChanged then task.spawn(o.OnChanged, io.KeyCode) end
			if o.Flag then RvrseUI:_autoSave() end  -- Auto-save on change
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

	local keybindAPI = {
		Set = function(_, key)
			currentKey = key
			btn.Text = (key and key.Name) or "Set Key"
			if o.OnChanged and key then o.OnChanged(key) end
		end,
		Get = function() return currentKey end,
		SetVisible = function(_, visible)
			f.Visible = visible
		end,
		CurrentKeybind = currentKey
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = keybindAPI
	end

	return keybindAPI
end


-- ========================
-- TextBox Module
-- ========================



function TextBox.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local corner = dependencies.corner
	local stroke = dependencies.stroke
	local pal3 = dependencies.pal3
	local Animator = dependencies.Animator
	local RvrseUI = dependencies.RvrseUI

	local f = card(44)

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, -240, 1, 0)
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = pal3.Text
	lbl.Text = o.Text or "Input"
	lbl.Parent = f

	local inputBox = Instance.new("TextBox")
	inputBox.AnchorPoint = Vector2.new(1, 0.5)
	inputBox.Position = UDim2.new(1, -8, 0.5, 0)
	inputBox.Size = UDim2.new(0, 220, 0, 32)
	inputBox.BackgroundColor3 = pal3.Card
	inputBox.BorderSizePixel = 0
	inputBox.Font = Enum.Font.Gotham
	inputBox.TextSize = 13
	inputBox.TextColor3 = pal3.Text
	inputBox.PlaceholderText = o.Placeholder or "Enter text..."
	inputBox.PlaceholderColor3 = pal3.TextMuted
	inputBox.Text = o.Default or ""
	inputBox.ClearTextOnFocus = false
	inputBox.Parent = f
	corner(inputBox, 8)
	stroke(inputBox, pal3.Border, 1)

	local currentValue = inputBox.Text

	inputBox.FocusLost:Connect(function(enterPressed)
		currentValue = inputBox.Text
		if o.OnChanged then
			task.spawn(o.OnChanged, currentValue, enterPressed)
		end
		if o.Flag then RvrseUI:_autoSave() end  -- Auto-save on focus lost
	end)

	inputBox.Focused:Connect(function()
		Animator:Tween(inputBox, {BackgroundColor3 = pal3.Hover}, Animator.Spring.Fast)
	end)

	inputBox.FocusLost:Connect(function()
		Animator:Tween(inputBox, {BackgroundColor3 = pal3.Card}, Animator.Spring.Fast)
	end)

	table.insert(RvrseUI._lockListeners, function()
		local locked = RvrseUI.Store:IsLocked(o.RespectLock)
		lbl.TextTransparency = locked and 0.5 or 0
		inputBox.TextEditable = not locked
	end)

	local textboxAPI = {
		Set = function(_, txt)
			inputBox.Text = txt
			currentValue = txt
		end,
		Get = function()
			return currentValue
		end,
		SetVisible = function(_, visible)
			f.Visible = visible
		end,
		CurrentValue = currentValue
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = textboxAPI
	end

	return textboxAPI
end


-- ========================
-- ColorPicker Module
-- ========================



function ColorPicker.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local corner = dependencies.corner
	local stroke = dependencies.stroke
	local pal3 = dependencies.pal3
	local Animator = dependencies.Animator
	local RvrseUI = dependencies.RvrseUI

	local f = card(44)

	local defaultColor = o.Default or Color3.fromRGB(255, 255, 255)
	local currentColor = defaultColor

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, -80, 1, 0)
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = pal3.Text
	lbl.Text = o.Text or "Color"
	lbl.Parent = f

	local preview = Instance.new("TextButton")
	preview.AnchorPoint = Vector2.new(1, 0.5)
	preview.Position = UDim2.new(1, 0, 0.5, 0)
	preview.Size = UDim2.new(0, 64, 0, 32)
	preview.BackgroundColor3 = currentColor
	preview.BorderSizePixel = 0
	preview.Text = ""
	preview.AutoButtonColor = false
	preview.Parent = f
	corner(preview, 8)
	stroke(preview, pal3.Border, 2)

	-- Simple color cycling demo (you can implement full color picker UI)
	local colors = {
		Color3.fromRGB(255, 0, 0),    -- Red
		Color3.fromRGB(255, 127, 0),  -- Orange
		Color3.fromRGB(255, 255, 0),  -- Yellow
		Color3.fromRGB(0, 255, 0),    -- Green
		Color3.fromRGB(0, 127, 255),  -- Blue
		Color3.fromRGB(139, 0, 255),  -- Purple
		Color3.fromRGB(255, 255, 255),-- White
		Color3.fromRGB(0, 0, 0),      -- Black
	}
	local colorIdx = 1

	preview.MouseButton1Click:Connect(function()
		if RvrseUI.Store:IsLocked(o.RespectLock) then return end
		colorIdx = (colorIdx % #colors) + 1
		currentColor = colors[colorIdx]
		preview.BackgroundColor3 = currentColor
		if o.OnChanged then
			task.spawn(o.OnChanged, currentColor)
		end
		if o.Flag then RvrseUI:_autoSave() end  -- Auto-save on change
	end)

	preview.MouseEnter:Connect(function()
		Animator:Tween(preview, {BackgroundTransparency = 0.2}, Animator.Spring.Fast)
	end)

	preview.MouseLeave:Connect(function()
		Animator:Tween(preview, {BackgroundTransparency = 0}, Animator.Spring.Fast)
	end)

	table.insert(RvrseUI._lockListeners, function()
		local locked = RvrseUI.Store:IsLocked(o.RespectLock)
		lbl.TextTransparency = locked and 0.5 or 0
	end)

	local colorpickerAPI = {
		Set = function(_, color)
			currentColor = color
			preview.BackgroundColor3 = color
		end,
		Get = function()
			return currentColor
		end,
		SetVisible = function(_, visible)
			f.Visible = visible
		end,
		CurrentValue = currentColor
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = colorpickerAPI
	end

	return colorpickerAPI
end


-- ========================
-- Label Module
-- ========================



function Label.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local pal3 = dependencies.pal3
	local RvrseUI = dependencies.RvrseUI

	local f = card(32)

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = pal3.Text
	lbl.Text = o.Text or "Label"
	lbl.Parent = f

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
		CurrentValue = lbl.Text
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = labelAPI
	end

	return labelAPI
end


-- ========================
-- Paragraph Module
-- ========================



function Paragraph.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local pal3 = dependencies.pal3
	local RvrseUI = dependencies.RvrseUI

	local text = o.Text or "Paragraph text"
	local lines = math.ceil(#text / 50)  -- Rough estimate
	local height = math.max(48, lines * 18 + 16)
	local f = card(height)

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, -16, 1, -16)
	lbl.Position = UDim2.new(0, 8, 0, 8)
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 13
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextYAlignment = Enum.TextYAlignment.Top
	lbl.TextColor3 = pal3.TextSub
	lbl.Text = text
	lbl.TextWrapped = true
	lbl.Parent = f

	local paragraphAPI = {
		Set = function(_, txt)
			lbl.Text = txt
			local newLines = math.ceil(#txt / 50)
			local newHeight = math.max(48, newLines * 18 + 16)
			f.Size = UDim2.new(1, 0, 0, newHeight)
		end,
		Get = function()
			return lbl.Text
		end,
		SetVisible = function(_, visible)
			f.Visible = visible
		end,
		CurrentValue = text
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = paragraphAPI
	end

	return paragraphAPI
end


-- ========================
-- Divider Module
-- ========================



function Divider.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local pal3 = dependencies.pal3

	local f = card(12)
	f.BackgroundTransparency = 1

	local line = Instance.new("Frame")
	line.Size = UDim2.new(1, -16, 0, 1)
	line.Position = UDim2.new(0, 8, 0.5, 0)
	line.BackgroundColor3 = pal3.Divider
	line.BorderSizePixel = 0
	line.Parent = f

	return {
		SetColor = function(_, color)
			line.BackgroundColor3 = color
		end,
		SetVisible = function(_, visible)
			f.Visible = visible
		end
	}
end


-- ========================
-- SectionBuilder Module
-- ========================



function SectionBuilder.CreateSection(sectionTitle, page, dependencies)
	local Theme = dependencies.Theme
	local helpers = dependencies.UIHelpers or {}
	local corner = helpers.corner or function(inst, radius)
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, radius or 12)
		c.Parent = inst
		return c
	end
	local stroke = helpers.stroke or function(inst, color, thickness)
		local s = Instance.new("UIStroke")
		s.Color = color or Color3.fromRGB(45, 45, 55)
		s.Thickness = thickness or 1
		s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		s.Parent = inst
		return s
	end
	local padding = helpers.padding or function(inst, inset)
		local pad = Instance.new("UIPadding")
		local offset = UDim.new(0, inset or 12)
		pad.PaddingTop = offset
		pad.PaddingBottom = offset
		pad.PaddingLeft = offset
		pad.PaddingRight = offset
		pad.Parent = inst
		return pad
	end
	local gradient = helpers.gradient or function() end
	local shadow = helpers.shadow or function() end
	local Elements = dependencies.Elements
	local RvrseUI = dependencies.RvrseUI
	local overlayLayer = dependencies.OverlayLayer

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

	-- Card factory function (creates base card for elements)
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

	

	-- Prepare element dependencies
	local function getElementDeps()
		return {
			card = card,
			corner = corner,
			stroke = stroke,
			padding = padding,
			pal3 = pal3,
			Theme = Theme,
			Animator = dependencies.Animator,
			RvrseUI = RvrseUI,
			UIS = dependencies.UIS,
			gradient = gradient,
			shadow = shadow,
			OverlayLayer = overlayLayer
		}
	end

	-- Element factory methods (delegate to Element modules)
	function SectionAPI:CreateButton(o)
		return Elements.Button.Create(o, getElementDeps())
	end

	function SectionAPI:CreateToggle(o)
		return Elements.Toggle.Create(o, getElementDeps())
	end

	function SectionAPI:CreateDropdown(o)
		return Elements.Dropdown.Create(o, getElementDeps())
	end

	function SectionAPI:CreateKeybind(o)
		return Elements.Keybind.Create(o, getElementDeps())
	end

	function SectionAPI:CreateSlider(o)
		return Elements.Slider.Create(o, getElementDeps())
	end

	function SectionAPI:CreateLabel(o)
		return Elements.Label.Create(o, getElementDeps())
	end

	function SectionAPI:CreateParagraph(o)
		return Elements.Paragraph.Create(o, getElementDeps())
	end

	function SectionAPI:CreateDivider(o)
		return Elements.Divider.Create(o, getElementDeps())
	end

	function SectionAPI:CreateTextBox(o)
		return Elements.TextBox.Create(o, getElementDeps())
	end

	function SectionAPI:CreateColorPicker(o)
		return Elements.ColorPicker.Create(o, getElementDeps())
	end

	-- Section utility methods
	function SectionAPI:Update(newTitle)
		sectionLabel.Text = newTitle or sectionTitle
	end

	function SectionAPI:SetVisible(visible)
		sectionHeader.Visible = visible
		container.Visible = visible
	end

	return SectionAPI
end

function SectionBuilder:Initialize(deps)
	-- SectionBuilder is ready to use
	-- Dependencies are passed when CreateSection is called
	-- No initialization state needed
end


-- ========================
-- TabBuilder Module
-- ========================



function TabBuilder.CreateTab(t, dependencies)
	t = t or {}

	local Theme = dependencies.Theme
	local corner = dependencies.UIHelpers.corner
	local Animator = dependencies.Animator
	local Icons = dependencies.Icons
	local SectionBuilder = dependencies.SectionBuilder
	local tabBar = dependencies.tabBar
	local body = dependencies.body
	local tabs = dependencies.tabs
	local activePage = dependencies.activePage

	local pal2 = Theme:Get()

	-- Tab button with icon support (Lucide, Roblox asset ID, or emoji)
	local tabBtn = Instance.new("TextButton")
	tabBtn.AutoButtonColor = false
	tabBtn.BackgroundColor3 = pal2.Card
	tabBtn.BackgroundTransparency = 0.7
	tabBtn.Size = UDim2.new(0, 100, 1, 0)
	tabBtn.Font = Enum.Font.GothamMedium
	tabBtn.TextSize = 13
	tabBtn.TextColor3 = pal2.TextSub
	tabBtn.Parent = tabBar
	corner(tabBtn, 8)

	-- Handle icon display
	local tabIcon = nil
	local tabText = t.Title or "Tab"

	if t.Icon then
		local iconAsset, iconType = Icons:Resolve(t.Icon)

		if iconType == "image" then
			-- Create image icon
			tabIcon = Instance.new("ImageLabel")
			tabIcon.BackgroundTransparency = 1
			tabIcon.Image = iconAsset
			tabIcon.Size = UDim2.new(0, 16, 0, 16)
			tabIcon.Position = UDim2.new(0, 8, 0.5, -8)
			tabIcon.ImageColor3 = pal2.TextSub
			tabIcon.Parent = tabBtn

			-- Adjust text position for image icon
			tabBtn.Text = "     " .. tabText
			tabBtn.TextXAlignment = Enum.TextXAlignment.Left
		elseif iconType == "text" then
			-- Use emoji/text icon inline
			tabBtn.Text = iconAsset .. " " .. tabText
		end
	else
		-- No icon, just text
		tabBtn.Text = tabText
	end

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
		dependencies.activePage = page  -- Update active page reference
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

	table.insert(tabs, {btn = tabBtn, page = page, indicator = tabIndicator, icon = tabIcon})

	-- Activate first tab automatically
	if #tabs == 1 then
		activateTab()
	end

	

	-- Tab SetIcon Method
	function TabAPI:SetIcon(newIcon)
		if not newIcon then return end

		local iconAsset, iconType = Icons:Resolve(newIcon)

		-- Remove old icon if exists
		if tabIcon and tabIcon.Parent then
			tabIcon:Destroy()
			tabIcon = nil
		end

		if iconType == "image" then
			-- Create new image icon
			tabIcon = Instance.new("ImageLabel")
			tabIcon.BackgroundTransparency = 1
			tabIcon.Image = iconAsset
			tabIcon.Size = UDim2.new(0, 16, 0, 16)
			tabIcon.Position = UDim2.new(0, 8, 0.5, -8)
			tabIcon.ImageColor3 = pal2.TextSub
			tabIcon.Parent = tabBtn

			tabBtn.Text = "     " .. tabText
			tabBtn.TextXAlignment = Enum.TextXAlignment.Left
		elseif iconType == "text" then
			-- Use emoji/text icon inline
			tabBtn.Text = iconAsset .. " " .. tabText
		end

		-- Update the tabs table reference
		for i, tabData in ipairs(tabs) do
			if tabData.btn == tabBtn then
				tabs[i].icon = tabIcon
				break
			end
		end
	end

	-- CreateSection method delegates to SectionBuilder
	function TabAPI:CreateSection(sectionTitle)
		return SectionBuilder.CreateSection(sectionTitle, page, dependencies)
	end

	return TabAPI
end

function TabBuilder:Initialize(deps)
	-- TabBuilder is ready to use
	-- Dependencies are passed when CreateTab is called
	-- No initialization state needed
end


-- ========================
-- WindowBuilder Module
-- ========================



local Theme, Animator, State, Config, UIHelpers, Icons, TabBuilder, SectionBuilder, WindowManager, Notifications
local Debug, Obfuscation, Hotkeys, Version, Elements, OverlayLayer

local UIS, GuiService, RS, PlayerGui, HttpService

function WindowBuilder:Initialize(deps)
	-- Inject all dependencies
	Theme = deps.Theme
	Animator = deps.Animator
	State = deps.State
	Config = deps.Config
	UIHelpers = deps.UIHelpers
	Icons = deps.Icons
	TabBuilder = deps.TabBuilder
	SectionBuilder = deps.SectionBuilder
	WindowManager = deps.WindowManager
	Notifications = deps.Notifications
	Debug = deps.Debug
	Obfuscation = deps.Obfuscation
	Hotkeys = deps.Hotkeys
	Version = deps.Version
	Elements = deps.Elements
	OverlayLayer = deps.OverlayLayer

	-- Services
	UIS = deps.UIS
	GuiService = deps.GuiService
	RS = deps.RS
	PlayerGui = deps.PlayerGui
	HttpService = deps.HttpService
end

function WindowBuilder:CreateWindow(RvrseUI, cfg, host)
	cfg = cfg or {}

	local overlayLayer = OverlayLayer
	if not overlayLayer or not overlayLayer.Parent then
		overlayLayer = host:FindFirstChild("RvrseUI_Overlay")
		if not overlayLayer then
			overlayLayer = Instance.new("Frame")
			overlayLayer.Name = "RvrseUI_Overlay"
			overlayLayer.BackgroundTransparency = 1
			overlayLayer.BorderSizePixel = 0
			overlayLayer.ClipsDescendants = false
			overlayLayer.ZIndex = 20000
			overlayLayer.Size = UDim2.new(1, 0, 1, 0)
			overlayLayer.Parent = host
		end
		OverlayLayer = overlayLayer
	end

	Debug.printf("=== CREATEWINDOW THEME DEBUG ===")

	-- IMPORTANT: Load saved theme FIRST before applying precedence
	if RvrseUI.ConfigurationSaving and RvrseUI.ConfigurationFileName then
		local fullPath = RvrseUI.ConfigurationFileName
		if RvrseUI.ConfigurationFolderName then
			fullPath = RvrseUI.ConfigurationFolderName .. "/" .. RvrseUI.ConfigurationFileName
		end

		Debug.printf("🔍 PRE-LOAD VERIFICATION (CreateWindow)")
		Debug.printf("PRE-LOAD PATH:", fullPath)
		Debug.printf("CONFIG INSTANCE:", tostring(RvrseUI))

		if type(readfile) ~= "function" then
			Debug.printf("[FS] readfile unavailable - skipping config pre-load")
		else
			local success, existingConfig = pcall(readfile, fullPath)
			if success and existingConfig then
				local decodeOk, decoded = pcall(HttpService.JSONDecode, HttpService, existingConfig)
				if decodeOk and typeof(decoded) == "table" then
					Debug.printf("PRE-LOAD VALUE: _RvrseUI_Theme =", decoded._RvrseUI_Theme or "nil")
					if decoded._RvrseUI_Theme then
						RvrseUI._savedTheme = decoded._RvrseUI_Theme
						Debug.printf("✅ Pre-loaded saved theme from config:", RvrseUI._savedTheme)
					end
				else
					Debug.printf("PRE-LOAD: JSON decode failed:", decoded)
				end
			else
				Debug.printf("PRE-LOAD readfile failed:", existingConfig)
			end
		end
	end

	Debug.printf("RvrseUI._savedTheme:", RvrseUI._savedTheme)
	Debug.printf("cfg.Theme:", cfg.Theme)
	Debug.printf("Theme.Current before:", Theme.Current)

	-- Deterministic precedence: saved theme wins, else cfg.Theme, else default
	local finalTheme = RvrseUI._savedTheme or cfg.Theme or "Dark"
	local source = RvrseUI._savedTheme and "saved" or (cfg.Theme and "cfg") or "default"

	-- Apply theme (does NOT mark dirty - this is initialization)
	Theme:Apply(finalTheme)

	Debug.printf("🎯 FINAL THEME APPLICATION")
	Debug.printf("✅ Applied theme (source=" .. source .. "):", finalTheme)
	Debug.printf("Theme.Current after:", Theme.Current)
	Debug.printf("Theme._dirty:", Theme._dirty)

	-- Assert valid theme
	assert(Theme.Current == "Dark" or Theme.Current == "Light", "Invalid Theme.Current at end of init: " .. tostring(Theme.Current))

	local pal = Theme:Get()

	-- Configuration system setup
	local autoSaveEnabled = true

	if cfg.ConfigurationSaving then
		if typeof(cfg.ConfigurationSaving) == "string" then
			RvrseUI.ConfigurationSaving = true
			RvrseUI.ConfigurationFileName = cfg.ConfigurationSaving .. ".json"
			RvrseUI.ConfigurationFolderName = "RvrseUI/Configs"
			Debug.printf("📂 Named profile mode:", cfg.ConfigurationSaving)
		elseif typeof(cfg.ConfigurationSaving) == "table" then
			RvrseUI.ConfigurationSaving = cfg.ConfigurationSaving.Enabled or true
			RvrseUI.ConfigurationFileName = cfg.ConfigurationSaving.FileName or "RvrseUI_Config.json"
			RvrseUI.ConfigurationFolderName = cfg.ConfigurationSaving.FolderName
			autoSaveEnabled = cfg.ConfigurationSaving.AutoSave ~= false
			Debug.printf("Configuration saving enabled:", RvrseUI.ConfigurationFolderName and (RvrseUI.ConfigurationFolderName .. "/" .. RvrseUI.ConfigurationFileName) or RvrseUI.ConfigurationFileName)
		elseif cfg.ConfigurationSaving == true then
			local lastConfig, lastTheme = RvrseUI:GetLastConfig()
			if lastConfig then
				Debug.printf("📂 Auto-loading last config:", lastConfig)
				local folder, file = lastConfig:match("^(.*)/([^/]+)$")
				if folder and file then
					RvrseUI.ConfigurationFolderName = folder
					RvrseUI.ConfigurationFileName = file
				else
					RvrseUI.ConfigurationFolderName = nil
					RvrseUI.ConfigurationFileName = lastConfig
				end
				RvrseUI.ConfigurationSaving = true

				if lastTheme then
					RvrseUI._savedTheme = lastTheme
					Debug.printf("📂 Overriding theme with last saved:", lastTheme)
				end
			else
				RvrseUI.ConfigurationSaving = true
				RvrseUI.ConfigurationFileName = "RvrseUI_Config.json"
				Debug.printf("📂 No last config, using default")
			end
		end
	end

	Config.ConfigurationSaving = RvrseUI.ConfigurationSaving
	Config.ConfigurationFileName = RvrseUI.ConfigurationFileName
	Config.ConfigurationFolderName = RvrseUI.ConfigurationFolderName
	Config.AutoSaveEnabled = autoSaveEnabled
	RvrseUI.AutoSaveEnabled = autoSaveEnabled

	local name = cfg.Name or "RvrseUI"
	local toggleKey = UIHelpers.coerceKeycode(cfg.ToggleUIKeybind or "K")
	RvrseUI.UI:BindToggleKey(toggleKey)

	local escapeKey = cfg.EscapeKey or Enum.KeyCode.Backspace
	if type(escapeKey) == "string" then
		escapeKey = UIHelpers.coerceKeycode(escapeKey)
	end
	RvrseUI.UI:BindEscapeKey(escapeKey)

	-- Container selection
	local windowHost = host

	if cfg.Container then
		local customHost = Instance.new("ScreenGui")
		customHost.Name = "_TestModule_" .. name:gsub("%s", "")
		customHost.ResetOnSpawn = false
		customHost.IgnoreGuiInset = false
		customHost.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		customHost.DisplayOrder = cfg.DisplayOrder or 100000

		local containerTarget = nil

		if typeof(cfg.Container) == "string" then
			local containerMap = {
				["PlayerGui"] = PlayerGui,
				["CoreGui"] = game:GetService("CoreGui"),
				["StarterGui"] = game:GetService("StarterGui"),
				["ReplicatedFirst"] = game:GetService("ReplicatedFirst"),
			}
			containerTarget = containerMap[cfg.Container]
		elseif typeof(cfg.Container) == "Instance" then
			containerTarget = cfg.Container
		end

		if containerTarget then
			customHost.Parent = containerTarget
			windowHost = customHost
			table.insert(RvrseUI._windows, {host = customHost})
			Debug.printf("Container set to:", cfg.Container)
		else
			warn("[RvrseUI] Invalid container specified, using default PlayerGui")
		end
	end

	-- Detect mobile/tablet
	local isMobile = UIS.TouchEnabled and not UIS.MouseEnabled
	local baseWidth = isMobile and 380 or 580
	local baseHeight = isMobile and 520 or 480

	-- Root window
	local root = Instance.new("Frame")
	root.Name = Obfuscation.getObfuscatedName("window")
	root.Size = UDim2.new(0, baseWidth, 0, baseHeight)

	local screenSize = workspace.CurrentCamera.ViewportSize
	local centerX = (screenSize.X - baseWidth) / 2
	local centerY = (screenSize.Y - baseHeight) / 2
	root.Position = UDim2.fromOffset(centerX, centerY)
	root.BackgroundColor3 = pal.Bg
	root.BackgroundTransparency = 0.05
	root.BorderSizePixel = 0
	root.Visible = false
	root.ClipsDescendants = false
	root.ZIndex = 10000
	root.Parent = windowHost
	UIHelpers.corner(root, 16)
	UIHelpers.stroke(root, pal.Border, 1.5)

	-- Glassmorphic overlay
	local glassOverlay = Instance.new("Frame")
	glassOverlay.Size = UDim2.new(1, 0, 1, 0)
	glassOverlay.BackgroundColor3 = Theme.Current == "Dark"
		and Color3.fromRGB(255, 255, 255)
		or Color3.fromRGB(245, 245, 250)
	glassOverlay.BackgroundTransparency = 0.95
	glassOverlay.BorderSizePixel = 0
	glassOverlay.ZIndex = root.ZIndex - 1
	glassOverlay.Parent = root
	UIHelpers.corner(glassOverlay, 16)

	local glassShine = Instance.new("UIStroke")
	glassShine.Color = Color3.fromRGB(255, 255, 255)
	glassShine.Transparency = 0.7
	glassShine.Thickness = 1
	glassShine.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	glassShine.Parent = glassOverlay

	-- Header bar
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 52)
	header.BackgroundColor3 = pal.Card
	header.BackgroundTransparency = 0.5
	header.BorderSizePixel = 0
	header.Parent = root
	UIHelpers.corner(header, 16)
	UIHelpers.stroke(header, pal.Border, 1)

	local headerDivider = Instance.new("Frame")
	headerDivider.BackgroundColor3 = pal.Divider
	headerDivider.BackgroundTransparency = 0.5
	headerDivider.BorderSizePixel = 0
	headerDivider.Position = UDim2.new(0, 12, 1, -1)
	headerDivider.Size = UDim2.new(1, -24, 0, 1)
	headerDivider.Parent = header

	-- ═══════════════════════════════════════════════════════════════
	-- ADVANCED CURSOR-LOCKED DRAG SYSTEM - Window Header
	-- ═══════════════════════════════════════════════════════════════
	-- Ensures the cursor stays perfectly glued to the exact grab point
	-- during the entire drag operation. Handles GUI inset, touch, and
	-- mouse input with sub-pixel precision.
	-- ═══════════════════════════════════════════════════════════════

	local dragging, activeDragInput, dragOffset
	local hostScreenGui = typeof(windowHost) == "Instance"
		and windowHost:IsA("ScreenGui")
		and windowHost
	local hostIgnoresInset = hostScreenGui and windowHost.IgnoreGuiInset == true

	-- Get raw pointer position in screen space (accounting for touch vs mouse)
	local function getRawPointerPosition(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.Touch then
			return Vector2.new(inputObject.Position.X, inputObject.Position.Y)
		end
		return UIS:GetMouseLocation()
	end

	-- Get GUI inset offset vector
	local function getGuiInset()
		local inset = GuiService:GetGuiInset()
		return Vector2.new(inset.X, inset.Y)
	end

	-- Convert screen-space pointer to UI coordinate space
	local function pointerToUISpace(inputObject)
		local rawPointer = getRawPointerPosition(inputObject)
		local inset = getGuiInset()
		return rawPointer - inset
	end

	-- Get the root window's top-left position in UI space
	local function getWindowTopLeftInUISpace()
		local absPos = root.AbsolutePosition
		-- If host doesn't ignore inset, we need to subtract it
		if hostScreenGui and not hostIgnoresInset then
			absPos = absPos - getGuiInset()
		end
		return absPos
	end

	-- Cache the EXACT offset from pointer to window top-left at grab time
	-- This is the "glue point" that will be maintained throughout the drag
	local function cacheGrabOffset(inputObject)
		local pointerInUI = pointerToUISpace(inputObject)
		local windowTopLeft = getWindowTopLeftInUISpace()
		dragOffset = pointerInUI - windowTopLeft

		Debug.printf("[DRAG] Cached offset: X=%.2f, Y=%.2f", dragOffset.X, dragOffset.Y)
	end

	-- Finish drag and save final position
	local function finishDrag()
		if not dragging then
			return
		end

		dragging = false
		activeDragInput = nil
		dragOffset = nil

		-- Save absolute position for restoration
		RvrseUI._lastWindowPosition = {
			XScale = 0,
			XOffset = root.AbsolutePosition.X,
			YScale = 0,
			YOffset = root.AbsolutePosition.Y
		}

		Debug.printf("[DRAG] Finished - saved position: X=%d, Y=%d",
			root.AbsolutePosition.X, root.AbsolutePosition.Y)
	end

	-- Start dragging when header is clicked
	header.InputBegan:Connect(function(io)
		if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			activeDragInput = io
			cacheGrabOffset(io)
			Debug.printf("[DRAG] Started - input type: %s", tostring(io.UserInputType))
		end
	end)

	-- End drag when released on header
	header.InputEnded:Connect(function(io)
		if io == activeDragInput then
			finishDrag()
		end
	end)

	-- Main drag update loop - maintains cursor lock
	UIS.InputChanged:Connect(function(io)
		if not dragging then
			return
		end

		-- Check if this is our active drag input
		local isMouseDrag = io.UserInputType == Enum.UserInputType.MouseMovement
			and activeDragInput
			and activeDragInput.UserInputType == Enum.UserInputType.MouseButton1
		local isTouchDrag = io == activeDragInput

		if not isMouseDrag and not isTouchDrag then
			return
		end

		-- Safety: recache offset if somehow lost
		if not dragOffset then
			cacheGrabOffset(activeDragInput or io)
		end

		-- Calculate target position: pointer - cached offset = new top-left
		local pointerInUI = pointerToUISpace(io)
		local targetX = pointerInUI.X - dragOffset.X
		local targetY = pointerInUI.Y - dragOffset.Y

		-- Get screen bounds for clamping
		local screenSize = workspace.CurrentCamera.ViewportSize
		local inset = getGuiInset()
		local windowWidth = root.AbsoluteSize.X
		local windowHeight = root.AbsoluteSize.Y
		local headerHeight = 52

		-- Clamp to keep window mostly on screen
		local minX = -(windowWidth - 100)
		local maxX = (screenSize.X - inset.X) - 100
		local minY = 0
		local maxY = (screenSize.Y - inset.Y) - headerHeight

		targetX = math.clamp(targetX, minX, maxX)
		targetY = math.clamp(targetY, minY, maxY)

		-- If host doesn't ignore inset, we need to ADD inset back to final position
		-- because AbsolutePosition is in screen space
		local finalX = targetX
		local finalY = targetY

		if hostScreenGui and not hostIgnoresInset then
			finalX = finalX + inset.X
			finalY = finalY + inset.Y
		end

		-- Apply position - cursor is now perfectly locked to grab point
		root.Position = UDim2.fromOffset(math.floor(finalX + 0.5), math.floor(finalY + 0.5))
	end)

	-- Global input end handler (in case release happens outside header)
	UIS.InputEnded:Connect(function(io)
		if io == activeDragInput then
			finishDrag()
		end
	end)

	-- Icon
	local iconHolder = Instance.new("Frame")
	iconHolder.BackgroundTransparency = 1
	iconHolder.Position = UDim2.new(0, 16, 0.5, -16)
	iconHolder.Size = UDim2.new(0, 32, 0, 32)
	iconHolder.Parent = header

	if cfg.Icon and cfg.Icon ~= 0 then
		local iconAsset, iconType = Icons.resolveIcon(cfg.Icon)

		if iconType == "image" then
			local img = Instance.new("ImageLabel")
			img.BackgroundTransparency = 1
			img.Image = iconAsset
			img.Size = UDim2.new(1, 0, 1, 0)
			img.ImageColor3 = pal.Accent
			img.Parent = iconHolder
			UIHelpers.corner(img, 8)
		elseif iconType == "text" then
			local iconTxt = Instance.new("TextLabel")
			iconTxt.BackgroundTransparency = 1
			iconTxt.Font = Enum.Font.GothamBold
			iconTxt.TextSize = 20
			iconTxt.TextColor3 = pal.Accent
			iconTxt.Text = iconAsset
			iconTxt.Size = UDim2.new(1, 0, 1, 0)
			iconTxt.Parent = iconHolder
		end
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

	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.AnchorPoint = Vector2.new(1, 0.5)
	closeBtn.Position = UDim2.new(1, -12, 0.5, 0)
	closeBtn.Size = UDim2.new(0, 32, 0, 32)
	closeBtn.BackgroundColor3 = pal.Error
	closeBtn.BackgroundTransparency = 0.9
	closeBtn.BorderSizePixel = 0
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 18
	closeBtn.Text = "❌"
	closeBtn.TextColor3 = pal.Error
	closeBtn.AutoButtonColor = false
	closeBtn.Parent = header
	UIHelpers.corner(closeBtn, 8)
	UIHelpers.stroke(closeBtn, pal.Error, 1)

	local closeTooltip = UIHelpers.createTooltip(closeBtn, "Close UI")

	closeBtn.MouseEnter:Connect(function()
		closeTooltip.Visible = true
		Animator:Tween(closeBtn, {BackgroundTransparency = 0.7}, Animator.Spring.Fast)
	end)
	closeBtn.MouseLeave:Connect(function()
		closeTooltip.Visible = false
		Animator:Tween(closeBtn, {BackgroundTransparency = 0.9}, Animator.Spring.Fast)
	end)

	closeBtn.MouseButton1Click:Connect(function()
		Animator:Ripple(closeBtn, 16, 16)
		Animator:Tween(root, {BackgroundTransparency = 1}, Animator.Spring.Fast)
		Animator:Tween(glassOverlay, {BackgroundTransparency = 1}, Animator.Spring.Fast)

		task.wait(0.3)

		if host and host.Parent then
			host:Destroy()
		end

		if RvrseUI.UI._toggleTargets then
			table.clear(RvrseUI.UI._toggleTargets)
		end
		if RvrseUI._lockListeners then
			table.clear(RvrseUI._lockListeners)
		end
		if RvrseUI._themeListeners then
			table.clear(RvrseUI._themeListeners)
		end

		print("[RvrseUI] Interface destroyed - No trace remaining")
	end)

	-- Notification Bell Toggle
	local bellToggle = Instance.new("TextButton")
	bellToggle.Name = "BellToggle"
	bellToggle.AnchorPoint = Vector2.new(1, 0.5)
	bellToggle.Position = UDim2.new(1, -52, 0.5, 0)
	bellToggle.Size = UDim2.new(0, 32, 0, 24)
	bellToggle.BackgroundColor3 = pal.Elevated
	bellToggle.BorderSizePixel = 0
	bellToggle.Font = Enum.Font.GothamBold
	bellToggle.TextSize = 14
	bellToggle.Text = "🔔"
	bellToggle.TextColor3 = pal.Success
	bellToggle.AutoButtonColor = false
	bellToggle.Parent = header
	UIHelpers.corner(bellToggle, 12)
	UIHelpers.stroke(bellToggle, pal.Border, 1)
	UIHelpers.addGlow(bellToggle, pal.Success, 1.5)

	local bellTooltip = UIHelpers.createTooltip(bellToggle, "Notifications: ON")

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
			if bellToggle:FindFirstChild("Glow") then
				bellToggle.Glow:Destroy()
			end
			UIHelpers.addGlow(bellToggle, pal.Success, 1.5)
		else
			bellToggle.Text = "🔕"
			bellToggle.TextColor3 = pal.Error
			bellTooltip.Text = "  Notifications: OFF  "
			if bellToggle:FindFirstChild("Glow") then
				bellToggle.Glow:Destroy()
			end
		end
		Animator:Ripple(bellToggle, 25, 12)
	end)

	-- Minimize button
	local minimizeBtn = Instance.new("TextButton")
	minimizeBtn.Name = "MinimizeButton"
	minimizeBtn.AnchorPoint = Vector2.new(1, 0.5)
	minimizeBtn.Position = UDim2.new(1, -132, 0.5, 0)
	minimizeBtn.Size = UDim2.new(0, 32, 0, 24)
	minimizeBtn.BackgroundColor3 = pal.Elevated
	minimizeBtn.BorderSizePixel = 0
	minimizeBtn.Font = Enum.Font.GothamBold
	minimizeBtn.TextSize = 18
	minimizeBtn.Text = "➖"
	minimizeBtn.TextColor3 = pal.Accent
	minimizeBtn.AutoButtonColor = false
	minimizeBtn.Parent = header
	UIHelpers.corner(minimizeBtn, 12)
	UIHelpers.stroke(minimizeBtn, pal.Border, 1)

	local minimizeTooltip = UIHelpers.createTooltip(minimizeBtn, "Minimize to Controller")

	minimizeBtn.MouseEnter:Connect(function()
		minimizeTooltip.Visible = true
		Animator:Tween(minimizeBtn, {BackgroundColor3 = pal.Hover}, Animator.Spring.Fast)
	end)
	minimizeBtn.MouseLeave:Connect(function()
		minimizeTooltip.Visible = false
		Animator:Tween(minimizeBtn, {BackgroundColor3 = pal.Elevated}, Animator.Spring.Fast)
	end)

	-- Theme Toggle Pill
	local themeToggle = Instance.new("TextButton")
	themeToggle.Name = "ThemeToggle"
	themeToggle.AnchorPoint = Vector2.new(1, 0.5)
	themeToggle.Position = UDim2.new(1, -92, 0.5, 0)
	themeToggle.Size = UDim2.new(0, 32, 0, 24)
	themeToggle.BackgroundColor3 = pal.Elevated
	themeToggle.BorderSizePixel = 0
	themeToggle.Font = Enum.Font.GothamBold
	themeToggle.TextSize = 14
	themeToggle.Text = Theme.Current == "Dark" and "🌙" or "🌞"
	themeToggle.TextColor3 = pal.Accent
	themeToggle.AutoButtonColor = false
	themeToggle.Parent = header
	UIHelpers.corner(themeToggle, 12)
	UIHelpers.stroke(themeToggle, pal.Border, 1)

	local themeTooltip = UIHelpers.createTooltip(themeToggle, "Theme: " .. Theme.Current)

	themeToggle.MouseEnter:Connect(function()
		themeTooltip.Visible = true
		Animator:Tween(themeToggle, {BackgroundColor3 = pal.Hover}, Animator.Spring.Fast)
	end)
	themeToggle.MouseLeave:Connect(function()
		themeTooltip.Visible = false
		Animator:Tween(themeToggle, {BackgroundColor3 = pal.Elevated}, Animator.Spring.Fast)
	end)

	-- Version badge
	local versionBadge = Instance.new("TextButton")
	versionBadge.Name = Obfuscation.getObfuscatedName("badge")
	versionBadge.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
	versionBadge.BackgroundTransparency = 0.9
	versionBadge.Position = UDim2.new(0, 8, 1, -24)
	versionBadge.Size = UDim2.new(0, 38, 0, 14)
	versionBadge.Font = Enum.Font.GothamBold
	versionBadge.TextSize = 7
	versionBadge.TextColor3 = Color3.fromRGB(0, 255, 200)
	versionBadge.Text = "v" .. Version.Full
	versionBadge.AutoButtonColor = false
	versionBadge.Parent = root
	UIHelpers.corner(versionBadge, 5)
	UIHelpers.stroke(versionBadge, Color3.fromRGB(0, 255, 200), 1)

	local versionTooltip = UIHelpers.createTooltip(versionBadge, string.format(
		"Version: %s | Build: %s | Hash: %s | Channel: %s",
		Version.Full,
		Version.Build,
		Version.Hash,
		Version.Channel
	))

	versionBadge.MouseEnter:Connect(function()
		versionTooltip.Visible = true
		Animator:Tween(versionBadge, {BackgroundTransparency = 0.7}, Animator.Spring.Fast)
	end)
	versionBadge.MouseLeave:Connect(function()
		versionTooltip.Visible = false
		Animator:Tween(versionBadge, {BackgroundTransparency = 0.9}, Animator.Spring.Fast)
	end)

	versionBadge.MouseButton1Click:Connect(function()
		local info = RvrseUI:GetVersionInfo()
		Notifications:Notify({
			Title = "RvrseUI " .. RvrseUI:GetVersionString(),
			Message = string.format("Hash: %s | Channel: %s", info.Hash, info.Channel),
			Duration = 4,
			Type = "info"
		})
	end)

	-- Tab bar
	local tabBar = Instance.new("ScrollingFrame")
	tabBar.BackgroundTransparency = 1
	tabBar.BorderSizePixel = 0
	tabBar.Position = UDim2.new(0, 54, 0, 60)
	tabBar.Size = UDim2.new(1, -66, 0, 40)
	tabBar.CanvasSize = UDim2.new(0, 0, 0, 40)
	tabBar.AutomaticCanvasSize = Enum.AutomaticSize.X
	tabBar.ScrollBarThickness = 4
	tabBar.ScrollBarImageColor3 = pal.Border
	tabBar.ScrollBarImageTransparency = 0.5
	tabBar.ScrollingDirection = Enum.ScrollingDirection.X
	tabBar.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
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
	UIHelpers.corner(body, 12)
	UIHelpers.stroke(body, pal.Border, 1)

	-- Splash screen
	local splash = Instance.new("Frame")
	splash.BackgroundColor3 = pal.Card
	splash.BorderSizePixel = 0
	splash.Position = UDim2.new(0, 12, 0, 108)
	splash.Size = UDim2.new(1, -24, 1, -120)
	splash.ZIndex = 999
	splash.Parent = root
	UIHelpers.corner(splash, 12)

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
	UIHelpers.corner(loadingBar, 2)

	local loadingFill = Instance.new("Frame")
	loadingFill.BackgroundColor3 = pal.Accent
	loadingFill.BorderSizePixel = 0
	loadingFill.Size = UDim2.new(0, 0, 1, 0)
	loadingFill.Parent = loadingBar
	UIHelpers.corner(loadingFill, 2)
	UIHelpers.gradient(loadingFill, 90, {pal.Accent, pal.AccentHover})

	Animator:Tween(loadingFill, {Size = UDim2.new(1, 0, 1, 0)}, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))

	local hideSplashAndShowRoot = function()
		if splash and splash.Parent then
			Animator:Tween(splash, {BackgroundTransparency = 1}, Animator.Spring.Fast)
			task.wait(0.2)
			splash.Visible = false
		end

		root.Visible = true
		print("[RvrseUI] ✨ UI visible - all settings applied")
	end

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
	UIHelpers.corner(chip, 18)
	UIHelpers.stroke(chip, pal.Border, 1)

	local function setHidden(hidden)
		root.Visible = not hidden
		chip.Visible = hidden
	end

	chip.MouseButton1Click:Connect(function() setHidden(false) end)

	-- Gaming Controller Minimize Chip
	local controllerChip = Instance.new("TextButton")
	controllerChip.Name = Obfuscation.getObfuscatedName("chip")
	controllerChip.Text = "🎮"
	controllerChip.Font = Enum.Font.GothamBold
	controllerChip.TextSize = 20
	controllerChip.TextColor3 = pal.Accent
	controllerChip.BackgroundColor3 = pal.Card
	controllerChip.BackgroundTransparency = 0.1
	controllerChip.Size = UDim2.new(0, 50, 0, 50)
	controllerChip.AnchorPoint = Vector2.new(0.5, 0.5)
	controllerChip.Position = UDim2.new(0.5, 0, 0.5, 0)
	controllerChip.Visible = false
	controllerChip.ZIndex = 10000
	controllerChip.Parent = host
	UIHelpers.corner(controllerChip, 25)
	UIHelpers.stroke(controllerChip, pal.Accent, 2)
	UIHelpers.addGlow(controllerChip, pal.Accent, 4)

	-- Add rotating shine effect
	local chipShine = Instance.new("Frame")
	chipShine.Name = "Shine"
	chipShine.BackgroundTransparency = 1
	chipShine.Size = UDim2.new(1, 0, 1, 0)
	chipShine.Position = UDim2.new(0, 0, 0, 0)
	chipShine.ZIndex = 999
	chipShine.Parent = controllerChip
	UIHelpers.corner(chipShine, 25)

	local shineGradient = Instance.new("UIGradient")
	shineGradient.Name = "ShineGradient"
	shineGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.3, 0.8),
		NumberSequenceKeypoint.new(0.5, 0.6),
		NumberSequenceKeypoint.new(0.7, 0.8),
		NumberSequenceKeypoint.new(1, 1)
	})
	shineGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.5, pal.Accent),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
	})
	shineGradient.Rotation = 0
	shineGradient.Parent = chipShine

	local shineRotation
	shineRotation = RS.Heartbeat:Connect(function()
		if controllerChip.Visible and shineGradient then
			shineGradient.Rotation = (shineGradient.Rotation + 2) % 360
		end
	end)

	-- Enhanced particle flow system for minimize/restore transitions
	local function createParticleFlow(startPos, endPos, count, duration, flowType)
		for i = 1, count do
			local particle = Instance.new("Frame")
			particle.Size = UDim2.new(0, math.random(2, 12), 0, math.random(2, 12))
			particle.BackgroundColor3 = pal.Accent
			particle.BackgroundTransparency = math.random(40, 70) / 100
			particle.BorderSizePixel = 0
			particle.Position = UDim2.new(0, startPos.X, 0, startPos.Y)
			particle.ZIndex = 999
			particle.Parent = host
			UIHelpers.corner(particle, math.random(2, 6))

			local delay = (i / count) * (duration * 0.7)
			task.delay(delay, function()
				if not particle or not particle.Parent then return end

				if flowType == "spread" then
					local angle = (i / count) * math.pi * 2
					local spreadRadius = math.random(300, 450)
					local spreadX = endPos.X + math.cos(angle) * spreadRadius
					local spreadY = endPos.Y + math.sin(angle) * spreadRadius
					local midX = (startPos.X + spreadX) / 2 + math.random(-80, 80)
					local midY = (startPos.Y + spreadY) / 2 + math.random(-80, 80)

					Animator:Tween(particle, {
						Position = UDim2.new(0, midX, 0, midY),
						BackgroundTransparency = 0.2,
						Size = UDim2.new(0, math.random(8, 14), 0, math.random(8, 14))
					}, TweenInfo.new(duration * 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out))

					task.wait(duration * 0.5)
					if not particle or not particle.Parent then return end

					Animator:Tween(particle, {
						Position = UDim2.new(0, spreadX, 0, spreadY),
						BackgroundTransparency = 0.3,
						Size = UDim2.new(0, math.random(6, 10), 0, math.random(6, 10))
					}, TweenInfo.new(duration * 0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut))

					task.wait(duration * 0.45)
					if not particle or not particle.Parent then return end

					local orbitX = spreadX + math.random(-30, 30)
					local orbitY = spreadY + math.random(-30, 30)
					Animator:Tween(particle, {
						Position = UDim2.new(0, orbitX, 0, orbitY),
						BackgroundTransparency = 0.6,
						Size = UDim2.new(0, math.random(4, 8), 0, math.random(4, 8))
					}, TweenInfo.new(duration * 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut))

					task.wait(duration * 0.3)
					if not particle or not particle.Parent then return end

					Animator:Tween(particle, {
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 2, 0, 2)
					}, TweenInfo.new(duration * 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))

					task.wait(duration * 0.25)
					if particle and particle.Parent then
						particle:Destroy()
					end
				else
					local angle = (i / count) * math.pi * 2
					local gatherRadius = math.random(300, 450)
					local gatherStartX = startPos.X + math.cos(angle) * gatherRadius
					local gatherStartY = startPos.Y + math.sin(angle) * gatherRadius

					particle.Position = UDim2.new(0, gatherStartX, 0, gatherStartY)
					particle.BackgroundTransparency = 0.6
					particle.Size = UDim2.new(0, math.random(4, 10), 0, math.random(4, 10))

					local midX = (gatherStartX + endPos.X) / 2 + math.random(-80, 80)
					local midY = (gatherStartY + endPos.Y) / 2 + math.random(-80, 80)

					Animator:Tween(particle, {
						Position = UDim2.new(0, midX, 0, midY),
						BackgroundTransparency = 0.2,
						Size = UDim2.new(0, math.random(8, 12), 0, math.random(8, 12))
					}, TweenInfo.new(duration * 0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.In))

					task.wait(duration * 0.45)
					if not particle or not particle.Parent then return end

					Animator:Tween(particle, {
						Position = UDim2.new(0, endPos.X, 0, endPos.Y),
						BackgroundTransparency = 0.1,
						Size = UDim2.new(0, math.random(5, 8), 0, math.random(5, 8))
					}, TweenInfo.new(duration * 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut))

					task.wait(duration * 0.5)
					if not particle or not particle.Parent then return end

					Animator:Tween(particle, {
						Position = UDim2.new(0, endPos.X, 0, endPos.Y),
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 1, 0, 1)
					}, TweenInfo.new(duration * 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In))

					task.wait(duration * 0.25)
					if particle and particle.Parent then
						particle:Destroy()
					end
				end
			end)
		end
	end

	local isMinimized = false

	local function minimizeWindow()
		if isMinimized then return end
		isMinimized = true
		Animator:Ripple(minimizeBtn, 16, 12)

		local screenSize = workspace.CurrentCamera.ViewportSize
		local chipTargetPos = UDim2.new(0.5, 0, 0.5, 0)
		if RvrseUI._controllerChipPosition then
			local saved = RvrseUI._controllerChipPosition
			chipTargetPos = UDim2.new(saved.XScale, saved.XOffset, saved.YScale, saved.YOffset)
		end

		local chipTargetX = chipTargetPos.X.Scale * screenSize.X + chipTargetPos.X.Offset
		local chipTargetY = chipTargetPos.Y.Scale * screenSize.Y + chipTargetPos.Y.Offset

		local rootPos = root.AbsolutePosition
		local rootSize = root.AbsoluteSize
		local windowCenterX = rootPos.X + (rootSize.X / 2)
		local windowCenterY = rootPos.Y + (rootSize.Y / 2)

		createParticleFlow(
			{X = windowCenterX, Y = windowCenterY},
			{X = chipTargetX, Y = chipTargetY},
			120,
			1.2,
			"gather"
		)

		Animator:Tween(root, {
			Size = UDim2.new(0, 0, 0, 0),
			Position = chipTargetPos,
			BackgroundTransparency = 1,
			Rotation = 180
		}, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In))

		Animator:Tween(glassOverlay, {
			BackgroundTransparency = 1
		}, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In))

		task.wait(0.6)
		if isMinimized then
			root.Visible = false
			controllerChip.Visible = true
			controllerChip.Size = UDim2.new(0, 0, 0, 0)

			Animator:Tween(controllerChip, {
				Size = UDim2.new(0, 50, 0, 50)
			}, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
		end
	end

	local function restoreWindow()
		if not isMinimized then return end
		isMinimized = false
		Animator:Ripple(controllerChip, 25, 25)

		local screenSize = workspace.CurrentCamera.ViewportSize
		local chipPos = controllerChip.AbsolutePosition
		local chipCenterX = chipPos.X + 25
		local chipCenterY = chipPos.Y + 25

		local targetSize = isMobile and UDim2.new(0, 380, 0, 520) or UDim2.new(0, baseWidth, 0, baseHeight)
		local targetPos = UDim2.new(0.5, 0, 0.5, 0)
		if RvrseUI._lastWindowPosition then
			local savedPos = RvrseUI._lastWindowPosition
			targetPos = UDim2.new(savedPos.XScale, savedPos.XOffset, savedPos.YScale, savedPos.YOffset)
		end

		local targetWidth = isMobile and 380 or baseWidth
		local targetHeight = isMobile and 520 or baseHeight
		local windowCenterX = targetPos.X.Scale * screenSize.X + targetPos.X.Offset + (targetWidth / 2)
		local windowCenterY = targetPos.Y.Scale * screenSize.Y + targetPos.Y.Offset + (targetHeight / 2)

		createParticleFlow(
			{X = chipCenterX, Y = chipCenterY},
			{X = windowCenterX, Y = windowCenterY},
			120,
			1.2,
			"spread"
		)

		Animator:Tween(controllerChip, {
			Size = UDim2.new(0, 0, 0, 0)
		}, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In))

		task.wait(0.3)
		controllerChip.Visible = false

		root.Visible = true
		root.Size = UDim2.new(0, 0, 0, 0)
		root.Position = controllerChip.Position
		root.Rotation = -180
		root.BackgroundTransparency = 1
		glassOverlay.BackgroundTransparency = 1

		Animator:Tween(root, {
			Size = targetSize,
			Position = targetPos,
			BackgroundTransparency = 0.05,
			Rotation = 0
		}, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out))

		Animator:Tween(glassOverlay, {
			BackgroundTransparency = Theme.Current == "Dark" and 0.97 or 0.95
		}, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out))
	end

	minimizeBtn.MouseButton1Click:Connect(minimizeWindow)

	-- ═══════════════════════════════════════════════════════════════
	-- ADVANCED CURSOR-LOCKED DRAG SYSTEM - Controller Chip
	-- ═══════════════════════════════════════════════════════════════
	-- Ensures the cursor stays perfectly glued to the exact grab point
	-- on the chip. Uses AnchorPoint (0.5, 0.5) so chip rotates around
	-- center, and maintains sub-pixel precision during drag.
	-- ═══════════════════════════════════════════════════════════════

	local chipDragging = false
	local chipWasDragged = false
	local chipDragThreshold = false
	local chipDragOffset = nil  -- Offset from pointer to chip center at grab time
	local chipActiveDragInput = nil

	-- Restore window on click (only if not dragged)
	controllerChip.MouseButton1Click:Connect(function()
		if not chipWasDragged then
			restoreWindow()
		end
		chipWasDragged = false
	end)

	-- Hover effects
	controllerChip.MouseEnter:Connect(function()
		Animator:Tween(controllerChip, {
			Size = UDim2.new(0, 60, 0, 60)
		}, Animator.Spring.Fast)
	end)

	controllerChip.MouseLeave:Connect(function()
		Animator:Tween(controllerChip, {
			Size = UDim2.new(0, 50, 0, 50)
		}, Animator.Spring.Fast)
	end)

	-- Start chip drag
	controllerChip.InputBegan:Connect(function(io)
		if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
			chipDragging = true
			chipWasDragged = false
			chipDragThreshold = false
			chipActiveDragInput = io
			chipDragOffset = nil  -- Will be calculated on first movement

			Debug.printf("[CHIP DRAG] Started - input type: %s", tostring(io.UserInputType))
		end
	end)

	-- End chip drag and save position
	controllerChip.InputEnded:Connect(function(io)
		if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
			if chipDragging and io == chipActiveDragInput then
				chipDragging = false
				chipActiveDragInput = nil
				chipDragOffset = nil

				-- Save final position
				RvrseUI._controllerChipPosition = {
					XScale = controllerChip.Position.X.Scale,
					XOffset = controllerChip.Position.X.Offset,
					YScale = controllerChip.Position.Y.Scale,
					YOffset = controllerChip.Position.Y.Offset
				}

				Debug.printf("[CHIP DRAG] Finished - saved position: X=%d, Y=%d",
					controllerChip.AbsolutePosition.X, controllerChip.AbsolutePosition.Y)
			end
		end
	end)

	-- Main chip drag update loop - maintains cursor lock
	UIS.InputChanged:Connect(function(io)
		if not chipDragging or not controllerChip.Visible then
			return
		end

		-- Check if this is our active drag input
		local isMouseDrag = io.UserInputType == Enum.UserInputType.MouseMovement
			and chipActiveDragInput
			and chipActiveDragInput.UserInputType == Enum.UserInputType.MouseButton1
		local isTouchDrag = io == chipActiveDragInput

		if not isMouseDrag and not isTouchDrag then
			return
		end

		-- Get current pointer position in UI space
		local mouseLocation = UIS:GetMouseLocation()
		local guiInset = GuiService:GetGuiInset()
		local pointerInUI = Vector2.new(
			mouseLocation.X - guiInset.X,
			mouseLocation.Y - guiInset.Y
		)

		-- Calculate chip center in UI space
		-- AnchorPoint is (0.5, 0.5) so AbsolutePosition IS the center
		local chipCenterInUI = controllerChip.AbsolutePosition - Vector2.new(guiInset.X, guiInset.Y)

		-- On first move, cache the exact offset from pointer to chip center
		if not chipDragOffset then
			chipDragOffset = pointerInUI - chipCenterInUI
			Debug.printf("[CHIP DRAG] Cached grab offset: X=%.2f, Y=%.2f", chipDragOffset.X, chipDragOffset.Y)
		end

		-- Check if we've moved enough to activate dragging (prevents accidental drags)
		if not chipDragThreshold then
			local dragDistance = (pointerInUI - chipCenterInUI).Magnitude
			if dragDistance > 5 then
				chipDragThreshold = true
				chipWasDragged = true
				Debug.printf("[CHIP DRAG] Threshold exceeded - drag activated")
			else
				return  -- Don't move yet
			end
		end

		-- Calculate target position: pointer - cached offset = new center
		local targetCenterX = pointerInUI.X - chipDragOffset.X
		local targetCenterY = pointerInUI.Y - chipDragOffset.Y

		-- Get screen bounds and chip size for clamping
		local currentScreenSize = workspace.CurrentCamera.ViewportSize
		local chipSize = controllerChip.AbsoluteSize.X
		local halfSize = chipSize / 2

		-- Clamp to keep chip fully on screen
		local minX = halfSize
		local maxX = currentScreenSize.X - halfSize
		local minY = halfSize
		local maxY = currentScreenSize.Y - halfSize

		targetCenterX = math.clamp(targetCenterX, minX, maxX)
		targetCenterY = math.clamp(targetCenterY, minY, maxY)

		-- Apply position - cursor is now perfectly locked to grab point
		-- Since AnchorPoint is (0.5, 0.5), Position.Offset IS the center
		controllerChip.Position = UDim2.fromOffset(
			math.floor(targetCenterX + 0.5),
			math.floor(targetCenterY + 0.5)
		)
	end)

	if RvrseUI._controllerChipPosition then
		local savedPos = RvrseUI._controllerChipPosition
		controllerChip.Position = UDim2.new(
			savedPos.XScale,
			savedPos.XOffset,
			savedPos.YScale,
			savedPos.YOffset
		)
	end

	-- Save and restore window position
	local windowData = {
		isMinimized = function() return isMinimized end,
		restoreFunction = restoreWindow,
		minimizeFunction = minimizeWindow,
		destroyFunction = nil
	}
	RvrseUI.UI:RegisterToggleTarget(root, windowData)

	-- Tab management
	local activePage
	local tabs = {}

	
	function WindowAPI:SetTitle(t) title.Text = t or name end
	function WindowAPI:Show() setHidden(false) end
	function WindowAPI:Hide() setHidden(true) end

	function WindowAPI:SetIcon(newIcon)
		if not newIcon then return end

		for _, child in ipairs(iconHolder:GetChildren()) do
			if child:IsA("ImageLabel") or child:IsA("TextLabel") then
				child:Destroy()
			end
		end

		local iconAsset, iconType = Icons.resolveIcon(newIcon)

		if iconType == "image" then
			local img = Instance.new("ImageLabel")
			img.BackgroundTransparency = 1
			img.Image = iconAsset
			img.Size = UDim2.new(1, 0, 1, 0)
			img.ImageColor3 = pal.Accent
			img.Parent = iconHolder
			UIHelpers.corner(img, 8)
		elseif iconType == "text" then
			local iconTxt = Instance.new("TextLabel")
			iconTxt.BackgroundTransparency = 1
			iconTxt.Font = Enum.Font.GothamBold
			iconTxt.TextSize = 20
			iconTxt.TextColor3 = pal.Accent
			iconTxt.Text = iconAsset
			iconTxt.Size = UDim2.new(1, 0, 1, 0)
			iconTxt.Parent = iconHolder
		end
	end

	function WindowAPI:Destroy()
		Animator:Tween(root, {BackgroundTransparency = 1}, Animator.Spring.Fast)
		Animator:Tween(chip, {BackgroundTransparency = 1}, Animator.Spring.Fast)
		task.wait(0.3)

		if host and host.Parent then
			host:Destroy()
		end

		if RvrseUI.UI._toggleTargets then
			table.clear(RvrseUI.UI._toggleTargets)
		end
		if RvrseUI._lockListeners then
			table.clear(RvrseUI._lockListeners)
		end
		if RvrseUI._themeListeners then
			table.clear(RvrseUI._themeListeners)
		end

		print("[RvrseUI] Interface destroyed - All traces removed")
	end

	windowData.destroyFunction = function()
		WindowAPI:Destroy()
	end

	function WindowAPI:Show()
		task.delay(0.9, function()
			if RvrseUI.ConfigurationSaving and RvrseUI.ConfigurationFileName then
				print("[RvrseUI] 📂 Loading configuration (after elements created)...")
				local success, message = RvrseUI:LoadConfiguration()
				if success then
					print("[RvrseUI] ✅ Configuration loaded successfully")
				else
					print("[RvrseUI] ⚠️ Config load warning:", message)
				end
				task.wait(0.1)
			end

			hideSplashAndShowRoot()
		end)
	end

	-- CreateTab uses TabBuilder module
	function WindowAPI:CreateTab(t)
		return TabBuilder.CreateTab(t, {
			Theme = Theme,
			UIHelpers = UIHelpers,
			Animator = Animator,
			Icons = Icons,
			SectionBuilder = SectionBuilder,
			tabBar = tabBar,
			body = body,
			tabs = tabs,
			activePage = activePage,
			RvrseUI = RvrseUI,
			Elements = Elements,
			UIS = UIS,
			OverlayLayer = overlayLayer
		})
	end

	if RvrseUI.ConfigurationSaving and cfg.ConfigurationManager ~= false then
		task.defer(function()
			local ok, err = pcall(function()
				local managerOptions = typeof(cfg.ConfigurationManager) == "table" and cfg.ConfigurationManager or {}
				local tabTitle = managerOptions.TabName or "Profiles"
				local tabIcon = managerOptions.Icon or "folder"
				local sectionTitle = managerOptions.SectionTitle or "Configuration Profiles"
				local profilePlaceholder = managerOptions.NewProfilePlaceholder or "my_profile"
				local dropdownPlaceholder = managerOptions.DropdownPlaceholder or "Select profile"

				local function safeNotify(title, message, kind)
					local notifyPayload = {
						Title = title or "Profiles",
						Message = message or "",
						Duration = 3,
						Type = kind or "info"
					}
					local okNotify = pcall(function()
						return RvrseUI:Notify(notifyPayload)
					end)
					if not okNotify then
						print("[RvrseUI]", notifyPayload.Title .. ":", notifyPayload.Message)
					end
				end

				local function trim(str)
					return (str:gsub("^%s+", ""):gsub("%s+$", ""))
				end

				local function containsValue(list, value)
					for _, item in ipairs(list) do
						if item == value then
							return true
						end
					end
					return false
				end

				local profilesTab = WindowAPI:CreateTab({
					Title = tabTitle,
					Icon = tabIcon
				})
				local profileSection = profilesTab:CreateSection(sectionTitle)

				local folderLabel = profileSection:CreateLabel({
					Text = "Folder: " .. (RvrseUI.ConfigurationFolderName or "(workspace)")
				})

				local activeLabel = profileSection:CreateLabel({
					Text = "Active Profile: " .. (RvrseUI.ConfigurationFileName or "none")
				})

				local selectedProfile = RvrseUI.ConfigurationFileName
				local lastProfileList = {}
				local profilesDropdown

				local function updateLabels(profileName)
					folderLabel:Set("Folder: " .. (RvrseUI.ConfigurationFolderName or "(workspace)"))
					activeLabel:Set("Active Profile: " .. (profileName or "none"))
				end

				local function gatherProfiles()
					local list, warning = RvrseUI:ListProfiles()
					list = list or {}
					table.sort(list)
					return list, warning
				end

				local function refreshProfiles(target, opts)
					opts = opts or {}
					local list, warning = gatherProfiles()
					lastProfileList = list
					profilesDropdown:Refresh(list)
					if warning and not opts.suppressWarning and managerOptions.SuppressWarnings ~= true then
						safeNotify("Profiles", tostring(warning), "warning")
					end

					local resolveTarget = target
					if resolveTarget and not containsValue(list, resolveTarget) then
						resolveTarget = nil
					end
					if not resolveTarget and selectedProfile and containsValue(list, selectedProfile) then
						resolveTarget = selectedProfile
					end
					if not resolveTarget and list[1] then
						resolveTarget = list[1]
					end

					selectedProfile = resolveTarget
					if resolveTarget then
						profilesDropdown:Set(resolveTarget, true)
						updateLabels(resolveTarget)
					else
						updateLabels(nil)
					end

					return list
				end

				local function applyProfile(profileName, opts)
					opts = opts or {}
					if not profileName or profileName == "" then
						safeNotify("Profiles", "No profile selected", "warning")
						return false
					end

					local base = profileName:gsub("%.json$", "")
					local setOk, setMsg = RvrseUI:SetConfigProfile(base)
					if not setOk then
						safeNotify("Profiles", tostring(setMsg), "error")
						return false
					end

					local loadOk, loadMsg = RvrseUI:LoadConfigByName(base)
					if loadOk then
						selectedProfile = profileName
						refreshProfiles(profileName, {suppressWarning = true})
						if not opts.muteNotify then
							safeNotify("Profiles", "Loaded " .. profileName, "success")
						end
						return true
					else
						safeNotify("Profiles", "Load failed: " .. tostring(loadMsg), "error")
						return false
					end
				end

				profilesDropdown = profileSection:CreateDropdown({
					Text = "Profiles",
					Values = {},
					PlaceholderText = dropdownPlaceholder,
					Overlay = true,
					OnOpen = function()
						refreshProfiles(selectedProfile, {suppressWarning = true})
					end,
					OnChanged = function(value)
						if not value or value == "" then return end
						if not containsValue(lastProfileList, value) then
							return
						end
						if value == selectedProfile then
							updateLabels(value)
							return
						end
						applyProfile(value)
					end
				})

				local newProfileName = ""
				local nameInput = profileSection:CreateTextBox({
					Text = "New Profile",
					Placeholder = profilePlaceholder,
					OnChanged = function(value)
						newProfileName = trim(value or "")
					end
				})

				profileSection:CreateButton({
					Text = "🔄 Refresh Profiles",
					Callback = function()
						refreshProfiles(selectedProfile)
						safeNotify("Profiles", "Profile list refreshed", "info")
					end
				})

				profileSection:CreateButton({
					Text = "💾 Save Current",
					Callback = function()
						local okSave, saveMsg = RvrseUI:SaveConfiguration()
						if okSave then
							local active = RvrseUI.ConfigurationFileName or selectedProfile
							safeNotify("Profiles", "Saved to " .. tostring(active or "config"), "success")
							refreshProfiles(active, {suppressWarning = true})
						else
							safeNotify("Profiles", "Save failed: " .. tostring(saveMsg), "error")
						end
					end
				})

				profileSection:CreateButton({
					Text = "📁 Save As",
					Callback = function()
						local trimmed = trim(newProfileName)
						if trimmed == "" then
							safeNotify("Profiles", "Enter a profile name first", "warning")
							return
						end
						local okSaveAs, saveAsMsg = RvrseUI:SaveConfigAs(trimmed)
						if okSaveAs then
							local fileName = trimmed:gsub("%.json$", "") .. ".json"
							safeNotify("Profiles", "Saved " .. fileName, "success")
							refreshProfiles(fileName, {suppressWarning = true})
							if managerOptions.ClearNameAfterSave ~= false then
								newProfileName = ""
								nameInput:Set("")
							end
						else
							safeNotify("Profiles", "Save As failed: " .. tostring(saveAsMsg), "error")
						end
					end
				})

				profileSection:CreateButton({
					Text = "↻ Load Selected",
					Callback = function()
						if not selectedProfile then
							safeNotify("Profiles", "No profile selected", "warning")
							return
						end
						applyProfile(selectedProfile, {muteNotify = false})
					end
				})

				profileSection:CreateButton({
					Text = "🗑️ Delete Profile",
					Callback = function()
						if not selectedProfile then
							safeNotify("Profiles", "No profile selected", "warning")
							return
						end
						local base = selectedProfile:gsub("%.json$", "")
						local okDelete, deleteMsg = RvrseUI:DeleteProfile(base)
						if okDelete then
							safeNotify("Profiles", "Deleted " .. selectedProfile, "warning")
							selectedProfile = nil
							refreshProfiles(nil, {suppressWarning = true})
						else
							safeNotify("Profiles", "Delete failed: " .. tostring(deleteMsg), "error")
						end
					end
				})

				profileSection:CreateToggle({
					Text = "Auto Save",
					State = RvrseUI:IsAutoSaveEnabled(),
					OnChanged = function(state)
						RvrseUI:SetAutoSaveEnabled(state)
						safeNotify("Profiles", state and "Auto save enabled" or "Auto save disabled", state and "info" or "warning")
					end
				})

				refreshProfiles(selectedProfile, {suppressWarning = true})
			end)
			if not ok then
				warn("[RvrseUI] Config manager initialization failed:", err)
			end
		end)
	end

	-- Welcome notifications
	if not cfg.DisableBuildWarnings then
		Notifications:Notify({Title = "RvrseUI v2.0", Message = "Modern UI loaded successfully", Duration = 2, Type = "success"})
	end
	if not cfg.DisableRvrseUIPrompts then
		Notifications:Notify({Title = "Tip", Message = "Press " .. toggleKey.Name .. " to toggle UI", Duration = 3, Type = "info"})
	end

	-- Pill sync and theme toggle (lines 3816-3916)
	local function syncPillFromTheme()
		local t = Theme.Current
		local currentPal = Theme:Get()
		themeToggle.Text = t == "Dark" and "🌙" or "🌞"
		themeToggle.TextColor3 = currentPal.Accent
		themeToggle.BackgroundColor3 = currentPal.Elevated
		themeTooltip.Text = "  Theme: " .. t .. "  "
		UIHelpers.stroke(themeToggle, currentPal.Border, 1)
	end

	themeToggle.MouseButton1Click:Connect(function()
		local newTheme = Theme.Current == "Dark" and "Light" or "Dark"
		Theme:Switch(newTheme)

		local newPal = Theme:Get()

		syncPillFromTheme()

		glassOverlay.BackgroundColor3 = newTheme == "Dark"
			and Color3.fromRGB(255, 255, 255)
			or Color3.fromRGB(245, 245, 250)

		root.BackgroundColor3 = newPal.Bg
		UIHelpers.stroke(root, newPal.Border, 1)

		header.BackgroundColor3 = newPal.Card
		UIHelpers.stroke(header, newPal.Border, 1)
		headerDivider.BackgroundColor3 = newPal.Divider
		title.TextColor3 = newPal.Text

		minimizeBtn.BackgroundColor3 = newPal.Elevated
		minimizeBtn.TextColor3 = newPal.Accent
		UIHelpers.stroke(minimizeBtn, newPal.Border, 1)

		bellToggle.BackgroundColor3 = newPal.Elevated
		bellToggle.TextColor3 = newPal.Accent
		UIHelpers.stroke(bellToggle, newPal.Border, 1)

		closeBtn.BackgroundColor3 = newPal.Elevated
		closeBtn.TextColor3 = newPal.Error
		UIHelpers.stroke(closeBtn, newPal.Border, 1)

		controllerChip.BackgroundColor3 = newPal.Card
		controllerChip.TextColor3 = newPal.Accent
		UIHelpers.stroke(controllerChip, newPal.Accent, 2)
		if controllerChip:FindFirstChild("Glow") then
			controllerChip.Glow.Color = newPal.Accent
		end

		body.BackgroundColor3 = newPal.Card
		UIHelpers.stroke(body, newPal.Border, 1)

		tabBar.ScrollBarImageColor3 = newPal.Border

		for _, tabData in ipairs(tabs) do
			tabData.btn.BackgroundColor3 = newPal.Card
			tabData.btn.TextColor3 = newPal.TextSub
			tabData.indicator.BackgroundColor3 = newPal.Accent
			tabData.page.ScrollBarImageColor3 = newPal.Border

			if tabData.icon then
				tabData.icon.ImageColor3 = newPal.TextSub
			end
		end

		Animator:Ripple(themeToggle, 25, 12)

		if RvrseUI.ConfigurationSaving then
			RvrseUI:_autoSave()
		end

		Notifications:Notify({
			Title = "Theme Changed",
			Message = "Switched to " .. newTheme .. " mode",
			Duration = 2,
			Type = "info"
		})
	end)

	task.defer(syncPillFromTheme)

	table.insert(RvrseUI._windows, WindowAPI)

	return WindowAPI
end


-- Return the framework
return RvrseUI
