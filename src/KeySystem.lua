-- KeySystem.lua
-- Advanced key validation system with multiple authentication methods
-- Supports: String keys, Remote keys, HWID whitelist, Discord webhooks

local KeySystem = {}
local deps

-- The reason the key window reports when the PLAYER closed it, rather than a
-- key being refused. The host tells one from the other: a refused key is a
-- mistake, a closed window means stop everything (see WindowBuilder).
KeySystem.ClosedReason = "key window closed"

-- How the free-key watcher paces itself. It used to give up after 5 minutes,
-- which is shorter than the ads it waits for (4-6 minutes measured) and far
-- shorter than the 60-minute wait the provider sometimes offers instead. The
-- player was told "go back to the game, it unlocks by itself" and then had to
-- come back and tap anyway. It now slows down instead of stopping, and the
-- SERVER decides when a run is over.
local FREE_FAST_FOR = 300   -- check every poll_after seconds for 5 minutes...
local FREE_SLOW_GAP = 20    -- ...then every 20 seconds, for as long as it takes
local FREE_GIVE_UP = 7200   -- a safety net only: the server's run dies long before

function KeySystem:Initialize(dependencies)
	deps = dependencies
end

-- === LUAVM-Rvrse license bridge =========================================
-- Lets a hub validate its key against a LUAVM-Rvrse license server (the one
-- that device-locks keys and enforces expiry/bans) through the SAME key window.
-- The server is the authority, so the valid key list is not in the file.
-- Opt in with KeySettings.License = { Endpoint = "...", BuildId = "...", Secret = "..." }.

-- === paste-proofing ====================================================
-- A key that travels through a clipboard, Discord, a browser or a phone
-- keyboard picks up junk: a trailing newline, a non-breaking space, a
-- zero-width character, a "smart" dash from autocorrect. The key then LOOKS
-- right, is refused, and the person has no way to tell why. So we clean it.

-- Characters that can never be part of a key. Byte sequences, so this works
-- without utf8 support on any executor.
local KEY_INVISIBLE = {
	["\239\187\191"] = "",  -- U+FEFF byte-order mark / zero-width no-break space
	["\226\128\139"] = "",  -- U+200B zero-width space
	["\226\128\140"] = "",  -- U+200C zero-width non-joiner
	["\226\128\141"] = "",  -- U+200D zero-width joiner
	["\194\173"] = "",      -- U+00AD soft hyphen
	["\194\160"] = " ",     -- U+00A0 non-breaking space
	["\226\128\168"] = " ", -- U+2028 line separator
	["\226\128\169"] = " ", -- U+2029 paragraph separator
}
-- Every dash that autocorrect or a web page substitutes for a plain hyphen.
local KEY_DASHES = {
	["\226\128\144"] = "-", -- U+2010 hyphen
	["\226\128\145"] = "-", -- U+2011 non-breaking hyphen
	["\226\128\146"] = "-", -- U+2012 figure dash
	["\226\128\147"] = "-", -- U+2013 en dash
	["\226\128\148"] = "-", -- U+2014 em dash
	["\226\136\146"] = "-", -- U+2212 minus sign
	["\239\188\141"] = "-", -- U+FF0D fullwidth hyphen
}

-- Safe clean: strips ONLY what can never belong to a key, so it is safe for
-- any key system. Returns the clean key and whether anything was changed.
function KeySystem:CleanKey(raw)
	if type(raw) ~= "string" then return "", false end
	local s = raw
	for from, to in pairs(KEY_INVISIBLE) do s = s:gsub(from, to) end
	for from, to in pairs(KEY_DASHES) do s = s:gsub(from, to) end
	s = s:gsub("[\r\n\t]", " ")
	s = s:match("^%s*(.-)%s*$") or s
	-- a key copied together with its quotation marks
	local unquoted = s:match('^"(.*)"$') or s:match("^'(.*)'$")
	if unquoted then s = unquoted:match("^%s*(.-)%s*$") or unquoted end
	return s, (s ~= raw)
end

-- Harder repair, only tried AFTER the clean key was refused, so it can never
-- change the meaning of a key that was already accepted: drop spaces that were
-- pasted into the middle, and (for our own keys) fix the case.
function KeySystem:RepairKey(clean, ourFormat)
	local s = (clean or ""):gsub("%s+", "")
	if ourFormat then s = s:upper() end
	return s
end

-- Say precisely what is wrong with a key of OUR shape
-- (RVRSE-AB3CD-EF4GH-JK5MN, from an alphabet that leaves out 0, O, 1 and I).
-- Advisory only -- the server is always the authority. Returns nil if fine.
function KeySystem:ScreenKey(key)
	key = key or ""
	if key == "" then return "Please enter your key" end
	-- Only advise about our own format; another server may use a different one.
	if not key:upper():match("^RVRSE%-") then return nil end
	local banned = key:upper():match("[01OI]")
	if banned then
		return ("Keys never contain 0, O, 1 or I - check the '%s' in yours"):format(banned)
	end
	local blocks = {}
	for b in key:upper():gmatch("[^%-]+") do blocks[#blocks + 1] = b end
	if #blocks ~= 4 or #blocks[2] ~= 5 or #blocks[3] ~= 5 or #blocks[4] ~= 5 then
		return "A key looks like RVRSE-AB3CD-EF4GH-JK5MN (four blocks)"
	end
	return nil
end

-- This device's id, computed EXACTLY like the LUAVM loader (UserId, then
-- RbxAnalyticsService:GetClientId, then gethwid -- last available wins) so one
-- key locks to one device across the key window and a full-lock unlock alike.
local function luavmDeviceId()
	local hwid = "MOCK_HWID_NO_PLAYER"
	pcall(function()
		local lp = game:GetService("Players").LocalPlayer
		if lp then hwid = tostring(lp.UserId) end
	end)
	pcall(function() hwid = tostring(game:GetService("RbxAnalyticsService"):GetClientId()) end)
	pcall(function() if gethwid then hwid = tostring(gethwid()) end end)
	return hwid
end

local function luavmIdentity()
	local uid, name = "", ""
	pcall(function()
		local lp = game:GetService("Players").LocalPlayer
		if lp then
			uid = tostring(lp.UserId)
			name = tostring(lp.Name)
		end
	end)
	return uid, name
end

