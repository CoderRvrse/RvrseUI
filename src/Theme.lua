-- =========================
-- RvrseUI Theme Module v4.0
-- =========================
-- Next-gen vibrant design system with stunning gradients and modern aesthetics
-- Complete redesign - removed Light theme, focusing on one amazing dark experience

local Theme = {}

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

		-- 🔲 Borders & dividers - Subtle with neon accents
		Border = Color3.fromRGB(51, 65, 85),        -- Visible border
		BorderBright = Color3.fromRGB(71, 85, 105), -- Brighter border
		BorderGlow = Color3.fromRGB(138, 43, 226),  -- Glowing purple border
		Divider = Color3.fromRGB(30, 41, 59),       -- Subtle divider
		DividerBright = Color3.fromRGB(51, 65, 85), -- Visible divider

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

		-- 🔲 Borders & dividers - Subtle with neon accents
		Border = Color3.fromRGB(226, 232, 240),     -- Light border
		BorderBright = Color3.fromRGB(203, 213, 225), -- Slightly darker border
		BorderGlow = Color3.fromRGB(138, 43, 226),  -- Glowing purple border
		Divider = Color3.fromRGB(241, 245, 249),    -- Very light divider
		DividerBright = Color3.fromRGB(226, 232, 240), -- Visible divider

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

return Theme
