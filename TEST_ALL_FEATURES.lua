--[[
	RvrseUI Master Test Suite

	This is the single, comprehensive test script for RvrseUI v3.
	It exercises every public feature:
	  ✅ 12 UI elements (Button, Toggle, Dropdown, Slider, Keybind, TextBox,
	      ColorPicker, Label, Paragraph, Divider, Section, Tab)
	  ✅ Notifications, lock groups, Flags registry
	  ✅ Theme switching and keyboard toggles
	  ✅ Configuration save/load helpers

	USAGE
	1. Place this script in a LocalScript (e.g. StarterPlayerScripts).
	2. Ensure HTTP requests are allowed if running from Roblox Studio.
	3. Press Play. Watch the output window for diagnostics.

	If you already have the modules in ReplicatedStorage,
	replace the loadstring block with `local RvrseUI = require(path.to.init)`.
]]

local function loadRvrseUI()
	local url = "https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/init.lua"

	print("\n" .. string.rep("=", 60))
	print("🧪 Loading RvrseUI from:", url)

	local ok, result = pcall(function()
		return game:HttpGet(url, true)
	end)
	if not ok then
		error("❌ HttpGet failed: " .. tostring(result), 0)
	end

	print("  ✅ Downloaded", #result, "bytes")

	local chunk, compileErr = loadstring(result)
	if not chunk then
		error("❌ loadstring failed: " .. tostring(compileErr), 0)
	end

	local moduleEnv = chunk()
	if type(moduleEnv) ~= "table" then
		error("❌ init.lua did not return a table", 0)
	end

	print("  ✅ RvrseUI module ready")
	print(string.rep("=", 60) .. "\n")

	return moduleEnv
end

local RvrseUI = loadRvrseUI()

-- Build the master test window
local Window = RvrseUI:CreateWindow({
	Name = "RvrseUI Master Test",
	Icon = "trophy",
	LoadingTitle = "RvrseUI Test Suite",
	LoadingSubtitle = "Warming up all systems...",
	Theme = "Dark",
	ToggleUIKeybind = "K",
	ConfigurationSaving = "MasterTestProfile"
})

Window:Show()

-- Convenience reference
local function notify(opts)
	RvrseUI:Notify(opts)
end

-- TAB 1: Core interactive elements -----------------------------------------
local CoreTab = Window:CreateTab({ Title = "Interactive", Icon = "sliders" })
local Actions = CoreTab:CreateSection("Actions & Controls")

local CoreButton = Actions:CreateButton({
	Text = "Send Notification",
	Callback = function()
		notify({
			Title = "Button Clicked",
			Message = "Hello from the master suite!",
			Duration = 3,
			Type = "success"
		})
	end,
	Flag = "Master_Button"
})

local CoreToggle = Actions:CreateToggle({
	Text = "Enable Feature",
	State = false,
	OnChanged = function(state)
		print("[Toggle] Enable Feature =", state)
	end,
	Flag = "Master_Toggle"
})

local CoreDropdown = Actions:CreateDropdown({
	Text = "Difficulty",
	Values = {"Easy", "Normal", "Hard", "Nightmare"},
	Default = "Normal",
	OnChanged = function(value)
		print("[Dropdown] Difficulty selected:", value)
	end,
	Flag = "Master_Dropdown"
})

local CoreSlider = Actions:CreateSlider({
	Text = "Volume",
	Min = 0,
	Max = 100,
	Step = 5,
	Default = 50,
	OnChanged = function(value)
		print("[Slider] Volume =", value)
	end,
	Flag = "Master_Slider"
})

local CoreKeybind = Actions:CreateKeybind({
	Text = "Custom Action Key",
	Default = Enum.KeyCode.F,
	OnChanged = function(key)
		print("[Keybind] Custom action set to:", key.Name)
	end,
	Flag = "Master_Keybind"
})

-- TAB 2: Input elements -----------------------------------------------------
local InputTab = Window:CreateTab({ Title = "Input", Icon = "edit-3" })
local Input = InputTab:CreateSection("Text & Colors")

local CoreTextBox = Input:CreateTextBox({
	Text = "Status Message",
	Placeholder = "Enter status...",
	Default = "System Ready",
	OnChanged = function(value, submitted)
		print("[TextBox] Status =", value, "| Submitted =", submitted)
	end,
	Flag = "Master_TextBox"
})

local CoreColor = Input:CreateColorPicker({
	Text = "Accent Color",
	Default = Color3.fromRGB(99, 102, 241),
	OnChanged = function(color)
		print(string.format("[ColorPicker] RGB(%d,%d,%d)", color.R * 255, color.G * 255, color.B * 255))
	end,
	Flag = "Master_Color"
})

-- TAB 3: Display helper elements -------------------------------------------
local DisplayTab = Window:CreateTab({ Title = "Display", Icon = "layout" })
local Display = DisplayTab:CreateSection("Labels & Paragraphs")

local CoreLabel = Display:CreateLabel({
	Text = "🚦 System state: ONLINE",
	Flag = "Master_Label"
})

local CoreParagraph = Display:CreateParagraph({
	Text = "This paragraph demonstrates wrapped text. Update it via Set() to confirm state changes propagate correctly throughout the Flags registry.",
	Flag = "Master_Paragraph"
})

Display:CreateDivider()
Display:CreateLabel({ Text = "Divider keeps layout tidy." })

-- TAB 4: Lock group + Flags verification -----------------------------------
local LockTab = Window:CreateTab({ Title = "Locks & Flags", Icon = "lock" })
local LockSection = LockTab:CreateSection("Master/Child Demo")

LockSection:CreateParagraph({
	Text = "Toggle the MASTER option to lock/unlock the child controls below."
})

LockSection:CreateToggle({
	Text = "MASTER: Automation Mode",
	LockGroup = "AutomationMode",
	OnChanged = function(state)
		notify({
			Title = "Automation " .. (state and "Enabled" or "Disabled"),
			Message = state and "Child controls locked." or "Child controls unlocked.",
			Type = state and "warning" or "info"
		})
	end
})

LockSection:CreateToggle({
	Text = "Child Option A",
	RespectLock = "AutomationMode"
})

LockSection:CreateSlider({
	Text = "Child Intensity",
	Min = 0,
	Max = 10,
	Default = 5,
	RespectLock = "AutomationMode"
})

LockSection:CreateDivider()

LockSection:CreateButton({
	Text = "Dump Flag Values",
	Callback = function()
		print("\n" .. string.rep("-", 40))
		print("🚩 FLAG SNAPSHOT")
		for flagName, element in pairs(RvrseUI.Flags) do
			if element.Get then
				local ok, value = pcall(element.Get, element)
				print(flagName .. " =", ok and value or "[error: " .. tostring(value) .. "]")
			end
		end
		print(string.rep("-", 40) .. "\n")
		notify({
			Title = "Flags Dumped",
			Message = "Check Output (F9) for full list.",
			Type = "info"
		})
	end
})

-- TAB 5: Configuration helpers ---------------------------------------------
local ConfigTab = Window:CreateTab({ Title = "Config & Theme", Icon = "settings" })
local ConfigSection = ConfigTab:CreateSection("Configuration Workflow")

ConfigSection:CreateButton({
	Text = "Save Configuration",
	Callback = function()
		local success, msg = RvrseUI:SaveConfiguration()
		print("[Config] Save result:", success, msg)
		notify({
			Title = success and "Configuration Saved" or "Save Failed",
			Message = msg,
			Type = success and "success" or "error"
		})
	end
})

ConfigSection:CreateButton({
	Text = "Load Configuration",
	Callback = function()
		local success, msg = RvrseUI:LoadConfiguration()
		print("[Config] Load result:", success, msg)
		notify({
			Title = success and "Configuration Loaded" or "Load Failed",
			Message = msg or "See console for details.",
			Type = success and "success" or "warning"
		})
	end
})

ConfigSection:CreateButton({
	Text = "Toggle Theme",
	Callback = function()
		local current = RvrseUI:GetTheme()
		local target = current == "Dark" and "Light" or "Dark"
		RvrseUI:SetTheme(target)
		notify({
			Title = "Theme Switched",
			Message = "Theme is now " .. target,
			Type = "info"
		})
	end
})

ConfigSection:CreateButton({
	Text = "Print Version Info",
	Callback = function()
		local info = RvrseUI:GetVersionInfo()
		print("\n" .. string.rep("=", 40))
		print("📦 VERSION INFO")
		for key, value in pairs(info) do
			print(key .. ":", value)
		end
		print(string.rep("=", 40) .. "\n")
	end
})

-- TAB 6: Utility + teardown -------------------------------------------------
local UtilTab = Window:CreateTab({ Title = "Utilities", Icon = "tool" })
local UtilSection = UtilTab:CreateSection("Window Controls")

UtilSection:CreateButton({
	Text = "Minimize Window",
	Callback = function()
		RvrseUI.UI:ToggleAllWindows()
	end
})

UtilSection:CreateButton({
	Text = "Destroy UI",
	Callback = function()
		RvrseUI:Destroy()
	end
})

local flagCount = 0
for _ in pairs(RvrseUI.Flags) do
	flagCount += 1
end

print("\n" .. string.rep("=", 60))
print("✅ RvrseUI Master Test Suite Loaded")
print("  • Tabs: Interactive, Input, Display, Locks & Flags, Config & Theme, Utilities")
print("  • Flags registered:", flagCount)
print("  • Configuration profile: MasterTestProfile.json")
print("Press K to toggle the entire UI.")
print(string.rep("=", 60) .. "\n")

notify({
	Title = "RvrseUI Master Test Suite",
	Message = "Explore each tab to validate components.",
	Type = "success",
	Duration = 6
})
