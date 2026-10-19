-- license_driver.lua — appended after roblox_mock.lua by license_run.js
-- Checks the LUAVM-Rvrse license bridge inside the key window:
--   * a full-lock build has already proved the key to the server (that answer
--     is what decrypted it), so its receipt is taken at its word and the
--     window makes NO second server call;
--   * anything doubtful about that receipt — wrong key, stale, no time stamp,
--     not VALID — falls back to a real server call, exactly as before.
-- Every scenario counts the calls the window makes, so a regression that
-- quietly re-checks every launch fails here.
-- SCENARIOS: receipt,noreceipt,stale,wrongkey,badstatus,unit
local H = { fails = {} }

function H.check(ok, what)
	if not ok then
		table.insert(H.fails, what)
	end
	return ok
end

function H.log(fmt, ...)
	M.nativePrint("H " .. string.format(fmt, ...))
end

local KEY = "RVRSE-ABCDE-FGHJK-LMNPQ"
local OTHER_KEY = "RVRSE-ZZZZZ-YYYYY-XXXXX"
local VALID_BODY = '{"status":"VALID","tier":"premium","expires_in_seconds":2592000}'

-- Count every call the key window makes to the license server. The executor
-- requester lives in getgenv(), which is where KeySystem looks first.
local calls = 0
local function installHttp(body)
	calls = 0
	M.genv.request = function(req)
		calls = calls + 1
		H.log("server asked: %s", tostring(req and req.Url))
		return { StatusCode = 200, Body = body or VALID_BODY }
	end
end

local function freshReceipt(key, extra)
	local r = {
		status = "VALID",
		key = key,
		build_id = "testbuild",
		tier = "premium",
		expires_in_seconds = 2592000,
		at = os.time(),
	}
	for k, v in pairs(extra or {}) do
		r[k] = v
	end
	return r
end

local function hubSettings()
	return {
		Name = "LicenseTest",
		KeySystem = true,
		KeySettings = {
			Title = "Licensed",
			SaveKey = false,
			License = {
				Endpoint = "https://license.invalid/api/v1/licensing/validate",
				BuildId = "testbuild",
			},
		},
	}
end

local function runProcess()
	local saidOk, saidMsg
	local ok = KeySystem:Process(hubSettings(), function(v, m)
		saidOk, saidMsg = v, m
	end)
	return ok, saidOk, saidMsg
end

-- Load the build. KeySystem is a global in the bundle, so it is reachable
-- here once RvrseUI has run.
assert(loadstring(RVRSEUI_SRC, "=RvrseUI"))()
H.check(type(KeySystem) == "table", "the build exposes KeySystem")
H.check(type(KeySystem.ReadLicenseReceipt) == "function", "this build has ReadLicenseReceipt")

if H_SCENARIO == "receipt" then
	-- The case this whole change is about: a full-lock launch costs one call,
	-- not two.
	installHttp()
	M.genv.LUAVM_LICENSE_KEY = KEY
	M.genv.LUAVM_LICENSE_OK = freshReceipt(KEY)
	local ok, saidOk, saidMsg = runProcess()
	H.check(ok == true, "the window let the licensed buyer in")
	H.check(saidOk == true, "the hub was told the key is good")
	H.check(calls == 0, "no server call was made (it made " .. calls .. ")")
	H.log("message: %s", tostring(saidMsg))

elseif H_SCENARIO == "noreceipt" then
	-- No full-lock receipt (a plain VM or source build): ask the server, once.
	installHttp()
	M.genv.LUAVM_LICENSE_KEY = KEY
	M.genv.LUAVM_LICENSE_OK = nil
	local ok = runProcess()
	H.check(ok == true, "the window let the buyer in after asking the server")
	H.check(calls == 1, "the server was asked exactly once (it made " .. calls .. ")")

elseif H_SCENARIO == "stale" then
	-- A receipt from an earlier session must not stand in for a fresh check.
	installHttp()
	M.genv.LUAVM_LICENSE_KEY = KEY
	M.genv.LUAVM_LICENSE_OK = freshReceipt(KEY, { at = os.time() - 600 })
	local ok = runProcess()
	H.check(ok == true, "a stale receipt still ends in a working launch")
	H.check(calls == 1, "a stale receipt is re-checked (calls: " .. calls .. ")")