-- POST JSON with the executor's own HTTP client (works without the game HTTP
-- toggle), HttpService:PostAsync as a fallback. Returns the response body text.
local function luavmPostJson(url, bodyTable, extraHeaders)
	local HttpService = game:GetService("HttpService")
	local body = HttpService:JSONEncode(bodyTable)
	local headers = { ["Content-Type"] = "application/json" }
	if extraHeaders then
		for k, v in pairs(extraHeaders) do headers[k] = v end
	end

	local envs = {}
	local okg, g = pcall(function() return getgenv and getgenv() end)
	if okg and type(g) == "table" then envs[#envs + 1] = g end
	envs[#envs + 1] = _G
	local reqfns = {}
	local function add(v) if type(v) == "function" then reqfns[#reqfns + 1] = v end end
	for _, env in ipairs(envs) do
		local syn = rawget(env, "syn")
		if type(syn) == "table" then add(rawget(syn, "request")) end
		add(rawget(env, "http_request"))
		add(rawget(env, "request"))
	end
	for _, fn in ipairs(reqfns) do
		local ok, resp = pcall(fn, { Url = url, Method = "POST", Headers = headers, Body = body })
		if ok and type(resp) == "table" and type(resp.Body) == "string" and resp.Body ~= "" then
			return resp.Body
		end
	end
	local out
	pcall(function() out = HttpService:PostAsync(url, body, Enum.HttpContentType.ApplicationJson) end)
	return out
end

local function luavmHumanTime(seconds)
	seconds = math.floor(tonumber(seconds) or 0)
	if seconds >= 86400 then return math.floor(seconds / 86400) .. "d"
	elseif seconds >= 3600 then return math.floor(seconds / 3600) .. "h"
	elseif seconds >= 60 then return math.floor(seconds / 60) .. "m"
	else return seconds .. "s" end
end

-- What the free key button says before anything has happened. The flow changes
-- it to an "I am done" prompt once a link has been handed over, and back again
-- if that link goes stale.
local FREE_KEY_LABEL = "🎟️  Get a free key (24 hours)"

-- Free keys paid for by ads (LootLabs). The licence server mints a 24-hour key
-- once a player finishes an ad run.
--
-- Nothing here is hub-specific on purpose: any hub that already sets
-- KeySettings.License gets the button with no extra setup, and a server with
-- free keys switched off answers {"status":"off"}, which makes the button take
-- itself away. Opt out with License.FreeKey = false.
--
-- The free routes sit beside the validate route under the same /api/v1 prefix,
-- so they are derived from the endpoint the hub already has.
-- License.FreeEndpoint overrides the base if a server ever splits them apart.
local function luavmFreeUrl(license, leaf)
	if type(license) ~= "table" then return nil end
	if license.FreeKey == false then return nil end
	local base = license.FreeEndpoint
	if type(base) ~= "string" or base == "" then
		local ep = license.Endpoint
		if type(ep) ~= "string" or ep == "" then return nil end
		base = ep:match("^(.-)/api/v1/") or ep:match("^(https?://[^/]+)")
	end
	if type(base) ~= "string" or base == "" then return nil end
	base = base:gsub("/+$", "")
	return base .. "/api/v1/free/" .. leaf
end

-- An executor cannot open a browser, so the clipboard is the hand-off for the
-- ad link.
--
-- This used to carry its own copy of the search, which read the environment
-- with rawget and so missed every executor that serves setclipboard through a
-- metatable -- indistinguishable, to the player, from an executor that cannot
-- copy at all, on the one screen where losing the link costs them the key.
-- UIHelpers.copyText is now the only implementation; do not reintroduce one.
local function luavmCopyText(text)
	if deps and deps.UIHelpers and deps.UIHelpers.copyText then
		return deps.UIHelpers.copyText(text)
	end
	return false
end

-- Validate a key against a LUAVM-Rvrse license server. Returns (ok, message).
-- Same request shape the LUAVM loader sends, so one key works in both places.
function KeySystem:ValidateLicense(inputKey, license)
	local url = license.Endpoint
	if type(url) ~= "string" or url == "" then
		return false, "License endpoint not set", "CONFIG"
	end
	local uid, uname = luavmIdentity()
	local headers = nil
	if license.Secret and license.Secret ~= "" then
		headers = { ["X-LUAVM-SECRET"] = tostring(license.Secret) }
	end
	local respBody = luavmPostJson(url, {
		key = inputKey or "",
		hardware_id = luavmDeviceId(),
		build_id = license.BuildId,
		user_id = uid,
		username = uname,
	}, headers)
	if type(respBody) ~= "string" or respBody == "" then
		return false, "Could not reach the license server", "NETWORK"
	end
	local ok, decoded = pcall(function()
		return game:GetService("HttpService"):JSONDecode(respBody)
	end)
	if not ok or type(decoded) ~= "table" or not decoded.status then
		return false, "Unexpected server response", "BADRESPONSE"
	end
	local status = tostring(decoded.status)
	if status == "VALID" then
		local msg = "Licensed"
		if tonumber(decoded.expires_in_seconds) and decoded.expires_in_seconds > 0 then
			msg = msg .. " (" .. luavmHumanTime(decoded.expires_in_seconds) .. " left)"
		elseif tonumber(decoded.expires_in_days) and decoded.expires_in_days > 0 then
			msg = msg .. " (" .. tostring(decoded.expires_in_days) .. " day(s) left)"
		end
		return true, msg, "VALID"
	elseif status == "EXPIRED" then
		return false, "This key has expired", "EXPIRED"
	elseif status == "BANNED" then
		return false, "This key is banned", "BANNED"
	else
		return false, "Invalid key or wrong device", "INVALID"
	end
end

-- A full-lock LUAVM build cannot start at all until the license server has
-- said VALID: that answer is literally what decrypts it. The build leaves the
-- answer in getgenv().LUAVM_LICENSE_OK, so the key window can take its word
-- for it instead of asking the server the identical question a second later.
-- Only a receipt for THIS key, marked VALID, and only minutes old, counts.
--
-- This is not a security step and is not meant to be one: the key window has
-- always been a front door (the script is already running by the time it
-- appears), and the real lock is full-lock's encryption. A forged receipt
-- skips a front door, not a lock.
function KeySystem:ReadLicenseReceipt(inputKey, env)
	if type(env) ~= "table" then
		return false
	end
	local receipt = env.LUAVM_LICENSE_OK
	if type(receipt) ~= "table" then
		return false
	end
	if tostring(receipt.status) ~= "VALID" then
		return false
	end
	if type(receipt.key) ~= "string" or receipt.key == "" then
		return false
	end
	if KeySystem:CleanKey(receipt.key) ~= KeySystem:CleanKey(inputKey) then
		return false
	end
	-- A receipt with no age, or a stale one, is not worth trusting: ask the
	-- server instead. An older build that leaves no stamp simply re-checks,
	-- exactly as it did before.
	local at = tonumber(receipt.at)
	if not at then
		return false
	end
	local okNow, now = pcall(os.time)
	if not okNow or not tonumber(now) then
		return false
	end
	local age = now - at
	if age < -60 or age > 300 then
		return false
	end
	local msg = "Licensed"
	local secs = tonumber(receipt.expires_in_seconds)
	local days = tonumber(receipt.expires_in_days)
	if secs and secs > 0 then
		msg = msg .. " (" .. luavmHumanTime(secs) .. " left)"
	elseif days and days > 0 then
		msg = msg .. " (" .. tostring(days) .. " day(s) left)"
	end
	return true, msg, "VALID"
end
-- === end LUAVM-Rvrse license bridge =====================================

-- Validate key against configured settings
function KeySystem:ValidateKey(inputKey, settings)
	local keySettings = settings.KeySettings or {}

	-- A pasted key almost always carries junk (a trailing newline, a hidden
	-- character, a smart dash). Clean it before ANY method sees it, or a
	-- perfectly good key is refused and nobody can see why.
	inputKey = KeySystem:CleanKey(inputKey)

	-- Method 0: LUAVM-Rvrse license server (remote; device-locked, expiry, ban).
	-- The server decides, so the valid keys are not written into the file.
	if keySettings.License and type(keySettings.License) == "table" and keySettings.License.Endpoint then
		local ok, msg, status = KeySystem:ValidateLicense(inputKey, keySettings.License)
		if ok then return true, msg end

		-- Only a real "no" is worth a second try: a network blip, an expired or
		-- a banned key would say the same thing again.
		if status == "INVALID" then
			local repaired = KeySystem:RepairKey(inputKey, true)
			if repaired ~= "" and repaired ~= inputKey then
				local ok2, msg2 = KeySystem:ValidateLicense(repaired, keySettings.License)
				if ok2 then
					-- A debug line must never be able to break a key check.
					if deps and deps.Debug and deps.Debug.printf then
						deps.Debug.printf("[KeySystem] key accepted after tidying it up")
					end
					return true, msg2
				end
			end
			-- Still refused: if we can see what is wrong with it, say that
			-- instead of a flat "invalid".
			local hint = KeySystem:ScreenKey(repaired)
			if hint then return false, hint end
		end
		return false, msg
	end

	-- Method 1: Custom validator function
	if keySettings.Validator and type(keySettings.Validator) == "function" then
		local success, result = pcall(keySettings.Validator, inputKey)
		if success and result == true then
			return true, "Custom validation passed"
		end
		return false, "Invalid key"
	end

	-- Method 2: HWID/UserID whitelist
	if keySettings.Whitelist and type(keySettings.Whitelist) == "table" then
		local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
		local userId = tostring(game.Players.LocalPlayer.UserId)

		for _, entry in ipairs(keySettings.Whitelist) do
			if entry == hwid or entry == userId or entry == inputKey then
				return true, "Whitelist validated"
			end
		end
	end

	-- Method 3: Table of valid keys
	if keySettings.Keys and type(keySettings.Keys) == "table" then
		for _, validKey in ipairs(keySettings.Keys) do
			if inputKey == validKey then
				return true, "Key matched"
			end
		end
	end

	-- Method 4: Single key string (legacy Rayfield compatibility)
	if keySettings.Key and type(keySettings.Key) == "string" then
		if inputKey == keySettings.Key then
			return true, "Key matched"
		end
	end

	return false, "Invalid key"
end

-- Fetch remote key from URL
function KeySystem:FetchRemoteKey(url)
	local success, result = pcall(function()
		return game:HttpGet(url, true)
	end)

	if success then
		-- Strip whitespace and newlines
		result = result:gsub("%s+", "")
		return true, result
	end

	return false, "Failed to fetch remote key"
end

-- Save validated key to file
function KeySystem:SaveKey(fileName, key)
	local folderPath = "RvrseUI/KeySystem"
	local filePath = folderPath .. "/" .. fileName .. ".key"

	-- Create folder if it doesn't exist
	if not isfolder("RvrseUI") then
		makefolder("RvrseUI")
	end
	if not isfolder(folderPath) then
		makefolder(folderPath)
	end

	-- Save key
	local success, err = pcall(function()
		writefile(filePath, key)
	end)

	return success, err
end

-- Load saved key from file
function KeySystem:LoadSavedKey(fileName)
	local filePath = "RvrseUI/KeySystem/" .. fileName .. ".key"

	if isfile(filePath) then
		local success, key = pcall(function()
			return readfile(filePath)
		end)

		if success then
			return true, key
		end
	end

	return false, nil
end

-- Send webhook notification (Discord logging)
function KeySystem:SendWebhook(webhookUrl, data)
	if not webhookUrl or webhookUrl == "" then
		return
	end

	local payload = {
		content = "",
		embeds = {
			{
				title = data.Title or "Key System Event",
				description = data.Description or "",
				color = data.Color or 5814783, -- Default blue
				fields = {
					{
						name = "Username",
						value = game.Players.LocalPlayer.Name,
						inline = true
					},
					{
						name = "User ID",
						value = tostring(game.Players.LocalPlayer.UserId),
						inline = true
					},
					{
						name = "Input Key",
						value = data.Key or "N/A",
						inline = false
					},
					{
						name = "Result",
						value = data.Result or "Unknown",
						inline = false
					},
					{
						name = "Timestamp",
						value = os.date("%Y-%m-%d %H:%M:%S"),
						inline = false
					}
				},
				footer = {
					text = "RvrseUI Key System"
				}
			}
		}
	}

	local success, err = pcall(function()
		local HttpService = game:GetService("HttpService")
		local jsonPayload = HttpService:JSONEncode(payload)

		request({
			Url = webhookUrl,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json"
			},
			Body = jsonPayload
		})
	end)

	if not success then
		warn("[KeySystem] Webhook failed:", err)
	end
end

-- Create key validation UI
-- Start an ad run. Returns (status, data, message):
--   "go"        data.loot_url + data.code -- send the player to the link
--   "ready"     data.key -- this device already holds a live free key, no ads
--   "off"       this server does not do free keys
--   "slow_down" too many starts from this device or address
--   "error"     message says what went wrong
function KeySystem:StartFreeKey(license)
	local url = luavmFreeUrl(license, "start")
	if not url then return "off", nil, "Free keys are not set up" end
	local uid, uname = luavmIdentity()
	local respBody = luavmPostJson(url, {
		hardware_id = luavmDeviceId(),
		build_id = license.BuildId,
		user_id = uid,
		username = uname,
	})
	if type(respBody) ~= "string" or respBody == "" then
		return "error", nil, "Could not reach the key server"
	end
	local ok, decoded = pcall(function()
		return game:GetService("HttpService"):JSONDecode(respBody)
	end)
	if not ok or type(decoded) ~= "table" or not decoded.status then
		return "error", nil, "Unexpected server response"
	end
	local status = tostring(decoded.status)
	if status == "go" then
		local hasLink = type(decoded.loot_url) == "string" and decoded.loot_url ~= ""
		local hasCode = type(decoded.code) == "string" and decoded.code ~= ""
		if not (hasLink and hasCode) then
			return "error", nil, "The server did not send a link"
		end
		return "go", decoded, "Link ready"
	elseif status == "ready" then
		if type(decoded.key) ~= "string" or decoded.key == "" then
			return "error", nil, "The server did not send a key"
		end
		return "ready", decoded, "You already have a free key"
	elseif status == "slow_down" then
		return "slow_down", nil, "Too many tries - wait a few minutes"
	elseif status == "off" then
		return "off", nil, "Free keys are not available right now"
	end
	return "error", nil, "Unexpected answer: " .. status
end

-- Ask whether the ads are finished. Returns (status, key, message):
--   "ready"   the key (the same key if asked twice)
--   "waiting" not finished yet, ask again
--   "expired" unknown, stale, or another device's code
--   "error"   message says what went wrong
function KeySystem:ClaimFreeKey(code, license)
	local url = luavmFreeUrl(license, "claim")
	if not url then return "error", nil, "Free keys are not set up" end
	if type(code) ~= "string" or code == "" then
		return "error", nil, "No code to check"
	end
	local respBody = luavmPostJson(url, {
		code = code,
		hardware_id = luavmDeviceId(),
	})
	if type(respBody) ~= "string" or respBody == "" then
		return "error", nil, "Could not reach the key server"
	end
	local ok, decoded = pcall(function()
		return game:GetService("HttpService"):JSONDecode(respBody)
	end)
	if not ok or type(decoded) ~= "table" or not decoded.status then
		return "error", nil, "Unexpected server response"
	end
	local status = tostring(decoded.status)
	if status == "ready" then
		if type(decoded.key) ~= "string" or decoded.key == "" then
			return "error", nil, "The server did not send a key"
		end
		return "ready", decoded.key, "Free key received"
	elseif status == "waiting" then
		return "waiting", nil, "Still waiting for the ads to finish..."
	elseif status == "expired" then
		return "expired", nil, "That link timed out"
	end
	return "error", nil, "Unexpected answer: " .. status
end

function KeySystem:CreateUI(settings, onSuccess, onFailure)
	local keySettings = settings.KeySettings or {}

	-- Get theme colors
	local colors = deps.Theme:Get()

	-- UI Configuration
	local title = keySettings.Title or (settings.Name .. " - Key System")
	local subtitle = keySettings.Subtitle or "Enter your key to continue"
	local note = keySettings.Note or "Visit our website to get a key"
	local noteButton = keySettings.NoteButton or nil

	-- Attempt configuration
	local maxAttempts = keySettings.MaxAttempts or 3
	local attemptsRemaining = maxAttempts

	-- Create ScreenGui
	local KeyGui = Instance.new("ScreenGui")
	KeyGui.Name = deps.Obfuscation:Generate("KeySystem")
	KeyGui.DisplayOrder = 999999
	KeyGui.ResetOnSpawn = false
	KeyGui.IgnoreGuiInset = true

	-- Parent to appropriate container
	if gethui then
		KeyGui.Parent = gethui()
	elseif syn and syn.protect_gui then
		syn.protect_gui(KeyGui)
		KeyGui.Parent = game.CoreGui
	else
		KeyGui.Parent = game.CoreGui
	end

	-- Main container with improved design
	local Container = Instance.new("Frame")
	Container.Name = "Container"
	Container.Size = UDim2.new(0, 500, 0, 0) -- Wider container
	Container.Position = UDim2.new(0.5, 0, 0.5, 0)
	Container.AnchorPoint = Vector2.new(0.5, 0.5)
	Container.BackgroundColor3 = colors.Bg
	Container.BorderSizePixel = 0
	Container.ClipsDescendants = true
	Container.Parent = KeyGui

	-- Rounded corners
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 16)
	Corner.Parent = Container

	-- Gradient border effect
	local Border = Instance.new("UIStroke")
	Border.Color = colors.Accent
	Border.Thickness = 2
	Border.Transparency = 0.5
	Border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Border.LineJoinMode = Enum.LineJoinMode.Round
	Border.Parent = Container

	local BorderGradient = Instance.new("UIGradient")
	BorderGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, colors.Primary),
		ColorSequenceKeypoint.new(0.5, colors.Accent),
		ColorSequenceKeypoint.new(1, colors.Secondary)
	})
	BorderGradient.Rotation = 45
	BorderGradient.Parent = Border

	-- Animated gradient rotation
	task.spawn(function()
		while Container.Parent do
			for i = 0, 360, 2 do
				if not Container.Parent then break end
				BorderGradient.Rotation = i
				task.wait(0.03)
			end
		end
	end)

	-- Shadow/glow effect
	local Glow = Instance.new("ImageLabel")
	Glow.Name = "Glow"
	Glow.Size = UDim2.new(1, 60, 1, 60)
	Glow.Position = UDim2.new(0.5, 0, 0.5, 0)
	Glow.AnchorPoint = Vector2.new(0.5, 0.5)
	Glow.BackgroundTransparency = 1
	Glow.Image = "rbxassetid://5028857084"
	Glow.ImageColor3 = colors.Accent
	Glow.ImageTransparency = 0.6
	Glow.ScaleType = Enum.ScaleType.Slice
	Glow.SliceCenter = Rect.new(24, 24, 276, 276)
	Glow.ZIndex = 0
	Glow.Parent = Container

	-- Header section with gradient
	local Header = Instance.new("Frame")
	Header.Name = "Header"
	Header.Size = UDim2.new(1, 0, 0, 100)
	Header.BackgroundColor3 = colors.Card
	Header.BorderSizePixel = 0
	Header.Parent = Container

	local HeaderCorner = Instance.new("UICorner")
	HeaderCorner.CornerRadius = UDim.new(0, 16)
	HeaderCorner.Parent = Header

	local HeaderGradient = Instance.new("UIGradient")
	HeaderGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, colors.Primary),
		ColorSequenceKeypoint.new(1, colors.Accent)
	})
	HeaderGradient.Rotation = 90
	HeaderGradient.Transparency = NumberSequence.new(0.7)
	HeaderGradient.Parent = Header

	-- Icon
	local Icon = Instance.new("TextLabel")
	Icon.Name = "Icon"
	Icon.Size = UDim2.new(0, 50, 0, 50)
	Icon.Position = UDim2.new(0, 25, 0, 25)
	Icon.BackgroundTransparency = 1
	Icon.Font = Enum.Font.GothamBold
	Icon.Text = "🔐"
	Icon.TextColor3 = colors.TextBright
	Icon.TextSize = 32
	Icon.Parent = Header

	-- Title
	local Title = Instance.new("TextLabel")
	Title.Name = "Title"
	Title.Size = UDim2.new(1, -100, 0, 30)
	Title.Position = UDim2.new(0, 85, 0, 20)
	Title.BackgroundTransparency = 1
	Title.Font = Enum.Font.GothamBold
	Title.Text = title
	Title.TextColor3 = colors.TextBright
	Title.TextSize = 20
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Header

	-- Subtitle
	local Subtitle = Instance.new("TextLabel")
	Subtitle.Name = "Subtitle"
	Subtitle.Size = UDim2.new(1, -100, 0, 20)
	Subtitle.Position = UDim2.new(0, 85, 0, 55)
	Subtitle.BackgroundTransparency = 1
	Subtitle.Font = Enum.Font.Gotham
	Subtitle.Text = subtitle
	Subtitle.TextColor3 = colors.TextSub
	Subtitle.TextSize = 14
	Subtitle.TextXAlignment = Enum.TextXAlignment.Left
	Subtitle.Parent = Header

	-- ============================================
	-- LIFECYCLE (v4.8.2)
	-- The key window used to leave its global listeners connected for the
	-- rest of the session. Everything it starts is now registered here and
	-- released by ONE teardown, however it closes: the X, a valid key, or
	-- the last attempt.
	-- ============================================
	local keyClosed = false
	local keyItems = {}
	
	local function trackKeyItem(item)
		if item ~= nil then
			table.insert(keyItems, item)
		end
		return item
	end
	
	local function releaseKeyItems()
		local items = keyItems
		keyItems = {}
		for i = #items, 1, -1 do
			local item = items[i]
			pcall(function()
				if typeof(item) == "RBXScriptConnection" then
					if item.Connected then
						item:Disconnect()
					end
				elseif type(item) == "function" then
					item()
				end
			end)
		end
	end
	
	-- Takes the window away and leaves nothing of it running. Safe to call
	-- twice; returns true only for the call that actually closed it.
	local function teardownKeyWindow()
		if keyClosed then
			return false
		end
		keyClosed = true
		releaseKeyItems()
		pcall(function()
			KeyGui:Destroy()
		end)
		return true
	end
	
	-- Close button (v4.8.2): the key window is a window, so it closes like
	-- one. Telling the host it was CLOSED rather than refused is what arms
	-- the hub's shutdown -- before this there was no way out but a key.
	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Name = "CloseButton"
	CloseBtn.AnchorPoint = Vector2.new(1, 0)
	CloseBtn.Position = UDim2.new(1, -16, 0, 16)
	CloseBtn.Size = UDim2.new(0, 32, 0, 32)
	CloseBtn.BackgroundColor3 = colors.Card
	CloseBtn.BorderSizePixel = 0
	CloseBtn.Font = Enum.Font.GothamBold
	CloseBtn.Text = "X"
	CloseBtn.TextColor3 = colors.Error
	CloseBtn.TextSize = 16
	CloseBtn.AutoButtonColor = false
	CloseBtn.ZIndex = 3
	CloseBtn.Parent = Header
	
	local CloseCorner = Instance.new("UICorner")
	CloseCorner.CornerRadius = UDim.new(0, 8)
	CloseCorner.Parent = CloseBtn
	
	local CloseStroke = Instance.new("UIStroke")
	CloseStroke.Color = colors.Error
	CloseStroke.Thickness = 1
	CloseStroke.Transparency = 0.4
	CloseStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	CloseStroke.Parent = CloseBtn

	CloseBtn.MouseEnter:Connect(function()
		deps.Animator:Tween(CloseBtn, {BackgroundColor3 = colors.Error}, deps.Animator.Spring.Lightning)
		CloseBtn.TextColor3 = colors.TextBright
	end)
	CloseBtn.MouseLeave:Connect(function()
		deps.Animator:Tween(CloseBtn, {BackgroundColor3 = colors.Card}, deps.Animator.Spring.Lightning)
		CloseBtn.TextColor3 = colors.Error
	end)
	
	CloseBtn.MouseButton1Click:Connect(function()
		if teardownKeyWindow() and onFailure then
			onFailure(KeySystem.ClosedReason)
		end
	end)
	
	-- ============================================
	-- DRAG + SCREEN FIT (v4.8.2)
	-- The main window learned both in 4.5.2; the key window never did, so
	-- it sat wherever it opened at a fixed 500 wide -- wider than a phone
	-- held upright, and taller than one held sideways.
	-- ============================================
	local KeyUIS = game:GetService("UserInputService")
	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local dragFrom = nil
	
	-- The screen, in the key window's own pixels.
	local function keyViewportSize()
		local size = nil
		pcall(function()
			local absolute = KeyGui.AbsoluteSize
			if typeof(absolute) == "Vector2" and absolute.X > 0 and absolute.Y > 0 then
				size = absolute
			end
		end)
		if not size then
			pcall(function()
				local camera = workspace.CurrentCamera
				if camera and camera.ViewportSize.X > 0 then
					size = camera.ViewportSize
				end
			end)
		end
		return size
	end
	
	-- The window is centred, so its position is an offset from the middle of
	-- the screen. Keep it on the screen: on a phone there is no mouse to
	-- fetch back a window that has been dragged into the void.
	local function clampKeyOffset(x, y)
		local view = keyViewportSize()
		if not view then
			return x, y
		end
		local size = Container.AbsoluteSize
		local maxX = math.max(0, (view.X - size.X) / 2)
		local maxY = math.max(0, (view.Y - size.Y) / 2)
		return math.clamp(x, -maxX, maxX), math.clamp(y, -maxY, maxY)
	end
	
	local function keyOffset()
		return Container.Position.X.Offset, Container.Position.Y.Offset
	end
	
	local function moveKeyWindow(x, y)
		local cx, cy = clampKeyOffset(x, y)
		Container.Position = UDim2.new(0.5, cx, 0.5, cy)
	end
	
	Header.Active = true
	trackKeyItem(Header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			dragFrom = Vector2.new(keyOffset())
			trackKeyItem(input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end))
		end
	end))
	
	trackKeyItem(Header.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end))
	
	trackKeyItem(KeyUIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging and dragFrom then
			local delta = input.Position - dragStart
			moveKeyWindow(dragFrom.X + delta.X, dragFrom.Y + delta.Y)
		end
	end))

	-- Content area
	local Content = Instance.new("Frame")
	Content.Name = "Content"
	Content.Size = UDim2.new(1, -40, 1, -120)
	Content.Position = UDim2.new(0, 20, 0, 110)
	Content.BackgroundTransparency = 1
	Content.Parent = Container

	-- Note message
	local NoteLabel = Instance.new("TextLabel")
	NoteLabel.Name = "Note"
	NoteLabel.Size = UDim2.new(1, 0, 0, 40)
	NoteLabel.Position = UDim2.new(0, 0, 0, 0)
	NoteLabel.BackgroundTransparency = 1
	NoteLabel.Font = Enum.Font.Gotham
	NoteLabel.Text = note
	NoteLabel.TextColor3 = colors.TextSub
	NoteLabel.TextSize = 13
	NoteLabel.TextXAlignment = Enum.TextXAlignment.Left
	NoteLabel.TextYAlignment = Enum.TextYAlignment.Top
	NoteLabel.TextWrapped = true
	NoteLabel.Parent = Content

	-- Note button (optional)
	local noteButtonHeight = 0
	if noteButton then
		noteButtonHeight = 45

		local NoteBtn = Instance.new("TextButton")
		NoteBtn.Name = "NoteButton"
		NoteBtn.Size = UDim2.new(1, 0, 0, 38)
		NoteBtn.Position = UDim2.new(0, 0, 0, 50)
		NoteBtn.BackgroundColor3 = colors.Surface
		NoteBtn.BorderSizePixel = 0
		NoteBtn.Font = Enum.Font.GothamMedium
		NoteBtn.Text = "  " .. (noteButton.Text or "Get Key")
		NoteBtn.TextColor3 = colors.Accent
		NoteBtn.TextSize = 14
		NoteBtn.TextXAlignment = Enum.TextXAlignment.Left
		NoteBtn.AutoButtonColor = false
		NoteBtn.Parent = Content

		local NoteBtnCorner = Instance.new("UICorner")
		NoteBtnCorner.CornerRadius = UDim.new(0, 10)
		NoteBtnCorner.Parent = NoteBtn

		local NoteBtnStroke = Instance.new("UIStroke")
		NoteBtnStroke.Color = colors.Accent
		NoteBtnStroke.Thickness = 1.5
		NoteBtnStroke.Transparency = 0.7
		NoteBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		NoteBtnStroke.LineJoinMode = Enum.LineJoinMode.Round
		NoteBtnStroke.Parent = NoteBtn

		local NoteBtnPadding = Instance.new("UIPadding")
		NoteBtnPadding.PaddingLeft = UDim.new(0, 12)
		NoteBtnPadding.Parent = NoteBtn

		NoteBtn.MouseButton1Click:Connect(function()
			if noteButton.Callback then
				noteButton.Callback()
			end
		end)

		-- Hover effect
		NoteBtn.MouseEnter:Connect(function()
			deps.Animator:Tween(NoteBtn, {BackgroundColor3 = colors.HoverBright}, deps.Animator.Spring.Lightning)
			deps.Animator:Tween(NoteBtnStroke, {Transparency = 0.3}, deps.Animator.Spring.Lightning)
		end)
		NoteBtn.MouseLeave:Connect(function()
			deps.Animator:Tween(NoteBtn, {BackgroundColor3 = colors.Surface}, deps.Animator.Spring.Lightning)
			deps.Animator:Tween(NoteBtnStroke, {Transparency = 0.7}, deps.Animator.Spring.Lightning)
		end)
	end

	-- Input box
	local InputBox = Instance.new("TextBox")
	InputBox.Name = "InputBox"
	InputBox.Size = UDim2.new(1, 0, 0, 48)
	InputBox.Position = UDim2.new(0, 0, 0, 55 + noteButtonHeight)
	InputBox.BackgroundColor3 = colors.Surface
	InputBox.BorderSizePixel = 0
	InputBox.Font = Enum.Font.GothamMedium
	InputBox.PlaceholderText = "Enter your key here..."
	InputBox.PlaceholderColor3 = colors.TextMuted
	InputBox.Text = ""
	InputBox.TextColor3 = colors.TextBright
	InputBox.TextSize = 15
	InputBox.ClearTextOnFocus = false
	InputBox.Parent = Content

	local InputCorner = Instance.new("UICorner")
	InputCorner.CornerRadius = UDim.new(0, 10)
	InputCorner.Parent = InputBox

	local InputStroke = Instance.new("UIStroke")
	InputStroke.Color = colors.Border
	InputStroke.Thickness = 1.5
	InputStroke.Transparency = 0.5
	InputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	InputStroke.LineJoinMode = Enum.LineJoinMode.Round
	InputStroke.Parent = InputBox

	local InputPadding = Instance.new("UIPadding")
	InputPadding.PaddingLeft = UDim.new(0, 16)
	InputPadding.PaddingRight = UDim.new(0, 16)
	InputPadding.Parent = InputBox

	-- Input focus effects
	InputBox.Focused:Connect(function()
		deps.Animator:Tween(InputStroke, {Color = colors.Accent, Transparency = 0.2}, deps.Animator.Spring.Lightning)
	end)
	InputBox.FocusLost:Connect(function()
		deps.Animator:Tween(InputStroke, {Color = colors.Border, Transparency = 0.5}, deps.Animator.Spring.Lightning)
	end)

	-- Status label
	local StatusLabel = Instance.new("TextLabel")
	StatusLabel.Name = "Status"
	StatusLabel.Size = UDim2.new(1, 0, 0, 20)
	StatusLabel.Position = UDim2.new(0, 0, 0, 113 + noteButtonHeight)
	StatusLabel.BackgroundTransparency = 1
	StatusLabel.Font = Enum.Font.Gotham
	StatusLabel.Text = string.format("Attempts remaining: %d/%d", attemptsRemaining, maxAttempts)
	StatusLabel.TextColor3 = colors.TextSub
	StatusLabel.TextSize = 12
	StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
	StatusLabel.Parent = Content

	-- Clean a pasted key the moment it lands, so the person SEES the key that
	-- will actually be sent instead of an invisible newline refusing it later.
	local sanitizing = false
	InputBox:GetPropertyChangedSignal("Text"):Connect(function()
		if sanitizing then return end
		local cleaned = KeySystem:CleanKey(InputBox.Text)
		if cleaned ~= InputBox.Text then
			sanitizing = true
			InputBox.Text = cleaned
			sanitizing = false
			StatusLabel.Text = "Tidied up a pasted key (spaces / hidden characters)"
			StatusLabel.TextColor3 = colors.TextSub
		end
	end)

	-- Submit button
	local SubmitBtn = Instance.new("TextButton")
	SubmitBtn.Name = "Submit"
	SubmitBtn.Size = UDim2.new(1, 0, 0, 48)
	SubmitBtn.Position = UDim2.new(0, 0, 0, 143 + noteButtonHeight)
	SubmitBtn.BackgroundColor3 = colors.Accent
	SubmitBtn.BorderSizePixel = 0
	SubmitBtn.Font = Enum.Font.GothamBold
	SubmitBtn.Text = "Validate Key"
	SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	SubmitBtn.TextSize = 15
	SubmitBtn.AutoButtonColor = false
	SubmitBtn.Parent = Content

	local SubmitCorner = Instance.new("UICorner")
	SubmitCorner.CornerRadius = UDim.new(0, 10)
	SubmitCorner.Parent = SubmitBtn

	-- Submit button gradient
	local SubmitGradient = Instance.new("UIGradient")
	SubmitGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, colors.Primary),
		ColorSequenceKeypoint.new(1, colors.Accent)
	})
	SubmitGradient.Rotation = 45
	SubmitGradient.Parent = SubmitBtn

	-- Free key button. Shown whenever the hub points at a licence server: the
	-- server decides whether free keys exist, and the button removes itself if
	-- they do not, so no hub ever has to configure or build this.
	local freeButtonHeight = 0
	local FreeBtn = nil
	if luavmFreeUrl(keySettings.License, "start") then
		freeButtonHeight = 52

		FreeBtn = Instance.new("TextButton")
		FreeBtn.Name = "FreeKeyButton"
		FreeBtn.Size = UDim2.new(1, 0, 0, 44)
		FreeBtn.Position = UDim2.new(0, 0, 0, 199 + noteButtonHeight)
		FreeBtn.BackgroundColor3 = colors.Surface
		FreeBtn.BorderSizePixel = 0
		FreeBtn.Font = Enum.Font.GothamMedium
		FreeBtn.Text = FREE_KEY_LABEL
		FreeBtn.TextColor3 = colors.Accent
		FreeBtn.TextSize = 14
		FreeBtn.AutoButtonColor = false
		FreeBtn.Parent = Content

		local FreeCorner = Instance.new("UICorner")
		FreeCorner.CornerRadius = UDim.new(0, 10)
		FreeCorner.Parent = FreeBtn

		local FreeStroke = Instance.new("UIStroke")
		FreeStroke.Color = colors.Accent
		FreeStroke.Thickness = 1.5
		FreeStroke.Transparency = 0.7
		FreeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		FreeStroke.LineJoinMode = Enum.LineJoinMode.Round
		FreeStroke.Parent = FreeBtn
	end

	-- Footer bar: the Discord badge and the build chip, side by side
	--
	-- The same pair the main window carries, and the key window is where both
	-- matter MOST. It is the first thing a player sees, and when something is
	-- wrong it is often the ONLY thing they see -- so this is exactly where a
	-- player needs the invite within reach, and where the team needs to be able
	-- to ask "what does the chip say?" and get an answer that identifies the
	-- build.
	--
	-- The geometry is this window's own, deliberately. The main window sizes its
	-- bar off the tab rail (`railWidth`); the key window has no rail -- it is a
	-- 500-wide dialog -- so reusing those numbers would wedge a tab-shaped bar
	-- into a dialog. What IS shared is the part that must never disagree: the
	-- invite (UIHelpers.resolveDiscordInvite) and the clipboard
	-- (UIHelpers.copyText).
	local discordInvite = deps.UIHelpers.resolveDiscordInvite(settings)
	local license = keySettings.License
	local hubBuildId = type(license) == "table" and license.BuildId or nil
	local version = deps.Version

	local FOOT_H = 24
	local FOOT_GAP = 12
	local FOOT_PAD = 20
	local DISCORD_W = 30
	local footerHeight = FOOT_H + FOOT_GAP

	local Footer = Instance.new("Frame")
	Footer.Name = deps.Obfuscation:Generate("KeyFooter")
	Footer.BackgroundColor3 = colors.Card
	Footer.BackgroundTransparency = 0.25
	Footer.BorderSizePixel = 0
	Footer.AnchorPoint = Vector2.new(0, 1)
	Footer.Position = UDim2.new(0, FOOT_PAD, 1, -FOOT_GAP)
	Footer.ZIndex = Container.ZIndex + 5
	Footer.Parent = Container

	local FooterCorner = Instance.new("UICorner")
	FooterCorner.CornerRadius = UDim.new(0, 6)
	FooterCorner.Parent = Footer

	local FooterStroke = Instance.new("UIStroke")
	FooterStroke.Color = colors.Border
	FooterStroke.Thickness = 1
	FooterStroke.Transparency = 0.5
	FooterStroke.Parent = Footer

	-- The chip names the build. Two numbers, because they answer two different
	-- questions: RvrseUI's own version says which UI the player is running, and
	-- the hub's build id says which HUB -- and that second one is the one that
	-- decides whether their key is even allowed to open it.
	local buildText = "v" .. tostring(version and version.Full or "?")
	if hubBuildId then
		buildText = buildText .. "  ·  " .. string.sub(tostring(hubBuildId), 1, 8)
	end

	local BuildChip = Instance.new("TextButton")
	BuildChip.Name = "BuildChip"
	BuildChip.BackgroundTransparency = 1
	BuildChip.Position = UDim2.new(0, discordInvite and DISCORD_W or 0, 0, 0)
	BuildChip.Font = Enum.Font.GothamBold
	BuildChip.TextSize = 11
	BuildChip.TextColor3 = colors.Accent
	BuildChip.Text = buildText
	BuildChip.AutoButtonColor = false
	BuildChip.ZIndex = Footer.ZIndex + 1
	BuildChip.Parent = Footer

	-- Width is measured off the text, so a longer version string or a build id
	-- that grows a character cannot quietly overflow the bar.
	local chipW = 0
	pcall(function()
		local TextService = game:GetService("TextService")
		chipW = TextService:GetTextSize(buildText, BuildChip.TextSize,
			BuildChip.Font, Vector2.new(400, 100)).X
	end)
	if chipW <= 0 then chipW = #buildText * 7 end
	chipW = chipW + 16
	BuildChip.Size = UDim2.new(0, chipW, 1, 0)
	Footer.Size = UDim2.new(0, (discordInvite and DISCORD_W or 0) + chipW, 0, FOOT_H)

	-- A tap hands the whole thing over, because a player reading a chip aloud
	-- gets it wrong and a screenshot of a 11px chip is unreadable.
	local function flash(button, original, word)
		button.Text = word
		task.delay(1.2, function()
			if button and button.Parent then
				button.Text = original
			end
		end)
	end

	BuildChip.MouseButton1Click:Connect(function()
		local line = string.format("RvrseUI %s (build %s, hash %s, %s)",
			tostring(version and version.Full or "?"),
			tostring(version and version.Build or "?"),
			tostring(version and version.Hash or "?"),
			tostring(version and version.Channel or "?"))
		if hubBuildId then
			line = line .. " | hub " .. tostring(hubBuildId)
		end
		if deps.UIHelpers.copyText(line) then
			flash(BuildChip, buildText, "Copied")
		end
	end)

	-- Discord half: the left end of the bar, in blurple so it reads as itself.
	if discordInvite then
		local DiscordBadge = Instance.new("TextButton")
		DiscordBadge.Name = "DiscordBadge"
		DiscordBadge.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
		DiscordBadge.BackgroundTransparency = 0.15
		DiscordBadge.BorderSizePixel = 0
		DiscordBadge.Position = UDim2.new(0, 0, 0, 0)
		DiscordBadge.Size = UDim2.new(0, DISCORD_W, 1, 0)
		DiscordBadge.Font = Enum.Font.GothamBold
		DiscordBadge.TextSize = 11
		DiscordBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
		DiscordBadge.Text = "Discord"
		DiscordBadge.TextScaled = false
		DiscordBadge.AutoButtonColor = false
		DiscordBadge.ZIndex = Footer.ZIndex + 1
		DiscordBadge.Parent = Footer

		local DiscordCorner = Instance.new("UICorner")
		DiscordCorner.CornerRadius = UDim.new(0, 6)
		DiscordCorner.Parent = DiscordBadge

		-- The badge is narrower than the word, so the word is the tooltip's job
		-- and the badge itself shows the mark.
		DiscordBadge.Text = "●"
		DiscordBadge.TextSize = 14

		DiscordBadge.MouseButton1Click:Connect(function()
			if deps.UIHelpers.copyText(discordInvite) then
				local was = DiscordBadge.Text
				DiscordBadge.Text = "✓"
				task.delay(1.2, function()
					if DiscordBadge and DiscordBadge.Parent then
						DiscordBadge.Text = was
					end
				end)
			end
		end)
	end

	-- Calculate final container height
	local finalHeight = 320 + noteButtonHeight + freeButtonHeight + footerHeight

	-- The window asks for 500 x finalHeight. A phone held upright is about
	-- 380 across, and one held sideways has about 320 of height below
	-- Roblox's top bar, so the key window was cut off on exactly the
	-- devices most players use. Scale it to the room there is -- the whole
	-- window at once, so the design is never re-laid-out -- and do it again
	-- whenever the screen changes (rotation, a resized emulator window).
	local KEY_BASE_WIDTH = 500
	local KEY_MARGIN = (KeyUIS.TouchEnabled and not KeyUIS.MouseEnabled) and 8 or 20
	local KeyScale = Instance.new("UIScale")
	KeyScale.Parent = Container
	
	local function fitKeyWindow()
		local view = keyViewportSize()
		if not view then
			return
		end
		local roomX = view.X - KEY_MARGIN * 2
		local roomY = view.Y - KEY_MARGIN * 2
		if roomX <= 0 or roomY <= 0 then
			return
		end
		local scale = math.min(1, roomX / KEY_BASE_WIDTH, roomY / finalHeight)
		-- Below this it is too small to read, and a player who cannot read it
		-- cannot type a key: better to overflow than to be illegible.
		KeyScale.Scale = math.max(0.5, scale)
		moveKeyWindow(keyOffset())
	end
	
	fitKeyWindow()
	trackKeyItem(KeyGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitKeyWindow))
	pcall(function()
		local camera = workspace.CurrentCamera
		if camera then
			trackKeyItem(camera:GetPropertyChangedSignal("ViewportSize"):Connect(fitKeyWindow))
		end
	end)

	-- Animate container entrance
	Container.Size = UDim2.new(0, 500, 0, 0)
	Container.BackgroundTransparency = 1
	Header.BackgroundTransparency = 1
	Icon.TextTransparency = 1
	Title.TextTransparency = 1
	Subtitle.TextTransparency = 1
	NoteLabel.TextTransparency = 1
	StatusLabel.TextTransparency = 1
	InputBox.BackgroundTransparency = 1
	InputBox.TextTransparency = 1
	InputStroke.Transparency = 1
	SubmitBtn.BackgroundTransparency = 1
	SubmitBtn.TextTransparency = 1
	Border.Transparency = 1
	if FreeBtn then
		FreeBtn.BackgroundTransparency = 1
		FreeBtn.TextTransparency = 1
	end
	Footer.BackgroundTransparency = 1
	FooterStroke.Transparency = 1

	task.wait(0.1)

	-- Smooth entrance animations
	deps.Animator:Tween(Container, {Size = UDim2.new(0, 500, 0, finalHeight)}, deps.Animator.Spring.Bounce)
	deps.Animator:Tween(Container, {BackgroundTransparency = 0}, deps.Animator.Spring.Butter)
	deps.Animator:Tween(Header, {BackgroundTransparency = 0}, deps.Animator.Spring.Butter)
	deps.Animator:Tween(Icon, {TextTransparency = 0}, deps.Animator.Spring.Glide)
	deps.Animator:Tween(Title, {TextTransparency = 0}, deps.Animator.Spring.Glide)
	deps.Animator:Tween(Subtitle, {TextTransparency = 0}, deps.Animator.Spring.Glide)
	deps.Animator:Tween(NoteLabel, {TextTransparency = 0}, deps.Animator.Spring.Glide)
	deps.Animator:Tween(StatusLabel, {TextTransparency = 0}, deps.Animator.Spring.Glide)
	deps.Animator:Tween(InputBox, {BackgroundTransparency = 0, TextTransparency = 0}, deps.Animator.Spring.Glide)
	deps.Animator:Tween(InputStroke, {Transparency = 0.5}, deps.Animator.Spring.Glide)
	deps.Animator:Tween(SubmitBtn, {BackgroundTransparency = 0, TextTransparency = 0}, deps.Animator.Spring.Glide)
	if FreeBtn then
		deps.Animator:Tween(FreeBtn, {BackgroundTransparency = 0, TextTransparency = 0}, deps.Animator.Spring.Glide)
	end
	deps.Animator:Tween(Border, {Transparency = 0.5}, deps.Animator.Spring.Glide)
	-- The footer fades in with the rest. Hiding something for an entrance and
	-- then not tweening it back is a bug that looks like a design decision: the
	-- chip and the badge carry their own colours, so they appeared on their own
	-- and only the card and border behind them stayed invisible -- for the whole
	-- life of the window, on every launch.
	deps.Animator:Tween(Footer, {BackgroundTransparency = 0.25}, deps.Animator.Spring.Glide)
	deps.Animator:Tween(FooterStroke, {Transparency = 0.5}, deps.Animator.Spring.Glide)

	-- Validation function
	local function validateInput()
		-- Clean here too, so what gets saved and handed to the callbacks is the
		-- real key, not whatever the clipboard brought with it.
		local inputKey = KeySystem:CleanKey(InputBox.Text)

		if inputKey == "" then
			-- Shake animation
			-- Shake where the window IS: it can be dragged now, and a shake that
			-- tweened back to the middle used to teleport it there.
			local shakeX, shakeY = keyOffset()
			deps.Animator:Tween(Container, {Position = UDim2.new(0.5, shakeX + 10, 0.5, shakeY)}, deps.Animator.Spring.Lightning)
			task.wait(0.05)
			deps.Animator:Tween(Container, {Position = UDim2.new(0.5, shakeX - 10, 0.5, shakeY)}, deps.Animator.Spring.Lightning)
			task.wait(0.05)
			deps.Animator:Tween(Container, {Position = UDim2.new(0.5, shakeX, 0.5, shakeY)}, deps.Animator.Spring.Lightning)

			StatusLabel.Text = "⚠️ Please enter a key!"
			StatusLabel.TextColor3 = colors.Warning
			return
		end

		-- Validate key
		local valid, message = KeySystem:ValidateKey(inputKey, settings)

		if valid then
			-- Success!
			StatusLabel.Text = "✓ Key validated! Loading..."
			StatusLabel.TextColor3 = colors.Success

			-- Save key if enabled
			if keySettings.SaveKey then
				local fileName = keySettings.FileName or settings.Name or "Key"
				KeySystem:SaveKey(fileName, inputKey)
			end

			-- Send webhook if configured
			if keySettings.WebhookURL then
				KeySystem:SendWebhook(keySettings.WebhookURL, {
					Title = "Key Validated ✓",
					Description = "User successfully validated key",
					Color = 3066993,
					Key = inputKey,
					Result = "Success: " .. message
				})
			end

			-- Callback
			if keySettings.OnKeyValid then
				keySettings.OnKeyValid(inputKey)
			end

			-- Animate out
			task.wait(0.5)
			deps.Animator:Tween(Container, {Size = UDim2.new(0, 500, 0, 0), BackgroundTransparency = 1}, deps.Animator.Spring.Expo)
			deps.Animator:Tween(Header, {BackgroundTransparency = 1}, deps.Animator.Spring.Expo)
			deps.Animator:Tween(Icon, {TextTransparency = 1}, deps.Animator.Spring.Expo)
			deps.Animator:Tween(Title, {TextTransparency = 1}, deps.Animator.Spring.Expo)
			deps.Animator:Tween(Subtitle, {TextTransparency = 1}, deps.Animator.Spring.Expo)
			deps.Animator:Tween(NoteLabel, {TextTransparency = 1}, deps.Animator.Spring.Expo)
			deps.Animator:Tween(StatusLabel, {TextTransparency = 1}, deps.Animator.Spring.Expo)
			deps.Animator:Tween(InputBox, {BackgroundTransparency = 1, TextTransparency = 1}, deps.Animator.Spring.Expo)
			deps.Animator:Tween(SubmitBtn, {BackgroundTransparency = 1, TextTransparency = 1}, deps.Animator.Spring.Expo)
			if FreeBtn then
				deps.Animator:Tween(FreeBtn, {BackgroundTransparency = 1, TextTransparency = 1}, deps.Animator.Spring.Expo)
			end
			deps.Animator:Tween(Border, {Transparency = 1}, deps.Animator.Spring.Expo)

			task.wait(0.6)
			teardownKeyWindow()

			-- Success callback
			if onSuccess then
				onSuccess(inputKey)
			end
		else
			-- Invalid key
			attemptsRemaining = attemptsRemaining - 1

			-- Shake animation
			-- Shake where the window IS: it can be dragged now, and a shake that
			-- tweened back to the middle used to teleport it there.
			local shakeX, shakeY = keyOffset()
			deps.Animator:Tween(Container, {Position = UDim2.new(0.5, shakeX + 15, 0.5, shakeY)}, deps.Animator.Spring.Lightning)
			task.wait(0.05)
			deps.Animator:Tween(Container, {Position = UDim2.new(0.5, shakeX - 15, 0.5, shakeY)}, deps.Animator.Spring.Lightning)
			task.wait(0.05)
			deps.Animator:Tween(Container, {Position = UDim2.new(0.5, shakeX, 0.5, shakeY)}, deps.Animator.Spring.Lightning)

			-- Send webhook if configured
			if keySettings.WebhookURL then
				KeySystem:SendWebhook(keySettings.WebhookURL, {
					Title = "Invalid Key Attempt ✗",
					Description = "User entered invalid key",
					Color = 15158332,
					Key = inputKey,
					Result = "Failed: " .. message .. " | Attempts remaining: " .. attemptsRemaining
				})
			end

			-- Callback
			if keySettings.OnKeyInvalid then
				keySettings.OnKeyInvalid(inputKey, attemptsRemaining)
			end

			if attemptsRemaining <= 0 then
				-- Out of attempts
				StatusLabel.Text = "✗ Out of attempts! Closing..."
				StatusLabel.TextColor3 = colors.Error

				-- Callback
				if keySettings.OnAttemptsExhausted then
					keySettings.OnAttemptsExhausted()
				end

				task.wait(1)

				-- Kick player if configured
				if keySettings.KickOnFailure ~= false then
					game.Players.LocalPlayer:Kick("Key validation failed - No attempts remaining")
				end

				teardownKeyWindow()

				-- Failure callback
				if onFailure then
					onFailure("No attempts remaining")
				end
			else
				-- Update status
				StatusLabel.Text = string.format("✗ Invalid key! Attempts: %d/%d", attemptsRemaining, maxAttempts)
				StatusLabel.TextColor3 = colors.Error

				-- Clear input
				InputBox.Text = ""
			end
		end
	end

	-- Submit button click
	SubmitBtn.MouseButton1Click:Connect(validateInput)

	-- Free key flow. One button walks the whole way: ask the server for the ad
	-- link, copy it, then watch for the key by itself and hand it to the normal
	-- validate path -- so saving, webhooks and callbacks behave exactly as they
	-- do for a key the player typed. Tapping again checks straight away for
	-- anyone who does not want to wait for the next poll.
	if FreeBtn then
		local freeCode = nil
		local freeWatching = false

		-- Closing the window stops the watcher at once, rather than leaving
		-- it to notice on its next pass.
		trackKeyItem(function()
			freeWatching = false
		end)

		local function say(text, colour)
			StatusLabel.Text = text
			StatusLabel.TextColor3 = colour or colors.TextSub
		end

		local function label(text, colour)
			FreeBtn.Text = text
			FreeBtn.TextColor3 = colour or colors.Accent
		end

		-- Hand the key to the ordinary path instead of repeating any of it.
		local function takeKey(key)
			freeWatching = false
			InputBox.Text = key
			say("Free key received - checking it...", colors.Success)
			validateInput()
		end

		-- Returns true when the waiting is over, either way.
		local function checkOnce()
			local status, key, message = KeySystem:ClaimFreeKey(freeCode, keySettings.License)
			if status == "ready" then
				takeKey(key)
				return true
			elseif status == "expired" then
				freeWatching = false
				freeCode = nil
				label(FREE_KEY_LABEL)
				say("That link timed out. Tap to start again.", colors.Warning)
				return true
			end
			say(message or "Still waiting for the ads to finish...", colors.TextSub)
			return false
		end

		FreeBtn.MouseButton1Click:Connect(function()
			-- Already holding a code: this tap means "I am done".
			if freeCode then
				checkOnce()
				return
			end

			label("Asking the server...", colors.TextSub)
			local status, data, message = KeySystem:StartFreeKey(keySettings.License)

			if status == "ready" then
				-- This device still has a live free key: no ads needed.
				takeKey(data.key)
				return
			elseif status == "go" then
				freeCode = data.code
				local copied = luavmCopyText(data.loot_url)
				label("I am done - check now", colors.Success)
				-- THE WAIT PATH NEEDS ITS OWN SENTENCE. The ad provider does not
				-- offer everybody the same thing: some players get "Watch Ads",
				-- others are offered ONLY a subscription or a 60-minute wait
				-- (seen on a real device, 2026-10-28). A player who takes the
				-- wait and then reads "come back" naturally comes back to the
				-- GAME -- and nothing happens, because the wait hands nothing
				-- over by itself. They have to open the SAME link again when the
				-- timer ends.
				--
				-- That is an hour of someone's evening spent for nothing, with
				-- no error anywhere, and it is indistinguishable to them from
				-- the bug this release fixed. So say it plainly, up front.
				if copied then
					say("Link copied. Open it in your browser and finish the steps - this keeps checking by itself.", colors.TextSub)
					say("If it offers a long wait instead of ads: open the SAME link again when the timer ends, or it hands over nothing.", colors.Warning)
				else
					say("Could not copy the link. Open this: " .. data.loot_url, colors.Warning)
				end

				if not freeWatching then
					freeWatching = true
					local gap = tonumber(data.poll_after) or 5
					if gap < 3 then gap = 3 end
					-- Keep watching until the SERVER says the run is over: checkOnce
					-- returns true both for "ready" and for an expired run. Slowing
					-- down rather than stopping is what makes the promise on the ad
					-- page -- "go back to the game, the hub unlocks by itself" -- true
					-- for a 60-minute wait as well as for a 5-minute one.
					task.spawn(function()
						local waited = 0
						while freeWatching do
							task.wait(gap)
							waited = waited + gap
							-- The window may have closed under us.
							if not freeWatching or not FreeBtn.Parent then break end
							if checkOnce() then return end
							if waited >= FREE_FAST_FOR and gap < FREE_SLOW_GAP then
								gap = FREE_SLOW_GAP
								say("Taking your time is fine - this keeps checking by itself.", colors.TextSub)
							end
							if waited >= FREE_GIVE_UP then
								freeWatching = false
								say("Stopped checking. Tap I am done once the tasks are finished.", colors.Warning)
								break
							end
						end
					end)
				end
				return
			elseif status == "off" then
				-- This server does not do free keys; stop offering them.
				FreeBtn.Visible = false
				say(message or "Free keys are not available right now.", colors.Warning)
				return
			end

			label(FREE_KEY_LABEL)
			say(message or "Could not start. Try again.", colors.Warning)
		end)
	end

	-- Enter key support
	InputBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			validateInput()
		end
	end)

	-- Hover effects
	SubmitBtn.MouseEnter:Connect(function()
		deps.Animator:Tween(SubmitBtn, {BackgroundColor3 = colors.AccentHover}, deps.Animator.Spring.Lightning)
	end)
	SubmitBtn.MouseLeave:Connect(function()
		deps.Animator:Tween(SubmitBtn, {BackgroundColor3 = colors.Accent}, deps.Animator.Spring.Lightning)
	end)

	-- Focus input box
	task.wait(0.8)
	InputBox:CaptureFocus()

	return KeyGui
