-- FilterableList Element Test Script
-- Tests the new FilterableList element for live filtering functionality
-- RvrseUI v4.4.0

local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

-- Enable debug mode
RvrseUI:EnableDebug(true)

-- Create Window
local Window = RvrseUI:CreateWindow({
    Name = "FilterableList Test Hub",
    LoadingTitle = "RvrseUI v4.4.0",
    LoadingSubtitle = "Testing FilterableList Element",
    ToggleKey = Enum.KeyCode.RightShift,
    ConfigurationSaving = false
})

-- ============================================
-- TAB 1: Basic FilterableList Examples
-- ============================================
local BasicTab = Window:CreateTab({
    Name = "Basic Examples",
    Icon = "lucide://list"
})

local BasicSection = BasicTab:CreateSection("Simple String List")

-- Simple string array
BasicSection:CreateFilterableList({
    Text = "Fruits",
    PlaceholderText = "Search fruits...",
    Items = {
        "Apple", "Banana", "Cherry", "Date", "Elderberry",
        "Fig", "Grape", "Honeydew", "Kiwi", "Lemon",
        "Mango", "Nectarine", "Orange", "Papaya", "Quince"
    },
    MaxVisibleItems = 5,
    OnItemClick = function(item)
        RvrseUI:Notify({
            Title = "Fruit Selected",
            Message = "You picked: " .. item.Text,
            Type = "success",
            Duration = 3
        })
    end,
    Flag = "FruitsList"
})

-- ============================================
-- TAB 2: Item Fetcher Example (Use Case)
-- ============================================
local FetcherTab = Window:CreateTab({
    Name = "Item Fetcher",
    Icon = "lucide://package"
})

local FetcherSection = FetcherTab:CreateSection("Game Items")

-- Simulated game items with icons
local gameItems = {
    { Text = "Log", Icon = "lucide://tree-deciduous", Data = { type = "resource", id = 1 } },
    { Text = "Stone", Icon = "lucide://mountain", Data = { type = "resource", id = 2 } },
    { Text = "Iron Ore", Icon = "lucide://gem", Data = { type = "resource", id = 3 } },
    { Text = "Gold Ore", Icon = "lucide://coins", Data = { type = "resource", id = 4 } },
    { Text = "Coal", Icon = "lucide://flame", Data = { type = "resource", id = 5 } },
    { Text = "Fuel Canister", Icon = "lucide://fuel", Data = { type = "item", id = 6 } },
    { Text = "Meat", Icon = "lucide://beef", Data = { type = "food", id = 7 } },
    { Text = "Fish", Icon = "lucide://fish", Data = { type = "food", id = 8 } },
    { Text = "Water Bottle", Icon = "lucide://droplet", Data = { type = "food", id = 9 } },
    { Text = "Bandage", Icon = "lucide://heart-pulse", Data = { type = "medical", id = 10 } },
    { Text = "First Aid Kit", Icon = "lucide://briefcase-medical", Data = { type = "medical", id = 11 } },
    { Text = "Axe", Icon = "lucide://axe", Data = { type = "tool", id = 12 } },
    { Text = "Pickaxe", Icon = "lucide://pickaxe", Data = { type = "tool", id = 13 } },
    { Text = "Hammer", Icon = "lucide://hammer", Data = { type = "tool", id = 14 } },
    { Text = "Sword", Icon = "lucide://sword", Data = { type = "weapon", id = 15 } },
    { Text = "Bow", Icon = "lucide://target", Data = { type = "weapon", id = 16 } },
    { Text = "Arrows", Icon = "lucide://arrow-right", Data = { type = "ammo", id = 17 } },
    { Text = "Torch", Icon = "lucide://flame", Data = { type = "light", id = 18 } },
    { Text = "Lantern", Icon = "lucide://lamp", Data = { type = "light", id = 19 } },
    { Text = "Rope", Icon = "lucide://link", Data = { type = "utility", id = 20 } },
}

