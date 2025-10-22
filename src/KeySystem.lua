-- KeySystem.lua
-- Advanced key validation system with multiple authentication methods
-- Supports: String keys, Remote keys, HWID whitelist, Discord webhooks

local KeySystem = {}
local deps

function KeySystem:Initialize(dependencies)
	deps = dependencies
end

-- Validate key against configured settings
function KeySystem:ValidateKey(inputKey, settings)
	local keySettings = settings.KeySettings or {}

	-- Method 1: Custom validator function
	if keySettings.Validator and type(keySettings.Validator) == "function" then
		local success, result = pcall(keySettings.Validator, inputKey)
		if success and result == true then
			return true, "Custom validation passed"
		end
		return false, "Invalid key"
	end

	-- Method 2: HWID/UserID whitelist
	if keySettings.Whitelist and type(keySettings.Whitelist) == "table" then
		local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
		local userId = tostring(game.Players.LocalPlayer.UserId)

		for _, entry in ipairs(keySettings.Whitelist) do
			if entry == hwid or entry == userId or entry == inputKey then
				return true, "Whitelist validated"
			end
		end
	end

	-- Method 3: Table of valid keys
	if keySettings.Keys and type(keySettings.Keys) == "table" then
		for _, validKey in ipairs(keySettings.Keys) do
			if inputKey == validKey then
				return true, "Key matched"
			end
		end
	end

	-- Method 4: Single key string (legacy Rayfield compatibility)
	if keySettings.Key and type(keySettings.Key) == "string" then
		if inputKey == keySettings.Key then
			return true, "Key matched"
		end
	end

	return false, "Invalid key"
end

-- Fetch remote key from URL
function KeySystem:FetchRemoteKey(url)
	local success, result = pcall(function()
		return game:HttpGet(url, true)
	end)

	if success then
		-- Strip whitespace and newlines
		result = result:gsub("%s+", "")
		return true, result
	end

	return false, "Failed to fetch remote key"
end

-- Save validated key to file
function KeySystem:SaveKey(fileName, key)
	local folderPath = "RvrseUI/KeySystem"
	local filePath = folderPath .. "/" .. fileName .. ".key"

	-- Create folder if it doesn't exist
	if not isfolder("RvrseUI") then
		makefolder("RvrseUI")
	end
	if not isfolder(folderPath) then
		makefolder(folderPath)
	end

	-- Save key
	local success, err = pcall(function()
		writefile(filePath, key)
	end)

	return success, err
end

-- Load saved key from file
function KeySystem:LoadSavedKey(fileName)
	local filePath = "RvrseUI/KeySystem/" .. fileName .. ".key"

	if isfile(filePath) then
		local success, key = pcall(function()
			return readfile(filePath)
		end)

		if success then
			return true, key
		end
	end

	return false, nil
end

-- Send webhook notification (Discord logging)
function KeySystem:SendWebhook(webhookUrl, data)
	if not webhookUrl or webhookUrl == "" then
		return
	end

	local payload = {
		content = "",
		embeds = {
			{
				title = data.Title or "Key System Event",
				description = data.Description or "",
				color = data.Color or 5814783, -- Default blue
				fields = {
					{
						name = "Username",
						value = game.Players.LocalPlayer.Name,
						inline = true
					},
					{
						name = "User ID",
						value = tostring(game.Players.LocalPlayer.UserId),
						inline = true
					},
					{
						name = "Input Key",
						value = data.Key or "N/A",
						inline = false
					},
					{
						name = "Result",
						value = data.Result or "Unknown",
						inline = false
					},
					{
						name = "Timestamp",
						value = os.date("%Y-%m-%d %H:%M:%S"),
						inline = false
					}
				},
				footer = {
					text = "RvrseUI Key System"
				}
			}
		}
	}

	local success, err = pcall(function()
		local HttpService = game:GetService("HttpService")
		local jsonPayload = HttpService:JSONEncode(payload)

		request({
			Url = webhookUrl,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json"
			},
			Body = jsonPayload
		})
	end)

	if not success then
		warn("[KeySystem] Webhook failed:", err)
	end
end