end

-- Main entry point: Process key system for window
function KeySystem:Process(settings, callback)
	local keySettings = settings.KeySettings or {}

	-- Check if key system is enabled
	if not settings.KeySystem or settings.KeySystem == false then
		if callback then
			callback(true, "Key system disabled")
		end
		return true
	end

	-- Try to load saved key
	if keySettings.SaveKey then
		local fileName = keySettings.FileName or settings.Name or "Key"
		local success, savedKey = KeySystem:LoadSavedKey(fileName)

		if success and savedKey then
			-- Validate saved key
			local valid, message = KeySystem:ValidateKey(savedKey, settings)

			if valid then
				deps.Debug.printf("[KeySystem] Loaded saved key: %s", message)

				-- OnKeyValid belongs here too, and its absence was a real bug.
				-- Every OTHER way a key succeeds calls it -- a typed key does,
				-- and so does the getgenv one-key bridge -- so a hub that hangs
				-- anything on OnKeyValid worked on a player's FIRST launch and
				-- silently did nothing on every launch after it, once SaveKey
				-- had remembered the key. That is exactly how it was found: the
				-- key gate validated a saved key, never heard about it, and left
				-- the player looking at an empty window.
				if keySettings.OnKeyValid then
					keySettings.OnKeyValid(savedKey)
				end
				if callback then
					callback(true, "Saved key validated")
				end
				return true
			else
				deps.Debug.printf("[KeySystem] Saved key invalid, showing UI")
			end
		end
	end

	-- One-key bridge: if the buyer already set the LUAVM key the documented way
	-- (getgenv().LUAVM_LICENSE_KEY -- the same key that unlocks a full-lock
	-- build), validate it silently so they never type it twice.
	if keySettings.License and type(keySettings.License) == "table" and keySettings.License.Endpoint then
		local okg, g = pcall(function() return getgenv and getgenv() end)
		local env = nil
		if okg and type(g) == "table" then
			env = g
		end
		local pre = env and env.LUAVM_LICENSE_KEY
		if type(pre) == "string" and pre ~= "" then
			-- A full-lock build proved this key to the server moments ago, so
			-- take its receipt rather than spend a second call on the answer
			-- we already have.
			local valid, message = KeySystem:ReadLicenseReceipt(pre, env)
			if valid then
				deps.Debug.printf("[KeySystem] full-lock receipt accepted, no second server call")
			else
				valid, message = KeySystem:ValidateKey(pre, settings)
			end
			if valid then
				deps.Debug.printf("[KeySystem] LUAVM key from getgenv validated: %s", message)
				if keySettings.SaveKey then
					KeySystem:SaveKey(keySettings.FileName or settings.Name or "Key", pre)
				end
				if keySettings.WebhookURL then
					KeySystem:SendWebhook(keySettings.WebhookURL, {
						Title = "Key Validated ✓",
						Description = "Auto-validated LUAVM key from getgenv",
						Color = 3066993,
						Key = pre,
						Result = "Success: " .. message,
					})
				end
				if keySettings.OnKeyValid then keySettings.OnKeyValid(pre) end
				if callback then callback(true, "Licensed via LUAVM key") end
				return true
			end
		end
	end

	-- Fetch remote key if configured
	if keySettings.GrabKeyFromSite and keySettings.Key and type(keySettings.Key) == "string" then
		local success, remoteKey = KeySystem:FetchRemoteKey(keySettings.Key)

		if success then
			keySettings.Keys = {remoteKey}
			deps.Debug.printf("[KeySystem] Fetched remote key")
		else
			warn("[KeySystem] Failed to fetch remote key:", remoteKey)
		end
	end

	-- Show key validation UI
	local passthrough = false
	local errorMsg = nil

	KeySystem:CreateUI(settings, function(validKey)
		passthrough = true
	end, function(errMsg)
		passthrough = false
		errorMsg = errMsg
	end)

	-- Block execution until validated
	repeat
		task.wait()
	until passthrough == true or errorMsg ~= nil

	if callback then
		callback(passthrough, errorMsg or "Key validated")
	end

	-- The reason comes back too: the host needs to tell a player who closed
	-- the window from a key that was refused.
	return passthrough, errorMsg
end

return KeySystem
