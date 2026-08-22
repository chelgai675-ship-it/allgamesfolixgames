-- ======================================================
-- MAX EDITION & DEEPSEEK ALL GAMES — FIXED EDITION
-- ======================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- ======================================================
-- SERVICES
-- ======================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local Camera = workspace.CurrentCamera

-- ======================================================
-- CONFIG
-- ======================================================

local Cheat = {
    Config = {
        SpeedValue = 16,
        SpinSpeed = 10,
        RainbowOffset = 0,
        FlySpeed = 70,
        TouchFlingPower = 1000000,
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
        TouchFling = false,
    },

    Runtime = {
        Connections = {},

        ESPTexts = {},
        ESPSmoothed = {},
        ESPHighlights = {},
        ESPCharacterConnections = {},

        OriginalTransparency = {},
        OriginalCanCollide = {},

        FlyBodyVelocity = nil,
        FreezeBV = nil,

        ConsoleVisible = false,

        CommandHistory = {},
        HistoryIndex = 0,

        MM2TargetPart = "HumanoidRootPart",
        MM2MurdererName = nil,
        LastShotTime = 0,

        FlyDirection = Vector3.zero,
        FlyUpActive = false,
        FlyDownActive = false,

        JumpConnection = nil,
        NoclipConnection = nil,

        TouchFlingConnections = {},
        AntiFlingConnection = nil,
        AntiFlingHeartbeat = nil,

        WeatherObjects = {},

        GodModeToken = 0,
        AutoClickToken = 0,
        AntiAFKToken = 0,
        SpinToken = 0,
    }
}

-- ======================================================
-- VARIABLES
-- ======================================================

local GUI = nil
local InputBox = nil
local OutputScrolling = nil
local Cmds = {}

local LastRightShiftPress = 0
local RightShiftPressCount = 0

local IsMobile = UserInputService.TouchEnabled
local IsDesktop = not IsMobile

local SettingsFile = "max_settings.json"

-- ======================================================
-- SAFE CONNECTION REGISTRY
-- ======================================================

local function TrackConnection(connection)
    if connection then
        table.insert(Cheat.Runtime.Connections, connection)
    end

    return connection
end

local function DisconnectConnection(name)
    local connection = Cheat.Runtime[name]

    if connection then
        pcall(function()
            connection:Disconnect()
        end)

        Cheat.Runtime[name] = nil
    end
end

-- ======================================================
-- MOBILE JOYSTICK
-- ======================================================

local JoyGui = Instance.new("ScreenGui")
JoyGui.Name = "MAX_FlyJoystick"
JoyGui.ResetOnSpawn = false
JoyGui.Enabled = false
JoyGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local JoyFrame = Instance.new("Frame")
JoyFrame.Name = "Joystick"
JoyFrame.Size = UDim2.new(0, 120, 0, 120)
JoyFrame.Position = UDim2.new(0.02, 0, 0.5, -60)
JoyFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
JoyFrame.BackgroundTransparency = 0.5
JoyFrame.BorderSizePixel = 2
JoyFrame.BorderColor3 = Color3.fromRGB(80, 80, 150)
JoyFrame.Parent = JoyGui

local JoyCorner = Instance.new("UICorner")
JoyCorner.CornerRadius = UDim.new(1, 0)
JoyCorner.Parent = JoyFrame

local JoyStick = Instance.new("Frame")
JoyStick.Name = "Stick"
JoyStick.Size = UDim2.new(0, 40, 0, 40)
JoyStick.Position = UDim2.new(0.5, -20, 0.5, -20)
JoyStick.BackgroundColor3 = Color3.fromRGB(200, 200, 255)
JoyStick.BackgroundTransparency = 0.3
JoyStick.BorderSizePixel = 2
JoyStick.BorderColor3 = Color3.fromRGB(255, 255, 255)
JoyStick.Parent = JoyFrame

local JoyStickCorner = Instance.new("UICorner")
JoyStickCorner.CornerRadius = UDim.new(1, 0)
JoyStickCorner.Parent = JoyStick

local JoyActive = false

local function ResetJoystick()
    JoyActive = false

    JoyStick.Position = UDim2.new(
        0.5,
        -20,
        0.5,
        -20
    )

    Cheat.Runtime.FlyDirection = Vector3.zero
end

JoyFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        JoyActive = true
    end
end)

JoyFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        ResetJoystick()
    end
end)

TrackConnection(UserInputService.TouchEnded:Connect(function()
    if JoyActive then
        ResetJoystick()
    end
end))

JoyFrame.InputChanged:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    if not JoyActive then
        return
    end

    local center = JoyFrame.AbsolutePosition
        + JoyFrame.AbsoluteSize / 2

    local delta = input.Position - center

    local maxDist = 40
    local distance = delta.Magnitude

    if distance > maxDist then
        delta = delta.Unit * maxDist
    end

    JoyStick.Position = UDim2.new(
        0.5,
        delta.X - 20,
        0.5,
        delta.Y - 20
    )

    Cheat.Runtime.FlyDirection = Vector3.new(
        delta.X / maxDist,
        0,
        -delta.Y / maxDist
    )
end)

local UpBtn = Instance.new("TextButton")
UpBtn.Name = "Up"
UpBtn.Size = UDim2.new(0, 50, 0, 50)
UpBtn.Position = UDim2.new(0.85, 0, 0.7, 0)
UpBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
UpBtn.Text = "⬆"
UpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UpBtn.TextScaled = true
UpBtn.Font = Enum.Font.GothamBold
UpBtn.Parent = JoyGui

local DownBtn = Instance.new("TextButton")
DownBtn.Name = "Down"
DownBtn.Size = UDim2.new(0, 50, 0, 50)
DownBtn.Position = UDim2.new(0.85, 0, 0.82, 0)
DownBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
DownBtn.Text = "⬇"
DownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DownBtn.TextScaled = true
DownBtn.Font = Enum.Font.GothamBold
DownBtn.Parent = JoyGui

UpBtn.MouseButton1Down:Connect(function()
    Cheat.Runtime.FlyUpActive = true
end)

UpBtn.MouseButton1Up:Connect(function()
    Cheat.Runtime.FlyUpActive = false
end)

DownBtn.MouseButton1Down:Connect(function()
    Cheat.Runtime.FlyDownActive = true
end)

DownBtn.MouseButton1Up:Connect(function()
    Cheat.Runtime.FlyDownActive = false
end)

-- ======================================================
-- RAINBOW
-- ======================================================

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
-- SETTINGS
-- ======================================================

local function SaveSettings()
    local settings = {
        speed = Cheat.Config.SpeedValue,
        flySpeed = Cheat.Config.FlySpeed,
        spinSpeed = Cheat.Config.SpinSpeed,

        esp = Cheat.Flags.ESP,
        noclip = Cheat.Flags.Noclip,
        saitama = Cheat.Flags.Saitama,
    }

    pcall(function()
        writefile(
            SettingsFile,
            HttpService:JSONEncode(settings)
        )
    end)
end

local function LoadSettings()
    local success, data = pcall(function()
        return readfile(SettingsFile)
    end)

    if not success or not data then
        return
    end

    local ok, settings = pcall(function()
        return HttpService:JSONDecode(data)
    end)

    if not ok or type(settings) ~= "table" then
        return
    end

    if tonumber(settings.speed) then
        Cheat.Config.SpeedValue = tonumber(settings.speed)
    end

    if tonumber(settings.flySpeed) then
        Cheat.Config.FlySpeed = math.max(
            1,
            math.min(
                tonumber(settings.flySpeed),
                1e19
            )
        )
    end

    if tonumber(settings.spinSpeed) then
        Cheat.Config.SpinSpeed = tonumber(settings.spinSpeed)
    end

    Cheat.Flags.ESP = settings.esp == true

    -- Эти функции специально не включаются автоматически.
    Cheat.Flags.Fly = false
    Cheat.Flags.Noclip = false
    Cheat.Flags.Saitama = false
end

LoadSettings()

-- ======================================================
-- CHARACTER HELPERS
-- ======================================================

local function GetCharacter()
    return LocalPlayer.Character
end

local function GetHumanoid()
    local char = GetCharacter()

    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRoot()
    local char = GetCharacter()

    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ======================================================
-- SAITAMA
-- ======================================================

local function RemoveSaitamaEffect(root)
    if not root then
        return
    end

    for _, child in ipairs(root:GetChildren()) do
        if child.Name == "SaitamaBeam"
            or child.Name == "SaitamaGlow0"
            or child.Name == "SaitamaGlow1" then

            pcall(function()
                child:Destroy()
            end)
        end
    end
