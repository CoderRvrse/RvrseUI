-- ============================================================================
-- RVRSE PATTERN 2: Remote Key + Whitelist (Advanced)
-- ============================================================================
--
-- This pattern combines remote key loading with whitelist overrides.
-- Perfect for: VIP access, dev testing, special users
--
-- What it does:
--   1. Checks whitelist first (user IDs, special keys)
--   2. If whitelisted, grants instant access
--   3. Otherwise, fetches key from remote server
--   4. Validates key and tracks usage
--
-- Use Cases:
--   - Give VIPs permanent access (no key needed)
--   - Dev testing without server dependency
--   - Beta testers with special keys
--   - Admin override for support
--
-- Setup Instructions:
--   1. Update Whitelist.UserIDs with trusted user IDs
--   2. Update Whitelist.OverrideKeys with special keys
--   3. Update RemoteKeyURL with your Heroku endpoint
--   4. Paste at top of your hub script
--
-- ============================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Config = {
    -- Whitelist settings (checked FIRST, before remote key)
    Whitelist = {
        Enabled = true,

        -- User IDs that always have access (no key needed)
        UserIDs = {
            123456789,   -- Example: Your Roblox user ID
            987654321,   -- Example: Co-developer's user ID
            -- Add more user IDs here
        },

        -- Special keys that bypass remote validation
        OverrideKeys = {
            "RVRSE-DEV-KEY-2024",       -- Example: Developer key
            "RVRSE-ADMIN-OVERRIDE",     -- Example: Admin key
            "RVRSE-VIP-ACCESS",         -- Example: VIP key
            -- Add more override keys here
        },

        -- Auto-whitelist on first successful key validation (sticky access)
        RememberValidUsers = true,
    },

    -- Remote server settings (used if not whitelisted)
    GrabKeyFromSite = true,
    RemoteKeyURL = "https://rvrse-keys-prod.herokuapp.com/keys/raw/mygame:hub",

    -- Local storage
    SaveKey = true,  -- Recommended: true (allows offline play after first validation)

    -- Validation settings
    MaxAttempts = 3,
    KickOnFailure = true,
}

-- ============================================================================
-- WHITELIST STORAGE (Persistent across sessions)
-- ============================================================================

local WhitelistFile = "rvrse_whitelist_cache.txt"

local function LoadWhitelistCache()
    local success, content = pcall(function()
        local file = readfile(WhitelistFile)
        return file
    end)

    if success and content then
        local cache = {}
        for userId in string.gmatch(content, "(%d+)") do
            cache[tonumber(userId)] = true
        end
        return cache
    end

    return {}
end

local function SaveWhitelistCache(userId)
    if not Config.Whitelist.RememberValidUsers then return end

    local success = pcall(function()
        local existing = LoadWhitelistCache()
        existing[userId] = true

        local content = ""
        for id, _ in pairs(existing) do
            content = content .. tostring(id) .. "\n"
        end

        writefile(WhitelistFile, content)
    end)

    if success then
        print("[WHITELIST] Cached user ID: " .. userId)
    end
end

-- ============================================================================
-- WHITELIST VALIDATION
-- ============================================================================

local function IsUserWhitelisted(userId)
    -- Check hardcoded user IDs
    for _, whitelistedId in ipairs(Config.Whitelist.UserIDs) do
        if userId == whitelistedId then
            return true, "Hardcoded user ID"
        end
    end

    -- Check cached whitelist (from previous valid sessions)
    if Config.Whitelist.RememberValidUsers then
        local cache = LoadWhitelistCache()
        if cache[userId] then
            return true, "Cached whitelist"
        end
    end

    return false, nil
end

local function IsKeyOverride(key)
    if not key then return false end

    for _, overrideKey in ipairs(Config.Whitelist.OverrideKeys) do
        if key == overrideKey then
            return true
        end
    end

    return false
end

-- ============================================================================
-- REMOTE KEY LOADER
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

local function OnKeyValid(key, source)
    Log("✅ Access granted via: " .. source)
    Log("🎮 Loading game...")

    -- Cache this user for future sessions
    SaveWhitelistCache(LocalPlayer.UserId)

    -- ========================================================================
    -- YOUR GAME CODE GOES HERE
    -- ========================================================================

    -- Example: Load your main hub script
    -- loadstring(game:HttpGet("https://raw.githubusercontent.com/..."))()

    -- Example: Set globals
    _G.PREMIUM_ACCESS = true
    _G.KEY = key
    _G.ACCESS_SOURCE = source  -- "whitelist", "override_key", or "remote_key"

    -- Example: Load RvrseUI hub
    -- local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/...RvrseUI.lua"))()
    -- RvrseUI:Init({ Title = "My Hub (VIP)", Key = key })

    print("🎉 Game loaded successfully!")
end

local function OnKeyInvalid(reason)
    Log("❌ Access denied: " .. tostring(reason))

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

Log("🚀 RVRSE Remote Key Loader (Whitelist Mode) Started")
Log("User ID: " .. LocalPlayer.UserId)

-- Step 1: Check whitelist first
if Config.Whitelist.Enabled then
    local isWhitelisted, whitelistSource = IsUserWhitelisted(LocalPlayer.UserId)

    if isWhitelisted then
        Log("✅ User is whitelisted: " .. whitelistSource)
        OnKeyValid("WHITELIST_OVERRIDE", "whitelist:" .. whitelistSource)
        return  -- Exit early, no need to fetch remote key
    end

    Log("ℹ️ User not whitelisted, checking remote key...")
end

-- Step 2: Attempt to fetch remote key
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

-- Step 3: Check if fetched key is an override key
if key and IsKeyOverride(key) then
    Log("✅ Override key detected")
    OnKeyValid(key, "override_key")
    return
end

-- Step 4: Validate result
if key and key ~= "" then
    OnKeyValid(key, "remote_key")
else
    OnKeyInvalid("Failed to fetch valid key after " .. attempts .. " attempts")
end

-- ============================================================================
-- SECURITY NOTES
-- ============================================================================
--
-- ⚠️ WHITELIST SECURITY:
--
-- The whitelist is CLIENT-SIDE and can be modified by attackers!
--
-- Best Practices:
--   1. Use whitelist for convenience, not security
--   2. Always validate important game actions server-side
--   3. Treat whitelisted users same as key users (both untrusted)
--   4. Use RememberValidUsers to reduce server load for returning users
--   5. Override keys are NOT secret - they can be extracted from code
--
-- When to use whitelist:
--   ✅ Dev testing without server dependency
--   ✅ VIP convenience (but validate purchases server-side!)
--   ✅ Beta testers in controlled environment
--   ✅ Reducing key server load for trusted users
--
-- When NOT to use whitelist:
--   ❌ As primary access control
--   ❌ For premium features (validate server-side!)
--   ❌ To protect secrets or sensitive data
--   ❌ For game action validation (must validate on server!)
--
-- ============================================================================
