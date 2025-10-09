-- =========================
-- RvrseUI Theme Module
-- =========================
-- Handles theme management, palettes, and theme switching
-- Extracted from RvrseUI.lua (lines 761-847)

local Theme = {}

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

return Theme
