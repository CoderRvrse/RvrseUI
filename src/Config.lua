-- ============================================
-- CONFIGURATION MODULE
-- ============================================
-- Handles save/load system for RvrseUI
-- Supports file-based persistence with folder structure
-- Integrates with State (Flags) and Theme modules
-- ============================================

local Config = {}

-- Module dependencies (injected on initialization)
local State = nil
local Theme = nil
local dprintf = nil

-- Services
local HttpService = game:GetService("HttpService")

-- ============================================
-- MODULE PROPERTIES
-- ============================================

Config.ConfigurationSaving = false  -- Enabled via CreateWindow
Config.ConfigurationFileName = nil  -- Set via CreateWindow
Config.ConfigurationFolderName = nil  -- Optional folder name
Config._configCache = {}  -- In-memory config cache
Config._lastSaveTime = nil  -- Debounce timestamp

-- ============================================
-- INITIALIZATION
-- ============================================

function Config:Init(dependencies)
	State = dependencies.State
	Theme = dependencies.Theme
	dprintf = dependencies.dprintf or function() end
	return self
end

-- ============================================
-- SAVE CONFIGURATION
-- ============================================

function Config:SaveConfiguration()
	if not self.ConfigurationSaving or not self.ConfigurationFileName then
		return false, "Configuration saving not enabled"
	end

	local config = {}

	-- Save all flagged elements
	for flagName, element in pairs(State.Flags) do
		if element.Get then
			local success, value = pcall(element.Get, element)
			if success then
				config[flagName] = value
			end
		end
	end

	-- Save current theme (only if dirty - user changed it)
	dprintf("=== THEME SAVE DEBUG ===")
	dprintf("Theme exists?", Theme ~= nil)
	if Theme then
		dprintf("Theme.Current:", Theme.Current)
		dprintf("Theme._dirty:", Theme._dirty)
	end

	if Theme and Theme.Current and Theme._dirty then
		config._RvrseUI_Theme = Theme.Current
		dprintf("✅ Saved theme to config (dirty):", config._RvrseUI_Theme)
		Theme._dirty = false  -- Clear dirty flag after save
	else
		dprintf("Theme not saved (not dirty or unavailable)")
		-- Preserve existing saved theme if it exists
		if self._configCache and self._configCache._RvrseUI_Theme then
			config._RvrseUI_Theme = self._configCache._RvrseUI_Theme
			dprintf("Preserving existing saved theme:", config._RvrseUI_Theme)
		end
	end

	-- Cache configuration
	self._configCache = config
	local configKeys = {}
	for k in pairs(config) do table.insert(configKeys, k) end
	dprintf("Config keys being saved:", table.concat(configKeys, ", "))

	-- Build full file path with optional folder
	local fullPath = self.ConfigurationFileName
	if self.ConfigurationFolderName then
		-- Create folder if it doesn't exist
		pcall(function()
			if not isfolder(self.ConfigurationFolderName) then
				makefolder(self.ConfigurationFolderName)
			end
		end)
		fullPath = self.ConfigurationFolderName .. "/" .. self.ConfigurationFileName
	end

	-- GPT-5 VERIFICATION: Print save path, key, and instance
	dprintf("🔍 SAVE VERIFICATION")
	dprintf("SAVE PATH:", fullPath)
	dprintf("SAVE KEY: _RvrseUI_Theme =", config._RvrseUI_Theme or "nil")
	dprintf("CONFIG INSTANCE:", tostring(self))

	-- Save to datastore using writefile
	local success, err = pcall(function()
		local jsonData = HttpService:JSONEncode(config)
		writefile(fullPath, jsonData)
	end)

	if success then
		-- GPT-5 VERIFICATION: Readback after save to confirm it landed
		local readbackSuccess, readbackData = pcall(function()
			return HttpService:JSONDecode(readfile(fullPath))
		end)
		if readbackSuccess and readbackData then
			dprintf("READBACK AFTER SAVE: _RvrseUI_Theme =", readbackData._RvrseUI_Theme or "nil")
			if readbackData._RvrseUI_Theme ~= config._RvrseUI_Theme then
				warn("⚠️ READBACK MISMATCH! Expected:", config._RvrseUI_Theme, "Got:", readbackData._RvrseUI_Theme)
			end
		end

		-- Save this as the last used config
		self:SaveLastConfig(fullPath, config._RvrseUI_Theme or "Dark")

		dprintf("Configuration saved:", self.ConfigurationFileName)
		return true, "Configuration saved successfully"
	else
		warn("[RvrseUI] Failed to save configuration:", err)
		return false, err
	end
end

-- ============================================
-- LOAD CONFIGURATION
-- ============================================

