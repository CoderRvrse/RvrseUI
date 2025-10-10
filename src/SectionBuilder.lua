-- =========================
-- RvrseUI SectionBuilder Module
-- =========================
-- Section builder that creates SectionAPI with element factory methods
-- Extracted from RvrseUI.lua (lines 2664-2803)
-- Part of RvrseUI v2.13.0 Modular Architecture

local SectionBuilder = {}

-- Creates a Section with all element creation methods
-- Dependencies required:
--   - Theme: Theme module
--   - UIHelpers: {corner, stroke, padding}
--   - Elements: {Button, Toggle, Dropdown, Keybind, Slider, Label, Paragraph, Divider, TextBox, ColorPicker}
--   - Animator: Animation module
--   - RvrseUI: Main RvrseUI instance (for _lockListeners, Flags, Store, _autoSave)
function SectionBuilder.CreateSection(sectionTitle, page, dependencies)
	local Theme = dependencies.Theme
	local helpers = dependencies.UIHelpers or {}
	local corner = helpers.corner or function(inst, radius)
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, radius or 12)
		c.Parent = inst
		return c
	end
	local stroke = helpers.stroke or function(inst, color, thickness)
		local s = Instance.new("UIStroke")
		s.Color = color or Color3.fromRGB(45, 45, 55)
		s.Thickness = thickness or 1
		s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		s.Parent = inst
		return s
	end
	local padding = helpers.padding or function(inst, inset)
		local pad = Instance.new("UIPadding")
		local offset = UDim.new(0, inset or 12)
		pad.PaddingTop = offset
		pad.PaddingBottom = offset
		pad.PaddingLeft = offset
		pad.PaddingRight = offset
		pad.Parent = inst
		return pad
	end
	local gradient = helpers.gradient or function() end
	local shadow = helpers.shadow or function() end
	local Elements = dependencies.Elements
	local RvrseUI = dependencies.RvrseUI
	local overlayLayer = dependencies.OverlayLayer

	local pal3 = Theme:Get()

	-- Section header
	local sectionHeader = Instance.new("Frame")
	sectionHeader.BackgroundTransparency = 1
	sectionHeader.Size = UDim2.new(1, 0, 0, 28)
	sectionHeader.Parent = page

	local sectionLabel = Instance.new("TextLabel")
	sectionLabel.BackgroundTransparency = 1
	sectionLabel.Size = UDim2.new(1, 0, 1, 0)
	sectionLabel.Font = Enum.Font.GothamBold
	sectionLabel.TextSize = 14
	sectionLabel.TextColor3 = pal3.TextMuted
	sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
	sectionLabel.Text = sectionTitle or "Section"
	sectionLabel.Parent = sectionHeader

	-- Section container
	local container = Instance.new("Frame")
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(1, 0, 0, 0)
	container.AutomaticSize = Enum.AutomaticSize.Y
	container.Parent = page

	local containerLayout = Instance.new("UIListLayout")
	containerLayout.Padding = UDim.new(0, 8)
	containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
	containerLayout.Parent = container

	-- Card factory function (creates base card for elements)
	local function card(height)
		local c = Instance.new("Frame")
		c.BackgroundColor3 = pal3.Elevated
		c.BackgroundTransparency = 0.3
		c.BorderSizePixel = 0
		c.Size = UDim2.new(1, 0, 0, height)
		c.Parent = container
		corner(c, 10)
		stroke(c, pal3.Border, 1)
		padding(c, 12)
		return c
	end

	local SectionAPI = {}

	-- Prepare element dependencies
	local function getElementDeps()
		return {
			card = card,
			corner = corner,
			stroke = stroke,
			padding = padding,
			pal3 = pal3,
			Theme = Theme,
			Animator = dependencies.Animator,
			RvrseUI = RvrseUI,
			UIS = dependencies.UIS,
			gradient = gradient,
			shadow = shadow,
			OverlayLayer = overlayLayer
		}
	end

	-- Element factory methods (delegate to Element modules)
	function SectionAPI:CreateButton(o)
		return Elements.Button.Create(o, getElementDeps())
	end

	function SectionAPI:CreateToggle(o)
		return Elements.Toggle.Create(o, getElementDeps())
	end

	function SectionAPI:CreateDropdown(o)
		return Elements.Dropdown.Create(o, getElementDeps())
	end

	function SectionAPI:CreateKeybind(o)
		return Elements.Keybind.Create(o, getElementDeps())
	end

	function SectionAPI:CreateSlider(o)
		return Elements.Slider.Create(o, getElementDeps())
	end

	function SectionAPI:CreateLabel(o)
		return Elements.Label.Create(o, getElementDeps())
	end

	function SectionAPI:CreateParagraph(o)
		return Elements.Paragraph.Create(o, getElementDeps())
	end

	function SectionAPI:CreateDivider(o)
		return Elements.Divider.Create(o, getElementDeps())
	end

	function SectionAPI:CreateTextBox(o)
		return Elements.TextBox.Create(o, getElementDeps())
	end

	function SectionAPI:CreateColorPicker(o)
		return Elements.ColorPicker.Create(o, getElementDeps())
	end

	-- Section utility methods
	function SectionAPI:Update(newTitle)
		sectionLabel.Text = newTitle or sectionTitle
	end

	function SectionAPI:SetVisible(visible)
		sectionHeader.Visible = visible
		container.Visible = visible
	end

	return SectionAPI
end

-- Initialize method (called by init.lua)
function SectionBuilder:Initialize(deps)
	-- SectionBuilder is ready to use
	-- Dependencies are passed when CreateSection is called
	-- No initialization state needed
end

return SectionBuilder
