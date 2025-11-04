# RVRSE Remote Key Loader - Official Patterns

**Version:** 2.5.0 (Phase 1)
**Updated:** 2025-11-04
**Purpose:** Clean, honest remote key loading patterns for RvrseUI integration

---

## What Are These Patterns?

These are the **3 official patterns** for integrating RVRSE remote key loading with RvrseUI. Each pattern demonstrates a specific use case with complete, copy-paste-ready code.

**Philosophy:** These patterns provide **developer friction**, not security. They make it easier to control who accesses your hub by validating keys server-side, but they don't protect against determined attackers.

---

## Quick Start

1. **Choose a pattern** based on your needs
2. **Generate a key** using RVRSE generator: `npm run generate` (in rvrse-obfuscate project)
3. **Update the pattern** with your remote key URL
4. **Paste at top of your hub** script
5. **Done!** Your hub now requires remote key validation

---

## The 3 Official Patterns

### Pattern 1: Remote Key Only (Simplest)
**File:** [`pattern-1-remote-key-only.lua`](pattern-1-remote-key-only.lua)

**Use Case:** Simple hubs, quick prototypes, getting started

**What It Does:**
- Fetches key from your remote server
- Validates key exists and isn't empty
- Calls your game code if valid
- Kicks player if invalid (optional)

**Perfect For:**
- Your first RVRSE integration
- Simple access control
- Minimal configuration

**Key Features:**
- ✅ ~150 lines of clean, readable code
- ✅ Retry logic with configurable max attempts
- ✅ Optional kick on failure
- ✅ Clear security notes and best practices

**Example Config:**
```lua
local Config = {
    GrabKeyFromSite = true,
    RemoteKeyURL = "https://rvrse-keys-prod.herokuapp.com/keys/raw/mygame:hub",
    SaveKey = false,
    MaxAttempts = 3,
    KickOnFailure = true,
}
```

---

### Pattern 2: Remote Key + Whitelist (Advanced)
**File:** [`pattern-2-remote-key-whitelist.lua`](pattern-2-remote-key-whitelist.lua)

**Use Case:** VIP access, dev testing, special users

**What It Does:**
- Checks whitelist first (user IDs, special keys)
- If whitelisted, grants instant access
- Otherwise, fetches key from remote server
- Optionally caches validated users for future sessions

**Perfect For:**
- Giving VIPs permanent access without keys
- Developer testing without server dependency
- Beta testers with special override keys
- Reducing server load for trusted users

**Key Features:**
- ✅ Hardcoded user ID whitelist
- ✅ Override key support (special bypass keys)
- ✅ Persistent whitelist cache (remembers validated users)
- ✅ Fallback to remote key if not whitelisted

**Example Config:**
```lua
local Config = {
    Whitelist = {
        Enabled = true,
        UserIDs = {
            123456789,   -- Your Roblox user ID
            987654321,   -- Co-developer's user ID
        },
        OverrideKeys = {
            "RVRSE-DEV-KEY-2024",
            "RVRSE-ADMIN-OVERRIDE",
        },
        RememberValidUsers = true,
    },
    RemoteKeyURL = "https://rvrse-keys-prod.herokuapp.com/keys/raw/mygame:hub",
}
```

**Security Note:** Whitelist is CLIENT-SIDE and can be modified! Use for convenience, not security. Always validate important actions server-side.

---

### Pattern 3: Remote Key + Webhook (Logging)
**File:** [`pattern-3-remote-key-webhook.lua`](pattern-3-remote-key-webhook.lua)

**Use Case:** Analytics, monitoring, abuse detection, user tracking

**What It Does:**
- Fetches key from remote server
- Validates key
- Sends detailed event logs to your webhook (Discord, Slack, or custom)
- Tracks user activity, device type, timestamps

**Perfect For:**
- Monitoring who's using your hub and when
- Detecting suspicious validation patterns
- Generating usage analytics
- Measuring engagement metrics
- Alerting on failed validation attempts

**Key Features:**
- ✅ Discord webhook integration (formatted embeds)
- ✅ Generic webhook support (JSON payloads)
- ✅ Configurable logging (choose what to track)
- ✅ User details (ID, username, account age)
- ✅ Device detection (Mobile/Console/PC)
- ✅ Event types: loader_started, key_fetch_attempt, key_valid, key_invalid

