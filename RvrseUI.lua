-- RvrseUI v4.0.3 | Cyberpunk Neon UI Framework
-- Compiled from modular architecture on 2025-10-18T18:27:02.424Z

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

do
	
	Version = {}
	
	Version.Data = {
		Major = 4,
		Minor = 0,
		Patch = 3,
		Build = "20251017b",  -- YYYYMMDD format
		Full = "4.0.3",
		Hash = "P8X4N7Q2",  -- Release hash for integrity verification
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
end


-- ========================
-- Debug Module
-- ========================

do
	
	Debug = {}
	
	Debug.Enabled = false  -- Global debug toggle (disabled by default for production)
	Debug.enabled = Debug.Enabled  -- Back-compat alias for legacy references
	
	function Debug:SetEnabled(state)
		local flag = state and true or false
		self.Enabled = flag
		self.enabled = flag
	end
	
	function Debug:IsEnabled()
		return self.Enabled and true or false
	end
	
	function Debug:Print(...)
		if self:IsEnabled() then
			print("[RvrseUI]", ...)
		end
	end
	
	Debug.Log = Debug.Print
	
	function Debug.printf(fmt, ...)
		if not Debug:IsEnabled() then
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
end


-- ========================
-- Obfuscation Module
-- ========================

do
	
	Obfuscation = {}
	
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
end


-- ========================
-- Icons Module
-- ========================

do
	
	Icons = {}
	
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
end


-- ========================
-- Theme Module
-- ========================

do
	
	Theme = {}
	
	Theme.Palettes = {
		Dark = {
			-- 🌌 ULTRA HIGH VISIBILITY (Red debug test confirmed UI renders!)
			Bg = Color3.fromRGB(50, 50, 70),            -- Window background
			Glass = Color3.fromRGB(60, 60, 85),         -- Glass effect
			Card = Color3.fromRGB(70, 70, 100),         -- Tab rail, header
			Elevated = Color3.fromRGB(85, 85, 120),     -- Body container (main content area)
			Surface = Color3.fromRGB(65, 65, 95),       -- Standard surface
	
			-- 🌈 Vibrant gradient accents - Electric Purple to Cyan
			Primary = Color3.fromRGB(138, 43, 226),     -- Electric purple (BlueViolet)
			PrimaryGlow = Color3.fromRGB(168, 85, 247), -- Lighter purple glow
			Secondary = Color3.fromRGB(0, 229, 255),    -- Electric cyan
			SecondaryGlow = Color3.fromRGB(34, 211, 238), -- Cyan glow
	
			-- 🎯 Main accent - Vibrant magenta/pink
			Accent = Color3.fromRGB(236, 72, 153),      -- Hot pink
			AccentHover = Color3.fromRGB(251, 113, 133),-- Lighter pink on hover
			AccentActive = Color3.fromRGB(219, 39, 119),-- Darker pink when active
			AccentGlow = Color3.fromRGB(249, 168, 212), -- Pink glow effect
	
			-- ✨ Text hierarchy - Crystal clear with vibrant highlights
			Text = Color3.fromRGB(248, 250, 252),       -- Almost white, perfect clarity
			TextBright = Color3.fromRGB(255, 255, 255), -- Pure white for emphasis
			TextSub = Color3.fromRGB(203, 213, 225),    -- Subtle gray for secondary
			TextMuted = Color3.fromRGB(148, 163, 184),  -- Muted for tertiary
			TextDim = Color3.fromRGB(100, 116, 139),    -- Very dim for hints
	
			-- 🎨 Status colors - Vibrant and eye-catching
			Success = Color3.fromRGB(34, 197, 94),      -- Vibrant green
			SuccessGlow = Color3.fromRGB(74, 222, 128), -- Green glow
			Warning = Color3.fromRGB(251, 146, 60),     -- Vibrant orange
			WarningGlow = Color3.fromRGB(253, 186, 116),-- Orange glow
			Error = Color3.fromRGB(248, 113, 113),      -- Bright red
			ErrorGlow = Color3.fromRGB(252, 165, 165),  -- Red glow
			Info = Color3.fromRGB(96, 165, 250),        -- Sky blue
			InfoGlow = Color3.fromRGB(147, 197, 253),   -- Blue glow
	
			-- 🔲 Borders & dividers - ENHANCED for crisp visibility
			Border = Color3.fromRGB(71, 85, 105),       -- Primary border (increased from 51,65,85)
			BorderBright = Color3.fromRGB(100, 116, 139), -- Bright border (increased contrast)
			BorderGlow = Color3.fromRGB(168, 85, 247),  -- Neon purple glow (brighter)
			Divider = Color3.fromRGB(51, 65, 85),       -- Divider line (increased from 30,41,59)
			DividerBright = Color3.fromRGB(71, 85, 105), -- Bright divider (more visible)
			GlossTop = Color3.fromRGB(255, 255, 255),   -- Gloss highlight top
			GlossBottom = Color3.fromRGB(120, 120, 160), -- Gloss subtle bottom
	
			-- 🎮 Interactive states - Smooth and responsive
			Hover = Color3.fromRGB(30, 30, 50),         -- Hover overlay
			HoverBright = Color3.fromRGB(40, 40, 65),   -- Bright hover
			Active = Color3.fromRGB(50, 50, 80),        -- Active/pressed state
			Selected = Color3.fromRGB(45, 45, 75),      -- Selected state
			Disabled = Color3.fromRGB(71, 85, 105),     -- Disabled gray
			DisabledText = Color3.fromRGB(100, 116, 139),-- Disabled text
	
			-- 🌟 Special effects
			Glow = Color3.fromRGB(168, 85, 247),        -- General glow effect
			Shadow = Color3.fromRGB(0, 0, 0),           -- Shadow color
			Shimmer = Color3.fromRGB(255, 255, 255),    -- Shimmer highlight
			Overlay = Color3.fromRGB(0, 0, 0),          -- Dark overlay
	
			-- 🎭 Gradient stops for advanced effects
			GradientStart = Color3.fromRGB(138, 43, 226),  -- Purple
			GradientMid = Color3.fromRGB(236, 72, 153),    -- Pink
			GradientEnd = Color3.fromRGB(0, 229, 255),     -- Cyan
		},
	
		Light = {
			-- ☀️ LIGHT MODE - Clean, modern, high contrast
			Bg = Color3.fromRGB(248, 250, 252),         -- Light window background
			Glass = Color3.fromRGB(241, 245, 249),      -- Light glass effect
			Card = Color3.fromRGB(255, 255, 255),       -- White cards
			Elevated = Color3.fromRGB(248, 250, 252),   -- Elevated surfaces
			Surface = Color3.fromRGB(255, 255, 255),    -- White surface
	
			-- 🌈 Vibrant gradient accents - Same as dark but adjusted
			Primary = Color3.fromRGB(138, 43, 226),     -- Electric purple
			PrimaryGlow = Color3.fromRGB(168, 85, 247), -- Purple glow
			Secondary = Color3.fromRGB(0, 191, 255),    -- Deep sky blue
			SecondaryGlow = Color3.fromRGB(34, 211, 238), -- Cyan glow
	
			-- 🎯 Main accent - Vibrant magenta/pink
			Accent = Color3.fromRGB(236, 72, 153),      -- Hot pink
			AccentHover = Color3.fromRGB(219, 39, 119), -- Darker pink on hover
			AccentActive = Color3.fromRGB(190, 24, 93), -- Even darker when active
			AccentGlow = Color3.fromRGB(251, 113, 133), -- Pink glow
	
			-- ✨ Text hierarchy - Dark text on light background
			Text = Color3.fromRGB(15, 23, 42),          -- Very dark gray (almost black)
			TextBright = Color3.fromRGB(0, 0, 0),       -- Pure black for emphasis
			TextSub = Color3.fromRGB(51, 65, 85),       -- Medium gray for secondary
			TextMuted = Color3.fromRGB(100, 116, 139),  -- Light gray for tertiary
			TextDim = Color3.fromRGB(148, 163, 184),    -- Very light gray for hints
	
			-- 🎨 Status colors - Vibrant and eye-catching
			Success = Color3.fromRGB(34, 197, 94),      -- Vibrant green
			SuccessGlow = Color3.fromRGB(74, 222, 128), -- Green glow
			Warning = Color3.fromRGB(251, 146, 60),     -- Vibrant orange
			WarningGlow = Color3.fromRGB(253, 186, 116),-- Orange glow
			Error = Color3.fromRGB(239, 68, 68),        -- Bright red
			ErrorGlow = Color3.fromRGB(248, 113, 113),  -- Red glow
			Info = Color3.fromRGB(59, 130, 246),        -- Blue
			InfoGlow = Color3.fromRGB(96, 165, 250),    -- Blue glow
	
			-- 🔲 Borders & dividers - ENHANCED for crisp visibility
			Border = Color3.fromRGB(203, 213, 225),     -- Primary border (darker for contrast)
			BorderBright = Color3.fromRGB(148, 163, 184), -- Bright border (more visible)
			BorderGlow = Color3.fromRGB(168, 85, 247),  -- Neon purple glow (brighter)
			Divider = Color3.fromRGB(226, 232, 240),    -- Divider line (darker from 241,245,249)
			DividerBright = Color3.fromRGB(203, 213, 225), -- Bright divider (more contrast)
			GlossTop = Color3.fromRGB(255, 255, 255),   -- Gloss highlight top
			GlossBottom = Color3.fromRGB(241, 245, 249), -- Gloss subtle bottom
	
			-- 🎮 Interactive states - Smooth and responsive
			Hover = Color3.fromRGB(241, 245, 249),      -- Light hover overlay
			HoverBright = Color3.fromRGB(226, 232, 240),-- Darker hover
			Active = Color3.fromRGB(226, 232, 240),     -- Active/pressed state
			Selected = Color3.fromRGB(219, 234, 254),   -- Selected state (light blue)
			Disabled = Color3.fromRGB(203, 213, 225),   -- Disabled gray
			DisabledText = Color3.fromRGB(148, 163, 184),-- Disabled text
	
			-- 🌟 Special effects
			Glow = Color3.fromRGB(168, 85, 247),        -- Purple glow effect
			Shadow = Color3.fromRGB(0, 0, 0),           -- Shadow color
			Shimmer = Color3.fromRGB(255, 255, 255),    -- Shimmer highlight
			Overlay = Color3.fromRGB(15, 23, 42),       -- Dark overlay for modals
	
			-- 🎭 Gradient stops for advanced effects
			GradientStart = Color3.fromRGB(138, 43, 226),  -- Purple
			GradientMid = Color3.fromRGB(236, 72, 153),    -- Pink
			GradientEnd = Color3.fromRGB(0, 191, 255),     -- Sky blue
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
end


-- ========================
-- Animator Module
-- ========================

do
	
	local TweenService = game:GetService("TweenService")
	
	Animator = {}
	
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
	
	function Animator:Tween(obj, props, info)
		info = info or self.Spring.Butter
		local tween = TweenService:Create(obj, info, props)
		tween:Play()
		return tween
	end
	
	function Animator:Scale(obj, scale, info)
		return self:Tween(obj, {Size = UDim2.new(scale, 0, scale, 0)}, info or self.Spring.Pop)
	end
	
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
	
	function Animator:Pulse(obj, scale, info)
		scale = scale or 1.05
		info = info or self.Spring.Bounce
	
		local originalSize = obj.Size
		-- Properly scale UDim2 by multiplying each component
		local scaledSize = UDim2.new(
			originalSize.X.Scale * scale,
			originalSize.X.Offset * scale,
			originalSize.Y.Scale * scale,
			originalSize.Y.Offset * scale
		)
	
		self:Tween(obj, {Size = scaledSize}, info)
	
		task.delay(info.Time, function()
			self:Tween(obj, {Size = originalSize}, info)
		end)
	end
	
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
	
	function Animator:FadeIn(obj, startTransparency, info)
		startTransparency = startTransparency or 1
		info = info or self.Spring.Glide
	
		obj.BackgroundTransparency = startTransparency
		self:Tween(obj, {BackgroundTransparency = 0}, info)
	end
	
	function Animator:Initialize(tweenService)
		-- Animator is ready to use
		-- TweenService is already imported at module level (line 7)
		-- Spring presets are defined at module load time
	end
end


-- ========================
-- State Module
-- ========================

do
	
	State = {}
	
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
end


-- ========================
-- UIHelpers Module
-- ========================

do
	
	local TweenService = game:GetService("TweenService")
	
	UIHelpers = {}
	
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
		s.Thickness = thickness or 1.5  -- Increased from 1 to 1.5 for crispness
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
	
	function UIHelpers:Initialize(deps)
		-- UIHelpers is ready to use
		-- Dependencies (Animator, Theme, Icons, PlayerGui) are passed but not stored
		-- Helper functions are self-contained and don't need initialization
	end
end


-- ========================
-- Config Module
-- ========================

do
	
	Config = {}
	
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
end


-- ========================
-- WindowManager Module
-- ========================

do
	
	local Players = game:GetService("Players")
	local CoreGui = game:GetService("CoreGui")
	
	local LP = Players.LocalPlayer
	local PlayerGui = LP:WaitForChild("PlayerGui")
	
	WindowManager = {}
	
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
end


-- ========================
-- Hotkeys Module
-- ========================

do
	
	local UIS = game:GetService("UserInputService")
	
	Hotkeys = {}
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
end


-- ========================
-- Notifications Module
-- ========================

do
	
	Notifications = {}
	
	local corner, stroke
	
	local Theme, Animator, host
	
	local notifyRoot
	-- [Removed conflicting local RvrseUI]
	
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
end


-- ========================
-- Overlay Module
-- ========================

do
	
	Overlay = {}
	Overlay._initialized = false
	
	local function setLayerVisibility(layer)
		local anyVisible = false
		for _, child in ipairs(layer:GetChildren()) do
			if child.Visible then
				anyVisible = true
				break
			end
		end
		layer.Visible = anyVisible
	end
	
	function Overlay:Initialize(opts)
		if self._initialized then
			return
		end
	
		opts = opts or {}
		local playerGui = opts.PlayerGui
		assert(playerGui, "[Overlay] PlayerGui is required")
	
		local function resolveDisplayOrder()
			if opts.DisplayOrder then
				return opts.DisplayOrder
			end
	
			local maxOrder = 0
			for _, gui in ipairs(playerGui:GetChildren()) do
				if gui:IsA("ScreenGui") then
					maxOrder = math.max(maxOrder, gui.DisplayOrder)
				end
			end
			return maxOrder + 1
		end
	
		local desiredDisplayOrder = resolveDisplayOrder()
	
		local popovers = playerGui:FindFirstChild("RvrseUI_Popovers")
		if not popovers then
			popovers = Instance.new("ScreenGui")
			popovers.Name = "RvrseUI_Popovers"
			popovers.ResetOnSpawn = false
			popovers.IgnoreGuiInset = true
			popovers.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			popovers.DisplayOrder = desiredDisplayOrder
			popovers.Parent = playerGui
		else
			popovers.DisplayOrder = math.max(popovers.DisplayOrder, desiredDisplayOrder)
		end
		self.Gui = popovers
		self._displayOrderConnections = self._displayOrderConnections or {}
	
		local displayOrderConnections = self._displayOrderConnections
	
		local function disconnectGui(gui)
			local bundle = displayOrderConnections[gui]
			if bundle then
				if bundle.orderChanged then
					bundle.orderChanged:Disconnect()
				end
				if bundle.ancestryChanged then
					bundle.ancestryChanged:Disconnect()
				end
				displayOrderConnections[gui] = nil
			end
		end
	
		local function updateDisplayOrder()
			local highest = opts.DisplayOrder or 0
			for _, gui in ipairs(playerGui:GetChildren()) do
				if gui:IsA("ScreenGui") and gui ~= popovers then
					highest = math.max(highest, gui.DisplayOrder)
				end
			end
			popovers.DisplayOrder = math.max(highest + 1, popovers.DisplayOrder, opts.DisplayOrder or 0)
		end
	
		local function watchGui(gui)
			if not gui:IsA("ScreenGui") or gui == popovers then
				return
			end
			if displayOrderConnections[gui] then
				return
			end
	
			local orderConn = gui:GetPropertyChangedSignal("DisplayOrder"):Connect(function()
				updateDisplayOrder()
			end)
			local ancestryConn = gui.AncestryChanged:Connect(function(_, parent)
				if parent ~= playerGui then
					disconnectGui(gui)
					task.defer(updateDisplayOrder)
				end
			end)
	
			displayOrderConnections[gui] = {
				orderChanged = orderConn,
				ancestryChanged = ancestryConn,
			}
		end
	
		for _, gui in ipairs(playerGui:GetChildren()) do
			watchGui(gui)
		end
	
		playerGui.ChildAdded:Connect(function(child)
			watchGui(child)
			task.defer(updateDisplayOrder)
		end)
	
		playerGui.ChildRemoved:Connect(function(child)
			disconnectGui(child)
			task.defer(updateDisplayOrder)
		end)
	
		updateDisplayOrder()
	
		-- Create overlay layer first (transparent container for overlays)
		local layer = popovers:FindFirstChild("OverlayLayer")
		if layer and not layer:IsA("Frame") then
			layer:Destroy()
			layer = nil
		end
		if not layer then
			layer = Instance.new("Frame")
			layer.Name = "OverlayLayer"
			layer.BackgroundTransparency = 1
			layer.BorderSizePixel = 0
			layer.ClipsDescendants = false
			layer.Size = UDim2.new(1, 0, 1, 0)
			layer.ZIndex = 1  -- Base layer
			layer.Visible = false
			layer.Parent = popovers
		end
		self.Layer = layer
	
		-- Create blocker inside layer (below overlay elements)
		local blocker = layer:FindFirstChild("OverlayBlocker")
		if blocker and not blocker:IsA("TextButton") then
			blocker:Destroy()
			blocker = nil
		end
		if not blocker then
			blocker = Instance.new("TextButton")
			blocker.Name = "OverlayBlocker"
			blocker.AutoButtonColor = false
			blocker.BackgroundColor3 = Color3.new(0, 0, 0)
			blocker.BackgroundTransparency = 1
			blocker.BorderSizePixel = 0
			blocker.Text = ""
			blocker.Size = UDim2.new(1, 0, 1, 0)
			blocker.ZIndex = 100  -- Below overlay elements (200+)
			blocker.Visible = false
			blocker.Modal = false
			blocker.Parent = layer  -- ⭐ Parent to layer, not popovers!
		end
		self.Blocker = blocker
	
		layer.ChildAdded:Connect(function(child)
			child:GetPropertyChangedSignal("Visible"):Connect(function()
				setLayerVisibility(layer)
			end)
			setLayerVisibility(layer)
		end)
	
		layer.ChildRemoved:Connect(function()
			task.defer(function()
				setLayerVisibility(layer)
			end)
		end)
	
		setLayerVisibility(layer)
	
		self._blockerCount = 0
		self.Debug = opts.Debug
		self._initialized = true
	end
	
	function Overlay:GetLayer()
		return self.Layer
	end
	
	function Overlay:GetBlocker()
		return self.Blocker
	end
	
	function Overlay:ShowBlocker(options)
		assert(self.Blocker, "[Overlay] Service not initialized")
		options = options or {}
	
		print("[OVERLAY] 🔷 ShowBlocker called with options:")
		print(string.format("  - Modal: %s", tostring(options.Modal)))
		print(string.format("  - ZIndex: %s", tostring(options.ZIndex)))
		print(string.format("  - Transparency: %s", tostring(options.Transparency)))
	
		self._blockerCount += 1
	
		local blocker = self.Blocker
		blocker.ZIndex = options.ZIndex or 100  -- Below overlay elements (200+)
		blocker.Visible = true
		blocker.Active = false  -- Allow click events to fire
		blocker.Modal = options.Modal ~= false
		local transparency = options.Transparency
		if transparency == nil then
			transparency = 1
		end
		blocker.BackgroundTransparency = transparency
	
		print(string.format("[OVERLAY] ✅ Blocker configured:"))
		print(string.format("  - Visible: %s", tostring(blocker.Visible)))
		print(string.format("  - Active: %s", tostring(blocker.Active)))
		print(string.format("  - Modal: %s", tostring(blocker.Modal)))
		print(string.format("  - ZIndex: %d", blocker.ZIndex))
		print(string.format("  - Transparency: %.2f", blocker.BackgroundTransparency))
		print(string.format("  - Blocker depth: %d", self._blockerCount))
	
		-- Make sure layer is visible
		if self.Layer then
			self.Layer.Visible = true
			print(string.format("[OVERLAY] Layer made visible"))
		end
	
		if self.Debug and self.Debug.IsEnabled and self.Debug:IsEnabled() then
			self.Debug.printf("[OVERLAY] ShowBlocker depth=%d alpha=%.2f zindex=%d", self._blockerCount, blocker.BackgroundTransparency, blocker.ZIndex)
		end
	
		return blocker
	end
	
	function Overlay:HideBlocker(force)
		assert(self.Blocker, "[Overlay] Service not initialized")
	
		print(string.format("[OVERLAY] 🔶 HideBlocker called (force: %s, current depth: %d)", tostring(force), self._blockerCount))
	
		if force then
			self._blockerCount = 0
		else
			self._blockerCount = math.max(0, self._blockerCount - 1)
		end
	
		print(string.format("[OVERLAY] New blocker depth: %d", self._blockerCount))
	
		if self._blockerCount == 0 then
			local blocker = self.Blocker
			blocker.Active = false
			blocker.Modal = false
			blocker.Visible = false
			blocker.BackgroundTransparency = 1
			print("[OVERLAY] ✅ Blocker hidden (depth reached 0)")
		else
			print(string.format("[OVERLAY] ⚠️ Blocker still active (depth: %d)", self._blockerCount))
		end
	
		if self.Debug and self.Debug.IsEnabled and self.Debug:IsEnabled() then
			self.Debug.printf("[OVERLAY] HideBlocker depth=%d", self._blockerCount)
		end
	end
	
	function Overlay:Attach(instance)
		assert(self.Layer, "[Overlay] Service not initialized")
		instance.Parent = self.Layer
		setLayerVisibility(self.Layer)
		return instance
	end
end


-- ========================
-- KeySystem Module
-- ========================

do
	
	KeySystem = {}
	local deps
	
	function KeySystem:Initialize(dependencies)
		deps = dependencies
	end
	
	function KeySystem:ValidateKey(inputKey, settings)
		local keySettings = settings.KeySettings or {}
	
		-- Method 1: Custom validator function
		if keySettings.Validator and type(keySettings.Validator) == "function" then
			local success, result = pcall(keySettings.Validator, inputKey)
			if success and result == true then
				return true, "Custom validation passed"
			end
			return false, "Invalid key"
		end
	
		-- Method 2: HWID/UserID whitelist
		if keySettings.Whitelist and type(keySettings.Whitelist) == "table" then
			local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
			local userId = tostring(game.Players.LocalPlayer.UserId)
	
			for _, entry in ipairs(keySettings.Whitelist) do
				if entry == hwid or entry == userId or entry == inputKey then
					return true, "Whitelist validated"
				end
			end
		end
	
		-- Method 3: Table of valid keys
		if keySettings.Keys and type(keySettings.Keys) == "table" then
			for _, validKey in ipairs(keySettings.Keys) do
				if inputKey == validKey then
					return true, "Key matched"
				end
			end
		end
	
		-- Method 4: Single key string (legacy Rayfield compatibility)
		if keySettings.Key and type(keySettings.Key) == "string" then
			if inputKey == keySettings.Key then
				return true, "Key matched"
			end
		end
	
		return false, "Invalid key"
	end
	
	function KeySystem:FetchRemoteKey(url)
		local success, result = pcall(function()
			return game:HttpGet(url, true)
		end)
	
		if success then
			-- Strip whitespace and newlines
			result = result:gsub("%s+", "")
			return true, result
		end
	
		return false, "Failed to fetch remote key"
	end
	
	function KeySystem:SaveKey(fileName, key)
		local folderPath = "RvrseUI/KeySystem"
		local filePath = folderPath .. "/" .. fileName .. ".key"
	
		-- Create folder if it doesn't exist
		if not isfolder("RvrseUI") then
			makefolder("RvrseUI")
		end
		if not isfolder(folderPath) then
			makefolder(folderPath)
		end
	
		-- Save key
		local success, err = pcall(function()
			writefile(filePath, key)
		end)
	
		return success, err
	end
	
	function KeySystem:LoadSavedKey(fileName)
		local filePath = "RvrseUI/KeySystem/" .. fileName .. ".key"
	
		if isfile(filePath) then
			local success, key = pcall(function()
				return readfile(filePath)
			end)
	
			if success then
				return true, key
			end
		end
	
		return false, nil
	end
	
	function KeySystem:SendWebhook(webhookUrl, data)
		if not webhookUrl or webhookUrl == "" then
			return
		end
	
		local payload = {
			content = "",
			embeds = {
				{
					title = data.Title or "Key System Event",
					description = data.Description or "",
					color = data.Color or 5814783, -- Default blue
					fields = {
						{
							name = "Username",
							value = game.Players.LocalPlayer.Name,
							inline = true
						},
						{
							name = "User ID",
							value = tostring(game.Players.LocalPlayer.UserId),
							inline = true
						},
						{
							name = "Input Key",
							value = data.Key or "N/A",
							inline = false
						},
						{
							name = "Result",
							value = data.Result or "Unknown",
							inline = false
						},
						{
							name = "Timestamp",
							value = os.date("%Y-%m-%d %H:%M:%S"),
							inline = false
						}
					},
					footer = {
						text = "RvrseUI Key System"
					}
				}
			}
		}
	
		local success, err = pcall(function()
			local HttpService = game:GetService("HttpService")
			local jsonPayload = HttpService:JSONEncode(payload)
	
			request({
				Url = webhookUrl,
				Method = "POST",
				Headers = {
					["Content-Type"] = "application/json"
				},
				Body = jsonPayload
			})
		end)
	
		if not success then
			warn("[KeySystem] Webhook failed:", err)
		end
	end
	
	function KeySystem:CreateUI(settings, onSuccess, onFailure)
		local keySettings = settings.KeySettings or {}
	
		-- Get theme colors
		local colors = deps.Theme:Get()
	
		-- UI Configuration
		local title = keySettings.Title or (settings.Name .. " - Key System")
		local subtitle = keySettings.Subtitle or "Enter your key to continue"
		local note = keySettings.Note or "Visit our website to get a key"
		local noteButton = keySettings.NoteButton or nil
	
		-- Attempt configuration
		local maxAttempts = keySettings.MaxAttempts or 3
		local attemptsRemaining = maxAttempts
	
		-- Create ScreenGui
		local KeyGui = Instance.new("ScreenGui")
		KeyGui.Name = deps.Obfuscation:Generate("KeySystem")
		KeyGui.DisplayOrder = 999999
		KeyGui.ResetOnSpawn = false
		KeyGui.IgnoreGuiInset = true
	
		-- Parent to appropriate container
		if gethui then
			KeyGui.Parent = gethui()
		elseif syn and syn.protect_gui then
			syn.protect_gui(KeyGui)
			KeyGui.Parent = game.CoreGui
		else
			KeyGui.Parent = game.CoreGui
		end
	
		-- Main container with improved design
		local Container = Instance.new("Frame")
		Container.Name = "Container"
		Container.Size = UDim2.new(0, 500, 0, 0) -- Wider container
		Container.Position = UDim2.new(0.5, 0, 0.5, 0)
		Container.AnchorPoint = Vector2.new(0.5, 0.5)
		Container.BackgroundColor3 = colors.Bg
		Container.BorderSizePixel = 0
		Container.ClipsDescendants = true
		Container.Parent = KeyGui
	
		-- Rounded corners
		local Corner = Instance.new("UICorner")
		Corner.CornerRadius = UDim.new(0, 16)
		Corner.Parent = Container
	
		-- Gradient border effect
		local Border = Instance.new("UIStroke")
		Border.Color = colors.Accent
		Border.Thickness = 2
		Border.Transparency = 0.5
		Border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		Border.Parent = Container
	
		local BorderGradient = Instance.new("UIGradient")
		BorderGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, colors.Primary),
			ColorSequenceKeypoint.new(0.5, colors.Accent),
			ColorSequenceKeypoint.new(1, colors.Secondary)
		})
		BorderGradient.Rotation = 45
		BorderGradient.Parent = Border
	
		-- Animated gradient rotation
		task.spawn(function()
			while Container.Parent do
				for i = 0, 360, 2 do
					if not Container.Parent then break end
					BorderGradient.Rotation = i
					task.wait(0.03)
				end
			end
		end)
	
		-- Shadow/glow effect
		local Glow = Instance.new("ImageLabel")
		Glow.Name = "Glow"
		Glow.Size = UDim2.new(1, 60, 1, 60)
		Glow.Position = UDim2.new(0.5, 0, 0.5, 0)
		Glow.AnchorPoint = Vector2.new(0.5, 0.5)
		Glow.BackgroundTransparency = 1
		Glow.Image = "rbxassetid://5028857084"
		Glow.ImageColor3 = colors.Accent
		Glow.ImageTransparency = 0.6
		Glow.ScaleType = Enum.ScaleType.Slice
		Glow.SliceCenter = Rect.new(24, 24, 276, 276)
		Glow.ZIndex = 0
		Glow.Parent = Container
	
		-- Header section with gradient
		local Header = Instance.new("Frame")
		Header.Name = "Header"
		Header.Size = UDim2.new(1, 0, 0, 100)
		Header.BackgroundColor3 = colors.Card
		Header.BorderSizePixel = 0
		Header.Parent = Container
	
		local HeaderCorner = Instance.new("UICorner")
		HeaderCorner.CornerRadius = UDim.new(0, 16)
		HeaderCorner.Parent = Header
	
		local HeaderGradient = Instance.new("UIGradient")
		HeaderGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, colors.Primary),
			ColorSequenceKeypoint.new(1, colors.Accent)
		})
		HeaderGradient.Rotation = 90
		HeaderGradient.Transparency = NumberSequence.new(0.7)
		HeaderGradient.Parent = Header
	
		-- Icon
		local Icon = Instance.new("TextLabel")
		Icon.Name = "Icon"
		Icon.Size = UDim2.new(0, 50, 0, 50)
		Icon.Position = UDim2.new(0, 25, 0, 25)
		Icon.BackgroundTransparency = 1
		Icon.Font = Enum.Font.GothamBold
		Icon.Text = "🔐"
		Icon.TextColor3 = colors.TextBright
		Icon.TextSize = 32
		Icon.Parent = Header
	
		-- Title
		local Title = Instance.new("TextLabel")
		Title.Name = "Title"
		Title.Size = UDim2.new(1, -100, 0, 30)
		Title.Position = UDim2.new(0, 85, 0, 20)
		Title.BackgroundTransparency = 1
		Title.Font = Enum.Font.GothamBold
		Title.Text = title
		Title.TextColor3 = colors.TextBright
		Title.TextSize = 20
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Parent = Header
	
		-- Subtitle
		local Subtitle = Instance.new("TextLabel")
		Subtitle.Name = "Subtitle"
		Subtitle.Size = UDim2.new(1, -100, 0, 20)
		Subtitle.Position = UDim2.new(0, 85, 0, 55)
		Subtitle.BackgroundTransparency = 1
		Subtitle.Font = Enum.Font.Gotham
		Subtitle.Text = subtitle
		Subtitle.TextColor3 = colors.TextSub
		Subtitle.TextSize = 14
		Subtitle.TextXAlignment = Enum.TextXAlignment.Left
		Subtitle.Parent = Header
	
		-- Content area
		local Content = Instance.new("Frame")
		Content.Name = "Content"
		Content.Size = UDim2.new(1, -40, 1, -120)
		Content.Position = UDim2.new(0, 20, 0, 110)
		Content.BackgroundTransparency = 1
		Content.Parent = Container
	
		-- Note message
		local NoteLabel = Instance.new("TextLabel")
		NoteLabel.Name = "Note"
		NoteLabel.Size = UDim2.new(1, 0, 0, 40)
		NoteLabel.Position = UDim2.new(0, 0, 0, 0)
		NoteLabel.BackgroundTransparency = 1
		NoteLabel.Font = Enum.Font.Gotham
		NoteLabel.Text = note
		NoteLabel.TextColor3 = colors.TextSub
		NoteLabel.TextSize = 13
		NoteLabel.TextXAlignment = Enum.TextXAlignment.Left
		NoteLabel.TextYAlignment = Enum.TextYAlignment.Top
		NoteLabel.TextWrapped = true
		NoteLabel.Parent = Content
	
		-- Note button (optional)
		local noteButtonHeight = 0
		if noteButton then
			noteButtonHeight = 45
	
			local NoteBtn = Instance.new("TextButton")
			NoteBtn.Name = "NoteButton"
			NoteBtn.Size = UDim2.new(1, 0, 0, 38)
			NoteBtn.Position = UDim2.new(0, 0, 0, 50)
			NoteBtn.BackgroundColor3 = colors.Surface
			NoteBtn.BorderSizePixel = 0
			NoteBtn.Font = Enum.Font.GothamMedium
			NoteBtn.Text = "  " .. (noteButton.Text or "Get Key")
			NoteBtn.TextColor3 = colors.Accent
			NoteBtn.TextSize = 14
			NoteBtn.TextXAlignment = Enum.TextXAlignment.Left
			NoteBtn.AutoButtonColor = false
			NoteBtn.Parent = Content
	
			local NoteBtnCorner = Instance.new("UICorner")
			NoteBtnCorner.CornerRadius = UDim.new(0, 10)
			NoteBtnCorner.Parent = NoteBtn
	
			local NoteBtnStroke = Instance.new("UIStroke")
			NoteBtnStroke.Color = colors.Accent
			NoteBtnStroke.Thickness = 1.5
			NoteBtnStroke.Transparency = 0.7
			NoteBtnStroke.Parent = NoteBtn
	
			local NoteBtnPadding = Instance.new("UIPadding")
			NoteBtnPadding.PaddingLeft = UDim.new(0, 12)
			NoteBtnPadding.Parent = NoteBtn
	
			NoteBtn.MouseButton1Click:Connect(function()
				if noteButton.Callback then
					noteButton.Callback()
				end
			end)
	
			-- Hover effect
			NoteBtn.MouseEnter:Connect(function()
				deps.Animator:Tween(NoteBtn, {BackgroundColor3 = colors.HoverBright}, deps.Animator.Spring.Lightning)
				deps.Animator:Tween(NoteBtnStroke, {Transparency = 0.3}, deps.Animator.Spring.Lightning)
			end)
			NoteBtn.MouseLeave:Connect(function()
				deps.Animator:Tween(NoteBtn, {BackgroundColor3 = colors.Surface}, deps.Animator.Spring.Lightning)
				deps.Animator:Tween(NoteBtnStroke, {Transparency = 0.7}, deps.Animator.Spring.Lightning)
			end)
		end
	
		-- Input box
		local InputBox = Instance.new("TextBox")
		InputBox.Name = "InputBox"
		InputBox.Size = UDim2.new(1, 0, 0, 48)
		InputBox.Position = UDim2.new(0, 0, 0, 55 + noteButtonHeight)
		InputBox.BackgroundColor3 = colors.Surface
		InputBox.BorderSizePixel = 0
		InputBox.Font = Enum.Font.GothamMedium
		InputBox.PlaceholderText = "Enter your key here..."
		InputBox.PlaceholderColor3 = colors.TextMuted
		InputBox.Text = ""
		InputBox.TextColor3 = colors.TextBright
		InputBox.TextSize = 15
		InputBox.ClearTextOnFocus = false
		InputBox.Parent = Content
	
		local InputCorner = Instance.new("UICorner")
		InputCorner.CornerRadius = UDim.new(0, 10)
		InputCorner.Parent = InputBox
	
		local InputStroke = Instance.new("UIStroke")
		InputStroke.Color = colors.Border
		InputStroke.Thickness = 1.5
		InputStroke.Transparency = 0.5
		InputStroke.Parent = InputBox
	
		local InputPadding = Instance.new("UIPadding")
		InputPadding.PaddingLeft = UDim.new(0, 16)
		InputPadding.PaddingRight = UDim.new(0, 16)
		InputPadding.Parent = InputBox
	
		-- Input focus effects
		InputBox.Focused:Connect(function()
			deps.Animator:Tween(InputStroke, {Color = colors.Accent, Transparency = 0.2}, deps.Animator.Spring.Lightning)
		end)
		InputBox.FocusLost:Connect(function()
			deps.Animator:Tween(InputStroke, {Color = colors.Border, Transparency = 0.5}, deps.Animator.Spring.Lightning)
		end)
	
		-- Status label
		local StatusLabel = Instance.new("TextLabel")
		StatusLabel.Name = "Status"
		StatusLabel.Size = UDim2.new(1, 0, 0, 20)
		StatusLabel.Position = UDim2.new(0, 0, 0, 113 + noteButtonHeight)
		StatusLabel.BackgroundTransparency = 1
		StatusLabel.Font = Enum.Font.Gotham
		StatusLabel.Text = string.format("Attempts remaining: %d/%d", attemptsRemaining, maxAttempts)
		StatusLabel.TextColor3 = colors.TextSub
		StatusLabel.TextSize = 12
		StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
		StatusLabel.Parent = Content
	
		-- Submit button
		local SubmitBtn = Instance.new("TextButton")
		SubmitBtn.Name = "Submit"
		SubmitBtn.Size = UDim2.new(1, 0, 0, 48)
		SubmitBtn.Position = UDim2.new(0, 0, 0, 143 + noteButtonHeight)
		SubmitBtn.BackgroundColor3 = colors.Accent
		SubmitBtn.BorderSizePixel = 0
		SubmitBtn.Font = Enum.Font.GothamBold
		SubmitBtn.Text = "Validate Key"
		SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		SubmitBtn.TextSize = 15
		SubmitBtn.AutoButtonColor = false
		SubmitBtn.Parent = Content
	
		local SubmitCorner = Instance.new("UICorner")
		SubmitCorner.CornerRadius = UDim.new(0, 10)
		SubmitCorner.Parent = SubmitBtn
	
		-- Submit button gradient
		local SubmitGradient = Instance.new("UIGradient")
		SubmitGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, colors.Primary),
			ColorSequenceKeypoint.new(1, colors.Accent)
		})
		SubmitGradient.Rotation = 45
		SubmitGradient.Parent = SubmitBtn
	
		-- Calculate final container height
		local finalHeight = 320 + noteButtonHeight
	
		-- Animate container entrance
		Container.Size = UDim2.new(0, 500, 0, 0)
		Container.BackgroundTransparency = 1
		Header.BackgroundTransparency = 1
		Icon.TextTransparency = 1
		Title.TextTransparency = 1
		Subtitle.TextTransparency = 1
		NoteLabel.TextTransparency = 1
		StatusLabel.TextTransparency = 1
		InputBox.BackgroundTransparency = 1
		InputBox.TextTransparency = 1
		InputStroke.Transparency = 1
		SubmitBtn.BackgroundTransparency = 1
		SubmitBtn.TextTransparency = 1
		Border.Transparency = 1
	
		task.wait(0.1)
	
		-- Smooth entrance animations
		deps.Animator:Tween(Container, {Size = UDim2.new(0, 500, 0, finalHeight)}, deps.Animator.Spring.Bounce)
		deps.Animator:Tween(Container, {BackgroundTransparency = 0}, deps.Animator.Spring.Butter)
		deps.Animator:Tween(Header, {BackgroundTransparency = 0}, deps.Animator.Spring.Butter)
		deps.Animator:Tween(Icon, {TextTransparency = 0}, deps.Animator.Spring.Glide)
		deps.Animator:Tween(Title, {TextTransparency = 0}, deps.Animator.Spring.Glide)
		deps.Animator:Tween(Subtitle, {TextTransparency = 0}, deps.Animator.Spring.Glide)
		deps.Animator:Tween(NoteLabel, {TextTransparency = 0}, deps.Animator.Spring.Glide)
		deps.Animator:Tween(StatusLabel, {TextTransparency = 0}, deps.Animator.Spring.Glide)
		deps.Animator:Tween(InputBox, {BackgroundTransparency = 0, TextTransparency = 0}, deps.Animator.Spring.Glide)
		deps.Animator:Tween(InputStroke, {Transparency = 0.5}, deps.Animator.Spring.Glide)
		deps.Animator:Tween(SubmitBtn, {BackgroundTransparency = 0, TextTransparency = 0}, deps.Animator.Spring.Glide)
		deps.Animator:Tween(Border, {Transparency = 0.5}, deps.Animator.Spring.Glide)
	
		-- Validation function
		local function validateInput()
			local inputKey = InputBox.Text
	
			if inputKey == "" then
				-- Shake animation
				deps.Animator:Tween(Container, {Position = UDim2.new(0.5, 10, 0.5, 0)}, deps.Animator.Spring.Lightning)
				task.wait(0.05)
				deps.Animator:Tween(Container, {Position = UDim2.new(0.5, -10, 0.5, 0)}, deps.Animator.Spring.Lightning)
				task.wait(0.05)
				deps.Animator:Tween(Container, {Position = UDim2.new(0.5, 0, 0.5, 0)}, deps.Animator.Spring.Lightning)
	
				StatusLabel.Text = "⚠️ Please enter a key!"
				StatusLabel.TextColor3 = colors.Warning
				return
			end
	
			-- Validate key
			local valid, message = KeySystem:ValidateKey(inputKey, settings)
	
			if valid then
				-- Success!
				StatusLabel.Text = "✓ Key validated! Loading..."
				StatusLabel.TextColor3 = colors.Success
	
				-- Save key if enabled
				if keySettings.SaveKey then
					local fileName = keySettings.FileName or settings.Name or "Key"
					KeySystem:SaveKey(fileName, inputKey)
				end
	
				-- Send webhook if configured
				if keySettings.WebhookURL then
					KeySystem:SendWebhook(keySettings.WebhookURL, {
						Title = "Key Validated ✓",
						Description = "User successfully validated key",
						Color = 3066993,
						Key = inputKey,
						Result = "Success: " .. message
					})
				end
	
				-- Callback
				if keySettings.OnKeyValid then
					keySettings.OnKeyValid(inputKey)
				end
	
				-- Animate out
				task.wait(0.5)
				deps.Animator:Tween(Container, {Size = UDim2.new(0, 500, 0, 0), BackgroundTransparency = 1}, deps.Animator.Spring.Expo)
				deps.Animator:Tween(Header, {BackgroundTransparency = 1}, deps.Animator.Spring.Expo)
				deps.Animator:Tween(Icon, {TextTransparency = 1}, deps.Animator.Spring.Expo)
				deps.Animator:Tween(Title, {TextTransparency = 1}, deps.Animator.Spring.Expo)
				deps.Animator:Tween(Subtitle, {TextTransparency = 1}, deps.Animator.Spring.Expo)
				deps.Animator:Tween(NoteLabel, {TextTransparency = 1}, deps.Animator.Spring.Expo)
				deps.Animator:Tween(StatusLabel, {TextTransparency = 1}, deps.Animator.Spring.Expo)
				deps.Animator:Tween(InputBox, {BackgroundTransparency = 1, TextTransparency = 1}, deps.Animator.Spring.Expo)
				deps.Animator:Tween(SubmitBtn, {BackgroundTransparency = 1, TextTransparency = 1}, deps.Animator.Spring.Expo)
				deps.Animator:Tween(Border, {Transparency = 1}, deps.Animator.Spring.Expo)
	
				task.wait(0.6)
				KeyGui:Destroy()
	
				-- Success callback
				if onSuccess then
					onSuccess(inputKey)
				end
			else
				-- Invalid key
				attemptsRemaining = attemptsRemaining - 1
	
				-- Shake animation
				deps.Animator:Tween(Container, {Position = UDim2.new(0.5, 15, 0.5, 0)}, deps.Animator.Spring.Lightning)
				task.wait(0.05)
				deps.Animator:Tween(Container, {Position = UDim2.new(0.5, -15, 0.5, 0)}, deps.Animator.Spring.Lightning)
				task.wait(0.05)
				deps.Animator:Tween(Container, {Position = UDim2.new(0.5, 0, 0.5, 0)}, deps.Animator.Spring.Lightning)
	
				-- Send webhook if configured
				if keySettings.WebhookURL then
					KeySystem:SendWebhook(keySettings.WebhookURL, {
						Title = "Invalid Key Attempt ✗",
						Description = "User entered invalid key",
						Color = 15158332,
						Key = inputKey,
						Result = "Failed: " .. message .. " | Attempts remaining: " .. attemptsRemaining
					})
				end
	
				-- Callback
				if keySettings.OnKeyInvalid then
					keySettings.OnKeyInvalid(inputKey, attemptsRemaining)
				end
	
				if attemptsRemaining <= 0 then
					-- Out of attempts
					StatusLabel.Text = "✗ Out of attempts! Closing..."
					StatusLabel.TextColor3 = colors.Error
	
					-- Callback
					if keySettings.OnAttemptsExhausted then
						keySettings.OnAttemptsExhausted()
					end
	
					task.wait(1)
	
					-- Kick player if configured
					if keySettings.KickOnFailure ~= false then
						game.Players.LocalPlayer:Kick("Key validation failed - No attempts remaining")
					end
	
					KeyGui:Destroy()
	
					-- Failure callback
					if onFailure then
						onFailure("No attempts remaining")
					end
				else
					-- Update status
					StatusLabel.Text = string.format("✗ Invalid key! Attempts: %d/%d", attemptsRemaining, maxAttempts)
					StatusLabel.TextColor3 = colors.Error
	
					-- Clear input
					InputBox.Text = ""
				end
			end
		end
	
		-- Submit button click
		SubmitBtn.MouseButton1Click:Connect(validateInput)
	
		-- Enter key support
		InputBox.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				validateInput()
			end
		end)
	
		-- Hover effects
		SubmitBtn.MouseEnter:Connect(function()
			deps.Animator:Tween(SubmitBtn, {BackgroundColor3 = colors.AccentHover}, deps.Animator.Spring.Lightning)
		end)
		SubmitBtn.MouseLeave:Connect(function()
			deps.Animator:Tween(SubmitBtn, {BackgroundColor3 = colors.Accent}, deps.Animator.Spring.Lightning)
		end)
	
		-- Focus input box
		task.wait(0.8)
		InputBox:CaptureFocus()
	
		return KeyGui
	end
	
	function KeySystem:Process(settings, callback)
		local keySettings = settings.KeySettings or {}
	
		-- Check if key system is enabled
		if not settings.KeySystem or settings.KeySystem == false then
			if callback then
				callback(true, "Key system disabled")
			end
			return true
		end
	
		-- Try to load saved key
		if keySettings.SaveKey then
			local fileName = keySettings.FileName or settings.Name or "Key"
			local success, savedKey = KeySystem:LoadSavedKey(fileName)
	
			if success and savedKey then
				-- Validate saved key
				local valid, message = KeySystem:ValidateKey(savedKey, settings)
	
				if valid then
					deps.Debug.printf("[KeySystem] Loaded saved key: %s", message)
	
					if callback then
						callback(true, "Saved key validated")
					end
					return true
				else
					deps.Debug.printf("[KeySystem] Saved key invalid, showing UI")
				end
			end
		end
	
		-- Fetch remote key if configured
		if keySettings.GrabKeyFromSite and keySettings.Key and type(keySettings.Key) == "string" then
			local success, remoteKey = KeySystem:FetchRemoteKey(keySettings.Key)
	
			if success then
				keySettings.Keys = {remoteKey}
				deps.Debug.printf("[KeySystem] Fetched remote key")
			else
				warn("[KeySystem] Failed to fetch remote key:", remoteKey)
			end
		end
	
		-- Show key validation UI
		local passthrough = false
		local errorMsg = nil
	
		KeySystem:CreateUI(settings, function(validKey)
			passthrough = true
		end, function(errMsg)
			passthrough = false
			errorMsg = errMsg
		end)
	
		-- Block execution until validated
		repeat
			task.wait()
		until passthrough == true or errorMsg ~= nil
	
		if callback then
			callback(passthrough, errorMsg or "Key validated")
		end
	
		return passthrough
	end
