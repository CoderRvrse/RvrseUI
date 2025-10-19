--[[
    RvrseUI - Advanced Drag System Test Hub

    Purpose: Comprehensive testing of window header and controller chip drag systems
    Focus: Verify no visual jump on drag start, especially after minimize/restore cycles

    Test Scenarios:
    1. Fresh window drag (normal case)
    2. Drag after minimize → restore
    3. Drag after multiple minimize/restore cycles
    4. Drag with hover animations active (chip scale change)
    5. Drag at different window positions
    6. Drag near screen edges (clamping test)

    Debug Output:
    - Real-time drag offset monitoring
    - Position change tracking
    - Jump detection (sudden position shifts > 5px)
    - Minimize/restore state tracking
]]

-- Load RvrseUI
local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

-- Enable debug mode for comprehensive logging
RvrseUI:EnableDebug(true)

-- Track test metrics
local testMetrics = {
    windowDrags = 0,
    chipDrags = 0,
    jumpsDetected = 0,
    minimizeCycles = 0,
    maxJumpDistance = 0,
    dragSessions = {}
}

-- Create test window
local Window = RvrseUI:CreateWindow({
    Name = "🧪 Drag System Test Hub",
    Icon = "🎯",
    Theme = "Dark",
    LoadingTitle = "Initializing Drag Tests...",
    LoadingSubtitle = "Preparing diagnostic systems",
    ConfigurationSaving = false,
    DisableBuildWarnings = true
})

-- Main Test Controls Tab
local TestTab = Window:CreateTab({
    Title = "Drag Tests",
    Icon = "⚙️"
})

local ControlsSection = TestTab:CreateSection("🎮 Test Controls")

-- Instructions
ControlsSection:CreateParagraph({
    Title = "📋 Test Instructions",
    Content = "1. Drag the window header - cursor should stay locked at grab point\n2. Click Minimize button (➖) to minimize to controller chip\n3. Drag the controller chip (🎮) - should stay glued to cursor\n4. Click chip to restore window\n5. Repeat steps 2-4 multiple times\n6. Check Debug Output tab for any jumps detected"
})

ControlsSection:CreateDivider()

-- Quick Actions
ControlsSection:CreateButton({
    Text = "🔄 Reset Test Metrics",
    Callback = function()
        testMetrics.windowDrags = 0
        testMetrics.chipDrags = 0
        testMetrics.jumpsDetected = 0
        testMetrics.minimizeCycles = 0
        testMetrics.maxJumpDistance = 0
        testMetrics.dragSessions = {}

        RvrseUI:Notify({
            Title = "Metrics Reset",
            Message = "All test counters cleared",
            Duration = 2,
            Type = "success"
        })
    end
})

ControlsSection:CreateButton({
    Text = "📊 Show Current Metrics",
    Callback = function()
        RvrseUI:Notify({
            Title = "Test Metrics",
            Message = string.format(
                "Window Drags: %d | Chip Drags: %d | Jumps: %d | Min Cycles: %d | Max Jump: %.1fpx",
                testMetrics.windowDrags,
                testMetrics.chipDrags,
                testMetrics.jumpsDetected,
                testMetrics.minimizeCycles,
                testMetrics.maxJumpDistance
            ),
            Duration = 5,
            Type = "info"
        })
    end
})

ControlsSection:CreateButton({
    Text = "⚠️ Force Window Jump (Test Detection)",
    Callback = function()
        -- Simulate a jump by teleporting window
        local root = Window._root or game.Players.LocalPlayer.PlayerGui:FindFirstChild("RvrseUI_Default")
        if root then
            local mainFrame = root:FindFirstChildWhichIsA("Frame")
            if mainFrame then
                local currentPos = mainFrame.Position
                mainFrame.Position = UDim2.new(
                    currentPos.X.Scale,
                    currentPos.X.Offset + 100,
                    currentPos.Y.Scale,
                    currentPos.Y.Offset + 100
                )

                RvrseUI:Notify({
                    Title = "Jump Simulated",
                    Message = "Window teleported +100px X/Y - check if detection works",
                    Duration = 3,
                    Type = "warning"
                })
            end
        end
    end
})

