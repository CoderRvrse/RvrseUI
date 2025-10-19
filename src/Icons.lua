-- Icons.lua
-- Unicode icon library and resolution system for RvrseUI
-- Extracted from RvrseUI.lua (lines 548-756)
-- Now supports Lucide icons via lucide:// protocol

local Icons = {}

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

return Icons
