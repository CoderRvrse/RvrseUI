-- =========================
-- RvrseUI Debug Module
-- =========================
-- Handles debug logging with conditional output
-- Extracted from RvrseUI.lua (lines 17, 60-64)

local Debug = {}

Debug.Enabled = true  -- Global debug toggle

-- Debug print helper (only prints when Enabled = true)
function Debug:Print(...)
	if self.Enabled then
		print("[RvrseUI]", ...)
	end
end

-- Alias for convenience
Debug.Log = Debug.Print

return Debug
