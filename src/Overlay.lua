-- =========================
-- Overlay Service Module
-- =========================
-- Manages a dedicated ScreenGui for popovers, dropdown blockers,
-- and modal dimming. Ensures a single overlay host is reused and
-- exposes helpers to show/hide the global blocker.

local Overlay = {}
Overlay._initialized = false

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

	local popovers = playerGui:FindFirstChild("RvrseUI_Popovers")
	if not popovers then
		popovers = Instance.new("ScreenGui")
		popovers.Name = "RvrseUI_Popovers"
		popovers.ResetOnSpawn = false
		popovers.IgnoreGuiInset = true
		popovers.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		popovers.DisplayOrder = opts.DisplayOrder or 110
		popovers.Parent = playerGui
	end
	self.Gui = popovers

	local blocker = popovers:FindFirstChild("OverlayBlocker")
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
		blocker.ZIndex = 900
		blocker.Visible = false
		blocker.Modal = false
		blocker.Parent = popovers
	end
	self.Blocker = blocker

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
		layer.ZIndex = 950
		layer.Visible = false
		layer.Parent = popovers
	end
	self.Layer = layer

	layer.ChildAdded:Connect(function(child)
		child:GetPropertyChangedSignal("Visible"):Connect(function()
			setLayerVisibility(layer)
		end)
		setLayerVisibility(layer)
	end)

	layer.ChildRemoved:Connect(function()
		task.defer(function()
			setLayerVisibility(layer)
		end)
	end)

	setLayerVisibility(layer)

	self._blockerCount = 0
	self.Debug = opts.Debug
	self._initialized = true
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

	self._blockerCount += 1

	local blocker = self.Blocker
	blocker.ZIndex = options.ZIndex or 900
	blocker.Visible = true
	blocker.Active = true
	blocker.Modal = options.Modal ~= false
	local transparency = options.Transparency
	if transparency == nil then
		transparency = 1
	end
	blocker.BackgroundTransparency = transparency

	if self.Debug and self.Debug.IsEnabled and self.Debug:IsEnabled() then
		self.Debug.printf("[OVERLAY] ShowBlocker depth=%d alpha=%.2f", self._blockerCount, blocker.BackgroundTransparency)
	end

	return blocker
end

function Overlay:HideBlocker(force)
	assert(self.Blocker, "[Overlay] Service not initialized")

	if force then
		self._blockerCount = 0
	else
		self._blockerCount = math.max(0, self._blockerCount - 1)
	end

	if self._blockerCount == 0 then
		local blocker = self.Blocker
		blocker.Active = false
		blocker.Modal = false
		blocker.Visible = false
		blocker.BackgroundTransparency = 1
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
