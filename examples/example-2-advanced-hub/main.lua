--[[
  EXAMPLE 2: Advanced Hub with VIP Whitelist

  This example shows a hub with RVRSE Pattern 2:
  - VIP users get instant access (no key needed)
  - Regular users need a valid key
  - Override keys for special access

  Setup:
  1. Copy pattern-2-remote-key-whitelist.lua from examples/
  2. Add your VIP user IDs to the whitelist
  3. Update RemoteKeyURL to your server
  4. Paste entire file into executor
]]--

-- ============================================================================
-- PASTE PATTERN 2 (pattern-2-remote-key-whitelist.lua) HERE
-- ============================================================================

-- [Pattern 2 content would go here - see ../pattern-2-remote-key-whitelist.lua]

-- ============================================================================
-- END PATTERN 2 - YOUR GAME CODE STARTS BELOW
-- ============================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Determine if user is VIP
local function IsUserVIP()
    -- Check if user ID is in whitelist
    local VIPUserIDs = {
        -- Add your VIP user IDs here:
        -- 123456789,
        -- 987654321,
    }

    for _, vipID in ipairs(VIPUserIDs) do
        if LocalPlayer.UserId == vipID then
            return true
        end
    end
    return false
end

local function LoadHub()
    local isVIP = IsUserVIP()

    print("🚀 Hub Loaded Successfully!")
    print("User: " .. LocalPlayer.Name)
    print("VIP Status: " .. (isVIP and "✅ YES" or "❌ NO"))
    print("=" .. string.rep("=", 50))

    -- Load RvrseUI
    local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

    RvrseUI:Init({
        Title = "Premium Hub",
        Subtitle = isVIP and "VIP Access" or "Standard Access",
        Version = "2.0",
        Theme = "Dark"
    })

    -- ========== PUBLIC TAB (All Users) ==========
    local PublicTab = RvrseUI:NewTab("Public")
    PublicTab:AddLabel("Welcome to Premium Hub")
    PublicTab:AddLabel("User: " .. LocalPlayer.Name)

    if isVIP then
        PublicTab:AddLabel("Status: ✅ VIP Access Granted")
        PublicTab:AddLabel("You have unlimited access!")
    else
        PublicTab:AddLabel("Status: Standard Access")
        PublicTab:AddLabel("Some features are VIP-only")
    end

    PublicTab:AddButton("Public Feature", function()
        print("✅ Public feature accessed")
    end)

    -- ========== VIP TAB (VIP Only) ==========
    if isVIP then
        local VIPTab = RvrseUI:NewTab("VIP Features")
        VIPTab:AddLabel("Exclusive VIP Features")
        VIPTab:AddLabel("Thanks for being a VIP!")

        VIPTab:AddButton("VIP Feature 1", function()
            print("⭐ VIP Feature 1 activated")
        end)

        VIPTab:AddButton("VIP Feature 2", function()
            print("⭐ VIP Feature 2 activated")
        end)

        VIPTab:AddButton("VIP Feature 3", function()
            print("⭐ VIP Feature 3 activated")
        end)

        VIPTab:AddToggle("VIP Mode", false, function(state)
            print("VIP Mode: " .. tostring(state))
        end)
    else
        local UpgradeTab = RvrseUI:NewTab("Upgrade")
        UpgradeTab:AddLabel("Upgrade to VIP")
        UpgradeTab:AddLabel("Get exclusive features!")
        UpgradeTab:AddButton("Learn More", function()
            print("Visit discord.gg/yourserver")
        end)
    end

    -- ========== SETTINGS TAB ==========
    local SettingsTab = RvrseUI:NewTab("Settings")
    SettingsTab:AddLabel("Hub Settings")

    SettingsTab:AddToggle("Show Notifications", true, function(state)
        print("Notifications: " .. tostring(state))
    end)

    SettingsTab:AddSlider("Volume", 0, 100, 50, function(value)
        print("Volume set to: " .. value)
    end)

    SettingsTab:AddLabel("Version: 2.0")
    SettingsTab:AddLabel("Protected by RVRSE")

    print("🎉 Hub initialization complete!")
end

-- ============================================================================
-- KEY VALIDATION CALLBACKS
-- ============================================================================

function OnKeyValid(key)
    print("✅ Key validated successfully!")
    print("Loading hub...")
    LoadHub()
end

function OnWhitelistValid(userID)
    print("✅ User is whitelisted!")
    print("Loading hub...")
    LoadHub()
end

function OnKeyInvalid(reason)
    print("❌ Access denied: " .. reason)
end

-- ============================================================================
-- GAME LOGIC
-- ============================================================================

LocalPlayer.CharacterAdded:Connect(function(character)
    local isVIP = IsUserVIP()
    local status = isVIP and "VIP" or "User"
    print("📍 " .. status .. " spawned: " .. LocalPlayer.Name)
end)

print("Script loaded. Validating access...")
