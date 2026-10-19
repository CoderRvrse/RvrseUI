--[[
	Gate a hub with keys your LICENSE SERVER issues (RvrseUI 4.7.0+)
	================================================================
	Normally RvrseUI's key window checks a list of keys written inside the hub,
	so anyone who opens the file can read them. With `License` the window asks a
	LUAVM-Rvrse license server instead: the valid keys never ship in the file,
	and the server decides VALID / EXPIRED / BANNED / wrong device.

	What you get for free:
	  * one device per key (the server locks a key to the first device it sees)
	  * expiry and bans you can change at any time, from the server
	  * the reason shown in the window ("This key has expired")
	  * your existing Discord webhook + OnKeyValid / OnKeyInvalid callbacks

	ONE KEY, TWO PLACES. The device id is worked out exactly the way the LUAVM
	loader does it, so the SAME key that unlocks a full-lock build also opens
	this window. If the buyer already set it the documented way --
	    getgenv().LUAVM_LICENSE_KEY = "RVRSE-..."
	-- the window validates it silently and never asks them to type it again.

	Make a key on your server (keep the admin secret off-screen):
	    POST <your-server>/api/v1/admin/genkey
	         header  X-Admin-Secret: <your ADMIN_SECRET>
	         body    {"count":1,"duration":"30d","tier":"premium"}
]]

local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

local Window = RvrseUI:CreateWindow({
	Name = "My Hub",
	Icon = "shield",

	KeySystem = true,
	KeySettings = {
		Title = "My Hub - Access",
		Subtitle = "Enter the key you were given",
		Note = "Your key is locked to this device.",

		-- The whole tie-in: let the server decide.
		License = {
			Endpoint = "https://YOUR-SERVER/api/v1/licensing/validate",
			BuildId = "my-hub",   -- optional: ties the key to this hub
			-- Secret = "...",    -- optional: only if your server wants the header
		},

		SaveKey = true,           -- remember it; it is re-checked every launch
		MaxAttempts = 3,

		NoteButton = {
			Text = "Get a key",
			Callback = function()
				setclipboard("https://your-site/get-key")
				RvrseUI:Notify({ Title = "Copied", Message = "Key page copied to clipboard" })
			end
		},

		WebhookURL = "",          -- optional Discord log of every attempt

		OnKeyValid = function(key)
			print("unlocked")
		end,
		OnKeyInvalid = function(key, attemptsLeft)
			warn("bad key, attempts left:", attemptsLeft)
		end,
		OnAttemptsExhausted = function()
			warn("out of attempts")
		end,
	},
})

local Tab = Window:CreateTab({ Title = "Main", Icon = "home" })
local Section = Tab:CreateSection("Ready")
Section:CreateLabel({ Text = "The key checked out." })

Window:SelectTab(1)

--[[
	Two levels of protection, same key
	----------------------------------
	1. This on its own: the window is the gate. Good for free or beta hubs.
	   The hub itself is already running, so someone who edits the file can get
	   past the window -- it stops casual sharing, not a determined cracker.

	2. Build the hub with LUAVM-Rvrse full lock for the real lock:
	       obfuscate.ps1 myhub.lua -Mode vm -FullLock -Production ^
	         -LicenseEndpoint https://YOUR-SERVER/api/v1/licensing/validate ^
	         -BuildsEndpoint  https://YOUR-SERVER/api/v1/admin/register-build ^
	         -BuildsSecret    <your ADMIN_SECRET>
	   Then the file is encrypted and will not even start without a key the
	   server accepts. The buyer sets getgenv().LUAVM_LICENSE_KEY once, and this
	   window picks the very same key up silently.
]]