-- Create key validation UI
function KeySystem:CreateUI(settings, onSuccess, onFailure)
	local keySettings = settings.KeySettings or {}

	-- Get theme colors
	local colors = deps.Theme:Get()

	-- UI Configuration
	local title = keySettings.Title or (settings.Name .. " - Key System")
	local subtitle = keySettings.Subtitle or "Enter your key to continue"
	local note = keySettings.Note or "Visit our website to get a key"
	local noteButton = keySettings.NoteButton or nil

	-- Attempt configuration
	local maxAttempts = keySettings.MaxAttempts or 3
	local attemptsRemaining = maxAttempts

	-- Create ScreenGui
	local KeyGui = Instance.new("ScreenGui")
	KeyGui.Name = deps.Obfuscation:Generate("KeySystem")
	KeyGui.DisplayOrder = 999999
	KeyGui.ResetOnSpawn = false
	KeyGui.IgnoreGuiInset = true

	-- Parent to appropriate container
	if gethui then
		KeyGui.Parent = gethui()
	elseif syn and syn.protect_gui then
		syn.protect_gui(KeyGui)
		KeyGui.Parent = game.CoreGui
	else
		KeyGui.Parent = game.CoreGui
	end

	-- Main container with improved design
	local Container = Instance.new("Frame")
	Container.Name = "Container"
	Container.Size = UDim2.new(0, 500, 0, 0) -- Wider container
	Container.Position = UDim2.new(0.5, 0, 0.5, 0)
	Container.AnchorPoint = Vector2.new(0.5, 0.5)
	Container.BackgroundColor3 = colors.Bg
	Container.BorderSizePixel = 0
	Container.ClipsDescendants = true
	Container.Parent = KeyGui

	-- Rounded corners
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 16)
	Corner.Parent = Container

	-- Gradient border effect
	local Border = Instance.new("UIStroke")
	Border.Color = colors.Accent
	Border.Thickness = 2
	Border.Transparency = 0.5
	Border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Border.LineJoinMode = Enum.LineJoinMode.Round
	Border.Parent = Container

	local BorderGradient = Instance.new("UIGradient")
	BorderGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, colors.Primary),
		ColorSequenceKeypoint.new(0.5, colors.Accent),
		ColorSequenceKeypoint.new(1, colors.Secondary)
	})
	BorderGradient.Rotation = 45
	BorderGradient.Parent = Border

	-- Animated gradient rotation
	task.spawn(function()
		while Container.Parent do
			for i = 0, 360, 2 do
				if not Container.Parent then break end
				BorderGradient.Rotation = i
				task.wait(0.03)
			end
		end
	end)

	-- Shadow/glow effect
	local Glow = Instance.new("ImageLabel")
	Glow.Name = "Glow"
	Glow.Size = UDim2.new(1, 60, 1, 60)
	Glow.Position = UDim2.new(0.5, 0, 0.5, 0)
	Glow.AnchorPoint = Vector2.new(0.5, 0.5)
	Glow.BackgroundTransparency = 1
	Glow.Image = "rbxassetid://5028857084"
	Glow.ImageColor3 = colors.Accent
	Glow.ImageTransparency = 0.6
	Glow.ScaleType = Enum.ScaleType.Slice
	Glow.SliceCenter = Rect.new(24, 24, 276, 276)
	Glow.ZIndex = 0
	Glow.Parent = Container

	-- Header section with gradient
	local Header = Instance.new("Frame")
	Header.Name = "Header"
	Header.Size = UDim2.new(1, 0, 0, 100)
	Header.BackgroundColor3 = colors.Card
	Header.BorderSizePixel = 0
	Header.Parent = Container

	local HeaderCorner = Instance.new("UICorner")
	HeaderCorner.CornerRadius = UDim.new(0, 16)
	HeaderCorner.Parent = Header

	local HeaderGradient = Instance.new("UIGradient")
	HeaderGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, colors.Primary),
		ColorSequenceKeypoint.new(1, colors.Accent)
	})
	HeaderGradient.Rotation = 90
	HeaderGradient.Transparency = NumberSequence.new(0.7)
	HeaderGradient.Parent = Header

	-- Icon
	local Icon = Instance.new("TextLabel")
	Icon.Name = "Icon"
	Icon.Size = UDim2.new(0, 50, 0, 50)
	Icon.Position = UDim2.new(0, 25, 0, 25)
	Icon.BackgroundTransparency = 1
	Icon.Font = Enum.Font.GothamBold
	Icon.Text = "🔐"
	Icon.TextColor3 = colors.TextBright
	Icon.TextSize = 32
	Icon.Parent = Header

	-- Title
	local Title = Instance.new("TextLabel")
	Title.Name = "Title"
	Title.Size = UDim2.new(1, -100, 0, 30)
	Title.Position = UDim2.new(0, 85, 0, 20)
	Title.BackgroundTransparency = 1
	Title.Font = Enum.Font.GothamBold
	Title.Text = title
	Title.TextColor3 = colors.TextBright
	Title.TextSize = 20
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Header

	-- Subtitle
	local Subtitle = Instance.new("TextLabel")
	Subtitle.Name = "Subtitle"
	Subtitle.Size = UDim2.new(1, -100, 0, 20)
	Subtitle.Position = UDim2.new(0, 85, 0, 55)
	Subtitle.BackgroundTransparency = 1
	Subtitle.Font = Enum.Font.Gotham
	Subtitle.Text = subtitle
	Subtitle.TextColor3 = colors.TextSub
	Subtitle.TextSize = 14
	Subtitle.TextXAlignment = Enum.TextXAlignment.Left
	Subtitle.Parent = Header

	-- Content area
	local Content = Instance.new("Frame")
	Content.Name = "Content"
	Content.Size = UDim2.new(1, -40, 1, -120)
	Content.Position = UDim2.new(0, 20, 0, 110)
	Content.BackgroundTransparency = 1
	Content.Parent = Container

	-- Note message
	local NoteLabel = Instance.new("TextLabel")
	NoteLabel.Name = "Note"
	NoteLabel.Size = UDim2.new(1, 0, 0, 40)
	NoteLabel.Position = UDim2.new(0, 0, 0, 0)
	NoteLabel.BackgroundTransparency = 1
	NoteLabel.Font = Enum.Font.Gotham
	NoteLabel.Text = note
	NoteLabel.TextColor3 = colors.TextSub
	NoteLabel.TextSize = 13
	NoteLabel.TextXAlignment = Enum.TextXAlignment.Left
	NoteLabel.TextYAlignment = Enum.TextYAlignment.Top
	NoteLabel.TextWrapped = true
	NoteLabel.Parent = Content

	-- Note button (optional)
	local noteButtonHeight = 0
	if noteButton then
		noteButtonHeight = 45

		local NoteBtn = Instance.new("TextButton")
		NoteBtn.Name = "NoteButton"
		NoteBtn.Size = UDim2.new(1, 0, 0, 38)
		NoteBtn.Position = UDim2.new(0, 0, 0, 50)
		NoteBtn.BackgroundColor3 = colors.Surface
		NoteBtn.BorderSizePixel = 0
		NoteBtn.Font = Enum.Font.GothamMedium
		NoteBtn.Text = "  " .. (noteButton.Text or "Get Key")
		NoteBtn.TextColor3 = colors.Accent
		NoteBtn.TextSize = 14
		NoteBtn.TextXAlignment = Enum.TextXAlignment.Left
		NoteBtn.AutoButtonColor = false
		NoteBtn.Parent = Content

		local NoteBtnCorner = Instance.new("UICorner")
		NoteBtnCorner.CornerRadius = UDim.new(0, 10)
		NoteBtnCorner.Parent = NoteBtn

		local NoteBtnStroke = Instance.new("UIStroke")
		NoteBtnStroke.Color = colors.Accent
		NoteBtnStroke.Thickness = 1.5
		NoteBtnStroke.Transparency = 0.7
		NoteBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		NoteBtnStroke.LineJoinMode = Enum.LineJoinMode.Round
		NoteBtnStroke.Parent = NoteBtn

		local NoteBtnPadding = Instance.new("UIPadding")
		NoteBtnPadding.PaddingLeft = UDim.new(0, 12)
		NoteBtnPadding.Parent = NoteBtn

		NoteBtn.MouseButton1Click:Connect(function()
			if noteButton.Callback then
				noteButton.Callback()
			end
		end)

		-- Hover effect
		NoteBtn.MouseEnter:Connect(function()
			deps.Animator:Tween(NoteBtn, {BackgroundColor3 = colors.HoverBright}, deps.Animator.Spring.Lightning)
			deps.Animator:Tween(NoteBtnStroke, {Transparency = 0.3}, deps.Animator.Spring.Lightning)
		end)
		NoteBtn.MouseLeave:Connect(function()
			deps.Animator:Tween(NoteBtn, {BackgroundColor3 = colors.Surface}, deps.Animator.Spring.Lightning)
			deps.Animator:Tween(NoteBtnStroke, {Transparency = 0.7}, deps.Animator.Spring.Lightning)
		end)
	end

	-- Input box
	local InputBox = Instance.new("TextBox")
	InputBox.Name = "InputBox"
	InputBox.Size = UDim2.new(1, 0, 0, 48)
	InputBox.Position = UDim2.new(0, 0, 0, 55 + noteButtonHeight)
	InputBox.BackgroundColor3 = colors.Surface
	InputBox.BorderSizePixel = 0
	InputBox.Font = Enum.Font.GothamMedium
	InputBox.PlaceholderText = "Enter your key here..."
	InputBox.PlaceholderColor3 = colors.TextMuted
	InputBox.Text = ""
	InputBox.TextColor3 = colors.TextBright
	InputBox.TextSize = 15
	InputBox.ClearTextOnFocus = false
	InputBox.Parent = Content

	local InputCorner = Instance.new("UICorner")
	InputCorner.CornerRadius = UDim.new(0, 10)
	InputCorner.Parent = InputBox

	local InputStroke = Instance.new("UIStroke")
	InputStroke.Color = colors.Border
	InputStroke.Thickness = 1.5
	InputStroke.Transparency = 0.5
	InputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	InputStroke.LineJoinMode = Enum.LineJoinMode.Round
	InputStroke.Parent = InputBox

	local InputPadding = Instance.new("UIPadding")
	InputPadding.PaddingLeft = UDim.new(0, 16)
	InputPadding.PaddingRight = UDim.new(0, 16)
	InputPadding.Parent = InputBox

	-- Input focus effects
	InputBox.Focused:Connect(function()
		deps.Animator:Tween(InputStroke, {Color = colors.Accent, Transparency = 0.2}, deps.Animator.Spring.Lightning)
	end)
	InputBox.FocusLost:Connect(function()
		deps.Animator:Tween(InputStroke, {Color = colors.Border, Transparency = 0.5}, deps.Animator.Spring.Lightning)
	end)

	-- Status label
	local StatusLabel = Instance.new("TextLabel")
	StatusLabel.Name = "Status"
	StatusLabel.Size = UDim2.new(1, 0, 0, 20)
	StatusLabel.Position = UDim2.new(0, 0, 0, 113 + noteButtonHeight)
	StatusLabel.BackgroundTransparency = 1
	StatusLabel.Font = Enum.Font.Gotham
	StatusLabel.Text = string.format("Attempts remaining: %d/%d", attemptsRemaining, maxAttempts)
	StatusLabel.TextColor3 = colors.TextSub
	StatusLabel.TextSize = 12
	StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
	StatusLabel.Parent = Content

	-- Submit button
	local SubmitBtn = Instance.new("TextButton")
	SubmitBtn.Name = "Submit"
	SubmitBtn.Size = UDim2.new(1, 0, 0, 48)
	SubmitBtn.Position = UDim2.new(0, 0, 0, 143 + noteButtonHeight)
	SubmitBtn.BackgroundColor3 = colors.Accent
	SubmitBtn.BorderSizePixel = 0
	SubmitBtn.Font = Enum.Font.GothamBold
	SubmitBtn.Text = "Validate Key"
	SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	SubmitBtn.TextSize = 15
	SubmitBtn.AutoButtonColor = false
	SubmitBtn.Parent = Content

	local SubmitCorner = Instance.new("UICorner")
	SubmitCorner.CornerRadius = UDim.new(0, 10)
	SubmitCorner.Parent = SubmitBtn

	-- Submit button gradient
	local SubmitGradient = Instance.new("UIGradient")
	SubmitGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, colors.Primary),
		ColorSequenceKeypoint.new(1, colors.Accent)
	})
	SubmitGradient.Rotation = 45
	SubmitGradient.Parent = SubmitBtn

	-- Calculate final container height
	local finalHeight = 320 + noteButtonHeight

	-- Animate container entrance
	Container.Size = UDim2.new(0, 500, 0, 0)
	Container.BackgroundTransparency = 1
	Header.BackgroundTransparency = 1
	Icon.TextTransparency = 1
	Title.TextTransparency = 1
	Subtitle.TextTransparency = 1
	NoteLabel.TextTransparency = 1
	StatusLabel.TextTransparency = 1
	InputBox.BackgroundTransparency = 1
	InputBox.TextTransparency = 1
	InputStroke.Transparency = 1
	SubmitBtn.BackgroundTransparency = 1
	SubmitBtn.TextTransparency = 1
	Border.Transparency = 1

	task.wait(0.1)

	-- Smooth entrance animations
	deps.Animator:Tween(Container, {Size = UDim2.new(0, 500, 0, finalHeight)}, deps.Animator.Spring.Bounce)
	deps.Animator:Tween(Container, {BackgroundTransparency = 0}, deps.Animator.Spring.Butter)
	deps.Animator:Tween(Header, {BackgroundTransparency = 0}, deps.Animator.Spring.Butter)
	deps.Animator:Tween(Icon, {TextTransparency = 0}, deps.Animator.Spring.Glide)
	deps.Animator:Tween(Title, {TextTransparency = 0}, deps.Animator.Spring.Glide)
	deps.Animator:Tween(Subtitle, {TextTransparency = 0}, deps.Animator.Spring.Glide)
	deps.Animator:Tween(NoteLabel, {TextTransparency = 0}, deps.Animator.Spring.Glide)
	deps.Animator:Tween(StatusLabel, {TextTransparency = 0}, deps.Animator.Spring.Glide)
	deps.Animator:Tween(InputBox, {BackgroundTransparency = 0, TextTransparency = 0}, deps.Animator.Spring.Glide)
	deps.Animator:Tween(InputStroke, {Transparency = 0.5}, deps.Animator.Spring.Glide)
	deps.Animator:Tween(SubmitBtn, {BackgroundTransparency = 0, TextTransparency = 0}, deps.Animator.Spring.Glide)
	deps.Animator:Tween(Border, {Transparency = 0.5}, deps.Animator.Spring.Glide)

	-- Validation function
	local function validateInput()
		local inputKey = InputBox.Text

		if inputKey == "" then
			-- Shake animation
			deps.Animator:Tween(Container, {Position = UDim2.new(0.5, 10, 0.5, 0)}, deps.Animator.Spring.Lightning)
			task.wait(0.05)
			deps.Animator:Tween(Container, {Position = UDim2.new(0.5, -10, 0.5, 0)}, deps.Animator.Spring.Lightning)
			task.wait(0.05)
			deps.Animator:Tween(Container, {Position = UDim2.new(0.5, 0, 0.5, 0)}, deps.Animator.Spring.Lightning)

			StatusLabel.Text = "⚠️ Please enter a key!"
			StatusLabel.TextColor3 = colors.Warning
			return
		end

		-- Validate key
		local valid, message = KeySystem:ValidateKey(inputKey, settings)

		if valid then
			-- Success!
			StatusLabel.Text = "✓ Key validated! Loading..."
			StatusLabel.TextColor3 = colors.Success

			-- Save key if enabled
			if keySettings.SaveKey then
				local fileName = keySettings.FileName or settings.Name or "Key"
				KeySystem:SaveKey(fileName, inputKey)
			end

			-- Send webhook if configured
			if keySettings.WebhookURL then
				KeySystem:SendWebhook(keySettings.WebhookURL, {
					Title = "Key Validated ✓",
					Description = "User successfully validated key",
					Color = 3066993,
					Key = inputKey,
					Result = "Success: " .. message
				})
			end

			-- Callback
			if keySettings.OnKeyValid then
				keySettings.OnKeyValid(inputKey)
			end

			-- Animate out
			task.wait(0.5)
			deps.Animator:Tween(Container, {Size = UDim2.new(0, 500, 0, 0), BackgroundTransparency = 1}, deps.Animator.Spring.Expo)
			deps.Animator:Tween(Header, {BackgroundTransparency = 1}, deps.Animator.Spring.Expo)
			deps.Animator:Tween(Icon, {TextTransparency = 1}, deps.Animator.Spring.Expo)
			deps.Animator:Tween(Title, {TextTransparency = 1}, deps.Animator.Spring.Expo)
			deps.Animator:Tween(Subtitle, {TextTransparency = 1}, deps.Animator.Spring.Expo)
			deps.Animator:Tween(NoteLabel, {TextTransparency = 1}, deps.Animator.Spring.Expo)
			deps.Animator:Tween(StatusLabel, {TextTransparency = 1}, deps.Animator.Spring.Expo)
			deps.Animator:Tween(InputBox, {BackgroundTransparency = 1, TextTransparency = 1}, deps.Animator.Spring.Expo)
			deps.Animator:Tween(SubmitBtn, {BackgroundTransparency = 1, TextTransparency = 1}, deps.Animator.Spring.Expo)
			deps.Animator:Tween(Border, {Transparency = 1}, deps.Animator.Spring.Expo)

			task.wait(0.6)
			KeyGui:Destroy()

			-- Success callback
			if onSuccess then
				onSuccess(inputKey)
			end
		else
			-- Invalid key
			attemptsRemaining = attemptsRemaining - 1

			-- Shake animation
			deps.Animator:Tween(Container, {Position = UDim2.new(0.5, 15, 0.5, 0)}, deps.Animator.Spring.Lightning)
			task.wait(0.05)
			deps.Animator:Tween(Container, {Position = UDim2.new(0.5, -15, 0.5, 0)}, deps.Animator.Spring.Lightning)
			task.wait(0.05)
			deps.Animator:Tween(Container, {Position = UDim2.new(0.5, 0, 0.5, 0)}, deps.Animator.Spring.Lightning)

			-- Send webhook if configured
			if keySettings.WebhookURL then
				KeySystem:SendWebhook(keySettings.WebhookURL, {
					Title = "Invalid Key Attempt ✗",
					Description = "User entered invalid key",
					Color = 15158332,
					Key = inputKey,
					Result = "Failed: " .. message .. " | Attempts remaining: " .. attemptsRemaining
				})
			end

			-- Callback
			if keySettings.OnKeyInvalid then
				keySettings.OnKeyInvalid(inputKey, attemptsRemaining)
			end

			if attemptsRemaining <= 0 then
				-- Out of attempts
				StatusLabel.Text = "✗ Out of attempts! Closing..."
				StatusLabel.TextColor3 = colors.Error

				-- Callback
				if keySettings.OnAttemptsExhausted then
					keySettings.OnAttemptsExhausted()
				end

				task.wait(1)

				-- Kick player if configured
				if keySettings.KickOnFailure ~= false then
					game.Players.LocalPlayer:Kick("Key validation failed - No attempts remaining")
				end

				KeyGui:Destroy()

				-- Failure callback
				if onFailure then
					onFailure("No attempts remaining")
				end
			else
				-- Update status
				StatusLabel.Text = string.format("✗ Invalid key! Attempts: %d/%d", attemptsRemaining, maxAttempts)
				StatusLabel.TextColor3 = colors.Error

				-- Clear input
				InputBox.Text = ""
			end
		end
	end

	-- Submit button click
	SubmitBtn.MouseButton1Click:Connect(validateInput)

	-- Enter key support
	InputBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			validateInput()
		end
	end)

	-- Hover effects
	SubmitBtn.MouseEnter:Connect(function()
		deps.Animator:Tween(SubmitBtn, {BackgroundColor3 = colors.AccentHover}, deps.Animator.Spring.Lightning)
	end)
	SubmitBtn.MouseLeave:Connect(function()
		deps.Animator:Tween(SubmitBtn, {BackgroundColor3 = colors.Accent}, deps.Animator.Spring.Lightning)
	end)

	-- Focus input box
	task.wait(0.8)
	InputBox:CaptureFocus()

	return KeyGui
