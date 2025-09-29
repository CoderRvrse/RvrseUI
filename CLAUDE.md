# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RvrseUI is a Roblox UI framework written in Luau (strict mode), inspired by Rayfield. It provides a complete UI library with theming, windows, tabs, sections, and various interactive elements for Roblox games.

**Runtime Environment**: Roblox LocalScript (runs on the client)

## Architecture

### Core Structure

The framework is organized in a single file (`RvrseUI.lua`) with the following architecture layers:

1. **Theme System** (lines 10-31)
   - Dynamic theme switching between Light and Dark modes
   - Subscriber-based reactive updates: components register with `themable()` to auto-update on theme changes
   - Access theme colors via `T(key)` helper function

2. **Primitives Layer** (lines 33-54)
   - Low-level GUI constructors: `newScreenGui`, `mkFrame`, `mkList`, `mkText`, `mkButtonLike`
   - All UI elements built on top of these primitives

3. **Elements Layer** (lines 56-213)
   - Individual components: Label, Toggle, Slider, Button, Dropdown, Keybind
   - Each returns an API object with methods like `:Set()`, `:Get()`, `:SetLocked()`, `:SetText()`

4. **Container Layer** (lines 215-241)
   - **Section**: Groups elements within a tab (has `_container` frame)
   - **Tab**: Contains sections with auto-scrolling (has `_page`, `_scroll`, `_sections`, `_button`)
   - **Window**: Top-level container managing tabs (has `_gui`, `_root`, `_tabbar`, `_body`, `_tabs`, `_pages`)

5. **Notification System** (lines 243-288)
   - Standalone toast-style notifications with auto-dismiss
   - Appears in bottom-right corner via separate ScreenGui

### Key Patterns

**Metatables**: Section, Tab, and Window use Lua metatables for OOP-style methods

**State Management**: Each element maintains local state closures with `paint()` functions for rendering

**Locking Mechanism**: Most elements support `.SetLocked()` to disable interaction (grays out, prevents clicks)

**Theme Reactivity**: Components register callbacks via `themable(instance, fn)` that auto-execute on `RvrseUI.SetTheme()`

## API Usage

```lua
-- Create window
local Window = RvrseUI.CreateWindow({Name = "My UI", Theme = "Dark"})

-- Create tab and section
local Tab = Window:CreateTab("Main")
local Section = Tab:CreateSection("Controls")

-- Add elements (returns control objects)
local toggle = Section:AddToggle("Feature", false, function(val) print(val) end)
local slider = Section:AddSlider("Speed", 0, 100, 1, 50, function(val) end)
local dropdown = Section:AddDropdown("Mode", {"A","B","C"}, 1, function(opt, idx) end)
local keybind = Section:AddKeybind("Hotkey", Enum.KeyCode.E, function(keyCode) end)
local button = Section:AddButton("Execute", function() end)
local label = Section:AddLabel("Status")

-- Notifications (global function)
RvrseUI.Notify({Title="Info", Message="Task done", Duration=3, Type="success"}) -- Types: info, success, warn, error

-- Theme switching
RvrseUI.SetTheme("Light") -- or "Dark"

-- Element methods
toggle:Set(true)
toggle:SetLocked(true)
toggle:SetText("New Label")
local state = toggle:Get()
```

## Modifying the Framework

**Adding a new element type**:
1. Create element function in Elements layer (e.g., `addTextbox`)
2. Build UI using primitives (`mkButtonLike`, `mkFrame`, `mkText`)
3. Return API object with standard methods (`:Set`, `:Get`, `:SetLocked`)
4. Add method to Section metatable (e.g., `function Section:AddTextbox(...)`)

**Theme colors**: Modify `Theme.Light` / `Theme.Dark` tables (lines 13-26). Keys: Bg, Panel, Text, Muted, Accent, Good, Bad, Warn, Border, Lock

**Layout changes**: Adjust size/position in container creation:
- Window dimensions: line 293 (`UDim2.new(0,620,0,420)`)
- Tab sidebar width: line 297 (`UDim2.new(0,160,...)`)
- Notification width: line 250 (`UDim2.new(0, 320,...)`)

## Testing

Since this is a Roblox framework, testing requires running in Roblox Studio:

1. Create a LocalScript in StarterPlayer.StarterPlayerScripts or StarterGui
2. Paste RvrseUI.lua as a ModuleScript in ReplicatedStorage
3. Require and use the module:
```lua
local RvrseUI = require(game.ReplicatedStorage.RvrseUI)
local Window = RvrseUI.CreateWindow({Name = "Test"})
-- Add tabs/sections/elements...
```
4. Run the game in Studio to see the UI

**Strict mode**: The `--!strict` annotation enables Luau type checking. When adding code, respect type annotations and use `:: any` type casts only when necessary (e.g., line 29: `(Theme[Theme.mode] :: any)[k]`)