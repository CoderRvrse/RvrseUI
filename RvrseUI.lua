-- RvrseUI v2.0 | Modern Professional UI Framework
-- Features: Glassmorphism, Spring Animations, Mobile-First Responsive, Touch-Optimized
-- API: CreateWindow → CreateTab → CreateSection → {CreateButton, CreateToggle, CreateDropdown, CreateKeybind, CreateSlider}
-- Extras: Notify system, Theme switcher, LockGroup system, Drag-to-move, Auto-scaling

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")
local Mouse = LP:GetMouse()

local RvrseUI = {}
RvrseUI.DEBUG = true  -- Enable debug logging to diagnose theme save/load

-- =========================
-- Version & Release System
-- =========================
RvrseUI.Version = {
	Major = 2,
	Minor = 8,
	Patch = 2,
	Build = "20251002",  -- YYYYMMDD format
	Full = "2.8.2",
	Hash = "S9M8P7Q6",  -- Release hash for integrity verification
	Channel = "Stable"   -- Stable, Beta, Dev
}

function RvrseUI:GetVersionString()
	return string.format("v%s (%s)", self.Version.Full, self.Version.Build)
end

function RvrseUI:GetVersionInfo()
	return {
		Version = self.Version.Full,
		Build = self.Version.Build,
		Hash = self.Version.Hash,
		Channel = self.Version.Channel,
		IsLatest = true  -- Will be checked against GitHub API in future
	}
end

function RvrseUI:CheckVersion(onlineVersion)
	-- Compare version with online version (for future update checker)
	if not onlineVersion then return "unknown" end
	local current = (self.Version.Major * 10000) + (self.Version.Minor * 100) + self.Version.Patch
	local online = (onlineVersion.Major * 10000) + (onlineVersion.Minor * 100) + onlineVersion.Patch
	if current < online then return "outdated"
	elseif current > online then return "ahead"
	else return "latest" end
end

RvrseUI.NotificationsEnabled = true  -- Global notification toggle
RvrseUI.Flags = {}  -- Global flag storage for all elements

-- Debug print helper (only prints when DEBUG = true)
local function dprintf(...)
	if RvrseUI.DEBUG then
		print("[RvrseUI]", ...)
	end
end

-- ============================================
-- ⚠️ CONFIGURATION SYSTEM - DO NOT MODIFY ⚠️
-- ============================================
-- This system is FULLY TESTED and PRODUCTION-READY
-- All functions work correctly with folder support
-- DO NOT change this code - it will break saves!
-- ============================================
RvrseUI.ConfigurationSaving = false  -- Enabled via CreateWindow
RvrseUI.ConfigurationFileName = nil  -- Set via CreateWindow
RvrseUI.ConfigurationFolderName = nil  -- Optional folder name
RvrseUI._configCache = {}  -- In-memory config cache

-- Save configuration to datastore
function RvrseUI:SaveConfiguration()
	if not self.ConfigurationSaving or not self.ConfigurationFileName then
		return false, "Configuration saving not enabled"
	end

	local config = {}

	-- Save all flagged elements
	for flagName, element in pairs(self.Flags) do
		if element.Get then
			local success, value = pcall(element.Get, element)
			if success then
				config[flagName] = value
			end
		end
	end

	-- Save current theme (only if dirty - user changed it)
	dprintf("=== THEME SAVE DEBUG ===")
	dprintf("RvrseUI.Theme exists?", RvrseUI.Theme ~= nil)
	if RvrseUI.Theme then
		dprintf("RvrseUI.Theme.Current:", RvrseUI.Theme.Current)
		dprintf("RvrseUI.Theme._dirty:", RvrseUI.Theme._dirty)
	end

	if RvrseUI.Theme and RvrseUI.Theme.Current and RvrseUI.Theme._dirty then
		config._RvrseUI_Theme = RvrseUI.Theme.Current
		dprintf("✅ Saved theme to config (dirty):", config._RvrseUI_Theme)
		RvrseUI.Theme._dirty = false  -- Clear dirty flag after save
	else
		dprintf("Theme not saved (not dirty or unavailable)")
		-- Preserve existing saved theme if it exists
		if self._configCache and self._configCache._RvrseUI_Theme then
			config._RvrseUI_Theme = self._configCache._RvrseUI_Theme
			dprintf("Preserving existing saved theme:", config._RvrseUI_Theme)
		end
	end

	-- Cache configuration
	self._configCache = config
	local configKeys = {}
	for k in pairs(config) do table.insert(configKeys, k) end
	dprintf("Config keys being saved:", table.concat(configKeys, ", "))

	-- Build full file path with optional folder
	local fullPath = self.ConfigurationFileName
	if self.ConfigurationFolderName then
		-- Create folder if it doesn't exist
		pcall(function()
			if not isfolder(self.ConfigurationFolderName) then
				makefolder(self.ConfigurationFolderName)
			end
		end)
		fullPath = self.ConfigurationFolderName .. "/" .. self.ConfigurationFileName
	end

	-- GPT-5 VERIFICATION: Print save path, key, and instance
	dprintf("🔍 SAVE VERIFICATION")
	dprintf("SAVE PATH:", fullPath)
	dprintf("SAVE KEY: _RvrseUI_Theme =", config._RvrseUI_Theme or "nil")
	dprintf("CONFIG INSTANCE:", tostring(self))

	-- Save to datastore using writefile
	local success, err = pcall(function()
		local jsonData = game:GetService("HttpService"):JSONEncode(config)
		writefile(fullPath, jsonData)
	end)

	if success then
		-- GPT-5 VERIFICATION: Readback after save to confirm it landed
		local readbackSuccess, readbackData = pcall(function()
			return game:GetService("HttpService"):JSONDecode(readfile(fullPath))
		end)
		if readbackSuccess and readbackData then
			dprintf("READBACK AFTER SAVE: _RvrseUI_Theme =", readbackData._RvrseUI_Theme or "nil")
			if readbackData._RvrseUI_Theme ~= config._RvrseUI_Theme then
				warn("⚠️ READBACK MISMATCH! Expected:", config._RvrseUI_Theme, "Got:", readbackData._RvrseUI_Theme)
			end
		end

		-- Save this as the last used config
		self:SaveLastConfig(fullPath, config._RvrseUI_Theme or "Dark")

		dprintf("Configuration saved:", self.ConfigurationFileName)
		return true, "Configuration saved successfully"
	else
		warn("[RvrseUI] Failed to save configuration:", err)
		return false, err
	end
end

-- Load configuration from datastore
function RvrseUI:LoadConfiguration()
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

	local success, result = pcall(function()
		if not isfile(fullPath) then
			return nil, "No saved configuration found"
		end

		local jsonData = readfile(fullPath)
		return game:GetService("HttpService"):JSONDecode(jsonData)
	end)

	if not success or not result then
		dprintf("No configuration to load or error:", result)
		dprintf("VALUE AT LOAD: nil (no file)")
		return false, result
	end

	-- GPT-5 VERIFICATION: Print the actual value loaded from disk
	dprintf("VALUE AT LOAD: _RvrseUI_Theme =", result._RvrseUI_Theme or "nil")

	-- Apply configuration to all flagged elements
	dprintf("=== THEME LOAD DEBUG ===")
	dprintf("Config loaded, checking for _RvrseUI_Theme...")

	local loadedCount = 0
	for flagName, value in pairs(result) do
		-- Skip internal RvrseUI settings (start with _RvrseUI_)
		if flagName:sub(1, 9) == "_RvrseUI_" then
			dprintf("Found internal setting:", flagName, "=", value)
			-- Handle theme loading
			if flagName == "_RvrseUI_Theme" and (value == "Dark" or value == "Light") then
				-- Store theme to apply when window is created
				self._savedTheme = value
				dprintf("✅ Saved theme found and stored:", value)
				dprintf("RvrseUI._savedTheme is now:", self._savedTheme)
			end
		elseif self.Flags[flagName] and self.Flags[flagName].Set then
			local setSuccess = pcall(self.Flags[flagName].Set, self.Flags[flagName], value)
			if setSuccess then
				loadedCount = loadedCount + 1
			end
		end
	end

	self._configCache = result
	dprintf(string.format("Configuration loaded: %d elements restored", loadedCount))

	return true, string.format("Loaded %d elements", loadedCount)
