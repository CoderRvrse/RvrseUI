--!strict
-- RvrseUI: Rayfield-style UI framework + Dropdown, Keybind, Notify

local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local LP      = Players.LocalPlayer

local RvrseUI = {}

-- ========== Theme ==========
local Theme = {
  mode = "Dark",
  Light = {
    Bg=Color3.fromRGB(245,245,248), Panel=Color3.fromRGB(235,235,240),
    Text=Color3.fromRGB(20,24,32),  Muted=Color3.fromRGB(110,116,134),
    Accent=Color3.fromRGB(60,120,250), Good=Color3.fromRGB(46,204,113),
    Bad=Color3.fromRGB(231,76,60), Warn=Color3.fromRGB(245,181,61),
    Border=Color3.fromRGB(210,214,222), Lock=Color3.fromRGB(190,195,206)
  },
  Dark = {
    Bg=Color3.fromRGB(18,18,22), Panel=Color3.fromRGB(28,28,36),
    Text=Color3.fromRGB(235,236,242), Muted=Color3.fromRGB(150,153,170),
    Accent=Color3.fromRGB(80,140,255), Good=Color3.fromRGB(46,204,113),
    Bad=Color3.fromRGB(231,76,60), Warn=Color3.fromRGB(245,181,61),
    Border=Color3.fromRGB(52,56,66), Lock=Color3.fromRGB(62,66,78)
  },
  subscribers = {},
}
local function T(k) return (Theme[Theme.mode] :: any)[k] end
function RvrseUI.SetTheme(mode) Theme.mode = mode; for inst,fn in pairs(Theme.subscribers) do if inst and inst.Parent then fn() else Theme.subscribers[inst]=nil end end end
local function themable(inst, fn) Theme.subscribers[inst]=fn; fn() end

-- ========== Primitives ==========
local function newScreenGui(name)
  local g=Instance.new("ScreenGui"); g.IgnoreGuiInset=true; g.ResetOnSpawn=false; g.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
  g.Name=name; g.Parent=LP:WaitForChild("PlayerGui"); return g
end
local function mkFrame(p, sz, bg, r)
  local f=Instance.new("Frame"); f.Size=sz; f.BackgroundColor3=bg; f.BorderSizePixel=0; f.ClipsDescendants=false; f.Parent=p
  if r then local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r); c.Parent=f end; return f
end
local function mkList(p, pad, horiz)
  local l=Instance.new("UIListLayout"); l.Padding=UDim.new(0,pad)
  l.FillDirection=horiz and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
  l.HorizontalAlignment=Enum.HorizontalAlignment.Left; l.VerticalAlignment=Enum.VerticalAlignment.Top; l.Parent=p; return l
end
local function mkText(p, txt, sz, bold)
  local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Text=txt; t.Font=(bold and Enum.Font.GothamBold or Enum.Font.Gotham)
  t.TextSize=sz; t.TextXAlignment=Enum.TextXAlignment.Left; t.Parent=p; themable(t,function() t.TextColor3=T("Text") end); return t
end
local function mkButtonLike(p, h)
  local b=Instance.new("TextButton"); b.AutoButtonColor=false; b.Size=UDim2.new(1,0,0,h); b.Text=""; b.BorderSizePixel=0; b.Parent=p
  local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,10); c.Parent=b; themable(b,function() b.BackgroundColor3=T("Panel") end); return b
end

-- ========== Elements ==========
local function addLabel(container, label)
  local row=mkButtonLike(container,32)
  local txt=mkText(row,label,16,true); txt.Position=UDim2.new(0,12,0,6); txt.Size=UDim2.new(1,-24,1,-12)
  return { SetText=function(_,s) txt.Text=s end }
end

local function addToggle(container, label, initial, onChanged)
  local row=mkButtonLike(container,36)
  local txt=mkText(row,label,16,true); txt.Position=UDim2.new(0,12,0,8); txt.Size=UDim2.new(1,-80,1,-16)
  local knob=mkFrame(row,UDim2.fromOffset(44,24),Color3.new(),12); knob.Position=UDim2.new(1,-56,0.5,-12)
  local dot =mkFrame(knob,UDim2.fromOffset(20,20),Color3.new(),10); dot.Position=UDim2.new(0,2,0.5,-10)
  local state=initial; local locked=false
  local function paint()
    themable(knob,function() knob.BackgroundColor3 = state and T("Good") or T("Border") end)
    dot.BackgroundColor3 = Theme.mode=="Light" and Color3.new(1,1,1) or Color3.fromRGB(230,232,238)
    dot.Position = state and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10)
    row.AutoButtonColor=not locked; row.Active=not locked; row.TextTransparency= locked and 0.35 or 0
    themable(row,function() row.BackgroundColor3 = locked and T("Lock") or T("Panel") end)
  end
  paint()
  row.MouseButton1Click:Connect(function() if locked then return end; state=not state; paint(); if onChanged then onChanged(state) end end)
  return { Set=function(_,v) state=v; paint() end, Get=function() return state end, SetLocked=function(_,v) locked=v; paint() end, SetText=function(_,s) txt.Text=s end }
