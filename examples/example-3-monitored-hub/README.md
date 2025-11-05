# Example 3: Monitored Hub with Discord Webhook Logging

**Difficulty:** Advanced
**Time to Setup:** 25 minutes
**Use Case:** Hub with real-time activity logging and Discord notifications

---

## What This Example Shows

A complete, production-grade Roblox hub that:
- ✅ Loads with RVRSE Pattern 3 (remote key + webhook validation)
- ✅ Logs all user actions to Discord in real-time
- ✅ Tracks access attempts (success/failure)
- ✅ Monitors player activity (spawns, deaths, button clicks)
- ✅ Provides detailed analytics through Discord embeds

---

## Prerequisites

1. **RVRSE Installed** - `npm install -g rvrse-obfuscate`
2. **RVRSE Server Running** - Remote key endpoint deployed
3. **Valid Key Generated** - Via `npm run generate`
4. **Discord Server** - For receiving webhook notifications
5. **Discord Webhook URL** - See "Creating a Discord Webhook" below
6. **Roblox Executor** - Codex, Synapse X, or similar

---

## Creating a Discord Webhook

### Step 1: Create Discord Server (if you don't have one)
1. Open Discord
2. Click "+" button to create new server
3. Name it (e.g., "Hub Analytics")

### Step 2: Create Webhook Channel
1. Right-click server name
2. Select "Create Channel"
3. Name it "hub-logs" (or your preference)
4. Click Create

### Step 3: Get Webhook URL
1. Right-click the channel
2. Select "Edit Channel"
3. Go to "Integrations" (left sidebar)
4. Click "Webhooks"
5. Click "New Webhook"
6. Name it "RVRSE Hub" (or your preference)
7. Click "Copy Webhook URL"
8. Save this URL - you'll need it for setup

**Example webhook URL:**
```
https://discord.com/api/webhooks/1234567890/abcdefghijklmnop
```

---

## Setup Steps

### Step 1: Copy Pattern File

Copy the Pattern 3 file to this directory:

```bash
# Windows
copy ..\pattern-3-remote-key-webhook.lua .

# Linux/Mac
cp ../pattern-3-remote-key-webhook.lua .
```

### Step 2: Configure Discord Webhook

Edit `main.lua` and find this line at the top:

```lua
local DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"
```

Replace with your actual webhook URL:

```lua
local DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1234567890/abcdefghijklmnop"
```

### Step 3: Update Pattern 3 Configuration

Edit `pattern-3-remote-key-webhook.lua` and update:

```lua
local Config = {
    GrabKeyFromSite = true,
    RemoteKeyURL = "https://YOUR-SERVER.herokuapp.com/keys/raw/YOUR-PRODUCT",
    SaveKey = false,
    MaxAttempts = 3,
    KickOnFailure = true,
}
```

Replace:
- `YOUR-SERVER.herokuapp.com` with your actual RVRSE server URL
- `YOUR-PRODUCT` with your product code

### Step 4: Prepare the Script

Combine pattern and main code:

```bash
# Windows
type pattern-3-remote-key-webhook.lua main.lua > combined.lua

# Linux/Mac
cat pattern-3-remote-key-webhook.lua main.lua > combined.lua
```

### Step 5: Test in Executor

1. Open Roblox executor (Codex, Synapse, etc.)
2. Join a Roblox game
3. Copy entire contents of `combined.lua`
4. Paste into executor
5. Execute (F9 or Execute button)

### Step 6: Verify Discord Logging

Check your Discord channel - you should see:

**✅ Success:**
```
✅ User Access Granted
Username: YourUsername
User ID: 123456789
Time: 2025-11-04 10:30:45
```

**❌ Failure (if key is invalid):**
```
❌ Access Denied
Username: YourUsername
User ID: 123456789
Reason: Failed to fetch key
Time: 2025-11-04 10:30:45
```

---

## How It Works

### 1. Pattern 3 Initialization

