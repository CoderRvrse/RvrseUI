-- =========================
-- RvrseUI TabBuilder Module
-- =========================
-- Tab builder that creates TabAPI with CreateSection method
-- Extracted from RvrseUI.lua (lines 2518-2806)
-- Part of RvrseUI v2.13.0 Modular Architecture

local TabBuilder = {}

-- Creates a Tab with CreateSection method
-- Dependencies required:
--   - Theme: Theme module
--   - UIHelpers: {corner}
--   - Animator: Animation module
--   - Icons: Icon resolution module
--   - SectionBuilder: Section builder module
--   - tabBar: Parent frame for tab buttons
--   - body: Parent frame for tab pages
--   - tabs: Array to track all tabs (for activation logic)
--   - activePage: Reference to currently active page (mutable)
function TabBuilder.CreateTab(t, dependencies)
	t = t or {}

	local Theme = dependencies.Theme
	local corner = dependencies.UIHelpers.corner
	local Animator = dependencies.Animator
	local Icons = dependencies.Icons
	local SectionBuilder = dependencies.SectionBuilder
	local tabBar = dependencies.tabBar
	local body = dependencies.body
	local tabs = dependencies.tabs
	local activePage = dependencies.activePage

	local function currentPalette()
		return Theme:Get()
	end
	local pal2 = currentPalette()

	-- Icon-only tab button (modern vertical rail design)
	local tabBtn = Instance.new("TextButton")
	tabBtn.AutoButtonColor = false
	tabBtn.BackgroundColor3 = pal2.Card
	tabBtn.BackgroundTransparency = 0.3
	tabBtn.BorderSizePixel = 0
	tabBtn.Size = UDim2.new(1, -16, 0, 56) -- Square-ish icon button
	tabBtn.Font = Enum.Font.GothamMedium
	tabBtn.TextSize = 24
	tabBtn.TextColor3 = pal2.TextSub
	tabBtn.Text = ""
	tabBtn.Parent = tabBar
	corner(tabBtn, 12)

	-- Subtle border
	local tabStroke = Instance.new("UIStroke")
	tabStroke.Color = pal2.Border
	tabStroke.Thickness = 1
	tabStroke.Transparency = 0.6
	tabStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	tabStroke.Parent = tabBtn

	-- Handle icon display (icon-only design)
	local tabIcon = nil
	local tabText = t.Title or "Tab"

	if t.Icon then
		local iconAsset, iconType = Icons:Resolve(t.Icon)

		if iconType == "image" then
			-- Create centered image icon
			tabIcon = Instance.new("ImageLabel")
			tabIcon.BackgroundTransparency = 1
			tabIcon.Image = iconAsset
			tabIcon.Size = UDim2.new(0, 28, 0, 28)
			tabIcon.Position = UDim2.new(0.5, -14, 0.5, -14)
			tabIcon.ImageColor3 = pal2.TextSub
			tabIcon.Parent = tabBtn
		elseif iconType == "text" then
			-- Use emoji/text icon centered
			tabBtn.Text = iconAsset
			tabBtn.TextSize = 24
		end
	else
		-- Fallback: use first letter of tab name
		local firstLetter = string.sub(tabText, 1, 1):upper()
		tabBtn.Text = firstLetter
		tabBtn.Font = Enum.Font.GothamBold
		tabBtn.TextSize = 20
	end

	-- Gradient overlay on active tab
	local tabGradient = Instance.new("UIGradient")
	tabGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, pal2.Primary),
		ColorSequenceKeypoint.new(0.5, pal2.Accent),
		ColorSequenceKeypoint.new(1, pal2.Secondary),
	}
	tabGradient.Rotation = 45
	tabGradient.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 1),
	}
	tabGradient.Parent = tabBtn

	-- Side indicator (glowing accent line)
	local tabIndicator = Instance.new("Frame")
	tabIndicator.BackgroundColor3 = pal2.Accent
	tabIndicator.BorderSizePixel = 0
	tabIndicator.AnchorPoint = Vector2.new(0, 0.5)
	tabIndicator.Position = UDim2.new(0, -6, 0.5, 0)
	tabIndicator.Size = UDim2.new(0, 4, 0, 0)
	tabIndicator.Visible = false
	tabIndicator.Parent = tabBtn
	corner(tabIndicator, 2)

	-- Tab page (scrollable)
	local page = Instance.new("ScrollingFrame")
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.Position = UDim2.new(0, 0, 0, 0)
	page.Size = UDim2.new(1, 0, 1, 0)
	page.ScrollBarThickness = 6
	page.ScrollBarImageColor3 = pal2.Border
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.ClipsDescendants = false
	page.Visible = false
	page.Parent = body

	local pagePadding = Instance.new("UIPadding")
	pagePadding.PaddingTop = UDim.new(0, 4)
	pagePadding.PaddingBottom = UDim.new(0, 4)
	pagePadding.Parent = page

	local pageLayout = Instance.new("UIListLayout")
	pageLayout.Padding = UDim.new(0, 12)
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageLayout.Parent = page

	local function setInactive(tabData)
		local pal = currentPalette()
		tabData.btn:SetAttribute("Active", false)
		tabData.page.Visible = false
		tabData.btn.BackgroundTransparency = 0.3
		tabData.btn.TextColor3 = pal.TextSub
		if tabData.icon then
			tabData.icon.ImageColor3 = pal.TextSub
		end

		-- Hide gradient (cannot tween NumberSequence, set directly)
		if tabData.gradient then
			tabData.gradient.Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 1),
			}
		end

		-- Restore border
		if tabData.stroke then
			Animator:Tween(tabData.stroke, {
				Thickness = 1,
				Transparency = 0.6
			}, Animator.Spring.Snappy)
		end

		tabData.indicator.Visible = false
	end

	-- Tab activation
	local function activateTab()
		local pal = currentPalette()
		for _, tabData in ipairs(tabs) do
			setInactive(tabData)
		end
		page.Visible = true
		tabBtn:SetAttribute("Active", true)
		tabBtn.BackgroundTransparency = 0.1
		tabBtn.TextColor3 = pal.TextBright
		if tabIcon then
			tabIcon.ImageColor3 = pal.Accent
		end

		-- Show gradient (cannot tween NumberSequence, set directly)
		tabGradient.Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 0.5),
		}

		-- Glow border
		Animator:Tween(tabStroke, {
			Color = pal.Accent,
			Thickness = 2,
			Transparency = 0.3
		}, Animator.Spring.Snappy)

		-- Indicator expands
		tabIndicator.Visible = true
		tabIndicator.Size = UDim2.new(0, 4, 0, 0)
		Animator:Tween(tabIndicator, {Size = UDim2.new(0, 4, 1, -12)}, Animator.Spring.Spring)
		dependencies.activePage = page  -- Update active page reference
	end

	tabBtn.MouseButton1Click:Connect(activateTab)
	tabBtn.MouseEnter:Connect(function()
		if page.Visible == false then
			-- Brighten background and border on hover
			Animator:Tween(tabBtn, {BackgroundTransparency = 0.1}, Animator.Spring.Lightning)
			Animator:Tween(tabStroke, {Transparency = 0.4}, Animator.Spring.Lightning)
		end
	end)
	tabBtn.MouseLeave:Connect(function()
		if page.Visible == false then
			-- Restore inactive state
			Animator:Tween(tabBtn, {BackgroundTransparency = 0.3}, Animator.Spring.Snappy)
			Animator:Tween(tabStroke, {Transparency = 0.6}, Animator.Spring.Snappy)
		end
	end)

	table.insert(tabs, {
		btn = tabBtn,
		page = page,
		indicator = tabIndicator,
		icon = tabIcon,
		gradient = tabGradient,
		stroke = tabStroke
	})

	-- Activate first tab automatically
	if #tabs == 1 then
		activateTab()
	end

	local TabAPI = {}

	-- Tab SetIcon Method (icon-only design)
	function TabAPI:SetIcon(newIcon)
		if not newIcon then return end

		local iconAsset, iconType = Icons:Resolve(newIcon)
		local pal = currentPalette()

		-- Remove old icon if exists
		if tabIcon and tabIcon.Parent then
			tabIcon:Destroy()
			tabIcon = nil
		end

		if iconType == "image" then
			-- Create centered image icon
			tabIcon = Instance.new("ImageLabel")
			tabIcon.BackgroundTransparency = 1
			tabIcon.Image = iconAsset
			tabIcon.Size = UDim2.new(0, 28, 0, 28)
			tabIcon.Position = UDim2.new(0.5, -14, 0.5, -14)
			tabIcon.ImageColor3 = pal.TextSub
			tabIcon.Parent = tabBtn
			tabBtn.Text = ""
		elseif iconType == "text" then
			-- Use emoji/text icon centered
			tabBtn.Text = iconAsset
			tabBtn.TextSize = 24
		end

		-- Update the tabs table reference
		for i, tabData in ipairs(tabs) do
			if tabData.btn == tabBtn then
				tabs[i].icon = tabIcon
				break
			end
		end
	end

	-- CreateSection method delegates to SectionBuilder
	function TabAPI:CreateSection(sectionTitle)
		return SectionBuilder.CreateSection(sectionTitle, page, dependencies)
	end

	return TabAPI
end

-- Initialize method (called by init.lua)
function TabBuilder:Initialize(deps)
	-- TabBuilder is ready to use
	-- Dependencies are passed when CreateTab is called
	-- No initialization state needed
end

return TabBuilder
