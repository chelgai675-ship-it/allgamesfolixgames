-- ======================================================
-- MAX EDITION & DEEPSEEK ALL GAMES
-- ВЕРСИЯ 10/10 (Cheat.Config / Flags / Runtime)
-- ======================================================

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- ======================================================
-- CHEAT (ТРЁХУРОВНЕВАЯ СТРУКТУРА)
-- ======================================================
local Cheat = {
    Config = {
        SpeedValue = 16,
        SpinSpeed = 10,
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
        MM2Aimbot = false,
        MM2AutoShoot = false,
    },

    Runtime = {
        Connections = {},
        ESPTexts = {},
        ESPSmoothed = {},
        ESPHighlights = {},
        FlyBodyVelocity = nil,
        FreezeBV = nil,
        ConsoleVisible = false,
        CommandHistory = {},
        HistoryIndex = 0,
        MM2TargetPart = "HumanoidRootPart",
        MM2MurdererName = nil,
        LastShotTime = 0,
        FlyDirection = Vector3.new(0, 0, 0),
        FlyUpActive = false,
        FlyDownActive = false,
        JumpConnection = nil,
    }
}

-- ======================================================
-- ПЕРЕМЕННЫЕ КОНСОЛИ
-- ======================================================
local LastRightShiftPress = 0
local RightShiftPressCount = 0
local GUI = nil
local InputBox = nil
local OutputScrolling = nil
local Cmds = {}

-- ======================================================
-- ОТКРЫТИЕ ПО ДВОЙНОМУ RIGHT SHIFT
-- ======================================================
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        if not Cmds then return end

        local currentTime = tick()
        if currentTime - LastRightShiftPress < 0.5 then
            RightShiftPressCount = RightShiftPressCount + 1
            if RightShiftPressCount >= 2 then
                RightShiftPressCount = 0
                Cheat.Runtime.ConsoleVisible = not Cheat.Runtime.ConsoleVisible
                if not GUI or not GUI.Parent then
                    CreateConsole()
                end
                if GUI then
                    GUI.Enabled = Cheat.Runtime.ConsoleVisible
                    if Cheat.Runtime.ConsoleVisible and InputBox then
                        task.wait(0.1)
                        InputBox:CaptureFocus()
                    end
                end
            end
        else
            RightShiftPressCount = 1
        end
        LastRightShiftPress = currentTime
    end
end)

-- ======================================================
-- СОХРАНЕНИЕ НАСТРОЕК
-- ======================================================
local SettingsFile = "max_settings.json"

local function SaveSettings()
    local settings = {
        speed = Cheat.Config.SpeedValue,
        esp = Cheat.Flags.ESP,
        fly = Cheat.Flags.Fly,
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
        if ok and settings then
            Cheat.Config.SpeedValue = settings.speed or 16
        end
    end

    -- Всё выключено при старте
    Cheat.Flags.ESP = false
    Cheat.Flags.Fly = false
    Cheat.Flags.Noclip = false
    Cheat.Flags.Saitama = false

    pcall(function()
        delfile(SettingsFile)
    end)
end

LoadSettings()

-- ======================================================
-- ОПРЕДЕЛЯЕМ ТИП УСТРОЙСТВА
-- ======================================================
local IsMobile = UserInputService.TouchEnabled
local IsDesktop = not IsMobile

local IsMM2 = game.PlaceId == 142823291 or game.PlaceId == 742596525 or game.PlaceId == 4257282231

-- ======================================================
-- РАДУГА
-- ======================================================
local function RainbowColor(offset)
    local r = math.sin(offset + 0) * 0.5 + 0.5
    local g = math.sin(offset + 2.094) * 0.5 + 0.5
    local b = math.sin(offset + 4.188) * 0.5 + 0.5
    return Color3.fromRGB(r * 255, g * 255, b * 255)
end

-- ======================================================
-- ЭФФЕКТ САЙТАМЫ
-- ======================================================
local function AddSaitamaEffect(part)
    if not part or not part:IsA("BasePart") then return end

    local attachment0 = Instance.new("Attachment", part)
    attachment0.Name = "SaitamaGlow0"

    local attachment1 = Instance.new("Attachment", part)
    attachment1.Name = "SaitamaGlow1"
    attachment1.Position = Vector3.new(0, 0.5, 0)

    local beam = Instance.new("Beam", part)
    beam.Name = "SaitamaBeam"
    beam.Attachment0 = attachment0
    beam.Attachment1 = attachment1
    beam.Width0 = 0.8
    beam.Width1 = 0.8
    beam.Transparency = NumberSequence.new(0.6)
    beam.Enabled = true

    task.spawn(function()
        while beam and beam.Parent do
            local color = RainbowColor(Cheat.Config.RainbowOffset)
            beam.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, color),
                ColorSequenceKeypoint.new(1, color)
            }
            Cheat.Config.RainbowOffset = Cheat.Config.RainbowOffset + 0.01
            task.wait(0.05)
        end
    end)
