-- =========================
-- Overlay Service Module
-- =========================
-- Manages a dedicated ScreenGui for popovers, dropdown blockers,
-- and modal dimming. Ensures a single overlay host is reused and
-- exposes helpers to show/hide the global blocker.

local Overlay = {}
Overlay._initialized = false

-- Diagnostic lines: silent unless RvrseUI:EnableDebug(true) is on
local function dprint(...)
	local dbg = Overlay.Debug
	if dbg and dbg.IsEnabled and dbg:IsEnabled() then
		print(...)
	end
end

local function setLayerVisibility(layer)
	local anyVisible = false
	for _, child in ipairs(layer:GetChildren()) do
		if child.Visible then
			anyVisible = true
			break
		end
	end
	layer.Visible = anyVisible
end

function Overlay:Initialize(opts)
	if self._initialized then
		return
	end

	opts = opts or {}
	local playerGui = opts.PlayerGui
	assert(playerGui, "[Overlay] PlayerGui is required")
	self._opts = opts -- kept so Revive() can rebuild after a Teardown()
	self._connections = {}

	local function resolveDisplayOrder()
		if opts.DisplayOrder then
			return opts.DisplayOrder
		end

		local maxOrder = 0
		for _, gui in ipairs(playerGui:GetChildren()) do
			if gui:IsA("ScreenGui") then
				maxOrder = math.max(maxOrder, gui.DisplayOrder)
			end
		end
		return maxOrder + 1
	end

	local desiredDisplayOrder = resolveDisplayOrder()

	local popovers = playerGui:FindFirstChild("RvrseUI_Popovers")
	if not popovers then
		popovers = Instance.new("ScreenGui")
		popovers.Name = "RvrseUI_Popovers"
		popovers.ResetOnSpawn = false
		popovers.IgnoreGuiInset = true
		popovers.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		popovers.DisplayOrder = desiredDisplayOrder
		popovers.Parent = playerGui
	else
		popovers.DisplayOrder = math.max(popovers.DisplayOrder, desiredDisplayOrder)
	end
	self.Gui = popovers
	self._displayOrderConnections = self._displayOrderConnections or {}

	local displayOrderConnections = self._displayOrderConnections

	local function disconnectGui(gui)
		local bundle = displayOrderConnections[gui]
		if bundle then
			if bundle.orderChanged then
				bundle.orderChanged:Disconnect()
			end
			if bundle.ancestryChanged then
				bundle.ancestryChanged:Disconnect()
			end
			displayOrderConnections[gui] = nil
		end
	end

	local function updateDisplayOrder()
		local highest = opts.DisplayOrder or 0
		for _, gui in ipairs(playerGui:GetChildren()) do
			if gui:IsA("ScreenGui") and gui ~= popovers then
				highest = math.max(highest, gui.DisplayOrder)
			end
		end
		popovers.DisplayOrder = math.max(highest + 1, popovers.DisplayOrder, opts.DisplayOrder or 0)
	end

	local function watchGui(gui)
		if not gui:IsA("ScreenGui") or gui == popovers then
			return
		end
		if displayOrderConnections[gui] then
			return
		end

		local orderConn = gui:GetPropertyChangedSignal("DisplayOrder"):Connect(function()
			updateDisplayOrder()
		end)
		local ancestryConn = gui.AncestryChanged:Connect(function(_, parent)
			if parent ~= playerGui then
				disconnectGui(gui)
				task.defer(updateDisplayOrder)
			end
		end)

		displayOrderConnections[gui] = {
			orderChanged = orderConn,
			ancestryChanged = ancestryConn,
		}
	end

	for _, gui in ipairs(playerGui:GetChildren()) do
		watchGui(gui)
	end

	table.insert(self._connections, playerGui.ChildAdded:Connect(function(child)
		watchGui(child)
		task.defer(updateDisplayOrder)
	end))

	table.insert(self._connections, playerGui.ChildRemoved:Connect(function(child)
		disconnectGui(child)
		task.defer(updateDisplayOrder)
	end))

	updateDisplayOrder()

	-- Create overlay layer first (transparent container for overlays)
	local layer = popovers:FindFirstChild("OverlayLayer")
	if layer and not layer:IsA("Frame") then
		layer:Destroy()
		layer = nil
	end
	if not layer then
		layer = Instance.new("Frame")
		layer.Name = "OverlayLayer"
		layer.BackgroundTransparency = 1
		layer.BorderSizePixel = 0
		layer.ClipsDescendants = false
		layer.Size = UDim2.new(1, 0, 1, 0)
		layer.ZIndex = 1  -- Base layer
		layer.Visible = false
		layer.Parent = popovers
	end
	self.Layer = layer

	-- Create blocker inside layer (below overlay elements)
	local blocker = layer:FindFirstChild("OverlayBlocker")
	if blocker and not blocker:IsA("TextButton") then
		blocker:Destroy()
		blocker = nil
	end
	if not blocker then
		blocker = Instance.new("TextButton")
		blocker.Name = "OverlayBlocker"
		blocker.AutoButtonColor = false
		blocker.BackgroundColor3 = Color3.new(0, 0, 0)
		blocker.BackgroundTransparency = 1
		blocker.BorderSizePixel = 0
		blocker.Text = ""
		blocker.Size = UDim2.new(1, 0, 1, 0)
		blocker.ZIndex = 100  -- Below overlay elements (200+)
		blocker.Visible = false
		blocker.Modal = false
		blocker.Parent = layer  -- ⭐ Parent to layer, not popovers!
	end
	self.Blocker = blocker

	table.insert(self._connections, layer.ChildAdded:Connect(function(child)
		child:GetPropertyChangedSignal("Visible"):Connect(function()
			setLayerVisibility(layer)
		end)
		setLayerVisibility(layer)
	end))

	table.insert(self._connections, layer.ChildRemoved:Connect(function()
		task.defer(function()
			if layer.Parent then
				setLayerVisibility(layer)
			end
		end)
	end))

	setLayerVisibility(layer)

	self._blockerCount = 0
	self.Debug = opts.Debug
	self._initialized = true
