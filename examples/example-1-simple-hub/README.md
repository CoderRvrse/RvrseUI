# Example 1: Simple Hub with Remote Key Loader

**Difficulty:** Beginner
**Time to Setup:** 15 minutes
**Use Case:** Basic hub with simple key validation

---

## What This Example Shows

A complete, working Roblox hub that:
- ✅ Loads with RVRSE Pattern 1 (remote key validation)
- ✅ Uses RvrseUI for the interface
- ✅ Requires a valid key from your RVRSE server
- ✅ Demonstrates simple game loading workflow

---

## Prerequisites

1. **RVRSE Installed** - `npm install -g rvrse-obfuscate`
2. **RVRSE Server Running** - Remote key endpoint deployed
3. **Valid Key Generated** - Via `npm run generate`
4. **Roblox Executor** - Codex, Synapse X, or similar

---

## Setup Steps

### Step 1: Get the Pattern File

Copy the Pattern 1 file to this directory:

```bash
# Windows
copy ..\pattern-1-remote-key-only.lua .

# Linux/Mac
cp ../pattern-1-remote-key-only.lua .
```

### Step 2: Update Configuration

Edit `main.lua` and update the Pattern 1 configuration:

```lua
-- Find this section in pattern-1-remote-key-only.lua:
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
- `YOUR-PRODUCT` with your product code (from `npm run generate`)

### Step 3: Prepare the Script

Combine pattern and main code:

```bash
# Windows
type pattern-1-remote-key-only.lua main.lua > combined.lua

# Linux/Mac
cat pattern-1-remote-key-only.lua main.lua > combined.lua
```

### Step 4: Test in Executor

1. Open Roblox executor (Codex, Synapse, etc.)
2. Join a Roblox game
3. Copy entire contents of `combined.lua`
4. Paste into executor
5. Execute (F9 or Execute button)

### Step 5: Expected Output

**If key is valid:**
```
[RVRSE LOADER] 🚀 RVRSE Remote Key Loader Started
[RVRSE LOADER] 🔄 Fetching key from remote server...
[RVRSE LOADER] ✅ Key fetched successfully
[RVRSE LOADER] ✅ Key validated successfully!
[RVRSE LOADER] 🎮 Access granted - Loading game...
🚀 Hub Loaded Successfully!
RvrseUI initialized...
🎉 Hub initialization complete!
```

**If key is invalid:**
```
[RVRSE LOADER] 🚀 RVRSE Remote Key Loader Started
[RVRSE LOADER] 🔄 Fetching key from remote server...
[RVRSE LOADER] ❌ Failed to fetch key
[RVRSE LOADER] Attempt 1/3
[RVRSE LOADER] 🔄 Retrying...
[RVRSE LOADER] ❌ Failed after 3 attempts
[RVRSE LOADER] 🚪 Kicking player...
```

---

## File Structure

```
example-1-simple-hub/
├── README.md                           (This file)
├── main.lua                            (Hub code with callbacks)
└── pattern-1-remote-key-only.lua      (Add from ../pattern-1-remote-key-only.lua)
```

---

## How It Works

### 1. Pattern 1 Initialization
When you execute the script, Pattern 1:
1. Starts the loader
2. Fetches your key from the server
3. Validates the key exists

### 2. Key Validation Success
Pattern 1 calls `OnKeyValid(key)` when validation succeeds:
```lua
function OnKeyValid(key)
    print("✅ Key validated successfully!")
    LoadHub()  -- This loads your game code
end
```

### 3. Hub Loading
The `LoadHub()` function:
1. Loads RvrseUI library
2. Initializes UI with tabs
3. Sets up buttons, toggles, sliders
4. Connects player events

### 4. Game Running
After hub loads, game code executes normally:
- Players can interact with UI
- Game logic runs as expected
- Character events work normally

---

## Customization

### Change UI Theme

Edit the RvrseUI initialization:

```lua
RvrseUI:Init({
    Title = "My Awesome Hub",
    Theme = "Dark"  -- Change to "Light" or "Custom"
})
```

### Add More Features

Add buttons to your tab:

```lua
MainTab:AddButton("Kill Player", function()
    LocalPlayer.Character.Humanoid.Health = 0
end)

MainTab:AddButton("Teleport", function()
    LocalPlayer.Character:MoveTo(Vector3.new(0, 100, 0))
end)
```

### Handle Key Failure

Customize error handling:

```lua
function OnKeyInvalid(reason)
    if reason:find("timeout") then
        print("⚠️ Server is down, retrying...")
    else
        print("❌ Invalid key")
    end
end
```

---

## Troubleshooting

### "Failed to fetch key"
**Problem:** Server URL is wrong or server is down

**Solutions:**
1. Check server URL in config
2. Test endpoint in browser: `https://your-server/keys/raw/your-product`
3. Make sure RVRSE server is running: `npm run server`

### "Access denied: No valid key found"
**Problem:** Key doesn't exist or is expired

**Solutions:**
1. Generate a new key: `npm run generate`
2. Update RemoteKeyURL in config
3. Check key isn't expired in your database

### Hub doesn't load after key validation
**Problem:** `OnKeyValid()` function not being called

**Solutions:**
1. Make sure main.lua is included after pattern file
2. Check function definitions are correct
3. Look at console for error messages

### "Attempt to call nil value"
**Problem:** RvrseUI load failed

**Solutions:**
1. Check internet connection
2. Verify GitHub URL is correct
3. Try loading RvrseUI URL directly in browser

---

## Next Steps

Once this example works:

1. **Try Example 2:** Advanced hub with whitelist - gives VIP users instant access
2. **Try Example 3:** Monitored hub with webhook - logs all activity to Discord
3. **Add Obfuscation:** Use RVRSE obfuscator to hide your code
4. **Deploy to Production:** Share key with players and run your hub

---

## Security Notes

✅ **Good Practice:**
- Server validates keys (never trust client)
- Keys are fetched fresh (not cached permanently)
- Multiple attempts before kicking player

⚠️ **Remember:**
- This is access control, not security
- Client code can always be modified
- Validate important game actions server-side
- Never put secrets in client code

---

## Resources

- **Pattern 1 Docs:** [../RVRSE-PATTERNS-README.md](../RVRSE-PATTERNS-README.md)
- **RVRSE Guide:** [../../docs/rvrseui-loader-guide.md](../../docs/rvrseui-loader-guide.md)
- **RvrseUI Repo:** https://github.com/CoderRvrse/RvrseUI
- **RVRSE Repo:** https://github.com/CoderRvrse/rvrse-obfuscate

---

**Status:** ✅ Ready to use
**Last Updated:** November 4, 2025
**Maintained By:** RVRSE Team