end

-- Main entry point: Process key system for window
function KeySystem:Process(settings, callback)
	local keySettings = settings.KeySettings or {}

	-- Check if key system is enabled
	if not settings.KeySystem or settings.KeySystem == false then
		if callback then
			callback(true, "Key system disabled")
		end
		return true
	end

	-- Try to load saved key
	if keySettings.SaveKey then
		local fileName = keySettings.FileName or settings.Name or "Key"
		local success, savedKey = KeySystem:LoadSavedKey(fileName)

		if success and savedKey then
			-- Validate saved key
			local valid, message = KeySystem:ValidateKey(savedKey, settings)

			if valid then
				deps.Debug.printf("[KeySystem] Loaded saved key: %s", message)

				if callback then
					callback(true, "Saved key validated")
				end
				return true
			else
				deps.Debug.printf("[KeySystem] Saved key invalid, showing UI")
			end
		end
	end

	-- Fetch remote key if configured
	if keySettings.GrabKeyFromSite and keySettings.Key and type(keySettings.Key) == "string" then
		local success, remoteKey = KeySystem:FetchRemoteKey(keySettings.Key)

		if success then
			keySettings.Keys = {remoteKey}
			deps.Debug.printf("[KeySystem] Fetched remote key")
		else
			warn("[KeySystem] Failed to fetch remote key:", remoteKey)
		end
	end

	-- Show key validation UI
	local passthrough = false
	local errorMsg = nil

	KeySystem:CreateUI(settings, function(validKey)
		passthrough = true
	end, function(errMsg)
		passthrough = false
		errorMsg = errMsg
	end)

	-- Block execution until validated
	repeat
		task.wait()
	until passthrough == true or errorMsg ~= nil

	if callback then
		callback(passthrough, errorMsg or "Key validated")
	end

	return passthrough
end

return KeySystem