FetcherSection:CreateFilterableList({
    Text = "Search Items",
    PlaceholderText = "Type to find items...",
    Items = gameItems,
    MaxVisibleItems = 8,
    DebounceTime = 0.1,
    OnItemClick = function(item)
        RvrseUI:Notify({
            Title = "Item Fetched!",
            Message = string.format("Bringing %s to player...", item.Text),
            Type = "info",
            Duration = 3
        })
        print("[FETCHER] Would bring item:", item.Text, "Type:", item.Data.type, "ID:", item.Data.id)
    end,
    Flag = "ItemFetcher"
})

-- ============================================
-- TAB 3: Player List Example
-- ============================================
local PlayersTab = Window:CreateTab({
    Name = "Players",
    Icon = "lucide://users"
})

local PlayersSection = PlayersTab:CreateSection("Online Players")

-- Generate fake player list
local function generatePlayers()
    local players = {}
    local names = {
        "xX_ProGamer_Xx", "NoobMaster69", "CoolKid123", "DarkShadow",
        "NinjaWarrior", "PixelHero", "DragonSlayer", "StormRider",
        "CyberNinja", "ShadowHunter", "BlazeMaster", "FrostBite",
        "ThunderBolt", "IronWolf", "GhostRider", "StarDust"
    }
    for i, name in ipairs(names) do
        table.insert(players, {
            Text = name,
            Icon = "lucide://user",
            Data = { userId = 1000 + i, displayName = name }
        })
    end
    return players
end

local playerList = PlayersSection:CreateFilterableList({
    Text = "Find Player",
    PlaceholderText = "Search by username...",
    Items = generatePlayers(),
    MaxVisibleItems = 6,
    OnItemClick = function(player)
        RvrseUI:Notify({
            Title = "Teleporting",
            Message = "Teleporting to " .. player.Text .. "...",
            Type = "info",
            Duration = 3
        })
        print("[TELEPORT] Would teleport to:", player.Text, "UserID:", player.Data.userId)
    end,
    Flag = "PlayerList"
})

-- Refresh button
PlayersSection:CreateButton({
    Text = "Refresh Player List",
    Icon = "lucide://refresh-cw",
    Callback = function()
        playerList:SetItems(generatePlayers())
        RvrseUI:Notify({
            Title = "Refreshed",
            Message = "Player list updated!",
            Type = "success",
            Duration = 2
        })
    end
})

-- ============================================
-- TAB 4: Teleport Locations
-- ============================================
local TeleportTab = Window:CreateTab({
    Name = "Teleports",
    Icon = "lucide://map-pin"
})

local LocationsSection = TeleportTab:CreateSection("Map Locations")

LocationsSection:CreateFilterableList({
    Text = "Search Locations",
    PlaceholderText = "Find a location...",
    Items = {
        { Text = "Spawn Point", Icon = "lucide://home", Data = CFrame.new(0, 10, 0) },
        { Text = "Shop", Icon = "lucide://shopping-cart", Data = CFrame.new(100, 10, 50) },
        { Text = "Forest", Icon = "lucide://trees", Data = CFrame.new(-200, 10, 100) },
        { Text = "Mountain Peak", Icon = "lucide://mountain", Data = CFrame.new(0, 500, 300) },
        { Text = "Beach", Icon = "lucide://waves", Data = CFrame.new(400, 5, 0) },
        { Text = "Cave Entrance", Icon = "lucide://door-open", Data = CFrame.new(-100, 0, -200) },
        { Text = "Village Center", Icon = "lucide://building-2", Data = CFrame.new(150, 10, 150) },
        { Text = "Bridge", Icon = "lucide://minus", Data = CFrame.new(75, 20, -50) },
        { Text = "Lake", Icon = "lucide://droplets", Data = CFrame.new(-150, 5, 200) },
        { Text = "Tower", Icon = "lucide://building", Data = CFrame.new(200, 100, -100) },
        { Text = "Arena", Icon = "lucide://swords", Data = CFrame.new(0, 10, -300) },
        { Text = "Secret Base", Icon = "lucide://lock", Data = CFrame.new(-500, -50, -500) },
    },
    MaxVisibleItems = 6,
    OnItemClick = function(location)
        RvrseUI:Notify({
            Title = "Teleporting",
            Message = "Going to " .. location.Text,
            Type = "info",
            Duration = 2
        })
        print("[TELEPORT] Would teleport to:", location.Text, "CFrame:", tostring(location.Data))
    end,
    Flag = "LocationsList"
})