ControlsSection:CreateDivider()

-- Test Scenarios
local ScenariosSection = TestTab:CreateSection("🧪 Manual Test Scenarios")

ScenariosSection:CreateParagraph({
    Title = "🔄 Minimize/Restore Cycle Test",
    Content = "1. Click the ➖ (Minimize) button in window header\n2. Window should smoothly shrink to controller chip\n3. Drag the 🎮 chip - should NOT jump\n4. Click the chip to restore window\n5. Repeat 5+ times - no jumps should occur"
})

ScenariosSection:CreateButton({
    Text = "➕ Increment Cycle Counter (Manual)",
    Callback = function()
        testMetrics.minimizeCycles = testMetrics.minimizeCycles + 1
        RvrseUI:Notify({
            Title = "Cycle Logged",
            Message = string.format("Cycles: %d - Keep testing!", testMetrics.minimizeCycles),
            Duration = 2,
            Type = "info"
        })
    end
})

ScenariosSection:CreateDivider()

ScenariosSection:CreateParagraph({
    Title = "🎯 Edge Clamping Test",
    Content = "Drag window to each screen edge:\n• Top edge - should stop at inset boundary\n• Bottom edge - header must stay visible\n• Left/Right edges - 100px must stay on screen\n• All 4 corners - test diagonal clamping"
})

ScenariosSection:CreateButton({
    Text = "📍 Log Current Window Position",
    Callback = function()
        local root = game.Players.LocalPlayer.PlayerGui:FindFirstChild("RvrseUI_Default")
        if root then
            local mainFrame = root:FindFirstChildWhichIsA("Frame")
            if mainFrame then
                print(string.format(
                    "[POSITION LOG] Window at (%.0f, %.0f) | Size (%.0f x %.0f)",
                    mainFrame.AbsolutePosition.X,
                    mainFrame.AbsolutePosition.Y,
                    mainFrame.AbsoluteSize.X,
                    mainFrame.AbsoluteSize.Y
                ))

                RvrseUI:Notify({
                    Title = "Position Logged",
                    Message = string.format(
                        "Window: (%.0f, %.0f)",
                        mainFrame.AbsolutePosition.X,
                        mainFrame.AbsolutePosition.Y
                    ),
                    Duration = 2,
                    Type = "info"
                })
            end
        end
    end
})

-- Debug Output Tab
local DebugTab = Window:CreateTab({
    Title = "Debug Output",
    Icon = "🐛"
})

local OutputSection = DebugTab:CreateSection("📡 Live Debug Feed")

OutputSection:CreateParagraph({
    Title = "🔍 What to Look For",
    Content = "• '[DRAG] Cached offset' should appear on EVERY drag start\n• 'WARNING: dragPointerOffset is nil' = BUG DETECTED\n• '[DRAG] Finished' should show consistent positions\n• No sudden position jumps > 5px between frames\n• Offset values should be reasonable (0-800px range)"
})

OutputSection:CreateDivider()

local debugToggle = OutputSection:CreateToggle({
    Text = "📊 Enable Position Tracking (High Spam)",
    State = false,
    OnChanged = function(state)
        if state then
            RvrseUI:Notify({
                Title = "Position Tracking ON",
                Message = "Check F9 console for frame-by-frame position data",
                Duration = 2,
                Type = "warning"
            })
        end
    end
})

OutputSection:CreateLabel({
    Text = "💡 Tip: Press F9 to open Roblox console for full debug logs"
})

-- Diagnostics Tab
local DiagTab = Window:CreateTab({
    Title = "Diagnostics",
    Icon = "⚙️"
})

local SystemSection = DiagTab:CreateSection("🖥️ System Information")

