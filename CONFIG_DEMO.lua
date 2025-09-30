-- RvrseUI v2.3.0 Configuration System Demo
-- Demonstrates automatic configuration saving and loading

local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("💾 RvrseUI v2.3.0 Configuration Demo")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

-- Create Window with Configuration Saving ENABLED
local Window = RvrseUI:CreateWindow({
	Name = "Config Demo",
	Icon = "settings",
	LoadingTitle = "Configuration System",
	LoadingSubtitle = "Auto-save enabled",
	Theme = "Dark",
	ToggleUIKeybind = "K",

	-- ✅ ENABLE CONFIGURATION SAVING
	ConfigurationSaving = true,
	FileName = "RvrseUI_ConfigDemo.json"  -- Will save to workspace folder
})

-- Tab 1: Player Settings
local PlayerTab = Window:CreateTab({
	Title = "Player",
	Icon = "user"
})

local PlayerSection = PlayerTab:CreateSection("Player Enhancements")

-- ⚠️ IMPORTANT: Use unique Flag names for each element you want to save
PlayerSection:CreateSlider({
	Text = "Walk Speed",
	Min = 16,
	Max = 100,
	Step = 2,
	Default = 16,
	Flag = "WalkSpeed",  -- 🔑 Unique flag identifier
	OnChanged = function(speed)
		print("Walk Speed:", speed)
		-- Apply walk speed
		local character = game.Players.LocalPlayer.Character
		if character and character:FindFirstChild("Humanoid") then
			character.Humanoid.WalkSpeed = speed
		end
	end
})

PlayerSection:CreateSlider({
	Text = "Jump Power",
	Min = 50,
	Max = 200,
	Step = 5,
	Default = 50,
	Flag = "JumpPower",  -- 🔑 Unique flag identifier
	OnChanged = function(power)
		print("Jump Power:", power)
		local character = game.Players.LocalPlayer.Character
		if character and character:FindFirstChild("Humanoid") then
			character.Humanoid.JumpPower = power
		end
	end
})

PlayerSection:CreateToggle({
	Text = "Infinite Jump",
	State = false,
	Flag = "InfiniteJump",  -- 🔑 Unique flag identifier
	OnChanged = function(enabled)
		print("Infinite Jump:", enabled)
		RvrseUI:Notify({
			Title = enabled and "Infinite Jump ON" or "Infinite Jump OFF",
			Type = enabled and "success" or "info",
			Duration = 2
		})
	end
})

-- Tab 2: Combat Settings
local CombatTab = Window:CreateTab({
	Title = "Combat",
	Icon = "sword"
})

local CombatSection = CombatTab:CreateSection("Combat Features")

CombatSection:CreateToggle({
	Text = "Auto Attack",
	State = false,
	Flag = "AutoAttack",  -- 🔑 Unique flag identifier
	OnChanged = function(enabled)
		print("Auto Attack:", enabled)
	end
})

CombatSection:CreateDropdown({
	Text = "Target Priority",
	Values = { "Closest", "Lowest HP", "Highest HP", "Random" },
	Default = "Closest",
	Flag = "TargetPriority",  -- 🔑 Unique flag identifier
	OnChanged = function(priority)
		print("Target Priority:", priority)
	end
})

CombatSection:CreateSlider({
	Text = "Attack Range",
	Min = 10,
	Max = 100,
	Step = 5,
	Default = 30,
	Flag = "AttackRange",  -- 🔑 Unique flag identifier
	OnChanged = function(range)
		print("Attack Range:", range)
	end
})

CombatSection:CreateKeybind({
	Text = "Combat Toggle",
	Default = Enum.KeyCode.C,
	Flag = "CombatKeybind",  -- 🔑 Unique flag identifier
	OnChanged = function(key)
		print("Combat Keybind:", key.Name)
	end
})

-- Tab 3: UI Settings
local UITab = Window:CreateTab({
	Title = "UI Settings",
	Icon = "settings"
})

