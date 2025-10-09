-- RvrseUI v3.0.0 - Diagnostic Loader (Developer-Grade)
-- Use this to diagnose loadstring failures and GitHub fetch issues

-- ============================================
-- STEP 1: Fetch with diagnostics
-- ============================================
local url = "https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"
print("[RvrseUI Diagnostic] Fetching:", url)

local ok, body = pcall(function()
	return game:HttpGet(url, true)  -- true = use cache headers
end)

if not ok then
	error("[RvrseUI] ❌ HttpGet failed: " .. tostring(body), 0)
end

-- ============================================
-- STEP 2: Validate response body
-- ============================================
print("[RvrseUI Diagnostic] Fetched", #body, "bytes")

if not body or #body < 100 then
	error("[RvrseUI] ❌ Body too short (len=" .. tostring(body and #body or 0) .. "). Likely 404/empty response.", 0)
end

-- Check for expected header comment
if not string.find(body, "RvrseUI v3.0.0", 1, true) then
	local preview = string.sub(body, 1, 120)
	if string.find(preview, "<!DOCTYPE", 1, true) or string.find(preview, "<html>", 1, true) then
		error("[RvrseUI] ❌ GitHub returned HTML (rate limit/404/Cloudflare). Preview:\n" .. preview, 0)
	else
		error("[RvrseUI] ❌ Unexpected body content. Expected 'RvrseUI v3.0.0' header. Preview:\n" .. preview, 0)
	end
end

print("[RvrseUI Diagnostic] ✓ Body looks like valid Lua (found version header)")

-- ============================================
-- STEP 3: Compile with loadstring
-- ============================================
local chunk, parseError = loadstring(body)

if not chunk then
	error("[RvrseUI] ❌ loadstring compile failed: " .. tostring(parseError), 0)
end

print("[RvrseUI Diagnostic] ✓ loadstring compiled successfully")

-- ============================================
-- STEP 4: Execute and return module
-- ============================================
local RvrseUI = chunk()

if not RvrseUI then
	error("[RvrseUI] ❌ Module executed but returned nil", 0)
end

if type(RvrseUI) ~= "table" then
	error("[RvrseUI] ❌ Module returned " .. type(RvrseUI) .. " instead of table", 0)
end

if not RvrseUI.CreateWindow then
	error("[RvrseUI] ❌ Module missing CreateWindow function", 0)
end

print("[RvrseUI Diagnostic] ✅ RvrseUI loaded successfully")
print("[RvrseUI Diagnostic] 📦 Version:", RvrseUI.Version and RvrseUI.Version.Full or "unknown")

-- ============================================
-- READY TO USE
-- ============================================
return RvrseUI
