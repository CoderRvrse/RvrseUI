-- LucideIcons.lua
-- SVG-to-Roblox icon renderer for Lucide icon library
-- Converts Lucide SVG paths to Roblox ImageLabel components

local LucideIcons = {}

-- Cache for rendered icons to avoid re-fetching
local iconCache = {}

-- Lucide CDN base URL
local LUCIDE_CDN = "https://raw.githubusercontent.com/lucide-icons/lucide/main/icons"

-- Dependencies (injected via Initialize)
local deps

-- SVG path parser - converts SVG path data to Roblox UIStroke/ImageLabel
-- NOTE: Roblox doesn't support native SVG rendering, so we use HttpService to fetch
-- the SVG and convert it to a data URL that can be loaded as an image
local function svgToDataUrl(svgContent)
	-- Wrap SVG in proper data URL format
	-- Replace stroke="currentColor" with actual color (handled by caller)
	return "data:image/svg+xml;charset=utf-8," .. deps.HttpService:UrlEncode(svgContent)
end

-- Fetch SVG from Lucide CDN
local function fetchLucideSVG(iconName)
	-- Check cache first
	if iconCache[iconName] then
		return iconCache[iconName]
	end

	-- Convert icon name to kebab-case (Lucide naming convention)
	local kebabName = iconName:lower():gsub("_", "-")

	-- Construct URL
	local url = LUCIDE_CDN .. "/" .. kebabName .. ".svg"

	-- Fetch SVG content
	local success, result = pcall(function()
		return deps.HttpService:GetAsync(url, true)
	end)

	if not success then
		warn("[RvrseUI] Failed to fetch Lucide icon:", iconName, "-", result)
		return nil
	end

	-- Cache the result
	iconCache[iconName] = result
	return result
end

-- Create a Roblox ImageLabel from Lucide SVG
-- @param iconName: string - Lucide icon name (e.g., "home", "settings", "arrow-right")
-- @param color: Color3 - Icon color (replaces currentColor)
-- @param size: UDim2 - Icon size (default: 24x24)
-- @return ImageLabel or nil if fetch failed
function LucideIcons:CreateIcon(iconName, color, size)
	local svgContent = fetchLucideSVG(iconName)
	if not svgContent then
		return nil
	end

	-- Replace currentColor with actual hex color
	local hexColor = string.format("#%02X%02X%02X",
		math.floor(color.R * 255),
		math.floor(color.G * 255),
		math.floor(color.B * 255)
	)
	svgContent = svgContent:gsub('stroke="currentColor"', 'stroke="' .. hexColor .. '"')

	-- IMPORTANT: Roblox does NOT support data URLs in Image property
	-- We need to use a different approach - render SVG as Frame with UIStroke
	-- For now, return a placeholder and log warning

	-- Alternative approach: Store pre-converted Lucide icons as Roblox assets
	-- or use a conversion service

	warn("[RvrseUI] Lucide SVG rendering not yet supported in Roblox")
	warn("[RvrseUI] Consider using pre-converted assets or Unicode fallbacks")

	return nil
end

-- Resolve a Lucide icon name to a usable format
-- Returns: iconValue (string), iconType (string), lucideData (table)
-- @param iconName: string - Icon name (e.g., "home", "settings")
function LucideIcons:Resolve(iconName)
	-- Fetch SVG data
	local svgContent = fetchLucideSVG(iconName)
	if not svgContent then
		return nil, nil, nil
	end

	-- Parse SVG to extract paths (for potential rendering)
	local paths = {}
	for path in svgContent:gmatch('<path d="([^"]*)"') do
		table.insert(paths, path)
	end

	-- Parse circles
	local circles = {}
	for cx, cy, r in svgContent:gmatch('<circle cx="([^"]*)" cy="([^"]*)" r="([^"]*)"') do
		table.insert(circles, {cx = tonumber(cx), cy = tonumber(cy), r = tonumber(r)})
	end

	-- Return structured data
	return iconName, "lucide", {
		name = iconName,
		svg = svgContent,
		paths = paths,
		circles = circles
	}