end

-- ======================================================
-- ESP (HIGHLIGHT + TEXT)
-- ======================================================
function ClearESP()
    for _, obj in pairs(Cheat.Runtime.ESPTexts) do
        pcall(function() obj:Remove() end)
    end
    Cheat.Runtime.ESPTexts = {}
    Cheat.Runtime.ESPSmoothed = {}

    for _, h in pairs(Cheat.Runtime.ESPHighlights) do
        pcall(function() h:Destroy() end)
    end
    Cheat.Runtime.ESPHighlights = {}
end

function AddESPForPlayer(pl)
    if Cheat.Runtime.ESPTexts[pl] then return end

    local char = pl.Character
    if not char then return end

    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not hum or not root or not head then return end

    local txt = Drawing.new("Text")
    txt.Size = 13
    txt.Center = true
    txt.Outline = true
    txt.OutlineColor = Color3.fromRGB(0, 0, 0)
    txt.Color = Color3.fromRGB(255, 255, 255)
    txt.Visible = false
    Cheat.Runtime.ESPTexts[pl] = txt

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
    highlight.OutlineTransparency = 0.3
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = char
    Cheat.Runtime.ESPHighlights[pl] = highlight

    Cheat.Runtime.ESPSmoothed[pl] = {
        root = root.Position,
        head = head.Position
    }
end

function CreateESP()
    ClearESP()

    for _, pl in pairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer then
            AddESPForPlayer(pl)
        end
    end
end

function UpdateESP()
    for _, pl in pairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character then
            local hum = pl.Character:FindFirstChild("Humanoid")
            local root = pl.Character:FindFirstChild("HumanoidRootPart")
            local head = pl.Character:FindFirstChild("Head")

            if hum and hum.Health > 0 and root and head then
                local txt = Cheat.Runtime.ESPTexts[pl]
                if txt then
                    local sm = Cheat.Runtime.ESPSmoothed[pl]
                    if not sm then
                        sm = {root = root.Position, head = head.Position}
                        Cheat.Runtime.ESPSmoothed[pl] = sm
                    end

                    local alpha = 0.25
                    sm.root = sm.root:Lerp(root.Position, alpha)
                    sm.head = sm.head:Lerp(head.Position, alpha)

                    local rootPos, rootVisible = Camera:WorldToScreenPoint(sm.root)
                    local headPos, headVisible = Camera:WorldToScreenPoint(sm.head)

                    if rootVisible and headVisible then
                        local camDir = Camera.CFrame.LookVector
                        local toTarget = (root.Position - Camera.CFrame.Position).Unit
                        if camDir:Dot(toTarget) > 0 then
                            local dist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and
                                (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude) or 0

                            local posY = math.min(headPos.Y, rootPos.Y) - 20
                            local posX = (headPos.X + rootPos.X) / 2

                            txt.Position = Vector2.new(posX, posY)
                            txt.Text = string.format("%s  [%d HP]  [%d м]", pl.Name, math.floor(hum.Health), math.floor(dist))
                            txt.Color = Color3.fromRGB(255, 255, 255)
                            txt.Visible = true
                        else
                            txt.Visible = false
                        end
                    else
                        txt.Visible = false
                    end
                end
            else
                local txt = Cheat.Runtime.ESPTexts[pl]
                if txt then txt.Visible = false end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if Cheat.Flags.ESP then
        UpdateESP()
    end
