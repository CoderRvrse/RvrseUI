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

	local pal2 = Theme:Get()

	-- Tab button with icon support (Lucide, Roblox asset ID, or emoji)
	local tabBtn = Instance.new("TextButton")
	tabBtn.AutoButtonColor = false
	tabBtn.BackgroundColor3 = pal2.Card
	tabBtn.BackgroundTransparency = 0.7
	tabBtn.Size = UDim2.new(0, 100, 1, 0)
	tabBtn.Font = Enum.Font.GothamMedium
	tabBtn.TextSize = 13
	tabBtn.TextColor3 = pal2.TextSub
	tabBtn.Parent = tabBar
	corner(tabBtn, 8)

	-- Handle icon display
	local tabIcon = nil
	local tabText = t.Title or "Tab"

	if t.Icon then
		local iconAsset, iconType = Icons:Resolve(t.Icon)

		if iconType == "image" then
			-- Create image icon
			tabIcon = Instance.new("ImageLabel")
			tabIcon.BackgroundTransparency = 1
			tabIcon.Image = iconAsset
			tabIcon.Size = UDim2.new(0, 16, 0, 16)
			tabIcon.Position = UDim2.new(0, 8, 0.5, -8)
			tabIcon.ImageColor3 = pal2.TextSub
			tabIcon.Parent = tabBtn

			-- Adjust text position for image icon
			tabBtn.Text = "     " .. tabText
			tabBtn.TextXAlignment = Enum.TextXAlignment.Left
		elseif iconType == "text" then
			-- Use emoji/text icon inline
			tabBtn.Text = iconAsset .. " " .. tabText
		end
	else
		-- No icon, just text
		tabBtn.Text = tabText
	end

	local tabIndicator = Instance.new("Frame")
	tabIndicator.BackgroundColor3 = pal2.Accent
	tabIndicator.BorderSizePixel = 0
	tabIndicator.Position = UDim2.new(0, 0, 1, -3)
	tabIndicator.Size = UDim2.new(0, 0, 0, 3)
	tabIndicator.Visible = false
	tabIndicator.Parent = tabBtn
	corner(tabIndicator, 2)

	-- Tab page (scrollable)
	local page = Instance.new("ScrollingFrame")
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.Position = UDim2.new(0, 8, 0, 8)
	page.Size = UDim2.new(1, -16, 1, -16)
	page.ScrollBarThickness = 6
	page.ScrollBarImageColor3 = pal2.Border
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.Parent = body

	local pageLayout = Instance.new("UIListLayout")
	pageLayout.Padding = UDim.new(0, 12)
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageLayout.Parent = page

	-- Tab activation
	local function activateTab()
		for _, tabData in ipairs(tabs) do
			tabData.page.Visible = false
			tabData.btn.BackgroundTransparency = 0.7
			tabData.btn.TextColor3 = pal2.TextSub
			tabData.indicator.Visible = false
		end
		page.Visible = true
		tabBtn.BackgroundTransparency = 0
		tabBtn.TextColor3 = pal2.Text
		tabIndicator.Visible = true
		Animator:Tween(tabIndicator, {Size = UDim2.new(1, 0, 0, 3)}, Animator.Spring.Snappy)
		dependencies.activePage = page  -- Update active page reference
	end

	tabBtn.MouseButton1Click:Connect(activateTab)
	tabBtn.MouseEnter:Connect(function()
		if page.Visible == false then
			Animator:Tween(tabBtn, {BackgroundTransparency = 0.4}, Animator.Spring.Fast)
		end
	end)
	tabBtn.MouseLeave:Connect(function()
		if page.Visible == false then
			Animator:Tween(tabBtn, {BackgroundTransparency = 0.7}, Animator.Spring.Fast)
		end
	end)

	table.insert(tabs, {btn = tabBtn, page = page, indicator = tabIndicator, icon = tabIcon})

	-- Activate first tab automatically
	if #tabs == 1 then
		activateTab()
	end

	local TabAPI = {}

	-- Tab SetIcon Method
	function TabAPI:SetIcon(newIcon)
		if not newIcon then return end

		local iconAsset, iconType = Icons:Resolve(newIcon)

		-- Remove old icon if exists
		if tabIcon and tabIcon.Parent then
			tabIcon:Destroy()
			tabIcon = nil
		end

		if iconType == "image" then
			-- Create new image icon
			tabIcon = Instance.new("ImageLabel")
			tabIcon.BackgroundTransparency = 1
			tabIcon.Image = iconAsset
			tabIcon.Size = UDim2.new(0, 16, 0, 16)
			tabIcon.Position = UDim2.new(0, 8, 0.5, -8)
			tabIcon.ImageColor3 = pal2.TextSub
			tabIcon.Parent = tabBtn

			tabBtn.Text = "     " .. tabText
			tabBtn.TextXAlignment = Enum.TextXAlignment.Left
		elseif iconType == "text" then
			-- Use emoji/text icon inline
			tabBtn.Text = iconAsset .. " " .. tabText
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
