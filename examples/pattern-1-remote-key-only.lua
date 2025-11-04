-- ============================================================================
-- RVRSE PATTERN 1: Remote Key Only (Simplest)
-- ============================================================================
--
-- This is the SIMPLEST pattern for RvrseUI remote key loading.
-- Perfect for: Simple hubs, quick prototypes, getting started
--
-- What it does:
--   1. Fetches key from your remote server
--   2. Validates key exists and isn't empty
--   3. Calls your game code if valid
--   4. Kicks player if invalid (optional)
--
-- Setup Instructions:
--   1. Generate key: npm run generate (in rvrse-obfuscate)
--   2. Update RemoteKeyURL below with your Heroku endpoint
--   3. Paste at top of your hub script
--   4. Done!
--
-- ============================================================================

local Config = {
    -- Remote server settings
    GrabKeyFromSite = true,
    RemoteKeyURL = "https://rvrse-keys-prod.herokuapp.com/keys/raw/mygame:hub",

    -- Local storage (optional - saves key after first validation)
    SaveKey = false,  -- Set to true if you want offline play

    -- Validation settings
    MaxAttempts = 3,
    KickOnFailure = true,  -- Set to false for soft failure
}

-- ============================================================================
-- LOADER IMPLEMENTATION
-- ============================================================================

local function Log(message)
    print("[RVRSE] " .. message)
end

local function FetchRemoteKey()
    Log("🔄 Fetching key from remote server...")

    local success, result = pcall(function()
        return game:HttpGet(Config.RemoteKeyURL)
    end)

    if success and result and result ~= "" then
        Log("✅ Key fetched successfully")
        return result
    end

    Log("❌ Failed to fetch key")
    return nil
end

local function OnKeyValid(key)
    Log("✅ Key validated successfully!")
    Log("🎮 Access granted - Loading game...")

    -- ========================================================================
    -- YOUR GAME CODE GOES HERE
    -- ========================================================================

    -- Example: Load your main hub script
    -- loadstring(game:HttpGet("https://raw.githubusercontent.com/..."))()

    -- Example: Enable features
    _G.PREMIUM_ACCESS = true
    _G.KEY = key

    -- Example: Load RvrseUI hub
    -- local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/...RvrseUI.lua"))()
    -- RvrseUI:Init({ Title = "My Hub", Key = key })

    print("🎉 Game loaded successfully!")
end

local function OnKeyInvalid(reason)
    Log("❌ Access denied: " .. tostring(reason))

    if Config.KickOnFailure then
        Log("🚪 Kicking player...")
        game:GetService("Players").LocalPlayer:Kick("Access denied: " .. tostring(reason))
    else
        Log("⚠️ Continuing without access")
    end
end

-- ============================================================================
-- MAIN EXECUTION
-- ============================================================================

Log("🚀 RVRSE Remote Key Loader Started")
Log("Max Attempts: " .. Config.MaxAttempts)

-- Attempt to fetch key
local attempts = 0
local key = nil

while attempts < Config.MaxAttempts and not key do
    attempts = attempts + 1
    Log("Attempt " .. attempts .. "/" .. Config.MaxAttempts)

    key = FetchRemoteKey()

    if not key then
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
-- SECURITY NOTES
-- ============================================================================
--
-- ⚠️ IMPORTANT: This is NOT a security system!
--
-- What this DOES provide:
--   ✅ Server-side key authority (your server decides who gets access)
--   ✅ Easy distribution (just give out keys, not full script)
--   ✅ Revocation (disable keys on server = instant access removal)
--   ✅ Developer friction (slows casual abuse)
--
-- What this DOES NOT provide:
--   ❌ Protection from determined attackers
--   ❌ Secret hiding (key fetch is visible in network logs)
--   ❌ Cheat prevention (server-side validation needed)
--   ❌ Code obfuscation (use RVRSE obfuscator separately)
--
-- Best Practices:
--   1. Always validate game actions on your server
--   2. Use this as access control, not security
--   3. Combine with RVRSE obfuscation for better protection
--   4. Monitor key usage via Heroku dashboard
--
-- ============================================================================
