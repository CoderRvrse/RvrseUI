-- ColorPicker Visual Debug Test
-- Colors each layer differently to identify what's blocking what

local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

RvrseUI:EnableDebug(true)

print("\n" .. string.rep("=", 80))
print("🎨 ColorPicker Visual Debug Test")
print("🔴 RED = Blocker Layer")
print("🟢 GREEN = Overlay Layer")
print("🔵 BLUE = ColorPicker Panel")
print("🟡 YELLOW = Main Window")
print(string.rep("=", 80))

local Window = RvrseUI:CreateWindow({
    Name = "Visual Debug Test",
    Icon = "🎨",
    Theme = "Dark"
})

local Tab = Window:CreateTab({ Title = "ColorPicker", Icon = "🌈" })
local Section = Tab:CreateSection("Visual Debug")

Section:CreateLabel({ Text = "Click the orange circle below" })
Section:CreateLabel({ Text = "Watch for colored layers:" })
Section:CreateLabel({ Text = "🔴 RED = Blocker (should be semi-transparent)" })
Section:CreateLabel({ Text = "🟢 GREEN = Overlay Layer" })
Section:CreateLabel({ Text = "🔵 BLUE = ColorPicker Panel" })
Section:CreateLabel({ Text = "🟡 YELLOW = Main Window Border" })

local picker = Section:CreateColorPicker({
    Text = "Debug ColorPicker",
    Default = Color3.fromRGB(255, 100, 50),
    Advanced = true,
    OnChanged = function(color)
        print("[ColorPicker Changed]", color)
    end
})

Window:Show()

-- Wait for UI to load
task.wait(1)

-- Find and color code all layers
local PlayerGui = game.Players.LocalPlayer.PlayerGui

print("\n🔍 Finding and coloring layers...")

-- Color main window YELLOW
local host = PlayerGui:FindFirstChild("RvrseUI_Host")
if host then
    for _, window in ipairs(host:GetChildren()) do
        if window.Name:match("^Window_") then
            -- Add yellow border
            local yellowStroke = Instance.new("UIStroke")
            yellowStroke.Color = Color3.fromRGB(255, 255, 0)
            yellowStroke.Thickness = 4
            yellowStroke.Parent = window
            print("✅ Added YELLOW border to main window")
            break
        end
    end
end

-- Find overlay layers
local overlayGui = PlayerGui:FindFirstChild("RvrseUI_Popovers")
if not overlayGui then
    overlayGui = game.CoreGui:FindFirstChild("RvrseUI_Popovers")
end

if overlayGui then
    print("✅ Found RvrseUI_Popovers ScreenGui")
    print("   DisplayOrder:", overlayGui.DisplayOrder)

    -- Find OverlayLayer
    local overlayLayer = overlayGui:FindFirstChild("OverlayLayer")
    if overlayLayer then
        print("✅ Found OverlayLayer")

        -- Color layer GREEN (very transparent to see through)
        overlayLayer.BackgroundTransparency = 0.7
        overlayLayer.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        print("   🟢 Set OverlayLayer to GREEN (70% transparent)")

        -- Find blocker
        local blocker = overlayLayer:FindFirstChild("OverlayBlocker")
        if blocker then
            print("✅ Found OverlayBlocker")
            print("   ZIndex:", blocker.ZIndex)
            print("   Visible:", blocker.Visible)
            print("   Transparency:", blocker.BackgroundTransparency)

            -- THIS IS THE KEY: Make blocker RED so we can see it
            blocker.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            print("   🔴 Set Blocker to RED")
        else
            warn("❌ OverlayBlocker not found!")
        end

        -- Find ColorPickerPanel
        local pickerPanel = overlayLayer:FindFirstChild("ColorPickerPanel")
        if pickerPanel then
            print("✅ Found ColorPickerPanel")
            print("   ZIndex:", pickerPanel.ZIndex)
            print("   Visible:", pickerPanel.Visible)
            print("   Size:", pickerPanel.Size)

            -- Color panel BLUE
            pickerPanel.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
            pickerPanel.BackgroundTransparency = 0.3
            print("   🔵 Set ColorPickerPanel to BLUE")
        else
            warn("❌ ColorPickerPanel not found!")
        end
    else
        warn("❌ OverlayLayer not found!")
    end
else
    warn("❌ RvrseUI_Popovers not found!")
end

print("\n" .. string.rep("=", 80))
print("✅ Visual debug setup complete!")
print("\n📋 What you should see:")
print("  1. Main window has YELLOW border")
print("  2. When you click the orange circle:")
print("     🔴 RED blocker should appear (semi-transparent)")
print("     🟢 GREEN overlay layer visible")
print("     🔵 BLUE ColorPicker panel with sliders")
print("\n⚠️  If RED blocker covers everything:")
print("     → Blocker ZIndex is too high")
print("     → Blocker shouldn't be Modal/Active")
print("\n⚠️  If you can't see BLUE panel:")
print("     → Panel ZIndex needs to be higher than blocker")
print("     → Panel might be off-screen (check position)")
print(string.rep("=", 80) .. "\n")

-- Monitor blocker state
local lastBlockerVisible = false
game:GetService("RunService").Heartbeat:Connect(function()
    if overlayGui then
        local layer = overlayGui:FindFirstChild("OverlayLayer")
        if layer then
            local blocker = layer:FindFirstChild("OverlayBlocker")
            if blocker and blocker.Visible ~= lastBlockerVisible then
                lastBlockerVisible = blocker.Visible
                print(string.format(
                    "[BLOCKER] Visible: %s | ZIndex: %d | Transparency: %.2f | Modal: %s | Active: %s",
                    tostring(blocker.Visible),
                    blocker.ZIndex,
                    blocker.BackgroundTransparency,
                    tostring(blocker.Modal),
                    tostring(blocker.Active)
                ))
            end
        end
    end
end)
