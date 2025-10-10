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

function Debug.printf(fmt, ...)
	if not Debug.Enabled then
		return
	end

	if type(fmt) == "string" and select("#", ...) > 0 then
		local ok, message = pcall(string.format, fmt, ...)
		if ok then
			Debug:Print(message)
			return
		end
	end

	Debug:Print(fmt, ...)
end

return Debug
