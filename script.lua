-- Загрузка Rayfield
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "❌ ОШИБКА",
        Text = "Инжектор не загрузил Rayfield. Скачай Delta или Xeno!",
        Duration = 10
    })
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local hasDrawing = pcall(function() return Drawing.new("Square") end)

-- Очистка старого мусора
if getgenv()._EspCache then
    for _, v in pairs(getgenv()._EspCache) do
        if v.Box then v.Box:Remove() end
        if v.Text then v.Text:Remove() end
    end
end
getgenv()._EspCache = {}
local espObjects = getgenv()._EspCache
local lootHighlights = {}

-- Настройки
local aimbotEnabled = false
local aimSmoothness = 1
local aimFov = 150
local maxDistance = 5000 
local espPlayers = true
local espLoot = true
local ignoreFriends = true 
local ignoreTeam = true    
local forceSun = true 
local forcedFov = 70 
local noShadows = false -- По умолчанию тени оставляем

-- ==================== НОРМАЛЬНЫЙ ДЕНЬ ====================
local function ApplyLighting()
    if not forceSun then return end
    
    -- Ставим нормальное время и яркость
    Lighting.ClockTime = 14
    Lighting.Brightness = 2
    
    -- Нормальное освещение (не чисто белый, чтобы был объем)
    Lighting.Ambient = Color3.fromRGB(80, 80, 80) 
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    
    -- Вырубаем туман
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    
    -- Тени вкл/выкл по кнопке
    Lighting.GlobalShadows = not noShadows
    
    -- Убираем только мешающую атмосферу, но не трогаем цвета
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("Atmosphere") then
            effect.Density = 0
            effect.Haze = 0
            effect.Glare = 0
        end
    end
end

-- Обновляем свет раз в секунду, чтобы игра не сбрасывала
task.spawn(function()
    while task.wait(1) do
        ApplyLighting()
    end
end)

