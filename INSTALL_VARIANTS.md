# RvrseUI v3.0.0 - Installation Variants

This guide provides **production-grade loadstring variants** to prevent common failures (HTML responses, rate limits, parse errors).

---

## ⚠️ Common Issue: "attempt to call a nil value"

**What it means:**
```lua
local RvrseUI = loadstring(game:HttpGet(...))()  -- ← fails here
```

If you see this error on **line 3** of your script, it means:
- `loadstring(...)` returned `nil` (compile failed)
- The code tried to call `nil()` → "attempt to call a nil value"

**Root causes:**
1. GitHub returned **HTML** (404/rate limit/Cloudflare page) instead of Lua
2. Empty/partial response (network timeout)
3. Syntax error in fetched body (rare, but possible)

**Fix:** Use one of the hardened variants below.

---

## 🚀 Installation Variants

### A) Latest (Main Branch) - With Error Handling

```lua
-- Fetch from main branch with diagnostic error handling
local url = "https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"
local body = game:HttpGet(url, true)

-- Validate body before compiling
if not body or #body < 100 or not string.find(body, "RvrseUI v3.0.0", 1, true) then
    error("[RvrseUI] Bad response from GitHub (len=" .. tostring(body and #body or 0) ..
          "). Likely rate limit/HTML/404. Preview:\n" .. tostring(string.sub(body or "", 1, 120)), 0)
end

-- Compile with error reporting
local chunk, parseError = loadstring(body)
if not chunk then
    error("[RvrseUI] loadstring failed: " .. tostring(parseError), 0)
end

local RvrseUI = chunk()
```

**Pros:** Always latest version
**Cons:** May change unexpectedly (use for testing/development)

---

### B) Pinned Version (Recommended for Production)

```lua
-- Pin to specific version tag (v3.0.0) for reproducibility
local url = "https://raw.githubusercontent.com/CoderRvrse/RvrseUI/v3.0.0/RvrseUI.lua"
local chunk, err = loadstring(game:HttpGet(url, true))

if not chunk then
    error("[RvrseUI] Failed to load v3.0.0: " .. tostring(err), 0)
end

local RvrseUI = chunk()
```

**Pros:** Reproducible, version-locked, immune to main branch changes
**Cons:** Needs manual update when new version releases

---

### C) Pinned Commit (For Forensics/Debugging)

```lua
-- Pin to exact commit SHA (replace <commit_sha> with actual hash)
local commit = "a5b3197"  -- Replace with your commit
local url = "https://raw.githubusercontent.com/CoderRvrse/RvrseUI/" .. commit .. "/RvrseUI.lua"
local chunk, err = loadstring(game:HttpGet(url, true))

if not chunk then
    error("[RvrseUI] Failed to load commit " .. commit .. ": " .. tostring(err), 0)
end

local RvrseUI = chunk()
```

**Pros:** Exact source control, perfect for debugging
**Cons:** Most verbose, requires commit lookup

---

### D) Full Diagnostic Loader (Developer Mode)

```lua
-- Use DIAGNOSTIC_LOADER.lua for comprehensive error reporting
-- This shows exactly what went wrong (HTML response, parse error, etc.)
local url = "https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/DIAGNOSTIC_LOADER.lua"
local RvrseUI = loadstring(game:HttpGet(url, true))()
```

**Pros:** Detailed error messages, prints fetch progress
**Cons:** Slower, extra prints (only use when debugging)

---

## 🔧 Quick Triage

If you get "attempt to call a nil value":

1. **Replace your one-liner** with variant A (error handling)
2. **Read the error message** - it will tell you:
   - If GitHub returned HTML (rate limit)
   - If the response was empty/short
   - The exact parse error location
3. **Switch to variant B** (pinned version) for production scripts

---

## 🚫 Anti-Patterns (Don't Do This)

### ❌ Using `.. tick()` for cache busting
```lua
-- BAD: Doesn't help if GitHub returns HTML, defeats reproducibility
local RvrseUI = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua?" .. tick()
))()
```

**Why:**
- Roblox caches based on GitHub's cache headers, not query params
- Adding `?timestamp` doesn't bypass rate limits
- Makes debugging impossible (every load is different)

**Fix:** Use `game:HttpGet(url, true)` (second arg respects cache headers) + pin to version tag

---

### ❌ No error handling on loadstring
```lua
-- BAD: Silent failure, "call a nil value" with no context
local RvrseUI = loadstring(game:HttpGet(...))()
```

**Fix:** Always check `chunk, err = loadstring(...)` and handle `nil` case

---

## 📦 Recommended Setup (Copy-Paste Ready)

```lua
--[[
    RvrseUI v3.0.0 - Production Setup
    - Pinned to version tag (reproducible)
    - Error handling (diagnostic messages)
    - Cache-friendly (respects GitHub headers)
]]

local VERSION = "v3.0.0"
local url = "https://raw.githubusercontent.com/CoderRvrse/RvrseUI/" .. VERSION .. "/RvrseUI.lua"

local body = game:HttpGet(url, true)
local chunk, err = loadstring(body)

if not chunk then
    error("[RvrseUI] Failed to load " .. VERSION .. ": " .. tostring(err) ..
          "\nFirst 120 chars of response:\n" .. string.sub(body or "", 1, 120), 0)
end

local RvrseUI = chunk()

-- Now use RvrseUI as normal
local Window = RvrseUI:CreateWindow({ Name = "My Script" })
-- ...
```

---

## 🧪 Testing Your Setup

After installing, verify it works:

```lua
-- This should print version info without errors
print("RvrseUI loaded:", RvrseUI.Version.Full)
print("Build:", RvrseUI.Version.Build)
print("Hash:", RvrseUI.Version.Hash)

-- Create test window
local Window = RvrseUI:CreateWindow({ Name = "Test" })
local Tab = Window:CreateTab({ Title = "Main" })
Tab:CreateSection("Test"):CreateButton({
    Text = "Click Me",
    Callback = function()
        print("✅ RvrseUI working!")
    end
})
```

If you see the version prints and can click the button → **setup successful**.

---

## 🆘 Still Getting Errors?

1. Copy the **full error message** (including stack trace)
2. Check if error message contains:
   - `<!DOCTYPE` or `<html>` → GitHub rate limit, wait 5 minutes
   - `attempt to index nil` → Wrong version/URL typo
   - `loadstring failed: [lua]:X: <parse error>` → File corruption, re-fetch
3. Try the **Diagnostic Loader** (variant D) for detailed output
4. Report issue at: https://github.com/CoderRvrse/RvrseUI/issues

---

**TL;DR:** Use **Variant B** (pinned version) for production scripts. It's reproducible, has error handling, and won't break when main branch updates.
