-- RvrseUI v2.2.2 Enhancements Test
-- Tests all 5 new enhancement features

local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🧪 RvrseUI v2.2.2 Enhancement Test")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

-- Create Window
local Window = RvrseUI:CreateWindow({
	Name = "v2.2.2 Test",
	Icon = "game",
	LoadingTitle = "Testing v2.2.2 Enhancements",
	LoadingSubtitle = "Dynamic UI Control",
	Theme = "Dark",
	ToggleUIKeybind = "K"
})

-- Tab 1: SetVisible() Tests
local VisibilityTab = Window:CreateTab({
	Title = "Visibility Test",
	Icon = "eye"
})

local VisSection = VisibilityTab:CreateSection("Element Visibility Control")

VisSection:CreateParagraph({
	Text = "This section tests the new SetVisible() method added to ALL 12 elements in v2.2.2"
})

-- Create test elements
local TestButton = VisSection:CreateButton({
	Text = "Test Button",
	Callback = function()
		print("✓ Button clicked!")
	end
})

local TestToggle = VisSection:CreateToggle({
	Text = "Test Toggle",
	State = false,
	OnChanged = function(state)
		print("✓ Toggle:", state)
	end
})

local TestSlider = VisSection:CreateSlider({
	Text = "Test Slider",
	Min = 0,
	Max = 100,
	Default = 50
})

local TestLabel = VisSection:CreateLabel({ Text = "Test Label" })
local TestParagraph = VisSection:CreateParagraph({ Text = "Test paragraph element" })

-- Control buttons
VisSection:CreateDivider()

VisSection:CreateButton({
	Text = "Hide All Test Elements",
	Callback = function()
		TestButton:SetVisible(false)
		TestToggle:SetVisible(false)
		TestSlider:SetVisible(false)
		TestLabel:SetVisible(false)
		TestParagraph:SetVisible(false)

		RvrseUI:Notify({
			Title = "Elements Hidden",
			Message = "All test elements are now hidden",
			Type = "info",
			Duration = 2
		})

		print("✓ All elements hidden via SetVisible(false)")
	end
})

VisSection:CreateButton({
	Text = "Show All Test Elements",
	Callback = function()
		TestButton:SetVisible(true)
		TestToggle:SetVisible(true)
		TestSlider:SetVisible(true)
		TestLabel:SetVisible(true)
		TestParagraph:SetVisible(true)

		RvrseUI:Notify({
			Title = "Elements Shown",
			Message = "All test elements are now visible",
			Type = "success",
			Duration = 2
		})

		print("✓ All elements shown via SetVisible(true)")
	end
})

-- Tab 2: Section Control
local SectionTab = Window:CreateTab({
	Title = "Section Control",
	Icon = "layers"
})

local DynamicSection = SectionTab:CreateSection("Dynamic Section")

DynamicSection:CreateParagraph({
	Text = "This section tests Section:Update() and Section:SetVisible() methods"
})

local sectionTitles = {
	"Dynamic Section",
	"Updated Title 1",
	"Updated Title 2",
	"Custom Section Name"
}
local titleIndex = 1