end

local function AddSaitamaEffect(part)
    if not part or not part:IsA("BasePart") then
        return
    end

    RemoveSaitamaEffect(part)

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
            local color = RainbowColor(
                Cheat.Config.RainbowOffset
            )

            beam.Color = ColorSequence.new(color)

            Cheat.Config.RainbowOffset =
                Cheat.Config.RainbowOffset + 0.03

            task.wait(0.05)
        end
    end)
end

-- ======================================================
-- ESP
-- ======================================================

local function GetTeamColor(player)
    local char = player.Character

    local color = Color3.fromRGB(
        255,
        255,
        255
    )

    if char then
        local function HasTool(toolName)
            if char:FindFirstChild(toolName) then
                return true
            end

            local backpack = player:FindFirstChild("Backpack")

            if backpack and backpack:FindFirstChild(toolName) then
                return true
            end

            return false
        end

        if HasTool("Knife")
            or HasTool("MurdererKnife") then

            color = Color3.fromRGB(
                255,
                50,
                50
            )

        elseif HasTool("Gun")
            or HasTool("Pistol")
            or HasTool("Revolver") then

            color = Color3.fromRGB(
                50,
                120,
                255
            )
        end
    end

    if player.Team
        and player.TeamColor
        and LocalPlayer.Team
        and LocalPlayer.TeamColor then

        if player.Team ~= LocalPlayer.Team then
            color = Color3.fromRGB(
                255,
                50,
                50
            )
        else
            color = Color3.fromRGB(
                50,
                255,
                100
            )
        end
    end

    return color
end

local function DestroyESPForPlayer(player)
    local billboard = Cheat.Runtime.ESPTexts[player]

    if billboard then
        pcall(function()
            billboard:Destroy()
        end)
    end

    Cheat.Runtime.ESPTexts[player] = nil
    Cheat.Runtime.ESPSmoothed[player] = nil

    local highlight = Cheat.Runtime.ESPHighlights[player]

    if highlight then
        pcall(function()
            highlight:Destroy()
        end)
    end

    Cheat.Runtime.ESPHighlights[player] = nil

    local connection =
        Cheat.Runtime.ESPCharacterConnections[player]

    if connection then
        pcall(function()
            connection:Disconnect()
        end)
    end

    Cheat.Runtime.ESPCharacterConnections[player] = nil
end

local function ClearESP()
    for player in pairs(Cheat.Runtime.ESPTexts) do
        DestroyESPForPlayer(player)
    end

    for player, connection
        in pairs(Cheat.Runtime.ESPCharacterConnections) do

        pcall(function()
            connection:Disconnect()
        end)

        Cheat.Runtime.ESPCharacterConnections[player] = nil
    end
end

local function AddESPForPlayer(player)
    if player == LocalPlayer then
        return
    end

    if not Cheat.Flags.ESP then
        return
    end

    DestroyESPForPlayer(player)

    local char = player.Character

    if not char then
        return
    end

    local humanoid =
        char:FindFirstChildOfClass("Humanoid")

    local root =
        char:FindFirstChild("HumanoidRootPart")

    local head =
        char:FindFirstChild("Head")

    if not humanoid or not root or not head then
        return
    end

    local color = GetTeamColor(player)

    local billboard = Instance.new("BillboardGui")

    billboard.Name = "MAX_ESP_Billboard"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 220, 0, 55)
    billboard.StudsOffset = Vector3.new(
        0,
        2.8,
        0
    )

    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 1000
    billboard.Parent = head

    local label = Instance.new("TextLabel")

    label.Name = "ESPText"
    label.Size = UDim2.new(1, 0, 1, 0)

    label.BackgroundTransparency = 1

    label.TextColor3 = color
    label.TextStrokeTransparency = 0.2
    label.TextStrokeColor3 =
        Color3.fromRGB(0, 0, 0)

    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Text = player.Name

    label.Parent = billboard

    Cheat.Runtime.ESPTexts[player] = billboard

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

    Cheat.Runtime.ESPHighlights[player] =
        highlight

    Cheat.Runtime.ESPSmoothed[player] = {
        root = root.Position,
        head = head.Position
    }

    Cheat.Runtime.ESPCharacterConnections[player] =
        player.CharacterAdded:Connect(function(newCharacter)

            if not Cheat.Flags.ESP then
                return
            end

            task.wait(0.25)

            if player.Parent
                and player.Character == newCharacter then

                AddESPForPlayer(player)
            end
        end)
end

local function CreateESP()
    ClearESP()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            AddESPForPlayer(player)
        end
    end
end

local function UpdateESP()
    if not Cheat.Flags.ESP then
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then

            local char = player.Character

            local humanoid =
                char and
                char:FindFirstChildOfClass("Humanoid")

            local root =
                char and
                char:FindFirstChild("HumanoidRootPart")

            local head =
                char and
                char:FindFirstChild("Head")

            local billboard =
                Cheat.Runtime.ESPTexts[player]

            local highlight =
                Cheat.Runtime.ESPHighlights[player]

            if humanoid and root and head then

                if not billboard
                    or not billboard.Parent then

                    AddESPForPlayer(player)

                    billboard =
                        Cheat.Runtime.ESPTexts[player]

                    highlight =
                        Cheat.Runtime.ESPHighlights[player]
                end

                if billboard then
                    billboard.Adornee = head
                    billboard.Enabled = true

                    local label =
                        billboard:FindFirstChild("ESPText")

                    if label then

                        local localRoot = GetRoot()

                        local distance = 0

                        if localRoot then
                            distance =
                                (
                                    localRoot.Position
                                    - root.Position
                                ).Magnitude
                        end

                        local hp =
                            math.max(
                                0,
                                math.floor(humanoid.Health)
                            )

                        local color =
                            GetTeamColor(player)

                        label.TextColor3 = color

                        label.Text =
                            string.format(
                                "%s [%d HP] [%d м]",
                                player.Name,
                                hp,
                                math.floor(distance)
                            )
                    end
                end

                if highlight then
                    local color =
                        GetTeamColor(player)

                    highlight.FillColor = color
                    highlight.OutlineColor = color

                    highlight.Adornee = char

                    highlight.Enabled =
                        humanoid.Health > 0
                end
            else

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

TrackConnection(
    RunService.RenderStepped:Connect(function()
        if Cheat.Flags.ESP then
            UpdateESP()
        end
    end)
)

TrackConnection(
    Players.PlayerAdded:Connect(function(player)

        if not Cheat.Flags.ESP then
            return
        end

        task.spawn(function()

            local character =
                player.Character
                or player.CharacterAdded:Wait()

            if not Cheat.Flags.ESP
                or not player.Parent then

                return
            end

            task.wait(0.25)

            if player.Character == character then
                AddESPForPlayer(player)
            end
        end)
    end)
)

TrackConnection(
    Players.PlayerRemoving:Connect(function(player)
        DestroyESPForPlayer(player)
    end)
)

-- ======================================================
-- TRANSPARENCY
-- ======================================================

local function SaveTransparency(character)
    if not character then
        return
    end

    Cheat.Runtime.OriginalTransparency = {}

    for _, object in ipairs(character:GetDescendants()) do
        if object:IsA("BasePart") then
            Cheat.Runtime.OriginalTransparency[object] =
                object.Transparency
        elseif object:IsA("Decal") then
            Cheat.Runtime.OriginalTransparency[object] =
                object.Transparency
        end
    end
end

local function SetInvisible(enabled)
    local character = GetCharacter()

    if not character then
        return
    end

    if enabled then
        SaveTransparency(character)

        for _, object in ipairs(character:GetDescendants()) do

            if object:IsA("BasePart")
                or object:IsA("Decal") then

                object.Transparency = 1
            end
        end
    else

        for object, transparency
            in pairs(Cheat.Runtime.OriginalTransparency) do

            if object and object.Parent then
                object.Transparency = transparency
            end
        end

        Cheat.Runtime.OriginalTransparency = {}
    end
end

-- ======================================================
-- NOCLIP
-- ======================================================

local function SaveCollision(character)
    Cheat.Runtime.OriginalCanCollide = {}

    for _, object in ipairs(character:GetDescendants()) do
        if object:IsA("BasePart") then
            Cheat.Runtime.OriginalCanCollide[object] =
                object.CanCollide
        end
    end
end

