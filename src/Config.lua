-- ============================================
-- CONFIGURATION MODULE
-- ============================================
-- Handles save/load system for RvrseUI
-- Supports file-based persistence with folder structure
-- Integrates with State (Flags) and Theme modules
-- ⚠️ Maintainers: The save/load pipeline is tightly coupled to
--    the live RvrseUI context. Do not refactor these functions
--    without replicating the v3.0.3 behaviour (context hand-off,
--    theme cache preservation, last-profile parsing).
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
Config._lastContext = nil  -- Most recent RvrseUI instance used for persistence
Config.AutoSaveEnabled = true  -- Auto-save flag (can be disabled via configuration)

-- ============================================
-- EXECUTOR FILE-SYSTEM PROBE
-- ============================================

local FileApi = {
	readfile = type(readfile) == "function" and readfile or nil,
	writefile = type(writefile) == "function" and writefile or nil,
	isfile = type(isfile) == "function" and isfile or nil,
	isfolder = type(isfolder) == "function" and isfolder or nil,
	makefolder = type(makefolder) == "function" and makefolder or nil,
	delfile = type(delfile) == "function" and delfile or nil,
	listfiles = type(listfiles) == "function" and listfiles or nil
}

local function fsCall(name, ...)
	local fn = FileApi[name]
	if not fn then
		return false, string.format("%s unavailable in this executor", name)
	end

	local ok, result = pcall(fn, ...)
	if not ok then
		return false, result
	end
	return true, result
end

local function fsSupports(name)
	return FileApi[name] ~= nil
end

local function traceFsSupport(tag)
	if not dprintf then
		return
	end

	dprintf(string.format(
		"[FS] %s support | readfile:%s writefile:%s isfile:%s isfolder:%s makefolder:%s",
		tag,
		fsSupports("readfile") and "✅" or "⛔",
		fsSupports("writefile") and "✅" or "⛔",
		fsSupports("isfile") and "✅" or "⛔",
		fsSupports("isfolder") and "✅" or "⛔",
		fsSupports("makefolder") and "✅" or "⛔"
	))
end

-- ============================================
-- INITIALIZATION
-- ============================================

function Config:Init(dependencies)
	State = dependencies.State
	Theme = dependencies.Theme
	dprintf = dependencies.dprintf or function() end
	self._lastContext = nil
	self.AutoSaveEnabled = true

	traceFsSupport("Init")

	return self
end

-- ============================================
-- SAVE CONFIGURATION
-- ============================================

