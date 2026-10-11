-- =========================
-- Layers Module
-- =========================
-- Keeps RvrseUI above the game's screens and usable in any game.
--
-- WHERE (default): PlayerGui, at the three largest DisplayOrders. Only a game
-- screen that itself uses one of those can still cover RvrseUI. PlayerGui stays
-- the default because hubs already out there look for RvrseUI's window in it
-- (the X button, to hook their own shutdown): moving it would silently stop
-- those hubs cleaning up on close.
--
-- WHERE (CreateWindow{ AlwaysOnTop = true }): the executor's hidden folder
-- (gethui), else CoreGui. A screen there sits ABOVE every PlayerGui screen
-- whatever DisplayOrder the game uses (Studio, 2026-10-11: a CoreGui screen at
-- order 0 took the click over a PlayerGui screen at 2147483647), and the game's
-- own scripts can't see it. A hub that asks for this must use Window:OnClose
-- for its shutdown, not a search of PlayerGui. Roblox's own Esc menu lives in
-- CoreGui at order 0, under RvrseUI then: while it is open RvrseUI's screens
-- step aside so Leave / Settings stay clickable.
--
-- MOUSE: while a window is on screen an invisible Modal button frees the mouse.
-- The engine unlocks first-person / LockCenter games by itself and locks again
-- when the window goes; the game's own MouseBehavior is never written (writing
-- it back on every change leaves it locked at the end of each render step).
-- Only on a device with a mouse: a touch screen is left exactly as it was.
--
-- POINTER: first-person games hide the pointer (MouseIconEnabled = false).
-- While a window is on screen RvrseUI then draws Roblox's own arrow at the mouse.
--
-- 2147483647 is the largest DisplayOrder; one more wraps round to the very
-- bottom (Studio-proven), so raised orders go through Layers.order().

local Layers = {}

Layers.TOP = 2147483647
Layers.HOST = Layers.TOP - 2 -- windows + notifications
Layers.OVERLAY = Layers.TOP - 1 -- dropdown lists, colour panels: above the windows
Layers.CURSOR = Layers.TOP -- RvrseUI's own pointer: above everything
Layers.CURSOR_IMAGE = "rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png"
Layers.CURSOR_SIZE = 64 -- Roblox's arrow image; its tip is the image centre

local UIS, RunService, GuiService, PlayerGui, CoreGui, Debug

local chosenParent = nil -- nil = PlayerGui (the default)
local mounted = setmetatable({}, { __mode = "k" }) -- our ScreenGuis (moved together, hidden together)
local menuHidden = setmetatable({}, { __mode = "k" }) -- gui -> Enabled it had when the menu opened
local menuOpen = false
local menuConnections = {}
local onScreen = {} -- window root -> true while that window is on screen
local cursorGui, cursorImage, cursorConn

local function dprint(...)
	if Debug and Debug.printf then
		Debug.printf(...)
	end
end

function Layers.order(n)
	return math.clamp(math.floor(n), -Layers.TOP, Layers.TOP)
end

function Layers:Initialize(opts)
	opts = opts or {}
	UIS = opts.UIS
	RunService = opts.RunService
	GuiService = opts.GuiService
	PlayerGui = opts.PlayerGui
	CoreGui = opts.CoreGui
	Debug = opts.Debug
end

-- Where RvrseUI's screens are right now
function Layers:GetParent()
	return chosenParent or PlayerGui
end

-- The executor's hidden folder, else CoreGui; nil when neither takes a screen
-- (a plain game script).
local function findHiddenParent()
	local candidates = {}
	if type(gethui) == "function" then
		local ok, hidden = pcall(gethui)
		if ok and typeof(hidden) == "Instance" then
			table.insert(candidates, hidden)
		end
	end
	if CoreGui then
		table.insert(candidates, CoreGui)
	end

	for _, parent in ipairs(candidates) do
		local probe = Instance.new("ScreenGui")
		local ok = pcall(function()
			probe.Parent = parent
		end)
		local landed = ok and probe.Parent == parent
		probe:Destroy()
		if landed then
			return parent
		end
	end
	return nil
end

-- In PlayerGui Roblox's Esc menu is above us anyway: nothing to do there.
local function stepAside()
	menuOpen = true
	for gui in pairs(mounted) do
		if gui.Parent and gui.Parent ~= PlayerGui and menuHidden[gui] == nil then
			menuHidden[gui] = gui.Enabled
			gui.Enabled = false
		end
	end
end

local function comeBack()
	menuOpen = false
	for gui, wasEnabled in pairs(menuHidden) do
		if gui.Parent then
			gui.Enabled = wasEnabled
		end
	end
	table.clear(menuHidden)
end

local function watchMenu()
	if #menuConnections > 0 or not GuiService then
		return
	end
	pcall(function()
		table.insert(menuConnections, GuiService.MenuOpened:Connect(stepAside))
		table.insert(menuConnections, GuiService.MenuClosed:Connect(comeBack))
	end)
	local ok, isOpen = pcall(function()
		return GuiService.MenuIsOpen
	end)
	if ok and isOpen then
		stepAside()
	end
end

local function place(gui)
	local parent = chosenParent or PlayerGui
	local ok = pcall(function()
		gui.Parent = parent
	end)
	if not ok or gui.Parent ~= parent then
		gui.Parent = PlayerGui
	end
	if gui.Parent ~= PlayerGui then
		watchMenu()
		if menuOpen and menuHidden[gui] == nil then
			menuHidden[gui] = gui.Enabled
			gui.Enabled = false
		end
	end