When you execute the script, Pattern 3:
1. Starts the loader
2. Fetches your key from the server
3. Validates the key exists
4. Makes webhook call to notify access attempt

### 2. Key Validation Success

Pattern 3 calls `OnKeyValid(key)` when validation succeeds:

```lua
function OnKeyValid(key)
    OnKeyValidCallback(key)
end
```

Which logs to Discord and loads the hub.

### 3. Key Validation Failure

Pattern 3 calls `OnKeyInvalid(reason)` if validation fails:

```lua
function OnKeyInvalid(reason)
    OnKeyInvalidCallback(reason)
end
```

Which logs the failure details to Discord.

### 4. Real-Time Activity Logging

Every user action in the hub sends a Discord message:

```lua
MainTab:AddButton("Test Feature", function()
    SendToDiscord(
        "🎮 Button Clicked",
        "User clicked 'Test Feature' button",
        3447003,
        { /* fields */ }
    )
end)
```

---

## Discord Message Types

### Access Granted (Green)
```
Title: ✅ User Access Granted
Color: Green (#00FF00)
Shows: Username, User ID, timestamp
```

### Access Denied (Red)
```
Title: ❌ Access Denied
Color: Red (#FF0000)
Shows: Username, User ID, reason, timestamp
```

### Button Clicks (Blue)
```
Title: 🎮 Button Clicked
Color: Blue (#3447003)
Shows: User, button name
```

### Settings Changes (Varies)
```
Title: ✅ Logging Enabled / ❌ Logging Disabled
Color: Green or Red
Shows: User, setting changed
```

### Player Activity (Varies)
```
Title: 📍 Character Spawned / 💀 Player Died
Color: Blue or Red
Shows: Player name, location/time
```

### Hub Startup (Green)
```
Title: 🚀 Hub Started
Color: Green (#00FF00)
Shows: Hub name, version, active players
```

---

## Customization

### Add More Logging

Add to any button:

```lua
MainTab:AddButton("My Feature", function()
    print("Feature executed!")
    SendToDiscord(
        "🎮 My Feature Used",
        "Player clicked My Feature",
        3447003,
        {
            {
                name = "User",
                value = game.Players.LocalPlayer.Name,
                inline = true
            },
            {
                name = "Feature",
                value = "My Feature",
                inline = true
            }
        }
    )
end)
```

### Change Embed Colors

Discord embed colors use decimal RGB values:

```lua
-- Common colors
65280   -- Green (#00FF00)
16711680 -- Red (#FF0000)
3447003 -- Blue (#0066CC)
16776960 -- Yellow (#FFFF00)
9807270 -- Purple (#9600F6)
```

### Disable Logging Temporarily

Set webhook URL to empty string:

```lua
local DISCORD_WEBHOOK_URL = ""
```

The hub will still work, just without Discord logging.

### Custom Webhook Validation

Add server-side verification in your RVRSE webhook endpoint:

```javascript
// On your RVRSE server
POST /api/webhooks/validate
{
  "key": "RVRSE-XXXX-XXXX-XXXX-XXXX",
  "discordWebhook": "https://discord.com/api/webhooks/..."
}
```

---

## Use Cases

### Use Case 1: Developer Testing
- Log all test players joining your game
- Monitor feature usage during development
- Get real-time Discord alerts on errors

### Use Case 2: Game Pass Premium Hub
- Track who purchases game pass
- Log which features they use most
- Monitor suspicious multi-account activity

### Use Case 3: Community Game
- Real-time notifications when players join
- Track popular features by usage frequency
- Alert admins to player deaths/events
- Build Discord-based leaderboards

### Use Case 4: Security Monitoring
- Log all failed access attempts
- Alert on suspicious patterns
- Track unauthorized access attempts
- Build security analytics

---

## Troubleshooting

### "Discord webhook not configured"

**Problem:** Webhook URL contains "YOUR_WEBHOOK"

