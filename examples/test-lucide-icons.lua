-- Recompiled & Corrected: Lucide Icon Integration Test
-- Focus: Buttons & Labels alignment (lucide:// sprites, Unicode fallbacks, emoji)

local SOURCE_URL = "https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"

local success, RvrseUILib = pcall(function()
	return loadstring(game:HttpGet(SOURCE_URL))()
end)

if not success then
	warn("[Lucide Integration Test] Failed to load RvrseUI.lua:", RvrseUILib)
	return
end

local RvrseUI = RvrseUILib

-- Enable verbose logging so sprite sheet vs fallback resolution is obvious in the console
RvrseUI:EnableDebug(true)

local Window = RvrseUI:CreateWindow({
	Title = "Lucide Icon QA Harness",
	Icon = "lucide://sparkles",
	Size = UDim2.new(0, 640, 0, 520),
	Theme = "Dark",
	ConfigurationSaving = {
		Enabled = false
	}
})

local spriteStatus = _G.RvrseUI_LucideIconsData and "✅ Sprite sheet embedded" or "⚠️ Sprite sheet missing – Unicode fallbacks only"

-- Overview Tab --------------------------------------------------------------
local OverviewTab = Window:CreateTab({
	Title = "Overview",
	Icon = "lucide://info"
})

local IntroSection = OverviewTab:CreateSection("Quick Start")

IntroSection:CreateLabel({
	Text = "This harness loads lucide:// icons across Tabs, Buttons, Labels, and Notifications.",
	Icon = "lucide://book-open"
})

IntroSection:CreateLabel({
	Text = "Status: " .. spriteStatus,
	Icon = _G.RvrseUI_LucideIconsData and "lucide://check-circle-2" or "lucide://alert-triangle",
	Color = _G.RvrseUI_LucideIconsData and Color3.fromRGB(60, 220, 140) or Color3.fromRGB(255, 180, 90)
})

IntroSection:CreateButton({
	Text = "Trigger Lucide Notification",
	Icon = "lucide://bell",
	Callback = function()
		RvrseUI:Notify({
			Icon = "lucide://sparkles",
			Title = "Lucide Notification",
			Message = "Notifications now resolve lucide:// icons (sprites or Unicode fallback).",
			Duration = 2.5
		})
	end
})

local DocsSection = OverviewTab:CreateSection("Icon Formats")

local iconFormats = {
	{ label = "Lucide (sprite)", icon = "lucide://home" },
	{ label = "Lucide (fallback)", icon = "lucide://sparkles" },
	{ label = "Unicode (icon://)", icon = "icon://trophy" },
	{ label = "Direct Emoji", icon = "🔥" },
	{ label = "Roblox asset id", icon = "rbxassetid://16364871493" } -- 🔥 Valid Roblox icon asset
}

for _, format in ipairs(iconFormats) do
	DocsSection:CreateLabel({
		Text = format.label .. " → " .. format.icon,
		Icon = format.icon
	})
end

-- Buttons & Labels QA Tab ---------------------------------------------------
local QATab = Window:CreateTab({
	Title = "Buttons & Labels",
	Icon = "lucide://layout-dashboard"
})

local ButtonSection = QATab:CreateSection("Button Alignment (icon left, text offset)")

local buttonSamples = {
	{
		text = "Lucide sprite · lucide://home",
		icon = "lucide://home"
	},
	{
		text = "Lucide sprite · long label to ensure padding stays intact even with wrapping enabled",
		icon = "lucide://settings"
	},
	{
		text = "Unicode fallback · icon://trophy",
		icon = "icon://trophy"
	},
	{
		text = "Emoji direct · 🚀",
		icon = "🚀"
	},
	{
		text = "No icon (control sample)",
		icon = nil
	}
}

for _, sample in ipairs(buttonSamples) do
	local labelText = sample.text
	local iconRef = sample.icon

	ButtonSection:CreateButton({
		Text = labelText,
		Icon = iconRef,
		Callback = function()
			RvrseUI:Notify({
				Title = "Button Clicked",
				Message = labelText,
				Icon = iconRef or "lucide://mouse-pointer-2",
				Duration = 2
			})
		end
	})
end

local LabelSection = QATab:CreateSection("Label Alignment (icons + text wrap)")

local labelSamples = {
	{
		text = "Lucide sprite label (sparkles)",
		icon = "lucide://sparkles",
		color = Color3.fromRGB(180, 200, 255)
	},
	{
		text = "Lucide fallback label (settings)",
		icon = "lucide://settings",
		color = Color3.fromRGB(150, 255, 200)
	},
	{
		text = "Unicode label (icon://bell)",
		icon = "icon://bell",
		color = Color3.fromRGB(255, 220, 120)
	},
	{
		text = "Emoji label (❤️)",
		icon = "❤️"
	},
	{
		text = "Plain label (no icon) to confirm padding resets",
		icon = nil
	}
}

for _, sample in ipairs(labelSamples) do
	LabelSection:CreateLabel({
		Text = sample.text,
		Icon = sample.icon,
		Color = sample.color
	})
end

-- Gallery Tab ---------------------------------------------------------------
local GalleryTab = Window:CreateTab({
	Title = "Lucide Gallery",
	Icon = "lucide://grid-3x3"
})

local GallerySection = GalleryTab:CreateSection("Popular Icons")

local galleryIcons = {
	{ "lucide://home", "Home" },
	{ "lucide://menu", "Menu" },
	{ "lucide://search", "Search" },
	{ "lucide://bell", "Notifications" },
	{ "lucide://star", "Favorites" },
	{ "lucide://user", "Profile" },
	{ "lucide://settings", "Settings" },
	{ "lucide://heart", "Likes" },
	{ "lucide://lock", "Security" },
	{ "lucide://activity", "Analytics" }
}

for _, entry in ipairs(galleryIcons) do
	GallerySection:CreateButton({
		Text = entry[2] .. " (" .. entry[1] .. ")",
		Icon = entry[1],
		Callback = function()
			print("[Lucide Gallery] Clicked:", entry[1])
		end
	})
end

GallerySection:CreateDivider()

GallerySection:CreateLabel({
	Text = "Add more with lucide.dev icons list. All entries support lucide://name syntax.",
	Icon = "lucide://plus-circle"
})

-- Interactions Tab ----------------------------------------------------------
local InteractionsTab = Window:CreateTab({
	Title = "Interactive",
	Icon = "lucide://sliders-horizontal"
})

local InteractionSection = InteractionsTab:CreateSection("Element Coverage")

InteractionSection:CreateToggle({
	Text = "Enable Notifications",
	Icon = "lucide://bell",
	Default = true,
	Callback = function(enabled)
		RvrseUI.NotificationsEnabled = enabled
		RvrseUI:Notify({
			Icon = enabled and "lucide://check" or "lucide://x",
			Title = enabled and "Notifications Enabled" or "Notifications Disabled",
			Message = "Toggles also support lucide:// icons.",
			Duration = 2
		})
	end
})

InteractionSection:CreateDropdown({
	Text = "Choose Icon Theme",
	Icon = "lucide://palette",
	Options = { "Lucide Sprites", "Unicode Fallbacks", "Emoji Mix" },
	Default = "Lucide Sprites",
	Callback = function(choice)
		print("[Lucide Test] Selected:", choice)
	end
})

InteractionSection:CreateButton({
	Text = "Dispatch Demo Notification Queue",
	Icon = "lucide://inbox",
	Callback = function()
		local icons = { "lucide://check", "lucide://heart", "lucide://alert-triangle", "lucide://star" }

		for _, iconRef in ipairs(icons) do
			RvrseUI:Notify({
				Icon = iconRef,
				Title = "Notification",
				Message = "Queued from test harness",
				Duration = 1.75
			})
			task.wait(0.15)
		end
	end
})

print("[Lucide Integration Test] Harness ready. Use tabs to validate icon rendering across components.")
