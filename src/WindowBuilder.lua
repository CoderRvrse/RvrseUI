-- WindowBuilder.lua
-- Creates and manages the main window structure
-- This is the largest module, responsible for building the entire UI hierarchy

local WindowBuilder = {}

-- Dependencies will be injected via Initialize()
local Theme, Animator, State, Config, UIHelpers, Icons, TabBuilder, SectionBuilder, WindowManager, NotificationsService
local Debug, Obfuscation, Hotkeys, Version, Elements, OverlayLayer, Overlay

-- Roblox services (will be injected)
local UIS, GuiService, RS, PlayerGui, HttpService

function WindowBuilder:Initialize(deps)
	-- Inject all dependencies
	Theme = deps.Theme
	Animator = deps.Animator
	State = deps.State
	Config = deps.Config
	UIHelpers = deps.UIHelpers
	Icons = deps.Icons
	TabBuilder = deps.TabBuilder
	SectionBuilder = deps.SectionBuilder
	WindowManager = deps.WindowManager
	NotificationsService = deps.Notifications
	Debug = deps.Debug
	Obfuscation = deps.Obfuscation
	Hotkeys = deps.Hotkeys
	Version = deps.Version
	Elements = deps.Elements
	OverlayLayer = deps.OverlayLayer
	Overlay = deps.Overlay

	-- Services
	UIS = deps.UIS
	GuiService = deps.GuiService
	RS = deps.RS
	PlayerGui = deps.PlayerGui
	HttpService = deps.HttpService
end

