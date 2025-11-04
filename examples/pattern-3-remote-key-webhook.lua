-- ============================================================================
-- RVRSE PATTERN 3: Remote Key + Webhook (Logging)
-- ============================================================================
--
-- This pattern adds webhook logging to track key validation events.
-- Perfect for: Analytics, monitoring, abuse detection, user tracking
--
-- What it does:
--   1. Fetches key from remote server
--   2. Validates key
--   3. Sends detailed event logs to your webhook
--   4. Tracks user activity and validation patterns
--
-- Use Cases:
--   - Monitor who's using your hub and when
--   - Detect suspicious validation patterns
--   - Track geographic distribution (via IP)
--   - Generate usage analytics
--   - Alert on failed validation attempts
--   - Measure engagement metrics
--
-- Setup Instructions:
--   1. Create webhook (Discord, Slack, or custom endpoint)
--   2. Update WebhookURL below with your endpoint
--   3. Update RemoteKeyURL with your Heroku endpoint
--   4. Paste at top of your hub script
--
-- ============================================================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Config = {
    -- Remote server settings
    GrabKeyFromSite = true,
    RemoteKeyURL = "https://rvrse-keys-prod.herokuapp.com/keys/raw/mygame:hub",

    -- Webhook settings (REQUIRED for this pattern)
    WebhookURL = "https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN",
    WebhookEnabled = true,

    -- What to log
    Logging = {
        KeyValid = true,       -- Log successful validations
        KeyInvalid = true,     -- Log failed validations
        KeyAttempts = true,    -- Log retry attempts
        UserDetails = true,    -- Log user info (ID, username, account age)
        DeviceInfo = true,     -- Log device type
        Timestamps = true,     -- Include timestamps
    },

    -- Local storage
    SaveKey = false,  -- Recommended: false (force server validation every time for better logs)

    -- Validation settings
    MaxAttempts = 3,
    KickOnFailure = true,
}

-- ============================================================================
-- WEBHOOK LOGGING
-- ============================================================================

local function GetDeviceType()
    local UserInputService = game:GetService("UserInputService")

    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        return "Mobile"
    elseif UserInputService.GamepadEnabled then
        return "Console"
    else
        return "PC"
    end
end

local function GetUserDetails()
    if not Config.Logging.UserDetails then
        return {}
    end

    return {
        userId = LocalPlayer.UserId,
        username = LocalPlayer.Name,
        displayName = LocalPlayer.DisplayName,
        accountAge = LocalPlayer.AccountAge,
        membershipType = tostring(LocalPlayer.MembershipType),
    }
end

local function SendWebhook(eventType, data)
    if not Config.WebhookEnabled or not Config.WebhookURL then
        return
    end

    -- Build webhook payload
    local payload = {
        event = eventType,
        timestamp = os.time(),
        user = GetUserDetails(),
    }

    if Config.Logging.DeviceInfo then
        payload.device = GetDeviceType()
    end

    -- Merge event-specific data
    for key, value in pairs(data or {}) do
        payload[key] = value
    end

    -- Send to webhook
    local success, response = pcall(function()
        -- For Discord webhooks, format as embed
        if string.match(Config.WebhookURL, "discord.com") then
            local color = eventType == "key_valid" and 3066993 or 15158332  -- Green or Red

            return HttpService:PostAsync(
                Config.WebhookURL,
                HttpService:JSONEncode({
                    embeds = {{
                        title = "🔐 RVRSE Key Event: " .. eventType,
                        description = "Key validation event detected",
                        color = color,
                        fields = {
                            {
                                name = "User",
                                value = payload.user.username .. " (" .. payload.user.userId .. ")",
                                inline = true
                            },
                            {
                                name = "Device",
                                value = payload.device or "Unknown",
                                inline = true
                            },
                            {
                                name = "Event Type",
                                value = "`" .. eventType .. "`",
                                inline = true
                            },
                            {
                                name = "Details",
                                value = "```json\n" .. HttpService:JSONEncode(data) .. "\n```",
                                inline = false
                            },
                        },
                        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ", payload.timestamp),
                        footer = {
                            text = "RVRSE Remote Key Loader v2.5.0"
                        }
                    }}
                }),
                Enum.HttpContentType.ApplicationJson
            )
        else
            -- For generic webhooks, send raw JSON
            return HttpService:PostAsync(
                Config.WebhookURL,
                HttpService:JSONEncode(payload),
                Enum.HttpContentType.ApplicationJson
            )
        end
    end)

    if success then
        print("[WEBHOOK] Event sent: " .. eventType)
    else
        warn("[WEBHOOK] Failed to send event: " .. tostring(response))
    end
end

-- ============================================================================
-- REMOTE KEY LOADER
-- ============================================================================

local function Log(message)
    print("[RVRSE] " .. message)
end

local function FetchRemoteKey()
    Log("🔄 Fetching key from remote server...")

    if Config.Logging.KeyAttempts then
        SendWebhook("key_fetch_attempt", {
            url = Config.RemoteKeyURL
        })
    end

    local success, result = pcall(function()
        return game:HttpGet(Config.RemoteKeyURL)
    end)

    if success and result and result ~= "" then
        Log("✅ Key fetched successfully")
        return result
    end

    Log("❌ Failed to fetch key")

    if Config.Logging.KeyInvalid then
        SendWebhook("key_fetch_failed", {
            reason = "HTTP request failed or empty response",
            url = Config.RemoteKeyURL
        })
    end

    return nil
