# RvrseUI v2.2.0 - Complete Element Documentation

## ALL 12 ELEMENTS

### 1. BUTTON
**Purpose**: Clickable action trigger

**API**:
```lua
local MyButton = Section:CreateButton({
	Text = "Click Me",
	Callback = function()
		print("Button clicked!")
	end,
	Flag = "MyButton",  -- Optional: Access via RvrseUI.Flags["MyButton"]
	RespectLock = "GroupName"  -- Optional: Disabled when lock active
})

-- Methods
MyButton:SetText("New Text")
-- Properties
MyButton.CurrentValue  -- Button text
```

### 2. TOGGLE
**Purpose**: On/Off switch with iOS-style animation

**API**:
```lua
local MyToggle = Section:CreateToggle({
	Text = "Enable Feature",
	State = false,  -- Initial state
	OnChanged = function(state)
		print("Toggle:", state)
	end,
	Flag = "MyToggle",
	LockGroup = "GroupName",  -- Optional: Controls lock (master)
	RespectLock = "GroupName"  -- Optional: Respects lock (child)
})

-- Methods
MyToggle:Set(true)  -- Set state
MyToggle:Get()  -- Get state
MyToggle:Refresh()  -- Update visual
-- Properties
MyToggle.CurrentValue  -- Current boolean state
```

###3. DROPDOWN
**Purpose**: Cycle through value options

**API**:
```lua
local MyDropdown = Section:CreateDropdown({
	Text = "Select Mode",
	Values = {"Easy", "Medium", "Hard"},
	Default = "Medium",
	OnChanged = function(value)
		print("Selected:", value)
	end,
	Flag = "MyDropdown",
	RespectLock = "GroupName"
})

-- Methods
MyDropdown:Set("Hard")  -- Set value (triggers callback)
MyDropdown:Get()  -- Get current value
MyDropdown:Refresh({"New", "Values"})  -- Update options list
-- Properties
MyDropdown.CurrentOption  -- Current selected value
```

### 4. SLIDER
**Purpose**: Numeric value selection with draggable thumb

**API**:
```lua
local MySlider = Section:CreateSlider({
	Text = "Speed",
	Min = 0,
	Max = 100,
	Step = 5,
	Default = 50,
	OnChanged = function(value)
		print("Slider:", value)
	end,
	Flag = "MySlider",
	RespectLock = "GroupName"
})

-- Methods
MySlider:Set(75)  -- Set value
MySlider:Get()  -- Get value
-- Properties
MySlider.CurrentValue  -- Current numeric value
```

### 5. KEYBIND
**Purpose**: Interactive key capture

**API**:
```lua
local MyKeybind = Section:CreateKeybind({
	Text = "Execute Hotkey",
	Default = Enum.KeyCode.E,
	OnChanged = function(key)
		print("Keybind set to:", key.Name)
	end,
	Flag = "MyKeybind",
	RespectLock = "GroupName"
})

-- Methods
MyKeybind:Set(Enum.KeyCode.Q)  -- Set keybind (triggers callback)
MyKeybind:Get()  -- Get KeyCode
-- Properties
MyKeybind.CurrentKeybind  -- Current Enum.KeyCode
```

### 6. TEXTBOX (Adaptive Input)
**Purpose**: Text input field

**API**:
```lua
local MyTextBox = Section:CreateTextBox({
	Text = "Username",
	Placeholder = "Enter username...",
	Default = "Player123",
	OnChanged = function(text, enterPressed)
		print("Text:", text, "Enter:", enterPressed)
	end,
	Flag = "MyTextBox",
	RespectLock = "GroupName"
})

-- Methods
MyTextBox:Set("NewText")  -- Set text
MyTextBox:Get()  -- Get text
-- Properties
MyTextBox.CurrentValue  -- Current text string
```

### 7. COLORPICKER
**Purpose**: Color selection (cycles through 8 presets)

**API**:
```lua
local MyColorPicker = Section:CreateColorPicker({
	Text = "Theme Color",
	Default = Color3.fromRGB(99, 102, 241),
	OnChanged = function(color)
		print("Color:", color)
	end,
	Flag = "MyColorPicker",
	RespectLock = "GroupName"
})

-- Methods
MyColorPicker:Set(Color3.fromRGB(255, 0, 0))  -- Set color
MyColorPicker:Get()  -- Get Color3
-- Properties
MyColorPicker.CurrentValue  -- Current Color3
```

### 8. LABEL
**Purpose**: Simple text display

**API**:
```lua
local MyLabel = Section:CreateLabel({
	Text = "Status: Ready",
	Flag = "MyLabel"
})

-- Methods
MyLabel:Set("Status: Updated")  -- Update text
MyLabel:Get()  -- Get text
-- Properties
MyLabel.CurrentValue  -- Current text
```

### 9. PARAGRAPH
**Purpose**: Multi-line text with auto-wrapping

**API**:
```lua
local MyParagraph = Section:CreateParagraph({
	Text = "This is a long paragraph with multiple lines...",
	Flag = "MyParagraph"
})

-- Methods
MyParagraph:Set("New paragraph text")  -- Update text (auto-resizes)
MyParagraph:Get()  -- Get text
-- Properties
MyParagraph.CurrentValue  -- Current text
```

### 10. DIVIDER
**Purpose**: Visual separator line

