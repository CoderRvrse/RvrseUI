-- ColorPicker Shadow Fix Verification Test
-- Tests that the shadow element no longer blocks the ColorPicker panel

local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

RvrseUI:EnableDebug(true)

print("\n" .. string.rep("=", 80))
print("🎨 ColorPicker Shadow Fix Verification Test (v4.0.1)")
print(string.rep("=", 80))

local Window = RvrseUI:CreateWindow({
    Name = "Shadow Fix Test",
    Icon = "🔧",
    Theme = "Dark"
})

local Tab = Window:CreateTab({ Title = "ColorPicker", Icon = "🌈" })
local Section = Tab:CreateSection("Shadow Fix Verification")

Section:CreateLabel({ Text = "✅ Shadow element has been removed!" })
Section:CreateLabel({ Text = "Click the orange circle below to test:" })
Section:CreateLabel({ Text = "• You should see RGB/HSV sliders" })
Section:CreateLabel({ Text = "• NO gray box should appear" })
Section:CreateLabel({ Text = "• Sliders should be fully interactive" })

local testColor = Color3.fromRGB(255, 100, 50)

local picker = Section:CreateColorPicker({
    Text = "Test ColorPicker (Advanced Mode)",
    Default = testColor,
    Advanced = true,  -- RGB/HSV sliders + Hex input
    OnChanged = function(color)
        local r = math.floor(color.R * 255)
        local g = math.floor(color.G * 255)
        local b = math.floor(color.B * 255)
        print(string.format("[ColorPicker Changed] RGB(%d, %d, %d)", r, g, b))
    end
})

Window:Show()

-- Wait for UI to load
task.wait(1)

-- Verify no shadow element exists in ColorPickerPanel
local PlayerGui = game.Players.LocalPlayer.PlayerGui
local overlayGui = PlayerGui:FindFirstChild("RvrseUI_Popovers")
if not overlayGui then
    overlayGui = game.CoreGui:FindFirstChild("RvrseUI_Popovers")
end

if overlayGui then
    print("\n🔍 Checking for shadow element in ColorPickerPanel...")
    local overlayLayer = overlayGui:FindFirstChild("OverlayLayer")
    if overlayLayer then
        local panel = overlayLayer:FindFirstChild("ColorPickerPanel")
        if panel then
            local shadow = panel:FindFirstChild("Shadow")
            if shadow then
                warn("❌ FAILED: Shadow element still exists!")
                warn("   Shadow Name:", shadow.Name)
                warn("   Shadow ClassName:", shadow.ClassName)
                warn("   Shadow Size:", shadow.Size)
                warn("   Shadow ZIndex:", shadow.ZIndex)
                warn("   This should have been removed in the fix!")
            else
                print("✅ PASSED: No shadow element found in ColorPickerPanel")
                print("   Panel is clean - only sliders and controls inside")
            end

            -- List all children for verification
            print("\n📋 ColorPickerPanel children:")
            for _, child in ipairs(panel:GetChildren()) do
                print(string.format("   - %s (%s)", child.Name, child.ClassName))
            end
        else
            warn("⚠️ ColorPickerPanel not found (may not be created until first click)")
        end
    else
        warn("❌ OverlayLayer not found!")
    end
else
    warn("❌ RvrseUI_Popovers ScreenGui not found!")
end

print("\n" .. string.rep("=", 80))
print("✅ Test loaded successfully!")
print("\n📋 What to test:")
print("  1. Click the orange circle to open the ColorPicker")
print("  2. Verify you see:")
print("     ✅ RGB sliders (R, G, B)")
print("     ✅ HSV sliders (H, S, V)")
print("     ✅ Hex input field (#FF6432)")
print("     ✅ NO gray/dark box covering the screen")
print("  3. Try dragging the sliders:")
print("     ✅ All 6 sliders should update in sync")
print("     ✅ Hex input should update live")
print("     ✅ Console should log color changes")
print("  4. Click outside the panel (on the dimmed area):")
print("     ✅ Panel should close smoothly")
print("     ✅ No gray box should remain")
print(string.rep("=", 80) .. "\n")

-- Monitor panel visibility
local monitoringStarted = false
game:GetService("RunService").Heartbeat:Connect(function()
    if overlayGui and not monitoringStarted then
        local layer = overlayGui:FindFirstChild("OverlayLayer")
        if layer then
            local panel = layer:FindFirstChild("ColorPickerPanel")
            if panel and panel.Visible then
                monitoringStarted = true
                print("\n🎯 ColorPickerPanel opened!")
                print("   Size:", panel.Size)
                print("   Position:", panel.Position)
                print("   ZIndex:", panel.ZIndex)
                print("   BackgroundColor3:", panel.BackgroundColor3)
                print("   BackgroundTransparency:", panel.BackgroundTransparency)

                -- Check for shadow one more time now that panel is visible
                local shadow = panel:FindFirstChild("Shadow")
                if shadow then
                    warn("\n❌ CRITICAL: Shadow element appeared after panel opened!")
                else
                    print("\n✅ VERIFIED: No shadow element even after panel opened")
                end

                -- Wait a bit then reset monitoring
                task.delay(2, function()
                    if not panel.Visible then
                        monitoringStarted = false
                    end
                end)
            end
        end
    end
end)
