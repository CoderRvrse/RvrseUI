-- RvrseUI v4.4.1 | Modern Professional UI Framework
-- Compiled from modular architecture on 2025-12-09T21:15:30.998Z

-- Features: Lucide icon system, Organic Particle System, Unified Dropdowns, ColorPicker, Key System, Spring Animations, FilterableList, Global Search
-- API: CreateWindow → CreateTab → CreateSection → {All 11 Elements}
-- Extras: Spore Bubble particles, Notify system, Theme switcher, LockGroup, Drag-to-move, Config persistence, Global Search (Ctrl+F)

-- 🏗️ ARCHITECTURE: This file is compiled from 31 modular files
-- Source: https://github.com/CoderRvrse/RvrseUI/tree/main/src
-- For modular version, use: require(script.init) instead of this file


local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")
local Mouse = LP:GetMouse()

local RvrseUI = {}


-- ========================
-- Version Module
-- ========================

-- RvrseUI Version Module
-- =========================
-- Handles version metadata and version comparison
-- Extracted from RvrseUI.lua (lines 22-54)

Version = {}

Version.Data = {
	Major = 4,
	Minor = 4,
	Patch = 0,
	Build = "20251209a",  -- YYYYMMDD format
	Full = "4.4.0",
	Hash = "F1L7R4B9",  -- Release hash for integrity verification
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

-- RvrseUI Debug Module
-- =========================
-- Handles debug logging with conditional output
-- Extracted from RvrseUI.lua (lines 17, 60-64)

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

-- Debug print helper (only prints when Enabled = true)
function Debug:Print(...)
	if self:IsEnabled() then
		print("[RvrseUI]", ...)
	end
end

-- Alias for convenience
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




-- ========================
-- Obfuscation Module
-- ========================

-- RvrseUI Name Obfuscation Module
-- =========================
-- Generates random GUI element names on every launch to prevent:
-- 1. Static detection by name
-- 2. Copy-paste theft from Explorer
-- 3. Anti-cheat pattern matching
-- 4. Reverse engineering attempts
-- Extracted from RvrseUI.lua (lines 75-149)

Obfuscation = {}

Obfuscation._seed = tick() * math.random(1, 999999)  -- Unique seed per session
Obfuscation._cache = {}  -- Cache generated names to avoid duplicates

-- Patterns for realistic-looking internal names
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

-- Helper: Get random word from pattern category
function Obfuscation:GetRandom(category)
	local words = namePatterns[category]
	self._seed = (self._seed * 9301 + 49297) % 233280
	local index = math.floor((self._seed / 233280) * #words) + 1
	return words[index]
end

-- Helper: Get random char
function Obfuscation:GetChar()
	return self:GetRandom(6)
end

-- Helper: Get random number
function Obfuscation:GetNum()
	return self:GetRandom(7)
end

-- Generate a random, realistic-looking internal name
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

-- Generate all required names for a session
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

-- Initialize method (called by init.lua)
function Obfuscation:Initialize()
	-- Reset seed and cache for new session
	self._seed = tick() * math.random(1, 999999)
	self._cache = {}
end

-- Helper function for compatibility with init.lua
function Obfuscation.getObfuscatedName(hint)
	return Obfuscation:Generate(hint)
end

-- Helper function to get full name set (called by init.lua)
function Obfuscation.getObfuscatedNames()
	return Obfuscation:GenerateSet()
end




-- ========================
-- Icons Module
-- ========================

-- Unicode icon library and resolution system for RvrseUI
-- Extracted from RvrseUI.lua (lines 548-756)
-- Now supports Lucide icons via lucide:// protocol

Icons = {}

-- Dependencies (injected via Initialize)
local deps

-- Complete Unicode icon library with named aliases
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

-- Resolves an icon input to its display format and type
-- @param icon: string (icon name/emoji/rbxassetid/lucide) or number (Roblox asset ID)
-- @return iconValue: (string | table), iconType: string
-- Return types:
--   - "text": iconValue is string (Unicode character or text)
--   - "image": iconValue is string (rbxassetid://123)
--   - "sprite": iconValue is table {id: number, imageRectSize: Vector2, imageRectOffset: Vector2}
-- Supported formats:
--   - Number: Roblox asset ID (e.g., 123456789) → returns "rbxassetid://123", "image"
--   - "icon://name": Unicode icon from library (e.g., "icon://home") → returns "🏠", "text"
--   - "lucide://name": Lucide sprite sheet icon → returns {sprite data}, "sprite" or fallback
--   - "rbxassetid://123": Direct Roblox asset URL → returns "rbxassetid://123", "image"
--   - "emoji" or "text": Direct emoji/text pass-through → returns "text", "text"
local function sanitizeAssetId(raw)
	if not raw then
		return nil
	end

	-- Trim whitespace
	local trimmed = raw:match("^%s*(.-)%s*$")
	if not trimmed or trimmed == "" then
		return nil
	end

	local lower = trimmed:lower()

	-- Handle explicit protocol (rbxassetid://123456)
	local id = lower:match("^rbxassetid://(%d+)$")
	if id then
		return "rbxassetid://" .. id
	end

	-- Handle generic Roblox asset protocol (rbxasset://textures/... or numeric id)
	local numeric = lower:match("^(%d+)$")
	if numeric then
		return "rbxassetid://" .. numeric
	end

	-- Handle rbxasset://id or rbxasset://textures/Asset? we can still return raw (Roblox accepts)
	if lower:match("^rbxasset://") then
		return trimmed
	end

	return nil
end

function Icons:Resolve(icon)
	-- If it's a number, it's a Roblox asset ID
	if typeof(icon) == "number" then
		return "rbxassetid://" .. icon, "image"
	end

	-- If it's a string
	if typeof(icon) == "string" then
		local lowerIcon = icon:lower()

		-- Check for lucide:// protocol (Rayfield hybrid pattern)
		local lucideName = lowerIcon:match("^lucide://(.+)")
		if lucideName and deps and deps.LucideIcons then
			-- Resolve Lucide icon (returns sprite data table or Unicode fallback)
			local lucideValue, lucideType = deps.LucideIcons:Get(lucideName)

			-- Return based on type:
			-- "sprite" → lucideValue is {id, imageRectSize, imageRectOffset}
			-- "text" → lucideValue is Unicode string
			if lucideType == "sprite" then
				return lucideValue, "sprite"  -- Return sprite data table as-is
			else
				return lucideValue, "text"  -- Return Unicode fallback
			end
		end

		-- Check if it's a named icon from our Unicode library
		local iconName = lowerIcon:gsub("^icon://", "")
		if self.UnicodeIcons[iconName] then
			return self.UnicodeIcons[iconName], "text"
		end

		-- Check if it's already a rbxassetid
		local assetId = sanitizeAssetId(icon)
		if assetId then
			return assetId, "image"
		end

		-- Otherwise, treat as emoji/text (user provided)
		return icon, "text"
	end

	return nil, nil
end

-- Initialize method (called by init.lua)
function Icons:Initialize(dependencies)
	deps = dependencies
	-- Icons table is ready to use
	-- UnicodeIcons are defined at module load time
	-- Lucide icons require LucideIcons module to be initialized
end

-- Helper function for compatibility (dot notation, lowercase)
function Icons.resolveIcon(icon)
	return Icons:Resolve(icon)
end




-- ========================
-- LucideIcons Module
-- ========================

-- Professional Lucide icon integration using sprite sheets (Rayfield pattern)
-- Provides 500+ pixel-perfect icons via ImageRectOffset/ImageRectSize

LucideIcons = {}

-- Dependencies (injected via Initialize)
local deps

-- Icons sprite sheet data (loaded from global or module)
local Icons = nil

-- Load icons data with error handling
-- Works in both modular mode (require) and monolith mode (global)
local function loadIconsData()
	-- Try global first (monolith/executor environment)
	if _G.RvrseUI_LucideIconsData then
		Icons = _G.RvrseUI_LucideIconsData
		if deps and deps.Debug then
			deps.Debug.printf("[LUCIDE] ✅ Sprite sheet data loaded from global")
			local sizes = {}
			for size, _ in pairs(Icons) do
				table.insert(sizes, size)
			end
			deps.Debug.printf("[LUCIDE] 📊 Available sizes: %s", table.concat(sizes, ", "))
		end
		return true
	end

	-- Try require (modular mode - Studio/ReplicatedStorage)
	local success, result = pcall(function()
		return require(script.Parent["lucide-icons-data"])
	end)

	if success and result then
		Icons = result
		if deps and deps.Debug then
			deps.Debug.printf("[LUCIDE] ✅ Sprite sheet data loaded via require()")
			local sizes = {}
			for size, _ in pairs(Icons) do
				table.insert(sizes, size)
			end
			deps.Debug.printf("[LUCIDE] 📊 Available sizes: %s", table.concat(sizes, ", "))
		end
		return true
	end

	-- Both methods failed - use Unicode fallbacks only
	warn("[RvrseUI] ❌ Failed to load Lucide icons sprite sheet")
	if deps and deps.Debug then
		deps.Debug.printf("[LUCIDE] ⚠️ Sprite data not found - using Unicode fallbacks only")
	end
	return false
end

-- Unicode fallbacks for common icons (when sprite sheets unavailable)
local UnicodeFallbacks = {
	-- Navigation
	["home"] = "🏠",
	["menu"] = "☰",
	["settings"] = "⚙",
	["search"] = "🔍",
	["x"] = "✕",
	["check"] = "✓",
	["info"] = "ℹ",
	["help-circle"] = "❓",

	-- Arrows
	["arrow-up"] = "↑",
	["arrow-down"] = "↓",
	["arrow-left"] = "←",
	["arrow-right"] = "→",
	["chevron-up"] = "▲",
	["chevron-down"] = "▼",
	["chevron-left"] = "◀",
	["chevron-right"] = "▶",
	["chevrons-up"] = "⏫",
	["chevrons-down"] = "⏬",
	["chevrons-left"] = "⏪",
	["chevrons-right"] = "⏩",

	-- Actions
	["plus"] = "+",
	["minus"] = "-",
	["edit"] = "✎",
	["pencil"] = "✎",
	["trash"] = "🗑",
	["trash-2"] = "🗑",
	["save"] = "💾",
	["download"] = "⬇",
	["upload"] = "⬆",
	["refresh-cw"] = "↻",
	["rotate-cw"] = "↻",
	["copy"] = "📋",

	-- Media
	["play"] = "▶",
	["pause"] = "⏸",
	["stop"] = "⏹",
	["skip-forward"] = "⏭",
	["skip-back"] = "⏮",
	["volume"] = "🔊",
	["volume-1"] = "🔉",
	["volume-2"] = "🔊",
	["volume-x"] = "🔇",

	-- Status
	["alert-triangle"] = "⚠",
	["alert-circle"] = "⚠",
	["check-circle"] = "✓",
	["check-circle-2"] = "✓",
	["x-circle"] = "✕",
	["bell"] = "🔔",
	["flag"] = "🚩",

	-- User
	["user"] = "👤",
	["users"] = "👥",
	["user-plus"] = "👤+",
	["user-minus"] = "👤-",
	["user-check"] = "✓👤",
	["user-x"] = "✕👤",
	["message-circle"] = "💬",
	["message-square"] = "💬",
	["mail"] = "✉",

	-- Security
	["lock"] = "🔒",
	["unlock"] = "🔓",
	["key"] = "🔑",
	["shield"] = "🛡",
	["shield-check"] = "🛡✓",
	["shield-alert"] = "🛡⚠",

	-- Objects
	["package"] = "📦",
	["gift"] = "🎁",
	["shopping-cart"] = "🛒",
	["heart"] = "❤",

	-- Files
	["file"] = "📄",
	["file-text"] = "📄",
	["folder"] = "📁",
	["folder-open"] = "📂",
	["link"] = "🔗",
	["paperclip"] = "📎",

	-- Tech
	["code"] = "⌨",
	["terminal"] = "⌨",
	["database"] = "🗄",
	["server"] = "🖥",
	["cpu"] = "⚙",
	["wifi"] = "📶",
	["battery"] = "🔋",
	["power"] = "⚡",
	["zap"] = "⚡",

	-- Nature
	["sun"] = "☀",
	["moon"] = "🌙",
	["star"] = "⭐",
	["cloud"] = "☁",
	["droplet"] = "💧",
	["flame"] = "🔥",

	-- Games
	["trophy"] = "🏆",
	["award"] = "🏅",
	["target"] = "🎯",
	["crown"] = "👑",
	["gamepad"] = "🎮",

	-- Misc
	["eye"] = "👁",
	["eye-off"] = "⚊",
	["camera"] = "📷",
	["calendar"] = "📅",
	["clock"] = "🕐",
	["map-pin"] = "📍",
	["bookmark"] = "🔖",
	["tag"] = "🏷",
}

-- Get icon from sprite sheet (Rayfield's getIcon pattern)
-- Returns: {id: number, imageRectSize: Vector2, imageRectOffset: Vector2} or nil
local function getIcon(name)
	-- Check if sprite sheet loaded
	if not Icons then
		if deps and deps.Debug then
			deps.Debug.printf("[LUCIDE] ⚠️ Sprite sheet not loaded, using fallback for: %s", name)
		end
		return nil
	end

	-- Normalize icon name (trim whitespace, lowercase)
	name = string.match(string.lower(name), "^%s*(.*)%s*$")

	-- Get 48px sprite sheet (standard size)
	local sizedicons = Icons["48px"]
	if not sizedicons then
		warn("[RvrseUI] Lucide Icons: No 48px sprite sheet found")
		return nil
	end

	-- Look up icon data
	local iconData = sizedicons[name]
	if not iconData then
		-- Icon not found in sprite sheet
		if deps and deps.Debug then
			deps.Debug.printf("[LUCIDE] ⚠️ Icon not found in sprite sheet: %s", name)
		end
		return nil
	end

	-- Parse sprite sheet data: {AssetID, {Width, Height}, {OffsetX, OffsetY}}
	local assetId = iconData[1]
	local size = iconData[2]
	local offset = iconData[3]

	-- Return Rayfield-compatible structure
	return {
		id = assetId,
		imageRectSize = Vector2.new(size[1], size[2]),
		imageRectOffset = Vector2.new(offset[1], offset[2])
	}
end

-- Get usable icon representation (sprite sheet or Unicode fallback)
-- @param iconName: string - Lucide icon name (e.g., "home", "settings", "arrow-right")
-- @return value (table or string), type ("sprite" or "text")
--
-- Return format for sprite icons:
-- {
--     id = number,              -- Roblox asset ID
--     imageRectSize = Vector2,  -- Size of icon in sprite sheet
--     imageRectOffset = Vector2 -- Position of icon in sprite sheet
-- }
function LucideIcons:Get(iconName)
	-- Try to get from sprite sheet first
	local spriteData = getIcon(iconName)
	if spriteData then
		return spriteData, "sprite"
	end

	-- Fall back to Unicode
	if UnicodeFallbacks[iconName] then
		return UnicodeFallbacks[iconName], "text"
	end

	-- No fallback available - return icon name as text
	if deps and deps.Debug then
		deps.Debug.printf("[LUCIDE] ⚠️ No fallback for icon: %s (displaying as text)", iconName)
	end
	return iconName, "text"
end

-- Check if sprite sheets are loaded
function LucideIcons:IsLoaded()
	return Icons ~= nil
end

-- Get list of available icon names (first 50 for debugging)
function LucideIcons:GetAvailableIcons(limit)
	if not Icons or not Icons["48px"] then
		return {}
	end

	local iconList = {}
	local count = 0
	limit = limit or 50

	for name, _ in pairs(Icons["48px"]) do
		table.insert(iconList, name)
		count = count + 1
		if count >= limit then
			break
		end
	end

	table.sort(iconList)
	return iconList
end

-- Get total icon count
function LucideIcons:GetIconCount()
	if not Icons or not Icons["48px"] then
		return 0
	end

	local count = 0
	for _ in pairs(Icons["48px"]) do
		count = count + 1
	end
	return count
end

-- Initialize method (called by init.lua)
function LucideIcons:Initialize(dependencies)
	deps = dependencies

	-- Load sprite sheet data
	local success = loadIconsData()

	-- Log initialization status
	if deps.Debug then
		-- Count Unicode fallbacks
		local fallbackCount = 0
		for _ in pairs(UnicodeFallbacks) do
			fallbackCount = fallbackCount + 1
		end

		if success then
			local iconCount = self:GetIconCount()
			deps.Debug.printf("[LUCIDE] ✅ Lucide icon system initialized")
			deps.Debug.printf("[LUCIDE] 📦 %d icons available via sprite sheets", iconCount)
			deps.Debug.printf("[LUCIDE] 🔄 %d Unicode fallbacks available", fallbackCount)

			-- Show sample icons
			local sample = self:GetAvailableIcons(10)
			deps.Debug.printf("[LUCIDE] 📋 Sample icons: %s", table.concat(sample, ", "))
		else
			deps.Debug.printf("[LUCIDE] ⚠️ Sprite sheets failed to load - using Unicode fallbacks only")
			deps.Debug.printf("[LUCIDE] 🔄 %d Unicode fallbacks available", fallbackCount)
		end
	end
end




-- ========================
-- lucide-icons-data Module
-- ========================

_G.RvrseUI_LucideIconsData = --!nocheck

return {["48px"]={rewind={16898613699,{48,48},{563,967}},fuel={16898613353,{48,48},{196,967}},["square-arrow-out-up-right"]={16898613777,{48,48},{967,514}},["table-cells-split"]={16898613777,{48,48},{771,955}},gavel={16898613353,{48,48},{967,808}},["dna-off"]={16898613044,{48,48},{453,967}},["refresh-ccw-dot"]={16898613699,{48,48},{869,404}},bean={16898612629,{48,48},{967,906}},["arrow-up-right-from-circle"]={16898612629,{48,48},{563,967}},["table-columns-split"]={16898613777,{48,48},{967,808}},bolt={16898612819,{48,48},{306,820}},["square-asterisk"]={16898613777,{48,48},{710,771}},feather={16898613353,{48,48},{771,98}},["align-horizontal-distribute-center"]={16898612629,{48,48},{771,355}},["align-center"]={16898612629,{48,48},{0,869}},["grip-vertical"]={16898613509,{48,48},{0,869}},["person-standing"]={16898613699,{48,48},{563,771}},["badge-swiss-franc"]={16898612629,{48,48},{771,857}},["between-horizontal-end"]={16898612819,{48,48},{771,306}},["rotate-cw"]={16898613699,{48,48},{869,453}},framer={16898613353,{48,48},{661,967}},["bus-front"]={16898612819,{48,48},{869,612}},["shield-ellipsis"]={16898613777,{48,48},{771,306}},["file-lock-2"]={16898613353,{48,48},{257,918}},["between-vertical-end"]={16898612819,{48,48},{257,820}},["globe-lock"]={16898613509,{48,48},{820,514}},["toggle-left"]={16898613869,{48,48},{869,49}},["concierge-bell"]={16898613044,{48,48},{869,147}},video={16898613869,{48,48},{355,967}},["arrow-left-square"]={16898612629,{48,48},{196,820}},["file-down"]={16898613353,{48,48},{98,820}},["picture-in-picture"]={16898613699,{48,48},{257,869}},["messages-square"]={16898613613,{48,48},{306,869}},grab={16898613509,{48,48},{514,820}},["phone-call"]={16898613699,{48,48},{514,820}},["chevron-up-circle"]={16898612819,{48,48},{820,808}},["server-crash"]={16898613699,{48,48},{918,955}},["heading-3"]={16898613509,{48,48},{869,306}},squircle={16898613777,{48,48},{820,759}},["wifi-off"]={16898613869,{48,48},{918,759}},["sun-medium"]={16898613777,{48,48},{661,967}},ungroup={16898613869,{48,48},{257,967}},["cloud-download"]={16898613044,{48,48},{612,820}},["sigma-square"]={16898613777,{48,48},{869,514}},["folder-plus"]={16898613353,{48,48},{661,918}},["hard-drive-download"]={16898613509,{48,48},{918,0}},["scatter-chart"]={16898613699,{48,48},{196,967}},pointer={16898613699,{48,48},{661,771}},ligature={16898613509,{48,48},{612,967}},["chevrons-up-down"]={16898612819,{48,48},{918,759}},["iteration-cw"]={16898613509,{48,48},{869,147}},["rail-symbol"]={16898613699,{48,48},{967,514}},["square-stack"]={16898613777,{48,48},{453,869}},parentheses={16898613613,{48,48},{869,906}},["book-up-2"]={16898612819,{48,48},{306,869}},flame={16898613353,{48,48},{967,306}},["chevrons-up"]={16898612819,{48,48},{869,808}},["chevron-right-square"]={16898612819,{48,48},{918,710}},["square-mouse-pointer"]={16898613777,{48,48},{869,661}},superscript={16898613777,{48,48},{918,759}},signal={16898613777,{48,48},{918,0}},["file-warning"]={16898613353,{48,48},{967,514}},hexagon={16898613509,{48,48},{967,0}},["navigation-2-off"]={16898613613,{48,48},{918,612}},unlock={16898613869,{48,48},{771,710}},["arrows-up-from-line"]={16898612629,{48,48},{918,404}},["square-gantt-chart"]={16898613777,{48,48},{453,820}},["square-chevron-left"]={16898613777,{48,48},{967,49}},scaling={16898613699,{48,48},{967,661}},["inspection-panel"]={16898613509,{48,48},{563,918}},["arrow-left-from-line"]={16898612629,{48,48},{869,147}},ship={16898613777,{48,48},{771,98}},["ticket-percent"]={16898613869,{48,48},{257,869}},["arrow-right-square"]={16898612629,{48,48},{869,404}},["calendar-clock"]={16898612819,{48,48},{918,98}},x={16898613869,{48,48},{869,906}},voicemail={16898613869,{48,48},{869,710}},presentation={16898613699,{48,48},{771,196}},["tree-palm"]={16898613869,{48,48},{820,612}},popsicle={16898613699,{48,48},{563,869}},["captions-off"]={16898612819,{48,48},{661,869}},["align-vertical-justify-center"]={16898612629,{48,48},{49,869}},theater={16898613869,{48,48},{98,771}},tent={16898613869,{48,48},{49,771}},["repeat-1"]={16898613699,{48,48},{918,612}},stethoscope={16898613777,{48,48},{147,967}},["screen-share-off"]={16898613699,{48,48},{771,906}},["arrow-big-up"]={16898612629,{48,48},{918,306}},["volume-x"]={16898613869,{48,48},{710,869}},["mouse-pointer-click"]={16898613613,{48,48},{771,710}},["square-m"]={16898613777,{48,48},{306,967}},["hard-drive"]={16898613509,{48,48},{820,98}},["package-minus"]={16898613613,{48,48},{771,808}},cloud={16898613044,{48,48},{918,306}},["mouse-pointer-square-dashed"]={16898613613,{48,48},{710,771}},["flip-horizontal"]={16898613353,{48,48},{306,967}},["alert-circle"]={16898612629,{48,48},{869,0}},unplug={16898613869,{48,48},{710,771}},["badge-cent"]={16898612629,{48,48},{612,967}},["check-square-2"]={16898612819,{48,48},{820,759}},["monitor-check"]={16898613613,{48,48},{196,771}},trello={16898613869,{48,48},{612,820}},["paintbrush-2"]={16898613613,{48,48},{967,404}},["bar-chart-horizontal"]={16898612629,{48,48},{710,967}},["book-plus"]={16898612819,{48,48},{771,404}},torus={16898613869,{48,48},{147,771}},["panel-right-close"]={16898613613,{48,48},{453,967}},["heart-handshake"]={16898613509,{48,48},{869,563}},trees={16898613869,{48,48},{661,771}},ham={16898613509,{48,48},{355,771}},text={16898613869,{48,48},{771,98}},["nut-off"]={16898613613,{48,48},{98,967}},["bean-off"]={16898612629,{48,48},{869,955}},rat={16898613699,{48,48},{869,612}},["separator-horizontal"]={16898613699,{48,48},{918,906}},["square-arrow-up-right"]={16898613777,{48,48},{820,661}},["signal-zero"]={16898613777,{48,48},{514,869}},citrus={16898613044,{48,48},{306,820}},["phone-missed"]={16898613699,{48,48},{771,98}},["user-round-check"]={16898613869,{48,48},{869,404}},["battery-medium"]={16898612629,{48,48},{869,906}},["square-minus"]={16898613777,{48,48},{918,612}},hotel={16898613509,{48,48},{98,869}},["folder-output"]={16898613353,{48,48},{771,808}},["ice-cream"]={16898613509,{48,48},{869,355}},menu={16898613613,{48,48},{49,820}},["arrow-up-left-square"]={16898612629,{48,48},{710,820}},lightbulb={16898613509,{48,48},{918,196}},["badge-help"]={16898612629,{48,48},{147,967}},angry={16898612629,{48,48},{257,918}},outdent={16898613613,{48,48},{918,661}},["circle-dot-dashed"]={16898613044,{48,48},{771,514}},speech={16898613777,{48,48},{820,147}},["cake-slice"]={16898612819,{48,48},{661,820}},["git-graph"]={16898613509,{48,48},{0,771}},armchair={16898612629,{48,48},{820,147}},["qr-code"]={16898613699,{48,48},{967,257}},copy={16898613044,{48,48},{918,612}},goal={16898613509,{48,48},{563,771}},["trending-down"]={16898613869,{48,48},{563,869}},haze={16898613509,{48,48},{98,820}},nfc={16898613613,{48,48},{612,918}},["receipt-russian-ruble"]={16898613699,{48,48},{514,967}},disc={16898613044,{48,48},{661,967}},["notebook-tabs"]={16898613613,{48,48},{967,98}},["panels-left-bottom"]={16898613613,{48,48},{820,906}},videotape={16898613869,{48,48},{967,612}},["sun-moon"]={16898613777,{48,48},{967,196}},calendar={16898612819,{48,48},{355,918}},["minus-circle"]={16898613613,{48,48},{869,98}},sunset={16898613777,{48,48},{967,710}},["navigation-2"]={16898613613,{48,48},{869,661}},["message-square-heart"]={16898613613,{48,48},{771,147}},["rectangle-ellipsis"]={16898613699,{48,48},{820,196}},["badge-plus"]={16898612629,{48,48},{918,710}},["indian-rupee"]={16898613509,{48,48},{710,771}},["monitor-dot"]={16898613613,{48,48},{147,820}},delete={16898613044,{48,48},{661,918}},["clipboard-pen-line"]={16898613044,{48,48},{918,0}},["folder-search"]={16898613353,{48,48},{918,196}},["utensils-crossed"]={16898613869,{48,48},{918,147}},dices={16898613044,{48,48},{918,710}},reply={16898613699,{48,48},{612,918}},["flask-round"]={16898613353,{48,48},{404,869}},pause={16898613699,{48,48},{0,771}},shrub={16898613777,{48,48},{306,820}},flag={16898613353,{48,48},{98,918}},underline={16898613869,{48,48},{820,404}},["align-horizontal-distribute-end"]={16898612629,{48,48},{355,771}},newspaper={16898613613,{48,48},{661,869}},table={16898613777,{48,48},{820,955}},["move-vertical"]={16898613613,{48,48},{820,453}},["file-pen-line"]={16898613353,{48,48},{612,820}},["badge-russian-ruble"]={16898612629,{48,48},{820,808}},radius={16898613699,{48,48},{257,967}},["loader-2"]={16898613509,{48,48},{820,857}},pilcrow={16898613699,{48,48},{612,771}},["scan-face"]={16898613699,{48,48},{820,808}},spade={16898613777,{48,48},{514,918}},["book-user"]={16898612819,{48,48},{918,514}},["flip-vertical"]={16898613353,{48,48},{918,612}},["square-arrow-down"]={16898613777,{48,48},{453,771}},["circle-plus"]={16898613044,{48,48},{869,0}},view={16898613869,{48,48},{918,661}},cctv={16898612819,{48,48},{355,967}},["more-horizontal"]={16898613613,{48,48},{257,967}},["file-key-2"]={16898613353,{48,48},{404,771}},["pause-octagon"]={16898613699,{48,48},{771,0}},["circle-arrow-out-down-left"]={16898612819,{48,48},{771,955}},volume={16898613869,{48,48},{661,918}},facebook={16898613353,{48,48},{563,771}},["octagon-alert"]={16898613613,{48,48},{918,404}},["panel-bottom-dashed"]={16898613613,{48,48},{918,710}},["book-a"]={16898612819,{48,48},{820,563}},["align-end-vertical"]={16898612629,{48,48},{820,306}},["user-x-2"]={16898613869,{48,48},{771,759}},chrome={16898612819,{48,48},{820,857}},["receipt-japanese-yen"]={16898613699,{48,48},{612,869}},rabbit={16898613699,{48,48},{869,355}},["scissors-square"]={16898613699,{48,48},{869,808}},["check-square"]={16898612819,{48,48},{771,808}},["train-front-tunnel"]={16898613869,{48,48},{771,404}},["panel-left-dashed"]={16898613613,{48,48},{661,967}},fish={16898613353,{48,48},{869,147}},slack={16898613777,{48,48},{0,918}},sliders={16898613777,{48,48},{404,771}},["message-circle-warning"]={16898613613,{48,48},{771,612}},map={16898613613,{48,48},{306,771}},route={16898613699,{48,48},{404,918}},["arrow-up-left"]={16898612629,{48,48},{661,869}},award={16898612629,{48,48},{918,661}},["message-square-plus"]={16898613613,{48,48},{49,869}},["unfold-horizontal"]={16898613869,{48,48},{355,869}},["area-chart"]={16898612629,{48,48},{869,98}},["music-4"]={16898613613,{48,48},{306,967}},["shield-x"]={16898613777,{48,48},{514,820}},["plane-landing"]={16898613699,{48,48},{771,147}},["disc-3"]={16898613044,{48,48},{771,857}},["columns-4"]={16898613044,{48,48},{710,771}},["archive-x"]={16898612629,{48,48},{967,0}},["square-dashed-kanban"]={16898613777,{48,48},{98,918}},["users-2"]={16898613869,{48,48},{612,918}},["shield-off"]={16898613777,{48,48},{820,514}},compass={16898613044,{48,48},{514,967}},vegan={16898613869,{48,48},{967,355}},["message-circle-plus"]={16898613613,{48,48},{257,869}},["stop-circle"]={16898613777,{48,48},{453,918}},nut={16898613613,{48,48},{967,355}},search={16898613699,{48,48},{918,857}},files={16898613353,{48,48},{771,710}},["send-to-back"]={16898613699,{48,48},{820,955}},["alarm-clock"]={16898612629,{48,48},{257,820}},["shopping-basket"]={16898613777,{48,48},{0,869}},send={16898613699,{48,48},{967,857}},["chevron-left-square"]={16898612819,{48,48},{453,918}},["terminal-square"]={16898613869,{48,48},{0,820}},wifi={16898613869,{48,48},{869,808}},["skip-back"]={16898613777,{48,48},{147,771}},["wrap-text"]={16898613869,{48,48},{869,857}},["file-scan"]={16898613353,{48,48},{820,147}},["message-square-dashed"]={16898613613,{48,48},{918,0}},trophy={16898613869,{48,48},{820,147}},umbrella={16898613869,{48,48},{869,355}},touchpad={16898613869,{48,48},{49,869}},["clipboard-copy"]={16898613044,{48,48},{820,563}},pentagon={16898613699,{48,48},{771,306}},["arrow-up-from-line"]={16898612629,{48,48},{820,710}},["circle-chevron-up"]={16898613044,{48,48},{771,0}},worm={16898613869,{48,48},{918,808}},["lamp-desk"]={16898613509,{48,48},{355,918}},["circle-arrow-up"]={16898612819,{48,48},{967,857}},zap={16898613869,{48,48},{918,906}},boxes={16898612819,{48,48},{196,771}},["swiss-franc"]={16898613777,{48,48},{820,857}},["move-left"]={16898613613,{48,48},{98,918}},["chevron-up"]={16898612819,{48,48},{710,918}},instagram={16898613509,{48,48},{514,967}},["pen-tool"]={16898613699,{48,48},{820,0}},["pencil-ruler"]={16898613699,{48,48},{0,820}},["grid-2x2"]={16898613509,{48,48},{771,98}},["arrow-big-down-dash"]={16898612629,{48,48},{771,196}},["clipboard-edit"]={16898613044,{48,48},{771,612}},mic={16898613613,{48,48},{820,612}},["file-minus-2"]={16898613353,{48,48},{869,563}},gitlab={16898613509,{48,48},{820,257}},["rotate-3d"]={16898613699,{48,48},{147,918}},["spell-check"]={16898613777,{48,48},{196,771}},popcorn={16898613699,{48,48},{612,820}},blocks={16898612819,{48,48},{49,820}},["washing-machine"]={16898613869,{48,48},{918,710}},siren={16898613777,{48,48},{771,147}},["cloud-sun"]={16898613044,{48,48},{0,967}},circle={16898613044,{48,48},{771,355}},["shield-alert"]={16898613777,{48,48},{49,771}},rainbow={16898613699,{48,48},{918,563}},["separator-vertical"]={16898613699,{48,48},{869,955}},ampersands={16898612629,{48,48},{355,820}},["user-search"]={16898613869,{48,48},{918,612}},fence={16898613353,{48,48},{98,771}},["square-user-round"]={16898613777,{48,48},{355,967}},sunrise={16898613777,{48,48},{453,967}},strikethrough={16898613777,{48,48},{869,759}},["calendar-days"]={16898612819,{48,48},{869,147}},["dollar-sign"]={16898613044,{48,48},{820,857}},["message-square-quote"]={16898613613,{48,48},{0,918}},["list-minus"]={16898613509,{48,48},{820,808}},["cloud-hail"]={16898613044,{48,48},{967,0}},upload={16898613869,{48,48},{612,869}},["app-window-mac"]={16898612629,{48,48},{661,771}},ellipsis={16898613353,{48,48},{771,49}},["copy-check"]={16898613044,{48,48},{453,820}},history={16898613509,{48,48},{869,98}},satellite={16898613699,{48,48},{147,967}},["bookmark-plus"]={16898612819,{48,48},{612,820}},["folder-key"]={16898613353,{48,48},{355,967}},["lamp-ceiling"]={16898613509,{48,48},{404,869}},["circle-power"]={16898613044,{48,48},{820,49}},hourglass={16898613509,{48,48},{49,918}},keyboard={16898613509,{48,48},{453,820}},triangle={16898613869,{48,48},{869,98}},["layers-2"]={16898613509,{48,48},{196,869}},["battery-full"]={16898612629,{48,48},{967,808}},["user-minus"]={16898613869,{48,48},{49,967}},["x-octagon"]={16898613869,{48,48},{967,808}},["folder-tree"]={16898613353,{48,48},{967,404}},command={16898613044,{48,48},{563,918}},["badge-dollar-sign"]={16898612629,{48,48},{918,196}},["align-start-vertical"]={16898612629,{48,48},{820,98}},["chevrons-down"]={16898612819,{48,48},{967,196}},["bluetooth-off"]={16898612819,{48,48},{869,257}},cannabis={16898612819,{48,48},{710,820}},book={16898612819,{48,48},{820,612}},hammer={16898613509,{48,48},{306,820}},["circle-minus"]={16898613044,{48,48},{771,306}},["audio-waveform"]={16898612629,{48,48},{967,612}},["moon-star"]={16898613613,{48,48},{355,869}},["arrow-right"]={16898612629,{48,48},{453,820}},sparkle={16898613777,{48,48},{967,0}},wand={16898613869,{48,48},{404,967}},["calendar-minus-2"]={16898612819,{48,48},{147,869}},["copy-minus"]={16898613044,{48,48},{404,869}},["folder-input"]={16898613353,{48,48},{453,869}},["book-image"]={16898612819,{48,48},{771,147}},shirt={16898613777,{48,48},{98,771}},["server-off"]={16898613699,{48,48},{967,955}},["move-up"]={16898613613,{48,48},{869,404}},["plug-2"]={16898613699,{48,48},{869,306}},radio={16898613699,{48,48},{306,918}},brackets={16898612819,{48,48},{98,869}},["calendar-heart"]={16898612819,{48,48},{196,820}},["list-ordered"]={16898613509,{48,48},{710,918}},["mic-off"]={16898613613,{48,48},{918,514}},["arrow-big-left"]={16898612629,{48,48},{98,869}},["square-split-horizontal"]={16898613777,{48,48},{918,404}},["tree-deciduous"]={16898613869,{48,48},{869,563}},["sun-snow"]={16898613777,{48,48},{196,967}},["user-2"]={16898613869,{48,48},{514,967}},["help-circle"]={16898613509,{48,48},{563,869}},["clock-2"]={16898613044,{48,48},{771,404}},["calendar-fold"]={16898612819,{48,48},{820,196}},["fish-off"]={16898613353,{48,48},{967,49}},baby={16898612629,{48,48},{771,808}},leaf={16898613509,{48,48},{918,661}},["fold-vertical"]={16898613353,{48,48},{661,869}},hop={16898613509,{48,48},{196,771}},paperclip={16898613613,{48,48},{918,857}},cigarette={16898612819,{48,48},{967,759}},minus={16898613613,{48,48},{771,196}},["smile-plus"]={16898613777,{48,48},{918,514}},["chevron-right-circle"]={16898612819,{48,48},{967,661}},["star-off"]={16898613777,{48,48},{612,967}},["git-pull-request-closed"]={16898613509,{48,48},{771,514}},["badge-check"]={16898612629,{48,48},{967,147}},["test-tube-2"]={16898613869,{48,48},{771,306}},["kanban-square"]={16898613509,{48,48},{98,918}},["plug-zap"]={16898613699,{48,48},{771,404}},["heading-4"]={16898613509,{48,48},{820,355}},["git-pull-request-create"]={16898613509,{48,48},{820,0}},["replace-all"]={16898613699,{48,48},{771,759}},["receipt-swiss-franc"]={16898613699,{48,48},{967,49}},["square-dashed-bottom-code"]={16898613777,{48,48},{196,820}},["clock-7"]={16898613044,{48,48},{918,514}},["scan-text"]={16898613699,{48,48},{661,967}},["shower-head"]={16898613777,{48,48},{771,355}},["equal-not"]={16898613353,{48,48},{49,771}},["move-down"]={16898613613,{48,48},{196,820}},["ticket-slash"]={16898613869,{48,48},{820,563}},ruler={16898613699,{48,48},{710,869}},["circle-user-round"]={16898613044,{48,48},{0,869}},subscript={16898613777,{48,48},{820,808}},["alarm-minus"]={16898612629,{48,48},{820,514}},["layout-grid"]={16898613509,{48,48},{918,404}},cog={16898613044,{48,48},{918,563}},dog={16898613044,{48,48},{869,808}},swords={16898613777,{48,48},{967,759}},["panel-right-dashed"]={16898613613,{48,48},{967,710}},["ship-wheel"]={16898613777,{48,48},{820,49}},bot={16898612819,{48,48},{869,98}},["trash-2"]={16898613869,{48,48},{257,918}},["chevron-down-square"]={16898612819,{48,48},{918,196}},dot={16898613044,{48,48},{918,808}},["file-symlink"]={16898613353,{48,48},{967,257}},["clipboard-paste"]={16898613044,{48,48},{514,869}},plug={16898613699,{48,48},{404,771}},["book-heart"]={16898612819,{48,48},{820,98}},["circle-parking"]={16898613044,{48,48},{820,514}},["volume-1"]={16898613869,{48,48},{820,759}},["circle-chevron-right"]={16898612819,{48,48},{967,955}},speaker={16898613777,{48,48},{869,98}},timer={16898613869,{48,48},{918,0}},forward={16898613353,{48,48},{771,857}},["file-up"]={16898613353,{48,48},{453,771}},["between-vertical-start"]={16898612819,{48,48},{820,514}},database={16898613044,{48,48},{710,869}},["panel-right"]={16898613613,{48,48},{820,857}},["log-out"]={16898613509,{48,48},{820,955}},["git-branch-plus"]={16898613353,{48,48},{967,857}},["clipboard-minus"]={16898613044,{48,48},{563,820}},["file-text"]={16898613353,{48,48},{869,355}},["arrow-right-circle"]={16898612629,{48,48},{49,967}},["table-rows-split"]={16898613777,{48,48},{869,906}},watch={16898613869,{48,48},{869,759}},["cloud-upload"]={16898613044,{48,48},{967,257}},banknote={16898612629,{48,48},{453,967}},["folder-up"]={16898613353,{48,48},{918,453}},["list-checks"]={16898613509,{48,48},{404,967}},bug={16898612819,{48,48},{257,967}},["circle-chevron-left"]={16898612819,{48,48},{918,955}},["arrow-down"]={16898612629,{48,48},{967,49}},["arrow-up-down"]={16898612629,{48,48},{918,612}},["file-audio"]={16898613353,{48,48},{771,355}},["whole-word"]={16898613869,{48,48},{967,710}},monitor={16898613613,{48,48},{404,820}},["flag-off"]={16898613353,{48,48},{820,196}},["align-right"]={16898612629,{48,48},{918,0}},["circle-stop"]={16898613044,{48,48},{49,820}},infinity={16898613509,{48,48},{661,820}},["arrow-big-down"]={16898612629,{48,48},{196,771}},["circle-parking-off"]={16898613044,{48,48},{257,820}},["calendar-x-2"]={16898612819,{48,48},{453,820}},["user-plus"]={16898613869,{48,48},{918,355}},["move-diagonal-2"]={16898613613,{48,48},{967,49}},["gallery-horizontal-end"]={16898613353,{48,48},{967,710}},["panel-top-dashed"]={16898613613,{48,48},{710,967}},["tram-front"]={16898613869,{48,48},{306,869}},podcast={16898613699,{48,48},{820,612}},["image-minus"]={16898613509,{48,48},{771,453}},["flip-vertical-2"]={16898613353,{48,48},{967,563}},github={16898613509,{48,48},{0,820}},pocket={16898613699,{48,48},{869,563}},printer={16898613699,{48,48},{196,771}},["megaphone-off"]={16898613613,{48,48},{514,820}},["file-bar-chart-2"]={16898613353,{48,48},{869,514}},["arrow-big-right"]={16898612629,{48,48},{0,967}},replace={16898613699,{48,48},{710,820}},["toy-brick"]={16898613869,{48,48},{918,257}},["square-chevron-down"]={16898613777,{48,48},{514,967}},["dice-1"]={16898613044,{48,48},{147,967}},["scan-search"]={16898613699,{48,48},{710,918}},["sticky-note"]={16898613777,{48,48},{918,453}},["shield-check"]={16898613777,{48,48},{820,257}},["hand-metal"]={16898613509,{48,48},{771,612}},["x-circle"]={16898613869,{48,48},{771,955}},["spell-check-2"]={16898613777,{48,48},{771,196}},["minus-square"]={16898613613,{48,48},{820,147}},["box-select"]={16898612819,{48,48},{820,147}},sprout={16898613777,{48,48},{918,306}},waypoints={16898613869,{48,48},{771,857}},["ice-cream-cone"]={16898613509,{48,48},{918,306}},["text-quote"]={16898613869,{48,48},{514,820}},wind={16898613869,{48,48},{820,857}},["layout-panel-left"]={16898613509,{48,48},{453,869}},["circle-percent"]={16898613044,{48,48},{563,771}},["circle-arrow-out-down-right"]={16898612819,{48,48},{967,808}},["square-x"]={16898613777,{48,48},{918,661}},italic={16898613509,{48,48},{967,49}},["step-forward"]={16898613777,{48,48},{196,918}},["a-arrow-down"]={16898612629,{48,48},{771,0}},container={16898613044,{48,48},{967,306}},sticker={16898613777,{48,48},{967,404}},["parking-circle-off"]={16898613613,{48,48},{820,955}},import={16898613509,{48,48},{967,514}},vault={16898613869,{48,48},{98,967}},["square-terminal"]={16898613777,{48,48},{404,918}},["file-music"]={16898613353,{48,48},{771,661}},beef={16898612819,{48,48},{0,771}},["route-off"]={16898613699,{48,48},{453,869}},["timer-reset"]={16898613869,{48,48},{514,869}},["monitor-stop"]={16898613613,{48,48},{820,404}},smile={16898613777,{48,48},{869,563}},["signpost-big"]={16898613777,{48,48},{869,49}},["folder-lock"]={16898613353,{48,48},{967,612}},["square-percent"]={16898613777,{48,48},{661,869}},["navigation-off"]={16898613613,{48,48},{820,710}},["arrow-left"]={16898612629,{48,48},{98,918}},["car-taxi-front"]={16898612819,{48,48},{967,98}},laugh={16898613509,{48,48},{869,196}},["x-square"]={16898613869,{48,48},{918,857}},["step-back"]={16898613777,{48,48},{918,196}},equal={16898613353,{48,48},{0,820}},megaphone={16898613613,{48,48},{869,0}},["calendar-x"]={16898612819,{48,48},{404,869}},egg={16898613353,{48,48},{514,771}},["video-off"]={16898613869,{48,48},{404,918}},["japanese-yen"]={16898613509,{48,48},{820,196}},library={16898613509,{48,48},{710,869}},["file-terminal"]={16898613353,{48,48},{918,306}},quote={16898613699,{48,48},{918,306}},accessibility={16898612629,{48,48},{257,771}},["square-library"]={16898613777,{48,48},{355,918}},salad={16898613699,{48,48},{967,147}},["tally-2"]={16898613869,{48,48},{771,0}},sheet={16898613777,{48,48},{820,0}},["circle-check-big"]={16898612819,{48,48},{918,906}},["map-pinned"]={16898613613,{48,48},{771,306}},["corner-down-left"]={16898613044,{48,48},{771,759}},dribbble={16898613044,{48,48},{918,857}},["pilcrow-square"]={16898613699,{48,48},{771,612}},["lamp-wall-up"]={16898613509,{48,48},{918,612}},["book-dashed"]={16898612819,{48,48},{514,869}},["unfold-vertical"]={16898613869,{48,48},{306,918}},["tree-pine"]={16898613869,{48,48},{771,661}},["receipt-indian-rupee"]={16898613699,{48,48},{661,820}},["check-circle-2"]={16898612819,{48,48},{918,661}},["flask-conical"]={16898613353,{48,48},{453,820}},["package-search"]={16898613613,{48,48},{612,967}},columns={16898613044,{48,48},{661,820}},["folder-sync"]={16898613353,{48,48},{147,967}},fingerprint={16898613353,{48,48},{563,918}},["arrow-up-narrow-wide"]={16898612629,{48,48},{612,918}},frame={16898613353,{48,48},{710,918}},["clock-12"]={16898613044,{48,48},{820,355}},images={16898613509,{48,48},{257,967}},lollipop={16898613509,{48,48},{967,857}},["folder-root"]={16898613353,{48,48},{612,967}},["arrow-left-circle"]={16898612629,{48,48},{918,98}},["lamp-floor"]={16898613509,{48,48},{306,967}},image={16898613509,{48,48},{306,918}},["baggage-claim"]={16898612629,{48,48},{967,196}},bike={16898612819,{48,48},{771,563}},option={16898613613,{48,48},{355,967}},["scroll-text"]={16898613699,{48,48},{967,759}},["toggle-right"]={16898613869,{48,48},{820,98}},["ferris-wheel"]={16898613353,{48,48},{49,820}},["camera-off"]={16898612819,{48,48},{306,967}},["function-square"]={16898613353,{48,48},{453,967}},group={16898613509,{48,48},{820,306}},codesandbox={16898613044,{48,48},{257,967}},["message-circle-question"]={16898613613,{48,48},{869,514}},["tent-tree"]={16898613869,{48,48},{771,49}},["rectangle-horizontal"]={16898613699,{48,48},{196,820}},subtitles={16898613777,{48,48},{771,857}},mail={16898613613,{48,48},{820,0}},["brain-cog"]={16898612819,{48,48},{0,967}},["hand-platter"]={16898613509,{48,48},{612,771}},club={16898613044,{48,48},{771,453}},twitch={16898613869,{48,48},{49,918}},pipette={16898613699,{48,48},{869,49}},user={16898613869,{48,48},{661,869}},["align-vertical-space-around"]={16898612629,{48,48},{869,306}},["test-tubes"]={16898613869,{48,48},{820,514}},wheat={16898613869,{48,48},{453,967}},["axis-3d"]={16898612629,{48,48},{820,759}},folders={16898613353,{48,48},{967,661}},diff={16898613044,{48,48},{869,759}},puzzle={16898613699,{48,48},{49,918}},["package-2"]={16898613613,{48,48},{869,710}},indent={16898613509,{48,48},{771,710}},tangent={16898613869,{48,48},{771,514}},["power-circle"]={16898613699,{48,48},{967,0}},["badge-pound-sterling"]={16898612629,{48,48},{869,759}},["mail-minus"]={16898613509,{48,48},{967,955}},["circle-slash"]={16898613044,{48,48},{98,771}},["app-window"]={16898612629,{48,48},{612,820}},["move-down-right"]={16898613613,{48,48},{820,196}},["parking-square-off"]={16898613613,{48,48},{869,955}},["clipboard-pen"]={16898613044,{48,48},{869,49}},["notepad-text"]={16898613613,{48,48},{147,918}},["signal-low"]={16898613777,{48,48},{612,771}},home={16898613509,{48,48},{820,147}},list={16898613509,{48,48},{869,808}},plus={16898613699,{48,48},{257,918}},["square-arrow-right"]={16898613777,{48,48},{918,563}},["scissors-square-dashed-bottom"]={16898613699,{48,48},{918,759}},["remove-formatting"]={16898613699,{48,48},{967,563}},["bookmark-check"]={16898612819,{48,48},{771,661}},["send-horizontal"]={16898613699,{48,48},{869,906}},["chevrons-left-right"]={16898612819,{48,48},{196,967}},["folder-kanban"]={16898613353,{48,48},{404,918}},["a-arrow-up"]={16898612629,{48,48},{0,771}},["list-restart"]={16898613509,{48,48},{967,196}},["cloud-moon"]={16898613044,{48,48},{820,147}},["book-audio"]={16898612819,{48,48},{771,612}},["vibrate-off"]={16898613869,{48,48},{869,453}},["mail-check"]={16898613509,{48,48},{918,955}},["panel-top-inactive"]={16898613613,{48,48},{967,759}},["file-type-2"]={16898613353,{48,48},{820,404}},["file-code"]={16898613353,{48,48},{869,49}},donut={16898613044,{48,48},{771,906}},["list-todo"]={16898613509,{48,48},{967,453}},dna={16898613044,{48,48},{967,710}},["monitor-down"]={16898613613,{48,48},{98,869}},["cassette-tape"]={16898612819,{48,48},{918,404}},["battery-low"]={16898612629,{48,48},{918,857}},flashlight={16898613353,{48,48},{869,404}},wine={16898613869,{48,48},{710,967}},signpost={16898613777,{48,48},{820,98}},["creative-commons"]={16898613044,{48,48},{147,918}},["globe-2"]={16898613509,{48,48},{257,820}},landmark={16898613509,{48,48},{771,759}},["map-pin"]={16898613613,{48,48},{820,257}},["clipboard-x"]={16898613044,{48,48},{98,820}},loader={16898613509,{48,48},{710,967}},bold={16898612819,{48,48},{355,771}},["dice-2"]={16898613044,{48,48},{967,404}},["file-type"]={16898613353,{48,48},{771,453}},utensils={16898613869,{48,48},{869,196}},beer={16898612819,{48,48},{257,771}},["file-video-2"]={16898613353,{48,48},{404,820}},["chef-hat"]={16898612819,{48,48},{661,918}},rocket={16898613699,{48,48},{918,147}},bird={16898612819,{48,48},{869,0}},["file-x"]={16898613353,{48,48},{869,612}},["move-diagonal"]={16898613613,{48,48},{918,98}},["folder-minus"]={16898613353,{48,48},{918,661}},["door-closed"]={16898613044,{48,48},{710,967}},["bluetooth-connected"]={16898612819,{48,48},{0,869}},["layout-template"]={16898613509,{48,48},{355,967}},["air-vent"]={16898612629,{48,48},{820,0}},["rows-2"]={16898613699,{48,48},{967,612}},["pen-square"]={16898613699,{48,48},{514,771}},["panel-bottom-close"]={16898613613,{48,48},{967,661}},["hand-heart"]={16898613509,{48,48},{869,514}},["file-code-2"]={16898613353,{48,48},{918,0}},["arrow-down-wide-narrow"]={16898612629,{48,48},{563,918}},["clock-10"]={16898613044,{48,48},{918,257}},drumstick={16898613044,{48,48},{869,955}},["disc-2"]={16898613044,{48,48},{820,808}},["skip-forward"]={16898613777,{48,48},{98,820}},skull={16898613777,{48,48},{49,869}},["chevron-left"]={16898612819,{48,48},{404,967}},["split-square-vertical"]={16898613777,{48,48},{49,918}},snowflake={16898613777,{48,48},{771,661}},key={16898613509,{48,48},{869,404}},["clock-11"]={16898613044,{48,48},{869,306}},["sliders-horizontal"]={16898613777,{48,48},{820,355}},["ticket-plus"]={16898613869,{48,48},{869,514}},["square-dashed-bottom"]={16898613777,{48,48},{147,869}},["mic-vocal"]={16898613613,{48,48},{869,563}},["activity-square"]={16898612629,{48,48},{771,514}},["monitor-pause"]={16898613613,{48,48},{0,967}},["book-open-check"]={16898612819,{48,48},{918,257}},projector={16898613699,{48,48},{147,820}},["lasso-select"]={16898613509,{48,48},{967,98}},["folder-open-dot"]={16898613353,{48,48},{869,710}},["align-justify"]={16898612629,{48,48},{563,820}},["log-in"]={16898613509,{48,48},{869,906}},tag={16898613777,{48,48},{967,906}},bus={16898612819,{48,48},{820,661}},["locate-fixed"]={16898613509,{48,48},{967,759}},["bed-single"]={16898612629,{48,48},{967,955}},["dice-4"]={16898613044,{48,48},{453,918}},["file-spreadsheet"]={16898613353,{48,48},{49,918}},["sun-dim"]={16898613777,{48,48},{710,918}},["clipboard-list"]={16898613044,{48,48},{612,771}},gamepad={16898613353,{48,48},{967,759}},["contact-round"]={16898613044,{48,48},{98,918}},["align-horizontal-space-around"]={16898612629,{48,48},{771,612}},["music-2"]={16898613613,{48,48},{404,869}},["hard-hat"]={16898613509,{48,48},{771,147}},["file-badge"]={16898613353,{48,48},{257,869}},["battery-warning"]={16898612629,{48,48},{820,955}},rows={16898613699,{48,48},{820,759}},["arrow-down-from-line"]={16898612629,{48,48},{404,820}},["rows-4"]={16898613699,{48,48},{869,710}},biohazard={16898612819,{48,48},{514,820}},["book-up"]={16898612819,{48,48},{257,918}},["heading-6"]={16898613509,{48,48},{404,771}},["scale-3d"]={16898613699,{48,48},{453,918}},["chevron-down-circle"]={16898612819,{48,48},{967,147}},["mail-x"]={16898613613,{48,48},{514,771}},["square-dashed-mouse-pointer"]={16898613777,{48,48},{49,967}},["user-cog"]={16898613869,{48,48},{147,869}},["satellite-dish"]={16898613699,{48,48},{196,918}},["alarm-clock-minus"]={16898612629,{48,48},{820,257}},pizza={16898613699,{48,48},{820,98}},["pc-case"]={16898613699,{48,48},{257,771}},["move-down-left"]={16898613613,{48,48},{869,147}},school={16898613699,{48,48},{453,967}},orbit={16898613613,{48,48},{967,612}},["file-minus"]={16898613353,{48,48},{820,612}},["rotate-ccw"]={16898613699,{48,48},{967,355}},["align-horizontal-justify-center"]={16898612629,{48,48},{257,869}},["phone-incoming"]={16898613699,{48,48},{820,49}},antenna={16898612629,{48,48},{869,563}},["memory-stick"]={16898613613,{48,48},{771,98}},["scan-eye"]={16898613699,{48,48},{869,759}},["align-center-vertical"]={16898612629,{48,48},{49,820}},["square-check"]={16898613777,{48,48},{563,918}},["align-end-horizontal"]={16898612629,{48,48},{869,257}},["message-square-off"]={16898613613,{48,48},{98,820}},["folder-open"]={16898613353,{48,48},{820,759}},["contact-2"]={16898613044,{48,48},{147,869}},["parking-circle"]={16898613613,{48,48},{967,857}},["menu-square"]={16898613613,{48,48},{98,771}},["hand-coins"]={16898613509,{48,48},{257,869}},["message-circle-code"]={16898613613,{48,48},{869,257}},["arrow-up-wide-narrow"]={16898612629,{48,48},{147,918}},["copy-x"]={16898613044,{48,48},{967,563}},clock={16898613044,{48,48},{771,661}},["file-pen"]={16898613353,{48,48},{563,869}},["git-compare-arrows"]={16898613353,{48,48},{918,955}},["square-arrow-down-right"]={16898613777,{48,48},{771,453}},joystick={16898613509,{48,48},{196,820}},["align-vertical-space-between"]={16898612629,{48,48},{820,355}},["file-pie-chart"]={16898613353,{48,48},{514,918}},gem={16898613353,{48,48},{918,857}},["calendar-plus"]={16898612819,{48,48},{918,355}},["bell-electric"]={16898612819,{48,48},{514,771}},["arrow-down-z-a"]={16898612629,{48,48},{514,967}},bath={16898612629,{48,48},{820,906}},anvil={16898612629,{48,48},{820,612}},["unlink-2"]={16898613869,{48,48},{918,563}},["archive-restore"]={16898612629,{48,48},{514,918}},archive={16898612629,{48,48},{918,49}},["folder-check"]={16898613353,{48,48},{563,967}},["arrow-big-left-dash"]={16898612629,{48,48},{147,820}},["book-key"]={16898612819,{48,48},{147,771}},ribbon={16898613699,{48,48},{967,98}},["package-open"]={16898613613,{48,48},{710,869}},["arrow-down-0-1"]={16898612629,{48,48},{869,355}},["library-big"]={16898613509,{48,48},{820,759}},["file-json"]={16898613353,{48,48},{771,404}},["arrow-down-a-z"]={16898612629,{48,48},{771,453}},["arrow-down-left"]={16898612629,{48,48},{257,967}},["square-scissors"]={16898613777,{48,48},{147,918}},["move-up-left"]={16898613613,{48,48},{967,306}},["arrow-down-up"]={16898612629,{48,48},{612,869}},["folder-heart"]={16898613353,{48,48},{869,453}},["gauge-circle"]={16898613353,{48,48},{820,906}},percent={16898613699,{48,48},{771,563}},["arrow-up-1-0"]={16898612629,{48,48},{355,918}},["arrow-up-a-z"]={16898612629,{48,48},{306,967}},["circle-arrow-right"]={16898612819,{48,48},{820,955}},["panel-bottom-inactive"]={16898613613,{48,48},{869,759}},["arrow-up"]={16898612629,{48,48},{967,355}},asterisk={16898612629,{48,48},{869,453}},["gallery-vertical"]={16898613353,{48,48},{771,906}},["swatch-book"]={16898613777,{48,48},{869,808}},["receipt-cent"]={16898613699,{48,48},{771,710}},["audio-lines"]={16898612629,{48,48},{355,967}},["folder-archive"]={16898613353,{48,48},{612,918}},["folder-symlink"]={16898613353,{48,48},{196,918}},["columns-3"]={16898613044,{48,48},{771,710}},ban={16898612629,{48,48},{196,967}},["message-square-x"]={16898613613,{48,48},{404,771}},["paint-roller"]={16898613613,{48,48},{147,967}},["folder-search-2"]={16898613353,{48,48},{967,147}},fan={16898613353,{48,48},{869,0}},["badge-euro"]={16898612629,{48,48},{196,918}},["badge-info"]={16898612629,{48,48},{918,453}},["building-2"]={16898612819,{48,48},{967,514}},square={16898613777,{48,48},{869,710}},medal={16898613613,{48,48},{563,771}},cake={16898612819,{48,48},{612,869}},["cloud-rain"]={16898613044,{48,48},{147,820}},["maximize-2"]={16898613613,{48,48},{820,514}},shell={16898613777,{48,48},{771,49}},wrench={16898613869,{48,48},{820,906}},badge={16898612629,{48,48},{661,967}},codepen={16898613044,{48,48},{306,918}},["corner-right-down"]={16898613044,{48,48},{563,967}},["flag-triangle-right"]={16898613353,{48,48},{147,869}},network={16898613613,{48,48},{710,820}},["bar-chart-3"]={16898612629,{48,48},{918,759}},bell={16898612819,{48,48},{820,257}},["bar-chart"]={16898612629,{48,48},{967,759}},ratio={16898613699,{48,48},{820,661}},["square-chevron-up"]={16898613777,{48,48},{869,147}},["brick-wall"]={16898612819,{48,48},{918,306}},["user-check"]={16898613869,{48,48},{918,98}},proportions={16898613699,{48,48},{98,869}},["alert-octagon"]={16898612629,{48,48},{820,49}},plane={16898613699,{48,48},{98,820}},["webhook-off"]={16898613869,{48,48},{661,967}},["thermometer-sun"]={16898613869,{48,48},{0,869}},["square-arrow-left"]={16898613777,{48,48},{404,820}},["mouse-pointer"]={16898613613,{48,48},{612,869}},heart={16898613509,{48,48},{661,771}},["test-tube-diagonal"]={16898613869,{48,48},{306,771}},["briefcase-medical"]={16898612819,{48,48},{820,404}},["align-vertical-distribute-start"]={16898612629,{48,48},{98,820}},mailbox={16898613613,{48,48},{771,49}},["bell-off"]={16898612819,{48,48},{771,49}},binary={16898612819,{48,48},{563,771}},["book-open-text"]={16898612819,{48,48},{869,306}},split={16898613777,{48,48},{0,967}},twitter={16898613869,{48,48},{0,967}},calculator={16898612819,{48,48},{563,918}},forklift={16898613353,{48,48},{869,759}},bluetooth={16898612819,{48,48},{771,355}},folder={16898613353,{48,48},{404,967}},["square-kanban"]={16898613777,{48,48},{404,869}},["message-square-diff"]={16898613613,{48,48},{869,49}},["square-sigma"]={16898613777,{48,48},{98,967}},["alarm-plus"]={16898612629,{48,48},{771,563}},star={16898613777,{48,48},{967,147}},["rotate-ccw-square"]={16898613699,{48,48},{98,967}},castle={16898612819,{48,48},{453,869}},["book-down"]={16898612819,{48,48},{918,0}},["file-volume-2"]={16898613353,{48,48},{306,918}},["book-headphones"]={16898612819,{48,48},{869,49}},power={16898613699,{48,48},{820,147}},album={16898612629,{48,48},{514,820}},["book-marked"]={16898612819,{48,48},{49,869}},["book-open"]={16898612819,{48,48},{820,355}},["file-box"]={16898613353,{48,48},{771,612}},["book-text"]={16898612819,{48,48},{404,771}},telescope={16898613869,{48,48},{820,0}},["glass-water"]={16898613509,{48,48},{771,306}},filter={16898613353,{48,48},{612,869}},glasses={16898613509,{48,48},{306,771}},["piggy-bank"]={16898613699,{48,48},{820,563}},["book-type"]={16898612819,{48,48},{355,820}},cuboid={16898613044,{48,48},{355,967}},["cloud-off"]={16898613044,{48,48},{771,196}},["check-check"]={16898612819,{48,48},{967,612}},activity={16898612629,{48,48},{514,771}},axe={16898612629,{48,48},{869,710}},["plane-takeoff"]={16898613699,{48,48},{147,771}},["book-x"]={16898612819,{48,48},{869,563}},["cloud-rain-wind"]={16898613044,{48,48},{196,771}},bookmark={16898612819,{48,48},{514,918}},["zoom-in"]={16898613869,{48,48},{869,955}},["square-pilcrow"]={16898613777,{48,48},{563,967}},["file-axis-3d"]={16898613353,{48,48},{355,771}},["receipt-euro"]={16898613699,{48,48},{710,771}},["brain-circuit"]={16898612819,{48,48},{49,918}},["briefcase-business"]={16898612819,{48,48},{869,355}},["bug-play"]={16898612819,{48,48},{306,918}},["tally-3"]={16898613869,{48,48},{0,771}},["clipboard-type"]={16898613044,{48,48},{147,771}},brush={16898612819,{48,48},{404,820}},["tally-5"]={16898613869,{48,48},{257,771}},["cable-car"]={16898612819,{48,48},{771,710}},cable={16898612819,{48,48},{710,771}},["calendar-check"]={16898612819,{48,48},{967,49}},["user-square-2"]={16898613869,{48,48},{869,661}},["calendar-minus"]={16898612819,{48,48},{98,918}},["calendar-plus-2"]={16898612819,{48,48},{967,306}},linkedin={16898613509,{48,48},{453,918}},["life-buoy"]={16898613509,{48,48},{661,918}},["calendar-search"]={16898612819,{48,48},{820,453}},["circle-chevron-down"]={16898612819,{48,48},{967,906}},["volume-2"]={16898613869,{48,48},{771,808}},["battery-charging"]={16898612629,{48,48},{771,955}},["russian-ruble"]={16898613699,{48,48},{661,918}},["square-arrow-up-left"]={16898613777,{48,48},{869,612}},["earth-lock"]={16898613353,{48,48},{771,0}},footprints={16898613353,{48,48},{918,710}},hash={16898613509,{48,48},{147,771}},building={16898612819,{48,48},{918,563}},ear={16898613044,{48,48},{967,955}},caravan={16898612819,{48,48},{869,196}},carrot={16898612819,{48,48},{196,869}},cherry={16898612819,{48,48},{612,967}},["user-check-2"]={16898613869,{48,48},{967,49}},["shield-plus"]={16898613777,{48,48},{771,563}},moon={16898613613,{48,48},{306,918}},["bell-minus"]={16898612819,{48,48},{820,0}},["image-up"]={16898613509,{48,48},{355,869}},["case-sensitive"]={16898612819,{48,48},{98,967}},drum={16898613044,{48,48},{918,906}},["arrow-up-z-a"]={16898612629,{48,48},{98,967}},sun={16898613777,{48,48},{967,453}},["gantt-chart-square"]={16898613353,{48,48},{918,808}},["align-horizontal-justify-start"]={16898612629,{48,48},{820,563}},["file-key"]={16898613353,{48,48},{355,820}},["monitor-smartphone"]={16898613613,{48,48},{918,306}},["move-3d"]={16898613613,{48,48},{514,967}},["scissors-line-dashed"]={16898613699,{48,48},{967,710}},["text-select"]={16898613869,{48,48},{820,49}},["case-lower"]={16898612819,{48,48},{147,918}},["plus-circle"]={16898613699,{48,48},{355,820}},["ticket-check"]={16898613869,{48,48},{355,771}},pyramid={16898613699,{48,48},{0,967}},["chevron-last"]={16898612819,{48,48},{967,404}},["user-cog-2"]={16898613869,{48,48},{196,820}},["refresh-cw-off"]={16898613699,{48,48},{453,820}},piano={16898613699,{48,48},{771,355}},["picture-in-picture-2"]={16898613699,{48,48},{306,820}},["user-round"]={16898613869,{48,48},{967,563}},["flower-2"]={16898613353,{48,48},{869,661}},["chevron-up-square"]={16898612819,{48,48},{771,857}},["chevrons-left"]={16898612819,{48,48},{967,453}},["chevrons-right-left"]={16898612819,{48,48},{453,967}},car={16898612819,{48,48},{918,147}},["keyboard-music"]={16898613509,{48,48},{820,453}},["star-half"]={16898613777,{48,48},{661,918}},mouse={16898613613,{48,48},{563,918}},lock={16898613509,{48,48},{918,857}},["pencil-line"]={16898613699,{48,48},{49,771}},mails={16898613613,{48,48},{49,771}},film={16898613353,{48,48},{710,771}},tablet={16898613777,{48,48},{918,906}},["circle-arrow-left"]={16898612819,{48,48},{820,906}},pi={16898613699,{48,48},{820,306}},trash={16898613869,{48,48},{918,514}},dock={16898613044,{48,48},{918,759}},["hdmi-port"]={16898613509,{48,48},{49,869}},["circle-arrow-out-up-left"]={16898612819,{48,48},{918,857}},["case-upper"]={16898612819,{48,48},{967,355}},["circle-arrow-out-up-right"]={16898612819,{48,48},{869,906}},tags={16898613777,{48,48},{918,955}},croissant={16898613044,{48,48},{967,355}},["circle-check"]={16898612819,{48,48},{869,955}},bomb={16898612819,{48,48},{257,869}},diameter={16898613044,{48,48},{967,147}},["circle-dashed"]={16898613044,{48,48},{0,771}},["bar-chart-big"]={16898612629,{48,48},{820,857}},["upload-cloud"]={16898613869,{48,48},{661,820}},["code-xml"]={16898613044,{48,48},{404,820}},divide={16898613044,{48,48},{967,453}},grape={16898613509,{48,48},{820,49}},["play-square"]={16898613699,{48,48},{0,918}},["party-popper"]={16898613613,{48,48},{918,955}},["circle-ellipsis"]={16898613044,{48,48},{820,0}},file={16898613353,{48,48},{820,661}},["user-circle-2"]={16898613869,{48,48},{869,147}},truck={16898613869,{48,48},{771,196}},["cloud-sun-rain"]={16898613044,{48,48},{49,918}},["calendar-range"]={16898612819,{48,48},{869,404}},contact={16898613044,{48,48},{49,967}},["zap-off"]={16898613869,{48,48},{967,857}},["square-check-big"]={16898613777,{48,48},{612,869}},["circle-user"]={16898613044,{48,48},{869,257}},["layout-panel-top"]={16898613509,{48,48},{404,918}},["roller-coaster"]={16898613699,{48,48},{196,869}},["laptop-minimal"]={16898613509,{48,48},{612,918}},["table-properties"]={16898613777,{48,48},{918,857}},["clipboard-check"]={16898613044,{48,48},{869,514}},layout={16898613509,{48,48},{967,612}},["indent-decrease"]={16898613509,{48,48},{869,612}},cookie={16898613044,{48,48},{869,404}},["message-square-more"]={16898613613,{48,48},{147,771}},clipboard={16898613044,{48,48},{49,869}},euro={16898613353,{48,48},{771,306}},sparkles={16898613777,{48,48},{918,49}},["heart-off"]={16898613509,{48,48},{820,612}},vibrate={16898613869,{48,48},{453,869}},["clock-3"]={16898613044,{48,48},{404,771}},["move-horizontal"]={16898613613,{48,48},{147,869}},["file-sliders"]={16898613353,{48,48},{98,869}},frown={16898613353,{48,48},{967,196}},["move-up-right"]={16898613613,{48,48},{918,355}},["cup-soda"]={16898613044,{48,48},{967,612}},["stretch-vertical"]={16898613777,{48,48},{918,710}},["refresh-cw"]={16898613699,{48,48},{404,869}},sword={16898613777,{48,48},{710,967}},["cloud-drizzle"]={16898613044,{48,48},{563,869}},["laptop-2"]={16898613509,{48,48},{661,869}},earth={16898613353,{48,48},{0,771}},slice={16898613777,{48,48},{869,306}},["land-plot"]={16898613509,{48,48},{820,710}},milk={16898613613,{48,48},{514,918}},["git-pull-request-draft"]={16898613509,{48,48},{771,49}},crown={16898613044,{48,48},{404,918}},["wallet-2"]={16898613869,{48,48},{967,147}},settings={16898613777,{48,48},{771,257}},["rotate-cw-square"]={16898613699,{48,48},{918,404}},atom={16898612629,{48,48},{404,918}},["package-x"]={16898613613,{48,48},{967,147}},["bed-double"]={16898612629,{48,48},{918,955}},["ice-cream-bowl"]={16898613509,{48,48},{967,257}},["circle-dot"]={16898613044,{48,48},{514,771}},["grip-horizontal"]={16898613509,{48,48},{49,820}},cloudy={16898613044,{48,48},{869,355}},["text-cursor-input"]={16898613869,{48,48},{771,563}},["folder-git-2"]={16898613353,{48,48},{967,355}},["message-square-code"]={16898613613,{48,48},{514,869}},clover={16898613044,{48,48},{820,404}},["arrow-down-narrow-wide"]={16898612629,{48,48},{967,514}},code={16898613044,{48,48},{355,869}},["user-x"]={16898613869,{48,48},{710,820}},coins={16898613044,{48,48},{869,612}},dumbbell={16898613044,{48,48},{967,906}},weight={16898613869,{48,48},{196,967}},["alert-triangle"]={16898612629,{48,48},{771,98}},expand={16898613353,{48,48},{306,771}},scale={16898613699,{48,48},{404,967}},component={16898613044,{48,48},{967,49}},["flashlight-off"]={16898613353,{48,48},{918,355}},["panel-top-open"]={16898613613,{48,48},{918,808}},computer={16898613044,{48,48},{918,98}},construction={16898613044,{48,48},{196,820}},notebook={16898613613,{48,48},{869,196}},["power-square"]={16898613699,{48,48},{869,98}},["copy-slash"]={16898613044,{48,48},{306,967}},["square-menu"]={16898613777,{48,48},{967,563}},["circle-play"]={16898613044,{48,48},{514,820}},wallet={16898613869,{48,48},{147,967}},laptop={16898613509,{48,48},{563,967}},["scan-line"]={16898613699,{48,48},{771,857}},["clock-4"]={16898613044,{48,48},{355,820}},["square-arrow-up"]={16898613777,{48,48},{771,710}},copyright={16898613044,{48,48},{820,710}},["chevron-down"]={16898612819,{48,48},{196,918}},["unlock-keyhole"]={16898613869,{48,48},{820,661}},["clock-1"]={16898613044,{48,48},{0,918}},["align-horizontal-distribute-start"]={16898612629,{48,48},{306,820}},["arrow-down-to-line"]={16898612629,{48,48},{661,820}},["mouse-pointer-2"]={16898613613,{48,48},{820,661}},["refresh-ccw"]={16898613699,{48,48},{820,453}},["venetian-mask"]={16898613869,{48,48},{918,404}},["calendar-check-2"]={16898612819,{48,48},{514,967}},["arrow-down-square"]={16898612629,{48,48},{771,710}},spline={16898613777,{48,48},{147,820}},banana={16898612629,{48,48},{967,453}},["git-pull-request-create-arrow"]={16898613509,{48,48},{514,771}},crosshair={16898613044,{48,48},{453,869}},["list-video"]={16898613509,{48,48},{967,710}},["arrow-right-left"]={16898612629,{48,48},{918,355}},["bar-chart-4"]={16898612629,{48,48},{869,808}},["dice-3"]={16898613044,{48,48},{918,453}},["dice-5"]={16898613044,{48,48},{404,967}},["dice-6"]={16898613044,{48,48},{967,661}},["square-plus"]={16898613777,{48,48},{918,147}},["timer-off"]={16898613869,{48,48},{563,820}},["arrow-big-right-dash"]={16898612629,{48,48},{49,918}},["radio-receiver"]={16898613699,{48,48},{404,820}},shield={16898613777,{48,48},{869,0}},["square-equal"]={16898613777,{48,48},{869,404}},backpack={16898612629,{48,48},{710,869}},download={16898613044,{48,48},{820,906}},["drafting-compass"]={16898613044,{48,48},{771,955}},youtube={16898613869,{48,48},{820,955}},["file-plus-2"]={16898613353,{48,48},{967,0}},["message-circle-more"]={16898613613,{48,48},{355,771}},["arrow-down-right"]={16898612629,{48,48},{820,661}},["loader-circle"]={16898613509,{48,48},{771,906}},receipt={16898613699,{48,48},{869,147}},["egg-off"]={16898613353,{48,48},{771,514}},bitcoin={16898612819,{48,48},{820,49}},["eye-off"]={16898613353,{48,48},{820,514}},factory={16898613353,{48,48},{514,820}},["fast-forward"]={16898613353,{48,48},{820,49}},["image-off"]={16898613509,{48,48},{453,771}},["file-audio-2"]={16898613353,{48,48},{820,306}},braces={16898612819,{48,48},{147,820}},cone={16898613044,{48,48},{820,196}},["wand-sparkles"]={16898613869,{48,48},{453,918}},["square-chevron-right"]={16898613777,{48,48},{918,98}},navigation={16898613613,{48,48},{771,759}},["file-check"]={16898613353,{48,48},{563,820}},["file-cog"]={16898613353,{48,48},{820,98}},["file-diff"]={16898613353,{48,48},{771,147}},["file-digit"]={16898613353,{48,48},{147,771}},["power-off"]={16898613699,{48,48},{918,49}},["align-vertical-distribute-center"]={16898612629,{48,48},{771,147}},["tally-1"]={16898613777,{48,48},{967,955}},ampersand={16898612629,{48,48},{404,771}},["line-chart"]={16898613509,{48,48},{196,918}},["shopping-cart"]={16898613777,{48,48},{869,257}},["align-vertical-justify-end"]={16898612629,{48,48},{0,918}},eraser={16898613353,{48,48},{820,257}},["alarm-smoke"]={16898612629,{48,48},{563,771}},["file-line-chart"]={16898613353,{48,48},{306,869}},["file-input"]={16898613353,{48,48},{869,306}},["clock-8"]={16898613044,{48,48},{869,563}},["server-cog"]={16898613699,{48,48},{967,906}},["cloud-cog"]={16898613044,{48,48},{661,771}},blend={16898612819,{48,48},{771,98}},["search-x"]={16898613699,{48,48},{967,808}},["radio-tower"]={16898613699,{48,48},{355,869}},["list-tree"]={16898613509,{48,48},{453,967}},droplet={16898613044,{48,48},{820,955}},heater={16898613509,{48,48},{612,820}},eye={16898613353,{48,48},{771,563}},battery={16898612629,{48,48},{967,857}},lamp={16898613509,{48,48},{869,661}},["link-2-off"]={16898613509,{48,48},{147,967}},["panel-top"]={16898613613,{48,48},{869,857}},["file-volume"]={16898613353,{48,48},{257,967}},["file-x-2"]={16898613353,{48,48},{918,563}},["circle-equal"]={16898613044,{48,48},{771,49}},["flag-triangle-left"]={16898613353,{48,48},{196,820}},flower={16898613353,{48,48},{820,710}},["fold-horizontal"]={16898613353,{48,48},{710,820}},["folder-closed"]={16898613353,{48,48},{918,147}},["folder-dot"]={16898613353,{48,48},{196,869}},["arrow-up-right"]={16898612629,{48,48},{918,147}},router={16898613699,{48,48},{355,967}},["leafy-green"]={16898613509,{48,48},{869,710}},["message-square-dot"]={16898613613,{48,48},{820,98}},focus={16898613353,{48,48},{771,759}},copyleft={16898613044,{48,48},{869,661}},["folder-x"]={16898613353,{48,48},{453,918}},["form-input"]={16898613353,{48,48},{820,808}},["minimize-2"]={16898613613,{48,48},{967,0}},regex={16898613699,{48,48},{306,967}},["gallery-horizontal"]={16898613353,{48,48},{918,759}},university={16898613869,{48,48},{967,514}},["gallery-vertical-end"]={16898613353,{48,48},{820,857}},["file-image"]={16898613353,{48,48},{918,257}},["at-sign"]={16898612629,{48,48},{453,869}},palette={16898613613,{48,48},{453,918}},["user-plus-2"]={16898613869,{48,48},{967,306}},["gallery-thumbnails"]={16898613353,{48,48},{869,808}},["arrow-down-right-from-circle"]={16898612629,{48,48},{918,563}},cpu={16898613044,{48,48},{196,869}},["split-square-horizontal"]={16898613777,{48,48},{98,869}},["thumbs-down"]={16898613869,{48,48},{820,306}},merge={16898613613,{48,48},{0,869}},ghost={16898613353,{48,48},{869,906}},["git-compare"]={16898613353,{48,48},{967,955}},["git-fork"]={16898613509,{48,48},{771,0}},hospital={16898613509,{48,48},{147,820}},["git-merge"]={16898613509,{48,48},{771,257}},["folder-edit"]={16898613353,{48,48},{98,967}},["thumbs-up"]={16898613869,{48,48},{771,355}},globe={16898613509,{48,48},{771,563}},palmtree={16898613613,{48,48},{404,967}},["bug-off"]={16898612819,{48,48},{355,869}},kanban={16898613509,{48,48},{49,967}},["thermometer-snowflake"]={16898613869,{48,48},{49,820}},apple={16898612629,{48,48},{563,869}},["wine-off"]={16898613869,{48,48},{771,906}},["graduation-cap"]={16898613509,{48,48},{869,0}},["hand-helping"]={16898613509,{48,48},{820,563}},hand={16898613509,{48,48},{563,820}},["square-bottom-dashed-scissors"]={16898613777,{48,48},{661,820}},stamp={16898613777,{48,48},{710,869}},["candy-off"]={16898612819,{48,48},{820,710}},["plug-zap-2"]={16898613699,{48,48},{820,355}},["heading-2"]={16898613509,{48,48},{918,257}},["square-activity"]={16898613777,{48,48},{869,355}},["circle-gauge"]={16898613044,{48,48},{0,820}},["cigarette-off"]={16898612819,{48,48},{710,967}},["arrow-up-0-1"]={16898612629,{48,48},{404,869}},["message-circle"]={16898613613,{48,48},{563,820}},["undo-2"]={16898613869,{48,48},{771,453}},headset={16898613509,{48,48},{257,918}},["heart-crack"]={16898613509,{48,48},{918,514}},["git-branch"]={16898613353,{48,48},{918,906}},shovel={16898613777,{48,48},{820,306}},share={16898613777,{48,48},{514,771}},["wallet-cards"]={16898613869,{48,48},{918,196}},["square-arrow-out-down-right"]={16898613777,{48,48},{306,918}},grip={16898613509,{48,48},{869,257}},["monitor-speaker"]={16898613613,{48,48},{869,355}},save={16898613699,{48,48},{918,453}},["cloud-snow"]={16898613044,{48,48},{98,869}},["file-question"]={16898613353,{48,48},{869,98}},["arrow-big-up-dash"]={16898612629,{48,48},{967,257}},coffee={16898613044,{48,48},{967,514}},["image-down"]={16898613509,{48,48},{820,404}},["beer-off"]={16898612819,{48,48},{771,257}},["file-bar-chart"]={16898613353,{48,48},{820,563}},["bar-chart-2"]={16898612629,{48,48},{967,710}},["lock-keyhole-open"]={16898613509,{48,48},{820,906}},["chevrons-down-up"]={16898612819,{48,48},{661,967}},["clipboard-plus"]={16898613044,{48,48},{820,98}},["monitor-up"]={16898613613,{48,48},{771,453}},["list-end"]={16898613509,{48,48},{918,710}},["square-radical"]={16898613777,{48,48},{196,869}},play={16898613699,{48,48},{918,257}},["chevrons-right"]={16898612819,{48,48},{967,710}},["file-badge-2"]={16898613353,{48,48},{306,820}},["message-square-reply"]={16898613613,{48,48},{918,257}},["corner-down-right"]={16898613044,{48,48},{710,820}},phone={16898613699,{48,48},{0,869}},["arrow-left-to-line"]={16898612629,{48,48},{147,869}},["lamp-wall-down"]={16898613509,{48,48},{967,563}},["link-2"]={16898613509,{48,48},{967,404}},["repeat"]={16898613699,{48,48},{820,710}},["ellipsis-vertical"]={16898613353,{48,48},{820,0}},snail={16898613777,{48,48},{820,612}},["paint-bucket"]={16898613613,{48,48},{196,918}},["square-parking"]={16898613777,{48,48},{771,759}},["align-horizontal-justify-end"]={16898612629,{48,48},{869,514}},lasso={16898613509,{48,48},{918,147}},["align-vertical-distribute-end"]={16898612629,{48,48},{147,771}},soup={16898613777,{48,48},{612,820}},airplay={16898612629,{48,48},{771,49}},["layout-dashboard"]={16898613509,{48,48},{967,355}},["heading-1"]={16898613509,{48,48},{0,918}},["circle-x"]={16898613044,{48,48},{820,306}},["monitor-x"]={16898613613,{48,48},{453,771}},["octagon-pause"]={16898613613,{48,48},{869,453}},["library-square"]={16898613509,{48,48},{771,808}},["square-pen"]={16898613777,{48,48},{710,820}},["heart-pulse"]={16898613509,{48,48},{771,661}},["database-backup"]={16898613044,{48,48},{820,759}},["gantt-chart"]={16898613353,{48,48},{869,857}},octagon={16898613613,{48,48},{404,918}},ticket={16898613869,{48,48},{612,771}},["message-square"]={16898613613,{48,48},{355,820}},["list-filter"]={16898613509,{48,48},{869,759}},["train-front"]={16898613869,{48,48},{404,771}},["spray-can"]={16898613777,{48,48},{967,257}},["list-music"]={16898613509,{48,48},{771,857}},["utility-pole"]={16898613869,{48,48},{196,869}},["list-plus"]={16898613509,{48,48},{661,967}},["screen-share"]={16898613699,{48,48},{710,967}},["file-clock"]={16898613353,{48,48},{514,869}},["list-collapse"]={16898613509,{48,48},{967,661}},gauge={16898613353,{48,48},{771,955}},store={16898613777,{48,48},{404,967}},["circle-arrow-down"]={16898612819,{48,48},{869,857}},["notebook-pen"]={16898613613,{48,48},{563,967}},["egg-fried"]={16898613353,{48,48},{257,771}},["calendar-off"]={16898612819,{48,48},{49,967}},["locate-off"]={16898613509,{48,48},{918,808}},["corner-right-up"]={16898613044,{48,48},{967,98}},locate={16898613509,{48,48},{869,857}},["ticket-x"]={16898613869,{48,48},{771,612}},["user-round-plus"]={16898613869,{48,48},{404,869}},["panel-left-close"]={16898613613,{48,48},{710,918}},["lock-keyhole"]={16898613509,{48,48},{771,955}},["lock-open"]={16898613509,{48,48},{967,808}},["user-round-minus"]={16898613869,{48,48},{453,820}},["m-square"]={16898613509,{48,48},{869,955}},magnet={16898613509,{48,48},{967,906}},["message-square-text"]={16898613613,{48,48},{820,355}},["mail-plus"]={16898613613,{48,48},{0,771}},["mail-search"]={16898613613,{48,48},{257,771}},move={16898613613,{48,48},{453,820}},["play-circle"]={16898613699,{48,48},{49,869}},["git-commit-vertical"]={16898613353,{48,48},{967,906}},slash={16898613777,{48,48},{918,257}},["map-pin-off"]={16898613613,{48,48},{0,820}},aperture={16898612629,{48,48},{771,661}},["image-plus"]={16898613509,{48,48},{404,820}},["message-circle-heart"]={16898613613,{48,48},{771,355}},syringe={16898613777,{48,48},{918,808}},info={16898613509,{48,48},{612,869}},["rows-3"]={16898613699,{48,48},{918,661}},check={16898612819,{48,48},{710,869}},["text-search"]={16898613869,{48,48},{869,0}},["square-slash"]={16898613777,{48,48},{967,355}},sandwich={16898613699,{48,48},{918,196}},["settings-2"]={16898613777,{48,48},{0,771}},["file-stack"]={16898613353,{48,48},{0,967}},["external-link"]={16898613353,{48,48},{257,820}},["ice-cream-2"]={16898613509,{48,48},{0,967}},["file-archive"]={16898613353,{48,48},{869,257}},["signal-high"]={16898613777,{48,48},{771,612}},inbox={16898613509,{48,48},{918,563}},["flip-horizontal-2"]={16898613353,{48,48},{355,918}},["traffic-cone"]={16898613869,{48,48},{820,355}},["file-signature"]={16898613353,{48,48},{147,820}},["align-horizontal-space-between"]={16898612629,{48,48},{612,771}},["message-circle-dashed"]={16898613613,{48,48},{820,306}},maximize={16898613613,{48,48},{771,563}},["database-zap"]={16898613044,{48,48},{771,808}},droplets={16898613044,{48,48},{967,857}},["fish-symbol"]={16898613353,{48,48},{918,98}},["message-circle-off"]={16898613613,{48,48},{306,820}},["wheat-off"]={16898613869,{48,48},{967,453}},["layout-list"]={16898613509,{48,48},{869,453}},["file-search"]={16898613353,{48,48},{196,771}},["download-cloud"]={16898613044,{48,48},{869,857}},["alarm-clock-plus"]={16898612629,{48,48},{306,771}},["circle-dollar-sign"]={16898613044,{48,48},{257,771}},usb={16898613869,{48,48},{563,918}},["arrow-up-square"]={16898612629,{48,48},{869,196}},["receipt-pound-sterling"]={16898613699,{48,48},{563,918}},scan={16898613699,{48,48},{967,196}},["heading-5"]={16898613509,{48,48},{771,404}},undo={16898613869,{48,48},{404,820}},["file-search-2"]={16898613353,{48,48},{771,196}},minimize={16898613613,{48,48},{918,49}},["redo-2"]={16898613699,{48,48},{49,967}},thermometer={16898613869,{48,48},{869,257}},["filter-x"]={16898613353,{48,48},{661,820}},["sliders-vertical"]={16898613777,{48,48},{771,404}},["boom-box"]={16898612819,{48,48},{967,0}},["table-2"]={16898613777,{48,48},{869,857}},["touchpad-off"]={16898613869,{48,48},{98,820}},["diamond-percent"]={16898613044,{48,48},{918,196}},brain={16898612819,{48,48},{967,257}},microwave={16898613613,{48,48},{661,771}},["arrow-down-left-square"]={16898612629,{48,48},{306,918}},["user-round-cog"]={16898613869,{48,48},{820,453}},["octagon-x"]={16898613613,{48,48},{453,869}},languages={16898613509,{48,48},{710,820}},["file-json-2"]={16898613353,{48,48},{820,355}},["alarm-clock-check"]={16898612629,{48,48},{0,820}},guitar={16898613509,{48,48},{771,355}},anchor={16898612629,{48,48},{306,869}},["text-cursor"]={16898613869,{48,48},{563,771}},["search-code"]={16898613699,{48,48},{820,906}},["square-parking-off"]={16898613777,{48,48},{820,710}},["notebook-text"]={16898613613,{48,48},{918,147}},["arrow-right-to-line"]={16898612629,{48,48},{820,453}},["ticket-minus"]={16898613869,{48,48},{306,820}},["tally-4"]={16898613869,{48,48},{771,257}},heading={16898613509,{48,48},{355,820}},wallpaper={16898613869,{48,48},{967,404}},["door-open"]={16898613044,{48,48},{967,759}},["arrow-down-circle"]={16898612629,{48,48},{453,771}},["monitor-play"]={16898613613,{48,48},{967,257}},["key-square"]={16898613509,{48,48},{918,355}},["monitor-off"]={16898613613,{48,48},{49,918}},["pocket-knife"]={16898613699,{48,48},{918,514}},["book-copy"]={16898612819,{48,48},{563,820}},["panel-left-inactive"]={16898613613,{48,48},{967,196}},["car-front"]={16898612819,{48,48},{563,967}},["file-video"]={16898613353,{48,48},{355,869}},["reply-all"]={16898613699,{48,48},{661,869}},["cloud-moon-rain"]={16898613044,{48,48},{869,98}},["zoom-out"]={16898613869,{48,48},{967,906}},["search-slash"]={16898613699,{48,48},{771,955}},["notepad-text-dashed"]={16898613613,{48,48},{196,869}},["circle-alert"]={16898612819,{48,48},{918,808}},briefcase={16898612819,{48,48},{771,453}},["list-start"]={16898613509,{48,48},{196,967}},["more-vertical"]={16898613613,{48,48},{967,514}},["a-large-small"]={16898612629,{48,48},{771,257}},tractor={16898613869,{48,48},{869,306}},waves={16898613869,{48,48},{820,808}},["folder-cog"]={16898613353,{48,48},{869,196}},["code-2"]={16898613044,{48,48},{453,771}},["clock-5"]={16898613044,{48,48},{306,869}},vote={16898613869,{48,48},{612,967}},["shield-question"]={16898613777,{48,48},{563,771}},["arrow-right-from-line"]={16898612629,{48,48},{967,306}},["flame-kindling"]={16898613353,{48,48},{49,967}},["square-power"]={16898613777,{48,48},{869,196}},["circle-help"]={16898613044,{48,48},{820,257}},["bring-to-front"]={16898612819,{48,48},{453,771}},["move-right"]={16898613613,{48,48},{49,967}},figma={16898613353,{48,48},{0,869}},["bell-plus"]={16898612819,{48,48},{49,771}},sailboat={16898613699,{48,48},{612,967}},["hard-drive-upload"]={16898613509,{48,48},{869,49}},["pie-chart"]={16898613699,{48,48},{869,514}},meh={16898613613,{48,48},{820,49}},["mail-warning"]={16898613613,{48,48},{771,514}},["music-3"]={16898613613,{48,48},{355,918}},["pause-circle"]={16898613613,{48,48},{967,955}},["panels-right-bottom"]={16898613613,{48,48},{771,955}},["file-edit"]={16898613353,{48,48},{49,869}},redo={16898613699,{48,48},{918,355}},["file-lock"]={16898613353,{48,48},{918,514}},["square-user"]={16898613777,{48,48},{967,612}},["circle-fading-plus"]={16898613044,{48,48},{49,771}},workflow={16898613869,{48,48},{967,759}},["undo-dot"]={16898613869,{48,48},{453,771}},target={16898613869,{48,48},{514,771}},tablets={16898613777,{48,48},{869,955}},radar={16898613699,{48,48},{820,404}},drama={16898613044,{48,48},{967,808}},["signal-medium"]={16898613777,{48,48},{563,820}},baseline={16898612629,{48,48},{869,857}},martini={16898613613,{48,48},{257,820}},contrast={16898613044,{48,48},{918,355}},pickaxe={16898613699,{48,48},{355,771}},["square-divide"]={16898613777,{48,48},{967,306}},["chevron-left-circle"]={16898612819,{48,48},{918,453}},["book-check"]={16898612819,{48,48},{612,771}},["scan-barcode"]={16898613699,{48,48},{918,710}},["book-lock"]={16898612819,{48,48},{98,820}},["panel-right-inactive"]={16898613613,{48,48},{918,759}},refrigerator={16898613699,{48,48},{355,918}},["divide-circle"]={16898613044,{48,48},{967,196}},["package-plus"]={16898613613,{48,48},{661,918}},["mic-2"]={16898613613,{48,48},{257,918}},["hop-off"]={16898613509,{48,48},{771,196}},warehouse={16898613869,{48,48},{967,661}},["plus-square"]={16898613699,{48,48},{306,869}},["square-arrow-out-up-left"]={16898613777,{48,48},{257,967}},["save-all"]={16898613699,{48,48},{967,404}},candy={16898612819,{48,48},{771,759}},["iteration-ccw"]={16898613509,{48,48},{918,98}},["corner-left-down"]={16898613044,{48,48},{661,869}},paintbrush={16898613613,{48,48},{918,453}},["cloud-lightning"]={16898613044,{48,48},{918,49}},["circle-slash-2"]={16898613044,{48,48},{771,98}},["layers-3"]={16898613509,{48,48},{147,918}},["credit-card"]={16898613044,{48,48},{98,967}},["ear-off"]={16898613044,{48,48},{918,955}},["git-commit-horizontal"]={16898613353,{48,48},{869,955}},["panel-bottom"]={16898613613,{48,48},{771,857}},["square-code"]={16898613777,{48,48},{820,196}},["panel-bottom-open"]={16898613613,{48,48},{820,808}},["kanban-square-dashed"]={16898613509,{48,48},{147,869}},["circle-pause"]={16898613044,{48,48},{771,563}},["panel-top-close"]={16898613613,{48,48},{771,906}},ambulance={16898612629,{48,48},{771,404}},["trending-up"]={16898613869,{48,48},{514,918}},["bookmark-x"]={16898612819,{48,48},{563,869}},["clock-9"]={16898613044,{48,48},{820,612}},pen={16898613699,{48,48},{771,49}},["smartphone-nfc"]={16898613777,{48,48},{306,869}},["candy-cane"]={16898612819,{48,48},{869,661}},unlink={16898613869,{48,48},{869,612}},["parking-meter"]={16898613613,{48,48},{918,906}},["gamepad-2"]={16898613353,{48,48},{710,967}},["user-round-search"]={16898613869,{48,48},{355,918}},["parking-square"]={16898613613,{48,48},{967,906}},["paw-print"]={16898613699,{48,48},{771,257}},["arrow-down-right-square"]={16898612629,{48,48},{869,612}},["square-split-vertical"]={16898613777,{48,48},{869,453}},["circle-off"]={16898613044,{48,48},{306,771}},dessert={16898613044,{48,48},{612,967}},eclipse={16898613353,{48,48},{771,257}},squirrel={16898613777,{48,48},{771,808}},["percent-circle"]={16898613699,{48,48},{306,771}},cylinder={16898613044,{48,48},{869,710}},["badge-japanese-yen"]={16898612629,{48,48},{453,918}},["circle-divide"]={16898613044,{48,48},{771,257}},["receipt-text"]={16898613699,{48,48},{918,98}},["square-pi"]={16898613777,{48,48},{612,918}},["align-center-horizontal"]={16898612629,{48,48},{98,771}},["phone-off"]={16898613699,{48,48},{98,771}},["pi-square"]={16898613699,{48,48},{869,257}},["file-output"]={16898613353,{48,48},{661,771}},["disc-album"]={16898613044,{48,48},{710,918}},["percent-square"]={16898613699,{48,48},{820,514}},clapperboard={16898613044,{48,48},{257,869}},captions={16898612819,{48,48},{612,918}},["wallet-minimal"]={16898613869,{48,48},{196,918}},layers={16898613509,{48,48},{98,967}},["umbrella-off"]={16898613869,{48,48},{918,306}},["badge-alert"]={16898612629,{48,48},{661,918}},["arrow-down-left-from-circle"]={16898612629,{48,48},{355,869}},["folder-pen"]={16898613353,{48,48},{710,869}},cross={16898613044,{48,48},{869,453}},["alarm-check"]={16898612629,{48,48},{49,771}},["chevron-right"]={16898612819,{48,48},{869,759}},pill={16898613699,{48,48},{563,820}},["square-arrow-down-left"]={16898613777,{48,48},{820,404}},["share-2"]={16898613777,{48,48},{771,514}},["arrow-up-from-dot"]={16898612629,{48,48},{869,661}},["pin-off"]={16898613699,{48,48},{514,869}},["align-vertical-justify-start"]={16898612629,{48,48},{918,257}},combine={16898613044,{48,48},{612,869}},["tv-2"]={16898613869,{48,48},{147,820}},mountain={16898613613,{48,48},{869,612}},cast={16898612819,{48,48},{869,453}},["indent-increase"]={16898613509,{48,48},{820,661}},currency={16898613044,{48,48},{918,661}},["shield-ban"]={16898613777,{48,48},{0,820}},["message-circle-reply"]={16898613613,{48,48},{820,563}},["corner-left-up"]={16898613044,{48,48},{612,918}},["triangle-right"]={16898613869,{48,48},{918,49}},["folder-clock"]={16898613353,{48,48},{967,98}},link={16898613509,{48,48},{918,453}},["pound-sterling"]={16898613699,{48,48},{514,918}},type={16898613869,{48,48},{967,257}},webhook={16898613869,{48,48},{967,196}},barcode={16898612629,{48,48},{918,808}},["shopping-bag"]={16898613777,{48,48},{49,820}},bed={16898612819,{48,48},{771,0}},["panel-right-open"]={16898613613,{48,48},{869,808}},["pointer-off"]={16898613699,{48,48},{771,661}},turtle={16898613869,{48,48},{196,771}},camera={16898612819,{48,48},{967,563}},scissors={16898613699,{48,48},{820,857}},["user-minus-2"]={16898613869,{48,48},{98,918}},["git-pull-request"]={16898613509,{48,48},{49,771}},["bluetooth-searching"]={16898612819,{48,48},{820,306}},["arrow-up-to-line"]={16898612629,{48,48},{196,869}},drill={16898613044,{48,48},{869,906}},["file-check-2"]={16898613353,{48,48},{612,771}},["badge-percent"]={16898612629,{48,48},{967,661}},shuffle={16898613777,{48,48},{257,869}},radiation={16898613699,{48,48},{771,453}},radical={16898613699,{48,48},{453,771}},microscope={16898613613,{48,48},{771,661}},["message-circle-x"]={16898613613,{48,48},{612,771}},box={16898612819,{48,48},{771,196}},["align-left"]={16898612629,{48,48},{514,869}},["switch-camera"]={16898613777,{48,48},{771,906}},["file-heart"]={16898613353,{48,48},{0,918}},cat={16898612819,{48,48},{404,918}},space={16898613777,{48,48},{563,869}},["rectangle-vertical"]={16898613699,{48,48},{147,869}},["clipboard-signature"]={16898613044,{48,48},{771,147}},["arrow-up-circle"]={16898612629,{48,48},{967,563}},["corner-up-left"]={16898613044,{48,48},{918,147}},["clock-6"]={16898613044,{48,48},{257,918}},["candlestick-chart"]={16898612819,{48,48},{918,612}},["key-round"]={16898613509,{48,48},{967,306}},headphones={16898613509,{48,48},{306,869}},tv={16898613869,{48,48},{98,869}},["book-minus"]={16898612819,{48,48},{0,918}},["bar-chart-horizontal-big"]={16898612629,{48,48},{771,906}},rss={16898613699,{48,48},{771,808}},["user-round-x"]={16898613869,{48,48},{306,967}},highlighter={16898613509,{48,48},{918,49}},["rocking-chair"]={16898613699,{48,48},{869,196}},["square-arrow-out-down-left"]={16898613777,{48,48},{355,869}},music={16898613613,{48,48},{967,563}},handshake={16898613509,{48,48},{514,869}},["check-circle"]={16898612819,{48,48},{869,710}},tornado={16898613869,{48,48},{771,147}},["copy-plus"]={16898613044,{48,48},{355,918}},["folder-git"]={16898613353,{48,48},{918,404}},["triangle-alert"]={16898613869,{48,48},{967,0}},shrink={16898613777,{48,48},{355,771}},sofa={16898613777,{48,48},{661,771}},["school-2"]={16898613699,{48,48},{967,453}},["search-check"]={16898613699,{48,48},{869,857}},crop={16898613044,{48,48},{918,404}},["columns-2"]={16898613044,{48,48},{820,661}},["mouse-pointer-square"]={16898613613,{48,48},{661,820}},["flask-conical-off"]={16898613353,{48,48},{820,453}},milestone={16898613613,{48,48},{612,820}},["wand-2"]={16898613869,{48,48},{918,453}},["square-dot"]={16898613777,{48,48},{918,355}},["badge-minus"]={16898612629,{48,48},{404,967}},["cloud-fog"]={16898613044,{48,48},{514,918}},["milk-off"]={16898613613,{48,48},{563,869}},bone={16898612819,{48,48},{869,514}},["percent-diamond"]={16898613699,{48,48},{257,820}},["package-check"]={16898613613,{48,48},{820,759}},["chevron-first"]={16898612819,{48,48},{147,967}},pencil={16898613699,{48,48},{820,257}},["shield-minus"]={16898613777,{48,48},{257,820}},["list-x"]={16898613509,{48,48},{918,759}},["stretch-horizontal"]={16898613777,{48,48},{967,661}},["panel-left-open"]={16898613613,{48,48},{196,967}},["corner-up-right"]={16898613044,{48,48},{869,196}},["repeat-2"]={16898613699,{48,48},{869,661}},pin={16898613699,{48,48},{918,0}},["mail-question"]={16898613613,{48,48},{771,257}},gift={16898613353,{48,48},{820,955}},["badge-indian-rupee"]={16898612629,{48,48},{967,404}},smartphone={16898613777,{48,48},{257,918}},["redo-dot"]={16898613699,{48,48},{967,306}},["users-round"]={16898613869,{48,48},{563,967}},["align-start-horizontal"]={16898612629,{48,48},{869,49}},["message-square-warning"]={16898613613,{48,48},{771,404}},["file-plus"]={16898613353,{48,48},{918,49}},["git-pull-request-arrow"]={16898613509,{48,48},{257,771}},webcam={16898613869,{48,48},{710,918}},["arrow-down-to-dot"]={16898612629,{48,48},{710,771}},["bell-dot"]={16898612819,{48,48},{771,514}},["folder-down"]={16898613353,{48,48},{147,918}},church={16898612819,{48,48},{771,906}},["square-play"]={16898613777,{48,48},{967,98}},["badge-x"]={16898612629,{48,48},{710,918}},server={16898613777,{48,48},{771,0}},["phone-forwarded"]={16898613699,{48,48},{869,0}},diamond={16898613044,{48,48},{196,918}},blinds={16898612819,{48,48},{98,771}},["user-square"]={16898613869,{48,48},{820,710}},package={16898613613,{48,48},{918,196}},["alarm-clock-off"]={16898612629,{48,48},{771,306}},["table-cells-merge"]={16898613777,{48,48},{820,906}},["helping-hand"]={16898613509,{48,48},{514,918}},recycle={16898613699,{48,48},{98,918}},["mountain-snow"]={16898613613,{48,48},{918,563}},luggage={16898613509,{48,48},{918,906}},["divide-square"]={16898613044,{48,48},{196,967}},["bot-message-square"]={16898612819,{48,48},{918,49}},["phone-outgoing"]={16898613699,{48,48},{49,820}},["smartphone-charging"]={16898613777,{48,48},{355,820}},["panel-left"]={16898613613,{48,48},{967,453}},["train-track"]={16898613869,{48,48},{355,820}},["bookmark-minus"]={16898612819,{48,48},{661,771}},["tablet-smartphone"]={16898613777,{48,48},{967,857}},["fire-extinguisher"]={16898613353,{48,48},{514,967}},sigma={16898613777,{48,48},{820,563}},["shield-half"]={16898613777,{48,48},{306,771}},terminal={16898613869,{48,48},{820,257}},shapes={16898613777,{48,48},{257,771}},["bell-ring"]={16898612819,{48,48},{0,820}},["tower-control"]={16898613869,{48,48},{0,918}},["arrow-down-1-0"]={16898612629,{48,48},{820,404}},users={16898613869,{48,48},{967,98}},scroll={16898613699,{48,48},{918,808}},["arrow-left-right"]={16898612629,{48,48},{820,196}},["lightbulb-off"]={16898613509,{48,48},{967,147}},["panels-top-left"]={16898613613,{48,48},{967,808}},beaker={16898612629,{48,48},{918,906}},["message-square-share"]={16898613613,{48,48},{869,306}},annoyed={16898612629,{48,48},{918,514}},["test-tube"]={16898613869,{48,48},{257,820}},["user-circle"]={16898613869,{48,48},{820,196}},["cooking-pot"]={16898613044,{48,48},{820,453}},["between-horizontal-start"]={16898612819,{48,48},{306,771}},fullscreen={16898613353,{48,48},{967,453}},["circuit-board"]={16898613044,{48,48},{355,771}},["grid-3x3"]={16898613509,{48,48},{98,771}},["mail-open"]={16898613613,{48,48},{771,0}},["square-function"]={16898613777,{48,48},{820,453}},["arrow-up-left-from-circle"]={16898612629,{48,48},{771,759}},variable={16898613869,{48,48},{147,918}},["arrow-up-right-square"]={16898612629,{48,48},{967,98}},["pen-line"]={16898613699,{48,48},{771,514}}},["256px"]={["align-vertical-distribute-center"]={16898613509,{256,256},{514,0}},["chevron-down"]={16898617411,{256,256},{514,257}},["list-restart"]={16898674572,{256,256},{257,257}},["table-cells-split"]={16898787819,{256,256},{514,0}},gavel={16898672166,{256,256},{514,257}},["dna-off"]={16898669271,{256,256},{514,514}},["refresh-ccw-dot"]={16898733036,{256,256},{257,514}},bean={16898615374,{256,256},{257,0}},["arrow-up-right-from-circle"]={16898614410,{256,256},{514,257}},["table-columns-split"]={16898787819,{256,256},{257,257}},bolt={16898615799,{256,256},{0,514}},heater={16898673271,{256,256},{257,0}},feather={16898669897,{256,256},{0,514}},["align-horizontal-distribute-center"]={16898613044,{256,256},{514,514}},["align-center"]={16898613044,{256,256},{0,514}},["grip-vertical"]={16898672700,{256,256},{514,0}},["person-standing"]={16898731539,{256,256},{257,257}},["badge-swiss-franc"]={16898615022,{256,256},{514,0}},["between-horizontal-end"]={16898615428,{256,256},{514,257}},["rotate-cw"]={16898733415,{256,256},{514,0}},framer={16898671684,{256,256},{514,514}},["bus-front"]={16898616879,{256,256},{0,514}},["shield-ellipsis"]={16898734564,{256,256},{514,0}},["file-lock-2"]={16898670241,{256,256},{0,0}},["between-vertical-end"]={16898615428,{256,256},{514,514}},["globe-lock"]={16898672599,{256,256},{514,0}},tags={16898788033,{256,256},{514,0}},["concierge-bell"]={16898619347,{256,256},{257,0}},["user-square"]={16898790047,{256,256},{514,257}},["arrow-left-square"]={16898614166,{256,256},{257,257}},["file-down"]={16898670072,{256,256},{514,514}},["picture-in-picture"]={16898731683,{256,256},{514,514}},["messages-square"]={16898728402,{256,256},{257,514}},["touchpad-off"]={16898788908,{256,256},{257,0}},["user-round-cog"]={16898789825,{256,256},{257,514}},["chevron-up-circle"]={16898617509,{256,256},{514,257}},["server-crash"]={16898734242,{256,256},{514,514}},["heading-3"]={16898672954,{256,256},{257,514}},squircle={16898736597,{256,256},{0,514}},["wifi-off"]={16898790996,{256,256},{257,514}},["sun-medium"]={16898736967,{256,256},{514,257}},["message-square"]={16898728402,{256,256},{514,257}},["cloud-download"]={16898618763,{256,256},{0,257}},["sigma-square"]={16898734792,{256,256},{257,257}},["folder-plus"]={16898671463,{256,256},{257,0}},["hard-drive-download"]={16898672829,{256,256},{257,514}},["scatter-chart"]={16898733817,{256,256},{257,257}},pointer={16898732061,{256,256},{514,514}},["circle-alert"]={16898617705,{256,256},{514,0}},["chevrons-up-down"]={16898617626,{256,256},{514,257}},["iteration-cw"]={16898673616,{256,256},{0,0}},["rail-symbol"]={16898732665,{256,256},{0,514}},["message-circle-more"]={16898675752,{256,256},{0,257}},parentheses={16898731166,{256,256},{257,514}},["book-up-2"]={16898616524,{256,256},{0,0}},flame={16898670919,{256,256},{0,257}},["chevrons-up"]={16898617626,{256,256},{257,514}},["chevron-right-square"]={16898617509,{256,256},{257,257}},["square-mouse-pointer"]={16898736237,{256,256},{257,0}},superscript={16898787671,{256,256},{514,0}},tag={16898788033,{256,256},{0,257}},["file-warning"]={16898670620,{256,256},{0,257}},hexagon={16898673271,{256,256},{257,257}},["navigation-2-off"]={16898730065,{256,256},{257,0}},["eye-off"]={16898669772,{256,256},{514,514}},["arrows-up-from-line"]={16898614574,{256,256},{0,514}},["square-gantt-chart"]={16898736072,{256,256},{257,257}},["square-chevron-left"]={16898735845,{256,256},{257,0}},scaling={16898733674,{256,256},{0,514}},["inspection-panel"]={16898673523,{256,256},{0,514}},["arrow-left-from-line"]={16898614166,{256,256},{0,257}},["signal-medium"]={16898734792,{256,256},{514,514}},["ticket-percent"]={16898788660,{256,256},{257,514}},["arrow-right-square"]={16898614275,{256,256},{257,0}},["calendar-clock"]={16898616953,{256,256},{0,514}},x={16898791349,{256,256},{257,0}},voicemail={16898790439,{256,256},{514,514}},presentation={16898732262,{256,256},{257,514}},["tree-palm"]={16898789012,{256,256},{0,514}},badge={16898615022,{256,256},{0,514}},["captions-off"]={16898617146,{256,256},{514,514}},["align-vertical-justify-center"]={16898613509,{256,256},{514,257}},theater={16898788479,{256,256},{514,514}},tent={16898788248,{256,256},{257,257}},["repeat-1"]={16898733146,{256,256},{0,514}},stethoscope={16898736776,{256,256},{257,257}},["screen-share-off"]={16898734065,{256,256},{0,257}},["arrow-big-up"]={16898613777,{256,256},{514,514}},["volume-x"]={16898790615,{256,256},{0,257}},["mouse-pointer-click"]={16898729337,{256,256},{0,514}},["square-m"]={16898736072,{256,256},{257,514}},["hard-hat"]={16898672954,{256,256},{257,0}},["package-minus"]={16898730417,{256,256},{257,514}},["iteration-ccw"]={16898673523,{256,256},{514,514}},pipette={16898731819,{256,256},{257,514}},["flip-horizontal"]={16898671019,{256,256},{0,0}},["alert-circle"]={16898613044,{256,256},{0,0}},unplug={16898789644,{256,256},{0,0}},["badge-cent"]={16898614755,{256,256},{514,514}},["check-square-2"]={16898617325,{256,256},{514,514}},["monitor-check"]={16898728878,{256,256},{257,257}},trello={16898789012,{256,256},{514,514}},["paintbrush-2"]={16898730641,{256,256},{514,257}},["bar-chart-horizontal"]={16898615143,{256,256},{514,257}},["book-open-text"]={16898616322,{256,256},{257,257}},["parking-meter"]={16898731301,{256,256},{257,0}},cat={16898617325,{256,256},{514,0}},["heart-handshake"]={16898673115,{256,256},{514,257}},trees={16898789012,{256,256},{257,514}},ham={16898672700,{256,256},{257,514}},text={16898788479,{256,256},{257,514}},["circle-pause"]={16898617944,{256,256},{0,514}},["chevron-up-square"]={16898617509,{256,256},{257,514}},rat={16898732665,{256,256},{257,514}},["separator-horizontal"]={16898734242,{256,256},{0,514}},ambulance={16898613613,{256,256},{0,257}},["signal-zero"]={16898734905,{256,256},{0,0}},citrus={16898618228,{256,256},{0,0}},["phone-missed"]={16898731539,{256,256},{514,514}},["calendar-off"]={16898617053,{256,256},{0,257}},["battery-medium"]={16898615240,{256,256},{0,514}},["square-minus"]={16898736237,{256,256},{0,0}},hotel={16898673358,{256,256},{0,257}},["folder-output"]={16898671263,{256,256},{514,514}},["ice-cream"]={16898673358,{256,256},{257,514}},menu={16898675673,{256,256},{514,257}},["arrow-up-left-square"]={16898614410,{256,256},{514,0}},["image-down"]={16898673358,{256,256},{514,514}},terminal={16898788248,{256,256},{514,257}},angry={16898613613,{256,256},{514,257}},outdent={16898730417,{256,256},{257,257}},["circle-dot-dashed"]={16898617884,{256,256},{514,0}},speech={16898735455,{256,256},{257,0}},["cake-slice"]={16898616953,{256,256},{0,0}},["git-graph"]={16898672316,{256,256},{514,514}},armchair={16898613777,{256,256},{0,0}},["qr-code"]={16898732504,{256,256},{257,257}},copy={16898619423,{256,256},{257,514}},goal={16898672599,{256,256},{0,514}},["trending-down"]={16898789153,{256,256},{0,0}},["creative-commons"]={16898668482,{256,256},{257,0}},nfc={16898730065,{256,256},{257,514}},pickaxe={16898731683,{256,256},{514,257}},car={16898617249,{256,256},{514,0}},["notebook-tabs"]={16898730298,{256,256},{0,0}},ear={16898669689,{256,256},{0,257}},videotape={16898790439,{256,256},{514,257}},["sun-moon"]={16898736967,{256,256},{257,514}},calendar={16898617146,{256,256},{0,0}},["minus-circle"]={16898728878,{256,256},{257,0}},["arrow-down-left-from-circle"]={16898613869,{256,256},{0,514}},gift={16898672316,{256,256},{0,0}},["message-square-heart"]={16898675863,{256,256},{0,514}},["rectangle-ellipsis"]={16898733036,{256,256},{0,0}},["badge-plus"]={16898615022,{256,256},{0,0}},["indian-rupee"]={16898673523,{256,256},{0,257}},["monitor-dot"]={16898728878,{256,256},{0,514}},delete={16898668755,{256,256},{514,257}},["clipboard-pen-line"]={16898618228,{256,256},{514,514}},["folder-search"]={16898671463,{256,256},{257,257}},["utensils-crossed"]={16898790259,{256,256},{257,257}},["arrow-up"]={16898614574,{256,256},{257,257}},["arrow-up-from-dot"]={16898614410,{256,256},{0,0}},["flask-round"]={16898670919,{256,256},{257,514}},pause={16898731301,{256,256},{257,514}},shrub={16898734792,{256,256},{0,257}},flag={16898670919,{256,256},{0,0}},underline={16898789303,{256,256},{514,257}},["align-horizontal-distribute-end"]={16898613353,{256,256},{0,0}},newspaper={16898730065,{256,256},{514,257}},table={16898787819,{256,256},{257,514}},["move-vertical"]={16898729752,{256,256},{257,257}},["file-pen-line"]={16898670241,{256,256},{514,257}},["badge-russian-ruble"]={16898615022,{256,256},{0,257}},radius={16898732665,{256,256},{257,257}},["loader-2"]={16898674684,{256,256},{0,257}},pilcrow={16898731819,{256,256},{514,0}},["corner-left-up"]={16898668288,{256,256},{257,257}},spade={16898735175,{256,256},{514,257}},["folder-cog"]={16898671139,{256,256},{514,0}},["flip-vertical"]={16898671019,{256,256},{0,257}},["square-arrow-down"]={16898735593,{256,256},{257,257}},["circle-plus"]={16898617944,{256,256},{514,514}},view={16898790439,{256,256},{257,514}},cctv={16898617325,{256,256},{257,257}},["more-horizontal"]={16898729337,{256,256},{0,0}},rows={16898733534,{256,256},{257,0}},["pause-octagon"]={16898731301,{256,256},{514,257}},["circle-arrow-left"]={16898617705,{256,256},{0,514}},volume={16898790615,{256,256},{514,0}},facebook={16898669897,{256,256},{257,0}},["octagon-alert"]={16898730298,{256,256},{257,514}},["panel-bottom-dashed"]={16898730821,{256,256},{0,257}},["book-a"]={16898615799,{256,256},{514,514}},["align-end-vertical"]={16898613044,{256,256},{257,514}},["user-x-2"]={16898790047,{256,256},{257,514}},chrome={16898617626,{256,256},{514,514}},["receipt-japanese-yen"]={16898732855,{256,256},{514,0}},rabbit={16898732504,{256,256},{514,257}},["scissors-square"]={16898734065,{256,256},{0,0}},["check-square"]={16898617411,{256,256},{0,0}},["train-front-tunnel"]={16898788908,{256,256},{257,514}},["panel-left-dashed"]={16898730821,{256,256},{257,514}},["dice-4"]={16898669042,{256,256},{0,514}},["message-circle-x"]={16898675752,{256,256},{514,514}},["folder-x"]={16898671684,{256,256},{0,0}},["message-circle-warning"]={16898675752,{256,256},{257,514}},map={16898675359,{256,256},{0,514}},move={16898729752,{256,256},{0,514}},["arrow-up-left"]={16898614410,{256,256},{257,257}},award={16898614755,{256,256},{0,257}},["arrow-down-wide-narrow"]={16898614020,{256,256},{257,514}},["unfold-horizontal"]={16898789451,{256,256},{257,0}},["area-chart"]={16898613699,{256,256},{514,514}},["music-4"]={16898729752,{256,256},{514,514}},["shield-x"]={16898734664,{256,256},{0,0}},["plane-landing"]={16898731919,{256,256},{0,0}},["disc-3"]={16898669271,{256,256},{0,257}},["columns-4"]={16898619182,{256,256},{514,0}},["archive-x"]={16898613699,{256,256},{514,257}},["square-dashed-kanban"]={16898735845,{256,256},{257,514}},["mouse-pointer-2"]={16898729337,{256,256},{257,257}},["shield-off"]={16898734564,{256,256},{514,257}},compass={16898619182,{256,256},{257,514}},vegan={16898790439,{256,256},{0,0}},["message-circle-plus"]={16898675752,{256,256},{257,257}},["stop-circle"]={16898736776,{256,256},{257,514}},nut={16898730298,{256,256},{514,257}},search={16898734242,{256,256},{257,0}},files={16898670620,{256,256},{514,257}},["send-to-back"]={16898734242,{256,256},{514,0}},["alarm-clock"]={16898612819,{256,256},{257,257}},["shopping-basket"]={16898734664,{256,256},{514,257}},send={16898734242,{256,256},{257,257}},["chevron-left-square"]={16898617509,{256,256},{257,0}},["terminal-square"]={16898788248,{256,256},{0,514}},["square-arrow-out-down-left"]={16898735593,{256,256},{514,257}},["skip-back"]={16898734905,{256,256},{0,514}},["zoom-in"]={16898791349,{256,256},{0,514}},["file-scan"]={16898670367,{256,256},{514,0}},["message-square-dashed"]={16898675863,{256,256},{0,257}},trophy={16898789153,{256,256},{0,514}},umbrella={16898789303,{256,256},{0,514}},touchpad={16898788908,{256,256},{0,257}},["clipboard-copy"]={16898618228,{256,256},{514,0}},["map-pin-off"]={16898675359,{256,256},{0,257}},headset={16898673115,{256,256},{257,257}},["circle-chevron-up"]={16898617803,{256,256},{514,514}},["align-vertical-space-between"]={16898613613,{256,256},{257,0}},["lamp-desk"]={16898673794,{256,256},{514,0}},["circle-arrow-up"]={16898617803,{256,256},{0,257}},zap={16898791349,{256,256},{257,257}},["triangle-alert"]={16898789153,{256,256},{0,257}},["swiss-franc"]={16898787671,{256,256},{0,514}},["move-left"]={16898729572,{256,256},{514,514}},["chevron-up"]={16898617509,{256,256},{514,514}},instagram={16898673523,{256,256},{514,257}},["pen-tool"]={16898731419,{256,256},{514,0}},["pencil-ruler"]={16898731419,{256,256},{514,257}},dna={16898669433,{256,256},{0,0}},["arrow-big-down-dash"]={16898613777,{256,256},{257,0}},["clipboard-edit"]={16898618228,{256,256},{257,257}},mic={16898728659,{256,256},{0,257}},["folder-search-2"]={16898671463,{256,256},{514,0}},gitlab={16898672450,{256,256},{514,514}},["rotate-3d"]={16898733317,{256,256},{514,514}},["spell-check"]={16898735455,{256,256},{514,0}},popcorn={16898732262,{256,256},{0,0}},blocks={16898615570,{256,256},{514,514}},["washing-machine"]={16898790791,{256,256},{0,514}},["badge-minus"]={16898614945,{256,256},{257,514}},["cloud-sun"]={16898618899,{256,256},{0,514}},circle={16898618049,{256,256},{257,514}},["shield-alert"]={16898734564,{256,256},{0,0}},rainbow={16898732665,{256,256},{514,257}},["separator-vertical"]={16898734242,{256,256},{514,257}},ampersands={16898613613,{256,256},{257,257}},["user-search"]={16898790047,{256,256},{257,257}},fence={16898669897,{256,256},{514,257}},["square-user-round"]={16898736597,{256,256},{257,0}},sunrise={16898787671,{256,256},{257,0}},strikethrough={16898736967,{256,256},{0,257}},["calendar-days"]={16898616953,{256,256},{514,257}},["dollar-sign"]={16898669433,{256,256},{514,0}},puzzle={16898732504,{256,256},{0,257}},["list-minus"]={16898674572,{256,256},{0,0}},["sun-dim"]={16898736967,{256,256},{0,514}},upload={16898789644,{256,256},{0,257}},["app-window-mac"]={16898613699,{256,256},{0,257}},ellipsis={16898669772,{256,256},{257,0}},["copy-check"]={16898619423,{256,256},{0,257}},history={16898673271,{256,256},{514,257}},satellite={16898733674,{256,256},{0,0}},["bookmark-plus"]={16898616524,{256,256},{257,514}},["folder-key"]={16898671263,{256,256},{514,0}},["lamp-ceiling"]={16898673794,{256,256},{0,257}},["circle-power"]={16898618049,{256,256},{0,0}},hourglass={16898673358,{256,256},{514,0}},["folder-git"]={16898671139,{256,256},{514,514}},bomb={16898615799,{256,256},{514,257}},["layers-2"]={16898673999,{256,256},{514,514}},["battery-full"]={16898615240,{256,256},{514,0}},["user-minus"]={16898789825,{256,256},{514,0}},["x-octagon"]={16898791187,{256,256},{514,514}},["folder-tree"]={16898671463,{256,256},{257,514}},command={16898619182,{256,256},{514,257}},regex={16898733146,{256,256},{514,0}},hand={16898672829,{256,256},{0,514}},["chevrons-down"]={16898617626,{256,256},{257,0}},["bluetooth-off"]={16898615799,{256,256},{257,0}},["music-2"]={16898729752,{256,256},{514,257}},book={16898616524,{256,256},{257,257}},hammer={16898672700,{256,256},{514,514}},["circle-minus"]={16898617944,{256,256},{257,0}},["audio-waveform"]={16898614755,{256,256},{257,0}},["moon-star"]={16898729141,{256,256},{257,514}},["arrow-down-narrow-wide"]={16898613869,{256,256},{514,514}},sparkle={16898735175,{256,256},{257,514}},wand={16898790791,{256,256},{514,0}},["calendar-minus-2"]={16898617053,{256,256},{0,0}},["copy-minus"]={16898619423,{256,256},{514,0}},["folder-input"]={16898671263,{256,256},{257,0}},["book-image"]={16898616080,{256,256},{257,514}},shirt={16898734664,{256,256},{257,257}},["server-off"]={16898734421,{256,256},{0,0}},["move-up"]={16898729752,{256,256},{514,0}},["plug-2"]={16898731919,{256,256},{514,257}},radio={16898732665,{256,256},{514,0}},brackets={16898616650,{256,256},{514,514}},["calendar-heart"]={16898616953,{256,256},{514,514}},["list-ordered"]={16898674572,{256,256},{0,257}},["mic-off"]={16898728659,{256,256},{0,0}},["arrow-big-left"]={16898613777,{256,256},{257,257}},["square-split-horizontal"]={16898736398,{256,256},{514,257}},clover={16898619015,{256,256},{0,0}},["sun-snow"]={16898736967,{256,256},{514,514}},["user-2"]={16898789644,{256,256},{257,257}},["help-circle"]={16898673271,{256,256},{0,257}},["clock-2"]={16898618583,{256,256},{257,0}},["calendar-fold"]={16898616953,{256,256},{257,514}},["fish-off"]={16898670775,{256,256},{514,0}},baby={16898614755,{256,256},{0,514}},leaf={16898674337,{256,256},{0,0}},["fold-vertical"]={16898671019,{256,256},{257,514}},hop={16898673358,{256,256},{0,0}},["phone-incoming"]={16898731539,{256,256},{257,514}},cigarette={16898617705,{256,256},{0,257}},minus={16898728878,{256,256},{514,0}},["smile-plus"]={16898735040,{256,256},{514,514}},["folder-edit"]={16898671139,{256,256},{514,257}},["star-off"]={16898736776,{256,256},{0,0}},["git-pull-request-closed"]={16898672450,{256,256},{0,257}},["badge-check"]={16898614945,{256,256},{0,0}},["test-tube-2"]={16898788248,{256,256},{257,514}},["kanban-square"]={16898673616,{256,256},{257,257}},["plug-zap"]={16898731919,{256,256},{514,514}},["heading-4"]={16898672954,{256,256},{514,514}},["git-pull-request-create"]={16898672450,{256,256},{257,257}},["replace-all"]={16898733146,{256,256},{514,514}},["receipt-swiss-franc"]={16898732855,{256,256},{514,257}},["square-dashed-bottom-code"]={16898735845,{256,256},{0,514}},["clock-7"]={16898618583,{256,256},{514,257}},["scan-text"]={16898733817,{256,256},{0,257}},["shower-head"]={16898734792,{256,256},{0,0}},["equal-not"]={16898669772,{256,256},{0,257}},["sliders-horizontal"]={16898735040,{256,256},{0,257}},["ticket-slash"]={16898788789,{256,256},{0,0}},ruler={16898733534,{256,256},{514,0}},["circle-user-round"]={16898618049,{256,256},{257,257}},["list-filter"]={16898674482,{256,256},{514,514}},["alarm-minus"]={16898612819,{256,256},{0,514}},["egg-off"]={16898669689,{256,256},{257,514}},cog={16898619015,{256,256},{514,514}},dog={16898669433,{256,256},{0,257}},swords={16898787671,{256,256},{514,514}},["panel-right-dashed"]={16898731024,{256,256},{514,0}},["ship-wheel"]={16898734664,{256,256},{0,257}},bot={16898616650,{256,256},{514,0}},["trash-2"]={16898789012,{256,256},{0,257}},["chevron-down-square"]={16898617411,{256,256},{0,514}},["panel-left-open"]={16898731024,{256,256},{0,0}},["file-symlink"]={16898670469,{256,256},{257,0}},["clipboard-paste"]={16898618228,{256,256},{257,514}},["chevron-last"]={16898617411,{256,256},{514,514}},["book-heart"]={16898616080,{256,256},{514,257}},["circle-parking"]={16898617944,{256,256},{257,257}},["panel-left"]={16898731024,{256,256},{257,0}},["message-circle-off"]={16898675752,{256,256},{514,0}},speaker={16898735455,{256,256},{0,0}},timer={16898788789,{256,256},{0,514}},forward={16898671684,{256,256},{514,257}},["file-up"]={16898670469,{256,256},{514,257}},["between-vertical-start"]={16898615570,{256,256},{0,0}},database={16898668755,{256,256},{0,514}},["panel-right"]={16898731024,{256,256},{514,257}},["log-out"]={16898674825,{256,256},{257,257}},["git-branch-plus"]={16898672316,{256,256},{257,0}},["shield-half"]={16898734564,{256,256},{257,257}},["square-dot"]={16898736072,{256,256},{257,0}},["arrow-right-circle"]={16898614166,{256,256},{257,514}},["table-rows-split"]={16898787819,{256,256},{514,257}},watch={16898790791,{256,256},{514,257}},["cloud-upload"]={16898618899,{256,256},{514,257}},["screen-share"]={16898734065,{256,256},{514,0}},drumstick={16898669562,{256,256},{514,514}},["list-checks"]={16898674482,{256,256},{0,514}},bug={16898616879,{256,256},{0,257}},["circle-chevron-left"]={16898617803,{256,256},{514,257}},["arrow-down"]={16898614166,{256,256},{0,0}},["arrow-up-down"]={16898614275,{256,256},{514,514}},["folder-dot"]={16898671139,{256,256},{257,257}},["whole-word"]={16898790996,{256,256},{514,257}},monitor={16898729141,{256,256},{514,257}},["flag-off"]={16898670775,{256,256},{514,257}},["align-right"]={16898613509,{256,256},{0,0}},["circle-stop"]={16898618049,{256,256},{514,0}},infinity={16898673523,{256,256},{514,0}},["arrow-big-down"]={16898613777,{256,256},{0,257}},["circle-parking-off"]={16898617944,{256,256},{514,0}},["calendar-x-2"]={16898617053,{256,256},{257,514}},["user-plus"]={16898789825,{256,256},{0,514}},["move-diagonal-2"]={16898729572,{256,256},{0,257}},["gallery-horizontal-end"]={16898672004,{256,256},{257,257}},["panel-top-dashed"]={16898731024,{256,256},{514,514}},["tram-front"]={16898789012,{256,256},{257,0}},podcast={16898732061,{256,256},{514,257}},["audio-lines"]={16898614755,{256,256},{0,0}},["flip-vertical-2"]={16898671019,{256,256},{257,0}},github={16898672450,{256,256},{257,514}},["rows-2"]={16898733415,{256,256},{257,514}},printer={16898732262,{256,256},{514,514}},["megaphone-off"]={16898675673,{256,256},{257,0}},["file-bar-chart-2"]={16898669984,{256,256},{514,257}},["arrow-big-right"]={16898613777,{256,256},{514,257}},["file-clock"]={16898670072,{256,256},{0,257}},["toy-brick"]={16898788908,{256,256},{257,257}},["square-chevron-down"]={16898735845,{256,256},{0,0}},smartphone={16898735040,{256,256},{257,514}},drill={16898669562,{256,256},{257,257}},["app-window"]={16898613699,{256,256},{514,0}},["shield-check"]={16898734564,{256,256},{0,257}},["hand-metal"]={16898672829,{256,256},{514,0}},["x-circle"]={16898791187,{256,256},{257,514}},["spell-check-2"]={16898735455,{256,256},{0,257}},["minus-square"]={16898728878,{256,256},{0,257}},["box-select"]={16898616650,{256,256},{257,257}},["list-plus"]={16898674572,{256,256},{514,0}},waypoints={16898790791,{256,256},{514,514}},["ice-cream-cone"]={16898673358,{256,256},{514,257}},["copy-slash"]={16898619423,{256,256},{0,514}},wind={16898791187,{256,256},{0,0}},["layout-panel-left"]={16898674182,{256,256},{0,514}},pill={16898731819,{256,256},{257,257}},grip={16898672700,{256,256},{257,257}},["square-x"]={16898736597,{256,256},{514,0}},italic={16898673523,{256,256},{257,514}},["step-forward"]={16898736776,{256,256},{514,0}},["a-arrow-down"]={16898612629,{256,256},{0,0}},container={16898619347,{256,256},{257,514}},sticker={16898736776,{256,256},{0,514}},["parking-circle-off"]={16898731166,{256,256},{514,514}},import={16898673447,{256,256},{514,257}},bird={16898615570,{256,256},{257,257}},["square-terminal"]={16898736597,{256,256},{0,0}},gem={16898672166,{256,256},{257,514}},beef={16898615374,{256,256},{0,514}},["ticket-x"]={16898788789,{256,256},{257,0}},["timer-reset"]={16898788789,{256,256},{257,257}},["monitor-stop"]={16898729141,{256,256},{514,0}},smile={16898735175,{256,256},{0,0}},["signpost-big"]={16898734905,{256,256},{0,257}},cloudy={16898618899,{256,256},{514,514}},["square-percent"]={16898736237,{256,256},{0,514}},["navigation-off"]={16898730065,{256,256},{514,0}},["arrow-left"]={16898614166,{256,256},{514,257}},["car-taxi-front"]={16898617249,{256,256},{0,257}},laugh={16898673999,{256,256},{257,514}},["x-square"]={16898791349,{256,256},{0,0}},["step-back"]={16898736776,{256,256},{0,257}},equal={16898669772,{256,256},{514,0}},megaphone={16898675673,{256,256},{0,257}},["chevron-left"]={16898617509,{256,256},{0,257}},egg={16898669689,{256,256},{514,514}},["video-off"]={16898790439,{256,256},{257,257}},["japanese-yen"]={16898673616,{256,256},{257,0}},library={16898674337,{256,256},{257,257}},["file-terminal"]={16898670469,{256,256},{0,257}},["circle-chevron-down"]={16898617803,{256,256},{0,514}},["bell-off"]={16898615428,{256,256},{0,257}},["square-library"]={16898736072,{256,256},{514,257}},salad={16898733534,{256,256},{514,257}},["tally-2"]={16898788033,{256,256},{0,514}},sheet={16898734421,{256,256},{257,514}},["circle-check-big"]={16898617803,{256,256},{514,0}},["map-pinned"]={16898675359,{256,256},{257,257}},["corner-down-left"]={16898668288,{256,256},{257,0}},dribbble={16898669562,{256,256},{514,0}},["pilcrow-square"]={16898731819,{256,256},{0,257}},["lamp-wall-up"]={16898673794,{256,256},{514,257}},["book-dashed"]={16898616080,{256,256},{514,0}},bluetooth={16898615799,{256,256},{514,0}},["tree-pine"]={16898789012,{256,256},{514,257}},["receipt-indian-rupee"]={16898732855,{256,256},{0,257}},["check-circle-2"]={16898617325,{256,256},{514,257}},["flask-conical"]={16898670919,{256,256},{514,257}},["package-search"]={16898730641,{256,256},{257,0}},columns={16898619182,{256,256},{257,257}},["folder-sync"]={16898671463,{256,256},{514,257}},fingerprint={16898670775,{256,256},{257,0}},["arrow-up-narrow-wide"]={16898614410,{256,256},{0,514}},frame={16898671684,{256,256},{257,514}},["clock-12"]={16898618583,{256,256},{0,0}},images={16898673447,{256,256},{0,514}},lollipop={16898674825,{256,256},{0,514}},["folder-root"]={16898671463,{256,256},{0,257}},["arrow-left-circle"]={16898614166,{256,256},{257,0}},["lamp-floor"]={16898673794,{256,256},{257,257}},image={16898673447,{256,256},{257,257}},["badge-euro"]={16898614945,{256,256},{0,257}},bike={16898615570,{256,256},{257,0}},option={16898730417,{256,256},{0,257}},["scroll-text"]={16898734065,{256,256},{257,257}},["toggle-right"]={16898788789,{256,256},{257,514}},["ferris-wheel"]={16898669897,{256,256},{257,514}},["camera-off"]={16898617146,{256,256},{257,0}},["function-square"]={16898672004,{256,256},{514,0}},group={16898672700,{256,256},{0,514}},codesandbox={16898619015,{256,256},{514,257}},expand={16898669772,{256,256},{514,257}},["tent-tree"]={16898788248,{256,256},{514,0}},settings={16898734421,{256,256},{514,0}},bitcoin={16898615570,{256,256},{0,514}},["thumbs-up"]={16898788660,{256,256},{257,257}},["calendar-search"]={16898617053,{256,256},{514,257}},["hand-platter"]={16898672829,{256,256},{257,257}},["circle-x"]={16898618049,{256,256},{514,257}},["file-diff"]={16898670072,{256,256},{514,257}},["archive-restore"]={16898613699,{256,256},{0,514}},["clock-10"]={16898618392,{256,256},{257,514}},["dice-1"]={16898669042,{256,256},{0,257}},["copy-x"]={16898619423,{256,256},{514,257}},["folder-open-dot"]={16898671263,{256,256},{514,257}},["axis-3d"]={16898614755,{256,256},{257,257}},["arrow-down-1-0"]={16898613869,{256,256},{257,0}},["clipboard-check"]={16898618228,{256,256},{0,257}},["file-x"]={16898670620,{256,256},{257,257}},diff={16898669271,{256,256},{0,0}},dot={16898669433,{256,256},{257,514}},castle={16898617325,{256,256},{0,257}},["power-circle"]={16898732262,{256,256},{514,0}},["fast-forward"]={16898669897,{256,256},{257,257}},["mail-minus"]={16898675156,{256,256},{257,0}},["file-minus-2"]={16898670241,{256,256},{0,257}},paintbrush={16898730641,{256,256},{257,514}},cast={16898617325,{256,256},{257,0}},["parking-square-off"]={16898731301,{256,256},{0,257}},["clipboard-pen"]={16898618392,{256,256},{0,0}},["settings-2"]={16898734421,{256,256},{0,257}},["alarm-clock-off"]={16898612819,{256,256},{0,257}},["ice-cream-2"]={16898673358,{256,256},{257,257}},list={16898674684,{256,256},{257,0}},["file-pie-chart"]={16898670241,{256,256},{514,514}},["square-arrow-right"]={16898735664,{256,256},{257,0}},["scissors-square-dashed-bottom"]={16898733817,{256,256},{514,514}},["remove-formatting"]={16898733146,{256,256},{257,257}},["bookmark-check"]={16898616524,{256,256},{0,514}},cannabis={16898617146,{256,256},{257,514}},["file-plus-2"]={16898670367,{256,256},{0,0}},["bookmark-x"]={16898616524,{256,256},{514,514}},["a-arrow-up"]={16898612629,{256,256},{257,0}},["chevron-right-circle"]={16898617509,{256,256},{514,0}},caravan={16898617249,{256,256},{257,257}},["file-text"]={16898670469,{256,256},{514,0}},["vibrate-off"]={16898790439,{256,256},{0,257}},["mail-check"]={16898675156,{256,256},{0,0}},["square-split-vertical"]={16898736398,{256,256},{257,514}},["file-type-2"]={16898670469,{256,256},{257,257}},["file-code"]={16898670072,{256,256},{257,257}},["file-volume"]={16898670620,{256,256},{257,0}},["flag-triangle-left"]={16898670775,{256,256},{257,514}},["square-equal"]={16898736072,{256,256},{0,257}},["scan-barcode"]={16898733674,{256,256},{514,257}},["cassette-tape"]={16898617325,{256,256},{0,0}},["battery-low"]={16898615240,{256,256},{257,257}},["utility-pole"]={16898790259,{256,256},{514,257}},folder={16898671684,{256,256},{257,0}},signpost={16898734905,{256,256},{514,0}},["file-edit"]={16898670171,{256,256},{0,0}},["globe-2"]={16898672599,{256,256},{0,257}},landmark={16898673999,{256,256},{0,0}},["fish-symbol"]={16898670775,{256,256},{257,257}},["form-input"]={16898671684,{256,256},{0,514}},loader={16898674684,{256,256},{257,257}},bold={16898615799,{256,256},{257,257}},["dice-2"]={16898669042,{256,256},{514,0}},["file-type"]={16898670469,{256,256},{0,514}},["book-user"]={16898616524,{256,256},{0,257}},beer={16898615374,{256,256},{257,514}},["gantt-chart-square"]={16898672166,{256,256},{0,257}},ghost={16898672166,{256,256},{514,514}},globe={16898672599,{256,256},{257,257}},["satellite-dish"]={16898733534,{256,256},{514,514}},binary={16898615570,{256,256},{0,257}},["move-diagonal"]={16898729572,{256,256},{514,0}},["table-cells-merge"]={16898787819,{256,256},{0,257}},["door-closed"]={16898669433,{256,256},{0,514}},["image-minus"]={16898673447,{256,256},{0,0}},utensils={16898790259,{256,256},{0,514}},["paw-print"]={16898731301,{256,256},{514,514}},["bar-chart-4"]={16898615143,{256,256},{514,0}},["book-x"]={16898616524,{256,256},{514,0}},["panel-bottom-close"]={16898730821,{256,256},{257,0}},["hand-heart"]={16898672829,{256,256},{257,0}},["file-code-2"]={16898670072,{256,256},{514,0}},["move-down-left"]={16898729572,{256,256},{257,257}},indent={16898673523,{256,256},{257,0}},joystick={16898673616,{256,256},{0,257}},keyboard={16898673794,{256,256},{257,0}},["toggle-left"]={16898788789,{256,256},{514,257}},skull={16898734905,{256,256},{257,514}},["route-off"]={16898733415,{256,256},{257,257}},["dice-6"]={16898669042,{256,256},{257,514}},lightbulb={16898674337,{256,256},{514,514}},key={16898673616,{256,256},{514,514}},["clock-11"]={16898618392,{256,256},{514,514}},["list-video"]={16898674572,{256,256},{514,514}},["ticket-plus"]={16898788660,{256,256},{514,514}},["square-dashed-bottom"]={16898735845,{256,256},{514,257}},["layout-panel-top"]={16898674182,{256,256},{514,257}},["more-vertical"]={16898729337,{256,256},{257,0}},["monitor-pause"]={16898728878,{256,256},{514,514}},["book-open-check"]={16898616322,{256,256},{514,0}},projector={16898732504,{256,256},{0,0}},["lasso-select"]={16898673999,{256,256},{0,514}},maximize={16898675359,{256,256},{514,514}},["text-quote"]={16898788479,{256,256},{257,257}},["image-up"]={16898673447,{256,256},{514,0}},["message-square-quote"]={16898728402,{256,256},{0,0}},bus={16898616879,{256,256},{514,257}},["square-arrow-down-right"]={16898735593,{256,256},{514,0}},["bed-single"]={16898615374,{256,256},{514,0}},["list-music"]={16898674572,{256,256},{257,0}},["file-spreadsheet"]={16898670367,{256,256},{514,514}},["heart-pulse"]={16898673115,{256,256},{514,514}},["clipboard-list"]={16898618228,{256,256},{0,514}},video={16898790439,{256,256},{0,514}},["contact-round"]={16898619347,{256,256},{0,514}},battery={16898615240,{256,256},{257,514}},microscope={16898728659,{256,256},{514,0}},["message-circle-question"]={16898675752,{256,256},{0,514}},["file-badge"]={16898669984,{256,256},{0,514}},["battery-warning"]={16898615240,{256,256},{514,257}},["git-pull-request"]={16898672450,{256,256},{514,257}},["arrow-down-from-line"]={16898613869,{256,256},{257,257}},briefcase={16898616757,{256,256},{514,257}},biohazard={16898615570,{256,256},{514,0}},moon={16898729141,{256,256},{514,514}},["heading-6"]={16898673115,{256,256},{257,0}},["scale-3d"]={16898733674,{256,256},{514,0}},["chevron-down-circle"]={16898617411,{256,256},{257,257}},["mail-x"]={16898675156,{256,256},{257,514}},["square-dashed-mouse-pointer"]={16898735845,{256,256},{514,514}},["user-cog"]={16898789825,{256,256},{257,0}},["lock-open"]={16898674825,{256,256},{257,0}},["mouse-pointer-square-dashed"]={16898729337,{256,256},{514,257}},pizza={16898731819,{256,256},{514,514}},["pc-case"]={16898731419,{256,256},{0,0}},["arrow-up-wide-narrow"]={16898614574,{256,256},{0,257}},["mouse-pointer"]={16898729337,{256,256},{514,514}},["clock-5"]={16898618583,{256,256},{257,257}},dices={16898669042,{256,256},{514,514}},["rotate-ccw"]={16898733415,{256,256},{257,0}},["align-horizontal-justify-center"]={16898613353,{256,256},{0,257}},mouse={16898729572,{256,256},{0,0}},antenna={16898613613,{256,256},{514,514}},["memory-stick"]={16898675673,{256,256},{257,257}},["scan-eye"]={16898733674,{256,256},{257,514}},["bean-off"]={16898615374,{256,256},{0,0}},["square-check"]={16898735664,{256,256},{514,514}},unlock={16898789451,{256,256},{514,514}},highlighter={16898673271,{256,256},{0,514}},["loader-circle"]={16898674684,{256,256},{514,0}},["hard-drive-upload"]={16898672829,{256,256},{514,514}},["gallery-vertical-end"]={16898672004,{256,256},{257,514}},["menu-square"]={16898675673,{256,256},{0,514}},["hand-coins"]={16898672829,{256,256},{0,0}},["notepad-text"]={16898730298,{256,256},{257,257}},orbit={16898730417,{256,256},{514,0}},["package-open"]={16898730417,{256,256},{514,514}},clock={16898618763,{256,256},{0,0}},["file-pen"]={16898670241,{256,256},{257,514}},["git-compare-arrows"]={16898672316,{256,256},{0,514}},["cloud-sun-rain"]={16898618899,{256,256},{257,257}},["align-horizontal-justify-start"]={16898613353,{256,256},{257,257}},["grid-2x2"]={16898672700,{256,256},{0,0}},percent={16898731539,{256,256},{514,0}},vibrate={16898790439,{256,256},{514,0}},["calendar-plus"]={16898617053,{256,256},{257,257}},brain={16898616757,{256,256},{0,257}},["arrow-down-z-a"]={16898614020,{256,256},{514,514}},bath={16898615240,{256,256},{257,0}},["panel-right-close"]={16898731024,{256,256},{0,257}},["unlink-2"]={16898789451,{256,256},{0,514}},paperclip={16898731166,{256,256},{514,257}},["parking-circle"]={16898731301,{256,256},{0,0}},["folder-check"]={16898671139,{256,256},{0,0}},["parking-square"]={16898731301,{256,256},{514,0}},["book-key"]={16898616080,{256,256},{514,514}},ribbon={16898733317,{256,256},{257,257}},microwave={16898728659,{256,256},{257,257}},["air-vent"]={16898612629,{256,256},{514,257}},["library-big"]={16898674337,{256,256},{0,257}},["file-json"]={16898670171,{256,256},{0,514}},["folder-open"]={16898671263,{256,256},{257,514}},["monitor-off"]={16898728878,{256,256},{257,514}},["square-scissors"]={16898736398,{256,256},{514,0}},["move-up-left"]={16898729752,{256,256},{257,0}},brush={16898616757,{256,256},{514,514}},["folder-heart"]={16898671263,{256,256},{0,0}},hash={16898672954,{256,256},{0,257}},["arrow-up-1-0"]={16898614275,{256,256},{0,514}},["arrow-right"]={16898614275,{256,256},{514,0}},["arrow-up-a-z"]={16898614275,{256,256},{514,257}},["badge-x"]={16898615022,{256,256},{257,257}},["panel-bottom-inactive"]={16898730821,{256,256},{514,0}},["file-video-2"]={16898670469,{256,256},{257,514}},["phone-call"]={16898731539,{256,256},{0,514}},construction={16898619347,{256,256},{514,0}},["swatch-book"]={16898787671,{256,256},{257,257}},["receipt-cent"]={16898732855,{256,256},{0,0}},["badge-pound-sterling"]={16898615022,{256,256},{257,0}},["folder-archive"]={16898671019,{256,256},{514,514}},["folder-symlink"]={16898671463,{256,256},{0,514}},["columns-3"]={16898619182,{256,256},{0,257}},ban={16898615022,{256,256},{257,514}},["message-square-x"]={16898728402,{256,256},{0,514}},["paint-roller"]={16898730641,{256,256},{0,514}},plug={16898732061,{256,256},{0,0}},gamepad={16898672166,{256,256},{257,0}},["book-minus"]={16898616322,{256,256},{0,257}},popsicle={16898732262,{256,256},{257,0}},["building-2"]={16898616879,{256,256},{514,0}},["circle-slash-2"]={16898618049,{256,256},{257,0}},["rectangle-horizontal"]={16898733036,{256,256},{257,0}},cake={16898616953,{256,256},{257,0}},["cloud-rain"]={16898618899,{256,256},{0,257}},["maximize-2"]={16898675359,{256,256},{257,514}},["redo-2"]={16898733036,{256,256},{257,257}},wrench={16898791187,{256,256},{514,257}},["repeat-2"]={16898733146,{256,256},{514,257}},codepen={16898619015,{256,256},{0,514}},reply={16898733317,{256,256},{0,257}},["flag-triangle-right"]={16898670775,{256,256},{514,514}},["rotate-ccw-square"]={16898733415,{256,256},{0,0}},["scan-search"]={16898733817,{256,256},{257,0}},bell={16898615428,{256,256},{0,514}},["grid-3x3"]={16898672700,{256,256},{257,0}},save={16898733674,{256,256},{0,257}},["music-3"]={16898729752,{256,256},{257,514}},focus={16898671019,{256,256},{0,514}},["user-check"]={16898789644,{256,256},{514,257}},proportions={16898732504,{256,256},{257,0}},["alert-octagon"]={16898613044,{256,256},{257,0}},plane={16898731919,{256,256},{0,257}},["webhook-off"]={16898790996,{256,256},{257,0}},carrot={16898617249,{256,256},{0,514}},["square-arrow-left"]={16898735593,{256,256},{0,514}},["file-cog"]={16898670072,{256,256},{0,514}},heart={16898673271,{256,256},{0,0}},["scan-face"]={16898733674,{256,256},{514,514}},["folder-down"]={16898671139,{256,256},{0,514}},["layout-template"]={16898674182,{256,256},{257,514}},mailbox={16898675359,{256,256},{0,0}},home={16898673271,{256,256},{257,514}},["traffic-cone"]={16898788908,{256,256},{514,257}},scissors={16898734065,{256,256},{257,0}},split={16898735455,{256,256},{257,514}},twitter={16898789303,{256,256},{0,257}},["locate-off"]={16898674684,{256,256},{514,257}},forklift={16898671684,{256,256},{257,257}},["square-arrow-out-up-left"]={16898735593,{256,256},{514,514}},component={16898619182,{256,256},{514,514}},["panels-left-bottom"]={16898731166,{256,256},{514,0}},["message-square-diff"]={16898675863,{256,256},{514,0}},["book-marked"]={16898616322,{256,256},{257,0}},["alarm-plus"]={16898612819,{256,256},{514,257}},["bluetooth-connected"]={16898615799,{256,256},{0,0}},unlink={16898789451,{256,256},{514,257}},signal={16898734905,{256,256},{257,0}},slack={16898734905,{256,256},{514,514}},["file-volume-2"]={16898670620,{256,256},{0,0}},["pound-sterling"]={16898732262,{256,256},{0,257}},power={16898732262,{256,256},{514,257}},["skip-forward"]={16898734905,{256,256},{514,257}},["m-square"]={16898674825,{256,256},{257,514}},["git-merge"]={16898672450,{256,256},{0,0}},["file-box"]={16898669984,{256,256},{514,514}},["align-justify"]={16898613353,{256,256},{257,514}},["paint-bucket"]={16898730641,{256,256},{257,257}},wallpaper={16898790791,{256,256},{0,0}},filter={16898670775,{256,256},{0,0}},glasses={16898672599,{256,256},{257,0}},["piggy-bank"]={16898731819,{256,256},{257,0}},["square-play"]={16898736237,{256,256},{514,514}},shell={16898734421,{256,256},{514,514}},["cloud-off"]={16898618899,{256,256},{0,0}},["check-check"]={16898617325,{256,256},{0,514}},activity={16898612629,{256,256},{0,514}},axe={16898614755,{256,256},{514,0}},["plane-takeoff"]={16898731919,{256,256},{257,0}},snowflake={16898735175,{256,256},{0,257}},["cloud-rain-wind"]={16898618899,{256,256},{257,0}},["square-plus"]={16898736398,{256,256},{0,0}},["dice-5"]={16898669042,{256,256},{514,257}},["search-slash"]={16898734065,{256,256},{514,514}},["file-axis-3d"]={16898669984,{256,256},{514,0}},["receipt-euro"]={16898732855,{256,256},{257,0}},["square-radical"]={16898736398,{256,256},{0,257}},["cloud-drizzle"]={16898618763,{256,256},{514,0}},["bug-play"]={16898616879,{256,256},{257,0}},["align-vertical-distribute-start"]={16898613509,{256,256},{0,514}},layout={16898674182,{256,256},{514,514}},["square-stack"]={16898736398,{256,256},{514,514}},["tally-5"]={16898788033,{256,256},{514,514}},squirrel={16898736597,{256,256},{514,257}},["pen-square"]={16898731419,{256,256},{0,257}},["folder-lock"]={16898671263,{256,256},{257,257}},["circle-divide"]={16898617884,{256,256},{257,0}},["case-sensitive"]={16898617249,{256,256},{257,514}},sunset={16898787671,{256,256},{0,257}},linkedin={16898674482,{256,256},{257,257}},["life-buoy"]={16898674337,{256,256},{0,514}},["circle-play"]={16898617944,{256,256},{257,514}},["tally-4"]={16898788033,{256,256},{257,514}},["volume-2"]={16898790615,{256,256},{257,0}},["battery-charging"]={16898615240,{256,256},{0,257}},["russian-ruble"]={16898733534,{256,256},{257,257}},["wallet-minimal"]={16898790615,{256,256},{257,514}},["earth-lock"]={16898669689,{256,256},{514,0}},footprints={16898671684,{256,256},{514,0}},["text-cursor-input"]={16898788479,{256,256},{0,257}},building={16898616879,{256,256},{257,257}},["lock-keyhole-open"]={16898674684,{256,256},{514,514}},twitch={16898789303,{256,256},{257,0}},["thermometer-sun"]={16898788660,{256,256},{257,0}},["switch-camera"]={16898787671,{256,256},{514,257}},club={16898619015,{256,256},{257,0}},["shield-plus"]={16898734564,{256,256},{257,514}},["alarm-check"]={16898612629,{256,256},{514,514}},["bell-minus"]={16898615428,{256,256},{257,0}},["log-in"]={16898674825,{256,256},{514,0}},["bot-message-square"]={16898616650,{256,256},{0,257}},drum={16898669562,{256,256},{257,514}},["arrow-up-z-a"]={16898614574,{256,256},{514,0}},sun={16898787671,{256,256},{0,0}},["layers-3"]={16898674182,{256,256},{0,0}},["zoom-out"]={16898791349,{256,256},{514,257}},["file-key"]={16898670171,{256,256},{257,514}},tractor={16898788908,{256,256},{0,514}},["school-2"]={16898733817,{256,256},{0,514}},["scissors-line-dashed"]={16898733817,{256,256},{257,514}},["text-select"]={16898788479,{256,256},{514,257}},["file-search"]={16898670367,{256,256},{0,514}},["unfold-vertical"]={16898789451,{256,256},{0,257}},["ticket-check"]={16898788660,{256,256},{0,514}},pyramid={16898732504,{256,256},{514,0}},["hard-drive"]={16898672954,{256,256},{0,0}},["user-cog-2"]={16898789825,{256,256},{0,0}},["refresh-cw-off"]={16898733146,{256,256},{0,0}},["external-link"]={16898669772,{256,256},{257,514}},["picture-in-picture-2"]={16898731683,{256,256},{257,514}},["file-x-2"]={16898670620,{256,256},{514,0}},["flower-2"]={16898671019,{256,256},{514,0}},["calendar-x"]={16898617053,{256,256},{514,514}},["user-round-check"]={16898789825,{256,256},{514,257}},["user-round"]={16898790047,{256,256},{514,0}},["link-2-off"]={16898674482,{256,256},{257,0}},["keyboard-music"]={16898673794,{256,256},{0,0}},["star-half"]={16898736597,{256,256},{514,514}},["user-x"]={16898790047,{256,256},{514,514}},["code-xml"]={16898619015,{256,256},{514,0}},["trending-up"]={16898789153,{256,256},{257,0}},mails={16898675359,{256,256},{257,0}},["brain-cog"]={16898616757,{256,256},{257,0}},tablet={16898788033,{256,256},{0,0}},["users-round"]={16898790259,{256,256},{0,257}},pi={16898731683,{256,256},{257,257}},trash={16898789012,{256,256},{514,0}},dock={16898669433,{256,256},{257,0}},["hdmi-port"]={16898672954,{256,256},{257,257}},braces={16898616650,{256,256},{257,514}},["case-upper"]={16898617249,{256,256},{514,514}},["move-3d"]={16898729572,{256,256},{257,0}},wallet={16898790615,{256,256},{514,514}},croissant={16898668482,{256,256},{514,0}},["monitor-speaker"]={16898729141,{256,256},{0,257}},waves={16898790791,{256,256},{257,514}},barcode={16898615143,{256,256},{514,514}},lock={16898674825,{256,256},{0,257}},["wheat-off"]={16898790996,{256,256},{257,257}},bed={16898615374,{256,256},{257,257}},quote={16898732504,{256,256},{0,514}},divide={16898669271,{256,256},{257,514}},grape={16898672599,{256,256},{514,514}},["play-square"]={16898731919,{256,256},{257,257}},["party-popper"]={16898731301,{256,256},{257,257}},["file-video"]={16898670469,{256,256},{514,514}},university={16898789451,{256,256},{257,257}},["user-circle-2"]={16898789644,{256,256},{257,514}},truck={16898789153,{256,256},{514,257}},box={16898616650,{256,256},{0,514}},["calendar-range"]={16898617053,{256,256},{0,514}},subscript={16898736967,{256,256},{514,0}},["zap-off"]={16898791349,{256,256},{514,0}},["square-check-big"]={16898735664,{256,256},{257,514}},["wand-sparkles"]={16898790791,{256,256},{0,257}},["square-chevron-up"]={16898735845,{256,256},{514,0}},["circle-ellipsis"]={16898617884,{256,256},{0,514}},["laptop-minimal"]={16898673999,{256,256},{514,0}},["radio-receiver"]={16898732665,{256,256},{257,0}},sofa={16898735175,{256,256},{514,0}},["square-asterisk"]={16898735664,{256,256},{0,514}},wine={16898791187,{256,256},{0,257}},cookie={16898619423,{256,256},{0,0}},["message-square-more"]={16898675863,{256,256},{514,257}},clapperboard={16898618228,{256,256},{257,0}},euro={16898669772,{256,256},{0,514}},["dice-3"]={16898669042,{256,256},{257,257}},["heart-off"]={16898673115,{256,256},{257,514}},["clipboard-minus"]={16898618228,{256,256},{514,257}},info={16898673523,{256,256},{257,257}},["move-horizontal"]={16898729572,{256,256},{257,514}},["file-sliders"]={16898670367,{256,256},{257,514}},frown={16898672004,{256,256},{0,0}},["cloud-hail"]={16898618763,{256,256},{0,514}},["cup-soda"]={16898668755,{256,256},{0,0}},["cable-car"]={16898616879,{256,256},{257,514}},["lock-keyhole"]={16898674825,{256,256},{0,0}},sword={16898787671,{256,256},{257,514}},play={16898731919,{256,256},{0,514}},["laptop-2"]={16898673999,{256,256},{0,257}},earth={16898669689,{256,256},{257,257}},slice={16898735040,{256,256},{257,0}},["land-plot"]={16898673794,{256,256},{514,514}},milk={16898728659,{256,256},{257,514}},["circle-user"]={16898618049,{256,256},{0,514}},["align-left"]={16898613353,{256,256},{514,514}},["circle-slash"]={16898618049,{256,256},{0,257}},contact={16898619347,{256,256},{514,257}},["rotate-cw-square"]={16898733415,{256,256},{0,257}},atom={16898614574,{256,256},{514,514}},["package-x"]={16898730641,{256,256},{0,257}},["bed-double"]={16898615374,{256,256},{0,257}},anchor={16898613613,{256,256},{0,514}},["circle-dot"]={16898617884,{256,256},{257,257}},["git-commit-horizontal"]={16898672316,{256,256},{514,0}},["git-commit-vertical"]={16898672316,{256,256},{257,257}},["message-circle-code"]={16898675673,{256,256},{514,514}},["folder-git-2"]={16898671139,{256,256},{257,514}},["message-square-code"]={16898675863,{256,256},{257,0}},["mail-plus"]={16898675156,{256,256},{514,0}},["diamond-percent"]={16898669042,{256,256},{0,0}},["message-circle-heart"]={16898675752,{256,256},{257,0}},["arrow-big-left-dash"]={16898613777,{256,256},{514,0}},["circle-arrow-out-down-left"]={16898617705,{256,256},{514,257}},dumbbell={16898669689,{256,256},{0,0}},["file-music"]={16898670241,{256,256},{257,257}},["alert-triangle"]={16898613044,{256,256},{0,257}},["chevrons-right-left"]={16898617626,{256,256},{257,257}},scale={16898733674,{256,256},{257,257}},eraser={16898669772,{256,256},{257,257}},["flashlight-off"]={16898670919,{256,256},{514,0}},["panel-top-open"]={16898731166,{256,256},{257,0}},["cloud-lightning"]={16898618763,{256,256},{514,257}},ungroup={16898789451,{256,256},{514,0}},notebook={16898730298,{256,256},{0,257}},["power-square"]={16898732262,{256,256},{0,514}},sprout={16898735593,{256,256},{0,0}},["square-menu"]={16898736072,{256,256},{514,514}},["mic-vocal"]={16898728659,{256,256},{257,0}},["monitor-smartphone"]={16898729141,{256,256},{257,0}},laptop={16898673999,{256,256},{257,257}},["scan-line"]={16898733817,{256,256},{0,0}},["clock-4"]={16898618583,{256,256},{514,0}},["square-arrow-up"]={16898735664,{256,256},{257,257}},copyright={16898668288,{256,256},{0,0}},["monitor-up"]={16898729141,{256,256},{257,257}},["unlock-keyhole"]={16898789451,{256,256},{257,514}},usb={16898789644,{256,256},{514,0}},rocket={16898733317,{256,256},{0,514}},["arrow-down-to-line"]={16898614020,{256,256},{0,514}},["book-plus"]={16898616322,{256,256},{514,257}},["refresh-ccw"]={16898733036,{256,256},{514,514}},["venetian-mask"]={16898790439,{256,256},{257,0}},["calendar-check-2"]={16898616953,{256,256},{514,0}},["arrow-down-square"]={16898614020,{256,256},{514,0}},spline={16898735455,{256,256},{257,257}},mail={16898675156,{256,256},{514,514}},["git-pull-request-create-arrow"]={16898672450,{256,256},{514,0}},["library-square"]={16898674337,{256,256},{514,0}},["circle-check"]={16898617803,{256,256},{257,257}},["square-arrow-up-right"]={16898735664,{256,256},{514,0}},["book-text"]={16898616322,{256,256},{257,514}},user={16898790259,{256,256},{0,0}},["file-key-2"]={16898670171,{256,256},{514,257}},["gallery-horizontal"]={16898672004,{256,256},{0,514}},["circle-chevron-right"]={16898617803,{256,256},{257,514}},["timer-off"]={16898788789,{256,256},{514,0}},["arrow-big-right-dash"]={16898613777,{256,256},{0,514}},["wallet-2"]={16898790615,{256,256},{0,514}},cloud={16898618899,{256,256},{257,514}},triangle={16898789153,{256,256},{257,257}},backpack={16898614755,{256,256},{514,257}},lamp={16898673794,{256,256},{257,514}},flower={16898671019,{256,256},{257,257}},youtube={16898791349,{256,256},{0,257}},["upload-cloud"]={16898789644,{256,256},{257,0}},lasso={16898673999,{256,256},{514,257}},["arrow-down-right"]={16898614020,{256,256},{0,257}},sailboat={16898733534,{256,256},{0,514}},receipt={16898732855,{256,256},{514,514}},["bell-ring"]={16898615428,{256,256},{257,257}},["heart-crack"]={16898673115,{256,256},{0,514}},["tree-deciduous"]={16898789012,{256,256},{257,257}},["fire-extinguisher"]={16898670775,{256,256},{0,257}},["baggage-claim"]={16898615022,{256,256},{514,257}},["image-off"]={16898673447,{256,256},{257,0}},["arrow-left-to-line"]={16898614166,{256,256},{0,514}},["layout-grid"]={16898674182,{256,256},{514,0}},["pi-square"]={16898731683,{256,256},{514,0}},["clock-3"]={16898618583,{256,256},{0,257}},["square-chevron-right"]={16898735845,{256,256},{0,257}},navigation={16898730065,{256,256},{257,257}},["filter-x"]={16898670620,{256,256},{514,514}},["bar-chart-3"]={16898615143,{256,256},{0,257}},["map-pin"]={16898675359,{256,256},{514,0}},["arrow-down-right-from-circle"]={16898614020,{256,256},{0,0}},["shopping-bag"]={16898734664,{256,256},{0,514}},["chevron-right"]={16898617509,{256,256},{0,514}},["tally-1"]={16898788033,{256,256},{257,257}},ampersand={16898613613,{256,256},{514,0}},["arrow-up-from-line"]={16898614410,{256,256},{257,0}},["shopping-cart"]={16898734664,{256,256},{257,514}},["user-minus-2"]={16898789825,{256,256},{0,257}},vote={16898790615,{256,256},{257,257}},["alarm-smoke"]={16898612819,{256,256},{257,514}},["file-line-chart"]={16898670171,{256,256},{514,514}},["file-input"]={16898670171,{256,256},{514,0}},["clock-8"]={16898618583,{256,256},{257,514}},["server-cog"]={16898734242,{256,256},{257,514}},["cloud-cog"]={16898618763,{256,256},{257,0}},blend={16898615570,{256,256},{514,257}},["search-x"]={16898734242,{256,256},{0,0}},["radio-tower"]={16898732665,{256,256},{0,257}},["list-tree"]={16898674572,{256,256},{257,514}},droplet={16898669562,{256,256},{0,514}},["panel-right-open"]={16898731024,{256,256},{0,514}},eye={16898669897,{256,256},{0,0}},siren={16898734905,{256,256},{257,257}},star={16898736776,{256,256},{257,0}},banana={16898615022,{256,256},{514,514}},["panel-top"]={16898731166,{256,256},{0,257}},donut={16898669433,{256,256},{257,257}},telescope={16898788248,{256,256},{0,257}},["circle-equal"]={16898617884,{256,256},{514,257}},["arrow-up-right"]={16898614410,{256,256},{514,514}},calculator={16898616953,{256,256},{0,257}},magnet={16898674825,{256,256},{514,514}},crown={16898668482,{256,256},{257,514}},subtitles={16898736967,{256,256},{257,257}},["brick-wall"]={16898616757,{256,256},{514,0}},["message-circle-dashed"]={16898675752,{256,256},{0,0}},["leafy-green"]={16898674337,{256,256},{257,0}},["message-square-dot"]={16898675863,{256,256},{257,257}},["arrow-down-a-z"]={16898613869,{256,256},{0,257}},copyleft={16898619423,{256,256},{514,514}},["monitor-play"]={16898729141,{256,256},{0,0}},["text-cursor"]={16898788479,{256,256},{514,0}},["minimize-2"]={16898728659,{256,256},{514,514}},disc={16898669271,{256,256},{257,257}},locate={16898674684,{256,256},{257,514}},cone={16898619347,{256,256},{0,257}},["heading-1"]={16898672954,{256,256},{0,514}},["file-image"]={16898670171,{256,256},{0,257}},sparkles={16898735175,{256,256},{514,514}},palette={16898730641,{256,256},{514,514}},["user-plus-2"]={16898789825,{256,256},{257,257}},["gallery-thumbnails"]={16898672004,{256,256},{514,257}},["book-up"]={16898616524,{256,256},{257,0}},cpu={16898668482,{256,256},{0,0}},["split-square-horizontal"]={16898735455,{256,256},{0,514}},["thumbs-down"]={16898788660,{256,256},{514,0}},merge={16898675673,{256,256},{257,514}},["circle-dashed"]={16898617884,{256,256},{0,0}},["bar-chart-big"]={16898615143,{256,256},{257,257}},["test-tubes"]={16898788479,{256,256},{257,0}},hospital={16898673358,{256,256},{257,0}},haze={16898672954,{256,256},{514,0}},plus={16898732061,{256,256},{514,0}},["align-vertical-space-around"]={16898613613,{256,256},{0,0}},["key-square"]={16898673616,{256,256},{257,514}},palmtree={16898730821,{256,256},{0,0}},["file-audio"]={16898669984,{256,256},{0,257}},kanban={16898673616,{256,256},{0,514}},["sliders-vertical"]={16898735040,{256,256},{514,0}},apple={16898613699,{256,256},{257,257}},["wine-off"]={16898791187,{256,256},{257,0}},["check-circle"]={16898617325,{256,256},{257,514}},cuboid={16898668482,{256,256},{514,514}},["square-code"]={16898735845,{256,256},{257,257}},["bug-off"]={16898616879,{256,256},{0,0}},["circle-arrow-out-up-left"]={16898617705,{256,256},{514,514}},["corner-right-down"]={16898668288,{256,256},{0,514}},["plug-zap-2"]={16898731919,{256,256},{257,514}},["heading-2"]={16898672954,{256,256},{514,257}},["square-activity"]={16898735593,{256,256},{257,0}},["package-plus"]={16898730641,{256,256},{0,0}},["cigarette-off"]={16898617705,{256,256},{257,0}},["align-vertical-justify-start"]={16898613509,{256,256},{514,514}},["power-off"]={16898732262,{256,256},{257,257}},["undo-2"]={16898789303,{256,256},{257,514}},router={16898733415,{256,256},{514,257}},["tower-control"]={16898788908,{256,256},{514,0}},["git-branch"]={16898672316,{256,256},{0,257}},shovel={16898734664,{256,256},{514,514}},share={16898734421,{256,256},{514,257}},["wallet-cards"]={16898790615,{256,256},{514,257}},["square-arrow-out-down-right"]={16898735593,{256,256},{257,514}},["circuit-board"]={16898618049,{256,256},{514,514}},shield={16898734664,{256,256},{257,0}},["bar-chart-2"]={16898615143,{256,256},{257,0}},["cloud-snow"]={16898618899,{256,256},{514,0}},["file-question"]={16898670367,{256,256},{0,257}},["arrow-big-up-dash"]={16898613777,{256,256},{257,514}},["folder-closed"]={16898671139,{256,256},{0,257}},["smartphone-nfc"]={16898735040,{256,256},{514,257}},network={16898730065,{256,256},{0,514}},["file-bar-chart"]={16898669984,{256,256},{257,514}},["user-round-x"]={16898790047,{256,256},{0,257}},["signal-low"]={16898734792,{256,256},{257,514}},["mail-question"]={16898675156,{256,256},{257,257}},["clipboard-plus"]={16898618392,{256,256},{257,0}},["file-minus"]={16898670241,{256,256},{514,0}},["list-end"]={16898674482,{256,256},{257,514}},torus={16898788908,{256,256},{0,0}},["arrow-down-left"]={16898613869,{256,256},{257,514}},["chevrons-right"]={16898617626,{256,256},{0,514}},["file-badge-2"]={16898669984,{256,256},{257,257}},["message-square-reply"]={16898728402,{256,256},{257,0}},["corner-down-right"]={16898668288,{256,256},{0,257}},["gauge-circle"]={16898672166,{256,256},{257,257}},["users-2"]={16898790259,{256,256},{257,0}},["lamp-wall-down"]={16898673794,{256,256},{0,514}},["square-bottom-dashed-scissors"]={16898735664,{256,256},{514,257}},["repeat"]={16898733146,{256,256},{257,514}},["ellipsis-vertical"]={16898669772,{256,256},{0,0}},snail={16898735175,{256,256},{257,0}},check={16898617411,{256,256},{257,0}},["square-parking"]={16898736237,{256,256},{514,0}},["align-horizontal-justify-end"]={16898613353,{256,256},{514,0}},["mail-search"]={16898675156,{256,256},{0,514}},["align-vertical-distribute-end"]={16898613509,{256,256},{257,257}},soup={16898735175,{256,256},{257,257}},airplay={16898612629,{256,256},{257,514}},pentagon={16898731419,{256,256},{514,514}},["rocking-chair"]={16898733317,{256,256},{514,257}},["between-horizontal-start"]={16898615428,{256,256},{257,514}},["monitor-x"]={16898729141,{256,256},{0,514}},["octagon-pause"]={16898730298,{256,256},{514,514}},["square-kanban"]={16898736072,{256,256},{0,514}},["square-pen"]={16898736237,{256,256},{257,257}},["rectangle-vertical"]={16898733036,{256,256},{0,257}},["panels-right-bottom"]={16898731166,{256,256},{257,257}},["gantt-chart"]={16898672166,{256,256},{514,0}},octagon={16898730417,{256,256},{257,0}},ticket={16898788789,{256,256},{0,257}},pocket={16898732061,{256,256},{0,514}},["link-2"]={16898674482,{256,256},{0,257}},["train-front"]={16898788908,{256,256},{514,514}},["spray-can"]={16898735455,{256,256},{514,514}},["arrow-up-0-1"]={16898614275,{256,256},{257,257}},album={16898612819,{256,256},{514,514}},replace={16898733317,{256,256},{0,0}},["move-right"]={16898729752,{256,256},{0,0}},["hand-helping"]={16898672829,{256,256},{0,257}},["list-collapse"]={16898674482,{256,256},{514,257}},gauge={16898672166,{256,256},{0,514}},store={16898736776,{256,256},{514,514}},["circle-arrow-down"]={16898617705,{256,256},{257,257}},["notebook-pen"]={16898730065,{256,256},{514,514}},["egg-fried"]={16898669689,{256,256},{514,257}},ligature={16898674337,{256,256},{514,257}},["sticky-note"]={16898736776,{256,256},{514,257}},["corner-right-up"]={16898668288,{256,256},{514,257}},["badge-help"]={16898614945,{256,256},{514,0}},["panel-top-inactive"]={16898731166,{256,256},{0,0}},["user-round-plus"]={16898790047,{256,256},{0,0}},["panel-left-close"]={16898730821,{256,256},{514,257}},rewind={16898733317,{256,256},{514,0}},fuel={16898672004,{256,256},{257,0}},["divide-circle"]={16898669271,{256,256},{0,514}},["square-arrow-out-up-right"]={16898735664,{256,256},{0,0}},["chevrons-down-up"]={16898617626,{256,256},{0,0}},["message-square-text"]={16898728402,{256,256},{514,0}},["user-round-search"]={16898790047,{256,256},{257,0}},scan={16898733817,{256,256},{514,0}},["monitor-down"]={16898728878,{256,256},{514,257}},["play-circle"]={16898731919,{256,256},{514,0}},["file-digit"]={16898670072,{256,256},{257,514}},slash={16898735040,{256,256},{0,0}},["split-square-vertical"]={16898735455,{256,256},{514,257}},aperture={16898613699,{256,256},{257,0}},["arrow-right-left"]={16898614275,{256,256},{0,0}},["helping-hand"]={16898673271,{256,256},{514,0}},["flask-conical-off"]={16898670919,{256,256},{0,514}},["circle-gauge"]={16898617884,{256,256},{514,514}},crosshair={16898668482,{256,256},{514,257}},["move-down-right"]={16898729572,{256,256},{0,514}},["text-search"]={16898788479,{256,256},{0,514}},["square-slash"]={16898736398,{256,256},{0,514}},sandwich={16898733534,{256,256},{257,514}},factory={16898669897,{256,256},{0,257}},["chef-hat"]={16898617411,{256,256},{0,257}},["arrow-down-to-dot"]={16898614020,{256,256},{257,257}},["image-plus"]={16898673447,{256,256},{0,257}},["file-archive"]={16898669984,{256,256},{0,0}},["signal-high"]={16898734792,{256,256},{514,257}},inbox={16898673447,{256,256},{257,514}},["flip-horizontal-2"]={16898670919,{256,256},{514,514}},["book-type"]={16898616322,{256,256},{514,514}},["file-signature"]={16898670367,{256,256},{514,257}},["align-horizontal-space-between"]={16898613353,{256,256},{514,257}},["bookmark-minus"]={16898616524,{256,256},{514,257}},["calendar-check"]={16898616953,{256,256},{257,257}},["database-zap"]={16898668755,{256,256},{257,257}},droplets={16898669562,{256,256},{514,257}},boxes={16898616650,{256,256},{514,257}},["bell-electric"]={16898615428,{256,256},{0,0}},["bar-chart"]={16898615143,{256,256},{257,514}},["layout-list"]={16898674182,{256,256},{257,257}},link={16898674482,{256,256},{514,0}},["download-cloud"]={16898669433,{256,256},{514,514}},["alarm-clock-plus"]={16898612819,{256,256},{514,0}},["circle-dollar-sign"]={16898617884,{256,256},{0,257}},["activity-square"]={16898612629,{256,256},{257,257}},["arrow-up-square"]={16898614574,{256,256},{0,0}},["receipt-pound-sterling"]={16898732855,{256,256},{257,257}},grab={16898672599,{256,256},{514,257}},["align-center-horizontal"]={16898613044,{256,256},{514,0}},undo={16898789451,{256,256},{0,0}},ratio={16898732665,{256,256},{514,514}},minimize={16898728878,{256,256},{0,0}},["user-square-2"]={16898790047,{256,256},{0,514}},heading={16898673115,{256,256},{0,257}},["panel-top-close"]={16898731024,{256,256},{257,514}},["grip-horizontal"]={16898672700,{256,256},{0,257}},["boom-box"]={16898616650,{256,256},{257,0}},package={16898730641,{256,256},{514,0}},["user-round-minus"]={16898789825,{256,256},{514,514}},["file-audio-2"]={16898669984,{256,256},{257,0}},["align-end-horizontal"]={16898613044,{256,256},{514,257}},mountain={16898729337,{256,256},{514,0}},["arrow-down-left-square"]={16898613869,{256,256},{514,257}},["folder-kanban"]={16898671263,{256,256},{0,257}},["octagon-x"]={16898730417,{256,256},{0,0}},languages={16898673999,{256,256},{257,0}},["file-json-2"]={16898670171,{256,256},{257,257}},["alarm-clock-check"]={16898612819,{256,256},{0,0}},["refresh-cw"]={16898733146,{256,256},{257,0}},medal={16898675673,{256,256},{0,0}},["beer-off"]={16898615374,{256,256},{514,257}},["search-code"]={16898734065,{256,256},{257,514}},["square-parking-off"]={16898736237,{256,256},{0,257}},["notebook-text"]={16898730298,{256,256},{257,0}},["arrow-right-to-line"]={16898614275,{256,256},{0,257}},["ticket-minus"]={16898788660,{256,256},{514,257}},["test-tube-diagonal"]={16898788248,{256,256},{514,514}},["rows-4"]={16898733534,{256,256},{0,0}},["pencil-line"]={16898731419,{256,256},{0,514}},["door-open"]={16898669433,{256,256},{514,257}},["arrow-down-circle"]={16898613869,{256,256},{514,0}},["pen-line"]={16898731419,{256,256},{257,0}},file={16898670620,{256,256},{0,514}},["git-compare"]={16898672316,{256,256},{514,257}},["pocket-knife"]={16898732061,{256,256},{257,257}},["book-copy"]={16898616080,{256,256},{0,257}},["panel-left-inactive"]={16898730821,{256,256},{514,514}},["car-front"]={16898617249,{256,256},{257,0}},["align-start-horizontal"]={16898613509,{256,256},{257,0}},["reply-all"]={16898733317,{256,256},{257,0}},["cloud-moon-rain"]={16898618763,{256,256},{257,514}},["clipboard-type"]={16898618392,{256,256},{514,0}},["contact-2"]={16898619347,{256,256},{257,257}},["list-todo"]={16898674572,{256,256},{514,257}},tablets={16898788033,{256,256},{257,0}},["pie-chart"]={16898731819,{256,256},{0,0}},["list-start"]={16898674572,{256,256},{0,514}},milestone={16898728659,{256,256},{0,514}},["a-large-small"]={16898612629,{256,256},{0,257}},ship={16898734664,{256,256},{514,0}},["percent-circle"]={16898731539,{256,256},{0,0}},radiation={16898732504,{256,256},{514,514}},["code-2"]={16898619015,{256,256},{0,257}},["tablet-smartphone"]={16898787819,{256,256},{514,514}},["phone-forwarded"]={16898731539,{256,256},{514,257}},["gallery-vertical"]={16898672004,{256,256},{514,514}},["arrow-right-from-line"]={16898614166,{256,256},{514,514}},webcam={16898790996,{256,256},{0,0}},["square-power"]={16898736398,{256,256},{257,0}},["circle-help"]={16898617944,{256,256},{0,0}},["bring-to-front"]={16898616757,{256,256},{257,514}},archive={16898613699,{256,256},{257,514}},figma={16898669897,{256,256},{514,514}},school={16898733817,{256,256},{514,257}},download={16898669562,{256,256},{0,0}},piano={16898731683,{256,256},{0,514}},["line-chart"]={16898674482,{256,256},{0,0}},folders={16898671684,{256,256},{0,257}},["mail-warning"]={16898675156,{256,256},{514,257}},vault={16898790259,{256,256},{514,514}},["pause-circle"]={16898731301,{256,256},{0,514}},["mic-2"]={16898728402,{256,256},{514,514}},["chevrons-left-right"]={16898617626,{256,256},{0,257}},redo={16898733036,{256,256},{514,257}},["file-lock"]={16898670241,{256,256},{257,0}},radar={16898732504,{256,256},{257,514}},["circle-fading-plus"]={16898617884,{256,256},{257,514}},workflow={16898791187,{256,256},{514,0}},["undo-dot"]={16898789303,{256,256},{514,514}},target={16898788248,{256,256},{257,0}},["corner-left-down"]={16898668288,{256,256},{514,0}},["indent-increase"]={16898673523,{256,256},{0,0}},drama={16898669562,{256,256},{0,257}},["arrow-down-up"]={16898614020,{256,256},{514,257}},baseline={16898615240,{256,256},{0,0}},martini={16898675359,{256,256},{514,257}},contrast={16898619347,{256,256},{514,514}},["shield-ban"]={16898734564,{256,256},{257,0}},syringe={16898787819,{256,256},{0,0}},["chevron-left-circle"]={16898617509,{256,256},{0,0}},["book-check"]={16898616080,{256,256},{257,0}},["nut-off"]={16898730298,{256,256},{0,514}},["book-lock"]={16898616322,{256,256},{0,0}},["panel-right-inactive"]={16898731024,{256,256},{257,257}},["briefcase-medical"]={16898616757,{256,256},{0,514}},bookmark={16898616650,{256,256},{0,0}},["heading-5"]={16898673115,{256,256},{0,0}},["align-vertical-justify-end"]={16898613509,{256,256},{257,514}},["hop-off"]={16898673271,{256,256},{514,514}},warehouse={16898790791,{256,256},{257,257}},["plus-square"]={16898732061,{256,256},{0,257}},["drafting-compass"]={16898669562,{256,256},{257,0}},["save-all"]={16898733674,{256,256},{257,0}},["plus-circle"]={16898732061,{256,256},{257,0}},["square-sigma"]={16898736398,{256,256},{257,257}},["clipboard-signature"]={16898618392,{256,256},{0,257}},["fold-horizontal"]={16898671019,{256,256},{514,257}},["notepad-text-dashed"]={16898730298,{256,256},{514,0}},["glass-water"]={16898672599,{256,256},{0,0}},["book-headphones"]={16898616080,{256,256},{0,514}},["credit-card"]={16898668482,{256,256},{0,257}},["message-circle"]={16898675863,{256,256},{0,0}},["square-pilcrow"]={16898736237,{256,256},{257,514}},radical={16898732665,{256,256},{0,0}},["tally-3"]={16898788033,{256,256},{514,257}},["panel-bottom-open"]={16898730821,{256,256},{257,257}},["kanban-square-dashed"]={16898673616,{256,256},{514,0}},["book-audio"]={16898616080,{256,256},{0,0}},["file-search-2"]={16898670367,{256,256},{257,257}},["receipt-russian-ruble"]={16898732855,{256,256},{0,514}},["square-arrow-up-left"]={16898735664,{256,256},{0,257}},["locate-fixed"]={16898674684,{256,256},{0,514}},["clock-9"]={16898618583,{256,256},{514,514}},pen={16898731419,{256,256},{257,257}},["navigation-2"]={16898730065,{256,256},{0,257}},["candy-cane"]={16898617146,{256,256},{257,257}},["book-open"]={16898616322,{256,256},{0,514}},["user-check-2"]={16898789644,{256,256},{0,514}},["gamepad-2"]={16898672166,{256,256},{0,0}},["badge-info"]={16898614945,{256,256},{0,514}},wheat={16898790996,{256,256},{0,514}},["roller-coaster"]={16898733317,{256,256},{257,514}},["arrow-down-right-square"]={16898614020,{256,256},{257,0}},["shield-minus"]={16898734564,{256,256},{0,514}},thermometer={16898788660,{256,256},{0,257}},dessert={16898668755,{256,256},{257,514}},eclipse={16898669689,{256,256},{0,514}},church={16898617705,{256,256},{0,0}},combine={16898619182,{256,256},{0,514}},cylinder={16898668755,{256,256},{0,257}},["badge-japanese-yen"]={16898614945,{256,256},{514,257}},["calendar-plus-2"]={16898617053,{256,256},{514,0}},["receipt-text"]={16898732855,{256,256},{257,514}},film={16898670620,{256,256},{257,514}},["book-down"]={16898616080,{256,256},{257,257}},asterisk={16898614574,{256,256},{514,257}},cable={16898616879,{256,256},{514,514}},["file-output"]={16898670241,{256,256},{0,514}},["disc-album"]={16898669271,{256,256},{514,0}},["percent-square"]={16898731539,{256,256},{0,257}},["arrow-down-0-1"]={16898613869,{256,256},{0,0}},captions={16898617249,{256,256},{0,0}},diameter={16898668755,{256,256},{514,514}},bone={16898615799,{256,256},{257,514}},["umbrella-off"]={16898789303,{256,256},{257,257}},["badge-alert"]={16898614755,{256,256},{257,514}},flashlight={16898670919,{256,256},{257,257}},["folder-pen"]={16898671463,{256,256},{0,0}},cross={16898668482,{256,256},{0,514}},["badge-dollar-sign"]={16898614945,{256,256},{257,0}},["ice-cream-bowl"]={16898673358,{256,256},{0,514}},worm={16898791187,{256,256},{257,257}},["square-arrow-down-left"]={16898735593,{256,256},{0,257}},["share-2"]={16898734421,{256,256},{0,514}},["circle-arrow-out-down-right"]={16898617705,{256,256},{257,514}},["ear-off"]={16898669689,{256,256},{257,0}},wifi={16898790996,{256,256},{514,514}},["message-square-off"]={16898675863,{256,256},{257,514}},["tv-2"]={16898789153,{256,256},{514,514}},fish={16898670775,{256,256},{0,514}},sliders={16898735040,{256,256},{257,257}},["stretch-horizontal"]={16898736967,{256,256},{0,0}},currency={16898668755,{256,256},{257,0}},coffee={16898619015,{256,256},{257,514}},["message-circle-reply"]={16898675752,{256,256},{514,257}},route={16898733415,{256,256},{0,514}},["triangle-right"]={16898789153,{256,256},{514,0}},["folder-clock"]={16898671139,{256,256},{257,0}},["circle-off"]={16898617944,{256,256},{0,257}},["message-square-plus"]={16898675863,{256,256},{514,514}},type={16898789303,{256,256},{514,0}},webhook={16898790996,{256,256},{0,257}},["candlestick-chart"]={16898617146,{256,256},{514,0}},phone={16898731683,{256,256},{0,257}},["package-2"]={16898730417,{256,256},{0,514}},["chevrons-left"]={16898617626,{256,256},{514,0}},["pointer-off"]={16898732061,{256,256},{257,514}},turtle={16898789153,{256,256},{257,514}},camera={16898617146,{256,256},{0,257}},["thermometer-snowflake"]={16898788660,{256,256},{0,0}},clipboard={16898618392,{256,256},{0,514}},["send-horizontal"]={16898734242,{256,256},{0,257}},["bluetooth-searching"]={16898615799,{256,256},{0,257}},["arrow-up-to-line"]={16898614574,{256,256},{257,0}},["wrap-text"]={16898791187,{256,256},{0,514}},["file-check-2"]={16898670072,{256,256},{0,0}},["badge-percent"]={16898614945,{256,256},{514,514}},shuffle={16898734792,{256,256},{514,0}},refrigerator={16898733146,{256,256},{0,257}},["rows-3"]={16898733415,{256,256},{514,514}},sigma={16898734792,{256,256},{0,514}},["milk-off"]={16898728659,{256,256},{514,257}},["file-check"]={16898670072,{256,256},{257,0}},["pin-off"]={16898731819,{256,256},{0,514}},["clock-1"]={16898618392,{256,256},{514,257}},["file-heart"]={16898670171,{256,256},{257,0}},beaker={16898615240,{256,256},{514,514}},space={16898735175,{256,256},{0,514}},users={16898790259,{256,256},{514,0}},["shield-question"]={16898734564,{256,256},{514,514}},["arrow-up-circle"]={16898614275,{256,256},{257,514}},["corner-up-left"]={16898668288,{256,256},{257,514}},["clock-6"]={16898618583,{256,256},{0,514}},["layout-dashboard"]={16898674182,{256,256},{0,257}},["key-round"]={16898673616,{256,256},{514,257}},headphones={16898673115,{256,256},{514,0}},tv={16898789303,{256,256},{0,0}},["brain-circuit"]={16898616757,{256,256},{0,0}},["bar-chart-horizontal-big"]={16898615143,{256,256},{0,514}},rss={16898733534,{256,256},{0,257}},["file-stack"]={16898670469,{256,256},{0,0}},["at-sign"]={16898614574,{256,256},{257,514}},code={16898619015,{256,256},{257,257}},["calendar-minus"]={16898617053,{256,256},{257,0}},music={16898730065,{256,256},{0,0}},handshake={16898672829,{256,256},{514,257}},["graduation-cap"]={16898672599,{256,256},{257,514}},tornado={16898788789,{256,256},{514,514}},["copy-plus"]={16898619423,{256,256},{257,257}},stamp={16898736597,{256,256},{257,514}},cherry={16898617411,{256,256},{514,0}},shrink={16898734792,{256,256},{257,0}},["circle-arrow-out-up-right"]={16898617803,{256,256},{0,0}},meh={16898675673,{256,256},{514,0}},["search-check"]={16898734065,{256,256},{514,257}},crop={16898668482,{256,256},{257,257}},["columns-2"]={16898619182,{256,256},{257,0}},["mouse-pointer-square"]={16898729337,{256,256},{257,514}},["indent-decrease"]={16898673447,{256,256},{514,514}},["align-center-vertical"]={16898613044,{256,256},{257,257}},["wand-2"]={16898790791,{256,256},{257,0}},anvil={16898613699,{256,256},{0,0}},["align-start-vertical"]={16898613509,{256,256},{0,257}},["cloud-fog"]={16898618763,{256,256},{257,257}},accessibility={16898612629,{256,256},{514,0}},layers={16898674182,{256,256},{257,0}},["percent-diamond"]={16898731539,{256,256},{257,0}},["package-check"]={16898730417,{256,256},{514,257}},["chevron-first"]={16898617411,{256,256},{257,514}},pencil={16898731419,{256,256},{257,514}},["database-backup"]={16898668755,{256,256},{514,0}},["list-x"]={16898674684,{256,256},{0,0}},shapes={16898734421,{256,256},{257,257}},["move-down"]={16898729572,{256,256},{514,257}},["corner-up-right"]={16898668288,{256,256},{514,514}},computer={16898619347,{256,256},{0,0}},pin={16898731819,{256,256},{514,257}},["phone-off"]={16898731683,{256,256},{0,0}},["clipboard-x"]={16898618392,{256,256},{257,257}},fullscreen={16898672004,{256,256},{0,257}},["align-horizontal-distribute-start"]={16898613353,{256,256},{257,0}},["redo-dot"]={16898733036,{256,256},{0,514}},["cloud-moon"]={16898618763,{256,256},{514,514}},["stretch-vertical"]={16898736967,{256,256},{257,0}},["message-square-warning"]={16898728402,{256,256},{257,257}},["file-plus"]={16898670367,{256,256},{257,0}},["git-pull-request-arrow"]={16898672450,{256,256},{257,0}},guitar={16898672700,{256,256},{514,257}},tangent={16898788248,{256,256},{0,0}},["bell-dot"]={16898615374,{256,256},{514,514}},["panel-bottom"]={16898730821,{256,256},{0,514}},["flame-kindling"]={16898670919,{256,256},{257,0}},["table-2"]={16898787819,{256,256},{257,0}},["align-horizontal-space-around"]={16898613353,{256,256},{0,514}},server={16898734421,{256,256},{257,0}},["briefcase-business"]={16898616757,{256,256},{257,257}},diamond={16898669042,{256,256},{257,0}},blinds={16898615570,{256,256},{257,514}},weight={16898790996,{256,256},{514,0}},candy={16898617146,{256,256},{514,257}},["volume-1"]={16898790615,{256,256},{0,0}},["table-properties"]={16898787819,{256,256},{0,514}},["git-fork"]={16898672316,{256,256},{257,514}},recycle={16898733036,{256,256},{514,0}},["mountain-snow"]={16898729337,{256,256},{0,257}},luggage={16898674825,{256,256},{514,257}},["divide-square"]={16898669271,{256,256},{514,257}},["folder-minus"]={16898671263,{256,256},{0,514}},["phone-outgoing"]={16898731683,{256,256},{257,0}},["smartphone-charging"]={16898735040,{256,256},{0,514}},banknote={16898615143,{256,256},{0,0}},["train-track"]={16898789012,{256,256},{0,0}},["folder-up"]={16898671463,{256,256},{514,514}},["circle-percent"]={16898617944,{256,256},{514,257}},["bell-plus"]={16898615428,{256,256},{514,0}},fan={16898669897,{256,256},{514,0}},["disc-2"]={16898669271,{256,256},{257,0}},["git-pull-request-draft"]={16898672450,{256,256},{0,514}},coins={16898619182,{256,256},{0,0}},["square-divide"]={16898736072,{256,256},{0,0}},scroll={16898734065,{256,256},{0,514}},["circle-arrow-right"]={16898617803,{256,256},{257,0}},["candy-off"]={16898617146,{256,256},{0,514}},["square-pi"]={16898736237,{256,256},{514,257}},["arrow-left-right"]={16898614166,{256,256},{514,0}},["lightbulb-off"]={16898674337,{256,256},{257,514}},["panels-top-left"]={16898731166,{256,256},{0,514}},["move-up-right"]={16898729752,{256,256},{0,257}},["message-square-share"]={16898728402,{256,256},{0,257}},annoyed={16898613613,{256,256},{257,514}},["test-tube"]={16898788479,{256,256},{0,0}},["user-circle"]={16898789644,{256,256},{514,514}},["cooking-pot"]={16898619423,{256,256},{257,0}},["case-lower"]={16898617249,{256,256},{514,257}},["alarm-clock-minus"]={16898612819,{256,256},{257,0}},["square-user"]={16898736597,{256,256},{0,257}},square={16898736597,{256,256},{257,257}},["mail-open"]={16898675156,{256,256},{0,257}},["square-function"]={16898736072,{256,256},{514,0}},["arrow-up-left-from-circle"]={16898614410,{256,256},{0,257}},variable={16898790259,{256,256},{257,514}},["arrow-up-right-square"]={16898614410,{256,256},{257,514}},["badge-indian-rupee"]={16898614945,{256,256},{257,257}}}}



-- ========================
-- Theme Module
-- ========================

-- RvrseUI Theme Module v4.0
-- =========================
-- Next-gen vibrant design system with stunning gradients and modern aesthetics
-- Complete redesign - removed Light theme, focusing on one amazing dark experience

Theme = {}

-- 🎨 REVOLUTIONARY COLOR PALETTE - Cyberpunk Neon meets Modern Minimalism
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

-- Default to the new Dark theme (only theme available)
Theme.Current = "Dark"
Theme._dirty = false  -- Dirty flag: true if user changed theme in-session
Theme._listeners = {}  -- Theme change listeners

-- Get current palette
function Theme:Get()
	return self.Palettes[self.Current]
end

-- Apply theme without marking dirty (used for initialization)
function Theme:Apply(mode, Debug)
	if self.Palettes[mode] then
		self.Current = mode
		if Debug then
			Debug:Print("Theme applied:", mode)
		end
	end
end

-- Switch theme and mark as dirty (used for user changes)
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

-- Register a theme change listener
function Theme:RegisterListener(callback)
	table.insert(self._listeners, callback)
end

-- Clear all listeners (useful for cleanup)
function Theme:ClearListeners()
	self._listeners = {}
end

-- Initialize method (called by init.lua)
function Theme:Initialize()
	-- Theme is ready to use, no initialization needed
	-- Palettes are defined at module load time
end




-- ========================
-- Animator Module
-- ========================

-- RvrseUI Animator Module v4.0
-- =========================
-- Next-generation animation system with buttery-smooth transitions
-- Redesigned for maximum responsiveness across PC, mobile, and console

local TweenService = game:GetService("TweenService")

Animator = {}

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
	glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	glow.LineJoinMode = Enum.LineJoinMode.Round
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




-- ========================
-- State Module
-- ========================

-- RvrseUI State Module
-- =========================
-- Handles global state management including locks and flags
-- Extracted from RvrseUI.lua (lines 57, 900-914, 1287-1288)

State = {}

-- Global flag storage for all elements
State.Flags = {}

-- Lock system for master/child relationships
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

-- Set lock state for a group
function State.Locks:SetLocked(group, isLocked)
	if not group then return end
	self._locks[group] = isLocked and true or false
	-- Trigger all lock listeners
	for _, fn in ipairs(self._listeners) do
		pcall(fn)
	end
end

-- Check if a group is locked
function State.Locks:IsLocked(group)
	return group and self._locks[group] == true
end

-- Register a lock change listener
function State.Locks:RegisterListener(callback)
	table.insert(self._listeners, callback)
end

-- Clear all listeners (useful for cleanup)
function State.Locks:ClearListeners()
	self._listeners = {}
end

-- Initialize method (called by init.lua)
function State:Initialize()
	-- State is ready to use, no initialization needed
	-- Flags and Locks are defined at module load time
end




-- ========================
-- UIHelpers Module
-- ========================

-- RvrseUI UIHelpers Module
-- =========================
-- Helper functions for creating UI elements
-- Extracted from RvrseUI.lua (lines 919-1032)

local TweenService = game:GetService("TweenService")

UIHelpers = {}

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




-- ========================
-- Config Module
-- ========================

-- CONFIGURATION MODULE
-- ============================================
-- Handles save/load system for RvrseUI
-- Supports file-based persistence with folder structure
-- Integrates with State (Flags) and Theme modules
-- ⚠️ Maintainers: The save/load pipeline is tightly coupled to
--    the live RvrseUI context. Do not refactor these functions
--    without replicating the v3.0.3 behaviour (context hand-off,
--    theme cache preservation, last-profile parsing).
-- ============================================

Config = {}

-- Module dependencies (injected on initialization)
local State = nil
local Theme = nil
local dprintf = nil

-- Services
local HttpService = game:GetService("HttpService")

-- ============================================
-- MODULE PROPERTIES
-- ============================================

Config.ConfigurationSaving = false  -- Enabled via CreateWindow
Config.ConfigurationFileName = nil  -- Set via CreateWindow
Config.ConfigurationFolderName = nil  -- Optional folder name
Config._configCache = {}  -- In-memory config cache
Config._lastSaveTime = nil  -- Debounce timestamp
Config._lastContext = nil  -- Most recent RvrseUI instance used for persistence
Config.AutoSaveEnabled = true  -- Auto-save flag (can be disabled via configuration)

-- ============================================
-- EXECUTOR FILE-SYSTEM PROBE
-- ============================================

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

-- ============================================
-- INITIALIZATION
-- ============================================

function Config:Init(dependencies)
	State = dependencies.State
	Theme = dependencies.Theme
	dprintf = dependencies.dprintf or function() end
	self._lastContext = nil
	self.AutoSaveEnabled = true

	traceFsSupport("Init")

	return self
end

-- ============================================
-- SAVE CONFIGURATION
-- ============================================

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

-- ============================================
-- LOAD CONFIGURATION
-- ============================================

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
	local hydrationQueue = {}
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
			local element = flagSource[flagName]
			local okSet, errSet = pcall(element.Set, element, value)
			if okSet then
				loadedCount = loadedCount + 1
				if element.Hydrate then
					hydrationQueue[#hydrationQueue + 1] = { element = element, value = value }
				end
			elseif dprintf then
				dprintf(string.format("[Config] Flag '%s' set failed: %s", flagName, tostring(errSet)))
			end
		end
	end

	for _, item in ipairs(hydrationQueue) do
		local element = item.element
		local okHydrate, errHydrate = pcall(element.Hydrate, element, item.value)
		if not okHydrate and dprintf then
			dprintf(string.format("[Config] Hydrate failed: %s", tostring(errHydrate)))
		end
	end

	self._configCache = result
	dprintf(string.format("Configuration loaded: %d elements restored", loadedCount))

	return true, string.format("Loaded %d elements", loadedCount)
end

-- ============================================
-- AUTO-SAVE HELPER
-- ============================================

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

-- ============================================
-- DELETE CONFIGURATION
-- ============================================

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

-- ============================================
-- CONFIGURATION EXISTS CHECK
-- ============================================

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

-- ============================================
-- GET LAST CONFIG
-- ============================================

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

-- ============================================
-- SAVE LAST CONFIG REFERENCE
-- ============================================

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

-- ============================================
-- LOAD CONFIGURATION BY NAME
-- ============================================

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

-- ============================================
-- SAVE CONFIGURATION AS
-- ============================================

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

-- ============================================
-- LIST PROFILES
-- ============================================

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

-- ============================================
-- SET ACTIVE PROFILE
-- ============================================

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

-- ============================================
-- DELETE PROFILE
-- ============================================

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

-- Manages the root ScreenGui host and global window operations
-- Dependencies: CoreGui, PlayerGui, NameObfuscator

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

WindowManager = {}

-- Initialize the WindowManager with dependencies
function WindowManager:Init(obfuscatedNames)
	self._host = nil
	self._windows = {}
	self._obfuscatedNames = obfuscatedNames

	-- Create root ScreenGui host
	self:CreateHost()

	return self._host
end

-- Create the root ScreenGui container
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

-- Register a window with the manager
function WindowManager:RegisterWindow(window)
	table.insert(self._windows, window)
end

-- Global destroy method - destroys ALL UI
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

-- Global visibility toggle - hides/shows ALL windows
function WindowManager:ToggleVisibility()
	if self._host and self._host.Parent then
		self._host.Enabled = not self._host.Enabled
		return self._host.Enabled
	end
	return false
end

-- Set visibility explicitly
function WindowManager:SetVisibility(visible)
	if self._host and self._host.Parent then
		self._host.Enabled = visible
		return true
	end
	return false
end

-- Get the host ScreenGui
function WindowManager:GetHost()
	return self._host
end

-- Get all registered windows
function WindowManager:GetWindows()
	return self._windows
end

-- Clear specific listeners (for cleanup)
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

-- Initialize method (called by init.lua)
function WindowManager:Initialize()
	-- WindowManager is ready to use
	-- _host and _windows will be set when CreateHost is called
end




-- ========================
-- Hotkeys Module
-- ========================

-- Manages global UI toggle/destroy hotkeys with minimize state tracking
-- Dependencies: UserInputService, coerceKeycode utility

local UIS = game:GetService("UserInputService")

Hotkeys = {}
Hotkeys.UI = {
	_toggleTargets = {},
	_windowData = {},
	_key = Enum.KeyCode.K,
	_escapeKey = Enum.KeyCode.Escape
}
Hotkeys._initialized = false

-- Utility: Convert string/KeyCode to Enum.KeyCode
local function coerceKeycode(k)
	if typeof(k) == "EnumItem" and k.EnumType == Enum.KeyCode then return k end
	if typeof(k) == "string" and #k > 0 then
		local up = k:upper():gsub("%s", "")
		if Enum.KeyCode[up] then return Enum.KeyCode[up] end
	end
	return Enum.KeyCode.K
end

-- Register a window frame for hotkey control
-- windowData: { isMinimized (function/bool), minimizeFunction, restoreFunction, destroyFunction }
function Hotkeys.UI:RegisterToggleTarget(frame, windowData)
	self._toggleTargets[frame] = true
	if windowData then
		self._windowData[frame] = windowData
	end
end

-- Bind the toggle/minimize key (default: K)
function Hotkeys.UI:BindToggleKey(key)
	self._key = coerceKeycode(key or "K")
end

-- Bind the destroy key (default: Escape)
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

-- Initialize hotkey listeners
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

-- Initialize method (called by init.lua)
function Hotkeys:Initialize(deps)
	-- Hotkeys system is ready to use
	-- deps contains: UserInputService, WindowManager
	-- Input listeners are set up when BindToggleKey is called
	self:Init()
end




-- ========================
-- Notifications Module
-- ========================

-- Notifications Module
-- =========================
-- Extracted from RvrseUI.lua (lines 1066-1179)
-- Provides toast notification system with animations and priority support

Notifications = {}

-- Helper functions (must be passed as dependencies)
local corner, stroke

-- Dependencies
local Theme, Animator, host, Icons

-- Module state
local notifyRoot
-- [Removed conflicting local RvrseUI]

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




-- ========================
-- Overlay Module
-- ========================

-- Overlay Service Module
-- =========================
-- Manages a dedicated ScreenGui for popovers, dropdown blockers,
-- and modal dimming. Ensures a single overlay host is reused and
-- exposes helpers to show/hide the global blocker.

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




-- ========================
-- KeySystem Module
-- ========================

-- Advanced key validation system with multiple authentication methods
-- Supports: String keys, Remote keys, HWID whitelist, Discord webhooks

KeySystem = {}
local deps

function KeySystem:Initialize(dependencies)
	deps = dependencies
end

-- Validate key against configured settings
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

-- Fetch remote key from URL
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

-- Save validated key to file
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

-- Load saved key from file
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

-- Send webhook notification (Discord logging)
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

-- Create key validation UI
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
	Border.LineJoinMode = Enum.LineJoinMode.Round
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
		NoteBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		NoteBtnStroke.LineJoinMode = Enum.LineJoinMode.Round
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
	InputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	InputStroke.LineJoinMode = Enum.LineJoinMode.Round
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

-- Main entry point: Process key system for window
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




-- ========================
-- Particles Module
-- ========================

-- RvrseUI "Spore Bubble" Particle System
-- GPU-cheap organic particle effects with Perlin noise drift

Particles = {}
local deps

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
PerlinNoise = {}
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

	return particle
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
		baseVelY = -(math.random() * (45 - 20) + 20), -- -20 to -45 px/s (negative = up)
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
	particle.BackgroundColor3 = data.color
	particle.BackgroundTransparency = 1 - data.currentOpacity
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

-- Main update loop (RunService heartbeat)
local function onHeartbeat(dt)
	if not Config.Enabled or not isPlaying then return end

	spawnLoop(dt)
	updateParticles(dt)
end

-- Public API
function Particles:Initialize(dependencies)
	deps = dependencies
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




-- ========================
-- Button Module
-- ========================

-- Next-gen vibrant button with gradient background and glow effects
-- Complete redesign for RvrseUI v4.0

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
	local Icons = dependencies.Icons
	local isLightTheme = Theme and Theme.Current == "Light"

	-- Create container with gradient background
	local f = card(48) -- Slightly taller for modern look
	f.BackgroundColor3 = pal3.Card
	f.BackgroundTransparency = isLightTheme and 0 or 0.2

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
	stroke.LineJoinMode = Enum.LineJoinMode.Round
	stroke.Parent = f

	-- Main button
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.AutoButtonColor = false
	btn.Text = ""
	btn.Parent = f

	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "Content"
	contentFrame.BackgroundTransparency = 1
	contentFrame.Size = UDim2.new(1, 0, 1, 0)
	contentFrame.Parent = btn

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "ButtonLabel"
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(1, -8, 1, 0)
	textLabel.Position = UDim2.new(0, 4, 0, 0)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = 15
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextColor3 = o.TextColor or pal3.TextBright
	textLabel.Text = o.Text or "Button"
	textLabel.TextWrapped = false
	textLabel.Parent = contentFrame

	local cardPadding = f:FindFirstChildOfClass("UIPadding")
	local basePadLeft = cardPadding and cardPadding.PaddingLeft.Offset or 0

	local ICON_MARGIN = 12
	local ICON_SIZE = 24

	local iconHolder = Instance.new("Frame")
	iconHolder.BackgroundTransparency = 1
	iconHolder.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
	iconHolder.AnchorPoint = Vector2.new(0, 0.5)
	iconHolder.Position = UDim2.new(0, math.max(0, ICON_MARGIN - basePadLeft), 0.5, 0)
	iconHolder.ClipsDescendants = true
	iconHolder.Visible = false
	iconHolder.ZIndex = textLabel.ZIndex + 1
	iconHolder.Parent = contentFrame

	local iconInstance = nil
	local defaultIconColor = o.IconColor or pal3.TextBright
	local defaultTextColor = textLabel.TextColor3
	local currentIcon = o.Icon
	local currentText = textLabel.Text
	local isHovering = false

	local function updateTextPadding(hasIcon)
		if hasIcon then
			local leftInset = ICON_MARGIN + ICON_SIZE + 6
			local relativeOffset = math.max(0, leftInset - basePadLeft)
			textLabel.Position = UDim2.new(0, relativeOffset, 0, 0)
			textLabel.Size = UDim2.new(1, -(relativeOffset + 8), 1, 0)
		else
			textLabel.Position = UDim2.new(0, 4, 0, 0)
			textLabel.Size = UDim2.new(1, -8, 1, 0)
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
		updateTextPadding(false)
	end

	local function tweenIconColor(color, spring)
		if not iconInstance then return end
		local props
		if iconInstance:IsA("ImageLabel") then
			props = {ImageColor3 = color}
		else
			props = {TextColor3 = color}
		end
		Animator:Tween(iconInstance, props, spring)
	end

	local function setIconTransparency(amount)
		if not iconInstance then return end
		if iconInstance:IsA("ImageLabel") then
			iconInstance.ImageTransparency = amount
		else
			iconInstance.TextTransparency = amount
		end
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
			local iconImage = Instance.new("ImageLabel")
			iconImage.BackgroundTransparency = 1
			iconImage.AnchorPoint = Vector2.new(0.5, 0.5)
			iconImage.Position = UDim2.new(0.5, 0, 0.5, 0)
			iconImage.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
			iconImage.Image = iconValue
			iconImage.ImageColor3 = defaultIconColor
			iconImage.ZIndex = iconHolder.ZIndex
			iconImage.Parent = iconHolder
			iconInstance = iconImage
		elseif iconType == "sprite" and type(iconValue) == "table" then
			local iconImage = Instance.new("ImageLabel")
			iconImage.BackgroundTransparency = 1
			iconImage.AnchorPoint = Vector2.new(0.5, 0.5)
			iconImage.Position = UDim2.new(0.5, 0, 0.5, 0)
			iconImage.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
			iconImage.Image = "rbxassetid://" .. iconValue.id
			iconImage.ImageRectSize = iconValue.imageRectSize
			iconImage.ImageRectOffset = iconValue.imageRectOffset
			iconImage.ImageColor3 = defaultIconColor
			iconImage.ZIndex = iconHolder.ZIndex
			iconImage.Parent = iconHolder
			iconInstance = iconImage
		elseif iconValue and iconType == "text" then
			local iconText = Instance.new("TextLabel")
			iconText.BackgroundTransparency = 1
			iconText.AnchorPoint = Vector2.new(0.5, 0.5)
			iconText.Position = UDim2.new(0.5, 0, 0.5, 0)
			iconText.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
			iconText.Font = Enum.Font.GothamBold
			iconText.TextSize = 18
			iconText.TextColor3 = defaultIconColor
			iconText.Text = tostring(iconValue)
			iconText.TextWrapped = false
			iconText.TextXAlignment = Enum.TextXAlignment.Center
			iconText.TextYAlignment = Enum.TextYAlignment.Center
			iconText.ZIndex = iconHolder.ZIndex
			iconText.Parent = iconHolder
			iconInstance = iconText
		end

		if iconInstance then
			iconHolder.Visible = true
			updateTextPadding(true)
		else
			updateTextPadding(false)
		end
	end

	updateTextPadding(false)
	setIcon(currentIcon)

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

		-- Brighten text/icon
		Animator:Tween(textLabel, {TextColor3 = pal3.Shimmer}, Animator.Spring.Lightning)
		tweenIconColor(pal3.Shimmer, Animator.Spring.Lightning)

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

		-- Restore text/icon color
		Animator:Tween(textLabel, {TextColor3 = defaultTextColor}, Animator.Spring.Snappy)
		tweenIconColor(defaultIconColor, Animator.Spring.Snappy)
	end)

	-- Lock state listener with visual feedback
	table.insert(RvrseUI._lockListeners, function()
		local locked = RvrseUI.Store:IsLocked(o.RespectLock)

		if locked then
			-- Desaturate and dim
			textLabel.TextTransparency = 0.5
			gradient.Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0.9),
				NumberSequenceKeypoint.new(1, 0.9),
			}
			stroke.Transparency = 0.8
			setIconTransparency(0.5)
		else
			-- Restore to normal or hover state
			textLabel.TextTransparency = 0
			setIconTransparency(0)
			if isHovering then
				gradient.Transparency = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 0.4),
					NumberSequenceKeypoint.new(1, 0.4),
				}
				stroke.Transparency = 0.2
			else
				gradient.Transparency = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 0.7),
					NumberSequenceKeypoint.new(1, 0.7),
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
				textLabel.Text = text
				currentText = text
			end
			-- interactText parameter reserved for future use (Rayfield compatibility)
		end,
		SetText = function(_, txt)
			-- Legacy method - kept for backwards compatibility
			textLabel.Text = txt
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
		SetIcon = function(_, icon)
			currentIcon = icon
			setIcon(icon)
			return currentIcon
		end,
		GetIcon = function()
			return currentIcon
		end,
		CurrentValue = currentText
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = buttonAPI
	end

	-- Register for global search
	local registerSearchableElement = dependencies.registerSearchableElement
	if registerSearchableElement then
		registerSearchableElement({
			text = o.Text or "Button",
			icon = o.Icon,
			elementType = "Button",
			path = (dependencies.tabTitle or "Tab") .. " > " .. (dependencies.sectionTitle or "Section"),
			frame = f,
			callback = o.Callback,
			tabData = dependencies.tabData
		})
	end

	return buttonAPI
end




-- ========================
-- Toggle Module
-- ========================

-- Switch-style toggle with vibrant gradient track
-- Complete redesign for RvrseUI v4.0

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
	local fireOnConfigLoad = o.FireOnConfigLoad ~= false

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
	corner(shell, "pill")

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
	trackStroke.LineJoinMode = Enum.LineJoinMode.Round
	trackStroke.Parent = shell

	-- Switch thumb (larger and glowing)
	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0, 26, 0, 26)
	dot.Position = UDim2.new(0, 2, 0.5, -13)
	dot.BackgroundColor3 = Color3.new(1, 1, 1)
	dot.BorderSizePixel = 0
	dot.ZIndex = 3
	dot.Parent = shell
	corner(dot, "pill")
	shadow(dot, 0.5, 3)

	-- Glow ring around thumb (when active)
	local glowRing = Instance.new("UIStroke")
	glowRing.Color = pal3.Accent
	glowRing.Thickness = 0
	glowRing.Transparency = 0.3
	glowRing.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	glowRing.LineJoinMode = Enum.LineJoinMode.Round
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
		Set = function(_, v, fireCallback)
			state = v and true or false
			visual()
			if controlsGroup then
				RvrseUI.Store:SetLocked(controlsGroup, state)
			end
			if fireCallback and o.OnChanged then
				task.spawn(o.OnChanged, state)
			end
		end,
		Get = function() return state end,
		Refresh = visual,
		SetVisible = function(_, visible)
			f.Visible = visible
		end,
		Hydrate = function(_, overrideState)
			if not fireOnConfigLoad then
				return
			end
			if o.OnChanged then
				local final = overrideState ~= nil and (overrideState and true or false) or state
				task.spawn(o.OnChanged, final)
			end
		end,
		CurrentValue = state
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = toggleAPI
	end

	-- Register for global search
	local registerSearchableElement = dependencies.registerSearchableElement
	if registerSearchableElement then
		registerSearchableElement({
			text = o.Text or "Toggle",
			icon = o.Icon,
			elementType = "Toggle",
			path = (dependencies.tabTitle or "Tab") .. " > " .. (dependencies.sectionTitle or "Section"),
			frame = f,
			tabData = dependencies.tabData
		})
	end

	return toggleAPI
end




-- ========================
-- Dropdown Module
-- ========================

-- Modern multi-select overlay dropdown system (unified as of v4.1.0)
-- Users can select multiple items or just one by clicking once

Dropdown = {}

function Dropdown.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local corner = dependencies.corner
	local stroke = dependencies.stroke
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
	local sourceValues = o.Values or {}
	for _, v in ipairs(sourceValues) do
		table.insert(values, v)
	end

	local selectedValues = {}  -- Always use multi-select mode

	-- Initialize selectedValues from CurrentOption
	if o.CurrentOption and type(o.CurrentOption) == "table" then
		for _, val in ipairs(o.CurrentOption) do
			table.insert(selectedValues, val)
		end
	end

	local maxHeight = o.MaxHeight or 240
	local itemHeight = 40
	local placeholder = o.PlaceholderText or "Select items"
	local DROPDOWN_BASE_Z = 3000
	local minDropdownWidth = 220  -- Minimum dropdown width (increased)
	local maxDropdownWidth = 500  -- Maximum dropdown width (increased for very long labels)
	local fallbackOverlayLayer
	local fallbackOverlayGui
	local f

	local function currentOverlayLayer()
		if baseOverlayLayer and baseOverlayLayer.Parent then
			return baseOverlayLayer
		end
		if fallbackOverlayLayer and fallbackOverlayLayer.Parent then
			return fallbackOverlayLayer
		end
		return nil
	end

	local function ancestorClips()
		if not f then
			return false
		end
		local current = f.Parent
		while current do
			if current:IsA("GuiObject") then
				if current.ClipsDescendants or current:IsA("ScrollingFrame") then
					return true
				end
			end
			current = current.Parent
		end
		return false
	end

	local function shouldUseOverlay()
		if o.ForceInline then
			return false
		end
		if o.Overlay == false then
			return ancestorClips()
		end
		return true
	end

	local function resolveOverlayLayer(force)
		if not force and not shouldUseOverlay() then
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
			-- Calculate highest DisplayOrder to ensure dropdown is on top
			local maxDisplayOrder = 0
			for _, gui in ipairs(playerGui:GetChildren()) do
				if gui:IsA("ScreenGui") then
					maxDisplayOrder = math.max(maxDisplayOrder, gui.DisplayOrder)
				end
			end

			hostGui = Instance.new("ScreenGui")
			hostGui.Name = "RvrseUI_DropdownHost"
			hostGui.ResetOnSpawn = false
			hostGui.IgnoreGuiInset = true
			hostGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			hostGui.DisplayOrder = maxDisplayOrder + 1000  -- Always on top
			hostGui.Parent = playerGui
			fallbackOverlayGui = hostGui

			if dependencies.Debug and dependencies.Debug.IsEnabled() then
				dependencies.Debug.printf("[Dropdown] Created fallback ScreenGui with DisplayOrder=%d (max was %d)",
					hostGui.DisplayOrder, maxDisplayOrder)
			end
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
	f = card(48)
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

	-- Trigger button (wider for long labels)
	local btn = Instance.new("TextButton")
	btn.AnchorPoint = Vector2.new(1, 0.5)
	btn.Position = UDim2.new(1, -6, 0.5, 0)
	btn.Size = UDim2.new(0, 200, 0, 32)  -- Increased from 130 to 200px
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
	dropdownLayout.Padding = UDim.new(0, 4)
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
	local dropdownAPI = {}
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
		if not shouldUseOverlay() then
			return
		end

		if OverlayService then
			overlayBlocker = OverlayService:ShowBlocker({
				Transparency = 0.45,
				ZIndex = DROPDOWN_BASE_Z - 2,
				Modal = false,
			})
		else
			local layer = resolveOverlayLayer(true)
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
			overlayBlocker.Active = false
			overlayBlocker.Modal = false
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
		dropdownAPI.CurrentOption = selectedValues
	end

	local function updateButtonText()
		local count = #selectedValues
		if count == 0 then
			btn.Text = placeholder
		elseif count == 1 then
			btn.Text = tostring(selectedValues[1])
		else
			btn.Text = count .. " selected"
		end
		updateCurrentOption()
	end

	local function isValueSelected(value)
		for _, v in ipairs(selectedValues) do
			if v == value then
				return true
			end
		end
		return false
	end

	local function updateHighlight()
		for i, optionBtn in ipairs(optionButtons) do
			local value = values[i]
			local selected = isValueSelected(value)

			if selected then
				optionBtn.BackgroundColor3 = pal3.Accent
				optionBtn.BackgroundTransparency = 0.8
			else
				optionBtn.BackgroundColor3 = pal3.Card
				optionBtn.BackgroundTransparency = 0
			end

			local textLabel = optionBtn:FindFirstChild("TextLabel", true)
			if textLabel then
				textLabel.TextColor3 = selected and pal3.Accent or pal3.Text
			end

			local checkbox = optionBtn:FindFirstChild("Checkbox", true)
			if checkbox then
				checkbox.Text = selected and "☑" or "☐"
				checkbox.TextColor3 = selected and pal3.Accent or pal3.TextSub
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

	local function calculateOptimalWidth()
		-- Create a temporary TextLabel to measure text width
		local tempLabel = Instance.new("TextLabel")
		tempLabel.Font = Enum.Font.GothamMedium
		tempLabel.TextSize = 14
		tempLabel.Text = ""
		tempLabel.Parent = nil

		local maxTextWidth = 0

		-- Measure all values
		for _, value in ipairs(values) do
			tempLabel.Text = tostring(value)
			local textBounds = tempLabel.TextBounds
			maxTextWidth = math.max(maxTextWidth, textBounds.X)
		end

		tempLabel:Destroy()

		-- Calculate total width needed to match actual UI layout:
		-- UI structure: [4px scroll pad][4px icon pad][32px checkbox][8px gap][TEXT][4px pad][4px scroll pad]
		-- ScrollFrame padding: 4px left + 4px right = 8px
		-- Icon area (iconFrame + gap to text): 40px (textFrame starts at X=40)
		-- Text area reserved space: textFrame.Size = (1, -44) means 44px is reserved for icon area + right padding
		-- Right padding: 4px
		-- Total chrome: 8px (scroll padding) + 44px (icon area + right pad) = 52px
		local totalWidth = 52 + maxTextWidth

		-- Clamp between min and max
		totalWidth = math.clamp(totalWidth, minDropdownWidth, maxDropdownWidth)

		return totalWidth
	end

	local function applyOverlayZIndex(layer)
		layer = layer or currentOverlayLayer()
		local overlayBaseZ = layer and layer.ZIndex or 0
		local blockerZ = overlayBlocker and overlayBlocker.ZIndex or overlayBaseZ

		-- Find maximum ZIndex in the layer to ensure dropdown is on top
		local maxZInLayer = overlayBaseZ
		if layer then
			for _, child in ipairs(layer:GetDescendants()) do
				if child:IsA("GuiObject") then
					maxZInLayer = math.max(maxZInLayer, child.ZIndex)
				end
			end
		end

		local dropdownZ = math.max(maxZInLayer + 10, overlayBaseZ + 2, blockerZ + 1, DROPDOWN_BASE_Z)
		dropdownList.ZIndex = dropdownZ
		dropdownScroll.ZIndex = dropdownZ + 1
		updateOptionZIndices(dropdownScroll.ZIndex + 1)

		if dependencies.Debug and dependencies.Debug.IsEnabled() then
			dependencies.Debug.printf("[Dropdown] Applied overlay ZIndex: dropdown=%d, scroll=%d (max in layer was %d)",
				dropdownZ, dropdownZ + 1, maxZInLayer)
		end
	end

	local function positionDropdown(width, height, skipCreate)
		height = height or dropdownHeight
		-- Use calculated optimal width if not provided
		if not width then
			local optimalWidth = calculateOptimalWidth()
			width = math.max(btn.AbsoluteSize.X, inlineWidth, optimalWidth)
		end

		local layer = nil
		if shouldUseOverlay() then
			layer = skipCreate and currentOverlayLayer() or resolveOverlayLayer(false)
			if not layer and not skipCreate then
				layer = resolveOverlayLayer(true)
			end
		end

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

	local function rebuildOptions()
		for _, child in ipairs(dropdownScroll:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		table.clear(optionButtons)
		local spacingPerItem = 4
		local totalItemsHeight = (#values * itemHeight) + ((#values - 1) * spacingPerItem)
		local paddingTotal = 8 + 8

		dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, totalItemsHeight + 8)
		dropdownHeight = math.min(totalItemsHeight + paddingTotal, maxHeight)

		updateButtonText()

		for i, value in ipairs(values) do
			local optionBtn = Instance.new("TextButton")
			optionBtn.Name = "Option_" .. i
			optionBtn.Size = UDim2.new(1, -8, 0, 36)
			local selected = isValueSelected(value)
			optionBtn.BackgroundColor3 = selected and pal3.Accent or pal3.Card
			optionBtn.BackgroundTransparency = selected and 0.8 or 0
			optionBtn.BorderSizePixel = 0
			optionBtn.Text = ""
			optionBtn.AutoButtonColor = false
			optionBtn.LayoutOrder = i
			optionBtn.ZIndex = dropdownScroll.ZIndex + 1
			optionBtn.Parent = dropdownScroll
			corner(optionBtn, 6)

			-- Icon column (fixed width for checkbox)
			local iconFrame = Instance.new("Frame")
			iconFrame.Name = "IconColumn"
			iconFrame.BackgroundTransparency = 1
			iconFrame.Size = UDim2.new(0, 32, 1, 0)
			iconFrame.Position = UDim2.new(0, 4, 0, 0)
			iconFrame.ZIndex = optionBtn.ZIndex + 1
			iconFrame.Parent = optionBtn

			local checkbox = Instance.new("TextLabel")
			checkbox.Name = "Checkbox"
			checkbox.BackgroundTransparency = 1
			checkbox.Size = UDim2.new(1, 0, 1, 0)
			checkbox.Position = UDim2.new(0, 0, 0, 0)
			checkbox.Font = Enum.Font.GothamBold
			checkbox.TextSize = 16
			checkbox.Text = selected and "☑" or "☐"
			checkbox.TextColor3 = selected and pal3.Accent or pal3.TextSub
			checkbox.TextXAlignment = Enum.TextXAlignment.Center
			checkbox.TextYAlignment = Enum.TextYAlignment.Center
			checkbox.ZIndex = iconFrame.ZIndex + 1
			checkbox.Parent = iconFrame

			-- Text column (flexible width)
			local textFrame = Instance.new("Frame")
			textFrame.Name = "TextColumn"
			textFrame.BackgroundTransparency = 1
			textFrame.Size = UDim2.new(1, -44, 1, 0)
			textFrame.Position = UDim2.new(0, 40, 0, 0)
			textFrame.ZIndex = optionBtn.ZIndex + 1
			textFrame.Parent = optionBtn

			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			textLabel.BackgroundTransparency = 1
			textLabel.Size = UDim2.new(1, 0, 1, 0)
			textLabel.Position = UDim2.new(0, 0, 0, 0)
			textLabel.Font = Enum.Font.GothamMedium
			textLabel.TextSize = 14
			textLabel.Text = tostring(value)
			textLabel.TextColor3 = selected and pal3.Accent or pal3.Text
			textLabel.TextXAlignment = Enum.TextXAlignment.Left
			textLabel.TextYAlignment = Enum.TextYAlignment.Center
			textLabel.TextTruncate = Enum.TextTruncate.AtEnd
			textLabel.TextWrapped = false
			textLabel.ZIndex = textFrame.ZIndex + 1
			textLabel.Parent = textFrame

			optionBtn.MouseButton1Click:Connect(function()
				if locked() then return end

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
		if overlayBlocker and OverlayService then
			if overlayBlockerConnection then
				overlayBlockerConnection:Disconnect()
			end

			overlayBlockerConnection = overlayBlocker.MouseButton1Click:Connect(function()
				if setOpen then
					setOpen(false)
				end
			end)
		end
	end

	setOpen = function(state)
		if locked() then
			return
		end

		if state == dropdownOpen then
			if state then
				local optimalWidth = calculateOptimalWidth()
				positionDropdown(math.max(btn.AbsoluteSize.X, inlineWidth, optimalWidth), dropdownHeight, true)
			end
			return
		end

		dropdownOpen = state
		arrow.Text = dropdownOpen and "▲" or "▼"

		if dropdownOpen then
			if o.OnOpen then
				o.OnOpen()
			end

			local spacingPerItem = 4
			local totalItemsHeight = (#values * itemHeight) + ((#values - 1) * spacingPerItem)
			local paddingTotal = 8 + 8

			dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, totalItemsHeight + 8)
			dropdownHeight = math.min(totalItemsHeight + paddingTotal, maxHeight)

			if #values > 0 then
				dropdownHeight = math.max(dropdownHeight, itemHeight + paddingTotal)
			end

			showOverlayBlocker()
			connectBlockerHandler()

			-- Calculate optimal width based on content
			local optimalWidth = calculateOptimalWidth()
			local targetWidth = math.max(btn.AbsoluteSize.X, inlineWidth, optimalWidth)
			positionDropdown(targetWidth, dropdownHeight)

			-- Diagnostic logging for render order debugging
			if dependencies.Debug and dependencies.Debug.IsEnabled() then
				local parent = dropdownList
				local clipPath = {}
				while parent do
					if parent:IsA("ScreenGui") then
						dependencies.Debug.printf("[Dropdown] ScreenGui '%s': DisplayOrder=%d", parent.Name, parent.DisplayOrder)
						break
					elseif parent:IsA("GuiObject") then
						table.insert(clipPath, string.format("%s (ZIndex=%d, Clips=%s)",
							parent.Name, parent.ZIndex, tostring(parent.ClipsDescendants)))
					end
					parent = parent.Parent
				end
				if #clipPath > 0 then
					dependencies.Debug.printf("[Dropdown] Hierarchy: %s", table.concat(clipPath, " → "))
				end
				dependencies.Debug.printf("[Dropdown] List ZIndex=%d, Scroll ZIndex=%d, Blocker ZIndex=%d",
					dropdownList.ZIndex, dropdownScroll.ZIndex,
					overlayBlocker and overlayBlocker.ZIndex or 0)
			end

			dropdownList.Visible = true
			dropdownScroll.CanvasPosition = Vector2.new(0, 0)
		else
			local layer = currentOverlayLayer()
			local targetWidth = layer and math.max(btn.AbsoluteSize.X, inlineWidth) or inlineWidth
			dropdownList.Visible = false
			dropdownList.Size = UDim2.new(0, targetWidth, 0, 0)
			collapseInline()
			hideOverlayBlocker(false)
			if o.OnClose then
				o.OnClose()
			end
		end
	end

	-- Toggle dropdown on button click
	btn.MouseButton1Click:Connect(function()
		if not dropdownOpen then
			if o.OnRefresh then
				local newValues = o.OnRefresh()
				if newValues and type(newValues) == "table" then
					values = {}
					for _, val in ipairs(newValues) do
						table.insert(values, val)
					end
					rebuildOptions()
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
	end

	dropdownAPI.Get = function()
		return selectedValues
	end

	dropdownAPI.Refresh = function(_, newValues)
		if newValues then
			values = {}
			for _, val in ipairs(newValues) do
				values[#values + 1] = val
			end
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

	-- Multi-select methods
	dropdownAPI.SelectAll = function(_)
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

	dropdownAPI.ClearAll = function(_)
		selectedValues = {}
		updateButtonText()
		updateHighlight()
		if o.OnChanged then
			task.spawn(o.OnChanged, selectedValues)
		end
		if o.Flag then RvrseUI:_autoSave() end
	end

	-- Always returns selected values as table
	dropdownAPI.CurrentOption = selectedValues

	if o.Flag then
		RvrseUI.Flags[o.Flag] = dropdownAPI
	end

	-- Register for global search
	local registerSearchableElement = dependencies.registerSearchableElement
	if registerSearchableElement then
		registerSearchableElement({
			text = o.Text or "Dropdown",
			icon = o.Icon,
			elementType = "Dropdown",
			path = (dependencies.tabTitle or "Tab") .. " > " .. (dependencies.sectionTitle or "Section"),
			frame = f,
			tabData = dependencies.tabData
		})
	end

	return dropdownAPI
end




-- ========================
-- Slider Module
-- ========================

-- Gradient-filled slider with glowing thumb
-- Complete redesign for RvrseUI v4.0

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
	local fireOnConfigLoad = o.FireOnConfigLoad ~= false

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
	corner(track, "pill")

	-- Track border glow
	local trackStroke = Instance.new("UIStroke")
	trackStroke.Color = pal3.BorderGlow
	trackStroke.Thickness = 1
	trackStroke.Transparency = 0.7
	trackStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	trackStroke.LineJoinMode = Enum.LineJoinMode.Round
	trackStroke.Parent = track

	-- Vibrant gradient fill
	local fill = Instance.new("Frame")
	local initialRatio = range > 0 and ((value - minVal) / range) or 0
	fill.Size = UDim2.new(initialRatio, 0, 1, 0)
	fill.BackgroundColor3 = pal3.Accent
	fill.BorderSizePixel = 0
	fill.ZIndex = 2
	fill.Parent = track
	corner(fill, "pill")

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
	corner(thumb, "pill")
	shadow(thumb, 0.5, 5) -- Enhanced shadow

	-- Glowing stroke around thumb
	local glowStroke = Instance.new("UIStroke")
	glowStroke.Color = pal3.Accent
	glowStroke.Thickness = 0
	glowStroke.Transparency = 0.2
	glowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	glowStroke.LineJoinMode = Enum.LineJoinMode.Round
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
	Set = function(_, v, fireCallback)
		if v == nil then
			return
		end
		setValueDirect(v)
			if fireCallback and o.OnChanged then
				task.spawn(o.OnChanged, sliderAPI.CurrentValue)
			end
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
		Hydrate = function(_, overrideValue)
			if not fireOnConfigLoad then
				return
			end
			if o.OnChanged then
				task.spawn(o.OnChanged, overrideValue ~= nil and overrideValue or sliderAPI.CurrentValue)
			end
		end,
		CurrentValue = value
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = sliderAPI
	end

	-- Register for global search
	local registerSearchableElement = dependencies.registerSearchableElement
	if registerSearchableElement then
		registerSearchableElement({
			text = o.Text or "Slider",
			icon = o.Icon,
			elementType = "Slider",
			path = (dependencies.tabTitle or "Tab") .. " > " .. (dependencies.sectionTitle or "Section"),
			frame = f,
			tabData = dependencies.tabData
		})
	end

	return sliderAPI
end




-- ========================
-- Keybind Module
-- ========================

-- Modern keybind with gradient highlight when capturing
-- Complete redesign for RvrseUI v4.0

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
	local isLightTheme = Theme and Theme.Current == "Light"

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
	btn.BackgroundTransparency = isLightTheme and 0 or 0.2
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.Code
	btn.TextSize = 13
	btn.TextColor3 = pal3.TextBright
	btn.Text = (o.Default and o.Default.Name) or "Set Key"
	btn.AutoButtonColor = false
	btn.Parent = f
	corner(btn, "pill")

	-- Border stroke
	local btnStroke = Instance.new("UIStroke")
	btnStroke.Color = pal3.Border
	btnStroke.Thickness = 1
	btnStroke.Transparency = 0.5
	btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	btnStroke.LineJoinMode = Enum.LineJoinMode.Round
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

	-- Register for global search
	local registerSearchableElement = dependencies.registerSearchableElement
	if registerSearchableElement then
		registerSearchableElement({
			text = o.Text or "Keybind",
			icon = o.Icon,
			elementType = "Keybind",
			path = (dependencies.tabTitle or "Tab") .. " > " .. (dependencies.sectionTitle or "Section"),
			frame = f,
			tabData = dependencies.tabData
		})
	end

	return keybindAPI
end




-- ========================
-- TextBox Module
-- ========================

-- Modern input with glowing underline and gradient focus
-- Complete redesign for RvrseUI v4.0

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
	local isLightTheme = Theme and Theme.Current == "Light"
	local baseTransparency = isLightTheme and 0 or 0.3
	local focusTransparency = isLightTheme and 0 or 0.1

	local f = card(52) -- Taller for modern look
	local fireOnConfigLoad = o.FireOnConfigLoad ~= false

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
	inputBox.BackgroundTransparency = baseTransparency
	inputBox.BorderSizePixel = 0
	inputBox.Font = Enum.Font.GothamMedium
	inputBox.TextSize = 14
	inputBox.TextColor3 = pal3.TextBright
	inputBox.PlaceholderText = o.Placeholder or "Enter text..."
	inputBox.PlaceholderColor3 = pal3.TextMuted
	inputBox.Text = o.Default or ""
	inputBox.ClearTextOnFocus = false
	inputBox.Parent = f
	corner(inputBox, "pill")

	-- Subtle border (default state)
	local borderStroke = Instance.new("UIStroke")
	borderStroke.Color = pal3.Border
	borderStroke.Thickness = 1
	borderStroke.Transparency = 0.6
	borderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	borderStroke.LineJoinMode = Enum.LineJoinMode.Round
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
	Animator:Tween(inputBox, {BackgroundTransparency = focusTransparency}, Animator.Spring.Lightning)

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
	Animator:Tween(inputBox, {BackgroundTransparency = baseTransparency}, Animator.Spring.Snappy)

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
	Set = function(_, txt, fireCallback)
		local textValue = txt ~= nil and tostring(txt) or ""
		inputBox.Text = textValue
		currentValue = textValue
		if fireCallback and o.OnChanged then
			task.spawn(o.OnChanged, currentValue, false)
		end
	end,
		Get = function()
			return currentValue
		end,
		SetVisible = function(_, visible)
			f.Visible = visible
		end,
		Hydrate = function(_, overrideValue)
			if not fireOnConfigLoad then
				return
			end
			if o.OnChanged then
				task.spawn(o.OnChanged, overrideValue or currentValue, false)
			end
		end,
		CurrentValue = currentValue
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = textboxAPI
	end

	-- Register for global search
	local registerSearchableElement = dependencies.registerSearchableElement
	if registerSearchableElement then
		registerSearchableElement({
			text = o.Text or "TextBox",
			icon = o.Icon,
			elementType = "TextBox",
			path = (dependencies.tabTitle or "Tab") .. " > " .. (dependencies.sectionTitle or "Section"),
			frame = f,
			tabData = dependencies.tabData
		})
	end

	return textboxAPI
end




-- ========================
-- ColorPicker Module
-- ========================

-- Advanced color picker with RGB/HSV sliders, hex input, and live preview
-- Supports both simple mode (preset colors) and advanced mode (full RGB/HSV control)

ColorPicker = {}

-- Helper: Convert RGB to HSV
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

-- Helper: Convert HSV to RGB
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

-- Helper: Convert Color3 to Hex
local function Color3ToHex(color)
	local r = math.floor(color.R * 255 + 0.5)
	local g = math.floor(color.G * 255 + 0.5)
	local b = math.floor(color.B * 255 + 0.5)
	return string.format("#%02X%02X%02X", r, g, b)
end

-- Helper: Convert Hex to Color3
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
	corner(preview, "pill")

	-- Glowing stroke
	local previewStroke = Instance.new("UIStroke")
	previewStroke.Color = pal3.Border
	previewStroke.Thickness = 2
	previewStroke.Transparency = 0.4
	previewStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	previewStroke.LineJoinMode = Enum.LineJoinMode.Round
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
	local fireOnConfigLoad = o.FireOnConfigLoad ~= false

	local colorpickerAPI = {
	Set = function(_, color, fireCallback)
		if not color then
			return
		end
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
			if fireCallback and o.OnChanged then
				task.spawn(o.OnChanged, currentColor)
			end
		end,
		Get = function()
			return currentColor
		end,
		SetVisible = function(_, visible)
			f.Visible = visible
		end,
	Hydrate = function(_, overrideColor)
		if not fireOnConfigLoad then
			return
		end
		local target = overrideColor or currentColor
		if o.OnChanged and target then
			task.spawn(o.OnChanged, target)
		end
	end,
		CurrentValue = currentColor
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = colorpickerAPI
	end

	-- Register for global search
	local registerSearchableElement = dependencies.registerSearchableElement
	if registerSearchableElement then
		registerSearchableElement({
			text = o.Text or "ColorPicker",
			icon = o.Icon,
			elementType = "ColorPicker",
			path = (dependencies.tabTitle or "Tab") .. " > " .. (dependencies.sectionTitle or "Section"),
			frame = f,
			tabData = dependencies.tabData
		})
	end

	return colorpickerAPI
end




-- ========================
-- Label Module
-- ========================

-- Clean label with optional gradient text
-- Minimal redesign for RvrseUI v4.0

Label = {}

function Label.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local pal3 = dependencies.pal3
	local RvrseUI = dependencies.RvrseUI
	local Icons = dependencies.Icons

	local f = card(36) -- Slightly taller

	local cardPadding = f:FindFirstChildOfClass("UIPadding")
	local basePadLeft = cardPadding and cardPadding.PaddingLeft.Offset or 0

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, -8, 1, 0)
	lbl.Position = UDim2.new(0, 4, 0, 0)
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = o.Color or pal3.TextSub -- Allow caller override
	lbl.Text = tostring(o.Text or "Label")
	lbl.TextWrapped = true
	lbl.Parent = f

	local ICON_MARGIN = 12
	local ICON_SIZE = 24

	local iconHolder = Instance.new("Frame")
	iconHolder.BackgroundTransparency = 1
	iconHolder.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
	iconHolder.AnchorPoint = Vector2.new(0, 0.5)
	iconHolder.Position = UDim2.new(0, math.max(0, ICON_MARGIN - basePadLeft), 0.5, 0)
	iconHolder.ClipsDescendants = true
	iconHolder.Visible = false
	iconHolder.ZIndex = lbl.ZIndex + 1
	iconHolder.Name = "IconHolder"
	iconHolder.Parent = f

	local iconInstance = nil
	local defaultIconColor = o.IconColor or pal3.TextSub
	local currentIcon = o.Icon

	local function applyIconColor(color)
		if not iconInstance then
			return
		end
		if iconInstance:IsA("ImageLabel") then
			iconInstance.ImageColor3 = color
		else
			iconInstance.TextColor3 = color
		end
	end

	local function updateLabelPadding(hasIcon)
		if hasIcon then
			local leftInset = ICON_MARGIN + ICON_SIZE + 6
			local relativeOffset = math.max(0, leftInset - basePadLeft)
			lbl.Position = UDim2.new(0, relativeOffset, 0, 0)
			lbl.Size = UDim2.new(1, -(relativeOffset + 4), 1, 0)
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
			iconInstance.ZIndex = iconHolder.ZIndex
			applyIconColor(defaultIconColor)
			iconHolder.Visible = true
			updateLabelPadding(true)
		end
	end

	updateLabelPadding(false)
	setIcon(o.Icon)

	local labelAPI = {
		Set = function(_, txt)
			lbl.Text = tostring(txt)
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
		SetIconColor = function(_, color)
			if color then
				defaultIconColor = color
				applyIconColor(color)
			end
		end,
		SetTextColor = function(_, color)
			if color then
				lbl.TextColor3 = color
			end
		end,
		GetIcon = function()
			return currentIcon
		end,
		CurrentValue = lbl.Text
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = labelAPI
	end

	-- Register for global search
	local registerSearchableElement = dependencies.registerSearchableElement
	if registerSearchableElement then
		registerSearchableElement({
			text = o.Text or "Label",
			icon = o.Icon,
			elementType = "Label",
			path = (dependencies.tabTitle or "Tab") .. " > " .. (dependencies.sectionTitle or "Section"),
			frame = f,
			tabData = dependencies.tabData
		})
	end

	return labelAPI
end




-- ========================
-- Paragraph Module
-- ========================

-- Part of RvrseUI v2.13.0 Modular Architecture
-- Extracted from RvrseUI.lua (lines 3560-3601)

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




-- ========================
-- Divider Module
-- ========================

-- Part of RvrseUI v2.13.0 Modular Architecture
-- Extracted from RvrseUI.lua (lines 3604-3624)

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




-- ========================
-- FilterableList Module
-- ========================

-- Live-filterable scrollable list with search input
-- Designed for item fetchers, player lists, teleport locations, etc.

FilterableList = {}

function FilterableList.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local corner = dependencies.corner
	local stroke = dependencies.stroke
	local pal3 = dependencies.pal3
	local Animator = dependencies.Animator
	local RvrseUI = dependencies.RvrseUI
	local Theme = dependencies.Theme
	local Icons = dependencies.Icons
	local UIS = dependencies.UIS
	local isLightTheme = Theme and Theme.Current == "Light"
	local baseTransparency = isLightTheme and 0 or 0.3
	local focusTransparency = isLightTheme and 0 or 0.1

	-- Settings
	local items = {}
	local sourceItems = o.Items or {}
	for _, item in ipairs(sourceItems) do
		if type(item) == "string" then
			table.insert(items, { Text = item, Data = item })
		elseif type(item) == "table" then
			table.insert(items, {
				Text = item.Text or tostring(item.Data or "Item"),
				Icon = item.Icon,
				Data = item.Data or item.Text,
			})
		end
	end

	local maxVisibleItems = o.MaxVisibleItems or 6
	local itemHeight = o.ItemHeight or 36
	local debounceTime = o.DebounceTime or 0.15
	local placeholder = o.PlaceholderText or "Type to filter..."
	local showCount = o.ShowCount ~= false
	local caseSensitive = o.CaseSensitive or false
	local noResultsText = o.NoResultsText or "No results found"
	local ICON_SIZE = 20
	local ICON_MARGIN = 8

	-- Calculate heights
	local searchHeight = 40
	local listPadding = 8
	local headerHeight = o.Text and 28 or 0
	local listMaxHeight = (maxVisibleItems * itemHeight) + ((maxVisibleItems - 1) * 4) + listPadding
	local totalHeight = searchHeight + listMaxHeight + headerHeight + 16

	-- Create main container (no card() helper - we manage our own layout)
	local f = Instance.new("Frame")
	f.Name = "FilterableList"
	f.BackgroundColor3 = pal3.Elevated
	f.BackgroundTransparency = isLightTheme and 0 or 0.3
	f.BorderSizePixel = 0
	f.Size = UDim2.new(1, 0, 0, totalHeight)
	f.AutomaticSize = Enum.AutomaticSize.Y
	f.Parent = dependencies.card and dependencies.card(0).Parent or nil
	corner(f, 10)
	stroke(f, pal3.Border, 1)

	local mainPadding = Instance.new("UIPadding")
	mainPadding.PaddingTop = UDim.new(0, 12)
	mainPadding.PaddingBottom = UDim.new(0, 12)
	mainPadding.PaddingLeft = UDim.new(0, 12)
	mainPadding.PaddingRight = UDim.new(0, 12)
	mainPadding.Parent = f

	local mainLayout = Instance.new("UIListLayout")
	mainLayout.FillDirection = Enum.FillDirection.Vertical
	mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
	mainLayout.Padding = UDim.new(0, 8)
	mainLayout.Parent = f

	-- Header label (if provided)
	if o.Text then
		local headerLabel = Instance.new("TextLabel")
		headerLabel.Name = "Header"
		headerLabel.BackgroundTransparency = 1
		headerLabel.Size = UDim2.new(1, 0, 0, 20)
		headerLabel.Font = Enum.Font.GothamBold
		headerLabel.TextSize = 15
		headerLabel.TextXAlignment = Enum.TextXAlignment.Left
		headerLabel.TextColor3 = pal3.Text
		headerLabel.Text = o.Text
		headerLabel.LayoutOrder = 1
		headerLabel.Parent = f
	end

	-- Search container
	local searchContainer = Instance.new("Frame")
	searchContainer.Name = "SearchContainer"
	searchContainer.BackgroundTransparency = 1
	searchContainer.Size = UDim2.new(1, 0, 0, searchHeight)
	searchContainer.LayoutOrder = 2
	searchContainer.Parent = f

	-- Search input
	local searchBox = Instance.new("TextBox")
	searchBox.Name = "SearchInput"
	searchBox.AnchorPoint = Vector2.new(0, 0)
	searchBox.Position = UDim2.new(0, 0, 0, 0)
	searchBox.Size = UDim2.new(1, 0, 1, 0)
	searchBox.BackgroundColor3 = pal3.Card
	searchBox.BackgroundTransparency = baseTransparency
	searchBox.BorderSizePixel = 0
	searchBox.Font = Enum.Font.GothamMedium
	searchBox.TextSize = 14
	searchBox.TextColor3 = pal3.TextBright
	searchBox.PlaceholderText = placeholder
	searchBox.PlaceholderColor3 = pal3.TextMuted
	searchBox.Text = ""
	searchBox.ClearTextOnFocus = false
	searchBox.TextXAlignment = Enum.TextXAlignment.Left
	searchBox.Parent = searchContainer
	corner(searchBox, 8)

	local searchPadding = Instance.new("UIPadding")
	searchPadding.PaddingLeft = UDim.new(0, 12)
	searchPadding.PaddingRight = UDim.new(0, 12)
	searchPadding.Parent = searchBox

	-- Search border
	local searchStroke = Instance.new("UIStroke")
	searchStroke.Color = pal3.Border
	searchStroke.Thickness = 1
	searchStroke.Transparency = 0.6
	searchStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	searchStroke.LineJoinMode = Enum.LineJoinMode.Round
	searchStroke.Parent = searchBox

	-- Search underline (glows on focus)
	local searchUnderline = Instance.new("Frame")
	searchUnderline.AnchorPoint = Vector2.new(0.5, 1)
	searchUnderline.Position = UDim2.new(0.5, 0, 1, 0)
	searchUnderline.Size = UDim2.new(0, 0, 0, 2)
	searchUnderline.BackgroundColor3 = pal3.Accent
	searchUnderline.BorderSizePixel = 0
	searchUnderline.ZIndex = 5
	searchUnderline.Parent = searchBox
	corner(searchUnderline, 1)

	-- Count label (shows filtered count)
	local countLabel
	if showCount then
		countLabel = Instance.new("TextLabel")
		countLabel.Name = "CountLabel"
		countLabel.BackgroundTransparency = 1
		countLabel.AnchorPoint = Vector2.new(1, 0.5)
		countLabel.Position = UDim2.new(1, -8, 0.5, 0)
		countLabel.Size = UDim2.new(0, 60, 0, 20)
		countLabel.Font = Enum.Font.Gotham
		countLabel.TextSize = 12
		countLabel.TextColor3 = pal3.TextMuted
		countLabel.TextXAlignment = Enum.TextXAlignment.Right
		countLabel.Text = #items .. " items"
		countLabel.Parent = searchContainer
	end

	-- List container
	local listContainer = Instance.new("Frame")
	listContainer.Name = "ListContainer"
	listContainer.BackgroundColor3 = pal3.Card
	listContainer.BackgroundTransparency = baseTransparency + 0.2
	listContainer.BorderSizePixel = 0
	listContainer.Size = UDim2.new(1, 0, 0, listMaxHeight)
	listContainer.ClipsDescendants = true
	listContainer.LayoutOrder = 3
	listContainer.Parent = f
	corner(listContainer, 8)
	stroke(listContainer, pal3.Border, 1)

	-- Scrolling frame for items
	local listScroll = Instance.new("ScrollingFrame")
	listScroll.Name = "ItemList"
	listScroll.BackgroundTransparency = 1
	listScroll.BorderSizePixel = 0
	listScroll.Size = UDim2.new(1, -8, 1, -8)
	listScroll.Position = UDim2.new(0, 4, 0, 4)
	listScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	listScroll.ScrollBarThickness = 4
	listScroll.ScrollBarImageColor3 = pal3.Accent
	listScroll.ScrollBarImageTransparency = 0.3
	listScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	listScroll.Parent = listContainer

	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Vertical
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 4)
	listLayout.Parent = listScroll

	local listPad = Instance.new("UIPadding")
	listPad.PaddingTop = UDim.new(0, 2)
	listPad.PaddingBottom = UDim.new(0, 2)
	listPad.PaddingLeft = UDim.new(0, 2)
	listPad.PaddingRight = UDim.new(0, 2)
	listPad.Parent = listScroll

	-- No results label
	local noResultsLabel = Instance.new("TextLabel")
	noResultsLabel.Name = "NoResults"
	noResultsLabel.BackgroundTransparency = 1
	noResultsLabel.Size = UDim2.new(1, 0, 0, itemHeight)
	noResultsLabel.Font = Enum.Font.GothamMedium
	noResultsLabel.TextSize = 14
	noResultsLabel.TextColor3 = pal3.TextMuted
	noResultsLabel.Text = noResultsText
	noResultsLabel.Visible = false
	noResultsLabel.Parent = listScroll

	-- State
	local filteredItems = {}
	local itemButtons = {}
	local currentQuery = ""
	local debounceThread = nil
	local isFocused = false

	-- Filter function
	local function defaultFilter(query, itemText)
		if caseSensitive then
			return itemText:find(query, 1, true) ~= nil
		else
			return itemText:lower():find(query:lower(), 1, true) ~= nil
		end
	end

	local filterFn = o.OnFilter or defaultFilter

	-- Update count label
	local function updateCount(filtered, total)
		if countLabel then
			if filtered == total then
				countLabel.Text = total .. " items"
			else
				countLabel.Text = filtered .. "/" .. total
			end
		end
	end

	-- Create item button
	local function createItemButton(item, index)
		local itemBtn = Instance.new("TextButton")
		itemBtn.Name = "Item_" .. index
		itemBtn.Size = UDim2.new(1, -4, 0, itemHeight)
		itemBtn.BackgroundColor3 = pal3.Elevated
		itemBtn.BackgroundTransparency = 0.5
		itemBtn.BorderSizePixel = 0
		itemBtn.Text = ""
		itemBtn.AutoButtonColor = false
		itemBtn.LayoutOrder = index
		itemBtn.Parent = listScroll
		corner(itemBtn, 6)

		-- Content layout
		local contentFrame = Instance.new("Frame")
		contentFrame.Name = "Content"
		contentFrame.BackgroundTransparency = 1
		contentFrame.Size = UDim2.new(1, 0, 1, 0)
		contentFrame.Parent = itemBtn

		local contentPad = Instance.new("UIPadding")
		contentPad.PaddingLeft = UDim.new(0, 10)
		contentPad.PaddingRight = UDim.new(0, 10)
		contentPad.Parent = contentFrame

		-- Icon holder (if item has icon)
		local textOffset = 0
		if item.Icon and Icons then
			local iconHolder = Instance.new("Frame")
			iconHolder.Name = "IconHolder"
			iconHolder.BackgroundTransparency = 1
			iconHolder.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
			iconHolder.AnchorPoint = Vector2.new(0, 0.5)
			iconHolder.Position = UDim2.new(0, 0, 0.5, 0)
			iconHolder.ClipsDescendants = true
			iconHolder.Parent = contentFrame

			local iconValue, iconType = Icons:Resolve(item.Icon)
			if iconType == "image" and type(iconValue) == "string" then
				local iconImage = Instance.new("ImageLabel")
				iconImage.BackgroundTransparency = 1
				iconImage.Size = UDim2.new(1, 0, 1, 0)
				iconImage.Image = iconValue
				iconImage.ImageColor3 = pal3.TextSub
				iconImage.Parent = iconHolder
			elseif iconType == "sprite" and type(iconValue) == "table" then
				local iconImage = Instance.new("ImageLabel")
				iconImage.BackgroundTransparency = 1
				iconImage.Size = UDim2.new(1, 0, 1, 0)
				iconImage.Image = "rbxassetid://" .. iconValue.id
				iconImage.ImageRectSize = iconValue.imageRectSize
				iconImage.ImageRectOffset = iconValue.imageRectOffset
				iconImage.ImageColor3 = pal3.TextSub
				iconImage.Parent = iconHolder
			elseif iconValue and iconType == "text" then
				local iconText = Instance.new("TextLabel")
				iconText.BackgroundTransparency = 1
				iconText.Size = UDim2.new(1, 0, 1, 0)
				iconText.Font = Enum.Font.GothamBold
				iconText.TextSize = 16
				iconText.TextColor3 = pal3.TextSub
				iconText.Text = tostring(iconValue)
				iconText.Parent = iconHolder
			end

			textOffset = ICON_SIZE + ICON_MARGIN
		end

		-- Text label
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "ItemText"
		textLabel.BackgroundTransparency = 1
		textLabel.AnchorPoint = Vector2.new(0, 0.5)
		textLabel.Position = UDim2.new(0, textOffset, 0.5, 0)
		textLabel.Size = UDim2.new(1, -textOffset, 1, 0)
		textLabel.Font = Enum.Font.GothamMedium
		textLabel.TextSize = 14
		textLabel.TextColor3 = pal3.Text
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.TextTruncate = Enum.TextTruncate.AtEnd
		textLabel.Text = item.Text
		textLabel.Parent = contentFrame

		-- Click handler
		itemBtn.MouseButton1Click:Connect(function()
			if RvrseUI.Store:IsLocked(o.RespectLock) then return end

			-- Visual feedback
			Animator:Pulse(itemBtn, 0.98, Animator.Spring.Lightning)
			Animator:Tween(itemBtn, {BackgroundTransparency = 0.2}, Animator.Spring.Lightning)
			task.delay(0.1, function()
				if itemBtn and itemBtn.Parent then
					Animator:Tween(itemBtn, {BackgroundTransparency = 0.5}, Animator.Spring.Snappy)
				end
			end)

			if o.OnItemClick then
				task.spawn(o.OnItemClick, item)
			end
		end)

		-- Hover effects
		itemBtn.MouseEnter:Connect(function()
			if not RvrseUI.Store:IsLocked(o.RespectLock) then
				Animator:Tween(itemBtn, {BackgroundColor3 = pal3.Hover, BackgroundTransparency = 0.3}, Animator.Spring.Fast)
				Animator:Tween(textLabel, {TextColor3 = pal3.TextBright}, Animator.Spring.Fast)
			end
		end)

		itemBtn.MouseLeave:Connect(function()
			Animator:Tween(itemBtn, {BackgroundColor3 = pal3.Elevated, BackgroundTransparency = 0.5}, Animator.Spring.Fast)
			Animator:Tween(textLabel, {TextColor3 = pal3.Text}, Animator.Spring.Fast)
		end)

		return itemBtn
	end

	-- Rebuild visible items based on filter
	local function rebuildList(query)
		-- Clear existing buttons
		for _, btn in ipairs(itemButtons) do
			if btn and btn.Parent then
				btn:Destroy()
			end
		end
		table.clear(itemButtons)
		table.clear(filteredItems)

		-- Filter items
		for i, item in ipairs(items) do
			local matches = true
			if query and query ~= "" then
				if o.OnFilter then
					matches = o.OnFilter(query, item)
				else
					matches = filterFn(query, item.Text)
				end
			end

			if matches then
				table.insert(filteredItems, item)
			end
		end

		-- Show/hide no results
		noResultsLabel.Visible = #filteredItems == 0

		-- Create buttons for filtered items
		for i, item in ipairs(filteredItems) do
			local btn = createItemButton(item, i)
			table.insert(itemButtons, btn)
		end

		-- Update count
		updateCount(#filteredItems, #items)

		-- Reset scroll position
		listScroll.CanvasPosition = Vector2.new(0, 0)
	end

	-- Debounced filter
	local function onSearchChanged()
		local query = searchBox.Text
		if query == currentQuery then return end
		currentQuery = query

		if debounceThread then
			task.cancel(debounceThread)
		end

		debounceThread = task.delay(debounceTime, function()
			rebuildList(query)
			debounceThread = nil
		end)
	end

	-- Search focus effects
	searchBox.Focused:Connect(function()
		isFocused = true
		Animator:Tween(searchBox, {BackgroundTransparency = focusTransparency}, Animator.Spring.Lightning)
		Animator:Tween(searchStroke, {Color = pal3.Accent, Thickness = 2, Transparency = 0.3}, Animator.Spring.Snappy)
		Animator:Tween(searchUnderline, {Size = UDim2.new(1, 0, 0, 2)}, Animator.Spring.Spring)
		Animator:Shimmer(searchBox, Theme)
	end)

	searchBox.FocusLost:Connect(function()
		isFocused = false
		Animator:Tween(searchBox, {BackgroundTransparency = baseTransparency}, Animator.Spring.Snappy)
		Animator:Tween(searchStroke, {Color = pal3.Border, Thickness = 1, Transparency = 0.6}, Animator.Spring.Snappy)
		Animator:Tween(searchUnderline, {Size = UDim2.new(0, 0, 0, 2)}, Animator.Spring.Glide)
	end)

	-- Live filtering on text change
	searchBox:GetPropertyChangedSignal("Text"):Connect(onSearchChanged)

	-- Lock listener
	table.insert(RvrseUI._lockListeners, function()
		local locked = RvrseUI.Store:IsLocked(o.RespectLock)
		searchBox.TextEditable = not locked
		if locked then
			f.BackgroundTransparency = 0.6
		else
			f.BackgroundTransparency = isLightTheme and 0 or 0.3
		end
	end)

	-- Initial build
	rebuildList("")

	-- Public API
	local listAPI = {
		-- Set new items list
		SetItems = function(_, newItems)
			items = {}
			for _, item in ipairs(newItems or {}) do
				if type(item) == "string" then
					table.insert(items, { Text = item, Data = item })
				elseif type(item) == "table" then
					table.insert(items, {
						Text = item.Text or tostring(item.Data or "Item"),
						Icon = item.Icon,
						Data = item.Data or item.Text,
					})
				end
			end
			rebuildList(currentQuery)
		end,

		-- Add single item
		AddItem = function(_, item)
			if type(item) == "string" then
				table.insert(items, { Text = item, Data = item })
			elseif type(item) == "table" then
				table.insert(items, {
					Text = item.Text or tostring(item.Data or "Item"),
					Icon = item.Icon,
					Data = item.Data or item.Text,
				})
			end
			rebuildList(currentQuery)
		end,

		-- Remove item by data or text
		RemoveItem = function(_, itemToRemove)
			for i, item in ipairs(items) do
				if item.Data == itemToRemove or item.Text == itemToRemove then
					table.remove(items, i)
					break
				end
			end
			rebuildList(currentQuery)
		end,

		-- Clear all items
		Clear = function(_)
			items = {}
			rebuildList("")
		end,

		-- Get current items
		GetItems = function(_)
			return items
		end,

		-- Get filtered items
		GetFilteredItems = function(_)
			return filteredItems
		end,

		-- Set search query programmatically
		SetQuery = function(_, query)
			searchBox.Text = query or ""
			rebuildList(query or "")
		end,

		-- Get current query
		GetQuery = function(_)
			return currentQuery
		end,

		-- Refresh the list (re-filter)
		Refresh = function(_)
			rebuildList(currentQuery)
		end,

		-- Set visibility
		SetVisible = function(_, visible)
			f.Visible = visible
		end,

		-- Get visibility
		IsVisible = function(_)
			return f.Visible
		end,

		-- Get count
		GetCount = function(_)
			return #filteredItems, #items
		end,

		-- Current value (for config compatibility)
		CurrentValue = currentQuery,
	}

	-- Store in flags if provided
	if o.Flag then
		RvrseUI.Flags[o.Flag] = listAPI
	end

	return listAPI
end




-- ========================
-- SectionBuilder Module
-- ========================

-- RvrseUI SectionBuilder Module
-- =========================
-- Section builder that creates SectionAPI with element factory methods
-- Extracted from RvrseUI.lua (lines 2664-2803)
-- Part of RvrseUI v2.13.0 Modular Architecture

SectionBuilder = {}

-- Creates a Section with all element creation methods
-- Dependencies required:
--   - Theme: Theme module
--   - UIHelpers: {corner, stroke, padding}
--   - Elements: {Button, Toggle, Dropdown, Keybind, Slider, Label, Paragraph, Divider, TextBox, ColorPicker}
--   - Animator: Animation module
--   - RvrseUI: Main RvrseUI instance (for _lockListeners, Flags, Store, _autoSave)
function SectionBuilder.CreateSection(sectionTitle, page, dependencies)
	local Theme = dependencies.Theme
	local helpers = dependencies.UIHelpers or {}
	local corner = helpers.corner or function(inst, radius)
		local c = Instance.new("UICorner")
		-- Accepts number, UDim, or "pill"/"full" sentinel for capsule radii
		if typeof(radius) == "UDim" then
			c.CornerRadius = radius
		elseif radius == "pill" or radius == "full" then
			c.CornerRadius = UDim.new(1, 0)
		else
			c.CornerRadius = UDim.new(0, radius or 12)
		end
		c.Parent = inst
		return c
	end
	local stroke = helpers.stroke or function(inst, color, thickness)
		local s = Instance.new("UIStroke")
		s.Color = color or Color3.fromRGB(45, 45, 55)
		s.Thickness = thickness or 1
		s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		s.LineJoinMode = Enum.LineJoinMode.Round
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
	local registerSearchableElement = dependencies.registerSearchableElement

	local pal3 = Theme:Get()
	local isLightTheme = Theme and Theme.Current == "Light"

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
		c.BackgroundTransparency = isLightTheme and 0 or 0.3
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
			Icons = dependencies.Icons,
			gradient = gradient,
			shadow = shadow,
			OverlayLayer = overlayLayer,
			Overlay = overlayService,
			registerSearchableElement = registerSearchableElement,
			sectionTitle = sectionTitle,
			tabTitle = dependencies.tabTitle
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
			-- Always use modern multi-select overlay dropdown (unified system as of v4.1.0)
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

	function SectionAPI:CreateFilterableList(o)
		return Elements.FilterableList.Create(o, getElementDeps())
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

-- Initialize method (called by init.lua)
function SectionBuilder:Initialize(deps)
	-- SectionBuilder is ready to use
	-- Dependencies are passed when CreateSection is called
	-- No initialization state needed
end




-- ========================
-- TabBuilder Module
-- ========================

-- RvrseUI TabBuilder Module
-- =========================
-- Tab builder that creates TabAPI with CreateSection method
-- Extracted from RvrseUI.lua (lines 2518-2806)
-- Part of RvrseUI v2.13.0 Modular Architecture

TabBuilder = {}

-- Creates a Tab with CreateSection method
-- Dependencies required:
--   - Theme: Theme module
--   - UIHelpers: {corner}
--   - Animator: Animation module
--   - Icons: Icon resolution module
--   - SectionBuilder: Section builder module
--   - tabBar: Parent frame for tab buttons
--   - body: Parent frame for tab pages
--   - tabs: Array to track all tabs (for activation logic)
--   - activePage: Reference to currently active page (mutable)
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
	tabStroke.LineJoinMode = Enum.LineJoinMode.Round
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
		elseif iconType == "sprite" and iconAsset then
			-- Lucide sprite sheet icon (pixel-perfect)
			tabIcon = Instance.new("ImageLabel")
			tabIcon.BackgroundTransparency = 1
			tabIcon.Image = "rbxassetid://" .. iconAsset.id
			tabIcon.ImageRectSize = iconAsset.imageRectSize
			tabIcon.ImageRectOffset = iconAsset.imageRectOffset
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
		elseif iconType == "sprite" and iconAsset then
			tabIcon = Instance.new("ImageLabel")
			tabIcon.BackgroundTransparency = 1
			tabIcon.Image = "rbxassetid://" .. iconAsset.id
			tabIcon.ImageRectSize = iconAsset.imageRectSize
			tabIcon.ImageRectOffset = iconAsset.imageRectOffset
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
		-- Add tab title to dependencies for search indexing
		local sectionDeps = {}
		for k, v in pairs(dependencies) do
			sectionDeps[k] = v
		end
		sectionDeps.tabTitle = tabText
		return SectionBuilder.CreateSection(sectionTitle, page, sectionDeps)
	end

	return TabAPI
end

-- Initialize method (called by init.lua)
function TabBuilder:Initialize(deps)
	-- TabBuilder is ready to use
	-- Dependencies are passed when CreateTab is called
	-- No initialization state needed
end




-- ========================
-- WindowBuilder Module
-- ========================

-- Creates and manages the main window structure
-- This is the largest module, responsible for building the entire UI hierarchy

WindowBuilder = {}

-- Dependencies will be injected via Initialize()
local Theme, Animator, State, Config, UIHelpers, Icons, TabBuilder, SectionBuilder, WindowManager, NotificationsService
local Debug, Obfuscation, Hotkeys, Version, Elements, OverlayLayer, Overlay, KeySystem, Particles

-- Roblox services (will be injected)
local UIS, GuiService, RS, PlayerGui, HttpService, RunService

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
	Particles = deps.Particles

	-- Services
	UIS = deps.UIS
	GuiService = deps.GuiService
	RS = deps.RS
	PlayerGui = deps.PlayerGui
	HttpService = deps.HttpService
	RunService = deps.RunService
end

-- Extract all the CreateWindow logic from RvrseUI.lua lines 1293-3922
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

	local function getViewportSize()
		local camera = workspace.CurrentCamera
		if camera and camera.ViewportSize then
			return camera.ViewportSize
		end
		return Vector2.new(baseWidth, baseHeight)
	end

	local function getCenteredPosition(size)
		local viewport = getViewportSize()
		local width = size.X.Offset
		local height = size.Y.Offset
		local centerX = math.max(0, math.floor((viewport.X - width) / 2))
		local centerY = math.max(0, math.floor((viewport.Y - height) / 2))
		return UDim2.fromOffset(centerX, centerY)
	end

	local function toScreenOffset(udim)
		local viewport = getViewportSize()
		local x = math.floor((udim.X.Scale or 0) * viewport.X + udim.X.Offset)
		local y = math.floor((udim.Y.Scale or 0) * viewport.Y + udim.Y.Offset)
		return UDim2.fromOffset(x, y)
	end

	-- Clamp position to keep window fully on-screen
	local function clampToScreen(position, size)
		local viewport = getViewportSize()
		local pos = toScreenOffset(position)
		local width = size.X.Offset
		local height = size.Y.Offset

		-- Add padding from edges (20px minimum)
		local padding = 20
		local maxX = viewport.X - width - padding
		local maxY = viewport.Y - height - padding

		-- Clamp X and Y within bounds
		local clampedX = math.max(padding, math.min(pos.X.Offset, maxX))
		local clampedY = math.max(padding, math.min(pos.Y.Offset, maxY))

		return UDim2.fromOffset(clampedX, clampedY)
	end

	root.Position = getCenteredPosition(root.Size)
	root.BackgroundColor3 = pal.Bg
	root.BackgroundTransparency = 1  -- TRANSPARENT - let children show through
	root.BorderSizePixel = 0
	root.Visible = false
	root.ClipsDescendants = false
	root.ZIndex = 100
	root.Parent = windowHost
	UIHelpers.corner(root, 16)
	UIHelpers.stroke(root, pal.Accent, 2)

	local lastWindowSize = root.Size
	local lastWindowPosition = root.Position

	local function rememberWindowPosition(pos)
		if typeof(pos) ~= "UDim2" then
			return
		end
		lastWindowPosition = pos
		RvrseUI._lastWindowPosition = pos
	end

	if typeof(RvrseUI._lastWindowPosition) == "UDim2" then
		root.Position = RvrseUI._lastWindowPosition
		rememberWindowPosition(root.Position)
	else
		rememberWindowPosition(lastWindowPosition)
	end

	local function createHeaderIcon(button, opts)
		opts = opts or {}

		button.Text = ""

		local holder = Instance.new("Frame")
		holder.Name = "Icon"
		holder.BackgroundTransparency = 1
		holder.AnchorPoint = Vector2.new(0.5, 0.5)
		holder.Position = UDim2.new(0.5, 0, 0.5, 0)
		holder.Size = UDim2.new(0, opts.size or 18, 0, opts.size or 18)
		holder.ZIndex = (button.ZIndex or 1) + 1
		holder.ClipsDescendants = true
		holder.Parent = button

		local iconInstance = nil
		local currentColor = opts.color or pal.Accent
		local currentIcon = nil
		local fallbackText = opts.fallbackText
		local fallbackColor = opts.fallbackColor

		local function clearIcon()
			if iconInstance then
				iconInstance:Destroy()
				iconInstance = nil
			end
			for _, child in ipairs(holder:GetChildren()) do
				child:Destroy()
			end
		end

		local function showFallback()
			if fallbackText then
				button.Text = fallbackText
				button.TextColor3 = fallbackColor or currentColor
			else
				button.Text = ""
			end
		end

		local function hideFallback()
			button.Text = ""
		end

		local function setFallback(text, color)
			fallbackText = text
			if color ~= nil then
				fallbackColor = color
			end

			if not iconInstance then
				showFallback()
			end
		end

		local function applyColor(color)
			currentColor = color or currentColor
			if iconInstance then
				if iconInstance:IsA("ImageLabel") then
					iconInstance.ImageColor3 = currentColor
				else
					iconInstance.TextColor3 = currentColor
				end
			else
				if fallbackText then
					button.TextColor3 = fallbackColor or currentColor
				end
			end
		end

		local function applyIcon(icon, color)
			if color then
				currentColor = color
			end
			currentIcon = icon

			clearIcon()

			if not Icons or not icon then
				iconInstance = nil
				showFallback()
				return
			end

			local iconValue, iconType = Icons:Resolve(icon)
			if iconType == "image" and typeof(iconValue) == "string" then
				local img = Instance.new("ImageLabel")
				img.BackgroundTransparency = 1
				img.Size = UDim2.new(1, 0, 1, 0)
				img.Image = iconValue
				img.ImageColor3 = currentColor
				img.Parent = holder
				iconInstance = img
			elseif iconType == "sprite" and typeof(iconValue) == "table" then
				local img = Instance.new("ImageLabel")
				img.BackgroundTransparency = 1
				img.Size = UDim2.new(1, 0, 1, 0)
				img.Image = "rbxassetid://" .. iconValue.id
				img.ImageRectSize = iconValue.imageRectSize
				img.ImageRectOffset = iconValue.imageRectOffset
				img.ImageColor3 = currentColor
				img.Parent = holder
				iconInstance = img
			elseif iconValue and iconType == "text" then
				local lbl = Instance.new("TextLabel")
				lbl.BackgroundTransparency = 1
				lbl.Size = UDim2.new(1, 0, 1, 0)
				lbl.Font = Enum.Font.GothamBold
				lbl.TextScaled = false
				lbl.TextSize = opts.textSize or 16
				lbl.TextColor3 = currentColor
				lbl.Text = tostring(iconValue)
				lbl.TextXAlignment = Enum.TextXAlignment.Center
				lbl.TextYAlignment = Enum.TextYAlignment.Center
				lbl.Parent = holder
				iconInstance = lbl
			else
				currentIcon = nil
			end

			if iconInstance then
				hideFallback()
			else
				showFallback()
			end
		end

		setFallback(fallbackText, fallbackColor)

		return {
			SetIcon = applyIcon,
			SetColor = applyColor,
			SetFallback = setFallback,
			GetIcon = function() return currentIcon end,
			GetHolder = function() return holder end
		}
	end

	-- Inner mask to control clipping during minimize animations
	local panelMask = Instance.new("Frame")
	panelMask.Name = "PanelMask"
	panelMask.BackgroundColor3 = pal.Card
	panelMask.BackgroundTransparency = 0.2
	panelMask.BorderSizePixel = 0
	panelMask.Size = UDim2.new(1, 0, 1, 0)
	panelMask.Position = UDim2.new(0, 0, 0, 0)
	panelMask.ZIndex = 100
	panelMask.ClipsDescendants = false
	panelMask.Parent = root
	UIHelpers.corner(panelMask, 16)

	-- Particle background layer (below content, above glass)
	local particleLayer = Instance.new("Frame")
	particleLayer.Name = "ParticleLayer"
	particleLayer.BackgroundTransparency = 1
	particleLayer.BorderSizePixel = 0
	particleLayer.Size = UDim2.new(1, 0, 1, 0)
	particleLayer.Position = UDim2.new(0, 0, 0, 0)
	particleLayer.ZIndex = 50 -- Below content (100+), above root background
	particleLayer.ClipsDescendants = false -- Allow particles to drift freely
	particleLayer.Parent = panelMask

	-- Initialize particle system for this window
	if Particles then
		Particles:SetLayer(particleLayer)
	end

	-- Header bar with gloss effect
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 52)
	header.BackgroundColor3 = pal.Card
	header.BackgroundTransparency = 0
	header.BorderSizePixel = 0
	header.Parent = panelMask
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
	headerStroke.LineJoinMode = Enum.LineJoinMode.Round
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
	content.Parent = panelMask
	content.ClipsDescendants = false

	local defaultRootClip = root.ClipsDescendants
	local defaultPanelClip = panelMask.ClipsDescendants
	local defaultContentClip = content.ClipsDescendants
	local defaultParticleClip = particleLayer.ClipsDescendants

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
		local newPos = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
		root.Position = newPos
		rememberWindowPosition(newPos)
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

			-- Throttle particles during drag
			if Particles and not isMinimized then
				Particles:SetState("dragging")
			end

			Debug.printf("[DRAG] Started - mouse: (%.1f, %.1f), window: %s",
				input.Position.X, input.Position.Y, tostring(root.Position))

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false

					-- Restore idle particles after drag
					if Particles and not isMinimized then
						Particles:SetState("idle")
					end

					Debug.printf("[DRAG] Finished - window: %s", tostring(root.Position))
					rememberWindowPosition(root.Position)
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
		elseif iconType == "sprite" and iconAsset then
			local img = Instance.new("ImageLabel")
			img.BackgroundTransparency = 1
			img.Image = "rbxassetid://" .. iconAsset.id
			img.ImageRectSize = iconAsset.imageRectSize
			img.ImageRectOffset = iconAsset.imageRectOffset
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
	closeBtn.Text = ""
	closeBtn.TextColor3 = pal.Error
	closeBtn.AutoButtonColor = false
	closeBtn.Parent = header
	UIHelpers.corner(closeBtn, 8)
	UIHelpers.stroke(closeBtn, pal.Error, 1)

	local closeIcon = createHeaderIcon(closeBtn, {
		size = 18,
		color = pal.Error
	})
	closeIcon.SetIcon("lucide://x", pal.Error)

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
	bellToggle.Text = ""
	bellToggle.TextColor3 = pal.Success
	bellToggle.AutoButtonColor = false
	bellToggle.Parent = header
	UIHelpers.corner(bellToggle, 12)
	UIHelpers.stroke(bellToggle, pal.Border, 1)

	local bellTooltip = UIHelpers.createTooltip(bellToggle, "Notifications: ON")

	local bellIcon = createHeaderIcon(bellToggle, {
		size = 18,
		color = pal.Success
	})

	if RvrseUI.NotificationsEnabled == nil then
		RvrseUI.NotificationsEnabled = true
	end

	local function syncBellIcon()
		local currentPal = Theme:Get()
		if bellToggle:FindFirstChild("Glow") then
			bellToggle.Glow:Destroy()
		end

		if RvrseUI.NotificationsEnabled then
			bellIcon.SetIcon("lucide://bell", currentPal.Success)
			bellIcon.SetColor(currentPal.Success)
			bellToggle.TextColor3 = currentPal.Success
			bellTooltip.Text = "  Notifications: ON  "
			UIHelpers.addGlow(bellToggle, currentPal.Success, 1.5)
		else
			bellIcon.SetIcon("lucide://bell-off", currentPal.Error)
			bellIcon.SetColor(currentPal.Error)
			bellToggle.TextColor3 = currentPal.Error
			bellTooltip.Text = "  Notifications: OFF  "
		end
	end

	syncBellIcon()

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
		RvrseUI.NotificationsEnabled = not RvrseUI.NotificationsEnabled
		syncBellIcon()
		Animator:Ripple(bellToggle, 25, 12)
	end)

	-- Search button (Global Search)
	local searchBtn = Instance.new("TextButton")
	searchBtn.Name = "SearchButton"
	searchBtn.AnchorPoint = Vector2.new(1, 0.5)
	searchBtn.Position = UDim2.new(1, -172, 0.5, 0)
	searchBtn.Size = UDim2.new(0, 32, 0, 24)
	searchBtn.BackgroundColor3 = pal.Elevated
	searchBtn.BorderSizePixel = 0
	searchBtn.Font = Enum.Font.GothamBold
	searchBtn.TextSize = 18
	searchBtn.Text = ""
	searchBtn.TextColor3 = pal.Accent
	searchBtn.AutoButtonColor = false
	searchBtn.Parent = header
	UIHelpers.corner(searchBtn, 12)
	UIHelpers.stroke(searchBtn, pal.Border, 1)

	local searchBtnIcon = createHeaderIcon(searchBtn, {
		size = 18,
		color = pal.Accent
	})
	searchBtnIcon.SetIcon("lucide://search", pal.Accent)

	local searchTooltip = UIHelpers.createTooltip(searchBtn, "Search (Ctrl+F)")

	searchBtn.MouseEnter:Connect(function()
		searchTooltip.Visible = true
		local currentPal = Theme:Get()
		Animator:Tween(searchBtn, {BackgroundColor3 = currentPal.Hover}, Animator.Spring.Fast)
	end)
	searchBtn.MouseLeave:Connect(function()
		searchTooltip.Visible = false
		local currentPal = Theme:Get()
		Animator:Tween(searchBtn, {BackgroundColor3 = currentPal.Elevated}, Animator.Spring.Fast)
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
	minimizeBtn.Text = ""
	minimizeBtn.TextColor3 = pal.Accent
	minimizeBtn.AutoButtonColor = false
	minimizeBtn.Parent = header
	UIHelpers.corner(minimizeBtn, 12)
	UIHelpers.stroke(minimizeBtn, pal.Border, 1)

	local minimizeIcon = createHeaderIcon(minimizeBtn, {
		size = 18,
		color = pal.Accent
	})
	minimizeIcon.SetIcon("lucide://minus", pal.Accent)

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
	themeToggle.Text = ""
	themeToggle.TextColor3 = pal.Accent
	themeToggle.AutoButtonColor = false
	themeToggle.Parent = header
	UIHelpers.corner(themeToggle, 12)
	UIHelpers.stroke(themeToggle, pal.Border, 1)

	local themeIcon = createHeaderIcon(themeToggle, {
		size = 18,
		color = pal.Accent
	})

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
	tabRailStroke.LineJoinMode = Enum.LineJoinMode.Round
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
		describeFrame("panelMask", panelMask)
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

		-- Start particle system with expand burst on initial show
		if Particles then
			Particles:Play("expand")
			-- Transition to idle after burst (300-450ms)
			task.delay(math.random() * (0.45 - 0.3) + 0.3, function()
				if Particles then
					Particles:SetState("idle")
				end
			end)
		end

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
	controllerChip.Font = Enum.Font.GothamBold
	controllerChip.TextSize = 20
	controllerChip.BackgroundColor3 = pal.Card
	controllerChip.BackgroundTransparency = 0.1
	controllerChip.Size = UDim2.new(0, 50, 0, 50)
	controllerChip.AnchorPoint = Vector2.new(0.5, 0.5)
	controllerChip.Position = UDim2.new(0.5, 0, 0.5, 0)
	controllerChip.Visible = false
	controllerChip.ZIndex = 200
	controllerChip.Parent = host
	UIHelpers.corner(controllerChip, 25)

	local chipIconFallback = cfg.ControllerIconFallback or cfg.TokenIconFallback or RvrseUI._tokenIconFallback or "🎮"
	local chipIconOverrideColor = cfg.ControllerIconColor or cfg.TokenIconColor or RvrseUI._tokenIconColor

	local function resolveConfigTokenIcon()
		if cfg.ControllerIcon ~= nil then
			return cfg.ControllerIcon
		end
		if cfg.TokenIcon ~= nil then
			return cfg.TokenIcon
		end
		if RvrseUI._tokenIcon ~= nil then
			return RvrseUI._tokenIcon
		end
		return nil
	end

	local chipIconRequested = resolveConfigTokenIcon()
	if chipIconRequested == nil then
		chipIconRequested = "lucide://gamepad-2"
	end
	local function resolveChipColor()
		return chipIconOverrideColor or Theme:Get().Accent
	end

	controllerChip.Text = chipIconFallback
	controllerChip.TextColor3 = resolveChipColor()

	local chipStroke = UIHelpers.stroke(controllerChip, resolveChipColor(), 2)
	local chipGlow = UIHelpers.addGlow(controllerChip, resolveChipColor(), 4)

	local controllerChipIcon = createHeaderIcon(controllerChip, {
		size = 26,
		textSize = 22,
		color = resolveChipColor(),
		fallbackText = chipIconFallback,
		fallbackColor = chipIconOverrideColor
	})

	local chipIconState = {
		icon = chipIconRequested,
		colorOverride = chipIconOverrideColor,
		fallback = chipIconFallback
	}

	local function applyControllerChipVisuals()
		local color = chipIconState.colorOverride or Theme:Get().Accent
		controllerChipIcon.SetFallback(chipIconState.fallback, chipIconState.colorOverride or color)
		controllerChipIcon.SetIcon(chipIconState.icon, color)
		controllerChipIcon.SetColor(color)
		controllerChip.TextColor3 = color
		if chipStroke then
			chipStroke.Color = color
		end
		if chipGlow and chipGlow.Parent then
			chipGlow.Color = color
		end
	end

	local function setChipIcon(icon, opts)
		opts = opts or {}

		if icon ~= nil then
			if icon == false then
				chipIconState.icon = nil
			else
				chipIconState.icon = icon
			end
		end

		if opts.UseThemeColor then
			chipIconState.colorOverride = nil
		elseif opts.Color ~= nil then
			chipIconState.colorOverride = opts.Color
		end

		if opts.Fallback ~= nil then
			chipIconState.fallback = opts.Fallback
		end

		applyControllerChipVisuals()
	end

	setChipIcon(chipIconRequested, {
		Color = chipIconOverrideColor,
		Fallback = chipIconFallback,
		UseThemeColor = chipIconOverrideColor == nil
	})

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

	-- Particle background layer for controller chip (circular, behind icon)
	local chipParticleLayer = Instance.new("Frame")
	chipParticleLayer.Name = "ChipParticleLayer"
	chipParticleLayer.BackgroundTransparency = 1
	chipParticleLayer.BorderSizePixel = 0
	chipParticleLayer.Size = UDim2.new(1, 0, 1, 0)
	chipParticleLayer.Position = UDim2.new(0, 0, 0, 0)
	chipParticleLayer.ZIndex = 190 -- Below chip content (200), above background
	chipParticleLayer.ClipsDescendants = true -- Clip to circular chip boundary
	chipParticleLayer.Parent = controllerChip
	UIHelpers.corner(chipParticleLayer, 25) -- Match chip corner radius

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
		panelMask.ClipsDescendants = true
		content.ClipsDescendants = true
		particleLayer.ClipsDescendants = true
	end

	local function restoreDefaultClipping()
		if not isMinimized then
			root.ClipsDescendants = defaultRootClip
			panelMask.ClipsDescendants = defaultPanelClip
			content.ClipsDescendants = defaultContentClip
			particleLayer.ClipsDescendants = defaultParticleClip
		end
	end

	local function minimizeWindow()
		if isMinimized or isAnimating then return end
		isMinimized = true
		isAnimating = true  -- ✅ LOCK drag during animation
		lastWindowSize = root.Size
		rememberWindowPosition(root.Position)
		if Overlay then
			Overlay:HideBlocker(true)
		end
		applyMinimizeClipping()
		Animator:Ripple(minimizeBtn, 16, 12)
		snapshotLayout("pre-minimize")

		if Particles then
			Particles:Stop(true)
		end

		local chipTargetPos = UDim2.new(0.5, 0, 0.5, 0)
		if RvrseUI._controllerChipPosition then
			local saved = RvrseUI._controllerChipPosition
			chipTargetPos = UDim2.new(saved.XScale, saved.XOffset, saved.YScale, saved.YOffset)
		end

		local chipTargetOffset = toScreenOffset(chipTargetPos)

		controllerChip.Position = chipTargetPos

		local minimizeTween = Animator:Tween(root, {
			Size = UDim2.new(0, 20, 0, 20),
			Position = chipTargetOffset,
			BackgroundTransparency = 1,
			Rotation = 0
		}, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut))

		minimizeTween.Completed:Wait()

		if not isMinimized then
			restoreDefaultClipping()
			isAnimating = false
			return
		end

		root.Visible = false
		root.Size = UDim2.new(0, baseWidth, 0, baseHeight)
		root.Position = chipTargetOffset
		root.Rotation = 0

		controllerChip.Visible = true
		controllerChip.Size = UDim2.new(0, 0, 0, 0)

		if Particles then
			Particles:SetLayer(chipParticleLayer)
			Particles:Play("idle")
		end

		local chipGrowTween = Animator:Tween(controllerChip, {
			Size = UDim2.new(0, 50, 0, 50)
		}, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))

		chipGrowTween.Completed:Wait()
		isAnimating = false
		Debug.printf("[MINIMIZE] ✅ Animation complete - drag unlocked")
	end

	local function restoreWindow()
		if not isMinimized or isAnimating then return end
		isMinimized = false
		isAnimating = true  -- ✅ LOCK drag during animation
		applyMinimizeClipping()
		Animator:Ripple(controllerChip, 25, 25)

		if Particles then
			Particles:Stop(true)
		end

		-- Calculate chip center position BEFORE shrinking
		local chipCenterPos = toScreenOffset(controllerChip.Position)

		local shrinkTween = Animator:Tween(controllerChip, {
			Size = UDim2.new(0, 0, 0, 0)
		}, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut))

		shrinkTween.Completed:Wait()
		controllerChip.Visible = false

		local fallbackSize = isMobile and UDim2.new(0, 380, 0, 520) or UDim2.new(0, baseWidth, 0, baseHeight)
		local fallbackPos = getCenteredPosition(fallbackSize)

		local targetSize = lastWindowSize or fallbackSize
		local storedPos = typeof(RvrseUI._lastWindowPosition) == "UDim2" and RvrseUI._lastWindowPosition or nil
		local targetPos = storedPos or lastWindowPosition or fallbackPos

		-- Clamp chip position and target position to stay on-screen
		local clampedChipPos = clampToScreen(chipCenterPos, targetSize)
		local clampedTargetPos = clampToScreen(targetPos, targetSize)

		-- Spawn window at clamped chip center, then animate to clamped original position
		root.Visible = true
		root.Size = targetSize
		root.Position = clampedChipPos
		root.Rotation = 0
		root.BackgroundTransparency = 1

		if Particles then
			Particles:SetLayer(particleLayer)
			Particles:Play("expand")
		end

		-- Animate FROM clamped chip center TO clamped original position
		local restoreTween = Animator:Tween(root, {
			Position = clampedTargetPos,
			BackgroundTransparency = 1
		}, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))

		task.defer(function()
			snapshotLayout("post-restore")
		end)

		restoreTween.Completed:Wait()
		task.wait(0.05)
		isAnimating = false
		lastWindowSize = targetSize
		rememberWindowPosition(clampedTargetPos)
		Debug.printf("[RESTORE] ✅ Animation complete - drag unlocked")

		task.delay(0.25, function()
			if Particles and not isMinimized then
				Particles:SetState("idle")
			end
		end)

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

			-- Throttle particles during chip drag
			if Particles and isMinimized then
				Particles:SetState("dragging")
			end

			Debug.printf("[CHIP DRAG] Started - mouse: (%.1f, %.1f), chip: %s",
				input.Position.X, input.Position.Y, tostring(controllerChip.Position))

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					chipDragging = false

					-- Restore idle particles after drag
					if Particles and isMinimized then
						Particles:SetState("idle")
					end

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

	-- ═══════════════════════════════════════════════════════════════
	-- GLOBAL SEARCH SYSTEM
	-- ═══════════════════════════════════════════════════════════════

	-- Track all searchable elements across all tabs/sections
	local searchableElements = {}
	local searchOverlayVisible = false

	-- Search overlay container
	local searchOverlay = Instance.new("Frame")
	searchOverlay.Name = "SearchOverlay"
	searchOverlay.BackgroundColor3 = pal.Bg
	searchOverlay.BackgroundTransparency = 0.05
	searchOverlay.BorderSizePixel = 0
	searchOverlay.Position = UDim2.new(0, 0, 0, 0)
	searchOverlay.Size = UDim2.new(1, 0, 1, 0)
	searchOverlay.ZIndex = 5000
	searchOverlay.Visible = false
	searchOverlay.Parent = panelMask
	UIHelpers.corner(searchOverlay, 16)

	-- Search header
	local searchHeader = Instance.new("Frame")
	searchHeader.Name = "SearchHeader"
	searchHeader.BackgroundColor3 = pal.Card
	searchHeader.BackgroundTransparency = 0
	searchHeader.BorderSizePixel = 0
	searchHeader.Size = UDim2.new(1, 0, 0, 60)
	searchHeader.ZIndex = 5001
	searchHeader.Parent = searchOverlay
	UIHelpers.corner(searchHeader, 16)

	-- Search input container
	local searchInputContainer = Instance.new("Frame")
	searchInputContainer.Name = "SearchInputContainer"
	searchInputContainer.BackgroundColor3 = pal.Elevated
	searchInputContainer.BorderSizePixel = 0
	searchInputContainer.Position = UDim2.new(0, 16, 0.5, -18)
	searchInputContainer.Size = UDim2.new(1, -100, 0, 36)
	searchInputContainer.ZIndex = 5002
	searchInputContainer.Parent = searchHeader
	UIHelpers.corner(searchInputContainer, 10)
	UIHelpers.stroke(searchInputContainer, pal.Border, 1)

	-- Search icon in input
	local searchInputIcon = Instance.new("ImageLabel")
	searchInputIcon.Name = "SearchIcon"
	searchInputIcon.BackgroundTransparency = 1
	searchInputIcon.Position = UDim2.new(0, 10, 0.5, -9)
	searchInputIcon.Size = UDim2.new(0, 18, 0, 18)
	searchInputIcon.ZIndex = 5003
	searchInputIcon.Parent = searchInputContainer

	local searchIconAsset, searchIconType = Icons.resolveIcon("lucide://search")
	if searchIconType == "sprite" and searchIconAsset then
		searchInputIcon.Image = "rbxassetid://" .. searchIconAsset.id
		searchInputIcon.ImageRectSize = searchIconAsset.imageRectSize
		searchInputIcon.ImageRectOffset = searchIconAsset.imageRectOffset
		searchInputIcon.ImageColor3 = pal.TextMuted
	end

	-- Search input field
	local searchInput = Instance.new("TextBox")
	searchInput.Name = "SearchInput"
	searchInput.BackgroundTransparency = 1
	searchInput.Position = UDim2.new(0, 36, 0, 0)
	searchInput.Size = UDim2.new(1, -46, 1, 0)
	searchInput.Font = Enum.Font.Gotham
	searchInput.TextSize = 14
	searchInput.TextColor3 = pal.Text
	searchInput.PlaceholderText = "Search tabs, sections, elements..."
	searchInput.PlaceholderColor3 = pal.TextMuted
	searchInput.Text = ""
	searchInput.TextXAlignment = Enum.TextXAlignment.Left
	searchInput.ClearTextOnFocus = false
	searchInput.ZIndex = 5003
	searchInput.Parent = searchInputContainer

	-- Close search button
	local closeSearchBtn = Instance.new("TextButton")
	closeSearchBtn.Name = "CloseSearch"
	closeSearchBtn.AnchorPoint = Vector2.new(1, 0.5)
	closeSearchBtn.Position = UDim2.new(1, -16, 0.5, 0)
	closeSearchBtn.Size = UDim2.new(0, 32, 0, 32)
	closeSearchBtn.BackgroundColor3 = pal.Elevated
	closeSearchBtn.BorderSizePixel = 0
	closeSearchBtn.Text = ""
	closeSearchBtn.AutoButtonColor = false
	closeSearchBtn.ZIndex = 5002
	closeSearchBtn.Parent = searchHeader
	UIHelpers.corner(closeSearchBtn, 8)
	UIHelpers.stroke(closeSearchBtn, pal.Border, 1)

	local closeSearchIcon = createHeaderIcon(closeSearchBtn, {
		size = 16,
		color = pal.TextSub
	})
	closeSearchIcon.SetIcon("lucide://x", pal.TextSub)

	-- Search results container
	local searchResults = Instance.new("ScrollingFrame")
	searchResults.Name = "SearchResults"
	searchResults.BackgroundTransparency = 1
	searchResults.BorderSizePixel = 0
	searchResults.Position = UDim2.new(0, 0, 0, 70)
	searchResults.Size = UDim2.new(1, 0, 1, -80)
	searchResults.CanvasSize = UDim2.new(0, 0, 0, 0)
	searchResults.AutomaticCanvasSize = Enum.AutomaticSize.Y
	searchResults.ScrollBarThickness = 4
	searchResults.ScrollBarImageColor3 = pal.Border
	searchResults.ScrollBarImageTransparency = 0.3
	searchResults.ZIndex = 5001
	searchResults.Parent = searchOverlay

	local searchResultsPadding = Instance.new("UIPadding")
	searchResultsPadding.PaddingTop = UDim.new(0, 8)
	searchResultsPadding.PaddingBottom = UDim.new(0, 16)
	searchResultsPadding.PaddingLeft = UDim.new(0, 16)
	searchResultsPadding.PaddingRight = UDim.new(0, 16)
	searchResultsPadding.Parent = searchResults

	local searchResultsLayout = Instance.new("UIListLayout")
	searchResultsLayout.Padding = UDim.new(0, 6)
	searchResultsLayout.FillDirection = Enum.FillDirection.Vertical
	searchResultsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	searchResultsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	searchResultsLayout.Parent = searchResults

	-- No results label
	local noResultsLabel = Instance.new("TextLabel")
	noResultsLabel.Name = "NoResults"
	noResultsLabel.BackgroundTransparency = 1
	noResultsLabel.Size = UDim2.new(1, 0, 0, 60)
	noResultsLabel.Font = Enum.Font.Gotham
	noResultsLabel.TextSize = 14
	noResultsLabel.TextColor3 = pal.TextMuted
	noResultsLabel.Text = "No results found"
	noResultsLabel.Visible = false
	noResultsLabel.ZIndex = 5002
	noResultsLabel.Parent = searchResults

	-- Function to register an element for search
	local function registerSearchableElement(elementData)
		table.insert(searchableElements, elementData)
	end

	-- Function to create a search result item
	local function createSearchResultItem(elementData, index)
		local currentPal = Theme:Get()

		local resultItem = Instance.new("TextButton")
		resultItem.Name = "Result_" .. index
		resultItem.BackgroundColor3 = currentPal.Card
		resultItem.BorderSizePixel = 0
		resultItem.Size = UDim2.new(1, 0, 0, 52)
		resultItem.Text = ""
		resultItem.AutoButtonColor = false
		resultItem.LayoutOrder = index
		resultItem.ZIndex = 5002
		resultItem.Parent = searchResults
		UIHelpers.corner(resultItem, 10)
		UIHelpers.stroke(resultItem, currentPal.Border, 1)

		-- Icon holder
		local iconHolder = Instance.new("Frame")
		iconHolder.BackgroundTransparency = 1
		iconHolder.Position = UDim2.new(0, 12, 0.5, -12)
		iconHolder.Size = UDim2.new(0, 24, 0, 24)
		iconHolder.ZIndex = 5003
		iconHolder.Parent = resultItem

		if elementData.icon then
			local iconAsset, iconType = Icons.resolveIcon(elementData.icon)
			if iconType == "sprite" and iconAsset then
				local img = Instance.new("ImageLabel")
				img.BackgroundTransparency = 1
				img.Size = UDim2.new(1, 0, 1, 0)
				img.Image = "rbxassetid://" .. iconAsset.id
				img.ImageRectSize = iconAsset.imageRectSize
				img.ImageRectOffset = iconAsset.imageRectOffset
				img.ImageColor3 = currentPal.Accent
				img.Parent = iconHolder
			elseif iconType == "image" then
				local img = Instance.new("ImageLabel")
				img.BackgroundTransparency = 1
				img.Size = UDim2.new(1, 0, 1, 0)
				img.Image = iconAsset
				img.ImageColor3 = currentPal.Accent
				img.Parent = iconHolder
			elseif iconType == "text" then
				local lbl = Instance.new("TextLabel")
				lbl.BackgroundTransparency = 1
				lbl.Size = UDim2.new(1, 0, 1, 0)
				lbl.Font = Enum.Font.GothamBold
				lbl.TextSize = 16
				lbl.TextColor3 = currentPal.Accent
				lbl.Text = tostring(iconAsset)
				lbl.Parent = iconHolder
			end
		end

		-- Element name
		local nameLabel = Instance.new("TextLabel")
		nameLabel.BackgroundTransparency = 1
		nameLabel.Position = UDim2.new(0, 44, 0, 8)
		nameLabel.Size = UDim2.new(1, -100, 0, 18)
		nameLabel.Font = Enum.Font.GothamMedium
		nameLabel.TextSize = 13
		nameLabel.TextColor3 = currentPal.Text
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
		nameLabel.Text = elementData.text or "Unknown"
		nameLabel.ZIndex = 5003
		nameLabel.Parent = resultItem

		-- Path (Tab > Section)
		local pathLabel = Instance.new("TextLabel")
		pathLabel.BackgroundTransparency = 1
		pathLabel.Position = UDim2.new(0, 44, 0, 28)
		pathLabel.Size = UDim2.new(1, -100, 0, 14)
		pathLabel.Font = Enum.Font.Gotham
		pathLabel.TextSize = 11
		pathLabel.TextColor3 = currentPal.TextMuted
		pathLabel.TextXAlignment = Enum.TextXAlignment.Left
		pathLabel.TextTruncate = Enum.TextTruncate.AtEnd
		pathLabel.Text = elementData.path or ""
		pathLabel.ZIndex = 5003
		pathLabel.Parent = resultItem

		-- Type badge
		local typeBadge = Instance.new("TextLabel")
		typeBadge.BackgroundColor3 = currentPal.Accent
		typeBadge.BackgroundTransparency = 0.85
		typeBadge.AnchorPoint = Vector2.new(1, 0.5)
		typeBadge.Position = UDim2.new(1, -12, 0.5, 0)
		typeBadge.Size = UDim2.new(0, 60, 0, 20)
		typeBadge.Font = Enum.Font.GothamMedium
		typeBadge.TextSize = 10
		typeBadge.TextColor3 = currentPal.Accent
		typeBadge.Text = elementData.elementType or "Element"
		typeBadge.ZIndex = 5003
		typeBadge.Parent = resultItem
		UIHelpers.corner(typeBadge, 6)

		-- Hover effects
		resultItem.MouseEnter:Connect(function()
			Animator:Tween(resultItem, {BackgroundColor3 = currentPal.Hover}, Animator.Spring.Fast)
		end)
		resultItem.MouseLeave:Connect(function()
			Animator:Tween(resultItem, {BackgroundColor3 = currentPal.Card}, Animator.Spring.Fast)
		end)

		-- Click to navigate
		resultItem.MouseButton1Click:Connect(function()
			-- Close search overlay
			hideSearch()

			-- Navigate to the element's tab
			if elementData.tabData and elementData.tabData.btn then
				-- Simulate tab click to switch to that tab
				local tabBtn = elementData.tabData.btn
				if tabBtn then
					-- Fire the tab's click handler
					for _, tabInfo in ipairs(tabs) do
						if tabInfo.btn == tabBtn then
							tabInfo.btn:SetAttribute("Active", true)
							tabInfo.indicator.Visible = true
							tabInfo.page.Visible = true
							Animator:Tween(tabInfo.btn, {BackgroundColor3 = currentPal.Active}, Animator.Spring.Fast)
							tabInfo.btn.TextColor3 = currentPal.Text
							if tabInfo.icon then
								tabInfo.icon.ImageColor3 = currentPal.Text
							end
						else
							tabInfo.btn:SetAttribute("Active", false)
							tabInfo.indicator.Visible = false
							tabInfo.page.Visible = false
							Animator:Tween(tabInfo.btn, {BackgroundColor3 = currentPal.Card}, Animator.Spring.Fast)
							tabInfo.btn.TextColor3 = currentPal.TextSub
							if tabInfo.icon then
								tabInfo.icon.ImageColor3 = currentPal.TextSub
							end
						end
					end
				end
			end

			-- Scroll to element if possible
			if elementData.frame and elementData.frame.Parent then
				local scrollFrame = elementData.frame:FindFirstAncestorOfClass("ScrollingFrame")
				if scrollFrame then
					local framePos = elementData.frame.AbsolutePosition.Y
					local scrollPos = scrollFrame.AbsolutePosition.Y
					local offset = framePos - scrollPos
					scrollFrame.CanvasPosition = Vector2.new(0, math.max(0, offset - 50))
				end

				-- Highlight the element briefly
				if elementData.frame:IsA("GuiObject") then
					local originalColor = elementData.frame.BackgroundColor3
					Animator:Tween(elementData.frame, {BackgroundColor3 = currentPal.Accent}, TweenInfo.new(0.15))
					task.delay(0.15, function()
						if elementData.frame and elementData.frame.Parent then
							Animator:Tween(elementData.frame, {BackgroundColor3 = originalColor}, TweenInfo.new(0.3))
						end
					end)
				end
			end

			-- Trigger element callback if it's a button
			if elementData.elementType == "Button" and elementData.callback then
				task.defer(elementData.callback)
			end
		end)

		return resultItem
	end

	-- Function to perform search
	local function performSearch(query)
		-- Clear existing results
		for _, child in ipairs(searchResults:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		if not query or query == "" then
			noResultsLabel.Visible = false
			-- Show all elements when query is empty (limited to first 50)
			local count = 0
			for i, elementData in ipairs(searchableElements) do
				if count >= 50 then break end
				createSearchResultItem(elementData, i)
				count = count + 1
			end
			return
		end

		local lowerQuery = query:lower()
		local results = {}

		for _, elementData in ipairs(searchableElements) do
			local text = (elementData.text or ""):lower()
			local path = (elementData.path or ""):lower()
			local elementType = (elementData.elementType or ""):lower()

			if text:find(lowerQuery, 1, true) or path:find(lowerQuery, 1, true) or elementType:find(lowerQuery, 1, true) then
				table.insert(results, elementData)
			end
		end

		if #results == 0 then
			noResultsLabel.Visible = true
			noResultsLabel.Text = 'No results for "' .. query .. '"'
		else
			noResultsLabel.Visible = false
			for i, elementData in ipairs(results) do
				if i > 100 then break end -- Limit results
				createSearchResultItem(elementData, i)
			end
		end
	end

	-- Show/hide search functions
	local function showSearch()
		if searchOverlayVisible then return end
		searchOverlayVisible = true
		searchOverlay.Visible = true
		searchOverlay.BackgroundTransparency = 1
		Animator:Tween(searchOverlay, {BackgroundTransparency = 0.05}, TweenInfo.new(0.2))
		searchInput:CaptureFocus()
		performSearch("")
	end

	function hideSearch()
		if not searchOverlayVisible then return end
		searchOverlayVisible = false
		searchInput.Text = ""
		searchInput:ReleaseFocus()
		Animator:Tween(searchOverlay, {BackgroundTransparency = 1}, TweenInfo.new(0.15))
		task.delay(0.15, function()
			if not searchOverlayVisible then
				searchOverlay.Visible = false
			end
		end)
	end

	-- Wire up search button
	searchBtn.MouseButton1Click:Connect(function()
		Animator:Ripple(searchBtn, 16, 12)
		if searchOverlayVisible then
			hideSearch()
		else
			showSearch()
		end
	end)

	-- Wire up close button
	closeSearchBtn.MouseEnter:Connect(function()
		local currentPal = Theme:Get()
		Animator:Tween(closeSearchBtn, {BackgroundColor3 = currentPal.Hover}, Animator.Spring.Fast)
	end)
	closeSearchBtn.MouseLeave:Connect(function()
		local currentPal = Theme:Get()
		Animator:Tween(closeSearchBtn, {BackgroundColor3 = currentPal.Elevated}, Animator.Spring.Fast)
	end)
	closeSearchBtn.MouseButton1Click:Connect(function()
		hideSearch()
	end)

	-- Wire up search input
	local searchDebounce = nil
	searchInput:GetPropertyChangedSignal("Text"):Connect(function()
		local query = searchInput.Text
		if searchDebounce then
			task.cancel(searchDebounce)
		end
		searchDebounce = task.delay(0.15, function()
			performSearch(query)
		end)
	end)

	-- Escape to close search
	searchInput.FocusLost:Connect(function(enterPressed)
		if not enterPressed then
			-- Don't close immediately, user might click a result
		end
	end)

	-- Keyboard shortcut (Ctrl+F)
	UIS.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		-- Ctrl+F or Cmd+F to open search
		if input.KeyCode == Enum.KeyCode.F then
			if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl) then
				if root.Visible and not isMinimized then
					if searchOverlayVisible then
						hideSearch()
					else
						showSearch()
					end
				end
			end
		end

		-- Escape to close search
		if input.KeyCode == Enum.KeyCode.Escape then
			if searchOverlayVisible then
				hideSearch()
			end
		end
	end)

	-- ═══════════════════════════════════════════════════════════════
	-- END GLOBAL SEARCH SYSTEM
	-- ═══════════════════════════════════════════════════════════════

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
		elseif iconType == "sprite" and iconAsset then
			local img = Instance.new("ImageLabel")
			img.BackgroundTransparency = 1
			img.Image = "rbxassetid://" .. iconAsset.id
			img.ImageRectSize = iconAsset.imageRectSize
			img.ImageRectOffset = iconAsset.imageRectOffset
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

	function WindowAPI:SetTokenIcon(tokenIcon, opts)
		opts = opts or {}

		if opts.Reset then
			local resetIcon = RvrseUI._tokenIcon
			if resetIcon == nil then
				resetIcon = "lucide://gamepad-2"
			end
			setChipIcon(resetIcon, {
				Color = RvrseUI._tokenIconColor,
				Fallback = RvrseUI._tokenIconFallback,
				UseThemeColor = RvrseUI._tokenIconColor == nil
			})
		else
			local applyOpts = {}

			if opts.Color == false then
				applyOpts.UseThemeColor = true
			elseif opts.Color ~= nil then
				applyOpts.Color = opts.Color
			end

			if opts.UseThemeColor then
				applyOpts.UseThemeColor = true
			end

			if opts.Fallback ~= nil then
				applyOpts.Fallback = opts.Fallback
			end

			setChipIcon(tokenIcon, applyOpts)
		end

		return chipIconState.icon, chipIconState.colorOverride, chipIconState.fallback
	end

	function WindowAPI:GetTokenIcon()
		return chipIconState.icon, chipIconState.colorOverride, chipIconState.fallback
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
			Overlay = Overlay,
			registerSearchableElement = registerSearchableElement
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
						if profilesDropdown then
							profilesDropdown:Refresh(list)
						end
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
						if resolveTarget and profilesDropdown then
							profilesDropdown:Set({resolveTarget}, true)
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
						CurrentOption = selectedProfile and {selectedProfile} or nil,
						OnOpen = function()
							refreshProfiles(selectedProfile, {suppressWarning = true})
						end,
						OnChanged = function(values)
						if type(values) ~= "table" or #values == 0 then
							return
						end

						local chosen = values[#values]
						if chosen == nil then
							return
						end

						-- If the last value matches the previous selection, look for another candidate
						if chosen == selectedProfile and #values > 1 then
							for _, candidate in ipairs(values) do
								if candidate ~= selectedProfile then
									chosen = candidate
									break
								end
							end
						end

						-- Collapse the multi-select array down to the resolved choice
						profilesDropdown:Set({chosen}, true)

						if not containsValue(lastProfileList, chosen) then
							return
						end

						if chosen == selectedProfile then
							updateLabels(chosen)
							return
						end

						if applyProfile(chosen) and profilesDropdown then
							profilesDropdown:Set({chosen}, true)
							profilesDropdown:SetOpen(false)
						else
							-- Revert visual selection on failure
							if selectedProfile then
								profilesDropdown:Set({selectedProfile}, true)
							else
								profilesDropdown:ClearAll()
							end
						end
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
						Text = "Refresh Profiles",
						Icon = "lucide://refresh-ccw",
						Callback = function()
							refreshProfiles(selectedProfile)
							safeNotify("Profiles", "Profile list refreshed", "info")
						end
					})

					profileSection:CreateButton({
						Text = "Save Current",
						Icon = "lucide://save",
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
						Text = "Save As",
						Icon = "lucide://folder-plus",
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
						Text = "Load Selected",
						Icon = "lucide://download",
						Callback = function()
							if not selectedProfile then
								safeNotify("Profiles", "No profile selected", "warning")
								return
							end
						applyProfile(selectedProfile, {muteNotify = false})
					end
					})

					profileSection:CreateButton({
						Text = "Delete Profile",
						Icon = "lucide://trash-2",
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
		local iconName = t == "Dark" and "lucide://moon" or "lucide://sun"
		themeIcon.SetIcon(iconName, currentPal.Accent)
		themeIcon.SetColor(currentPal.Accent)
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

		panelMask.BackgroundColor3 = newPal.Card
		UIHelpers.stroke(root, newPal.Border, 1.5)

		header.BackgroundColor3 = newPal.Elevated
		UIHelpers.stroke(header, newPal.Border, 1)
		headerDivider.BackgroundColor3 = newPal.Divider
		title.TextColor3 = newPal.Text

		minimizeBtn.BackgroundColor3 = newPal.Elevated
		minimizeIcon.SetColor(newPal.Accent)
		UIHelpers.stroke(minimizeBtn, newPal.Border, 1)

		themeToggle.BackgroundColor3 = newPal.Elevated
		themeToggle.TextColor3 = newPal.Accent
		UIHelpers.stroke(themeToggle, newPal.Border, 1)

		bellToggle.BackgroundColor3 = newPal.Elevated
		UIHelpers.stroke(bellToggle, newPal.Border, 1)
		syncBellIcon()

		closeBtn.BackgroundColor3 = newPal.Elevated
		closeIcon.SetColor(newPal.Error)
		UIHelpers.stroke(closeBtn, newPal.Border, 1)

		controllerChip.BackgroundColor3 = newPal.Card
		applyControllerChipVisuals()

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

LucideIcons:Initialize({
    HttpService = HttpService,
    Debug = Debug
})

Icons:Initialize({
    LucideIcons = LucideIcons
})

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
    FilterableList = FilterableList
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
    RvrseUI = RvrseUI,
    Icons = Icons
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

Particles:Initialize({
    Theme = Theme,
    RunService = RS
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

local function isIconLike(value)
    if typeof(value) == "string" then
        if value:match("^lucide://") or value:match("^icon://") or value:match("^rbxassetid://") or value:match("^rbxasset://") then
            return true
        end

        local success, length = pcall(utf8.len, value)
        if success and length and length <= 2 then
            return true
        end
    elseif typeof(value) == "number" then
        return true
    end

    return false
end

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
        Overlay = Overlay,
        KeySystem = KeySystem,
        Particles = Particles,
        Debug = Debug,
        Obfuscation = Obfuscation,
        Hotkeys = Hotkeys,
        Version = Version,
        Elements = Elements,
        OverlayLayer = DEFAULT_OVERLAY,
        UIS = UIS,
        GuiService = GuiService,
        RS = RS,
        RunService = RS,
        PlayerGui = PlayerGui,
        HttpService = HttpService
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
            RvrseUI = RvrseUI,
            Icons = Icons
        })
    end

    return WindowBuilder:CreateWindow(self, cfg, DEFAULT_HOST)
end

function RvrseUI:Notify(options, message, duration, notifType)
    if not self.NotificationsEnabled then return end

    local payload

    if typeof(options) == "table" then
        if table.clone then
            payload = table.clone(options)
        else
            payload = {}
            for k, v in pairs(options) do
                payload[k] = v
            end
        end
    else
        payload = {}

        if isIconLike(options) then
            payload.Icon = options
        elseif typeof(options) == "string" then
            payload.Title = options
        elseif typeof(options) == "number" then
            payload.Duration = options
        end

        if typeof(message) == "table" then
            for k, v in pairs(message) do
                payload[k] = v
            end
        elseif typeof(message) == "string" then
            if payload.Icon and not payload.Title then
                payload.Title = message
            elseif payload.Title then
                payload.Message = message
            else
                payload.Title = message
            end
        elseif typeof(message) == "number" then
            payload.Duration = message
        end

        if typeof(duration) == "number" then
            payload.Duration = duration
        elseif typeof(duration) == "string" then
            payload.Type = duration
        end

        if typeof(notifType) == "string" then
            payload.Type = notifType
        elseif typeof(notifType) == "number" then
            payload.Duration = notifType
        end

        if not payload.Title then
            payload.Title = payload.Message or "Notification"
            if payload.Message == payload.Title then
                payload.Message = nil
            end
        end
    end

    payload.Type = payload.Type or "info"

    return Notifications:Notify(payload)
end

function RvrseUI:Destroy()
    for _, window in ipairs(self._windows) do
        if window.Destroy then window:Destroy() end
    end
    if self.UI._toggleTargets then table.clear(self.UI._toggleTargets) end
    if self._lockListeners then table.clear(self._lockListeners) end
    if self._themeListeners then table.clear(self._themeListeners) end
    print("[RvrseUI] All interfaces destroyed")
end

function RvrseUI:ToggleVisibility()
    self.UI:ToggleAllWindows()
end

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

function RvrseUI:SetTheme(themeName)
    Theme:Switch(themeName)
    if self.ConfigurationSaving then self:_autoSave() end
end

function RvrseUI:GetTheme()
    return Theme.Current
end

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

Notifications:SetContext(RvrseUI)


return RvrseUI