local function RestoreCollision(character)
    for object, value
        in pairs(Cheat.Runtime.OriginalCanCollide) do

        if object
            and object.Parent
            and object:IsA("BasePart") then

            object.CanCollide = value
        end
    end

    Cheat.Runtime.OriginalCanCollide = {}
end

local function StartNoclip()
    DisconnectConnection("NoclipConnection")

    local character = GetCharacter()

    if character then
        SaveCollision(character)
    end

    Cheat.Runtime.NoclipConnection =
        RunService.Stepped:Connect(function()

            if not Cheat.Flags.Noclip then
                return
            end

            local char = GetCharacter()

            if not char then
                return
            end

            for _, object in ipairs(char:GetDescendants()) do
                if object:IsA("BasePart") then
                    object.CanCollide = false
                end
            end
        end)
end

local function StopNoclip()
    DisconnectConnection("NoclipConnection")

    local character = GetCharacter()

    if character then
        RestoreCollision(character)
    end
end

-- ======================================================
-- FLY
-- ======================================================

local function StopFly()
    Cheat.Flags.Fly = false

    if Cheat.Runtime.FlyBodyVelocity then
        pcall(function()
            Cheat.Runtime.FlyBodyVelocity:Destroy()
        end)

        Cheat.Runtime.FlyBodyVelocity = nil
    end

    local humanoid = GetHumanoid()

    if humanoid then
        humanoid.PlatformStand = false
    end

    Cheat.Runtime.FlyDirection = Vector3.zero
    Cheat.Runtime.FlyUpActive = false
    Cheat.Runtime.FlyDownActive = false

    if IsMobile and JoyGui then
        JoyGui.Enabled = false
    end
end

-- ======================================================
-- SPIN
-- ======================================================

local function StopSpin()
    Cheat.Flags.Spin = false
    Cheat.Runtime.SpinToken =
        Cheat.Runtime.SpinToken + 1
end

local function StartSpin()
    if Cheat.Flags.Spin then
        return
    end

    Cheat.Flags.Spin = true

    Cheat.Runtime.SpinToken =
        Cheat.Runtime.SpinToken + 1

    local token =
        Cheat.Runtime.SpinToken

    task.spawn(function()

        while Cheat.Flags.Spin
            and token == Cheat.Runtime.SpinToken do

            local root = GetRoot()

            if root then
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
    end)
end

-- ======================================================
-- GOD MODE
-- ======================================================

local function StopGodMode()
    Cheat.Flags.GodMode = false

    Cheat.Runtime.GodModeToken =
        Cheat.Runtime.GodModeToken + 1
end

local function StartGodMode()
    if Cheat.Flags.GodMode then
        return
    end

    Cheat.Flags.GodMode = true

    Cheat.Runtime.GodModeToken =
        Cheat.Runtime.GodModeToken + 1

    local token =
        Cheat.Runtime.GodModeToken

    task.spawn(function()

        while Cheat.Flags.GodMode
            and token == Cheat.Runtime.GodModeToken do

            local humanoid = GetHumanoid()

            if humanoid
                and humanoid.Health > 0 then

                humanoid.Health =
                    humanoid.MaxHealth
            end

            task.wait(0.2)
        end
    end)
end

-- ======================================================
-- ANTI-AFK
-- ======================================================

local function StopAntiAFK()
    Cheat.Flags.AntiAFK = false

    Cheat.Runtime.AntiAFKToken =
        Cheat.Runtime.AntiAFKToken + 1
end

local function StartAntiAFK()
    if Cheat.Flags.AntiAFK then
        return
    end

    Cheat.Flags.AntiAFK = true

    Cheat.Runtime.AntiAFKToken =
        Cheat.Runtime.AntiAFKToken + 1

    local token =
        Cheat.Runtime.AntiAFKToken

    task.spawn(function()

        while Cheat.Flags.AntiAFK
            and token == Cheat.Runtime.AntiAFKToken do

            task.wait(30)

            if not Cheat.Flags.AntiAFK
                or token ~= Cheat.Runtime.AntiAFKToken then

                break
            end

            local humanoid = GetHumanoid()

            if humanoid then
                humanoid.Jump = true
            end
        end
    end)
end

-- ======================================================
-- AUTO CLICK
-- ======================================================

local function StopAutoClick()
    Cheat.Flags.AutoClick = false

    Cheat.Runtime.AutoClickToken =
        Cheat.Runtime.AutoClickToken + 1
end

local function StartAutoClick()
    if Cheat.Flags.AutoClick then
        return
    end

    Cheat.Flags.AutoClick = true

    Cheat.Runtime.AutoClickToken =
        Cheat.Runtime.AutoClickToken + 1

    local token =
        Cheat.Runtime.AutoClickToken

    task.spawn(function()

        while Cheat.Flags.AutoClick
            and token == Cheat.Runtime.AutoClickToken do

            pcall(function()

                local virtualInput =
                    game:GetService(
                        "VirtualInputManager"
                    )

                virtualInput:SendMouseButtonEvent(
                    0,
                    0,
                    0,
                    true,
                    game,
                    0
                )

                task.wait(0.01)

                virtualInput:SendMouseButtonEvent(
                    0,
                    0,
                    0,
                    false,
                    game,
                    0
                )
            end)

            task.wait(0.1)
        end
    end)
end

-- ======================================================
-- WEATHER
-- ======================================================

local WeatherState = {
    Type = "sun"
}

local function ClearWeather()
    for _, object in ipairs(
        Cheat.Runtime.WeatherObjects
    ) do

        pcall(function()
            object:Destroy()
        end)
    end

    Cheat.Runtime.WeatherObjects = {}

    WeatherState.Type = "sun"
end

local function CreateWeatherEmitter(name)
    local character = GetCharacter()
    local root =
        character and
        character:FindFirstChild("HumanoidRootPart")

    if not root then
        return nil
    end

    local attachment = Instance.new("Attachment")

    attachment.Name = name
    attachment.Parent = root

    table.insert(
        Cheat.Runtime.WeatherObjects,
        attachment
    )

    return attachment
end

local function CreateRain()
    ClearWeather()

    local attachment =
        CreateWeatherEmitter(
            "MAX_RainAttachment"
        )

    if not attachment then
        return false
    end

    local emitter = Instance.new("ParticleEmitter")

    emitter.Name = "MAX_Rain"
    emitter.Rate = 300
    emitter.Lifetime = NumberRange.new(0.5, 1)
    emitter.Speed = NumberRange.new(40, 60)
    emitter.Acceleration =
        Vector3.new(0, -30, 0)

    emitter.SpreadAngle =
        Vector2.new(5, 5)

    emitter.Size =
        NumberSequence.new(0.08)

    emitter.Parent = attachment

    WeatherState.Type = "rain"

    return true
end

local function CreateSnow()
    ClearWeather()

    local attachment =
        CreateWeatherEmitter(
            "MAX_SnowAttachment"
        )

    if not attachment then
        return false
    end

    local emitter = Instance.new("ParticleEmitter")

    emitter.Name = "MAX_Snow"
    emitter.Rate = 100
    emitter.Lifetime = NumberRange.new(2, 4)
    emitter.Speed = NumberRange.new(2, 6)

    emitter.Acceleration =
        Vector3.new(0, -3, 0)

    emitter.SpreadAngle =
        Vector2.new(30, 30)

    emitter.Size =
        NumberSequence.new(0.3)

    emitter.Parent = attachment

    WeatherState.Type = "snow"

    return true
end

-- ======================================================
-- PLAYER SEARCH
-- ======================================================

local function FindPlayersByExactName(name)
    local matches = {}
    local lowerName = name:lower()

    for _, player in ipairs(Players:GetPlayers()) do

        if player ~= LocalPlayer then

            local username =
                player.Name:lower()

            local displayName =
                player.DisplayName
                and player.DisplayName:lower()

            if username == lowerName
                or displayName == lowerName then

                table.insert(
                    matches,
                    player
                )
            end
        end
    end

    return matches
end

local function FindPlayersByPrefix(prefix)
    local matches = {}
    local lowerPrefix = prefix:lower()

    for _, player in ipairs(Players:GetPlayers()) do

        if player ~= LocalPlayer then

            local username =
                player.Name:lower()

            local displayName =
                player.DisplayName
                and player.DisplayName:lower()

            if username:sub(
                    1,
                    #lowerPrefix
                ) == lowerPrefix
                or (
                    displayName
                    and displayName:sub(
                        1,
                        #lowerPrefix
                    ) == lowerPrefix
                ) then

                table.insert(
                    matches,
                    player
                )
            end
        end
    end

    return matches