**Solution:**
1. Replace with actual webhook URL
2. Make sure URL starts with `https://discord.com/api/webhooks/`
3. Double-check for spaces or typos

### "Failed to log to Discord"

**Problem:** HttpPost call failing silently

**Solutions:**
1. Verify webhook URL is valid
2. Check Discord server/channel still exists
3. Make sure webhook isn't deleted
4. Check executor has internet permissions

### "No Discord messages appearing"

**Problem:** Webhook exists but no messages sent

**Checks:**
1. Webhook URL is correct (copy from Discord again)
2. Hub successfully loaded (check console for startup message)
3. Webhook channel permissions allow messages
4. No rate limiting (Discord limits ~10 messages/second)

### "Messages showing but missing formatting"

**Problem:** Fields appear blank or malformed

**Solutions:**
1. Check field names and values are strings
2. Make sure JSON encoding is valid
3. Verify embedded color value is valid decimal

### "Player activity not logging"

**Problem:** Character spawns/deaths don't send Discord messages

**Solutions:**
1. Make sure character already exists when script loads
2. Add to existing character if not spawning:
   ```lua
   if LocalPlayer.Character then
       -- Character already loaded, add events manually
   end
   ```
3. Check humanoid exists before connecting events

---

## Advanced: Webhook Rate Limiting

Discord limits webhook posts. If you have many players:

```lua
-- Implement rate limiting (optional)
local lastWebhookTime = 0
local webhookCooldown = 1 -- 1 second between posts

local function SendToDiscordRateLimited(title, description, color, fields)
    local now = os.time()
    if now - lastWebhookTime < webhookCooldown then
        return
    end
    lastWebhookTime = now
    SendToDiscord(title, description, color, fields)
end
```

---

## Advanced: Analytics Dashboard

Create a separate Discord channel just for analytics:

```lua
-- Separate webhook for analytics (different channel)
local ANALYTICS_WEBHOOK = "https://discord.com/api/webhooks/..."

local function LogAnalytics(event, data)
    -- Send to analytics webhook instead
end
```

Then create a Discord bot to:
- Parse analytics messages
- Build leaderboards
- Show usage graphs
- Send periodic reports

---

## Production Deployment

When deploying to production:

1. **Move webhook URL to server config:**
   ```lua
   -- Don't hardcode in script
   local WEBHOOK_URL = game:HttpGet(config_endpoint)
   ```

2. **Add rate limiting:**
   ```lua
   -- Prevent Discord spam from many concurrent players
   ```

3. **Log to multiple channels:**
   ```lua
   -- Separate webhooks for different event types
   ```

4. **Monitor webhook health:**
   ```lua
   -- Track failed posts and retry
   ```

---

## Security Notes

✅ **Good:**
- Webhooks don't expose keys or secrets
- Player data logged is non-sensitive (username, ID, public actions)
- Hub still works if Discord is down
- Logging is optional

⚠️ **Remember:**
- Don't log sensitive data (passwords, API keys)
- Anyone with webhook URL can spam your Discord
- Consider making webhook URL dynamic (fetched from server)
- Implement rate limiting for high-player games

---

## Next Steps

Once this example works:

1. **Add multiple webhooks** - Separate channels for different event types
2. **Build analytics bot** - Parse Discord messages to create dashboards
3. **Monitor patterns** - Track usage trends and peak times
4. **Integrate with database** - Persist logs for long-term analytics
5. **Add alerts** - Notify admins of important events

---

## Resources

- **Pattern 3 Docs:** [../RVRSE-PATTERNS-README.md](../RVRSE-PATTERNS-README.md)
- **Discord Webhook Guide:** https://discord.com/developers/docs/resources/webhook
- **RvrseUI Repo:** https://github.com/CoderRvrse/RvrseUI
- **RVRSE Repo:** https://github.com/CoderRvrse/rvrse-obfuscate

---

**Status:** ✅ Ready to use
**Last Updated:** November 4, 2025
**Maintained By:** RVRSE Team
