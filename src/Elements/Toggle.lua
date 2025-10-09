-- Toggle Element Module
-- Part of RvrseUI v2.13.0 Modular Architecture
-- Extracted from RvrseUI.lua (lines 2766-2853)

local Toggle = {}

function Toggle.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local corner = dependencies.corner
	local shadow = dependencies.shadow
	local pal3 = dependencies.pal3
	local Animator = dependencies.Animator
	local RvrseUI = dependencies.RvrseUI

	local f = card(44)

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, -60, 1, 0)
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = pal3.Text
	lbl.Text = o.Text or "Toggle"
	lbl.Parent = f

	local shell = Instance.new("Frame")
	shell.AnchorPoint = Vector2.new(1, 0.5)
	shell.Position = UDim2.new(1, 0, 0.5, 0)
	shell.Size = UDim2.new(0, 48, 0, 26)
	shell.BackgroundColor3 = pal3.Border
	shell.BorderSizePixel = 0
	shell.Parent = f
	corner(shell, 13)

	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0, 22, 0, 22)
	dot.Position = UDim2.new(0, 2, 0.5, -11)
	dot.BackgroundColor3 = Color3.new(1, 1, 1)
	dot.BorderSizePixel = 0
	dot.Parent = shell
	corner(dot, 11)
	shadow(dot, 0.6, 2)

	local state = o.State == true
	local controlsGroup = o.LockGroup
	local respectGroup = o.RespectLock

	local function lockedNow()
		return respectGroup and RvrseUI.Store:IsLocked(respectGroup)
	end

	local function visual()
		local locked = lockedNow()
		local targetColor = locked and pal3.Disabled or (state and pal3.Success or pal3.Border)
		local targetPos = state and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)

		Animator:Tween(shell, {BackgroundColor3 = targetColor}, Animator.Spring.Smooth)
		Animator:Tween(dot, {Position = targetPos}, Animator.Spring.Snappy)
		lbl.TextTransparency = locked and 0.5 or 0
	end
	visual()

	f.InputBegan:Connect(function(io)
		if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
			if lockedNow() then return end
			state = not state
			visual()
			if controlsGroup then
				RvrseUI.Store:SetLocked(controlsGroup, state)
			end
			if o.OnChanged then task.spawn(o.OnChanged, state) end
			if o.Flag then RvrseUI:_autoSave() end  -- Auto-save on change
		end
	end)

	table.insert(RvrseUI._lockListeners, visual)

	local toggleAPI = {
		Set = function(_, v)
			state = v and true or false
			visual()
			if controlsGroup then
				RvrseUI.Store:SetLocked(controlsGroup, state)
			end
		end,
		Get = function() return state end,
		Refresh = visual,
		SetVisible = function(_, visible)
			f.Visible = visible
		end,
		CurrentValue = state
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = toggleAPI
	end

	return toggleAPI
end

return Toggle
