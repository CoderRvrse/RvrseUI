--[[
  EXAMPLE 3: Monitored Hub with Webhook Logging

  This example shows a Roblox hub protected with RVRSE
  that logs all activity to Discord via webhook. Perfect for
  tracking hub usage, monitoring who accessed your game, and
  building analytics dashboards.

  Setup:
  1. Copy pattern-3-remote-key-webhook.lua from examples/ to this directory
  2. Update RemoteKeyURL to point to your RVRSE server
  3. Get a Discord webhook URL (see README.md for instructions)
  4. Update DiscordWebhookURL below with your webhook
  5. Paste this entire file into your Roblox executor

  What This Does:
  - Script fetches key from your server
  - If key is valid → logs to Discord and loads hub
  - If key is invalid → logs failure to Discord and kicks player
  - All user actions (buttons, toggles) are logged to Discord
]]--

-- ============================================================================
-- PASTE PATTERN 3 (pattern-3-remote-key-webhook.lua) HERE
-- ============================================================================

-- [Pattern 3 content would go here - see ../pattern-3-remote-key-webhook.lua]

-- ============================================================================
-- END PATTERN 3 - YOUR GAME CODE STARTS BELOW
-- ============================================================================

--[[
  This code runs AFTER the key loader validates the user.
  The loader calls OnKeyValid() when validation succeeds.
]]--

-- Configuration
local DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"
local HUB_NAME = "Monitored Hub"
local HUB_VERSION = "1.0"

-- Helper function to send messages to Discord
local function SendToDiscord(title, description, color, fields)
    if not DISCORD_WEBHOOK_URL or DISCORD_WEBHOOK_URL:find("YOUR_WEBHOOK") then
        print("⚠️ Discord webhook not configured - logging disabled")
        return
    end

    -- Build webhook payload
    local payload = {
        embeds = {
            {
                title = title,
                description = description,
                color = color or 3447003, -- Default blue
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                fields = fields or {},
                footer = {
                    text = HUB_NAME .. " v" .. HUB_VERSION
                }
            }
        }
    }

    -- Convert to JSON and send
    local json = game:GetService("HttpService"):JSONEncode(payload)

    local success, err = pcall(function()
        game:HttpPost(DISCORD_WEBHOOK_URL, json, Enum.HttpContentType.ApplicationJson)
    end)

    if success then
        print("📊 [Discord] Logged: " .. title)
    else
        print("⚠️ [Discord] Failed to log: " .. tostring(err))
    end
end

-- Function called when key validation succeeds
local function OnKeyValidCallback(key)
    print("✅ Key validated successfully!")

    -- Log successful access to Discord
    SendToDiscord(
        "✅ User Access Granted",
        "User successfully authenticated with valid key",
        65280, -- Green color
        {
            {
                name = "Username",
                value = game.Players.LocalPlayer.Name,
                inline = true
            },
            {
                name = "User ID",
                value = tostring(game.Players.LocalPlayer.UserId),
                inline = true
            },
            {
                name = "Time",
                value = os.date("%Y-%m-%d %H:%M:%S"),
                inline = false
            }
        }
    )

    print("Loading hub...")
    LoadHub()
end

-- Function called when key validation fails
local function OnKeyInvalidCallback(reason)
    print("❌ Key validation failed: " .. reason)

    -- Log failed access to Discord
    SendToDiscord(
        "❌ Access Denied",
        "User failed to authenticate with valid key",
        16711680, -- Red color
        {
            {
                name = "Username",
                value = game.Players.LocalPlayer.Name,
                inline = true
            },
            {
                name = "User ID",
                value = tostring(game.Players.LocalPlayer.UserId),
                inline = true
            },
            {
                name = "Reason",
                value = reason,
                inline = false
            },
            {
                name = "Time",
                value = os.date("%Y-%m-%d %H:%M:%S"),
                inline = false
            }
        }
    )

    print("Access denied.")
end

