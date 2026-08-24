-- MAX EDITION & DEEPSEEK ALL GAMES — CLEAN FIX
-- TouchFling удалён.
-- Fly не включается автоматически после респавна.
-- После респавна команда "fly" снова работает.

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
    }
}

local GUI
local InputBox
local OutputScrolling
local Cmds = {}

local LastRightShiftPress = 0
local RightShiftPressCount = 0

local IsMobile = UserInputService.TouchEnabled
local IsDesktop = not IsMobile

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ======================================================
-- MOBILE FLY JOYSTICK
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
    JoyStick.Position = UDim2.new(0.5, -20, 0.5, -20)
end

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

    local center = JoyFrame.AbsolutePosition + JoyFrame.AbsoluteSize / 2
    local delta = input.Position - center
    local maxDist = 40

    if delta.Magnitude > maxDist then
        delta = delta.Unit * maxDist
    end

    JoyStick.Position = UDim2.new(
        0.5, delta.X - 20,
        0.5, delta.Y - 20
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
        fly = false,
        noclip = Cheat.Flags.Noclip,
        saitama = Cheat.Flags.Saitama,
    }

    pcall(function()
        writefile(SettingsFile, HttpService:JSONEncode(settings))
    end)
end

local function LoadSettings()
    local success, data = pcall(function()
        return readfile(SettingsFile)
    end)

    if success and data then
        local ok, settings = pcall(function()
            return HttpService:JSONDecode(data)
        end)

        if ok and type(settings) == "table" then
            Cheat.Config.SpeedValue = tonumber(settings.speed) or 16
        end
    end

    -- Fly, ESP, Noclip и Saitama не восстанавливаются автоматически.
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
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRoot()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
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
    if not char then return end

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
            local color = RainbowColor(Cheat.Config.RainbowOffset)
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
    -- Определяем настоящий цвет команды, а не просто
    -- красный/зелёный по отношению к LocalPlayer.
    local char = pl.Character
    local teamColor = pl.TeamColor

    -- 1. Roblox TeamColor — самый надёжный вариант, если Team существует.
    if pl.Team and teamColor then
        return teamColor.Color
    end

    -- 2. Если игра использует цветные SpawnLocation,
    -- пытаемся определить команду по ближайшему спавну.
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        local nearestColor = nil
        local nearestDistance = math.huge

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("SpawnLocation") and obj.Neutral == false then
                local distance = (obj.Position - root.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestColor = obj.TeamColor.Color
                end
            end
        end

        if nearestColor and nearestDistance <= 35 then
            return nearestColor
        end
    end

    -- 3. Некоторые игры не используют Team/SpawnLocation,
    -- поэтому проверяем типичные объекты/значения с цветом команды.
    local candidates = {
        char and char:FindFirstChild("TeamColor"),
        char and char:FindFirstChild("Team"),
        pl:FindFirstChild("TeamColor"),
    }

    for _, obj in ipairs(candidates) do
        if obj then
            if obj:IsA("BrickColorValue") then
                return obj.Value.Color
            elseif obj:IsA("Color3Value") then
                return obj.Value
            end
        end
    end

    -- 4. Если команда действительно не определилась,
    -- используем нейтральный белый вместо ложного красного/зелёного.
    return Color3.fromRGB(255, 255, 255)
end

local function ClearESP()
    for _, obj in pairs(Cheat.Runtime.ESPTexts) do
        pcall(function() obj:Destroy() end)
    end

    for _, obj in pairs(Cheat.Runtime.ESPHighlights) do
        pcall(function() obj:Destroy() end)
    end

    for _, conn in pairs(Cheat.Runtime.ESPCharacterConnections) do
        pcall(function() conn:Disconnect() end)
    end

    Cheat.Runtime.ESPTexts = {}
    Cheat.Runtime.ESPHighlights = {}
    Cheat.Runtime.ESPCharacterConnections = {}
end

local function AddESPForPlayer(pl)
    if pl == LocalPlayer or not Cheat.Flags.ESP then
        return
    end

    if Cheat.Runtime.ESPTexts[pl] then
        pcall(function() Cheat.Runtime.ESPTexts[pl]:Destroy() end)
        Cheat.Runtime.ESPTexts[pl] = nil
    end

    if Cheat.Runtime.ESPHighlights[pl] then
        pcall(function() Cheat.Runtime.ESPHighlights[pl]:Destroy() end)
        Cheat.Runtime.ESPHighlights[pl] = nil
    end

    local char = pl.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")

    if not hum or not root or not head then
        return
    end

    local color = GetTeamColor(pl)

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

    local highlight = Instance.new("Highlight")
    highlight.Name = "MAX_ESP_Highlight"
    highlight.FillColor = color
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = color
    highlight.OutlineTransparency = 0.2
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = char
    highlight.Parent = char

    Cheat.Runtime.ESPTexts[pl] = billboard
    Cheat.Runtime.ESPHighlights[pl] = highlight

    if Cheat.Runtime.ESPCharacterConnections[pl] then
        pcall(function()
            Cheat.Runtime.ESPCharacterConnections[pl]:Disconnect()
        end)
    end

    Cheat.Runtime.ESPCharacterConnections[pl] =
        pl.CharacterAdded:Connect(function()
            if not Cheat.Flags.ESP then return end
            task.wait(0.25)

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
    if not Cheat.Flags.ESP then return end

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer then
            local char = pl.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")

            local billboard = Cheat.Runtime.ESPTexts[pl]
            local highlight = Cheat.Runtime.ESPHighlights[pl]

            if hum and root and head then
                if not billboard or not billboard.Parent then
                    AddESPForPlayer(pl)
                    billboard = Cheat.Runtime.ESPTexts[pl]
                    highlight = Cheat.Runtime.ESPHighlights[pl]
                end

                local color = GetTeamColor(pl)
                local label = billboard and billboard:FindFirstChild("ESPText")

                if label then
                    local localRoot = GetRoot()
                    local dist = localRoot
                        and (localRoot.Position - root.Position).Magnitude
                        or 0

                    local hp = math.max(0, math.floor(hum.Health))

                    label.TextColor3 = color
                    label.Text = string.format(
                        "%s [%d HP] [%d м]",
                        pl.Name,
                        hp,
                        math.floor(dist)
                    )
                    label.Visible = true
                end

                if highlight then
                    highlight.FillColor = color
                    highlight.OutlineColor = color
                    highlight.Adornee = char
                    highlight.Enabled = hum.Health > 0
                end

                if billboard then
                    billboard.Adornee = head
                    billboard.Enabled = true
                end
            else
                if billboard then billboard.Enabled = false end
                if highlight then highlight.Enabled = false end
            end
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)

Players.PlayerAdded:Connect(function(pl)
    if not Cheat.Flags.ESP then return end

    task.spawn(function()
        pl.CharacterAdded:Wait()
        task.wait(0.25)

        if Cheat.Flags.ESP and pl.Parent then
            AddESPForPlayer(pl)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(pl)
    if Cheat.Runtime.ESPTexts[pl] then
        pcall(function() Cheat.Runtime.ESPTexts[pl]:Destroy() end)
    end

    if Cheat.Runtime.ESPHighlights[pl] then
        pcall(function() Cheat.Runtime.ESPHighlights[pl]:Destroy() end)
    end

    if Cheat.Runtime.ESPCharacterConnections[pl] then
        pcall(function() Cheat.Runtime.ESPCharacterConnections[pl]:Disconnect() end)
    end

    Cheat.Runtime.ESPTexts[pl] = nil
    Cheat.Runtime.ESPHighlights[pl] = nil
    Cheat.Runtime.ESPCharacterConnections[pl] = nil
end)

-- ======================================================
-- FLY — FIXED RESPAWN SYSTEM
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
        hum.PlatformStand = false
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

    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    if not hum or not root then
        return false, "⚠️ Персонаж ещё не загрузился"
    end

    if hum.Health <= 0 then
        return false, "⚠️ Персонаж мёртв"
    end

    DestroyFlyVelocity()

    local bv = Instance.new("BodyVelocity")
    bv.Name = "MAX_FlyVelocity"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.P = 100000
    bv.Velocity = Vector3.zero
    bv.Parent = root

    Cheat.Runtime.FlyBodyVelocity = bv
    Cheat.Flags.Fly = true

    hum.PlatformStand = true

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
        return
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    local bv = Cheat.Runtime.FlyBodyVelocity

    if not hum or not root or not bv or bv.Parent ~= root then
        StopFly()
        return
    end

    if hum.Health <= 0 then
        StopFly()
        return
    end

    Camera = workspace.CurrentCamera
    if not Camera then return end

    local speed = tonumber(Cheat.Config.FlySpeed) or 70
    local velocity = Vector3.zero

    local look = Camera.CFrame.LookVector
    local right = Camera.CFrame.RightVector
    local up = Vector3.new(0, 1, 0)

    if IsDesktop then
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
        local center = JoyFrame.AbsolutePosition + JoyFrame.AbsoluteSize / 2
        local stickCenter = JoyStick.AbsolutePosition + JoyStick.AbsoluteSize / 2
        local delta = stickCenter - center
        local maxDist = 40

        local x = math.clamp(delta.X / maxDist, -1, 1)
        local z = math.clamp(delta.Y / maxDist, -1, 1)

        velocity += right * x * speed
        velocity += look * (-z) * speed

        if FlyUpActive then velocity += up * speed end
        if FlyDownActive then velocity -= up * speed end
    end

    bv.Velocity = velocity
end

Cheat.Runtime.FlyRenderConnection =
    RunService.RenderStepped:Connect(UpdateFly)

-- ======================================================
-- RESPAWN HANDLER
-- ======================================================

LocalPlayer.CharacterRemoving:Connect(function()
    -- Старый персонаж удаляется.
    -- Fly полностью выключается.
    StopFly()
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    -- Fly здесь НЕ запускается автоматически.
    -- После загрузки новый fly создаётся командой "fly".

    task.spawn(function()
        local hum = character:WaitForChild("Humanoid", 10)
        local root = character:WaitForChild("HumanoidRootPart", 10)

        if not hum or not root then
            return
        end

        task.wait(0.2)

        hum.WalkSpeed = Cheat.Config.SpeedValue

        if Cheat.Flags.Noclip then
            if Cheat.Runtime.NoclipConnection then
                pcall(function()
                    Cheat.Runtime.NoclipConnection:Disconnect()
                end)
                Cheat.Runtime.NoclipConnection = nil
            end

            Cheat.Runtime.NoclipConnection =
                RunService.Stepped:Connect(function()
                    if not Cheat.Flags.Noclip then return end

                    local currentChar = LocalPlayer.Character
                    if not currentChar then return end

                    for _, part in ipairs(currentChar:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end)
        end

        if Cheat.Flags.Saitama then
            local newRoot = character:FindFirstChild("HumanoidRootPart")
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
    if not OutputScrolling then return end

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -8, 0, 22)
    label.Position = UDim2.new(0, 4, 0, OutputScrolling.CanvasSize.Y.Offset)
    label.BackgroundTransparency = 1
    label.Text = tostring(text)
    label.TextColor3 = color or Color3.new(1, 1, 1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 15
    label.Parent = OutputScrolling

    OutputScrolling.CanvasSize = UDim2.new(
        0, 0, 0,
        OutputScrolling.CanvasSize.Y.Offset + 24
    )

    task.defer(function()
        OutputScrolling.CanvasPosition = Vector2.new(
            0,
            math.max(0, OutputScrolling.CanvasSize.Y.Offset)
        )
    end)
end

local function ExecuteCommand(cmd, output)
    local parts = {}

    for word in cmd:gmatch("%S+") do
        table.insert(parts, word)
    end

    if #parts == 0 then return end

    local name = table.remove(parts, 1):lower()
    local command = Cmds[name]

    if command then
        local ok, err = pcall(function()
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
    if GUI then
        pcall(function() GUI:Destroy() end)
    end

    GUI = Instance.new("ScreenGui")
    GUI.Name = "MaxEditionConsole"
    GUI.ResetOnSpawn = false
    GUI.Enabled = Cheat.Runtime.ConsoleVisible
    GUI.Parent = PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 600, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -225)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.fromRGB(255, 215, 0)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = GUI

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
    Title.Text = "⚡ MAX EDITION & DEEPSEEK"
    Title.TextColor3 = Color3.fromRGB(255, 215, 0)
    Title.TextScaled = true
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame

    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, 0, 0, 20)
    InfoLabel.Position = UDim2.new(0, 0, 0, 40)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Text = "🟢 ⚡ или двойной RightShift"
    InfoLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
    InfoLabel.TextScaled = true
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.Parent = MainFrame

    OutputScrolling = Instance.new("ScrollingFrame")
    OutputScrolling.Size = UDim2.new(1, -20, 0, 280)
    OutputScrolling.Position = UDim2.new(0, 10, 0, 65)
    OutputScrolling.BackgroundColor3 = Color3.fromRGB(5, 5, 15)
    OutputScrolling.BackgroundTransparency = 0.3
    OutputScrolling.BorderSizePixel = 1
    OutputScrolling.BorderColor3 = Color3.fromRGB(60, 60, 100)
    OutputScrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
    OutputScrolling.ScrollBarThickness = 5
    OutputScrolling.Parent = MainFrame

    InputBox = Instance.new("TextBox")
    InputBox.Size = UDim2.new(1, -20, 0, 35)
    InputBox.Position = UDim2.new(0, 10, 0, 355)
    InputBox.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    InputBox.BorderSizePixel = 1
    InputBox.BorderColor3 = Color3.fromRGB(80, 80, 150)
    InputBox.Text = ""
    InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputBox.TextSize = 16
    InputBox.Font = Enum.Font.Gotham
    InputBox.ClearTextOnFocus = false
    InputBox.PlaceholderText = "Введите команду... (help)"
    InputBox.Parent = MainFrame

    local function output(text, color)
        AddConsoleOutput(text, color)
    end

    output(
        "⚡ MAX EDITION | TouchFling удалён | Fly fixed",
        Color3.fromRGB(255, 215, 0)
    )

    InputBox.FocusLost:Connect(function(enterPressed)
        if not enterPressed then return end

        local cmd = InputBox.Text
        InputBox.Text = ""

        if cmd ~= "" then
            output("> " .. cmd, Color3.fromRGB(200, 200, 255))

            table.insert(Cheat.Runtime.CommandHistory, cmd)

            if #Cheat.Runtime.CommandHistory > 100 then
                table.remove(Cheat.Runtime.CommandHistory, 1)
            end

            Cheat.Runtime.HistoryIndex =
                #Cheat.Runtime.CommandHistory + 1

            ExecuteCommand(cmd, output)
        end
    end)
end

-- ======================================================
-- COMMANDS
-- ======================================================

Cmds.help = {
    desc = "Показать все команды",

    run = function(args, output)
        output("===== ДОСТУПНЫЕ КОМАНДЫ =====", Color3.fromRGB(255, 215, 0))

        local commands = {
            "help", "fly", "unfly", "speed", "noclip",
            "fakeheal", "goto", "esp", "saitama",
            "antiafk", "autoclick", "spin", "sit",
            "jump", "tpall", "freeze", "time", "weather",
            "godmode", "invisible", "mm2aimbot",
            "mm2autoshoot", "reset", "unload"
        }

        for _, name in ipairs(commands) do
            if Cmds[name] then
                output(
                    name .. " - " .. Cmds[name].desc,
                    Color3.fromRGB(200, 200, 255)
                )
            elseif name == "goto" then
                output(
                    "goto/tp - Телепорт к игроку или координатам",
                    Color3.fromRGB(200, 200, 255)
                )
            end
        end

        output("===== КОНЕЦ СПИСКА =====", Color3.fromRGB(255, 215, 0))
    end
}

Cmds.fly = {
    desc = "Полет: fly [скорость]. Выключение: unfly",

    run = function(args, output)
        local requested = tonumber(args[1])

        if requested then
            Cheat.Config.FlySpeed =
                math.clamp(requested, 1, 100000)
        end

        if Cheat.Flags.Fly then
            output(
                "✈️ Полет уже включен | скорость: " ..
                tostring(Cheat.Config.FlySpeed),
                Color3.fromRGB(0, 255, 0)
            )
            return
        end

        local ok, message = StartFly()

        if not ok then
            output(message, Color3.fromRGB(255, 255, 0))
            return
        end

        output(
            "✈️ Полет ВКЛЮЧЕН | скорость: " ..
            tostring(Cheat.Config.FlySpeed),
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

        Cheat.Config.SpeedValue = math.max(0, speed)

        local hum = GetHumanoid()
        if hum then
            hum.WalkSpeed = Cheat.Config.SpeedValue
        end

        SaveSettings()

        output(
            "🏃 Скорость: " .. tostring(Cheat.Config.SpeedValue),
            Color3.fromRGB(0, 255, 0)
        )
    end
}

Cmds.noclip = {
    desc = "Включить/выключить прохождение сквозь стены",

    run = function(args, output)
        Cheat.Flags.Noclip = not Cheat.Flags.Noclip

        if Cheat.Flags.Noclip then
            if Cheat.Runtime.NoclipConnection then
                Cheat.Runtime.NoclipConnection:Disconnect()
            end

            Cheat.Runtime.NoclipConnection =
                RunService.Stepped:Connect(function()
                    if not Cheat.Flags.Noclip then return end

                    local char = GetCharacter()

                    if char then
                        for _, part in ipairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end)

            output("🚧 Noclip ВКЛЮЧЕН", Color3.fromRGB(0, 255, 0))
        else
            if Cheat.Runtime.NoclipConnection then
                Cheat.Runtime.NoclipConnection:Disconnect()
                Cheat.Runtime.NoclipConnection = nil
            end

            local char = GetCharacter()

            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end

            output("🚧 Noclip ВЫКЛЮЧЕН", Color3.fromRGB(255, 0, 0))
        end

        SaveSettings()
    end
}

Cmds.fakeheal = {
    desc = "Восстановить здоровье",

    run = function(args, output)
        local hum = GetHumanoid()

        if hum then
            hum.Health = hum.MaxHealth
            output("❤️ Здоровье восстановлено", Color3.fromRGB(0, 255, 0))
        else
            output("⚠️ Персонаж не найден", Color3.fromRGB(255, 255, 0))
        end
    end
}

Cmds.esp = {
    desc = "Включить/выключить ESP",

    run = function(args, output)
        Cheat.Flags.ESP = not Cheat.Flags.ESP

        if Cheat.Flags.ESP then
            CreateESP()
            output("👁️ ESP ВКЛЮЧЕН", Color3.fromRGB(0, 255, 0))
        else
            ClearESP()
            output("👁️ ESP ВЫКЛЮЧЕН", Color3.fromRGB(255, 0, 0))
        end

        SaveSettings()
    end
}

Cmds.saitama = {
    desc = "Включить/выключить режим Сайтамы",

    run = function(args, output)
        Cheat.Flags.Saitama = not Cheat.Flags.Saitama
        local root = GetRoot()

        if Cheat.Flags.Saitama and root then
            AddSaitamaEffect(root)
            output("👊 Режим Сайтамы ВКЛЮЧЕН", Color3.fromRGB(0, 255, 0))
        else
            RemoveSaitamaEffect()
            output("👊 Режим Сайтамы ВЫКЛЮЧЕН", Color3.fromRGB(255, 0, 0))
        end

        SaveSettings()
    end
}

Cmds.sit = {
    desc = "Сесть/встать",

    run = function(args, output)
        Cheat.Flags.Sit = not Cheat.Flags.Sit
        local hum = GetHumanoid()

        if hum then
            hum.Sit = Cheat.Flags.Sit
            output(
                Cheat.Flags.Sit and "🪑 Сел" or "🪑 Встал",
                Color3.fromRGB(0, 255, 0)
            )
        end
    end
}

Cmds.jump = {
    desc = "Включить/выключить бесконечный прыжок",

    run = function(args, output)
        Cheat.Flags.InfiniteJump = not Cheat.Flags.InfiniteJump

        if Cheat.Flags.InfiniteJump then
            if Cheat.Runtime.JumpConnection then
                Cheat.Runtime.JumpConnection:Disconnect()
            end

            Cheat.Runtime.JumpConnection =
                UserInputService.JumpRequest:Connect(function()
                    if not Cheat.Flags.InfiniteJump then return end

                    local hum = GetHumanoid()

                    if hum and hum.Health > 0 then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end)

            output("🦘 Бесконечный прыжок ВКЛЮЧЕН", Color3.fromRGB(0, 255, 0))
        else
            if Cheat.Runtime.JumpConnection then
                Cheat.Runtime.JumpConnection:Disconnect()
                Cheat.Runtime.JumpConnection = nil
            end

            output("🦘 Бесконечный прыжок ВЫКЛЮЧЕН", Color3.fromRGB(255, 0, 0))
        end
    end
}

Cmds.tpall = {
    desc = "Телепортировать всех к себе",

    run = function(args, output)
        local root = GetRoot()

        if not root then
            output("⚠️ Вы не в игре", Color3.fromRGB(255, 255, 0))
            return
        end

        local count = 0

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local targetRoot =
                    player.Character
                    and player.Character:FindFirstChild("HumanoidRootPart")

                if targetRoot then
                    targetRoot.CFrame =
                        root.CFrame + Vector3.new(0, 3, 0)
                    count += 1
                end
            end
        end

        output(
            "📍 Телепортировано: " .. count,
            Color3.fromRGB(0, 255, 0)
        )
    end
}

Cmds.freeze = {
    desc = "Заморозить/разморозить себя",

    run = function(args, output)
        Cheat.Flags.Freeze = not Cheat.Flags.Freeze

        local root = GetRoot()
        local hum = GetHumanoid()

        if not root or not hum then return end

        if Cheat.Flags.Freeze then
            if Cheat.Runtime.FreezeBV then
                Cheat.Runtime.FreezeBV:Destroy()
            end

            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1, 1, 1) * 100000
            bv.Velocity = Vector3.zero
            bv.Parent = root

            Cheat.Runtime.FreezeBV = bv
            hum.PlatformStand = true

            output("🧊 Вы заморожены", Color3.fromRGB(0, 255, 0))
        else
            if Cheat.Runtime.FreezeBV then
                Cheat.Runtime.FreezeBV:Destroy()
                Cheat.Runtime.FreezeBV = nil
            end

            hum.PlatformStand = false
            hum.Sit = false

            output("🧊 Вы разморожены", Color3.fromRGB(0, 255, 0))
        end
    end
}

Cmds.time = {
    desc = "Установить время: time [0-23]",

    run = function(args, output)
        local hour = tonumber(args[1])

        if not hour or hour < 0 or hour > 23 then
            output("⚠️ Использование: time [0-23]", Color3.fromRGB(255, 255, 0))
            return
        end

        Lighting:SetMinutesAfterMidnight(hour * 60)

        output(
            "🕐 Время: " .. hour .. ":00",
            Color3.fromRGB(0, 255, 0)
        )
    end
}

Cmds.weather = {
    desc = "Погода: weather [rain/sun/snow]",

    run = function(args, output)
        local weather = args[1] and args[1]:lower()

        if not weather then
            output(
                "⚠️ Использование: weather [rain/sun/snow]",
                Color3.fromRGB(255, 255, 0)
            )
            return
        end

        if weather == "rain" then
            pcall(function() Lighting.Rain = 1 end)
            output("🌧️ Дождь", Color3.fromRGB(0, 255, 0))
        elseif weather == "sun" then
            pcall(function() Lighting.Rain = 0 end)
            output("☀️ Солнечно", Color3.fromRGB(0, 255, 0))
        elseif weather == "snow" then
            pcall(function() Lighting.Snow = 1 end)
            output("❄️ Снег", Color3.fromRGB(0, 255, 0))
        else
            output(
                "⚠️ Неизвестный тип погоды",
                Color3.fromRGB(255, 255, 0)
            )
        end
    end
}

Cmds.antiafk = {
    desc = "Защита от AFK",

    run = function(args, output)
        Cheat.Flags.AntiAFK = not Cheat.Flags.AntiAFK

        if Cheat.Flags.AntiAFK then
            task.spawn(function()
                while Cheat.Flags.AntiAFK do
                    pcall(function()
                        LocalPlayer:Move(Vector3.zero)
                    end)
                    task.wait(30)
                end
            end)

            output("🛡️ Anti-AFK ВКЛЮЧЕН", Color3.fromRGB(0, 255, 0))
        else
            output("🛡️ Anti-AFK ВЫКЛЮЧЕН", Color3.fromRGB(255, 0, 0))
        end
    end
}

Cmds.autoclick = {
    desc = "Авто-кликер",

    run = function(args, output)
        Cheat.Flags.AutoClick = not Cheat.Flags.AutoClick

        if Cheat.Flags.AutoClick then
            task.spawn(function()
                local vim = game:GetService("VirtualInputManager")

                while Cheat.Flags.AutoClick do
                    pcall(function()
                        vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.01)
                        vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end)
                    task.wait(0.1)
                end
            end)

            output("🖱️ Авто-кликер ВКЛЮЧЕН", Color3.fromRGB(0, 255, 0))
        else
            output("🖱️ Авто-кликер ВЫКЛЮЧЕН", Color3.fromRGB(255, 0, 0))
        end
    end
}

Cmds.spin = {
    desc = "Вращение: spin [скорость]",

    run = function(args, output)
        local speed = tonumber(args[1])

        if speed then
            Cheat.Config.SpinSpeed = speed
        else
            Cheat.Flags.Spin = not Cheat.Flags.Spin
        end

        if speed and not Cheat.Flags.Spin then
            Cheat.Flags.Spin = true
        end

        if Cheat.Flags.Spin then
            if Cheat.Runtime.SpinThread then return end

            Cheat.Runtime.SpinThread = true

            task.spawn(function()
                while Cheat.Flags.Spin do
                    local root = GetRoot()

                    if root then
                        root.CFrame =
                            root.CFrame *
                            CFrame.Angles(
                                0,
                                math.rad(Cheat.Config.SpinSpeed),
                                0
                            )
                    end

                    task.wait(0.05)
                end

                Cheat.Runtime.SpinThread = nil
            end)

            output(
                "🔄 Spin ВКЛЮЧЕН | скорость: " ..
                tostring(Cheat.Config.SpinSpeed),
                Color3.fromRGB(0, 255, 0)
            )
        else
            output("🔄 Spin ВЫКЛЮЧЕН", Color3.fromRGB(255, 0, 0))
        end
    end
}

local function FindPlayer(query)
    local lower = query:lower()
    local exact = {}
    local prefix = {}
    local contains = {}

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer then
            local name = pl.Name:lower()
            local display = pl.DisplayName and pl.DisplayName:lower() or ""

            if name == lower or display == lower then
                table.insert(exact, pl)
            elseif name:sub(1, #lower) == lower
                or display:sub(1, #lower) == lower then
                table.insert(prefix, pl)
            elseif name:find(lower, 1, true)
                or display:find(lower, 1, true) then
                table.insert(contains, pl)
            end
        end
    end

    if #exact == 1 then return exact[1], exact end
    if #prefix == 1 then return prefix[1], prefix end
    if #contains == 1 then return contains[1], contains end
    if #exact > 0 then return nil, exact end
    if #prefix > 0 then return nil, prefix end

    return nil, contains
end

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
            output("⚠️ Вы не в игре", Color3.fromRGB(255, 255, 0))
            return
        end

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
                root.CFrame = CFrame.new(Vector3.new(x, y, z))
                output("📍 Телепорт на координаты", Color3.fromRGB(0, 255, 0))
            end

            return
        end

        local query = table.concat(args, " ")
        local target, candidates = FindPlayer(query)

        if target then
            local targetRoot =
                target.Character
                and target.Character:FindFirstChild("HumanoidRootPart")

            if targetRoot then
                root.CFrame =
                    targetRoot.CFrame +
                    Vector3.new(0, 3, 0)

                output(
                    "📍 Телепорт к " .. target.Name,
                    Color3.fromRGB(0, 255, 0)
                )
            else
                output(
                    "⚠️ У игрока нет персонажа",
                    Color3.fromRGB(255, 255, 0)
                )
            end

            return
        end

        if #candidates > 1 then
            output("⚠️ Найдено несколько игроков:", Color3.fromRGB(255, 255, 0))

            for _, p in ipairs(candidates) do
                output(
                    " - " .. p.Name ..
                    (p.DisplayName ~= p.Name
                        and " (" .. p.DisplayName .. ")"
                        or ""),
                    Color3.fromRGB(255, 255, 0)
                )
            end
        else
            output(
                "⚠️ Игрок не найден: " .. query,
                Color3.fromRGB(255, 255, 0)
            )
        end
    end
}

Cmds.tp = Cmds.goto

Cmds.godmode = {
    desc = "Включить/выключить восстановление здоровья",

    run = function(args, output)
        Cheat.Flags.GodMode = not Cheat.Flags.GodMode

        if Cheat.Flags.GodMode then
            if Cheat.Runtime.GodModeConnection then
                Cheat.Runtime.GodModeConnection:Disconnect()
            end

            Cheat.Runtime.GodModeConnection =
                RunService.Heartbeat:Connect(function()
                    if not Cheat.Flags.GodMode then return end

                    local hum = GetHumanoid()

                    if hum and hum.Health > 0 then
                        hum.Health = hum.MaxHealth
                    end
                end)

            output("🛡️ GodMode ВКЛЮЧЕН", Color3.fromRGB(0, 255, 0))
        else
            if Cheat.Runtime.GodModeConnection then
                Cheat.Runtime.GodModeConnection:Disconnect()
                Cheat.Runtime.GodModeConnection = nil
            end

            output("🛡️ GodMode ВЫКЛЮЧЕН", Color3.fromRGB(255, 0, 0))
        end
    end
}

Cmds.invisible = {
    desc = "Включить/выключить локальную невидимость",

    run = function(args, output)
        Cheat.Flags.Invisible = not Cheat.Flags.Invisible

        local char = GetCharacter()

        if not char then return end

        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = Cheat.Flags.Invisible and 1 or 0
            elseif part:IsA("Decal") then
                part.Transparency = Cheat.Flags.Invisible and 1 or 0
            end
        end

        output(
            Cheat.Flags.Invisible
                and "👻 Невидимость ВКЛЮЧЕНА"
                or "👻 Невидимость ВЫКЛЮЧЕНА",
            Color3.fromRGB(0, 255, 0)
        )
    end
}

Cmds.mm2aimbot = {
    desc = "MM2 Aimbot (заглушка)",

    run = function(args, output)
        Cheat.Flags.MM2Aimbot = not Cheat.Flags.MM2Aimbot

        output(
            "🎯 MM2 Aimbot " ..
            (Cheat.Flags.MM2Aimbot and "ВКЛЮЧЕН" or "ВЫКЛЮЧЕН") ..
            " (не реализовано)",
            Color3.fromRGB(255, 255, 0)
        )
    end
}

Cmds.mm2autoshoot = {
    desc = "MM2 AutoShoot (заглушка)",

    run = function(args, output)
        Cheat.Flags.MM2AutoShoot = not Cheat.Flags.MM2AutoShoot

        output(
            "🔫 MM2 AutoShoot " ..
            (Cheat.Flags.MM2AutoShoot and "ВКЛЮЧЕН" or "ВЫКЛЮЧЕН") ..
            " (не реализовано)",
            Color3.fromRGB(255, 255, 0)
        )
    end
}

-- ======================================================
-- RESET
-- ======================================================

Cmds.reset = {
    desc = "Сбросить состояния скрипта",

    run = function(args, output)
        StopFly()

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

        ClearESP()
        RemoveSaitamaEffect()

        if Cheat.Runtime.FreezeBV then
            pcall(function()
                Cheat.Runtime.FreezeBV:Destroy()
            end)
            Cheat.Runtime.FreezeBV = nil
        end

        if Cheat.Runtime.JumpConnection then
            Cheat.Runtime.JumpConnection:Disconnect()
            Cheat.Runtime.JumpConnection = nil
        end

        if Cheat.Runtime.NoclipConnection then
            Cheat.Runtime.NoclipConnection:Disconnect()
            Cheat.Runtime.NoclipConnection = nil
        end

        if Cheat.Runtime.GodModeConnection then
            Cheat.Runtime.GodModeConnection:Disconnect()
            Cheat.Runtime.GodModeConnection = nil
        end

        local hum = GetHumanoid()
        local char = GetCharacter()

        if hum then
            hum.PlatformStand = false
            hum.Sit = false
            hum.WalkSpeed = 16
        end

        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                    part.CanCollide = true
                elseif part:IsA("Decal") then
                    part.Transparency = 0
                end
            end
        end

        JoyGui.Enabled = false
        ResetJoystick()

        output(
            "✅ Состояния сброшены. Fly НЕ включён.",
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
        StopFly()
        ClearESP()
        RemoveSaitamaEffect()

        for _, conn in pairs(Cheat.Runtime.Connections) do
            pcall(function()
                conn:Disconnect()
            end)
        end

        Cheat.Runtime.Connections = {}

        if Cheat.Runtime.JumpConnection then
            Cheat.Runtime.JumpConnection:Disconnect()
            Cheat.Runtime.JumpConnection = nil
        end

        if Cheat.Runtime.NoclipConnection then
            Cheat.Runtime.NoclipConnection:Disconnect()
            Cheat.Runtime.NoclipConnection = nil
        end

        if Cheat.Runtime.GodModeConnection then
            Cheat.Runtime.GodModeConnection:Disconnect()
            Cheat.Runtime.GodModeConnection = nil
        end

        if Cheat.Runtime.FlyRenderConnection then
            Cheat.Runtime.FlyRenderConnection:Disconnect()
            Cheat.Runtime.FlyRenderConnection = nil
        end

        if Cheat.Runtime.FreezeBV then
            pcall(function()
                Cheat.Runtime.FreezeBV:Destroy()
            end)
            Cheat.Runtime.FreezeBV = nil
        end

        if GUI then
            GUI:Destroy()
            GUI = nil
        end

        if JoyGui then
            JoyGui:Destroy()
        end

        if MobileButton then
            MobileButton:Destroy()
        end

        output("🛑 Скрипт выгружен", Color3.fromRGB(255, 0, 0))
    end
}

-- ======================================================
-- MOBILE OPEN BUTTON
-- ======================================================

local MobileButton = Instance.new("ScreenGui")
MobileButton.Name = "MobileOpenButton"
MobileButton.ResetOnSpawn = false
MobileButton.Parent = PlayerGui

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 60, 0, 60)
OpenBtn.Position = UDim2.new(0.9, 0, 0.05, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
OpenBtn.BorderSizePixel = 2
OpenBtn.BorderColor3 = Color3.fromRGB(255, 215, 0)
OpenBtn.Text = "⚡"
OpenBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
OpenBtn.TextScaled = true
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Parent = MobileButton

-- ======================================================
-- CONSOLE TOGGLE
-- ======================================================

local function ToggleConsole()
    Cheat.Runtime.ConsoleVisible =
        not Cheat.Runtime.ConsoleVisible

    if not GUI or not GUI.Parent then
        CreateConsole()
    end

    GUI.Enabled = Cheat.Runtime.ConsoleVisible

    if Cheat.Runtime.ConsoleVisible and InputBox then
        task.defer(function()
            InputBox:CaptureFocus()
        end)
    end
end

OpenBtn.MouseButton1Click:Connect(ToggleConsole)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.RightShift then
        local now = os.clock()

        if now - LastRightShiftPress < 0.5 then
            RightShiftPressCount += 1

            if RightShiftPressCount >= 2 then
                RightShiftPressCount = 0
                ToggleConsole()
            end
        else
            RightShiftPressCount = 1
        end

        LastRightShiftPress = now
    end
end)

-- ======================================================
-- INITIALIZE
-- ======================================================

CreateConsole()

if GUI then
    GUI.Enabled = false
end

JoyGui.Enabled = false

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "⚡ MAX EDITION",
        Text = "Fly исправлен. После респавна включай fly вручную.",
        Duration = 5
    })
end)

print("✅ MAX EDITION загружена")
print("✅ TouchFling удалён")
print("✅ Fly после респавна выключен и готов к повторному запуску")
