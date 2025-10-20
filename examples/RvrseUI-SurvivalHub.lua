-- ═══════════════════════════════════════════════════════════════════
-- RvrseUI Home Module
-- Adds a Home tab with movement utilities (walk speed, jump height, infinite jump)
-- ═══════════════════════════════════════════════════════════════════

local SOURCE = "https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua"
local chunk, err = loadstring(game:HttpGet(SOURCE, true))
if not chunk then error("[RvrseUIHome] Failed to load RvrseUI: " .. tostring(err), 0) end
local RvrseUI = chunk()

local HomeHub = {}

HomeHub.Services = {
    Players = game:GetService("Players"),
    UserInputService = game:GetService("UserInputService"),
    Workspace = game:GetService("Workspace"),
    TweenService = game:GetService("TweenService"), -- reserved for future transitions
}

HomeHub.Config = {
    Window = {
        Name = "RvrseUI Home",
        Icon = "home",
        LoadingTitle = "RvrseUI Loader",
        LoadingSubtitle = "Preparing movement toolkit...",
        Theme = "Dark",
        ToggleUIKeybind = "K",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "RvrseUIHome",
            FileName = "Config.json",
            AutoSave = true
        }
    },
    Movement = {
        WalkSpeed = { Min = 16, Max = 100, Step = 2, Default = 16 },
        JumpHeight = { Min = 7, Max = 150, Step = 1, Default = 50 },
        InfiniteJumpStepHeight = 7.0
    }
}

local env = getgenv()
env.RvrseUIHomeState = env.RvrseUIHomeState or {}
local state = env.RvrseUIHomeState

state.WalkSpeed = state.WalkSpeed or HomeHub.Config.Movement.WalkSpeed.Default
state.JumpHeight = state.JumpHeight or HomeHub.Config.Movement.JumpHeight.Default
state.InfiniteJump = state.InfiniteJump or false

HomeHub.State = {
    LocalPlayer = HomeHub.Services.Players.LocalPlayer,
    Character = nil,
    Humanoid = nil,
    HRP = nil
}

HomeHub.UI = {
    Window = nil,
    HomeTab = nil,
    MovementSection = nil
}

-- ═══════════════════════════════════════════════════════════════════
-- Internal Helpers
-- ═══════════════════════════════════════════════════════════════════

function HomeHub:EnsureCharacter()
    local player = self.State.LocalPlayer
    if not player then return nil end
    if player.Character then return player.Character end
    local character = player.CharacterAdded:Wait()
    return character
end

function HomeHub:WireCharacter(character)
    if not character then return end
    self.State.Character = character
    self.State.Humanoid = character:WaitForChild("Humanoid")
    self.State.HRP = character:WaitForChild("HumanoidRootPart")

    self:ApplyWalkSpeed(state.WalkSpeed)
    self:ApplyJumpHeight(state.JumpHeight)
end

function HomeHub:ApplyWalkSpeed(speed)
    state.WalkSpeed = speed

    local function apply(char)
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speed
            return true
        end
        return false
    end

    local character = self.State.Character or self.State.LocalPlayer and self.State.LocalPlayer.Character
    if character and apply(character) then return end

    task.spawn(function()
        local char = self:EnsureCharacter()
        if char then
            apply(char)
        end
    end)
end

function HomeHub:ApplyJumpHeight(height)
    state.JumpHeight = height

    local humanoid = self.State.Humanoid or (self.State.Character and self.State.Character:FindFirstChildOfClass("Humanoid"))
    if humanoid then
        pcall(function()
            humanoid.UseJumpPower = false
            humanoid.JumpHeight = height
        end)
        return
    end

    task.spawn(function()
        local char = self:EnsureCharacter()
        if not char then return end
        local hum = char:WaitForChild("Humanoid")
        pcall(function()
            hum.UseJumpPower = false
            hum.JumpHeight = height
        end)
    end)
end

local function getJumpVelocity(workspaceService, stepHeight)
    if stepHeight <= 0 then return 0 end
    return math.sqrt(2 * workspaceService.Gravity * stepHeight)
end

function HomeHub:HandleInfiniteJump()
    if not state.InfiniteJump then return end

    local hrp = self.State.HRP
    local humanoid = self.State.Humanoid
    if not hrp or not humanoid then return end

    local addVelocity = getJumpVelocity(self.Services.Workspace, self.Config.Movement.InfiniteJumpStepHeight)
    local currentVelocity = hrp.AssemblyLinearVelocity
    if currentVelocity.Y < addVelocity then
        hrp.AssemblyLinearVelocity = Vector3.new(currentVelocity.X, addVelocity, currentVelocity.Z)
    end

    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end

function HomeHub:SetInfiniteJump(enabled, opts)
    state.InfiniteJump = enabled
    if opts and opts.silent then return end

    if enabled then
        RvrseUI:Notify({
            Title = "Infinite Jump Enabled",
            Message = "Jump freely in mid-air.",
            Type = "success",
            Duration = 3
        })
    else
        RvrseUI:Notify({
            Title = "Infinite Jump Disabled",
            Message = "Jump behavior restored.",
            Type = "info",
            Duration = 3
        })
    end
end

function HomeHub:BindInfiniteJump()
    self.Services.UserInputService.JumpRequest:Connect(function()
        self:HandleInfiniteJump()
    end)
end

function HomeHub:SetupCharacterHandlers()
    local player = self.State.LocalPlayer
    if not player then return end

    player.CharacterAdded:Connect(function(char)
        self:WireCharacter(char)
    end)

    if player.Character then
        task.spawn(function()
            self:WireCharacter(player.Character)
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- UI Construction
-- ═══════════════════════════════════════════════════════════════════

function HomeHub:BuildUI()
    self.UI.Window = RvrseUI:CreateWindow(self.Config.Window)
    self.UI.HomeTab = self.UI.Window:CreateTab({ Title = "Home", Icon = "home" })
    self.UI.MovementSection = self.UI.HomeTab:CreateSection("Movement Tools")

    self.UI.MovementSection:CreateSlider({
        Text = "Walk Speed",
        Min = self.Config.Movement.WalkSpeed.Min,
        Max = self.Config.Movement.WalkSpeed.Max,
        Step = self.Config.Movement.WalkSpeed.Step,
        Default = state.WalkSpeed,
        Flag = "WalkSpeed",
        OnChanged = function(speed)
            self:ApplyWalkSpeed(speed)
        end
    })

    self.UI.MovementSection:CreateSlider({
        Text = "Jump Height",
        Min = self.Config.Movement.JumpHeight.Min,
        Max = self.Config.Movement.JumpHeight.Max,
        Step = self.Config.Movement.JumpHeight.Step,
        Default = state.JumpHeight,
        Flag = "JumpHeight",
        OnChanged = function(height)
            self:ApplyJumpHeight(height)
        end
    })

    self.UI.MovementSection:CreateToggle({
        Text = "Infinite Jump",
        Default = state.InfiniteJump,
        Flag = "InfiniteJump",
        OnChanged = function(enabled)
            self:SetInfiniteJump(enabled)
        end
    })
end

-- ═══════════════════════════════════════════════════════════════════
-- Initialization
-- ═══════════════════════════════════════════════════════════════════

function HomeHub:Init()
    self:SetupCharacterHandlers()
    self:BindInfiniteJump()
    self:BuildUI()
    local ok, message = RvrseUI:LoadConfiguration()
    print("[RvrseUIHome] Config load:", ok, message)
end

HomeHub:Init()

return HomeHub