end

local function addSlider(container, label, min,max,step,initial,onChanged)
  local row=mkButtonLike(container,44)
  local txt=mkText(row, ("%s: %d"):format(label,initial),16,true); txt.Position=UDim2.new(0,12,0,6); txt.Size=UDim2.new(1,-24,0,18)
  local bar=mkFrame(row,UDim2.new(1,-24,0,6),Color3.new(),3); bar.Position=UDim2.new(0,12,0,28)
  local fill=mkFrame(bar,UDim2.new(0,0,1,0),Color3.new(),3)
  local value=initial; local locked=false
  local function pct() return (value-min)/(max-min) end
  local function paint()
    txt.Text = ("%s: %d"):format(label, value)
    fill.Size = UDim2.new(math.clamp(pct(),0,1),0,1,0)
    themable(bar,function()  bar.BackgroundColor3=T("Border") end)
    themable(fill,function() fill.BackgroundColor3=T("Accent") end)
    row.AutoButtonColor=not locked; row.Active=not locked
    themable(row,function() row.BackgroundColor3= locked and T("Lock") or T("Panel") end)
  end
  paint()
  row.InputBegan:Connect(function(io)
    if locked then return end
    if io.UserInputType.Name:find("MouseButton") then
      local abs=bar.AbsoluteSize.X
      local rel=math.clamp((UIS:GetMouseLocation().X - bar.AbsolutePosition.X)/abs,0,1)
      local raw=min + rel*(max-min)
      value = math.round(raw/step)*step
      paint(); if onChanged then onChanged(value) end
    end
  end)
  return { Set=function(_,v) value=math.clamp(v,min,max); paint() end, Get=function() return value end, SetLocked=function(_,v) locked=v; paint() end }
end

local function addButton(container,label,cb)
  local row=mkButtonLike(container,32)
  local txt=mkText(row,label,16,true); txt.Position=UDim2.new(0,12,0,6); txt.Size=UDim2.new(1,-24,1,-12)
  row.MouseButton1Click:Connect(function() if cb then cb() end end)
  return { SetLocked=function(_,v) row.AutoButtonColor=not v; row.Active=not v; themable(row,function() row.BackgroundColor3= v and T("Lock") or T("Panel") end) end, SetText=function(_,s) txt.Text=s end }
end