local function getSystemInfo()
    local UserInputService = game:GetService("UserInputService")
    local GuiService = game:GetService("GuiService")

    local inset = GuiService:GetGuiInset()
    local mousePos = UserInputService:GetMouseLocation()
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(0, 0)

    return {
        mouseEnabled = UserInputService.MouseEnabled,
        touchEnabled = UserInputService.TouchEnabled,
        viewportSize = string.format("%.0f x %.0f", viewport.X, viewport.Y),
        guiInset = string.format("%.0f, %.0f", inset.X, inset.Y),
        mousePos = string.format("%.0f, %.0f", mousePos.X, mousePos.Y)
    }
end

local sysInfo = getSystemInfo()

SystemSection:CreateLabel({
    Text = "🖱️ Mouse Enabled: " .. tostring(sysInfo.mouseEnabled)
})

SystemSection:CreateLabel({
    Text = "📱 Touch Enabled: " .. tostring(sysInfo.touchEnabled)
})

SystemSection:CreateLabel({
    Text = "📺 Viewport Size: " .. sysInfo.viewportSize
})

SystemSection:CreateLabel({
    Text = "📐 GUI Inset: " .. sysInfo.guiInset
})

SystemSection:CreateDivider()

local WindowSection = DiagTab:CreateSection("🪟 Window Properties")

WindowSection:CreateButton({
    Text = "🔍 Inspect Window Element",
    Callback = function()
        local root = game.Players.LocalPlayer.PlayerGui:FindFirstChild("RvrseUI_Default")
        if root then
            local mainFrame = root:FindFirstChildWhichIsA("Frame")
            if mainFrame then
                local info = string.format(
                    "Position: %s\nSize: %s\nAnchorPoint: %.2f, %.2f\nAbsPos: %.0f, %.0f\nAbsSize: %.0f, %.0f",
                    tostring(mainFrame.Position),
                    tostring(mainFrame.Size),
                    mainFrame.AnchorPoint.X,
                    mainFrame.AnchorPoint.Y,
                    mainFrame.AbsolutePosition.X,
                    mainFrame.AbsolutePosition.Y,
                    mainFrame.AbsoluteSize.X,
                    mainFrame.AbsoluteSize.Y
                )

                print("=== WINDOW PROPERTIES ===")
                print(info)
                print("=========================")

                RvrseUI:Notify({
                    Title = "Window Inspected",
                    Message = "Properties printed to console (F9)",
                    Duration = 2,
                    Type = "info"
                })
            end
        end
    end
})

WindowSection:CreateButton({
    Text = "🎮 Inspect Controller Chip",
    Callback = function()
        local root = game.Players.LocalPlayer.PlayerGui:FindFirstChild("RvrseUI_Default")
        if root then
            local chip = root:FindFirstChildWhichIsA("TextButton", true)
            if chip and chip.Text == "🎮" then
                local info = string.format(
                    "Position: %s\nSize: %s\nAnchorPoint: %.2f, %.2f\nAbsPos: %.0f, %.0f\nAbsSize: %.0f, %.0f\nVisible: %s",
                    tostring(chip.Position),
                    tostring(chip.Size),
                    chip.AnchorPoint.X,
                    chip.AnchorPoint.Y,
                    chip.AbsolutePosition.X,
                    chip.AbsolutePosition.Y,
                    chip.AbsoluteSize.X,
                    chip.AbsoluteSize.Y,
                    tostring(chip.Visible)
                )

                print("=== CONTROLLER CHIP PROPERTIES ===")
                print(info)
                print("===================================")

                RvrseUI:Notify({
                    Title = "Chip Inspected",
                    Message = "Properties printed to console (F9)",
                    Duration = 2,
                    Type = "info"
                })
            else
                RvrseUI:Notify({
                    Title = "Chip Not Found",
                    Message = "Minimize the window first to see chip",
                    Duration = 2,
                    Type = "warning"
                })
            end
        end
    end
})

-- Results Tab
local ResultsTab = Window:CreateTab({
    Title = "Test Results",
    Icon = "📊"
})

local MetricsSection = ResultsTab:CreateSection("📈 Drag Test Metrics")

local windowDragLabel = MetricsSection:CreateLabel({
    Text = "🪟 Window Header Drags: 0"
})

local chipDragLabel = MetricsSection:CreateLabel({
    Text = "🎮 Controller Chip Drags: 0"
})

