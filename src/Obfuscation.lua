-- =========================
-- RvrseUI Name Obfuscation Module
-- =========================
-- Generates random GUI element names on every launch to prevent:
-- 1. Static detection by name
-- 2. Copy-paste theft from Explorer
-- 3. Anti-cheat pattern matching
-- 4. Reverse engineering attempts
-- Extracted from RvrseUI.lua (lines 75-149)

local Obfuscation = {}

Obfuscation._seed = tick() * math.random(1, 999999)  -- Unique seed per session
Obfuscation._cache = {}  -- Cache generated names to avoid duplicates

-- Patterns for realistic-looking internal names
local namePatterns = {
	-- Looks like internal Roblox systems
	{"_", "Core", "System", "Module", "Service", "Handler", "Manager", "Controller"},
	{"UI", "GUI", "Frame", "Panel", "Widget", "Component", "Element"},
	{"Test", "Debug", "Dev", "Internal", "Util", "Helper", "Proxy"},
	{"Data", "Config", "State", "Cache", "Buffer", "Queue", "Stack"},
	-- Technical suffixes
	{"Ref", "Impl", "Inst", "Obj", "Node", "Item", "Entry"},
	-- Random chars/numbers for uniqueness
	{"A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "L", "M", "N", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"},
	{"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}
}

-- Helper: Get random word from pattern category
function Obfuscation:GetRandom(category)
	local words = namePatterns[category]
	self._seed = (self._seed * 9301 + 49297) % 233280
	local index = math.floor((self._seed / 233280) * #words) + 1
	return words[index]
end

-- Helper: Get random char
function Obfuscation:GetChar()
	return self:GetRandom(6)
end

-- Helper: Get random number
function Obfuscation:GetNum()
	return self:GetRandom(7)
end

-- Generate a random, realistic-looking internal name
function Obfuscation:Generate(hint)
	-- Update seed for randomness
	self._seed = (self._seed * 9301 + 49297) % 233280
	local rand = self._seed / 233280

	-- Pick random pattern
	local patterns = {
		function() return "_" .. self:GetRandom(1) .. self:GetRandom(7) .. self:GetRandom(5) end,  -- _CoreTest3Ref
		function() return self:GetRandom(2) .. "_" .. self:GetRandom(2) .. self:GetRandom(5) .. self:GetNum() end,  -- UI_GUIObj5
		function() return "_" .. self:GetRandom(3) .. self:GetRandom(2) .. self:GetNum() .. self:GetChar() end,  -- _DevUI3A
		function() return self:GetRandom(4) .. self:GetRandom(2) .. "_" .. self:GetNum() .. self:GetChar() end,  -- DataUI_7K
		function() return "_" .. self:GetChar() .. self:GetNum() .. self:GetRandom(2) .. self:GetRandom(3) end,  -- _M4UIInternal
	}

	local name
	local attempts = 0
	repeat
		local pattern = patterns[math.floor(rand * #patterns) + 1]
		name = pattern()
		attempts = attempts + 1
		-- Update rand for next attempt
		self._seed = (self._seed * 9301 + 49297) % 233280
		rand = self._seed / 233280
	until (not self._cache[name]) or attempts > 10

	self._cache[name] = true
	return name
end

-- Generate all required names for a session
function Obfuscation:GenerateSet()
	return {
		host = self:Generate("host"),
		notifyRoot = self:Generate("notify"),
		window = self:Generate("window"),
		chip = self:Generate("chip"),
		badge = self:Generate("badge"),
		customHost = self:Generate("custom")
	}
end

return Obfuscation
