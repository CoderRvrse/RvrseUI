-- TEST: Verify Lucide Sprite Data Loads in Executor Environment
-- This test checks if the sprite sheet data is accessible via the global

print("==============================================")
print("🔍 LUCIDE SPRITE DATA LOADING TEST")
print("==============================================")

-- Load RvrseUI
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

-- Enable debug mode to see loading logs
RvrseUI:EnableDebug(true)

print("\n📊 TEST 1: Check if global sprite data exists")
if _G.RvrseUI_LucideIconsData then
	print("✅ PASS: _G.RvrseUI_LucideIconsData exists")

	-- Check structure
	if _G.RvrseUI_LucideIconsData["48px"] then
		print("✅ PASS: 48px sprite sheet found")

		-- Count icons
		local iconCount = 0
		for _ in pairs(_G.RvrseUI_LucideIconsData["48px"]) do
			iconCount = iconCount + 1
		end
		print("✅ PASS: " .. iconCount .. " icons in sprite sheet")

		-- Test a few specific icons
		local testIcons = {"home", "settings", "search", "x", "check", "arrow-right"}
		print("\n📋 TEST 2: Verify specific icons exist:")
		for _, iconName in ipairs(testIcons) do
			local iconData = _G.RvrseUI_LucideIconsData["48px"][iconName]
			if iconData then
				print(string.format("  ✅ %s: Asset %d, Size (%d,%d), Offset (%d,%d)",
					iconName,
					iconData[1],
					iconData[2][1], iconData[2][2],
					iconData[3][1], iconData[3][2]
				))
			else
				print("  ❌ " .. iconName .. ": NOT FOUND")
			end
		end
	else
		print("❌ FAIL: 48px sprite sheet not found!")
	end
else
	print("❌ FAIL: _G.RvrseUI_LucideIconsData does not exist!")
	print("   This means the sprite data wasn't embedded in RvrseUI.lua")
end

print("\n📊 TEST 3: Create window with Lucide icons")
local Window = RvrseUI:CreateWindow({
	Name = "Lucide Data Test",
	Theme = "Dark",
	ConfigurationSaving = false
})

local Tab = Window:CreateTab({
	Title = "Test Tab",
	Icon = "lucide://home"  -- Should show 🏠 (Unicode fallback for now)
})

local Section = Tab:CreateSection("Icon Tests")

Section:CreateLabel({
	Text = "If you see this window, sprite data loaded!"
})

Section:CreateButton({
	Text = "Home Icon Test",
	Icon = "lucide://home",  -- Will show 🏠 until sprite rendering is implemented
	Callback = function()
		print("Button clicked! Icon: lucide://home")
	end
})

Section:CreateButton({
	Text = "Settings Icon Test",
	Icon = "lucide://settings",  -- Will show ⚙
	Callback = function()
		print("Button clicked! Icon: lucide://settings")
	end
})

Section:CreateButton({
	Text = "Check Icon Test",
	Icon = "lucide://check",  -- Will show ✓
	Callback = function()
		print("Button clicked! Icon: lucide://check")
	end
})

Section:CreateDivider()

Section:CreateParagraph({
	Title = "Expected Results:",
	Content = [[
✅ Tab icon shows 🏠 (Unicode fallback)
✅ Buttons show emoji icons (🏠 ⚙ ✓)
✅ Debug console shows sprite data loaded
✅ No errors in console

Note: Icons currently display as Unicode
fallbacks. Sprite sheet rendering (pixel-
perfect icons) will be implemented next!
]]
})

print("\n==============================================")
print("✅ TEST COMPLETE - Window created successfully!")
print("==============================================")
print("\n💡 Check the debug output above for:")
print("   - [LUCIDE] ✅ Sprite sheet data loaded from global")
print("   - [LUCIDE] 📦 X icons available via sprite sheets")
print("\nIf you see those messages, the system is working!")
print("Next step: Update UI elements to render sprites.")
print("==============================================")