end


-- ========================
-- Button Module
-- ========================

do
	
	Button = {}
	
	function Button.Create(o, dependencies)
		o = o or {}
	
		-- Extract dependencies
		local card = dependencies.card
		local pal3 = dependencies.pal3
		local UIS = dependencies.UIS
		local Animator = dependencies.Animator
		local RvrseUI = dependencies.RvrseUI
		local Theme = dependencies.Theme
	
		-- Create container with gradient background
		local f = card(48) -- Slightly taller for modern look
		f.BackgroundColor3 = pal3.Card
		f.BackgroundTransparency = 0.2
	
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
		stroke.Parent = f
	
		-- Main button
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.BackgroundTransparency = 1
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 15
		btn.TextColor3 = pal3.TextBright
		btn.Text = o.Text or "Button"
		btn.AutoButtonColor = false
		btn.Parent = f
	
		local currentText = btn.Text
		local isHovering = false
	
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
	
			-- Brighten text
			Animator:Tween(btn, {TextColor3 = pal3.Shimmer}, Animator.Spring.Lightning)
	
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
	
			-- Restore text color
			Animator:Tween(btn, {TextColor3 = pal3.TextBright}, Animator.Spring.Snappy)
		end)
	
		-- Lock state listener with visual feedback
		table.insert(RvrseUI._lockListeners, function()
			local locked = RvrseUI.Store:IsLocked(o.RespectLock)
	
			if locked then
				-- Desaturate and dim
				btn.TextTransparency = 0.5
				gradient.Transparency = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 0.9),
					NumberSequenceKeypoint.new(1, 0.9),
				}
				stroke.Transparency = 0.8
			else
				-- Restore to normal or hover state
				btn.TextTransparency = 0
				if isHovering then
					gradient.Transparency = NumberSequence.new{
						NumberSequenceKeypoint.new(0, 0.4),
						NumberSequenceKeypoint.new(1, 0.4),
					}
					stroke.Transparency = 0.2
				else
					gradient.Transparency = NumberSequence.new{
						ColorSequenceKeypoint.new(0, 0.7),
						ColorSequenceKeypoint.new(1, 0.7),
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
					btn.Text = text
					currentText = text
				end
				-- interactText parameter reserved for future use (Rayfield compatibility)
			end,
			SetText = function(_, txt)
				-- Legacy method - kept for backwards compatibility
				btn.Text = txt
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
			CurrentValue = currentText
		}
	
		if o.Flag then
			RvrseUI.Flags[o.Flag] = buttonAPI
		end
	
		return buttonAPI
	end