local UISection = UITab:CreateSection("Interface Customization")

UISection:CreateDropdown({
	Text = "Theme",
	Values = { "Dark", "Light" },
	Default = "Dark",
	Flag = "UITheme",  -- 🔑 Unique flag identifier
	OnChanged = function(theme)
		print("Theme:", theme)
		if theme == "Dark" then
			Theme:Switch("Dark")
		else
			Theme:Switch("Light")
		end
		RvrseUI:Notify({
			Title = "Theme Changed",
			Message = "UI theme set to " .. theme,
			Type = "info",
			Duration = 2
		})
	end
})

UISection:CreateTextBox({
	Text = "Player Name",
	Placeholder = "Enter your name...",
	Default = "",
	Flag = "PlayerName",  -- 🔑 Unique flag identifier
	OnChanged = function(name, enterPressed)
		print("Player Name:", name, "Enter pressed:", enterPressed)
	end
})

UISection:CreateColorPicker({
	Text = "Accent Color",
	Default = Color3.fromRGB(99, 102, 241),
	Flag = "AccentColor",  -- 🔑 Unique flag identifier
	OnChanged = function(color)
		print("Accent Color:", color)
	end
})

-- Tab 4: Configuration Management
local ConfigTab = Window:CreateTab({
	Title = "Config",
	Icon = "save"
})

local ConfigSection = ConfigTab:CreateSection("Configuration Management")

ConfigSection:CreateParagraph({
	Text = "Configuration is automatically saved when you change any flagged element. You can also manually save, load, or delete configurations using the buttons below."
})

ConfigSection:CreateDivider()

ConfigSection:CreateButton({
	Text = "💾 Manually Save Configuration",
	Callback = function()
		local success, message = RvrseUI:SaveConfiguration()
		if success then
			RvrseUI:Notify({
				Title = "Config Saved",
				Message = "Configuration saved successfully",
				Type = "success",
				Duration = 3
			})
			print("✓ Configuration saved manually")
		else
			RvrseUI:Notify({
				Title = "Save Failed",
				Message = tostring(message),
				Type = "error",
				Duration = 3
			})
			print("✗ Save failed:", message)
		end
	end
})

ConfigSection:CreateButton({
	Text = "📂 Load Configuration",
	Callback = function()
		local success, message = RvrseUI:LoadConfiguration()
		if success then
			RvrseUI:Notify({
				Title = "Config Loaded",
				Message = message or "Configuration restored",
				Type = "success",
				Duration = 3
			})
			print("✓ Configuration loaded:", message)
		else
			RvrseUI:Notify({
				Title = "Load Failed",
				Message = "No saved configuration found",
				Type = "warn",
				Duration = 3
			})
			print("✗ Load failed:", message)
		end
	end
})

ConfigSection:CreateButton({
	Text = "🗑 Delete Configuration",
	Callback = function()
		local success, message = RvrseUI:DeleteConfiguration()
		if success then
			RvrseUI:Notify({
				Title = "Config Deleted",
				Message = "Saved configuration removed",
				Type = "info",
				Duration = 3
			})
			print("✓ Configuration deleted")
		else
			RvrseUI:Notify({
				Title = "Delete Failed",
				Message = tostring(message),
				Type = "error",
				Duration = 3
			})
			print("✗ Delete failed:", message)
		end
	end
})

ConfigSection:CreateDivider()

ConfigSection:CreateButton({
	Text = "📊 Check Config Status",
	Callback = function()
		local exists = RvrseUI:ConfigurationExists()
		local flagCount = 0
		for _ in pairs(RvrseUI.Flags) do
			flagCount = flagCount + 1
		end

		print("━━━━━━━━━━━━━━━━━━━━━━━━━")
		print("📊 Configuration Status")
		print("━━━━━━━━━━━━━━━━━━━━━━━━━")
		print("Config File:", RvrseUI.ConfigurationFileName)
		print("File Exists:", exists and "YES" or "NO")
		print("Flagged Elements:", flagCount)
		print("Auto-Save:", RvrseUI.ConfigurationSaving and "ENABLED" or "DISABLED")
		print("━━━━━━━━━━━━━━━━━━━━━━━━━")

		RvrseUI:Notify({
			Title = "Config Status",
			Message = string.format("%d elements tracked | File %s", flagCount, exists and "exists" or "not found"),
			Type = "info",
			Duration = 4
		})
	end
})