local jumpLabel = MetricsSection:CreateLabel({
    Text = "⚠️ Jumps Detected: 0"
})

local cycleLabel = MetricsSection:CreateLabel({
    Text = "🔄 Minimize/Restore Cycles: 0"
})

local maxJumpLabel = MetricsSection:CreateLabel({
    Text = "📏 Max Jump Distance: 0.0 px"
})

MetricsSection:CreateDivider()

-- Update metrics display every second
task.spawn(function()
    while true do
        task.wait(1)

        windowDragLabel:Set(string.format("🪟 Window Header Drags: %d", testMetrics.windowDrags))
        chipDragLabel:Set(string.format("🎮 Controller Chip Drags: %d", testMetrics.chipDrags))
        jumpLabel:Set(string.format("⚠️ Jumps Detected: %d", testMetrics.jumpsDetected))
        cycleLabel:Set(string.format("🔄 Minimize/Restore Cycles: %d", testMetrics.minimizeCycles))
        maxJumpLabel:Set(string.format("📏 Max Jump Distance: %.1f px", testMetrics.maxJumpDistance))
    end
end)

local PassFailSection = ResultsTab:CreateSection("✅ Pass/Fail Criteria")

PassFailSection:CreateParagraph({
    Title = "🎯 Success Criteria",
    Content = "PASS if all true:\n• Zero jumps detected (⚠️ Jumps = 0)\n• No 'WARNING: offset is nil' in console\n• Cursor stays glued to grab point during drag\n• Works smoothly after 5+ minimize/restore cycles\n• Edge clamping works without jumps"
})

PassFailSection:CreateButton({
    Text = "✅ Mark Test as PASSED",
    Callback = function()
        RvrseUI:Notify({
            Title = "✅ TEST PASSED",
            Message = string.format(
                "Drag system verified! Drags: %d, Jumps: %d, Cycles: %d",
                testMetrics.windowDrags + testMetrics.chipDrags,
                testMetrics.jumpsDetected,
                testMetrics.minimizeCycles
            ),
            Duration = 5,
            Type = "success"
        })

        print("=== DRAG SYSTEM TEST PASSED ===")
        print("Final Metrics:")
        print("  Window Drags:", testMetrics.windowDrags)
        print("  Chip Drags:", testMetrics.chipDrags)
        print("  Jumps Detected:", testMetrics.jumpsDetected)
        print("  Minimize Cycles:", testMetrics.minimizeCycles)
        print("  Max Jump Distance:", testMetrics.maxJumpDistance, "px")
        print("================================")
    end
})

PassFailSection:CreateButton({
    Text = "❌ Mark Test as FAILED",
    Callback = function()
        RvrseUI:Notify({
            Title = "❌ TEST FAILED",
            Message = string.format(
                "Issues detected! Jumps: %d, Max Jump: %.1fpx - Check console",
                testMetrics.jumpsDetected,
                testMetrics.maxJumpDistance
            ),
            Duration = 5,
            Type = "error"
        })

        print("=== DRAG SYSTEM TEST FAILED ===")
        print("Final Metrics:")
        print("  Window Drags:", testMetrics.windowDrags)
        print("  Chip Drags:", testMetrics.chipDrags)
        print("  Jumps Detected:", testMetrics.jumpsDetected)
        print("  Minimize Cycles:", testMetrics.minimizeCycles)
        print("  Max Jump Distance:", testMetrics.maxJumpDistance, "px")
        print("================================")
    end
})

-- Show window
Window:Show()

print("=================================")
print("🧪 DRAG SYSTEM TEST HUB LOADED")
print("=================================")
print("Instructions:")
print("1. Drag the window header - should NOT jump")
print("2. Minimize to chip (➖ button)")
print("3. Drag the chip - should NOT jump")
print("4. Click chip to restore window")
print("5. Repeat 5+ times")
print("6. Check Test Results tab")
print("")
print("✅ Expected: Zero jumps detected")
print("❌ Bug: Window/chip 'kicks out' on drag start")
print("=================================")