end


-- ========================
-- Toggle Module
-- ========================

do
	
	Toggle = {}
	
	function Toggle.Create(o, dependencies)
		o = o or {}
	
		-- Extract dependencies
		local card = dependencies.card
		local corner = dependencies.corner
		local shadow = dependencies.shadow
		local pal3 = dependencies.pal3
		local Animator = dependencies.Animator
		local RvrseUI = dependencies.RvrseUI
		local Theme = dependencies.Theme
	
		local f = card(48) -- Taller for modern look
	
		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Size = UDim2.new(1, -70, 1, 0)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 15
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextColor3 = pal3.Text
		lbl.Text = o.Text or "Toggle"
		lbl.Parent = f
	
		-- Modern switch track (wider and taller)
		local shell = Instance.new("Frame")
		shell.AnchorPoint = Vector2.new(1, 0.5)
		shell.Position = UDim2.new(1, -6, 0.5, 0)
		shell.Size = UDim2.new(0, 56, 0, 30)
		shell.BackgroundColor3 = pal3.Border
		shell.BorderSizePixel = 0
		shell.Parent = f
		corner(shell, 15)
	
		-- Gradient overlay on track
		local trackGradient = Instance.new("UIGradient")
		trackGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, pal3.Primary),
			ColorSequenceKeypoint.new(0.5, pal3.Accent),
			ColorSequenceKeypoint.new(1, pal3.Secondary),
		}
		trackGradient.Rotation = 45
		trackGradient.Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 0.9),
			NumberSequenceKeypoint.new(1, 0.9),
		}
		trackGradient.Parent = shell
	
		-- Glowing border on track
		local trackStroke = Instance.new("UIStroke")
		trackStroke.Color = pal3.BorderGlow
		trackStroke.Thickness = 0
		trackStroke.Transparency = 0.7
		trackStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		trackStroke.Parent = shell
	
		-- Switch thumb (larger and glowing)
		local dot = Instance.new("Frame")
		dot.Size = UDim2.new(0, 26, 0, 26)
		dot.Position = UDim2.new(0, 2, 0.5, -13)
		dot.BackgroundColor3 = Color3.new(1, 1, 1)
		dot.BorderSizePixel = 0
		dot.ZIndex = 3
		dot.Parent = shell
		corner(dot, 13)
		shadow(dot, 0.5, 3)
	
		-- Glow ring around thumb (when active)
		local glowRing = Instance.new("UIStroke")
		glowRing.Color = pal3.Accent
		glowRing.Thickness = 0
		glowRing.Transparency = 0.3
		glowRing.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		glowRing.Parent = dot
	
		local state = o.State == true
		local controlsGroup = o.LockGroup
		local respectGroup = o.RespectLock
		local isHovering = false
	
		local function lockedNow()
			return respectGroup and RvrseUI.Store:IsLocked(respectGroup)
		end
	
		local function visual()
			local locked = lockedNow()
	
			if locked then
				-- Locked state: desaturated
				shell.BackgroundColor3 = pal3.Disabled
				trackGradient.Transparency = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 0.95),
					NumberSequenceKeypoint.new(1, 0.95),
				}
				trackStroke.Thickness = 0
				glowRing.Thickness = 0
				lbl.TextTransparency = 0.5
			elseif state then
				-- Active state: vibrant gradient track
				shell.BackgroundColor3 = pal3.Accent
				trackGradient.Transparency = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 0.3),
					NumberSequenceKeypoint.new(1, 0.3),
				}
				trackStroke.Thickness = 1
				trackStroke.Transparency = 0.4
	
				-- Glow the thumb
				Animator:Tween(glowRing, {Thickness = 3}, Animator.Spring.Snappy)
	
				-- Slide thumb to right
				Animator:Tween(dot, {Position = UDim2.new(1, -28, 0.5, -13)}, Animator.Spring.Spring)
	
				lbl.TextTransparency = 0
				lbl.TextColor3 = pal3.TextBright
			else
				-- Inactive state: subtle
				shell.BackgroundColor3 = pal3.Border
				trackGradient.Transparency = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 0.9),
					NumberSequenceKeypoint.new(1, 0.9),
				}
				trackStroke.Thickness = 0
				glowRing.Thickness = 0
	
				-- Slide thumb to left
				Animator:Tween(dot, {Position = UDim2.new(0, 2, 0.5, -13)}, Animator.Spring.Spring)
	
				lbl.TextTransparency = 0
				lbl.TextColor3 = pal3.Text
			end
		end
		visual()
	
		-- Click/tap interaction
		f.InputBegan:Connect(function(io)
			if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
				if lockedNow() then return end
	
				state = not state
	
				-- Multiple effects on toggle
				if state then
					Animator:Shimmer(shell, Theme) -- Shimmer on activate
				end
	
				-- Quick pulse
				Animator:Pulse(dot, 1.1, Animator.Spring.Lightning)
	
				visual()
	
				if controlsGroup then
					RvrseUI.Store:SetLocked(controlsGroup, state)
				end
				if o.OnChanged then task.spawn(o.OnChanged, state) end
				if o.Flag then RvrseUI:_autoSave() end
			end
		end)
	
		-- Hover effects
		shell.MouseEnter:Connect(function()
			if lockedNow() then return end
			isHovering = true
	
			-- Brighten on hover (set directly - can't tween NumberSequence)
			if not state then
				trackGradient.Transparency = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 0.8),
					NumberSequenceKeypoint.new(1, 0.8),
				}
			end
		end)
	
		shell.MouseLeave:Connect(function()
			isHovering = false
	
			-- Restore transparency (set directly - can't tween NumberSequence)
			if not state then
				trackGradient.Transparency = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 0.9),
					NumberSequenceKeypoint.new(1, 0.9),
				}
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
end


-- ========================
-- Dropdown Module
-- ========================

