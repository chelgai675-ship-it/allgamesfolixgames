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
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

-- ======================================================
-- CONFIG
-- ======================================================

local Cheat = {
    Config = {
        SpeedValue = 16,
        SpinSpeed = 10,
        FlySpeed = 70,
        RainbowOffset = 0,
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

        -- Заглушки
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

        JumpConnection = nil,
        NoclipConnection = nil,

        OriginalCanCollide = {},
        OriginalTransparency = {},

        SaitamaEffects = {},

        FlyDirection = Vector3.zero,
        FlyUpActive = false,
        FlyDownActive = false,

        ConsoleVisible = false,

        CommandHistory = {},
        HistoryIndex = 0,

        Destroyed = false,
    }
}

-- ======================================================
-- VARIABLES
-- ======================================================

local SettingsFile = "max_settings.json"

local GUI = nil
local InputBox = nil
local OutputScrolling = nil

local Cmds = {}

local LastRightShiftPress = 0
local RightShiftPressCount = 0

local IsMobile = UserInputService.TouchEnabled
local IsDesktop = not IsMobile

-- ======================================================
-- CONNECTION HELPER
-- ======================================================

local function AddConnection(conn)
    if conn then
        table.insert(Cheat.Runtime.Connections, conn)
    end

    return conn
end

local function DisconnectConnection(connection)
    if connection then
        pcall(function()
            connection:Disconnect()
        end)
    end

    return nil
end

-- ======================================================
-- FORWARD DECLARATIONS
-- ======================================================

local CreateConsole
local ExecuteCommand
local ApplyAllSavedSettings

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
-- SAITAMA EFFECT
-- ======================================================

local function RemoveSaitamaEffect(part)
    local effects = Cheat.Runtime.SaitamaEffects[part]

    if effects then
        for _, object in ipairs(effects) do
            pcall(function()
                object:Destroy()
            end)
        end

        Cheat.Runtime.SaitamaEffects[part] = nil
    end
end

local function AddSaitamaEffect(part)
    if not part or not part:IsA("BasePart") then
        return
    end

    RemoveSaitamaEffect(part)

    local effects = {}

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

    table.insert(effects, attachment0)
    table.insert(effects, attachment1)
    table.insert(effects, beam)

    Cheat.Runtime.SaitamaEffects[part] = effects

    task.spawn(function()
        while beam.Parent and Cheat.Flags.Saitama do
            local color = RainbowColor(Cheat.Config.RainbowOffset)

            beam.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, color),
                ColorSequenceKeypoint.new(1, color)
            })

            Cheat.Config.RainbowOffset =
                Cheat.Config.RainbowOffset + 0.01

            task.wait(0.05)
        end
    end)
end

-- ======================================================
-- SETTINGS
-- ======================================================

