-- COMPREHENSIVE ICON FORMAT TEST SUITE
-- Tests ALL 5 icon formats across ALL 10 UI elements with detailed debug logging
-- Verifies what works, what doesn't, and why

local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

-- ✅ CRITICAL: Enable debug mode to see icon resolution logs
RvrseUI:EnableDebug(true)

print("=" .. string.rep("=", 78))
print("🧪 ICON FORMAT TEST SUITE - COMPREHENSIVE DEBUG MODE")
print("=" .. string.rep("=", 78))
print("📋 Testing 5 icon formats across 10 UI elements")
print("🔍 Debug logs will show icon resolution process")
print("=" .. string.rep("=", 78))

-- Test data for all 5 icon formats
local iconFormats = {
	{
		name = "Lucide Icons (lucide://)",
		description = "Lucide library via lucide:// protocol",
		examples = {
			{icon = "lucide://home", expected = "🏠 (Unicode fallback)", label = "Home"},
			{icon = "lucide://settings", expected = "⚙ (Unicode fallback)", label = "Settings"},
			{icon = "lucide://arrow-right", expected = "→ (Unicode fallback)", label = "Arrow Right"},
			{icon = "lucide://bell", expected = "🔔 (Unicode fallback)", label = "Bell"},
			{icon = "lucide://check", expected = "✓ (Unicode fallback)", label = "Check"},
			{icon = "lucide://x", expected = "✕ (Unicode fallback)", label = "Close"},
			{icon = "lucide://star", expected = "⭐ (Unicode fallback)", label = "Star"},
			{icon = "lucide://heart", expected = "❤ (Unicode fallback)", label = "Heart"},
			{icon = "lucide://user", expected = "👤 (Unicode fallback)", label = "User"},
			{icon = "lucide://lock", expected = "🔒 (Unicode fallback)", label = "Lock"},
		}
	},
	{
		name = "Built-in Unicode (icon://)",
		description = "RvrseUI's 190+ Unicode library",
		examples = {
			{icon = "icon://home", expected = "🏠", label = "Home"},
			{icon = "icon://trophy", expected = "🏆", label = "Trophy"},
			{icon = "icon://fire", expected = "🔥", label = "Fire"},
			{icon = "icon://diamond", expected = "💎", label = "Diamond"},
			{icon = "icon://crown", expected = "👑", label = "Crown"},
			{icon = "icon://shield", expected = "🛡", label = "Shield"},
			{icon = "icon://sword", expected = "⚔", label = "Sword"},
			{icon = "icon://target", expected = "🎯", label = "Target"},
			{icon = "icon://game", expected = "🎮", label = "Game"},
			{icon = "icon://controller", expected = "🎮", label = "Controller"},
		}
	},
	{
		name = "Direct Emoji",
		description = "Any emoji or Unicode character",
		examples = {
			{icon = "🚀", expected = "🚀 (pass-through)", label = "Rocket"},
			{icon = "⚡", expected = "⚡ (pass-through)", label = "Lightning"},
			{icon = "💰", expected = "💰 (pass-through)", label = "Money"},
			{icon = "🎁", expected = "🎁 (pass-through)", label = "Gift"},
			{icon = "🌟", expected = "🌟 (pass-through)", label = "Glowing Star"},
			{icon = "🔥", expected = "🔥 (pass-through)", label = "Fire"},
			{icon = "💎", expected = "💎 (pass-through)", label = "Gem"},
			{icon = "🎯", expected = "🎯 (pass-through)", label = "Bullseye"},
			{icon = "🏆", expected = "🏆 (pass-through)", label = "Trophy"},
			{icon = "👑", expected = "👑 (pass-through)", label = "Crown"},
		}
	},
	{
		name = "Roblox Asset URL (rbxassetid://)",
		description = "Direct Roblox ImageAsset URL",
		examples = {
			{icon = "rbxassetid://123456789", expected = "ImageLabel (won't load - invalid ID)", label = "Invalid Asset"},
			{icon = "rbxassetid://987654321", expected = "ImageLabel (won't load - invalid ID)", label = "Another Invalid"},
		}
	},
	{
		name = "Asset ID Number",
		description = "Roblox asset ID as number type",
		examples = {
			{icon = 123456789, expected = "ImageLabel (won't load - invalid ID)", label = "Number ID 1"},
			{icon = 987654321, expected = "ImageLabel (won't load - invalid ID)", label = "Number ID 2"},
		}
	}
}

