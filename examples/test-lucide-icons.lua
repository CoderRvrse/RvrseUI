-- TEST: Lucide Icon Integration
-- Demonstrates the new lucide:// protocol for using Lucide icons in RvrseUI
-- https://lucide.dev/icons - Browse 500+ available icons

local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

-- Enable debug mode to see Lucide icon resolution
RvrseUI:EnableDebug(true)

local Window = RvrseUI:CreateWindow({
	Title = "Lucide Icons Demo",
	Icon = "lucide://sparkles",  -- ✨ Using Lucide icon for window!
	Size = UDim2.new(0, 600, 0, 450),
	Theme = "Dark",
	ConfigurationSaving = {
		Enabled = false
	}
})

-- Tab 1: Icon Formats Comparison
local Tab1 = Window:CreateTab({
	Title = "Icon Formats",
	Icon = "lucide://palette"  -- Using Lucide icon for tab
})

local Section1 = Tab1:CreateSection({
	Title = "Icon Format Comparison",
	Side = "Left"
})

Section1:CreateLabel({
	Text = "RvrseUI supports 4 icon formats:",
	Color = Color3.fromRGB(255, 255, 255)
})

-- 1. Lucide Icons (NEW!)
Section1:CreateButton({
	Text = "Lucide Icon (lucide://home)",
	Icon = "lucide://home",
	Callback = function()
		RvrseUI:Notify("Lucide Icon", "Using lucide:// protocol → Unicode fallback", 2)
	end
})

Section1:CreateButton({
	Text = "Lucide Icon (lucide://settings)",
	Icon = "lucide://settings",
	Callback = function()
		RvrseUI:Notify("Lucide Icon", "lucide://settings → ⚙", 2)
	end
})

Section1:CreateButton({
	Text = "Lucide Icon (lucide://arrow-right)",
	Icon = "lucide://arrow-right",
	Callback = function()
		RvrseUI:Notify("Lucide Icon", "lucide://arrow-right → →", 2)
	end
})

-- 2. Unicode Icons (Built-in)
Section1:CreateButton({
	Text = "Unicode Icon (icon://trophy)",
	Icon = "icon://trophy",
	Callback = function()
		RvrseUI:Notify("Unicode Icon", "Using icon:// protocol → 🏆", 2)
	end
})

-- 3. Direct Emoji
Section1:CreateButton({
	Text = "Direct Emoji (🚀)",
	Icon = "🚀",
	Callback = function()
		RvrseUI:Notify("Direct Emoji", "Passed through as-is", 2)
	end
})

-- 4. Roblox Asset ID (if you upload custom icons)
Section1:CreateButton({
	Text = "Roblox Asset (rbxassetid://123456)",
	Icon = "rbxassetid://123456789",  -- Example - won't load without valid ID
	Callback = function()
		RvrseUI:Notify("Asset ID", "Use for custom uploaded icons", 2)
	end
})

-- Tab 2: Lucide Icon Gallery
local Tab2 = Window:CreateTab({
	Title = "Lucide Gallery",
	Icon = "lucide://grid-3x3"
})

local Section2 = Tab2:CreateSection({
	Title = "Popular Lucide Icons",
	Side = "Left"
})

Section2:CreateLabel({
	Text = "Navigation & UI",
	Color = Color3.fromRGB(100, 180, 255)
})

local navIcons = {
	{"lucide://home", "Home"},
	{"lucide://menu", "Menu"},
	{"lucide://search", "Search"},
	{"lucide://settings", "Settings"},
	{"lucide://x", "Close"},
	{"lucide://check", "Check"},
}

for _, iconData in ipairs(navIcons) do
	Section2:CreateButton({
		Text = iconData[2] .. " (" .. iconData[1] .. ")",
		Icon = iconData[1],
		Callback = function()
			print("Clicked:", iconData[1])
		end
	})
end

Section2:CreateDivider()

Section2:CreateLabel({
	Text = "Arrows & Directions",
	Color = Color3.fromRGB(100, 255, 180)
})

local arrowIcons = {
	{"lucide://arrow-up", "Arrow Up"},
	{"lucide://arrow-down", "Arrow Down"},
	{"lucide://arrow-left", "Arrow Left"},
	{"lucide://arrow-right", "Arrow Right"},
	{"lucide://chevron-up", "Chevron Up"},
	{"lucide://chevron-down", "Chevron Down"},
}

for _, iconData in ipairs(arrowIcons) do
	Section2:CreateButton({
		Text = iconData[2],
		Icon = iconData[1],
		Callback = function()
			print("Clicked:", iconData[1])
		end
	})
end

-- Tab 3: Interactive Elements with Lucide Icons
local Tab3 = Window:CreateTab({
	Title = "Elements",
	Icon = "lucide://box"
})

local Section3 = Tab3:CreateSection({
	Title = "UI Elements with Lucide Icons",
	Side = "Left"
})

Section3:CreateToggle({
	Text = "Notifications Enabled",
	Icon = "lucide://bell",
	Default = true,
	Callback = function(value)
		RvrseUI:Notify(
			value and "lucide://check" or "lucide://x",
			"Notifications " .. (value and "enabled" or "disabled"),
			2
		)
	end
})

Section3:CreateToggle({
	Text = "Auto-Save Config",
	Icon = "lucide://save",
	Default = false,
	Callback = function(value)
		print("Auto-save:", value)
	end
})

Section3:CreateToggle({
	Text = "Show FPS Counter",
	Icon = "lucide://activity",
	Default = true,
	Callback = function(value)
		print("FPS counter:", value)
	end
})

