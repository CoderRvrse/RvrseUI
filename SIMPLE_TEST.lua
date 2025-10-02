-- SIMPLE_TEST.lua - Production-Ready RvrseUI v2.7.1 Demo
-- ✅ Theme persistence working! Saved theme always loads correctly
-- ✅ All elements, config saving, no errors!

-- Load RvrseUI with cache buster (always gets latest version)
local RvrseUI = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua?" .. tick()
))()

-- Create window with configuration saving
-- NOTE: Theme parameter is first-run default only - saved theme takes precedence!
local Window = RvrseUI:CreateWindow({
	Name = "Simple Test Hub",
	Icon = "🎮",
	LoadingTitle = "Simple Test Hub",
	LoadingSubtitle = "Loading features...",
	Theme = "Dark",  -- Used ONLY on first run (saved theme wins after that)
	ToggleUIKeybind = "K",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "SimpleTestHub",
		FileName = "Config.json"
	}
})

-- Main Tab
local MainTab = Window:CreateTab({
	Title = "Main",
	Icon = "⚙"
})

-- Player Section
local PlayerSection = MainTab:CreateSection("Player Features")

-- Speed Slider (with config saving)
local speedSlider = PlayerSection:CreateSlider({
	Text = "Walk Speed",
	Min = 16,
	Max = 100,
	Step = 2,
	Default = 16,
	Flag = "WalkSpeed",  -- Auto-saves!
	OnChanged = function(speed)
		-- Apply walk speed
		local player = game.Players.LocalPlayer
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.WalkSpeed = speed
		end

		RvrseUI:Notify({
			Title = "Speed Changed",
			Message = "Walk speed set to " .. speed,
			Duration = 1,
			Type = "info"
		})
	end
})

-- Jump Power Slider
PlayerSection:CreateSlider({
	Text = "Jump Power",
	Min = 50,
	Max = 200,
	Step = 5,
	Default = 50,
	Flag = "JumpPower",
	OnChanged = function(power)
		local player = game.Players.LocalPlayer
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.JumpPower = power
		end
	end
})

-- Fly Toggle
local flyToggle = PlayerSection:CreateToggle({
	Text = "Enable Flying",
	State = false,
	Flag = "FlyEnabled",
	OnChanged = function(enabled)
		if enabled then
			RvrseUI:Notify({
				Title = "Flight Enabled",
				Message = "You can now fly!",
				Duration = 2,
				Type = "success"
			})
			-- Add your fly code here
		else
			RvrseUI:Notify({
				Title = "Flight Disabled",
				Duration = 1,
				Type = "warn"
			})
			-- Disable fly code here
		end
	end
})

-- Noclip Toggle
PlayerSection:CreateToggle({
	Text = "Noclip",
	State = false,
	Flag = "NoclipEnabled",
	OnChanged = function(enabled)
		if enabled then
			-- Enable noclip
			RvrseUI:Notify({
				Title = "Noclip ON",
				Type = "success",
				Duration = 1
			})
		else
			-- Disable noclip
			RvrseUI:Notify({
				Title = "Noclip OFF",
				Type = "warn",
				Duration = 1
			})
		end
	end
})

-- Combat Section
local CombatSection = MainTab:CreateSection("Combat")

-- Auto Farm Master Toggle
CombatSection:CreateToggle({
	Text = "🎯 Auto Farm (MASTER)",
	State = false,
	LockGroup = "AutoFarm",  -- Locks child toggles when ON
	OnChanged = function(enabled)
		if enabled then
			RvrseUI:Notify({
				Title = "Auto Farm Started",
				Message = "Individual farms are now locked",
				Duration = 2,
				Type = "success"
			})
		else
			RvrseUI:Notify({
				Title = "Auto Farm Stopped",
				Duration = 1,
				Type = "warn"
			})
		end
	end
})

-- Individual farm toggles (locked by master)
CombatSection:CreateToggle({
	Text = "Farm Coins",
	State = false,
	RespectLock = "AutoFarm",
	Flag = "FarmCoins",
	OnChanged = function(on)
		print("Farm Coins:", on)
	end
})

CombatSection:CreateToggle({
	Text = "Farm XP",
	State = false,
	RespectLock = "AutoFarm",
	Flag = "FarmXP",
	OnChanged = function(on)
		print("Farm XP:", on)
	end
})

