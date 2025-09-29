-- RvrseUI |  external UI
-- Single-file bundle (drop-in). No console spam (DEBUG=false).
-- API: CreateWindow → CreateTab → CreateSection → {CreateButton, CreateToggle, CreateDropdown, CreateKeybind}
-- Extras: RvrseUI:Notify(...), Theme Light/Dark, mobile chip, keybind toggle, LockGroup system.

local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local RS      = game:GetService("RunService")

local LP          = Players.LocalPlayer
local PlayerGui   = LP:WaitForChild("PlayerGui")

local RvrseUI = {}
RvrseUI.DEBUG = false

-- =========================
-- Theme
-- =========================
local Theme = {}
Theme.Palettes = {
  Dark = {
    Bg     = Color3.fromRGB(14,14,18),
    Card   = Color3.fromRGB(24,24,30),
    Muted  = Color3.fromRGB(32,32,40),
    Text   = Color3.fromRGB(235,235,245),
    Sub    = Color3.fromRGB(180,180,190),
    Success= Color3.fromRGB(35,120,60),
    Info   = Color3.fromRGB(40,90,160),
    Warn   = Color3.fromRGB(180,120,30),
    Error  = Color3.fromRGB(170,50,60),
  },
  Light = {
    Bg     = Color3.fromRGB(244,244,248),
    Card   = Color3.fromRGB(255,255,255),
    Muted  = Color3.fromRGB(235,235,240),
    Text   = Color3.fromRGB(20,20,24),
    Sub    = Color3.fromRGB(80,80,90),
    Success= Color3.fromRGB(30,160,80),
    Info   = Color3.fromRGB(40,110,210),
    Warn   = Color3.fromRGB(210,150,40),
    Error  = Color3.fromRGB(200,60,70),
  }
}
Theme.Current = "Dark"
function Theme:Get() return self.Palettes[self.Current] end

-- =========================
-- Store (locks, ui refs, binding)
-- =========================
RvrseUI.Store = {
  _locks = {}, -- [group] = true/false
}
function RvrseUI.Store:SetLocked(group, isLocked)
  self._locks[group] = isLocked and true or false
  -- broadcast to UI to refresh visuals
  if RvrseUI._refreshLockListeners then
    for _,fn in ipairs(RvrseUI._refreshLockListeners) do
      pcall(fn)
    end
  end
end
function RvrseUI.Store:IsLocked(group)
  return self._locks[group] == true
end

-- =========================
-- Utils
-- =========================
local function coerceKeycode(k)
  if typeof(k) == "EnumItem" and k.EnumType == Enum.KeyCode then return k end
  if typeof(k) == "string" then
    local up = k:upper()
    if Enum.KeyCode[up] then return Enum.KeyCode[up] end
    if #up == 1 and Enum.KeyCode[up] then return Enum.KeyCode[up] end
  end
  return Enum.KeyCode.K
end

local function corner(inst, r)
  local u = Instance.new("UICorner")
  u.CornerRadius = UDim.new(0, r or 10)
  u.Parent = inst
  return u
end

-- =========================
-- Root Host + Notify
-- =========================
local host = Instance.new("ScreenGui")
host.Name = "RvrseUI"
host.ResetOnSpawn = false
host.IgnoreGuiInset = true
host.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
host.Parent = PlayerGui

-- Notify stack
local notifyRoot = Instance.new("Frame")
notifyRoot.Name = "NotifyStack"
notifyRoot.BackgroundTransparency = 1
notifyRoot.AnchorPoint = Vector2.new(1,1)
notifyRoot.Position = UDim2.new(1,-12, 1,-12)
notifyRoot.Size = UDim2.new(0, 320, 1, -24)
notifyRoot.Parent = host
local notifyLayout = Instance.new("UIListLayout")
notifyLayout.Padding = UDim.new(0,6)
notifyLayout.FillDirection = Enum.FillDirection.Vertical
notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
notifyLayout.Parent = notifyRoot

