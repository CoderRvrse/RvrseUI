-- =========================
-- RvrseUI Debug Module
-- =========================
-- Handles debug logging with conditional output
-- Extracted from RvrseUI.lua (lines 17, 60-64)

local Debug = {}

Debug.Enabled = false  -- Global debug toggle (disabled by default for production)
Debug.enabled = Debug.Enabled  -- Back-compat alias for legacy references

function Debug:SetEnabled(state)
	local flag = state and true or false
	self.Enabled = flag
	self.enabled = flag
end

function Debug:IsEnabled()
	return self.Enabled and true or false
end

-- Debug print helper (only prints when Enabled = true)
function Debug:Print(...)
	if self:IsEnabled() then
		print("[RvrseUI]", ...)
	end
end

-- Alias for convenience
Debug.Log = Debug.Print

function Debug.printf(fmt, ...)
	if not Debug:IsEnabled() then
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
