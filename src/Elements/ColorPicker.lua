-- ColorPicker Element Module v4.1
-- Advanced color picker with RGB/HSV sliders, hex input, and live preview
-- Supports both simple mode (preset colors) and advanced mode (full RGB/HSV control)

local ColorPicker = {}

-- Helper: Convert RGB to HSV
local function RGBtoHSV(r, g, b)
	r, g, b = r / 255, g / 255, b / 255
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local delta = max - min

	local h, s, v = 0, 0, max

	if delta > 0 then
		s = delta / max

		if max == r then
			h = ((g - b) / delta) % 6
		elseif max == g then
			h = (b - r) / delta + 2
		else
			h = (r - g) / delta + 4
		end

		h = h * 60
		if h < 0 then h = h + 360 end
	end

	return math.floor(h + 0.5), math.floor(s * 100 + 0.5), math.floor(v * 100 + 0.5)
end

-- Helper: Convert HSV to RGB
local function HSVtoRGB(h, s, v)
	s, v = s / 100, v / 100
	local c = v * s
	local x = c * (1 - math.abs(((h / 60) % 2) - 1))
	local m = v - c

	local r, g, b = 0, 0, 0

	if h >= 0 and h < 60 then
		r, g, b = c, x, 0
	elseif h >= 60 and h < 120 then
		r, g, b = x, c, 0
	elseif h >= 120 and h < 180 then
		r, g, b = 0, c, x
	elseif h >= 180 and h < 240 then
		r, g, b = 0, x, c
	elseif h >= 240 and h < 300 then
		r, g, b = x, 0, c
	else
		r, g, b = c, 0, x
	end

	r, g, b = (r + m) * 255, (g + m) * 255, (b + m) * 255
	return math.floor(r + 0.5), math.floor(g + 0.5), math.floor(b + 0.5)
end

-- Helper: Convert Color3 to Hex
local function Color3ToHex(color)
	local r = math.floor(color.R * 255 + 0.5)
	local g = math.floor(color.G * 255 + 0.5)
	local b = math.floor(color.B * 255 + 0.5)
	return string.format("#%02X%02X%02X", r, g, b)
end

-- Helper: Convert Hex to Color3
local function HexToColor3(hex)
	hex = hex:gsub("#", "")
	if #hex ~= 6 then return nil end

	local r = tonumber(hex:sub(1, 2), 16)
	local g = tonumber(hex:sub(3, 4), 16)
	local b = tonumber(hex:sub(5, 6), 16)

	if not r or not g or not b then return nil end
	return Color3.fromRGB(r, g, b)
end