end

local function FindPlayersBySubstring(substr)
    local matches = {}
    local lowerSubstr = substr:lower()

    for _, player in ipairs(Players:GetPlayers()) do

        if player ~= LocalPlayer then

            local username =
                player.Name:lower()

            local displayName =
                player.DisplayName
                and player.DisplayName:lower()

            if username:find(
                    lowerSubstr,
                    1,
                    true
                )
                or (
                    displayName
                    and displayName:find(
                        lowerSubstr,
                        1,
                        true
                    )
                ) then

                table.insert(
                    matches,
                    player
                )
            end
        end
    end

    return matches
end

-- ======================================================
-- CONSOLE
-- ======================================================

local function AddConsoleOutput(text, color)
    if not OutputScrolling then
        return
    end

    local label = Instance.new("TextLabel")

    label.Size =
        UDim2.new(1, -10, 0, 22)

    label.Position =
        UDim2.new(
            0,
            5,
            0,
            OutputScrolling.CanvasSize.Y.Offset
        )

    label.BackgroundTransparency = 1

    label.Text = tostring(text)

    label.TextColor3 =
        color
        or Color3.fromRGB(
            255,
            255,
            255
        )

    label.TextXAlignment =
        Enum.TextXAlignment.Left

    label.Font = Enum.Font.Gotham
    label.TextSize = 14

    label.Parent = OutputScrolling

    OutputScrolling.CanvasSize =
        UDim2.new(
            0,
            0,
            0,
            OutputScrolling.CanvasSize.Y.Offset
                + 24
        )

    OutputScrolling.CanvasPosition =
        Vector2.new(
            0,
            OutputScrolling.CanvasSize.Y.Offset
        )
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
        parts[1]:lower()

    table.remove(parts, 1)

    local args = parts

    if name == "tp" then
        name = "goto"
    end

    if Cmds[name] then
        local success, errorMessage =
            pcall(function()
                Cmds[name].run(
                    args,
                    output
                )
            end)

        if not success then
            output(
                "❌ Ошибка: "
                    .. tostring(errorMessage),
                Color3.fromRGB(
                    255,
                    70,
                    70
                )
            )
        end
    else
        output(
            "⚠️ Неизвестная команда. Используйте help",
            Color3.fromRGB(
                255,
                255,
                0
            )
        )
    end
end

local function CreateConsole()
    if GUI then
        pcall(function()
            GUI:Destroy()
        end)

        GUI = nil
    end

    GUI = Instance.new("ScreenGui")

    GUI.Name =
        "MaxEditionConsole"

    GUI.ResetOnSpawn = false

    GUI.Enabled =
        Cheat.Runtime.ConsoleVisible

    GUI.Parent =
        LocalPlayer:WaitForChild(
            "PlayerGui"
        )

    local MainFrame = Instance.new("Frame")

    MainFrame.Name = "Main"

    MainFrame.Size =
        UDim2.new(
            0,
            600,
            0,
            450
        )

    MainFrame.Position =
        UDim2.new(
            0.5,
            -300,
            0.5,
            -225
        )

    MainFrame.BackgroundColor3 =
        Color3.fromRGB(
            15,
            15,
            30
        )

    MainFrame.BackgroundTransparency = 0.05

    MainFrame.BorderSizePixel = 2

    MainFrame.BorderColor3 =
        Color3.fromRGB(
            255,
            215,
            0
        )

    MainFrame.Active = true
    MainFrame.Draggable = true

    MainFrame.Parent = GUI

    local Title = Instance.new("TextLabel")

    Title.Size =
        UDim2.new(
            1,
            0,
            0,
            40
        )

    Title.BackgroundColor3 =
        Color3.fromRGB(
            40,
            40,
            70
        )

    Title.Text =
        "⚡ MAX EDITION & DEEPSEEK ALL GAMES"

    Title.TextColor3 =
        Color3.fromRGB(
            255,
            215,
            0
        )

    Title.TextScaled = true
    Title.Font = Enum.Font.GothamBold

    Title.Parent = MainFrame

    local InfoLabel =
        Instance.new("TextLabel")

    InfoLabel.Size =
        UDim2.new(
            1,
            0,
            0,
            20
        )

    InfoLabel.Position =
        UDim2.new(
            0,
            0,
            0,
            40
        )

    InfoLabel.BackgroundTransparency = 1

    InfoLabel.Text =
        "🟢 Кнопка ⚡ или двойной RightShift"

    InfoLabel.TextColor3 =
        Color3.fromRGB(
            150,
            200,
            255
        )

    InfoLabel.TextScaled = true
    InfoLabel.Font = Enum.Font.Gotham

    InfoLabel.Parent = MainFrame

    OutputScrolling =
        Instance.new("ScrollingFrame")

    OutputScrolling.Size =
        UDim2.new(
            1,
            -20,
            0,
            280
        )

    OutputScrolling.Position =
        UDim2.new(
            0,
            10,
            0,
            65
        )

    OutputScrolling.BackgroundColor3 =
        Color3.fromRGB(
            5,
            5,
            15
        )

    OutputScrolling.BackgroundTransparency = 0.3

    OutputScrolling.BorderSizePixel = 1

    OutputScrolling.BorderColor3 =
        Color3.fromRGB(
            60,
            60,
            100
        )

    OutputScrolling.CanvasSize =
        UDim2.new(
            0,
            0,
            0,
            0
        )

    OutputScrolling.ScrollBarThickness = 5

    OutputScrolling.Parent = MainFrame

    InputBox =
        Instance.new("TextBox")

    InputBox.Size =
        UDim2.new(
            1,
            -20,
            0,
            35
        )

    InputBox.Position =
        UDim2.new(
            0,
            10,
            0,
            355
        )

    InputBox.BackgroundColor3 =
        Color3.fromRGB(
            25,
            25,
            45
        )

    InputBox.BorderSizePixel = 1

    InputBox.BorderColor3 =
        Color3.fromRGB(
            80,
            80,
            150
        )

    InputBox.Text = ""

    InputBox.TextColor3 =
        Color3.fromRGB(
            255,
            255,
            255
        )

    InputBox.TextSize = 16
    InputBox.Font = Enum.Font.Gotham

    InputBox.PlaceholderText =
        "Введите команду... (help)"

    InputBox.Parent = MainFrame

    AddConsoleOutput(
        "⚡ MAX EDITION & DEEPSEEK | FIXED",
        Color3.fromRGB(
            255,
            215,
            0
        )
    )

    InputBox.InputBegan:Connect(function(input)

        if input.KeyCode == Enum.KeyCode.Up then

            if #Cheat.Runtime.CommandHistory > 0 then

                Cheat.Runtime.HistoryIndex =
                    math.max(
                        1,
                        Cheat.Runtime.HistoryIndex - 1
                    )

                InputBox.Text =
                    Cheat.Runtime.CommandHistory[
                        Cheat.Runtime.HistoryIndex
                    ]

                InputBox.CursorPosition =
                    #InputBox.Text
            end

        elseif input.KeyCode == Enum.KeyCode.Down then

            if Cheat.Runtime.HistoryIndex
                < #Cheat.Runtime.CommandHistory then

                Cheat.Runtime.HistoryIndex =
                    Cheat.Runtime.HistoryIndex + 1

                InputBox.Text =
                    Cheat.Runtime.CommandHistory[
                        Cheat.Runtime.HistoryIndex
                    ]

            else

                Cheat.Runtime.HistoryIndex =
                    #Cheat.Runtime.CommandHistory + 1

                InputBox.Text = ""
            end

        elseif input.KeyCode == Enum.KeyCode.Tab then

            local text =
                InputBox.Text:lower()

            local match

            for name in pairs(Cmds) do

                if name:sub(
                        1,
                        #text
                    ):lower() == text then

                    match = name
                    break
                end
            end

            if match then
                InputBox.Text = match

                InputBox.CursorPosition =
                    #InputBox.Text
            end
        end
    end)

    InputBox.FocusLost:Connect(
        function(enterPressed)

            if not enterPressed then
                return
            end

            local cmd =
                InputBox.Text

            InputBox.Text = ""

            if cmd == "" then
                return
            end

            AddConsoleOutput(
                "> " .. cmd,
                Color3.fromRGB(
                    200,
                    200,
                    255
                )
            )

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
                AddConsoleOutput
            )
        end
    )

    return MainFrame
end

-- ======================================================
-- CONSOLE TOGGLE
-- ======================================================