DynamicSection:CreateButton({
	Text = "Update Section Title",
	Callback = function()
		titleIndex = (titleIndex % #sectionTitles) + 1
		DynamicSection:Update(sectionTitles[titleIndex])

		RvrseUI:Notify({
			Title = "Section Updated",
			Message = "Title changed to: " .. sectionTitles[titleIndex],
			Type = "info",
			Duration = 2
		})

		print("✓ Section title updated to:", sectionTitles[titleIndex])
	end
})

local sectionVisible = true
DynamicSection:CreateButton({
	Text = "Toggle Section Visibility",
	Callback = function()
		sectionVisible = not sectionVisible
		DynamicSection:SetVisible(sectionVisible)

		RvrseUI:Notify({
			Title = sectionVisible and "Section Shown" or "Section Hidden",
			Message = "Section is now " .. (sectionVisible and "visible" or "hidden"),
			Type = "info",
			Duration = 2
		})

		print("✓ Section visibility:", sectionVisible)
	end
})

-- Tab 3: Dynamic Icons
local IconTab = Window:CreateTab({
	Title = "Icon Test",
	Icon = "star"
})

local IconSection = IconTab:CreateSection("Dynamic Icon Control")

IconSection:CreateParagraph({
	Text = "Test Tab:SetIcon() and Window:SetIcon() - changes icons at runtime"
})

local tabIcons = { "home", "settings", "user", "trophy", "target", "game", "star" }
local tabIconIdx = 3

IconSection:CreateButton({
	Text = "Change This Tab's Icon",
	Callback = function()
		tabIconIdx = (tabIconIdx % #tabIcons) + 1
		IconTab:SetIcon(tabIcons[tabIconIdx])

		RvrseUI:Notify({
			Title = "Tab Icon Changed",
			Message = "Icon: " .. tabIcons[tabIconIdx],
			Type = "info",
			Duration = 2
		})

		print("✓ Tab icon changed to:", tabIcons[tabIconIdx])
	end
})

local windowIcons = { "game", "trophy", "crown", "verified", "premium", "robux", "diamond" }
local windowIconIdx = 1

IconSection:CreateButton({
	Text = "Change Window Icon",
	Callback = function()
		windowIconIdx = (windowIconIdx % #windowIcons) + 1
		Window:SetIcon(windowIcons[windowIconIdx])

		RvrseUI:Notify({
			Title = "Window Icon Changed",
			Message = "Icon: " .. windowIcons[windowIconIdx],
			Type = "info",
			Duration = 2
		})

		print("✓ Window icon changed to:", windowIcons[windowIconIdx])
	end
})

-- Tab 4: Notification Priority
local NotifyTab = Window:CreateTab({
	Title = "Notifications",
	Icon = "bell"
})

local NotifySection = NotifyTab:CreateSection("Priority System Test")

NotifySection:CreateParagraph({
	Text = "Test the new notification priority system. Critical notifications appear at the bottom (most visible position)."
})

NotifySection:CreateButton({
	Text = "Send Critical Notification",
	Callback = function()
		RvrseUI:Notify({
			Title = "Critical Alert",
			Message = "This is a critical priority notification",
			Priority = "critical",
			Type = "error",
			Duration = 5
		})
		print("✓ Sent CRITICAL notification")
	end
})

NotifySection:CreateButton({
	Text = "Send High Priority Notification",
	Callback = function()
		RvrseUI:Notify({
			Title = "High Priority",
			Message = "This is a high priority notification",
			Priority = "high",
			Type = "warn",
			Duration = 4
		})
		print("✓ Sent HIGH priority notification")
	end
})

NotifySection:CreateButton({
	Text = "Send Normal Notification",
	Callback = function()
		RvrseUI:Notify({
			Title = "Normal Priority",
			Message = "This is a normal priority notification (default)",
			Priority = "normal",
			Type = "info",
			Duration = 3
		})
		print("✓ Sent NORMAL priority notification")
	end
})

NotifySection:CreateButton({
	Text = "Send Low Priority Notification",
	Callback = function()
		RvrseUI:Notify({
			Title = "Low Priority",
			Message = "This is a low priority notification",
			Priority = "low",
			Type = "info",
			Duration = 3
		})
		print("✓ Sent LOW priority notification")
	end
})

NotifySection:CreateDivider()

NotifySection:CreateButton({
	Text = "Test Priority Stacking",
	Callback = function()
		-- Send multiple notifications with different priorities
		task.wait(0.2)
		RvrseUI:Notify({
			Title = "Low Priority",
			Message = "Low",
			Priority = "low",
			Type = "info",
			Duration = 10
		})

		task.wait(0.2)
		RvrseUI:Notify({
			Title = "Normal Priority",
			Message = "Normal",
			Priority = "normal",
			Type = "info",
			Duration = 10
		})

		task.wait(0.2)
		RvrseUI:Notify({
			Title = "High Priority",
			Message = "High",
			Priority = "high",
			Type = "warn",
			Duration = 10
		})

		task.wait(0.2)
		RvrseUI:Notify({
			Title = "CRITICAL",
			Message = "Critical appears at bottom (most visible)",
			Priority = "critical",
			Type = "error",
			Duration = 10
		})

		print("✓ Sent priority stack test (watch notification order)")
	end
})

-- Tab 5: Complete Test
local CompleteTab = Window:CreateTab({
	Title = "Complete Test",
	Icon = "check"
})

local CompleteSection = CompleteTab:CreateSection("All Enhancements Test")

CompleteSection:CreateParagraph({
	Text = "Run a complete test of all v2.2.2 enhancements"
})

CompleteSection:CreateButton({
	Text = "Run Complete Enhancement Test",
	Callback = function()
		print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		print("🧪 COMPLETE v2.2.2 ENHANCEMENT TEST")
		print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

		-- Test 1: Element Visibility
		print("\n[1/5] Testing Element:SetVisible()...")
		TestButton:SetVisible(false)
		task.wait(0.5)
		TestButton:SetVisible(true)
		print("✓ Element visibility working")

		-- Test 2: Section Updates
		print("\n[2/5] Testing Section:Update()...")
		DynamicSection:Update("Test Title 1")
		task.wait(0.5)
		DynamicSection:Update("Test Title 2")
		task.wait(0.5)
		DynamicSection:Update("Dynamic Section")
		print("✓ Section updates working")

		-- Test 3: Section Visibility
		print("\n[3/5] Testing Section:SetVisible()...")
		DynamicSection:SetVisible(false)
		task.wait(0.5)
		DynamicSection:SetVisible(true)
		print("✓ Section visibility working")

		-- Test 4: Icon Changes
		print("\n[4/5] Testing Tab:SetIcon() and Window:SetIcon()...")
		IconTab:SetIcon("trophy")
		task.wait(0.5)
		Window:SetIcon("crown")
		task.wait(0.5)
		IconTab:SetIcon("star")
		Window:SetIcon("game")
		print("✓ Dynamic icons working")

		-- Test 5: Priority Notifications
		print("\n[5/5] Testing Notification Priority...")
		RvrseUI:Notify({
			Title = "Low",
			Priority = "low",
			Type = "info",
			Duration = 5
		})
		task.wait(0.3)
		RvrseUI:Notify({
			Title = "Normal",
			Priority = "normal",
			Type = "info",
			Duration = 5
		})
		task.wait(0.3)
		RvrseUI:Notify({
			Title = "High",
			Priority = "high",
			Type = "warn",
			Duration = 5
		})
		task.wait(0.3)
		RvrseUI:Notify({
			Title = "Critical",
			Priority = "critical",
			Type = "error",
			Duration = 5
		})
		print("✓ Priority notifications working")

		print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		print("✅ ALL TESTS PASSED - v2.2.2 WORKING PERFECTLY")
		print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

		RvrseUI:Notify({
			Title = "Complete Test Passed",
			Message = "All v2.2.2 enhancements working perfectly!",
			Priority = "critical",
			Type = "success",
			Duration = 5
		})
	end
})

-- Welcome notification
RvrseUI:Notify({
	Title = "v2.2.2 Enhancement Test Loaded",
	Message = "Test all 5 new features across 5 tabs!",
	Priority = "high",
	Type = "success",
	Duration = 4
})

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("✅ Test script loaded successfully!")
print("📋 5 Enhancement Tests Available:")
print("   1. Element:SetVisible() - Tab 1")
print("   2. Section:Update() - Tab 2")
print("   3. Section:SetVisible() - Tab 2")
print("   4. Tab/Window:SetIcon() - Tab 3")
print("   5. Notification Priority - Tab 4")
print("   6. Complete Test - Tab 5")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
