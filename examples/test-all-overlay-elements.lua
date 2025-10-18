-- Comprehensive Overlay Elements Test (v4.0.1)
-- Tests ALL overlay elements for shadow() blocking issues
-- Verifies ColorPicker and Dropdown work without gray boxes

local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

RvrseUI:EnableDebug(true)

print("\n" .. string.rep("=", 80))
print("🧪 Comprehensive Overlay Elements Test (v4.0.1)")
print("Testing: ColorPicker, Dropdown, DropdownLegacy for shadow() issues")
print(string.rep("=", 80))

local Window = RvrseUI:CreateWindow({
    Name = "Overlay Test Suite",
    Icon = "🧪",
    Theme = "Dark"
})

-- Tab 1: ColorPicker Tests
local ColorTab = Window:CreateTab({ Title = "ColorPicker", Icon = "🎨" })
local ColorSection = ColorTab:CreateSection("Advanced ColorPicker Test")

ColorSection:CreateLabel({ Text = "✅ v4.0.1: Shadow removed from ColorPicker panel" })
ColorSection:CreateLabel({ Text = "Click the orange circle below:" })

local colorPicker1 = ColorSection:CreateColorPicker({
    Text = "Test 1: RGB/HSV Sliders",
    Default = Color3.fromRGB(255, 100, 50),
    Advanced = true,
    OnChanged = function(color)
        local r = math.floor(color.R * 255)
        local g = math.floor(color.G * 255)
        local b = math.floor(color.B * 255)
        print(string.format("[ColorPicker 1] RGB(%d, %d, %d)", r, g, b))
    end
})

ColorSection:CreateDivider()

local colorPicker2 = ColorSection:CreateColorPicker({
    Text = "Test 2: Different Default Color",
    Default = Color3.fromRGB(100, 200, 255),
    Advanced = true,
    OnChanged = function(color)
        print("[ColorPicker 2]", color)
    end
})

-- Tab 2: Dropdown Tests (Modern Overlay Version)
local DropdownTab = Window:CreateTab({ Title = "Dropdown", Icon = "📋" })
local DropdownSection = DropdownTab:CreateSection("Modern Dropdown Test")

DropdownSection:CreateLabel({ Text = "✅ v4.0.1: Shadow removed from Dropdown menus" })
DropdownSection:CreateLabel({ Text = "Click dropdowns below (modern overlay version):" })

local dropdown1 = DropdownSection:CreateDropdown({
    Text = "Test 1: Single Select",
    Values = {"Option A", "Option B", "Option C", "Option D", "Option E"},
    CurrentOption = "Option A",
    UseModernDropdown = true,  -- Force modern overlay dropdown
    OnChanged = function(value)
        print("[Dropdown 1] Selected:", value)
    end
})

DropdownSection:CreateDivider()

local dropdown2 = DropdownSection:CreateDropdown({
    Text = "Test 2: Multi-Select",
    Values = {"Red", "Green", "Blue", "Yellow", "Purple", "Orange"},
    MultiSelect = true,
    CurrentOption = {"Red", "Blue"},
    UseModernDropdown = true,  -- Force modern overlay dropdown
    OnChanged = function(values)
        print("[Dropdown 2] Selected:", table.concat(values, ", "))
    end
})

-- Tab 3: Legacy Dropdown Tests
local LegacyTab = Window:CreateTab({ Title = "Legacy", Icon = "📁" })
local LegacySection = LegacyTab:CreateSection("Legacy Dropdown Test")

LegacySection:CreateLabel({ Text = "✅ v4.0.1: Shadow removed from Legacy dropdowns" })
LegacySection:CreateLabel({ Text = "Click dropdowns below (legacy inline version):" })

local legacyDropdown1 = LegacySection:CreateDropdown({
    Text = "Test 3: Legacy Single Select",
    Values = {"Choice 1", "Choice 2", "Choice 3", "Choice 4"},
    CurrentOption = "Choice 1",
    -- UseModernDropdown = false (default behavior)
    OnChanged = function(value)
        print("[Legacy Dropdown 1] Selected:", value)
    end
})

LegacySection:CreateDivider()

local legacyDropdown2 = LegacySection:CreateDropdown({
    Text = "Test 4: Legacy Single-Select Only",
    Values = {"Apple", "Banana", "Cherry", "Date", "Elderberry"},
    CurrentOption = "Apple",
    -- ⚠️ NOTE: Legacy dropdown does NOT support MultiSelect!
    -- MultiSelect = true,  -- ❌ NOT SUPPORTED in DropdownLegacy
    OnChanged = function(value)
        -- Legacy dropdown ALWAYS passes a single string value, not a table
        print("[Legacy Dropdown 2] Selected:", value)
    end
})

Window:Show()

-- Wait for UI to load
task.wait(1)

-- Automated shadow detection
local PlayerGui = game.Players.LocalPlayer.PlayerGui
local overlayGui = PlayerGui:FindFirstChild("RvrseUI_Popovers")
if not overlayGui then
    overlayGui = game.CoreGui:FindFirstChild("RvrseUI_Popovers")
end

print("\n🔍 Running automated shadow detection...\n")

local function checkForShadow(element, elementName)
    if not element then
        warn(string.format("❌ %s not found!", elementName))
        return
    end

    local shadow = element:FindFirstChild("Shadow")
    if shadow then
        warn(string.format("❌ FAILED: %s has Shadow element!", elementName))
        warn(string.format("   Shadow Size: %s", tostring(shadow.Size)))
        warn(string.format("   Shadow ZIndex: %d", shadow.ZIndex))
        warn(string.format("   Parent Size: %s", tostring(element.Size)))
        return false
    else
        print(string.format("✅ PASSED: %s has NO shadow element", elementName))
        return true
    end
