-- Simple Dropdown Test - Focused on Multi-Select Blocker Issue
-- Tests ONLY the dropdown element to isolate the bug

print("\n" .. string.rep("=", 80))
print("🧪 SIMPLE DROPDOWN TEST - Multi-Select Blocker Debug")
print(string.rep("=", 80))

-- Load RvrseUI with cache-busting
local timestamp = os.time()
print("⏰ Loading RvrseUI with timestamp:", timestamp)
local url = string.format("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua?t=%d", timestamp)
local RvrseUI = loadstring(game:HttpGet(url))()

-- Verify version
print("\n📦 Version Info:")
print("  Version:", RvrseUI.Version.Full)
print("  Build:", RvrseUI.Version.Build)
print("  Hash:", RvrseUI.Version.Hash)

-- Enable debug mode
RvrseUI:EnableDebug(true)
print("  Debug: ENABLED\n")

print(string.rep("=", 80))
print("🪟 Creating Window...")
print(string.rep("=", 80))

-- Create simple window
local Window = RvrseUI:CreateWindow({
    Name = "Dropdown Test",
    Icon = "📋",
    Theme = "Dark"
})

print("✅ Window created\n")

print(string.rep("=", 80))
print("📑 Creating Tab...")
print(string.rep("=", 80))

local Tab = Window:CreateTab({ Title = "Test", Icon = "🧪" })
print("✅ Tab created\n")

print(string.rep("=", 80))
print("📦 Creating Section...")
print(string.rep("=", 80))

local Section = Tab:CreateSection("Dropdown Tests")
print("✅ Section created\n")

-- Add instructions
Section:CreateLabel({ Text = "🎯 INSTRUCTIONS:" })
Section:CreateLabel({ Text = "1. Click the dropdown below" })
Section:CreateLabel({ Text = "2. Select MULTIPLE options" })
Section:CreateLabel({ Text = "3. Click OUTSIDE the dropdown (on dimmed area)" })
Section:CreateLabel({ Text = "4. Watch console for errors" })

Section:CreateDivider()

print(string.rep("=", 80))
print("🔽 Creating Modern Dropdown (Multi-Select)...")
print(string.rep("=", 80))

