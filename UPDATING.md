# How to Update RvrseUI

## Your UI Shows Old Version?

If the version badge shows an old version (e.g., v2.3.2 instead of v2.3.6), you need to **reload the script**.

### Why This Happens
RvrseUI is loaded into your Roblox game's memory when you first run it. Any updates to the GitHub repository **won't automatically appear** in your running game - you need to reload.

---

## How to Update

### Method 1: Reload the Script (Recommended)
1. **Stop your current game** (press Stop in Roblox Studio, or leave the game if in Player)
2. **Re-run your script** that loads RvrseUI
3. The latest version will be fetched from GitHub

### Method 2: Force Refresh (If using loadstring)
If you're using `loadstring()` to load RvrseUI:

```lua
-- Add a cache buster to force refresh
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua?" .. tick()))()
```

The `.. tick()` adds a timestamp to the URL, forcing Roblox to fetch a fresh copy instead of using cached data.

### Method 3: Check Version Manually
```lua
print(RvrseUI.Version.Full)  -- Should print: 2.3.6
print(RvrseUI.Version.Hash)  -- Should print: E8A3C5F1
```

---

## Current Latest Version
- **Version**: 2.3.6
- **Build**: 20250930
- **Hash**: E8A3C5F1
- **Channel**: Stable

---

## Common Errors After Updates

### Error: "attempt to index nil with 'Switch'"
**Cause**: Old cached version of RvrseUI running
**Fix**: Reload the script completely (stop game → restart)

### Error: "attempt to call a nil value" (SaveConfiguration)
**Cause**: Running v2.3.5 or earlier
**Fix**: Update to v2.3.6+ which fixes this critical bug

### Version Badge Shows Wrong Version
**Cause**: Cached version in memory
**Fix**: Reload the script to fetch latest from GitHub

---

## Verifying You Have Latest Version

Run this in your script:
```lua
if RvrseUI.Version.Patch < 6 then
  warn("You are running an OLD version of RvrseUI!")
  warn("Current: v" .. RvrseUI.Version.Full)
  warn("Latest: v2.3.6")
  warn("Please reload your script to get the latest version.")
end
```

---

## Auto-Update Check (Coming Soon)
Future versions will include automatic update checking that notifies you when a new version is available.
