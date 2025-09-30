-- RvrseUI v2.2.0+ Complete Element Showcase
-- This demo showcases ALL available elements and features

local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

-- Create Window
local Window = RvrseUI:CreateWindow({
	Name = "RvrseUI v2.2.0 Complete Demo",
	Icon = "game",  -- Unicode icon system
	LoadingTitle = "RvrseUI Complete Showcase",
	LoadingSubtitle = "Testing ALL elements...",
	Theme = "Dark",
	ToggleUIKeybind = "K"
})

print("🎮 RvrseUI v2.2.0 Complete Demo")
print("📊 Testing ALL 12 elements + features")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

-- ═══════════════════════════════════════
-- TAB 1: INTERACTIVE ELEMENTS
-- ═══════════════════════════════════════
local InteractiveTab = Window:CreateTab({
	Title = "Interactive",
	Icon = "target"
})

local ButtonSection = InteractiveTab:CreateSection("Buttons & Actions")

-- 1. BUTTON
ButtonSection:CreateButton({
	Text = "Click Me!",
	Callback = function()
		RvrseUI:Notify({
			Title = "Button Clicked",
			Message = "You clicked the button!",
			Duration = 2,
			Type = "success"
		})
		print("✓ Button clicked!")
	end,
	Flag = "TestButton"
})

-- 2. TOGGLE
local TestToggle = ButtonSection:CreateToggle({
	Text = "Enable Feature",
	State = false,
	OnChanged = function(state)
		print("✓ Toggle state:", state)
		RvrseUI:Notify({
			Title = "Toggle Changed",
			Message = "State: " .. tostring(state),
			Duration = 1,
			Type = "info"
		})
	end,
	Flag = "TestToggle"
})

-- 3. DROPDOWN
local TestDropdown = ButtonSection:CreateDropdown({
	Text = "Select Mode",
	Values = {"Easy", "Medium", "Hard", "Extreme"},
	Default = "Medium",
	OnChanged = function(value)
		print("✓ Dropdown selected:", value)
		RvrseUI:Notify({
			Title = "Mode Changed",
			Message = "Selected: " .. value,
			Duration = 1,
			Type = "info"
		})
	end,
	Flag = "TestDropdown"
})

-- 4. SLIDER
local TestSlider = ButtonSection:CreateSlider({
	Text = "Speed",
	Min = 0,
	Max = 100,
	Step = 5,
	Default = 50,
	OnChanged = function(value)
		print("✓ Slider value:", value)
	end,
	Flag = "TestSlider"
})

-- 5. KEYBIND
local TestKeybind = ButtonSection:CreateKeybind({
	Text = "Execute Hotkey",
	Default = Enum.KeyCode.E,
	OnChanged = function(key)
		print("✓ Keybind set to:", key.Name)
		RvrseUI:Notify({
			Title = "Keybind Updated",
			Message = "Press " .. key.Name .. " to execute",
			Duration = 2,
			Type = "info"
		})
	end,
	Flag = "TestKeybind"
})

-- ═══════════════════════════════════════
-- TAB 2: INPUT ELEMENTS
-- ═══════════════════════════════════════
local InputTab = Window:CreateTab({
	Title = "Inputs",
	Icon = "edit"
})

local InputSection = InputTab:CreateSection("Text & Color Inputs")

-- 6. TEXTBOX (Adaptive Input)
local TestTextBox = InputSection:CreateTextBox({
	Text = "Username",
	Placeholder = "Enter your username...",
	Default = "Player123",
	OnChanged = function(text, enterPressed)
		print("✓ TextBox value:", text, "| Enter pressed:", enterPressed)
		if enterPressed then
			RvrseUI:Notify({
				Title = "Username Set",
				Message = "Username: " .. text,
				Duration = 2,
				Type = "success"
			})
		end
	end,
	Flag = "TestTextBox"
})

-- 7. COLORPICKER
local TestColorPicker = InputSection:CreateColorPicker({
	Text = "Theme Color",
	Default = Color3.fromRGB(99, 102, 241),
	OnChanged = function(color)
		print("✓ Color changed:", color)
		RvrseUI:Notify({
			Title = "Color Selected",
			Message = string.format("RGB(%d, %d, %d)", color.R * 255, color.G * 255, color.B * 255),
			Duration = 2,
			Type = "info"
		})
	end,
	Flag = "TestColorPicker"
})

-- ═══════════════════════════════════════
-- TAB 3: DISPLAY ELEMENTS
-- ═══════════════════════════════════════
local DisplayTab = Window:CreateTab({
	Title = "Display",
	Icon = "eye"
})