**Example Config:**
```lua
local Config = {
    RemoteKeyURL = "https://rvrse-keys-prod.herokuapp.com/keys/raw/mygame:hub",
    WebhookURL = "https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN",
    WebhookEnabled = true,
    Logging = {
        KeyValid = true,
        KeyInvalid = true,
        KeyAttempts = true,
        UserDetails = true,
        DeviceInfo = true,
    },
}
```

**Privacy Note:** This pattern logs user data to external webhooks. Inform users and follow privacy best practices.

---

## Pattern Comparison

| Feature | Pattern 1 | Pattern 2 | Pattern 3 |
|---------|-----------|-----------|-----------|
| **Remote Key Validation** | ✅ | ✅ | ✅ |
| **Whitelist Support** | ❌ | ✅ | ❌ |
| **Override Keys** | ❌ | ✅ | ❌ |
| **Webhook Logging** | ❌ | ❌ | ✅ |
| **User Analytics** | ❌ | ❌ | ✅ |
| **Complexity** | Simple | Medium | Medium |
| **Lines of Code** | ~150 | ~300 | ~400 |
| **Best For** | Beginners | Power users | Analytics |

---

## How Remote Key Loading Works

```
User runs your hub script
    ↓
Loader starts (pattern-1, pattern-2, or pattern-3)
    ↓
Loader checks whitelist (pattern-2 only)
    ↓
Loader fetches key from: https://heroku/keys/raw/:product
    ↓
Heroku server checks database
    ↓
Server returns: RVRSE-XXXX-XXXX-XXXX-XXXX (plain text)
    ↓
Loader validates key exists and isn't empty
    ↓
Loader calls OnKeyValid() or OnKeyInvalid()
    ↓
OnKeyValid() loads your game code
    ↓
Game proceeds normally
```

**Key Point:** Your server (Heroku) has ALL authority. Client can be hacked, but server decides YES/NO.

---

## Security Reality

### What These Patterns DO Provide:

✅ **Server-side key authority** - Your server decides who gets access
✅ **Easy distribution** - Give out keys, not full scripts
✅ **Revocation** - Disable keys on server = instant access removal
✅ **Developer friction** - Slows casual abuse and script sharing

### What These Patterns DO NOT Provide:

❌ **Protection from determined attackers** - Client code can always be modified
❌ **Secret hiding** - Key fetch is visible in network logs
❌ **Cheat prevention** - Server-side validation needed for game actions
❌ **Code obfuscation** - Use RVRSE obfuscator separately for that

### Best Practices:

1. **Always validate game actions server-side** - Don't trust client-side validation
2. **Use this as access control, not security** - It's a friction layer
3. **Combine with RVRSE obfuscation** - Makes code harder to read
4. **Monitor key usage** - Use Pattern 3 webhooks or Heroku dashboard
5. **Rotate keys regularly** - Generate new keys periodically
6. **Don't put secrets in client code** - Never!

---

## Setup Instructions

### Step 1: Generate Key on Server

In your `rvrse-obfuscate` project:

```bash
npm run generate
```

Follow the prompts to create your `RemoteKeyLoader.lua` configuration.

### Step 2: Deploy Key Server

Make sure your Heroku server is running with the `/keys/raw/:productCode` endpoint:

```bash
cd rvrse-obfuscate
npm run server
```

Deploy to Heroku:

```bash
git push heroku main
```

### Step 3: Choose Pattern

Pick the pattern that matches your use case:

- **Pattern 1:** Just need basic remote key validation? Start here.
- **Pattern 2:** Need VIP access or dev testing? Use this.
- **Pattern 3:** Want analytics and monitoring? This is it.

### Step 4: Update Configuration

Open the pattern file and update:

```lua
RemoteKeyURL = "https://YOUR-HEROKU-APP.herokuapp.com/keys/raw/YOUR-PRODUCT-CODE"
```

For Pattern 3, also add:

```lua
WebhookURL = "https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"
```

### Step 5: Integrate with Your Hub

Paste the pattern code at the **top** of your hub script, before any other code:

```lua
-- Pattern code goes here (150-400 lines)

-- Then your game code:
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/..."))()
RvrseUI:Init({ Title = "My Hub" })
```

### Step 6: Test

Run your hub in a Roblox executor and verify:

1. ✅ Key fetches successfully
2. ✅ Validation passes/fails correctly
3. ✅ Game code loads after validation
4. ✅ Webhook logs appear (Pattern 3 only)

---

## Troubleshooting

### "Failed to fetch key"

**Possible Causes:**
- Remote server is down
- Wrong RemoteKeyURL
- Network blocked by executor
- Key doesn't exist for that productCode