local function ToggleConsole()
    Cheat.Runtime.ConsoleVisible =
        not Cheat.Runtime.ConsoleVisible

    if not GUI
        or not GUI.Parent then

        CreateConsole()
    end

    if GUI then

        GUI.Enabled =
            Cheat.Runtime.ConsoleVisible

        if Cheat.Runtime.ConsoleVisible
            and InputBox then

            task.defer(function()
                InputBox:CaptureFocus()
            end)
        end
    end
end

TrackConnection(
    UserInputService.InputBegan:Connect(
        function(input, processed)

            if processed then
                return
            end

            if input.KeyCode
                ~= Enum.KeyCode.RightShift then

                return
            end

            local currentTime =
                os.clock()

            if currentTime
                - LastRightShiftPress
                < 0.5 then

                RightShiftPressCount =
                    RightShiftPressCount + 1

                if RightShiftPressCount >= 2 then
                    RightShiftPressCount = 0
                    ToggleConsole()
                end
            else
                RightShiftPressCount = 1
            end

            LastRightShiftPress =
                currentTime
        end
    )
)

-- ======================================================
-- MOBILE BUTTON
-- ======================================================

local MobileButton =
    Instance.new("ScreenGui")

MobileButton.Name =
    "MobileOpenButton"

MobileButton.ResetOnSpawn = false

MobileButton.Parent =
    LocalPlayer:WaitForChild(
        "PlayerGui"
    )

local OpenBtn =
    Instance.new("TextButton")

OpenBtn.Size =
    UDim2.new(
        0,
        60,
        0,
        60
    )

OpenBtn.Position =
    UDim2.new(
        0.9,
        0,
        0.05,
        0
    )

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
        215,
        0
    )

OpenBtn.Text = "⚡"

OpenBtn.TextColor3 =
    Color3.fromRGB(
        255,
        215,
        0
    )

OpenBtn.TextScaled = true
OpenBtn.Font = Enum.Font.GothamBold

OpenBtn.Parent = MobileButton

OpenBtn.MouseButton1Click:Connect(
    ToggleConsole
)

if not IsMobile then
    MobileButton.Enabled = false
end

-- ======================================================
-- COMMANDS
-- ======================================================

Cmds.help = {
    desc = "Показать все команды",

    run = function(args, output)

        output(
            "===== ДОСТУПНЫЕ КОМАНДЫ =====",
            Color3.fromRGB(
                255,
                215,
                0
            )
        )

        local commands = {
            "help",
            "fly",
            "unfly",
            "speed",
            "noclip",
            "fakeheal",
            "goto",
            "esp",
            "saitama",
            "antiafk",
            "autoclick",
            "spin",
            "sit",
            "jump",
            "tpall",
            "freeze",
            "touchfling",
            "untouchfling",
            "time",
            "weather",
            "godmode",
            "invisible",
            "mm2aimbot",
            "mm2autoshoot",
            "reset",
            "unload",
        }

        for _, name in ipairs(commands) do

            if Cmds[name] then

                output(
                    name
                        .. " - "
                        .. Cmds[name].desc,
                    Color3.fromRGB(
                        200,
                        200,
                        255
                    )
                )

            elseif name == "goto" then

                output(
                    "goto/tp - Телепорт к игроку или координатам",
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
            Color3.fromRGB(
                255,
                215,
                0
            )
        )
    end
}

-- ======================================================
-- ANTI AFK
-- ======================================================

Cmds.antiafk = {
    desc = "Защита от AFK",

    run = function(args, output)

        if Cheat.Flags.AntiAFK then
            StopAntiAFK()

            output(
                "🛡️ Anti-AFK ВЫКЛЮЧЕН",
                Color3.fromRGB(
                    255,
                    0,
                    0
                )
            )
        else
            StartAntiAFK()

            output(
                "🛡️ Anti-AFK ВКЛЮЧЕН",
                Color3.fromRGB(
                    0,
                    255,
                    0
                )
            )
        end
    end
}

-- ======================================================
-- AUTO CLICK
-- ======================================================

Cmds.autoclick = {
    desc = "Авто-кликер",

    run = function(args, output)

        if Cheat.Flags.AutoClick then
            StopAutoClick()

            output(
                "🖱️ Авто-кликер ВЫКЛЮЧЕН",
                Color3.fromRGB(
                    255,
                    0,
                    0
                )
            )
        else
            StartAutoClick()

            output(
                "🖱️ Авто-кликер ВКЛЮЧЕН",
                Color3.fromRGB(
                    0,
                    255,
                    0
                )
            )
        end
    end
}

-- ======================================================
-- SPIN
-- ======================================================

Cmds.spin = {
    desc = "Вращение: spin [скорость]",

    run = function(args, output)

        local speed =
            tonumber(args[1])

        if speed then

            Cheat.Config.SpinSpeed =
                speed

            if not Cheat.Flags.Spin then
                StartSpin()
            end

            output(
                "🔄 Скорость вращения: "
                    .. tostring(speed),
                Color3.fromRGB(
                    0,
                    255,
                    0
                )
            )

        else

            if Cheat.Flags.Spin then
                StopSpin()

                output(
                    "🔄 Вращение ВЫКЛЮЧЕНО",
                    Color3.fromRGB(
                        255,
                        0,
                        0
                    )
                )
            else
                StartSpin()

                output(
                    "🔄 Вращение ВКЛЮЧЕНО",
                    Color3.fromRGB(
                        0,
                        255,
                        0
                    )
                )
            end
        end
    end
}

-- ======================================================
-- SIT
-- ======================================================

Cmds.sit = {
    desc = "Сесть / встать",

    run = function(args, output)

        Cheat.Flags.Sit =
            not Cheat.Flags.Sit

        local humanoid =
            GetHumanoid()

        if not humanoid then
            return
        end

        humanoid.Sit =
            Cheat.Flags.Sit

        output(
            "🪑 "
                .. (
                    Cheat.Flags.Sit
                    and "Сел"
                    or "Встал"
                ),
            Color3.fromRGB(
                0,
                255,
                0
            )
        )
    end
}

-- ======================================================
-- INFINITE JUMP
-- ======================================================

Cmds.jump = {
    desc = "Включить/выключить бесконечный прыжок",

    run = function(args, output)

        Cheat.Flags.InfiniteJump =
            not Cheat.Flags.InfiniteJump

        DisconnectConnection(
            "JumpConnection"
        )

        if Cheat.Flags.InfiniteJump then

            Cheat.Runtime.JumpConnection =
                UserInputService.JumpRequest:Connect(
                    function()

                        local humanoid =
                            GetHumanoid()

                        if humanoid
                            and not humanoid.PlatformStand then

                            humanoid:ChangeState(
                                Enum.HumanoidStateType.Jumping
                            )
                        end
                    end
                )

            output(
                "🦘 Бесконечный прыжок ВКЛЮЧЕН",
                Color3.fromRGB(
                    0,
                    255,
                    0
                )
            )

        else

            output(
                "🦘 Бесконечный прыжок ВЫКЛЮЧЕН",
                Color3.fromRGB(
                    255,
                    0,
                    0
                )
            )
        end
    end
}

-- ======================================================
-- TP ALL
-- ======================================================

Cmds.tpall = {
    desc = "Телепортировать всех к себе",

    run = function(args, output)

        local root = GetRoot()

        if not root then

            output(
                "⚠️ Вы не в игре",
                Color3.fromRGB(
                    255,
                    255,
                    0
                )
            )

            return
        end

        local position =
            root.Position

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

                    pcall(function()

                        targetRoot.CFrame =
                            CFrame.new(
                                position
                                    + Vector3.new(
                                        0,
                                        3,
                                        0
                                    )
                            )
                    end)

                    count =
                        count + 1
                end
            end
        end

        output(
            "📍 Обработано игроков: "
                .. tostring(count),
            Color3.fromRGB(
                0,
                255,
                0
            )
        )
    end
}

-- ======================================================
-- FREEZE
-- ======================================================

local function StopFreeze()
    Cheat.Flags.Freeze = false

    if Cheat.Runtime.FreezeBV then
        pcall(function()
            Cheat.Runtime.FreezeBV:Destroy()
        end)

        Cheat.Runtime.FreezeBV = nil
    end

    local humanoid =
        GetHumanoid()

    if humanoid then
        humanoid.PlatformStand = false
        humanoid.Sit = false
    end
end