do
	
	Dropdown = {}
	
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
		local baseOverlayLayer = dependencies.OverlayLayer
		local OverlayService = dependencies.Overlay
	
		if OverlayService and not baseOverlayLayer then
			baseOverlayLayer = OverlayService:GetLayer()
		end
	
		-- Settings
		local values = {}
		-- Support both "Values" (RvrseUI) and "Options" (Rayfield compatibility)
		local sourceValues = o.Values or o.Options or {}
		for _, v in ipairs(sourceValues) do
			table.insert(values, v)
		end
	
		local multiSelect = o.MultiSelect == true or o.MultipleOptions == true  -- Multi-select mode (support both APIs)
		local selectedValues = {}  -- For multi-select mode
	
		-- Initialize selectedValues from CurrentOption (Rayfield compatibility)
		if multiSelect and o.CurrentOption and type(o.CurrentOption) == "table" then
			for _, val in ipairs(o.CurrentOption) do
				table.insert(selectedValues, val)
			end
		end
	
		local maxHeight = o.MaxHeight or 240  -- Increased to 240 for better visibility
		local itemHeight = 40  -- Increased to 40 for better touch targets
		local placeholder = o.PlaceholderText or (multiSelect and "Select multiple" or "Select")
		local DROPDOWN_BASE_Z = 3000
		local fallbackOverlayLayer
		local fallbackOverlayGui
	
		local function currentOverlayLayer()
			if baseOverlayLayer and baseOverlayLayer.Parent then
				return baseOverlayLayer
			end
			if fallbackOverlayLayer and fallbackOverlayLayer.Parent then
				return fallbackOverlayLayer
			end
			return nil
		end
	
		local function resolveOverlayLayer()
			if o.Overlay == false then
				return nil
			end
	
			local layer = currentOverlayLayer()
			if layer then
				return layer
			end
	
			local player
			local ok, result = pcall(function()
				return game:GetService("Players").LocalPlayer
			end)
			if ok then
				player = result
			end
			if not player then
				return nil
			end
	
			local playerGui = player:FindFirstChildOfClass("PlayerGui")
			if not playerGui then
				local okWait, gui = pcall(function()
					return player:WaitForChild("PlayerGui", 1)
				end)
				if okWait then
					playerGui = gui
				end
			end
	
			if not playerGui then
				return nil
			end
	
			local hostGui = fallbackOverlayGui
			if not hostGui or not hostGui.Parent then
				hostGui = Instance.new("ScreenGui")
				hostGui.Name = "RvrseUI_DropdownHost"
				hostGui.ResetOnSpawn = false
				hostGui.IgnoreGuiInset = true
				hostGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
				hostGui.DisplayOrder = 2000000
				hostGui.Parent = playerGui
				fallbackOverlayGui = hostGui
			end
	
			local layerFrame = fallbackOverlayLayer
			if not layerFrame or not layerFrame.Parent then
				layerFrame = Instance.new("Frame")
				layerFrame.Name = "DropdownLayer"
				layerFrame.BackgroundTransparency = 1
				layerFrame.BorderSizePixel = 0
				layerFrame.ClipsDescendants = false
				layerFrame.Size = UDim2.new(1, 0, 1, 0)
				layerFrame.ZIndex = DROPDOWN_BASE_Z - 10
				layerFrame.Parent = hostGui
				fallbackOverlayLayer = layerFrame
			end
	
			return layerFrame
		end
	
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
		-- shadow(dropdownList, 0.6, 16)  -- ❌ DISABLED: Shadow too large for overlay mode, blocks entire screen!
	
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
		dropdownLayout.Padding = UDim.new(0, 4)  -- Increased from 2 to 4 for better spacing
		dropdownLayout.Parent = dropdownScroll
	
		-- Add padding inside dropdown scroll
		local dropdownPadding = Instance.new("UIPadding")
		dropdownPadding.PaddingTop = UDim.new(0, 4)
		dropdownPadding.PaddingBottom = UDim.new(0, 4)
		dropdownPadding.PaddingLeft = UDim.new(0, 4)
		dropdownPadding.PaddingRight = UDim.new(0, 4)
		dropdownPadding.Parent = dropdownScroll
	
		local inlineParent = dropdownList.Parent
		local inlineWidth = btn.Size.X.Offset
		local dropdownHeight = 0
	
		local overlayBlocker
		local overlayBlockerConnection
		local blockerActive = false
		local dropdownOpen = false
		local optionButtons = {}
		local idx = 1
		local dropdownAPI = {}  -- Forward declaration for updateCurrentOption
		local setOpen  -- Forward declaration for blocker click handler
	
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
	
		local function showOverlayBlocker()
			print("[DROPDOWN] 📦 showOverlayBlocker() called")
			-- Always show overlay blocker for dropdown
			if OverlayService then
				print("[DROPDOWN] Using Overlay service")
				overlayBlocker = OverlayService:ShowBlocker({
					Transparency = 0.45,
					ZIndex = DROPDOWN_BASE_Z - 2,
					Modal = false,  -- Allow click events to fire on blocker
				})
				print(string.format("[DROPDOWN] Blocker created - Modal: %s, Active: %s, Visible: %s",
					tostring(overlayBlocker.Modal),
					tostring(overlayBlocker.Active),
					tostring(overlayBlocker.Visible)))
				-- DON'T connect handler here - will be connected after setOpen is defined
				print("[DROPDOWN] ⚠️ Blocker created, handler will be connected after setOpen is defined")
			else
				local layer = resolveOverlayLayer()
				if not layer then
					return
				end
	
				if not overlayBlocker or not overlayBlocker.Parent then
					overlayBlocker = Instance.new("TextButton")
					overlayBlocker.Name = "DropdownOverlayBlocker"
					overlayBlocker.AutoButtonColor = false
					overlayBlocker.Text = ""
					overlayBlocker.BackgroundColor3 = Color3.new(0, 0, 0)
					overlayBlocker.BackgroundTransparency = 0.55
					overlayBlocker.BorderSizePixel = 0
					overlayBlocker.Size = UDim2.new(1, 0, 1, 0)
					overlayBlocker.ZIndex = DROPDOWN_BASE_Z - 2
					overlayBlocker.Visible = false
					overlayBlocker.Parent = layer
					-- Connect inline function to close dropdown
					overlayBlocker.MouseButton1Click:Connect(function()
						if setOpen then
							setOpen(false)
						end
					end)
				elseif overlayBlocker.Parent ~= layer then
					overlayBlocker.Parent = layer
				end
				overlayBlocker.Visible = true
				overlayBlocker.Active = false  -- Allow click events to fire
				overlayBlocker.Modal = false   -- Don't block other UI
				overlayBlocker.ZIndex = DROPDOWN_BASE_Z - 2
			end
	
			blockerActive = true
		end
	
		local function hideOverlayBlocker(force)
			if not blockerActive then
				return
			end
	
			if OverlayService then
				if overlayBlockerConnection then
					overlayBlockerConnection:Disconnect()
					overlayBlockerConnection = nil
				end
				OverlayService:HideBlocker(force)
			elseif overlayBlocker then
				overlayBlocker.Visible = false
				overlayBlocker.Active = false
				overlayBlocker.Modal = false
			end
	
			blockerActive = false
		end
	
		local function updateCurrentOption()
			-- Update CurrentOption property (Rayfield compatibility)
			if multiSelect then
				dropdownAPI.CurrentOption = selectedValues
			else
				dropdownAPI.CurrentOption = values[idx] and {values[idx]} or {}
			end
		end
	
		local function updateButtonText()
			if multiSelect then
				local count = #selectedValues
				if count == 0 then
					btn.Text = placeholder
				elseif count == 1 then
					btn.Text = tostring(selectedValues[1])
				else
					btn.Text = count .. " selected"
				end
			else
				if values[idx] then
					btn.Text = tostring(values[idx])
				else
					btn.Text = placeholder
				end
			end
			updateCurrentOption()
		end
	
		local function isValueSelected(value)
			if multiSelect then
				for _, v in ipairs(selectedValues) do
					if v == value then
						return true
					end
				end
				return false
			else
				return values[idx] == value
			end
		end
	
		local function updateHighlight()
			for i, optionBtn in ipairs(optionButtons) do
				local value = values[i]
				local selected = isValueSelected(value)
	
				if selected then
					optionBtn.BackgroundColor3 = pal3.Accent
					optionBtn.BackgroundTransparency = 0.8
					optionBtn.TextColor3 = pal3.Accent
				else
					optionBtn.BackgroundColor3 = pal3.Card
					optionBtn.BackgroundTransparency = 0
					optionBtn.TextColor3 = pal3.Text
				end
	
				-- Update checkbox if multi-select
				if multiSelect then
					local checkbox = optionBtn:FindFirstChild("Checkbox")
					if checkbox then
						checkbox.Text = selected and "☑" or "☐"
						checkbox.TextColor3 = selected and pal3.Accent or pal3.TextSub
					end
				end
			end
		end
	
		local function updateOptionZIndices(base)
			for _, optionBtn in ipairs(optionButtons) do
				optionBtn.ZIndex = base
			end
		end
	
		local function collapseInline()
			dropdownList.Parent = inlineParent
			dropdownList.ZIndex = DROPDOWN_BASE_Z
			dropdownScroll.ZIndex = DROPDOWN_BASE_Z + 1
			updateOptionZIndices(dropdownScroll.ZIndex + 1)
			dropdownList.Position = UDim2.new(1, -(inlineWidth + 6), 0.5, 40)
			dropdownList.Size = UDim2.new(0, inlineWidth, 0, dropdownList.Size.Y.Offset)
		end
	
		local function applyOverlayZIndex(layer)
			layer = layer or currentOverlayLayer()
			local overlayBaseZ = layer and layer.ZIndex or 0
			local blockerZ = overlayBlocker and overlayBlocker.ZIndex or overlayBaseZ
			local dropdownZ = math.max(overlayBaseZ + 2, blockerZ + 1, DROPDOWN_BASE_Z)
			dropdownList.ZIndex = dropdownZ
			dropdownScroll.ZIndex = dropdownZ + 1
			updateOptionZIndices(dropdownScroll.ZIndex + 1)
		end
	
		local function positionDropdown(width, height, skipCreate)
			height = height or dropdownHeight
			width = width or math.max(btn.AbsoluteSize.X, inlineWidth)
	
			local layer = skipCreate and currentOverlayLayer() or resolveOverlayLayer()
	
			if layer then
				dropdownList.Parent = layer
				applyOverlayZIndex(layer)
	
				local overlayOffset = layer.AbsolutePosition
				local buttonPos = btn.AbsolutePosition
				local buttonSize = btn.AbsoluteSize
				local screenSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
	
				local dropdownX = buttonPos.X - overlayOffset.X + buttonSize.X - width
				local dropdownY = buttonPos.Y - overlayOffset.Y + buttonSize.Y + 4
	
				local minX = -overlayOffset.X + 4
				local maxX = screenSize.X - width - overlayOffset.X - 4
				local minY = -overlayOffset.Y + buttonSize.Y
				local maxY = screenSize.Y - height - overlayOffset.Y - 4
	
				dropdownX = math.clamp(dropdownX, minX, math.max(minX, maxX))
				dropdownY = math.clamp(dropdownY, minY, math.max(minY, maxY))
	
				dropdownList.Position = UDim2.fromOffset(dropdownX, dropdownY)
			else
				dropdownList.Parent = inlineParent
				dropdownList.ZIndex = DROPDOWN_BASE_Z
				dropdownScroll.ZIndex = DROPDOWN_BASE_Z + 1
				updateOptionZIndices(dropdownScroll.ZIndex + 1)
				dropdownList.Position = UDim2.new(1, -(width + 6), 0.5, 40)
			end
	
			dropdownList.Size = UDim2.new(0, width, 0, height)
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
			-- Calculate proper height: items + spacing + padding
			local spacingPerItem = 4  -- From UIListLayout.Padding
			local totalItemsHeight = (#values * itemHeight) + ((#values - 1) * spacingPerItem)
			local paddingTotal = 8 + 8  -- Top + Bottom padding (4+4 each side, doubled for Frame + Scroll)
	
	
			dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, totalItemsHeight + 8)  -- Add 8 for scroll padding
			dropdownHeight = math.min(totalItemsHeight + paddingTotal, maxHeight)
	
	
			if #values == 0 then
				idx = 0
			else
				-- Initialize idx from CurrentOption (single-select mode, Rayfield compatibility)
				if not multiSelect and o.CurrentOption then
					local currentVal
					if type(o.CurrentOption) == "table" and #o.CurrentOption > 0 then
						currentVal = o.CurrentOption[1]
					elseif type(o.CurrentOption) == "string" then
						currentVal = o.CurrentOption
					end
	
					if currentVal then
						for i, val in ipairs(values) do
							if val == currentVal then
								idx = i
								break
							end
						end
					end
				end
	
				if idx < 1 or idx > #values then
					idx = 1
				end
			end
			updateButtonText()
	
			for i, value in ipairs(values) do
				local optionBtn = Instance.new("TextButton")
				optionBtn.Name = "Option_" .. i
				optionBtn.Size = UDim2.new(1, -8, 0, 36)  -- Match itemHeight (40 - 4 for padding)
				local selected = isValueSelected(value)
				optionBtn.BackgroundColor3 = selected and pal3.Accent or pal3.Card
				optionBtn.BackgroundTransparency = selected and 0.8 or 0
				optionBtn.BorderSizePixel = 0
				optionBtn.Font = Enum.Font.GothamMedium  -- Changed to Medium for better readability
				optionBtn.TextSize = 14  -- Increased from 13 to 14 for clarity
				optionBtn.TextColor3 = selected and pal3.Accent or pal3.Text
				optionBtn.Text = tostring(value)
				optionBtn.TextXAlignment = multiSelect and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center
				optionBtn.AutoButtonColor = false
				optionBtn.LayoutOrder = i
				optionBtn.ZIndex = dropdownScroll.ZIndex + 1
				optionBtn.Parent = dropdownScroll
				corner(optionBtn, 6)
	
				-- Add checkbox for multi-select
				if multiSelect then
					local checkbox = Instance.new("TextLabel")
					checkbox.Name = "Checkbox"
					checkbox.BackgroundTransparency = 1
					checkbox.Size = UDim2.new(0, 24, 1, 0)
					checkbox.Position = UDim2.new(0, 8, 0, 0)
					checkbox.Font = Enum.Font.GothamBold
					checkbox.TextSize = 16
					checkbox.Text = selected and "☑" or "☐"
					checkbox.TextColor3 = selected and pal3.Accent or pal3.TextSub
					checkbox.ZIndex = optionBtn.ZIndex + 1
					checkbox.Parent = optionBtn
	
					-- Add padding for text after checkbox
					local textPadding = Instance.new("UIPadding")
					textPadding.PaddingLeft = UDim.new(0, 36)
					textPadding.Parent = optionBtn
				end
	
				optionBtn.MouseButton1Click:Connect(function()
					if locked() then return end
	
					if multiSelect then
						-- Toggle selection
						local found = false
						for k, v in ipairs(selectedValues) do
							if v == value then
								table.remove(selectedValues, k)
								found = true
								break
							end
						end
	
						if not found then
							table.insert(selectedValues, value)
						end
	
						updateButtonText()
						updateHighlight()
	
						if o.OnChanged then
							task.spawn(o.OnChanged, selectedValues)
						end
						if o.Flag then RvrseUI:_autoSave() end
					else
						-- Single select (close on click)
						idx = i
						updateButtonText()
						updateHighlight()
						setOpen(false)
	
						if o.OnChanged then
							task.spawn(o.OnChanged, value)
						end
						if o.Flag then RvrseUI:_autoSave() end
					end
				end)
	
				optionBtn.MouseEnter:Connect(function()
					if not isValueSelected(value) then
						Animator:Tween(optionBtn, {BackgroundColor3 = pal3.Hover}, Animator.Spring.Fast)
					end
				end)
	
				optionBtn.MouseLeave:Connect(function()
					if not isValueSelected(value) then
						Animator:Tween(optionBtn, {BackgroundColor3 = pal3.Card}, Animator.Spring.Fast)
					end
				end)
	
				optionButtons[i] = optionBtn
			end
	
			updateHighlight()
		end
	
		rebuildOptions()
		visual()
	
		-- Connect blocker click handler (called AFTER blocker is created)
		local function connectBlockerHandler()
			print("[DROPDOWN] 🔗 connectBlockerHandler() called")
			print(string.format("  - overlayBlocker exists: %s", tostring(overlayBlocker ~= nil)))
			print(string.format("  - OverlayService exists: %s", tostring(OverlayService ~= nil)))
	
			if overlayBlocker and OverlayService then
				print(string.format("  - overlayBlocker ClassName: %s", overlayBlocker.ClassName))
				print(string.format("  - overlayBlocker.Name: %s", overlayBlocker.Name))
				print(string.format("  - overlayBlocker.Parent: %s", tostring(overlayBlocker.Parent)))
				print(string.format("  - overlayBlocker.Visible: %s", tostring(overlayBlocker.Visible)))
				print(string.format("  - overlayBlocker.Modal: %s", tostring(overlayBlocker.Modal)))
				print(string.format("  - overlayBlocker.Active: %s", tostring(overlayBlocker.Active)))
				print(string.format("  - overlayBlocker.ZIndex: %d", overlayBlocker.ZIndex))
	
				if overlayBlockerConnection then
					print("[DROPDOWN] ⚠️ Disconnecting previous blocker connection")
					overlayBlockerConnection:Disconnect()
				end
	
				print("[DROPDOWN] 🎯 About to connect MouseButton1Click handler")
				print(string.format("  - setOpen exists: %s (type: %s)", tostring(setOpen ~= nil), type(setOpen)))
	
				-- Connect blocker click handler with inline function
				-- This creates a NEW closure each time, capturing the CURRENT scope
				overlayBlockerConnection = overlayBlocker.MouseButton1Click:Connect(function()
					print("=========================================================")
					print("[DROPDOWN] 🔴🔴🔴 BLOCKER CLICKED! Handler called")
					print("=========================================================")
					print(string.format("  - setOpen type at click time: %s", type(setOpen)))
					print(string.format("  - setOpen exists: %s", tostring(setOpen ~= nil)))
	
					if setOpen then
						print("[DROPDOWN] ✅ setOpen EXISTS! Calling setOpen(false)...")
						setOpen(false)
						print("[DROPDOWN] ✅ Dropdown closed successfully!")
					else
						print("[DROPDOWN] ❌❌❌ ERROR: setOpen is nil at click time!")
					end
					print("=========================================================")
				end)
	
				print(string.format("  - Connection created: %s (type: %s)", tostring(overlayBlockerConnection ~= nil), type(overlayBlockerConnection)))
				print("[DROPDOWN] ✅ Blocker handler connected with inline function!")
			else
				print("[DROPDOWN] ❌ Cannot connect handler - blocker or service missing")
			end
		end
	
		setOpen = function(state)
			print(string.format("[DROPDOWN] 🎯 setOpen(%s) called", tostring(state)))
			if locked() then
				print("[DROPDOWN] ⛔ Dropdown is locked, ignoring")
				return
			end
	
			if state == dropdownOpen then
				print(string.format("[DROPDOWN] State already %s, skipping", tostring(state)))
				if state then
					positionDropdown(math.max(btn.AbsoluteSize.X, inlineWidth, 150), dropdownHeight, true)
				end
				return
			end
	
			dropdownOpen = state
			arrow.Text = dropdownOpen and "▲" or "▼"
			print(string.format("[DROPDOWN] dropdownOpen now: %s, arrow: %s", tostring(dropdownOpen), arrow.Text))
	
			if dropdownOpen then
				print("[DROPDOWN] 🟢 OPENING dropdown")
				if o.OnOpen then
					o.OnOpen()
				end
	
				-- Calculate proper dropdown height
				local spacingPerItem = 4
				local totalItemsHeight = (#values * itemHeight) + ((#values - 1) * spacingPerItem)
				local paddingTotal = 8 + 8
	
				dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, totalItemsHeight + 8)
				dropdownHeight = math.min(totalItemsHeight + paddingTotal, maxHeight)
	
				-- Ensure minimum height if there are items
				if #values > 0 then
					dropdownHeight = math.max(dropdownHeight, itemHeight + paddingTotal)
				end
	
				showOverlayBlocker()
				print("[DROPDOWN] 🚨 About to call connectBlockerHandler()")
				print(string.format("  - We are INSIDE setOpen function body (state=%s)", tostring(state)))
				print(string.format("  - setOpen variable in THIS scope: %s (type: %s)", tostring(setOpen ~= nil), type(setOpen)))
				connectBlockerHandler()  -- Connect handler AFTER setOpen is fully defined
				print("[DROPDOWN] 🚨 connectBlockerHandler() call completed")
	
				local targetWidth = math.max(btn.AbsoluteSize.X, inlineWidth, 150)  -- Minimum 150px width
				positionDropdown(targetWidth, dropdownHeight)
	
				dropdownList.Visible = true
				dropdownScroll.CanvasPosition = Vector2.new(0, 0)
			else
				print("[DROPDOWN] 🔴 CLOSING dropdown")
				local layer = currentOverlayLayer()
				local targetWidth = layer and math.max(btn.AbsoluteSize.X, inlineWidth) or inlineWidth
				dropdownList.Visible = false
				dropdownList.Size = UDim2.new(0, targetWidth, 0, 0)
				collapseInline()
				print("[DROPDOWN] Calling hideOverlayBlocker()")
				hideOverlayBlocker(false)
				print("[DROPDOWN] ✅ Dropdown closed successfully")
				if o.OnClose then
					o.OnClose()
				end
			end
		end
	
		-- Toggle dropdown on button click
		btn.MouseButton1Click:Connect(function()
			-- Refresh dropdown values before opening (for dynamic config lists)
			if not dropdownOpen then
				-- If a refresh callback is provided, use it to get new values
				if o.OnRefresh then
					local newValues = o.OnRefresh()
					if newValues and type(newValues) == "table" then
						values = {}
						for _, val in ipairs(newValues) do
							table.insert(values, val)
						end
						rebuildOptions()
					else
						warn("[Dropdown] OnRefresh returned invalid data: " .. tostring(type(newValues)))
					end
				elseif o.RefreshOnOpen then
					rebuildOptions()
				end
			end
	
			setOpen(not dropdownOpen)
		end)
	
		-- Close when clicking outside (inline mode)
		UIS.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				if not dropdownOpen then return end
				if currentOverlayLayer() then return end
	
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
	
			f.Destroying:Connect(function()
				if dropdownOpen then
					hideOverlayBlocker(true)
					dropdownOpen = false
				end
			end)
	
	
		-- Build dropdownAPI methods
		dropdownAPI.Set = function(_, v, suppressCallback)
			if multiSelect then
				-- For multi-select, v should be an array
				if type(v) == "table" then
					selectedValues = {}
					for _, val in ipairs(v) do
						table.insert(selectedValues, val)
					end
				else
					selectedValues = {}
				end
	
				updateButtonText()
				updateHighlight()
				visual()
	
				if not suppressCallback and o.OnChanged then
					task.spawn(o.OnChanged, selectedValues)
				end
			else
				-- Single select mode
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
			end
		end
	
		dropdownAPI.Get = function()
			if multiSelect then
				return selectedValues
			else
				return values[idx]
			end
		end
	
		dropdownAPI.Refresh = function(_, newValues)
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
				positionDropdown(nil, dropdownHeight)
			end
		end
	
		dropdownAPI.SetVisible = function(_, visible)
			f.Visible = visible
		end
	
		dropdownAPI.SetOpen = function(_, state)
			setOpen(state and true or false)
		end
	
		-- Multi-select specific methods
		dropdownAPI.SelectAll = function(_)
			if multiSelect then
				selectedValues = {}
				for _, val in ipairs(values) do
					table.insert(selectedValues, val)
				end
				updateButtonText()
				updateHighlight()
				if o.OnChanged then
					task.spawn(o.OnChanged, selectedValues)
				end
				if o.Flag then RvrseUI:_autoSave() end
			end
		end
	
		dropdownAPI.ClearAll = function(_)
			if multiSelect then
				selectedValues = {}
				updateButtonText()
				updateHighlight()
				if o.OnChanged then
					task.spawn(o.OnChanged, selectedValues)
				end
				if o.Flag then RvrseUI:_autoSave() end
			end
		end
	
		dropdownAPI.IsMultiSelect = function()
			return multiSelect
		end
	
		-- Add CurrentOption property (Rayfield compatibility)
		-- This returns the current selection as a table (like Rayfield)
		dropdownAPI.CurrentOption = multiSelect and selectedValues or (values[idx] and {values[idx]} or {})
	
		if o.Flag then
			RvrseUI.Flags[o.Flag] = dropdownAPI
		end
	
		return dropdownAPI
	end
end


-- ========================
-- DropdownLegacy Module
-- ========================