**Fix:**
1. Check Heroku server is running: `heroku logs --tail`
2. Verify RemoteKeyURL is correct
3. Test endpoint in browser: `https://your-app.herokuapp.com/keys/raw/your-product`
4. Generate key with correct `metadata.productCode`

### "Access denied: No valid key found"

**Possible Causes:**
- Max attempts exceeded (default: 3)
- Key expired or revoked
- Network timeout

**Fix:**
1. Increase `MaxAttempts` in config
2. Check key status in Heroku dashboard
3. Try again with fresh executor session

### "Webhook not sending"

**Possible Causes:**
- Wrong WebhookURL
- Discord rate limiting
- Executor blocks HttpPost

**Fix:**
1. Verify webhook URL is correct
2. Test webhook with curl: `curl -X POST YOUR_WEBHOOK_URL -d '{"content":"test"}'`
3. Check Discord webhook permissions
4. Enable webhook logging: `WebhookEnabled = true`

---

## Migration from Old Patterns

If you're using old RvrseUI patterns (before Phase 1), here's how to migrate:

### Old Pattern (Deprecated):
```lua
-- Complex wrapper with "security" layers
-- Instance proxying
-- Metatables everywhere
-- 500+ lines of complexity
```

### New Pattern (Phase 1):
```lua
-- Simple remote key fetch
-- Clean validation logic
-- 150 lines, easy to understand
-- Honest about what it does
```

**Migration Steps:**

1. **Backup your old code** - Save it just in case
2. **Remove old wrapper** - Delete complex RvrseUI wrapper code
3. **Use Pattern 1** - Start with the simplest pattern
4. **Update RemoteKeyURL** - Point to new `/keys/raw/:product` endpoint
5. **Test thoroughly** - Verify everything works
6. **Upgrade to Pattern 2 or 3** - If needed, add whitelist or webhooks

---

## FAQ

### Q: Do I need all 3 patterns?

**A:** No! Choose ONE pattern based on your needs. Most users should start with Pattern 1.

### Q: Can I combine patterns?

**A:** Yes! You can mix features. For example, combine Pattern 2's whitelist with Pattern 3's webhooks. Just merge the code carefully.

### Q: Is this really secure?

**A:** No! This is **developer friction**, not security. It slows casual abuse but won't stop determined attackers. Always validate important actions server-side.

### Q: Can I customize the patterns?

**A:** Absolutely! These are templates. Modify them to fit your needs. Just keep the core logic intact.

### Q: Do I need RVRSE obfuscation too?

**A:** Not required, but recommended. Remote key loading controls **who** accesses your hub. Obfuscation makes it harder to **read** your code. Together they provide better protection.

### Q: What if my key server goes down?

**A:** Users won't be able to access your hub until it's back up. This is by design - server has authority. Use a reliable host like Heroku with good uptime.

### Q: Can I use this with other UI libraries?

**A:** Yes! These patterns work with any Lua code, not just RvrseUI. Replace the `OnKeyValid()` section with your own game loading logic.

### Q: How do I revoke access?

**A:** Two options:
1. **Disable key on server** - Set key status to "inactive" in database
2. **Delete key** - Remove key entirely from server

Both will immediately block access when user tries to validate.

---

## Support

- **RVRSE Documentation:** [d:\rvrse-obfuscate\PHASE_1_IMPLEMENTATION.md](../../rvrse-obfuscate/PHASE_1_IMPLEMENTATION.md)
- **Server Setup:** [d:\rvrse-obfuscate\server\key-server-v2.mjs](../../rvrse-obfuscate/server/key-server-v2.mjs)
- **Generator:** [d:\rvrse-obfuscate\rvrse-remote-keys.mjs](../../rvrse-obfuscate/rvrse-remote-keys.mjs)

---

## What's Next (Phase 2)

After Phase 1 is complete, we'll:

1. Clean up old RvrseUI wrapper complexity
2. Remove false "security wrapper" claims
3. Archive deprecated components
4. Update all remaining documentation
5. Release v2.5.0 "Clean Honest Tool"

But for now, these 3 patterns are all you need!

---

**Created:** 2025-11-04
**Phase:** 1 (Remote Key Loader)
**Status:** ✅ OFFICIAL PATTERNS COMPLETE
**License:** MIT © 2025 RVRSE / VIPSPOT

---

**Remember:** Real security lives on servers. RVRSE is a friction layer that slows casual abuse while providing clean developer experience.