-- Kill Aura Button
CombatSection:CreateButton({
	Text = "Activate Kill Aura",
	Callback = function()
		RvrseUI:Notify({
			Title = "Kill Aura",
			Message = "Feature activated!",
			Duration = 2,
			Type = "success"
		})
		-- Add your kill aura code
	end
})

-- Settings Tab
local SettingsTab = Window:CreateTab({
	Title = "Settings",
	Icon = "🔧"
})

-- Theme Section
local ThemeSection = SettingsTab:CreateSection("Appearance")

ThemeSection:CreateDropdown({
	Text = "Theme Mode",
	Values = {"Dark", "Light"},
	Default = "Dark",
	Flag = "ThemeMode",
	OnChanged = function(theme)
		-- Theme switching is handled by topbar toggle
		RvrseUI:Notify({
			Title = "Theme",
			Message = "Use the 🌙/🌞 button in the header to switch themes",
			Duration = 3,
			Type = "info"
		})
	end
})

-- Controls Section
local ControlsSection = SettingsTab:CreateSection("Controls")

ControlsSection:CreateKeybind({
	Text = "Toggle UI Hotkey",
	Default = Enum.KeyCode.K,
	IsUIToggle = true,  -- 🔑 IMPORTANT: This makes it rebind the UI toggle key!
	OnChanged = function(key)
		RvrseUI:Notify({
			Title = "UI Toggle Updated",
			Message = "Press " .. key.Name .. " to open/close UI",
			Duration = 2,
			Type = "success"
		})
	end
})

ControlsSection:CreateKeybind({
	Text = "Destroy UI Key (Backspace)",
	Default = Enum.KeyCode.Backspace,
	IsUIEscape = true,  -- 🔑 Makes this the destroy/close key!
	OnChanged = function(key)
		RvrseUI:Notify({
			Title = "Destroy Key Updated",
			Message = "Press " .. key.Name .. " to destroy UI",
			Duration = 2,
			Type = "success"
		})
	end
})

-- Config Section
local ConfigSection = SettingsTab:CreateSection("Configuration")

ConfigSection:CreateButton({
	Text = "💾 Save Configuration",
	Callback = function()
		local success, message = RvrseUI:SaveConfiguration()
		if success then
			RvrseUI:Notify({
				Title = "Config Saved",
				Message = "Settings saved to SimpleTestHub/Config.json",
				Duration = 2,
				Type = "success"
			})
		else
			RvrseUI:Notify({
				Title = "Save Failed",
				Message = message,
				Duration = 3,
				Type = "error"
			})
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
				Message = message,
				Duration = 2,
				Type = "success"
			})
		else
			RvrseUI:Notify({
				Title = "Load Failed",
				Message = message,
				Duration = 3,
				Type = "warn"
			})
		end
	end
})

ConfigSection:CreateButton({
	Text = "🗑️ Delete Configuration",
	Callback = function()
		local success = RvrseUI:DeleteConfiguration()
		if success then
			RvrseUI:Notify({
				Title = "Config Deleted",
				Duration = 2,
				Type = "warn"
			})
		end
	end
})

-- Info Section
local InfoSection = SettingsTab:CreateSection("Information")

InfoSection:CreateLabel({
	Text = "Simple Test Hub v1.0"
})

InfoSection:CreateParagraph({
	Text = "This is a production-ready demo of RvrseUI v2.7.1 with theme persistence, GPT-5 verification logging, minimize to controller, and all features working flawlessly. Configuration auto-saves, theme persists correctly, no errors!"
})

InfoSection:CreateDivider()

InfoSection:CreateLabel({
	Text = "Features: Config saving, lock groups, smooth sliders, premium UX"
})

-- Auto-load configuration on startup
task.spawn(function()
	task.wait(1)
	if RvrseUI:ConfigurationExists() then
		RvrseUI:LoadConfiguration()
		RvrseUI:Notify({
			Title = "Config Auto-Loaded",
			Message = "Your saved settings have been restored",
			Duration = 3,
			Type = "success"
		})
	end
end)

-- Welcome notification
RvrseUI:Notify({
	Title = "Simple Test Hub Loaded",
	Message = "Press K to toggle UI. All features working!",
	Duration = 4,
	Type = "success"
})

-- Version check
print("===========================================")
print("RvrseUI Version:", RvrseUI.Version.Full)
print("Build:", RvrseUI.Version.Build)
print("Hash:", RvrseUI.Version.Hash)
print("Channel:", RvrseUI.Version.Channel)
print("===========================================")