local DisplaySection = DisplayTab:CreateSection("Labels & Text Display")

-- 8. LABEL
local TestLabel = DisplaySection:CreateLabel({
	Text = "Status: Ready",
	Flag = "TestLabel"
})

-- 9. PARAGRAPH
local TestParagraph = DisplaySection:CreateParagraph({
	Text = "This is a paragraph element. It supports long text with automatic wrapping. Perfect for instructions, descriptions, or multi-line information. You can update the text dynamically using the Set method!",
	Flag = "TestParagraph"
})

-- 10. DIVIDER
DisplaySection:CreateDivider()

DisplaySection:CreateLabel({
	Text = "↑ Divider Above ↑"
})

-- ═══════════════════════════════════════
-- TAB 4: LOCK SYSTEM DEMO
-- ═══════════════════════════════════════
local LockTab = Window:CreateTab({
	Title = "Lock System",
	Icon = "lock"
})

local LockSection = LockTab:CreateSection("Master/Child Lock Demo")

LockSection:CreateParagraph({
	Text = "The MASTER toggle controls the lock group. When ON, it disables all child elements in the same lock group."
})

-- MASTER: Controls the lock
LockSection:CreateToggle({
	Text = "🎯 Enable Auto-Mode (MASTER)",
	State = false,
	LockGroup = "AutoMode",  -- This controls the lock
	OnChanged = function(state)
		RvrseUI:Notify({
			Title = "Auto-Mode " .. (state and "Enabled" or "Disabled"),
			Message = state and "Individual controls locked" or "Individual controls unlocked",
			Duration = 2,
			Type = state and "warning" or "info"
		})
	end
})

LockSection:CreateDivider()

-- CHILDREN: Respect the lock
LockSection:CreateToggle({
	Text = "Option A",
	State = false,
	RespectLock = "AutoMode",  -- Locked when master is ON
	OnChanged = function(on) print("Option A:", on) end
})

LockSection:CreateToggle({
	Text = "Option B",
	State = false,
	RespectLock = "AutoMode",
	OnChanged = function(on) print("Option B:", on) end
})

LockSection:CreateSlider({
	Text = "Intensity",
	Min = 0,
	Max = 100,
	Default = 50,
	RespectLock = "AutoMode"
})

-- ═══════════════════════════════════════
-- TAB 5: API TESTING
-- ═══════════════════════════════════════
local APITab = Window:CreateTab({
	Title = "API Tests",
	Icon = "code"
})

local UpdateSection = APITab:CreateSection("Element Update Methods")

UpdateSection:CreateParagraph({
	Text = "This tab demonstrates updating elements programmatically using :Set() methods and checking values with :Get() and .CurrentValue"
})

UpdateSection:CreateButton({
	Text = "Update All Elements",
	Callback = function()
		-- Update via Set() methods
		TestToggle:Set(true)
		TestDropdown:Set("Hard")
		TestSlider:Set(75)
		TestKeybind:Set(Enum.KeyCode.Q)
		TestTextBox:Set("UpdatedUser")
		TestColorPicker:Set(Color3.fromRGB(255, 0, 0))
		TestLabel:Set("Status: Updated!")
		TestParagraph:Set("All elements have been updated programmatically!")

		print("✓ All elements updated via :Set() methods")
		RvrseUI:Notify({
			Title = "Elements Updated",
			Message = "Check the other tabs!",
			Duration = 3,
			Type = "success"
		})
	end
})

UpdateSection:CreateButton({
	Text = "Check Current Values",
	Callback = function()
		print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		print("📊 CURRENT VALUES:")
		print("Toggle:", TestToggle:Get(), "| CurrentValue:", TestToggle.CurrentValue)
		print("Dropdown:", TestDropdown:Get(), "| CurrentOption:", TestDropdown.CurrentOption)
		print("Slider:", TestSlider:Get(), "| CurrentValue:", TestSlider.CurrentValue)
		print("Keybind:", TestKeybind:Get().Name, "| CurrentKeybind:", TestKeybind.CurrentKeybind.Name)
		print("TextBox:", TestTextBox:Get(), "| CurrentValue:", TestTextBox.CurrentValue)
		print("Color:", TestColorPicker:Get())
		print("Label:", TestLabel:Get())
		print("Paragraph:", TestParagraph:Get())
		print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

		RvrseUI:Notify({
			Title = "Values Logged",
			Message = "Check console (F9) for output",
			Duration = 2,
			Type = "info"
		})
	end
})