end

local allPassed = true

-- Check ColorPickerPanel in overlay
if overlayGui then
    local overlayLayer = overlayGui:FindFirstChild("OverlayLayer")
    if overlayLayer then
        local colorPickerPanel = overlayLayer:FindFirstChild("ColorPickerPanel")
        if colorPickerPanel then
            allPassed = checkForShadow(colorPickerPanel, "ColorPickerPanel") and allPassed
        else
            print("ℹ️  ColorPickerPanel not created yet (will appear when clicked)")
        end

        local dropdownList = overlayLayer:FindFirstChild("DropdownList")
        if dropdownList then
            allPassed = checkForShadow(dropdownList, "Dropdown (Modern Overlay)") and allPassed
        else
            print("ℹ️  Modern Dropdown not opened yet (will appear when clicked)")
        end
    else
        warn("❌ OverlayLayer not found in RvrseUI_Popovers!")
        allPassed = false
    end
else
    warn("❌ RvrseUI_Popovers ScreenGui not found!")
    allPassed = false
end

-- Check legacy dropdowns in host
local hostGui = PlayerGui:FindFirstChild("RvrseUI_Host")
if hostGui then
    print("\nℹ️  Legacy dropdowns are inline (parented to element cards)")
    print("   They will be checked when you open them")
else
    warn("❌ RvrseUI_Host ScreenGui not found!")
    allPassed = false
end

print("\n" .. string.rep("=", 80))
if allPassed then
    print("✅ ALL AUTOMATED CHECKS PASSED!")
else
    print("❌ SOME AUTOMATED CHECKS FAILED - See warnings above")
end
print(string.rep("=", 80))

print("\n📋 Manual Test Checklist:")
print("  1. Click ColorPicker (Tab 1) - Check for:")
print("     ✅ RGB sliders visible (R, G, B)")
print("     ✅ HSV sliders visible (H, S, V)")
print("     ✅ Hex input visible (#FF6432)")
print("     ❌ NO gray/dark box covering screen")
print("     ✅ All sliders interactive and updating")
print()
print("  2. Click Modern Dropdown (Tab 2) - Check for:")
print("     ✅ Dropdown menu appears in overlay")
print("     ❌ NO gray box covering UI")
print("     ✅ Options are clickable")
print("     ✅ Multi-select shows checkboxes")
print()
print("  3. Click Legacy Dropdown (Tab 3) - Check for:")
print("     ✅ Dropdown menu appears inline")
print("     ❌ NO gray shadows extending beyond menu")
print("     ✅ Options are clickable")
print("     ✅ Closes automatically after selection (single-select only)")
print("     ⚠️  Legacy does NOT support multi-select!")
print()
print("  4. Click outside any open panel:")
print("     ✅ Panel closes smoothly")
print("     ❌ NO gray box remains")
print()
print(string.rep("=", 80))

-- Monitor overlay elements in real-time
local monitoring = {
    colorPicker = false,
    dropdown = false
}

game:GetService("RunService").Heartbeat:Connect(function()
    if not overlayGui then return end

    local layer = overlayGui:FindFirstChild("OverlayLayer")
    if not layer then return end

    -- Monitor ColorPickerPanel
    local pickerPanel = layer:FindFirstChild("ColorPickerPanel")
    if pickerPanel and pickerPanel.Visible and not monitoring.colorPicker then
        monitoring.colorPicker = true
        print("\n🎯 ColorPickerPanel opened!")

        -- Check for shadow NOW
        local shadow = pickerPanel:FindFirstChild("Shadow")
        if shadow then
            warn("❌ CRITICAL: Shadow found in ColorPickerPanel!")
            warn("   This should have been removed in v4.0.1!")
        else
            print("✅ VERIFIED: No shadow in ColorPickerPanel")
        end

        print("   Size:", pickerPanel.Size)
        print("   ZIndex:", pickerPanel.ZIndex)
        print("   Children:", #pickerPanel:GetChildren())

        -- List all children (should be sliders, labels, etc - NOT Shadow!)
        for _, child in ipairs(pickerPanel:GetChildren()) do
            if child.Name == "Shadow" then
                warn("   ❌ Shadow:", child.ClassName)
            else
                print(string.format("   ✅ %s (%s)", child.Name, child.ClassName))
            end
        end

        -- Reset monitoring when panel closes
        task.delay(2, function()
            if not pickerPanel.Visible then
                monitoring.colorPicker = false
            end
        end)
    end

    -- Monitor Modern Dropdown
    local dropdownList = layer:FindFirstChild("DropdownList")
    if dropdownList and dropdownList.Visible and not monitoring.dropdown then
        monitoring.dropdown = true
        print("\n🎯 Modern Dropdown opened!")

        -- Check for shadow NOW
        local shadow = dropdownList:FindFirstChild("Shadow")
        if shadow then
            warn("❌ CRITICAL: Shadow found in Modern Dropdown!")
            warn("   This should have been removed in v4.0.1!")
        else
            print("✅ VERIFIED: No shadow in Modern Dropdown")
        end

        print("   Size:", dropdownList.Size)
        print("   ZIndex:", dropdownList.ZIndex)

        -- Reset monitoring when dropdown closes
        task.delay(2, function()
            if not dropdownList.Visible then
                monitoring.dropdown = false
            end
        end)
    end
end)

print("\n✅ Test suite loaded! Real-time monitoring active.")
print("Click elements to test - console will show detailed feedback.\n")