local function SaveSettings()
    local settings = {
        speed = Cheat.Config.SpeedValue,
        spin = Cheat.Config.SpinSpeed,

        esp = Cheat.Flags.ESP,
        fly = Cheat.Flags.Fly,
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

    local successJSON, settings = pcall(function()
        return HttpService:JSONDecode(data)
    end)

    if not successJSON or type(settings) ~= "table" then
        return
    end

    if tonumber(settings.speed) then
        Cheat.Config.SpeedValue = tonumber(settings.speed)
    end

    if tonumber(settings.spin) then
        Cheat.Config.SpinSpeed = tonumber(settings.spin)
    end

    if settings.esp ~= nil then
        Cheat.Flags.ESP = settings.esp == true
    end

    if settings.fly ~= nil then
        Cheat.Flags.Fly = settings.fly == true
    end

    if settings.noclip ~= nil then
        Cheat.Flags.Noclip = settings.noclip == true
    end

    if settings.saitama ~= nil then
        Cheat.Flags.Saitama = settings.saitama == true
    end
end

LoadSettings()

-- ======================================================
-- PLAYER HELPERS
-- ======================================================

local function GetCharacter()
    return LocalPlayer.Character
end

local function GetHumanoid()
    local char = GetCharacter()

    if not char then
        return nil
    end

    return char:FindFirstChildOfClass("Humanoid")
end

local function GetRoot()
    local char = GetCharacter()

    if not char then
        return nil
    end

    return char:FindFirstChild("HumanoidRootPart")
end

-- ======================================================
-- ESP
-- ======================================================

local function GetTeamColor(player)
    local char = player.Character
    local color = Color3.fromRGB(255, 255, 255)

    local function HasTool(name)
        if char and char:FindFirstChild(name) then
            return true
        end

        local backpack = player:FindFirstChildOfClass("Backpack")

        if backpack and backpack:FindFirstChild(name) then
            return true
        end

        return false
    end

    if HasTool("Knife")
        or HasTool("MurdererKnife") then

        color = Color3.fromRGB(255, 50, 50)

    elseif HasTool("Gun")
        or HasTool("Pistol")
        or HasTool("Revolver") then

        color = Color3.fromRGB(50, 120, 255)
    end

    if player.Team
        and LocalPlayer.Team
        and player.Team ~= LocalPlayer.Team then

        color = Color3.fromRGB(255, 50, 50)

    elseif player.Team
        and LocalPlayer.Team
        and player.Team == LocalPlayer.Team then

        color = Color3.fromRGB(50, 255, 100)
    end

    return color
end

local function RemoveESPForPlayer(player)
    if Cheat.Runtime.ESPTexts[player] then
        pcall(function()
            Cheat.Runtime.ESPTexts[player]:Destroy()
        end)

        Cheat.Runtime.ESPTexts[player] = nil
    end

    if Cheat.Runtime.ESPHighlights[player] then
        pcall(function()
            Cheat.Runtime.ESPHighlights[player]:Destroy()
        end)

        Cheat.Runtime.ESPHighlights[player] = nil
    end

    if Cheat.Runtime.ESPCharacterConnections[player] then
        pcall(function()
            Cheat.Runtime.ESPCharacterConnections[player]:Disconnect()
        end)

        Cheat.Runtime.ESPCharacterConnections[player] = nil
    end
end

local function ClearESP()
    for _, player in ipairs(Players:GetPlayers()) do
        RemoveESPForPlayer(player)
    end

    Cheat.Runtime.ESPTexts = {}
    Cheat.Runtime.ESPHighlights = {}
    Cheat.Runtime.ESPCharacterConnections = {}
end

local function AddESPForPlayer(player)
    if player == LocalPlayer then
        return
    end

    RemoveESPForPlayer(player)

    local character = player.Character

    if not character then
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local head = character:FindFirstChild("Head")

    if not humanoid or not head then
        return
    end

    local color = GetTeamColor(player)

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Adornee = head
    billboard.Size = UDim2.fromOffset(240, 50)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 500
    billboard.Parent = character

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.3
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Text = player.Name
    label.Parent = billboard

    Cheat.Runtime.ESPTexts[player] = billboard

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillColor = color
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = color
    highlight.OutlineTransparency = 0.3
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character

    Cheat.Runtime.ESPHighlights[player] = highlight

    Cheat.Runtime.ESPCharacterConnections[player] =
        player.CharacterAdded:Connect(function()
            if not Cheat.Flags.ESP then
                return
            end

            task.wait(0.5)

            if Cheat.Flags.ESP then
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

    local localRoot = GetRoot()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then

            local character = player.Character
            local humanoid = character
                and character:FindFirstChildOfClass("Humanoid")

            local root = character
                and character:FindFirstChild("HumanoidRootPart")

            local head = character
                and character:FindFirstChild("Head")

            local billboard = Cheat.Runtime.ESPTexts[player]
            local highlight = Cheat.Runtime.ESPHighlights[player]

            if humanoid
                and humanoid.Health > 0
                and root
                and head then

                if billboard then
                    billboard.Enabled = true

                    local label =
                        billboard:FindFirstChildOfClass("TextLabel")

                    if label then
                        local distance = 0

                        if localRoot then
                            distance =
                                (localRoot.Position - root.Position).Magnitude
                        end

                        local color = GetTeamColor(player)

                        label.TextColor3 = color

                        label.Text = string.format(
                            "%s [%d HP] [%d м]",
                            player.Name,
                            math.floor(humanoid.Health),
                            math.floor(distance)
                        )
                    end
                end

                if highlight then
                    local color = GetTeamColor(player)

                    highlight.Enabled = true
                    highlight.FillColor = color
                    highlight.OutlineColor = color
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

-- ======================================================
-- FLY
-- ======================================================

local JoyGui
local JoyFrame
local JoyStick
local UpBtn
local DownBtn

local JoyActive = false

local function ResetJoystick()
    JoyActive = false

    if JoyStick then
        JoyStick.Position =
            UDim2.new(0.5, -20, 0.5, -20)
    end

    Cheat.Runtime.FlyDirection = Vector3.zero
end

local function SetupMobileFly()
    if not IsMobile then
        return
    end

    JoyGui = Instance.new("ScreenGui")
    JoyGui.Name = "FlyJoystick"
    JoyGui.ResetOnSpawn = false
    JoyGui.Enabled = false
    JoyGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    JoyFrame = Instance.new("Frame")
    JoyFrame.Size = UDim2.fromOffset(120, 120)
    JoyFrame.Position = UDim2.new(0.02, 0, 0.5, -60)
    JoyFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
    JoyFrame.BackgroundTransparency = 0.5
    JoyFrame.BorderSizePixel = 2
    JoyFrame.BorderColor3 = Color3.fromRGB(80, 80, 150)
    JoyFrame.Parent = JoyGui

    JoyStick = Instance.new("Frame")
    JoyStick.Size = UDim2.fromOffset(40, 40)
    JoyStick.Position = UDim2.new(0.5, -20, 0.5, -20)
    JoyStick.BackgroundColor3 = Color3.fromRGB(200, 200, 255)
    JoyStick.BackgroundTransparency = 0.3
    JoyStick.BorderSizePixel = 2
    JoyStick.BorderColor3 = Color3.new(1, 1, 1)
    JoyStick.Parent = JoyFrame

    UpBtn = Instance.new("TextButton")
    UpBtn.Size = UDim2.fromOffset(50, 50)
    UpBtn.Position = UDim2.new(0.85, 0, 0.7, 0)
    UpBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    UpBtn.Text = "⬆"
    UpBtn.TextColor3 = Color3.new(1, 1, 1)
    UpBtn.TextScaled = true
    UpBtn.Font = Enum.Font.GothamBold
    UpBtn.Parent = JoyGui

    DownBtn = Instance.new("TextButton")
    DownBtn.Size = UDim2.fromOffset(50, 50)
    DownBtn.Position = UDim2.new(0.85, 0, 0.82, 0)
    DownBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    DownBtn.Text = "⬇"
    DownBtn.TextColor3 = Color3.new(1, 1, 1)
    DownBtn.TextScaled = true
    DownBtn.Font = Enum.Font.GothamBold
    DownBtn.Parent = JoyGui

    AddConnection(JoyFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            JoyActive = true
        end
    end))

    AddConnection(JoyFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            ResetJoystick()
        end
    end))

    AddConnection(UserInputService.TouchEnded:Connect(function()
        if JoyActive then
            ResetJoystick()
        end
    end))

    AddConnection(JoyFrame.InputChanged:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch
            or not JoyActive then
            return
        end

        local center =
            JoyFrame.AbsolutePosition
            + JoyFrame.AbsoluteSize / 2

        local delta = input.Position - center

        local maxDist = 40
        local distance = delta.Magnitude

        if distance > maxDist then
            delta = delta.Unit * maxDist
        end

        JoyStick.Position =
            UDim2.new(
                0.5,
                delta.X - 20,
                0.5,
                delta.Y - 20
            )

        Cheat.Runtime.FlyDirection =
            Vector3.new(
                delta.X / maxDist,
                0,
                -delta.Y / maxDist
            )
    end))

    AddConnection(UpBtn.MouseButton1Down:Connect(function()
        Cheat.Runtime.FlyUpActive = true
    end))

    AddConnection(UpBtn.MouseButton1Up:Connect(function()
        Cheat.Runtime.FlyUpActive = false
    end))

    AddConnection(DownBtn.MouseButton1Down:Connect(function()
        Cheat.Runtime.FlyDownActive = true
    end))

    AddConnection(DownBtn.MouseButton1Up:Connect(function()
        Cheat.Runtime.FlyDownActive = false
    end))
