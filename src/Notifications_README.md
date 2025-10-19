# Notifications Module

Extracted from `RvrseUI.lua` (lines 1066-1179) - A standalone toast notification system with animations and priority support.

## Overview

The Notifications module provides a bottom-right stacked notification system with:
- Type-based color coding (success, error, warn, info)
- Priority system (critical, high, normal, low)
- Smooth slide-in/fade-in animations
- Auto-dismiss with configurable duration
- Accent stripe and icon indicators

## Dependencies

This module requires the following dependencies to be injected via `Init()`:

| Dependency | Type | Description |
|------------|------|-------------|
| `Theme` | Table | Theme system with `Get()` method returning color palette |
| `Animator` | Table | Animation system with `Tween()` method and `Spring` presets |
| `host` | ScreenGui | Parent ScreenGui instance for the notification container |
| `RvrseUI` | Table | Main RvrseUI table (for `NotificationsEnabled` flag) |
| `corner` | Function | Helper function: `corner(instance, radius)` |
| `stroke` | Function | Helper function: `stroke(instance, color, thickness)` |

## Usage

### 1. Initialize the Module

```lua
local Notifications = require(path.to.Notifications)

-- Initialize with dependencies
Notifications:Init({
	Theme = Theme,
	Animator = Animator,
	host = screenGuiInstance,
	RvrseUI = RvrseUI,
	corner = cornerFunction,
	stroke = strokeFunction
})
```

### 2. Create Notifications

```lua
-- Basic notification
Notifications:Notify({
	Title = "Success",
	Message = "Operation completed successfully!",
	Type = "success",
	Duration = 3
})

-- With priority
Notifications:Notify({
	Title = "Critical Error",
	Message = "System failure detected!",
	Type = "error",
	Priority = "critical",
	Duration = 5
})
```

## API Reference

### `Notifications:Init(dependencies)`

Initializes the notifications module with required dependencies.

**Parameters:**
- `dependencies` (table): Table containing all required dependencies (see Dependencies section)

**Returns:**
- `self` (table): The Notifications module instance

---

### `Notifications:Notify(opt)`

Creates and displays a notification toast.

**Parameters:**
- `opt` (table): Notification configuration

**Options:**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `Title` | string | `"Notification"` | Notification title text |
| `Message` | string | `nil` | Optional message body (supports multi-line) |
| `Type` | string | `"info"` | Notification type: `"success"`, `"error"`, `"warn"`, `"info"` |
| `Icon` | string\|number | `nil` | Icon identifier (`lucide://`, `icon://`, emoji, `rbxassetid://`, or Roblox asset ID) |
| `IconColor` | Color3 | Accent color | Optional override for icon tint |
| `Duration` | number | `3` | Auto-dismiss duration in seconds |
| `Priority` | string | `"normal"` | Priority level: `"critical"`, `"high"`, `"normal"`, `"low"` |

**Type Colors:**
- `success` → Green (✓ icon)
- `error` → Red (✕ icon)
- `warn` → Yellow/Orange (⚠ icon)
- `info` → Blue (ℹ icon)

**Priority System:**
- Higher priority notifications appear at the bottom (most visible)
- `critical` = LayoutOrder 1
- `high` = LayoutOrder 2
- `normal` = LayoutOrder 3
- `low` = LayoutOrder 4

## Helper Functions

The module requires these helper functions to be passed as dependencies:

### `corner(instance, radius)`
Adds a UICorner to an instance.

```lua
local function corner(inst, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 12)
	c.Parent = inst
	return c
end
```

### `stroke(instance, color, thickness)`
Adds a UIStroke border to an instance.

```lua
local function stroke(inst, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme:Get().Border
	s.Thickness = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = inst
	return s
end
```

## Integration Example

```lua
-- Load dependencies
local Theme = require(script.Theme)
local Animator = require(script.Animator)
local Notifications = require(script.Notifications)

-- Create host ScreenGui
local host = Instance.new("ScreenGui")
host.Name = "RvrseUI"
host.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
host.ResetOnSpawn = false
host.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Helper functions
local function corner(inst, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 12)
	c.Parent = inst
	return c
end

local function stroke(inst, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme:Get().Border
	s.Thickness = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = inst
	return s
end

-- Initialize notifications
local RvrseUI = { NotificationsEnabled = true }

Notifications:Init({
	Theme = Theme,
	Animator = Animator,
	host = host,
	RvrseUI = RvrseUI,
	corner = corner,
	stroke = stroke
})

-- Use notifications
Notifications:Notify({
	Title = "Welcome",
	Message = "System initialized successfully!",
	Type = "success",
	Duration = 3
})
```

## Features

### Visual Design
- **Card-based layout**: 300px width, 72px height
- **Accent stripe**: 4px colored left border indicating type
- **Icon system**: Type-specific icons (✓, ✕, ⚠, ℹ)
- **Typography**: GothamBold for title, Gotham for message
- **Theme integration**: Uses theme colors for backgrounds, text, and accents

### Animations
- **Slide-in**: Cards slide from right (20px offset) with fade-in
- **Stripe animation**: Accent stripe grows from 0 to 4px width
- **Slide-out**: Cards slide right and fade out before destroying
- **Spring presets**:
  - Card animation: `Snappy` (0.2s Back easing)
  - Stripe animation: `Smooth` (0.3s Quad easing)
  - Dismiss animation: `Fast` (0.15s Sine easing)

### Layout System
- **Bottom-right positioning**: Anchored to (1, 1) with 8px padding
- **Vertical stacking**: UIListLayout with 8px spacing
- **Priority ordering**: LayoutOrder determines position (lower = more visible)
- **Auto-sizing**: Adapts to message content length

## Notes

- Notifications are **disabled** if `RvrseUI.NotificationsEnabled` is `false`
- The notification root uses **dynamic obfuscation** (random name per launch)
- All notifications have **ZIndex 15000** to stay above other UI
- Cards **auto-destroy** after animation completes (prevents memory leaks)
- Size reduced to **300px width** for mobile compatibility

## Original Source

Extracted from `d:\RvrseUI\RvrseUI.lua` lines 1066-1179
