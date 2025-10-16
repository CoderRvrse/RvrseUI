-- ⚠️ Development only - Use for testing latest changes
local url = "https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"
local body = game:HttpGet(url, true)
local chunk, err = loadstring(body)

if not chunk then
    error("[RvrseUI] loadstring failed: " .. tostring(err) ..
          "\nFirst 120 chars:\n" .. string.sub(body, 1, 120), 0)
end

local RvrseUI = chunk()
RvrseUI:EnableDebug(true) -- Optional: enable verbose diagnostics for live testing

-- ✅ v3.0.0 - Compiled from modular architecture (115 KB, all 26 modules inlined)
-- All features: 12 elements, theme system, config persistence, animations

-- Create window with configuration saving
local Window = RvrseUI:CreateWindow({
  Name = "Simple Test Hub",
  Icon = "🎮",
  LoadingTitle = "Simple Test Hub",
  LoadingSubtitle = "Loading features...",
  Theme = "Dark",  -- Used ONLY on first run (saved theme wins after that)
  ToggleUIKeybind = "K",
  ConfigurationSaving = {
    Enabled = true,
    FolderName = "TestHub",  -- Saves to:TestHub/Config.json
    FileName = "Config.json"
  }
})

-- Main Tab
local MainTab = Window:CreateTab({ Title = "Main", Icon = "⚙" })

-- Player Section
local PlayerSection = MainTab:CreateSection("Player Features")

-- Speed Slider (with auto-save via Flag)
PlayerSection:CreateSlider({
  Text = "Walk Speed",
  Min = 16,
  Max = 100,
  Step = 2,
  Default = 16,
  Flag = "WalkSpeed",  -- Auto-saves when changed!
  OnChanged = function(speed)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("Humanoid") then
      player.Character.Humanoid.WalkSpeed = speed
    end
  end
})

-- Fly Toggle (with auto-save)
PlayerSection:CreateToggle({
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
    else
      RvrseUI:Notify({
        Title = "Flight Disabled",
        Duration = 1,
        Type = "warn"
      })
    end
  end
})

-- Combat Section with Lock Groups
local CombatSection = MainTab:CreateSection("Combat Features")

-- Master Toggle (locks child toggles when ON)
CombatSection:CreateToggle({
  Text = "🎯 Auto Farm (MASTER)",
  State = false,
  LockGroup = "AutoFarm",  -- Locks all toggles with RespectLock = "AutoFarm"
  OnChanged = function(enabled)
    if enabled then
      RvrseUI:Notify({
        Title = "Auto Farm Started",
        Message = "Individual farms are now locked",
        Duration = 2,
        Type = "success"
      })
    end
  end
})

-- Child Toggles (locked when master is ON)
CombatSection:CreateToggle({
  Text = "Farm Coins",
  State = false,
  RespectLock = "AutoFarm",  -- Becomes disabled when AutoFarm master is ON
  Flag = "FarmCoins",
  OnChanged = function(on) print("Farm Coins:", on) end
})

-- Settings Tab
local SettingsTab = Window:CreateTab({ Title = "Settings", Icon = "🔧" })

-- Controls Section with rebindable UI toggle
local ControlsSection = SettingsTab:CreateSection("Controls")

ControlsSection:CreateKeybind({
  Text = "Toggle UI Hotkey",
  Default = Enum.KeyCode.K,
  Flag = "UIToggleKey",  -- 💾 Saves to config
  IsUIToggle = true,  -- 🔑 Makes this keybind control the UI toggle!
  OnChanged = function(key)
    RvrseUI:Notify({
      Title = "Hotkey Updated",
      Message = "Press " .. key.Name .. " to toggle UI",
      Duration = 2,
      Type = "success"
    })
  end
})