end

local function SetFly(enabled)
    Cheat.Flags.Fly = enabled

    local humanoid = GetHumanoid()
    local root = GetRoot()

    if enabled then
        if not humanoid or not root then
            Cheat.Flags.Fly = false
            return false
        end

        humanoid.PlatformStand = true

        if Cheat.Runtime.FlyBodyVelocity then
            Cheat.Runtime.FlyBodyVelocity:Destroy()
        end

        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "MaxEditionFly"
        bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 100000
        bodyVelocity.Velocity = Vector3.zero
        bodyVelocity.Parent = root

        Cheat.Runtime.FlyBodyVelocity = bodyVelocity

        if JoyGui then
            JoyGui.Enabled = true
        end

        return true

    else
        if Cheat.Runtime.FlyBodyVelocity then
            Cheat.Runtime.FlyBodyVelocity:Destroy()
            Cheat.Runtime.FlyBodyVelocity = nil
        end

        if humanoid then
            humanoid.PlatformStand = false
        end

        if JoyGui then
            JoyGui.Enabled = false
        end

        Cheat.Runtime.FlyDirection = Vector3.zero
        Cheat.Runtime.FlyUpActive = false
        Cheat.Runtime.FlyDownActive = false

        return true
    end
end

-- ======================================================
-- NOCLIP
-- ======================================================

local function SaveCollisionState()
    Cheat.Runtime.OriginalCanCollide = {}

    local character = GetCharacter()

    if not character then
        return
    end

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            Cheat.Runtime.OriginalCanCollide[part] =
                part.CanCollide
        end
    end
end

local function RestoreCollisionState()
    for part, original in pairs(
        Cheat.Runtime.OriginalCanCollide
    ) do

        pcall(function()
            if part and part.Parent then
                part.CanCollide = original
            end
        end)
    end

    Cheat.Runtime.OriginalCanCollide = {}
end

local function SetNoclip(enabled)
    Cheat.Flags.Noclip = enabled

    if enabled then
        SaveCollisionState()

        Cheat.Runtime.NoclipConnection =
            DisconnectConnection(
                Cheat.Runtime.NoclipConnection
            )

        Cheat.Runtime.NoclipConnection =
            RunService.Stepped:Connect(function()
                if not Cheat.Flags.Noclip then
                    return
                end

                local character = GetCharacter()

                if character then
                    for _, part in ipairs(
                        character:GetDescendants()
                    ) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)

    else
        Cheat.Runtime.NoclipConnection =
            DisconnectConnection(
                Cheat.Runtime.NoclipConnection
            )

        RestoreCollisionState()
    end
end

-- ======================================================
-- INVISIBLE
-- ======================================================

local function RestoreTransparency()
    for part, original in pairs(
        Cheat.Runtime.OriginalTransparency
    ) do

        pcall(function()
            if part and part.Parent then
                part.Transparency = original
            end
        end)
    end

    Cheat.Runtime.OriginalTransparency = {}
end

local function SetInvisible(enabled)
    Cheat.Flags.Invisible = enabled

    local character = GetCharacter()

    if not character then
        return
    end

    if enabled then
        Cheat.Runtime.OriginalTransparency = {}

        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                Cheat.Runtime.OriginalTransparency[part] =
                    part.Transparency

                part.Transparency = 1
            end
        end
    else
        RestoreTransparency()
    end
end

-- ======================================================
-- CONSOLE
-- ======================================================