end

-- Remove the overlay ScreenGui and every listener it owns (last window closed).
function Overlay:Teardown()
	if not self._initialized then
		return
	end
	for _, conn in ipairs(self._connections or {}) do
		conn:Disconnect()
	end
	self._connections = {}
	for _, bundle in pairs(self._displayOrderConnections or {}) do
		if bundle.orderChanged then
			bundle.orderChanged:Disconnect()
		end
		if bundle.ancestryChanged then
			bundle.ancestryChanged:Disconnect()
		end
	end
	self._displayOrderConnections = {}
	if self.Gui and self.Gui.Parent then
		self.Gui:Destroy()
	end
	self.Gui = nil
	self.Layer = nil
	self.Blocker = nil
	self._blockerCount = 0
	self._initialized = false
end

-- Rebuild after a Teardown() (a new window was created later)
function Overlay:Revive()
	if not self._initialized and self._opts then
		self:Initialize(self._opts)
	end
end

function Overlay:GetLayer()
	return self.Layer
end

function Overlay:GetBlocker()
	return self.Blocker
end

function Overlay:ShowBlocker(options)
	assert(self.Blocker, "[Overlay] Service not initialized")
	options = options or {}

	dprint("[OVERLAY] 🔷 ShowBlocker called with options:")
	dprint(string.format("  - Modal: %s", tostring(options.Modal)))
	dprint(string.format("  - ZIndex: %s", tostring(options.ZIndex)))
	dprint(string.format("  - Transparency: %s", tostring(options.Transparency)))

	self._blockerCount += 1

	local blocker = self.Blocker
	blocker.ZIndex = options.ZIndex or 100  -- Below overlay elements (200+)
	blocker.Visible = true
	blocker.Active = false  -- Allow click events to fire
	blocker.Modal = options.Modal ~= false
	local transparency = options.Transparency
	if transparency == nil then
		transparency = 1
	end
	blocker.BackgroundTransparency = transparency

	dprint(string.format("[OVERLAY] ✅ Blocker configured:"))
	dprint(string.format("  - Visible: %s", tostring(blocker.Visible)))
	dprint(string.format("  - Active: %s", tostring(blocker.Active)))
	dprint(string.format("  - Modal: %s", tostring(blocker.Modal)))
	dprint(string.format("  - ZIndex: %d", blocker.ZIndex))
	dprint(string.format("  - Transparency: %.2f", blocker.BackgroundTransparency))
	dprint(string.format("  - Blocker depth: %d", self._blockerCount))

	-- Make sure layer is visible
	if self.Layer then
		self.Layer.Visible = true
		dprint(string.format("[OVERLAY] Layer made visible"))
	end

	if self.Debug and self.Debug.IsEnabled and self.Debug:IsEnabled() then
		self.Debug.printf("[OVERLAY] ShowBlocker depth=%d alpha=%.2f zindex=%d", self._blockerCount, blocker.BackgroundTransparency, blocker.ZIndex)
	end

	return blocker
end

function Overlay:HideBlocker(force)
	if not self.Blocker then
		return -- torn down (all windows closed): nothing to hide
	end

	dprint(string.format("[OVERLAY] 🔶 HideBlocker called (force: %s, current depth: %d)", tostring(force), self._blockerCount))

	if force then
		self._blockerCount = 0
	else
		self._blockerCount = math.max(0, self._blockerCount - 1)
	end

	dprint(string.format("[OVERLAY] New blocker depth: %d", self._blockerCount))

	if self._blockerCount == 0 then
		local blocker = self.Blocker
		blocker.Active = false
		blocker.Modal = false
		blocker.Visible = false
		blocker.BackgroundTransparency = 1
		dprint("[OVERLAY] ✅ Blocker hidden (depth reached 0)")
	else
		dprint(string.format("[OVERLAY] ⚠️ Blocker still active (depth: %d)", self._blockerCount))
	end

	if self.Debug and self.Debug.IsEnabled and self.Debug:IsEnabled() then
		self.Debug.printf("[OVERLAY] HideBlocker depth=%d", self._blockerCount)
	end
end

function Overlay:Attach(instance)
	assert(self.Layer, "[Overlay] Service not initialized")
	instance.Parent = self.Layer
	setLayerVisibility(self.Layer)
	return instance
end

return Overlay