-- ==================== ОКНО RAYFIELD ====================
local Window = Rayfield:CreateWindow({
    Name = "Decay Hub | Sun & ESP",
    LoadingTitle = "Загрузка...",
    LoadingSubtitle = "by AI",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

-- ==================== ВКЛАДКА: AIMBOT ====================
local TabAim = Window:CreateTab("Aimbot", 4483362458)

TabAim:CreateToggle({
    Name = "Включить Aimbot",
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
local TabEsp = Window:CreateTab("ESP & Wallhack", 4483362458)

TabEsp:CreateSlider({
    Name = "Макс. Дистанция",
    Range = {100, 10000},
    Increment = 100,
    Suffix = "m",
    CurrentValue = 5000,
    Flag = "EspDist",
    Callback = function(v) maxDistance = v end,
})

TabEsp:CreateToggle({
    Name = "ESP Игроков",
    CurrentValue = true,
    Flag = "EspPlr",
    Callback = function(v) 
        espPlayers = v 
        if not v then
            for _, d in pairs(espObjects) do
                if d.Box then d.Box.Visible = false end
                if d.Text then d.Text.Visible = false end
            end
        end
    end,
})

TabEsp:CreateToggle({
    Name = "ESP Лута",
    CurrentValue = true,
    Flag = "EspLoot",
    Callback = function(v) 
        espLoot = v
        if not v then
            for _, hl in pairs(lootHighlights) do hl:Destroy() end
            lootHighlights = {}
        end
    end,
})

-- ==================== ВКЛАДКА: ВИЗУАЛ ====================
local TabVisual = Window:CreateTab("World / Visuals", 4483362458)

TabVisual:CreateToggle({
    Name = "День без тумана",
    CurrentValue = true, 
    Flag = "ForceSun",
    Callback = function(v)
        forceSun = v
        if forceSun then ApplyLighting() end
    end,
})

TabVisual:CreateToggle({
    Name = "Убрать тени (Плоский вид)",
    CurrentValue = false, 
    Flag = "NoShadows",
    Callback = function(v)
        noShadows = v
        ApplyLighting()
    end,
})

TabVisual:CreateSlider({
    Name = "Расширенный FOV (Зум)",
    Range = {70, 120},
    Increment = 1,
    Suffix = "°",
    CurrentValue = 70,
    Flag = "CamFOV",
    Callback = function(v)
        forcedFov = v
        Camera.FieldOfView = forcedFov 
    end,
})

-- ==================== ФУНКЦИИ ДЛЯ ПРОВЕРКИ ====================
local function isFriend(player)
    if not player or player == LocalPlayer then return false end
    local success, result = pcall(function() return LocalPlayer:IsFriendsWith(player.UserId) end)
    return success and result
end

local function isTeammate(player)
    if not player or player == LocalPlayer then return false end
    return player.Team ~= nil and LocalPlayer.Team ~= nil and player.Team == LocalPlayer.Team
end

-- ==================== ГЛАВНЫЙ ЦИКЛ ESP ====================
if hasDrawing then
    local FovCircle = Drawing.new("Circle")
    FovCircle.Visible = true
    FovCircle.Radius = aimFov
    FovCircle.Color = Color3.fromRGB(255, 255, 255)
    FovCircle.Thickness = 1.5
    FovCircle.Filled = false
    FovCircle.Transparency = 0.8

    RunService.RenderStepped:Connect(function()
        -- Блокировка сброса FOV при беге
        if Camera.FieldOfView ~= forcedFov then
            Camera.FieldOfView = forcedFov
        end

        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FovCircle.Position = center
        FovCircle.Radius = aimFov

        local closestTarget = nil
        local minDist = aimFov
        
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
                    espObjects[model] = { Box = box, Text = text }
                end
                local esp = espObjects[model]

                if dist <= maxDistance then
                    local topPos, topOn = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.5, 0))
                    local botPos, botOn = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

                    if (topOn or botOn) and topPos.Z > 0 then
                        if espPlayers then
                            local h = math.abs(topPos.Y - botPos.Y)
                            local w = h / 2
                            h = math.clamp(h, 15, 500)
                            w = math.clamp(w, 8, 250)

                            esp.Box.Size = Vector2.new(w, h)
                            esp.Box.Position = Vector2.new(topPos.X - w/2, topPos.Y)
                            
                            local displayName = player and player.DisplayName or model.Name
                            
                            if isSleeping then
                                esp.Box.Color = Color3.fromRGB(0, 150, 255)
                                esp.Text.Color = Color3.fromRGB(0, 150, 255)
                                esp.Text.Text = displayName .. " [СПИТ] | " .. math.floor(dist) .. "m"
                            else
                                if player and (isFriend(player) or isTeammate(player)) then
                                    esp.Box.Color = Color3.fromRGB(0, 255, 0)
                                else
                                    esp.Box.Color = Color3.fromRGB(255, 0, 0)
                                end
                                esp.Text.Color = Color3.fromRGB(255, 255, 255)
                                esp.Text.Text = displayName .. " | " .. math.floor(humanoid.Health) .. " HP | " .. math.floor(dist) .. "m"
                            end
                            
                            esp.Box.Visible = true
                            esp.Text.Position = Vector2.new(topPos.X, topPos.Y - 20)
                            esp.Text.Visible = true
                        else
                            esp.Box.Visible = false; esp.Text.Visible = false
                        end
                    else
                        esp.Box.Visible = false; esp.Text.Visible = false
                    end
                else
                    esp.Box.Visible = false; esp.Text.Visible = false
                end

                if aimbotEnabled and player and not isSleeping then
                    local skipTarget = false
                    if ignoreFriends and isFriend(player) then skipTarget = true end
                    if ignoreTeam and isTeammate(player) then skipTarget = true end

                    if not skipTarget then
                        local headPos, headOn = Camera:WorldToViewportPoint(head.Position)
                        if headOn and headPos.Z > 0 then
                            local d = (Vector2.new(headPos.X, headPos.Y) - center).Magnitude
                            if d < minDist then
                                minDist = d
                                closestTarget = head
                            end
                        end
                    end
                end
            end
        end
        
        for model, esp in pairs(espObjects) do
            if not model.Parent or not model:FindFirstChild("HumanoidRootPart") then
                esp.Box:Remove()
                esp.Text:Remove()
                espObjects[model] = nil
            end
        end

        if aimbotEnabled and closestTarget then
            local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, closestTarget.Position)
            if aimSmoothness > 1 then
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / (aimSmoothness * 1.5))
            else
                Camera.CFrame = targetCFrame
            end
        end
    end)
end

-- ==================== СКАНЕР ЛУТА ====================
task.spawn(function()
    local lootNames = {"Chest", "Crate", "Loot", "Box", "Airdrop", "Supply", "Container", "Barrel", "Bag", "Backpack", "Safe", "Locker", "Cabinet", "Weapon", "Gun", "Ammo", "Item"}

    while task.wait(1.5) do 
        for obj, hl in pairs(lootHighlights) do
            if not obj.Parent then hl:Destroy(); lootHighlights[obj] = nil end
        end

        local localChar = LocalPlayer.Character
        local localHRP = localChar and localChar:FindFirstChild("HumanoidRootPart")
        if not localHRP then continue end

        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                local name = obj.Name:lower()
                local isLoot = false
                
                local objPos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetBoundingBox().Position) or obj.Position
                if localHRP and objPos and (localHRP.Position - objPos).Magnitude > 5000 then continue end

                for _, kw in ipairs(lootNames) do if name:find(kw) then isLoot = true break end end

                if espLoot and isLoot then
                    if not lootHighlights[obj] then
                        local hl = Instance.new("Highlight")
                        hl.Adornee = obj
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.FillColor = Color3.fromRGB(255, 255, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 165, 0)
                        hl.FillTransparency = 0.6
                        hl.Parent = workspace
                        lootHighlights[obj] = hl
                    end
                end
            end
        end
    end
end)