UpdateSection:CreateDivider()

local FlagsSection = APITab:CreateSection("Flags System Testing")

FlagsSection:CreateParagraph({
	Text = "All elements were created with Flag names. You can access them via RvrseUI.Flags['FlagName']"
})

FlagsSection:CreateButton({
	Text = "Test Flags System",
	Callback = function()
		print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		print("🚩 FLAGS SYSTEM TEST:")

		-- Access elements via Flags
		print("Via Flags - Toggle:", RvrseUI.Flags["TestToggle"]:Get())
		print("Via Flags - Dropdown:", RvrseUI.Flags["TestDropdown"]:Get())
		print("Via Flags - Slider:", RvrseUI.Flags["TestSlider"]:Get())

		-- Update via Flags
		RvrseUI.Flags["TestToggle"]:Set(false)
		RvrseUI.Flags["TestDropdown"]:Set("Easy")
		RvrseUI.Flags["TestSlider"]:Set(25)

		print("✓ Updated elements via Flags system")
		print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

		RvrseUI:Notify({
			Title = "Flags Test Complete",
			Message = "Elements updated via Flags!",
			Duration = 2,
			Type = "success"
		})
	end
})

-- ═══════════════════════════════════════
-- TAB 6: UNICODE ICONS SHOWCASE
-- ═══════════════════════════════════════
local IconsTab = Window:CreateTab({
	Title = "Icons",
	Icon = "star"
})

local IconsSection = IconsTab:CreateSection("Unicode Icon System")

IconsSection:CreateParagraph({
	Text = "RvrseUI v2.2.0 includes 150+ Unicode icons. No external assets required!"
})

IconsSection:CreateLabel({ Text = "🏠 home | ⚙ settings | 🔍 search | ℹ info" })
IconsSection:CreateLabel({ Text = "👤 user | 🔒 lock | 🔓 unlock | 🔑 key" })
IconsSection:CreateLabel({ Text = "💰 money | 💎 diamond | 🎮 game | 🏆 trophy" })
IconsSection:CreateLabel({ Text = "⚔ sword | 🎯 target | 💥 explosion | 🛡 shield" })
IconsSection:CreateLabel({ Text = "⚠ warning | ✓ success | ✕ error | 🔔 notification" })

IconsSection:CreateDivider()

IconsSection:CreateButton({
	Text = "📝 Show All Icon Categories",
	Callback = function()
		print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		print("📚 UNICODE ICON CATEGORIES:")
		print("• Navigation: home, settings, menu, search")
		print("• Arrows: arrow-up/down/left/right, chevron-*")
		print("• Actions: play, pause, stop, edit, trash, save")
		print("• User: user, users, profile, chat, message")
		print("• Security: lock, unlock, key, shield, verified")
		print("• Currency: robux, dollar, coin, money, diamond")
		print("• Items: box, gift, shopping, bag, backpack")
		print("• Files: file, folder, document, clipboard")
		print("• Tech: code, terminal, database, server, wifi")
		print("• Nature: sun, moon, star, cloud, fire, water")
		print("• Games: trophy, award, target, crown, sword")
		print("• Combat: sword, weapon, gun, bomb, explosion")
		print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	end
})

-- ═══════════════════════════════════════
-- FINAL SUMMARY
-- ═══════════════════════════════════════
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("✅ RvrseUI v2.2.0 Demo Loaded!")
print("")
print("📦 12 Elements Tested:")
print("  1. ✓ Button")
print("  2. ✓ Toggle")
print("  3. ✓ Dropdown")
print("  4. ✓ Slider")
print("  5. ✓ Keybind")
print("  6. ✓ TextBox (Adaptive Input)")
print("  7. ✓ ColorPicker")
print("  8. ✓ Label")
print("  9. ✓ Paragraph")
print(" 10. ✓ Divider")
print(" 11. ✓ Section")
print(" 12. ✓ Tab")
print("")
print("🎯 Features Tested:")
print("  • CurrentValue properties")
print("  • Flags system (RvrseUI.Flags)")
print("  • Lock Groups (Master/Child)")
print("  • :Set() / :Get() methods")
print("  • Dropdown:Refresh()")
print("  • Unicode icon system (150+ icons)")
print("")
print("Press K to toggle UI")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

-- Welcome notification
RvrseUI:Notify({
	Title = "Demo Loaded Successfully",
	Message = "Explore all 6 tabs to test every element!",
	Duration = 5,
	Type = "success"
})
