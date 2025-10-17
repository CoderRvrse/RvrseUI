-- Simple ColorPicker Debug Test
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

RvrseUI:EnableDebug(true)

print("=== Simple ColorPicker Test ===")

local Window = RvrseUI:CreateWindow({
    Name = "ColorPicker Debug",
    Icon = "🎨",
    Theme = "Dark"
})

local Tab = Window:CreateTab({ Title = "Test", Icon = "🔧" })
local Section = Tab:CreateSection("ColorPicker Test")

Section:CreateLabel({ Text = "Click the orange circle below:" })

local picker = Section:CreateColorPicker({
    Text = "Test ColorPicker",
    Default = Color3.fromRGB(255, 100, 50),
    Advanced = true,
    OnChanged = function(color)
        print("[ColorPicker] Changed to:", color)
        print("  RGB:",
            math.floor(color.R * 255 + 0.5),
            math.floor(color.G * 255 + 0.5),
            math.floor(color.B * 255 + 0.5)
        )
    end
})

Section:CreateDivider()
Section:CreateLabel({ Text = "Debug Info:" })
Section:CreateLabel({ Text = "1. Click orange circle" })
Section:CreateLabel({ Text = "2. Panel should open with sliders" })
Section:CreateLabel({ Text = "3. Check console for errors" })

Section:CreateButton({
    Text = "Check Panel State",
    Callback = function()
        print("\n=== Panel Debug Info ===")
        print("Picker exists:", picker ~= nil)
        print("Current color:", picker:Get())
    end
})

Window:Show()

print("Test loaded! Click the orange circle.")
