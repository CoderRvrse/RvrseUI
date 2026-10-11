-- Paragraph Element Module
-- Part of RvrseUI v2.13.0 Modular Architecture
-- Extracted from RvrseUI.lua (lines 3560-3601)

local Paragraph = {}

function Paragraph.Create(o, dependencies)
	o = o or {}

	-- Extract dependencies
	local card = dependencies.card
	local pal3 = dependencies.pal3
	local RvrseUI = dependencies.RvrseUI
	local fitHeight = dependencies.fitHeight

	local text = o.Text or "Paragraph text"
	-- A first guess; with fitHeight the card then takes its text's real height.
	local lines = math.ceil(#text / 50)  -- Rough estimate
	local height = math.max(48, lines * 18 + 16)
	local f = card(height)

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 13
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextYAlignment = Enum.TextYAlignment.Top
	lbl.TextColor3 = pal3.TextSub
	lbl.Text = text
	lbl.TextWrapped = true
	if fitHeight then
		-- ✅ v4.5.2: the text fills the card's padded area and the card is as tall
		-- as the text really is, on any screen (the guess above cut it on phones).
		lbl.Size = UDim2.new(1, 0, 1, 0)
		lbl.Position = UDim2.new(0, 0, 0, 0)
		lbl.TextYAlignment = Enum.TextYAlignment.Center
	else
		lbl.Size = UDim2.new(1, -16, 1, -16)
		lbl.Position = UDim2.new(0, 8, 0, 8)
	end
	lbl.Parent = f
	if fitHeight then
		fitHeight(f, lbl, 48)
	end

	local paragraphAPI = {
		Set = function(_, txt)
			lbl.Text = txt
			if not fitHeight then
				local newLines = math.ceil(#txt / 50)
				local newHeight = math.max(48, newLines * 18 + 16)
				f.Size = UDim2.new(1, 0, 0, newHeight)
			end
		end,
		Get = function()
			return lbl.Text
		end,
		SetVisible = function(_, visible)
			f.Visible = visible
		end,
		CurrentValue = text
	}

	if o.Flag then
		RvrseUI.Flags[o.Flag] = paragraphAPI
	end

	return paragraphAPI
end

return Paragraph
