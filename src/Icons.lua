-- Icons.lua
-- Unicode icon library and resolution system for RvrseUI
-- Extracted from RvrseUI.lua (lines 548-756)

local Icons = {}

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
-- @param icon: string (icon name/emoji/rbxassetid) or number (Roblox asset ID)
-- @return iconValue: string (unicode char or asset URL), iconType: string ("text" or "image")
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

-- Initialize method (called by init.lua)
function Icons:Initialize()
	-- Icons table is ready to use, no initialization needed
	-- UnicodeIcons are defined at module load time
end

return Icons
