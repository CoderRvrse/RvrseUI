-- RvrseUI Key System Example
-- Demonstrates all key system features and authentication methods

-- Load RvrseUI
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

-- ============================================
-- EXAMPLE 1: Simple Key System (Rayfield Compatible)
-- ============================================

local Window1 = RvrseUI:CreateWindow({
    Name = "Simple Key System",
    Icon = "🔐",
    Theme = "Dark",

    -- Enable key system
    KeySystem = true,

    KeySettings = {
        Title = "My Hub - Key System",
        Subtitle = "Enter your key to continue",
        Note = "Join our Discord to get a key!",

        -- Simple key validation
        Key = "MySecretKey123",  -- Single key string (Rayfield compatible)

        -- Save key locally so user doesn't re-enter every time
        SaveKey = true,
        FileName = "MyHubKey",

        -- Attempt limiting
        MaxAttempts = 3,

        -- Kick player if validation fails
        KickOnFailure = true
    }
})

-- If we get here, key was validated successfully!
local Tab1 = Window1:CreateTab({ Title = "Main", Icon = "⚙️" })
local Section1 = Tab1:CreateSection("Welcome")

Section1:CreateLabel({ Text = "✓ Key validated successfully!" })

Window1:Show()


-- ============================================
-- EXAMPLE 2: Multiple Valid Keys
-- ============================================

local Window2 = RvrseUI:CreateWindow({
    Name = "Multi-Key System",

    KeySystem = true,
    KeySettings = {
        Title = "Multi-Key Validation",
        Subtitle = "Any of these keys will work",

        -- Table of valid keys (RvrseUI extension)
        Keys = {
            "VIPKey2024",
            "AdminKey999",
            "DevKey123"
        },

        SaveKey = true,
        FileName = "MultiKey",
        MaxAttempts = 5
    }
})


-- ============================================
-- EXAMPLE 3: Remote Key Fetching (Pastebin/GitHub)
-- ============================================

local Window3 = RvrseUI:CreateWindow({
    Name = "Remote Key System",

    KeySystem = true,
    KeySettings = {
        Title = "Remote Key Validation",
        Subtitle = "Fetching key from server...",
        Note = "Key is fetched from Pastebin",

        -- Fetch key from remote URL
        GrabKeyFromSite = true,
        Key = "https://pastebin.com/raw/YourKeyHere",  -- URL to raw key

        SaveKey = true,
        FileName = "RemoteKey"
    }
})


-- ============================================
-- EXAMPLE 4: HWID/User ID Whitelist
-- ============================================

local Window4 = RvrseUI:CreateWindow({
    Name = "Whitelist System",

    KeySystem = true,
    KeySettings = {
        Title = "Whitelist Validation",
        Subtitle = "Your HWID or User ID must be whitelisted",

        -- Whitelist array (HWIDs, User IDs, or manual keys)
        Whitelist = {
            "12345678",  -- User ID
            "HWID-ABC123-XYZ789",  -- Hardware ID
            "ManualKey123"  -- Manual override key
        },

        MaxAttempts = 3,
        KickOnFailure = true
    }
})


-- ============================================
-- EXAMPLE 5: Custom Validator Function
-- ============================================

local Window5 = RvrseUI:CreateWindow({
    Name = "Custom Validation",

    KeySystem = true,
    KeySettings = {
        Title = "Custom Key Logic",
        Subtitle = "Advanced validation",

        -- Custom validator function (ultimate flexibility)
        Validator = function(inputKey)
            -- Example: Key must be "ADMIN" + current day of month
            local requiredKey = "ADMIN" .. os.date("%d")

            if inputKey == requiredKey then
                return true
            end

            -- Or validate against external API
            local success, response = pcall(function()
                return game:HttpGet("https://api.example.com/validate?key=" .. inputKey)
            end)

            if success and response == "valid" then
                return true
            end

            return false
        end,

        SaveKey = false,  -- Don't save since key changes daily
        MaxAttempts = 5
    }
})


-- ============================================
-- EXAMPLE 6: Discord Webhook Logging
-- ============================================

local Window6 = RvrseUI:CreateWindow({
    Name = "Logged Key System",

    KeySystem = true,
    KeySettings = {
        Title = "Monitored Access",
        Subtitle = "All attempts are logged",
        Note = "Admins are notified of access attempts",

        Keys = {"SecretKey2024", "VIPAccess"},

        -- Discord webhook for logging
        WebhookURL = "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE",

        SaveKey = true,
        FileName = "LoggedKey",
        MaxAttempts = 3
    }
})

-- Webhook will send embeds with:
-- - Username
-- - User ID
-- - Input key
-- - Validation result (success/failure)
-- - Timestamp


-- ============================================
-- EXAMPLE 7: Custom Callbacks
-- ============================================

