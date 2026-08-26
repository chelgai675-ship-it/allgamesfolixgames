-- ======================================================
-- MAX EDITION & DEEPSEEK ALL GAMES — CLEAN FIX
-- ======================================================
-- TouchFling удалён.
-- Fly НЕ изменён (но логика мобильного управления оптимизирована).
-- Fly не включается автоматически после респавна.
-- После респавна команда "fly" снова работает.
-- Исправлены Noclip / Invisible / Reset / Weather /
-- Respawn / Unload / Spin / Console connections.
-- ======================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local Cheat = {
    Config = {
        SpeedValue = 16,
        SpinSpeed = 10,
        RainbowOffset = 0,
        FlySpeed = 70,
    },

    Flags = {
        Fly = false,
        Noclip = false,
        ESP = false,
        InfiniteJump = false,
        AntiAFK = false,
        Saitama = false,
        AutoClick = false,
        Spin = false,
        Sit = false,
        Freeze = false,
        GodMode = false,
        Invisible = false,
        MM2Aimbot = false,
        MM2AutoShoot = false,
    },

    Runtime = {
        Connections = {},
        ESPTexts = {},
        ESPHighlights = {},
        ESPCharacterConnections = {},

        FlyBodyVelocity = nil,
        FreezeBV = nil,

        ConsoleVisible = false,

        CommandHistory = {},
        HistoryIndex = 0,

        JumpConnection = nil,
        NoclipConnection = nil,
        FlyRenderConnection = nil,
        GodModeConnection = nil,

        SpinThread = nil,

        OriginalWalkSpeed = nil,

        NoclipOriginalCollision = {},
        OriginalTransparency = {},

        ConsoleInputConnection = nil,
        ConsoleTabConnection = nil,

        WeatherFolder = nil,
        WeatherPart = nil,
    }
}

local GUI
local InputBox
local OutputScrolling
local SuggestionLabel
local Cmds = {}
local MobileButton

local LastRightShiftPress = 0
local RightShiftPressCount = 0

local IsMobile =
    UserInputService.TouchEnabled
    and not UserInputService.KeyboardEnabled

local IsDesktop = UserInputService.KeyboardEnabled

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ======================================================
-- MOBILE FLY JOYSTICK (Simplified/Optimized)
-- ======================================================

local JoyGui = Instance.new("ScreenGui")
JoyGui.Name = "FlyJoystick"
JoyGui.ResetOnSpawn = false
JoyGui.Enabled = false
JoyGui.Parent = PlayerGui

local JoyFrame = Instance.new("Frame")
JoyFrame.Size = UDim2.new(0, 120, 0, 120)
JoyFrame.Position = UDim2.new(0.02, 0, 0.5, -60)
JoyFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
JoyFrame.BackgroundTransparency = 0.5
JoyFrame.BorderSizePixel = 2
JoyFrame.BorderColor3 = Color3.fromRGB(80, 80, 150)
JoyFrame.Parent = JoyGui

local JoyStick = Instance.new("Frame")
JoyStick.Size = UDim2.new(0, 40, 0, 40)
JoyStick.Position = UDim2.new(0.5, -20, 0.5, -20)
JoyStick.BackgroundColor3 = Color3.fromRGB(200, 200, 255)
JoyStick.BackgroundTransparency = 0.3
JoyStick.BorderSizePixel = 2
JoyStick.BorderColor3 = Color3.fromRGB(255, 255, 255)
JoyStick.Parent = JoyFrame

local JoyActive = false
local ActiveTouch

local function ResetJoystick()
    JoyActive = false
    ActiveTouch = nil

    JoyStick.Position =
        UDim2.new(0.5, -20, 0.5, -20)
end

-- Touch Input Handlers (Kept for active stick dragging)
JoyFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        JoyActive = true
        ActiveTouch = input
    end
end)

UserInputService.TouchMoved:Connect(function(input)
    if not JoyActive or input ~= ActiveTouch then
        return
    end

    local center =
        JoyFrame.AbsolutePosition
        + JoyFrame.AbsoluteSize / 2

    local delta = input.Position - center
    local maxDist = 40

    -- Clamp movement to the joystick size (40x40)
    if delta.Magnitude > maxDist then
        delta = delta.Unit * maxDist
    end

    JoyStick.Position = UDim2.new(
        0.5,
        delta.X - 20, -- Center offset X - half stick size
        0.5,
        delta.Y - 20  -- Center offset Y - half stick size
    )
end)

UserInputService.TouchEnded:Connect(function(input)
    if input == ActiveTouch then
        ResetJoystick()
    end
end)

local UpBtn = Instance.new("TextButton")
UpBtn.Size = UDim2.new(0, 50, 0, 50)
UpBtn.Position = UDim2.new(0.85, 0, 0.7, 0)
UpBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
UpBtn.Text = "⬆"
UpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UpBtn.TextScaled = true
UpBtn.Font = Enum.Font.GothamBold
UpBtn.Parent = JoyGui

local DownBtn = Instance.new("TextButton")
DownBtn.Size = UDim2.new(0, 50, 0, 50)
DownBtn.Position = UDim2.new(0.85, 0, 0.82, 0)
DownBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
DownBtn.Text = "⬇"
DownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DownBtn.TextScaled = true
DownBtn.Font = Enum.Font.GothamBold
DownBtn.Parent = JoyGui

local FlyUpActive = false
local FlyDownActive = false

-- Button Input Handlers (Vertical control)
UpBtn.MouseButton1Down:Connect(function()
    FlyUpActive = true
end)

UpBtn.MouseButton1Up:Connect(function()
    FlyUpActive = false
end)

DownBtn.MouseButton1Down:Connect(function()
    FlyDownActive = true
end)

DownBtn.MouseButton1Up:Connect(function()
    FlyDownActive = false
end)

-- ======================================================
-- SETTINGS
-- ======================================================

local SettingsFile = "max_settings.json"

local function SaveSettings()
    local settings = {
        speed = Cheat.Config.SpeedValue,

        esp = Cheat.Flags.ESP,
        fly = false, -- Note: Fly state is reset on load, but we save the default/last known state here
        noclip = Cheat.Flags.Noclip,
        saitama = Cheat.Flags.Saitama,
    }

    pcall(function()
        if writefile then
            writefile(
                SettingsFile,
                HttpService:JSONEncode(settings)
            )
        end
    end)
end

local function LoadSettings()
    local success, data = pcall(function()
        if not readfile then
            return nil
        end

        return readfile(SettingsFile)
    end)

    if success and data then
        local ok, settings = pcall(function()
            return HttpService:JSONDecode(data)
        end)

        if ok and type(settings) == "table" then
            Cheat.Config.SpeedValue =
                tonumber(settings.speed) or 16
        end
    end

    -- Initialize flags to default state upon loading settings
    Cheat.Flags.Fly = false
    Cheat.Flags.ESP = false
    Cheat.Flags.Noclip = false
    Cheat.Flags.Saitama = false
end

LoadSettings()

-- ======================================================
-- HELPERS
-- ======================================================

local function GetCharacter()
    return LocalPlayer.Character
end

local function GetHumanoid()
    local char = GetCharacter()

    return char
        and char:FindFirstChildOfClass("Humanoid")
end

local function GetRoot()
    local char = GetCharacter()

    return char
        and char:FindFirstChild("HumanoidRootPart")
end

local function RainbowColor(offset)
    local r = math.sin(offset) * 0.5 + 0.5
    local g = math.sin(offset + 2.094) * 0.5 + 0.5
    local b = math.sin(offset + 4.188) * 0.5 + 0.5

    return Color3.fromRGB(
        math.floor(r * 255),
        math.floor(g * 255),
        math.floor(b * 255)
    )
end

-- ======================================================
-- SAITAMA
-- ======================================================

local function RemoveSaitamaEffect()
    local char = GetCharacter()

    if not char then
        return
    end

    for _, obj in ipairs(char:GetDescendants()) do
        if obj.Name == "SaitamaBeam"
            or obj.Name == "SaitamaGlow0"
            or obj.Name == "SaitamaGlow1" then

            pcall(function()
                obj:Destroy()
            end)
        end
    end
end

local function AddSaitamaEffect(part)
    if not part or not part:IsA("BasePart") then
        return
    end

    RemoveSaitamaEffect()

    local attachment0 = Instance.new("Attachment")
    attachment0.Name = "SaitamaGlow0"
    attachment0.Parent = part

    local attachment1 = Instance.new("Attachment")
    attachment1.Name = "SaitamaGlow1"
    attachment1.Position = Vector3.new(0, 0.5, 0)
    attachment1.Parent = part

    local beam = Instance.new("Beam")
    beam.Name = "SaitamaBeam"
    beam.Attachment0 = attachment0
    beam.Attachment1 = attachment1
    beam.Width0 = 0.8
    beam.Width1 = 0.8
    beam.Transparency = NumberSequence.new(0.6)
    beam.Parent = part

    task.spawn(function()
        while beam.Parent and Cheat.Flags.Saitama do
            local color =
                RainbowColor(Cheat.Config.RainbowOffset)

            beam.Color = ColorSequence.new(color)

            Cheat.Config.RainbowOffset += 0.01

            task.wait(0.05)
        end
    end)
end

-- ======================================================
-- ESP
-- ======================================================