do
	
	DropdownLegacy = {}
	
	function DropdownLegacy.Create(o, dependencies)
		o = o or {}
	
		local card = dependencies.card
		local corner = dependencies.corner
		local stroke = dependencies.stroke
		local shadow = dependencies.shadow
		local pal3 = dependencies.pal3
		local Animator = dependencies.Animator
		local RvrseUI = dependencies.RvrseUI
		local UIS = dependencies.UIS
	
		local values = {}
		for _, v in ipairs(o.Values or {}) do
			values[#values + 1] = v
		end
	
		local maxHeight = o.MaxHeight or 160
		local itemHeight = o.ItemHeight or 32
		local dropdownHeight = 0
		local idx = 1
	
		if o.Default then
			for i, v in ipairs(values) do
				if v == o.Default then
					idx = i
					break
				end
			end
		end
	
		local f = card(48)
		f.ClipsDescendants = false
	
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
	
	local dropdownWidth = btn.Size.X.Offset
	
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
	
		local dropdownList = Instance.new("Frame")
		dropdownList.Name = "DropdownList"
		dropdownList.BackgroundColor3 = pal3.Elevated
		dropdownList.BorderSizePixel = 0
	dropdownList.Position = UDim2.new(1, -(dropdownWidth + 6), 0.5, 40)
	dropdownList.Size = UDim2.new(0, dropdownWidth, 0, 0)
		dropdownList.Visible = false
		dropdownList.ZIndex = 100
		dropdownList.ClipsDescendants = true
		dropdownList.Parent = f
		corner(dropdownList, 8)
		stroke(dropdownList, pal3.Accent, 1)
		-- shadow(dropdownList, 0.6, 16)  -- ⚠️ DISABLED: Shadows on dropdown menus can cause visual issues
	
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
	
		local dropdownPadding = Instance.new("UIPadding")
		dropdownPadding.PaddingTop = UDim.new(0, 4)
		dropdownPadding.PaddingBottom = UDim.new(0, 4)
		dropdownPadding.PaddingLeft = UDim.new(0, 4)
		dropdownPadding.PaddingRight = UDim.new(0, 4)
		dropdownPadding.Parent = dropdownScroll
	
		local dropdownOpen = false
		local optionButtons = {}
	
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
	
		local function updateButtonText()
			if values[idx] then
				btn.Text = tostring(values[idx])
			else
				btn.Text = o.PlaceholderText or "Select"
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
	
		local function rebuildOptions(newValues)
		if newValues then
			table.clear(values)
			for _, val in ipairs(newValues) do
				values[#values + 1] = val
			end
			if #values == 0 then
				idx = 0
			else
				idx = math.clamp(idx, 1, #values)
			end
		end
	
			for _, child in ipairs(dropdownScroll:GetChildren()) do
				if child:IsA("TextButton") then
					child:Destroy()
				end
			end
	
			table.clear(optionButtons)
	
			dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, #values * itemHeight)
			dropdownHeight = math.min(#values * itemHeight, maxHeight)
	
			for i, value in ipairs(values) do
				local optionBtn = Instance.new("TextButton")
				optionBtn.Name = "Option_" .. i
				optionBtn.Size = UDim2.new(1, -8, 0, itemHeight - 4)
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
					dropdownOpen = false
					arrow.Text = "▼"
	
				Animator:Tween(dropdownList, {
					Size = UDim2.new(0, dropdownWidth, 0, 0)
				}, Animator.Spring.Fast)
	
					task.delay(0.15, function()
						if dropdownList and dropdownList.Parent then
							dropdownList.Visible = false
						end
					end)
	
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
	
			updateButtonText()
			updateHighlight()
		end
	
		rebuildOptions()
		visual()
	
		local function toggleDropdown()
			if locked() then
				return
			end
	
		if not dropdownOpen then
			if o.OnRefresh then
				local newValues = o.OnRefresh()
				if type(newValues) == "table" then
					rebuildOptions(newValues)
				end
			elseif o.RefreshOnOpen then
				rebuildOptions()
			end
	
			if o.OnOpen then
				o.OnOpen()
			end
	
			dropdownOpen = true
			arrow.Text = "▲"
	
			dropdownList.Size = UDim2.new(0, dropdownWidth, 0, 0)
			dropdownList.Visible = true
			dropdownList.ZIndex = 100
	
			print(string.format("[DropdownLegacy] opening '%s' with %d options", o.Text or "Dropdown", #values))
	
			if #values == 0 then
				print("[DropdownLegacy] no options available, skipping expand")
				dropdownOpen = false
				arrow.Text = "▼"
				dropdownList.Visible = false
				return
			end
	
			Animator:Tween(dropdownList, {
				Size = UDim2.new(0, dropdownWidth, 0, dropdownHeight)
			}, Animator.Spring.Snappy)
		else
			dropdownOpen = false
			arrow.Text = "▼"
	
			Animator:Tween(dropdownList, {
				Size = UDim2.new(0, dropdownWidth, 0, 0)
			}, Animator.Spring.Fast)
	
			task.delay(0.15, function()
				if dropdownList and dropdownList.Parent then
					dropdownList.Visible = false
				end
			end)
	
			if o.OnClose then
				o.OnClose()
			end
		end
	end
	
		btn.MouseButton1Click:Connect(toggleDropdown)
	
		UIS.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				if not dropdownOpen then return end
	
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
					toggleDropdown()
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
					idx = #values > 0 and 1 or 0
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
				rebuildOptions(newValues)
				visual()
			end,
	
			SetVisible = function(_, visible)
				f.Visible = visible
			end,
	
			CurrentOption = values[idx],
			SetOpen = function(_, state)
				if state then
					if not dropdownOpen then
						toggleDropdown()
					end
				else
					if dropdownOpen then
						toggleDropdown()
					end
				end
			end
		}
	
		if o.Flag then
			RvrseUI.Flags[o.Flag] = dropdownAPI
		end
	
		return dropdownAPI
	end
end


-- ========================
-- Slider Module
-- ========================

do
	
	Slider = {}
	
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
		local Theme = dependencies.Theme
	
		local minVal = o.Min or 0
		local maxVal = o.Max or 100
		local step = o.Step or 1
		local value = o.Default or minVal
		local range = maxVal - minVal
		if range == 0 then
			range = 1
		end
		local baseLabelText = o.Text or "Slider"
	
		local f = card(64) -- Taller for modern layout
	
		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Size = UDim2.new(1, -60, 0, 22)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 15
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextColor3 = pal3.Text
		lbl.Text = string.format("%s: %s", baseLabelText, tostring(value))
		lbl.Parent = f
	
		-- Value display (right-aligned)
		local valueLbl = Instance.new("TextLabel")
		valueLbl.BackgroundTransparency = 1
		valueLbl.AnchorPoint = Vector2.new(1, 0)
		valueLbl.Position = UDim2.new(1, -6, 0, 0)
		valueLbl.Size = UDim2.new(0, 50, 0, 22)
		valueLbl.Font = Enum.Font.GothamBold
		valueLbl.TextSize = 14
		valueLbl.TextXAlignment = Enum.TextXAlignment.Right
		valueLbl.TextColor3 = pal3.Accent
		valueLbl.Text = tostring(value)
		valueLbl.Parent = f
	
		-- Track (thicker for better interaction)
		local track = Instance.new("Frame")
		track.Position = UDim2.new(0, 0, 0, 32)
		track.Size = UDim2.new(1, 0, 0, 10)
		track.BackgroundColor3 = pal3.Card
		track.BorderSizePixel = 0
		track.Parent = f
		corner(track, 5)
	
		-- Track border glow
		local trackStroke = Instance.new("UIStroke")
		trackStroke.Color = pal3.BorderGlow
		trackStroke.Thickness = 1
		trackStroke.Transparency = 0.7
		trackStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		trackStroke.Parent = track
	
		-- Vibrant gradient fill
		local fill = Instance.new("Frame")
		local initialRatio = range > 0 and ((value - minVal) / range) or 0
		fill.Size = UDim2.new(initialRatio, 0, 1, 0)
		fill.BackgroundColor3 = pal3.Accent
		fill.BorderSizePixel = 0
		fill.ZIndex = 2
		fill.Parent = track
		corner(fill, 5)
	
		-- Multi-color gradient on fill
		local fillGradient = Instance.new("UIGradient")
		fillGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, pal3.Primary),
			ColorSequenceKeypoint.new(0.5, pal3.Accent),
			ColorSequenceKeypoint.new(1, pal3.Secondary),
		}
		fillGradient.Rotation = 0 -- Horizontal gradient
		fillGradient.Parent = fill
	
		-- Premium thumb with glow
		local thumb = Instance.new("Frame")
		thumb.AnchorPoint = Vector2.new(0.5, 0.5)
		thumb.Position = UDim2.new(initialRatio, 0, 0.5, 0)
		thumb.Size = UDim2.new(0, 22, 0, 22) -- Larger for modern look
		thumb.BackgroundColor3 = Color3.new(1, 1, 1)
		thumb.BorderSizePixel = 0
		thumb.ZIndex = 4
		thumb.Parent = track
		corner(thumb, 11)
		shadow(thumb, 0.5, 5) -- Enhanced shadow
	
		-- Glowing stroke around thumb
		local glowStroke = Instance.new("UIStroke")
		glowStroke.Color = pal3.Accent
		glowStroke.Thickness = 0
		glowStroke.Transparency = 0.2
		glowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		glowStroke.Parent = thumb
	
		local dragging = false
		local hovering = false
	
		local suffix = o.Suffix or ""
	
		local function updateLabelText(newValue)
			local displayValue = suffix ~= "" and (tostring(newValue) .. suffix) or tostring(newValue)
			lbl.Text = string.format("%s: %s", baseLabelText, displayValue)
			valueLbl.Text = displayValue
		end
	
		local function update(inputPos)
			local relativeX = math.clamp((inputPos.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
			value = math.round((minVal + relativeX * range) / step) * step
			value = math.clamp(value, minVal, maxVal)
			local snappedRatio = range > 0 and ((value - minVal) / range) or 0
			updateLabelText(value)
	
			-- Ultra-smooth animations
			Animator:Tween(fill, {Size = UDim2.new(snappedRatio, 0, 1, 0)}, Animator.Spring.Butter)
			Animator:Tween(thumb, {Position = UDim2.new(snappedRatio, 0, 0.5, 0)}, Animator.Spring.Glide)
	
			if o.OnChanged then task.spawn(o.OnChanged, value) end
			if o.Flag then RvrseUI:_autoSave() end
		end
	
		-- Enhanced hover effects
		track.MouseEnter:Connect(function()
			if RvrseUI.Store:IsLocked(o.RespectLock) then return end
			hovering = true
	
			-- Thumb grows
			Animator:Tween(thumb, {Size = UDim2.new(0, 24, 0, 24)}, Animator.Spring.Snappy)
	
			-- Subtle glow appears
			Animator:Tween(glowStroke, {Thickness = 2}, Animator.Spring.Snappy)
	
			-- Track border brightens
			Animator:Tween(trackStroke, {Transparency = 0.4}, Animator.Spring.Lightning)
		end)
	
		track.MouseLeave:Connect(function()
			if dragging then return end
			hovering = false
	
			-- Thumb shrinks
			Animator:Tween(thumb, {Size = UDim2.new(0, 22, 0, 22)}, Animator.Spring.Bounce)
	
			-- Glow fades
			Animator:Tween(glowStroke, {Thickness = 0}, Animator.Spring.Snappy)
	
			-- Track restores
			Animator:Tween(trackStroke, {Transparency = 0.7}, Animator.Spring.Snappy)
		end)
	
		-- Dragging: GROW, GLOW, and vibrant feedback
		track.InputBegan:Connect(function(io)
			if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
				if RvrseUI.Store:IsLocked(o.RespectLock) then return end
				dragging = true
	
				-- GROW: Thumb expands dramatically
				Animator:Tween(thumb, {Size = UDim2.new(0, 28, 0, 28)}, Animator.Spring.Pop)
	
				-- GLOW: Strong accent ring
				Animator:Tween(glowStroke, {Thickness = 4}, Animator.Spring.Snappy)
	
				-- Track glows brighter
				Animator:Tween(trackStroke, {
					Thickness = 2,
					Transparency = 0.2
				}, Animator.Spring.Lightning)
	
				-- Value label pulses
				Animator:Pulse(valueLbl, 1.1, Animator.Spring.Lightning)
	
				update(io.Position)
			end
		end)
	
		track.InputEnded:Connect(function(io)
			if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
				dragging = false
	
				-- SHRINK: Return to hover or normal size with bounce
				local targetSize = hovering and 24 or 22
				Animator:Tween(thumb, {Size = UDim2.new(0, targetSize, 0, targetSize)}, Animator.Spring.Bounce)
	
				-- GLOW: Fade to hover or off
				local targetThickness = hovering and 2 or 0
				Animator:Tween(glowStroke, {Thickness = targetThickness}, Animator.Spring.Glide)
	
				-- Track restores
				Animator:Tween(trackStroke, {
					Thickness = 1,
					Transparency = hovering and 0.4 or 0.7
				}, Animator.Spring.Snappy)
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
	
		local sliderAPI
	
		local function setValueDirect(newValue)
			value = math.clamp(newValue, minVal, maxVal)
			local relativeX = range > 0 and ((value - minVal) / range) or 0
			updateLabelText(value)
			fill.Size = UDim2.new(relativeX, 0, 1, 0)
			thumb.Position = UDim2.new(relativeX, 0, 0.5, 0)
			if sliderAPI then
				sliderAPI.CurrentValue = value
			end
		end
	
		sliderAPI = {
			Set = function(_, v)
				setValueDirect(v)
			end,
			SetRange = function(_, newMin, newMax, newStep)
				-- Rayfield-compatible SetRange method
				-- Update min/max/step at runtime and recalculate current value
				minVal = newMin or minVal
				maxVal = newMax or maxVal
				step = newStep or step
				range = maxVal - minVal
				if range == 0 then
					range = 1
				end
				-- Clamp current value to new range
				value = math.clamp(value, minVal, maxVal)
				setValueDirect(value)
			end,
			SetSuffix = function(_, newSuffix)
				-- Rayfield-compatible SetSuffix method
				-- Update the suffix displayed after the value (e.g., "%", " items", " HP")
				suffix = newSuffix or ""
				updateLabelText(value)
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
end


-- ========================
-- Keybind Module
-- ========================

do
	
	Keybind = {}
	
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
		local Theme = dependencies.Theme
	
		local f = card(48) -- Taller for modern look
	
		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Size = UDim2.new(1, -150, 1, 0)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 15
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextColor3 = pal3.Text
		lbl.Text = o.Text or "Keybind"
		lbl.Parent = f
	
		-- Modern key display button
		local btn = Instance.new("TextButton")
		btn.AnchorPoint = Vector2.new(1, 0.5)
		btn.Position = UDim2.new(1, -6, 0.5, 0)
		btn.Size = UDim2.new(0, 140, 0, 36)
		btn.BackgroundColor3 = pal3.Card
		btn.BackgroundTransparency = 0.2
		btn.BorderSizePixel = 0
		btn.Font = Enum.Font.Code
		btn.TextSize = 13
		btn.TextColor3 = pal3.TextBright
		btn.Text = (o.Default and o.Default.Name) or "Set Key"
		btn.AutoButtonColor = false
		btn.Parent = f
		corner(btn, 10)
	
		-- Border stroke
		local btnStroke = Instance.new("UIStroke")
		btnStroke.Color = pal3.Border
		btnStroke.Thickness = 1
		btnStroke.Transparency = 0.5
		btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		btnStroke.Parent = btn
	
		-- Gradient overlay (shows when capturing)
		local btnGradient = Instance.new("UIGradient")
		btnGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, pal3.Primary),
			ColorSequenceKeypoint.new(0.5, pal3.Accent),
			ColorSequenceKeypoint.new(1, pal3.Secondary),
		}
		btnGradient.Rotation = 45
		btnGradient.Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 1),
		}
		btnGradient.Parent = btn
	
		local capturing = false
		local currentKey = o.Default
	
		btn.MouseButton1Click:Connect(function()
			if RvrseUI.Store:IsLocked(o.RespectLock) then return end
			capturing = true
			btn.Text = "⌨️ Press any key..."
	
			-- Activate gradient background (set directly - can't tween NumberSequence)
			btnGradient.Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0.5),
				NumberSequenceKeypoint.new(1, 0.5),
			}
	
			-- Glow border
			Animator:Tween(btnStroke, {
				Color = pal3.Accent,
				Thickness = 2,
				Transparency = 0.2
			}, Animator.Spring.Snappy)
	
			-- Shimmer effect
			Animator:Shimmer(btn, Theme)
	
			-- Pulse
			Animator:Pulse(btn, 1.05, Animator.Spring.Bounce)
		end)
	
		UIS.InputBegan:Connect(function(io, gpe)
			if gpe or not capturing then return end
			if io.KeyCode ~= Enum.KeyCode.Unknown then
				capturing = false
				currentKey = io.KeyCode
				btn.Text = io.KeyCode.Name
	
				-- Deactivate gradient (set directly - can't tween NumberSequence)
				btnGradient.Transparency = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(1, 1),
				}
	
				-- Restore border
				Animator:Tween(btnStroke, {
					Color = pal3.Border,
					Thickness = 1,
					Transparency = 0.5
				}, Animator.Spring.Snappy)
	
				-- Success pulse
				Animator:Pulse(btn, 1.08, Animator.Spring.Bounce)
	
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
				if o.Flag then RvrseUI:_autoSave() end
			end
		end)
	
		btn.MouseEnter:Connect(function()
			if not capturing then
				Animator:Tween(btn, {BackgroundTransparency = 0.1}, Animator.Spring.Lightning)
				Animator:Tween(btnStroke, {Transparency = 0.3}, Animator.Spring.Lightning)
			end
		end)
		btn.MouseLeave:Connect(function()
			if not capturing then
				Animator:Tween(btn, {BackgroundTransparency = 0.2}, Animator.Spring.Snappy)
				Animator:Tween(btnStroke, {Transparency = 0.5}, Animator.Spring.Snappy)
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
end


-- ========================
-- TextBox Module
-- ========================

do
	
	TextBox = {}
	
	function TextBox.Create(o, dependencies)
		o = o or {}
	
		-- Extract dependencies
		local card = dependencies.card
		local corner = dependencies.corner
		local stroke = dependencies.stroke
		local pal3 = dependencies.pal3
		local Animator = dependencies.Animator
		local RvrseUI = dependencies.RvrseUI
		local Theme = dependencies.Theme
	
		local f = card(52) -- Taller for modern look
	
		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Size = UDim2.new(1, -260, 1, 0)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 15
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextColor3 = pal3.Text
		lbl.Text = o.Text or "Input"
		lbl.Parent = f
	
		-- Modern input container
		local inputBox = Instance.new("TextBox")
		inputBox.AnchorPoint = Vector2.new(1, 0.5)
		inputBox.Position = UDim2.new(1, -8, 0.5, 0)
		inputBox.Size = UDim2.new(0, 240, 0, 36)
		inputBox.BackgroundColor3 = pal3.Card
		inputBox.BackgroundTransparency = 0.3
		inputBox.BorderSizePixel = 0
		inputBox.Font = Enum.Font.GothamMedium
		inputBox.TextSize = 14
		inputBox.TextColor3 = pal3.TextBright
		inputBox.PlaceholderText = o.Placeholder or "Enter text..."
		inputBox.PlaceholderColor3 = pal3.TextMuted
		inputBox.Text = o.Default or ""
		inputBox.ClearTextOnFocus = false
		inputBox.Parent = f
		corner(inputBox, 10)
	
		-- Subtle border (default state)
		local borderStroke = Instance.new("UIStroke")
		borderStroke.Color = pal3.Border
		borderStroke.Thickness = 1
		borderStroke.Transparency = 0.6
		borderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		borderStroke.Parent = inputBox
	
		-- Gradient underline (glows on focus)
		local underline = Instance.new("Frame")
		underline.AnchorPoint = Vector2.new(0.5, 1)
		underline.Position = UDim2.new(0.5, 0, 1, 0)
		underline.Size = UDim2.new(0, 0, 0, 3)
		underline.BackgroundColor3 = pal3.Accent
		underline.BorderSizePixel = 0
		underline.ZIndex = 5
		underline.Parent = inputBox
		corner(underline, 2)
	
		-- Gradient on underline
		local underlineGradient = Instance.new("UIGradient")
		underlineGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, pal3.Primary),
			ColorSequenceKeypoint.new(0.5, pal3.Accent),
			ColorSequenceKeypoint.new(1, pal3.Secondary),
		}
		underlineGradient.Rotation = 0
		underlineGradient.Parent = underline
	
		local currentValue = inputBox.Text
		local isFocused = false
	
		-- Focus: Glow and expand underline
		inputBox.Focused:Connect(function()
			isFocused = true
	
			-- Background brightens
			Animator:Tween(inputBox, {BackgroundTransparency = 0.1}, Animator.Spring.Lightning)
	
			-- Border glows
			Animator:Tween(borderStroke, {
				Color = pal3.Accent,
				Thickness = 2,
				Transparency = 0.3
			}, Animator.Spring.Snappy)
	
			-- Underline expands from center
			Animator:Tween(underline, {Size = UDim2.new(1, 0, 0, 3)}, Animator.Spring.Spring)
	
			-- Label brightens
			Animator:Tween(lbl, {TextColor3 = pal3.TextBright}, Animator.Spring.Lightning)
	
			-- Add shimmer effect
			Animator:Shimmer(inputBox, Theme)
		end)
	
		-- Blur: Restore
		inputBox.FocusLost:Connect(function(enterPressed)
			isFocused = false
			currentValue = inputBox.Text
	
			-- Background dims
			Animator:Tween(inputBox, {BackgroundTransparency = 0.3}, Animator.Spring.Snappy)
	
			-- Border restores
			Animator:Tween(borderStroke, {
				Color = pal3.Border,
				Thickness = 1,
				Transparency = 0.6
			}, Animator.Spring.Snappy)
	
			-- Underline collapses
			Animator:Tween(underline, {Size = UDim2.new(0, 0, 0, 3)}, Animator.Spring.Glide)
	
			-- Label restores
			Animator:Tween(lbl, {TextColor3 = pal3.Text}, Animator.Spring.Snappy)
	
			if o.OnChanged then
				task.spawn(o.OnChanged, currentValue, enterPressed)
			end
			if o.Flag then RvrseUI:_autoSave() end
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
end


-- ========================
-- ColorPicker Module
-- ========================

do
	
	ColorPicker = {}
	
	local function RGBtoHSV(r, g, b)
		r, g, b = r / 255, g / 255, b / 255
		local max = math.max(r, g, b)
		local min = math.min(r, g, b)
		local delta = max - min
	
		local h, s, v = 0, 0, max
	
		if delta > 0 then
			s = delta / max
	
			if max == r then
				h = ((g - b) / delta) % 6
			elseif max == g then
				h = (b - r) / delta + 2
			else
				h = (r - g) / delta + 4
			end
	
			h = h * 60
			if h < 0 then h = h + 360 end
		end
	
		return math.floor(h + 0.5), math.floor(s * 100 + 0.5), math.floor(v * 100 + 0.5)
	end
	
	local function HSVtoRGB(h, s, v)
		s, v = s / 100, v / 100
		local c = v * s
		local x = c * (1 - math.abs(((h / 60) % 2) - 1))
		local m = v - c
	
		local r, g, b = 0, 0, 0
	
		if h >= 0 and h < 60 then
			r, g, b = c, x, 0
		elseif h >= 60 and h < 120 then
			r, g, b = x, c, 0
		elseif h >= 120 and h < 180 then
			r, g, b = 0, c, x
		elseif h >= 180 and h < 240 then
			r, g, b = 0, x, c
		elseif h >= 240 and h < 300 then
			r, g, b = x, 0, c
		else
			r, g, b = c, 0, x
		end
	
		r, g, b = (r + m) * 255, (g + m) * 255, (b + m) * 255
		return math.floor(r + 0.5), math.floor(g + 0.5), math.floor(b + 0.5)
	end
	
	local function Color3ToHex(color)
		local r = math.floor(color.R * 255 + 0.5)
		local g = math.floor(color.G * 255 + 0.5)
		local b = math.floor(color.B * 255 + 0.5)
		return string.format("#%02X%02X%02X", r, g, b)
	end
	
	local function HexToColor3(hex)
		hex = hex:gsub("#", "")
		if #hex ~= 6 then return nil end
	
		local r = tonumber(hex:sub(1, 2), 16)
		local g = tonumber(hex:sub(3, 4), 16)
		local b = tonumber(hex:sub(5, 6), 16)
	
		if not r or not g or not b then return nil end
		return Color3.fromRGB(r, g, b)
	end
	
	function ColorPicker.Create(o, dependencies)
		o = o or {}
	
		-- Extract dependencies
		local card = dependencies.card
		local corner = dependencies.corner
		local stroke = dependencies.stroke
		local shadow = dependencies.shadow
		local pal3 = dependencies.pal3
		local Animator = dependencies.Animator
		local RvrseUI = dependencies.RvrseUI
		local Theme = dependencies.Theme
		local baseOverlayLayer = dependencies.OverlayLayer
		local OverlayService = dependencies.Overlay
	
		-- DEBUG: Check overlay layer availability
		print("[ColorPicker] Creating ColorPicker, Advanced =", o.Advanced ~= false)
		print("[ColorPicker] OverlayLayer from deps:", baseOverlayLayer)
		print("[ColorPicker] OverlayService:", OverlayService)
	
		if OverlayService and not baseOverlayLayer then
			baseOverlayLayer = OverlayService:GetLayer()
			print("[ColorPicker] Got layer from OverlayService:", baseOverlayLayer)
		end
	
		if not baseOverlayLayer then
			warn("[ColorPicker] ⚠️ CRITICAL: No OverlayLayer available! Panel will parent to element card and may be clipped!")
		end
	
		-- Settings
		local advancedMode = o.Advanced ~= false  -- Default to advanced mode
		local defaultColor = o.Default or pal3.Accent
		local currentColor = defaultColor
	
		-- Extract RGB from default color
		local r = math.floor(currentColor.R * 255 + 0.5)
		local g = math.floor(currentColor.G * 255 + 0.5)
		local b = math.floor(currentColor.B * 255 + 0.5)
		local h, s, v = RGBtoHSV(r, g, b)
	
		local updatingSliders = false  -- Prevent circular updates
	
		-- Declare slider variables (used in advanced mode)
		local rSlider, gSlider, bSlider, hSlider, sSlider, vSlider, hexInput
	
		-- Base card
		local f = card(48)
		f.ClipsDescendants = false
	
		-- Label
		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Size = UDim2.new(1, -90, 1, 0)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 15
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextColor3 = pal3.Text
		lbl.Text = o.Text or "Color"
		lbl.Parent = f
	
		-- Circular preview button
		local preview = Instance.new("TextButton")
		preview.AnchorPoint = Vector2.new(1, 0.5)
		preview.Position = UDim2.new(1, -6, 0.5, 0)
		preview.Size = UDim2.new(0, 40, 0, 40)
		preview.BackgroundColor3 = currentColor
		preview.BorderSizePixel = 0
		preview.Text = ""
		preview.AutoButtonColor = false
		preview.Parent = f
		corner(preview, 20)
	
		-- Glowing stroke
		local previewStroke = Instance.new("UIStroke")
		previewStroke.Color = pal3.Border
		previewStroke.Thickness = 2
		previewStroke.Transparency = 0.4
		previewStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		previewStroke.Parent = preview
	
		-- Advanced mode: Color picker panel
		local pickerPanel
		local pickerOpen = false
		local overlayBlocker
		local overlayBlockerConnection
	
		if advancedMode then
			-- Panel container
			pickerPanel = Instance.new("Frame")
			pickerPanel.Name = "ColorPickerPanel"
			pickerPanel.BackgroundColor3 = pal3.Elevated
			pickerPanel.BackgroundTransparency = 0  -- Fully opaque
			pickerPanel.BorderSizePixel = 0
			pickerPanel.Size = UDim2.new(0, 320, 0, 0)  -- Start collapsed
			pickerPanel.Position = UDim2.new(1, -(320 + 6), 0.5, 52)
			pickerPanel.Visible = false
			pickerPanel.ZIndex = 200  -- Above blocker (100)
			pickerPanel.ClipsDescendants = false  -- Don't clip during animation
	
			-- Parent to overlay layer if available, otherwise to element card
			local panelParent = baseOverlayLayer or f
			pickerPanel.Parent = panelParent
	
			-- DEBUG: Log panel creation
			print("[ColorPicker] Panel created:")
			print("  Parent:", pickerPanel.Parent)
			print("  Parent Name:", pickerPanel.Parent and pickerPanel.Parent.Name or "nil")
			print("  Size:", pickerPanel.Size)
			print("  Visible:", pickerPanel.Visible)
			print("  BackgroundTransparency:", pickerPanel.BackgroundTransparency)
			print("  ZIndex:", pickerPanel.ZIndex)
	
			corner(pickerPanel, 12)
			stroke(pickerPanel, pal3.Accent, 2)
			-- shadow(pickerPanel, 0.7, 20)  -- ❌ DISABLED: Shadow too large for overlay panels, blocks entire screen!
	
			-- Panel padding
			local panelPadding = Instance.new("UIPadding")
			panelPadding.PaddingTop = UDim.new(0, 12)
			panelPadding.PaddingBottom = UDim.new(0, 12)
			panelPadding.PaddingLeft = UDim.new(0, 12)
			panelPadding.PaddingRight = UDim.new(0, 12)
			panelPadding.Parent = pickerPanel
	
			-- Panel layout
			local panelLayout = Instance.new("UIListLayout")
			panelLayout.FillDirection = Enum.FillDirection.Vertical
			panelLayout.SortOrder = Enum.SortOrder.LayoutOrder
			panelLayout.Padding = UDim.new(0, 8)
			panelLayout.Parent = pickerPanel
	
			-- Helper: Create a slider row
			local function createSlider(name, min, max, default, callback)
				local row = Instance.new("Frame")
				row.BackgroundTransparency = 1
				row.Size = UDim2.new(1, 0, 0, 32)
				row.LayoutOrder = #pickerPanel:GetChildren()
				row.Parent = pickerPanel
	
				local label = Instance.new("TextLabel")
				label.BackgroundTransparency = 1
				label.Size = UDim2.new(0, 40, 1, 0)
				label.Font = Enum.Font.GothamMedium
				label.TextSize = 13
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.TextColor3 = pal3.Text
				label.Text = name
				label.Parent = row
	
				local valueLabel = Instance.new("TextLabel")
				valueLabel.AnchorPoint = Vector2.new(1, 0)
				valueLabel.Position = UDim2.new(1, 0, 0, 0)
				valueLabel.Size = UDim2.new(0, 40, 1, 0)
				valueLabel.BackgroundTransparency = 1
				valueLabel.Font = Enum.Font.GothamBold
				valueLabel.TextSize = 13
				valueLabel.TextXAlignment = Enum.TextXAlignment.Right
				valueLabel.TextColor3 = pal3.Accent
				valueLabel.Text = tostring(default)
				valueLabel.Parent = row
	
				-- Slider track
				local track = Instance.new("Frame")
				track.AnchorPoint = Vector2.new(0, 0.5)
				track.Position = UDim2.new(0, 50, 0.5, 0)
				track.Size = UDim2.new(1, -100, 0, 6)
				track.BackgroundColor3 = pal3.Card
				track.BorderSizePixel = 0
				track.Parent = row
				corner(track, 3)
	
				-- Slider fill
				local fill = Instance.new("Frame")
				fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
				fill.BackgroundColor3 = pal3.Accent
				fill.BorderSizePixel = 0
				fill.Parent = track
				corner(fill, 3)
	
				-- Slider thumb
				local thumb = Instance.new("Frame")
				thumb.AnchorPoint = Vector2.new(0.5, 0.5)
				thumb.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
				thumb.Size = UDim2.new(0, 16, 0, 16)
				thumb.BackgroundColor3 = pal3.Text
				thumb.BorderSizePixel = 0
				thumb.ZIndex = 5001
				thumb.Parent = track
				corner(thumb, 8)
				stroke(thumb, pal3.Accent, 2)
	
				-- Slider dragging
				local dragging = false
				local currentValue = default
	
				-- Update slider visual and value (with optional callback trigger)
				local function updateSlider(value, triggerCallback)
					value = math.clamp(value, min, max)
					currentValue = value
	
					local percent = (value - min) / (max - min)
					fill.Size = UDim2.new(percent, 0, 1, 0)
					thumb.Position = UDim2.new(percent, 0, 0.5, 0)
					valueLabel.Text = tostring(value)
	
					-- Only trigger callback if explicitly requested (user interaction)
					if triggerCallback and callback then
						callback(value)
					end
				end
	
				thumb.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						Animator:Pulse(thumb, 1.2, Animator.Spring.Snappy)
					end
				end)
	
				thumb.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
						Animator:Pulse(thumb, 1, Animator.Spring.Bounce)
					end
				end)
	
				track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						local mousePos = input.Position.X
						local trackPos = track.AbsolutePosition.X
						local trackSize = track.AbsoluteSize.X
						local percent = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
						local value = math.floor(min + (percent * (max - min)) + 0.5)
						updateSlider(value, true)  -- User clicked, trigger callback
					end
				end)
	
				game:GetService("UserInputService").InputChanged:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						local mousePos = input.Position.X
						local trackPos = track.AbsolutePosition.X
						local trackSize = track.AbsoluteSize.X
						local percent = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
						local value = math.floor(min + (percent * (max - min)) + 0.5)
						updateSlider(value, true)  -- User dragging, trigger callback
					end
				end)
	
				return {
					Set = function(value)
						updateSlider(value, false)  -- Programmatic set, don't trigger callback
					end,
					Get = function()
						return currentValue
					end
				}
			end
	
			-- Update color from RGB
			local function updateFromRGB()
				if updatingSliders then return end
				updatingSliders = true
	
				currentColor = Color3.fromRGB(r, g, b)
				preview.BackgroundColor3 = currentColor
	
				-- Update HSV
				h, s, v = RGBtoHSV(r, g, b)
				hSlider.Set(h)
				sSlider.Set(s)
				vSlider.Set(v)
	
				-- Update hex
				hexInput.Text = Color3ToHex(currentColor)
	
				if o.OnChanged then
					task.spawn(o.OnChanged, currentColor)
				end
				if o.Flag then RvrseUI:_autoSave() end
	
				updatingSliders = false
			end
	
			-- Update color from HSV
			local function updateFromHSV()
				if updatingSliders then return end
				updatingSliders = true
	
				r, g, b = HSVtoRGB(h, s, v)
				currentColor = Color3.fromRGB(r, g, b)
				preview.BackgroundColor3 = currentColor
	
				-- Update RGB
				rSlider.Set(r)
				gSlider.Set(g)
				bSlider.Set(b)
	
				-- Update hex
				hexInput.Text = Color3ToHex(currentColor)
	
				if o.OnChanged then
					task.spawn(o.OnChanged, currentColor)
				end
				if o.Flag then RvrseUI:_autoSave() end
	
				updatingSliders = false
			end
	
			-- RGB Section
			local rgbHeader = Instance.new("TextLabel")
			rgbHeader.BackgroundTransparency = 1
			rgbHeader.Size = UDim2.new(1, 0, 0, 20)
			rgbHeader.Font = Enum.Font.GothamBold
			rgbHeader.TextSize = 14
			rgbHeader.TextXAlignment = Enum.TextXAlignment.Left
			rgbHeader.TextColor3 = pal3.Text
			rgbHeader.Text = "RGB"
			rgbHeader.LayoutOrder = 1
			rgbHeader.Parent = pickerPanel
	
			rSlider = createSlider("R:", 0, 255, r, function(value)
				r = value
				updateFromRGB()
			end)
	
			gSlider = createSlider("G:", 0, 255, g, function(value)
				g = value
				updateFromRGB()
			end)
	
			bSlider = createSlider("B:", 0, 255, b, function(value)
				b = value
				updateFromRGB()
			end)
	
			-- HSV Section
			local hsvHeader = Instance.new("TextLabel")
			hsvHeader.BackgroundTransparency = 1
			hsvHeader.Size = UDim2.new(1, 0, 0, 20)
			hsvHeader.Font = Enum.Font.GothamBold
			hsvHeader.TextSize = 14
			hsvHeader.TextXAlignment = Enum.TextXAlignment.Left
			hsvHeader.TextColor3 = pal3.Text
			hsvHeader.Text = "HSV"
			hsvHeader.LayoutOrder = 5
			hsvHeader.Parent = pickerPanel
	
			hSlider = createSlider("H:", 0, 360, h, function(value)
				h = value
				updateFromHSV()
			end)
	
			sSlider = createSlider("S:", 0, 100, s, function(value)
				s = value
				updateFromHSV()
			end)
	
			vSlider = createSlider("V:", 0, 100, v, function(value)
				v = value
				updateFromHSV()
			end)
	
			-- Hex Input Section
			local hexHeader = Instance.new("TextLabel")
			hexHeader.BackgroundTransparency = 1
			hexHeader.Size = UDim2.new(1, 0, 0, 20)
			hexHeader.Font = Enum.Font.GothamBold
			hexHeader.TextSize = 14
			hexHeader.TextXAlignment = Enum.TextXAlignment.Left
			hexHeader.TextColor3 = pal3.Text
			hexHeader.Text = "Hex Code"
			hexHeader.LayoutOrder = 9
			hexHeader.Parent = pickerPanel
	
			local hexRow = Instance.new("Frame")
			hexRow.BackgroundTransparency = 1
			hexRow.Size = UDim2.new(1, 0, 0, 36)
			hexRow.LayoutOrder = 10
			hexRow.Parent = pickerPanel
	
			hexInput = Instance.new("TextBox")
			hexInput.Size = UDim2.new(1, 0, 1, 0)
			hexInput.BackgroundColor3 = pal3.Card
			hexInput.BorderSizePixel = 0
			hexInput.Font = Enum.Font.GothamMedium
			hexInput.TextSize = 14
			hexInput.TextColor3 = pal3.Text
			hexInput.PlaceholderText = "#FFFFFF"
			hexInput.Text = Color3ToHex(currentColor)
			hexInput.ClearTextOnFocus = false
			hexInput.Parent = hexRow
			corner(hexInput, 8)
			stroke(hexInput, pal3.Border, 1)
	
			hexInput.FocusLost:Connect(function()
				local color = HexToColor3(hexInput.Text)
				if color then
					updatingSliders = true
					currentColor = color
					preview.BackgroundColor3 = currentColor
	
					r = math.floor(color.R * 255 + 0.5)
					g = math.floor(color.G * 255 + 0.5)
					b = math.floor(color.B * 255 + 0.5)
					h, s, v = RGBtoHSV(r, g, b)
	
					rSlider.Set(r)
					gSlider.Set(g)
					bSlider.Set(b)
					hSlider.Set(h)
					sSlider.Set(s)
					vSlider.Set(v)
	
					if o.OnChanged then
						task.spawn(o.OnChanged, currentColor)
					end
					if o.Flag then RvrseUI:_autoSave() end
	
					updatingSliders = false
				else
					hexInput.Text = Color3ToHex(currentColor)
				end
			end)
	
			-- Toggle panel function
			local function setPickerOpen(state)
				print("[ColorPicker] setPickerOpen called, state =", state)
	
				if RvrseUI.Store:IsLocked(o.RespectLock) then
					print("[ColorPicker] Blocked by lock, RespectLock =", o.RespectLock)
					return
				end
	
				pickerOpen = state
	
				if state then
					print("[ColorPicker] Opening panel...")
	
					-- Show blocker first
					if OverlayService then
						print("[ColorPicker] Showing blocker...")
						overlayBlocker = OverlayService:ShowBlocker({
							Transparency = 0.45,
							ZIndex = 100,
							Modal = false,  -- Allow click events to fire on blocker
						})
						if overlayBlockerConnection then
							overlayBlockerConnection:Disconnect()
						end
						overlayBlockerConnection = overlayBlocker.MouseButton1Click:Connect(function()
							setPickerOpen(false)
						end)
						print("[ColorPicker] Blocker shown:", overlayBlocker)
					else
						warn("[ColorPicker] ⚠️ No OverlayService available!")
					end
	
					-- Show panel and animate (spawn to avoid blocking)
					print("[ColorPicker] Setting panel visible...")
					pickerPanel.Visible = true
					pickerPanel.Size = UDim2.new(0, 320, 0, 0)  -- Start collapsed
	
					print("[ColorPicker] Panel state after visible:")
					print("  Visible:", pickerPanel.Visible)
					print("  Size:", pickerPanel.Size)
					print("  AbsoluteSize:", pickerPanel.AbsoluteSize)
					print("  Parent:", pickerPanel.Parent)
	
					task.spawn(function()
						-- Wait for layout to calculate content size
						task.wait(0.05)
						local targetHeight = panelLayout.AbsoluteContentSize.Y + 24
						print("[ColorPicker] Layout calculated, targetHeight =", targetHeight)
	
						if targetHeight < 50 then
							-- Fallback if layout hasn't calculated yet
							targetHeight = 380
							print("[ColorPicker] Using fallback height:", targetHeight)
						end
	
						-- Animate to full height
						print("[ColorPicker] Starting animation to height:", targetHeight)
						Animator:Tween(pickerPanel, {
							Size = UDim2.new(0, 320, 0, targetHeight)
						}, Animator.Spring.Gentle)
						print("[ColorPicker] Animation started")
					end)
	
					-- Pulse effect
					Animator:Pulse(preview, 1.15, Animator.Spring.Bounce)
					print("[ColorPicker] Panel opened successfully")
				else
					-- Hide blocker
					if OverlayService then
						if overlayBlockerConnection then
							overlayBlockerConnection:Disconnect()
							overlayBlockerConnection = nil
						end
						OverlayService:HideBlocker(false)
					end
	
					-- Animate panel close
					Animator:Tween(pickerPanel, {
						Size = UDim2.new(0, 320, 0, 0)
					}, Animator.Spring.Snappy)
	
					task.delay(0.3, function()
						if not pickerOpen then
							pickerPanel.Visible = false
						end
					end)
				end
			end
	
			-- Toggle on preview click
			preview.MouseButton1Click:Connect(function()
				setPickerOpen(not pickerOpen)
			end)
	
			-- Cleanup on destroy
			f.Destroying:Connect(function()
				if pickerOpen then
					setPickerOpen(false)
				end
			end)
		else
			-- Simple mode: Color cycling (original behavior)
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
	
				-- Smooth color transition
				Animator:Tween(preview, {BackgroundColor3 = currentColor}, Animator.Spring.Snappy)
	
				-- Pulse effect
				Animator:Pulse(preview, 1.15, Animator.Spring.Bounce)
	
				-- Border flashes the new color
				Animator:Tween(previewStroke, {
					Color = currentColor,
					Thickness = 3
				}, Animator.Spring.Lightning)
	
				task.delay(0.2, function()
					Animator:Tween(previewStroke, {
						Color = pal3.Border,
						Thickness = 2
					}, Animator.Spring.Glide)
				end)
	
				if o.OnChanged then
					task.spawn(o.OnChanged, currentColor)
				end
				if o.Flag then RvrseUI:_autoSave() end
			end)
		end
	
		-- Hover effects
		preview.MouseEnter:Connect(function()
			Animator:Tween(previewStroke, {
				Thickness = 3,
				Transparency = 0.2
			}, Animator.Spring.Snappy)
	
			Animator:Glow(preview, 0.4, 0.5, Theme)
		end)
	
		preview.MouseLeave:Connect(function()
			Animator:Tween(previewStroke, {
				Thickness = 2,
				Transparency = 0.4
			}, Animator.Spring.Snappy)
		end)
	
		-- Lock listener
		table.insert(RvrseUI._lockListeners, function()
			local locked = RvrseUI.Store:IsLocked(o.RespectLock)
			lbl.TextTransparency = locked and 0.5 or 0
		end)
	
		-- API
		local colorpickerAPI = {
			Set = function(_, color)
				if advancedMode and rSlider then
					updatingSliders = true
	
					currentColor = color
					preview.BackgroundColor3 = color
	
					r = math.floor(color.R * 255 + 0.5)
					g = math.floor(color.G * 255 + 0.5)
					b = math.floor(color.B * 255 + 0.5)
					h, s, v = RGBtoHSV(r, g, b)
	
					rSlider.Set(r)
					gSlider.Set(g)
					bSlider.Set(b)
					hSlider.Set(h)
					sSlider.Set(s)
					vSlider.Set(v)
					hexInput.Text = Color3ToHex(currentColor)
	
					updatingSliders = false
				else
					currentColor = color
					preview.BackgroundColor3 = color
				end
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
end


-- ========================
-- Label Module
-- ========================

do
	
	Label = {}
	
	function Label.Create(o, dependencies)
		o = o or {}
	
		-- Extract dependencies
		local card = dependencies.card
		local pal3 = dependencies.pal3
		local RvrseUI = dependencies.RvrseUI
	
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
end


-- ========================
-- Paragraph Module
-- ========================

do
	
	Paragraph = {}
	
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
end


-- ========================
-- Divider Module
-- ========================

do
	
	Divider = {}
	
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
end


-- ========================
-- SectionBuilder Module
-- ========================

do
	
	SectionBuilder = {}
	
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
		local overlayService = dependencies.Overlay
	
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
	
		local SectionAPI = {}
	
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
				OverlayLayer = overlayLayer,
				Overlay = overlayService
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
				o = o or {}
				-- Default to the legacy inline dropdown; the overlay-based version caused clipping/z-order regressions.
				-- Opt back into the modern behaviour only by setting `UseModernDropdown = true` on the element config.
				if o.UseModernDropdown then
					return Elements.Dropdown.Create(o, getElementDeps())
				end
				return Elements.DropdownLegacy.Create(o, getElementDeps())
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
end


-- ========================
-- TabBuilder Module
-- ========================

do
	
	TabBuilder = {}
	
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
	
		local function currentPalette()
			return Theme:Get()
		end
		local pal2 = currentPalette()
	
		-- Icon-only tab button (modern vertical rail design)
		local tabBtn = Instance.new("TextButton")
		tabBtn.AutoButtonColor = false
		tabBtn.BackgroundColor3 = pal2.Card
		tabBtn.BackgroundTransparency = 0.3
		tabBtn.BorderSizePixel = 0
		tabBtn.Size = UDim2.new(1, -16, 0, 56) -- Square-ish icon button
		tabBtn.Font = Enum.Font.GothamMedium
		tabBtn.TextSize = 24
		tabBtn.TextColor3 = pal2.TextSub
		tabBtn.Text = ""
		tabBtn.Parent = tabBar
		corner(tabBtn, 12)
	
		-- Subtle border
		local tabStroke = Instance.new("UIStroke")
		tabStroke.Color = pal2.Border
		tabStroke.Thickness = 1
		tabStroke.Transparency = 0.6
		tabStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		tabStroke.Parent = tabBtn
	
		-- Handle icon display (icon-only design)
		local tabIcon = nil
		local tabText = t.Title or "Tab"
	
		if t.Icon then
			local iconAsset, iconType = Icons:Resolve(t.Icon)
	
			if iconType == "image" then
				-- Create centered image icon
				tabIcon = Instance.new("ImageLabel")
				tabIcon.BackgroundTransparency = 1
				tabIcon.Image = iconAsset
				tabIcon.Size = UDim2.new(0, 28, 0, 28)
				tabIcon.Position = UDim2.new(0.5, -14, 0.5, -14)
				tabIcon.ImageColor3 = pal2.TextSub
				tabIcon.Parent = tabBtn
			elseif iconType == "text" then
				-- Use emoji/text icon centered
				tabBtn.Text = iconAsset
				tabBtn.TextSize = 24
			end
		else
			-- Fallback: use first letter of tab name
			local firstLetter = string.sub(tabText, 1, 1):upper()
			tabBtn.Text = firstLetter
			tabBtn.Font = Enum.Font.GothamBold
			tabBtn.TextSize = 20
		end
	
		-- Gradient overlay on active tab
		local tabGradient = Instance.new("UIGradient")
		tabGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, pal2.Primary),
			ColorSequenceKeypoint.new(0.5, pal2.Accent),
			ColorSequenceKeypoint.new(1, pal2.Secondary),
		}
		tabGradient.Rotation = 45
		tabGradient.Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 1),
		}
		tabGradient.Parent = tabBtn
	
		-- Side indicator (glowing accent line)
		local tabIndicator = Instance.new("Frame")
		tabIndicator.BackgroundColor3 = pal2.Accent
		tabIndicator.BorderSizePixel = 0
		tabIndicator.AnchorPoint = Vector2.new(0, 0.5)
		tabIndicator.Position = UDim2.new(0, -6, 0.5, 0)
		tabIndicator.Size = UDim2.new(0, 4, 0, 0)
		tabIndicator.Visible = false
		tabIndicator.Parent = tabBtn
		corner(tabIndicator, 2)
	
		-- Tab page (scrollable)
		local page = Instance.new("ScrollingFrame")
		page.BackgroundTransparency = 1
		page.BorderSizePixel = 0
		page.Position = UDim2.new(0, 0, 0, 0)
		page.Size = UDim2.new(1, 0, 1, 0)
		page.ScrollBarThickness = 6
		page.ScrollBarImageColor3 = pal2.Border
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.Visible = false
		page.Parent = body
	
		local pagePadding = Instance.new("UIPadding")
		pagePadding.PaddingTop = UDim.new(0, 4)
		pagePadding.PaddingBottom = UDim.new(0, 4)
		pagePadding.Parent = page
	
		local pageLayout = Instance.new("UIListLayout")
		pageLayout.Padding = UDim.new(0, 12)
		pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		pageLayout.Parent = page
	
		local function setInactive(tabData)
			local pal = currentPalette()
			tabData.btn:SetAttribute("Active", false)
			tabData.page.Visible = false
			tabData.btn.BackgroundTransparency = 0.3
			tabData.btn.TextColor3 = pal.TextSub
			if tabData.icon then
				tabData.icon.ImageColor3 = pal.TextSub
			end
	
			-- Hide gradient (cannot tween NumberSequence, set directly)
			if tabData.gradient then
				tabData.gradient.Transparency = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(1, 1),
				}
			end
	
			-- Restore border
			if tabData.stroke then
				Animator:Tween(tabData.stroke, {
					Thickness = 1,
					Transparency = 0.6
				}, Animator.Spring.Snappy)
			end
	
			tabData.indicator.Visible = false
		end
	
		-- Tab activation
		local function activateTab()
			local pal = currentPalette()
			for _, tabData in ipairs(tabs) do
				setInactive(tabData)
			end
			page.Visible = true
			tabBtn:SetAttribute("Active", true)
			tabBtn.BackgroundTransparency = 0.1
			tabBtn.TextColor3 = pal.TextBright
			if tabIcon then
				tabIcon.ImageColor3 = pal.Accent
			end
	
			-- Show gradient (cannot tween NumberSequence, set directly)
			tabGradient.Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0.5),
				NumberSequenceKeypoint.new(1, 0.5),
			}
	
			-- Glow border
			Animator:Tween(tabStroke, {
				Color = pal.Accent,
				Thickness = 2,
				Transparency = 0.3
			}, Animator.Spring.Snappy)
	
			-- Indicator expands
			tabIndicator.Visible = true
			tabIndicator.Size = UDim2.new(0, 4, 0, 0)
			Animator:Tween(tabIndicator, {Size = UDim2.new(0, 4, 1, -12)}, Animator.Spring.Spring)
			dependencies.activePage = page  -- Update active page reference
		end
	
		tabBtn.MouseButton1Click:Connect(activateTab)
		tabBtn.MouseEnter:Connect(function()
			if page.Visible == false then
				-- Brighten background and border on hover
				Animator:Tween(tabBtn, {BackgroundTransparency = 0.1}, Animator.Spring.Lightning)
				Animator:Tween(tabStroke, {Transparency = 0.4}, Animator.Spring.Lightning)
			end
		end)
		tabBtn.MouseLeave:Connect(function()
			if page.Visible == false then
				-- Restore inactive state
				Animator:Tween(tabBtn, {BackgroundTransparency = 0.3}, Animator.Spring.Snappy)
				Animator:Tween(tabStroke, {Transparency = 0.6}, Animator.Spring.Snappy)
			end
		end)
	
		table.insert(tabs, {
			btn = tabBtn,
			page = page,
			indicator = tabIndicator,
			icon = tabIcon,
			gradient = tabGradient,
			stroke = tabStroke
		})
	
		-- Activate first tab automatically
		if #tabs == 1 then
			activateTab()
		end
	
		local TabAPI = {}
	
		-- Tab SetIcon Method (icon-only design)
		function TabAPI:SetIcon(newIcon)
			if not newIcon then return end
	
			local iconAsset, iconType = Icons:Resolve(newIcon)
			local pal = currentPalette()
	
			-- Remove old icon if exists
			if tabIcon and tabIcon.Parent then
				tabIcon:Destroy()
				tabIcon = nil
			end
	
			if iconType == "image" then
				-- Create centered image icon
				tabIcon = Instance.new("ImageLabel")
				tabIcon.BackgroundTransparency = 1
				tabIcon.Image = iconAsset
				tabIcon.Size = UDim2.new(0, 28, 0, 28)
				tabIcon.Position = UDim2.new(0.5, -14, 0.5, -14)
				tabIcon.ImageColor3 = pal.TextSub
				tabIcon.Parent = tabBtn
				tabBtn.Text = ""
			elseif iconType == "text" then
				-- Use emoji/text icon centered
				tabBtn.Text = iconAsset
				tabBtn.TextSize = 24
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
end


