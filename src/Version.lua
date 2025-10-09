-- =========================
-- RvrseUI Version Module
-- =========================
-- Handles version metadata and version comparison
-- Extracted from RvrseUI.lua (lines 22-54)

local Version = {}

Version.Data = {
	Major = 2,
	Minor = 13,
	Patch = 0,
	Build = "20251002",  -- YYYYMMDD format
	Full = "2.13.0",
	Hash = "D8Y2K5M3",  -- Release hash for integrity verification
	Channel = "Stable"   -- Stable, Beta, Dev
}

function Version:GetString()
	return string.format("v%s (%s)", self.Data.Full, self.Data.Build)
end

function Version:GetInfo()
	return {
		Version = self.Data.Full,
		Build = self.Data.Build,
		Hash = self.Data.Hash,
		Channel = self.Data.Channel,
		IsLatest = true  -- Will be checked against GitHub API in future
	}
end

function Version:Check(onlineVersion)
	-- Compare version with online version (for future update checker)
	if not onlineVersion then return "unknown" end
	local current = (self.Data.Major * 10000) + (self.Data.Minor * 100) + self.Data.Patch
	local online = (onlineVersion.Major * 10000) + (onlineVersion.Minor * 100) + onlineVersion.Patch
	if current < online then return "outdated"
	elseif current > online then return "ahead"
	else return "latest" end
end

return Version