**API**:
```lua
local MyDivider = Section:CreateDivider()

-- Methods
MyDivider:SetColor(Color3.fromRGB(255, 255, 255))  -- Change color
```

### 11. SECTION
**Purpose**: Container for elements within a tab

**API**:
```lua
local MySection = Tab:CreateSection("Section Title")

-- Then create elements:
MySection:CreateButton({...})
MySection:CreateToggle({...})
MySection:CreateDropdown({...})
MySection:CreateSlider({...})
MySection:CreateKeybind({...})
MySection:CreateTextBox({...})
MySection:CreateColorPicker({...})
MySection:CreateLabel({...})
MySection:CreateParagraph({...})
MySection:CreateDivider()
```

### 12. TAB
**Purpose**: Top-level navigation container

**API**:
```lua
local MyTab = Window:CreateTab({
	Title = "Main",
	Icon = "home"  -- Unicode icon name, asset ID, or emoji
})

-- Then create sections:
local Section1 = MyTab:CreateSection("Section 1")
local Section2 = MyTab:CreateSection("Section 2")
```

## GLOBAL SYSTEMS

### Flags System
Access any flagged element globally:
```lua
-- Create with Flag
local Toggle = Section:CreateToggle({ Text = "Test", Flag = "MyToggle" })

-- Access anywhere
RvrseUI.Flags["MyToggle"]:Set(true)
RvrseUI.Flags["MyToggle"]:Get()  -- Returns: true
```

### Lock Groups
Master/Child control relationships:
```lua
-- MASTER: Controls the lock
Section:CreateToggle({
	Text = "Auto Mode (MASTER)",
	LockGroup = "AutoMode"  -- When ON, locks children
})

-- CHILDREN: Respect the lock
Section:CreateToggle({
	Text = "Option A",
	RespectLock = "AutoMode"  -- Disabled when master is ON
})

Section:CreateSlider({
	Text = "Speed",
	RespectLock = "AutoMode"  -- Also disabled
})
```

### CurrentValue Properties
Check element values without callbacks:
```lua
print(MyToggle.CurrentValue)  -- boolean
print(MyDropdown.CurrentOption)  -- string
print(MySlider.CurrentValue)  -- number
print(MyKeybind.CurrentKeybind)  -- Enum.KeyCode
print(MyTextBox.CurrentValue)  -- string
print(MyColorPicker.CurrentValue)  -- Color3
print(MyLabel.CurrentValue)  -- string
```

### Dropdown:Refresh()
Update dropdown options dynamically:
```lua
local Dropdown = Section:CreateDropdown({
	Values = {"Easy", "Medium", "Hard"}
})

-- Later, refresh with new values:
Dropdown:Refresh({"Beginner", "Intermediate", "Expert", "Master"})
```

## COMPLETE EXAMPLE

```lua
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

local Window = RvrseUI:CreateWindow({ Name = "Test", Icon = "game" })
local Tab = Window:CreateTab({ Title = "Main", Icon = "home" })
local Section = Tab:CreateSection("Elements")

-- 1. Button
Section:CreateButton({
	Text = "Click",
	Callback = function() print("Clicked!") end,
	Flag = "Btn"
})

-- 2. Toggle
local Toggle = Section:CreateToggle({
	Text = "Enable",
	State = false,
	OnChanged = function(s) print(s) end,
	Flag = "Tgl"
})

-- 3. Dropdown
local Dropdown = Section:CreateDropdown({
	Text = "Mode",
	Values = {"A", "B", "C"},
	Default = "B",
	OnChanged = function(v) print(v) end,
	Flag = "Drop"
})

-- 4. Slider
local Slider = Section:CreateSlider({
	Text = "Value",
	Min = 0,
	Max = 100,
	Default = 50,
	OnChanged = function(v) print(v) end,
	Flag = "Slide"
})

-- 5. Keybind
local Keybind = Section:CreateKeybind({
	Text = "Hotkey",
	Default = Enum.KeyCode.E,
	OnChanged = function(k) print(k.Name) end,
	Flag = "Key"
})

-- 6. TextBox
local TextBox = Section:CreateTextBox({
	Text = "Name",
	Placeholder = "Enter...",
	Default = "User",
	OnChanged = function(t) print(t) end,
	Flag = "Text"
})

-- 7. ColorPicker
local ColorPicker = Section:CreateColorPicker({
	Text = "Color",
	Default = Color3.fromRGB(255, 0, 0),
	OnChanged = function(c) print(c) end,
	Flag = "Color"
})

-- 8. Label
local Label = Section:CreateLabel({
	Text = "Status: OK",
	Flag = "Label"
})

-- 9. Paragraph
local Para = Section:CreateParagraph({
	Text = "Long text here...",
	Flag = "Para"
})

-- 10. Divider
Section:CreateDivider()

-- Update elements
Toggle:Set(true)
Dropdown:Set("C")
Slider:Set(75)
Label:Set("Status: Updated")

-- Check values
print(Toggle:Get())  -- true
print(Toggle.CurrentValue)  -- true
print(Dropdown.CurrentOption)  -- "C"
print(Slider.CurrentValue)  -- 75

-- Access via Flags
RvrseUI.Flags["Tgl"]:Set(false)
print(RvrseUI.Flags["Drop"]:Get())  -- "C"

-- Refresh dropdown
Dropdown:Refresh({"X", "Y", "Z"})
```