function Config:SaveConfiguration(context)
	if context ~= nil then
		self._lastContext = context
	elseif self._lastContext then
		context = self._lastContext
	end

	if not self.ConfigurationSaving or not self.ConfigurationFileName then
		return false, "Configuration saving not enabled"
	end

	if not (fsSupports("writefile") and fsSupports("readfile")) then
		if dprintf then
			dprintf("[FS] Save aborted - writefile/readfile unavailable")
		end
		return false, "Executor does not expose writefile/readfile"
	end

	local config = {}

	local flagSource = {}
	if context and context.Flags then
		flagSource = context.Flags
	elseif State and State.Flags then
		flagSource = State.Flags
	end

	for flagName, element in pairs(flagSource) do
		if element.Get then
			local success, value = pcall(element.Get, element)
			if success then
				config[flagName] = value
			end
		end
	end

	dprintf("=== THEME SAVE DEBUG ===")
	dprintf("Theme exists?", Theme ~= nil)
	if Theme then
		dprintf("Theme.Current:", Theme.Current)
		dprintf("Theme._dirty:", Theme._dirty)
	end

	if Theme and Theme.Current and Theme._dirty then
		config._RvrseUI_Theme = Theme.Current
		dprintf("✅ Saved theme to config (dirty):", config._RvrseUI_Theme)
		Theme._dirty = false
	else
		dprintf("Theme not saved (not dirty or unavailable)")
		if self._configCache and self._configCache._RvrseUI_Theme then
			config._RvrseUI_Theme = self._configCache._RvrseUI_Theme
			dprintf("Preserving existing saved theme:", config._RvrseUI_Theme)
		end
	end

	self._configCache = config
	local configKeys = {}
	for k in pairs(config) do table.insert(configKeys, k) end
	dprintf("Config keys being saved:", table.concat(configKeys, ", "))

	local fullPath = self.ConfigurationFileName
	if self.ConfigurationFolderName then
		if fsSupports("isfolder") then
			local existsOk, existsOrErr = fsCall("isfolder", self.ConfigurationFolderName)
			if existsOk then
				if not existsOrErr and fsSupports("makefolder") then
					local createOk, createErr = fsCall("makefolder", self.ConfigurationFolderName)
					if not createOk and dprintf then
						dprintf("[FS] makefolder failed:", createErr)
					end
				end
			elseif dprintf then
				dprintf("[FS] isfolder failed:", existsOrErr)
			end
		elseif dprintf then
			dprintf("[FS] isfolder unavailable - skipping folder creation probe")
		end
		fullPath = self.ConfigurationFolderName .. "/" .. self.ConfigurationFileName
	end

	dprintf("?? SAVE VERIFICATION")
	dprintf("SAVE PATH:", fullPath)
	dprintf("SAVE KEY: _RvrseUI_Theme =", config._RvrseUI_Theme or "nil")
	dprintf("CONFIG INSTANCE:", tostring(self))

	local success, err = pcall(function()
		local jsonData = HttpService:JSONEncode(config)
		FileApi.writefile(fullPath, jsonData)
	end)

	if success then
		if fsSupports("readfile") then
			local readOk, rawOrErr = fsCall("readfile", fullPath)
			if readOk and rawOrErr then
				local decodeOk, readbackData = pcall(HttpService.JSONDecode, HttpService, rawOrErr)
				if decodeOk and typeof(readbackData) == "table" then
					dprintf("READBACK AFTER SAVE: _RvrseUI_Theme =", readbackData._RvrseUI_Theme or "nil")
					if readbackData._RvrseUI_Theme ~= config._RvrseUI_Theme then
						warn("?? READBACK MISMATCH! Expected:", config._RvrseUI_Theme, "Got:", readbackData._RvrseUI_Theme)
					end
				elseif dprintf then
					dprintf("[FS] Readback decode failed:", readbackData)
				end
			elseif dprintf then
				dprintf("[FS] Readback skipped:", rawOrErr)
			end
		elseif dprintf then
			dprintf("[FS] Readback skipped - readfile unavailable")
		end

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

function Config:LoadConfiguration(context)
	if context ~= nil then
		self._lastContext = context
	elseif self._lastContext then
		context = self._lastContext
	end

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

	if not fsSupports("readfile") then
		if dprintf then
			dprintf("[FS] Load aborted - readfile unavailable")
		end
		return false, "Executor does not expose readfile"
	end

	if fsSupports("isfile") then
		local existsOk, existsOrErr = fsCall("isfile", fullPath)
		if not existsOk then
			dprintf("File existence check failed:", existsOrErr)
			return false, existsOrErr
		end
		if not existsOrErr then
			dprintf("No configuration to load or error:", existsOrErr)
			dprintf("VALUE AT LOAD: nil (no file)")
			return false, "No saved configuration found"
		end
	end

	local readOk, rawOrErr = fsCall("readfile", fullPath)
	if not readOk then
		dprintf("Read failed:", rawOrErr)
		return false, rawOrErr
	end

	local decodeOk, result = pcall(HttpService.JSONDecode, HttpService, rawOrErr)
	if not decodeOk then
		dprintf("JSON decode failed:", result)
		return false, result
	end

	-- GPT-5 VERIFICATION: Print the actual value loaded from disk
	dprintf("VALUE AT LOAD: _RvrseUI_Theme =", result._RvrseUI_Theme or "nil")

	-- Apply configuration to all flagged elements
	dprintf("=== THEME LOAD DEBUG ===")
	dprintf("Config loaded, checking for _RvrseUI_Theme...")

	local loadedCount = 0
	local flagSource = {}
	if context and context.Flags then
		flagSource = context.Flags
	elseif State and State.Flags then
		flagSource = State.Flags
	end

	for flagName, value in pairs(result) do
		-- Skip internal RvrseUI settings (start with _RvrseUI_)
		if flagName:sub(1, 9) == "_RvrseUI_" then
			dprintf("Found internal setting:", flagName, "=", value)
			-- Handle theme loading
			if flagName == "_RvrseUI_Theme" and (value == "Dark" or value == "Light") then
				-- Store theme to apply when window is created
				if context then
					context._savedTheme = value
					dprintf("✅ Saved theme found and stored:", value)
					dprintf("context._savedTheme is now:", context._savedTheme)
				else
					State._savedTheme = value
					dprintf("✅ Saved theme stored on State:", value)
					dprintf("State._savedTheme is now:", State._savedTheme)
				end
			end
		elseif flagSource[flagName] and flagSource[flagName].Set then
			local setSuccess = pcall(flagSource[flagName].Set, flagSource[flagName], value)
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
	if self.ConfigurationSaving and self.AutoSaveEnabled then
		-- Debounce saves (max once per second)
		if not self._lastSaveTime or (tick() - self._lastSaveTime) > 1 then
			self._lastSaveTime = tick()
			task.spawn(function()
				self:SaveConfiguration(self._lastContext)
			end)
		end
	end