-- Modern Dropdown with Multi-Select
local dropdown = Section:CreateDropdown({
    Text = "Test: Multi-Select Colors",
    Values = {"Red", "Green", "Blue", "Yellow", "Purple", "Orange"},
    MultiSelect = true,
    CurrentOption = {"Red", "Blue"},
    UseModernDropdown = true,  -- Force modern overlay dropdown
    OnChanged = function(values)
        print(string.rep("-", 80))
        print("[OnChanged] Callback triggered!")
        print("[OnChanged] Type:", type(values))

        if type(values) == "table" then
            print("[OnChanged] Count:", #values)
            print("[OnChanged] Selected:", table.concat(values, ", "))
        else
            warn("[OnChanged] ⚠️ Expected table, got:", type(values))
            print("[OnChanged] Value:", tostring(values))
        end
        print(string.rep("-", 80))
    end
})

print("✅ Dropdown created")
print("  Text: Test: Multi-Select Colors")
print("  Multi-Select: true")
print("  Values: Red, Green, Blue, Yellow, Purple, Orange")
print("  Default: Red, Blue\n")

print(string.rep("=", 80))
print("📺 Showing Window...")
print(string.rep("=", 80))

Window:Show()

print("✅ Window shown\n")

-- Wait for UI to load
task.wait(1)

print(string.rep("=", 80))
print("🔍 CHECKING DROPDOWN IMPLEMENTATION...")
print(string.rep("=", 80))

-- Find and verify dropdown in compiled code
local PlayerGui = game.Players.LocalPlayer.PlayerGui
local overlayGui = PlayerGui:FindFirstChild("RvrseUI_Popovers")
if not overlayGui then
    overlayGui = game.CoreGui:FindFirstChild("RvrseUI_Popovers")
end

if overlayGui then
    print("✅ Found RvrseUI_Popovers")
    print("  DisplayOrder:", overlayGui.DisplayOrder)

    local overlayLayer = overlayGui:FindFirstChild("OverlayLayer")
    if overlayLayer then
        print("✅ Found OverlayLayer")
        print("  Visible:", overlayLayer.Visible)
        print("  ZIndex:", overlayLayer.ZIndex)

        -- Check for blocker
        local blocker = overlayLayer:FindFirstChild("OverlayBlocker")
        if blocker then
            print("✅ Found OverlayBlocker (from Overlay service)")
            print("  Visible:", blocker.Visible)
            print("  ZIndex:", blocker.ZIndex)
            print("  Transparency:", blocker.BackgroundTransparency)
        else
            print("⚠️  OverlayBlocker not found (will be created on dropdown open)")
        end

        -- Check for dropdown list
        local dropdownList = overlayLayer:FindFirstChild("DropdownList")
        if dropdownList then
            print("✅ Found DropdownList (already opened)")
        else
            print("ℹ️  DropdownList not found (will be created on dropdown open)")
        end
    else
        warn("❌ OverlayLayer not found!")
    end
else
    warn("❌ RvrseUI_Popovers not found!")
end

print("\n" .. string.rep("=", 80))
print("⚠️  CRITICAL TEST POINT:")
print(string.rep("=", 80))
print("1. Click the dropdown")
print("2. Select multiple colors")
print("3. Click OUTSIDE the dropdown (on the dark background)")
print("4. If you see ':3853: attempt to call a nil value' → Bug still exists!")
print("5. If dropdown closes smoothly → Bug is FIXED!")
print(string.rep("=", 80))

-- Monitor dropdown state changes
local monitoring = false
local dropdownOpen = false

game:GetService("RunService").Heartbeat:Connect(function()
    if not overlayGui then return end

    local layer = overlayGui:FindFirstChild("OverlayLayer")
    if not layer then return end

    local dropdownList = layer:FindFirstChild("DropdownList")
    if dropdownList then
        local nowOpen = dropdownList.Visible

        if nowOpen and not dropdownOpen then
            -- Dropdown just opened
            dropdownOpen = true
            monitoring = true

            print("\n" .. string.rep("=", 80))
            print("🟢 DROPDOWN OPENED!")
            print(string.rep("=", 80))
            print("  DropdownList.Visible:", dropdownList.Visible)
            print("  DropdownList.Size:", dropdownList.Size)
            print("  DropdownList.Position:", dropdownList.Position)
            print("  DropdownList.ZIndex:", dropdownList.ZIndex)
            print("  DropdownList.Parent:", dropdownList.Parent.Name)

            -- Check blocker
            local blocker = layer:FindFirstChild("OverlayBlocker")
            if blocker then
                print("\n  OverlayBlocker:")
                print("    Visible:", blocker.Visible)
                print("    ZIndex:", blocker.ZIndex)
                print("    Transparency:", blocker.BackgroundTransparency)
                print("    Modal:", blocker.Modal)
                print("    Active:", blocker.Active)

                -- Check if blocker has click connection
                print("\n  ⚠️  NOW: Click OUTSIDE the dropdown to test blocker close!")
            else
                warn("  ❌ No blocker found!")
            end
            print(string.rep("=", 80))

        elseif not nowOpen and dropdownOpen then
            -- Dropdown just closed
            dropdownOpen = false

            print("\n" .. string.rep("=", 80))
            print("🔴 DROPDOWN CLOSED!")
            print(string.rep("=", 80))
            print("  ✅ NO ERROR - Dropdown closed successfully!")
            print("  DropdownList.Visible:", dropdownList.Visible)
            print(string.rep("=", 80) .. "\n")

            -- Reset monitoring after a delay
            task.delay(1, function()
                monitoring = false
            end)
        end
    end
end)

print("\n✅ Test loaded! Monitoring active.")
print("Console will show detailed logs when dropdown opens/closes.\n")

-- Add error handler
local errorConnection
errorConnection = game:GetService("ScriptContext").Error:Connect(function(message, stacktrace, script)
    if message:match("attempt to call") or message:match("3853") then
        print("\n" .. string.rep("=", 80))
        print("💥 ERROR CAUGHT!")
        print(string.rep("=", 80))
        warn("Message:", message)
        warn("Stack:", stacktrace)
        warn("Script:", script.Name)
        print(string.rep("=", 80))
        print("🐛 BUG CONFIRMED: setOpen is still nil when blocker clicked!")
        print(string.rep("=", 80) .. "\n")
    end
end)

print("🛡️  Error handler installed - will catch any 'attempt to call' errors\n")