function RvrseUI:Notify(opt)
  local pal = Theme:Get()
  local f = Instance.new("Frame")
  f.Size = UDim2.new(1, 0, 0, 56)
  f.BackgroundColor3 = pal.Card
  f.BorderSizePixel = 0
  f.Parent = notifyRoot
  corner(f, 10)

  local stripe = Instance.new("Frame")
  stripe.Size = UDim2.new(0,4,1,0)
  stripe.BackgroundColor3 = pal.Info
  stripe.BorderSizePixel = 0
  stripe.Parent = f
  if opt.Type == "success" then stripe.BackgroundColor3 = pal.Success
  elseif opt.Type == "warn" then stripe.BackgroundColor3 = pal.Warn
  elseif opt.Type == "error" then stripe.BackgroundColor3 = pal.Error end

  local title = Instance.new("TextLabel")
  title.BackgroundTransparency = 1
  title.Font = Enum.Font.GothamBold
  title.TextSize = 14
  title.TextXAlignment = Enum.TextXAlignment.Left
  title.TextColor3 = pal.Text
  title.Text = opt.Title or "Info"
  title.Position = UDim2.new(0,10,0,6)
  title.Size = UDim2.new(1,-20,0,18)
  title.Parent = f

  local msg = Instance.new("TextLabel")
  msg.BackgroundTransparency = 1
  msg.Font = Enum.Font.Gotham
  msg.TextSize = 13
  msg.TextXAlignment = Enum.TextXAlignment.Left
  msg.TextColor3 = pal.Sub
  msg.TextWrapped = true
  msg.Text = opt.Message or ""
  msg.Position = UDim2.new(0,10,0,24)
  msg.Size = UDim2.new(1,-20,0,28)
  msg.Parent = f

  f.BackgroundTransparency = 1
  stripe.Size = UDim2.new(0,0,1,0)
  game:GetService("TweenService"):Create(f, TweenInfo.new(0.18), {BackgroundTransparency=0}):Play()
  game:GetService("TweenService"):Create(stripe, TweenInfo.new(0.18), {Size=UDim2.new(0,4,1,0)}):Play()

  local dur = tonumber(opt.Duration) or 2
  task.delay(dur, function()
    pcall(function()
      game:GetService("TweenService"):Create(f, TweenInfo.new(0.18), {BackgroundTransparency=1}):Play()
      game:GetService("TweenService"):Create(stripe, TweenInfo.new(0.18), {Size=UDim2.new(0,0,1,0)}):Play()
      task.wait(0.2)
      f:Destroy()
    end)
  end)
end

-- =========================
-- Public UI helpers (bind/unbind toggle key)
-- =========================
RvrseUI.UI = { _toggleTargets = {}, _key = Enum.KeyCode.K }
function RvrseUI.UI:RegisterToggleTarget(frame)
  self._toggleTargets[frame] = true
end
function RvrseUI.UI:BindToggleKey(key)
  self._key = coerceKeycode(key or "K")
end

UIS.InputBegan:Connect(function(io, gpe)
  if gpe then return end
  if io.KeyCode == RvrseUI.UI._key then
    for f in pairs(RvrseUI.UI._toggleTargets) do
      if f and f.Parent then
        f.Visible = not f.Visible
      end
    end
  end
end)

-- lock refresh listeners
RvrseUI._refreshLockListeners = {}