end

local function OnKeyValid(key)
    Log("✅ Key validated successfully!")
    Log("🎮 Access granted - Loading game...")

    -- Send success webhook
    if Config.Logging.KeyValid then
        SendWebhook("key_valid", {
            key = string.sub(key, 1, 20) .. "...",  -- Only send first 20 chars for privacy
            keyLength = #key,
            message = "User successfully validated and gained access"
        })
    end

    -- ========================================================================
    -- YOUR GAME CODE GOES HERE
    -- ========================================================================

    -- Example: Load your main hub script
    -- loadstring(game:HttpGet("https://raw.githubusercontent.com/..."))()

    -- Example: Set globals
    _G.PREMIUM_ACCESS = true
    _G.KEY = key
    _G.WEBHOOK_LOGGING = true

    -- Example: Load RvrseUI hub
    -- local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/...RvrseUI.lua"))()
    -- RvrseUI:Init({ Title = "My Hub", Key = key })

    print("🎉 Game loaded successfully!")
end

local function OnKeyInvalid(reason)
    Log("❌ Access denied: " .. tostring(reason))

    -- Send failure webhook
    if Config.Logging.KeyInvalid then
        SendWebhook("key_invalid", {
            reason = tostring(reason),
            message = "User failed to validate key",
            willKick = Config.KickOnFailure
        })
    end

    if Config.KickOnFailure then
        Log("🚪 Kicking player...")
        LocalPlayer:Kick("Access denied: " .. tostring(reason))
    else
        Log("⚠️ Continuing without access")
    end
end

-- ============================================================================
-- MAIN EXECUTION
-- ============================================================================

Log("🚀 RVRSE Remote Key Loader (Webhook Logging) Started")
Log("User ID: " .. LocalPlayer.UserId)
Log("Device: " .. GetDeviceType())

-- Send initialization webhook
if Config.WebhookEnabled then
    SendWebhook("loader_started", {
        version = "2.5.0",
        device = GetDeviceType(),
        message = "Remote key loader initialized"
    })
end

-- Attempt to fetch key
local attempts = 0
local key = nil

while attempts < Config.MaxAttempts and not key do
    attempts = attempts + 1
    Log("Attempt " .. attempts .. "/" .. Config.MaxAttempts)

    key = FetchRemoteKey()

    if not key and attempts < Config.MaxAttempts then
        wait(1)  -- Wait before retry
    end
end

-- Validate result
if key and key ~= "" then
    OnKeyValid(key)
else
    OnKeyInvalid("Failed to fetch valid key after " .. attempts .. " attempts")
end

-- ============================================================================
-- WEBHOOK EXAMPLES
-- ============================================================================
--
-- Example Discord Webhook Payload (key_valid event):
-- {
--   "embeds": [{
--     "title": "🔐 RVRSE Key Event: key_valid",
--     "description": "Key validation event detected",
--     "color": 3066993,
--     "fields": [
--       {
--         "name": "User",
--         "value": "JohnDoe (123456789)",
--         "inline": true
--       },
--       {
--         "name": "Device",
--         "value": "PC",
--         "inline": true
--       },
--       {
--         "name": "Event Type",
--         "value": "`key_valid`",
--         "inline": true
--       },
--       {
--         "name": "Details",
--         "value": "```json\n{\"key\":\"RVRSE-XXXX-XXXX-X...\",\"message\":\"User successfully validated\"}\n```",
--         "inline": false
--       }
--     ],
--     "timestamp": "2025-11-04T10:30:00Z",
--     "footer": {
--       "text": "RVRSE Remote Key Loader v2.5.0"
--     }
--   }]
-- }
--
-- ============================================================================

-- ============================================================================
-- SECURITY & PRIVACY NOTES
-- ============================================================================
--
-- ⚠️ PRIVACY CONCERNS:
--
-- This pattern logs user data to external webhooks!
--
-- What gets logged:
--   ✅ User IDs (public Roblox data)
--   ✅ Usernames (public Roblox data)
--   ✅ Account age (public Roblox data)
--   ✅ Device type (client-side detection)
--   ✅ Timestamps (server time)
--   ✅ Key validation events
--
-- What should NOT be logged:
--   ❌ Full keys (only first 20 chars shown)
--   ❌ Personal information beyond Roblox profile
--   ❌ IP addresses (unless your webhook service adds them)
--   ❌ Sensitive game state or player data
--
-- Best Practices:
--   1. Inform users that usage is logged (terms of service)
--   2. Only log data necessary for your use case
--   3. Secure webhook URLs (don't share publicly)
--   4. Use Discord webhook permissions to limit access
--   5. Regularly review logs and delete old data
--   6. Don't log full keys (only partial for debugging)
--   7. Consider GDPR/privacy laws if EU users
--
-- Webhook Security:
--   ✅ Discord webhooks are rate-limited (protect against spam)
--   ✅ Use dedicated webhook per project
--   ✅ Rotate webhook URLs if compromised
--   ✅ Monitor webhook channel for abuse
--
-- Analytics Use Cases:
--   ✅ Track peak usage times
--   ✅ Identify popular features
--   ✅ Detect abuse patterns (rapid retries)
--   ✅ Monitor key sharing (same key, different users)
--   ✅ Geographic distribution (if webhook logs IP)
--   ✅ Device type distribution (mobile vs PC)
--
-- ============================================================================