elseif H_SCENARIO == "wrongkey" then
	-- A receipt for a different key proves nothing about this one.
	installHttp()
	M.genv.LUAVM_LICENSE_KEY = KEY
	M.genv.LUAVM_LICENSE_OK = freshReceipt(OTHER_KEY)
	local ok = runProcess()
	H.check(ok == true, "a mismatched receipt still ends in a working launch")
	H.check(calls == 1, "a receipt for another key is ignored (calls: " .. calls .. ")")

elseif H_SCENARIO == "badstatus" then
	-- Only VALID counts. Anything else goes to the server.
	installHttp()
	M.genv.LUAVM_LICENSE_KEY = KEY
	M.genv.LUAVM_LICENSE_OK = freshReceipt(KEY, { status = "EXPIRED" })
	local ok = runProcess()
	H.check(ok == true, "a non-VALID receipt still ends in a working launch")
	H.check(calls == 1, "a non-VALID receipt is ignored (calls: " .. calls .. ")")

elseif H_SCENARIO == "unit" then
	local function reads(receipt, key)
		return KeySystem:ReadLicenseReceipt(key or KEY, { LUAVM_LICENSE_OK = receipt })
	end

	H.check(KeySystem:ReadLicenseReceipt(KEY, nil) == false, "no environment: refused")
	H.check(KeySystem:ReadLicenseReceipt(KEY, {}) == false, "no receipt at all: refused")
	H.check(reads("not a table") == false, "a receipt that is not a table: refused")
	H.check(reads(freshReceipt(KEY)) == true, "a good fresh receipt: accepted")
	H.check(reads(freshReceipt(KEY, { status = "BANNED" })) == false, "status BANNED: refused")
	-- Built inline, not through freshReceipt: a missing field cannot be
	-- expressed by overriding one with nil.
	H.check(reads({ status = "VALID", key = KEY, expires_in_seconds = 2592000 }) == false,
		"an older build that leaves no time stamp: refused")
	H.check(reads(freshReceipt(KEY, { at = os.time() - 600 })) == false, "ten minutes old: refused")
	H.check(reads(freshReceipt(KEY, { at = os.time() - 120 })) == true, "two minutes old: accepted")
	H.check(reads(freshReceipt(KEY, { at = os.time() + 30 })) == true, "a clock 30s ahead: accepted")
	H.check(reads(freshReceipt(KEY, { at = os.time() + 600 })) == false, "a stamp from the future: refused")
	H.check(reads(freshReceipt(KEY, { key = "" })) == false, "an empty key in the receipt: refused")
	H.check(reads(freshReceipt(OTHER_KEY)) == false, "a receipt for another key: refused")

	-- The same paste-proofing the typed key gets: a receipt whose key arrived
	-- with a trailing newline is still the same key.
	H.check(reads(freshReceipt(KEY .. "\n")) == true, "receipt key with a trailing newline: accepted")
	H.check(reads(freshReceipt(KEY), KEY .. " ") == true, "set key with a trailing space: accepted")

	-- The buyer should still see how long they have left.
	local ok, msg = reads(freshReceipt(KEY))
	H.check(ok == true and type(msg) == "string" and msg:find("Licensed") ~= nil, "it says Licensed")
	H.check(type(msg) == "string" and msg:find("30d") ~= nil, "it says how long is left (" .. tostring(msg) .. ")")

	-- A receipt with no expiry at all is a lifetime key: still accepted.
	local okLife, msgLife = reads({ status = "VALID", key = KEY, at = os.time() })
	H.check(okLife == true, "a lifetime receipt: accepted")
	H.check(msgLife == "Licensed", "a lifetime receipt says plain Licensed (" .. tostring(msgLife) .. ")")

else
	H.check(false, "unknown scenario " .. tostring(H_SCENARIO))
end

if #H.fails == 0 then
	M.nativePrint("HARNESS RESULT PASS")
else
	for _, f in ipairs(H.fails) do
		M.nativePrint("H FAIL: " .. f)
	end
	M.nativePrint("HARNESS RESULT FAIL")
end
