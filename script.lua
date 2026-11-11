-- Загрузка Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local hasDrawing = pcall(function() return Drawing.new("Square") end)

-- Очистка старого мусора
if getgenv()._EspCache then
    for _, v in pairs(getgenv()._EspCache) do
        if v.Box then v.Box:Remove() end
        if v.Text then v.Text:Remove() end
        if v.HpBg then v.HpBg:Remove() end
        if v.HpFill then v.HpFill:Remove() end
        if v.Highlight then v.Highlight:Destroy() end
    end
end
getgenv()._EspCache = {}
local espObjects = getgenv()._EspCache

-- Настройки
local aimbotEnabled = false
local aimSmoothness = 1
local aimFov = 150
local maxDistance = 10000
local espPlayers = true
local ignoreFriends = true 
local ignoreTeam = true    

local forceNoFog = true
local lockFov = true
local forcedFov = 70

local speedEnabled = false
local speedValue = 16
local infJumpEnabled = false

local thirdPersonEnabled = false
local tpDistance = 12.5

-- Freecam
local freecamEnabled = false
local freecamSpeed = 50
local originalSpeed = 16
local originalJump = 50
local originalCamType = Enum.CameraType.Custom
local originalSubject = nil

-- ==================== ВИЗУАЛ (ТУМАН) ====================
task.spawn(function()
    while task.wait(0.1) do 
        if forceNoFog then
            Lighting.FogEnd = 1000000
            Lighting.FogStart = 0
            for _, effect in ipairs(Lighting:GetChildren()) do
                if effect:IsA("Atmosphere") then
                    effect.Density = 0
                    effect.Haze = 0
                    effect.Glare = 0
                end
            end
        end
    end
end)

-- ==================== ЖЕСТКОЕ ТРЕТЬЕ ЛИЦО ====================
task.spawn(function()
    while task.wait(0.1) do
        if thirdPersonEnabled and not freecamEnabled then
            -- Перебиваем игру каждые 0.1 секунды
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            LocalPlayer.CameraMaxZoomDistance = tpDistance
            LocalPlayer.CameraMinZoomDistance = tpDistance
        end
    end
end)