local function StartFreeze()
    StopFreeze()

    Cheat.Flags.Freeze = true

    local root = GetRoot()

    if not root then
        return
    end

    local bodyVelocity =
        Instance.new("BodyVelocity")

    bodyVelocity.Name =
        "MAX_FreezeVelocity"

    bodyVelocity.MaxForce =
        Vector3.new(
            1,
            1,
            1
        ) * 100000

    bodyVelocity.Velocity =
        Vector3.zero

    bodyVelocity.Parent = root

    Cheat.Runtime.FreezeBV =
        bodyVelocity

    local humanoid =
        GetHumanoid()

    if humanoid then
        humanoid.PlatformStand = true
    end
end

Cmds.freeze = {
    desc = "Заморозить/разморозить себя",

    run = function(args, output)

        if Cheat.Flags.Freeze then
            StopFreeze()

            output(
                "🧊 Вы разморожены",
                Color3.fromRGB(
                    0,
                    255,
                    0
                )
            )
        else
            StartFreeze()

            output(
                "🧊 Вы заморожены",
                Color3.fromRGB(
                    0,
                    255,
                    0
                )
            )
        end
    end
}

-- ======================================================
-- TIME
-- ======================================================

Cmds.time = {
    desc = "Установить время: time [0-23]",

    run = function(args, output)

        local hour =
            tonumber(args[1])

        if not hour then

            output(
                "⚠️ Использование: time [0-23]",
                Color3.fromRGB(
                    255,
                    255,
                    0
                )
            )

            return
        end

        hour =
            math.clamp(
                hour,
                0,
                23
            )

        Lighting.ClockTime =
            hour

        output(
            "🕐 Время: "
                .. tostring(hour)
                .. ":00",
            Color3.fromRGB(
                0,
                255,
                0
            )
        )
    end
}

-- ======================================================
-- WEATHER
-- ======================================================

Cmds.weather = {
    desc = "Погода: weather [rain/sun/snow]",

    run = function(args, output)

        local weatherType =
            args[1]
            and args[1]:lower()

        if not weatherType then

            output(
                "⚠️ Использование: weather [rain/sun/snow]",
                Color3.fromRGB(
                    255,
                    255,
                    0
                )
            )

            return
        end

        if weatherType == "rain" then

            if CreateRain() then

                output(
                    "🌧️ Дождь включён",
                    Color3.fromRGB(
                        0,
                        255,
                        0
                    )
                )

            else

                output(
                    "⚠️ Персонаж не готов",
                    Color3.fromRGB(
                        255,
                        255,
                        0
                    )
                )
            end

        elseif weatherType == "snow" then

            if CreateSnow() then

                output(
                    "❄️ Снег включён",
                    Color3.fromRGB(
                        0,
                        255,
                        0
                    )
                )

            else

                output(
                    "⚠️ Персонаж не готов",
                    Color3.fromRGB(
                        255,
                        255,
                        0
                    )
                )
            end

        elseif weatherType == "sun" then

            ClearWeather()

            output(
                "☀️ Солнечно",
                Color3.fromRGB(
                    0,
                    255,
                    0
                )
            )

        else

            output(
                "⚠️ Неизвестный тип",
                Color3.fromRGB(
                    255,
                    255,
                    0
                )
            )
        end
    end
}

-- ======================================================
-- SPEED
-- ======================================================

Cmds.speed = {
    desc = "Установить скорость: speed [число]",

    run = function(args, output)

        local speed =
            tonumber(args[1])

        if not speed then

            output(
                "⚠️ Использование: speed [число]",
                Color3.fromRGB(
                    255,
                    255,
                    0
                )
            )

            return
        end

        Cheat.Config.SpeedValue =
            math.max(
                0,
                speed
            )

        local humanoid =
            GetHumanoid()

        if humanoid then
            humanoid.WalkSpeed =
                Cheat.Config.SpeedValue
        end

        output(
            "🏃 Скорость установлена: "
                .. tostring(
                    Cheat.Config.SpeedValue
                ),
            Color3.fromRGB(
                0,
                255,
                0
            )
        )

        SaveSettings()
    end
}

-- ======================================================
-- NOCLIP
-- ======================================================

Cmds.noclip = {
    desc = "Включить/выключить прохождение сквозь стены",

    run = function(args, output)

        Cheat.Flags.Noclip =
            not Cheat.Flags.Noclip

        if Cheat.Flags.Noclip then

            StartNoclip()

            output(
                "🚧 Noclip ВКЛЮЧЕН",
                Color3.fromRGB(
                    0,
                    255,
                    0
                )
            )

        else

            StopNoclip()

            output(
                "🚧 Noclip ВЫКЛЮЧЕН",
                Color3.fromRGB(
                    255,
                    0,
                    0
                )
            )
        end

        SaveSettings()
    end
}

-- ======================================================
-- FAKE HEAL
-- ======================================================

Cmds.fakeheal = {
    desc = "Восстановить здоровье",

    run = function(args, output)

        local humanoid =
            GetHumanoid()

        if not humanoid then
            return
        end

        humanoid.Health =
            humanoid.MaxHealth

        output(
            "❤️ Здоровье восстановлено",
            Color3.fromRGB(
                0,
                255,
                0
            )
        )
    end
}

-- ======================================================
-- GOTO / TP
-- ======================================================

Cmds.goto = {
    desc = "Телепорт к игроку или координатам",

    run = function(args, output)

        if #args == 0 then

            output(
                "⚠️ Использование: goto [имя] или goto [x y z]",
                Color3.fromRGB(
                    255,
                    255,
                    0
                )
            )

            return
        end

        local root = GetRoot()

        if not root then

            output(
                "⚠️ Вы не в игре",
                Color3.fromRGB(
                    255,
                    255,
                    0
                )
            )

            return
        end

        if tonumber(args[1]) then

            if #args < 3 then

                output(
                    "⚠️ Нужно три координаты: x y z",
                    Color3.fromRGB(
                        255,
                        255,
                        0
                    )
                )

                return
            end

            local x =
                tonumber(args[1])

            local y =
                tonumber(args[2])

            local z =
                tonumber(args[3])

            if x and y and z then

                root.CFrame =
                    CFrame.new(
                        x,
                        y,
                        z
                    )

                output(
                    "📍 Телепорт на координаты",
                    Color3.fromRGB(
                        0,
                        255,
                        0
                    )
                )
            end

            return
        end

        local query =
            table.concat(
                args,
                " "
            )

        local candidates =
            FindPlayersByExactName(
                query
            )

        if #candidates == 0 then
            candidates =
                FindPlayersByPrefix(
                    query
                )
        end

        if #candidates == 0 then
            candidates =
                FindPlayersBySubstring(
                    query
                )
        end

        if #candidates == 1 then

            local target =
                candidates[1]

            local targetRoot =
                target.Character
                and target.Character:FindFirstChild(
                    "HumanoidRootPart"
                )

            if targetRoot then

                root.CFrame =
                    targetRoot.CFrame
                    + Vector3.new(
                        0,
                        3,
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

        if #candidates > 1 then

            output(
                "⚠️ Найдено несколько игроков:",
                Color3.fromRGB(
                    255,
                    255,
                    0
                )
            )

            for _, player in ipairs(
                candidates
            ) do

                output(
                    "   - "
                        .. player.Name
                        .. (
                            player.DisplayName
                                ~= player.Name
                            and " ("
                                .. player.DisplayName
                                .. ")"
                            or ""
                        ),
                    Color3.fromRGB(
                        255,
                        255,
                        0
                    )
                )
            end

            return
        end

        output(
            "⚠️ Игрок не найден",
            Color3.fromRGB(
                255,
                255,
                0
            )
        )
    end
}

-- ======================================================
-- ESP COMMAND
-- ======================================================

Cmds.esp = {
    desc = "Включить/выключить ESP",

    run = function(args, output)

        Cheat.Flags.ESP =
            not Cheat.Flags.ESP

        if Cheat.Flags.ESP then

            CreateESP()

            output(
                "👁️ ESP ВКЛЮЧЕН",
                Color3.fromRGB(
                    0,
                    255,
                    0
                )
            )

        else

            ClearESP()

            output(
                "👁️ ESP ВЫКЛЮЧЕН",
                Color3.fromRGB(
                    255,
                    0,
                    0
                )
            )
        end

        SaveSettings()
    end
}

-- ======================================================
-- SAITAMA COMMAND
-- ======================================================

Cmds.saitama = {
    desc = "Включить/выключить режим Сайтамы",

    run = function(args, output)

        Cheat.Flags.Saitama =
            not Cheat.Flags.Saitama

        local root = GetRoot()

        if not root then
            return
        end

        if Cheat.Flags.Saitama then

            AddSaitamaEffect(root)

            output(
                "👊 Режим Сайтамы ВКЛЮЧЕН",
                Color3.fromRGB(
                    0,
                    255,
                    0
                )
            )

        else

            RemoveSaitamaEffect(root)

            output(
                "👊 Режим Сайтамы ВЫКЛЮЧЕН",
                Color3.fromRGB(
                    255,
                    0,
                    0
                )
            )
        end

        SaveSettings()
    end
}

-- ======================================================
-- GOD MODE
-- ======================================================

Cmds.godmode = {
    desc = "Включить/выключить бессмертие",

    run = function(args, output)

        if Cheat.Flags.GodMode then

            StopGodMode()

            output(
                "🛡️ Бессмертие ВЫКЛЮЧЕНО",
                Color3.fromRGB(
                    255,
                    0,
                    0
                )
            )

        else

            StartGodMode()

            output(
                "🛡️ Бессмертие ВКЛЮЧЕНО",
                Color3.fromRGB(
                    0,
                    255,
                    0
                )
            )
        end
    end
}

-- ======================================================
-- INVISIBLE
-- ======================================================

Cmds.invisible = {
    desc = "Включить/выключить невидимость",

    run = function(args, output)

        Cheat.Flags.Invisible =
            not Cheat.Flags.Invisible

        SetInvisible(
            Cheat.Flags.Invisible
        )

        output(
            "👻 Невидимость "
                .. (
                    Cheat.Flags.Invisible
                    and "ВКЛЮЧЕНА"
                    or "ВЫКЛЮЧЕНА"
                ),
            Color3.fromRGB(
                0,
                255,
                0
            )
        )
    end
}

-- ======================================================
-- MM2 AIMBOT PLACEHOLDER
-- ======================================================

Cmds.mm2aimbot = {
    desc = "MM2 Aimbot",

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
                .. " | требуется отдельная реализация под конкретную версию MM2",
            Color3.fromRGB(
                255,
                255,
                0
            )
        )
    end
}

