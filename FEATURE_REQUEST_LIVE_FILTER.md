# 🚀 Feature Request: Live Filterable Element Lists

## Summary

**Request**: Add support for dynamically filtering/updating UI element lists (buttons, labels, etc.) based on user input in real-time.

**Priority**: High - Multiple users have requested this as a "must-have" feature.

**Use Case**: Item Fetcher systems, player lists, inventory displays, and any scenario where users need to search/filter through a large list of clickable items.

---

## The Problem

### Current Limitation

RvrseUI currently does not support:
1. **Dynamically removing** elements from a Section after creation
2. **Dynamically adding** elements to an existing Section after initial build
3. **Live filtering** of button lists as the user types

### Real-World Scenario

In our SurvivalHub script, we have an **Item Fetcher** feature that displays buttons for each item type in the game world (e.g., "Log", "Fuel Canister", "Meat", etc.). 

Users requested the ability to:
1. Type in a search box (e.g., "log")
2. See the button list **instantly filter** to only show matching items
3. Click the filtered result to bring the item

### Current Workaround

We're forced to use a Dropdown as a pseudo-filter:
```lua
section:CreateDropdown({
    Text = "Search Items",
    Values = itemNames,  -- Can't update this list dynamically
    OnChanged = function(selected)
        -- Bring the selected item
    end
})
```

**Problems with this workaround:**
- Dropdown requires clicking to open, then typing
- Users expect a text input that filters a visible button list
- Less intuitive UX compared to live filtering
- Can't refresh the Values without recreating the entire dropdown

---

## Proposed Solutions

### Option 1: Section:Clear() and Section:Rebuild()

Add methods to clear and rebuild a section's contents:

```lua
-- Clear all elements from section
Section:Clear()

-- Then re-add only filtered elements
for _, item in ipairs(filteredItems) do
    Section:CreateButton({
        Text = item.name,
        Callback = function() ... end
    })
end
```

**API Addition:**
```lua
Section:Clear()  -- Removes all child elements from section
```

---

### Option 2: Filterable Button Group Element

Create a new element type specifically for filterable lists:

```lua
Section:CreateFilterableList({
    Text = "Search Items",
    PlaceholderText = "Type to filter...",
    Items = {
        { Text = "Log", Icon = "lucide://tree", Data = "log" },
        { Text = "Fuel Canister", Icon = "lucide://fuel", Data = "fuel" },
        { Text = "Meat", Icon = "lucide://beef", Data = "meat" },
    },
    OnItemClick = function(item)
        print("Clicked:", item.Data)
    end,
    OnFilter = function(query, items)
        -- Optional custom filter logic
        -- Default: case-insensitive contains match
    end
})
```

**Features:**
- Built-in text input at the top
- Live filtering as user types (debounced)
- Scrollable item list below
- Case-insensitive matching by default
- Support for custom filter functions

---

### Option 3: Element Visibility Toggle

Add ability to show/hide individual elements:

```lua
local button = Section:CreateButton({
    Text = "Log",
    Callback = function() ... end
})

-- Later, based on filter:
button:SetVisible(false)  -- Hide without destroying
button:SetVisible(true)   -- Show again
```

**API Addition:**
```lua
Element:SetVisible(visible: boolean)
Element:IsVisible(): boolean
```

---

### Option 4: Dynamic Values for All Elements

Extend the existing `:Refresh()` pattern to support full content updates:

```lua
local buttonGroup = Section:CreateButtonGroup({
    Buttons = initialButtons
})

-- On filter change:
buttonGroup:Refresh(filteredButtons)
```

---

## Implementation Priority

We recommend **Option 2 (Filterable Button Group)** as the primary solution because:

1. ✅ Encapsulates the entire filter UX in one element
2. ✅ Handles debouncing, scrolling, and rendering internally
3. ✅ Matches user expectations from modern UIs
4. ✅ Doesn't require changes to existing Section/Element architecture
5. ✅ Can be styled consistently with existing RvrseUI theme

**Option 1 (Section:Clear)** would be valuable as a secondary addition for advanced users who need full control.

---

## Example Use Cases

### 1. Item Fetcher (Our Use Case)
```lua
Section:CreateFilterableList({
    Text = "Search Items",
    Items = GetAllGameItems(),  -- Returns 50+ items
    OnItemClick = function(item)
        BringItemToPlayer(item.name)
    end
})
```

### 2. Player Teleport List
```lua
Section:CreateFilterableList({
    Text = "Find Player",
    Items = GetAllPlayers(),
    OnItemClick = function(player)
        TeleportToPlayer(player)
    end
})
```

### 3. Teleport Locations
```lua
Section:CreateFilterableList({
    Text = "Search Locations",
    Items = {
        { Text = "Camp Fire", Data = CFrame.new(...) },
        { Text = "Stronghold", Data = CFrame.new(...) },
        { Text = "Cave Entrance", Data = CFrame.new(...) },
        -- ... many more locations
    },
    OnItemClick = function(location)
        TeleportTo(location.Data)
    end
})
```

### 4. Script/Command Browser
```lua
Section:CreateFilterableList({
    Text = "Search Commands",
    Items = GetAllCommands(),
    OnItemClick = function(cmd)
        ExecuteCommand(cmd.name)
    end
})
```

---

## Technical Considerations

### Performance
- Debounce filter input (100-200ms delay) to avoid excessive re-renders
- Use virtual scrolling for lists > 50 items
- Cache filtered results to avoid re-filtering on scroll

### Accessibility
- Support keyboard navigation (arrow keys, Enter to select)
- Highlight matching text in results
- Show "No results" message when filter matches nothing

### Styling
- Match existing RvrseUI neon/cyber aesthetic
- Smooth fade animations for showing/hiding items
- Optional: highlight matched text portion

---

## Related Issues

- Large item lists cause UI lag when creating 50+ buttons
- Dropdown `:Refresh()` doesn't always update displayed text
- No way to update Section contents after `Window:Show()`

---

## Summary

Adding live filter support would significantly improve RvrseUI's capability for building production-quality UIs. The **Filterable Button Group** element would be the most impactful addition, providing a clean, encapsulated solution that matches modern UI expectations.

We're happy to help test any implementation or provide additional feedback!

---

**Submitted by**: SurvivalHub Team  
**Date**: December 2024  
**RvrseUI Version**: v4.3.31  
**Repository**: [RvrseUI-night-in-the-forest-99](https://github.com/CoderRvrse/RvrseUI-night-in-the-forest-99)
