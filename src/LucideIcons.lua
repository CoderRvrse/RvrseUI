-- LucideIcons.lua
-- Professional Lucide icon integration using sprite sheets (Rayfield pattern)
-- Provides 500+ pixel-perfect icons via ImageRectOffset/ImageRectSize

local LucideIcons = {}

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

return LucideIcons