end)

Players.PlayerAdded:Connect(function(pl)
    if Cheat.Flags.ESP then
        task.wait(0.5)
        AddESPForPlayer(pl)
    end
end)

Players.PlayerRemoving:Connect(function(pl)
    if Cheat.Runtime.ESPTexts[pl] then
        pcall(function() Cheat.Runtime.ESPTexts[pl]:Remove() end)
        Cheat.Runtime.ESPTexts[pl] = nil
    end
    Cheat.Runtime.ESPSmoothed[pl] = nil

    if Cheat.Runtime.ESPHighlights[pl] then
        pcall(function() Cheat.Runtime.ESPHighlights[pl]:Destroy() end)
        Cheat.Runtime.ESPHighlights[pl] = nil
    end
end)

LocalPlayer.CharacterRemoving:Connect(function()
    if Cheat.Flags.Fly then
        Cheat.Flags.Fly = false
        if Cheat.Runtime.FlyBodyVelocity then
            Cheat.Runtime.FlyBodyVelocity:Destroy()
            Cheat.Runtime.FlyBodyVelocity = nil
        end
    end
    if Cheat.Runtime.FreezeBV then
        Cheat.Runtime.FreezeBV:Destroy()
        Cheat.Runtime.FreezeBV = nil
    end
    ClearESP()
end)

-- ======================================================
-- КОНСОЛЬ
-- ======================================================
function CreateConsole()
    if GUI then pcall(function() GUI:Destroy() end) GUI = nil end

    GUI = Instance.new("ScreenGui")
    GUI.Name = "MaxEditionConsole"
    GUI.ResetOnSpawn = false
    GUI.Parent = LocalPlayer:WaitForChild("PlayerGui") or StarterGui
    GUI.Enabled = Cheat.Runtime.ConsoleVisible

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
    Title.Text = "⚡ MAX EDITION & DEEPSEEK ALL GAMES"
    Title.TextColor3 = Color3.fromRGB(255, 215, 0)
    Title.TextScaled = true
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame

    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, 0, 0, 20)
    InfoLabel.Position = UDim2.new(0, 0, 0, 40)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Text = "🟢 Двойной RightShift - консоль | ESP Highlight"
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
    InputBox.TextScaled = true
    InputBox.Font = Enum.Font.Gotham
    InputBox.PlaceholderText = "Введите команду... (help)"
    InputBox.Parent = MainFrame

    local function AddOutput(text, color)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Position = UDim2.new(0, 0, 0, OutputScrolling.CanvasSize.Y.Offset)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextScaled = true
        label.Font = Enum.Font.Gotham
        label.Parent = OutputScrolling
        OutputScrolling.CanvasSize = UDim2.new(0, 0, 0, OutputScrolling.CanvasSize.Y.Offset + 22)
        OutputScrolling.CanvasPosition = Vector2.new(0, OutputScrolling.CanvasSize.Y.Offset)
    end

    AddOutput("⚡ MAX EDITION & DEEPSEEK | ESP Highlight", Color3.fromRGB(255, 215, 0))

    InputBox.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Up then
            if #Cheat.Runtime.CommandHistory > 0 then
                Cheat.Runtime.HistoryIndex = math.max(1, Cheat.Runtime.HistoryIndex - 1)
                InputBox.Text = Cheat.Runtime.CommandHistory[Cheat.Runtime.HistoryIndex]
                InputBox.CursorPosition = #InputBox.Text
            end
        elseif input.KeyCode == Enum.KeyCode.Down then
            if Cheat.Runtime.HistoryIndex < #Cheat.Runtime.CommandHistory then
                Cheat.Runtime.HistoryIndex = Cheat.Runtime.HistoryIndex + 1
                InputBox.Text = Cheat.Runtime.CommandHistory[Cheat.Runtime.HistoryIndex]
                InputBox.CursorPosition = #InputBox.Text
            else
                Cheat.Runtime.HistoryIndex = #Cheat.Runtime.CommandHistory + 1
                InputBox.Text = ""
            end
        end
    end)

    InputBox.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Tab then
            input.StopPropagation = true
            local text = InputBox.Text
            local match = nil
            for name in pairs(Cmds) do
                if name:sub(1, #text):lower() == text:lower() then
                    match = name
                    break
                end
            end
            if match then
                InputBox.Text = match
                InputBox.CursorPosition = #InputBox.Text
            end
            return
        end
    end)

    InputBox.FocusLost:Connect(function(enterPressed)
        if not enterPressed then return end
        local cmd = InputBox.Text
        InputBox.Text = ""
        if cmd ~= "" then
            AddOutput("> " .. cmd, Color3.fromRGB(200, 200, 255))
            table.insert(Cheat.Runtime.CommandHistory, cmd)
            if #Cheat.Runtime.CommandHistory > 100 then
                table.remove(Cheat.Runtime.CommandHistory, 1)
            end
            Cheat.Runtime.HistoryIndex = #Cheat.Runtime.CommandHistory + 1
            ExecuteCommand(cmd, AddOutput)
        end
    end)

    return MainFrame