-- Extract all the CreateWindow logic from RvrseUI.lua lines 1293-3922
function WindowBuilder:CreateWindow(RvrseUI, cfg, host)
	cfg = cfg or {}

	local overlayLayer = Overlay and Overlay:GetLayer() or OverlayLayer

	Debug.printf("=== CREATEWINDOW THEME DEBUG ===")

	-- IMPORTANT: Load saved theme FIRST before applying precedence
	if RvrseUI.ConfigurationSaving and RvrseUI.ConfigurationFileName then
		local fullPath = RvrseUI.ConfigurationFileName
		if RvrseUI.ConfigurationFolderName then
			fullPath = RvrseUI.ConfigurationFolderName .. "/" .. RvrseUI.ConfigurationFileName
		end

		Debug.printf("🔍 PRE-LOAD VERIFICATION (CreateWindow)")
		Debug.printf("PRE-LOAD PATH:", fullPath)
		Debug.printf("CONFIG INSTANCE:", tostring(RvrseUI))

		if type(readfile) ~= "function" then
			Debug.printf("[FS] readfile unavailable - skipping config pre-load")
		else
			local success, existingConfig = pcall(readfile, fullPath)
			if success and existingConfig then
				local decodeOk, decoded = pcall(HttpService.JSONDecode, HttpService, existingConfig)
				if decodeOk and typeof(decoded) == "table" then
					Debug.printf("PRE-LOAD VALUE: _RvrseUI_Theme =", decoded._RvrseUI_Theme or "nil")
					if decoded._RvrseUI_Theme then
						RvrseUI._savedTheme = decoded._RvrseUI_Theme
						Debug.printf("✅ Pre-loaded saved theme from config:", RvrseUI._savedTheme)
					end
				else
					Debug.printf("PRE-LOAD: JSON decode failed:", decoded)
				end
			else
				Debug.printf("PRE-LOAD readfile failed:", existingConfig)
			end
		end
	end

	Debug.printf("RvrseUI._savedTheme:", RvrseUI._savedTheme)
	Debug.printf("cfg.Theme:", cfg.Theme)
	Debug.printf("Theme.Current before:", Theme.Current)

	-- Deterministic precedence: saved theme wins, else cfg.Theme, else default
	local finalTheme = RvrseUI._savedTheme or cfg.Theme or "Dark"
	local source = RvrseUI._savedTheme and "saved" or (cfg.Theme and "cfg") or "default"

	-- Apply theme (does NOT mark dirty - this is initialization)
	Theme:Apply(finalTheme)

	Debug.printf("🎯 FINAL THEME APPLICATION")
	Debug.printf("✅ Applied theme (source=" .. source .. "):", finalTheme)
	Debug.printf("Theme.Current after:", Theme.Current)
	Debug.printf("Theme._dirty:", Theme._dirty)

	-- Assert valid theme
	assert(Theme.Current == "Dark" or Theme.Current == "Light", "Invalid Theme.Current at end of init: " .. tostring(Theme.Current))

	local pal = Theme:Get()

	-- Configuration system setup
	local autoSaveEnabled = true

	if cfg.ConfigurationSaving then
		if typeof(cfg.ConfigurationSaving) == "string" then
			RvrseUI.ConfigurationSaving = true
			RvrseUI.ConfigurationFileName = cfg.ConfigurationSaving .. ".json"
			RvrseUI.ConfigurationFolderName = "RvrseUI/Configs"
			Debug.printf("📂 Named profile mode:", cfg.ConfigurationSaving)
		elseif typeof(cfg.ConfigurationSaving) == "table" then
			RvrseUI.ConfigurationSaving = cfg.ConfigurationSaving.Enabled or true
			RvrseUI.ConfigurationFileName = cfg.ConfigurationSaving.FileName or "RvrseUI_Config.json"
			RvrseUI.ConfigurationFolderName = cfg.ConfigurationSaving.FolderName
			autoSaveEnabled = cfg.ConfigurationSaving.AutoSave ~= false
			Debug.printf("Configuration saving enabled:", RvrseUI.ConfigurationFolderName and (RvrseUI.ConfigurationFolderName .. "/" .. RvrseUI.ConfigurationFileName) or RvrseUI.ConfigurationFileName)
		elseif cfg.ConfigurationSaving == true then
			local lastConfig, lastTheme = RvrseUI:GetLastConfig()
			if lastConfig then
				Debug.printf("📂 Auto-loading last config:", lastConfig)
				local folder, file = lastConfig:match("^(.*)/([^/]+)$")
				if folder and file then
					RvrseUI.ConfigurationFolderName = folder
					RvrseUI.ConfigurationFileName = file
				else
					RvrseUI.ConfigurationFolderName = nil
					RvrseUI.ConfigurationFileName = lastConfig
				end
				RvrseUI.ConfigurationSaving = true

				if lastTheme then
					RvrseUI._savedTheme = lastTheme
					Debug.printf("📂 Overriding theme with last saved:", lastTheme)
				end
			else
				RvrseUI.ConfigurationSaving = true
				RvrseUI.ConfigurationFileName = "RvrseUI_Config.json"
				Debug.printf("📂 No last config, using default")
			end
		end
	end

	Config.ConfigurationSaving = RvrseUI.ConfigurationSaving
	Config.ConfigurationFileName = RvrseUI.ConfigurationFileName
	Config.ConfigurationFolderName = RvrseUI.ConfigurationFolderName
	Config.AutoSaveEnabled = autoSaveEnabled
	RvrseUI.AutoSaveEnabled = autoSaveEnabled

	local name = cfg.Name or "RvrseUI"
	local toggleKey = UIHelpers.coerceKeycode(cfg.ToggleUIKeybind or "K")
	RvrseUI.UI:BindToggleKey(toggleKey)

	local escapeKey = cfg.EscapeKey or Enum.KeyCode.Backspace
	if type(escapeKey) == "string" then
		escapeKey = UIHelpers.coerceKeycode(escapeKey)
	end
	RvrseUI.UI:BindEscapeKey(escapeKey)

	-- Container selection
	local windowHost = host

	if cfg.Container then
		local customHost = Instance.new("ScreenGui")
		customHost.Name = "_TestModule_" .. name:gsub("%s", "")
		customHost.ResetOnSpawn = false
		customHost.IgnoreGuiInset = false
		customHost.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		customHost.DisplayOrder = cfg.DisplayOrder or 100000

		local containerTarget = nil

		if typeof(cfg.Container) == "string" then
			local containerMap = {
				["PlayerGui"] = PlayerGui,
				["CoreGui"] = game:GetService("CoreGui"),
				["StarterGui"] = game:GetService("StarterGui"),
				["ReplicatedFirst"] = game:GetService("ReplicatedFirst"),
			}
			containerTarget = containerMap[cfg.Container]
		elseif typeof(cfg.Container) == "Instance" then
			containerTarget = cfg.Container
		end

		if containerTarget then
			customHost.Parent = containerTarget
			windowHost = customHost
			table.insert(RvrseUI._windows, {host = customHost})
			Debug.printf("Container set to:", cfg.Container)
		else
			warn("[RvrseUI] Invalid container specified, using default PlayerGui")
		end
	end

	-- Detect mobile/tablet
	local isMobile = UIS.TouchEnabled and not UIS.MouseEnabled
	local baseWidth = isMobile and 380 or 580
	local baseHeight = isMobile and 520 or 480

	-- Root window
	local root = Instance.new("Frame")
	root.Name = Obfuscation.getObfuscatedName("window")
	root.Size = UDim2.new(0, baseWidth, 0, baseHeight)

	local screenSize = workspace.CurrentCamera.ViewportSize
	local centerX = (screenSize.X - baseWidth) / 2
	local centerY = (screenSize.Y - baseHeight) / 2
	root.Position = UDim2.fromOffset(centerX, centerY)
	root.BackgroundColor3 = pal.Bg
	root.BackgroundTransparency = 1  -- TRANSPARENT - let children show through
	root.BorderSizePixel = 0
	root.Visible = false
	root.ClipsDescendants = false
	root.ZIndex = 100
	root.Parent = windowHost
	UIHelpers.corner(root, 16)
	UIHelpers.stroke(root, pal.Accent, 2)

	-- Header bar with gloss effect
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 52)
	header.BackgroundColor3 = pal.Card
	header.BackgroundTransparency = 0
	header.BorderSizePixel = 0
	header.Parent = root
	UIHelpers.addGloss(header, Theme)
	UIHelpers.corner(header, 16)

	-- Gradient overlay on header
	local headerGradient = Instance.new("UIGradient")
	headerGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, pal.Primary),
		ColorSequenceKeypoint.new(0.5, pal.Accent),
		ColorSequenceKeypoint.new(1, pal.Secondary),
	}
	headerGradient.Rotation = 90
	headerGradient.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.7),
		NumberSequenceKeypoint.new(1, 0.7),
	}
	headerGradient.Parent = header

	-- Header border
	local headerStroke = Instance.new("UIStroke")
	headerStroke.Color = pal.BorderGlow
	headerStroke.Thickness = 1
	headerStroke.Transparency = 0.5
	headerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	headerStroke.Parent = header

	local headerDivider = Instance.new("Frame")
	headerDivider.BackgroundColor3 = pal.Divider
	headerDivider.BackgroundTransparency = 0.5
	headerDivider.BorderSizePixel = 0
	headerDivider.Position = UDim2.new(0, 12, 1, -1)
	headerDivider.Size = UDim2.new(1, -24, 0, 1)
	headerDivider.Parent = header

	-- Content region beneath header
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.Position = UDim2.new(0, 0, 0, header.Size.Y.Offset)
	content.Size = UDim2.new(1, 0, 1, -header.Size.Y.Offset)
	content.Parent = root

	-- ═══════════════════════════════════════════════════════════════
	-- ADVANCED CURSOR-LOCKED DRAG SYSTEM - Window Header
	-- ═══════════════════════════════════════════════════════════════
	-- Ensures the cursor stays perfectly glued to the exact grab point
	-- during the entire drag operation. Handles GUI inset, touch, and
	-- mouse input with sub-pixel precision.
	-- ═══════════════════════════════════════════════════════════════

	local dragging, activeDragInput
	local dragPointerOffset
	local headerLastPointer
	local hostScreenGui = typeof(windowHost) == "Instance"
		and windowHost:IsA("ScreenGui")
		and windowHost
	if hostScreenGui and hostScreenGui.ZIndexBehavior ~= Enum.ZIndexBehavior.Global then
		Debug.printf("[DRAG] Enforcing Global ZIndexBehavior on host ScreenGui")
		hostScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	end
	local hostIgnoresInset = hostScreenGui and windowHost.IgnoreGuiInset == true

	-- Get current pointer position in screen space (touch or mouse)
	local function getPointerPosition(inputObject)
		if inputObject and inputObject.UserInputType == Enum.UserInputType.Touch then
			return Vector2.new(inputObject.Position.X, inputObject.Position.Y)
		end
		return UIS:GetMouseLocation()
	end

	-- Get GUI inset offset vector
	local function getGuiInset()
		if hostScreenGui and hostIgnoresInset then
			return Vector2.new(0, 0)
		end

		local inset = GuiService:GetGuiInset()
		return Vector2.new(inset.X, inset.Y)
	end

	-- Finish drag and save final position
	local function finishDrag()
		if not dragging then
			return
		end

		dragging = false
		activeDragInput = nil
		dragPointerOffset = nil
		headerLastPointer = nil

		-- Save absolute position for restoration
		RvrseUI._lastWindowPosition = {
			XScale = 0,
			XOffset = root.AbsolutePosition.X,
			YScale = 0,
			YOffset = root.AbsolutePosition.Y
		}

		Debug.printf("[DRAG] Finished - saved position: X=%d, Y=%d",
			root.AbsolutePosition.X, root.AbsolutePosition.Y)
	end

	-- Start dragging when header is clicked
	header.Active = true

	header.InputBegan:Connect(function(io)
		if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			activeDragInput = io
			local pointer = getPointerPosition(io)
			dragPointerOffset = pointer - root.AbsolutePosition
			headerLastPointer = pointer
			Debug.printf("[DRAG] Cached offset: X=%.2f, Y=%.2f", dragPointerOffset.X, dragPointerOffset.Y)
			Debug.printf("[DRAG] Started - input type: %s", tostring(io.UserInputType))
		end
	end)

	-- End drag when released on header
	header.InputEnded:Connect(function(io)
		if io == activeDragInput then
			finishDrag()
		end
	end)

	-- Main drag update loop - maintains cursor lock
	UIS.InputChanged:Connect(function(io)
		if not dragging then
			return
		end

		-- Check if this is our active drag input
		local isMouseDrag = io.UserInputType == Enum.UserInputType.MouseMovement
			and activeDragInput
			and activeDragInput.UserInputType == Enum.UserInputType.MouseButton1
		local isTouchDrag = io == activeDragInput

		if not isMouseDrag and not isTouchDrag then
			return
		end

		local pointerPosition = getPointerPosition(io)
		if not dragPointerOffset then
			dragPointerOffset = pointerPosition - root.AbsolutePosition
		end
		local previousPointer = headerLastPointer or pointerPosition
		headerLastPointer = pointerPosition

		-- Calculate target top-left using cached delta
		local targetTopLeftX = pointerPosition.X - dragPointerOffset.X
		local targetTopLeftY = pointerPosition.Y - dragPointerOffset.Y

		-- Get screen bounds for clamping
		local currentCamera = workspace.CurrentCamera
		local screenSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1920, 1080)
		local inset = getGuiInset()
		local windowWidth = root.AbsoluteSize.X
		local headerHeight = 52

		-- Clamp to keep window mostly on screen
		local effectiveWidth = hostIgnoresInset and screenSize.X or (screenSize.X + inset.X)
		local effectiveHeight = hostIgnoresInset and screenSize.Y or (screenSize.Y + inset.Y)
		local minTopLeftX = -(windowWidth - 100)
		local maxTopLeftX = effectiveWidth - 100
		local minTopLeftY = hostIgnoresInset and 0 or inset.Y
		local maxTopLeftY = effectiveHeight - headerHeight

		targetTopLeftX = math.clamp(targetTopLeftX, minTopLeftX, maxTopLeftX)
		targetTopLeftY = math.clamp(targetTopLeftY, minTopLeftY, maxTopLeftY)

		local finalX = targetTopLeftX
		local finalY = targetTopLeftY
		if not hostIgnoresInset then
			finalX -= inset.X
			finalY -= inset.Y
		end

		root.Position = UDim2.fromOffset(
			math.floor(finalX + 0.5),
			math.floor(finalY + 0.5)
		)

		if Debug:IsEnabled() then
			local gluePoint = Vector2.new(targetTopLeftX + dragPointerOffset.X, targetTopLeftY + dragPointerOffset.Y)
			local pointerDelta = pointerPosition - previousPointer
			local distance = pointerDelta.Magnitude
			Debug.printf("[DRAG][Header] pointer=(%.1f, %.1f) prev=(%.1f, %.1f) glue=(%.1f, %.1f) delta=(%.2f, %.2f) dist=%.2f",
				pointerPosition.X, pointerPosition.Y,
				previousPointer.X, previousPointer.Y,
				gluePoint.X, gluePoint.Y,
				pointerDelta.X, pointerDelta.Y,
				distance
			)
		end
	end)

	-- Global input end handler (in case release happens outside header)
	UIS.InputEnded:Connect(function(io)
		if io == activeDragInput then
			finishDrag()
		end
	end)

	-- Icon
	local iconHolder = Instance.new("Frame")
	iconHolder.BackgroundTransparency = 1
	iconHolder.Position = UDim2.new(0, 16, 0.5, -16)
	iconHolder.Size = UDim2.new(0, 32, 0, 32)
	iconHolder.Parent = header

	if cfg.Icon and cfg.Icon ~= 0 then
		local iconAsset, iconType = Icons.resolveIcon(cfg.Icon)

		if iconType == "image" then
			local img = Instance.new("ImageLabel")
			img.BackgroundTransparency = 1
			img.Image = iconAsset
			img.Size = UDim2.new(1, 0, 1, 0)
			img.ImageColor3 = pal.Accent
			img.Parent = iconHolder
			UIHelpers.corner(img, 8)
		elseif iconType == "text" then
			local iconTxt = Instance.new("TextLabel")
			iconTxt.BackgroundTransparency = 1
			iconTxt.Font = Enum.Font.GothamBold
			iconTxt.TextSize = 20
			iconTxt.TextColor3 = pal.Accent
			iconTxt.Text = iconAsset
			iconTxt.Size = UDim2.new(1, 0, 1, 0)
			iconTxt.Parent = iconHolder
		end
	end

	-- Title
	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 56, 0, 0)
	title.Size = UDim2.new(1, -120, 1, 0)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.TextColor3 = pal.Text
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = name
	title.Parent = header

	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.AnchorPoint = Vector2.new(1, 0.5)
	closeBtn.Position = UDim2.new(1, -12, 0.5, 0)
	closeBtn.Size = UDim2.new(0, 32, 0, 32)
	closeBtn.BackgroundColor3 = pal.Elevated
	closeBtn.BackgroundTransparency = 0
	closeBtn.BorderSizePixel = 0
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 18
	closeBtn.Text = "❌"
	closeBtn.TextColor3 = pal.Error
	closeBtn.AutoButtonColor = false
	closeBtn.Parent = header
	UIHelpers.corner(closeBtn, 8)
	UIHelpers.stroke(closeBtn, pal.Error, 1)

	local closeTooltip = UIHelpers.createTooltip(closeBtn, "Close UI")

	closeBtn.MouseEnter:Connect(function()
		closeTooltip.Visible = true
		local currentPal = Theme:Get()
		Animator:Tween(closeBtn, {BackgroundColor3 = currentPal.Hover}, Animator.Spring.Fast)
	end)
	closeBtn.MouseLeave:Connect(function()
		closeTooltip.Visible = false
		local currentPal = Theme:Get()
		Animator:Tween(closeBtn, {BackgroundColor3 = currentPal.Elevated}, Animator.Spring.Fast)
	end)

	closeBtn.MouseButton1Click:Connect(function()
		if Overlay then
			Overlay:HideBlocker(true)
		end
		Animator:Ripple(closeBtn, 16, 16)
		Animator:Tween(root, {BackgroundTransparency = 1}, Animator.Spring.Fast)

		task.wait(0.3)

		if host and host.Parent then
			host:Destroy()
		end

		if RvrseUI.UI._toggleTargets then
			table.clear(RvrseUI.UI._toggleTargets)
		end
		if RvrseUI._lockListeners then
			table.clear(RvrseUI._lockListeners)
		end
		if RvrseUI._themeListeners then
			table.clear(RvrseUI._themeListeners)
		end

		print("[RvrseUI] Interface destroyed - No trace remaining")
	end)

	-- Notification Bell Toggle
	local bellToggle = Instance.new("TextButton")
	bellToggle.Name = "BellToggle"
	bellToggle.AnchorPoint = Vector2.new(1, 0.5)
	bellToggle.Position = UDim2.new(1, -52, 0.5, 0)
	bellToggle.Size = UDim2.new(0, 32, 0, 24)
	bellToggle.BackgroundColor3 = pal.Elevated
	bellToggle.BorderSizePixel = 0
	bellToggle.Font = Enum.Font.GothamBold
	bellToggle.TextSize = 14
	bellToggle.Text = "🔔"
	bellToggle.TextColor3 = pal.Success
	bellToggle.AutoButtonColor = false
	bellToggle.Parent = header
	UIHelpers.corner(bellToggle, 12)
	UIHelpers.stroke(bellToggle, pal.Border, 1)
	UIHelpers.addGlow(bellToggle, pal.Success, 1.5)

	local bellTooltip = UIHelpers.createTooltip(bellToggle, "Notifications: ON")

	bellToggle.MouseEnter:Connect(function()
		bellTooltip.Visible = true
		local currentPal = Theme:Get()
		Animator:Tween(bellToggle, {BackgroundColor3 = currentPal.Hover}, Animator.Spring.Fast)
	end)
	bellToggle.MouseLeave:Connect(function()
		bellTooltip.Visible = false
		local currentPal = Theme:Get()
		Animator:Tween(bellToggle, {BackgroundColor3 = currentPal.Elevated}, Animator.Spring.Fast)
	end)

	bellToggle.MouseButton1Click:Connect(function()
		local currentPal = Theme:Get()
		RvrseUI.NotificationsEnabled = not RvrseUI.NotificationsEnabled
		if RvrseUI.NotificationsEnabled then
			bellToggle.Text = "🔔"
			bellToggle.TextColor3 = currentPal.Success
			bellTooltip.Text = "  Notifications: ON  "
			if bellToggle:FindFirstChild("Glow") then
				bellToggle.Glow:Destroy()
			end
			UIHelpers.addGlow(bellToggle, currentPal.Success, 1.5)
		else
			bellToggle.Text = "🔕"
			bellToggle.TextColor3 = currentPal.Error
			bellTooltip.Text = "  Notifications: OFF  "
			if bellToggle:FindFirstChild("Glow") then
				bellToggle.Glow:Destroy()
			end
		end
		Animator:Ripple(bellToggle, 25, 12)
	end)

	-- Minimize button
	local minimizeBtn = Instance.new("TextButton")
	minimizeBtn.Name = "MinimizeButton"
	minimizeBtn.AnchorPoint = Vector2.new(1, 0.5)
	minimizeBtn.Position = UDim2.new(1, -132, 0.5, 0)
	minimizeBtn.Size = UDim2.new(0, 32, 0, 24)
	minimizeBtn.BackgroundColor3 = pal.Elevated
	minimizeBtn.BorderSizePixel = 0
	minimizeBtn.Font = Enum.Font.GothamBold
	minimizeBtn.TextSize = 18
	minimizeBtn.Text = "➖"
	minimizeBtn.TextColor3 = pal.Accent
	minimizeBtn.AutoButtonColor = false
	minimizeBtn.Parent = header
	UIHelpers.corner(minimizeBtn, 12)
	UIHelpers.stroke(minimizeBtn, pal.Border, 1)

	local minimizeTooltip = UIHelpers.createTooltip(minimizeBtn, "Minimize to Controller")

	minimizeBtn.MouseEnter:Connect(function()
		minimizeTooltip.Visible = true
		local currentPal = Theme:Get()
		Animator:Tween(minimizeBtn, {BackgroundColor3 = currentPal.Hover}, Animator.Spring.Fast)
	end)
	minimizeBtn.MouseLeave:Connect(function()
		minimizeTooltip.Visible = false
		local currentPal = Theme:Get()
		Animator:Tween(minimizeBtn, {BackgroundColor3 = currentPal.Elevated}, Animator.Spring.Fast)
	end)

	-- Theme Toggle Pill
	local themeToggle = Instance.new("TextButton")
	themeToggle.Name = "ThemeToggle"
	themeToggle.AnchorPoint = Vector2.new(1, 0.5)
	themeToggle.Position = UDim2.new(1, -92, 0.5, 0)
	themeToggle.Size = UDim2.new(0, 32, 0, 24)
	themeToggle.BackgroundColor3 = pal.Elevated
	themeToggle.BorderSizePixel = 0
	themeToggle.Font = Enum.Font.GothamBold
	themeToggle.TextSize = 14
	themeToggle.Text = Theme.Current == "Dark" and "🌙" or "🌞"
	themeToggle.TextColor3 = pal.Accent
	themeToggle.AutoButtonColor = false
	themeToggle.Parent = header
	UIHelpers.corner(themeToggle, 12)
	UIHelpers.stroke(themeToggle, pal.Border, 1)

	local themeTooltip = UIHelpers.createTooltip(themeToggle, "Theme: " .. Theme.Current)

	themeToggle.MouseEnter:Connect(function()
		themeTooltip.Visible = true
		local currentPal = Theme:Get()
		Animator:Tween(themeToggle, {BackgroundColor3 = currentPal.Hover}, Animator.Spring.Fast)
	end)
	themeToggle.MouseLeave:Connect(function()
		themeTooltip.Visible = false
		local currentPal = Theme:Get()
		Animator:Tween(themeToggle, {BackgroundColor3 = currentPal.Elevated}, Animator.Spring.Fast)
	end)

	-- Version badge
	local versionBadge = Instance.new("TextButton")
	versionBadge.Name = Obfuscation.getObfuscatedName("badge")
	versionBadge.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
	versionBadge.BackgroundTransparency = 0.9
	versionBadge.Position = UDim2.new(0, 8, 1, -24)
	versionBadge.Size = UDim2.new(0, 38, 0, 14)
	versionBadge.Font = Enum.Font.GothamBold
	versionBadge.TextSize = 7
	versionBadge.TextColor3 = Color3.fromRGB(0, 255, 200)
	versionBadge.Text = "v" .. Version.Full
	versionBadge.AutoButtonColor = false
	versionBadge.Parent = root
	UIHelpers.corner(versionBadge, 5)
	UIHelpers.stroke(versionBadge, Color3.fromRGB(0, 255, 200), 1)

	local versionTooltip = UIHelpers.createTooltip(versionBadge, string.format(
		"Version: %s | Build: %s | Hash: %s | Channel: %s",
		Version.Full,
		Version.Build,
		Version.Hash,
		Version.Channel
	))

	versionBadge.MouseEnter:Connect(function()
		versionTooltip.Visible = true
		Animator:Tween(versionBadge, {BackgroundTransparency = 0.7}, Animator.Spring.Fast)
	end)
	versionBadge.MouseLeave:Connect(function()
		versionTooltip.Visible = false
		Animator:Tween(versionBadge, {BackgroundTransparency = 0.9}, Animator.Spring.Fast)
	end)

	versionBadge.MouseButton1Click:Connect(function()
		if NotificationsService and NotificationsService.Notify then
			local info = RvrseUI:GetVersionInfo()
			NotificationsService:Notify({
				Title = "RvrseUI " .. RvrseUI:GetVersionString(),
				Message = string.format("Hash: %s | Channel: %s", info.Hash, info.Channel),
				Duration = 4,
				Type = "info"
			})
		end
	end)

	-- Sleek vertical icon-only tab rail
	local railWidth = 80 -- Narrower for icon-only design
	local tabBar = Instance.new("ScrollingFrame")
	tabBar.Name = "TabRail"
	tabBar.BackgroundColor3 = pal.Card
	tabBar.BackgroundTransparency = 0.05
	tabBar.BorderSizePixel = 0
	tabBar.Position = UDim2.new(0, 0, 0, 0)
	tabBar.Size = UDim2.new(0, railWidth, 1, 0)
	tabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabBar.ScrollBarThickness = 3
	tabBar.ScrollBarImageColor3 = pal.Border
	tabBar.ScrollBarImageTransparency = 0.5
	tabBar.ScrollingDirection = Enum.ScrollingDirection.Y
	tabBar.ElasticBehavior = Enum.ElasticBehavior.Never
	tabBar.ClipsDescendants = true
	tabBar.Parent = content
	UIHelpers.corner(tabBar, 12)

	-- Subtle gradient on tab rail
	local tabRailGradient = Instance.new("UIGradient")
	tabRailGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, pal.Primary),
		ColorSequenceKeypoint.new(0.5, pal.Accent),
		ColorSequenceKeypoint.new(1, pal.Secondary),
	}
	tabRailGradient.Rotation = 90
	tabRailGradient.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.9),
		NumberSequenceKeypoint.new(1, 0.9),
	}
	tabRailGradient.Parent = tabBar

	-- Border stroke
	local tabRailStroke = Instance.new("UIStroke")
	tabRailStroke.Color = pal.BorderGlow
	tabRailStroke.Thickness = 1
	tabRailStroke.Transparency = 0.6
	tabRailStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	tabRailStroke.Parent = tabBar

	local tabPadding = Instance.new("UIPadding")
	tabPadding.PaddingTop = UDim.new(0, 12)
	tabPadding.PaddingBottom = UDim.new(0, 12)
	tabPadding.PaddingLeft = UDim.new(0, 12)
	tabPadding.PaddingRight = UDim.new(0, 8)
	tabPadding.Parent = tabBar

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.Padding = UDim.new(0, 8)
	tabLayout.FillDirection = Enum.FillDirection.Vertical
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	tabLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Parent = tabBar

	-- Body container
	local body = Instance.new("Frame")
	body.BackgroundColor3 = pal.Elevated
	body.BackgroundTransparency = 0.1
	body.BorderSizePixel = 0
	body.Position = UDim2.new(0, railWidth + 16, 0, 16)
	body.Size = UDim2.new(1, -(railWidth + 28), 1, -32)
	body.Parent = content
	UIHelpers.corner(body, 16)
	UIHelpers.stroke(body, pal.Border, 1)

	local bodyPadding = Instance.new("UIPadding")
	bodyPadding.PaddingTop = UDim.new(0, 20)
	bodyPadding.PaddingBottom = UDim.new(0, 20)
	bodyPadding.PaddingLeft = UDim.new(0, 24)
	bodyPadding.PaddingRight = UDim.new(0, 24)
	bodyPadding.Parent = body

	local function describeFrame(label, inst)
		if not Debug:IsEnabled() or not inst then
			return
		end

		local ok, info = pcall(function()
			local absPos = inst.AbsolutePosition
			local absSize = inst.AbsoluteSize
			local bg = inst.BackgroundColor3 or Color3.new(0, 0, 0)
			return string.format(
				"%s visible=%s z=%d clips=%s pos=(%d,%d) size=(%d,%d) alpha=%.2f rgb=(%d,%d,%d)",
				label,
				tostring(inst.Visible),
				inst.ZIndex or 0,
				tostring(inst.ClipsDescendants),
				math.floor(absPos.X),
				math.floor(absPos.Y),
				math.floor(absSize.X),
				math.floor(absSize.Y),
				inst.BackgroundTransparency or 0,
				math.floor(bg.R * 255 + 0.5),
				math.floor(bg.G * 255 + 0.5),
				math.floor(bg.B * 255 + 0.5)
			)
		end)

		if ok and info then
			Debug.printf("[LAYOUT] %s", info)
		end
	end

	local function snapshotLayout(stage)
		if not Debug:IsEnabled() then
			return
		end

		Debug.printf("[LAYOUT] --- %s ---", stage)
		describeFrame("root", root)
		describeFrame("header", header)
		describeFrame("content", content)
		describeFrame("tabRail", tabBar)
		describeFrame("body", body)
		describeFrame("splash", splash)
		describeFrame("overlay", overlayLayer)
		if overlayLayer then
			for _, child in ipairs(overlayLayer:GetChildren()) do
				describeFrame("overlay." .. child.Name, child)
			end
		end
	end

	-- Splash screen
	local splash
	local splashHidden = false
	splash = Instance.new("Frame")
	splash.BackgroundColor3 = pal.Elevated
	splash.BorderSizePixel = 0
	splash.Position = body.Position
	splash.Size = body.Size
	splash.ZIndex = 999
	splash.Parent = content
	UIHelpers.corner(splash, 16)

	local splashTitle = Instance.new("TextLabel")
	splashTitle.BackgroundTransparency = 1
	splashTitle.Position = UDim2.new(0, 24, 0, 24)
	splashTitle.Size = UDim2.new(1, -48, 0, 32)
	splashTitle.Font = Enum.Font.GothamBold
	splashTitle.TextSize = 22
	splashTitle.TextColor3 = pal.Text
	splashTitle.TextXAlignment = Enum.TextXAlignment.Left
	splashTitle.Text = cfg.LoadingTitle or name
	splashTitle.Parent = splash

	local splashSub = Instance.new("TextLabel")
	splashSub.BackgroundTransparency = 1
	splashSub.Position = UDim2.new(0, 24, 0, 60)
	splashSub.Size = UDim2.new(1, -48, 0, 22)
	splashSub.Font = Enum.Font.Gotham
	splashSub.TextSize = 14
	splashSub.TextColor3 = pal.TextSub
	splashSub.TextXAlignment = Enum.TextXAlignment.Left
	splashSub.Text = cfg.LoadingSubtitle or "Loading..."
	splashSub.Parent = splash

	-- Loading bar
	local loadingBar = Instance.new("Frame")
	loadingBar.BackgroundColor3 = pal.Border
	loadingBar.BorderSizePixel = 0
	loadingBar.Position = UDim2.new(0, 24, 0, 100)
	loadingBar.Size = UDim2.new(1, -48, 0, 4)
	loadingBar.Parent = splash
	UIHelpers.corner(loadingBar, 2)

	local loadingFill = Instance.new("Frame")
	loadingFill.BackgroundColor3 = pal.Accent
	loadingFill.BorderSizePixel = 0
	loadingFill.Size = UDim2.new(0, 0, 1, 0)
	loadingFill.Parent = loadingBar
	UIHelpers.corner(loadingFill, 2)
	UIHelpers.gradient(loadingFill, 90, {pal.Accent, pal.AccentHover})

	Animator:Tween(loadingFill, {Size = UDim2.new(1, 0, 1, 0)}, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))

	task.defer(function()
		snapshotLayout("initial-build")
	end)

	local hideSplashAndShowRoot = function()
		if splash and splash.Parent then
			if not splashHidden then
				pcall(function()
					Animator:Tween(splash, {BackgroundTransparency = 1}, Animator.Spring.Fast)
					task.wait(0.2)
				end)
			end
			-- Destroy splash completely to prevent blocking
			if splash then
				pcall(function() splash:Destroy() end)
				splash = nil
			end
			splashHidden = true
		end

		root.Visible = true
		task.defer(function()
			snapshotLayout("post-show")
		end)
		print("[RvrseUI] ✨ UI visible - all settings applied")
	end

	-- Mobile chip
	local chip = Instance.new("TextButton")
	chip.Text = cfg.ShowText or "RvrseUI"
	chip.Font = Enum.Font.GothamMedium
	chip.TextSize = 13
	chip.TextColor3 = pal.Text
	chip.BackgroundColor3 = pal.Card
	chip.Size = UDim2.new(0, 120, 0, 36)
	chip.AnchorPoint = Vector2.new(1, 0)
	chip.Position = UDim2.new(1, -16, 0, 16)
	chip.Visible = false
	chip.Parent = host
	UIHelpers.corner(chip, 18)
	UIHelpers.stroke(chip, pal.Border, 1)

	local function setHidden(hidden)
		if hidden and Overlay then
			Overlay:HideBlocker(true)
		end
		root.Visible = not hidden
		chip.Visible = hidden
	end

	chip.MouseButton1Click:Connect(function() setHidden(false) end)

	-- Gaming Controller Minimize Chip
	local controllerChip = Instance.new("TextButton")
	controllerChip.Name = Obfuscation.getObfuscatedName("chip")
	controllerChip.Text = "🎮"
	controllerChip.Font = Enum.Font.GothamBold
	controllerChip.TextSize = 20
	controllerChip.TextColor3 = pal.Accent
	controllerChip.BackgroundColor3 = pal.Card
	controllerChip.BackgroundTransparency = 0.1
	controllerChip.Size = UDim2.new(0, 50, 0, 50)
	controllerChip.AnchorPoint = Vector2.new(0.5, 0.5)
	controllerChip.Position = UDim2.new(0.5, 0, 0.5, 0)
	controllerChip.Visible = false
	controllerChip.ZIndex = 200
	controllerChip.Parent = host
	UIHelpers.corner(controllerChip, 25)
	UIHelpers.stroke(controllerChip, pal.Accent, 2)
	UIHelpers.addGlow(controllerChip, pal.Accent, 4)

	-- Add rotating shine effect
	local chipShine = Instance.new("Frame")
	chipShine.Name = "Shine"
	chipShine.BackgroundTransparency = 1
	chipShine.Size = UDim2.new(1, 0, 1, 0)
	chipShine.Position = UDim2.new(0, 0, 0, 0)
	chipShine.ZIndex = 210
	chipShine.Parent = controllerChip
	UIHelpers.corner(chipShine, 25)

	local shineGradient = Instance.new("UIGradient")
	shineGradient.Name = "ShineGradient"
	shineGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.3, 0.8),
		NumberSequenceKeypoint.new(0.5, 0.6),
		NumberSequenceKeypoint.new(0.7, 0.8),
		NumberSequenceKeypoint.new(1, 1)
	})
	shineGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.5, pal.Accent),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
	})
	shineGradient.Rotation = 0
	shineGradient.Parent = chipShine

	local shineRotation
	shineRotation = RS.Heartbeat:Connect(function()
		if controllerChip.Visible and shineGradient then
			shineGradient.Rotation = (shineGradient.Rotation + 2) % 360
		end
	end)

	-- Enhanced particle flow system for minimize/restore transitions
	local function createParticleFlow(startPos, endPos, count, duration, flowType)
		for i = 1, count do
			local particle = Instance.new("Frame")
			particle.Size = UDim2.new(0, math.random(2, 12), 0, math.random(2, 12))
			particle.BackgroundColor3 = pal.Accent
			particle.BackgroundTransparency = math.random(40, 70) / 100
			particle.BorderSizePixel = 0
			particle.Position = UDim2.new(0, startPos.X, 0, startPos.Y)
			particle.ZIndex = 999
			particle.Parent = host
			UIHelpers.corner(particle, math.random(2, 6))

			local delay = (i / count) * (duration * 0.7)
			task.delay(delay, function()
				if not particle or not particle.Parent then return end

				if flowType == "spread" then
					local angle = (i / count) * math.pi * 2
					local spreadRadius = math.random(300, 450)
					local spreadX = endPos.X + math.cos(angle) * spreadRadius
					local spreadY = endPos.Y + math.sin(angle) * spreadRadius
					local midX = (startPos.X + spreadX) / 2 + math.random(-80, 80)
					local midY = (startPos.Y + spreadY) / 2 + math.random(-80, 80)

					Animator:Tween(particle, {
						Position = UDim2.new(0, midX, 0, midY),
						BackgroundTransparency = 0.2,
						Size = UDim2.new(0, math.random(8, 14), 0, math.random(8, 14))
					}, TweenInfo.new(duration * 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out))

					task.wait(duration * 0.5)
					if not particle or not particle.Parent then return end

					Animator:Tween(particle, {
						Position = UDim2.new(0, spreadX, 0, spreadY),
						BackgroundTransparency = 0.3,
						Size = UDim2.new(0, math.random(6, 10), 0, math.random(6, 10))
					}, TweenInfo.new(duration * 0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut))

					task.wait(duration * 0.45)
					if not particle or not particle.Parent then return end

					local orbitX = spreadX + math.random(-30, 30)
					local orbitY = spreadY + math.random(-30, 30)
					Animator:Tween(particle, {
						Position = UDim2.new(0, orbitX, 0, orbitY),
						BackgroundTransparency = 0.6,
						Size = UDim2.new(0, math.random(4, 8), 0, math.random(4, 8))
					}, TweenInfo.new(duration * 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut))

					task.wait(duration * 0.3)
					if not particle or not particle.Parent then return end

					Animator:Tween(particle, {
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 2, 0, 2)
					}, TweenInfo.new(duration * 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))

					task.wait(duration * 0.25)
					if particle and particle.Parent then
						particle:Destroy()
					end
				else
					local angle = (i / count) * math.pi * 2
					local gatherRadius = math.random(300, 450)
					local gatherStartX = startPos.X + math.cos(angle) * gatherRadius
					local gatherStartY = startPos.Y + math.sin(angle) * gatherRadius

					particle.Position = UDim2.new(0, gatherStartX, 0, gatherStartY)
					particle.BackgroundTransparency = 0.6
					particle.Size = UDim2.new(0, math.random(4, 10), 0, math.random(4, 10))

					local midX = (gatherStartX + endPos.X) / 2 + math.random(-80, 80)
					local midY = (gatherStartY + endPos.Y) / 2 + math.random(-80, 80)

					Animator:Tween(particle, {
						Position = UDim2.new(0, midX, 0, midY),
						BackgroundTransparency = 0.2,
						Size = UDim2.new(0, math.random(8, 12), 0, math.random(8, 12))
					}, TweenInfo.new(duration * 0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.In))

					task.wait(duration * 0.45)
					if not particle or not particle.Parent then return end

					Animator:Tween(particle, {
						Position = UDim2.new(0, endPos.X, 0, endPos.Y),
						BackgroundTransparency = 0.1,
						Size = UDim2.new(0, math.random(5, 8), 0, math.random(5, 8))
					}, TweenInfo.new(duration * 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut))

					task.wait(duration * 0.5)
					if not particle or not particle.Parent then return end

					Animator:Tween(particle, {
						Position = UDim2.new(0, endPos.X, 0, endPos.Y),
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 1, 0, 1)
					}, TweenInfo.new(duration * 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In))

					task.wait(duration * 0.25)
					if particle and particle.Parent then
						particle:Destroy()
					end
				end
			end)
		end
	end

	local isMinimized = false

	local function minimizeWindow()
		if isMinimized then return end
		isMinimized = true
		if Overlay then
			Overlay:HideBlocker(true)
		end
		Animator:Ripple(minimizeBtn, 16, 12)
		snapshotLayout("pre-minimize")

		local screenSize = workspace.CurrentCamera.ViewportSize
		local chipTargetPos = UDim2.new(0.5, 0, 0.5, 0)
		if RvrseUI._controllerChipPosition then
			local saved = RvrseUI._controllerChipPosition
			chipTargetPos = UDim2.new(saved.XScale, saved.XOffset, saved.YScale, saved.YOffset)
		end

		local chipTargetX = chipTargetPos.X.Scale * screenSize.X + chipTargetPos.X.Offset
		local chipTargetY = chipTargetPos.Y.Scale * screenSize.Y + chipTargetPos.Y.Offset

		local rootPos = root.AbsolutePosition
		local rootSize = root.AbsoluteSize
		local windowCenterX = rootPos.X + (rootSize.X / 2)
		local windowCenterY = rootPos.Y + (rootSize.Y / 2)

		createParticleFlow(
			{X = windowCenterX, Y = windowCenterY},
			{X = chipTargetX, Y = chipTargetY},
			120,
			1.2,
			"gather"
		)

		Animator:Tween(root, {
			Size = UDim2.new(0, 0, 0, 0),
			Position = chipTargetPos,
			BackgroundTransparency = 1,
			Rotation = 180
		}, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In))

		task.wait(0.6)
		if isMinimized then
			root.Visible = false
			controllerChip.Visible = true
			controllerChip.Size = UDim2.new(0, 0, 0, 0)

			Animator:Tween(controllerChip, {
				Size = UDim2.new(0, 50, 0, 50)
			}, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
		end
	end

	local function restoreWindow()
		if not isMinimized then return end
		isMinimized = false
		Animator:Ripple(controllerChip, 25, 25)

		local screenSize = workspace.CurrentCamera.ViewportSize
		local chipPos = controllerChip.AbsolutePosition
		local chipCenterX = chipPos.X + 25
		local chipCenterY = chipPos.Y + 25

		local targetSize = isMobile and UDim2.new(0, 380, 0, 520) or UDim2.new(0, baseWidth, 0, baseHeight)
		local targetPos = UDim2.new(0.5, 0, 0.5, 0)
		if RvrseUI._lastWindowPosition then
			local savedPos = RvrseUI._lastWindowPosition
			targetPos = UDim2.new(savedPos.XScale, savedPos.XOffset, savedPos.YScale, savedPos.YOffset)
		end

		local targetWidth = isMobile and 380 or baseWidth
		local targetHeight = isMobile and 520 or baseHeight
		local windowCenterX = targetPos.X.Scale * screenSize.X + targetPos.X.Offset + (targetWidth / 2)
		local windowCenterY = targetPos.Y.Scale * screenSize.Y + targetPos.Y.Offset + (targetHeight / 2)

		createParticleFlow(
			{X = chipCenterX, Y = chipCenterY},
			{X = windowCenterX, Y = windowCenterY},
			120,
			1.2,
			"spread"
		)

		Animator:Tween(controllerChip, {
			Size = UDim2.new(0, 0, 0, 0)
		}, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In))

		task.wait(0.3)
		controllerChip.Visible = false

		root.Visible = true
		root.Size = UDim2.new(0, 0, 0, 0)
		root.Position = controllerChip.Position
		root.Rotation = -180
		root.BackgroundTransparency = 1

		Animator:Tween(root, {
			Size = targetSize,
			Position = targetPos,
			BackgroundTransparency = 1,  -- KEEP TRANSPARENT!
			Rotation = 0
		}, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out))

		task.defer(function()
			snapshotLayout("post-restore")
		end)
	end

	minimizeBtn.MouseButton1Click:Connect(minimizeWindow)

	-- ═══════════════════════════════════════════════════════════════
	-- ADVANCED CURSOR-LOCKED DRAG SYSTEM - Controller Chip
	-- ═══════════════════════════════════════════════════════════════
	-- Ensures the cursor stays perfectly glued to the exact grab point
	-- on the chip. Uses AnchorPoint (0.5, 0.5) so chip rotates around
	-- center, and maintains sub-pixel precision during drag.
	-- ═══════════════════════════════════════════════════════════════

	local chipDragging = false
	local chipWasDragged = false
	local chipDragThreshold = false
	local chipCenterOffset = nil  -- Offset from pointer to chip center at grab time
	local chipActiveDragInput = nil
	local chipInitialPointer = nil
	local chipLastPointer = nil

	-- Restore window on click (only if not dragged)
	controllerChip.MouseButton1Click:Connect(function()
		if not chipWasDragged then
			restoreWindow()
		end
		chipWasDragged = false
	end)

	-- Hover effects
	controllerChip.MouseEnter:Connect(function()
		Animator:Tween(controllerChip, {
			Size = UDim2.new(0, 60, 0, 60)
		}, Animator.Spring.Fast)
	end)

	controllerChip.MouseLeave:Connect(function()
		Animator:Tween(controllerChip, {
			Size = UDim2.new(0, 50, 0, 50)
		}, Animator.Spring.Fast)
	end)

	-- Start chip drag
	controllerChip.InputBegan:Connect(function(io)
		if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
			chipDragging = true
			chipWasDragged = false
			chipDragThreshold = false
			chipActiveDragInput = io
			chipCenterOffset = nil  -- Will be calculated on first movement
			chipInitialPointer = getPointerPosition(io)
			chipLastPointer = chipInitialPointer

			Debug.printf("[CHIP DRAG] Started - input type: %s", tostring(io.UserInputType))
		end
	end)

	-- End chip drag and save position
	controllerChip.InputEnded:Connect(function(io)
		if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
			if chipDragging and io == chipActiveDragInput then
				chipDragging = false
				chipActiveDragInput = nil
				chipCenterOffset = nil
				chipInitialPointer = nil
				chipLastPointer = nil

				-- Save final position
				RvrseUI._controllerChipPosition = {
					XScale = controllerChip.Position.X.Scale,
					XOffset = controllerChip.Position.X.Offset,
					YScale = controllerChip.Position.Y.Scale,
					YOffset = controllerChip.Position.Y.Offset
				}

				Debug.printf("[CHIP DRAG] Finished - saved position: X=%d, Y=%d",
					controllerChip.AbsolutePosition.X, controllerChip.AbsolutePosition.Y)
			end
		end
	end)

	-- Main chip drag update loop - maintains cursor lock
	UIS.InputChanged:Connect(function(io)
		if not chipDragging or not controllerChip.Visible then
			return
		end

		-- Check if this is our active drag input
		local isMouseDrag = io.UserInputType == Enum.UserInputType.MouseMovement
			and chipActiveDragInput
			and chipActiveDragInput.UserInputType == Enum.UserInputType.MouseButton1
		local isTouchDrag = io == chipActiveDragInput

		if not isMouseDrag and not isTouchDrag then
			return
		end

		-- Get current pointer position in UI space
		local pointer = getPointerPosition(io)
		local previousPointer = chipLastPointer or pointer
		chipLastPointer = pointer
		local inset = getGuiInset()

		local chipTopLeft = controllerChip.AbsolutePosition
		local chipSize = controllerChip.AbsoluteSize
		local chipAnchor = controllerChip.AnchorPoint
		local chipCenter = Vector2.new(
			chipTopLeft.X + (chipSize.X * chipAnchor.X),
			chipTopLeft.Y + (chipSize.Y * chipAnchor.Y)
		)

		if not chipCenterOffset then
			chipCenterOffset = pointer - chipCenter
			Debug.printf("[CHIP DRAG] Cached grab offset: X=%.2f, Y=%.2f", chipCenterOffset.X, chipCenterOffset.Y)
		end

		if not chipInitialPointer then
			chipInitialPointer = pointer
		end

		-- Check if we've moved enough to activate dragging (prevents accidental drags)
		if not chipDragThreshold then
			local dragDistance = (pointer - chipInitialPointer).Magnitude
			if dragDistance > 5 then
				chipDragThreshold = true
				chipWasDragged = true
				Debug.printf("[CHIP DRAG] Threshold exceeded - drag activated")
			else
				return  -- Don't move yet
			end
		end

		local chipWidth = chipSize.X
		local chipHeight = chipSize.Y
		local halfWidth = chipWidth / 2
		local halfHeight = chipHeight / 2

		-- Calculate target center: pointer - cached offset
		local targetCenterX = pointer.X - chipCenterOffset.X
		local targetCenterY = pointer.Y - chipCenterOffset.Y

		-- Get screen bounds and clamp center to keep chip fully on screen
		local currentCamera = workspace.CurrentCamera
		local screenSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1920, 1080)
		local effectiveWidth = hostIgnoresInset and screenSize.X or (screenSize.X + inset.X)
		local effectiveHeight = hostIgnoresInset and screenSize.Y or (screenSize.Y + inset.Y)
		local minCenterX = (hostIgnoresInset and 0 or inset.X) + halfWidth
		local maxCenterX = effectiveWidth - halfWidth
		local minCenterY = (hostIgnoresInset and 0 or inset.Y) + halfHeight
		local maxCenterY = effectiveHeight - halfHeight

		targetCenterX = math.clamp(targetCenterX, minCenterX, maxCenterX)
		targetCenterY = math.clamp(targetCenterY, minCenterY, maxCenterY)

		local finalCenterX = targetCenterX
		local finalCenterY = targetCenterY
		if not hostIgnoresInset then
			finalCenterX -= inset.X
			finalCenterY -= inset.Y
		end

		controllerChip.Position = UDim2.fromOffset(
			math.floor(finalCenterX + 0.5),
			math.floor(finalCenterY + 0.5)
		)

		if Debug:IsEnabled() then
			local gluePoint = Vector2.new(targetCenterX + chipCenterOffset.X, targetCenterY + chipCenterOffset.Y)
			local pointerDelta = pointer - previousPointer
			local distance = pointerDelta.Magnitude
			Debug.printf("[DRAG][Chip] pointer=(%.1f, %.1f) prev=(%.1f, %.1f) glue=(%.1f, %.1f) delta=(%.2f, %.2f) dist=%.2f",
				pointer.X, pointer.Y,
				previousPointer.X, previousPointer.Y,
				gluePoint.X, gluePoint.Y,
				pointerDelta.X, pointerDelta.Y,
				distance
			)
		end
	end)

	if RvrseUI._controllerChipPosition then
		local savedPos = RvrseUI._controllerChipPosition
		controllerChip.Position = UDim2.new(
			savedPos.XScale,
			savedPos.XOffset,
			savedPos.YScale,
			savedPos.YOffset
		)
	end

	-- Save and restore window position
	local windowData = {
		isMinimized = function() return isMinimized end,
		restoreFunction = restoreWindow,
		minimizeFunction = minimizeWindow,
		destroyFunction = nil
	}
	RvrseUI.UI:RegisterToggleTarget(root, windowData)

	-- Tab management
	local activePage
	local tabs = {}

	local WindowAPI = {}
	function WindowAPI:SetTitle(t) title.Text = t or name end
	function WindowAPI:Hide() setHidden(true) end

	function WindowAPI:SetIcon(newIcon)
		if not newIcon then return end

		for _, child in ipairs(iconHolder:GetChildren()) do
			if child:IsA("ImageLabel") or child:IsA("TextLabel") then
				child:Destroy()
			end
		end

		local iconAsset, iconType = Icons.resolveIcon(newIcon)

		if iconType == "image" then
			local img = Instance.new("ImageLabel")
			img.BackgroundTransparency = 1
			img.Image = iconAsset
			img.Size = UDim2.new(1, 0, 1, 0)
			img.ImageColor3 = pal.Accent
			img.Parent = iconHolder
			UIHelpers.corner(img, 8)
		elseif iconType == "text" then
			local iconTxt = Instance.new("TextLabel")
			iconTxt.BackgroundTransparency = 1
			iconTxt.Font = Enum.Font.GothamBold
			iconTxt.TextSize = 20
			iconTxt.TextColor3 = pal.Accent
			iconTxt.Text = iconAsset
			iconTxt.Size = UDim2.new(1, 0, 1, 0)
			iconTxt.Parent = iconHolder
		end
	end

	function WindowAPI:Destroy()
		if Overlay then
			Overlay:HideBlocker(true)
		end
		Animator:Tween(root, {BackgroundTransparency = 1}, Animator.Spring.Fast)
		Animator:Tween(chip, {BackgroundTransparency = 1}, Animator.Spring.Fast)
		task.wait(0.3)

		if host and host.Parent then
			host:Destroy()
		end

		if RvrseUI.UI._toggleTargets then
			table.clear(RvrseUI.UI._toggleTargets)
		end
		if RvrseUI._lockListeners then
			table.clear(RvrseUI._lockListeners)
		end
		if RvrseUI._themeListeners then
			table.clear(RvrseUI._themeListeners)
		end

		print("[RvrseUI] Interface destroyed - All traces removed")
	end

	windowData.destroyFunction = function()
		WindowAPI:Destroy()
	end

	local firstShowCompleted = false

	function WindowAPI:Show()
		setHidden(false)

		if not firstShowCompleted then
			firstShowCompleted = true
			hideSplashAndShowRoot()

			task.defer(function()
				if RvrseUI.ConfigurationSaving and RvrseUI.ConfigurationFileName then
					print("[RvrseUI] 📂 Loading configuration (after elements created)...")
					local success, message = RvrseUI:LoadConfiguration()
					if success then
						print("[RvrseUI] ✅ Configuration loaded successfully")
					else
						print("[RvrseUI] ⚠️ Config load warning:", message)
					end
					task.wait(0.1)
				end
			end)
		else
			hideSplashAndShowRoot()
		end
	end

	-- CreateTab uses TabBuilder module
	function WindowAPI:CreateTab(t)
		return TabBuilder.CreateTab(t, {
			Theme = Theme,
			UIHelpers = UIHelpers,
			Animator = Animator,
			Icons = Icons,
			SectionBuilder = SectionBuilder,
			tabBar = tabBar,
			body = body,
			tabs = tabs,
			activePage = activePage,
			RvrseUI = RvrseUI,
			Elements = Elements,
			UIS = UIS,
			OverlayLayer = overlayLayer,
			Overlay = Overlay
		})
	end

	if RvrseUI.ConfigurationSaving and cfg.ConfigurationManager ~= false then
		task.defer(function()
			local ok, err = pcall(function()
				local managerOptions = typeof(cfg.ConfigurationManager) == "table" and cfg.ConfigurationManager or {}
				local tabTitle = managerOptions.TabName or "Profiles"
				local tabIcon = managerOptions.Icon or "folder"
				local sectionTitle = managerOptions.SectionTitle or "Configuration Profiles"
				local profilePlaceholder = managerOptions.NewProfilePlaceholder or "my_profile"
				local dropdownPlaceholder = managerOptions.DropdownPlaceholder or "Select profile"

				local function safeNotify(title, message, kind)
					local notifyPayload = {
						Title = title or "Profiles",
						Message = message or "",
						Duration = 3,
						Type = kind or "info"
					}
					local okNotify = pcall(function()
						return RvrseUI:Notify(notifyPayload)
					end)
					if not okNotify then
						print("[RvrseUI]", notifyPayload.Title .. ":", notifyPayload.Message)
					end
				end

				local function trim(str)
					return (str:gsub("^%s+", ""):gsub("%s+$", ""))
				end

				local function containsValue(list, value)
					for _, item in ipairs(list) do
						if item == value then
							return true
						end
					end
					return false
				end

				local profilesTab = WindowAPI:CreateTab({
					Title = tabTitle,
					Icon = tabIcon
				})
				local profileSection = profilesTab:CreateSection(sectionTitle)

				local folderLabel = profileSection:CreateLabel({
					Text = "Folder: " .. (RvrseUI.ConfigurationFolderName or "(workspace)")
				})

				local activeLabel = profileSection:CreateLabel({
					Text = "Active Profile: " .. (RvrseUI.ConfigurationFileName or "none")
				})

				local selectedProfile = RvrseUI.ConfigurationFileName
				local lastProfileList = {}
				local profilesDropdown

				local function updateLabels(profileName)
					folderLabel:Set("Folder: " .. (RvrseUI.ConfigurationFolderName or "(workspace)"))
					activeLabel:Set("Active Profile: " .. (profileName or "none"))
				end

				local function gatherProfiles()
					local list, warning = RvrseUI:ListProfiles()
					list = list or {}
					table.sort(list)
					return list, warning
				end

				local function refreshProfiles(target, opts)
					opts = opts or {}
					local list, warning = gatherProfiles()
					lastProfileList = list
					print(string.format("[Profiles] refresh count=%d", #list))
					profilesDropdown:Refresh(list)
					if warning and not opts.suppressWarning and managerOptions.SuppressWarnings ~= true then
						safeNotify("Profiles", tostring(warning), "warning")
					end

					local resolveTarget = target
					if resolveTarget and not containsValue(list, resolveTarget) then
						resolveTarget = nil
					end
					if not resolveTarget and selectedProfile and containsValue(list, selectedProfile) then
						resolveTarget = selectedProfile
					end
					if not resolveTarget and list[1] then
						resolveTarget = list[1]
					end

					selectedProfile = resolveTarget
					if resolveTarget then
						profilesDropdown:Set(resolveTarget, true)
						updateLabels(resolveTarget)
					else
						updateLabels(nil)
					end

					return list
				end

				local function applyProfile(profileName, opts)
					opts = opts or {}
					if not profileName or profileName == "" then
						safeNotify("Profiles", "No profile selected", "warning")
						return false
					end

					local base = profileName:gsub("%.json$", "")
					local setOk, setMsg = RvrseUI:SetConfigProfile(base)
					if not setOk then
						safeNotify("Profiles", tostring(setMsg), "error")
						return false
					end

					local loadOk, loadMsg = RvrseUI:LoadConfigByName(base)
					if loadOk then
						selectedProfile = profileName
						refreshProfiles(profileName, {suppressWarning = true})
						if not opts.muteNotify then
							safeNotify("Profiles", "Loaded " .. profileName, "success")
						end
						return true
					else
						safeNotify("Profiles", "Load failed: " .. tostring(loadMsg), "error")
						return false
					end
				end

				profilesDropdown = profileSection:CreateDropdown({
					Text = "Profiles",
					Values = {},
					PlaceholderText = dropdownPlaceholder,
					Overlay = false,
					UseLegacyDropdown = true,
					OnOpen = function()
						refreshProfiles(selectedProfile, {suppressWarning = true})
					end,
					OnChanged = function(value)
						if not value or value == "" then return end
						if not containsValue(lastProfileList, value) then
							return
						end
						if value == selectedProfile then
							updateLabels(value)
							return
						end
						applyProfile(value)
					end
				})

				local newProfileName = ""
				local nameInput = profileSection:CreateTextBox({
					Text = "New Profile",
					Placeholder = profilePlaceholder,
					OnChanged = function(value)
						newProfileName = trim(value or "")
					end
				})

				profileSection:CreateButton({
					Text = "🔄 Refresh Profiles",
					Callback = function()
						refreshProfiles(selectedProfile)
						safeNotify("Profiles", "Profile list refreshed", "info")
					end
				})

				profileSection:CreateButton({
					Text = "💾 Save Current",
					Callback = function()
						local okSave, saveMsg = RvrseUI:SaveConfiguration()
						if okSave then
							local active = RvrseUI.ConfigurationFileName or selectedProfile
							safeNotify("Profiles", "Saved to " .. tostring(active or "config"), "success")
							refreshProfiles(active, {suppressWarning = true})
						else
							safeNotify("Profiles", "Save failed: " .. tostring(saveMsg), "error")
						end
					end
				})

				profileSection:CreateButton({
					Text = "📁 Save As",
					Callback = function()
						local trimmed = trim(newProfileName)
						if trimmed == "" then
							safeNotify("Profiles", "Enter a profile name first", "warning")
							return
						end
						local okSaveAs, saveAsMsg = RvrseUI:SaveConfigAs(trimmed)
						if okSaveAs then
							local fileName = trimmed:gsub("%.json$", "") .. ".json"
							safeNotify("Profiles", "Saved " .. fileName, "success")
							refreshProfiles(fileName, {suppressWarning = true})
							if managerOptions.ClearNameAfterSave ~= false then
								newProfileName = ""
								nameInput:Set("")
							end
						else
							safeNotify("Profiles", "Save As failed: " .. tostring(saveAsMsg), "error")
						end
					end
				})

				profileSection:CreateButton({
					Text = "↻ Load Selected",
					Callback = function()
						if not selectedProfile then
							safeNotify("Profiles", "No profile selected", "warning")
							return
						end
						applyProfile(selectedProfile, {muteNotify = false})
					end
				})

				profileSection:CreateButton({
					Text = "🗑️ Delete Profile",
					Callback = function()
						if not selectedProfile then
							safeNotify("Profiles", "No profile selected", "warning")
							return
						end
						local base = selectedProfile:gsub("%.json$", "")
						local okDelete, deleteMsg = RvrseUI:DeleteProfile(base)
						if okDelete then
							safeNotify("Profiles", "Deleted " .. selectedProfile, "warning")
							selectedProfile = nil
							refreshProfiles(nil, {suppressWarning = true})
						else
							safeNotify("Profiles", "Delete failed: " .. tostring(deleteMsg), "error")
						end
					end
				})

				profileSection:CreateToggle({
					Text = "Auto Save",
					State = RvrseUI:IsAutoSaveEnabled(),
					OnChanged = function(state)
						RvrseUI:SetAutoSaveEnabled(state)
						safeNotify("Profiles", state and "Auto save enabled" or "Auto save disabled", state and "info" or "warning")
					end
				})

				refreshProfiles(selectedProfile, {suppressWarning = true})
			end)
			if not ok then
				warn("[RvrseUI] Config manager initialization failed:", err)
			end
		end)
	end

	-- Welcome notifications
	if NotificationsService and NotificationsService.Notify then
		if not cfg.DisableBuildWarnings then
			NotificationsService:Notify({
				Title = "RvrseUI v2.0",
				Message = "Modern UI loaded successfully",
				Duration = 2,
				Type = "success"
			})
		end
		if not cfg.DisableRvrseUIPrompts then
			NotificationsService:Notify({
				Title = "Tip",
				Message = "Press " .. toggleKey.Name .. " to toggle UI",
				Duration = 3,
				Type = "info"
			})
		end
	end

	-- Pill sync and theme toggle (lines 3816-3916)
	local function syncPillFromTheme()
		local t = Theme.Current
		local currentPal = Theme:Get()
		themeToggle.Text = t == "Dark" and "🌙" or "🌞"
		themeToggle.TextColor3 = currentPal.Accent
		themeToggle.BackgroundColor3 = currentPal.Elevated
		themeTooltip.Text = "  Theme: " .. t .. "  "
		UIHelpers.stroke(themeToggle, currentPal.Border, 1)
	end

	themeToggle.MouseButton1Click:Connect(function()
		local newTheme = Theme.Current == "Dark" and "Light" or "Dark"
		Theme:Switch(newTheme)

		local newPal = Theme:Get()

		syncPillFromTheme()

		root.BackgroundColor3 = newPal.Card
		UIHelpers.stroke(root, newPal.Border, 1.5)

		header.BackgroundColor3 = newPal.Elevated
		UIHelpers.stroke(header, newPal.Border, 1)
		headerDivider.BackgroundColor3 = newPal.Divider
		title.TextColor3 = newPal.Text

		minimizeBtn.BackgroundColor3 = newPal.Elevated
		minimizeBtn.TextColor3 = newPal.Accent
		UIHelpers.stroke(minimizeBtn, newPal.Border, 1)

		bellToggle.BackgroundColor3 = newPal.Elevated
		bellToggle.TextColor3 = newPal.Accent
		UIHelpers.stroke(bellToggle, newPal.Border, 1)

		closeBtn.BackgroundColor3 = newPal.Elevated
		closeBtn.TextColor3 = newPal.Error
		UIHelpers.stroke(closeBtn, newPal.Border, 1)

		controllerChip.BackgroundColor3 = newPal.Card
		controllerChip.TextColor3 = newPal.Accent
		UIHelpers.stroke(controllerChip, newPal.Accent, 2)
		if controllerChip:FindFirstChild("Glow") then
			controllerChip.Glow.Color = newPal.Accent
		end

		tabBar.BackgroundColor3 = newPal.Card
		UIHelpers.stroke(tabBar, newPal.Border, 1)
		tabBar.ScrollBarImageColor3 = newPal.Border

		body.BackgroundColor3 = newPal.Elevated
		UIHelpers.stroke(body, newPal.Border, 1)

		-- Update splash screen elements only if they still exist (destroyed after init)
		if splash and splash.Parent then
			splash.BackgroundColor3 = newPal.Elevated
		end
		if loadingBar and loadingBar.Parent then
			loadingBar.BackgroundColor3 = newPal.Border
		end
		if loadingFill and loadingFill.Parent then
			loadingFill.BackgroundColor3 = newPal.Accent
			local loadingGradient = loadingFill:FindFirstChildOfClass("UIGradient")
			if loadingGradient then
				loadingGradient.Color = ColorSequence.new(newPal.Accent, newPal.AccentHover)
			end
		end

		for _, tabData in ipairs(tabs) do
			local isActive = tabData.btn:GetAttribute("Active") == true
			tabData.btn.BackgroundColor3 = isActive and newPal.Active or newPal.Card
			tabData.btn.TextColor3 = isActive and newPal.Text or newPal.TextSub
			tabData.indicator.BackgroundColor3 = newPal.Accent
			tabData.page.ScrollBarImageColor3 = newPal.Border

			if tabData.icon then
				tabData.icon.ImageColor3 = isActive and newPal.Text or newPal.TextSub
			end
		end

		snapshotLayout("theme-switch")

		Animator:Ripple(themeToggle, 25, 12)

		if RvrseUI.ConfigurationSaving then
			RvrseUI:_autoSave()
		end

		if NotificationsService and NotificationsService.Notify then
			NotificationsService:Notify({
				Title = "Theme Changed",
				Message = "Switched to " .. newTheme .. " mode",
				Duration = 2,
				Type = "info"
			})
		end
	end)

	task.defer(syncPillFromTheme)

	table.insert(RvrseUI._windows, WindowAPI)

	task.defer(function()
		WindowAPI:Show()
	end)

	return WindowAPI
end

return WindowBuilder