CreateConsole = function()
    if GUI then
        pcall(function()
            GUI:Destroy()
        end)

        GUI = nil
    end

    GUI = Instance.new("ScreenGui")
    GUI.Name = "MaxEditionConsole"
    GUI.ResetOnSpawn = false
    GUI.Enabled = Cheat.Runtime.ConsoleVisible
    GUI.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.fromOffset(600, 450)
    mainFrame.Position =
        UDim2.new(0.5, -300, 0.5, -225)

    mainFrame.BackgroundColor3 =
        Color3.fromRGB(15, 15, 30)

    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 =
        Color3.fromRGB(255, 215, 0)

    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = GUI

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 =
        Color3.fromRGB(40, 40, 70)

    title.Text =
        "⚡ MAX EDITION & DEEPSEEK ALL GAMES"

    title.TextColor3 =
        Color3.fromRGB(255, 215, 0)

    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 20)
    info.Position = UDim2.fromOffset(0, 40)
    info.BackgroundTransparency = 1
    info.Text =
        "🟢 Кнопка ⚡ или двойной RightShift"
    info.TextColor3 =
        Color3.fromRGB(150, 200, 255)
    info.TextScaled = true
    info.Font = Enum.Font.Gotham
    info.Parent = mainFrame

    OutputScrolling = Instance.new("ScrollingFrame")
    OutputScrolling.Size =
        UDim2.new(1, -20, 0, 280)

    OutputScrolling.Position =
        UDim2.fromOffset(10, 65)

    OutputScrolling.BackgroundColor3 =
        Color3.fromRGB(5, 5, 15)

    OutputScrolling.BackgroundTransparency = 0.3
    OutputScrolling.BorderSizePixel = 1
    OutputScrolling.BorderColor3 =
        Color3.fromRGB(60, 60, 100)

    OutputScrolling.CanvasSize =
        UDim2.new(0, 0, 0, 0)

    OutputScrolling.ScrollBarThickness = 5
    OutputScrolling.Parent = mainFrame

    InputBox = Instance.new("TextBox")
    InputBox.Size =
        UDim2.new(1, -20, 0, 35)

    InputBox.Position =
        UDim2.fromOffset(10, 355)

    InputBox.BackgroundColor3 =
        Color3.fromRGB(25, 25, 45)

    InputBox.BorderSizePixel = 1
    InputBox.BorderColor3 =
        Color3.fromRGB(80, 80, 150)

    InputBox.Text = ""
    InputBox.TextColor3 =
        Color3.fromRGB(255, 255, 255)

    InputBox.TextScaled = true
    InputBox.Font = Enum.Font.Gotham

    InputBox.PlaceholderText =
        "Введите команду... (help)"

    InputBox.Parent = mainFrame

    local function AddOutput(text, color)
        if not OutputScrolling
            or not OutputScrolling.Parent then
            return
        end

        local label = Instance.new("TextLabel")

        label.Size =
            UDim2.new(1, 0, 0, 20)

        label.Position =
            UDim2.fromOffset(
                0,
                OutputScrolling.CanvasSize.Y.Offset
            )

        label.BackgroundTransparency = 1
        label.Text = text

        label.TextColor3 =
            color or Color3.new(1, 1, 1)

        label.TextXAlignment =
            Enum.TextXAlignment.Left

        label.TextScaled = true
        label.Font = Enum.Font.Gotham
        label.Parent = OutputScrolling

        OutputScrolling.CanvasSize =
            UDim2.new(
                0,
                0,
                0,
                OutputScrolling.CanvasSize.Y.Offset + 22
            )

        OutputScrolling.CanvasPosition =
            Vector2.new(
                0,
                OutputScrolling.CanvasSize.Y.Offset
            )
    end

    AddOutput(
        "⚡ MAX EDITION & DEEPSEEK | FIXED",
        Color3.fromRGB(255, 215, 0)
    )

    AddConnection(InputBox.InputBegan:Connect(function(input)
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

                InputBox.CursorPosition =
                    #InputBox.Text

            else
                Cheat.Runtime.HistoryIndex =
                    #Cheat.Runtime.CommandHistory + 1

                InputBox.Text = ""
            end

        elseif input.KeyCode == Enum.KeyCode.Tab then

            local text = InputBox.Text
            local match = nil

            for name in pairs(Cmds) do
                if name:sub(1, #text):lower()
                    == text:lower() then

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
    end))

    AddConnection(InputBox.FocusLost:Connect(
        function(enterPressed)

            if not enterPressed then
                return
            end

            local command = InputBox.Text
            InputBox.Text = ""

            if command == "" then
                return
            end

            AddOutput(
                "> " .. command,
                Color3.fromRGB(200, 200, 255)
            )

            table.insert(
                Cheat.Runtime.CommandHistory,
                command
            )

            if #Cheat.Runtime.CommandHistory > 100 then
                table.remove(
                    Cheat.Runtime.CommandHistory,
                    1
                )
            end

            Cheat.Runtime.HistoryIndex =
                #Cheat.Runtime.CommandHistory + 1

            ExecuteCommand(command, AddOutput)
        end
    ))

    return mainFrame
end

-- ======================================================
-- PLAYER SEARCH
-- ======================================================

local function FindPlayerByName(name)
    local lowerName = name:lower()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then

            if player.Name:lower() == lowerName
                or player.DisplayName:lower() == lowerName then

                return {player}
            end
        end
    end

    local matches = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then

            if player.Name:lower():sub(1, #lowerName)
                == lowerName

                or player.DisplayName:lower():sub(1, #lowerName)
                == lowerName then

                table.insert(matches, player)
            end
        end
    end

    if #matches > 0 then
        return matches
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then

            if player.Name:lower():find(
                lowerName,
                1,
                true
            )

            or player.DisplayName:lower():find(
                lowerName,
                1,
                true
            ) then

                table.insert(matches, player)
            end
        end
    end

    return matches
end

-- ======================================================
-- COMMANDS
-- ======================================================

Cmds.help = {
    desc = "Показать все команды",

    run = function(args, output)
        output(
            "===== ДОСТУПНЫЕ КОМАНДЫ =====",
            Color3.fromRGB(255, 215, 0)
        )

        local commands = {
            "help",
            "fly",
            "speed",
            "noclip",
            "fakeheal",
            "goto",
            "tp",
            "esp",
            "saitama",
            "antiafk",
            "autoclick",
            "spin",
            "sit",
            "jump",
            "tpall",
            "freeze",
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
                    name .. " - " .. Cmds[name].desc,
                    Color3.fromRGB(200, 200, 255)
                )
            end
        end

        output(
            "===== КОНЕЦ СПИСКА =====",
            Color3.fromRGB(255, 215, 0)
        )
    end
}

Cmds.speed = {
    desc = "Установить скорость: speed [число]",

    run = function(args, output)
        local speed = tonumber(args[1])

        if not speed then
            output(
                "⚠️ Использование: speed [число]",
                Color3.fromRGB(255, 255, 0)
            )
            return
        end

        speed = math.clamp(speed, 0, 500)

        Cheat.Config.SpeedValue = speed

        local humanoid = GetHumanoid()

        if humanoid then
            humanoid.WalkSpeed = speed
        end

        SaveSettings()

        output(
            "🏃 Скорость: " .. speed,
            Color3.fromRGB(0, 255, 0)
        )
    end
}

Cmds.fly = {
    desc = "Включить/выключить полет",

    run = function(args, output)
        local newState = not Cheat.Flags.Fly

        if newState then
            if not SetFly(true) then
                output(
                    "⚠️ Персонаж не готов",
                    Color3.fromRGB(255, 255, 0)
                )
                return
            end

            output(
                "✈️ Полет ВКЛЮЧЕН",
                Color3.fromRGB(0, 255, 0)
            )
        else
            SetFly(false)

            output(
                "✈️ Полет ВЫКЛЮЧЕН",
                Color3.fromRGB(255, 0, 0)
            )
        end

        SaveSettings()
    end
}

Cmds.noclip = {
    desc = "Включить/выключить noclip",

    run = function(args, output)
        local state = not Cheat.Flags.Noclip

        SetNoclip(state)

        output(
            "🚧 Noclip "
                .. (state and "ВКЛЮЧЕН" or "ВЫКЛЮЧЕН"),
            state
                and Color3.fromRGB(0, 255, 0)
                or Color3.fromRGB(255, 0, 0)
        )

        SaveSettings()
    end
}

Cmds.esp = {
    desc = "Включить/выключить ESP",

    run = function(args, output)
        Cheat.Flags.ESP = not Cheat.Flags.ESP

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

Cmds.saitama = {
    desc = "Включить/выключить режим Сайтамы",

    run = function(args, output)
        Cheat.Flags.Saitama =
            not Cheat.Flags.Saitama

        local root = GetRoot()

        if root then
            if Cheat.Flags.Saitama then
                AddSaitamaEffect(root)
            else
                RemoveSaitamaEffect(root)
            end
        end

        output(
            "👊 Режим Сайтамы "
                .. (
                    Cheat.Flags.Saitama
                    and "ВКЛЮЧЕН"
                    or "ВЫКЛЮЧЕН"
                ),
            Color3.fromRGB(0, 255, 0)
        )

        SaveSettings()
    end
}

Cmds.sit = {
    desc = "Сесть/встать",

    run = function(args, output)
        local humanoid = GetHumanoid()

        if not humanoid then
            return
        end

        humanoid.Sit = not humanoid.Sit

        output(
            humanoid.Sit
                and "🪑 Сел"
                or "🪑 Встал",
            Color3.fromRGB(0, 255, 0)
        )
    end
}

Cmds.jump = {
    desc = "Включить/выключить бесконечный прыжок",

    run = function(args, output)
        Cheat.Flags.InfiniteJump =
            not Cheat.Flags.InfiniteJump

        Cheat.Runtime.JumpConnection =
            DisconnectConnection(
                Cheat.Runtime.JumpConnection
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
                Color3.fromRGB(0, 255, 0)
            )
        else
            output(
                "🦘 Бесконечный прыжок ВЫКЛЮЧЕН",
                Color3.fromRGB(255, 0, 0)
            )
        end
    end
}

Cmds.spin = {
    desc = "Вращение: spin [скорость]",

    run = function(args, output)
        local speed = tonumber(args[1])

        if speed then
            Cheat.Config.SpinSpeed =
                math.clamp(speed, 0, 1000)

            Cheat.Flags.Spin = true

            output(
                "🔄 Скорость вращения: "
                    .. Cheat.Config.SpinSpeed,
                Color3.fromRGB(0, 255, 0)
            )

            return
        end

        Cheat.Flags.Spin =
            not Cheat.Flags.Spin

        output(
            "🔄 Вращение "
                .. (
                    Cheat.Flags.Spin
                    and "ВКЛЮЧЕНО"
                    or "ВЫКЛЮЧЕНО"
                ),
            Color3.fromRGB(0, 255, 0)
        )
    end
}

Cmds.fakeheal = {
    desc = "Восстановить здоровье локального Humanoid",

    run = function(args, output)
        local humanoid = GetHumanoid()

        if not humanoid then
            return
        end

        humanoid.Health = humanoid.MaxHealth

        output(
            "❤️ Здоровье восстановлено",
            Color3.fromRGB(0, 255, 0)
        )
    end
}

Cmds.godmode = {
    desc = "Включить/выключить локальное поддержание HP",

    run = function(args, output)
        Cheat.Flags.GodMode =
            not Cheat.Flags.GodMode

        output(
            "🛡️ Бессмертие "
                .. (
                    Cheat.Flags.GodMode
                    and "ВКЛЮЧЕНО"
                    or "ВЫКЛЮЧЕНО"
                ),
            Cheat.Flags.GodMode
                and Color3.fromRGB(0, 255, 0)
                or Color3.fromRGB(255, 0, 0)
        )
    end
}

Cmds.invisible = {
    desc = "Включить/выключить локальную невидимость",

    run = function(args, output)
        SetInvisible(
            not Cheat.Flags.Invisible
        )

        output(
            "👻 Невидимость "
                .. (
                    Cheat.Flags.Invisible
                    and "ВКЛЮЧЕНА"
                    or "ВЫКЛЮЧЕНА"
                ),
            Color3.fromRGB(0, 255, 0)
        )
    end
}

Cmds.goto = {
    desc = "goto [имя] или goto [x y z]. Алиас: tp",

    run = function(args, output)
        local root = GetRoot()

        if not root then
            output(
                "⚠️ Персонаж не готов",
                Color3.fromRGB(255, 255, 0)
            )
            return
        end

        if #args == 0 then
            output(
                "⚠️ Использование: goto [имя] или goto [x y z]",
                Color3.fromRGB(255, 255, 0)
            )
            return
        end

        local x = tonumber(args[1])

        if x then
            if #args < 3 then
                output(
                    "⚠️ Нужно три координаты",
                    Color3.fromRGB(255, 255, 0)
                )
                return
            end

            local y = tonumber(args[2])
            local z = tonumber(args[3])

            if not y or not z then
                output(
                    "⚠️ Неверные координаты",
                    Color3.fromRGB(255, 255, 0)
                )
                return
            end

            root.CFrame =
                CFrame.new(x, y, z)

            output(
                "📍 Телепорт выполнен",
                Color3.fromRGB(0, 255, 0)
            )

            return
        end

        local name = table.concat(args, " ")
        local matches = FindPlayerByName(name)

        if #matches == 1 then
            local targetRoot =
                matches[1].Character
                and matches[1].Character:FindFirstChild(
                    "HumanoidRootPart"
                )

            if targetRoot then
                root.CFrame =
                    targetRoot.CFrame
                    + Vector3.new(0, 3, 0)

                output(
                    "📍 Телепорт к "
                        .. matches[1].Name,
                    Color3.fromRGB(0, 255, 0)
                )
            else
                output(
                    "⚠️ У игрока нет персонажа",
                    Color3.fromRGB(255, 255, 0)
                )
            end

        elseif #matches > 1 then

            output(
                "⚠️ Найдено несколько игроков:",
                Color3.fromRGB(255, 255, 0)
            )

            for _, player in ipairs(matches) do
                output(
                    " - " .. player.Name,
                    Color3.fromRGB(255, 255, 0)
                )
            end

        else
            output(
                "⚠️ Игрок не найден",
                Color3.fromRGB(255, 255, 0)
            )
        end
    end
}

Cmds.tp = {
    desc = "Алиас команды goto",

    run = function(args, output)
        Cmds.goto.run(args, output)
    end
}

Cmds.tpall = {
    desc = "Телепортировать игроков к себе",

    run = function(args, output)
        local root = GetRoot()

        if not root then
            output(
                "⚠️ Персонаж не готов",
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
                    targetRoot.CFrame =
                        root.CFrame
                        + Vector3.new(0, 3, 0)

                    count += 1
                end
            end
        end

        output(
            "📍 Обработано игроков: " .. count,
            Color3.fromRGB(0, 255, 0)
        )
    end
}

Cmds.freeze = {
    desc = "Заморозить/разморозить себя",

    run = function(args, output)
        Cheat.Flags.Freeze =
            not Cheat.Flags.Freeze

        local humanoid = GetHumanoid()
        local root = GetRoot()

        if not humanoid or not root then
            Cheat.Flags.Freeze = false
            return
        end

        if Cheat.Flags.Freeze then

            if Cheat.Runtime.FreezeBV then
                Cheat.Runtime.FreezeBV:Destroy()
            end

            local bodyVelocity =
                Instance.new("BodyVelocity")

            bodyVelocity.MaxForce =
                Vector3.new(1, 1, 1) * 100000

            bodyVelocity.Velocity =
                Vector3.zero

            bodyVelocity.Parent = root

            Cheat.Runtime.FreezeBV =
                bodyVelocity

            humanoid.PlatformStand = true

            output(
                "🧊 Вы заморожены",
                Color3.fromRGB(0, 255, 0)
            )

        else

            if Cheat.Runtime.FreezeBV then
                Cheat.Runtime.FreezeBV:Destroy()
                Cheat.Runtime.FreezeBV = nil
            end

            humanoid.PlatformStand = false
            humanoid.Sit = false

            output(
                "🧊 Вы разморожены",
                Color3.fromRGB(0, 255, 0)
            )
        end
    end
}

Cmds.time = {
    desc = "Установить локальное время: time [0-23]",

    run = function(args, output)
        local hour = tonumber(args[1])

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
            string.format(
                "🕐 Локальное время: %02d:00",
                hour
            ),
            Color3.fromRGB(0, 255, 0)
        )
    end
}

Cmds.weather = {
    desc = "Изменить локальный туман: rain/sun/snow",

    run = function(args, output)
        local weather =
            args[1]
            and args[1]:lower()

        if weather == "rain" then

            Lighting.FogColor =
                Color3.fromRGB(100, 100, 100)

            Lighting.FogEnd = 200

            output(
                "🌧️ Локальный эффект дождя",
                Color3.fromRGB(0, 255, 0)
            )

        elseif weather == "sun" then

            Lighting.FogColor =
                Color3.fromRGB(255, 255, 255)

            Lighting.FogEnd = 1000

            output(
                "☀️ Локальная солнечная погода",
                Color3.fromRGB(0, 255, 0)
            )

        elseif weather == "snow" then

            Lighting.FogColor =
                Color3.fromRGB(200, 200, 255)

            Lighting.FogEnd = 300

            output(
                "❄️ Локальный снежный туман",
                Color3.fromRGB(0, 255, 0)
            )

        else
            output(
                "⚠️ Использование: weather [rain/sun/snow]",
                Color3.fromRGB(255, 255, 0)
            )
        end
    end
}

Cmds.antiafk = {
    desc = "Включить/выключить Anti-AFK",

    run = function(args, output)
        Cheat.Flags.AntiAFK =
            not Cheat.Flags.AntiAFK

        output(
            "🛡️ Anti-AFK "
                .. (
                    Cheat.Flags.AntiAFK
                    and "ВКЛЮЧЕН"
                    or "ВЫКЛЮЧЕН"
                ),
            Color3.fromRGB(0, 255, 0)
        )
    end
}

Cmds.autoclick = {
    desc = "Включить/выключить авто-кликер",

    run = function(args, output)
        Cheat.Flags.AutoClick =
            not Cheat.Flags.AutoClick

        output(
            "🖱️ Авто-кликер "
                .. (
                    Cheat.Flags.AutoClick
                    and "ВКЛЮЧЕН"
                    or "ВЫКЛЮЧЕН"
                ),
            Color3.fromRGB(0, 255, 0)
        )
    end
}

Cmds.mm2aimbot = {
    desc = "MM2 Aimbot — заглушка",

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
            Color3.fromRGB(255, 255, 0)
        )
    end
}

Cmds.mm2autoshoot = {
    desc = "MM2 AutoShoot — заглушка",

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
            Color3.fromRGB(255, 255, 0)
        )
    end
}

-- ======================================================
-- RESET
-- ======================================================

Cmds.reset = {
    desc = "Сбросить состояние",

    run = function(args, output)
        output(
            "🔄 Сброс состояния...",
            Color3.fromRGB(255, 255, 0)
        )

        -- Выключаем функции
        SetFly(false)
        SetNoclip(false)
        SetInvisible(false)

        Cheat.Flags.ESP = false
        Cheat.Flags.Saitama = false
        Cheat.Flags.InfiniteJump = false
        Cheat.Flags.AntiAFK = false
        Cheat.Flags.AutoClick = false
        Cheat.Flags.Spin = false
        Cheat.Flags.Sit = false
        Cheat.Flags.Freeze = false
        Cheat.Flags.GodMode = false
        Cheat.Flags.MM2Aimbot = false
        Cheat.Flags.MM2AutoShoot = false

        Cheat.Runtime.JumpConnection =
            DisconnectConnection(
                Cheat.Runtime.JumpConnection
            )

        if Cheat.Runtime.FreezeBV then
            Cheat.Runtime.FreezeBV:Destroy()
            Cheat.Runtime.FreezeBV = nil
        end

        ClearESP()

        for part, original in pairs(
            Cheat.Runtime.OriginalTransparency
        ) do

            pcall(function()
                if part and part.Parent then
                    part.Transparency = original
                end
            end)
        end

        Cheat.Runtime.OriginalTransparency = {}

        local humanoid = GetHumanoid()

        if humanoid then
            humanoid.PlatformStand = false
            humanoid.Sit = false
            humanoid.WalkSpeed = 16
            humanoid.Health = humanoid.Health
        end

        Cheat.Config.SpeedValue = 16
        Cheat.Config.SpinSpeed = 10

        if JoyGui then
            JoyGui.Enabled = false
        end

        output(
            "✅ Состояние сброшено",
            Color3.fromRGB(0, 255, 0)
        )
    end
}

-- ======================================================
-- UNLOAD
-- ======================================================

Cmds.unload = {
    desc = "Полностью выгрузить скрипт",

    run = function(args, output)
        output(
            "🛑 Выгрузка скрипта...",
            Color3.fromRGB(255, 0, 0)
        )

        task.wait(0.1)

        Cheat.Runtime.Destroyed = true

        Cheat.Flags.Fly = false
        Cheat.Flags.Noclip = false
        Cheat.Flags.ESP = false
        Cheat.Flags.InfiniteJump = false
        Cheat.Flags.AntiAFK = false
        Cheat.Flags.Saitama = false
        Cheat.Flags.AutoClick = false
        Cheat.Flags.Spin = false
        Cheat.Flags.Freeze = false
        Cheat.Flags.GodMode = false
        Cheat.Flags.Invisible = false

        if Cheat.Runtime.FlyBodyVelocity then
            Cheat.Runtime.FlyBodyVelocity:Destroy()
            Cheat.Runtime.FlyBodyVelocity = nil
        end

        if Cheat.Runtime.FreezeBV then
            Cheat.Runtime.FreezeBV:Destroy()
            Cheat.Runtime.FreezeBV = nil
        end

        Cheat.Runtime.JumpConnection =
            DisconnectConnection(
                Cheat.Runtime.JumpConnection
            )

        Cheat.Runtime.NoclipConnection =
            DisconnectConnection(
                Cheat.Runtime.NoclipConnection
            )

        RestoreCollisionState()
        RestoreTransparency()
        ClearESP()

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

        if JoyGui then
            pcall(function()
                JoyGui:Destroy()
            end)

            JoyGui = nil
        end

        -- Кнопка мобильного интерфейса удаляется ниже
        if MobileButton then
            pcall(function()
                MobileButton:Destroy()
            end)

            MobileButton = nil
        end

        print("MAX EDITION выгружена.")
    end
}

-- ======================================================
-- COMMAND EXECUTOR
-- ======================================================

ExecuteCommand = function(command, output)
    if type(command) ~= "string" then
        return
    end

    local parts = {}

    for word in command:gmatch("%S+") do
        table.insert(parts, word)
    end

    if #parts == 0 then
        return
    end

    local name = parts[1]:lower()

    table.remove(parts, 1)

    local args = parts

    if name == "tp" then
        name = "goto"
    end

    local commandData = Cmds[name]

    if commandData
        and type(commandData.run) == "function" then

        local success, errorMessage =
            pcall(function()
                commandData.run(args, output)
            end)

        if not success then
            output(
                "❌ Ошибка: " .. tostring(errorMessage),
                Color3.fromRGB(255, 50, 50)
            )
        end

    else
        output(
            "⚠️ Неизвестная команда. Используйте help",
            Color3.fromRGB(255, 255, 0)
        )
    end
end

-- ======================================================
-- MOBILE OPEN BUTTON
-- ======================================================

local MobileButton = Instance.new("ScreenGui")
MobileButton.Name = "MobileOpenButton"
MobileButton.ResetOnSpawn = false
MobileButton.Parent =
    LocalPlayer:WaitForChild("PlayerGui")

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.fromOffset(60, 60)
OpenBtn.Position =
    UDim2.new(0.9, 0, 0.05, 0)

OpenBtn.BackgroundColor3 =
    Color3.fromRGB(30, 30, 60)

OpenBtn.BorderSizePixel = 2
OpenBtn.BorderColor3 =
    Color3.fromRGB(255, 215, 0)

OpenBtn.Text = "⚡"
OpenBtn.TextColor3 =
    Color3.fromRGB(255, 215, 0)

OpenBtn.TextScaled = true
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Parent = MobileButton

-- ======================================================
-- CONSOLE TOGGLE
-- ======================================================

local function ToggleConsole()
    if Cheat.Runtime.Destroyed then
        return
    end

    Cheat.Runtime.ConsoleVisible =
        not Cheat.Runtime.ConsoleVisible

    if not GUI or not GUI.Parent then
        CreateConsole()
    end

    if GUI then
        GUI.Enabled =
            Cheat.Runtime.ConsoleVisible

        if Cheat.Runtime.ConsoleVisible
            and InputBox then

            task.defer(function()
                if InputBox
                    and InputBox.Parent then

                    InputBox:CaptureFocus()
                end
            end)
        end
    end
end

AddConnection(
    OpenBtn.MouseButton1Click:Connect(
        ToggleConsole
    )
)

AddConnection(
    UserInputService.InputBegan:Connect(
        function(input, processed)
            if processed then
                return
            end

            if input.KeyCode ~= Enum.KeyCode.RightShift then
                return
            end

            local now = os.clock()

            if now - LastRightShiftPress < 0.5 then
                RightShiftPressCount += 1
            else
                RightShiftPressCount = 1
            end

            LastRightShiftPress = now

            if RightShiftPressCount >= 2 then
                RightShiftPressCount = 0
                ToggleConsole()
            end
        end
    )
)

-- ======================================================
-- RENDER LOOP
-- ======================================================

AddConnection(
    RunService.RenderStepped:Connect(function()
        if Cheat.Runtime.Destroyed then
            return
        end

        -- ESP
        if Cheat.Flags.ESP then
            UpdateESP()
        end

        -- Fly
        if Cheat.Flags.Fly
            and Cheat.Runtime.FlyBodyVelocity then

            local speed =
                Cheat.Config.FlySpeed

            local velocity = Vector3.zero

            local look =
                Camera.CFrame.LookVector

            local right =
                Camera.CFrame.RightVector

            local up =
                Vector3.new(0, 1, 0)

            if IsDesktop then

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.W
                ) then
                    velocity += look * speed
                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.S
                ) then
                    velocity -= look * speed
                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.A
                ) then
                    velocity -= right * speed
                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.D
                ) then
                    velocity += right * speed
                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.Space
                ) then
                    velocity += up * speed
                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.LeftControl
                ) then
                    velocity -= up * speed
                end

            else

                velocity +=
                    right
                    * Cheat.Runtime.FlyDirection.X
                    * speed

                velocity +=
                    look
                    * Cheat.Runtime.FlyDirection.Z
                    * speed

                if Cheat.Runtime.FlyUpActive then
                    velocity += up * speed
                end

                if Cheat.Runtime.FlyDownActive then
                    velocity -= up * speed
                end
            end

            if Cheat.Runtime.FlyBodyVelocity.Parent then
                Cheat.Runtime.FlyBodyVelocity.Velocity =
                    velocity
            end
        end

        -- Spin
        if Cheat.Flags.Spin then
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
        end
    end)
)

