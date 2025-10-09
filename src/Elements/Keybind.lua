-- Keybind Element Module
-- Part of RvrseUI v2.13.0 Modular Architecture
-- Extracted from RvrseUI.lua (lines 3249-3352)

local Keybind = {}

function Keybind.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local corner = dependencies.corner
	local stroke = dependencies.stroke
	local pal3 = dependencies.pal3
	local Animator = dependencies.Animator
	local RvrseUI = dependencies.RvrseUI
	local UIS = dependencies.UIS

	local f = card(44)

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, -140, 1, 0)
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = pal3.Text
	lbl.Text = o.Text or "Keybind"
	lbl.Parent = f

	local btn = Instance.new("TextButton")
	btn.AnchorPoint = Vector2.new(1, 0.5)
	btn.Position = UDim2.new(1, 0, 0.5, 0)
	btn.Size = UDim2.new(0, 130, 0, 32)
	btn.BackgroundColor3 = pal3.Card
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.Code
	btn.TextSize = 12
	btn.TextColor3 = pal3.Text
	btn.Text = (o.Default and o.Default.Name) or "Set Key"
	btn.AutoButtonColor = false
	btn.Parent = f
	corner(btn, 8)
	stroke(btn, pal3.Border, 1)

	local capturing = false
	local currentKey = o.Default

	btn.MouseButton1Click:Connect(function()
		if RvrseUI.Store:IsLocked(o.RespectLock) then return end
		capturing = true
		btn.Text = "Press any key..."
		btn.TextColor3 = pal3.Accent
	end)

	UIS.InputBegan:Connect(function(io, gpe)
		if gpe or not capturing then return end
		if io.KeyCode ~= Enum.KeyCode.Unknown then
			capturing = false
			currentKey = io.KeyCode
			btn.Text = io.KeyCode.Name
			btn.TextColor3 = pal3.Text

			-- SPECIAL: If this keybind is for UI toggle, update the global toggle key
			if o.Flag == "_UIToggleKey" or o.IsUIToggle then
				RvrseUI.UI:BindToggleKey(io.KeyCode)
				print("[KEYBIND] UI Toggle key updated to:", io.KeyCode.Name)
			end

			-- SPECIAL: If this keybind is for escape/close, update the escape key
			if o.Flag == "_UIEscapeKey" or o.IsUIEscape then
				RvrseUI.UI:BindEscapeKey(io.KeyCode)
				print("[KEYBIND] UI Escape key updated to:", io.KeyCode.Name)
			end

			if o.OnChanged then task.spawn(o.OnChanged, io.KeyCode) end
			if o.Flag then RvrseUI:_autoSave() end  -- Auto-save on change
		end
	end)

	btn.MouseEnter:Connect(function()
		if not capturing then
			Animator:Tween(btn, {BackgroundColor3 = pal3.Hover}, Animator.Spring.Fast)
		end
	end)
	btn.MouseLeave:Connect(function()
		if not capturing then
			Animator:Tween(btn, {BackgroundColor3 = pal3.Card}, Animator.Spring.Fast)
		end
	end)

	table.insert(RvrseUI._lockListeners, function()
		local locked = RvrseUI.Store:IsLocked(o.RespectLock)
		lbl.TextTransparency = locked and 0.5 or 0
		btn.AutoButtonColor = not locked
	end)

	if o.Default and o.OnChanged then
		task.spawn(o.OnChanged, o.Default)
	end

	local keybindAPI = {
		Set = function(_, key)
			currentKey = key
			btn.Text = (key and key.Name) or "Set Key"
			if o.OnChanged and key then o.OnChanged(key) end
		end,
		Get = function() return currentKey end,
		SetVisible = function(_, visible)
			f.Visible = visible
		end,
		CurrentKeybind = currentKey
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = keybindAPI
	end

	return keybindAPI
end

return Keybind