-- NEW: Dropdown
local function addDropdown(container,label,options,defaultIndex,onChanged)
  options = options or {}
  local idx = defaultIndex or 1
  local row = mkButtonLike(container, 36)
  local txt = mkText(row, ("%s: %s"):format(label, options[idx] or "-"), 16, true)
  txt.Position = UDim2.new(0,12,0,8); txt.Size = UDim2.new(1,-40,1,-16)

  local chev = mkText(row, "▼", 16, true); chev.Position = UDim2.new(1,-26,0,8); chev.Size=UDim2.new(0,20,0,20)
  themable(chev,function() chev.TextColor3 = T("Muted") end)

  local locked=false; local open=false
  local popup

  local function paintLabel() txt.Text = ("%s: %s"):format(label, options[idx] or "-") end
  local function close()
    open=false; if popup then popup:Destroy(); popup=nil end
  end

  row.MouseButton1Click:Connect(function()
    if locked then return end
    if open then close() return end
    open=true
    popup = mkFrame(row, UDim2.new(1,-12, 0, math.min(#options,6)*28 + 8), T("Panel"), 10)
    popup.Position = UDim2.new(0,6,1,4); mkList(popup,6)
    themable(popup,function() popup.BackgroundColor3=T("Panel") end)
    local pad = Instance.new("UIPadding"); pad.PaddingTop=UDim.new(0,6); pad.PaddingLeft=UDim.new(0,6); pad.Parent=popup

    for i,opt in ipairs(options) do
      local b=mkButtonLike(popup,24); b.Text="" -- reused primitive
      local t=mkText(b, opt, 14, false); t.Position=UDim2.new(0,8,0,4); t.Size=UDim2.new(1,-16,1,-8)
      b.MouseButton1Click:Connect(function()
        idx=i; paintLabel(); if onChanged then onChanged(options[idx], idx) end; close()
      end)
    end
  end)

  UIS.InputBegan:Connect(function(io)
    if open and io.UserInputType == Enum.UserInputType.MouseButton1 then
      local m = UIS:GetMouseLocation()
      local abs = row.AbsolutePosition; local size = row.AbsoluteSize
      local inside = m.X>=abs.X and m.X<=abs.X+size.X and m.Y>=abs.Y and m.Y<=abs.Y+size.Y+ (popup and popup.AbsoluteSize.Y or 0)
      if not inside then close() end
    end
  end)

  return {
    SetLocked=function(_,v) locked=v; row.AutoButtonColor=not v; row.Active=not v; themable(row,function() row.BackgroundColor3= v and T("Lock") or T("Panel") end) end,
    Set=function(_,i) if options[i] then idx=i; paintLabel() end end,
    Get=function() return options[idx], idx end,
    SetOptions=function(_,opts) options=opts or {}; idx=math.clamp(idx,1,#options); paintLabel() end,
  }
end

-- NEW: Keybind
local function addKeybind(container,label,initialKeyCode,onChanged)
  local row=mkButtonLike(container,36)
  local txt=mkText(row,label,16,true); txt.Position=UDim2.new(0,12,0,8); txt.Size=UDim2.new(1,-120,1,-16)

  local btn=mkFrame(row, UDim2.fromOffset(90,24), T("Border"), 8)
  btn.Position=UDim2.new(1,-102,0.5,-12)
  local btxt=mkText(btn, initialKeyCode and initialKeyCode.Name or "Unbound", 14, false)
  btxt.Size=UDim2.new(1,0,1,0); btxt.TextXAlignment=Enum.TextXAlignment.Center

  local current = initialKeyCode
  local listening=false
  local locked=false

  local function paint()
    themable(btn,function() btn.BackgroundColor3 = listening and T("Accent") or T("Border") end)
    row.AutoButtonColor = not locked; row.Active = not locked
    themable(row,function() row.BackgroundColor3 = locked and T("Lock") or T("Panel") end)
    btxt.Text = current and current.Name or "Unbound"
  end
  paint()

  row.MouseButton1Click:Connect(function()
    if locked then return end
    listening=true; paint()
  end)

  UIS.InputBegan:Connect(function(io,gp)
    if not listening or gp then return end
    if io.KeyCode == Enum.KeyCode.Backspace or io.KeyCode == Enum.KeyCode.Escape then
      current=nil; listening=false; paint(); if onChanged then onChanged(nil) end; return
    end
    if io.KeyCode ~= Enum.KeyCode.Unknown then
      current = io.KeyCode; listening=false; paint(); if onChanged then onChanged(current) end
    end
  end)

  return {
    SetLocked=function(_,v) locked=v; paint() end,
    Set=function(_,kc) current=kc; listening=false; paint() end,
    Get=function() return current end,
  }
end

-- ========== Containers ==========
local Section = {}; Section.__index=Section
function Section:AddLabel(t) return addLabel(self._container,t) end
function Section:AddToggle(t,i,cb) return addToggle(self._container,t,i,cb) end
function Section:AddSlider(t,min,max,step,i,cb) return addSlider(self._container,t,min,max,step,i,cb) end
function Section:AddButton(t,cb) return addButton(self._container,t,cb) end
function Section:AddDropdown(t,opts,idx,cb) return addDropdown(self._container,t,opts,idx,cb) end
function Section:AddKeybind(t,kc,cb) return addKeybind(self._container,t,kc,cb) end

local Tab = {}; Tab.__index=Tab
function Tab:CreateSection(title)
  local secWrap=mkFrame(self._scroll, UDim2.new(1,-12,0,0), T("Panel"), 10)
  secWrap.AutomaticSize=Enum.AutomaticSize.Y; themable(secWrap,function() secWrap.BackgroundColor3=T("Panel") end)
  local pad=Instance.new("UIPadding"); pad.PaddingTop=UDim.new(0,8); pad.PaddingBottom=UDim.new(0,8); pad.PaddingLeft=UDim.new(0,12); pad.PaddingRight=UDim.new(0,12); pad.Parent=secWrap
  local titleLbl=mkText(secWrap,title,18,true); titleLbl.Size=UDim2.new(1,0,0,20)
  local body=mkFrame(secWrap,UDim2.new(1,0,0,0),T("Panel")); body.BackgroundTransparency=1; body.AutomaticSize=Enum.AutomaticSize.Y; body.Parent=secWrap
  mkList(body,8)
  local s=setmetatable({_container=body},Section); table.insert(self._sections,s); return s
end

local Window={}; Window.__index=Window
function Window:CreateTab(name)
  local btn=addButton(self._tabbar,name,function() for _,t in ipairs(self._tabs) do t._page.Visible=false end; self._pages[name].Visible=true end)
  local page=mkFrame(self._body,UDim2.new(1,-24,1,-60),T("Bg")); page.Position=UDim2.new(0,12,0,48); themable(page,function() page.BackgroundColor3=T("Bg") end); page.Visible=(#self._tabs==0)
  local scroll=Instance.new("ScrollingFrame"); scroll.Size=UDim2.new(1,0,1,0); scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0; scroll.Parent=page; scroll.CanvasSize=UDim2.new(0,0,0,0); mkList(scroll,10)
  local tab=setmetatable({_page=page,_scroll=scroll,_sections={},_button=btn},Tab); self._pages[name]=page; table.insert(self._tabs,tab); return tab
end

-- ========== Notifications ==========
local notifyGui: ScreenGui? = nil
local stackHolder: Frame? = nil

local function ensureNotify()
  if notifyGui then return end
  notifyGui = newScreenGui("RvrseUI_Notify")
  stackHolder = mkFrame(notifyGui, UDim2.new(0, 320, 1, -20), T("Bg"))
  stackHolder.AnchorPoint = Vector2.new(1,1)
  stackHolder.Position = UDim2.new(1,-12,1,-12)
  stackHolder.BackgroundTransparency = 1
  mkList(stackHolder,8)
end

function RvrseUI.Notify(opts: {Title:string?, Message:string?, Duration:number?, Type:string?})
  ensureNotify()
  local dur = opts.Duration or 3
  local kind = (opts.Type or "info")
  local color = (kind=="success" and T("Good")) or (kind=="warn" and T("Warn")) or (kind=="error" and T("Bad")) or T("Accent")

  local card = mkFrame(stackHolder, UDim2.new(1,0,0,0), T("Panel"), 10)
  card.AutomaticSize = Enum.AutomaticSize.Y
  themable(card,function() card.BackgroundColor3=T("Panel") end)
  local pad = Instance.new("UIPadding"); pad.PaddingTop=UDim.new(0,10); pad.PaddingBottom=UDim.new(0,10); pad.PaddingLeft=UDim.new(0,12); pad.PaddingRight=UDim.new(0,12); pad.Parent=card

  local title = mkText(card, opts.Title or "Notification", 16, true)
  title.Size = UDim2.new(1, -10, 0, 18)
  themable(title,function() title.TextColor3 = color end)

  if opts.Message and #opts.Message>0 then
    local msg = mkText(card, opts.Message, 14, false)
    msg.Position = UDim2.new(0,0,0,22)
    msg.Size = UDim2.new(1,0,0,18)
    themable(msg,function() msg.TextColor3 = T("Text") end)
  end

  card.Transparency = 1
  card:TweenTransparency(0, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
  task.delay(dur, function()
    if card and card.Parent then
      card:TweenTransparency(1, Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.2, true, function()
        if card then card:Destroy() end
      end)
    end
  end)
end

function RvrseUI.CreateWindow(config: {Name: string, Theme: "Light"|"Dark"?})
  if config.Theme then RvrseUI.SetTheme(config.Theme) end
  local gui=newScreenGui("RvrseUI")
  local root=mkFrame(gui,UDim2.new(0,620,0,420),T("Bg"),16); root.Position=UDim2.new(0.5,-310,0.5,-210); themable(root,function() root.BackgroundColor3=T("Bg") end)
  local header=mkFrame(root,UDim2.new(1,0,0,40),T("Panel"),16); themable(header,function() header.BackgroundColor3=T("Panel") end)
  local title=mkText(header,config.Name or "RVRSE UI",18,true); title.Position=UDim2.new(0,12,0,10); title.Size=UDim2.new(1,-24,0,20)
  local body=mkFrame(root,UDim2.new(1,0,1,-40),T("Bg")); body.Position=UDim2.new(0,0,0,40); themable(body,function() body.BackgroundColor3=T("Bg") end)
  local tabbar=mkFrame(body,UDim2.new(0,160,1,-24),T("Panel"),12); tabbar.Position=UDim2.new(0,12,0,12); mkList(tabbar,6); themable(tabbar,function() tabbar.BackgroundColor3=T("Panel") end)
  local main=mkFrame(body,UDim2.new(1,-196,1,-24),T("Bg"),12); main.Position=UDim2.new(0,184,0,12); themable(main,function() main.BackgroundColor3=T("Bg") end)
  return setmetatable({ _gui=gui,_root=root,_tabbar=tabbar,_body=main,_tabs={},_pages={} }, Window)
end

return RvrseUI