Section3:CreateDivider()

Section3:CreateDropdown({
	Text = "Select Theme",
	Icon = "lucide://palette",
	Options = {"Dark", "Light", "Midnight", "Ocean"},
	Default = "Dark",
	Callback = function(value)
		RvrseUI:Notify("lucide://palette", "Theme: " .. value, 2)
	end
})

Section3:CreateDropdown({
	Text = "Server Region",
	Icon = "lucide://globe",
	Options = {"NA East", "NA West", "EU", "Asia", "Oceania"},
	Default = "NA East",
	Callback = function(value)
		print("Region:", value)
	end
})

-- Tab 4: Icon Documentation
local Tab4 = Window:CreateTab({
	Title = "Documentation",
	Icon = "lucide://book-open"
})

local Section4 = Tab4:CreateSection({
	Title = "How to Use Lucide Icons",
	Side = "Left"
})

Section4:CreateParagraph({
	Title = "What are Lucide Icons?",
	Content = [[
Lucide is a beautiful, consistent icon set with 500+ icons. RvrseUI now supports Lucide icons via the lucide:// protocol.

Browse all available icons at: https://lucide.dev/icons
]]
})

Section4:CreateParagraph({
	Title = "How to Use",
	Content = [[
1. Find an icon at https://lucide.dev/icons
2. Copy the icon name (e.g., "home", "settings")
3. Use it in RvrseUI with the lucide:// protocol:
   Icon = "lucide://home"
   Icon = "lucide://arrow-right"
   Icon = "lucide://sparkles"
]]
})

Section4:CreateParagraph({
	Title = "How It Works",
	Content = [[
Lucide icons are SVG-based and not directly supported in Roblox. RvrseUI automatically converts them to:

1. Unicode fallbacks (for common icons)
2. Roblox asset IDs (if you upload custom assets)
3. Or displays the icon name as text

To use custom Lucide SVGs, upload them as Roblox ImageAssets and add them to LucideIcons.AssetMap in the source code.
]]
})

Section4:CreateParagraph({
	Title = "Icon Name Examples",
	Content = [[
lucide://home
lucide://settings
lucide://arrow-right
lucide://check-circle
lucide://alert-triangle
lucide://user
lucide://lock
lucide://heart
lucide://star
lucide://trophy

See full list: https://lucide.dev/icons
]]
})

Section4:CreateDivider()

Section4:CreateLabel({
	Text = "For Developers: Custom Asset Mapping",
	Color = Color3.fromRGB(255, 200, 100)
})

Section4:CreateParagraph({
	Title = "Upload Custom Icons (Advanced)",
	Content = [[
To use actual Lucide SVGs instead of Unicode fallbacks:

1. Download SVG from https://lucide.dev/icons
2. Convert to PNG/JPEG (Roblox doesn't support SVG)
3. Upload to Roblox as Decal/ImageAsset
4. Edit src/LucideIcons.lua:

LucideIcons.AssetMap = {
    ["home"] = 123456789,  -- Your asset ID
    ["settings"] = 987654321,
}

5. Rebuild: node build.js

Now lucide://home will use your custom asset!
]]
})

-- Tab 5: Status & Alerts
local Tab5 = Window:CreateTab({
	Title = "Status",
	Icon = "lucide://check-circle"
})

local Section5 = Tab5:CreateSection({
	Title = "Status Indicators with Lucide Icons",
	Side = "Left"
})

Section5:CreateButton({
	Text = "Success Notification",
	Icon = "lucide://check-circle",
	Callback = function()
		RvrseUI:Notify("lucide://check-circle", "Operation successful!", 3)
	end
})

Section5:CreateButton({
	Text = "Warning Notification",
	Icon = "lucide://alert-triangle",
	Callback = function()
		RvrseUI:Notify("lucide://alert-triangle", "Warning: Low health", 3)
	end
})

Section5:CreateButton({
	Text = "Error Notification",
	Icon = "lucide://x-circle",
	Callback = function()
		RvrseUI:Notify("lucide://x-circle", "Error: Connection lost", 3)
	end
})

Section5:CreateButton({
	Text = "Info Notification",
	Icon = "lucide://info",
	Callback = function()
		RvrseUI:Notify("lucide://info", "Server restart in 5 minutes", 3)
	end
})

Section5:CreateDivider()

Section5:CreateLabel({
	Text = "User Actions",
	Color = Color3.fromRGB(150, 200, 255)
})

Section5:CreateButton({
	Text = "Download Data",
	Icon = "lucide://download",
	Callback = function()
		RvrseUI:Notify("lucide://download", "Downloading...", 2)
	end
})

Section5:CreateButton({
	Text = "Upload Settings",
	Icon = "lucide://upload",
	Callback = function()
		RvrseUI:Notify("lucide://upload", "Uploading...", 2)
	end
})

Section5:CreateButton({
	Text = "Refresh Data",
	Icon = "lucide://refresh-cw",
	Callback = function()
		RvrseUI:Notify("lucide://refresh-cw", "Refreshing...", 2)
	end
})

Section5:CreateButton({
	Text = "Delete Account",
	Icon = "lucide://trash",
	Callback = function()
		RvrseUI:Notify("lucide://trash", "Are you sure?", 2)
	end
})

print("✨ Lucide Icons Demo loaded!")
print("📚 Browse icons at: https://lucide.dev/icons")
print("🎨 Total icons available: 500+")
print("📦 Using Unicode fallbacks for compatibility")
