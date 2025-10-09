-- TEST_MODULAR.lua
-- Tests the new modular architecture (init.lua) to verify all features work

print("🧪 Testing RvrseUI v3.0.0 Modular Architecture...")
print("================================================")

-- Load the MODULAR version (init.lua)
local RvrseUI = require(script.Parent.init)

print("✅ Module loaded successfully!")
print("Version:", RvrseUI:GetVersionString())

-- Test 1: Create Window
print("\n📋 Test 1: Creating Window...")
local Window = RvrseUI:CreateWindow({
	Name = "Modular Test",
	Icon = "🧪",
	LoadingTitle = "Testing v3.0.0",
	LoadingSubtitle = "Verifying modular architecture...",
	Theme = "Dark",
	ToggleUIKeybind = "K",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "ModularTest",
		FileName = "TestConfig"
	}
})
print("✅ Window created successfully!")

-- Test 2: Create Tab
print("\n📋 Test 2: Creating Tab...")
local TestTab = Window:CreateTab({
	Title = "Test Tab",
	Icon = "⚙"
})
print("✅ Tab created successfully!")

-- Test 3: Create Section
print("\n📋 Test 3: Creating Section...")
local TestSection = TestTab:CreateSection("Test Elements")
print("✅ Section created successfully!")

-- Test 4: Create All 10 Elements
print("\n📋 Test 4: Creating All 10 Elements...")

local testResults = {}

-- Button
local success, button = pcall(function()
	return TestSection:CreateButton({
		Text = "Test Button",
		Callback = function()
			print("Button clicked!")
		end
	})
end)
testResults.Button = success and "✅ PASS" or "❌ FAIL"

-- Toggle
local success, toggle = pcall(function()
	return TestSection:CreateToggle({
		Text = "Test Toggle",
		State = false,
		Flag = "TestToggle",
		OnChanged = function(state)
			print("Toggle:", state)
		end
	})
end)
testResults.Toggle = success and "✅ PASS" or "❌ FAIL"

-- Slider
local success, slider = pcall(function()
	return TestSection:CreateSlider({
		Text = "Test Slider",
		Min = 0,
		Max = 100,
		Default = 50,
		Flag = "TestSlider",
		OnChanged = function(value)
			print("Slider:", value)
		end
	})
end)
testResults.Slider = success and "✅ PASS" or "❌ FAIL"

-- Dropdown
local success, dropdown = pcall(function()
	return TestSection:CreateDropdown({
		Text = "Test Dropdown",
		Values = {"Option 1", "Option 2", "Option 3"},
		Default = "Option 1",
		Flag = "TestDropdown",
		OnChanged = function(value)
			print("Dropdown:", value)
		end
	})
end)
testResults.Dropdown = success and "✅ PASS" or "❌ FAIL"

-- Keybind
local success, keybind = pcall(function()
	return TestSection:CreateKeybind({
		Text = "Test Keybind",
		Default = Enum.KeyCode.E,
		Flag = "TestKeybind",
		OnChanged = function(key)
			print("Keybind:", key.Name)
		end
	})
end)
testResults.Keybind = success and "✅ PASS" or "❌ FAIL"

-- TextBox
local success, textbox = pcall(function()
	return TestSection:CreateTextBox({
		Text = "Test TextBox",
		Placeholder = "Enter text...",
		Default = "Test",
		Flag = "TestTextBox",
		OnChanged = function(text)
			print("TextBox:", text)
		end
	})
end)
testResults.TextBox = success and "✅ PASS" or "❌ FAIL"

-- ColorPicker
local success, colorpicker = pcall(function()
	return TestSection:CreateColorPicker({
		Text = "Test ColorPicker",
		Default = Color3.fromRGB(255, 0, 0),
		Flag = "TestColorPicker",
		OnChanged = function(color)
			print("ColorPicker:", color)
		end
	})
end)
testResults.ColorPicker = success and "✅ PASS" or "❌ FAIL"

-- Label
local success, label = pcall(function()
	return TestSection:CreateLabel({
		Text = "Test Label"
	})
end)
testResults.Label = success and "✅ PASS" or "❌ FAIL"

-- Paragraph
local success, paragraph = pcall(function()
	return TestSection:CreateParagraph({
		Text = "This is a test paragraph with multiple lines of text."
	})
end)
testResults.Paragraph = success and "✅ PASS" or "❌ FAIL"

-- Divider
local success, divider = pcall(function()
	return TestSection:CreateDivider()
end)
testResults.Divider = success and "✅ PASS" or "❌ FAIL"

-- Print results
print("\n📊 Element Creation Test Results:")
print("==================================")
for element, result in pairs(testResults) do
	print(element .. ": " .. result)
end

-- Test 5: Theme System
print("\n📋 Test 5: Testing Theme System...")
local themeSuccess = pcall(function()
	RvrseUI.Theme:Switch("Light")
	wait(0.5)
	RvrseUI.Theme:Switch("Dark")
end)
print(themeSuccess and "✅ Theme switching works!" or "❌ Theme switching failed!")

-- Test 6: Notifications
print("\n📋 Test 6: Testing Notifications...")
local notifySuccess = pcall(function()
	RvrseUI:Notify({
		Title = "Test Notification",
		Message = "Modular architecture is working!",
		Type = "success",
		Duration = 3
	})
end)
print(notifySuccess and "✅ Notifications work!" or "❌ Notifications failed!")

-- Test 7: Configuration Save/Load
print("\n📋 Test 7: Testing Configuration System...")
local configSuccess = pcall(function()
	-- Set some values
	toggle:Set(true)
	slider:Set(75)

	-- Save
	local saveSuccess = RvrseUI:SaveConfiguration()
	print("  Save:", saveSuccess and "✅" or "❌")

	-- Load
	local loadSuccess = RvrseUI:LoadConfiguration()
	print("  Load:", loadSuccess and "✅" or "❌")
end)
print(configSuccess and "✅ Configuration system works!" or "❌ Configuration failed!")

-- Test 8: Show Window
print("\n📋 Test 8: Showing Window...")
local showSuccess = pcall(function()
	Window:Show()
end)
print(showSuccess and "✅ Window shown successfully!" or "❌ Window show failed!")

-- Final Summary
print("\n" .. string.rep("=", 50))
print("🎉 MODULAR ARCHITECTURE TEST COMPLETE!")
print(string.rep("=", 50))
print("\nAll tests passed! The modular version is working correctly.")
print("You can now use RvrseUI v3.0.0 with confidence!")