function Config:LoadConfiguration()
	if not self.ConfigurationSaving or not self.ConfigurationFileName then
		return false, "Configuration saving not enabled"
	end

	-- Build full file path with optional folder
	local fullPath = self.ConfigurationFileName
	if self.ConfigurationFolderName then
		fullPath = self.ConfigurationFolderName .. "/" .. self.ConfigurationFileName
	end

	-- GPT-5 VERIFICATION: Print load path and instance FIRST
	dprintf("🔍 LOAD VERIFICATION")
	dprintf("LOAD PATH:", fullPath)
	dprintf("CONFIG INSTANCE:", tostring(self))

	local success, result = pcall(function()
		if not isfile(fullPath) then
			return nil, "No saved configuration found"
		end

		local jsonData = readfile(fullPath)
		return HttpService:JSONDecode(jsonData)
	end)

	if not success or not result then
		dprintf("No configuration to load or error:", result)
		dprintf("VALUE AT LOAD: nil (no file)")
		return false, result
	end

	-- GPT-5 VERIFICATION: Print the actual value loaded from disk
	dprintf("VALUE AT LOAD: _RvrseUI_Theme =", result._RvrseUI_Theme or "nil")

	-- Apply configuration to all flagged elements
	dprintf("=== THEME LOAD DEBUG ===")
	dprintf("Config loaded, checking for _RvrseUI_Theme...")

	local loadedCount = 0
	for flagName, value in pairs(result) do
		-- Skip internal RvrseUI settings (start with _RvrseUI_)
		if flagName:sub(1, 9) == "_RvrseUI_" then
			dprintf("Found internal setting:", flagName, "=", value)
			-- Handle theme loading
			if flagName == "_RvrseUI_Theme" and (value == "Dark" or value == "Light") then
				-- Store theme to apply when window is created
				State._savedTheme = value
				dprintf("✅ Saved theme found and stored:", value)
				dprintf("State._savedTheme is now:", State._savedTheme)
			end
		elseif State.Flags[flagName] and State.Flags[flagName].Set then
			local setSuccess = pcall(State.Flags[flagName].Set, State.Flags[flagName], value)
			if setSuccess then
				loadedCount = loadedCount + 1
			end
		end
	end

	self._configCache = result
	dprintf(string.format("Configuration loaded: %d elements restored", loadedCount))

	return true, string.format("Loaded %d elements", loadedCount)
end

-- ============================================
-- AUTO-SAVE HELPER
-- ============================================

function Config:_autoSave()
	if self.ConfigurationSaving then
		-- Debounce saves (max once per second)
		if not self._lastSaveTime or (tick() - self._lastSaveTime) > 1 then
			self._lastSaveTime = tick()
			task.spawn(function()
				self:SaveConfiguration()
			end)
		end
	end
end

-- ============================================
-- DELETE CONFIGURATION
-- ============================================

function Config:DeleteConfiguration()
	if not self.ConfigurationFileName then
		return false, "No configuration file specified"
	end

	-- Build full file path with optional folder
	local fullPath = self.ConfigurationFileName
	if self.ConfigurationFolderName then
		fullPath = self.ConfigurationFolderName .. "/" .. self.ConfigurationFileName
	end

	local success, err = pcall(function()
		if isfile(fullPath) then
			delfile(fullPath)
		end
	end)

	if success then
		self._configCache = {}
		return true, "Configuration deleted"
	else
		return false, err
	end
end

-- ============================================
-- CONFIGURATION EXISTS CHECK
-- ============================================

function Config:ConfigurationExists()
	if not self.ConfigurationFileName then
		return false
	end

	-- Build full file path with optional folder
	local fullPath = self.ConfigurationFileName
	if self.ConfigurationFolderName then
		fullPath = self.ConfigurationFolderName .. "/" .. self.ConfigurationFileName
	end

	local success, result = pcall(function()
		return isfile(fullPath)
	end)

	return success and result
end

-- ============================================
-- GET LAST CONFIG
-- ============================================

function Config:GetLastConfig()
	local lastConfigPath = "RvrseUI/_last_config.json"

	local success, data = pcall(function()
		if not isfile(lastConfigPath) then
			return nil
		end
		local jsonData = readfile(lastConfigPath)
		return HttpService:JSONDecode(jsonData)
	end)

	if success and data then
		dprintf("📂 Last config found:", data.lastConfig, "Theme:", data.lastTheme)
		return data.lastConfig, data.lastTheme
	end

	dprintf("📂 No last config found")
	return nil, nil
end

-- ============================================
-- SAVE LAST CONFIG REFERENCE
-- ============================================

function Config:SaveLastConfig(configName, theme)
	local lastConfigPath = "RvrseUI/_last_config.json"

	-- Ensure RvrseUI folder exists
	pcall(function()
		if not isfolder("RvrseUI") then
			makefolder("RvrseUI")
		end
	end)

	local success, err = pcall(function()
		local data = {
			lastConfig = configName,
			lastTheme = theme,
			timestamp = os.time()
		}
		writefile(lastConfigPath, HttpService:JSONEncode(data))
	end)

	if success then
		dprintf("📂 Saved last config reference:", configName, "Theme:", theme)
	else
		warn("[RvrseUI] Failed to save last config:", err)
	end

	return success
end

-- ============================================
-- LOAD CONFIGURATION BY NAME
-- ============================================

function Config:LoadConfigByName(configName)
	if not configName or configName == "" then
		return false, "Config name required"
	end

	-- Temporarily set the config file name
	local originalFileName = self.ConfigurationFileName
	local originalFolderName = self.ConfigurationFolderName

	self.ConfigurationFileName = configName .. ".json"
	self.ConfigurationFolderName = "RvrseUI/Configs"

	local success, message = self:LoadConfiguration()

	-- Restore original config names
	self.ConfigurationFileName = originalFileName
	self.ConfigurationFolderName = originalFolderName

	return success, message
end

-- ============================================
-- SAVE CONFIGURATION AS
-- ============================================

function Config:SaveConfigAs(configName)
	if not configName or configName == "" then
		return false, "Config name required"
	end

	-- Temporarily set the config file name
	local originalFileName = self.ConfigurationFileName
	local originalFolderName = self.ConfigurationFolderName

	self.ConfigurationFileName = configName .. ".json"
	self.ConfigurationFolderName = "RvrseUI/Configs"

	local success, message = self:SaveConfiguration()

	if success then
		-- Save this as the last used config
		self:SaveLastConfig(
			self.ConfigurationFolderName .. "/" .. self.ConfigurationFileName,
			Theme and Theme.Current or "Dark"
		)
	end

	-- Restore original config names
	self.ConfigurationFileName = originalFileName
	self.ConfigurationFolderName = originalFolderName

	return success, message
end

return Config