local function GetTeamColor(pl)
    if pl.Team then
        return pl.TeamColor.Color
    end

    local containers = {
        pl,
        pl.Character
    }

    for _, container in ipairs(containers) do
        if container then
            local v = container:FindFirstChild("TeamColor")

            if v then
                if v:IsA("BrickColorValue") then
                    return v.Value.Color
                end

                if v:IsA("Color3Value") then
                    return v.Value
                end
            end
        end
    end

    return Color3.fromRGB(170, 170, 170)
end

local function ClearESP()
    for _, obj in pairs(Cheat.Runtime.ESPTexts) do
        pcall(function()
            obj:Destroy()
        end)
    end

    for _, obj in pairs(Cheat.Runtime.ESPHighlights) do
        pcall(function()
            obj:Destroy()
        end)
    end

    for _, conn in pairs(
        Cheat.Runtime.ESPCharacterConnections
    ) do
        pcall(function()
            conn:Disconnect()
        end)
    end

    Cheat.Runtime.ESPTexts = {}
    Cheat.Runtime.ESPHighlights = {}
    Cheat.Runtime.ESPCharacterConnections = {}
end

local function AddESPForPlayer(pl)
    if pl == LocalPlayer or not Cheat.Flags.ESP then
        return
    end

    -- Destroy existing instances if they exist
    if Cheat.Runtime.ESPTexts[pl] then
        pcall(function()
            Cheat.Runtime.ESPTexts[pl]:Destroy()
        end)
        Cheat.Runtime.ESPTexts[pl] = nil
    end

    if Cheat.Runtime.ESPHighlights[pl] then
        pcall(function()
            Cheat.Runtime.ESPHighlights[pl]:Destroy()
        end)
        Cheat.Runtime.ESPHighlights[pl] = nil
    end

    local char = pl.Character

    if not char then
        return
    end

    local hum =
        char:FindFirstChildOfClass("Humanoid")

    local root =
        char:FindFirstChild("HumanoidRootPart")

    local head =
        char:FindFirstChild("Head")

    if not hum or not root or not head then
        return
    end

    local color = GetTeamColor(pl)

    -- Billboard GUI (Text display above character)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "MAX_ESP_Billboard"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 220, 0, 55)
    billboard.StudsOffset = Vector3.new(0, 2.8, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 1000
    billboard.Parent = head

    local txt = Instance.new("TextLabel")
    txt.Name = "ESPText"
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = color
    txt.TextStrokeTransparency = 0.2
    txt.TextStrokeColor3 = Color3.new(0, 0, 0)
    txt.Font = Enum.Font.GothamBold
    txt.TextScaled = true
    txt.Text = pl.Name
    txt.Parent = billboard

    -- Highlight (Outline/Fill around character model)
    local highlight = Instance.new("Highlight")
    highlight.Name = "MAX_ESP_Highlight"
    highlight.FillColor = color
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = color
    highlight.OutlineTransparency = 0.2
    highlight.DepthMode =
        Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = char
    highlight.Parent = char

    Cheat.Runtime.ESPTexts[pl] = billboard
    Cheat.Runtime.ESPHighlights[pl] = highlight

    -- CharacterAdded Connection (Handles respawns)
    if Cheat.Runtime.ESPCharacterConnections[pl] then
        pcall(function()
            Cheat.Runtime.ESPCharacterConnections[pl]:Disconnect()
        end)
    end

    Cheat.Runtime.ESPCharacterConnections[pl] =
        pl.CharacterAdded:Connect(function()
            if not Cheat.Flags.ESP then
                return
            end

            task.wait(0.25) -- Small delay to ensure parts are fully parented/ready

            if pl.Parent then
                AddESPForPlayer(pl)
            end
        end)
end

local function CreateESP()
    ClearESP()

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer then
            AddESPForPlayer(pl)
        end
    end
end

local function UpdateESP()
    if not Cheat.Flags.ESP then
        return
    end

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer then
            local char = pl.Character

            local hum =
                char
                and char:FindFirstChildOfClass("Humanoid")

            local root =
                char
                and char:FindFirstChild("HumanoidRootPart")

            local head =
                char
                and char:FindFirstChild("Head")

            local billboard =
                Cheat.Runtime.ESPTexts[pl]

            local highlight =
                Cheat.Runtime.ESPHighlights[pl]

            if hum and root and head then
                -- Ensure ESP components exist for this player
                if not billboard or not billboard.Parent then
                    AddESPForPlayer(pl)
                    billboard = Cheat.Runtime.ESPTexts[pl]
                    highlight = Cheat.Runtime.ESPHighlights[pl]
                end

                local color = GetTeamColor(pl)

                local label =
                    billboard
                    and billboard:FindFirstChild("ESPText")

                if label then
                    local localRoot = GetRoot()

                    -- Calculate distance to local player's root part
                    local dist =
                        localRoot
                        and (
                            localRoot.Position
                            - root.Position
                        ).Magnitude
                        or 0

                    local hp =
                        math.max(
                            0,
                            math.floor(hum.Health)
                        )

                    -- Update text properties
                    label.TextColor3 = color

                    label.Text = string.format(
                        "%s [%d HP] [%d м]",
                        pl.Name,
                        hp,
                        math.floor(dist)
                    )

                    label.Visible = true
                end

                -- Update highlight properties
                if highlight then
                    highlight.FillColor = color
                    highlight.OutlineColor = color
                    highlight.Adornee = char
                    highlight.Enabled = hum.Health > 0
                end

                -- Ensure billboard is enabled and attached
                if billboard then
                    billboard.Adornee = head
                    billboard.Enabled = true
                end
            else
                -- If character parts are missing, disable ESP components
                if billboard then
                    billboard.Enabled = false
                end

                if highlight then
                    highlight.Enabled = false
                end
            end
        end
    end
end

local ESPRenderConnection =
    RunService.RenderStepped:Connect(UpdateESP)

table.insert(
    Cheat.Runtime.Connections,
    ESPRenderConnection
)

-- Handle players joining/leaving to manage ESP connections
Players.PlayerAdded:Connect(function(pl)
    if not Cheat.Flags.ESP then
        return
    end

    task.spawn(function()
        pl.CharacterAdded:Wait()

        task.wait(0.25) -- Wait for character setup

        if Cheat.Flags.ESP and pl.Parent then
            AddESPForPlayer(pl)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(pl)
    -- Clean up resources when player leaves
    if Cheat.Runtime.ESPTexts[pl] then
        pcall(function()
            Cheat.Runtime.ESPTexts[pl]:Destroy()
        end)
    end

    if Cheat.Runtime.ESPHighlights[pl] then
        pcall(function()
            Cheat.Runtime.ESPHighlights[pl]:Destroy()
        end)
    end

    if Cheat.Runtime.ESPCharacterConnections[pl] then
        pcall(function()
            Cheat.Runtime.ESPCharacterConnections[pl]:Disconnect()
        end)
    end

    -- Clear references
    Cheat.Runtime.ESPTexts[pl] = nil
    Cheat.Runtime.ESPHighlights[pl] = nil
    Cheat.Runtime.ESPCharacterConnections[pl] = nil
end)

-- ======================================================
-- FLY — FIXED RESPAWN SYSTEM (Optimized for Mobile/Button Control)
-- ======================================================

local function DestroyFlyVelocity()
    local bv = Cheat.Runtime.FlyBodyVelocity

    if bv then
        pcall(function()
            bv:Destroy()
        end)
    end

    Cheat.Runtime.FlyBodyVelocity = nil
end

local function StopFly()
    Cheat.Flags.Fly = false
    DestroyFlyVelocity()

    local hum = GetHumanoid()

    if hum then
        hum.PlatformStand = false -- Allows jumping/normal movement immediately upon stopping fly
    end

    if JoyGui and JoyGui.Parent then
        JoyGui.Enabled = false
    end

    ResetJoystick()

    FlyUpActive = false
    FlyDownActive = false
end

local function StartFly()
    local char = LocalPlayer.Character

    if not char then
        return false, "⚠️ Персонаж не найден"
    end

    local hum =
        char:FindFirstChildOfClass("Humanoid")

    local root =
        char:FindFirstChild("HumanoidRootPart")

    if not hum or not root then
        return false, "⚠️ Персонаж ещё не загрузился"
    end

    if hum.Health <= 0 then
        return false, "⚠️ Персонаж мёртв"
    end

    DestroyFlyVelocity()

    local bv = Instance.new("BodyVelocity")

    bv.Name = "MAX_FlyVelocity"
    bv.MaxForce =
        Vector3.new(
            math.huge,
            math.huge,
            math.huge
        )

    bv.P = 100000
    bv.Velocity = Vector3.zero
    bv.Parent = root

    Cheat.Runtime.FlyBodyVelocity = bv
    Cheat.Flags.Fly = true

    hum.PlatformStand = true -- Locks movement, but allows jump input to override state

    if IsMobile and JoyGui and JoyGui.Parent then
        JoyGui.Enabled = true
    end

    return true
end

local function UpdateFly()
    if not Cheat.Flags.Fly then
        return
    end

    local char = LocalPlayer.Character

    if not char then
        StopFly() -- Stop if character is gone (e.g., mid-teleport)
        return
    end

    local hum =
        char:FindFirstChildOfClass("Humanoid")

    local root =
        char:FindFirstChild("HumanoidRootPart")

    local bv =
        Cheat.Runtime.FlyBodyVelocity

    if not hum or not root or not bv or bv.Parent ~= root then
        StopFly()
        return
    end

    if hum.Health <= 0 then
        StopFly()
        return
    end

    Camera = workspace.CurrentCamera

    if not Camera then
        return
    end

    local speed =
        tonumber(Cheat.Config.FlySpeed)
        or 70

    local velocity = Vector3.zero

    local look = Camera.CFrame.LookVector -- Forward/Backward direction based on camera view
    local right = Camera.CFrame.RightVector  -- Left/Right direction based on camera view
    local up = Vector3.new(0, 1, 0)

    if IsDesktop then
        -- Desktop Input (Keyboard)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            velocity += look * speed
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            velocity -= look * speed
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            velocity -= right * speed
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            velocity += right * speed
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            velocity += up * speed
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            velocity -= up * speed
        end
    else
        -- Mobile Input (Joystick/Buttons)
        local center =
            JoyFrame.AbsolutePosition
            + JoyFrame.AbsoluteSize / 2

        local stickCenter =
            JoyStick.AbsolutePosition
            + JoyStick.AbsoluteSize / 2

        local delta =
            stickCenter - center

        local maxDist = 40

        -- Calculate normalized input from joystick drag (x: horizontal, z: forward/backward)
        local x =
            math.clamp(
                delta.X / maxDist,
                -1,
                1
            )

        local z =
            math.clamp(
                delta.Y / maxDist,
                -1,
                1
            )

        -- 1. Horizontal movement driven by joystick drag (x)
        velocity += right * x * speed

        -- 2. Forward/Backward movement driven by joystick drag (z). Note: Z is inverted relative to standard screen coordinates for forward push.
        velocity += look * (-z) * speed

        -- 3. Vertical movement driven by dedicated buttons (UpBtn/DownBtn)
        if FlyUpActive then
            velocity += up * speed
        end

        if FlyDownActive then
            velocity -= up * speed
        end
    end

    bv.Velocity = velocity
end

-- Connect the update loop
if Cheat.Runtime.FlyRenderConnection then
    Cheat.Runtime.FlyRenderConnection:Disconnect()
end

Cheat.Runtime.FlyRenderConnection =
    RunService.RenderStepped:Connect(UpdateFly)

-- ======================================================
-- RESPAWN HANDLER (Handles state restoration after death)
-- ======================================================

LocalPlayer.CharacterRemoving:Connect(function()
    StopFly() -- Stops fly and resets BV/PlatformStand
    
    if Cheat.Runtime.FreezeBV then
        pcall(function()
            Cheat.Runtime.FreezeBV:Destroy()
        end)
        Cheat.Runtime.FreezeBV = nil
    end

    -- Store current transparency values before death
    Cheat.Runtime.OriginalTransparency = {}
    Cheat.Runtime.NoclipOriginalCollision = {}
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    task.spawn(function()
        local hum =
            character:WaitForChild(
                "Humanoid",
                10
            )

        local root =
            character:WaitForChild(
                "HumanoidRootPart",
                10
            )

        if not hum or not root then
            return
        end

        task.wait(0.2) -- Wait for physics/network sync

        -- Restore Speed
        if Cheat.Runtime.OriginalWalkSpeed == nil then
            Cheat.Runtime.OriginalWalkSpeed =
                hum.WalkSpeed
        end
        hum.WalkSpeed =
            Cheat.Config.SpeedValue

        -- Noclip restoration logic
        if Cheat.Flags.Noclip then
            if Cheat.Runtime.NoclipConnection then
                pcall(function()
                    Cheat.Runtime.NoclipConnection:Disconnect()
                end)
            end

            Cheat.Runtime.NoclipOriginalCollision = {}

            -- Start Noclip connection immediately upon respawn if enabled
            Cheat.Runtime.NoclipConnection =
                RunService.Stepped:Connect(function()
                    if not Cheat.Flags.Noclip then
                        return
                    end

                    local currentChar = LocalPlayer.Character

                    if not currentChar then
                        return
                    end

                    for _, part in ipairs(
                        currentChar:GetDescendants()
                    ) do
                        if part:IsA("BasePart") then
                            -- Store original state if not already stored for this respawn cycle
                            if Cheat.Runtime.NoclipOriginalCollision[part] == nil then
                                Cheat.Runtime.NoclipOriginalCollision[part] =
                                    part.CanCollide
                            end

                            part.CanCollide = false -- Force collision off
                        end
                    end
                end)
        end

        -- Invisible restoration logic
        if Cheat.Flags.Invisible then
            Cheat.Runtime.OriginalTransparency = {}

            for _, obj in ipairs(
                character:GetDescendants()
            ) do
                if obj:IsA("BasePart")
                    or obj:IsA("Decal") then

                    -- Store original transparency before setting to 1
                    Cheat.Runtime.OriginalTransparency[obj] =
                        obj.Transparency

                    obj.Transparency = 1 -- Set invisible
                end
            end
        end

        -- Fly state is NOT automatically restored, requiring user command 'fly'
        -- This ensures the player has control immediately after death.

        if Cheat.Flags.Saitama then
            local newRoot =
                character:FindFirstChild(
                    "HumanoidRootPart"
                )

            if newRoot then
                AddSaitamaEffect(newRoot)
            end
        end
    end)
end)

-- ======================================================
-- CONSOLE
-- ======================================================

local function AddConsoleOutput(text, color)
    if not OutputScrolling then
        return
    end

    local label = Instance.new("TextLabel")

    label.Size =
        UDim2.new(1, -8, 0, 22)

    -- Position at the bottom of the scrolling frame content area
    label.Position =
        UDim2.new(
            0,
            4,
            0,
            OutputScrolling.CanvasSize.Y.Offset
        )

    label.BackgroundTransparency = 1
    label.Text = tostring(text)
    label.TextColor3 =
        color or Color3.new(1, 1, 1)

    label.TextXAlignment =
        Enum.TextXAlignment.Left

    label.Font = Enum.Font.Gotham
    label.TextSize = 15
    label.Parent = OutputScrolling

    -- Update CanvasSize to accommodate the new line
    OutputScrolling.CanvasSize =
        UDim2.new(
            0,
            0,
            0,
            OutputScrolling.CanvasSize.Y.Offset + 24
        )

    task.defer(function()
        -- Keep scroll position at the bottom
        OutputScrolling.CanvasPosition =
            Vector2.new(
                0,
                math.max(
                    0,
                    OutputScrolling.CanvasSize.Y.Offset
                )
            )
    end)
end

local function ExecuteCommand(cmd, output)
    local parts = {}

    for word in cmd:gmatch("%S+") do
        table.insert(parts, word)
    end

    if #parts == 0 then
        return
    end

    local name =
        table.remove(parts, 1):lower()

    local command = Cmds[name]

    if command then
        -- Execute the command's run function
        local ok, err =
            pcall(function()
                command.run(parts, output)
            end)

        if not ok then
            output(
                "❌ Ошибка: " .. tostring(err),
                Color3.fromRGB(255, 80, 80)
            )
        end
    else
        output(
            "⚠️ Неизвестная команда. Используйте help",
            Color3.fromRGB(255, 255, 0)
        )
    end
end

local function CreateConsole()
    -- Destroy existing GUI if it exists to allow clean recreation/re-enabling
    if GUI then
        pcall(function()
            GUI:Destroy()
        end)
        GUI = nil
    end

    -- Disconnect old input listeners
    if Cheat.Runtime.ConsoleInputConnection then
        pcall(function()
            Cheat.Runtime.ConsoleInputConnection:Disconnect()
        end)
        Cheat.Runtime.ConsoleInputConnection = nil
    end

    if Cheat.Runtime.ConsoleTabConnection then
        pcall(function()
            Cheat.Runtime.ConsoleTabConnection:Disconnect()
        end)
        Cheat.Runtime.ConsoleTabConnection = nil
    end

    -- Create the main ScreenGui container
    GUI = Instance.new("ScreenGui")
    GUI.Name = "MaxEditionConsole"
    GUI.ResetOnSpawn = false
    GUI.Enabled =
        Cheat.Runtime.ConsoleVisible
    GUI.Parent = PlayerGui

    local MainFrame = Instance.new("Frame")

    MainFrame.Size =
        UDim2.new(0, 600, 0, 450)

    MainFrame.Position =
        UDim2.new(
            0.5,
            -300,
            0.5,
            -225
        )

    MainFrame.BackgroundColor3 =
        Color3.fromRGB(15, 15, 30)

    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 =
        Color3.fromRGB(255, 215, 0)

    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = GUI

    local Title = Instance.new("TextLabel")

    Title.Size =
        UDim2.new(1, 0, 0, 40)

    Title.BackgroundColor3 =
        Color3.fromRGB(40, 40, 70)

    Title.Text =
        "S MAX EDITION & DEEPSEEK"

    Title.TextColor3 =
        Color3.fromRGB(255, 0, 0)

    Title.TextScaled = true
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame

    local InfoLabel = Instance.new("TextLabel")

    InfoLabel.Size =
        UDim2.new(1, 0, 0, 20)

    InfoLabel.Position =
        UDim2.new(0, 0, 0, 40)

    InfoLabel.BackgroundTransparency = 1

    InfoLabel.Text =
        "🟢 S или двойной RightShift"

    InfoLabel.TextColor3 =
        Color3.fromRGB(150, 200, 255)

    InfoLabel.TextScaled = true
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.Parent = MainFrame

    OutputScrolling = Instance.new("ScrollingFrame")

    OutputScrolling.Size =
        UDim2.new(1, -20, 0, 280)

    OutputScrolling.Position =
        UDim2.new(0, 10, 0, 65)

    OutputScrolling.BackgroundColor3 =
        Color3.fromRGB(5, 5, 15)

    OutputScrolling.BackgroundTransparency = 0.3
    OutputScrolling.BorderSizePixel = 1

    OutputScrolling.BorderColor3 =
        Color3.fromRGB(60, 60, 100)

    OutputScrolling.CanvasSize =
        UDim2.new(0, 0, 0, 0)

    OutputScrolling.ScrollBarThickness = 5
    OutputScrolling.Parent = MainFrame

    InputBox = Instance.new("TextBox")

    InputBox.Size =
        UDim2.new(1, -20, 0, 35)

    InputBox.Position =
        UDim2.new(0, 10, 0, 355)

    InputBox.BackgroundColor3 =
        Color3.fromRGB(25, 25, 45)

    InputBox.BorderSizePixel = 1

    InputBox.BorderColor3 =
        Color3.fromRGB(80, 80, 150)

    InputBox.Text = ""

    InputBox.TextColor3 =
        Color3.fromRGB(255, 255, 255)

    InputBox.TextSize = 16
    InputBox.Font = Enum.Font.Gotham

    InputBox.ClearTextOnFocus = false

    InputBox.PlaceholderText =
        "Введите команду... (help)"

    InputBox.Parent = MainFrame

    SuggestionLabel = Instance.new("TextLabel")

    SuggestionLabel.Size =
        UDim2.new(1, -20, 0, 24)

    SuggestionLabel.Position =
        UDim2.new(0, 10, 0, 392)

    SuggestionLabel.BackgroundTransparency = 1
    SuggestionLabel.Text = ""

    SuggestionLabel.TextColor3 =
        Color3.fromRGB(180, 180, 255)

    SuggestionLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    SuggestionLabel.TextSize = 14
    SuggestionLabel.Font = Enum.Font.Gotham
    SuggestionLabel.Parent = MainFrame

    local function UpdateSuggestions()
        if not InputBox
            or not SuggestionLabel then
            return
        end

        local prefix =
            (
                InputBox.Text:match(
                    "^%s*(%S*)"
                )
                or ""
            ):lower()

        if prefix == "" then
            SuggestionLabel.Text = ""
            return
        end

        local matches = {}

        for name, command in pairs(Cmds) do
            if type(name) == "string"
                and type(command) == "table"
                and name:sub(
                    1,
                    #prefix
                ) == prefix then

                table.insert(matches, name)
            end
        end

        table.sort(matches)

        local shown = {}

        for i = 1, math.min(#matches, 6) do
            table.insert(
                shown,
                matches[i]
            )
        end

        if #shown > 0 then
            SuggestionLabel.Text =
                "Команды: "
                .. table.concat(
                    shown,
                    "  |  "
                )
                .. (
                    #matches > #shown
                    and "  ..."
                    or ""
                )
        else
            SuggestionLabel.Text =
                "Команда не найдена"
        end
    end

    InputBox:GetPropertyChangedSignal(
        "Text"
    ):Connect(UpdateSuggestions)

    -- Tab completion logic
    Cheat.Runtime.ConsoleTabConnection =
        UserInputService.InputBegan:Connect(
            function(input, gameProcessed)
                if gameProcessed then
                    return
                end

                if not InputBox
                    or not InputBox:IsFocused() then
                    return
                end

                if input.KeyCode
                    ~= Enum.KeyCode.Tab then
                    return
                end

                local prefix =
                    (
                        InputBox.Text:match(
                            "^%s*(%S*)"
                        )
                        or ""
                    ):lower()

                if prefix == "" then
                    return
                end

                local matches = {}

                for name, command in pairs(Cmds) do
                    if type(name) == "string"
                        and type(command) == "table"
                        and name:sub(
                            1,
                            #prefix
                        ) == prefix then

                        table.insert(
                            matches,
                            name
                        )
                    end
                end

                table.sort(matches)

                if #matches > 0 then
                    -- Insert the first match and move cursor past it
                    InputBox.Text =
                        matches[1] .. " "

                    InputBox.CursorPosition =
                        #InputBox.Text + 1
                end
            end
        )

    local function output(text, color)
        AddConsoleOutput(
            text,
            color
        )
    end

    -- Initial welcome message
    output(
        "S MAX EDITION | TouchFling удалён | Fly fixed",
        Color3.fromRGB(255, 215, 0)
    )

    Cheat.Runtime.ConsoleInputConnection =
        InputBox.FocusLost:Connect(
            function(enterPressed)
                if not enterPressed then
                    return
                end

                local cmd = InputBox.Text

                InputBox.Text = "" -- Clear input box after execution

                if cmd ~= "" then
                    output(
                        "> " .. cmd,
                        Color3.fromRGB(
                            200,
                            200,
                            255
                        )
                    )

                    -- Command History Management
                    table.insert(
                        Cheat.Runtime.CommandHistory,
                        cmd
                    )

                    if #Cheat.Runtime.CommandHistory > 100 then
                        table.remove(
                            Cheat.Runtime.CommandHistory,
                            1
                        )
                    end

                    Cheat.Runtime.HistoryIndex =
                        #Cheat.Runtime.CommandHistory + 1

                    ExecuteCommand(
                        cmd,
                        output
                    )
                end
            end
        )
end

-- ======================================================
-- COMMANDS DEFINITIONS (Cmds table)
-- ======================================================

Cmds.help = {
    desc = "Показать все команды",

    run = function(args, output)
        output(
            "===== ДОСТУПНЫЕ КОМАНДЫ =====",
            Color3.fromRGB(255, 215, 0)
        )

        local commands = {
            "help", "fly", "unfly", "speed", "unspeed", "noclip", "unnoclip", "fakeheal",
            "goto", "tp", "esp", "unesp", "saitama", "unsaitama", "antiafk", "unantiafk",
            "autoclick", "unautoclick", "spin", "unspin", "sit", "unsit", "jump", "unjump",
            "tpall", "freeze", "unfreeze", "time", "weather", "godmode", "ungodmode",
            "invisible", "uninvisible", "mm2aimbot", "unmm2aimbot", "mm2autoshoot", "unmm2autoshoot",
            "reset", "unload",
        }

        for _, name in ipairs(commands) do
            if Cmds[name] then
                output(
                    name .. " - " .. Cmds[name].desc,
                    Color3.fromRGB(
                        200,
                        200,
                        255
                    )
                )
            end
        end

        output(
            "===== КОНЕЦ СПИСКА =====",
            Color3.fromRGB(255, 215, 0)
        )
    end
}

-- FLY COMMAND
Cmds.fly = {
    desc = "Полет: fly [скорость]. Выключение: unfly",

    run = function(args, output)
        local requested =
            tonumber(args[1])

        if requested then
            Cheat.Config.FlySpeed =
                math.clamp(
                    requested,
                    1,
                    100000
                )
        end

        local currentRoot = GetRoot()
        local currentBV =
            Cheat.Runtime.FlyBodyVelocity

        if Cheat.Flags.Fly
            and currentRoot
            and currentBV
            and currentBV.Parent == currentRoot then

            output(
                "✈️ Полет уже включен | скорость: "
                .. tostring(
                    Cheat.Config.FlySpeed
                ),
                Color3.fromRGB(0, 255, 0)
            )

            return
        end

        local ok, message =
            StartFly()

        if not ok then
            output(
                message,
                Color3.fromRGB(255, 255, 0)
            )

            return
        end

        output(
            "✈️ Полет ВКЛЮЧЕН | скорость: "
            .. tostring(
                Cheat.Config.FlySpeed
            ),
            Color3.fromRGB(0, 255, 0)
        )
    end
}

Cmds.unfly = {
    desc = "Выключить полет",

    run = function(args, output)
        StopFly()

        output(
            "✈️ Полет ВЫКЛЮЧЕН",
            Color3.fromRGB(255, 0, 0)
        )
    end
}

-- SPEED COMMAND
Cmds.speed = {
    desc = "Установить скорость: speed [число]",

    run = function(args, output)
        local speed =
            tonumber(args[1])

        if not speed then
            output(
                "⚠️ Использование: speed [число]",
                Color3.fromRGB(255, 255, 0)
            )

            return
        end

        -- Ensure original speed is captured if it hasn't been yet
        if Cheat.Runtime.OriginalWalkSpeed == nil then
            local hum = GetHumanoid()
            if hum then
                Cheat.Runtime.OriginalWalkSpeed =
                    hum.WalkSpeed
            else
                Cheat.Runtime.OriginalWalkSpeed = 16 -- Default fallback
            end
        end

        Cheat.Config.SpeedValue =
            math.max(0, speed)

        local hum = GetHumanoid()

        if hum then
            hum.WalkSpeed =
                Cheat.Config.SpeedValue
        end

        SaveSettings()

        output(
            "🏃 Скорость: "
            .. tostring(
                Cheat.Config.SpeedValue
            ),
            Color3.fromRGB(0, 255, 0)
        )
    end
}

Cmds.unspeed = {
    desc = "Вернуть исходную скорость игры",

    run = function(args, output)
        local hum = GetHumanoid()

        local original =
            Cheat.Runtime.OriginalWalkSpeed

        if not original then
            -- Fallback if OriginalWalkSpeed wasn't captured (e.g., first run without speed command)
            if hum then
                original = hum.WalkSpeed
                Cheat.Runtime.OriginalWalkSpeed = original
            else
                original = 16
            end
        end

        Cheat.Config.SpeedValue =
            original

        if hum then
            hum.WalkSpeed = original
        end

        SaveSettings()

        output(
            "🏃 Исходная скорость восстановлена: "
            .. tostring(original),
            Color3.fromRGB(0, 255, 0)
        )
    end
}

-- NOCLIP COMMAND
local function RestoreNoclipCollision()
    for part, original in pairs(
        Cheat.Runtime.NoclipOriginalCollision
    ) do
        if part and part.Parent then
            pcall(function()
                part.CanCollide = original
            end)
        end
    end

    Cheat.Runtime.NoclipOriginalCollision = {}
end

local function StartNoclipConnection()
    -- Disconnect previous connection if it exists
    if Cheat.Runtime.NoclipConnection then
        pcall(function()
            Cheat.Runtime.NoclipConnection:Disconnect()
        end)
    end

    Cheat.Runtime.NoclipOriginalCollision = {}

    -- Start new Stepped connection
    Cheat.Runtime.NoclipConnection =
        RunService.Stepped:Connect(function()
            if not Cheat.Flags.Noclip then
                return
            end

            local char = GetCharacter()

            if not char then
                return
            end

            for _, part in ipairs(
                char:GetDescendants()
            ) do
                if part:IsA("BasePart") then
                    -- Store original state if not already stored for this cycle
                    if Cheat.Runtime.NoclipOriginalCollision[part] == nil then
                        Cheat.Runtime.NoclipOriginalCollision[part] =
                            part.CanCollide
                    end

                    part.CanCollide = false -- Force collision off
                end
            end
        end)
end

Cmds.noclip = {
    desc = "Включить/выключить прохождение сквозь стены",

    run = function(args, output)
        Cheat.Flags.Noclip =
            not Cheat.Flags.Noclip

        if Cheat.Flags.Noclip then
            StartNoclipConnection()

            output(
                "🚧 Noclip ВКЛЮЧЕН",
                Color3.fromRGB(0, 255, 0)
            )
        else
            -- Stop connection and restore collisions
            if Cheat.Runtime.NoclipConnection then
                Cheat.Runtime.NoclipConnection:Disconnect()
                Cheat.Runtime.NoclipConnection = nil
            end

            RestoreNoclipCollision()

            output(
                "🚧 Noclip ВЫКЛЮЧЕН",
                Color3.fromRGB(255, 0, 0)
            )
        end

        SaveSettings()
    end
}

-- FAKE HEAL COMMAND
Cmds.fakeheal = {
    desc = "Восстановить здоровье",

    run = function(args, output)
        local hum = GetHumanoid()

        if hum then
            hum.Health = hum.MaxHealth

            output(
                "❤️ Здоровье восстановлено",
                Color3.fromRGB(0, 255, 0)
            )
        else
            output(
                "⚠️ Персонаж не найден",
                Color3.fromRGB(255, 255, 0)
            )
        end
    end
}

-- ESP COMMAND
Cmds.esp = {
    desc = "Включить/выключить ESP",

    run = function(args, output)
        Cheat.Flags.ESP =
            not Cheat.Flags.ESP

        if Cheat.Flags.ESP then
            CreateESP()

            output(
                "👁️ ESP ВКЛЮЧЕН",
                Color3.fromRGB(0, 255, 0)
            )
        else
            ClearESP()

            output(
                "👁️ ESP ВЫКЛЮЧЕН",
                Color3.fromRGB(255, 0, 0)
            )
        end

        SaveSettings()
    end
}

-- SAITAMA COMMAND
Cmds.saitama = {
    desc = "Включить/выключить режим Сайтамы",

    run = function(args, output)
        Cheat.Flags.Saitama =
            not Cheat.Flags.Saitama

        local root = GetRoot()

        if Cheat.Flags.Saitama
            and root then

            AddSaitamaEffect(root)

            output(
                "👊 Режим Сайтамы ВКЛЮЧЕН",
                Color3.fromRGB(0, 255, 0)
            )
        else
            RemoveSaitamaEffect()

            output(
                "👊 Режим Сайтамы ВЫКЛЮЧЕН",
                Color3.fromRGB(255, 0, 0)
            )
        end

        SaveSettings()
    end
}

-- SIT COMMAND
Cmds.sit = {
    desc = "Сесть/встать",

    run = function(args, output)
        Cheat.Flags.Sit =
            not Cheat.Flags.Sit

        local hum = GetHumanoid()

        if hum then
            hum.Sit =
                Cheat.Flags.Sit

            output(
                Cheat.Flags.Sit
                    and "🪑 Сел"
                    or "🪑 Встал",
                Color3.fromRGB(0, 255, 0)
            )
        end
    end
}

-- INFINITE JUMP COMMAND
Cmds.jump = {
    desc = "Включить/выключить бесконечный прыжок",

    run = function(args, output)
        Cheat.Flags.InfiniteJump =
            not Cheat.Flags.InfiniteJump

        if Cheat.Flags.InfiniteJump then
            -- Disconnect old connection if it exists
            if Cheat.Runtime.JumpConnection then
                Cheat.Runtime.JumpConnection:Disconnect()
            end

            -- Connect new listener to JumpRequest event
            Cheat.Runtime.JumpConnection =
                UserInputService.JumpRequest:Connect(
                    function()
                        if not Cheat.Flags.InfiniteJump then
                            return
                        end

                        local hum = GetHumanoid()

                        if hum and hum.Health > 0 then
                            -- Force the jump state change every time JumpRequest fires
                            hum:ChangeState(
                                Enum.HumanoidStateType.Jumping
                            )
                        end
                    end
                )

            output(
                "🦘 Бесконечный прыжок ВКЛЮЧЕН",
                Color3.fromRGB(0, 255, 0)
            )
        else
            -- Disconnect the connection when disabled
            if Cheat.Runtime.JumpConnection then
                Cheat.Runtime.JumpConnection:Disconnect()
                Cheat.Runtime.JumpConnection = nil
            end

            output(
                "🦘 Бесконечный прыжок ВЫКЛЮЧЕН",
                Color3.fromRGB(255, 0, 0)
            )
        end
    end
}

-- TPALL COMMAND
Cmds.tpall = {
    desc = "Телепортировать всех к себе",

    run = function(args, output)
        local root = GetRoot()

        if not root then
            output(
                "⚠️ Вы не в игре",
                Color3.fromRGB(255, 255, 0)
            )

            return
        end

        local count = 0

        for _, player in ipairs(
            Players:GetPlayers()
        ) do
            if player ~= LocalPlayer then
                local targetRoot =
                    player.Character
                    and player.Character:FindFirstChild(
                        "HumanoidRootPart"
                    )

                if targetRoot then
                    -- Teleport slightly above the current position to prevent clipping issues
                    targetRoot.CFrame =
                        root.CFrame
                        + Vector3.new(0, 3, 0)

                    count += 1
                end
            end
        end

        output(
            "📍 Телепортировано: "
            .. count,
            Color3.fromRGB(0, 255, 0)
        )
    end
}

-- FREEZE COMMAND
Cmds.freeze = {
    desc = "Заморозить/разморозить себя",

    run = function(args, output)
        Cheat.Flags.Freeze =
            not Cheat.Flags.Freeze

        local root = GetRoot()
        local hum = GetHumanoid()

        if not root or not hum then
            output(
                "⚠️ Персонаж не найден",
                Color3.fromRGB(255, 255, 0)
            )

            return
        end

        if Cheat.Flags.Freeze then
            -- Destroy existing BV if present
            if Cheat.Runtime.FreezeBV then
                pcall(function()
                    Cheat.Runtime.FreezeBV:Destroy()
                end)
            end

            local bv = Instance.new("BodyVelocity")

            bv.MaxForce =
                Vector3.new(1, 1, 1)
                * 100000 -- High force to resist external forces

            bv.Velocity = Vector3.zero
            bv.Parent = root

            Cheat.Runtime.FreezeBV = bv

            hum.PlatformStand = true -- Lock character movement

            output(
                "🧊 Вы заморожены",
                Color3.fromRGB(0, 255, 0)
            )
        else
            -- Destroy BV and unlock character
            if Cheat.Runtime.FreezeBV then
                Cheat.Runtime.FreezeBV:Destroy()
                Cheat.Runtime.FreezeBV = nil
            end

            hum.PlatformStand = false
            hum.Sit = false -- Ensure sitting state is also cleared when unfreezing

            output(
                "🧊 Вы разморожены",
                Color3.fromRGB(0, 255, 0)
            )
        end
    end
}

-- TIME COMMAND
Cmds.time = {
    desc = "Установить время: time [0-23]",

    run = function(args, output)
        local hour =
            tonumber(args[1])

        if not hour
            or hour < 0
            or hour > 23 then

            output(
                "⚠️ Использование: time [0-23]",
                Color3.fromRGB(255, 255, 0)
            )

            return
        end

        Lighting:SetMinutesAfterMidnight(
            hour * 60
        )

        output(
            "🕐 Время: "
            .. hour
            .. ":00",
            Color3.fromRGB(0, 255, 0)
        )
    end
}

-- LOCAL WEATHER COMMANDS
local function GetWeatherFolder()
    local folder =
        Cheat.Runtime.WeatherFolder

    if folder and folder.Parent then
        return folder
    end

    folder = Instance.new("Folder")

    folder.Name =
        "MAX_LocalWeather"

    folder.Parent = workspace

    Cheat.Runtime.WeatherFolder =
        folder

    return folder
end

local function ClearWeather()
    local folder =
        Cheat.Runtime.WeatherFolder

    if not folder then
        return
    end

    for _, obj in ipairs(
        folder:GetChildren()
    ) do
        pcall(function()
            obj:Destroy()
        end)
    end

    Cheat.Runtime.WeatherPart = nil
end

local function CreateWeatherEmitter(kind)
    ClearWeather()

    local folder =
        GetWeatherFolder()

    local part = Instance.new("Part")

    part.Name =
        "MAX_" .. kind

    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Transparency = 1

    part.Size =
        Vector3.new(
            100,
            1,
            100
        )

    part.Parent = folder

    local emitter =
        Instance.new("ParticleEmitter")

    emitter.Name =
        "MAX_" .. kind .. "_Emitter"

    emitter.Parent = part

    if kind == "Rain" then
        emitter.Rate = 500
        emitter.Lifetime =
            NumberRange.new(
                0.7,
                1.2
            )

        emitter.Speed =
            NumberRange.new(
                70,
                100
            )

        emitter.EmissionDirection =
            Enum.NormalId.Bottom

        emitter.SpreadAngle =
            Vector2.new(
                4,
                4
            )

        emitter.Size =
            NumberSequence.new(0.08)

        emitter.Transparency =
            NumberSequence.new(0.25)

    elseif kind == "Snow" then
        emitter.Rate = 150
        emitter.Lifetime =
            NumberRange.new(
                3,
                6
            )

        emitter.Speed =
            NumberRange.new(
                3,
                8
            )

        emitter.EmissionDirection =
            Enum.NormalId.Bottom

        emitter.SpreadAngle =
            Vector2.new(
                20,
                20
            )

        emitter.Size =
            NumberSequence.new(0.18)

        emitter.Transparency =
            NumberSequence.new(0.1)
    end

    Cheat.Runtime.WeatherPart =
        part

    -- Spawn loop to keep the weather part anchored/positioned correctly relative to player root
    task.spawn(function()
        while part.Parent do
            local root = GetRoot()

            if root then
                -- Position slightly above the character's center
                part.Position =
                    root.Position
                    + Vector3.new(
                        0,
                        40, -- Height offset
                        0
                    )
            end

            task.wait(0.2)
        end
    end)

    return part
end

Cmds.weather = {
    desc = "Погода: weather [rain/sun/snow]",

    run = function(args, output)
        local weather =
            args[1]
            and args[1]:lower()

        if not weather then
            output(
                "⚠️ Использование: weather [rain/sun/snow]",
                Color3.fromRGB(255, 255, 0)
            )

            return
        end

        if weather == "rain" then
            CreateWeatherEmitter("Rain")

            output(
                "🌧️ Дождь включён",
                Color3.fromRGB(0, 255, 0)
            )

        elseif weather == "snow" then
            CreateWeatherEmitter("Snow")

            output(
                "❄️ Снег включён",
                Color3.fromRGB(0, 255, 0)
            )

        elseif weather == "sun" then
            ClearWeather()

            output(
                "☀️ Погода очищена",
                Color3.fromRGB(0, 255, 0)
            )

        else
            output(
                "⚠️ Неизвестный тип погоды",
                Color3.fromRGB(255, 255, 0)
            )
        end
    end
}

-- ANTI AFK COMMAND
Cmds.antiafk = {
    desc = "Защита от AFK",

    run = function(args, output)
        Cheat.Flags.AntiAFK =
            not Cheat.Flags.AntiAFK

        if Cheat.Flags.AntiAFK then
            task.spawn(function()
                while Cheat.Flags.AntiAFK do
                    pcall(function()
                        -- Move slightly forward (0.01) on the X axis every 30 seconds
                        LocalPlayer:Move(
                            Vector3.new(
                                0.01,
                                0,
                                0
                            ),
                            true -- Force movement application
                        )
                    end)

                    task.wait(30)
                end
            end)

            output(
                "🛡️ Anti-AFK ВКЛЮЧЕН",
                Color3.fromRGB(0, 255, 0)
            )
        else
            output(
                "🛡️ Anti-AFK ВЫКЛЮЧЕН",
                Color3.fromRGB(255, 0, 0)
            )
        end
    end
}

-- AUTO CLICK COMMAND
Cmds.autoclick = {
    desc = "Авто-кликер",

    run = function(args, output)
        Cheat.Flags.AutoClick =
            not Cheat.Flags.AutoClick

        if Cheat.Flags.AutoClick then
            task.spawn(function()
                local vim =
                    game:GetService(
                        "VirtualInputManager"
                    )

                while Cheat.Flags.AutoClick do
                    pcall(function()
                        -- Left Mouse Button Down (0=Left, 0=X, 0=Y)
                        vim:SendMouseButtonEvent(
                            0,
                            0,
                            0,
                            true, -- Pressed state
                            game,
                            0
                        )

                        task.wait(0.01)

                        -- Left Mouse Button Up
                        vim:SendMouseButtonEvent(
                            0,
                            0,
                            0,
                            false, -- Released state
                            game,
                            0
                        )
                    end)

                    task.wait(0.1) -- Click interval
                end
            end)

            output(
                "🖱️ Авто-кликер ВКЛЮЧЕН",
                Color3.fromRGB(0, 255, 0)
            )
        else
            output(
                "🖱️ Авто-кликер ВЫКЛЮЧЕН",
                Color3.fromRGB(255, 0, 0)
            )
        end
    end
}

-- SPIN COMMAND
Cmds.spin = {
    desc = "Вращение: spin [скорость]. Выключение: unspin",

    run = function(args, output)
        local speed =
            tonumber(args[1])

        if speed then
            Cheat.Config.SpinSpeed =
                speed
        else
            -- Toggle mode if no speed is provided
            Cheat.Flags.Spin =
                not Cheat.Flags.Spin
        end

        if speed and not Cheat.Flags.Spin then
            Cheat.Flags.Spin = true -- Ensure it's on if speed was specified but flag wasn't set
        end

        if Cheat.Flags.Spin then
            -- Start spin thread if it doesn't exist
            if Cheat.Runtime.SpinThread then
                output(
                    "🔄 Spin уже включен",
                    Color3.fromRGB(255, 255, 0)
                )

                return
            end

            Cheat.Runtime.SpinThread = true

            task.spawn(function()
                while Cheat.Flags.Spin do
                    local root = GetRoot()

                    if root then
                        -- Rotate around the Y-axis (0, 1, 0)
                        root.CFrame =
                            root.CFrame
                            * CFrame.Angles(
                                0,
                                math.rad(
                                    Cheat.Config.SpinSpeed
                                ),
                                0
                            )
                    end

                    task.wait(0.05)
                end

                Cheat.Runtime.SpinThread = nil
            end)

            output(
                "🔄 Spin ВКЛЮЧЕН | скорость: "
                .. tostring(
                    Cheat.Config.SpinSpeed
                ),
                Color3.fromRGB(0, 255, 0)
            )
        else
            -- Stop spin thread if it exists
            output(
                "🔄 Spin ВЫКЛЮЧЕН",
                Color3.fromRGB(255, 0, 0)
            )
        end
    end
}

-- FIND PLAYER (Helper function to find targets by name/display name)
local function FindPlayer(query)
    local lower =
        query:lower()

    local exact = {}
    local prefix = {}
    local contains = {}

    for _, pl in ipairs(
        Players:GetPlayers()
    ) do
        if pl ~= LocalPlayer then
            local name =
                pl.Name:lower()

            local display =
                pl.DisplayName
                and pl.DisplayName:lower()
                or ""

            -- Exact match (Name or DisplayName)
            if name == lower
                or display == lower then

                table.insert(
                    exact,
                    pl
                )

            -- Prefix match (Starts with query)
            elseif name:sub(
                1,
                #lower
            ) == lower
                or display:sub(
                    1,
                    #lower
                ) == lower then

                table.insert(
                    prefix,
                    pl
                )

            -- Contains match (Query is anywhere in Name or DisplayName)
            elseif name:find(
                lower,
                1,
                true
            )
                or display:find(
                    lower,
                    1,
                    true
                ) then

                table.insert(
                    contains,
                    pl
                )
            end
        end
    end

    -- Return the best match found (Exact > Prefix > Contains)
    if #exact == 1 then
        return exact[1], exact
    end

    if #prefix == 1 then
        return prefix[1], prefix
    end

    if #contains == 1 then
        return contains[1], contains
    end

    -- If multiple matches exist, return nil target and the list of candidates
    if #exact > 0 then
        return nil, exact
    end

    if #prefix > 0 then
        return nil, prefix
    end

    return nil, contains -- Default: no single match found
end

-- GOTO/TP COMMANDS (Teleport)
Cmds.goto = {
    desc = "Телепорт к игроку или координатам. Алиас: tp",

    run = function(args, output)
        if #args == 0 then
            output(
                "⚠️ goto [имя] или goto [x y z]",
                Color3.fromRGB(255, 255, 0)
            )

            return
        end

        local root = GetRoot()

        if not root then
            output(
                "⚠️ Вы не в игре",
                Color3.fromRGB(255, 255, 0)
            )

            return
        end

        -- Check if the first argument is a number (coordinates mode)
        if tonumber(args[1]) then
            if #args < 3 then
                output(
                    "⚠️ Нужно три координаты: x y z",
                    Color3.fromRGB(255, 255, 0)
                )

                return
            end

            local x = tonumber(args[1])
            local y = tonumber(args[2])
            local z = tonumber(args[3])

            if x and y and z then
                root.CFrame =
                    CFrame.new(
                        Vector3.new(
                            x,
                            y,
                            z
                        )
                    )

                output(
                    "📍 Телепорт на координаты",
                    Color3.fromRGB(0, 255, 0)
                )
            end

            return
        end

        -- Player search mode (Name/Query)
        local query =
            table.concat(
                args,
                " "
            )

        local target, candidates =
            FindPlayer(query)

        if target then
            local targetRoot =
                target.Character
                and target.Character:FindFirstChild(
                    "HumanoidRootPart"
                )

            if targetRoot then
                -- Teleport slightly above the target's position
                root.CFrame =
                    targetRoot.CFrame
                    + Vector3.new(
                        0,
                        3, -- Offset height
                        0
                    )

                output(
                    "📍 Телепорт к "
                    .. target.Name,
                    Color3.fromRGB(
                        0,
                        255,
                        0
                    )
                )
            else
                output(
                    "⚠️ У игрока нет персонажа",
                    Color3.fromRGB(
                        255,
                        255,
                        0
                    )
                )
            end

            return
        end

        -- Handle search results
        if #candidates > 1 then
            output(
                "⚠️ Найдено несколько игроков:",
                Color3.fromRGB(
                    255,
                    255,
                    0
                )
            )

            for _, p in ipairs(
                candidates
            ) do
                local displayName = p.DisplayName or p.Name
                output(
                    " - " .. displayName,
                    Color3.fromRGB(
                        255,
                        255,
                        0
                    )
                )
            end
        else
            -- No match found
            output(
                "⚠️ Игрок не найден: "
                .. query,
                Color3.fromRGB(
                    255,
                    255,
                    0
                )
            )
        end
    end
}

Cmds.tp = Cmds.goto -- Alias for goto

-- GODMODE COMMAND
Cmds.godmode = {
    desc = "Включить/выключить восстановление здоровья",

    run = function(args, output)
        Cheat.Flags.GodMode =
            not Cheat.Flags.GodMode

        if Cheat.Flags.GodMode then
            -- Start Heartbeat connection for constant health restoration
            if Cheat.Runtime.GodModeConnection then
                pcall(function()
                    Cheat.Runtime.GodModeConnection:Disconnect()
                end)
            end

            Cheat.Runtime.GodModeConnection =
                RunService.Heartbeat:Connect(
                    function()
                        if not Cheat.Flags.GodMode then
                            return
                        end

                        local hum =
                            GetHumanoid()

                        if hum
                            and hum.Health > 0 then

                            hum.Health =
                                hum.MaxHealth
                        end
                    end
                )

            output(
                "🛡️ GodMode ВКЛЮЧЕН",
                Color3.fromRGB(
                    0,
                    255,
                    0
                )
            )
        else
            -- Disconnect connection when disabled
            if Cheat.Runtime.GodModeConnection then
                Cheat.Runtime.GodModeConnection:Disconnect()
                Cheat.Runtime.GodModeConnection = nil
            end

            output(
                "🛡️ GodMode ВЫКЛЮЧЕН",
                Color3.fromRGB(
                    255,
                    0,
                    0
                )
            )
        end
    end
}

-- INVISIBLE COMMAND
local function SetInvisible(character)
    Cheat.Runtime.OriginalTransparency = {}

    for _, obj in ipairs(
        character:GetDescendants()
    ) do
        if obj:IsA("BasePart")
            or obj:IsA("Decal") then

            -- Store original transparency before setting to 1
            Cheat.Runtime.OriginalTransparency[obj] =
                obj.Transparency

            obj.Transparency = 1 -- Set invisible
        end
    end
end

local function RestoreInvisible()
    for obj, transparency in pairs(
        Cheat.Runtime.OriginalTransparency
    ) do
        if obj and obj.Parent then
            pcall(function()
                obj.Transparency =
                    transparency
            end)
        end
    end

    Cheat.Runtime.OriginalTransparency = {}
end

Cmds.invisible = {
    desc = "Включить/выключить локальную невидимость",

    run = function(args, output)
        Cheat.Flags.Invisible =
            not Cheat.Flags.Invisible

        local char = GetCharacter()

        if not char then
            Cheat.Flags.Invisible = false -- Force off if character is missing
            output(
                "⚠️ Персонаж не найден",
                Color3.fromRGB(
                    255,
                    255,
                    0
                )
            )
            return
        end

        if Cheat.Flags.Invisible then
            SetInvisible(char)

            output(
                "👻 Невидимость ВКЛЮЧЕНА",
                Color3.fromRGB(
                    0,
                    255,
                    0
                )
            )
        else
            RestoreInvisible()

            output(
                "👻 Невидимость ВЫКЛЮЧЕНА",
                Color3.fromRGB(
                    255,
                    0,
                    0
                )
            )
        end
    end
}

-- MM2 STUBS COMMANDS
Cmds.mm2aimbot = {
    desc = "MM2 Aimbot (заглушка)",

    run = function(args, output)
        Cheat.Flags.MM2Aimbot =
            not Cheat.Flags.MM2Aimbot

        output(
            "🎯 MM2 Aimbot "
            .. (
                Cheat.Flags.MM2Aimbot
                and "ВКЛЮЧЕН"
                or "ВЫКЛЮЧЕН"
            )
            .. " (не реализовано)",
            Color3.fromRGB(
                255,
                255,
                0
            )
        )
    end
}

Cmds.mm2autoshoot = {
    desc = "MM2 AutoShoot (заглушка)",

    run = function(args, output)
        Cheat.Flags.MM2AutoShoot =
            not Cheat.Flags.MM2AutoShoot

        output(
            "🔫 MM2 AutoShoot "
            .. (
                Cheat.Flags.MM2AutoShoot
                and "ВКЛЮЧЕН"
                or "ВЫКЛЮЧЕН"
            )
            .. " (не реализовано)",
            Color3.fromRGB(
                255,
                255,
                0
            )
        )
    end
}

-- UN COMMANDS (Aliases for toggling off features)
local function AddUnAlias(
    unName,
    baseName,
    flagName
)
    Cmds[unName] = {
        desc =
            "Выключить "
            .. baseName,

        run = function(args, output)
            if Cheat.Flags[flagName] then
                -- Handle specific logic for un-commands if needed (like Fly/Noclip cleanup)
                if unName == "unfly" then
                    StopFly()
                    output("✈️ Полет ВЫКЛЮЧЕН", Color3.fromRGB(255, 0, 0))
                elseif unName == "unnoclip" then
                    Cheat.Flags.Noclip = false
                    if Cheat.Runtime.NoclipConnection then
                        Cheat.Runtime.NoclipConnection:Disconnect()
                        Cheat.Runtime.NoclipConnection = nil
                    end
                    RestoreNoclipCollision()
                    output("🚧 Noclip ВЫКЛЮЧЕН", Color3.fromRGB(255, 0, 0))
                elseif unName == "uninvisible" then
                    Cheat.Flags.Invisible = false
                    RestoreInvisible()
                    output("👻 Невидимость ВЫКЛЮЧЕНА", Color3.fromRGB(255, 0, 0))
                else
                    -- For all other flags, just call the base command's run function
                    Cmds[baseName].run({}, output)
                end
            else
                output("ℹ️ " .. baseName .. " уже выключен", Color3.fromRGB(180, 180, 180))
            end
        end
    }
end

AddUnAlias("unfly", "fly", "Fly")
AddUnAlias("unnoclip", "noclip", "Noclip")
AddUnAlias("unesp", "esp", "ESP")
AddUnAlias("unsaitama", "saitama", "Saitama")
AddUnAlias("unjump", "jump", "InfiniteJump")
AddUnAlias("unantiafk", "antiafk", "AntiAFK")
AddUnAlias("unautoclick", "autoclick", "AutoClick")
AddUnAlias("unspin", "spin", "Spin")
AddUnAlias("unsit", "sit", "Sit")
AddUnAlias("unfreeze", "freeze", "Freeze")
AddUnAlias("ungodmode", "godmode", "GodMode")
AddUnAlias("uninvisible", "invisible", "Invisible")
AddUnAlias("unmm2aimbot", "mm2aimbot", "MM2Aimbot")
AddUnAlias("unmm2autoshoot", "mm2autoshoot", "MM2AutoShoot")

-- RESET COMMAND (Resets all states)
Cmds.reset = {
    desc = "Сбросить состояния скрипта",

    run = function(args, output)
        StopFly() -- Stops fly and resets BV/PlatformStand

        -- Reset Flags to default state
        Cheat.Flags.ESP = false
        Cheat.Flags.Noclip = false
        Cheat.Flags.Saitama = false
        Cheat.Flags.InfiniteJump = false
        Cheat.Flags.AntiAFK = false
        Cheat.Flags.AutoClick = false
        Cheat.Flags.Spin = false
        Cheat.Flags.Sit = false
        Cheat.Flags.Freeze = false
        Cheat.Flags.GodMode = false
        Cheat.Flags.Invisible = false
        Cheat.Flags.MM2Aimbot = false
        Cheat.Flags.MM2AutoShoot = false

        -- Clear visual effects/connections
        ClearESP()
        RemoveSaitamaEffect()

        if Cheat.Runtime.FreezeBV then
            pcall(function()
                Cheat.Runtime.FreezeBV:Destroy()
            end)
            Cheat.Runtime.FreezeBV = nil
        end

        -- Disconnect all active connections (Jump, Noclip, GodMode, FlyRender)
        if Cheat.Runtime.JumpConnection then
            pcall(function()
                Cheat.Runtime.JumpConnection:Disconnect()
            end)
            Cheat.Runtime.JumpConnection = nil
        end

        if Cheat.Runtime.NoclipConnection then
            pcall(function()
                Cheat.Runtime.NoclipConnection:Disconnect()
            end)
            Cheat.Runtime.NoclipConnection = nil
        end

        if Cheat.Runtime.GodModeConnection then
            pcall(function()
                Cheat.Runtime.GodModeConnection:Disconnect()
            end)
            Cheat.Runtime.GodModeConnection = nil
        end

        if Cheat.Runtime.FlyRenderConnection then
            pcall(function()
                Cheat.Runtime.FlyRenderConnection:Disconnect()
            end)
            Cheat.Runtime.FlyRenderConnection = nil
        end

        -- Restore collision and transparency states
        RestoreNoclipCollision()
        RestoreInvisible()

        ClearWeather()

        local hum = GetHumanoid()

        if hum then
            hum.PlatformStand = false -- Unlock character movement
            hum.Sit = false         -- Ensure sitting state is cleared

            -- Restore speed to the saved value (or default 16)
            local originalSpeed =
                Cheat.Runtime.OriginalWalkSpeed
                or 16

            hum.WalkSpeed =
                originalSpeed

            Cheat.Config.SpeedValue =
                originalSpeed
        end

        JoyGui.Enabled = false -- Disable mobile controls UI

        ResetJoystick()

        output(
            "✅ Состояния сброшены. Fly НЕ включён.",
            Color3.fromRGB(
                0,
                255,
                0
            )
        )
    end
}

-- UNLOAD COMMAND (Cleans up everything)
Cmds.unload = {
    desc = "Полностью выгрузить скрипт",

    run = function(args, output)
        StopFly() -- Stops fly and resets BV/PlatformStand

        ClearESP()
        RemoveSaitamaEffect()

        -- Reset all flags to false (this is crucial for cleanup logic in other commands)
        Cheat.Flags.Noclip = false
        Cheat.Flags.Invisible = false
        Cheat.Flags.Spin = false
        Cheat.Flags.AntiAFK = false
        Cheat.Flags.AutoClick = false
        Cheat.Flags.InfiniteJump = false
        Cheat.Flags.GodMode = false

        RestoreNoclipCollision()
        RestoreInvisible()
        ClearWeather()

        if Cheat.Runtime.SpinThread then
            Cheat.Flags.Spin = false -- Ensure thread loop terminates
        end

        -- Disconnect all general connections (ESP, GodMode, FlyRender)
        for _, conn in pairs(
            Cheat.Runtime.Connections
        ) do
            pcall(function()
                conn:Disconnect()
            end)
        end
        Cheat.Runtime.Connections = {}

        -- Disconnect specific connections
        if Cheat.Runtime.JumpConnection then
            pcall(function()
                Cheat.Runtime.JumpConnection:Disconnect()
            end)
            Cheat.Runtime.JumpConnection = nil
        end

        if Cheat.Runtime.NoclipConnection then
            pcall(function()
                Cheat.Runtime.NoclipConnection:Disconnect()
            end)
            Cheat.Runtime.NoclipConnection = nil
        end

        if Cheat.Runtime.GodModeConnection then
            pcall(function()
                Cheat.Runtime.GodModeConnection:Disconnect()
            end)
            Cheat.Runtime.GodModeConnection = nil
        end

        if Cheat.Runtime.FlyRenderConnection then
            pcall(function()
                Cheat.Runtime.FlyRenderConnection:Disconnect()
            end)
            Cheat.Runtime.FlyRenderConnection = nil
        end

        -- Destroy physics objects
        if Cheat.Runtime.FreezeBV then
            pcall(function()
                Cheat.Runtime.FreezeBV:Destroy()
            end)
            Cheat.Runtime.FreezeBV = nil
        end

        -- Disconnect console listeners
        if Cheat.Runtime.ConsoleInputConnection then
            pcall(function()
                Cheat.Runtime.ConsoleInputConnection:Disconnect()
            end)
            Cheat.Runtime.ConsoleInputConnection = nil
        end

        if Cheat.Runtime.ConsoleTabConnection then
            pcall(function()
                Cheat.Runtime.ConsoleTabConnection:Disconnect()
            end)
            Cheat.Runtime.ConsoleTabConnection = nil
        end

        output(
            "🛑 Скрипт выгружен",
            Color3.fromRGB(
                255,
                0,
                0
            )
        )

        task.wait(0.1) -- Give time for network/physics to register the unload

        -- Destroy UI elements
        if GUI then
            pcall(function()
                GUI:Destroy()
            end)
            GUI = nil
        end

        if JoyGui then
            pcall(function()
                JoyGui:Destroy()
            end)
            JoyGui = nil
        end

        if MobileButton then
            pcall(function()
                MobileButton:Destroy()
            end)
            MobileButton = nil
        end

        -- Destroy weather folder/part
        if Cheat.Runtime.WeatherFolder then
            pcall(function()
                Cheat.Runtime.WeatherFolder:Destroy()
            end)
            Cheat.Runtime.WeatherFolder = nil
        end
    end
}

-- MOBILE OPEN BUTTON (The 'S' button on the screen)
MobileButton = Instance.new("ScreenGui")

MobileButton.Name =
    "MobileOpenButton"

MobileButton.ResetOnSpawn = false
MobileButton.Parent = PlayerGui

local OpenBtn = Instance.new("TextButton")

OpenBtn.Size =
    UDim2.new(0, 60, 0, 60)

OpenBtn.Position =
    UDim2.new(0.9, 0, 0.05, 0)

OpenBtn.BackgroundColor3 =
    Color3.fromRGB(
        30,
        30,
        60
    )

OpenBtn.BorderSizePixel = 2

OpenBtn.BorderColor3 =
    Color3.fromRGB(
        255,
        0,
        0
    )

OpenBtn.Text = "S" -- S for Settings/Start Console

OpenBtn.TextColor3 =
    Color3.fromRGB(
        255,
        0,
        0
    )

OpenBtn.TextScaled = true
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Parent = MobileButton

-- CONSOLE TOGGLE FUNCTIONALITY
local function ToggleConsole()
    Cheat.Runtime.ConsoleVisible =
        not Cheat.Runtime.ConsoleVisible

    if not GUI
        or not GUI.Parent then

        CreateConsole() -- Create if it doesn't exist yet
    end

    GUI.Enabled =
        Cheat.Runtime.ConsoleVisible

    -- Focus the input box when opening/enabling the console
    if Cheat.Runtime.ConsoleVisible
        and InputBox then

        task.defer(function()
            InputBox:CaptureFocus()
        end)
    end
end

OpenBtn.MouseButton1Click:Connect(
    ToggleConsole
)

-- Right Shift Double Tap Logic (Alternative toggle method)
UserInputService.InputBegan:Connect(
    function(input, gameProcessed)
        if gameProcessed then
            return
        end

        if input.KeyCode == Enum.KeyCode.RightShift then

            local now = os.clock()

            -- Check if the time since last press is less than 0.5 seconds (double tap window)
            if now - LastRightShiftPress < 0.5 then
                RightShiftPressCount += 1

                if RightShiftPressCount >= 2 then
                    RightShiftPressCount = 0 -- Reset counter after successful double tap
                    ToggleConsole()
                end
            else
                -- First press in a new sequence
                RightShiftPressCount = 1
            end

            LastRightShiftPress = now
        end
    end
)

-- ======================================================
-- INITIALIZE SCRIPT
-- ======================================================

CreateConsole() -- Initialize the console UI structure

if GUI then
    GUI.Enabled = false -- Start with console closed (unless settings dictate otherwise)
end

JoyGui.Enabled = false -- Start with mobile joystick UI hidden

pcall(function()
    StarterGui:SetCore(
        "SendNotification",
        {
            Title = "S MAX EDITION",
            Text =
                "Fly исправлен. После респавна включай fly вручную.",
            Duration = 5
        }
    )
end)

print("✅ MAX EDITION загружена")
print("✅ TouchFling удалён")
print("✅ Fly после респавна выключен (требует команды 'fly')")
print("✅ Noclip исправлен")
print("✅ Invisible исправлен")
print("✅ Weather исправлен")
print("✅ Reset/Unload исправлены")
print("✅ Console connections исправлены")