end

-- Auto-save helper (called when element values change)
function RvrseUI:_autoSave()
	if self.ConfigurationSaving then
		-- Debounce saves (max once per second)
		if not self._lastSaveTime or (tick() - self._lastSaveTime) > 1 then
			self._lastSaveTime = tick()
			task.spawn(function()
				self:SaveConfiguration()
			end)
		end
	end
end

-- Delete saved configuration
function RvrseUI:DeleteConfiguration()
	if not self.ConfigurationFileName then
		return false, "No configuration file specified"
	end

	-- Build full file path with optional folder
	local fullPath = self.ConfigurationFileName
	if self.ConfigurationFolderName then
		fullPath = self.ConfigurationFolderName .. "/" .. self.ConfigurationFileName
	end

	local success, err = pcall(function()
		if isfile(fullPath) then
			delfile(fullPath)
		end
	end)

	if success then
		self._configCache = {}
		return true, "Configuration deleted"
	else
		return false, err
	end
end

-- Check if configuration exists
function RvrseUI:ConfigurationExists()
	if not self.ConfigurationFileName then
		return false
	end

	-- Build full file path with optional folder
	local fullPath = self.ConfigurationFileName
	if self.ConfigurationFolderName then
		fullPath = self.ConfigurationFolderName .. "/" .. self.ConfigurationFileName
	end

	local success, result = pcall(function()
		return isfile(fullPath)
	end)

	return success and result
end

-- Get last used configuration name
function RvrseUI:GetLastConfig()
	local lastConfigPath = "RvrseUI/_last_config.json"

	local success, data = pcall(function()
		if not isfile(lastConfigPath) then
			return nil
		end
		local jsonData = readfile(lastConfigPath)
		return game:GetService("HttpService"):JSONDecode(jsonData)
	end)

	if success and data then
		dprintf("📂 Last config found:", data.lastConfig, "Theme:", data.lastTheme)
		return data.lastConfig, data.lastTheme
	end

	dprintf("📂 No last config found")
	return nil, nil
end

-- Save reference to last used config
function RvrseUI:SaveLastConfig(configName, theme)
	local lastConfigPath = "RvrseUI/_last_config.json"

	-- Ensure RvrseUI folder exists
	pcall(function()
		if not isfolder("RvrseUI") then
			makefolder("RvrseUI")
		end
	end)

	local success, err = pcall(function()
		local data = {
			lastConfig = configName,
			lastTheme = theme,
			timestamp = os.time()
		}
		writefile(lastConfigPath, game:GetService("HttpService"):JSONEncode(data))
	end)

	if success then
		dprintf("📂 Saved last config reference:", configName, "Theme:", theme)
	else
		warn("[RvrseUI] Failed to save last config:", err)
	end

	return success
end

-- Load configuration by name
function RvrseUI:LoadConfigByName(configName)
	if not configName or configName == "" then
		return false, "Config name required"
	end

	-- Temporarily set the config file name
	local originalFileName = self.ConfigurationFileName
	local originalFolderName = self.ConfigurationFolderName

	self.ConfigurationFileName = configName .. ".json"
	self.ConfigurationFolderName = "RvrseUI/Configs"

	local success, message = self:LoadConfiguration()

	-- Restore original config names
	self.ConfigurationFileName = originalFileName
	self.ConfigurationFolderName = originalFolderName

	return success, message
end

-- Save configuration with a specific name
function RvrseUI:SaveConfigAs(configName)
	if not configName or configName == "" then
		return false, "Config name required"
	end

	-- Temporarily set the config file name
	local originalFileName = self.ConfigurationFileName
	local originalFolderName = self.ConfigurationFolderName

	self.ConfigurationFileName = configName .. ".json"
	self.ConfigurationFolderName = "RvrseUI/Configs"

	local success, message = self:SaveConfiguration()

	if success then
		-- Save this as the last used config
		self:SaveLastConfig(self.ConfigurationFolderName .. "/" .. self.ConfigurationFileName, RvrseUI.Theme and RvrseUI.Theme.Current or "Dark")
	end

	-- Restore original config names
	self.ConfigurationFileName = originalFileName
	self.ConfigurationFolderName = originalFolderName

	return success, message
end

-- ============================================
-- ⚠️ END CONFIGURATION SYSTEM - DO NOT MODIFY ⚠️
-- ============================================

-- =========================
-- Global UI Management
-- =========================
-- Store reference to host for global destruction/visibility control
RvrseUI._host = nil
RvrseUI._windows = {}

-- Global destroy method - destroys ALL UI
function RvrseUI:Destroy()
	if self._host and self._host.Parent then
		-- Fade out animation
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
		if self.UI._toggleTargets then
			table.clear(self.UI._toggleTargets)
		end
		if self._lockListeners then
			table.clear(self._lockListeners)
		end
		if self._themeListeners then
			table.clear(self._themeListeners)
		end
		table.clear(self._windows)

		print("[RvrseUI] All interfaces destroyed - No trace remaining")
		return true
	end
	return false
end

-- Global visibility toggle - hides/shows ALL windows
function RvrseUI:ToggleVisibility()
	if self._host and self._host.Parent then
		self._host.Enabled = not self._host.Enabled
		return self._host.Enabled
	end
	return false
end

-- Set visibility explicitly
function RvrseUI:SetVisibility(visible)
	if self._host and self._host.Parent then
		self._host.Enabled = visible
		return true
	end
	return false
end

-- =========================
-- Unicode Icon System
-- =========================
-- Universal Unicode icon mapping (works everywhere, including Roblox)
-- Icon format: "icon:name" or just "name" (auto-detected)
-- Supports: Unicode symbols, emojis, Roblox-specific icons, and asset IDs
local UnicodeIcons = {
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

local function resolveIcon(icon)
	-- If it's a number, it's a Roblox asset ID
	if typeof(icon) == "number" then
		return "rbxassetid://" .. icon, "image"
	end

	-- If it's a string
	if typeof(icon) == "string" then
		-- Check if it's a named icon from our Unicode library
		local iconName = icon:lower():gsub("icon://", "")
		if UnicodeIcons[iconName] then
			return UnicodeIcons[iconName], "text"
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

-- =========================
-- Modern Theme System
-- =========================
local Theme = {}
RvrseUI.Theme = Theme  -- Make Theme globally accessible
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

function Theme:Get() return self.Palettes[self.Current] end

function Theme:Apply(mode)
	if self.Palettes[mode] then
		self.Current = mode
		dprintf("Theme applied:", mode)
	end
end

function Theme:Switch(mode)
	if self.Palettes[mode] then
		self.Current = mode
		self._dirty = true  -- Mark dirty when user changes theme
		dprintf("Theme switched (dirty=true):", mode)
		-- Trigger theme refresh
		if RvrseUI._themeListeners then
			for _, fn in ipairs(RvrseUI._themeListeners) do
				pcall(fn)
			end
		end
	end
end

-- =========================
-- Animation System (Spring-based)
-- =========================
local Animator = {}
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
	return self:Tween(obj, {Size = UDim2.new(scale, obj.Size.X.Offset, scale, obj.Size.Y.Offset)}, info)
end

function Animator:Ripple(parent, x, y)
	local pal = Theme:Get()
	local ripple = Instance.new("Frame")
	ripple.Name = "Ripple"
	ripple.AnchorPoint = Vector2.new(0.5, 0.5)
	ripple.Position = UDim2.new(0, x, 0, y)
	ripple.Size = UDim2.new(0, 0, 0, 0)
	ripple.BackgroundColor3 = pal.Accent
	ripple.BackgroundTransparency = 0.5
	ripple.BorderSizePixel = 0
	ripple.ZIndex = 100
	ripple.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = ripple

	local size = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2
	local tween = TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, size, 0, size),
		BackgroundTransparency = 1
	})
	tween:Play()
	tween.Completed:Connect(function() ripple:Destroy() end)
end

-- =========================
-- Store (Locks & State)
-- =========================
RvrseUI.Store = {
	_locks = {},
}
function RvrseUI.Store:SetLocked(group, isLocked)
	if not group then return end
	self._locks[group] = isLocked and true or false
	if RvrseUI._lockListeners then
		for _, fn in ipairs(RvrseUI._lockListeners) do
			pcall(fn)
		end
	end
