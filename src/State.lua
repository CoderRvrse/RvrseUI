-- =========================
-- RvrseUI State Module
-- =========================
-- Handles global state management including locks and flags
-- Extracted from RvrseUI.lua (lines 57, 900-914, 1287-1288)

local State = {}

-- Global flag storage for all elements
State.Flags = {}

-- Lock system for master/child relationships
State.Locks = {
	_locks = {},
	_listeners = {}
}

-- Set lock state for a group
function State.Locks:SetLocked(group, isLocked)
	if not group then return end
	self._locks[group] = isLocked and true or false
	-- Trigger all lock listeners
	for _, fn in ipairs(self._listeners) do
		pcall(fn)
	end
end

-- Check if a group is locked
function State.Locks:IsLocked(group)
	return group and self._locks[group] == true
end

-- Register a lock change listener
function State.Locks:RegisterListener(callback)
	table.insert(self._listeners, callback)
end

-- Clear all listeners (useful for cleanup)
function State.Locks:ClearListeners()
	self._listeners = {}
end

-- Initialize method (called by init.lua)
function State:Initialize()
	-- State is ready to use, no initialization needed
	-- Flags and Locks are defined at module load time
end

return State