-- ======================================================
-- GODMODE LOOP
-- ======================================================

AddConnection(
    RunService.Heartbeat:Connect(function()
        if Cheat.Runtime.Destroyed then
            return
        end

        if Cheat.Flags.GodMode then
            local humanoid = GetHumanoid()

            if humanoid
                and humanoid.Parent
                and humanoid.Health > 0 then

                humanoid.Health =
                    humanoid.MaxHealth
            end
        end
    end)
)

-- ======================================================
-- ANTI-AFK
-- ======================================================

task.spawn(function()
    while not Cheat.Runtime.Destroyed do

        if Cheat.Flags.AntiAFK then
            pcall(function()
                LocalPlayer:Move(
                    Vector3.new(1, 0, 0)
                )

                task.wait(0.25)

                LocalPlayer:Move(
                    Vector3.new(-1, 0, 0)
                )
            end)
        end

        task.wait(30)
    end
end)

-- ======================================================
-- AUTO CLICK
-- ======================================================

task.spawn(function()
    while not Cheat.Runtime.Destroyed do

        if Cheat.Flags.AutoClick then
            pcall(function()
                local VirtualInputManager =
                    game:GetService(
                        "VirtualInputManager"
                    )

                VirtualInputManager:
                    SendMouseButtonEvent(
                        0,
                        0,
                        0,
                        true,
                        game,
                        0
                    )

                task.wait(0.01)

                VirtualInputManager:
                    SendMouseButtonEvent(
                        0,
                        0,
                        0,
                        false,
                        game,
                        0
                    )
            end)
        end

        task.wait(0.1)
    end
end)