-- ============================================
-- TAB 5: API Testing
-- ============================================
local APITab = Window:CreateTab({
    Name = "API Tests",
    Icon = "lucide://code"
})

local APISection = APITab:CreateSection("FilterableList API")

-- Create a test list for API manipulation
local testList = APISection:CreateFilterableList({
    Text = "Dynamic List",
    PlaceholderText = "Search...",
    Items = { "Item 1", "Item 2", "Item 3" },
    MaxVisibleItems = 5,
    OnItemClick = function(item)
        print("Clicked:", item.Text)
    end,
    Flag = "TestList"
})

-- API Controls
APISection:CreateButton({
    Text = "Add Random Item",
    Icon = "lucide://plus",
    Callback = function()
        local newItem = "New Item " .. math.random(100, 999)
        testList:AddItem(newItem)
        RvrseUI:Notify({
            Title = "Item Added",
            Message = newItem,
            Type = "success",
            Duration = 2
        })
    end
})

APISection:CreateButton({
    Text = "Remove First Item",
    Icon = "lucide://minus",
    Callback = function()
        local items = testList:GetItems()
        if #items > 0 then
            testList:RemoveItem(items[1].Text)
            RvrseUI:Notify({
                Title = "Item Removed",
                Message = items[1].Text,
                Type = "warning",
                Duration = 2
            })
        end
    end
})

APISection:CreateButton({
    Text = "Clear All Items",
    Icon = "lucide://trash-2",
    Callback = function()
        testList:Clear()
        RvrseUI:Notify({
            Title = "Cleared",
            Message = "All items removed",
            Type = "error",
            Duration = 2
        })
    end
})

APISection:CreateButton({
    Text = "Reset with 10 Items",
    Icon = "lucide://refresh-cw",
    Callback = function()
        local newItems = {}
        for i = 1, 10 do
            table.insert(newItems, { Text = "Reset Item " .. i, Icon = "lucide://star" })
        end
        testList:SetItems(newItems)
        RvrseUI:Notify({
            Title = "Reset",
            Message = "List reset with 10 items",
            Type = "info",
            Duration = 2
        })
    end
})

APISection:CreateButton({
    Text = "Set Query to 'Item'",
    Icon = "lucide://search",
    Callback = function()
        testList:SetQuery("Item")
    end
})

APISection:CreateButton({
    Text = "Get Count",
    Icon = "lucide://hash",
    Callback = function()
        local filtered, total = testList:GetCount()
        RvrseUI:Notify({
            Title = "Count",
            Message = string.format("Showing %d of %d items", filtered, total),
            Type = "info",
            Duration = 3
        })
    end
})

-- ============================================
-- TAB 6: Custom Filter Example
-- ============================================
local CustomTab = Window:CreateTab({
    Name = "Custom Filter",
    Icon = "lucide://filter"
})

local CustomSection = CustomTab:CreateSection("Advanced Filtering")

-- Custom filter that only matches items starting with query
CustomSection:CreateFilterableList({
    Text = "Starts With Filter",
    PlaceholderText = "Type prefix...",
    NoResultsText = "No items start with that prefix",
    Items = {
        "Apple", "Apricot", "Avocado",
        "Banana", "Blueberry", "Blackberry",
        "Cherry", "Cranberry", "Coconut"
    },
    MaxVisibleItems = 5,
    OnFilter = function(query, item)
        -- Custom filter: only match if item starts with query
        return item.Text:lower():sub(1, #query) == query:lower()
    end,
    OnItemClick = function(item)
        print("Selected:", item.Text)
    end
})

-- Case-sensitive filter example
CustomSection:CreateFilterableList({
    Text = "Case Sensitive Filter",
    PlaceholderText = "Exact case matching...",
    CaseSensitive = true,
    Items = {
        "Apple", "APPLE", "apple",
        "Banana", "BANANA", "banana",
        "Cherry", "CHERRY", "cherry"
    },
    MaxVisibleItems = 5,
    OnItemClick = function(item)
        print("Selected:", item.Text)
    end
})

print("[FilterableList Test] All tabs created successfully!")
print("[FilterableList Test] Press RightShift to toggle UI")