-- =========================
-- Window Builder
-- =========================
function RvrseUI:CreateWindow(w)
  w = w or {}
  local pal = Theme:Get()
  if w.Theme and Theme.Palettes[w.Theme] then Theme.Current = w.Theme; pal = Theme:Get() end

  local name      = w.Name or "RvrseUI"
  local icon      = w.Icon or 0
  local showText  = w.ShowText or "RvrseUI"
  local loadTitle = w.LoadingTitle or name
  local loadSub   = w.LoadingSubtitle or ""
  local toggleKey = coerceKeycode(w.ToggleUIKeybind or "K")
  self.UI:BindToggleKey(toggleKey)

  -- window root
  local root = Instance.new("Frame")
  root.Name = "Window_"..name:gsub("%s","")
  root.Size = UDim2.new(0, 560, 0, 440)
  root.Position = UDim2.new(0.5, -280, 0.5, -220)
  root.BackgroundColor3 = pal.Bg
  root.BorderSizePixel = 0
  root.Visible = true
  root.Parent = host
  corner(root, 12)
  self.UI:RegisterToggleTarget(root)

  -- top bar
  local top = Instance.new("Frame")
  top.Size = UDim2.new(1,0,0,44)
  top.BackgroundColor3 = pal.Card
  top.BorderSizePixel = 0
  top.Parent = root
  corner(top, 12)

  local iconHolder = Instance.new("Frame")
  iconHolder.BackgroundTransparency = 1
  iconHolder.Size = UDim2.new(0,44,1,0)
  iconHolder.Parent = top
  if typeof(icon) == "number" and icon ~= 0 then
    local img = Instance.new("ImageLabel")
    img.BackgroundTransparency = 1
    img.Image = "rbxassetid://"..icon
    img.Size = UDim2.new(0,24,0,24)
    img.Position = UDim2.new(0,10,0.5,-12)
    img.Parent = iconHolder
  elseif typeof(icon) == "string" and icon ~= "" then
    local txt = Instance.new("TextLabel")
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 20
    txt.TextColor3 = pal.Text
    txt.Text = icon
    txt.Size = UDim2.new(0,24,0,24)
    txt.Position = UDim2.new(0,10,0.5,-12)
    txt.Parent = iconHolder
  end

  local title = Instance.new("TextLabel")
  title.BackgroundTransparency = 1
  title.Font = Enum.Font.GothamBold
  title.TextSize = 18
  title.TextColor3 = pal.Text
  title.TextXAlignment = Enum.TextXAlignment.Left
  title.Text = name
  title.Position = UDim2.new(0,56,0,0)
  title.Size = UDim2.new(1,-56,1,0)
  title.Parent = top

  -- tabbar
  local tabbar = Instance.new("Frame")
  tabbar.BackgroundTransparency = 1
  tabbar.Position = UDim2.new(0,12,0,52)
  tabbar.Size = UDim2.new(1,-24,0,36)
  tabbar.Parent = root
  local tabsLayout = Instance.new("UIListLayout")
  tabsLayout.Padding = UDim.new(0,8)
  tabsLayout.FillDirection = Enum.FillDirection.Horizontal
  tabsLayout.Parent = tabbar

  -- body
  local body = Instance.new("Frame")
  body.BackgroundColor3 = pal.Card
  body.BorderSizePixel = 0
  body.Position = UDim2.new(0,12,0,96)
  body.Size = UDim2.new(1,-24,1,-108)
  body.Parent = root
  corner(body,10)

  -- splash
  local splash = Instance.new("Frame")
  splash.BackgroundColor3 = pal.Card
  splash.BorderSizePixel = 0
  splash.Position = UDim2.new(0,12,0,96)
  splash.Size = UDim2.new(1,-24,1,-108)
  splash.Parent = root
  corner(splash,10)

  local lt = Instance.new("TextLabel")
  lt.BackgroundTransparency = 1
  lt.Font = Enum.Font.GothamBold
  lt.TextSize = 20
  lt.TextColor3 = pal.Text
  lt.Text = loadTitle
  lt.Position = UDim2.new(0,16,0,16)
  lt.Size = UDim2.new(1,-32,0,28)
  lt.TextXAlignment = Enum.TextXAlignment.Left
  lt.Parent = splash

  local ls = Instance.new("TextLabel")
  ls.BackgroundTransparency = 1
  ls.Font = Enum.Font.Gotham
  ls.TextSize = 14
  ls.TextColor3 = pal.Sub
  ls.Text = loadSub
  ls.Position = UDim2.new(0,16,0,50)
  ls.Size = UDim2.new(1,-32,0,22)
  ls.TextXAlignment = Enum.TextXAlignment.Left
  ls.Parent = splash

  task.delay(0.8, function() if splash and splash.Parent then splash.Visible = false end end)

  -- mobile chip
  local chip = Instance.new("TextButton")
  chip.Text = showText
  chip.Font = Enum.Font.GothamMedium
  chip.TextSize = 12
  chip.TextColor3 = pal.Text
  chip.BackgroundColor3 = pal.Card
  chip.Size = UDim2.new(0,110,0,28)
  chip.AnchorPoint = Vector2.new(1,0)
  chip.Position = UDim2.new(1,-12,0,12)
  chip.Parent = host
  chip.Visible = false
  corner(chip,14)

  RvrseUI.UI._toggleTargets[chip] = false -- not toggled by key
  local function setHidden(v)
    root.Visible = not v
    chip.Visible = v
  end

  -- CreateTab/Section/Elements
  local activePage

  local WindowAPI = {}
  function WindowAPI:SetTitle(t) title.Text = t or name end
  function WindowAPI:Show() setHidden(false) end
  function WindowAPI:Hide() setHidden(true) end

  chip.MouseButton1Click:Connect(function() setHidden(false) end)

  -- lock refresh registry
  RvrseUI._refreshLockListeners = RvrseUI._refreshLockListeners or {}

  function WindowAPI:CreateTab(t)
    local palNow = Theme:Get()
    t = t or {}
    local b = Instance.new("TextButton")
    b.AutoButtonColor = true
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 14
    b.TextColor3 = palNow.Text
    b.BackgroundColor3 = palNow.Muted
    b.Size = UDim2.new(0, 100, 1, 0)
    b.Text = ((t.Icon and (t.Icon.." ")) or "") .. (t.Title or "Tab")
    b.Parent = tabbar
    corner(b,8)

    local page = Instance.new("ScrollingFrame")
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1,-16,1,-16)
    page.Position = UDim2.new(0,8,0,8)
    page.ScrollBarThickness = 4
    page.Visible = false
    page.Parent = body
    local vlist = Instance.new("UIListLayout")
    vlist.Padding = UDim.new(0,10)
    vlist.Parent = page

    b.MouseButton1Click:Connect(function()
      if activePage then activePage.Visible=false end
      page.Visible=true
      activePage=page
    end)
    if not activePage then page.Visible=true; activePage=page end

    local TabAPI = {}
    function TabAPI:CreateSection(text)
      local pal2 = Theme:Get()

      local header = Instance.new("TextLabel")
      header.BackgroundTransparency = 1
      header.Font = Enum.Font.GothamBold
      header.TextSize = 16
      header.TextColor3 = pal2.Sub
      header.TextXAlignment = Enum.TextXAlignment.Left
      header.Text = text or "Section"
      header.Size = UDim2.new(1,0,0,18)
      header.Parent = page

      local container = Instance.new("Frame")
      container.BackgroundTransparency = 1
      container.Size = UDim2.new(1,0,0,0)
      container.Parent = page
      local list = Instance.new("UIListLayout")
      list.Padding = UDim.new(0,8)
      list.Parent = container

      local function card(height)
        local c = Instance.new("Frame")
        c.BackgroundColor3 = pal2.Muted
        c.BorderSizePixel = 0
        c.Size = UDim2.new(1,0,0,height)
        c.Parent = container
        corner(c,10)
        local pad = Instance.new("UIPadding", c)
        pad.PaddingTop = UDim.new(0,8); pad.PaddingBottom = UDim.new(0,8); pad.PaddingLeft = UDim.new(0,8); pad.PaddingRight = UDim.new(0,8)
        return c
      end

      local SectionAPI = {}

      -- Button
      function SectionAPI:CreateButton(o)
        o = o or {}
        local f = card(40)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,0,1,0)
        btn.Text = o.Text or "Button"
        btn.BackgroundTransparency = 1
        btn.TextColor3 = pal2.Text
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 14
        btn.Parent = f
        btn.MouseButton1Click:Connect(function()
          if RvrseUI.Store:IsLocked(o.RespectLock) then return end
          if o.Callback then task.spawn(o.Callback) end
        end)
        table.insert(RvrseUI._refreshLockListeners, function()
          btn.TextTransparency = RvrseUI.Store:IsLocked(o.RespectLock) and 0.3 or 0
        end)
        return {
          SetText = function(_, t) btn.Text = t end
        }
      end

      -- Toggle
      function SectionAPI:CreateToggle(o)
        o = o or {}
        local f = card(40)
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 14
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextColor3 = pal2.Text
        lbl.Text = o.Text or "Toggle"
        lbl.Size = UDim2.new(1,-56,1,0)
        lbl.Parent = f

        local shell = Instance.new("Frame")
        shell.AnchorPoint = Vector2.new(1,0.5)
        shell.Position = UDim2.new(1,-8,0.5,0)
        shell.Size = UDim2.new(0,44,0,22)
        shell.BackgroundColor3 = pal2.Card
        shell.BorderSizePixel = 0
        shell.Parent = f
        corner(shell,11)

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0,18,0,18)
        dot.Position = UDim2.new(0,2,0.5,-9)
        dot.BackgroundColor3 = pal2.Sub
        dot.BorderSizePixel = 0
        dot.Parent = shell
        corner(dot,9)

        local state = o.State == true
        -- If LockGroup is provided, this toggle CONTROLS that lock; if RespectLock is provided, it RESPONDS to that lock.
        local controlsGroup = o.LockGroup
        local respectGroup  = o.RespectLock

        local function lockedNow()
          return respectGroup and RvrseUI.Store:IsLocked(respectGroup)
        end

        local function visual()
          local locked = lockedNow()
          shell.BackgroundColor3 = locked and Color3.fromRGB(70,74,83) or (state and pal2.Success or pal2.Card)
          dot.Position = UDim2.new(state and 1 or 0, state and -20 or 2, 0.5, -9)
          lbl.TextTransparency = locked and 0.3 or 0
        end
        visual()

        f.InputBegan:Connect(function(io)
          if io.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
          if lockedNow() then return end
          state = not state
          visual()
          if controlsGroup then
            RvrseUI.Store:SetLocked(controlsGroup, state)
          end
          if o.OnChanged then task.spawn(o.OnChanged, state) end
        end)

        table.insert(RvrseUI._refreshLockListeners, visual)

        return {
          Set = function(_, v) state = v and true or false; visual(); if controlsGroup then RvrseUI.Store:SetLocked(controlsGroup, state) end end,
          Get = function() return state end,
          Refresh = visual
        }
      end

      -- Dropdown
      function SectionAPI:CreateDropdown(o)
        o = o or {}
        local f = card(46)
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 14
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextColor3 = pal2.Text
        lbl.Text = o.Text or "Dropdown"
        lbl.Size = UDim2.new(1,-130,1,0)
        lbl.Parent = f

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,120,0,30)
        btn.AnchorPoint = Vector2.new(1,0.5)
        btn.Position = UDim2.new(1,-8,0.5,0)
        btn.BackgroundColor3 = pal2.Card
        btn.TextColor3 = pal2.Text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.Text = tostring(o.Default or (o.Values and o.Values[1]) or "Select")
        btn.Parent = f
        corner(btn,8)

        local values = o.Values or {}
        local idx = 1
        for i,v in ipairs(values) do if v == o.Default then idx = i break end end

        local function locked() return o.RespectLock and RvrseUI.Store:IsLocked(o.RespectLock) end
        local function visual()
          btn.AutoButtonColor = not locked()
          lbl.TextTransparency = locked() and 0.3 or 0
        end
        visual()

        btn.MouseButton1Click:Connect(function()
          if locked() then return end
          idx = (idx % #values) + 1
          btn.Text = tostring(values[idx])
          if o.OnChanged then task.spawn(o.OnChanged, values[idx]) end
        end)

        table.insert(RvrseUI._refreshLockListeners, visual)

        return {
          Set = function(_, v)
            for i,val in ipairs(values) do if val==v then idx=i break end end
            btn.Text = tostring(values[idx])
            visual()
          end,
          Get = function() return values[idx] end
        }
      end

      -- Keybind
      function SectionAPI:CreateKeybind(o)
        o = o or {}
        local f = card(40)
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 14
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextColor3 = pal2.Text
        lbl.Text = o.Text or "Keybind"
        lbl.Size = UDim2.new(1,-140,1,0)
        lbl.Parent = f

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,120,0,30)
        btn.AnchorPoint = Vector2.new(1,0.5)
        btn.Position = UDim2.new(1,-8,0.5,0)
        btn.BackgroundColor3 = pal2.Card
        btn.TextColor3 = pal2.Text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.Text = (o.Default and o.Default.Name) or "Set Key"
        btn.Parent = f
        corner(btn,8)

        local capturing = false
        btn.MouseButton1Click:Connect(function()
          if RvrseUI.Store:IsLocked(o.RespectLock) then return end
          capturing = true
          btn.Text = "Press a key..."
        end)

        UIS.InputBegan:Connect(function(io, gpe)
          if gpe or not capturing then return end
          if io.KeyCode ~= Enum.KeyCode.Unknown then
            capturing = false
            btn.Text = io.KeyCode.Name
            if o.OnChanged then task.spawn(o.OnChanged, io.KeyCode) end
          end
        end)

        table.insert(RvrseUI._refreshLockListeners, function()
          btn.AutoButtonColor = not RvrseUI.Store:IsLocked(o.RespectLock)
          lbl.TextTransparency = RvrseUI.Store:IsLocked(o.RespectLock) and 0.3 or 0
        end)

        -- init default callback
        if o.Default then
          task.spawn(function()
            if o.OnChanged then o.OnChanged(o.Default) end
          end)
        end

        return {
          Set = function(_, key)
            btn.Text = (key and key.Name) or "Set Key"
            if o.OnChanged and key then o.OnChanged(key) end
          end
        }
      end

      return SectionAPI
    end

    return TabAPI
  end

  -- optional prompts/warnings
  if not w.DisableBuildWarnings then
    RvrseUI:Notify({ Title="RvrseUI", Message="Dev build loaded", Duration=2, Type="success" })
  end
  if not w.DisableRvrseUIPrompts then
    RvrseUI:Notify({ Title="Welcome", Message="Press "..toggleKey.Name.." to toggle UI", Duration=3, Type="info" })
  end

  return WindowAPI
end

return RvrseUI
