-- Button Element Module
-- Part of RvrseUI v2.13.0 Modular Architecture
-- Extracted from RvrseUI.lua (lines 2711-2763)

local Button = {}

function Button.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local pal3 = dependencies.pal3
	local UIS = dependencies.UIS
	local Animator = dependencies.Animator
	local RvrseUI = dependencies.RvrseUI

	local f = card(44)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 14
	btn.TextColor3 = pal3.Text
	btn.Text = o.Text or "Button"
	btn.AutoButtonColor = false
	btn.Parent = f

	local currentText = btn.Text

	btn.MouseButton1Click:Connect(function()
		if RvrseUI.Store:IsLocked(o.RespectLock) then return end
		local absPos = btn.AbsolutePosition
		local mousePos = UIS:GetMouseLocation()
		Animator:Ripple(btn, mousePos.X - absPos.X, mousePos.Y - absPos.Y)
		if o.Callback then task.spawn(o.Callback) end
	end)

	btn.MouseEnter:Connect(function()
		Animator:Tween(f, {BackgroundTransparency = 0.1}, Animator.Spring.Fast)
	end)
	btn.MouseLeave:Connect(function()
		Animator:Tween(f, {BackgroundTransparency = 0.3}, Animator.Spring.Fast)
	end)

	table.insert(RvrseUI._lockListeners, function()
		local locked = RvrseUI.Store:IsLocked(o.RespectLock)
		btn.TextTransparency = locked and 0.5 or 0
	end)

	local buttonAPI = {
		SetText = function(_, txt)
			btn.Text = txt
			currentText = txt
		end,
		SetVisible = function(_, visible)
			f.Visible = visible
		end,
		CurrentValue = currentText
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = buttonAPI
	end

	return buttonAPI
end

return Button