-- ========================
-- WindowBuilder Module
-- ========================

do
	
	WindowBuilder = {}
	
	local Theme, Animator, State, Config, UIHelpers, Icons, TabBuilder, SectionBuilder, WindowManager, NotificationsService
	local Debug, Obfuscation, Hotkeys, Version, Elements, OverlayLayer, Overlay, KeySystem
	
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
		NotificationsService = deps.Notifications
		Debug = deps.Debug
		Obfuscation = deps.Obfuscation
		Hotkeys = deps.Hotkeys
		Version = deps.Version
		Elements = deps.Elements
		OverlayLayer = deps.OverlayLayer
		Overlay = deps.Overlay
		KeySystem = deps.KeySystem
	
		-- Services
		UIS = deps.UIS
		GuiService = deps.GuiService
		RS = deps.RS
		PlayerGui = deps.PlayerGui
		HttpService = deps.HttpService
	end
	
	function WindowBuilder:CreateWindow(RvrseUI, cfg, host)
		cfg = cfg or {}
	
		-- ============================================
		-- KEY SYSTEM VALIDATION (BLOCKING)
		-- ============================================
		if cfg.KeySystem then
			Debug.printf("[KeySystem] Key system enabled, processing...")
	
			-- Process key system (BLOCKS until validated or failed)
			local success, message = KeySystem:Process(cfg, function(validated, msg)
				Debug.printf("[KeySystem] Validation result: %s - %s", tostring(validated), msg or "nil")
			end)
	
			if not success then
				Debug.printf("[KeySystem] Key validation failed: %s", tostring(message or "No attempts remaining"))
				-- Return a dummy window object with no-op methods to prevent script errors
				-- This allows user scripts to continue without crashing
				local DummySection = {
					CreateButton = function() return {} end,
					CreateToggle = function() return {} end,
					CreateSlider = function() return {} end,
					CreateDropdown = function() return {} end,
					CreateKeybind = function() return {} end,
					CreateTextBox = function() return {} end,
					CreateColorPicker = function() return {} end,
					CreateLabel = function() return {} end,
					CreateParagraph = function() return {} end,
					CreateDivider = function() return {} end
				}
				local DummyTab = {
					CreateSection = function() return DummySection end
				}
				local DummyWindow = {
					CreateTab = function() return DummyTab end,
					Show = function() end,
					Destroy = function() end,
					SetTheme = function() end,
					Minimize = function() end,
					Restore = function() end
				}
				warn("[RvrseUI] Key validation failed - Window creation blocked")
				return DummyWindow
			end
	
			Debug.printf("[KeySystem] Key validated successfully, proceeding to window creation")
		end
	
		local overlayLayer = Overlay and Overlay:GetLayer() or OverlayLayer
	
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
		root.AnchorPoint = Vector2.new(0, 0)  -- ✅ EXPLICIT top-left anchor (never assume default)
		root.Size = UDim2.new(0, baseWidth, 0, baseHeight)
	
		local screenSize = workspace.CurrentCamera.ViewportSize
		local centerX = (screenSize.X - baseWidth) / 2
		local centerY = (screenSize.Y - baseHeight) / 2
		root.Position = UDim2.fromOffset(centerX, centerY)
		root.BackgroundColor3 = pal.Bg
		root.BackgroundTransparency = 1  -- TRANSPARENT - let children show through
		root.BorderSizePixel = 0
		root.Visible = false
		root.ClipsDescendants = false
		root.ZIndex = 100
		root.Parent = windowHost
		UIHelpers.corner(root, 16)
		UIHelpers.stroke(root, pal.Accent, 2)
	
		-- Header bar with gloss effect
		local header = Instance.new("Frame")
		header.Size = UDim2.new(1, 0, 0, 52)
		header.BackgroundColor3 = pal.Card
		header.BackgroundTransparency = 0
		header.BorderSizePixel = 0
		header.Parent = root
		UIHelpers.addGloss(header, Theme)
		UIHelpers.corner(header, 16)
	
		-- Gradient overlay on header
		local headerGradient = Instance.new("UIGradient")
		headerGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, pal.Primary),
			ColorSequenceKeypoint.new(0.5, pal.Accent),
			ColorSequenceKeypoint.new(1, pal.Secondary),
		}
		headerGradient.Rotation = 90
		headerGradient.Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 0.7),
			NumberSequenceKeypoint.new(1, 0.7),
		}
		headerGradient.Parent = header
	
		-- Header border
		local headerStroke = Instance.new("UIStroke")
		headerStroke.Color = pal.BorderGlow
		headerStroke.Thickness = 1
		headerStroke.Transparency = 0.5
		headerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		headerStroke.Parent = header
	
		local headerDivider = Instance.new("Frame")
		headerDivider.BackgroundColor3 = pal.Divider
		headerDivider.BackgroundTransparency = 0.5
		headerDivider.BorderSizePixel = 0
		headerDivider.Position = UDim2.new(0, 12, 1, -1)
		headerDivider.Size = UDim2.new(1, -24, 0, 1)
		headerDivider.Parent = header
	
		-- Content region beneath header
		local content = Instance.new("Frame")
		content.Name = "Content"
		content.BackgroundTransparency = 1
		content.BorderSizePixel = 0
		content.Position = UDim2.new(0, 0, 0, header.Size.Y.Offset)
		content.Size = UDim2.new(1, 0, 1, -header.Size.Y.Offset)
		content.Parent = root
		content.ClipsDescendants = false
	
		local defaultRootClip = root.ClipsDescendants
		local defaultContentClip = content.ClipsDescendants
	
		-- ═══════════════════════════════════════════════════════════════
		-- SIMPLE DRAG SYSTEM - Window Header (Classic Roblox Pattern)
		-- ═══════════════════════════════════════════════════════════════
	
		local dragging = false
		local dragInput = nil
		local dragStart = nil
		local startPos = nil
		local isAnimating = false  -- Blocks drag during minimize/restore animations
	
		-- Helper to update window position
		local function updateWindowPosition(input)
			local delta = input.Position - dragStart
			root.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	
		-- Start dragging when header is clicked
		header.Active = true
	
		header.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or
			   input.UserInputType == Enum.UserInputType.Touch then
	
				-- Block drag during animations
				if isAnimating then
					Debug.printf("[DRAG] ⚠️ Drag blocked - animation in progress")
					return
				end
	
				dragging = true
				dragStart = input.Position
				startPos = root.Position
	
				Debug.printf("[DRAG] Started - mouse: (%.1f, %.1f), window: %s",
					input.Position.X, input.Position.Y, tostring(root.Position))
	
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
						Debug.printf("[DRAG] Finished - window: %s", tostring(root.Position))
					end
				end)
			end
		end)
	
		-- Track input changes
		header.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or
			   input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
	
		-- Update position during drag
		UIS.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				updateWindowPosition(input)
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
		closeBtn.BackgroundColor3 = pal.Elevated
		closeBtn.BackgroundTransparency = 0
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
			local currentPal = Theme:Get()
			Animator:Tween(closeBtn, {BackgroundColor3 = currentPal.Hover}, Animator.Spring.Fast)
		end)
		closeBtn.MouseLeave:Connect(function()
			closeTooltip.Visible = false
			local currentPal = Theme:Get()
			Animator:Tween(closeBtn, {BackgroundColor3 = currentPal.Elevated}, Animator.Spring.Fast)
		end)
	
		closeBtn.MouseButton1Click:Connect(function()
			if Overlay then
				Overlay:HideBlocker(true)
			end
			Animator:Ripple(closeBtn, 16, 16)
			Animator:Tween(root, {BackgroundTransparency = 1}, Animator.Spring.Fast)
	
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
			local currentPal = Theme:Get()
			Animator:Tween(bellToggle, {BackgroundColor3 = currentPal.Hover}, Animator.Spring.Fast)
		end)
		bellToggle.MouseLeave:Connect(function()
			bellTooltip.Visible = false
			local currentPal = Theme:Get()
			Animator:Tween(bellToggle, {BackgroundColor3 = currentPal.Elevated}, Animator.Spring.Fast)
		end)
	
		bellToggle.MouseButton1Click:Connect(function()
			local currentPal = Theme:Get()
			RvrseUI.NotificationsEnabled = not RvrseUI.NotificationsEnabled
			if RvrseUI.NotificationsEnabled then
				bellToggle.Text = "🔔"
				bellToggle.TextColor3 = currentPal.Success
				bellTooltip.Text = "  Notifications: ON  "
				if bellToggle:FindFirstChild("Glow") then
					bellToggle.Glow:Destroy()
				end
				UIHelpers.addGlow(bellToggle, currentPal.Success, 1.5)
			else
				bellToggle.Text = "🔕"
				bellToggle.TextColor3 = currentPal.Error
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
			local currentPal = Theme:Get()
			Animator:Tween(minimizeBtn, {BackgroundColor3 = currentPal.Hover}, Animator.Spring.Fast)
		end)
		minimizeBtn.MouseLeave:Connect(function()
			minimizeTooltip.Visible = false
			local currentPal = Theme:Get()
			Animator:Tween(minimizeBtn, {BackgroundColor3 = currentPal.Elevated}, Animator.Spring.Fast)
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
			local currentPal = Theme:Get()
			Animator:Tween(themeToggle, {BackgroundColor3 = currentPal.Hover}, Animator.Spring.Fast)
		end)
		themeToggle.MouseLeave:Connect(function()
			themeTooltip.Visible = false
			local currentPal = Theme:Get()
			Animator:Tween(themeToggle, {BackgroundColor3 = currentPal.Elevated}, Animator.Spring.Fast)
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
			if NotificationsService and NotificationsService.Notify then
				local info = RvrseUI:GetVersionInfo()
				NotificationsService:Notify({
					Title = "RvrseUI " .. RvrseUI:GetVersionString(),
					Message = string.format("Hash: %s | Channel: %s", info.Hash, info.Channel),
					Duration = 4,
					Type = "info"
				})
			end
		end)
	
		-- Sleek vertical icon-only tab rail
		local railWidth = 80 -- Narrower for icon-only design
		local tabBar = Instance.new("ScrollingFrame")
		tabBar.Name = "TabRail"
		tabBar.BackgroundColor3 = pal.Card
		tabBar.BackgroundTransparency = 0.05
		tabBar.BorderSizePixel = 0
		tabBar.Position = UDim2.new(0, 0, 0, 0)
		tabBar.Size = UDim2.new(0, railWidth, 1, 0)
		tabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
		tabBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
		tabBar.ScrollBarThickness = 3
		tabBar.ScrollBarImageColor3 = pal.Border
		tabBar.ScrollBarImageTransparency = 0.5
		tabBar.ScrollingDirection = Enum.ScrollingDirection.Y
		tabBar.ElasticBehavior = Enum.ElasticBehavior.Never
		tabBar.ClipsDescendants = true
		tabBar.Parent = content
		UIHelpers.corner(tabBar, 12)
	
		-- Subtle gradient on tab rail
		local tabRailGradient = Instance.new("UIGradient")
		tabRailGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, pal.Primary),
			ColorSequenceKeypoint.new(0.5, pal.Accent),
			ColorSequenceKeypoint.new(1, pal.Secondary),
		}
		tabRailGradient.Rotation = 90
		tabRailGradient.Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 0.9),
			NumberSequenceKeypoint.new(1, 0.9),
		}
		tabRailGradient.Parent = tabBar
	
		-- Border stroke
		local tabRailStroke = Instance.new("UIStroke")
		tabRailStroke.Color = pal.BorderGlow
		tabRailStroke.Thickness = 1
		tabRailStroke.Transparency = 0.6
		tabRailStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		tabRailStroke.Parent = tabBar
	
		local tabPadding = Instance.new("UIPadding")
		tabPadding.PaddingTop = UDim.new(0, 12)
		tabPadding.PaddingBottom = UDim.new(0, 12)
		tabPadding.PaddingLeft = UDim.new(0, 12)
		tabPadding.PaddingRight = UDim.new(0, 8)
		tabPadding.Parent = tabBar
	
		local tabLayout = Instance.new("UIListLayout")
		tabLayout.Padding = UDim.new(0, 8)
		tabLayout.FillDirection = Enum.FillDirection.Vertical
		tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		tabLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
		tabLayout.Parent = tabBar
	
		-- Body container
		local body = Instance.new("Frame")
		body.BackgroundColor3 = pal.Elevated
		body.BackgroundTransparency = 0.1
		body.BorderSizePixel = 0
		body.Position = UDim2.new(0, railWidth + 16, 0, 16)
		body.Size = UDim2.new(1, -(railWidth + 28), 1, -32)
		body.Parent = content
		UIHelpers.corner(body, 16)
		UIHelpers.stroke(body, pal.Border, 1)
	
		local bodyPadding = Instance.new("UIPadding")
		bodyPadding.PaddingTop = UDim.new(0, 20)
		bodyPadding.PaddingBottom = UDim.new(0, 20)
		bodyPadding.PaddingLeft = UDim.new(0, 24)
		bodyPadding.PaddingRight = UDim.new(0, 24)
		bodyPadding.Parent = body
	
		local function describeFrame(label, inst)
			if not Debug:IsEnabled() or not inst then
				return
			end
	
			local ok, info = pcall(function()
				local absPos = inst.AbsolutePosition
				local absSize = inst.AbsoluteSize
				local bg = inst.BackgroundColor3 or Color3.new(0, 0, 0)
				return string.format(
					"%s visible=%s z=%d clips=%s pos=(%d,%d) size=(%d,%d) alpha=%.2f rgb=(%d,%d,%d)",
					label,
					tostring(inst.Visible),
					inst.ZIndex or 0,
					tostring(inst.ClipsDescendants),
					math.floor(absPos.X),
					math.floor(absPos.Y),
					math.floor(absSize.X),
					math.floor(absSize.Y),
					inst.BackgroundTransparency or 0,
					math.floor(bg.R * 255 + 0.5),
					math.floor(bg.G * 255 + 0.5),
					math.floor(bg.B * 255 + 0.5)
				)
			end)
	
			if ok and info then
				Debug.printf("[LAYOUT] %s", info)
			end
		end
	
		local function snapshotLayout(stage)
			if not Debug:IsEnabled() then
				return
			end
	
			Debug.printf("[LAYOUT] --- %s ---", stage)
			describeFrame("root", root)
			describeFrame("header", header)
			describeFrame("content", content)
			describeFrame("tabRail", tabBar)
			describeFrame("body", body)
			describeFrame("splash", splash)
			describeFrame("overlay", overlayLayer)
			if overlayLayer then
				for _, child in ipairs(overlayLayer:GetChildren()) do
					describeFrame("overlay." .. child.Name, child)
				end
			end
		end
	
		-- Splash screen
		local splash
		local splashHidden = false
		splash = Instance.new("Frame")
		splash.BackgroundColor3 = pal.Elevated
		splash.BorderSizePixel = 0
		splash.Position = body.Position
		splash.Size = body.Size
		splash.ZIndex = 999
		splash.Parent = content
		UIHelpers.corner(splash, 16)
	
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
	
		task.defer(function()
			snapshotLayout("initial-build")
		end)
	
		local hideSplashAndShowRoot = function()
			if splash and splash.Parent then
				if not splashHidden then
					pcall(function()
						Animator:Tween(splash, {BackgroundTransparency = 1}, Animator.Spring.Fast)
						task.wait(0.2)
					end)
				end
				-- Destroy splash completely to prevent blocking
				if splash then
					pcall(function() splash:Destroy() end)
					splash = nil
				end
				splashHidden = true
			end
	
			root.Visible = true
			task.defer(function()
				snapshotLayout("post-show")
			end)
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
			if hidden and Overlay then
				Overlay:HideBlocker(true)
			end
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
		controllerChip.ZIndex = 200
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
		chipShine.ZIndex = 210
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
		-- isAnimating already declared at top with drag variables (line 330)
	
		-- Prevent content from spilling outside the window shell while the minimize/restore
		-- animation runs (the Profiles tab previously leaked the body frame when shrinking).
		local function applyMinimizeClipping()
			root.ClipsDescendants = true
			content.ClipsDescendants = true
		end
	
		local function restoreDefaultClipping()
			if not isMinimized then
				root.ClipsDescendants = defaultRootClip
				content.ClipsDescendants = defaultContentClip
			end
		end
	
		local function minimizeWindow()
			if isMinimized or isAnimating then return end
			isMinimized = true
			isAnimating = true  -- ✅ LOCK drag during animation
			if Overlay then
				Overlay:HideBlocker(true)
			end
			applyMinimizeClipping()
			Animator:Ripple(minimizeBtn, 16, 12)
			snapshotLayout("pre-minimize")
	
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
	
			task.wait(0.6)
			if isMinimized then
				root.Visible = false
				controllerChip.Visible = true
				controllerChip.Size = UDim2.new(0, 0, 0, 0)
	
				local chipGrowTween = Animator:Tween(controllerChip, {
					Size = UDim2.new(0, 50, 0, 50)
				}, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
	
				-- ✅ UNLOCK drag after chip growth completes
				chipGrowTween.Completed:Wait()
				isAnimating = false
				Debug.printf("[MINIMIZE] ✅ Animation complete - drag unlocked")
			else
				isAnimating = false
			end
		end
	
		local function restoreWindow()
			if not isMinimized or isAnimating then return end
			isMinimized = false
			isAnimating = true  -- ✅ LOCK drag during animation
			applyMinimizeClipping()
			Animator:Ripple(controllerChip, 25, 25)
	
			local screenSize = workspace.CurrentCamera.ViewportSize
			local chipPos = controllerChip.AbsolutePosition
			local chipCenterX = chipPos.X + 25
			local chipCenterY = chipPos.Y + 25
	
			local targetSize = isMobile and UDim2.new(0, 380, 0, 520) or UDim2.new(0, baseWidth, 0, baseHeight)
			-- ALWAYS center the window when restoring from minimize (ignore _lastWindowPosition)
			local targetWidth = isMobile and 380 or baseWidth
			local targetHeight = isMobile and 520 or baseHeight
			local centerX = (screenSize.X - targetWidth) / 2
			local centerY = (screenSize.Y - targetHeight) / 2
			local targetPos = UDim2.fromOffset(centerX, centerY)
	
			local windowCenterX = centerX + (targetWidth / 2)
			local windowCenterY = centerY + (targetHeight / 2)
	
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
	
			local restoreTween = Animator:Tween(root, {
				Size = targetSize,
				Position = targetPos,
				BackgroundTransparency = 1,  -- KEEP TRANSPARENT!
				Rotation = 0
			}, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
	
			task.defer(function()
				snapshotLayout("post-restore")
			end)
	
			-- ✅ UNLOCK drag after restore completes
			restoreTween.Completed:Wait()
			task.wait(0.05)  -- Small buffer for tween to fully settle
			isAnimating = false
			Debug.printf("[RESTORE] ✅ Animation complete - drag unlocked")
	
			task.delay(0.05, restoreDefaultClipping)
		end
	
		minimizeBtn.MouseButton1Click:Connect(minimizeWindow)
	
		-- ═══════════════════════════════════════════════════════════════
		-- SIMPLE DRAG SYSTEM - Controller Chip (Classic Roblox Pattern)
		-- ═══════════════════════════════════════════════════════════════
	
		local chipDragging = false
		local chipWasDragged = false
		local chipDragInput = nil
		local chipDragStart = nil
		local chipStartPos = nil
	
		-- Helper to update chip position
		local function updateChipPosition(input)
			local delta = input.Position - chipDragStart
			controllerChip.Position = UDim2.new(
				chipStartPos.X.Scale,
				chipStartPos.X.Offset + delta.X,
				chipStartPos.Y.Scale,
				chipStartPos.Y.Offset + delta.Y
			)
		end
	
		-- Restore window on click (only if not dragged)
		controllerChip.MouseButton1Click:Connect(function()
			if not chipWasDragged then
				restoreWindow()
			end
			chipWasDragged = false
		end)
	
		-- Start chip drag
		controllerChip.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or
			   input.UserInputType == Enum.UserInputType.Touch then
	
				-- Block drag during animations
				if isAnimating then
					Debug.printf("[CHIP DRAG] ⚠️ Drag blocked - animation in progress")
					return
				end
	
				chipDragging = true
				chipWasDragged = false
				chipDragStart = input.Position
				chipStartPos = controllerChip.Position
	
				Debug.printf("[CHIP DRAG] Started - mouse: (%.1f, %.1f), chip: %s",
					input.Position.X, input.Position.Y, tostring(controllerChip.Position))
	
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						chipDragging = false
	
						-- Save final position
						RvrseUI._controllerChipPosition = {
							XScale = controllerChip.Position.X.Scale,
							XOffset = controllerChip.Position.X.Offset,
							YScale = controllerChip.Position.Y.Scale,
							YOffset = controllerChip.Position.Y.Offset
						}
	
						Debug.printf("[CHIP DRAG] Finished - chip: %s", tostring(controllerChip.Position))
					end
				end)
			end
		end)
	
		-- Track input changes
		controllerChip.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or
			   input.UserInputType == Enum.UserInputType.Touch then
				chipDragInput = input
			end
		end)
	
		-- Update position during drag
		UIS.InputChanged:Connect(function(input)
			if input == chipDragInput and chipDragging then
				chipWasDragged = true  -- Mark as dragged so click doesn't restore
				updateChipPosition(input)
			end
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
	
		local WindowAPI = {}
		function WindowAPI:SetTitle(t) title.Text = t or name end
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
			if Overlay then
				Overlay:HideBlocker(true)
			end
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
	
		local firstShowCompleted = false
	
		function WindowAPI:Show()
			setHidden(false)
	
			if not firstShowCompleted then
				firstShowCompleted = true
				hideSplashAndShowRoot()
	
				task.defer(function()
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
				end)
			else
				hideSplashAndShowRoot()
			end
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
				OverlayLayer = overlayLayer,
				Overlay = Overlay
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
						print(string.format("[Profiles] refresh count=%d", #list))
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
						Overlay = false,
						UseLegacyDropdown = true,
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
		if NotificationsService and NotificationsService.Notify then
			if not cfg.DisableBuildWarnings then
				NotificationsService:Notify({
					Title = "RvrseUI v2.0",
					Message = "Modern UI loaded successfully",
					Duration = 2,
					Type = "success"
				})
			end
			if not cfg.DisableRvrseUIPrompts then
				NotificationsService:Notify({
					Title = "Tip",
					Message = "Press " .. toggleKey.Name .. " to toggle UI",
					Duration = 3,
					Type = "info"
				})
			end
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
	
			root.BackgroundColor3 = newPal.Card
			UIHelpers.stroke(root, newPal.Border, 1.5)
	
			header.BackgroundColor3 = newPal.Elevated
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
	
			tabBar.BackgroundColor3 = newPal.Card
			UIHelpers.stroke(tabBar, newPal.Border, 1)
			tabBar.ScrollBarImageColor3 = newPal.Border
	
			body.BackgroundColor3 = newPal.Elevated
			UIHelpers.stroke(body, newPal.Border, 1)
	
			-- Update splash screen elements only if they still exist (destroyed after init)
			if splash and splash.Parent then
				splash.BackgroundColor3 = newPal.Elevated
			end
			if loadingBar and loadingBar.Parent then
				loadingBar.BackgroundColor3 = newPal.Border
			end
			if loadingFill and loadingFill.Parent then
				loadingFill.BackgroundColor3 = newPal.Accent
				local loadingGradient = loadingFill:FindFirstChildOfClass("UIGradient")
				if loadingGradient then
					loadingGradient.Color = ColorSequence.new(newPal.Accent, newPal.AccentHover)
				end
			end
	
			for _, tabData in ipairs(tabs) do
				local isActive = tabData.btn:GetAttribute("Active") == true
				tabData.btn.BackgroundColor3 = isActive and newPal.Active or newPal.Card
				tabData.btn.TextColor3 = isActive and newPal.Text or newPal.TextSub
				tabData.indicator.BackgroundColor3 = newPal.Accent
				tabData.page.ScrollBarImageColor3 = newPal.Border
	
				if tabData.icon then
					tabData.icon.ImageColor3 = isActive and newPal.Text or newPal.TextSub
				end
			end
	
			snapshotLayout("theme-switch")
	
			Animator:Ripple(themeToggle, 25, 12)
	
			if RvrseUI.ConfigurationSaving then
				RvrseUI:_autoSave()
			end
	
			if NotificationsService and NotificationsService.Notify then
				NotificationsService:Notify({
					Title = "Theme Changed",
					Message = "Switched to " .. newTheme .. " mode",
					Duration = 2,
					Type = "info"
				})
			end
		end)
	
		task.defer(syncPillFromTheme)
	
		table.insert(RvrseUI._windows, WindowAPI)
	
		task.defer(function()
			WindowAPI:Show()
		end)
	
		return WindowAPI
	end
end


-- ============================================
-- MODULE INITIALIZATION (compiled from init.lua)
-- ============================================

Obfuscation:Initialize()
Theme:Initialize()
Animator:Initialize(TweenService)
State:Initialize()

local function configLogger(...)
	if Debug and Debug.Print then
		Debug:Print(...)
	else
		print("[RvrseUI]", ...)
	end
end

Config:Init({
	State = State,
	Theme = Theme,
	dprintf = configLogger
})

UIHelpers:Initialize({
	Animator = Animator,
	Theme = Theme,
	Icons = Icons,
	PlayerGui = PlayerGui
})

Icons:Initialize()

Elements = {
	Button = Button,
	Toggle = Toggle,
	Dropdown = Dropdown,
	Slider = Slider,
	Keybind = Keybind,
	TextBox = TextBox,
	ColorPicker = ColorPicker,
	Label = Label,
	Paragraph = Paragraph,
	Divider = Divider,
	DropdownLegacy = DropdownLegacy
}

RvrseUI.NotificationsEnabled = true

local DEFAULT_HOST = Instance.new("ScreenGui")
DEFAULT_HOST.Name = Obfuscation.getObfuscatedName("gui")
DEFAULT_HOST.ResetOnSpawn = false
DEFAULT_HOST.IgnoreGuiInset = true
DEFAULT_HOST.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
DEFAULT_HOST.DisplayOrder = 999
DEFAULT_HOST.Parent = PlayerGui

local DEFAULT_OVERLAY = Instance.new("Frame")
DEFAULT_OVERLAY.Name = "RvrseUI_Overlay"
DEFAULT_OVERLAY.BackgroundTransparency = 1
DEFAULT_OVERLAY.BorderSizePixel = 0
DEFAULT_OVERLAY.ClipsDescendants = false
DEFAULT_OVERLAY.Visible = false
DEFAULT_OVERLAY.ZIndex = 20000
DEFAULT_OVERLAY.Size = UDim2.new(1, 0, 1, 0)
DEFAULT_OVERLAY.Parent = DEFAULT_HOST

-- Initialize Overlay service
Overlay:Initialize({
	PlayerGui = PlayerGui,
	DisplayOrder = DEFAULT_HOST.DisplayOrder + 10,
	OverlayFrame = DEFAULT_OVERLAY
})

Notifications:Initialize({
	host = DEFAULT_HOST,
	Theme = Theme,
	Animator = Animator,
	UIHelpers = UIHelpers,
	RvrseUI = RvrseUI
})

Hotkeys:Initialize({
	UIS = UIS
})

WindowManager:Initialize()

KeySystem:Initialize({
	Theme = Theme,
	Animator = Animator,
	UIHelpers = UIHelpers,
	Debug = Debug,
	Obfuscation = Obfuscation
})


-- ============================================
-- MAIN RVRSEUI TABLE & PUBLIC API
-- ============================================

RvrseUI.Version = Version
RvrseUI.NotificationsEnabled = true
RvrseUI.Flags = {}
RvrseUI.Store = State
RvrseUI.UI = Hotkeys

-- Internal state
RvrseUI._windows = {}
RvrseUI._lockListeners = {}
RvrseUI._themeListeners = {}
RvrseUI._savedTheme = nil
RvrseUI._lastWindowPosition = nil
RvrseUI._controllerChipPosition = nil

-- Configuration settings
RvrseUI.ConfigurationSaving = false
RvrseUI.ConfigurationFileName = nil
RvrseUI.ConfigurationFolderName = nil
RvrseUI.AutoSaveEnabled = true

-- Create Window (main entry point)
function RvrseUI:CreateWindow(cfg)
	local deps = {
		Theme = Theme,
		Animator = Animator,
		State = State,
		Config = Config,
		UIHelpers = UIHelpers,
		Icons = Icons,
		TabBuilder = TabBuilder,
		SectionBuilder = SectionBuilder,
		WindowManager = WindowManager,
		Notifications = Notifications,
		Overlay = Overlay,  -- ⭐ CRITICAL: Pass Overlay service!
		KeySystem = KeySystem,
		Debug = Debug,
		Obfuscation = Obfuscation,
		Hotkeys = Hotkeys,
		Version = Version,
		Elements = Elements,
		OverlayLayer = DEFAULT_OVERLAY,
		UIS = UIS,
		GuiService = GuiService,
		RS = RS,
		PlayerGui = PlayerGui,
		HttpService = game:GetService("HttpService")
	}

	TabBuilder:Initialize(deps)
	SectionBuilder:Initialize(deps)
	WindowBuilder:Initialize(deps)

	if not DEFAULT_HOST or not DEFAULT_HOST.Parent then
		DEFAULT_HOST = Instance.new("ScreenGui")
		DEFAULT_HOST.Name = Obfuscation.getObfuscatedName("gui")
		DEFAULT_HOST.ResetOnSpawn = false
		DEFAULT_HOST.IgnoreGuiInset = true
		DEFAULT_HOST.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		DEFAULT_HOST.DisplayOrder = 999
		DEFAULT_HOST.Parent = PlayerGui

		DEFAULT_OVERLAY = Instance.new("Frame")
		DEFAULT_OVERLAY.Name = "RvrseUI_Overlay"
		DEFAULT_OVERLAY.BackgroundTransparency = 1
		DEFAULT_OVERLAY.BorderSizePixel = 0
		DEFAULT_OVERLAY.ClipsDescendants = false
		DEFAULT_OVERLAY.Visible = false
		DEFAULT_OVERLAY.ZIndex = 20000
		DEFAULT_OVERLAY.Size = UDim2.new(1, 0, 1, 0)
		DEFAULT_OVERLAY.Parent = DEFAULT_HOST

		Notifications:Initialize({
			host = DEFAULT_HOST,
			Theme = Theme,
			Animator = Animator,
			UIHelpers = UIHelpers,
			RvrseUI = RvrseUI
		})
	end

	return WindowBuilder:CreateWindow(self, cfg, DEFAULT_HOST)
end

-- Notifications
function RvrseUI:Notify(options)
	if not self.NotificationsEnabled then return end
	return Notifications:Notify(options)
end

-- Destroy all UI
function RvrseUI:Destroy()
	for _, window in ipairs(self._windows) do
		if window.Destroy then window:Destroy() end
	end
	if self.UI._toggleTargets then table.clear(self.UI._toggleTargets) end
	if self._lockListeners then table.clear(self._lockListeners) end
	if self._themeListeners then table.clear(self._themeListeners) end
	print("[RvrseUI] All interfaces destroyed")
end

-- Toggle UI visibility
function RvrseUI:ToggleVisibility()
	self.UI:ToggleAllWindows()
end

-- Configuration Management
function RvrseUI:SaveConfiguration()
	return Config:SaveConfiguration(self)
end

function RvrseUI:LoadConfiguration()
	return Config:LoadConfiguration(self)
end

function RvrseUI:SaveConfigAs(profileName)
	return Config:SaveConfigAs(profileName, self)
end

function RvrseUI:LoadConfigByName(profileName)
	return Config:LoadConfigByName(profileName, self)
end

function RvrseUI:_autoSave()
	if self.ConfigurationSaving and Config.AutoSaveEnabled and self.AutoSaveEnabled then
		task.defer(function() self:SaveConfiguration() end)
	end
end

function RvrseUI:GetLastConfig()
	return Config:GetLastConfig()
end

function RvrseUI:SetConfigProfile(profileName)
	return Config:SetConfigProfile(self, profileName)
end

function RvrseUI:ListProfiles()
	return Config:ListProfiles()
end

function RvrseUI:DeleteProfile(profileName)
	return Config:DeleteProfile(profileName)
end

function RvrseUI:SetAutoSaveEnabled(enabled)
	local state = Config:SetAutoSave(enabled)
	self.AutoSaveEnabled = state
	return state
end

function RvrseUI:IsAutoSaveEnabled()
	return self.AutoSaveEnabled
end

-- Version Information
function RvrseUI:GetVersionInfo()
	return {
		Full = Version.Full,
		Major = Version.Major,
		Minor = Version.Minor,
		Patch = Version.Patch,
		Build = Version.Build,
		Hash = Version.Hash,
		Channel = Version.Channel
	}
end

function RvrseUI:GetVersionString()
	return Version.Full
end

-- Theme Management
function RvrseUI:SetTheme(themeName)
	Theme:Switch(themeName)
	if self.ConfigurationSaving then self:_autoSave() end
end

function RvrseUI:GetTheme()
	return Theme.Current
end

-- Debug Methods
function RvrseUI:EnableDebug(enabled)
	if Debug then
		if Debug.SetEnabled then
			Debug:SetEnabled(enabled)
		else
			local flag = enabled and true or false
			Debug.Enabled = flag
			Debug.enabled = flag
		end
	end
end

function RvrseUI:IsDebugEnabled()
	if Debug then
		if Debug.IsEnabled then
			return Debug:IsEnabled()
		end
		return not not (Debug.Enabled or Debug.enabled)
	end
	return false
end

-- Window Management
function RvrseUI:GetWindows()
	return self._windows
end

function RvrseUI:MinimizeAll()
	for _, window in ipairs(self._windows) do
		if window.Minimize then window:Minimize() end
	end
end

function RvrseUI:RestoreAll()
	for _, window in ipairs(self._windows) do
		if window.Restore then window:Restore() end
	end
end

-- Provide notifications module with RvrseUI context
Notifications:SetContext(RvrseUI)

-- Return the framework
return RvrseUI
