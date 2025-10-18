-- Test Dropdown Layout Fix - Long Labels
-- Tests the new column layout with icon + text separation

print("\n" .. string.rep("=", 80))
print("🧪 DROPDOWN LAYOUT FIX TEST - Long Labels")
print(string.rep("=", 80))

-- Load RvrseUI
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

print("\n📦 Version:", RvrseUI.Version.Full)
print("🔧 Testing new column layout system\n")

-- Create window
local Window = RvrseUI:CreateWindow({
    Name = "Dropdown Layout Test",
    Icon = "📋",
    Theme = "Dark"
})

local Tab = Window:CreateTab({ Title = "Test", Icon = "🧪" })
local Section = Tab:CreateSection("Long Label Tests")

-- Test labels (acceptance criteria)
local testLabels = {
    "Red",
    "Green",
    "Blue",
    "Ultrasonic Cyan Hyper-Saturation v2.7.1",
    "Yellow (Wide-Glyph—ＭＷ)",
    "Supercalifragilisticexpialidocious",
    "Short",
    "This is a moderately long label that should truncate nicely",
    "🎨 Emoji Label Test",
    "UPPERCASE LONG TEXT SHOULD ALSO WORK CORRECTLY"
}

Section:CreateLabel({ Text = "🎯 MODE A: Single-Line + Ellipsis" })
Section:CreateLabel({ Text = "Long labels should truncate with ..." })

Section:CreateDivider()

-- Test 1: Single-line mode (default)
local dropdown1 = Section:CreateDropdown({
    Text = "Single-Line Mode",
    Values = testLabels,
    MultiSelect = true,
    CurrentOption = {"Red", "Blue"},
    TruncationMode = "singleLine",  -- DEFAULT: ellipsis
    OnChanged = function(selected)
        print("[Single-Line] Selected:", table.concat(selected, ", "))
    end
})

Section:CreateDivider()
Section:CreateLabel({ Text = "🎯 MODE B: Two-Line Wrap + Ellipsis" })
Section:CreateLabel({ Text = "Long labels can wrap to 2 lines" })

Section:CreateDivider()

-- Test 2: Two-line mode
local dropdown2 = Section:CreateDropdown({
    Text = "Two-Line Mode",
    Values = testLabels,
    MultiSelect = true,
    CurrentOption = {"Green"},
    TruncationMode = "twoLine",  -- Wrap up to 2 lines
    OnChanged = function(selected)
        print("[Two-Line] Selected:", table.concat(selected, ", "))
    end
})

Section:CreateDivider()
Section:CreateLabel({ Text = "🎯 Single-Select Test" })
Section:CreateLabel({ Text = "No checkbox, centered text" })

Section:CreateDivider()

-- Test 3: Single-select (no checkbox)
local dropdown3 = Section:CreateDropdown({
    Text = "Single-Select Mode",
    Values = testLabels,
    MultiSelect = false,
    CurrentOption = {"Red"},
    OnChanged = function(value)
        print("[Single-Select] Selected:", value)
    end
})

Window:Show()

print("\n" .. string.rep("=", 80))
print("✅ TEST LOADED - Check these:")
print(string.rep("=", 80))
print("1. Icon column is aligned (32px fixed width)")
print("2. No text overlaps checkboxes")
print("3. Long labels truncate with ellipsis (Mode A)")
print("4. Long labels wrap to 2 lines max (Mode B)")
print("5. Row heights are consistent per mode")
print("6. Hover/selection doesn't shift layout")
print("7. Toggle checkbox doesn't change text position")
print(string.rep("=", 80))

-- Diagnostic info
task.wait(2)

print("\n" .. string.rep("=", 80))
print("🔍 DIAGNOSTIC INFO:")
print(string.rep("=", 80))

-- Check GUI structure
local PlayerGui = game.Players.LocalPlayer.PlayerGui
local overlayGui = PlayerGui:FindFirstChild("RvrseUI_Popovers")

if overlayGui then
    local overlay = overlayGui:FindFirstChild("OverlayLayer")
    if overlay then
        print("✅ Overlay layer found")

        -- Check for dropdown lists when they open
        local function checkDropdown(dropdownList)
            if dropdownList then
                print("\n📋 Dropdown Structure:")
                for _, optionBtn in ipairs(dropdownList:GetChildren()) do
                    if optionBtn:IsA("TextButton") and optionBtn.Name:match("Option_") then
                        local iconCol = optionBtn:FindFirstChild("IconColumn")
                        local textCol = optionBtn:FindFirstChild("TextColumn")
                        local textLabel = optionBtn:FindFirstChild("TextLabel", true)

                        print(string.format("  %s:", optionBtn.Name))
                        print(string.format("    Size: %s", tostring(optionBtn.Size)))

                        if iconCol then
                            print(string.format("    Icon Column: %dpx", iconCol.Size.X.Offset))
                        end

                        if textCol then
                            print(string.format("    Text Column: Size=%s, Pos=%s",
                                tostring(textCol.Size), tostring(textCol.Position)))
                        end

                        if textLabel then
                            print(string.format("    Text: '%s'", textLabel.Text:sub(1, 30)))
                            print(string.format("    Truncate: %s, Wrapped: %s",
                                tostring(textLabel.TextTruncate), tostring(textLabel.TextWrapped)))
                            print(string.format("    TextBounds: %s", tostring(textLabel.TextBounds)))
                        end
                    end
                end
            end
        end

        -- Monitor for dropdown opens
        overlay.ChildAdded:Connect(function(child)
            if child.Name == "DropdownList" then
                task.wait(0.1)  -- Wait for options to render
                checkDropdown(child)
            end
        end)

        print("\n⏰ Monitoring for dropdown opens...")
        print("Open any dropdown to see diagnostic info")
    end
end

print("\n✅ Test ready! Open dropdowns and check layout.\n")