function ColorPicker.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local corner = dependencies.corner
	local stroke = dependencies.stroke
	local shadow = dependencies.shadow
	local pal3 = dependencies.pal3
	local Animator = dependencies.Animator
	local RvrseUI = dependencies.RvrseUI
	local Theme = dependencies.Theme
	local baseOverlayLayer = dependencies.OverlayLayer
	local OverlayService = dependencies.Overlay

	if OverlayService and not baseOverlayLayer then
		baseOverlayLayer = OverlayService:GetLayer()
	end

	-- Settings
	local advancedMode = o.Advanced ~= false  -- Default to advanced mode
	local defaultColor = o.Default or pal3.Accent
	local currentColor = defaultColor

	-- Extract RGB from default color
	local r = math.floor(currentColor.R * 255 + 0.5)
	local g = math.floor(currentColor.G * 255 + 0.5)
	local b = math.floor(currentColor.B * 255 + 0.5)
	local h, s, v = RGBtoHSV(r, g, b)

	local updatingSliders = false  -- Prevent circular updates

	-- Declare slider variables (used in advanced mode)
	local rSlider, gSlider, bSlider, hSlider, sSlider, vSlider, hexInput

	-- Base card
	local f = card(48)
	f.ClipsDescendants = false

	-- Label
	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, -90, 1, 0)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 15
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = pal3.Text
	lbl.Text = o.Text or "Color"
	lbl.Parent = f

	-- Circular preview button
	local preview = Instance.new("TextButton")
	preview.AnchorPoint = Vector2.new(1, 0.5)
	preview.Position = UDim2.new(1, -6, 0.5, 0)
	preview.Size = UDim2.new(0, 40, 0, 40)
	preview.BackgroundColor3 = currentColor
	preview.BorderSizePixel = 0
	preview.Text = ""
	preview.AutoButtonColor = false
	preview.Parent = f
	corner(preview, 20)

	-- Glowing stroke
	local previewStroke = Instance.new("UIStroke")
	previewStroke.Color = pal3.Border
	previewStroke.Thickness = 2
	previewStroke.Transparency = 0.4
	previewStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	previewStroke.Parent = preview

	-- Advanced mode: Color picker panel
	local pickerPanel
	local pickerOpen = false
	local overlayBlocker
	local overlayBlockerConnection

	if advancedMode then
		-- Panel container
		pickerPanel = Instance.new("Frame")
		pickerPanel.Name = "ColorPickerPanel"
		pickerPanel.BackgroundColor3 = pal3.Elevated
		pickerPanel.BorderSizePixel = 0
		pickerPanel.Size = UDim2.new(0, 320, 0, 380)  -- Full height to show sliders
		pickerPanel.Position = UDim2.new(1, -(320 + 6), 0.5, 52)
		pickerPanel.Visible = false
		pickerPanel.ZIndex = 5000
		pickerPanel.ClipsDescendants = false  -- Don't clip during animation
		-- Parent to overlay layer if available, otherwise to element card
		pickerPanel.Parent = baseOverlayLayer or f
		corner(pickerPanel, 12)
		stroke(pickerPanel, pal3.Accent, 2)
		shadow(pickerPanel, 0.7, 20)

		-- Panel padding
		local panelPadding = Instance.new("UIPadding")
		panelPadding.PaddingTop = UDim.new(0, 12)
		panelPadding.PaddingBottom = UDim.new(0, 12)
		panelPadding.PaddingLeft = UDim.new(0, 12)
		panelPadding.PaddingRight = UDim.new(0, 12)
		panelPadding.Parent = pickerPanel

		-- Panel layout
		local panelLayout = Instance.new("UIListLayout")
		panelLayout.FillDirection = Enum.FillDirection.Vertical
		panelLayout.SortOrder = Enum.SortOrder.LayoutOrder
		panelLayout.Padding = UDim.new(0, 8)
		panelLayout.Parent = pickerPanel

		-- Helper: Create a slider row
		local function createSlider(name, min, max, default, callback)
			local row = Instance.new("Frame")
			row.BackgroundTransparency = 1
			row.Size = UDim2.new(1, 0, 0, 32)
			row.LayoutOrder = #pickerPanel:GetChildren()
			row.Parent = pickerPanel

			local label = Instance.new("TextLabel")
			label.BackgroundTransparency = 1
			label.Size = UDim2.new(0, 40, 1, 0)
			label.Font = Enum.Font.GothamMedium
			label.TextSize = 13
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextColor3 = pal3.Text
			label.Text = name
			label.Parent = row

			local valueLabel = Instance.new("TextLabel")
			valueLabel.AnchorPoint = Vector2.new(1, 0)
			valueLabel.Position = UDim2.new(1, 0, 0, 0)
			valueLabel.Size = UDim2.new(0, 40, 1, 0)
			valueLabel.BackgroundTransparency = 1
			valueLabel.Font = Enum.Font.GothamBold
			valueLabel.TextSize = 13
			valueLabel.TextXAlignment = Enum.TextXAlignment.Right
			valueLabel.TextColor3 = pal3.Accent
			valueLabel.Text = tostring(default)
			valueLabel.Parent = row

			-- Slider track
			local track = Instance.new("Frame")
			track.AnchorPoint = Vector2.new(0, 0.5)
			track.Position = UDim2.new(0, 50, 0.5, 0)
			track.Size = UDim2.new(1, -100, 0, 6)
			track.BackgroundColor3 = pal3.Card
			track.BorderSizePixel = 0
			track.Parent = row
			corner(track, 3)

			-- Slider fill
			local fill = Instance.new("Frame")
			fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
			fill.BackgroundColor3 = pal3.Accent
			fill.BorderSizePixel = 0
			fill.Parent = track
			corner(fill, 3)

			-- Slider thumb
			local thumb = Instance.new("Frame")
			thumb.AnchorPoint = Vector2.new(0.5, 0.5)
			thumb.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
			thumb.Size = UDim2.new(0, 16, 0, 16)
			thumb.BackgroundColor3 = pal3.Text
			thumb.BorderSizePixel = 0
			thumb.ZIndex = 5001
			thumb.Parent = track
			corner(thumb, 8)
			stroke(thumb, pal3.Accent, 2)

			-- Slider dragging
			local dragging = false
			local currentValue = default

			-- Update slider visual and value (with optional callback trigger)
			local function updateSlider(value, triggerCallback)
				value = math.clamp(value, min, max)
				currentValue = value

				local percent = (value - min) / (max - min)
				fill.Size = UDim2.new(percent, 0, 1, 0)
				thumb.Position = UDim2.new(percent, 0, 0.5, 0)
				valueLabel.Text = tostring(value)

				-- Only trigger callback if explicitly requested (user interaction)
				if triggerCallback and callback then
					callback(value)
				end
			end

			thumb.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					Animator:Pulse(thumb, 1.2, Animator.Spring.Snappy)
				end
			end)

			thumb.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
					Animator:Pulse(thumb, 1, Animator.Spring.Bounce)
				end
			end)

			track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					local mousePos = input.Position.X
					local trackPos = track.AbsolutePosition.X
					local trackSize = track.AbsoluteSize.X
					local percent = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
					local value = math.floor(min + (percent * (max - min)) + 0.5)
					updateSlider(value, true)  -- User clicked, trigger callback
				end
			end)

			game:GetService("UserInputService").InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					local mousePos = input.Position.X
					local trackPos = track.AbsolutePosition.X
					local trackSize = track.AbsoluteSize.X
					local percent = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
					local value = math.floor(min + (percent * (max - min)) + 0.5)
					updateSlider(value, true)  -- User dragging, trigger callback
				end
			end)

			return {
				Set = function(value)
					updateSlider(value, false)  -- Programmatic set, don't trigger callback
				end,
				Get = function()
					return currentValue
				end
			}
		end

		-- Update color from RGB
		local function updateFromRGB()
			if updatingSliders then return end
			updatingSliders = true

			currentColor = Color3.fromRGB(r, g, b)
			preview.BackgroundColor3 = currentColor

			-- Update HSV
			h, s, v = RGBtoHSV(r, g, b)
			hSlider.Set(h)
			sSlider.Set(s)
			vSlider.Set(v)

			-- Update hex
			hexInput.Text = Color3ToHex(currentColor)

			if o.OnChanged then
				task.spawn(o.OnChanged, currentColor)
			end
			if o.Flag then RvrseUI:_autoSave() end

			updatingSliders = false
		end

		-- Update color from HSV
		local function updateFromHSV()
			if updatingSliders then return end
			updatingSliders = true

			r, g, b = HSVtoRGB(h, s, v)
			currentColor = Color3.fromRGB(r, g, b)
			preview.BackgroundColor3 = currentColor

			-- Update RGB
			rSlider.Set(r)
			gSlider.Set(g)
			bSlider.Set(b)

			-- Update hex
			hexInput.Text = Color3ToHex(currentColor)

			if o.OnChanged then
				task.spawn(o.OnChanged, currentColor)
			end
			if o.Flag then RvrseUI:_autoSave() end

			updatingSliders = false
		end

		-- RGB Section
		local rgbHeader = Instance.new("TextLabel")
		rgbHeader.BackgroundTransparency = 1
		rgbHeader.Size = UDim2.new(1, 0, 0, 20)
		rgbHeader.Font = Enum.Font.GothamBold
		rgbHeader.TextSize = 14
		rgbHeader.TextXAlignment = Enum.TextXAlignment.Left
		rgbHeader.TextColor3 = pal3.Text
		rgbHeader.Text = "RGB"
		rgbHeader.LayoutOrder = 1
		rgbHeader.Parent = pickerPanel

		rSlider = createSlider("R:", 0, 255, r, function(value)
			r = value
			updateFromRGB()
		end)

		gSlider = createSlider("G:", 0, 255, g, function(value)
			g = value
			updateFromRGB()
		end)

		bSlider = createSlider("B:", 0, 255, b, function(value)
			b = value
			updateFromRGB()
		end)

		-- HSV Section
		local hsvHeader = Instance.new("TextLabel")
		hsvHeader.BackgroundTransparency = 1
		hsvHeader.Size = UDim2.new(1, 0, 0, 20)
		hsvHeader.Font = Enum.Font.GothamBold
		hsvHeader.TextSize = 14
		hsvHeader.TextXAlignment = Enum.TextXAlignment.Left
		hsvHeader.TextColor3 = pal3.Text
		hsvHeader.Text = "HSV"
		hsvHeader.LayoutOrder = 5
		hsvHeader.Parent = pickerPanel

		hSlider = createSlider("H:", 0, 360, h, function(value)
			h = value
			updateFromHSV()
		end)

		sSlider = createSlider("S:", 0, 100, s, function(value)
			s = value
			updateFromHSV()
		end)

		vSlider = createSlider("V:", 0, 100, v, function(value)
			v = value
			updateFromHSV()
		end)

		-- Hex Input Section
		local hexHeader = Instance.new("TextLabel")
		hexHeader.BackgroundTransparency = 1
		hexHeader.Size = UDim2.new(1, 0, 0, 20)
		hexHeader.Font = Enum.Font.GothamBold
		hexHeader.TextSize = 14
		hexHeader.TextXAlignment = Enum.TextXAlignment.Left
		hexHeader.TextColor3 = pal3.Text
		hexHeader.Text = "Hex Code"
		hexHeader.LayoutOrder = 9
		hexHeader.Parent = pickerPanel

		local hexRow = Instance.new("Frame")
		hexRow.BackgroundTransparency = 1
		hexRow.Size = UDim2.new(1, 0, 0, 36)
		hexRow.LayoutOrder = 10
		hexRow.Parent = pickerPanel

		hexInput = Instance.new("TextBox")
		hexInput.Size = UDim2.new(1, 0, 1, 0)
		hexInput.BackgroundColor3 = pal3.Card
		hexInput.BorderSizePixel = 0
		hexInput.Font = Enum.Font.GothamMedium
		hexInput.TextSize = 14
		hexInput.TextColor3 = pal3.Text
		hexInput.PlaceholderText = "#FFFFFF"
		hexInput.Text = Color3ToHex(currentColor)
		hexInput.ClearTextOnFocus = false
		hexInput.Parent = hexRow
		corner(hexInput, 8)
		stroke(hexInput, pal3.Border, 1)

		hexInput.FocusLost:Connect(function()
			local color = HexToColor3(hexInput.Text)
			if color then
				updatingSliders = true
				currentColor = color
				preview.BackgroundColor3 = currentColor

				r = math.floor(color.R * 255 + 0.5)
				g = math.floor(color.G * 255 + 0.5)
				b = math.floor(color.B * 255 + 0.5)
				h, s, v = RGBtoHSV(r, g, b)

				rSlider.Set(r)
				gSlider.Set(g)
				bSlider.Set(b)
				hSlider.Set(h)
				sSlider.Set(s)
				vSlider.Set(v)

				if o.OnChanged then
					task.spawn(o.OnChanged, currentColor)
				end
				if o.Flag then RvrseUI:_autoSave() end

				updatingSliders = false
			else
				hexInput.Text = Color3ToHex(currentColor)
			end
		end)

		-- Toggle panel function
		local function setPickerOpen(state)
			if RvrseUI.Store:IsLocked(o.RespectLock) then return end

			pickerOpen = state

			if state then
				-- Show panel and blocker
				pickerPanel.Visible = true
				pickerPanel.Size = UDim2.new(0, 320, 0, 0)  -- Start collapsed

				if OverlayService then
					overlayBlocker = OverlayService:ShowBlocker({
						Transparency = 0.45,
						ZIndex = 4999,
					})
					if overlayBlockerConnection then
						overlayBlockerConnection:Disconnect()
					end
					overlayBlockerConnection = overlayBlocker.MouseButton1Click:Connect(function()
						setPickerOpen(false)
					end)
				end

				-- Wait for layout to calculate, then animate to full height
				task.wait(0.05)
				local targetHeight = panelLayout.AbsoluteContentSize.Y + 24
				if targetHeight < 50 then
					-- Fallback if layout hasn't calculated yet
					targetHeight = 380
				end

				Animator:Tween(pickerPanel, {
					Size = UDim2.new(0, 320, 0, targetHeight)
				}, Animator.Spring.Gentle)

				-- Pulse effect
				Animator:Pulse(preview, 1.15, Animator.Spring.Bounce)
			else
				-- Hide blocker
				if OverlayService then
					if overlayBlockerConnection then
						overlayBlockerConnection:Disconnect()
						overlayBlockerConnection = nil
					end
					OverlayService:HideBlocker(false)
				end

				-- Animate panel close
				Animator:Tween(pickerPanel, {
					Size = UDim2.new(0, 320, 0, 0)
				}, Animator.Spring.Snappy)

				task.delay(0.3, function()
					if not pickerOpen then
						pickerPanel.Visible = false
					end
				end)
			end
		end

		-- Toggle on preview click
		preview.MouseButton1Click:Connect(function()
			setPickerOpen(not pickerOpen)
		end)

		-- Cleanup on destroy
		f.Destroying:Connect(function()
			if pickerOpen then
				setPickerOpen(false)
			end
		end)
	else
		-- Simple mode: Color cycling (original behavior)
		local colors = {
			Color3.fromRGB(255, 0, 0),    -- Red
			Color3.fromRGB(255, 127, 0),  -- Orange
			Color3.fromRGB(255, 255, 0),  -- Yellow
			Color3.fromRGB(0, 255, 0),    -- Green
			Color3.fromRGB(0, 127, 255),  -- Blue
			Color3.fromRGB(139, 0, 255),  -- Purple
			Color3.fromRGB(255, 255, 255),-- White
			Color3.fromRGB(0, 0, 0),      -- Black
		}
		local colorIdx = 1

		preview.MouseButton1Click:Connect(function()
			if RvrseUI.Store:IsLocked(o.RespectLock) then return end
			colorIdx = (colorIdx % #colors) + 1
			currentColor = colors[colorIdx]

			-- Smooth color transition
			Animator:Tween(preview, {BackgroundColor3 = currentColor}, Animator.Spring.Snappy)

			-- Pulse effect
			Animator:Pulse(preview, 1.15, Animator.Spring.Bounce)

			-- Border flashes the new color
			Animator:Tween(previewStroke, {
				Color = currentColor,
				Thickness = 3
			}, Animator.Spring.Lightning)

			task.delay(0.2, function()
				Animator:Tween(previewStroke, {
					Color = pal3.Border,
					Thickness = 2
				}, Animator.Spring.Glide)
			end)

			if o.OnChanged then
				task.spawn(o.OnChanged, currentColor)
			end
			if o.Flag then RvrseUI:_autoSave() end
		end)
	end

	-- Hover effects
	preview.MouseEnter:Connect(function()
		Animator:Tween(previewStroke, {
			Thickness = 3,
			Transparency = 0.2
		}, Animator.Spring.Snappy)

		Animator:Glow(preview, 0.4, 0.5, Theme)
	end)

	preview.MouseLeave:Connect(function()
		Animator:Tween(previewStroke, {
			Thickness = 2,
			Transparency = 0.4
		}, Animator.Spring.Snappy)
	end)

	-- Lock listener
	table.insert(RvrseUI._lockListeners, function()
		local locked = RvrseUI.Store:IsLocked(o.RespectLock)
		lbl.TextTransparency = locked and 0.5 or 0
	end)

	-- API
	local colorpickerAPI = {
		Set = function(_, color)
			if advancedMode and rSlider then
				updatingSliders = true

				currentColor = color
				preview.BackgroundColor3 = color

				r = math.floor(color.R * 255 + 0.5)
				g = math.floor(color.G * 255 + 0.5)
				b = math.floor(color.B * 255 + 0.5)
				h, s, v = RGBtoHSV(r, g, b)

				rSlider.Set(r)
				gSlider.Set(g)
				bSlider.Set(b)
				hSlider.Set(h)
				sSlider.Set(s)
				vSlider.Set(v)
				hexInput.Text = Color3ToHex(currentColor)

				updatingSliders = false
			else
				currentColor = color
				preview.BackgroundColor3 = color
			end
		end,
		Get = function()
			return currentColor
		end,
		SetVisible = function(_, visible)
			f.Visible = visible
		end,
		CurrentValue = currentColor
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = colorpickerAPI
	end

	return colorpickerAPI
end

return ColorPicker