local Window7 = RvrseUI:CreateWindow({
    Name = "Callback System",

    KeySystem = true,
    KeySettings = {
        Title = "Event-Driven Keys",

        Keys = {"TestKey123"},

        -- Callback when valid key entered
        OnKeyValid = function(validKey)
            print("✓ Valid key entered:", validKey)

            RvrseUI:Notify({
                Title = "Welcome!",
                Message = "Key validated: " .. validKey,
                Duration = 5,
                Type = "success"
            })
        end,

        -- Callback when invalid key entered
        OnKeyInvalid = function(invalidKey, attemptsLeft)
            print("✗ Invalid key:", invalidKey)
            print("Attempts remaining:", attemptsLeft)

            RvrseUI:Notify({
                Title = "Invalid Key",
                Message = attemptsLeft .. " attempts remaining",
                Duration = 3,
                Type = "error"
            })
        end,

        -- Callback when attempts exhausted
        OnAttemptsExhausted = function()
            print("⚠️ Out of attempts!")

            -- Custom action instead of kick
            -- e.g., redirect to key purchase page
        end,

        MaxAttempts = 3,
        KickOnFailure = false  -- Handle failure manually in callback
    }
})


-- ============================================
-- EXAMPLE 8: Key System with "Get Key" Button
-- ============================================

local Window8 = RvrseUI:CreateWindow({
    Name = "Get Key Button",

    KeySystem = true,
    KeySettings = {
        Title = "Premium Hub Access",
        Subtitle = "Purchase a key to unlock features",
        Note = "Click below to visit our key shop",

        -- "Get Key" button
        NoteButton = {
            Text = "🔑 Get Key",
            Callback = function()
                -- Copy link to clipboard
                setclipboard("https://example.com/getkey")

                RvrseUI:Notify({
                    Title = "Link Copied!",
                    Message = "Key shop link copied to clipboard",
                    Duration = 3,
                    Type = "success"
                })

                -- Or open in browser (if executor supports)
                -- request({ Url = "https://example.com/getkey", Method = "GET" })
            end
        },

        Keys = {"PremiumKey2024"},
        SaveKey = true,
        FileName = "PremiumKey"
    }
})


-- ============================================
-- EXAMPLE 9: Production-Ready Configuration
-- ============================================

local ProductionHub = RvrseUI:CreateWindow({
    Name = "My Production Hub",
    Icon = "🎮",
    Theme = "Dark",

    -- Configuration saving
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MyHub",
        FileName = "Config.json"
    },

    -- Key system (blocks UI until validated)
    KeySystem = true,
    KeySettings = {
        -- UI Configuration
        Title = "My Hub - Authentication",
        Subtitle = "Enter your license key",
        Note = "Visit myhub.gg/key to get your key",
        NoteButton = {
            Text = "🌐 Get Key",
            Callback = function()
                setclipboard("https://myhub.gg/key")
            end
        },

        -- Validation Method (choose one or combine)
        Keys = {
            "TRIAL-2024",
            "PREMIUM-XYZ"
        },

        -- OR use whitelist
        -- Whitelist = {"123456", "789012"},

        -- OR fetch from server
        -- GrabKeyFromSite = true,
        -- Key = "https://pastebin.com/raw/ABC123",

        -- Security Settings
        SaveKey = true,
        FileName = "MyHubLicense",
        MaxAttempts = 3,
        KickOnFailure = true,

        -- Discord Logging (optional)
        WebhookURL = "https://discord.com/api/webhooks/YOUR_WEBHOOK",

        -- Callbacks (optional)
        OnKeyValid = function(key)
            print("User authenticated with key:", key)
        end,

        OnKeyInvalid = function(key, attempts)
            warn("Failed attempt:", key, "- Remaining:", attempts)
        end
    }
})

-- Rest of your hub code here
local MainTab = ProductionHub:CreateTab({ Title = "Main", Icon = "⚙️" })
local Section = MainTab:CreateSection("Features")

Section:CreateLabel({ Text = "✓ Access granted!" })

ProductionHub:Show()


-- ============================================
-- RAYFIELD MIGRATION EXAMPLE
-- ============================================

-- If you're migrating from Rayfield, your existing code works as-is!

local RayfieldCompatible = RvrseUI:CreateWindow({
    Name = "Rayfield Migration",

    -- This is exactly how Rayfield does it
    KeySystem = true,
    KeySettings = {
        Title = "Untitled",
        Subtitle = "Key System",
        Note = "No method of obtaining the key is provided",
        FileName = "Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"Hello"}  -- Rayfield uses Key with table
    }
})

-- RvrseUI improvements you can add:
-- - Multiple validation methods (Whitelist, Validator)
-- - Discord webhook logging
-- - Custom callbacks (OnKeyValid, OnKeyInvalid)
-- - NoteButton for "Get Key" actions
-- - Better UI (themed, animated)


print("🔐 Key System Examples Loaded!")
print("Uncomment the example you want to test")
