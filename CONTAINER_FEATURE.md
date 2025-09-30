# RvrseUI Container Selection Feature

## 📦 What is Container Selection?

Container selection allows you to choose **where** your RvrseUI window is hosted in the Roblox game hierarchy. By default, UIs are placed in `PlayerGui`, but legitimate use cases may require different containers.

---

## ✅ Legitimate Use Cases

### 1. **CoreGui - Admin/Mod Panels**
Place UI in CoreGui for admin tools that persist across character respawns and can't be easily closed by players.

```lua
local Window = RvrseUI:CreateWindow({
	Name = "Admin Panel",
	Container = "CoreGui",  -- Persistent admin UI
	Icon = "shield",
	Theme = "Dark"
})
```

**Use case:** Game admin panels, moderation tools, developer consoles

---

### 2. **ReplicatedFirst - Loading Screens**
Create custom loading screens that appear before the game fully loads.

```lua
local Window = RvrseUI:CreateWindow({
	Name = "Loading Screen",
	Container = "ReplicatedFirst",  -- Shows during game load
	Icon = "loader",
	Theme = "Dark"
})

-- Add loading progress
local Tab = Window:CreateTab({ Title = "Loading", Icon = "clock" })
local Section = Tab:CreateSection("Game Assets")

Section:CreateSlider({
	Text = "Loading Progress",
	Min = 0,
	Max = 100,
	Default = 0,
	OnChanged = function(progress)
		print("Loading:", progress .. "%")
	end
})
```

**Use case:** Custom loading screens, asset preloading displays, game initialization UI

---

### 3. **StarterGui - Template UIs**
Create UI templates that clone to each player on spawn.

```lua
local Window = RvrseUI:CreateWindow({
	Name = "Player HUD Template",
	Container = "StarterGui",  -- Clones to each player
	Icon = "layout",
	Theme = "Dark"
})
```

**Use case:** HUD templates, default player UIs, tutorial systems

---

### 4. **Custom Instance - 3D World UI**
Attach UI to a specific part or model in the game world.

```lua
local customPart = workspace.UIHolder  -- Your custom part/model

local Window = RvrseUI:CreateWindow({
	Name = "3D UI",
	Container = customPart,  -- Direct instance reference
	Icon = "box",
	Theme = "Light"
})
```

**Use case:** In-world computer screens, interactive terminals, shop kiosks

---

## 🎯 API Reference

### Basic Usage

```lua
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

local Window = RvrseUI:CreateWindow({
	Name = "My Window",
	Container = "PlayerGui",  -- Optional (default)
	DisplayOrder = 999,       -- Optional (default: 999)
	Icon = "home",
	Theme = "Dark"
})
```

### Container Options

| Container | Type | Description | Use Case |
|-----------|------|-------------|----------|
| `"PlayerGui"` | String | Default, standard UI | Normal player interfaces |
| `"CoreGui"` | String | Persistent, high-level UI | Admin panels, mod tools |
| `"ReplicatedFirst"` | String | Pre-game loading UI | Loading screens |
| `"StarterGui"` | String | Template UI (clones) | Default HUDs |
| `workspace.Part` | Instance | Custom object | 3D world UI, kiosks |

### Advanced: Custom DisplayOrder

```lua
local Window = RvrseUI:CreateWindow({
	Name = "Overlay UI",
	Container = "PlayerGui",
	DisplayOrder = 9999,  -- Higher = renders on top
})
```

---

## 📚 Complete Examples

### Example 1: Admin Panel (CoreGui)

```lua
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

-- Admin panel in CoreGui (persistent)
local AdminWindow = RvrseUI:CreateWindow({
	Name = "Admin Panel",
	Container = "CoreGui",
	Icon = "shield",
	Theme = "Dark",
	ToggleUIKeybind = "F1"
})

local AdminTab = AdminWindow:CreateTab({ Title = "Moderation", Icon = "users" })
local ModSection = AdminTab:CreateSection("Player Management")

ModSection:CreateButton({
	Text = "Kick Player",
	Callback = function()
		-- Admin kick logic
		RvrseUI:Notify({
			Title = "Admin Action",
			Message = "Player kicked",
			Duration = 2,
			Type = "success"
		})
	end
})

ModSection:CreateButton({
	Text = "Ban Player",
	Callback = function()
		-- Admin ban logic
		RvrseUI:Notify({
			Title = "Admin Action",
			Message = "Player banned",
			Duration = 2,
			Type = "warn"
		})
	end
})
```

---

### Example 2: Loading Screen (ReplicatedFirst)