end

function ExecuteCommand(cmd, output)
    local parts = {}
    for word in cmd:gmatch("%S+") do
        table.insert(parts, word)
    end
    if #parts == 0 then return end
    local name = parts[1]:lower()
    table.remove(parts, 1)
    local args = parts

    if Cmds[name] then
        Cmds[name].run(args, output)
    else
        output("⚠️ Неизвестная команда. Используйте help", Color3.fromRGB(255, 255, 0))
    end
end

-- ======================================================
-- ВСЕ КОМАНДЫ
-- ======================================================
Cmds.help = {
    desc = "Показать все команды",
    run = function(args, output)
        output("===== ДОСТУПНЫЕ КОМАНДЫ =====", Color3.fromRGB(255, 215, 0))
        local commands = {
            "help", "fly", "speed", "noclip", "fakeheal", "goto", "esp", "saitama",
            "antiafk", "autoclick", "spin", "sit", "jump", "tpall",
            "freeze", "time", "weather", "reset", "unload"
        }
        if IsMM2 then
            table.insert(commands, "mm2aimbot")
            table.insert(commands, "mm2autoshoot")
            table.insert(commands, "mm2target")
        end
        for _, name in pairs(commands) do
            if Cmds[name] then
                output(name .. " - " .. Cmds[name].desc, Color3.fromRGB(200, 200, 255))
            end
        end
        output("===== КОНЕЦ СПИСКА =====", Color3.fromRGB(255, 215, 0))
    end
}

-- ======================================================
-- ANTI-AFK
-- ======================================================
Cmds.antiafk = {
    desc = "Защита от AFK",
    run = function(args, output)
        Cheat.Flags.AntiAFK = not Cheat.Flags.AntiAFK
        if Cheat.Flags.AntiAFK then
            task.spawn(function()
                while Cheat.Flags.AntiAFK do
                    LocalPlayer:Move(Vector3.new(0, 0, 0))
                    task.wait(30)
                end
            end)
            output("🛡️ Anti-AFK ВКЛЮЧЕН", Color3.fromRGB(0, 255, 0))
        else
            output("🛡️ Anti-AFK ВЫКЛЮЧЕН", Color3.fromRGB(255, 0, 0))
        end
    end
}