end

function Config:SetAutoSave(enabled)
	self.AutoSaveEnabled = enabled ~= false
	return self.AutoSaveEnabled
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
	if not (fsSupports("isfile") and fsSupports("delfile")) then
		return false, "Executor does not expose isfile/delfile"
	end

	local existsOk, existsOrErr = fsCall("isfile", fullPath)
	if not existsOk then
		return false, existsOrErr
	end
	if not existsOrErr then
		return false, "Configuration file not found"
	end

	local deleteOk, deleteErr = fsCall("delfile", fullPath)
	if deleteOk then
		self._configCache = {}
		return true, "Configuration deleted"
	else
		return false, deleteErr
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

	if not fsSupports("isfile") then
		return false
	end

	local existsOk, existsOrErr = fsCall("isfile", fullPath)
	return existsOk and existsOrErr or false
end

-- ============================================
-- GET LAST CONFIG
-- ============================================

function Config:GetLastConfig()
	local lastConfigPath = "RvrseUI/_last_config.json"

	if not (fsSupports("isfile") and fsSupports("readfile")) then
		dprintf("[FS] Last config probe skipped - filesystem unavailable")
		return nil, nil
	end

	local existsOk, existsOrErr = fsCall("isfile", lastConfigPath)
	if not existsOk then
		dprintf("Last config isfile failed:", existsOrErr)
		return nil, nil
	end
	if not existsOrErr then
		dprintf("📂 No last config found")
		return nil, nil
	end

	local readOk, rawOrErr = fsCall("readfile", lastConfigPath)
	if not readOk then
		dprintf("Last config read failed:", rawOrErr)
		return nil, nil
	end

	local decodeOk, data = pcall(HttpService.JSONDecode, HttpService, rawOrErr)
	if decodeOk and data then
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

	if fsSupports("isfolder") and fsSupports("makefolder") then
		local existsOk, existsOrErr = fsCall("isfolder", "RvrseUI")
		if existsOk and not existsOrErr then
			fsCall("makefolder", "RvrseUI")
		elseif not existsOk and dprintf then
			dprintf("[FS] isfolder('RvrseUI') failed:", existsOrErr)
		end
	elseif dprintf then
		dprintf("[FS] Skipping folder ensure - isfolder/makefolder unavailable")
	end

	if not fsSupports("writefile") then
		return false
	end

	local data = {
		lastConfig = configName,
		lastTheme = theme,
		timestamp = os.time()
	}

	local writeOk, writeErr = fsCall("writefile", lastConfigPath, HttpService:JSONEncode(data))

	if writeOk then
		dprintf("📂 Saved last config reference:", configName, "Theme:", theme)
	else
		warn("[RvrseUI] Failed to save last config:", writeErr)
	end

	return writeOk
end

-- ============================================
-- LOAD CONFIGURATION BY NAME
-- ============================================

function Config:LoadConfigByName(configName, context)
	if not configName or configName == "" then
		return false, "Config name required"
	end

	-- Temporarily set the config file name
	local originalFileName = self.ConfigurationFileName
	local originalFolderName = self.ConfigurationFolderName

	self.ConfigurationFileName = configName .. ".json"
	self.ConfigurationFolderName = "RvrseUI/Configs"

	local success, message = self:LoadConfiguration(context or self._lastContext)

	-- Restore original config names
	self.ConfigurationFileName = originalFileName
	self.ConfigurationFolderName = originalFolderName

	return success, message
end

-- ============================================
-- SAVE CONFIGURATION AS
-- ============================================

function Config:SaveConfigAs(configName, context)
	if not configName or configName == "" then
		return false, "Config name required"
	end

	-- Temporarily set the config file name
	local originalFileName = self.ConfigurationFileName
	local originalFolderName = self.ConfigurationFolderName

	self.ConfigurationFileName = configName .. ".json"
	self.ConfigurationFolderName = "RvrseUI/Configs"

	local success, message = self:SaveConfiguration(context or self._lastContext)

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

