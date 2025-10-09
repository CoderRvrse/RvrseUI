-- =========================
-- RvrseUI Version Module
-- =========================
-- Handles version metadata and version comparison
-- Extracted from RvrseUI.lua (lines 22-54)

local Version = {}

Version.Data = {
	Major = 3,
	Minor = 0,
	Patch = 2,
	Build = "20251010B",  -- YYYYMMDD format with hotfix suffix
	Full = "3.0.2",
	Hash = "Z4X7C2V1",  -- Release hash for integrity verification
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