-- Edge cases to test
local edgeCases = {
	{icon = "lucide://nonexistent-icon-12345", expected = "Text fallback", label = "Non-existent Lucide"},
	{icon = "icon://fake-icon-xyz", expected = "Text fallback", label = "Non-existent Unicode"},
	{icon = "", expected = "Empty or nil", label = "Empty String"},
	{icon = "just-plain-text", expected = "Text pass-through", label = "Plain Text"},
	{icon = "🔥🔥🔥", expected = "Multiple emojis", label = "Multiple Emojis"},
}

-- Create main window
local Window = RvrseUI:CreateWindow({
	Title = "🧪 Icon Format Test Suite",
	Icon = "lucide://test-tube",
	Size = UDim2.new(0, 700, 0, 600),
	Theme = "Dark",
	ConfigurationSaving = {
		Enabled = false
	}
})

print("\n🪟 Window created with icon: lucide://test-tube")
print("   └─ Check console for: [ICONS] Resolving icon: lucide://test-tube")

-- ============================================
-- TAB 1: FORMAT TESTING - ALL ELEMENTS
-- ============================================
local Tab1 = Window:CreateTab({
	Title = "Format Tests",
	Icon = "lucide://test-tube-2"
})

print("\n📑 Tab created with icon: lucide://test-tube-2")