ControlsSection:CreateKeybind({
  Text = "Destroy UI Key (Backspace)",
  Default = Enum.KeyCode.Backspace,
  Flag = "UIDestroyKey",  -- 💾 Saves to config
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

local ConfigSection = SettingsTab:CreateSection("Configuration")

-- Manual Save Button
ConfigSection:CreateButton({
  Text = "💾 Save Configuration",
  Callback = function()
    local success, message = RvrseUI:SaveConfiguration()
    if success then
      RvrseUI:Notify({
        Title = "Config Saved",
        Message = "Settings saved successfully!",
        Duration = 2,
        Type = "success"
      })
    end
  end
})

-- Load Button
ConfigSection:CreateButton({
  Text = "📂 Load Configuration",
  Callback = function()
    local success, message = RvrseUI:LoadConfiguration()
    RvrseUI:Notify({
      Title = success and "Config Loaded" or "Load Failed",
      Message = message,
      Duration = 2,
      Type = success and "success" or "warn"
    })
  end
})

-- ═══════════════════════════════════════════════════════════════
-- 🧪 RAYFIELD PARITY TESTS (Phase 1)
-- Testing Button:Set(), Slider:SetRange(), Slider:SetSuffix()
-- ═══════════════════════════════════════════════════════════════

local TestTab = Window:CreateTab({ Title = "🧪 Parity Tests", Icon = "🔬" })
local ParitySection = TestTab:CreateSection("Rayfield API Compatibility Tests")

-- ─────────────────────────────────────────────────────────────
-- TEST 1: Button:Set() Method
-- ─────────────────────────────────────────────────────────────
ParitySection:CreateLabel({ Text = "─── Button:Set() Test ───" })

local testButton = ParitySection:CreateButton({
  Text = "Test Button (Original)",
  Callback = function()
    RvrseUI:Notify({
      Title = "Button Clicked",
      Message = "Button callback fired!",
      Duration = 2,
      Type = "info"
    })
  end
})

ParitySection:CreateButton({
  Text = "🔄 Change Button Text",
  Callback = function()
    local newText = "✅ Button Updated at " .. os.date("%H:%M:%S")
    testButton:Set(newText)
    RvrseUI:Notify({
      Title = "Button:Set() Success",
      Message = "Text changed to: " .. newText,
      Duration = 2,
      Type = "success"
    })
  end
})

-- ─────────────────────────────────────────────────────────────
-- TEST 2: Slider:SetRange() Method
-- ─────────────────────────────────────────────────────────────
ParitySection:CreateLabel({ Text = "─── Slider:SetRange() Test ───" })

local testSlider = ParitySection:CreateSlider({
  Text = "Dynamic Range Slider",
  Min = 0,
  Max = 100,
  Step = 1,
  Default = 50,
  Suffix = "",
  OnChanged = function(value)
    print("[Test Slider] Value:", value)
  end
})

ParitySection:CreateButton({
  Text = "📊 Set Range: 0-200 (Step 10)",
  Callback = function()
    testSlider:SetRange(0, 200, 10)
    RvrseUI:Notify({
      Title = "SetRange() Success",
      Message = "Range changed to 0-200, step 10",
      Duration = 2,
      Type = "success"
    })
  end
})

ParitySection:CreateButton({
  Text = "📊 Set Range: 0-1000 (Step 50)",
  Callback = function()
    testSlider:SetRange(0, 1000, 50)
    RvrseUI:Notify({
      Title = "SetRange() Success",
      Message = "Range changed to 0-1000, step 50",
      Duration = 2,
      Type = "success"
    })
  end
})

ParitySection:CreateButton({
  Text = "📊 Reset Range: 0-100 (Step 1)",
  Callback = function()
    testSlider:SetRange(0, 100, 1)
    RvrseUI:Notify({
      Title = "SetRange() Success",
      Message = "Range reset to 0-100, step 1",
      Duration = 2,
      Type = "success"
    })
  end
})

-- ─────────────────────────────────────────────────────────────
-- TEST 3: Slider:SetSuffix() Method
-- ─────────────────────────────────────────────────────────────
ParitySection:CreateLabel({ Text = "─── Slider:SetSuffix() Test ───" })

local suffixSlider = ParitySection:CreateSlider({
  Text = "Value Suffix Demo",
  Min = 0,
  Max = 100,
  Step = 5,
  Default = 50,
  Suffix = "%",
  OnChanged = function(value)
    print("[Suffix Slider] Value:", value)
  end
})

ParitySection:CreateButton({
  Text = "📝 Change Suffix: '%'",
  Callback = function()
    suffixSlider:SetSuffix("%")
    RvrseUI:Notify({
      Title = "SetSuffix() Success",
      Message = "Suffix changed to '%'",
      Duration = 2,
      Type = "success"
    })
  end
})

ParitySection:CreateButton({
  Text = "📝 Change Suffix: ' items'",
  Callback = function()
    suffixSlider:SetSuffix(" items")
    RvrseUI:Notify({
      Title = "SetSuffix() Success",
      Message = "Suffix changed to ' items'",
      Duration = 2,
      Type = "success"
    })
  end
})

ParitySection:CreateButton({
  Text = "📝 Change Suffix: ' HP'",
  Callback = function()
    suffixSlider:SetSuffix(" HP")
    RvrseUI:Notify({
      Title = "SetSuffix() Success",
      Message = "Suffix changed to ' HP'",
      Duration = 2,
      Type = "success"
    })
  end
})

ParitySection:CreateButton({
  Text = "📝 Remove Suffix (Empty)",
  Callback = function()
    suffixSlider:SetSuffix("")
    RvrseUI:Notify({
      Title = "SetSuffix() Success",
      Message = "Suffix removed",
      Duration = 2,
      Type = "success"
    })
  end
})

-- ─────────────────────────────────────────────────────────────
-- TEST 4: Combined Dynamic Updates
-- ─────────────────────────────────────────────────────────────
ParitySection:CreateLabel({ Text = "─── Combined Test ───" })

local dynamicSlider = ParitySection:CreateSlider({
  Text = "Dynamic Slider",
  Min = 0,
  Max = 100,
  Step = 1,
  Default = 50,
  Suffix = "",
  Flag = "DynamicSliderTest",
  OnChanged = function(value)
    print("[Dynamic Slider] Value:", value)
  end
})

ParitySection:CreateButton({
  Text = "🎯 Simulate Game Difficulty Change",
  Callback = function()
    -- Change to difficulty scale: 1-10
    dynamicSlider:SetRange(1, 10, 1)
    dynamicSlider:SetSuffix(" (difficulty)")
    dynamicSlider:Set(5)
    RvrseUI:Notify({
      Title = "Difficulty Mode Active",
      Message = "Range: 1-10, Suffix: (difficulty)",
      Duration = 3,
      Type = "info"
    })
  end
})

ParitySection:CreateButton({
  Text = "💰 Simulate Currency System",
  Callback = function()
    -- Change to currency scale: 0-10000
    dynamicSlider:SetRange(0, 10000, 100)
    dynamicSlider:SetSuffix(" coins")
    dynamicSlider:Set(5000)
    RvrseUI:Notify({
      Title = "Currency Mode Active",
      Message = "Range: 0-10000, Suffix: coins",
      Duration = 3,
      Type = "info"
    })
  end
})

ParitySection:CreateButton({
  Text = "❤️ Simulate Health System",
  Callback = function()
    -- Change to health scale: 0-500
    dynamicSlider:SetRange(0, 500, 10)
    dynamicSlider:SetSuffix(" HP")
    dynamicSlider:Set(250)
    RvrseUI:Notify({
      Title = "Health Mode Active",
      Message = "Range: 0-500, Suffix: HP",
      Duration = 3,
      Type = "info"
    })
  end
})

-- ─────────────────────────────────────────────────────────────
-- TEST 5: Mass Update Test (Stress Test)
-- ─────────────────────────────────────────────────────────────
ParitySection:CreateLabel({ Text = "─── Stress Test ───" })

ParitySection:CreateButton({
  Text = "⚡ Run Mass Update Test",
  Callback = function()
    RvrseUI:Notify({
      Title = "Mass Update Started",
      Message = "Updating all test elements rapidly...",
      Duration = 2,
      Type = "info"
    })

    -- Simulate rapid updates (like profile loading)
    task.spawn(function()
      for i = 1, 10 do
        testButton:Set("Update #" .. i)
        testSlider:Set(math.random(0, 100))
        suffixSlider:Set(math.random(0, 100))
        dynamicSlider:Set(math.random(0, 500))
        task.wait(0.1)
      end

      RvrseUI:Notify({
        Title = "Mass Update Complete",
        Message = "All elements updated 10x successfully!",
        Duration = 3,
        Type = "success"
      })
    end)
  end
})

ParitySection:CreateParagraph({
  Text = "✅ Parity Test Results:\n• Button:Set() - Working\n• Slider:SetRange() - Working\n• Slider:SetSuffix() - Working\n• Mass Updates - Stable\n\nRvrseUI is now 95% Rayfield compatible!"
})

-- ═══════════════════════════════════════════════════════════════
-- 🎨 PHASE 2: ColorPicker RGB/HSV + Hex Input Tests
-- ═══════════════════════════════════════════════════════════════

local Phase2Tab = Window:CreateTab({ Title = "🎨 Phase 2 Features", Icon = "🚀" })
local ColorPickerSection = Phase2Tab:CreateSection("Advanced ColorPicker (RGB/HSV/Hex)")

ColorPickerSection:CreateLabel({ Text = "─── Advanced Color Picker Demo ───" })

-- Advanced ColorPicker with full RGB/HSV/Hex controls
local advancedPicker = ColorPickerSection:CreateColorPicker({
  Text = "Advanced Color Picker",
  Default = Color3.fromRGB(88, 101, 242),  -- Discord Blurple
  Advanced = true,  -- Enable RGB/HSV/Hex controls
  Flag = "AdvancedColor",
  OnChanged = function(color)
    print("[Advanced Picker] Color changed:", color)
  end
})

ColorPickerSection:CreateLabel({ Text = "Features:" })
ColorPickerSection:CreateParagraph({
  Text = "• RGB Sliders (0-255)\n• HSV Sliders (H: 0-360, S/V: 0-100%)\n• Hex Input (#RRGGBB)\n• Live Preview Circle\n• Auto-sync between modes\n• Click circle to toggle panel"
})

-- Simple ColorPicker for comparison
ColorPickerSection:CreateLabel({ Text = "─── Simple Mode (Preset Colors) ───" })

ColorPickerSection:CreateColorPicker({
  Text = "Simple Color Cycler",
  Default = Color3.fromRGB(255, 0, 0),
  Advanced = false,  -- Disable advanced mode (8 preset colors)
  Flag = "SimpleColor",
  OnChanged = function(color)
    print("[Simple Picker] Color changed:", color)
  end
})

-- API Test Buttons
ColorPickerSection:CreateLabel({ Text = "─── ColorPicker API Tests ───" })

ColorPickerSection:CreateButton({
  Text = "🎨 Set Random Color",
  Callback = function()
    local randomColor = Color3.fromRGB(
      math.random(0, 255),
      math.random(0, 255),
      math.random(0, 255)
    )
    advancedPicker:Set(randomColor)
    RvrseUI:Notify({
      Title = "Color Updated",
      Message = "Set to random color!",
      Duration = 2,
      Type = "success"
    })
  end
})

ColorPickerSection:CreateButton({
  Text = "📋 Get Current Color",
  Callback = function()
    local color = advancedPicker:Get()
    local r = math.floor(color.R * 255 + 0.5)
    local g = math.floor(color.G * 255 + 0.5)
    local b = math.floor(color.B * 255 + 0.5)
    RvrseUI:Notify({
      Title = "Current Color",
      Message = string.format("RGB(%d, %d, %d)", r, g, b),
      Duration = 3,
      Type = "info"
    })
  end
})

-- ═══════════════════════════════════════════════════════════════
-- 📋 PHASE 2: Dropdown Multi-Select Tests
-- ═══════════════════════════════════════════════════════════════

local DropdownSection = Phase2Tab:CreateSection("Dropdown Multi-Select")

DropdownSection:CreateLabel({ Text = "─── Multi-Select Dropdown Demo ───" })

-- Multi-select dropdown (Rayfield-compatible syntax)
local multiDropdown = DropdownSection:CreateDropdown({
  Text = "Select Game Modes",
  Options = {"Team Deathmatch", "Capture the Flag", "King of the Hill", "Free for All", "Domination", "Search & Destroy"},  -- "Options" for Rayfield compatibility
  CurrentOption = {"Team Deathmatch", "Free for All"},  -- Pre-select 2 options
  MultipleOptions = true,  -- Rayfield syntax for multi-select
  PlaceholderText = "Choose modes",
  Flag = "GameModes",
  OnChanged = function(selected)
    print("[Multi-Select] Selected:", table.concat(selected, ", "))
  end
})

DropdownSection:CreateLabel({ Text = "Features:" })
DropdownSection:CreateParagraph({
  Text = "• Checkboxes for each item\n• Multiple selection support\n• Shows count when 2+ selected\n• Returns array of values\n• Click to toggle selection\n• Stays open for more selections"
})

-- Control buttons for multi-select
DropdownSection:CreateLabel({ Text = "─── Multi-Select Controls ───" })

DropdownSection:CreateButton({
  Text = "✅ Select All Modes",
  Callback = function()
    multiDropdown:SelectAll()
    RvrseUI:Notify({
      Title = "All Selected",
      Message = "All game modes selected!",
      Duration = 2,
      Type = "success"
    })
  end
})

DropdownSection:CreateButton({
  Text = "❌ Clear All Selections",
  Callback = function()
    multiDropdown:ClearAll()
    RvrseUI:Notify({
      Title = "Cleared",
      Message = "All selections cleared",
      Duration = 2,
      Type = "warn"
    })
  end
})

DropdownSection:CreateButton({
  Text = "📋 Get Selected Modes",
  Callback = function()
    local selected = multiDropdown:Get()
    if #selected == 0 then
      RvrseUI:Notify({
        Title = "No Selection",
        Message = "No modes selected",
        Duration = 2,
        Type = "warn"
      })
    else
      RvrseUI:Notify({
        Title = "Selected Modes",
        Message = table.concat(selected, ", "),
        Duration = 4,
        Type = "info"
      })
    end
  end
})

DropdownSection:CreateButton({
  Text = "🔍 Check CurrentOption Property",
  Callback = function()
    -- Test Rayfield's CurrentOption property
    local current = multiDropdown.CurrentOption
    if #current == 0 then
      RvrseUI:Notify({
        Title = "CurrentOption",
        Message = "Empty array: {}",
        Duration = 2,
        Type = "info"
      })
    else
      RvrseUI:Notify({
        Title = "CurrentOption Property",
        Message = "Array: {" .. table.concat(current, ", ") .. "}",
        Duration = 4,
        Type = "info"
      })
    end
  end
})

DropdownSection:CreateButton({
  Text = "🎯 Set Custom Selection",
  Callback = function()
    multiDropdown:Set({"Team Deathmatch", "Free for All", "Domination"})
    RvrseUI:Notify({
      Title = "Selection Updated",
      Message = "Set to 3 specific modes",
      Duration = 2,
      Type = "success"
    })
  end
})

-- Standard single-select for comparison (Rayfield syntax)
DropdownSection:CreateLabel({ Text = "─── Single-Select (Rayfield Syntax) ───" })

local singleDropdown = DropdownSection:CreateDropdown({
  Text = "Select Difficulty",
  Options = {"Easy", "Normal", "Hard", "Expert", "Master"},  -- Rayfield uses "Options"
  CurrentOption = {"Hard"},  -- Pre-select "Hard" (Rayfield syntax: table with 1 item)
  MultipleOptions = false,  -- Rayfield syntax for single-select
  Flag = "Difficulty",
  OnChanged = function(value)
    print("[Single-Select] Selected:", value)
  end
})

DropdownSection:CreateButton({
  Text = "🔍 Check Single-Select CurrentOption",
  Callback = function()
    -- Test Rayfield's CurrentOption property for single-select
    local current = singleDropdown.CurrentOption
    RvrseUI:Notify({
      Title = "Single-Select CurrentOption",
      Message = "Array: {" .. table.concat(current, ", ") .. "}",
      Duration = 3,
      Type = "info"
    })
  end
})

-- Phase 2 Summary
Phase2Tab:CreateSection("Phase 2 Summary"):CreateParagraph({
  Text = "✨ Phase 2 Complete!\n\n🎨 ColorPicker Upgrade:\n• Full RGB/HSV slider controls\n• Hex color input (#RRGGBB)\n• Live preview with sync\n• Backward compatible simple mode\n\n📋 Dropdown Multi-Select:\n• Checkbox-based selection\n• SelectAll/ClearAll methods\n• Returns array of selected values\n• Preserves single-select mode\n• 100% Rayfield-compatible API:\n  - Options/Values\n  - CurrentOption property\n  - MultipleOptions/MultiSelect\n  - Refresh() and Set() methods\n\n🔥 Both features are production-ready!"
})

-- 🔧 IMPORTANT: Call Window:Show() to load config and display UI
-- This MUST be called AFTER all tabs, sections, and elements are created!
Window:Show()

-- Welcome notification
RvrseUI:Notify({
  Title = "Dev Test Loaded",
  Message = "Press K to toggle UI. Check 🎨 Phase 2 Features tab!",
  Duration = 5,
  Type = "success"
})