-- FilterableList Element Module v4.4.0
-- Live-filterable scrollable list with search input
-- Designed for item fetchers, player lists, teleport locations, etc.

local FilterableList = {}

function FilterableList.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local corner = dependencies.corner
	local stroke = dependencies.stroke
	local pal3 = dependencies.pal3
	local Animator = dependencies.Animator
	local RvrseUI = dependencies.RvrseUI
	local Theme = dependencies.Theme
	local Icons = dependencies.Icons
	local UIS = dependencies.UIS
	local isLightTheme = Theme and Theme.Current == "Light"
	local baseTransparency = isLightTheme and 0 or 0.3
	local focusTransparency = isLightTheme and 0 or 0.1

	-- Settings
	local items = {}
	local sourceItems = o.Items or {}
	for _, item in ipairs(sourceItems) do
		if type(item) == "string" then
			table.insert(items, { Text = item, Data = item })
		elseif type(item) == "table" then
			table.insert(items, {
				Text = item.Text or tostring(item.Data or "Item"),
				Icon = item.Icon,
				Data = item.Data or item.Text,
			})
		end
	end

	local maxVisibleItems = o.MaxVisibleItems or 6
	local itemHeight = o.ItemHeight or 36
	local debounceTime = o.DebounceTime or 0.15
	local placeholder = o.PlaceholderText or "Type to filter..."
	local showCount = o.ShowCount ~= false
	local caseSensitive = o.CaseSensitive or false
	local noResultsText = o.NoResultsText or "No results found"
	local ICON_SIZE = 20
	local ICON_MARGIN = 8

	-- Calculate heights
	local searchHeight = 40
	local listPadding = 8
	local headerHeight = o.Text and 28 or 0
	local listMaxHeight = (maxVisibleItems * itemHeight) + ((maxVisibleItems - 1) * 4) + listPadding
	local totalHeight = searchHeight + listMaxHeight + headerHeight + 16

	-- Create main container (no card() helper - we manage our own layout)
	local f = Instance.new("Frame")
	f.Name = "FilterableList"
	f.BackgroundColor3 = pal3.Elevated
	f.BackgroundTransparency = isLightTheme and 0 or 0.3
	f.BorderSizePixel = 0
	f.Size = UDim2.new(1, 0, 0, totalHeight)
	f.AutomaticSize = Enum.AutomaticSize.Y
	f.Parent = dependencies.card and dependencies.card(0).Parent or nil
	corner(f, 10)
	stroke(f, pal3.Border, 1)

	local mainPadding = Instance.new("UIPadding")
	mainPadding.PaddingTop = UDim.new(0, 12)
	mainPadding.PaddingBottom = UDim.new(0, 12)
	mainPadding.PaddingLeft = UDim.new(0, 12)
	mainPadding.PaddingRight = UDim.new(0, 12)
	mainPadding.Parent = f

	local mainLayout = Instance.new("UIListLayout")
	mainLayout.FillDirection = Enum.FillDirection.Vertical
	mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
	mainLayout.Padding = UDim.new(0, 8)
	mainLayout.Parent = f

	-- Header label (if provided)
	if o.Text then
		local headerLabel = Instance.new("TextLabel")
		headerLabel.Name = "Header"
		headerLabel.BackgroundTransparency = 1
		headerLabel.Size = UDim2.new(1, 0, 0, 20)
		headerLabel.Font = Enum.Font.GothamBold
		headerLabel.TextSize = 15
		headerLabel.TextXAlignment = Enum.TextXAlignment.Left
		headerLabel.TextColor3 = pal3.Text
		headerLabel.Text = o.Text
		headerLabel.LayoutOrder = 1
		headerLabel.Parent = f
	end

	-- Search container
	local searchContainer = Instance.new("Frame")
	searchContainer.Name = "SearchContainer"
	searchContainer.BackgroundTransparency = 1
	searchContainer.Size = UDim2.new(1, 0, 0, searchHeight)
	searchContainer.LayoutOrder = 2
	searchContainer.Parent = f

	-- Search input
	local searchBox = Instance.new("TextBox")
	searchBox.Name = "SearchInput"
	searchBox.AnchorPoint = Vector2.new(0, 0)
	searchBox.Position = UDim2.new(0, 0, 0, 0)
	searchBox.Size = UDim2.new(1, 0, 1, 0)
	searchBox.BackgroundColor3 = pal3.Card
	searchBox.BackgroundTransparency = baseTransparency
	searchBox.BorderSizePixel = 0
	searchBox.Font = Enum.Font.GothamMedium
	searchBox.TextSize = 14
	searchBox.TextColor3 = pal3.TextBright
	searchBox.PlaceholderText = placeholder
	searchBox.PlaceholderColor3 = pal3.TextMuted
	searchBox.Text = ""
	searchBox.ClearTextOnFocus = false
	searchBox.TextXAlignment = Enum.TextXAlignment.Left
	searchBox.Parent = searchContainer
	corner(searchBox, 8)

	local searchPadding = Instance.new("UIPadding")
	searchPadding.PaddingLeft = UDim.new(0, 12)
	searchPadding.PaddingRight = UDim.new(0, 12)
	searchPadding.Parent = searchBox

	-- Search border
	local searchStroke = Instance.new("UIStroke")
	searchStroke.Color = pal3.Border
	searchStroke.Thickness = 1
	searchStroke.Transparency = 0.6
	searchStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	searchStroke.LineJoinMode = Enum.LineJoinMode.Round
	searchStroke.Parent = searchBox

	-- Search underline (glows on focus)
	local searchUnderline = Instance.new("Frame")
	searchUnderline.AnchorPoint = Vector2.new(0.5, 1)
	searchUnderline.Position = UDim2.new(0.5, 0, 1, 0)
	searchUnderline.Size = UDim2.new(0, 0, 0, 2)
	searchUnderline.BackgroundColor3 = pal3.Accent
	searchUnderline.BorderSizePixel = 0
	searchUnderline.ZIndex = 5
	searchUnderline.Parent = searchBox
	corner(searchUnderline, 1)

	-- Count label (shows filtered count)
	local countLabel
	if showCount then
		countLabel = Instance.new("TextLabel")
		countLabel.Name = "CountLabel"
		countLabel.BackgroundTransparency = 1
		countLabel.AnchorPoint = Vector2.new(1, 0.5)
		countLabel.Position = UDim2.new(1, -8, 0.5, 0)
		countLabel.Size = UDim2.new(0, 60, 0, 20)
		countLabel.Font = Enum.Font.Gotham
		countLabel.TextSize = 12
		countLabel.TextColor3 = pal3.TextMuted
		countLabel.TextXAlignment = Enum.TextXAlignment.Right
		countLabel.Text = #items .. " items"
		countLabel.Parent = searchContainer
	end

	-- List container
	local listContainer = Instance.new("Frame")
	listContainer.Name = "ListContainer"
	listContainer.BackgroundColor3 = pal3.Card
	listContainer.BackgroundTransparency = baseTransparency + 0.2
	listContainer.BorderSizePixel = 0
	listContainer.Size = UDim2.new(1, 0, 0, listMaxHeight)
	listContainer.ClipsDescendants = true
	listContainer.LayoutOrder = 3
	listContainer.Parent = f
	corner(listContainer, 8)
	stroke(listContainer, pal3.Border, 1)

	-- Scrolling frame for items
	local listScroll = Instance.new("ScrollingFrame")
	listScroll.Name = "ItemList"
	listScroll.BackgroundTransparency = 1
	listScroll.BorderSizePixel = 0
	listScroll.Size = UDim2.new(1, -8, 1, -8)
	listScroll.Position = UDim2.new(0, 4, 0, 4)
	listScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	listScroll.ScrollBarThickness = 4
	listScroll.ScrollBarImageColor3 = pal3.Accent
	listScroll.ScrollBarImageTransparency = 0.3
	listScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	listScroll.Parent = listContainer

	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Vertical
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 4)
	listLayout.Parent = listScroll

	local listPad = Instance.new("UIPadding")
	listPad.PaddingTop = UDim.new(0, 2)
	listPad.PaddingBottom = UDim.new(0, 2)
	listPad.PaddingLeft = UDim.new(0, 2)
	listPad.PaddingRight = UDim.new(0, 2)
	listPad.Parent = listScroll

	-- No results label
	local noResultsLabel = Instance.new("TextLabel")
	noResultsLabel.Name = "NoResults"
	noResultsLabel.BackgroundTransparency = 1
	noResultsLabel.Size = UDim2.new(1, 0, 0, itemHeight)
	noResultsLabel.Font = Enum.Font.GothamMedium
	noResultsLabel.TextSize = 14
	noResultsLabel.TextColor3 = pal3.TextMuted
	noResultsLabel.Text = noResultsText
	noResultsLabel.Visible = false
	noResultsLabel.Parent = listScroll

	-- State
	local filteredItems = {}
	local itemButtons = {}
	local currentQuery = ""
	local debounceThread = nil
	local isFocused = false

	-- Filter function
	local function defaultFilter(query, itemText)
		if caseSensitive then
			return itemText:find(query, 1, true) ~= nil
		else
			return itemText:lower():find(query:lower(), 1, true) ~= nil
		end
	end

	local filterFn = o.OnFilter or defaultFilter

	-- Update count label
	local function updateCount(filtered, total)
		if countLabel then
			if filtered == total then
				countLabel.Text = total .. " items"
			else
				countLabel.Text = filtered .. "/" .. total
			end
		end
	end

	-- Create item button
	local function createItemButton(item, index)
		local itemBtn = Instance.new("TextButton")
		itemBtn.Name = "Item_" .. index
		itemBtn.Size = UDim2.new(1, -4, 0, itemHeight)
		itemBtn.BackgroundColor3 = pal3.Elevated
		itemBtn.BackgroundTransparency = 0.5
		itemBtn.BorderSizePixel = 0
		itemBtn.Text = ""
		itemBtn.AutoButtonColor = false
		itemBtn.LayoutOrder = index
		itemBtn.Parent = listScroll
		corner(itemBtn, 6)

		-- Content layout
		local contentFrame = Instance.new("Frame")
		contentFrame.Name = "Content"
		contentFrame.BackgroundTransparency = 1
		contentFrame.Size = UDim2.new(1, 0, 1, 0)
		contentFrame.Parent = itemBtn

		local contentPad = Instance.new("UIPadding")
		contentPad.PaddingLeft = UDim.new(0, 10)
		contentPad.PaddingRight = UDim.new(0, 10)
		contentPad.Parent = contentFrame

		-- Icon holder (if item has icon)
		local textOffset = 0
		if item.Icon and Icons then
			local iconHolder = Instance.new("Frame")
			iconHolder.Name = "IconHolder"
			iconHolder.BackgroundTransparency = 1
			iconHolder.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
			iconHolder.AnchorPoint = Vector2.new(0, 0.5)
			iconHolder.Position = UDim2.new(0, 0, 0.5, 0)
			iconHolder.ClipsDescendants = true
			iconHolder.Parent = contentFrame

			local iconValue, iconType = Icons:Resolve(item.Icon)
			if iconType == "image" and type(iconValue) == "string" then
				local iconImage = Instance.new("ImageLabel")
				iconImage.BackgroundTransparency = 1
				iconImage.Size = UDim2.new(1, 0, 1, 0)
				iconImage.Image = iconValue
				iconImage.ImageColor3 = pal3.TextSub
				iconImage.Parent = iconHolder
			elseif iconType == "sprite" and type(iconValue) == "table" then
				local iconImage = Instance.new("ImageLabel")
				iconImage.BackgroundTransparency = 1
				iconImage.Size = UDim2.new(1, 0, 1, 0)
				iconImage.Image = "rbxassetid://" .. iconValue.id
				iconImage.ImageRectSize = iconValue.imageRectSize
				iconImage.ImageRectOffset = iconValue.imageRectOffset
				iconImage.ImageColor3 = pal3.TextSub
				iconImage.Parent = iconHolder
			elseif iconValue and iconType == "text" then
				local iconText = Instance.new("TextLabel")
				iconText.BackgroundTransparency = 1
				iconText.Size = UDim2.new(1, 0, 1, 0)
				iconText.Font = Enum.Font.GothamBold
				iconText.TextSize = 16
				iconText.TextColor3 = pal3.TextSub
				iconText.Text = tostring(iconValue)
				iconText.Parent = iconHolder
			end

			textOffset = ICON_SIZE + ICON_MARGIN
		end

		-- Text label
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "ItemText"
		textLabel.BackgroundTransparency = 1
		textLabel.AnchorPoint = Vector2.new(0, 0.5)
		textLabel.Position = UDim2.new(0, textOffset, 0.5, 0)
		textLabel.Size = UDim2.new(1, -textOffset, 1, 0)
		textLabel.Font = Enum.Font.GothamMedium
		textLabel.TextSize = 14
		textLabel.TextColor3 = pal3.Text
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.TextTruncate = Enum.TextTruncate.AtEnd
		textLabel.Text = item.Text
		textLabel.Parent = contentFrame

		-- Click handler
		itemBtn.MouseButton1Click:Connect(function()
			if RvrseUI.Store:IsLocked(o.RespectLock) then return end

			-- Visual feedback
			Animator:Pulse(itemBtn, 0.98, Animator.Spring.Lightning)
			Animator:Tween(itemBtn, {BackgroundTransparency = 0.2}, Animator.Spring.Lightning)
			task.delay(0.1, function()
				if itemBtn and itemBtn.Parent then
					Animator:Tween(itemBtn, {BackgroundTransparency = 0.5}, Animator.Spring.Snappy)
				end
			end)

			if o.OnItemClick then
				task.spawn(o.OnItemClick, item)
			end
		end)

		-- Hover effects
		itemBtn.MouseEnter:Connect(function()
			if not RvrseUI.Store:IsLocked(o.RespectLock) then
				Animator:Tween(itemBtn, {BackgroundColor3 = pal3.Hover, BackgroundTransparency = 0.3}, Animator.Spring.Fast)
				Animator:Tween(textLabel, {TextColor3 = pal3.TextBright}, Animator.Spring.Fast)
			end
		end)

		itemBtn.MouseLeave:Connect(function()
			Animator:Tween(itemBtn, {BackgroundColor3 = pal3.Elevated, BackgroundTransparency = 0.5}, Animator.Spring.Fast)
			Animator:Tween(textLabel, {TextColor3 = pal3.Text}, Animator.Spring.Fast)
		end)

		return itemBtn
	end

	-- Rebuild visible items based on filter
	local function rebuildList(query)
		-- Clear existing buttons
		for _, btn in ipairs(itemButtons) do
			if btn and btn.Parent then
				btn:Destroy()
			end
		end
		table.clear(itemButtons)
		table.clear(filteredItems)

		-- Filter items
		for i, item in ipairs(items) do
			local matches = true
			if query and query ~= "" then
				if o.OnFilter then
					matches = o.OnFilter(query, item)
				else
					matches = filterFn(query, item.Text)
				end
			end

			if matches then
				table.insert(filteredItems, item)
			end
		end

		-- Show/hide no results
		noResultsLabel.Visible = #filteredItems == 0

		-- Create buttons for filtered items
		for i, item in ipairs(filteredItems) do
			local btn = createItemButton(item, i)
			table.insert(itemButtons, btn)
		end

		-- Update count
		updateCount(#filteredItems, #items)

		-- Reset scroll position
		listScroll.CanvasPosition = Vector2.new(0, 0)
	end

	-- Debounced filter
	local function onSearchChanged()
		local query = searchBox.Text
		if query == currentQuery then return end
		currentQuery = query

		if debounceThread then
			task.cancel(debounceThread)
		end

		debounceThread = task.delay(debounceTime, function()
			rebuildList(query)
			debounceThread = nil
		end)
	end

	-- Search focus effects
	searchBox.Focused:Connect(function()
		isFocused = true
		Animator:Tween(searchBox, {BackgroundTransparency = focusTransparency}, Animator.Spring.Lightning)
		Animator:Tween(searchStroke, {Color = pal3.Accent, Thickness = 2, Transparency = 0.3}, Animator.Spring.Snappy)
		Animator:Tween(searchUnderline, {Size = UDim2.new(1, 0, 0, 2)}, Animator.Spring.Spring)
		Animator:Shimmer(searchBox, Theme)
	end)

	searchBox.FocusLost:Connect(function()
		isFocused = false
		Animator:Tween(searchBox, {BackgroundTransparency = baseTransparency}, Animator.Spring.Snappy)
		Animator:Tween(searchStroke, {Color = pal3.Border, Thickness = 1, Transparency = 0.6}, Animator.Spring.Snappy)
		Animator:Tween(searchUnderline, {Size = UDim2.new(0, 0, 0, 2)}, Animator.Spring.Glide)
	end)

	-- Live filtering on text change
	searchBox:GetPropertyChangedSignal("Text"):Connect(onSearchChanged)

	-- Lock listener
	table.insert(RvrseUI._lockListeners, function()
		local locked = RvrseUI.Store:IsLocked(o.RespectLock)
		searchBox.TextEditable = not locked
		if locked then
			f.BackgroundTransparency = 0.6
		else
			f.BackgroundTransparency = isLightTheme and 0 or 0.3
		end
	end)

	-- Initial build
	rebuildList("")

	-- Public API
	local listAPI = {
		-- Set new items list
		SetItems = function(_, newItems)
			items = {}
			for _, item in ipairs(newItems or {}) do
				if type(item) == "string" then
					table.insert(items, { Text = item, Data = item })
				elseif type(item) == "table" then
					table.insert(items, {
						Text = item.Text or tostring(item.Data or "Item"),
						Icon = item.Icon,
						Data = item.Data or item.Text,
					})
				end
			end
			rebuildList(currentQuery)
		end,

		-- Add single item
		AddItem = function(_, item)
			if type(item) == "string" then
				table.insert(items, { Text = item, Data = item })
			elseif type(item) == "table" then
				table.insert(items, {
					Text = item.Text or tostring(item.Data or "Item"),
					Icon = item.Icon,
					Data = item.Data or item.Text,
				})
			end
			rebuildList(currentQuery)
		end,

		-- Remove item by data or text
		RemoveItem = function(_, itemToRemove)
			for i, item in ipairs(items) do
				if item.Data == itemToRemove or item.Text == itemToRemove then
					table.remove(items, i)
					break
				end
			end
			rebuildList(currentQuery)
		end,

		-- Clear all items
		Clear = function(_)
			items = {}
			rebuildList("")
		end,

		-- Get current items
		GetItems = function(_)
			return items
		end,

		-- Get filtered items
		GetFilteredItems = function(_)
			return filteredItems
		end,

		-- Set search query programmatically
		SetQuery = function(_, query)
			searchBox.Text = query or ""
			rebuildList(query or "")
		end,

		-- Get current query
		GetQuery = function(_)
			return currentQuery
		end,

		-- Refresh the list (re-filter)
		Refresh = function(_)
			rebuildList(currentQuery)
		end,

		-- Set visibility
		SetVisible = function(_, visible)
			f.Visible = visible
		end,

		-- Get visibility
		IsVisible = function(_)
			return f.Visible
		end,

		-- Get count
		GetCount = function(_)
			return #filteredItems, #items
		end,

		-- Current value (for config compatibility)
		CurrentValue = currentQuery,
	}

	-- Store in flags if provided
	if o.Flag then
		RvrseUI.Flags[o.Flag] = listAPI
	end

	return listAPI
end

return FilterableList