for formatIndex, format in ipairs(iconFormats) do
	local Section = Tab1:CreateSection({
		Title = format.name,
		Side = formatIndex % 2 == 1 and "Left" or "Right"
	})

	Section:CreateLabel({
		Text = format.description,
		Color = Color3.fromRGB(150, 200, 255)
	})

	Section:CreateDivider()

	-- Test first 3 examples from each format
	for i = 1, math.min(3, #format.examples) do
		local example = format.examples[i]

		print(string.format("\n🔍 Testing %s: %s", format.name, tostring(example.icon)))
		print(string.format("   Expected: %s", example.expected))

		-- Button
		Section:CreateButton({
			Text = string.format("Button: %s", example.label),
			Icon = example.icon,
			Callback = function()
				print(string.format("✅ Button clicked with icon: %s", tostring(example.icon)))
				RvrseUI:Notify(
					example.icon,
					string.format("%s (%s)", example.label, format.name),
					2
				)
			end
		})
	end

	Section:CreateDivider()
end

-- ============================================
-- TAB 2: ELEMENT-BY-ELEMENT TESTING
-- ============================================
local Tab2 = Window:CreateTab({
	Title = "All Elements",
	Icon = "lucide://layout"
})

local Section2L = Tab2:CreateSection({
	Title = "Element Tests (Left)",
	Side = "Left"
})

local Section2R = Tab2:CreateSection({
	Title = "Element Tests (Right)",
	Side = "Right"
})

Section2L:CreateLabel({
	Text = "Testing all 10 UI elements with different icon formats:",
	Color = Color3.fromRGB(255, 200, 100)
})

print("\n" .. string.rep("=", 80))
print("📦 TESTING ALL 10 UI ELEMENTS WITH DIFFERENT ICON FORMATS")
print(string.rep("=", 80))

-- 1. Button (Lucide)
print("\n1️⃣ BUTTON with lucide://home")
Section2L:CreateButton({
	Text = "Button Test",
	Icon = "lucide://home",
	Callback = function()
		print("   ✅ Button callback fired!")
	end
})

-- 2. Toggle (icon://)
print("\n2️⃣ TOGGLE with icon://trophy")
Section2L:CreateToggle({
	Text = "Toggle Test",
	Icon = "icon://trophy",
	Default = true,
	Callback = function(value)
		print(string.format("   ✅ Toggle callback: %s", tostring(value)))
	end
})

-- 3. Dropdown (emoji)
print("\n3️⃣ DROPDOWN with emoji 🎯")
Section2L:CreateDropdown({
	Text = "Dropdown Test",
	Icon = "🎯",
	Options = {"Option 1", "Option 2", "Option 3"},
	Default = "Option 1",
	Callback = function(value)
		print(string.format("   ✅ Dropdown callback: %s", table.concat(value, ", ")))
	end
})

-- 4. Slider (Lucide)
print("\n4️⃣ SLIDER with lucide://sliders")
Section2L:CreateSlider({
	Text = "Slider Test",
	Icon = "lucide://sliders",
	Min = 0,
	Max = 100,
	Default = 50,
	Callback = function(value)
		print(string.format("   ✅ Slider callback: %d", value))
	end
})

-- 5. Keybind (icon://)
print("\n5️⃣ KEYBIND with icon://key")
Section2L:CreateKeybind({
	Text = "Keybind Test",
	Icon = "icon://key",
	Default = Enum.KeyCode.E,
	Callback = function(key)
		print(string.format("   ✅ Keybind callback: %s", tostring(key)))
	end
})

-- 6. TextBox (emoji)
print("\n6️⃣ TEXTBOX with emoji ✏️")
Section2R:CreateTextBox({
	Text = "TextBox Test",
	Icon = "✏️",
	Placeholder = "Enter text...",
	Default = "Test",
	Callback = function(value)
		print(string.format("   ✅ TextBox callback: %s", value))
	end
})

-- 7. ColorPicker (Lucide)
print("\n7️⃣ COLORPICKER with lucide://palette")
Section2R:CreateColorPicker({
	Text = "ColorPicker Test",
	Icon = "lucide://palette",
	Default = Color3.fromRGB(255, 0, 0),
	Callback = function(color)
		print(string.format("   ✅ ColorPicker callback: RGB(%d, %d, %d)",
			color.R * 255, color.G * 255, color.B * 255))
	end
})

-- 8. Label (icon://)
print("\n8️⃣ LABEL with icon://info")
Section2R:CreateLabel({
	Text = "Label Test",
	Icon = "icon://info",
	Color = Color3.fromRGB(100, 255, 100)
})

-- 9. Paragraph (emoji)
print("\n9️⃣ PARAGRAPH with emoji 📝")
Section2R:CreateParagraph({
	Title = "Paragraph Test",
	Icon = "📝",
	Content = "This paragraph uses an emoji icon. Icons work across all elements!"
})

-- 10. Divider (no icon support)
print("\n🔟 DIVIDER (no icon support)")
Section2R:CreateDivider()

-- ============================================
-- TAB 3: EDGE CASES & DEBUG INFO
-- ============================================
local Tab3 = Window:CreateTab({
	Title = "Edge Cases",
	Icon = "lucide://bug"
})

local Section3 = Tab3:CreateSection({
	Title = "Edge Case Testing",
	Side = "Left"
})

Section3:CreateLabel({
	Text = "Testing invalid, empty, and unusual icon inputs:",
	Color = Color3.fromRGB(255, 150, 150)
})

print("\n" .. string.rep("=", 80))
print("🐛 TESTING EDGE CASES")
print(string.rep("=", 80))

for i, test in ipairs(edgeCases) do
	print(string.format("\nEdge Case %d: %s", i, test.label))
	print(string.format("   Input: %s", tostring(test.icon)))
	print(string.format("   Expected: %s", test.expected))

	Section3:CreateButton({
		Text = string.format("%s: %s", test.label, tostring(test.icon)),
		Icon = test.icon,
		Callback = function()
			print(string.format("   ✅ Edge case button clicked: %s", test.label))
		end
	})
end

Section3:CreateDivider()

-- ============================================
-- TAB 4: RESOLUTION BREAKDOWN
-- ============================================
local Tab4 = Window:CreateTab({
	Title = "Resolution Info",
	Icon = "lucide://info"
})

local Section4 = Tab4:CreateSection({
	Title = "Icon Resolution Process",
	Side = "Left"
})

Section4:CreateParagraph({
	Title = "📚 How Icon Resolution Works",
	Content = [[
When you pass an icon to RvrseUI, it goes through this resolution chain:

1️⃣ NUMBER CHECK
   If icon is a number → rbxassetid://[number]
   Type: "image"

2️⃣ LUCIDE PROTOCOL (lucide://)
   Extract icon name after lucide://
   ├─ Check LucideIcons.AssetMap (user uploads)
   │  └─ If found → rbxassetid://[id], Type: "image"
   ├─ Check LucideIcons.UnicodeFallbacks
   │  └─ If found → Unicode character, Type: "text"
   └─ Not found → Display name as text, Type: "text"

3️⃣ ICON PROTOCOL (icon://)
   Extract icon name after icon://
   └─ Check Icons.UnicodeIcons library
      ├─ If found → Unicode character, Type: "text"
      └─ Not found → Continue to next check

4️⃣ RBXASSETID PROTOCOL
   If starts with rbxassetid:// → Use as-is
   Type: "image"

5️⃣ PLAIN TEXT/EMOJI
   Everything else → Pass through as text
   Type: "text"
]]
})

Section4:CreateParagraph({
	Title = "🔍 Debug Log Format",
	Content = [[
Look for these console messages:

[ICONS] Resolving icon: lucide://home
[LUCIDE] Icon 'home' resolved to: 🏠 (type: text)

[ICONS] Resolving icon: icon://trophy
[ICONS] Resolved to: 🏆 (type: text)

[ICONS] Resolving icon: 123456789
[ICONS] Resolved to: rbxassetid://123456789 (type: image)
]]
})

Section4:CreateDivider()

Section4:CreateLabel({
	Text = "Available Icon Formats:",
	Color = Color3.fromRGB(100, 255, 255)
})

Section4:CreateParagraph({
	Title = "✅ 5 Supported Formats",
	Content = [[
1. lucide://[name] - Lucide icons (500+ available)
   Example: lucide://home, lucide://arrow-right

2. icon://[name] - Built-in Unicode (190+ icons)
   Example: icon://trophy, icon://fire

3. [emoji] - Direct emoji/Unicode
   Example: 🚀, ⚡, 💎

4. rbxassetid://[id] - Roblox asset URL
   Example: rbxassetid://123456789

5. [number] - Asset ID as number
   Example: 123456789
]]
})

-- ============================================
-- TAB 5: TEST RESULTS SUMMARY
-- ============================================
local Tab5 = Window:CreateTab({
	Title = "Results",
	Icon = "lucide://check-circle-2"
})

local Section5 = Tab5:CreateSection({
	Title = "Test Results & Observations",
	Side = "Left"
})

Section5:CreateParagraph({
	Title = "✅ What Should Work",
	Content = [[
✔️ lucide:// icons with Unicode fallbacks
   • All common icons (home, settings, arrows, etc.)
   • Falls back to text if no Unicode mapping

✔️ icon:// built-in Unicode icons
   • 190+ pre-defined icons
   • Always renders as text/emoji

✔️ Direct emoji input
   • Any Unicode character
   • Passes through unchanged

✔️ rbxassetid:// URLs
   • Renders as ImageLabel
   • Only works with VALID Roblox asset IDs

✔️ Asset ID numbers
   • Converts to rbxassetid://[number]
   • Only works with VALID IDs
]]
})

Section5:CreateParagraph({
	Title = "⚠️ Known Limitations",
	Content = [[
❌ Invalid Roblox asset IDs
   • Won't display anything (broken image)
   • Console: "Unable to load asset ID"

❌ Non-existent Lucide icons
   • Falls back to displaying icon name as text
   • Example: "lucide://fake" → "fake"

❌ SVG rendering
   • Roblox doesn't support SVG
   • Must use Unicode fallbacks or upload as PNG

⚠️ ImageLabel icons
   • May appear as squares if asset load fails
   • Check console for asset loading errors
]]
})

Section5:CreateDivider()

Section5:CreateLabel({
	Text = "📊 Test Statistics",
	Color = Color3.fromRGB(255, 200, 100)
})

Section5:CreateButton({
	Text = "Print Full Test Report",
	Icon = "lucide://file-text",
	Callback = function()
		print("\n" .. string.rep("=", 80))
		print("📊 ICON TEST SUITE - FULL REPORT")
		print(string.rep("=", 80))
		print(string.format("Total Icon Formats Tested: %d", #iconFormats))
		print(string.format("Total Edge Cases Tested: %d", #edgeCases))
		print(string.format("Total UI Elements Tested: 10"))
		print("\n✅ Check console logs above for detailed resolution traces")
		print("🔍 Look for [ICONS] and [LUCIDE] prefixed messages")
		print(string.rep("=", 80))
	end
})

-- ============================================
-- STARTUP SUMMARY
-- ============================================
print("\n" .. string.rep("=", 80))
print("✅ ICON TEST SUITE LOADED SUCCESSFULLY!")
print(string.rep("=", 80))
print(string.format("📋 Total Icon Formats: %d", #iconFormats))
print(string.format("🐛 Total Edge Cases: %d", #edgeCases))
print("📦 Total UI Elements: 10")
print("\n🔍 WHAT TO LOOK FOR IN CONSOLE:")
print("   • [ICONS] Resolving icon: ... - Icon resolution started")
print("   • [LUCIDE] Icon resolved to: ... - Lucide fallback used")
print("   • Type: text/image - How the icon will render")
print("\n📚 TABS:")
print("   1. Format Tests - All 5 icon formats across elements")
print("   2. All Elements - All 10 UI elements with different icons")
print("   3. Edge Cases - Invalid/unusual inputs")
print("   4. Resolution Info - How icon resolution works")
print("   5. Results - Expected behavior & limitations")
print(string.rep("=", 80))
print("🎯 Ready to test! Interact with elements and watch console logs.")
print(string.rep("=", 80) .. "\n")