-- ======================================================
-- AUTO CLICK
-- ======================================================
Cmds.autoclick = {
    desc = "Авто-кликер",
    run = function(args, output)
        Cheat.Flags.AutoClick = not Cheat.Flags.AutoClick
        if Cheat.Flags.AutoClick then
            task.spawn(function()
                while Cheat.Flags.AutoClick do
                    pcall(function()
                        game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.01)
                        game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end)
                    pcall(function()
                        mouse1click()
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

-- ======================================================
-- SPIN
-- ======================================================
local function startSpin()
    if Cheat.Flags.Spin then return end
    Cheat.Flags.Spin = true
    task.spawn(function()
        while Cheat.Flags.Spin do
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(Cheat.Config.SpinSpeed), 0)
            end
            task.wait(0.05)
        end
    end)
end

Cmds.spin = {
    desc = "Включить/выключить вращение (spin или spin [скорость])",
    run = function(args, output)
        local speed = tonumber(args[1])
        if speed then
            Cheat.Config.SpinSpeed = speed
            output("🔄 Скорость вращения: " .. speed, Color3.fromRGB(0, 255, 0))
            if not Cheat.Flags.Spin then
                startSpin()
            end
        else
            Cheat.Flags.Spin = not Cheat.Flags.Spin
            if Cheat.Flags.Spin then
                startSpin()
                output("🔄 Вращение ВКЛЮЧЕНО", Color3.fromRGB(0, 255, 0))
            else
                output("🔄 Вращение ВЫКЛЮЧЕНО", Color3.fromRGB(255, 0, 0))
            end
        end
    end
}

-- ======================================================
-- SIT
-- ======================================================
Cmds.sit = {
    desc = "Сесть",
    run = function(args, output)
        Cheat.Flags.Sit = not Cheat.Flags.Sit
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum.Sit = Cheat.Flags.Sit
                output("🪑 " .. (Cheat.Flags.Sit and "Сел" or "Встал"), Color3.fromRGB(0, 255, 0))
            end
        end
    end
}

-- ======================================================
-- JUMP (JumpRequest + ChangeState)
-- ======================================================
Cmds.jump = {
    desc = "Включить/выключить бесконечный прыжок",
    run = function(args, output)
        Cheat.Flags.InfiniteJump = not Cheat.Flags.InfiniteJump

        if Cheat.Flags.InfiniteJump then
            Cheat.Runtime.JumpConnection = UserInputService.JumpRequest:Connect(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChild("Humanoid")
                if hum and not hum.PlatformStand then
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

-- ======================================================
-- TPALL
-- ======================================================
Cmds.tpall = {
    desc = "Телепортировать всех к себе",
    run = function(args, output)
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            output("⚠️ Вы не в игре", Color3.fromRGB(255, 255, 0))
            return
        end
        local pos = char.HumanoidRootPart.Position
        local count = 0
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                count = count + 1
            end
        end
        if count > 0 then
            output("📍 Телепортировано: " .. count, Color3.fromRGB(0, 255, 0))
        else
            output("⚠️ Некого телепортировать", Color3.fromRGB(255, 255, 0))
        end
    end
}

-- ======================================================
-- FREEZE
-- ======================================================
Cmds.freeze = {
    desc = "Заморозить/разморозить себя",
    run = function(args, output)
        Cheat.Flags.Freeze = not Cheat.Flags.Freeze
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                if Cheat.Flags.Freeze then
                    local bv = Instance.new("BodyVelocity")
                    bv.MaxForce = Vector3.new(1, 1, 1) * 100000
                    bv.Velocity = Vector3.new(0, 0, 0)
                    bv.Parent = root
                    Cheat.Runtime.FreezeBV = bv
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then
                        hum.PlatformStand = true
                    end
                    output("🧊 Вы заморожены", Color3.fromRGB(0, 255, 0))
                else
                    if Cheat.Runtime.FreezeBV then
                        Cheat.Runtime.FreezeBV:Destroy()
                        Cheat.Runtime.FreezeBV = nil
                    end
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then
                        hum.PlatformStand = false
                        hum.Sit = false
                    end
                    output("🧊 Вы разморожены", Color3.fromRGB(0, 255, 0))
                end
            end
        end
    end
}

-- ======================================================
-- TIME
-- ======================================================
Cmds.time = {
    desc = "Установить время (time [0-23])",
    run = function(args, output)
        local hour = tonumber(args[1])
        if not hour then
            output("⚠️ Использование: time [0-23]", Color3.fromRGB(255, 255, 0))
            return
        end
        Lighting:SetMinutesAfterMidnight(hour * 60)
        output("🕐 Время: " .. hour .. ":00", Color3.fromRGB(0, 255, 0))
    end
}

-- ======================================================
-- WEATHER
-- ======================================================
Cmds.weather = {
    desc = "Сменить погоду (weather [rain/sun/snow])",
    run = function(args, output)
        local type = args[1]
        if not type then
            output("⚠️ Использование: weather [rain/sun/snow]", Color3.fromRGB(255, 255, 0))
            return
        end
        if type == "rain" then
            Lighting.Rain = 1
            output("🌧️ Дождь", Color3.fromRGB(0, 255, 0))
        elseif type == "sun" then
            Lighting.Rain = 0
            output("☀️ Солнечно", Color3.fromRGB(0, 255, 0))
        elseif type == "snow" then
            Lighting.Snow = 1
            output("❄️ Снег", Color3.fromRGB(0, 255, 0))
        else
            output("⚠️ Неизвестный тип", Color3.fromRGB(255, 255, 0))
        end
    end
}

-- ======================================================
-- RESET
-- ======================================================
Cmds.reset = {
    desc = "Перезапустить скрипт",
    run = function(args, output)
        output("🔄 Перезапуск...", Color3.fromRGB(255, 255, 0))
        task.wait(0.5)
        if GUI then
            pcall(function() GUI:Destroy() end)
            GUI = nil
        end
        ClearESP()
        JoyGui.Enabled = false
        Cheat.Flags.Fly = false
        Cheat.Flags.Noclip = false
        Cheat.Flags.ESP = false
        Cheat.Flags.Saitama = false
        CreateConsole()
        if GUI then GUI.Enabled = false end
        output("✅ Скрипт перезапущен", Color3.fromRGB(0, 255, 0))
    end
}

-- ======================================================
-- UNLOAD (ЧИСТАЯ ВЫГРУЗКА)
-- ======================================================
Cmds.unload = {
    desc = "Выключить скрипт и очистить память",
    run = function(args, output)
        -- Отключаем все соединения
        for _, connection in pairs(Cheat.Runtime.Connections) do
            pcall(function() connection:Disconnect() end)
        end
        Cheat.Runtime.Connections = {}

        -- Отключаем JumpConnection
        if Cheat.Runtime.JumpConnection then
            Cheat.Runtime.JumpConnection:Disconnect()
            Cheat.Runtime.JumpConnection = nil
        end

        -- Удаляем GUI
        if GUI then
            GUI:Destroy()
            GUI = nil
        end

        -- Очищаем ESP
        ClearESP()

        -- Сбрасываем физику
        if Cheat.Runtime.FlyBodyVelocity then
            Cheat.Runtime.FlyBodyVelocity:Destroy()
            Cheat.Runtime.FlyBodyVelocity = nil
        end
        if Cheat.Runtime.FreezeBV then
            Cheat.Runtime.FreezeBV:Destroy()
            Cheat.Runtime.FreezeBV = nil
        end

        output("🛑 Скрипт полностью выгружен из памяти", Color3.fromRGB(255, 0, 0))
    end
}

-- ======================================================
-- ОСНОВНЫЕ КОМАНДЫ
-- ======================================================
Cmds.fly = {
    desc = "Включить/выключить полет",
    run = function(args, output)
        Cheat.Flags.Fly = not Cheat.Flags.Fly
        if Cheat.Flags.Fly then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then hum.PlatformStand = true end
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    if Cheat.Runtime.FlyBodyVelocity then Cheat.Runtime.FlyBodyVelocity:Destroy() end
                    Cheat.Runtime.FlyBodyVelocity = Instance.new("BodyVelocity")
                    Cheat.Runtime.FlyBodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 100000
                    Cheat.Runtime.FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    Cheat.Runtime.FlyBodyVelocity.Parent = root
                end
                if IsMobile then JoyGui.Enabled = true end
                output("✈️ Полет ВКЛЮЧЕН", Color3.fromRGB(0, 255, 0))
            end
        else
            if Cheat.Runtime.FlyBodyVelocity then
                Cheat.Runtime.FlyBodyVelocity:Destroy()
                Cheat.Runtime.FlyBodyVelocity = nil
            end
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then hum.PlatformStand = false end
            end
            if IsMobile then JoyGui.Enabled = false end
            output("✈️ Полет ВЫКЛЮЧЕН", Color3.fromRGB(255, 0, 0))
        end
        SaveSettings()
    end
}

Cmds.speed = {
    desc = "Установить скорость (speed число)",
    run = function(args, output)
        local val = tonumber(args[1])
        if not val then
            output("⚠️ Использование: speed [число]", Color3.fromRGB(255, 255, 0))
            return
        end
        Cheat.Config.SpeedValue = val
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum.WalkSpeed = val
                output("⚡ Скорость: " .. val, Color3.fromRGB(0, 255, 0))
            end
        end
        SaveSettings()
    end
}

Cmds.noclip = {
    desc = "Включить/выключить noclip",
    run = function(args, output)
        Cheat.Flags.Noclip = not Cheat.Flags.Noclip
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = not Cheat.Flags.Noclip
                end
            end
        end
        output("🌀 Noclip " .. (Cheat.Flags.Noclip and "ВКЛЮЧЕН" or "ВЫКЛЮЧЕН"), Color3.fromRGB(0, 255, 0))
        SaveSettings()
    end
}

RunService.RenderStepped:Connect(function()
    if Cheat.Flags.Noclip then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide == true then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- ======================================================
-- FAKEHEAL (ЧЕСТНОЕ ПРЕДУПРЕЖДЕНИЕ)
-- ======================================================
Cmds.fakeheal = {
    desc = "Включить/выключить авто-хил (НЕ бессмертие!)",
    run = function(args, output)
        Cheat.Flags.GodMode = not Cheat.Flags.GodMode

        if Cheat.Flags.GodMode then
            task.spawn(function()
                while Cheat.Flags.GodMode do
                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChild("Humanoid")
                    if hum and hum.Health < hum.MaxHealth then
                        hum.Health = hum.MaxHealth
                    end
                    task.wait(0.05)
                end
            end)
            output("🩸 Авто-хил ВКЛЮЧЕН (клиентский, не защищает от сервера)", Color3.fromRGB(0, 255, 0))
        else
            output("🩸 Авто-хил ВЫКЛЮЧЕН", Color3.fromRGB(255, 0, 0))
        end
    end
}

Cmds.goto = {
    desc = "Телепорт к игроку (goto имя)",
    run = function(args, output)
        local name = args[1]
        if not name then
            output("⚠️ Использование: goto [имя]", Color3.fromRGB(255, 255, 0))
            return
        end
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            output("⚠️ Вы не в игре", Color3.fromRGB(255, 255, 0))
            return
        end
        for _, player in pairs(Players:GetPlayers()) do
            if string.lower(player.Name):find(string.lower(name)) then
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
                    output("📍 Телепорт к " .. player.Name, Color3.fromRGB(0, 255, 0))
                    return
                end
            end
        end
        output("⚠️ Игрок не найден", Color3.fromRGB(255, 255, 0))
    end
}

Cmds.esp = {
    desc = "Включить/выключить ESP (Highlight + текст)",
    run = function(args, output)
        Cheat.Flags.ESP = not Cheat.Flags.ESP
        if Cheat.Flags.ESP then
            output("📦 ESP ВКЛЮЧЕН", Color3.fromRGB(0, 255, 0))
            CreateESP()
        else
            output("📦 ESP ВЫКЛЮЧЕН", Color3.fromRGB(255, 0, 0))
            ClearESP()
        end
        SaveSettings()
    end
}

Cmds.saitama = {
    desc = "Включить/выключить эффект Сайтамы",
    run = function(args, output)
        Cheat.Flags.Saitama = not Cheat.Flags.Saitama
        if Cheat.Flags.Saitama then
            output("🔥 Сайтама ВКЛЮЧЕН", Color3.fromRGB(255, 215, 0))
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        AddSaitamaEffect(part)
                    end
                end
            end
        else
            output("🔥 Сайтама ВЫКЛЮЧЕН", Color3.fromRGB(255, 0, 0))
            local char = LocalPlayer.Character
            if char then
                for _, beam in pairs(char:GetDescendants()) do
                    if beam.Name == "SaitamaBeam" then
                        beam:Destroy()
                    end
                end
            end
        end
        SaveSettings()
    end
}

-- ======================================================
-- ДЖОЙСТИК (МОБИЛА)
-- ======================================================
local JoyGui = Instance.new("ScreenGui")
JoyGui.Name = "FlyJoystick"
JoyGui.ResetOnSpawn = false
JoyGui.Parent = LocalPlayer:WaitForChild("PlayerGui") or StarterGui
JoyGui.Enabled = false

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

local JoyLabel = Instance.new("TextLabel")
JoyLabel.Size = UDim2.new(1, 0, 0, 20)
JoyLabel.Position = UDim2.new(0, 0, 0, 120)
JoyLabel.BackgroundTransparency = 1
JoyLabel.Text = "FLY"
JoyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
JoyLabel.TextScaled = true
JoyLabel.Font = Enum.Font.GothamBold
JoyLabel.Parent = JoyFrame

local JoyActive = false

local function ResetJoystick()
    JoyActive = false
    JoyStick.Position = UDim2.new(0.5, -20, 0.5, -20)
    Cheat.Runtime.FlyDirection = Vector3.new(0, 0, 0)
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

UserInputService.TouchEnded:Connect(function()
    if JoyActive then
        ResetJoystick()
    end
end)

JoyFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and JoyActive then
        local delta = input.Position - JoyFrame.AbsolutePosition - JoyFrame.AbsoluteSize / 2
        local maxDist = 40
        local dist = delta.Magnitude
        if dist > maxDist then
            delta = delta.Unit * maxDist
        end
        JoyStick.Position = UDim2.new(0.5, delta.X - 20, 0.5, delta.Y - 20)
        Cheat.Runtime.FlyDirection = Vector3.new(delta.X / maxDist, 0, -delta.Y / maxDist)
    end
end)

local FlyUpBtn = Instance.new("TextButton")
FlyUpBtn.Size = UDim2.new(0, 50, 0, 50)
FlyUpBtn.Position = UDim2.new(0.85, 0, 0.7, 0)
FlyUpBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
FlyUpBtn.BorderSizePixel = 2
FlyUpBtn.BorderColor3 = Color3.fromRGB(100, 255, 100)
FlyUpBtn.Text = "⬆"
FlyUpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyUpBtn.TextScaled = true
FlyUpBtn.Font = Enum.Font.GothamBold
FlyUpBtn.Parent = JoyGui

local FlyDownBtn = Instance.new("TextButton")
FlyDownBtn.Size = UDim2.new(0, 50, 0, 50)
FlyDownBtn.Position = UDim2.new(0.85, 0, 0.82, 0)
FlyDownBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
FlyDownBtn.BorderSizePixel = 2
FlyDownBtn.BorderColor3 = Color3.fromRGB(255, 100, 100)
FlyDownBtn.Text = "⬇"
FlyDownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyDownBtn.TextScaled = true
FlyDownBtn.Font = Enum.Font.GothamBold
FlyDownBtn.Parent = JoyGui

local function SetupFlyButton(btn, varName)
    btn.MouseButton1Down:Connect(function() Cheat.Runtime[varName] = true end)
    btn.MouseButton1Up:Connect(function() Cheat.Runtime[varName] = false end)
end

SetupFlyButton(FlyUpBtn, "FlyUpActive")
SetupFlyButton(FlyDownBtn, "FlyDownActive")

RunService.RenderStepped:Connect(function()
    if Cheat.Flags.Fly and Cheat.Runtime.FlyBodyVelocity then
        local speed = 70
        local vel = Vector3.new(0, 0, 0)
        local look = Camera.CFrame.LookVector
        local right = Camera.CFrame.RightVector
        local up = Camera.CFrame.UpVector

        if IsDesktop then
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + look * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - look * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - right * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + right * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + up * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel = vel - up * speed end
        end

        if IsMobile then
            vel = vel + right * Cheat.Runtime.FlyDirection.X * speed
            vel = vel + look * Cheat.Runtime.FlyDirection.Z * speed
            if Cheat.Runtime.FlyUpActive then vel = vel + up * speed end
            if Cheat.Runtime.FlyDownActive then vel = vel - up * speed end
        end

        Cheat.Runtime.FlyBodyVelocity.Velocity = vel
    end
end)

-- ======================================================
-- ЗАПУСК
-- ======================================================
CreateConsole()
if GUI then GUI.Enabled = false end
JoyGui.Enabled = false

StarterGui:SetCore("SendNotification", {
    Title = "⚡ MAX EDITION & DEEPSEEK",
    Text = "Двойной RightShift - консоль | ESP Highlight",
    Duration = 5
})

print("✅ MAX EDITION & DEEPSEEK загружена | ESP Highlight")
