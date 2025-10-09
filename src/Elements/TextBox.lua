-- TextBox Element Module
-- Part of RvrseUI v2.13.0 Modular Architecture
-- Extracted from RvrseUI.lua (lines 3627-3701)

local TextBox = {}

function TextBox.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local corner = dependencies.corner
	local stroke = dependencies.stroke
	local pal3 = dependencies.pal3
	local Animator = dependencies.Animator
	local RvrseUI = dependencies.RvrseUI

	local f = card(44)

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, -240, 1, 0)
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = pal3.Text
	lbl.Text = o.Text or "Input"
	lbl.Parent = f

	local inputBox = Instance.new("TextBox")
	inputBox.AnchorPoint = Vector2.new(1, 0.5)
	inputBox.Position = UDim2.new(1, -8, 0.5, 0)
	inputBox.Size = UDim2.new(0, 220, 0, 32)
	inputBox.BackgroundColor3 = pal3.Card
	inputBox.BorderSizePixel = 0
	inputBox.Font = Enum.Font.Gotham
	inputBox.TextSize = 13
	inputBox.TextColor3 = pal3.Text
	inputBox.PlaceholderText = o.Placeholder or "Enter text..."
	inputBox.PlaceholderColor3 = pal3.TextMuted
	inputBox.Text = o.Default or ""
	inputBox.ClearTextOnFocus = false
	inputBox.Parent = f
	corner(inputBox, 8)
	stroke(inputBox, pal3.Border, 1)

	local currentValue = inputBox.Text

	inputBox.FocusLost:Connect(function(enterPressed)
		currentValue = inputBox.Text
		if o.OnChanged then
			task.spawn(o.OnChanged, currentValue, enterPressed)
		end
		if o.Flag then RvrseUI:_autoSave() end  -- Auto-save on focus lost
	end)

	inputBox.Focused:Connect(function()
		Animator:Tween(inputBox, {BackgroundColor3 = pal3.Hover}, Animator.Spring.Fast)
	end)

	inputBox.FocusLost:Connect(function()
		Animator:Tween(inputBox, {BackgroundColor3 = pal3.Card}, Animator.Spring.Fast)
	end)

	table.insert(RvrseUI._lockListeners, function()
		local locked = RvrseUI.Store:IsLocked(o.RespectLock)
		lbl.TextTransparency = locked and 0.5 or 0
		inputBox.TextEditable = not locked
	end)

	local textboxAPI = {
		Set = function(_, txt)
			inputBox.Text = txt
			currentValue = txt
		end,
		Get = function()
			return currentValue
		end,
		SetVisible = function(_, visible)
			f.Visible = visible
		end,
		CurrentValue = currentValue
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = textboxAPI
	end

	return textboxAPI
end

return TextBox
