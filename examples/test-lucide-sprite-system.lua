-- Test Lucide Sprite Sheet System
-- Tests the professional-grade Lucide icon integration using Rayfield's pattern

local RvrseUI = require(game.ReplicatedStorage.RvrseUI.init)

-- Enable debug mode to see sprite sheet loading
RvrseUI:EnableDebug(true)

-- Create window with Lucide sprite icon (will use sprite sheet)
local Window = RvrseUI:CreateWindow({
	Name = "Lucide Sprite Test",
	Theme = "Dark",
	ConfigurationSaving = false
})

-- Test Tab with Lucide icon
local Tab = Window:CreateTab({
	Title = "Sprite Icons",
	Icon = "lucide://home"  -- Should use sprite sheet (48x48 from asset)
})

local Section = Tab:CreateSection("Icon Format Tests")

-- Test different icon formats
Section:CreateLabel({
	Text = "Testing 5 icon formats:"
})

Section:CreateLabel({
	Text = "1. lucide://home - Sprite sheet (pixel-perfect)"
})

Section:CreateLabel({
	Text = "2. lucide://settings - Sprite sheet fallback"
})

Section:CreateLabel({
	Text = "3. lucide://invalid - Unicode fallback or text"
})

-- Test button with Lucide sprite icon (when implemented)
Section:CreateButton({
	Text = "Lucide Home Icon",
	Callback = function()
		print("[TEST] Lucide sprite icon clicked!")
	end
})

-- Show window
Window:Show()

-- Log test info
print("====== LUCIDE SPRITE SHEET TEST ======")
print("Expected behavior:")
print("1. Debug log shows: '✅ Sprite sheet data loaded successfully'")
print("2. Debug log shows: '📦 X icons available via sprite sheets'")
print("3. Tab icon should be pixel-perfect home icon (from sprite sheet)")
print("4. If sprite fails, falls back to Unicode 🏠")
print("=======================================")