-- ==================== ОКНО RAYFIELD ====================
local Window = Rayfield:CreateWindow({
    Name = "decay test script /\\extract/",
    LoadingTitle = "Загрузка...",
    LoadingSubtitle = "by AI",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

-- ==================== ВКЛАДКА: AIMBOT ====================
local TabAim = Window:CreateTab("Aimbot", 4483362458)

TabAim:CreateToggle({
    Name = "Включить Aimbot (ПКМ)",
    CurrentValue = false,
    Flag = "AimToggle",
    Callback = function(v) aimbotEnabled = v end,
})

TabAim:CreateToggle({
    Name = "Игнорировать Друзей",
    CurrentValue = true,
    Flag = "IgnoreFriends",
    Callback = function(v) ignoreFriends = v end,
})

TabAim:CreateToggle({
    Name = "Игнорировать Тиммейтов",
    CurrentValue = true,
    Flag = "IgnoreTeam",
    Callback = function(v) ignoreTeam = v end,
})

TabAim:CreateSlider({
    Name = "Плавность",
    Range = {1, 20},
    Increment = 1,
    Suffix = "",
    CurrentValue = 1,
    Flag = "AimSmooth",
    Callback = function(v) aimSmoothness = v end,
})

TabAim:CreateSlider({
    Name = "Размер FOV",
    Range = {50, 600},
    Increment = 10,
    Suffix = " studs",
    CurrentValue = 150,
    Flag = "AimFOV",
    Callback = function(v) aimFov = v end,
})

-- ==================== ВКЛАДКА: ESP ====================
local TabEsp = Window:CreateTab("ESP", 4483362458)

TabEsp:CreateSlider({
    Name = "Макс. Дистанция",
    Range = {100, 15000},
    Increment = 100,
    Suffix = "m",
    CurrentValue = 10000,
    Flag = "EspDist",
    Callback = function(v) maxDistance = v end,
})

TabEsp:CreateToggle({
    Name = "ESP Игроков (Вкл. Спящих)",
    CurrentValue = true,
    Flag = "EspPlr",
    Callback = function(v) 
        espPlayers = v 
        if not v then
            for _, d in pairs(espObjects) do
                if d.Box then d.Box.Visible = false end
                if d.Text then d.Text.Visible = false end
                if d.HpBg then d.HpBg.Visible = false end
                if d.HpFill then d.HpFill.Visible = false end
                if d.Highlight then d.Highlight.Enabled = false end
            end
        end
    end,
})

TabEsp:CreateToggle({
    Name = "Убрать Туман (No Fog)",
    CurrentValue = true, 
    Flag = "ForceNoFog",
    Callback = function(v) forceNoFog = v end,
})

TabEsp:CreateSlider({
    Name = "Расширенный FOV (Зум)",
    Range = {70, 120},
    Increment = 1,
    Suffix = "°",
    CurrentValue = 70,
    Flag = "CamFOV",
    Callback = function(v)
        forcedFov = v
        if lockFov and not freecamEnabled then Camera.FieldOfView = forcedFov end
    end,
})

TabEsp:CreateToggle({
    Name = "Блокировать сброс FOV",
    CurrentValue = true, 
    Flag = "LockFov",
    Callback = function(v) lockFov = v end,
})

-- ==================== ВКЛАДКА: ДВИЖЕНИЕ ====================
local TabMove = Window:CreateTab("Движение", 4483362458)

TabMove:CreateSlider({
    Name = "Скорость (WalkSpeed)",
    Range = {16, 200},
    Increment = 1,
    Suffix = " studs/s",
    CurrentValue = 16,
    Flag = "SpeedValue",
    Callback = function(v) speedValue = v end,
})

TabMove:CreateToggle({
    Name = "Включить скорость",
    CurrentValue = false,
    Flag = "SpeedToggle",
    Callback = function(v)
        speedEnabled = v
        if not v and not freecamEnabled then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end,
})

TabMove:CreateToggle({
    Name = "Бесконечный прыжок (Пробел)",
    CurrentValue = false,
    Flag = "InfJumpToggle",
    Callback = function(v) infJumpEnabled = v end,
})

-- ==================== ВКЛАДКА: КАМЕРА ====================
local TabCam = Window:CreateTab("Камера", 4483362458)

TabCam:CreateToggle({
    Name = "Третье лицо",
    CurrentValue = false,
    Flag = "ThirdPersonToggle",
    Callback = function(v) thirdPersonEnabled = v end,
})

TabCam:CreateSlider({
    Name = "Дистанция 3-го лица",
    Range = {5, 25},
    Increment = 0.5,
    Suffix = " studs",
    CurrentValue = 12.5,
    Flag = "ThirdPersonZoom",
    Callback = function(v) tpDistance = v end,
})

TabCam:CreateLabel("Freecam включается/выключается на клавишу [ B ]")

-- ==================== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ====================
local function isFriend(player)
    if not player or player == LocalPlayer then return false end
    local success, result = pcall(function() return LocalPlayer:IsFriendsWith(player.UserId) end)
    return success and result
end

local function isTeammate(player)
    if not player or player == LocalPlayer then return false end
    return player.Team ~= nil and LocalPlayer.Team ~= nil and player.Team == LocalPlayer.Team
end

-- ==================== FOV КРУГ ====================
local FovCircle = Drawing.new("Circle")
FovCircle.Visible = false
FovCircle.Radius = aimFov
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Thickness = 1.5
FovCircle.Filled = false
FovCircle.Transparency = 0.8

-- ==================== БЕСКОНЕЧНЫЙ ПРЫЖОК (РУЧНОЙ) ====================
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled and not freecamEnabled then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ==================== FREECAM (КЛАВИША B) ====================
local function ToggleFreecam()
    freecamEnabled = not freecamEnabled
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if freecamEnabled then
        -- СОХРАНЯЕМ СТАРЫЕ НАСТРОЙКИ
        originalCamType = Camera.CameraType
        originalSubject = Camera.CameraSubject
        if hum then 
            originalSpeed = hum.WalkSpeed
            originalJump = hum.JumpPower
            hum.WalkSpeed = 0 
            hum.JumpPower = 0
            hum:ChangeState(Enum.HumanoidStateType.Physics) -- Вырубаем анимации
        end
        
        -- ОТВЯЗЫВАЕМ КАМЕРУ
        Camera.CameraType = Enum.CameraType.Scriptable
        Camera.CameraSubject = nil
    else
        -- ВОЗВРАЩАЕМ ВСЕ ОБРАТНО
        Camera.CameraType = originalCamType
        Camera.CameraSubject = originalSubject or (char and char:FindFirstChild("Humanoid"))
        
        if hum then 
            hum.WalkSpeed = speedEnabled and speedValue or originalSpeed
            hum.JumpPower = originalJump
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.B then
        ToggleFreecam()
    end
end)

-- ==================== ГЛАВНЫЙ ЦИКЛ ====================
RunService.RenderStepped:Connect(function(dt)
    -- Блокировка FOV камеры (только если Freecam выключен)
    if lockFov and Camera.FieldOfView ~= forcedFov and not freecamEnabled then
        Camera.FieldOfView = forcedFov
    end

    -- Скорость
    if speedEnabled and not freecamEnabled then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= speedValue then
            hum.WalkSpeed = speedValue
        end
    end

    -- FREECAM (Полет камеры)
    if freecamEnabled then
        -- Принудительно держим камеру отвязанной
        Camera.CameraType = Enum.CameraType.Scriptable
        
        local moveDir = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += Camera.CFrame.RightVector end
        
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end
        
        if moveDir.Magnitude > 0 then
            Camera.CFrame = Camera.CFrame + moveDir.Unit * dt * freecamSpeed
        end
    end

    -- FOV Круг Аимбота
    if hasDrawing then
        FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FovCircle.Radius = aimFov
        FovCircle.Visible = aimbotEnabled
    end

    -- ESP Игроков
    if hasDrawing then
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local validModels = {}
        
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(validModels, p.Character)
            end
        end
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChildOfClass("Humanoid") then
                if not Players:GetPlayerFromCharacter(obj) then
                    table.insert(validModels, obj)
                end
            end
        end

        for _, model in ipairs(validModels) do
            local hrp = model:FindFirstChild("HumanoidRootPart")
            local head = model:FindFirstChild("Head")
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            local player = Players:GetPlayerFromCharacter(model)
            
            if hrp and head and humanoid then
                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                local isSleeping = (player == nil) or model:GetAttribute("Sleeping") or humanoid.Health <= 0
                
                if not espObjects[model] then
                    local box = Drawing.new("Square")
                    box.Visible = false; box.Thickness = 1; box.Filled = false
                    
                    local text = Drawing.new("Text")
                    text.Visible = false; text.Size = 16; text.Center = true; text.Outline = true
                    
                    local hpBg = Drawing.new("Square")
                    hpBg.Visible = false; hpBg.Filled = true; hpBg.Color = Color3.fromRGB(0, 0, 0); hpBg.Thickness = 0
                    
                    local hpFill = Drawing.new("Square")
                    hpFill.Visible = false; hpFill.Filled = true; hpFill.Thickness = 0

                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = model
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillTransparency = 1 
                    highlight.OutlineTransparency = 0
                    highlight.Parent = model
                    
                    espObjects[model] = { Box = box, Text = text, HpBg = hpBg, HpFill = hpFill, Highlight = highlight }
                end
                
                local esp = espObjects[model]

                if dist <= maxDistance and espPlayers then
                    local topPos, topOn = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.5, 0))
                    local botPos, botOn = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

                    if (topOn or botOn) and topPos.Z > 0 then
                        local h = math.clamp(math.abs(topPos.Y - botPos.Y), 15, 600)
                        local w = math.clamp(h / 2, 8, 300)

                        local boxColor = Color3.fromRGB(255, 0, 0)
                        local hpColor = Color3.fromRGB(0, 255, 0)
                        local bodyOutlineColor = Color3.fromRGB(255, 0, 0)
                        
                        if isSleeping then
                            boxColor = Color3.fromRGB(0, 150, 255)
                            hpColor = Color3.fromRGB(0, 150, 255)
                            bodyOutlineColor = Color3.fromRGB(0, 150, 255)
                        elseif player and (isFriend(player) or isTeammate(player)) then
                            boxColor = Color3.fromRGB(0, 255, 0)
                            bodyOutlineColor = Color3.fromRGB(0, 255, 0)
                        end

                        esp.Highlight.Enabled = true
                        esp.Highlight.OutlineColor = bodyOutlineColor

                        esp.Box.Size = Vector2.new(w, h)
                        esp.Box.Position = Vector2.new(topPos.X - w/2, topPos.Y)
                        esp.Box.Color = boxColor
                        esp.Box.Visible = true

                        local hpPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                        local barHeight = 3
                        
                        esp.HpBg.Size = Vector2.new(w, barHeight)
                        esp.HpBg.Position = Vector2.new(topPos.X - w/2, topPos.Y - 8)
                        esp.HpBg.Visible = true

                        esp.HpFill.Size = Vector2.new(w * hpPercent, barHeight)
                        esp.HpFill.Position = Vector2.new(topPos.X - w/2, topPos.Y - 8)
                        esp.HpFill.Color = hpColor
                        esp.HpFill.Visible = true

                        local displayName = player and player.DisplayName or model.Name
                        if isSleeping then
                            esp.Text.Text = displayName .. " [СПИТ] | " .. math.floor(dist) .. "m"
                        else
                            esp.Text.Text = displayName .. " | " .. math.floor(humanoid.Health) .. " HP | " .. math.floor(dist) .. "m"
                        end
                        esp.Text.Color = Color3.fromRGB(255, 255, 255)
                        esp.Text.Position = Vector2.new(topPos.X, topPos.Y - 28)
                        esp.Text.Visible = true

                        if aimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and player and not isSleeping and not freecamEnabled then
                            local skipTarget = false
                            if ignoreFriends and isFriend(player) then skipTarget = true end
                            if ignoreTeam and isTeammate(player) then skipTarget = true end

                            if not skipTarget then
                                local headPos, headOn = Camera:WorldToViewportPoint(head.Position)
                                if headOn and headPos.Z > 0 then
                                    local d = (Vector2.new(headPos.X, headPos.Y) - center).Magnitude
                                    if d < aimFov then
                                        local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, head.Position)
                                        if aimSmoothness > 1 then
                                            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / (aimSmoothness * 1.5))
                                        else
                                            Camera.CFrame = targetCFrame
                                        end
                                    end
                                end
                            end
                        end
                    else
                        esp.Box.Visible = false; esp.Text.Visible = false; esp.HpBg.Visible = false; esp.HpFill.Visible = false; esp.Highlight.Enabled = false
                    end
                else
                    esp.Box.Visible = false; esp.Text.Visible = false; esp.HpBg.Visible = false; esp.HpFill.Visible = false; esp.Highlight.Enabled = false
                end
            end
        end
        
        for model, esp in pairs(espObjects) do
            if not model.Parent or not model:FindFirstChild("HumanoidRootPart") then
                esp.Box:Remove()
                esp.Text:Remove()
                esp.HpBg:Remove()
                esp.HpFill:Remove()
                if esp.Highlight then esp.Highlight:Destroy() end
                espObjects[model] = nil
            end
        end
    end
end)