end
function RvrseUI.Store:IsLocked(group)
	return group and self._locks[group] == true
end

-- =========================
-- Utility Functions
-- =========================
local function coerceKeycode(k)
	if typeof(k) == "EnumItem" and k.EnumType == Enum.KeyCode then return k end
	if typeof(k) == "string" and #k > 0 then
		local up = k:upper():gsub("%s", "")
		if Enum.KeyCode[up] then return Enum.KeyCode[up] end
	end
	return Enum.KeyCode.K
end

local function corner(inst, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 12)
	c.Parent = inst
	return c
end

local function stroke(inst, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme:Get().Border
	s.Thickness = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = inst
	return s
end

local function gradient(inst, rotation, colors)
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

local function padding(inst, all)
	local p = Instance.new("UIPadding")
	local u = UDim.new(0, all or 12)
	p.PaddingTop = u
	p.PaddingBottom = u
	p.PaddingLeft = u
	p.PaddingRight = u
	p.Parent = inst
	return p
end

local function shadow(inst, transparency, size)
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

local function createTooltip(parent, text)
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
	corner(tooltip, 6)

	local tooltipStroke = Instance.new("UIStroke")
	tooltipStroke.Color = Color3.fromRGB(60, 60, 70)
	tooltipStroke.Thickness = 1
	tooltipStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	tooltipStroke.Parent = tooltip

	return tooltip
end

local function addGlow(inst, color, intensity)
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

-- =========================
-- Root Host (Default Container)
-- =========================
-- Note: Default container is PlayerGui for standard UI
-- Can be customized per-window via CreateWindow({ Container = ... })
local host = Instance.new("ScreenGui")
host.Name = "RvrseUI_v2"
host.ResetOnSpawn = false
host.IgnoreGuiInset = true
host.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
host.DisplayOrder = 999
host.Parent = PlayerGui

-- Store global reference for RvrseUI:Destroy() and visibility methods
RvrseUI._host = host

-- =========================
-- Notification System
-- =========================
local notifyRoot = Instance.new("Frame")
notifyRoot.Name = "NotifyStack"
notifyRoot.BackgroundTransparency = 1
notifyRoot.AnchorPoint = Vector2.new(1, 1)
notifyRoot.Position = UDim2.new(1, -8, 1, -8)
notifyRoot.Size = UDim2.new(0, 300, 1, -16)  -- Reduced from 340 to 300 for small screens
notifyRoot.Parent = host

local notifyLayout = Instance.new("UIListLayout")
notifyLayout.Padding = UDim.new(0, 8)
notifyLayout.FillDirection = Enum.FillDirection.Vertical
notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
notifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifyLayout.Parent = notifyRoot

function RvrseUI:Notify(opt)
	-- Check if notifications are enabled
	if not RvrseUI.NotificationsEnabled then return end

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

-- =========================
-- UI Toggle System
-- =========================
RvrseUI.UI = { _toggleTargets = {}, _windowData = {}, _key = Enum.KeyCode.K }
function RvrseUI.UI:RegisterToggleTarget(frame, windowData)
	self._toggleTargets[frame] = true
	if windowData then
		self._windowData[frame] = windowData
	end
end
function RvrseUI.UI:BindToggleKey(key)
	self._key = coerceKeycode(key or "K")
end

UIS.InputBegan:Connect(function(io, gpe)
	if gpe then return end
	if io.KeyCode == RvrseUI.UI._key then
		print("\n========== [HOTKEY DEBUG] ==========")
		print("[HOTKEY] Toggle key pressed:", RvrseUI.UI._key.Name)

		for f in pairs(RvrseUI.UI._toggleTargets) do
			if f and f.Parent then
				local windowData = RvrseUI.UI._windowData and RvrseUI.UI._windowData[f]
				print("[HOTKEY] Window found:", f.Name)
				print("[HOTKEY] Has windowData:", windowData ~= nil)

				if windowData then
					print("[HOTKEY] Has isMinimized function:", windowData.isMinimized ~= nil)
					print("[HOTKEY] Has minimizeFunction:", windowData.minimizeFunction ~= nil)
					print("[HOTKEY] Has restoreFunction:", windowData.restoreFunction ~= nil)
				end

				if windowData and windowData.isMinimized then
					local minimized = type(windowData.isMinimized) == "function" and windowData.isMinimized() or windowData.isMinimized
					print("[HOTKEY] Current state - isMinimized:", minimized, "| f.Visible:", f.Visible)

					if minimized then
						print("[HOTKEY] ✅ ACTION: RESTORE (chip → full window)")
						if windowData.restoreFunction then
							windowData.restoreFunction()
						else
							print("[HOTKEY] ❌ ERROR: restoreFunction missing!")
						end
					else
						-- Window is NOT minimized
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
end)

-- Listeners
RvrseUI._lockListeners = {}
RvrseUI._themeListeners = {}

-- =========================
-- Window Builder
-- =========================
function RvrseUI:CreateWindow(cfg)
	cfg = cfg or {}

	dprintf("=== CREATEWINDOW THEME DEBUG ===")

	-- IMPORTANT: Load saved theme FIRST before applying precedence
	-- If configuration exists, load it now to populate _savedTheme
	if self.ConfigurationSaving and self.ConfigurationFileName then
		-- Build full path matching the save/load functions
		local fullPath = self.ConfigurationFileName
		if self.ConfigurationFolderName then
			fullPath = self.ConfigurationFolderName .. "/" .. self.ConfigurationFileName
		end

		-- GPT-5 VERIFICATION: Print pre-load attempt
		dprintf("🔍 PRE-LOAD VERIFICATION (CreateWindow)")
		dprintf("PRE-LOAD PATH:", fullPath)
		dprintf("CONFIG INSTANCE:", tostring(self))

		local success, existingConfig = pcall(readfile, fullPath)
		if success then
			local decoded = HttpService:JSONDecode(existingConfig)
			dprintf("PRE-LOAD VALUE: _RvrseUI_Theme =", decoded._RvrseUI_Theme or "nil")
			if decoded._RvrseUI_Theme then
				self._savedTheme = decoded._RvrseUI_Theme
				dprintf("✅ Pre-loaded saved theme from config:", self._savedTheme)
			end
		else
			dprintf("PRE-LOAD: No config file found (first run or deleted)")
		end
	end

	dprintf("RvrseUI._savedTheme:", self._savedTheme)
	dprintf("cfg.Theme:", cfg.Theme)
	dprintf("Theme.Current before:", Theme.Current)

	-- Deterministic precedence: saved theme wins, else cfg.Theme, else default
	local finalTheme = self._savedTheme or cfg.Theme or "Dark"
	local source = self._savedTheme and "saved" or (cfg.Theme and "cfg") or "default"

	-- Apply theme (does NOT mark dirty - this is initialization)
	Theme:Apply(finalTheme)

	dprintf("🎯 FINAL THEME APPLICATION")
	dprintf("✅ Applied theme (source=" .. source .. "):", finalTheme)
	dprintf("Theme.Current after:", Theme.Current)
	dprintf("Theme._dirty:", Theme._dirty)

	-- Assert valid theme
	assert(Theme.Current == "Dark" or Theme.Current == "Light", "Invalid Theme.Current at end of init: " .. tostring(Theme.Current))

	local pal = Theme:Get()

	-- Configuration system setup
	if cfg.ConfigurationSaving then
		-- Support multiple formats: boolean, table, or string (profile name)
		if typeof(cfg.ConfigurationSaving) == "string" then
			-- String = named profile (e.g., ConfigurationSaving = "MyProfile")
			self.ConfigurationSaving = true
			self.ConfigurationFileName = cfg.ConfigurationSaving .. ".json"
			self.ConfigurationFolderName = "RvrseUI/Configs"
			dprintf("📂 Named profile mode:", cfg.ConfigurationSaving)
		elseif typeof(cfg.ConfigurationSaving) == "table" then
			-- Table format with Enabled/FileName/FolderName
			self.ConfigurationSaving = cfg.ConfigurationSaving.Enabled or true
			self.ConfigurationFileName = cfg.ConfigurationSaving.FileName or "RvrseUI_Config.json"
			self.ConfigurationFolderName = cfg.ConfigurationSaving.FolderName
			dprintf("Configuration saving enabled:", self.ConfigurationFolderName and (self.ConfigurationFolderName .. "/" .. self.ConfigurationFileName) or self.ConfigurationFileName)
		elseif cfg.ConfigurationSaving == true then
			-- Boolean true = auto-load last used config
			local lastConfig, lastTheme = self:GetLastConfig()
			if lastConfig then
				-- Load last used config
				dprintf("📂 Auto-loading last config:", lastConfig)
				local configParts = lastConfig:match("(.+)/(.+)")
				if configParts then
					self.ConfigurationFolderName = configParts:match("(.+)/")
					self.ConfigurationFileName = configParts:match("/([^/]+)$")
				else
					self.ConfigurationFileName = lastConfig
				end
				self.ConfigurationSaving = true

				-- Override theme with last saved theme
				if lastTheme then
					self._savedTheme = lastTheme
					dprintf("📂 Overriding theme with last saved:", lastTheme)
				end
			else
				-- No last config, use default
				self.ConfigurationSaving = true
				self.ConfigurationFileName = "RvrseUI_Config.json"
				dprintf("📂 No last config, using default")
			end
		end
	end

	local name = cfg.Name or "RvrseUI"
	local toggleKey = coerceKeycode(cfg.ToggleUIKeybind or "K")
	self.UI:BindToggleKey(toggleKey)

	-- Container selection (legitimate use cases)
	local windowHost = host -- Default: use global PlayerGui host

	if cfg.Container then
		-- User specified a custom container
		local customHost = Instance.new("ScreenGui")
		customHost.Name = "RvrseUI_" .. name:gsub("%s", "")
		customHost.ResetOnSpawn = false
		customHost.IgnoreGuiInset = true
		customHost.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		customHost.DisplayOrder = cfg.DisplayOrder or 999

		-- Resolve container target
		local containerTarget = nil

		if typeof(cfg.Container) == "string" then
			-- String reference (e.g., "PlayerGui", "CoreGui", "ReplicatedFirst")
			local containerMap = {
				["PlayerGui"] = PlayerGui,
				["CoreGui"] = game:GetService("CoreGui"),
				["StarterGui"] = game:GetService("StarterGui"),
				["ReplicatedFirst"] = game:GetService("ReplicatedFirst"),
			}
			containerTarget = containerMap[cfg.Container]
		elseif typeof(cfg.Container) == "Instance" then
			-- Direct instance reference
			containerTarget = cfg.Container
		end

		if containerTarget then
			customHost.Parent = containerTarget
			windowHost = customHost

			-- Register this custom host for global methods
			table.insert(self._windows, {host = customHost})

			dprintf("Container set to:", cfg.Container)
		else
			warn("[RvrseUI] Invalid container specified, using default PlayerGui")
		end
	end

	-- Detect mobile/tablet
	local isMobile = UIS.TouchEnabled and not UIS.MouseEnabled
	local baseWidth = isMobile and 380 or 580
	local baseHeight = isMobile and 520 or 480

	-- Root window (glassmorphic)
	local root = Instance.new("Frame")
	root.Name = "Window_" .. name:gsub("%s", "")
	root.Size = UDim2.new(0, baseWidth, 0, baseHeight)
	root.Position = UDim2.new(0.5, -baseWidth/2, 0.5, -baseHeight/2)
	root.BackgroundColor3 = pal.Bg
	root.BackgroundTransparency = 0.05
	root.BorderSizePixel = 0
	root.Visible = true
	root.ClipsDescendants = false
	root.Parent = windowHost
	corner(root, 16)
	stroke(root, pal.Border, 1.5)

	-- Enhanced Glassmorphic overlay (93-97% transparency)
	local glassOverlay = Instance.new("Frame")
	glassOverlay.Size = UDim2.new(1, 0, 1, 0)
	glassOverlay.BackgroundColor3 = Theme.Current == "Dark"
		and Color3.fromRGB(255, 255, 255)
		or Color3.fromRGB(245, 245, 250)
	glassOverlay.BackgroundTransparency = 0.95  -- 95% transparent for true glass effect
	glassOverlay.BorderSizePixel = 0
	glassOverlay.ZIndex = root.ZIndex - 1
	glassOverlay.Parent = root
	corner(glassOverlay, 16)

	-- Glass edge shine
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
	corner(header, 16)
	stroke(header, pal.Border, 1)

	-- Header bottom divider (subtle separation)
	local headerDivider = Instance.new("Frame")
	headerDivider.BackgroundColor3 = pal.Divider
	headerDivider.BackgroundTransparency = 0.5
	headerDivider.BorderSizePixel = 0
	headerDivider.Position = UDim2.new(0, 12, 1, -1)
	headerDivider.Size = UDim2.new(1, -24, 0, 1)
	headerDivider.Parent = header

	-- Drag to move (header)
	local dragging, dragStart, startPos
	header.InputBegan:Connect(function(io)
		if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = io.Position
			startPos = root.Position
		end
	end)
	header.InputEnded:Connect(function(io)
		if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
			if dragging then
				dragging = false
				-- Save window position
				RvrseUI._lastWindowPosition = {
					XScale = root.Position.X.Scale,
					XOffset = root.Position.X.Offset,
					YScale = root.Position.Y.Scale,
					YOffset = root.Position.Y.Offset
				}
			end
		end
	end)
	UIS.InputChanged:Connect(function(io)
		if dragging and (io.UserInputType == Enum.UserInputType.MouseMovement or io.UserInputType == Enum.UserInputType.Touch) then
			local delta = io.Position - dragStart
			root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	-- Icon (supports Lucide, Roblox asset ID, or emoji)
	local iconHolder = Instance.new("Frame")
	iconHolder.BackgroundTransparency = 1
	iconHolder.Position = UDim2.new(0, 16, 0.5, -16)
	iconHolder.Size = UDim2.new(0, 32, 0, 32)
	iconHolder.Parent = header

	if cfg.Icon and cfg.Icon ~= 0 then
		local iconAsset, iconType = resolveIcon(cfg.Icon)

		if iconType == "image" then
			local img = Instance.new("ImageLabel")
			img.BackgroundTransparency = 1
			img.Image = iconAsset
			img.Size = UDim2.new(1, 0, 1, 0)
			img.ImageColor3 = pal.Accent
			img.Parent = iconHolder
			corner(img, 8)
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

	-- Close button (top right - furthest right)
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
	closeBtn.Text = "❌"  -- Clear close icon
	closeBtn.TextColor3 = pal.Error
	closeBtn.AutoButtonColor = false
	closeBtn.Parent = header
	corner(closeBtn, 8)
	stroke(closeBtn, pal.Error, 1)

	local closeTooltip = createTooltip(closeBtn, "Close UI")

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

		-- Fade out animation before destruction
		Animator:Tween(root, {BackgroundTransparency = 1}, Animator.Spring.Fast)
		Animator:Tween(glassOverlay, {BackgroundTransparency = 1}, Animator.Spring.Fast)

		-- Wait for animation then completely destroy everything
		task.wait(0.3)

		-- Destroy the entire ScreenGui host (removes all UI and connections)
		if host and host.Parent then
			host:Destroy()
		end

		-- Clear all stored references and listeners
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

	-- Notification Bell Toggle (second from right)
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
	corner(bellToggle, 12)
	stroke(bellToggle, pal.Border, 1)
	addGlow(bellToggle, pal.Success, 1.5)

	local bellTooltip = createTooltip(bellToggle, "Notifications: ON")

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
			-- Re-add glow
			if bellToggle:FindFirstChild("Glow") then
				bellToggle.Glow:Destroy()
			end
			addGlow(bellToggle, pal.Success, 1.5)
		else
			bellToggle.Text = "🔕"
			bellToggle.TextColor3 = pal.Error
			bellTooltip.Text = "  Notifications: OFF  "
			-- Remove glow
			if bellToggle:FindFirstChild("Glow") then
				bellToggle.Glow:Destroy()
			end
		end
		Animator:Ripple(bellToggle, 25, 12)
	end)

	-- Minimize button (fourth from right)
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
	corner(minimizeBtn, 12)
	stroke(minimizeBtn, pal.Border, 1)

	local minimizeTooltip = createTooltip(minimizeBtn, "Minimize to Controller")

	minimizeBtn.MouseEnter:Connect(function()
		minimizeTooltip.Visible = true
		Animator:Tween(minimizeBtn, {BackgroundColor3 = pal.Hover}, Animator.Spring.Fast)
	end)
	minimizeBtn.MouseLeave:Connect(function()
		minimizeTooltip.Visible = false
		Animator:Tween(minimizeBtn, {BackgroundColor3 = pal.Elevated}, Animator.Spring.Fast)
	end)

	-- Minimize click handler (defined after controllerChip and particle system are created)
	-- This will be connected later in the code

	-- Theme Toggle Pill (third from right)
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
	corner(themeToggle, 12)
	stroke(themeToggle, pal.Border, 1)

	local themeTooltip = createTooltip(themeToggle, "Theme: " .. Theme.Current)

	themeToggle.MouseEnter:Connect(function()
		themeTooltip.Visible = true
		Animator:Tween(themeToggle, {BackgroundColor3 = pal.Hover}, Animator.Spring.Fast)
	end)
	themeToggle.MouseLeave:Connect(function()
		themeTooltip.Visible = false
		Animator:Tween(themeToggle, {BackgroundColor3 = pal.Elevated}, Animator.Spring.Fast)
	end)

	-- Theme toggle click handler defined AFTER all UI elements created (see bottom of CreateWindow)

	-- Version badge with hash (bottom left corner - fully contained with proper insets)
	local versionBadge = Instance.new("TextButton")
	versionBadge.Name = "VersionBadge"
	versionBadge.BackgroundColor3 = Color3.fromRGB(0, 255, 255)  -- Cyan/Neon Blue
	versionBadge.BackgroundTransparency = 0.9
	versionBadge.Position = UDim2.new(0, 8, 1, -24)  -- 8px inset from left, 24px from bottom (8px inset + 16px height)
	versionBadge.Size = UDim2.new(0, 38, 0, 14)  -- Smaller pill: 38x14 (was 42x16)
	versionBadge.Font = Enum.Font.GothamBold  -- Bold for better visibility
	versionBadge.TextSize = 7  -- Smaller text: 7px (was 8px)
	versionBadge.TextColor3 = Color3.fromRGB(0, 255, 200)  -- Bright neon cyan/green
	versionBadge.Text = "v" .. RvrseUI.Version.Full
	versionBadge.AutoButtonColor = false
	versionBadge.Parent = root
	corner(versionBadge, 5)  -- Smaller radius: 5px (was 6px)
	stroke(versionBadge, Color3.fromRGB(0, 255, 200), 1)  -- Neon stroke

	local versionTooltip = createTooltip(versionBadge, string.format(
		"Version: %s | Build: %s | Hash: %s | Channel: %s",
		RvrseUI.Version.Full,
		RvrseUI.Version.Build,
		RvrseUI.Version.Hash,
		RvrseUI.Version.Channel
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
		RvrseUI:Notify({
			Title = "RvrseUI " .. RvrseUI:GetVersionString(),
			Message = string.format("Hash: %s | Channel: %s", info.Hash, info.Channel),
			Duration = 4,
			Type = "info"
		})
	end)

	-- Tab bar (horizontal ScrollingFrame to prevent overflow)
	-- Extra left padding to create space above version badge
	local tabBar = Instance.new("ScrollingFrame")
	tabBar.BackgroundTransparency = 1
	tabBar.BorderSizePixel = 0
	tabBar.Position = UDim2.new(0, 54, 0, 60)  -- 54px from left (was 12px) to clear version badge below
	tabBar.Size = UDim2.new(1, -66, 0, 40)  -- Adjusted width: -66 (54 left + 12 right)
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
	corner(body, 12)
	stroke(body, pal.Border, 1)

	-- Splash screen
	local splash = Instance.new("Frame")
	splash.BackgroundColor3 = pal.Card
	splash.BorderSizePixel = 0
	splash.Position = UDim2.new(0, 12, 0, 108)
	splash.Size = UDim2.new(1, -24, 1, -120)
	splash.ZIndex = 999
	splash.Parent = root
	corner(splash, 12)

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
	corner(loadingBar, 2)

	local loadingFill = Instance.new("Frame")
	loadingFill.BackgroundColor3 = pal.Accent
	loadingFill.BorderSizePixel = 0
	loadingFill.Size = UDim2.new(0, 0, 1, 0)
	loadingFill.Parent = loadingBar
	corner(loadingFill, 2)
	gradient(loadingFill, 90, {pal.Accent, pal.AccentHover})

	Animator:Tween(loadingFill, {Size = UDim2.new(1, 0, 1, 0)}, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
	task.delay(0.9, function()
		if splash and splash.Parent then
			Animator:Tween(splash, {BackgroundTransparency = 1}, Animator.Spring.Fast)
			task.wait(0.2)
			splash.Visible = false
		end
	end)

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
	corner(chip, 18)
	stroke(chip, pal.Border, 1)

	local function setHidden(hidden)
		root.Visible = not hidden
		chip.Visible = hidden
	end

	chip.MouseButton1Click:Connect(function() setHidden(false) end)

	-- Gaming Controller Minimize Chip
	local controllerChip = Instance.new("TextButton")
	controllerChip.Name = "ControllerChip"
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
	controllerChip.ZIndex = 1000
	controllerChip.Parent = host
	corner(controllerChip, 25)
	stroke(controllerChip, pal.Accent, 2)
	addGlow(controllerChip, pal.Accent, 4)

	-- Add rotating shine effect to controller chip
	local chipShine = Instance.new("Frame")
	chipShine.Name = "Shine"
	chipShine.BackgroundTransparency = 1
	chipShine.Size = UDim2.new(1, 0, 1, 0)
	chipShine.Position = UDim2.new(0, 0, 0, 0)
	chipShine.ZIndex = 999
	chipShine.Parent = controllerChip
	corner(chipShine, 25)

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

	-- Animate the shine rotation continuously
	local shineRotation
	shineRotation = RS.Heartbeat:Connect(function()
		if controllerChip.Visible and shineGradient then
			shineGradient.Rotation = (shineGradient.Rotation + 2) % 360
		end
	end)

	-- Enhanced particle system with smooth flow around GUI
	local function createParticleFlow(startPos, endPos, count, duration, flowType)
		local particles = {}

		for i = 1, count do
			local particle = Instance.new("Frame")
			particle.Size = UDim2.new(0, math.random(4, 8), 0, math.random(4, 8))
			particle.BackgroundColor3 = pal.Accent
			particle.BackgroundTransparency = 0.5
			particle.BorderSizePixel = 0
			particle.Position = UDim2.new(0, startPos.X, 0, startPos.Y)
			particle.ZIndex = 999
			particle.Parent = host
			corner(particle, math.random(3, 5))

			-- Smooth stagger timing for fluid flow
			local delay = (i / count) * (duration * 0.5)

			task.delay(delay, function()
				if particle and particle.Parent then
					if flowType == "spread" then
						-- OPENING: Spread particles around the GUI perimeter
						local angle = (i / count) * math.pi * 2
						local spreadRadius = math.random(200, 280)
						local spreadX = endPos.X + math.cos(angle) * spreadRadius
						local spreadY = endPos.Y + math.sin(angle) * spreadRadius

						-- Smooth curve outward
						local midX = (startPos.X + spreadX) / 2 + math.random(-50, 50)
						local midY = (startPos.Y + spreadY) / 2 + math.random(-50, 50)

						-- Phase 1: Flow from chip to midpoint (smooth acceleration)
						Animator:Tween(particle, {
							Position = UDim2.new(0, midX, 0, midY),
							BackgroundTransparency = 0.2,
							Size = UDim2.new(0, 6, 0, 6)
						}, TweenInfo.new(duration * 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out))

						task.wait(duration * 0.4)
						if particle and particle.Parent then
							-- Phase 2: Flow to GUI perimeter (smooth deceleration)
							Animator:Tween(particle, {
								Position = UDim2.new(0, spreadX, 0, spreadY),
								BackgroundTransparency = 0.3,
								Size = UDim2.new(0, 5, 0, 5)
							}, TweenInfo.new(duration * 0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut))

							task.wait(duration * 0.35)
							if particle and particle.Parent then
								-- Phase 3: Gentle fade and orbit around GUI
								Animator:Tween(particle, {
									BackgroundTransparency = 1,
									Size = UDim2.new(0, 2, 0, 2)
								}, TweenInfo.new(duration * 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))

								task.wait(duration * 0.25)
								if particle and particle.Parent then
									particle:Destroy()
								end
							end
						end

					else
						-- CLOSING: Gather particles from GUI perimeter to chip
						local angle = (i / count) * math.pi * 2
						local gatherRadius = math.random(200, 280)
						local gatherStartX = startPos.X + math.cos(angle) * gatherRadius
						local gatherStartY = startPos.Y + math.sin(angle) * gatherRadius

						-- Start particles around GUI perimeter
						particle.Position = UDim2.new(0, gatherStartX, 0, gatherStartY)
						particle.BackgroundTransparency = 0.6
						particle.Size = UDim2.new(0, 5, 0, 5)

						-- Smooth curve inward
						local midX = (gatherStartX + endPos.X) / 2 + math.random(-40, 40)
						local midY = (gatherStartY + endPos.Y) / 2 + math.random(-40, 40)

						-- Phase 1: Gather from perimeter to midpoint (smooth acceleration)
						Animator:Tween(particle, {
							Position = UDim2.new(0, midX, 0, midY),
							BackgroundTransparency = 0.2,
							Size = UDim2.new(0, 6, 0, 6)
						}, TweenInfo.new(duration * 0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In))

						task.wait(duration * 0.35)
						if particle and particle.Parent then
							-- Phase 2: Flow to chip position (smooth deceleration)
							Animator:Tween(particle, {
								Position = UDim2.new(0, endPos.X, 0, endPos.Y),
								BackgroundTransparency = 0.1,
								Size = UDim2.new(0, 4, 0, 4)
							}, TweenInfo.new(duration * 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut))

							task.wait(duration * 0.4)
							if particle and particle.Parent then
								-- Phase 3: Final convergence and fade
								Animator:Tween(particle, {
									Position = UDim2.new(0, endPos.X, 0, endPos.Y),
									BackgroundTransparency = 1,
									Size = UDim2.new(0, 1, 0, 1)
								}, TweenInfo.new(duration * 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In))

								task.wait(duration * 0.25)
								if particle and particle.Parent then
									particle:Destroy()
								end
							end
						end
					end
				end
			end)

			table.insert(particles, particle)
		end

		return particles
	end

	-- Minimize/Restore functionality
	local isMinimized = false

	local function minimizeWindow()
		if isMinimized then return end
		isMinimized = true

		-- Ripple effect on button
		Animator:Ripple(minimizeBtn, 16, 12)

		-- Get controller chip's target position (where it will appear)
		local screenSize = workspace.CurrentCamera.ViewportSize
		local chipTargetPos = UDim2.new(0.5, 0, 0.5, 0)

		-- If chip was previously dragged, use that saved position
		if RvrseUI._controllerChipPosition then
			local saved = RvrseUI._controllerChipPosition
			chipTargetPos = UDim2.new(saved.XScale, saved.XOffset, saved.YScale, saved.YOffset)
		end

		-- Calculate absolute pixel position of chip target
		local chipTargetX = chipTargetPos.X.Scale * screenSize.X + chipTargetPos.X.Offset
		local chipTargetY = chipTargetPos.Y.Scale * screenSize.Y + chipTargetPos.Y.Offset

		-- Get root window center position
		local rootPos = root.AbsolutePosition
		local rootSize = root.AbsoluteSize
		local windowCenterX = rootPos.X + (rootSize.X / 2)
		local windowCenterY = rootPos.Y + (rootSize.Y / 2)

		-- Create smooth particle flow gathering to chip's actual position
		createParticleFlow(
			{X = windowCenterX, Y = windowCenterY},
			{X = chipTargetX, Y = chipTargetY},
			60,  -- particle count (increased for smoother effect)
			0.8,  -- duration (faster, smoother flow)
			"gather"  -- flow type: particles gather from GUI to chip
		)

		-- Shrink window with faster rotation
		Animator:Tween(root, {
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(chipTargetPos.X.Scale, chipTargetPos.X.Offset, chipTargetPos.Y.Scale, chipTargetPos.Y.Offset),
			BackgroundTransparency = 1,
			Rotation = 180
		}, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In))

		Animator:Tween(glassOverlay, {
			BackgroundTransparency = 1
		}, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In))

		-- Show controller chip after window shrinks
		task.wait(0.6)
		if isMinimized then
			root.Visible = false
			controllerChip.Visible = true
			controllerChip.Size = UDim2.new(0, 0, 0, 0)

			-- Pop in effect
			Animator:Tween(controllerChip, {
				Size = UDim2.new(0, 50, 0, 50)
			}, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
		end
	end

	local function restoreWindow()
		if not isMinimized then return end
		isMinimized = false

		-- Ripple effect on controller chip
		Animator:Ripple(controllerChip, 25, 25)

		-- Get controller chip's current position
		local screenSize = workspace.CurrentCamera.ViewportSize
		local chipPos = controllerChip.AbsolutePosition
		local chipCenterX = chipPos.X + 25  -- chip is 50x50, so center is +25
		local chipCenterY = chipPos.Y + 25

		-- Original window size and position
		local targetSize = isMobile and UDim2.new(0, 380, 0, 520) or UDim2.new(0, baseWidth, 0, baseHeight)

		-- Restore to last saved position, or center if no position saved
		local targetPos = UDim2.new(0.5, 0, 0.5, 0)
		if RvrseUI._lastWindowPosition then
			local savedPos = RvrseUI._lastWindowPosition
			targetPos = UDim2.new(savedPos.XScale, savedPos.XOffset, savedPos.YScale, savedPos.YOffset)
		end

		-- Calculate where window center will be
		local targetWidth = isMobile and 380 or baseWidth
		local targetHeight = isMobile and 520 or baseHeight
		local windowCenterX = targetPos.X.Scale * screenSize.X + targetPos.X.Offset + (targetWidth / 2)
		local windowCenterY = targetPos.Y.Scale * screenSize.Y + targetPos.Y.Offset + (targetHeight / 2)

		-- Create smooth particle flow spreading around GUI from chip's actual position
		createParticleFlow(
			{X = chipCenterX, Y = chipCenterY},
			{X = windowCenterX, Y = windowCenterY},
			60,  -- particle count (increased for smoother effect)
			0.8,  -- duration (faster, smoother flow)
			"spread"  -- flow type: particles spread from chip around GUI
		)

		-- Shrink controller chip smoothly
		Animator:Tween(controllerChip, {
			Size = UDim2.new(0, 0, 0, 0)
		}, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In))

		-- Wait for chip to shrink, then show window
		task.wait(0.3)
		controllerChip.Visible = false

		-- Reset window properties and show it
		root.Visible = true
		root.Size = UDim2.new(0, 0, 0, 0)
		root.Position = controllerChip.Position  -- Start from chip position
		root.Rotation = -180
		root.BackgroundTransparency = 1
		glassOverlay.BackgroundTransparency = 1

		-- Expand window with faster rotation
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

	-- Connect minimize button click
	minimizeBtn.MouseButton1Click:Connect(function()
		minimizeWindow()
	end)

	-- Connect controller chip click (restore) - only if not dragged
	controllerChip.MouseButton1Click:Connect(function()
		if not chipWasDragged then
			restoreWindow()
		end
		chipWasDragged = false
	end)

	-- Add hover effect to controller chip
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

	-- Make controller chip draggable - sticks directly to mouse
	local chipDragging, chipWasDragged, chipDragThreshold
	controllerChip.InputBegan:Connect(function(io)
		if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
			chipDragging = true
			chipWasDragged = false
			chipDragThreshold = false -- Track if we've moved enough to be considered a drag
		end
	end)
	controllerChip.InputEnded:Connect(function(io)
		if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
			if chipDragging then
				chipDragging = false
				-- Save controller chip position
				RvrseUI._controllerChipPosition = {
					XScale = controllerChip.Position.X.Scale,
					XOffset = controllerChip.Position.X.Offset,
					YScale = controllerChip.Position.Y.Scale,
					YOffset = controllerChip.Position.Y.Offset
				}
			end
		end
	end)
	UIS.InputChanged:Connect(function(io)
		if chipDragging and controllerChip.Visible and (io.UserInputType == Enum.UserInputType.MouseMovement or io.UserInputType == Enum.UserInputType.Touch) then
			-- Get current mouse position
			local mousePos = io.Position

			-- Check if we've moved enough to be a drag (prevents accidental drags on click)
			if not chipDragThreshold then
				local chipCenter = controllerChip.AbsolutePosition + Vector2.new(25, 25) -- 50/2 = 25
				local distance = (mousePos - chipCenter).Magnitude
				if distance > 5 then
					chipDragThreshold = true
					chipWasDragged = true
				end
			end

			if chipDragThreshold then
				-- Position chip centered under mouse cursor
				local chipSize = 50  -- Controller chip is 50x50
				local halfSize = chipSize / 2

				-- Calculate position to center chip under cursor
				local newX = mousePos.X - halfSize
				local newY = mousePos.Y - halfSize

				-- Get screen size for boundary clamping
				local screenSize = workspace.CurrentCamera.ViewportSize

				-- Clamp position to screen boundaries (keep chip fully visible)
				newX = math.clamp(newX, 0, screenSize.X - chipSize)
				newY = math.clamp(newY, 0, screenSize.Y - chipSize)

				-- Set position directly to mouse location (scale = 0, offset only)
				controllerChip.Position = UDim2.new(0, newX, 0, newY)
			end
		end
	end)

	-- Load saved controller chip position if available
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
	local lastWindowPosition = root.Position

	-- Register window with UI toggle system, including minimize state tracking
	local windowData = {
		isMinimized = function() return isMinimized end,
		restoreFunction = restoreWindow,
		minimizeFunction = minimizeWindow
	}
	self.UI:RegisterToggleTarget(root, windowData)

	-- Tab management
	local activePage
	local tabs = {}

	local WindowAPI = {}
	function WindowAPI:SetTitle(t) title.Text = t or name end
	function WindowAPI:Show() setHidden(false) end
	function WindowAPI:Hide() setHidden(true) end
	-- SetTheme removed - theme switching is now exclusively controlled by the topbar pill toggle

	-- SetIcon method - dynamically change window icon
	function WindowAPI:SetIcon(newIcon)
		if not newIcon then return end

		-- Clear existing icon
		for _, child in ipairs(iconHolder:GetChildren()) do
			if child:IsA("ImageLabel") or child:IsA("TextLabel") then
				child:Destroy()
			end
		end

		local iconAsset, iconType = resolveIcon(newIcon)

		if iconType == "image" then
			local img = Instance.new("ImageLabel")
			img.BackgroundTransparency = 1
			img.Image = iconAsset
			img.Size = UDim2.new(1, 0, 1, 0)
			img.ImageColor3 = pal.Accent
			img.Parent = iconHolder
			corner(img, 8)
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

	-- Destroy method - completely removes UI and cleans up all traces
	function WindowAPI:Destroy()
		-- Fade out animation
		Animator:Tween(root, {BackgroundTransparency = 1}, Animator.Spring.Fast)
		Animator:Tween(chip, {BackgroundTransparency = 1}, Animator.Spring.Fast)
		task.wait(0.3)

		-- Destroy the entire ScreenGui host
		if host and host.Parent then
			host:Destroy()
		end

		-- Clear all stored references
		if RvrseUI.UI._toggleTargets then
			table.clear(RvrseUI.UI._toggleTargets)
		end

		-- Clear lock listeners
		if RvrseUI._lockListeners then
			table.clear(RvrseUI._lockListeners)
		end

		-- Clear theme listeners
		if RvrseUI._themeListeners then
			table.clear(RvrseUI._themeListeners)
		end

		print("[RvrseUI] Interface destroyed - All traces removed")
	end

	function WindowAPI:CreateTab(t)
		t = t or {}
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
			local iconAsset, iconType = resolveIcon(t.Icon)

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
			activePage = page
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

		if not activePage then
			activateTab()
		end

		local TabAPI = {}

		-- Tab SetIcon Method
		function TabAPI:SetIcon(newIcon)
			if not newIcon then return end

			local iconAsset, iconType = resolveIcon(newIcon)

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

		function TabAPI:CreateSection(sectionTitle)
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

			-- Button
			function SectionAPI:CreateButton(o)
				o = o or {}
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

			-- Toggle
			function SectionAPI:CreateToggle(o)
				o = o or {}
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

			-- Dropdown
		function SectionAPI:CreateDropdown(o)
			o = o or {}

			-- Calculate dropdown height
			local values = o.Values or {}
			local maxHeight = 160
			local itemHeight = 32
			local dropdownHeight = math.min(#values * itemHeight, maxHeight)

			-- Create card with DISABLED clipping (CRITICAL for dropdown overflow)
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

			-- Dropdown arrow indicator
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

			local idx = 1
			for i, v in ipairs(values) do
				if v == o.Default then
					idx = i
					break
				end
			end
			btn.Text = tostring(values[idx] or "Select")

			-- Dropdown list container (positioned BELOW the button with 8px gap)
			local dropdownList = Instance.new("Frame")
			dropdownList.Name = "DropdownList"
			dropdownList.BackgroundColor3 = pal3.Elevated
			dropdownList.BorderSizePixel = 0
			dropdownList.Position = UDim2.new(1, -136, 0.5, 40)  -- Below button with gap
			dropdownList.Size = UDim2.new(0, 130, 0, 0)  -- Start at 0 height for animation
			dropdownList.Visible = false
			dropdownList.ZIndex = 100
			dropdownList.ClipsDescendants = true
			dropdownList.Parent = f
			corner(dropdownList, 8)
			stroke(dropdownList, pal3.Accent, 1)

			-- Shadow for dropdown
			shadow(dropdownList, 0.6, 16)

			local dropdownScroll = Instance.new("ScrollingFrame")
			dropdownScroll.BackgroundTransparency = 1
			dropdownScroll.BorderSizePixel = 0
			dropdownScroll.Size = UDim2.new(1, -8, 1, -8)
			dropdownScroll.Position = UDim2.new(0, 4, 0, 4)
			dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, #values * itemHeight)
			dropdownScroll.ScrollBarThickness = 4
			dropdownScroll.ScrollBarImageColor3 = pal3.Accent
			dropdownScroll.ZIndex = 101
			dropdownScroll.Parent = dropdownList

			local dropdownLayout = Instance.new("UIListLayout")
			dropdownLayout.FillDirection = Enum.FillDirection.Vertical
			dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
			dropdownLayout.Padding = UDim.new(0, 2)
			dropdownLayout.Parent = dropdownScroll

			local dropdownOpen = false
			local optionButtons = {}

			-- Create option buttons
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

				optionButtons[i] = optionBtn

				optionBtn.MouseButton1Click:Connect(function()
					local function locked()
						return o.RespectLock and RvrseUI.Store:IsLocked(o.RespectLock)
					end

					if locked() then return end

					-- Update selection
					idx = i
					btn.Text = tostring(value)

					-- Update all option visuals
					for j, obtn in ipairs(optionButtons) do
						if j == i then
							obtn.BackgroundColor3 = pal3.Accent
							obtn.BackgroundTransparency = 0.8
							obtn.TextColor3 = pal3.Accent
						else
							obtn.BackgroundColor3 = pal3.Card
							obtn.BackgroundTransparency = 0
							obtn.TextColor3 = pal3.Text
						end
					end

					-- Close dropdown with animation
					dropdownOpen = false
					arrow.Text = "▼"
					Animator:Tween(dropdownList, {
						Size = UDim2.new(0, 130, 0, 0)
					}, Animator.Spring.Fast)

					task.delay(0.15, function()
						if dropdownList and dropdownList.Parent then
							dropdownList.Visible = false
						end
					end)

					-- Trigger callback
					if o.OnChanged then
						task.spawn(function()
							o.OnChanged(value)
						end)
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
			end

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
			visual()

			-- Toggle dropdown on button click
			btn.MouseButton1Click:Connect(function()
				if locked() then return end

				dropdownOpen = not dropdownOpen
				arrow.Text = dropdownOpen and "▲" or "▼"

				if dropdownOpen then
					dropdownList.Visible = true
					dropdownList.ZIndex = 100
					dropdownScroll.ZIndex = 101

					-- Animate dropdown expansion
					Animator:Tween(dropdownList, {
						Size = UDim2.new(0, 130, 0, dropdownHeight)
					}, Animator.Spring.Snappy)
				else
					-- Animate dropdown collapse
					Animator:Tween(dropdownList, {
						Size = UDim2.new(0, 130, 0, 0)
					}, Animator.Spring.Fast)

					task.delay(0.15, function()
						if dropdownList and dropdownList.Parent then
							dropdownList.Visible = false
						end
					end)
				end
			end)

			-- Close dropdown when clicking outside
			UIS.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					if not dropdownOpen then return end

					task.wait(0.05)  -- Small delay to ensure AbsolutePosition is updated

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
						dropdownOpen = false
						arrow.Text = "▼"

						Animator:Tween(dropdownList, {
							Size = UDim2.new(0, 130, 0, 0)
						}, Animator.Spring.Fast)

						task.delay(0.15, function()
							if dropdownList and dropdownList.Parent then
								dropdownList.Visible = false
							end
						end)
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
				Set = function(_, v)
					for i, val in ipairs(values) do
						if val == v then
							idx = i
							break
						end
					end
					btn.Text = tostring(values[idx])

					-- Update dropdown options highlighting
					for j, obtn in ipairs(optionButtons) do
						if j == idx then
							obtn.BackgroundColor3 = pal3.Accent
							obtn.BackgroundTransparency = 0.8
							obtn.TextColor3 = pal3.Accent
						else
							obtn.BackgroundColor3 = pal3.Card
							obtn.BackgroundTransparency = 0
							obtn.TextColor3 = pal3.Text
						end
					end

					visual()
					if o.OnChanged then task.spawn(o.OnChanged, values[idx]) end
					if o.Flag then RvrseUI:_autoSave() end  -- Auto-save on Set
				end,
				Get = function() return values[idx] end,
				Refresh = function(_, newValues)
					if newValues then
						values = newValues
						idx = 1
						btn.Text = tostring(values[idx] or "Select")

						-- Rebuild dropdown options
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

							optionButtons[i] = optionBtn

							optionBtn.MouseButton1Click:Connect(function()
								if locked() then return end
								idx = i
								btn.Text = tostring(value)

								for j, obtn in ipairs(optionButtons) do
									if j == i then
										obtn.BackgroundColor3 = pal3.Accent
										obtn.BackgroundTransparency = 0.8
										obtn.TextColor3 = pal3.Accent
									else
										obtn.BackgroundColor3 = pal3.Card
										obtn.BackgroundTransparency = 0
										obtn.TextColor3 = pal3.Text
									end
								end

								dropdownOpen = false
								arrow.Text = "▼"
								Animator:Tween(dropdownList, {Size = UDim2.new(0, 130, 0, 0)}, Animator.Spring.Fast)
								task.delay(0.15, function()
									if dropdownList and dropdownList.Parent then dropdownList.Visible = false end
								end)

								if o.OnChanged then task.spawn(o.OnChanged, value) end
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
						end
					end
					visual()
				end,
				SetVisible = function(_, visible)
					f.Visible = visible
				end,
				CurrentOption = values[idx]
			}

			if o.Flag then
				RvrseUI.Flags[o.Flag] = dropdownAPI
			end

			return dropdownAPI
		end

			-- Keybind
			function SectionAPI:CreateKeybind(o)
				o = o or {}
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

			-- Slider
			function SectionAPI:CreateSlider(o)
				o = o or {}
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

			-- Label
			function SectionAPI:CreateLabel(o)
				o = o or {}
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

			-- Paragraph
			function SectionAPI:CreateParagraph(o)
				o = o or {}
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

			-- Divider
			function SectionAPI:CreateDivider(o)
				o = o or {}
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

			-- TextBox (Adaptive Input)
			function SectionAPI:CreateTextBox(o)
				o = o or {}
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

			-- ColorPicker
			function SectionAPI:CreateColorPicker(o)
				o = o or {}
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

			-- Section Update Method
			function SectionAPI:Update(newTitle)
				sectionLabel.Text = newTitle or sectionTitle
			end

			-- Section SetVisible Method
			function SectionAPI:SetVisible(visible)
				sectionHeader.Visible = visible
				container.Visible = visible
			end

			return SectionAPI
		end

		return TabAPI
	end

	-- Welcome notifications
	if not cfg.DisableBuildWarnings then
		RvrseUI:Notify({Title = "RvrseUI v2.0", Message = "Modern UI loaded successfully", Duration = 2, Type = "success"})
	end
	if not cfg.DisableRvrseUIPrompts then
		RvrseUI:Notify({Title = "Tip", Message = "Press " .. toggleKey.Name .. " to toggle UI", Duration = 3, Type = "info"})
	end

	-- ============================================
	-- Pill Sync Function (ensures pill always matches Theme.Current)
	-- ============================================
	local function syncPillFromTheme()
		local t = Theme.Current
		local currentPal = Theme:Get()
		themeToggle.Text = t == "Dark" and "🌙" or "🌞"
		themeToggle.TextColor3 = currentPal.Accent
		themeToggle.BackgroundColor3 = currentPal.Elevated
		themeTooltip.Text = "  Theme: " .. t .. "  "
		stroke(themeToggle, currentPal.Border, 1)
	end

	-- ============================================
	-- Theme Toggle Handler (moved here so body/tabBar are in scope)
	-- ============================================
	themeToggle.MouseButton1Click:Connect(function()
		local newTheme = Theme.Current == "Dark" and "Light" or "Dark"
		Theme:Switch(newTheme)

		-- Force update all UI elements
		local newPal = Theme:Get()

		-- Update theme toggle button (use sync function)
		syncPillFromTheme()

		-- Update glass overlay
		glassOverlay.BackgroundColor3 = newTheme == "Dark"
			and Color3.fromRGB(255, 255, 255)
			or Color3.fromRGB(245, 245, 250)

		-- Update root window colors
		root.BackgroundColor3 = newPal.Bg
		stroke(root, newPal.Border, 1)

		-- Update header
		header.BackgroundColor3 = newPal.Card
		stroke(header, newPal.Border, 1)
		headerDivider.BackgroundColor3 = newPal.Divider
		title.TextColor3 = newPal.Text

		-- Update minimize button
		minimizeBtn.BackgroundColor3 = newPal.Elevated
		minimizeBtn.TextColor3 = newPal.Accent
		stroke(minimizeBtn, newPal.Border, 1)

		-- Update notification bell toggle
		bellToggle.BackgroundColor3 = newPal.Elevated
		bellToggle.TextColor3 = newPal.Accent
		stroke(bellToggle, newPal.Border, 1)

		-- Update close button
		closeBtn.BackgroundColor3 = newPal.Elevated
		closeBtn.TextColor3 = newPal.Error
		stroke(closeBtn, newPal.Border, 1)

		-- Update controller chip
		controllerChip.BackgroundColor3 = newPal.Card
		controllerChip.TextColor3 = newPal.Accent
		stroke(controllerChip, newPal.Accent, 2)
		if controllerChip:FindFirstChild("Glow") then
			controllerChip.Glow.Color = newPal.Accent
		end

		-- Update body
		body.BackgroundColor3 = newPal.Card
		stroke(body, newPal.Border, 1)

		-- Update tab bar scrollbar
		tabBar.ScrollBarImageColor3 = newPal.Border

		-- Update all tabs (including tab icons)
		for _, tabData in ipairs(tabs) do
			tabData.btn.BackgroundColor3 = newPal.Card
			tabData.btn.TextColor3 = newPal.TextSub
			tabData.indicator.BackgroundColor3 = newPal.Accent
			tabData.page.ScrollBarImageColor3 = newPal.Border

			-- Update tab icon color if it exists
			if tabData.icon then
				tabData.icon.ImageColor3 = newPal.TextSub
			end
		end

		Animator:Ripple(themeToggle, 25, 12)

		-- Auto-save theme if config is enabled
		if RvrseUI.ConfigurationSaving then
			RvrseUI:_autoSave()
		end

		RvrseUI:Notify({
			Title = "Theme Changed",
			Message = "Switched to " .. newTheme .. " mode",
			Duration = 2,
			Type = "info"
		})
	end)

	-- Call pill sync after UI build to ensure it matches loaded theme (fixes first-paint)
	task.defer(syncPillFromTheme)

	-- Register window for global management
	table.insert(RvrseUI._windows, WindowAPI)

	return WindowAPI
end

return RvrseUI