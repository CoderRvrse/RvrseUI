-- Clean close demo (RvrseUI v4.5.0+)
-- Everything this hub starts stops when its window closes — X button,
-- Window:Destroy(), RvrseUI:Destroy() or the destroy key — and RvrseUI itself
-- leaves nothing running either.
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local Window = RvrseUI:CreateWindow({
	Name = "Clean Close Demo",
	Icon = "lucide://sparkles",
	TurnOffTogglesOnClose = true, -- every ON toggle gets OnChanged(false) when the window closes
	OnClose = function(reason) -- "close-button" | "destroy" | "destroy-key" | "rvrseui-destroy"
		print("[Demo] window closed:", reason)
	end,
})

local Section = Window:CreateTab({ Title = "Player", Icon = "lucide://user" }):CreateSection("Movement")

-- Changes the world. Its own OnChanged(false) undoes it, and
-- TurnOffTogglesOnClose calls that for us when the window closes.
local defaultGravity = workspace.Gravity
Section:CreateToggle({
	Text = "Low Gravity",
	State = false,
	OnChanged = function(on)
		workspace.Gravity = on and 50 or defaultGravity
	end,
})

-- A per-frame feature: Track() disconnects it on close.
local spinning = false
Section:CreateToggle({
	Text = "Spin",
	State = false,
	OnChanged = function(on)
		spinning = on
	end,
})
Window:Track(RunService.Heartbeat:Connect(function(dt)
	local root = spinning and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if root then
		root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(180) * dt, 0)
	end
end))

-- A background loop: Track() cancels the thread on close.
Window:Track(task.spawn(function()
	while true do
		task.wait(5)
		print("[Demo] still running")
	end
end))

-- Anything else: one more close callback.
Window:OnClose(function()
	print("[Demo] cleanup done - nothing left running")
end)

Window:Show()
