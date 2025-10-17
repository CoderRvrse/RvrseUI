-- ✅ ColorPicker Advanced Mode Test Script
-- Tests RGB/HSV sliders, Hex input, and callbacks

local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

-- Enable debug mode
RvrseUI:EnableDebug(true)

print("=== ColorPicker Advanced Mode Test ===")
print("Testing Phase 2 Features: RGB/HSV sliders + Hex input")

local Window = RvrseUI:CreateWindow({
    Name = "ColorPicker Test Hub",
    Icon = "🎨",
    Theme = "Dark"
})

local Tab = Window:CreateTab({ Title = "Color Tests", Icon = "🌈" })
local Section = Tab:CreateSection("Advanced ColorPicker Tests")

-- Test 1: Basic Advanced ColorPicker
local testColor1 = Color3.fromRGB(255, 100, 50)
print("\n[Test 1] Creating Advanced ColorPicker with default:", testColor1)

local ColorPicker1 = Section:CreateColorPicker({
    Text = "Test 1: Default Red-Orange",
    Default = testColor1,
    Advanced = true,  -- Enable advanced mode
    Flag = "ColorTest1",
    OnChanged = function(color)
        print("[Test 1 Callback] Color changed to:", color)
        print("  RGB:",
            math.floor(color.R * 255 + 0.5),
            math.floor(color.G * 255 + 0.5),
            math.floor(color.B * 255 + 0.5)
        )
    end
})

print("[Test 1] ColorPicker created, current value:", ColorPicker1:Get())

-- Test 2: Pure RGB Colors
Section:CreateLabel({ Text = "--- Test 2: Pure RGB Colors ---" })

local ColorPicker2 = Section:CreateColorPicker({
    Text = "Test 2: Pure Red (255,0,0)",
    Default = Color3.fromRGB(255, 0, 0),
    Advanced = true,
    Flag = "ColorTest2",
    OnChanged = function(color)
        local r = math.floor(color.R * 255 + 0.5)
        local g = math.floor(color.G * 255 + 0.5)
        local b = math.floor(color.B * 255 + 0.5)
        print(string.format("[Test 2 Callback] RGB: (%d, %d, %d)", r, g, b))
    end
})

local ColorPicker3 = Section:CreateColorPicker({
    Text = "Test 3: Pure Green (0,255,0)",
    Default = Color3.fromRGB(0, 255, 0),
    Advanced = true,
    Flag = "ColorTest3"
})

local ColorPicker4 = Section:CreateColorPicker({
    Text = "Test 4: Pure Blue (0,0,255)",
    Default = Color3.fromRGB(0, 0, 255),
    Advanced = true,
    Flag = "ColorTest4"
})

-- Test 3: HSV Edge Cases
Section:CreateLabel({ Text = "--- Test 3: HSV Edge Cases ---" })

local ColorPicker5 = Section:CreateColorPicker({
    Text = "Test 5: White (255,255,255)",
    Default = Color3.fromRGB(255, 255, 255),
    Advanced = true,
    Flag = "ColorTest5",
    OnChanged = function(color)
        print("[Test 5 Callback] White/Black test:", color)
    end
})

local ColorPicker6 = Section:CreateColorPicker({
    Text = "Test 6: Black (0,0,0)",
    Default = Color3.fromRGB(0, 0, 0),
    Advanced = true,
    Flag = "ColorTest6"
})

local ColorPicker7 = Section:CreateColorPicker({
    Text = "Test 7: Gray (127,127,127)",
    Default = Color3.fromRGB(127, 127, 127),
    Advanced = true,
    Flag = "ColorTest7"
})

-- Test 4: Programmatic Color Setting
Section:CreateLabel({ Text = "--- Test 4: Programmatic Control ---" })

local targetPicker = Section:CreateColorPicker({
    Text = "Test 8: Target Picker",
    Default = Color3.fromRGB(100, 100, 100),
    Advanced = true,
    Flag = "ColorTest8",
    OnChanged = function(color)
        print("[Test 8 Callback] Programmatically set to:", color)
    end
})

Section:CreateButton({
    Text = "Set to Purple (128,0,128)",
    Callback = function()
        print("[Test 4] Setting color programmatically to Purple")
        targetPicker:Set(Color3.fromRGB(128, 0, 128))
        print("[Test 4] After Set(), value is:", targetPicker:Get())
    end
})

Section:CreateButton({
    Text = "Set to Cyan (0,255,255)",
    Callback = function()
        print("[Test 4] Setting color programmatically to Cyan")
        targetPicker:Set(Color3.fromRGB(0, 255, 255))
        print("[Test 4] After Set(), value is:", targetPicker:Get())
    end
})

