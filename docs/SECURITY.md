# Security Best Practices - RvrseUI

## 🔒 Executor Safety & Detection Avoidance

This document outlines critical security practices to prevent detection when using RvrseUI.

---

## ⚠️ CRITICAL: Never Use `_G` for RvrseUI

### ❌ WRONG - Will Get Detected
```lua
-- DO NOT DO THIS!
_G.RvrseUI = loadstring(game:HttpGet(...))()
_G.MyHub = _G.RvrseUI:CreateWindow(...)
_G.enabled = true

-- Roblox can detect _G usage!
```

**Why it's bad:**
- `_G` is globally accessible across all scripts in the game
- Anti-cheat systems monitor `_G` for suspicious activity
- Easily flagged by logging/monitoring systems

---

## ✅ CORRECT - Safe Patterns

### Pattern 1: Local Variables (Recommended)
```lua
-- ✅ SAFE - Use local variables
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

local Window = RvrseUI:CreateWindow({
    Name = "My Hub",
    Theme = "Dark"
})

-- Store states locally
local enabled = true
local looping = false
```

**Why it's safe:**
- Local variables are script-scoped
- Not accessible from other scripts
- No global pollution
- No detection risk

---

### Pattern 2: getgenv() for Persistent State (Advanced)
```lua
-- ✅ SAFE - Use getgenv() for executor-private globals
if not getgenv().RvrseUI then
    getgenv().RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()
end

local RvrseUI = getgenv().RvrseUI

-- Store toggles in getgenv() (not _G!)
getgenv().loopEnabled = true

while getgenv().loopEnabled do
    task.wait()
    -- Your loop logic
end

-- To stop:
getgenv().loopEnabled = false
```

**Why it's safe:**
- `getgenv()` returns executor's **private** global environment
- NOT the same as `_G` (Roblox's global)
- Roblox cannot monitor executor-specific globals
- Persists across script reloads

---

## 🧠 Understanding the Difference

### `_G` (Roblox Global)
- Shared across ALL scripts in the game
- Monitored by anti-cheat systems
- **NEVER use for exploits/hubs!**

### `getgenv()` (Executor Global)
- **Executor-specific** private environment
- NOT accessible from Roblox's environment
- Safe for storing persistent state
- Unique to your executor instance

### `local` (Script-scoped)
- Only exists within current script
- Most secure option
- Best for non-persistent data

---

## 📋 RvrseUI Security Checklist

### ✅ What RvrseUI Does RIGHT

1. **No `_G` usage internally**
   - RvrseUI never touches `_G`
   - All state stored in module-scoped locals
   - Returns a clean table via `return RvrseUI`

2. **Proper variable scoping**
   - Uses `local RvrseUI = {}` at module level
   - No global pollution
   - No shadowing conflicts (verified in build scripts)

3. **Clean initialization**
   ```lua
   -- RvrseUI's internal pattern
   local RvrseUI = {}
   -- ... all code ...
   return RvrseUI  -- Returned to caller, not stored globally
   ```

### ⚠️ What YOU Should Do

1. **Always use local variables**
   ```lua
   local RvrseUI = loadstring(...)()
   local Window = RvrseUI:CreateWindow(...)
   ```

2. **For persistent toggles, use getgenv()**
   ```lua
   getgenv().myToggle = true
   ```

3. **Never do this:**
   ```lua
   _G.RvrseUI = ...        -- ❌ Detected!
   _G.Window = ...         -- ❌ Detected!
   _G.myToggle = ...       -- ❌ Detected!
   ```

---

## 🔄 Persistent State Pattern

If you need state that persists across script reloads:

```lua
-- Initialize once using getgenv()
if not getgenv().MyHubState then
    getgenv().MyHubState = {
        RvrseUI = nil,
        Window = nil,
        enabled = false,
        looping = false
    }
end

-- Load RvrseUI if not already loaded
if not getgenv().MyHubState.RvrseUI then
    getgenv().MyHubState.RvrseUI = loadstring(game:HttpGet(...))()
end

-- Create window if not already created
if not getgenv().MyHubState.Window then
    local RvrseUI = getgenv().MyHubState.RvrseUI
    getgenv().MyHubState.Window = RvrseUI:CreateWindow({
        Name = "My Hub"
    })

    -- Create UI elements...
    local Tab = getgenv().MyHubState.Window:CreateTab({ Title = "Main" })
    local Section = Tab:CreateSection("Settings")

    Section:CreateToggle({
        Text = "Enable Loop",
        Default = getgenv().MyHubState.looping,
        OnChanged = function(value)
            getgenv().MyHubState.looping = value
        end
    })

    getgenv().MyHubState.Window:Show()
else
    -- Window already exists, just show it
    getgenv().MyHubState.Window.Visible = true
end

-- Your loop (runs independently)
task.spawn(function()
    while task.wait(1) do
        if getgenv().MyHubState.looping then
            -- Loop logic here
        end
    end
end)
```

---

## 🛡️ Anti-Detection Checklist

Before releasing your hub:

- [ ] No `_G` usage anywhere
- [ ] All RvrseUI references are `local` or in `getgenv()`
- [ ] No global function pollution
- [ ] Toggles/states use `getgenv()` not `_G`
- [ ] No hardcoded game-specific values in global scope
- [ ] Clean up old instances before creating new ones

---

## 🚨 Common Mistakes

### Mistake 1: Storing UI in `_G`
```lua
-- ❌ WRONG
_G.UI = RvrseUI:CreateWindow(...)

-- ✅ CORRECT
local UI = RvrseUI:CreateWindow(...)
-- OR
getgenv().UI = RvrseUI:CreateWindow(...)
```

### Mistake 2: Sharing state via `_G`
```lua
-- ❌ WRONG
_G.aimbot = true

-- ✅ CORRECT
getgenv().aimbot = true
```

### Mistake 3: Global loops
```lua
-- ❌ WRONG
_G.loop = true
while _G.loop do
    task.wait()
end

-- ✅ CORRECT
getgenv().loop = true
while getgenv().loop do
    task.wait()
end
```

---

## 📖 Further Reading

- **CLAUDE.md** - Build system and architecture (no `_G` conflicts)
- **init.lua** - See how RvrseUI initializes internally (all locals)
- **examples/** - All examples use safe patterns

---

## ✅ Verification

To verify RvrseUI has no `_G` usage:

```bash
# Search for _G in codebase
grep -r "_G\." src/ init.lua
# (Should return no results)
```

---

**Last Updated:** 2025-10-18
**Version:** 4.3.0

**Remember:** `_G` = Detected | `getgenv()` = Safe | `local` = Safest
