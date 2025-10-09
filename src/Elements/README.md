# Element Modules - RvrseUI v2.13.0

This directory contains all 10 element creation modules extracted from the main RvrseUI.lua file.

## Module Structure

Each element module follows this pattern:

```lua
local ElementName = {}

function ElementName.Create(o, dependencies)
    -- Element creation logic
    return elementAPI
end

return ElementName
```

## Dependency Requirements

Each element module requires specific dependencies to be passed via the `dependencies` parameter:

### Common Dependencies (Used by Most Elements)
- `card` - Function to create card container frames
- `corner` - Function to add rounded corners (UICorner)
- `stroke` - Function to add borders (UIStroke)
- `shadow` - Function to add shadows
- `gradient` - Function to add gradients (UIGradient)
- `pal3` - Current theme palette (color scheme)
- `Animator` - Animation system with Spring presets
- `RvrseUI` - Main RvrseUI instance (for Store, Flags, _lockListeners, _autoSave)
- `UIS` - UserInputService reference

### Element-Specific Dependencies

#### 1. **Button.lua**
Dependencies: `card`, `pal3`, `UIS`, `Animator`, `RvrseUI`
- Ripple animation on click
- Lock system integration
- Flag system support

#### 2. **Toggle.lua**
Dependencies: `card`, `corner`, `shadow`, `pal3`, `Animator`, `RvrseUI`
- iOS-style switch animation
- Dual lock modes (LockGroup controller + RespectLock responder)
- Auto-save on change

#### 3. **Dropdown.lua**
Dependencies: `card`, `corner`, `stroke`, `shadow`, `pal3`, `Animator`, `RvrseUI`, `UIS`
- Scrollable dropdown list with animation
- Click-outside-to-close behavior
- Refresh() method to update options dynamically
- Auto-save on change

#### 4. **Keybind.lua**
Dependencies: `card`, `corner`, `stroke`, `pal3`, `Animator`, `RvrseUI`, `UIS`
- Interactive key capture
- Special handling for UI toggle/escape keys
- Auto-save on change

#### 5. **Slider.lua**
Dependencies: `card`, `corner`, `shadow`, `gradient`, `pal3`, `Animator`, `RvrseUI`, `UIS`
- Premium UX with grow-on-grab + glow effects
- Draggable thumb with smooth animations
- Hover effects
- Auto-save on change

#### 6. **Label.lua**
Dependencies: `card`, `pal3`, `RvrseUI`
- Simple text display
- Flag system support

#### 7. **Paragraph.lua**
Dependencies: `card`, `pal3`, `RvrseUI`
- Multi-line text with auto-wrapping
- Auto-resizing on Set()
- Flag system support

#### 8. **Divider.lua**
Dependencies: `card`, `pal3`
- Visual separator line
- SetColor() method
- No flag system support

#### 9. **TextBox.lua**
Dependencies: `card`, `corner`, `stroke`, `pal3`, `Animator`, `RvrseUI`
- Adaptive input field
- Focus/blur animations
- Lock system integration
- Auto-save on focus lost

#### 10. **ColorPicker.lua**
Dependencies: `card`, `corner`, `stroke`, `pal3`, `Animator`, `RvrseUI`
- Color cycling through 8 preset colors
- Click to cycle
- Auto-save on change
- Lock system integration

## API Methods

### Common Methods (All Elements)
- `SetVisible(visible)` - Show/hide the element

### Element-Specific Methods

**Button:**
- `SetText(text)` - Update button text
- `CurrentValue` - Current button text

**Toggle:**
- `Set(state)` - Set toggle state (boolean)
- `Get()` - Get current state
- `Refresh()` - Update visual state
- `CurrentValue` - Current boolean state

**Dropdown:**
- `Set(value)` - Set selected value (from values list)
- `Get()` - Get current selected value
- `Refresh(newValues)` - Update dropdown options list
- `CurrentOption` - Current selected value

**Keybind:**
- `Set(keyCode)` - Set keybind (Enum.KeyCode)
- `Get()` - Get current keybind
- `CurrentKeybind` - Current Enum.KeyCode

**Slider:**
- `Set(value)` - Set slider value (number)
- `Get()` - Get current value
- `CurrentValue` - Current numeric value

**Label:**
- `Set(text)` - Update label text
- `Get()` - Get current text
- `CurrentValue` - Current text

**Paragraph:**
- `Set(text)` - Update paragraph text (auto-resizes)
- `Get()` - Get current text
- `CurrentValue` - Current text

**Divider:**
- `SetColor(color)` - Change divider line color

**TextBox:**
- `Set(text)` - Set input text
- `Get()` - Get current text
- `CurrentValue` - Current text

**ColorPicker:**
- `Set(color)` - Set color (Color3)
- `Get()` - Get current color
- `CurrentValue` - Current Color3

## Integration Notes

### Lock System
Elements with `RespectLock` parameter:
- Register with `RvrseUI._lockListeners` for visual updates
- Check lock state via `RvrseUI.Store:IsLocked(lockGroup)`
- Disable interactions when locked

Elements with `LockGroup` parameter (Toggle only):
- Control the lock state via `RvrseUI.Store:SetLocked(group, state)`

### Flag System
Elements with `Flag` parameter:
- Register with `RvrseUI.Flags[flagName] = elementAPI`
- Allow global access to element methods

### Auto-Save
Elements that trigger auto-save:
- Toggle, Dropdown, Keybind, Slider, TextBox, ColorPicker
- Call `RvrseUI:_autoSave()` when value changes

### Callbacks
Elements with callback support:
- **Button:** `Callback` - Fired on click
- **Toggle:** `OnChanged(state)` - Fired on state change
- **Dropdown:** `OnChanged(value)` - Fired on selection change
- **Keybind:** `OnChanged(keyCode)` - Fired on key set
- **Slider:** `OnChanged(value)` - Fired on value change
- **TextBox:** `OnChanged(text, enterPressed)` - Fired on focus lost
- **ColorPicker:** `OnChanged(color)` - Fired on color change

## Extraction Details

All elements were extracted from `d:\RvrseUI\RvrseUI.lua`:
- **Button**: Lines 2711-2763
- **Toggle**: Lines 2766-2853
- **Dropdown**: Lines 2856-3246
- **Keybind**: Lines 3249-3352
- **Slider**: Lines 3355-3522
- **Label**: Lines 3525-3557
- **Paragraph**: Lines 3560-3601
- **Divider**: Lines 3604-3624
- **TextBox**: Lines 3627-3701
- **ColorPicker**: Lines 3704-3789

All functionality has been preserved exactly as in the original implementation.
