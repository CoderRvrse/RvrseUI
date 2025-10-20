-- Config Profiles Integration Test
-- Validates that the Profiles tab uses the modern multi-select dropdown
-- and that profile refresh/load flows behave with current APIs.

print("\n" .. string.rep("=", 90))
print("🧪 RvrseUI Config Profiles Test")
print(string.rep("=", 90))

local timestamp = os.time()
local url = string.format("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua?t=%d", timestamp)
print(string.format("⏬ Fetching RvrseUI build (%s)", url))
local RvrseUI = loadstring(game:HttpGet(url))()

print("\n📦 Version:", RvrseUI.Version.Full, "| Build:", RvrseUI.Version.Build, "| Hash:", RvrseUI.Version.Hash)

-- Enable debug tracing so dropdown lifecycle logs appear in the console.
RvrseUI:EnableDebug(true)

-- Is filesystem available? (Some executors sandbox file APIs.)
local hasFS = type(writefile) == "function" and type(readfile) == "function"
local testFolder = "RvrseUI/ConfigProfilesTest"

print("\n🗂️ File system access:", hasFS and "available ✅" or "limited ⚠️ (profiles simulated only)")

-- Utility to wipe old test files to keep the list clean between runs.
local function clearOldProfiles()
	if not hasFS or type(listfiles) ~= "function" then
		return
	end

	if not isfolder(testFolder) then
		makefolder(testFolder)
		return
	end

	for _, path in ipairs(listfiles(testFolder)) do
		local name = path:match("([^/\\]+)$")
		if name and name:match("^test_profile_") then
			delfile(testFolder .. "/" .. name)
		end
	end
end

-- Seed a few profiles so the dropdown always has content.
local function seedProfiles()
	if not hasFS then
		print("ℹ️ Skipping profile seeding (writefile unavailable). Use manual saves in the UI.")
		return
	end

	clearOldProfiles()

	-- create placeholder configs
	local profiles = {
		{ name = "test_profile_dark", theme = "Dark" },
		{ name = "test_profile_light", theme = "Light" },
		{ name = "test_profile_vibrant", theme = "Dark" },
	}

	for _, entry in ipairs(profiles) do
		local payload = {
			_RvrseUI_Theme = entry.theme,
			_RvrseUI_State = {
				exampleToggle = entry.theme == "Dark",
				exampleSlider = entry.theme == "Dark" and 0.45 or 0.8,
			},
		}

		local ok, json = pcall(game.HttpService.JSONEncode, game.HttpService, payload)
		if ok then
			writefile(string.format("%s/%s.json", testFolder, entry.name), json)
		end
	end

	print(string.format("✅ Seeded %d sample profiles in %s", #profiles, testFolder))
end

seedProfiles()

print("\n🪟 Building window…")

local Window = RvrseUI:CreateWindow({
	Name = "Profiles QA Harness",
	Icon = "lucide://layers",
	Theme = "Dark",
	ToggleUIKeybind = "P",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = testFolder,
		FileName = "active_profile.json",
		AutoSave = false,
	},
	ConfigurationManager = {
		TabName = "Profiles",
		Icon = "lucide://folder",
		SectionTitle = "Profile Manager",
		SuppressWarnings = false,
		NewProfilePlaceholder = "my_profile",
	},
})

-- Basic content so the window has user-facing state to store.
local MainTab = Window:CreateTab({ Title = "Elements", Icon = "lucide://sliders-horizontal" })
local Section = MainTab:CreateSection("Stateful Elements")

local testToggle = Section:CreateToggle({
	Text = "Example Toggle",
	Default = true,
	Flag = "ProfilesTest.Toggle",
})

local testSlider = Section:CreateSlider({
	Text = "Volume",
	Min = 0,
	Max = 100,
	Default = 35,
	Flag = "ProfilesTest.Volume",
})

Section:CreateLabel({ Text = "Profiles tab lives on the left rail. Switch over after seeding completes." })

Window:Show()

print("\n✅ Window created. Profiles tab should now use the modern dropdown.")

-- Diagnostics: list profiles via API to mirror what the dropdown consumes.
local function dumpProfiles(context)
	local list, warning = RvrseUI:ListProfiles()
	print(string.rep("-", 70))
	print(string.format("📁 Available profiles [%s]:", context))
	if warning then
		print("  ⚠️ Warning:", warning)
	end
	if list and #list > 0 then
		for i, name in ipairs(list) do
			print(string.format("  %d) %s", i, name))
		end
	else
		print("  (none discovered)")
	end
end

dumpProfiles("initial load")

task.delay(2, function()
	print("\n🧪 Auto-save current UI state into 'test_profile_runtime' for validation")
	local ok, message = RvrseUI:SaveConfigAs("test_profile_runtime")
	print("   Save result:", ok and "success ✅" or ("failed ❌ (" .. tostring(message) .. ")"))
	dumpProfiles("after runtime save")

	-- Try reloading the freshly saved profile to validate API path.
	local loadOk, loadMsg = RvrseUI:LoadConfigByName("test_profile_runtime")
	print("   Load result:", loadOk and "success ✅" or ("failed ❌ (" .. tostring(loadMsg) .. ")"))
end)

print("\n" .. string.rep("=", 90))
print("🎯 Manual Verification Checklist")
print(string.rep("=", 90))
print("1. Open the Profiles tab (left side icon).")
print("2. Click the dropdown – it should render the modern multi-select UI (checkbox entries).")
print("3. Selecting any profile should close the dropdown and update the \"Active Profile\" label.")
print("4. Use \"Save As\" to create another profile; the dropdown should refresh automatically.")
print("5. Press the refresh button → confirm console logs show the profile list update.")
print("6. (Optional) Toggle \"Example Toggle\" or adjust the slider, then re-load profiles to confirm persistence.")
print(string.rep("=", 90))

print("\n⌨️ Use keybind 'P' to toggle the UI on/off if needed.\n")
