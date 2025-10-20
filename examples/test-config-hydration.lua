-- RvrseUI Config Hydration Demo
-- Shows how restored configs now auto-fire OnChanged callbacks (v4.3.2+)

local RvrseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"))()

local env = getgenv()
env.SurvivalDemo = env.SurvivalDemo or {
    WalkSpeed = 24,
    AutoLoot = false,
    Accent = Color3.fromRGB(255, 170, 60),
    Motto = "Stay alive!"
}

local Demo = {}

function Demo:ApplyWalkSpeed(value)
    env.SurvivalDemo.WalkSpeed = value
    local character = game.Players.LocalPlayer.Character
    if character and character:FindFirstChildOfClass("Humanoid") then
        character:FindFirstChildOfClass("Humanoid").WalkSpeed = value
    end
end

function Demo:Init()
    local window = RvrseUI:CreateWindow({
        Name = "Config Hydration Demo",
        Theme = "Dark",
        ToggleUIKeybind = "K",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "RvrseUI-Demos",
            FileName = "Hydration.json"
        }
    })

    local mainTab = window:CreateTab({ Title = "Main", Icon = "lucide://activity" })
    local section = mainTab:CreateSection("Character")
    section:CreateDivider("Core Settings")

    section:CreateSlider({
        Text = "Walk Speed",
        Min = 10,
        Max = 32,
        Default = env.SurvivalDemo.WalkSpeed,
        Flag = "DemoWalkSpeed",
        OnChanged = function(value)
            self:ApplyWalkSpeed(value)
        end
    })

    section:CreateToggle({
        Text = "Auto Loot",
        Default = env.SurvivalDemo.AutoLoot,
        Flag = "DemoAutoLoot",
        OnChanged = function(enabled)
            env.SurvivalDemo.AutoLoot = enabled
            print("[Hydration Demo] Auto Loot:", enabled)
        end
    })

    section:CreateColorPicker({
        Text = "Accent",
        Default = env.SurvivalDemo.Accent,
        Flag = "DemoAccent",
        OnChanged = function(color)
            env.SurvivalDemo.Accent = color
            print("[Hydration Demo] Accent RGB:", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
        end
    })

    section:CreateTextBox({
        Text = "Squad Motto",
        Placeholder = "Stay alive!",
        Default = env.SurvivalDemo.Motto,
        Flag = "DemoMotto",
        OnChanged = function(text)
            env.SurvivalDemo.Motto = text
            print("[Hydration Demo] Motto:", text)
        end
    })

    window:Show()

    local ok, message = RvrseUI:LoadConfiguration()
    print("[Hydration Demo] LoadConfig:", ok, message)
end

Demo:Init()