-- Tab 5: Test Configuration System
local TestTab = Window:CreateTab({
	Title = "Test",
	Icon = "check"
})

local TestSection = TestTab:CreateSection("Configuration Test")

TestSection:CreateParagraph({
	Text = "Test the configuration system by changing some values, then reload the script. Your settings will be restored automatically!"
})

TestSection:CreateButton({
	Text = "🧪 Run Configuration Test",
	Callback = function()
		print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		print("🧪 CONFIGURATION SYSTEM TEST")
		print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

		-- Count flagged elements
		local flagCount = 0
		local flagList = {}
		for flagName in pairs(RvrseUI.Flags) do
			flagCount = flagCount + 1
			table.insert(flagList, flagName)
		end

		print(string.format("\n[1/4] Flagged Elements: %d", flagCount))
		for _, flag in ipairs(flagList) do
			print("  •", flag)
		end

		-- Test save
		print("\n[2/4] Testing Save...")
		local saveSuccess, saveMsg = RvrseUI:SaveConfiguration()
		print(saveSuccess and "  ✓ Save successful" or "  ✗ Save failed: " .. tostring(saveMsg))

		-- Check if file exists
		print("\n[3/4] Checking File...")
		local exists = RvrseUI:ConfigurationExists()
		print(exists and "  ✓ Config file exists" or "  ✗ Config file not found")

		-- Display current values
		print("\n[4/4] Current Values:")
		for flagName, element in pairs(RvrseUI.Flags) do
			if element.Get then
				local success, value = pcall(element.Get, element)
				if success then
					local valueStr = tostring(value)
					if typeof(value) == "EnumItem" then
						valueStr = value.Name
					elseif typeof(value) == "Color3" then
						valueStr = string.format("RGB(%d, %d, %d)", value.R * 255, value.G * 255, value.B * 255)
					end
					print(string.format("  • %s: %s", flagName, valueStr))
				end
			end
		end

		print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		print("✅ TEST COMPLETE")
		print("💡 TIP: Change some values, then reload")
		print("   the script to see auto-load in action!")
		print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")

		RvrseUI:Notify({
			Title = "Test Complete",
			Message = string.format("%d elements tested successfully", flagCount),
			Priority = "high",
			Type = "success",
			Duration = 4
		})
	end
})

TestSection:CreateDivider()

TestSection:CreateLabel({ Text = "📝 Instructions:" })
TestSection:CreateParagraph({
	Text = "1. Adjust some settings (sliders, toggles, etc.)\n2. Settings auto-save after 1 second\n3. Reload this script\n4. Your settings will be automatically restored!"
})

-- ✨ IMPORTANT: Load saved configuration at startup
print("\n💾 Loading saved configuration...")
local loadSuccess, loadMessage = RvrseUI:LoadConfiguration()

if loadSuccess then
	print("✓ Configuration loaded:", loadMessage)
	RvrseUI:Notify({
		Title = "Config Loaded",
		Message = loadMessage or "Settings restored",
		Priority = "high",
		Type = "success",
		Duration = 4
	})
else
	print("ℹ No saved configuration found - using defaults")
	RvrseUI:Notify({
		Title = "Config Demo Loaded",
		Message = "No saved config - using defaults",
		Type = "info",
		Duration = 3
	})
end

print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("✅ Configuration Demo Ready!")
print("📁 Config File:", RvrseUI.ConfigurationFileName)
print("🔄 Auto-Save: ENABLED")
print("💡 Change any setting to trigger auto-save")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