-- ======================================================
-- MM2 AUTO SHOOT PLACEHOLDER
-- ======================================================

Cmds.mm2autoshoot = {
    desc = "MM2 AutoShoot",

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
                .. " | требуется отдельная реализация под конкретную версию MM2",
            Color3.fromRGB(
                255,
                255,
                0
            )
        )
    end
}

-- ======================================================
-- TOUCH FLING
-- ======================================================

local function StopAntiFling()

    DisconnectConnection(
        "AntiFlingConnection"
    )

    DisconnectConnection(
        "AntiFlingHeartbeat"
    )
end

local function StabilizeLocalCharacter()

    if not Cheat.Flags.TouchFling then
        return
    end

    local root = GetRoot()
    local humanoid = GetHumanoid()

    if not root
        or not humanoid
        or humanoid.Health <= 0 then

        return
    end

    pcall(function()

        root.AssemblyLinearVelocity =
            Vector3.zero

        root.AssemblyAngularVelocity =
            Vector3.zero

    end)
end

local function StartAntiFling()

    StopAntiFling()

    if RunService.PreSimulation then

        Cheat.Runtime.AntiFlingConnection =
            RunService.PreSimulation:Connect(
                StabilizeLocalCharacter
            )

    else

        Cheat.Runtime.AntiFlingConnection =
            RunService.Stepped:Connect(
                StabilizeLocalCharacter
            )
    end

    Cheat.Runtime.AntiFlingHeartbeat =
        RunService.Heartbeat:Connect(
            StabilizeLocalCharacter
        )
end

local function StopTouchFling()

    Cheat.Flags.TouchFling = false

    StopAntiFling()

    for _, connection in ipairs(
        Cheat.Runtime.TouchFlingConnections
    ) do

        pcall(function()
            connection:Disconnect()
        end)
    end

    Cheat.Runtime.TouchFlingConnections =
        {}

end

local function StartTouchFling()

    StopTouchFling()

    Cheat.Flags.TouchFling = true

    StartAntiFling()

    local cooldown = {}

    local function FlingTarget(player)

        if not Cheat.Flags.TouchFling then
            return
        end

        if not player
            or player == LocalPlayer then

            return
        end

        local now = os.clock()

        if cooldown[player]
            and now - cooldown[player] < 0.15 then

            return
        end

        cooldown[player] = now

        local myRoot = GetRoot()

        local targetCharacter =
            player.Character

        local targetRoot =
            targetCharacter
            and targetCharacter:FindFirstChild(
                "HumanoidRootPart"
            )

        local targetHumanoid =
            targetCharacter
            and targetCharacter:FindFirstChildOfClass(
                "Humanoid"
            )

        if not myRoot
            or not targetRoot
            or not targetHumanoid
            or targetHumanoid.Health <= 0 then

            return
        end

        local offset =
            targetRoot.Position
            - myRoot.Position

        local direction

        if offset.Magnitude > 0.01 then
            direction = offset.Unit
        else
            direction =
                myRoot.CFrame.LookVector
        end

        -- Client-side physics only.
        pcall(function()

            targetRoot.AssemblyLinearVelocity =
                direction
                * Cheat.Config.TouchFlingPower
                + Vector3.new(
                    0,
                    Cheat.Config.TouchFlingPower
                        * 0.35,
                    0
                )

            targetRoot.AssemblyAngularVelocity =
                Vector3.new(
                    Cheat.Config.TouchFlingPower
                        * 0.08,

                    Cheat.Config.TouchFlingPower
                        * 0.05,

                    Cheat.Config.TouchFlingPower
                        * 0.08
                )
        end)
    end

    local function HookCharacter(character)

        for _, connection in ipairs(
            Cheat.Runtime.TouchFlingConnections
        ) do

            pcall(function()
                connection:Disconnect()
            end)
        end

        Cheat.Runtime.TouchFlingConnections =
            {}

        for _, part in ipairs(
            character:GetDescendants()
        ) do

            if part:IsA("BasePart") then

                local connection =
                    part.Touched:Connect(
                        function(hit)

                            if not Cheat.Flags.TouchFling then
                                return
                            end

                            if not hit
                                or not hit.Parent then

                                return
                            end

                            local otherCharacter =
                                hit:FindFirstAncestorOfClass(
                                    "Model"
                                )

                            local otherPlayer =
                                otherCharacter
                                and Players:GetPlayerFromCharacter(
                                    otherCharacter
                                )

                            if otherPlayer
                                and otherPlayer ~= LocalPlayer then

                                FlingTarget(
                                    otherPlayer
                                )
                            end
                        end
                    )

                table.insert(
                    Cheat.Runtime.TouchFlingConnections,
                    connection
                )
            end
        end
    end

    if LocalPlayer.Character then
        HookCharacter(
            LocalPlayer.Character
        )
    end

    local characterConnection =
        LocalPlayer.CharacterAdded:Connect(
            function(character)

                if not Cheat.Flags.TouchFling then
                    return
                end

                task.wait(0.25)

                if Cheat.Flags.TouchFling then
                    HookCharacter(character)
                end
            end
        )

    table.insert(
        Cheat.Runtime.TouchFlingConnections,
        characterConnection
    )
end

Cmds.touchfling = {
    desc = "TouchFling + Anti-Fling",

    run = function(args, output)

        if Cheat.Flags.TouchFling then

            output(
                "💥 TouchFling уже включён | Anti-Fling активен",
                Color3.fromRGB(
                    255,
                    215,
                    0
                )
            )

            return
        end

        StartTouchFling()

        output(
            "💥 TouchFling ВКЛЮЧЕН | 🛡️ Anti-Fling ВКЛЮЧЕН",
            Color3.fromRGB(
                0,
                255,
                0
            )
        )
    end
}

Cmds.untouchfling = {
    desc = "Выключить TouchFling и Anti-Fling",

    run = function(args, output)

        StopTouchFling()

        output(
            "💥 TouchFling ВЫКЛЮЧЕН | 🛡️ Anti-Fling ВЫКЛЮЧЕН",
            Color3.fromRGB(
                255,
                0,
                0
            )
        )
    end
}

-- ======================================================
-- FLY COMMAND
-- ======================================================