Section:CreateButton({
    Text = "Set to Yellow (255,255,0)",
    Callback = function()
        print("[Test 4] Setting color programmatically to Yellow")
        targetPicker:Set(Color3.fromRGB(255, 255, 0))
        print("[Test 4] After Set(), value is:", targetPicker:Get())
    end
})

-- Test 5: Hex Input Testing
Section:CreateLabel({ Text = "--- Test 5: Hex Input ---" })
Section:CreateLabel({ Text = "Test hex input in panel:" })
Section:CreateLabel({ Text = "#FF0000 (Red)" })
Section:CreateLabel({ Text = "#00FF00 (Green)" })
Section:CreateLabel({ Text = "#0000FF (Blue)" })
Section:CreateLabel({ Text = "#FFFF00 (Yellow)" })
Section:CreateLabel({ Text = "#FF00FF (Magenta)" })
Section:CreateLabel({ Text = "#00FFFF (Cyan)" })

local hexTestPicker = Section:CreateColorPicker({
    Text = "Test 9: Hex Input Target",
    Default = Color3.fromRGB(255, 128, 0),
    Advanced = true,
    Flag = "ColorTest9",
    OnChanged = function(color)
        local hex = string.format("#%02X%02X%02X",
            math.floor(color.R * 255 + 0.5),
            math.floor(color.G * 255 + 0.5),
            math.floor(color.B * 255 + 0.5)
        )
        print("[Test 9 Callback] Hex input changed to:", hex)
    end
})

-- Test 6: Slider Range Testing
Section:CreateLabel({ Text = "--- Test 6: Slider Ranges ---" })
Section:CreateLabel({ Text = "RGB: Should show 0-255" })
Section:CreateLabel({ Text = "HSV: H=0-360, S/V=0-100" })

local sliderTestPicker = Section:CreateColorPicker({
    Text = "Test 10: Slider Range Check",
    Default = Color3.fromRGB(180, 90, 200),
    Advanced = true,
    Flag = "ColorTest10",
    OnChanged = function(color)
        print("[Test 10 Callback] Slider moved, new color:", color)
    end
})

-- Test 7: Simple Mode vs Advanced Mode
local SimpleSection = Tab:CreateSection("Simple Mode Tests")

SimpleSection:CreateLabel({ Text = "Simple mode cycles through presets" })

local simplePicker = SimpleSection:CreateColorPicker({
    Text = "Test 11: Simple Mode",
    Default = Color3.fromRGB(255, 0, 0),
    Advanced = false,  -- Simple mode
    Flag = "ColorTest11",
    OnChanged = function(color)
        print("[Test 11 Callback] Simple mode clicked:", color)
    end
})

-- Test 8: Multiple Pickers Open
Section:CreateLabel({ Text = "--- Test 8: Multiple Panels ---" })
Section:CreateLabel({ Text = "Try opening multiple pickers" })

for i = 1, 3 do
    Section:CreateColorPicker({
        Text = "Multi-Picker " .. i,
        Default = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)),
        Advanced = true,
        Flag = "MultiPicker" .. i
    })
end

-- Instructions
local InstructionsTab = Window:CreateTab({ Title = "Instructions", Icon = "📋" })
local InstructionsSection = InstructionsTab:CreateSection("How to Test")

InstructionsSection:CreateLabel({ Text = "1. Click color preview circles to open panels" })
InstructionsSection:CreateLabel({ Text = "2. Drag RGB sliders (0-255)" })
InstructionsSection:CreateLabel({ Text = "3. Drag HSV sliders (H:0-360, S/V:0-100)" })
InstructionsSection:CreateLabel({ Text = "4. Type hex codes (#RRGGBB)" })
InstructionsSection:CreateLabel({ Text = "5. Watch console for callback output" })
InstructionsSection:CreateLabel({ Text = "6. Check sliders sync with each other" })
InstructionsSection:CreateLabel({ Text = "7. Test programmatic Set() buttons" })
InstructionsSection:CreateLabel({ Text = "8. Click blocker to close panels" })

InstructionsSection:CreateDivider()

InstructionsSection:CreateLabel({ Text = "Expected Behavior:" })
InstructionsSection:CreateLabel({ Text = "✓ RGB sliders update HSV automatically" })
InstructionsSection:CreateLabel({ Text = "✓ HSV sliders update RGB automatically" })
InstructionsSection:CreateLabel({ Text = "✓ Hex input updates all sliders" })
InstructionsSection:CreateLabel({ Text = "✓ Preview circle shows current color" })
InstructionsSection:CreateLabel({ Text = "✓ OnChanged callback fires on every change" })
InstructionsSection:CreateLabel({ Text = "✓ Blocker closes panel on click" })

