-- Keybind Element Module v4.0
-- Modern keybind with gradient highlight when capturing
-- Complete redesign for RvrseUI v4.0

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
	local Theme = dependencies.Theme
	local isLightTheme = Theme and Theme.Current == "Light"

	local f = card(48) -- Taller for modern look

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, -150, 1, 0)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 15
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = pal3.Text
	lbl.Text = o.Text or "Keybind"
	lbl.Parent = f

	-- Modern key display button
	local btn = Instance.new("TextButton")
	btn.AnchorPoint = Vector2.new(1, 0.5)
	btn.Position = UDim2.new(1, -6, 0.5, 0)
	btn.Size = UDim2.new(0, 140, 0, 36)
	btn.BackgroundColor3 = pal3.Card
	btn.BackgroundTransparency = isLightTheme and 0 or 0.2
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.Code
	btn.TextSize = 13
	btn.TextColor3 = pal3.TextBright
	btn.Text = (o.Default and o.Default.Name) or "Set Key"
	btn.AutoButtonColor = false
	btn.Parent = f
	corner(btn, "pill")

	-- Border stroke
	local btnStroke = Instance.new("UIStroke")
	btnStroke.Color = pal3.Border
	btnStroke.Thickness = 1
	btnStroke.Transparency = 0.5
	btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	btnStroke.LineJoinMode = Enum.LineJoinMode.Round
	btnStroke.Parent = btn

	-- Gradient overlay (shows when capturing)
	local btnGradient = Instance.new("UIGradient")
	btnGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, pal3.Primary),
		ColorSequenceKeypoint.new(0.5, pal3.Accent),
		ColorSequenceKeypoint.new(1, pal3.Secondary),
	}
	btnGradient.Rotation = 45
	btnGradient.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 1),
	}
	btnGradient.Parent = btn

	local capturing = false
	local currentKey = o.Default

	btn.MouseButton1Click:Connect(function()
		if RvrseUI.Store:IsLocked(o.RespectLock) then return end
		capturing = true
		btn.Text = "⌨️ Press any key..."

		-- Activate gradient background (set directly - can't tween NumberSequence)
		btnGradient.Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 0.5),
		}

		-- Glow border
		Animator:Tween(btnStroke, {
			Color = pal3.Accent,
			Thickness = 2,
			Transparency = 0.2
		}, Animator.Spring.Snappy)

		-- Shimmer effect
		Animator:Shimmer(btn, Theme)

		-- Pulse
		Animator:Pulse(btn, 1.05, Animator.Spring.Bounce)
	end)

	UIS.InputBegan:Connect(function(io, gpe)
		if gpe or not capturing then return end
		if io.KeyCode ~= Enum.KeyCode.Unknown then
			capturing = false
			currentKey = io.KeyCode
			btn.Text = io.KeyCode.Name

			-- Deactivate gradient (set directly - can't tween NumberSequence)
			btnGradient.Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 1),
			}

			-- Restore border
			Animator:Tween(btnStroke, {
				Color = pal3.Border,
				Thickness = 1,
				Transparency = 0.5
			}, Animator.Spring.Snappy)

			-- Success pulse
			Animator:Pulse(btn, 1.08, Animator.Spring.Bounce)

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
			if o.Flag then RvrseUI:_autoSave() end
		end
	end)

	btn.MouseEnter:Connect(function()
		if not capturing then
			Animator:Tween(btn, {BackgroundTransparency = 0.1}, Animator.Spring.Lightning)
			Animator:Tween(btnStroke, {Transparency = 0.3}, Animator.Spring.Lightning)
		end
	end)
	btn.MouseLeave:Connect(function()
		if not capturing then
			Animator:Tween(btn, {BackgroundTransparency = 0.2}, Animator.Spring.Snappy)
			Animator:Tween(btnStroke, {Transparency = 0.5}, Animator.Spring.Snappy)
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

	-- Register for global search
	local registerSearchableElement = dependencies.registerSearchableElement
	if registerSearchableElement then
		registerSearchableElement({
			text = o.Text or "Keybind",
			icon = o.Icon,
			elementType = "Keybind",
			path = (dependencies.tabTitle or "Tab") .. " > " .. (dependencies.sectionTitle or "Section"),
			frame = f,
			tabData = dependencies.tabData
		})
	end

	return keybindAPI
end

return Keybind