end

-- Put one of RvrseUI's ScreenGuis where the others are (see GetParent), at the
-- given order.
function Layers:Mount(gui, order)
	gui.DisplayOrder = Layers.order(order or Layers.HOST)
	mounted[gui] = true
	place(gui)
	return gui.Parent
end

-- CreateWindow{ AlwaysOnTop = true }: move every RvrseUI screen to the executor's
-- hidden folder / CoreGui (false: back to PlayerGui). Returns where they are now;
-- still PlayerGui when neither takes a screen.
function Layers:SetOnTop(on)
	local parent = nil
	if on then
		parent = findHiddenParent()
	end
	if parent ~= chosenParent then
		chosenParent = parent
		local wasOpen = menuOpen
		comeBack() -- anything hidden for the Esc menu is shown, then hidden again where it lands
		menuOpen = wasOpen
		for gui in pairs(mounted) do
			if gui.Parent then
				place(gui)
			end
		end
		dprint("[Layers] RvrseUI screens moved to %s", self:GetParent():GetFullName())
	end
	return self:GetParent()
end

local function buildCursor()
	cursorGui = Instance.new("ScreenGui")
	cursorGui.Name = "RvrseUI_Cursor"
	cursorGui.ResetOnSpawn = false
	cursorGui.IgnoreGuiInset = true -- GetMouseLocation counts from the screen's top-left
	cursorGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	cursorImage = Instance.new("ImageLabel")
	cursorImage.Name = "Pointer"
	cursorImage.BackgroundTransparency = 1
	cursorImage.Image = Layers.CURSOR_IMAGE
	cursorImage.Size = UDim2.fromOffset(Layers.CURSOR_SIZE, Layers.CURSOR_SIZE)
	cursorImage.AnchorPoint = Vector2.new(0.5, 0.5)
	cursorImage.Active = false
	pcall(function()
		cursorImage.Interactable = false -- never catches a click or a hover
	end)
	cursorImage.Visible = false
	cursorImage.Parent = cursorGui

	Layers:Mount(cursorGui, Layers.CURSOR)
end

-- Once a frame while a window is on screen: show our pointer only when the game
-- hid the real one and there is a mouse to follow.
local function drawCursor()
	local show = UIS.MouseEnabled and not UIS.MouseIconEnabled
	if show and not (cursorImage and cursorImage.Parent) then
		buildCursor()
	end
	if cursorImage then
		cursorImage.Visible = show
		if show then
			local at = UIS:GetMouseLocation()
			cursorImage.Position = UDim2.fromOffset(at.X, at.Y)
		end
	end
end

local function updateCursorLoop()
	local wanted = next(onScreen) ~= nil
	if wanted and not cursorConn and RunService and UIS then
		cursorConn = RunService.RenderStepped:Connect(drawCursor)
		drawCursor()
	elseif not wanted and cursorConn then
		cursorConn:Disconnect()
		cursorConn = nil
		if cursorImage then
			cursorImage.Visible = false
		end
	end
end

-- A window on screen frees the mouse and, where the game hid the pointer, shows
-- RvrseUI's own. host = the window's ScreenGui, root = its main frame,
-- track = the window's Lifecycle tracker (all of it goes when the window closes).
function Layers:AttachWindow(host, root, track)
	local unlock = Instance.new("TextButton")
	unlock.Name = "MouseUnlock"
	unlock.BackgroundTransparency = 1
	unlock.Text = ""
	unlock.AutoButtonColor = false
	unlock.Selectable = false
	unlock.Size = UDim2.fromOffset(0, 0)
	unlock.Modal = false
	unlock.Parent = host
	track(unlock)

	-- No mouse (a touch screen): nothing to free and no pointer to draw
	local function sync()
		local visible = root.Parent ~= nil and root.Visible and UIS ~= nil and UIS.MouseEnabled == true
		unlock.Modal = visible
		onScreen[root] = visible or nil
		updateCursorLoop()
	end

	track(root:GetPropertyChangedSignal("Visible"):Connect(sync))
	track(function()
		onScreen[root] = nil
		updateCursorLoop()
	end)
	sync()
	return unlock
end

-- What the pointer / mouse side is doing (tests and the debug report)
function Layers:GetState()
	local windows = 0
	for _ in pairs(onScreen) do
		windows = windows + 1
	end
	return {
		parent = self:GetParent(),
		windowsOnScreen = windows,
		cursorLoop = cursorConn ~= nil,
		cursorShown = cursorImage ~= nil and cursorImage.Visible,
		menuOpen = menuOpen,
	}
end

-- Last window closed: stop the pointer loop and the Esc-menu listeners, remove
-- the pointer screen. Mount() / AttachWindow() bring them back for a new window.
function Layers:Teardown()
	for _, conn in ipairs(menuConnections) do
		conn:Disconnect()
	end
	table.clear(menuConnections)
	if cursorConn then
		cursorConn:Disconnect()
		cursorConn = nil
	end
	if cursorGui then
		cursorGui:Destroy()
	end
	cursorGui, cursorImage = nil, nil
	table.clear(onScreen)
	comeBack()
	table.clear(mounted)
end

return Layers
