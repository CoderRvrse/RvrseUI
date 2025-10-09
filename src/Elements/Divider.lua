-- Divider Element Module
-- Part of RvrseUI v2.13.0 Modular Architecture
-- Extracted from RvrseUI.lua (lines 3604-3624)

local Divider = {}

function Divider.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local pal3 = dependencies.pal3

	local f = card(12)
	f.BackgroundTransparency = 1

	local line = Instance.new("Frame")
	line.Size = UDim2.new(1, -16, 0, 1)
	line.Position = UDim2.new(0, 8, 0.5, 0)
	line.BackgroundColor3 = pal3.Divider
	line.BorderSizePixel = 0
	line.Parent = f

	return {
		SetColor = function(_, color)
			line.BackgroundColor3 = color
		end,
		SetVisible = function(_, visible)
			f.Visible = visible
		end
	}
end

return Divider
