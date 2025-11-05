# Example 2: Advanced Hub with VIP Whitelist

**Difficulty:** Intermediate
**Time to Setup:** 20 minutes
**Use Case:** Hub with VIP users and tiered access

---

## What This Example Shows

A complete hub that:
- ✅ Gives VIP users instant access (no key required)
- ✅ Requires keys for regular users
- ✅ Shows different features based on access level
- ✅ Supports override keys for special cases

---

## Setup Steps

### Step 1: Copy Pattern 2

```bash
# Windows
copy ..\pattern-2-remote-key-whitelist.lua .

# Linux/Mac
cp ../pattern-2-remote-key-whitelist.lua .
```

### Step 2: Add Your VIP Users

Edit `pattern-2-remote-key-whitelist.lua` and add your VIP user IDs:

```lua
local Config = {
    Whitelist = {
        Enabled = true,
        UserIDs = {
            123456789,  -- Replace with your user ID
            987654321,  -- Replace with co-owner ID
        },
        OverrideKeys = {
            "RVRSE-VIP-2024",
            "RVRSE-ADMIN",
        },
    },
    RemoteKeyURL = "https://your-server.herokuapp.com/keys/raw/your-product",
}
```

### Step 3: Configure main.lua

Update the VIP user list in `main.lua`:

```lua
local function IsUserVIP()
    local VIPUserIDs = {
        123456789,  -- Your Roblox user ID
        987654321,  -- Co-dev user ID
    }
    -- ... rest of function
end
```

### Step 4: Test

Combine and execute in Roblox executor (same as Example 1)

---

## How VIP System Works

### User Gets Fetched
1. User executes script
2. Pattern 2 checks if user ID is in whitelist
3. If YES → instant access, `OnWhitelistValid()` called
4. If NO → fetch key from server, validate it

### VIP Access
If user is VIP:
- No key needed
- Hub loads immediately
- VIP tab shows exclusive features
- All VIP buttons available

### Regular User Access
If user is regular:
- Key is required from server
- Validation happens with retry logic
- Hub loads after key validation
- Upgrade tab shown instead of VIP tab

---

## Customizing VIP Features

### Add VIP-Only Buttons

In `main.lua`, find the VIP tab section:

```lua
if isVIP then
    local VIPTab = RvrseUI:NewTab("VIP Features")

    VIPTab:AddButton("Your Feature", function()
        print("VIP feature executed")
    end)
end
```

### Give Different Titles to VIP Users

```lua
RvrseUI:Init({
    Title = "Premium Hub",
    Subtitle = isVIP and "VIP Access" or "Standard Access",
})
```

### Track VIP Stats

```lua
if isVIP then
    VIPTab:AddLabel("VIP Since: November 2024")
    VIPTab:AddLabel("Days Active: 45")
end
```

---

## Override Keys

Pattern 2 supports special override keys for:
- Admin access
- Emergency access
- Testing

Configure in pattern file:

```lua
OverrideKeys = {
    "RVRSE-ADMIN-2024",
    "RVRSE-EMERGENCY",
}
```

Users who enter these keys get instant access even if not on whitelist.

---

## Use Cases

### Use Case 1: Developer Hub
- VIP: You and co-developers (instant access for testing)
- Regular: Players with purchased keys

### Use Case 2: Game Pass Integration
- VIP: Players who own game pass (user ID stored after purchase)
- Regular: Free players (need key)

### Use Case 3: Discord Role Based
- VIP: Discord members (verified, user ID synced)
- Regular: Others (need key to join)

---

## Troubleshooting

### "I'm VIP but Pattern 2 doesn't recognize me"
**Solution:** Make sure your user ID is correct

```lua
print(game.Players.LocalPlayer.UserId)  -- Get your real ID
-- Copy this ID to the whitelist
```

### "VIP tab doesn't show"
**Check:**
1. Whitelist is enabled: `Enabled = true`
2. Your user ID is in the list
3. User IDs are numbers (not strings)

### "Override key doesn't work"
**Solution:** Make sure key is in OverrideKeys list, not just in database

---

## Advanced: Caching Validated Users

Pattern 2 can cache validated users so they don't need keys every time:

```lua
Whitelist = {
    RememberValidUsers = true,  -- Cache valid users locally
}
```

This saves validated user IDs locally so they get faster access next time.

---

## Security Notes

✅ **Good:**
- VIP list is in client code (expected for whitelist)
- Keys still required for non-VIP
- Server validates all keys

⚠️ **Remember:**
- Whitelist can be modified by attacker
- Use only for convenience, not security
- Real access control should be server-side
- Don't put secrets in whitelist

---

## Next Steps

1. **Add more VIP features** - Expand the VIP tab
2. **Sync with Discord** - Auto-add verified members as VIP
3. **Track VIP status** - Log who accesses as VIP
4. **Try Example 3** - Add webhook logging for analytics

---

## Resources

- **Pattern 2 Docs:** [../RVRSE-PATTERNS-README.md](../RVRSE-PATTERNS-README.md)
- **User ID Guide:** https://devforum.roblox.com/t/how-to-get-userid/
- **Whitelist Strategy:** https://en.wikipedia.org/wiki/Whitelist

---

**Status:** ✅ Ready to use
**Last Updated:** November 4, 2025
