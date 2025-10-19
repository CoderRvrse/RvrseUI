-- SIMPLE TEST: Lucide Icon Integration
-- Quick test to verify lucide:// protocol works

local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

-- Enable debug to see icon resolution
RvrseUI:EnableDebug(true)

local Window = RvrseUI:CreateWindow({
	Title = "Lucide Test",
	Icon = "lucide://sparkles",  -- Should fallback to "sparkles" text or emoji
	Size = UDim2.new(0, 500, 0, 400),
	Theme = "Dark"
})

local Tab = Window:CreateTab({
	Title = "Icons",
	Icon = "lucide://home"  -- Should fallback to 🏠
})

local Section = Tab:CreateSection({
	Title = "Lucide Icon Tests",
	Side = "Left"
})

Section:CreateLabel({
	Text = "Testing lucide:// protocol",
	Color = Color3.fromRGB(100, 200, 255)
})

-- Test common icons with Unicode fallbacks
local testIcons = {
	{"lucide://home", "Home"},
	{"lucide://settings", "Settings"},
	{"lucide://arrow-right", "Arrow Right"},
	{"lucide://check", "Check"},
	{"lucide://x", "Close"},
	{"lucide://heart", "Heart"},
	{"lucide://star", "Star"},
	{"lucide://user", "User"},
	{"lucide://bell", "Bell"},
	{"lucide://lock", "Lock"},
}

for _, iconData in ipairs(testIcons) do
	Section:CreateButton({
		Text = iconData[2] .. " → " .. iconData[1],
		Icon = iconData[1],
		Callback = function()
			RvrseUI:Notify(
				iconData[1],
				"Clicked: " .. iconData[2],
				2
			)
		end
	})
end

Section:CreateDivider()

Section:CreateToggle({
	Text = "Test Toggle with Lucide Icon",
	Icon = "lucide://toggle-left",
	Default = true,
	Callback = function(value)
		print("Toggle:", value)
	end
})

Section:CreateDropdown({
	Text = "Test Dropdown with Lucide Icon",
	Icon = "lucide://chevron-down",
	Options = {"Option 1", "Option 2", "Option 3"},
	Default = "Option 1",
	Callback = function(value)
		print("Dropdown:", value)
	end
})

print("✅ Lucide icon test loaded!")
print("🔍 Check console for icon resolution debug messages")
print("📚 Icons should resolve to Unicode fallbacks")