-- ======================================================
-- PLAYER EVENTS
-- ======================================================

AddConnection(
    Players.PlayerAdded:Connect(function(player)

        if Cheat.Flags.ESP
            and player ~= LocalPlayer then

            task.wait(0.5)

            if Cheat.Flags.ESP then
                AddESPForPlayer(player)
            end
        end
    end)
)

AddConnection(
    Players.PlayerRemoving:Connect(function(player)
        RemoveESPForPlayer(player)
    end)
)

AddConnection(
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)

        if Cheat.Runtime.Destroyed then
            return
        end

        -- Speed
        local humanoid = GetHumanoid()

        if humanoid then
            humanoid.WalkSpeed =
                Cheat.Config.SpeedValue
        end

        -- Fly
        if Cheat.Flags.Fly then
            SetFly(true)
        end

        -- Noclip
        if Cheat.Flags.Noclip then
            SetNoclip(true)
        end

        -- Invisible
        if Cheat.Flags.Invisible then
            SetInvisible(true)
        end

        -- Saitama
        if Cheat.Flags.Saitama then
            local root = GetRoot()

            if root then
                AddSaitamaEffect(root)
            end
        end

        -- ESP
        if Cheat.Flags.ESP then
            CreateESP()
        end
    end)
)

-- ======================================================
-- MOBILE SETUP
-- ======================================================

SetupMobileFly()

-- ======================================================
-- INITIAL CONSOLE
-- ======================================================

CreateConsole()

if GUI then
    GUI.Enabled = false
end

if JoyGui then
    JoyGui.Enabled = false
end

-- ======================================================
-- APPLY SAVED SETTINGS
-- ======================================================

task.defer(function()
    task.wait(1)

    if Cheat.Runtime.Destroyed then
        return
    end

    local humanoid = GetHumanoid()

    if humanoid then
        humanoid.WalkSpeed =
            Cheat.Config.SpeedValue
    end

    -- ESP
    if Cheat.Flags.ESP then
        CreateESP()
    end

    -- Noclip
    if Cheat.Flags.Noclip then
        SetNoclip(true)
    end

    -- Fly
    if Cheat.Flags.Fly then
        SetFly(true)
    end

    -- Saitama
    if Cheat.Flags.Saitama then
        local root = GetRoot()

        if root then
            AddSaitamaEffect(root)
        end
    end
end)

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
                "Готово! ⚡ или двойной RightShift",

            Duration = 5
        }
    )
end)

print(
    "✅ MAX EDITION & DEEPSEEK FIXED загружена"
)