end

-- ALTERNATIVE SOLUTION: Pre-converted Lucide icon mapping
-- Since Roblox cannot render SVG directly, we provide a mapping of popular
-- Lucide icons to their Roblox asset IDs (user would upload these manually)
-- or to Unicode equivalents

LucideIcons.AssetMap = {
	-- Example mappings (user would populate with uploaded assets)
	-- ["home"] = 1234567890,  -- Roblox asset ID
	-- ["settings"] = 9876543210,
}

-- Fallback: Map Lucide icons to Unicode equivalents
LucideIcons.UnicodeFallbacks = {
	-- Navigation
	["home"] = "🏠",
	["menu"] = "☰",
	["settings"] = "⚙",
	["search"] = "🔍",
	["x"] = "✕",
	["check"] = "✓",

	-- Arrows
	["arrow-up"] = "↑",
	["arrow-down"] = "↓",
	["arrow-left"] = "←",
	["arrow-right"] = "→",
	["chevron-up"] = "▲",
	["chevron-down"] = "▼",
	["chevron-left"] = "◀",
	["chevron-right"] = "▶",

	-- Actions
	["plus"] = "+",
	["minus"] = "-",
	["edit"] = "✎",
	["trash"] = "🗑",
	["save"] = "💾",
	["download"] = "⬇",
	["upload"] = "⬆",
	["refresh"] = "↻",

	-- Media
	["play"] = "▶",
	["pause"] = "⏸",
	["stop"] = "⏹",
	["volume"] = "🔊",
	["volume-x"] = "🔇",

	-- Status
	["alert-triangle"] = "⚠",
	["alert-circle"] = "⚠",
	["info"] = "ℹ",
	["help-circle"] = "❓",
	["check-circle"] = "✓",
	["x-circle"] = "✕",

	-- User
	["user"] = "👤",
	["users"] = "👥",
	["message-circle"] = "💬",
	["mail"] = "✉",

	-- Security
	["lock"] = "🔒",
	["unlock"] = "🔓",
	["key"] = "🔑",
	["shield"] = "🛡",

	-- Objects
	["package"] = "📦",
	["gift"] = "🎁",
	["shopping-cart"] = "🛒",

	-- Files
	["file"] = "📄",
	["folder"] = "📁",
	["link"] = "🔗",

	-- Tech
	["code"] = "⌨",
	["terminal"] = "⌨",
	["database"] = "🗄",
	["server"] = "🖥",
	["cpu"] = "⚙",
	["wifi"] = "📶",
	["battery"] = "🔋",
	["power"] = "⚡",

	-- Nature
	["sun"] = "☀",
	["moon"] = "🌙",
	["star"] = "⭐",
	["cloud"] = "☁",
	["droplet"] = "💧",
	["flame"] = "🔥",

	-- Emotions
	["heart"] = "❤",
	["smile"] = "😊",

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

-- Get a usable icon representation (asset ID or Unicode fallback)
-- @param iconName: string - Lucide icon name
-- @return value (number or string), type ("image" or "text")
function LucideIcons:Get(iconName)
	-- Check if user has uploaded asset
	if self.AssetMap[iconName] then
		return self.AssetMap[iconName], "image"
	end

	-- Use Unicode fallback
	if self.UnicodeFallbacks[iconName] then
		return self.UnicodeFallbacks[iconName], "text"
	end

	-- No fallback available - return the icon name as text
	warn("[RvrseUI] No fallback for Lucide icon:", iconName)
	return iconName, "text"
end

-- Initialize method (called by init.lua)
function LucideIcons:Initialize(dependencies)
	deps = dependencies

	-- Log initialization
	if deps.Debug then
		deps.Debug.printf("[LUCIDE] Lucide icon system initialized")
		deps.Debug.printf("[LUCIDE] %d Unicode fallbacks available", #self.UnicodeFallbacks)
	end
end

return LucideIcons