-- Comparison with Rayfield
local ComparisonTab = Window:CreateTab({ Title = "vs Rayfield", Icon = "⚖️" })
local ComparisonSection = ComparisonTab:CreateSection("RvrseUI vs Rayfield ColorPicker")

ComparisonSection:CreateLabel({ Text = "Rayfield Implementation:" })
ComparisonSection:CreateLabel({ Text = "• Uses 2D gradient square + hue slider" })
ComparisonSection:CreateLabel({ Text = "• RGB/Hex inputs in dropdown" })
ComparisonSection:CreateLabel({ Text = "• Manual RGB input boxes" })
ComparisonSection:CreateLabel({ Text = "• No HSV sliders" })
ComparisonSection:CreateLabel({ Text = "• Expands vertically on click" })

ComparisonSection:CreateDivider()

ComparisonSection:CreateLabel({ Text = "RvrseUI Implementation:" })
ComparisonSection:CreateLabel({ Text = "✓ Full RGB sliders (0-255)" })
ComparisonSection:CreateLabel({ Text = "✓ Full HSV sliders (H:0-360, S/V:0-100)" })
ComparisonSection:CreateLabel({ Text = "✓ Hex input box (#RRGGBB)" })
ComparisonSection:CreateLabel({ Text = "✓ Overlay panel (not inline)" })
ComparisonSection:CreateLabel({ Text = "✓ Auto-sync between RGB/HSV/Hex" })
ComparisonSection:CreateLabel({ Text = "✓ Simple mode fallback" })
ComparisonSection:CreateLabel({ Text = "✓ Blocker for easy close" })

ComparisonSection:CreateDivider()

ComparisonSection:CreateLabel({ Text = "Improvements over Rayfield:" })
ComparisonSection:CreateLabel({ Text = "⭐ More precise control (sliders)" })
ComparisonSection:CreateLabel({ Text = "⭐ Both RGB AND HSV modes" })
ComparisonSection:CreateLabel({ Text = "⭐ Better UX (overlay panel)" })
ComparisonSection:CreateLabel({ Text = "⭐ Cleaner design" })

-- Debug section
local DebugTab = Window:CreateTab({ Title = "Debug", Icon = "🐛" })
local DebugSection = DebugTab:CreateSection("Debug Information")

DebugSection:CreateLabel({ Text = "Check console for:" })
DebugSection:CreateLabel({ Text = "• Callback execution logs" })
DebugSection:CreateLabel({ Text = "• RGB value changes" })
DebugSection:CreateLabel({ Text = "• Programmatic Set() calls" })

DebugSection:CreateButton({
    Text = "Dump All ColorPicker Values",
    Callback = function()
        print("\n=== ColorPicker Values Dump ===")
        for i = 1, 10 do
            local flag = "ColorTest" .. i
            if RvrseUI.Flags[flag] then
                local color = RvrseUI.Flags[flag]:Get()
                local r = math.floor(color.R * 255 + 0.5)
                local g = math.floor(color.G * 255 + 0.5)
                local b = math.floor(color.B * 255 + 0.5)
                print(string.format("[%s] RGB: (%d, %d, %d) = %s", flag, r, g, b, color))
            end
        end
        print("=== End Dump ===\n")
    end
})

DebugSection:CreateButton({
    Text = "Test Rapid Color Changes",
    Callback = function()
        print("\n[Rapid Test] Changing colors quickly...")
        for i = 1, 5 do
            task.wait(0.2)
            local randomColor = Color3.fromRGB(
                math.random(0, 255),
                math.random(0, 255),
                math.random(0, 255)
            )
            targetPicker:Set(randomColor)
            print("[Rapid Test] Set to:", randomColor)
        end
        print("[Rapid Test] Complete!")
    end
})

Window:Show()

print("\n=== Test Script Loaded ===")
print("Instructions:")
print("1. Open ColorPicker panels by clicking preview circles")
print("2. Test RGB sliders (should be 0-255)")
print("3. Test HSV sliders (H: 0-360, S/V: 0-100)")
print("4. Test Hex input (type #FF0000, #00FF00, etc.)")
print("5. Watch console for OnChanged callbacks")
print("6. Try programmatic Set() buttons")
print("7. Report any issues with slider sync or callbacks")
