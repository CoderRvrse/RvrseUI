--[[
  EXAMPLE 1: Simple Hub with Remote Key Loader

  This example shows a basic Roblox hub protected with RVRSE
  remote key loading. No advanced features - just clean, simple
  key validation and game loading.

  Setup:
  1. Copy pattern-1-remote-key-only.lua from examples/ to this directory
  2. Update RemoteKeyURL to point to your RVRSE server
  3. Paste this entire file into your Roblox executor

  Expected behavior:
  - Script fetches key from your server
  - If key is valid → hub loads
  - If key is invalid → player gets kicked
]]--

-- ============================================================================
-- PASTE PATTERN 1 (pattern-1-remote-key-only.lua) HERE
-- ============================================================================

-- [Pattern 1 content would go here - see ../pattern-1-remote-key-only.lua]

-- ============================================================================
-- END PATTERN 1 - YOUR GAME CODE STARTS BELOW
-- ============================================================================

--[[
  This code runs AFTER the key loader validates the user.
  The loader calls OnKeyValid() when validation succeeds.
]]--

local function LoadHub()
    -- Print startup message
    print("🚀 Hub Loaded Successfully!")
    print("=" .. string.rep("=", 50))

    -- Load RvrseUI (or your preferred UI library)
    local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

    -- Initialize UI
    RvrseUI:Init({
        Title = "My Awesome Hub",
        Subtitle = "Example 1 - Simple Setup",
        Version = "1.0",
        Theme = "Dark"
    })

    -- Create a tab
    local MainTab = RvrseUI:NewTab("Home")

    -- Add a label
    MainTab:AddLabel("Welcome to the Hub!")
    MainTab:AddLabel("This hub is protected by RVRSE")

    -- Add buttons
    MainTab:AddButton("Test Button", function()
        print("✅ Button clicked!")
    end)

    MainTab:AddToggle("Enable Feature", false, function(state)
        print("Feature toggled: " .. tostring(state))
    end)

    MainTab:AddSlider("Slider", 0, 100, 50, function(value)
        print("Slider value: " .. value)
    end)

    -- Add more tabs as needed
    local AboutTab = RvrseUI:NewTab("About")
    AboutTab:AddLabel("About This Hub")
    AboutTab:AddLabel("Protected with RVRSE v2.5.0")
    AboutTab:AddLabel("Simple Pattern 1 - Remote Key Only")

    print("🎉 Hub initialization complete!")
end

-- ============================================================================
-- KEY VALIDATION CALLBACKS
-- ============================================================================

--[[
  These functions are called by the Pattern 1 loader.
  Pattern 1 calls OnKeyValid() when validation succeeds.
]]--

function OnKeyValid(key)
    print("✅ Key validated successfully!")
    print("Loading hub...")
    LoadHub()
end

function OnKeyInvalid(reason)
    print("❌ Key validation failed: " .. reason)
    print("Access denied.")
end

-- ============================================================================
-- OPTIONAL: Game Logic
-- ============================================================================

-- Add any other game logic here
-- This will run after the hub is loaded

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Example: Track player activity
LocalPlayer.CharacterAdded:Connect(function(character)
    print("📍 Character spawned: " .. LocalPlayer.Name)
end)

print("Script loaded. Waiting for key validation...")