Cmds.fly = {
    desc = "Полет: fly [скорость]",

    run = function(args, output)

        local requested =
            tonumber(args[1])

        if requested then

            Cheat.Config.FlySpeed =
                math.max(
                    1,
                    math.min(
                        requested,
                        1e19
                    )
                )
        end

        if Cheat.Flags.Fly then

            output(
                "✈️ Полет уже включен | скорость: "
                    .. tostring(
                        Cheat.Config.FlySpeed
                    ),
                Color3.fromRGB(
                    0,
                    255,
                    0
                )
            )

            return
        end

        local humanoid =
            GetHumanoid()

        local root =
            GetRoot()

        if not humanoid or not root then

            output(
                "⚠️ Персонаж не готов",
                Color3.fromRGB(
                    255,
                    255,
                    0
                )
            )

            return
        end

        Cheat.Flags.Fly = true

        humanoid.PlatformStand = true

        if Cheat.Runtime.FlyBodyVelocity then

            pcall(function()
                Cheat.Runtime.FlyBodyVelocity:Destroy()
            end)
        end

        local bodyVelocity =
            Instance.new("BodyVelocity")

        bodyVelocity.Name =
            "MAX_FlyVelocity"

        bodyVelocity.MaxForce =
            Vector3.new(
                1e9,
                1e9,
                1e9
            )

        bodyVelocity.P = 1e5

        bodyVelocity.Velocity =
            Vector3.zero

        bodyVelocity.Parent = root

        Cheat.Runtime.FlyBodyVelocity =
            bodyVelocity

        if IsMobile then
            JoyGui.Enabled = true
        end

        output(
            "✈️ Полет ВКЛЮЧЕН | скорость: "
                .. tostring(
                    Cheat.Config.FlySpeed
                ),
            Color3.fromRGB(
                0,
                255,
                0
            )
        )
    end
}

Cmds.unfly = {
    desc = "Выключить полет",

    run = function(args, output)

        StopFly()

        output(
            "✈️ Полет ВЫКЛЮЧЕН",
            Color3.fromRGB(
                255,
                0,
                0
            )
        )
    end
}

-- ======================================================
-- FLY UPDATE
-- ======================================================

TrackConnection(
    RunService.RenderStepped:Connect(
        function()

            if not Cheat.Flags.Fly then
                return
            end

            local bodyVelocity =
                Cheat.Runtime.FlyBodyVelocity

            if not bodyVelocity
                or not bodyVelocity.Parent then

                StopFly()
                return
            end

            local speed =
                Cheat.Config.FlySpeed
                or 70

            local velocity =
                Vector3.zero

            local look =
                Camera.CFrame.LookVector

            local right =
                Camera.CFrame.RightVector

            local up =
                Vector3.new(
                    0,
                    1,
                    0
                )

            if IsDesktop then

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.W
                ) then

                    velocity =
                        velocity
                        + look * speed
                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.S
                ) then

                    velocity =
                        velocity
                        - look * speed
                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.A
                ) then

                    velocity =
                        velocity
                        - right * speed
                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.D
                ) then

                    velocity =
                        velocity
                        + right * speed
                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.Space
                ) then

                    velocity =
                        velocity
                        + up * speed
                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.LeftControl
                ) then

                    velocity =
                        velocity
                        - up * speed
                end

            else

                velocity =
                    velocity
                    + right
                    * Cheat.Runtime.FlyDirection.X
                    * speed

                velocity =
                    velocity
                    + look
                    * Cheat.Runtime.FlyDirection.Z
                    * speed

                if Cheat.Runtime.FlyUpActive then

                    velocity =
                        velocity
                        + up * speed
                end

                if Cheat.Runtime.FlyDownActive then

                    velocity =
                        velocity
                        - up * speed
                end
            end

            bodyVelocity.Velocity =
                velocity
        end
    )
)

-- ======================================================
-- CHARACTER RESPAWN
-- ======================================================

TrackConnection(
    LocalPlayer.CharacterAdded:Connect(
        function(character)

            task.wait(0.5)

            local humanoid =
                character:FindFirstChildOfClass(
                    "Humanoid"
                )

            if humanoid then

                humanoid.WalkSpeed =
                    Cheat.Config.SpeedValue
            end

            if Cheat.Flags.Invisible then
                SetInvisible(true)
            end

            if Cheat.Flags.Saitama then

                local root =
                    character:FindFirstChild(
                        "HumanoidRootPart"
                    )

                if root then
                    AddSaitamaEffect(root)
                end
            end

            if Cheat.Flags.Noclip then
                StartNoclip()
            end

            if Cheat.Flags.ESP then
                task.wait(0.25)
                CreateESP()
            end
        end
    )
)

TrackConnection(
    LocalPlayer.CharacterRemoving:Connect(
        function()

            StopFly()
            StopFreeze()

            if Cheat.Flags.Noclip then
                Cheat.Runtime.OriginalCanCollide =
                    {}
            end
        end
    )
)

-- ======================================================
-- RESET
-- ======================================================

local function ResetEverything()

    Cheat.Flags.Fly = false
    Cheat.Flags.Noclip = false
    Cheat.Flags.ESP = false
    Cheat.Flags.InfiniteJump = false
    Cheat.Flags.AntiAFK = false
    Cheat.Flags.Saitama = false
    Cheat.Flags.AutoClick = false
    Cheat.Flags.Spin = false
    Cheat.Flags.Sit = false
    Cheat.Flags.Freeze = false
    Cheat.Flags.GodMode = false
    Cheat.Flags.Invisible = false
    Cheat.Flags.MM2Aimbot = false
    Cheat.Flags.MM2AutoShoot = false
    Cheat.Flags.TouchFling = false

    StopFly()
    StopFreeze()
    StopSpin()
    StopGodMode()
    StopAntiAFK()
    StopAutoClick()
    StopTouchFling()

    StopNoclip()

    ClearESP()

    ClearWeather()

    DisconnectConnection(
        "JumpConnection"
    )

    local character =
        GetCharacter()

    if character then

        local humanoid =
            character:FindFirstChildOfClass(
                "Humanoid"
            )

        if humanoid then

            humanoid.PlatformStand = false
            humanoid.Sit = false

            humanoid.WalkSpeed = 16
        end

        SetInvisible(false)

        RestoreCollision(character)
    end

    if IsMobile and JoyGui then
        JoyGui.Enabled = false
    end
end

Cmds.reset = {
    desc = "Сбросить все функции",

    run = function(args, output)

        output(
            "🔄 Сброс функций...",
            Color3.fromRGB(
                255,
                255,
                0
            )
        )

        task.wait(0.2)

        ResetEverything()

        output(
            "✅ Все функции сброшены",
            Color3.fromRGB(
                0,
                255,
                0
            )
        )
    end
}

-- ======================================================
-- UNLOAD
-- ======================================================

local function UnloadScript()

    ResetEverything()

    for _, connection in ipairs(
        Cheat.Runtime.Connections
    ) do

        pcall(function()
            connection:Disconnect()
        end)
    end

    Cheat.Runtime.Connections = {}

    if GUI then

        pcall(function()
            GUI:Destroy()
        end)

        GUI = nil
    end

    if MobileButton then

        pcall(function()
            MobileButton:Destroy()
        end)
    end

    if JoyGui then

        pcall(function()
            JoyGui:Destroy()
        end)
    end

    Cheat.Runtime.ConsoleVisible =
        false
end

Cmds.unload = {
    desc = "Полностью выгрузить скрипт",

    run = function(args, output)

        output(
            "🛑 Выгрузка скрипта...",
            Color3.fromRGB(
                255,
                0,
                0
            )
        )

        task.wait(0.2)

        UnloadScript()
    end
}

-- ======================================================
-- CREATE CONSOLE
-- ======================================================

CreateConsole()

if GUI then
    GUI.Enabled = false
end

JoyGui.Enabled = false

-- ======================================================
-- NOTIFICATION
-- ======================================================

pcall(function()

    StarterGui:SetCore(
        "SendNotification",
        {
            Title =
                "⚡ MAX EDITION & DEEPSEEK",

            Text =
                "Кнопка ⚡ или двойной RightShift",

            Duration = 5
        }
    )
end)

-- ======================================================
-- APPLY DEFAULT SPEED
-- ======================================================

task.defer(function()

    local humanoid =
        GetHumanoid()

    if humanoid then
        humanoid.WalkSpeed =
            Cheat.Config.SpeedValue
    end

    if Cheat.Flags.ESP then
        CreateESP()
    end
end)

-- ======================================================
-- LOADED
-- ======================================================

print(
    "✅ MAX EDITION & DEEPSEEK FIXED EDITION загружена"
)

print(
    "📌 ESP: готов"
)

print(
    "📌 Fly: готов"
)

print(
    "📌 Console: RightShift x2 / ⚡"
)
