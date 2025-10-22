-- Toggle Element Module v4.0
-- Switch-style toggle with vibrant gradient track
-- Complete redesign for RvrseUI v4.0

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
	local Theme = dependencies.Theme

	local f = card(48) -- Taller for modern look
	local fireOnConfigLoad = o.FireOnConfigLoad ~= false

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, -70, 1, 0)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 15
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = pal3.Text
	lbl.Text = o.Text or "Toggle"
	lbl.Parent = f

	-- Modern switch track (wider and taller)
	local shell = Instance.new("Frame")
	shell.AnchorPoint = Vector2.new(1, 0.5)
	shell.Position = UDim2.new(1, -6, 0.5, 0)
	shell.Size = UDim2.new(0, 56, 0, 30)
	shell.BackgroundColor3 = pal3.Border
	shell.BorderSizePixel = 0
	shell.Parent = f
	corner(shell, "pill")

	-- Gradient overlay on track
	local trackGradient = Instance.new("UIGradient")
	trackGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, pal3.Primary),
		ColorSequenceKeypoint.new(0.5, pal3.Accent),
		ColorSequenceKeypoint.new(1, pal3.Secondary),
	}
	trackGradient.Rotation = 45
	trackGradient.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.9),
		NumberSequenceKeypoint.new(1, 0.9),
	}
	trackGradient.Parent = shell

	-- Glowing border on track
	local trackStroke = Instance.new("UIStroke")
	trackStroke.Color = pal3.BorderGlow
	trackStroke.Thickness = 0
	trackStroke.Transparency = 0.7
	trackStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	trackStroke.LineJoinMode = Enum.LineJoinMode.Round
	trackStroke.Parent = shell

	-- Switch thumb (larger and glowing)
	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0, 26, 0, 26)
	dot.Position = UDim2.new(0, 2, 0.5, -13)
	dot.BackgroundColor3 = Color3.new(1, 1, 1)
	dot.BorderSizePixel = 0
	dot.ZIndex = 3
	dot.Parent = shell
	corner(dot, "pill")
	shadow(dot, 0.5, 3)

	-- Glow ring around thumb (when active)
	local glowRing = Instance.new("UIStroke")
	glowRing.Color = pal3.Accent
	glowRing.Thickness = 0
	glowRing.Transparency = 0.3
	glowRing.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	glowRing.LineJoinMode = Enum.LineJoinMode.Round
	glowRing.Parent = dot

	local state = o.State == true
	local controlsGroup = o.LockGroup
	local respectGroup = o.RespectLock
	local isHovering = false

	local function lockedNow()
		return respectGroup and RvrseUI.Store:IsLocked(respectGroup)
	end

	local function visual()
		local locked = lockedNow()

		if locked then
			-- Locked state: desaturated
			shell.BackgroundColor3 = pal3.Disabled
			trackGradient.Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0.95),
				NumberSequenceKeypoint.new(1, 0.95),
			}
			trackStroke.Thickness = 0
			glowRing.Thickness = 0
			lbl.TextTransparency = 0.5
		elseif state then
			-- Active state: vibrant gradient track
			shell.BackgroundColor3 = pal3.Accent
			trackGradient.Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0.3),
				NumberSequenceKeypoint.new(1, 0.3),
			}
			trackStroke.Thickness = 1
			trackStroke.Transparency = 0.4

			-- Glow the thumb
			Animator:Tween(glowRing, {Thickness = 3}, Animator.Spring.Snappy)

			-- Slide thumb to right
			Animator:Tween(dot, {Position = UDim2.new(1, -28, 0.5, -13)}, Animator.Spring.Spring)

			lbl.TextTransparency = 0
			lbl.TextColor3 = pal3.TextBright
		else
			-- Inactive state: subtle
			shell.BackgroundColor3 = pal3.Border
			trackGradient.Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0.9),
				NumberSequenceKeypoint.new(1, 0.9),
			}
			trackStroke.Thickness = 0
			glowRing.Thickness = 0

			-- Slide thumb to left
			Animator:Tween(dot, {Position = UDim2.new(0, 2, 0.5, -13)}, Animator.Spring.Spring)

			lbl.TextTransparency = 0
			lbl.TextColor3 = pal3.Text
		end
	end
	visual()

	-- Click/tap interaction
	f.InputBegan:Connect(function(io)
		if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
			if lockedNow() then return end

			state = not state

			-- Multiple effects on toggle
			if state then
				Animator:Shimmer(shell, Theme) -- Shimmer on activate
			end

			-- Quick pulse
			Animator:Pulse(dot, 1.1, Animator.Spring.Lightning)

			visual()

			if controlsGroup then
				RvrseUI.Store:SetLocked(controlsGroup, state)
			end
			if o.OnChanged then task.spawn(o.OnChanged, state) end
			if o.Flag then RvrseUI:_autoSave() end
		end
	end)

	-- Hover effects
	shell.MouseEnter:Connect(function()
		if lockedNow() then return end
		isHovering = true

		-- Brighten on hover (set directly - can't tween NumberSequence)
		if not state then
			trackGradient.Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0.8),
				NumberSequenceKeypoint.new(1, 0.8),
			}
		end
	end)

	shell.MouseLeave:Connect(function()
		isHovering = false

		-- Restore transparency (set directly - can't tween NumberSequence)
		if not state then
			trackGradient.Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0.9),
				NumberSequenceKeypoint.new(1, 0.9),
			}
		end
	end)

	table.insert(RvrseUI._lockListeners, visual)

	local toggleAPI = {
		Set = function(_, v, fireCallback)
			state = v and true or false
			visual()
			if controlsGroup then
				RvrseUI.Store:SetLocked(controlsGroup, state)
			end
			if fireCallback and o.OnChanged then
				task.spawn(o.OnChanged, state)
			end
		end,
		Get = function() return state end,
		Refresh = visual,
		SetVisible = function(_, visible)
			f.Visible = visible
		end,
		Hydrate = function(_, overrideState)
			if not fireOnConfigLoad then
				return
			end
			if o.OnChanged then
				local final = overrideState ~= nil and (overrideState and true or false) or state
				task.spawn(o.OnChanged, final)
			end
		end,
		CurrentValue = state
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = toggleAPI
	end

	return toggleAPI
end

return Toggle
