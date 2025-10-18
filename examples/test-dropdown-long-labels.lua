-- Test Dropdown Adaptive Width - Long Labels
-- Tests the new adaptive width system that prevents label truncation

print("\n" .. string.rep("=", 80))
print("🧪 DROPDOWN ADAPTIVE WIDTH TEST - Long Labels")
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
    Name = "Dropdown Width Test",
    Icon = "📏",
    Theme = "Dark"
})

print("✅ Window created\n")

local Tab = Window:CreateTab({ Title = "Tests", Icon = "🧪" })
print("✅ Tab created\n")

local Section = Tab:CreateSection("Long Label Tests")
print("✅ Section created\n")

-- Add instructions
Section:CreateLabel({ Text = "🎯 TEST: Dropdown should auto-size to fit labels" })
Section:CreateLabel({ Text = "Expected: No '...' truncation on long labels" })

Section:CreateDivider()

print(string.rep("=", 80))
print("🔽 Creating Test Dropdowns...")
print(string.rep("=", 80))

-- Test 1: Single-Select with exact labels from screenshot
print("\n📋 Test 1: Single-Select (Colors)")
local dropdown1 = Section:CreateDropdown({
    Text = "Single-Select (Color)",
    Values = {"Red", "Green", "Blue", "Yellow"},
    CurrentOption = {"Red"},
    OnChanged = function(selected)
        print(string.rep("-", 80))
        print("[Test 1] Selected:", table.concat(selected, ", "))
        print(string.rep("-", 80))
    end
})
print("✅ Created: Single-Select dropdown")

Section:CreateDivider()

-- Test 2: Multi-Select with exact labels from screenshot
print("\n📋 Test 2: Multi-Select (Colors)")
local dropdown2 = Section:CreateDropdown({
    Text = "Multi-Select (Colors)",
    Values = {"Red", "Green", "Blue", "Yellow", "Purple", "Orange"},
    CurrentOption = {"Red", "Blue", "Yellow"},
    OnChanged = function(selected)
        print(string.rep("-", 80))
        print("[Test 2] Selected:", table.concat(selected, ", "))
        print(string.rep("-", 80))
    end
})
print("✅ Created: Multi-Select dropdown")

Section:CreateDivider()

-- Test 3: Long Labels (exact labels from screenshot)
print("\n📋 Test 3: Long Labels (Visual Test)")
local dropdown3 = Section:CreateDropdown({
    Text = "Long Labels (visual test)",
    Values = {
        "Ultrasonic...",  -- This should NOT show ... anymore!
        "Deep-Space...",  -- This should NOT show ... anymore!
        "Supercalifra...", -- This should NOT show ... anymore!
        "Regular Blue"
    },
    CurrentOption = {},
    OnChanged = function(selected)
        print(string.rep("-", 80))
        print("[Test 3] Selected:", table.concat(selected, ", "))
        print(string.rep("-", 80))
    end
})
print("✅ Created: Long Labels dropdown")

Section:CreateDivider()

-- Test 4: ACTUAL long labels (full text)
print("\n📋 Test 4: ACTUAL Long Labels (Full Text)")
local dropdown4 = Section:CreateDropdown({
    Text = "ACTUAL Long Labels",
    Values = {
        "Ultrasonic Cyan Hyper-Saturation v2.7.1",
        "Deep-Space Quantum Violet Nexus Edition",
        "Supercalifragilisticexpialidocious Magenta",
        "Regular Blue",
        "Short",
        "This is a moderately long label that should display fully without truncation"
    },
    CurrentOption = {},
    OnChanged = function(selected)
        print(string.rep("-", 80))
        print("[Test 4] Selected:", table.concat(selected, ", "))
        print(string.rep("-", 80))
    end
})
print("✅ Created: ACTUAL Long Labels dropdown")

print(string.rep("=", 80))
print("📺 Showing Window...")
print(string.rep("=", 80))

Window:Show()

print("✅ Window shown\n")

print(string.rep("=", 80))
print("⚠️  TESTING INSTRUCTIONS:")
print(string.rep("=", 80))
print("1. Open each dropdown")
print("2. Verify long labels are FULLY visible (no '...' truncation)")
print("3. Verify dropdown width adapts to content")
print("4. Verify min width is 200px (never too narrow)")
print("5. Verify max width is 400px (never too wide)")
print("6. Verify text is readable against dark overlay")
print(string.rep("=", 80))

print("\n✅ Test loaded! Open dropdowns to verify adaptive width.\n")