```lua
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

-- Custom loading screen
local LoadingWindow = RvrseUI:CreateWindow({
	Name = "Game Loading",
	Container = "ReplicatedFirst",
	Icon = "loader",
	Theme = "Dark"
})

local LoadTab = LoadingWindow:CreateTab({ Title = "Loading", Icon = "clock" })
local LoadSection = LoadTab:CreateSection("Preparing Game...")

local progressSlider = LoadSection:CreateSlider({
	Text = "Loading Assets",
	Min = 0,
	Max = 100,
	Default = 0,
	OnChanged = function(value)
		print("Loading progress:", value .. "%")
	end
})

-- Simulate loading
task.spawn(function()
	for i = 0, 100, 10 do
		wait(0.3)
		progressSlider:Set(i)

		if i >= 100 then
			RvrseUI:Notify({
				Title = "Loading Complete!",
				Message = "Game ready to play",
				Duration = 3,
				Type = "success"
			})
			wait(2)
			LoadingWindow:Destroy()
		end
	end
end)
```

---

### Example 3: Multiple Containers

```lua
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

-- Player UI in PlayerGui (default)
local PlayerWindow = RvrseUI:CreateWindow({
	Name = "Player HUD",
	Icon = "user",
	Theme = "Dark"
})

-- Admin UI in CoreGui (persistent)
local AdminWindow = RvrseUI:CreateWindow({
	Name = "Admin Tools",
	Container = "CoreGui",
	Icon = "shield",
	Theme = "Light"
})

-- Each window operates independently!
```

---

## ⚠️ Important Notes

### Security Considerations

1. **CoreGui Access**: On live Roblox servers, CoreGui may be restricted. Test thoroughly.
2. **ReplicatedFirst**: Loading screen UIs should be destroyed after loading completes.
3. **Custom Instances**: Ensure the target instance exists before creating the window.

### Best Practices

```lua
-- ✅ Good: Check if container is accessible
local hasCoreguiAccess = pcall(function()
	return game:GetService("CoreGui")
end)

if hasCoreguiAccess then
	local Window = RvrseUI:CreateWindow({
		Container = "CoreGui"
	})
else
	warn("CoreGui access denied, using PlayerGui")
	local Window = RvrseUI:CreateWindow({
		Container = "PlayerGui"
	})
end
```

```lua
-- ✅ Good: Destroy loading screens after use
local LoadingWindow = RvrseUI:CreateWindow({
	Container = "ReplicatedFirst"
})

-- After loading completes
wait(5)
LoadingWindow:Destroy()
```

```lua
-- ❌ Bad: Leaving UIs in ReplicatedFirst permanently
-- This can cause memory leaks
```

---

## 🔧 Troubleshooting

### Issue: "Invalid container specified"

**Cause:** Container string doesn't match available options

**Solution:**
```lua
-- Valid containers (case-sensitive)
Container = "PlayerGui"       -- ✅
Container = "CoreGui"          -- ✅
Container = "ReplicatedFirst"  -- ✅
Container = "StarterGui"       -- ✅

Container = "playergui"        -- ❌ Wrong case
Container = "Lighting"         -- ❌ Not supported
```

### Issue: UI not appearing

**Cause:** DisplayOrder too low or container not accessible

**Solution:**
```lua
local Window = RvrseUI:CreateWindow({
	Container = "PlayerGui",
	DisplayOrder = 9999  -- Increase to render on top
})
```

### Issue: UI persists after respawn

**Cause:** Using CoreGui or ResetOnSpawn = false

**Solution:**
```lua
-- For respawn-safe UI, use default PlayerGui
local Window = RvrseUI:CreateWindow({
	Container = "PlayerGui"  -- Resets on respawn by default
})
```

---

## 📊 Container Comparison

| Feature | PlayerGui | CoreGui | ReplicatedFirst | StarterGui |
|---------|-----------|---------|-----------------|------------|
| **Default** | ✅ Yes | ❌ No | ❌ No | ❌ No |
| **Resets on Respawn** | ✅ Yes | ❌ No | ❌ No | ✅ Yes |
| **Accessible in Live Games** | ✅ Yes | ⚠️ Limited | ⚠️ Limited | ✅ Yes |
| **Use for Loading Screens** | ❌ No | ❌ No | ✅ Yes | ❌ No |
| **Use for Admin Panels** | ⚠️ Maybe | ✅ Yes | ❌ No | ❌ No |
| **Use for Player HUD** | ✅ Yes | ❌ No | ❌ No | ⚠️ Templates |

---

## 🎯 Summary

The container selection feature allows you to:

✅ **Place admin UIs in CoreGui** for persistence
✅ **Create loading screens in ReplicatedFirst**
✅ **Build HUD templates in StarterGui**
✅ **Attach UIs to custom instances** for 3D world UI

All legitimate, useful features for Roblox game developers!

---

**RvrseUI v2.1.5+** - Flexible Container System for Every Use Case