-- Main hub loading function
local function LoadHub()
    print("🚀 Hub Loaded Successfully!")
    print("=" .. string.rep("=", 50))

    -- Load RvrseUI
    local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

    -- Initialize UI
    RvrseUI:Init({
        Title = HUB_NAME,
        Subtitle = "With Activity Logging",
        Version = HUB_VERSION,
        Theme = "Dark"
    })

    -- ================================================================
    -- MAIN TAB
    -- ================================================================
    local MainTab = RvrseUI:NewTab("Home")

    MainTab:AddLabel("Welcome to the Monitored Hub!")
    MainTab:AddLabel("All activity is logged to Discord")

    MainTab:AddButton("Test Feature", function()
        print("✅ Test button clicked!")
        SendToDiscord(
            "🎮 Button Clicked",
            "User clicked 'Test Feature' button",
            3447003, -- Blue
            {
                {
                    name = "User",
                    value = game.Players.LocalPlayer.Name,
                    inline = true
                },
                {
                    name = "Button",
                    value = "Test Feature",
                    inline = true
                }
            }
        )
    end)

    MainTab:AddToggle("Enable Logging", true, function(state)
        print("Logging toggled: " .. tostring(state))
        SendToDiscord(
            state and "✅ Logging Enabled" or "❌ Logging Disabled",
            "User changed logging preference",
            state and 65280 or 16711680,
            {
                {
                    name = "User",
                    value = game.Players.LocalPlayer.Name,
                    inline = true
                },
                {
                    name = "Setting",
                    value = "Logging Enabled: " .. tostring(state),
                    inline = true
                }
            }
        )
    end)

    MainTab:AddSlider("Volume", 0, 100, 50, function(value)
        print("Volume set to: " .. value)
        SendToDiscord(
            "🔊 Volume Changed",
            "User adjusted volume setting",
            3447003,
            {
                {
                    name = "User",
                    value = game.Players.LocalPlayer.Name,
                    inline = true
                },
                {
                    name = "Volume",
                    value = value .. "%",
                    inline = true
                }
            }
        )
    end)

    -- ================================================================
    -- STATS TAB
    -- ================================================================
    local StatsTab = RvrseUI:NewTab("Stats")

    StatsTab:AddLabel("Session Information")
    StatsTab:AddLabel("Hub Name: " .. HUB_NAME)
    StatsTab:AddLabel("Version: " .. HUB_VERSION)
    StatsTab:AddLabel("Player: " .. game.Players.LocalPlayer.Name)
    StatsTab:AddLabel("User ID: " .. game.Players.LocalPlayer.UserId)
    StatsTab:AddLabel("Join Time: " .. os.date("%Y-%m-%d %H:%M:%S"))

    StatsTab:AddButton("Copy Session Info", function()
        local sessionInfo = {
            player = game.Players.LocalPlayer.Name,
            userId = game.Players.LocalPlayer.UserId,
            joinTime = os.date("%Y-%m-%d %H:%M:%S"),
            hubVersion = HUB_VERSION
        }

        print("📋 Session Info:")
        for key, value in pairs(sessionInfo) do
            print("  " .. key .. ": " .. tostring(value))
        end

        SendToDiscord(
            "📋 Session Info Copied",
            "User viewed session information",
            3447003,
            {
                {
                    name = "User",
                    value = game.Players.LocalPlayer.Name,
                    inline = true
                },
                {
                    name = "Action",
                    value = "Copied Session Info",
                    inline = true
                }
            }
        )
    end)

    -- ================================================================
    -- ABOUT TAB
    -- ================================================================
    local AboutTab = RvrseUI:NewTab("About")

    AboutTab:AddLabel("About This Hub")
    AboutTab:AddLabel("Protected with RVRSE v2.5.0")
    AboutTab:AddLabel("Pattern 3 - Remote Key + Webhook Logging")
    AboutTab:AddLabel("")
    AboutTab:AddLabel("Features:")
    AboutTab:AddLabel("✅ Remote key validation")
    AboutTab:AddLabel("✅ Discord activity logging")
    AboutTab:AddLabel("✅ User analytics tracking")
    AboutTab:AddLabel("✅ Real-time monitoring")

    AboutTab:AddButton("Report Issue", function()
        print("📢 Opening issue reporter...")
        SendToDiscord(
            "🐛 Issue Report",
            "User opened issue reporter",
            16776960, -- Yellow
            {
                {
                    name = "User",
                    value = game.Players.LocalPlayer.Name,
                    inline = true
                },
                {
                    name = "Hub Version",
                    value = HUB_VERSION,
                    inline = true
                }
            }
        )
    end)

    print("🎉 Hub initialization complete!")

    -- Log hub startup
    SendToDiscord(
        "🚀 Hub Started",
        "Monitored hub successfully loaded and initialized",
        65280, -- Green
        {
            {
                name = "Hub",
                value = HUB_NAME,
                inline = true
            },
            {
                name = "Version",
                value = HUB_VERSION,
                inline = true
            },
            {
                name = "Active Players",
                value = tostring(#game.Players:GetPlayers()),
                inline = false
            }
        }
    )
end

-- ============================================================================
-- KEY VALIDATION CALLBACKS
-- ============================================================================

--[[
  These functions are called by the Pattern 3 loader.
  Pattern 3 calls OnKeyValid() when validation succeeds.
]]--

function OnKeyValid(key)
    OnKeyValidCallback(key)
end

function OnKeyInvalid(reason)
    OnKeyInvalidCallback(reason)
end

-- ============================================================================
-- OPTIONAL: Track player activity
-- ============================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Track character spawn
LocalPlayer.CharacterAdded:Connect(function(character)
    print("📍 Character spawned: " .. LocalPlayer.Name)

    SendToDiscord(
        "📍 Character Spawned",
        "Player character loaded",
        3447003,
        {
            {
                name = "Player",
                value = LocalPlayer.Name,
                inline = true
            },
            {
                name = "Location",
                value = "Game World",
                inline = true
            }
        }
    )
end)

-- Track character death
if LocalPlayer.Character then
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Died:Connect(function()
            print("💀 Character died")

            SendToDiscord(
                "💀 Player Died",
                "Player character was defeated",
                16711680, -- Red
                {
                    {
                        name = "Player",
                        value = LocalPlayer.Name,
                        inline = true
                    },
                    {
                        name = "Time",
                        value = os.date("%H:%M:%S"),
                        inline = true
                    }
                }
            )
        end)
    end
end

print("Script loaded. Waiting for key validation...")
