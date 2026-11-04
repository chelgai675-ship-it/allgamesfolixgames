--- Загрузка Rayfield
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
local charCache = getgenv()._EspCache 
local lootHighlights = {}
local doorTexts = {}

-- Настройки
local aimbotEnabled = false
local aimSmoothness = 1
local aimFov = 150
local maxDistance = 5000 
local espPlayers = true
local espLoot = true
local espDoors = true
local ignoreFriends = true 
local ignoreTeam = true    

-- Сохраняем оригинальные настройки света
local originalBrightness = Lighting.Brightness
local originalFogEnd = Lighting.FogEnd

-- ==================== ОКНО RAYFIELD ====================
local Window = Rayfield:CreateWindow({
    Name = "Decay Hub | Ultimate",
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
    Name = "Размер FOV (Аимбота)",
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
    Name = "ESP Игроков (Вкл. Спящих)",
    CurrentValue = true,
    Flag = "EspPlr",
    Callback = function(v) 
        espPlayers = v 
        if not v then
            for _, d in pairs(charCache) do
                if d.Box then d.Box.Visible = false end
                if d.Text then d.Text.Visible = false end
            end
        end
    end,
})

TabEsp:CreateToggle({
    Name = "ESP Лута и Трупов",
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

TabEsp:CreateToggle({
    Name = "ESP Дверей и Кодов",
    CurrentValue = true,
    Flag = "EspDoor",
    Callback = function(v) 
        espDoors = v
        if not v then
            for _, txt in pairs(doorTexts) do txt:Remove() end
            doorTexts = {}
        end
    end,
})

-- ==================== ВКЛАДКА: ВИЗУАЛ ====================
local TabVisual = Window:CreateTab("World / Visuals", 4483362458)

TabVisual:CreateToggle({
    Name = "Fullbright (Убрать тени)",
    CurrentValue = false,
    Flag = "Fullbright",
    Callback = function(v)
        if v then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 3
        else
            Lighting.Ambient = Color3.fromRGB(0, 0, 0)
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            Lighting.Brightness = originalBrightness
        end
    end,
})

TabVisual:CreateToggle({
    Name = "No Fog (Убрать туман)",
    CurrentValue = false,
    Flag = "NoFog",
    Callback = function(v)
        if v then
            Lighting.FogEnd = 1000000
            Lighting.FogStart = 0
        else
            Lighting.FogEnd = originalFogEnd
            Lighting.FogStart = 0
        end
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
        Camera.FieldOfView = v
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

-- ==================== ЛОГИКА ОТРИСОВКИ ESP ====================
if hasDrawing then
    local FovCircle = Drawing.new("Circle")
    FovCircle.Visible = true
    FovCircle.Radius = aimFov
    FovCircle.Color = Color3.fromRGB(255, 255, 255)
    FovCircle.Thickness = 1.5
    FovCircle.Filled = false
    FovCircle.Transparency = 0.8

    local function setupEsp(model)
        if not model or model == LocalPlayer.Character or charCache[model] then return end
        
        local box = Drawing.new("Square")
        box.Visible = false; box.Thickness = 1; box.Filled = false
        
        local text = Drawing.new("Text")
        text.Visible = false; text.Size = 16; text.Center = true; text.Outline = true
        
        charCache[model] = { Box = box, Text = text }
    end

    local function checkNewModel(child)
        if child:IsA("Model") and child:FindFirstChildOfClass("Humanoid") and child:FindFirstChild("HumanoidRootPart") then
            setupEsp(child)
        end
    end

    for _, obj in ipairs(workspace:GetChildren()) do checkNewModel(obj) end
    workspace.ChildAdded:Connect(function(child)
        task.wait(0.2)
        checkNewModel(child)
    end)

    RunService.RenderStepped:Connect(function()
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        FovCircle.Position = center
        FovCircle.Radius = aimFov

        local closestTarget = nil
        local minDist = aimFov

        for model, esp in pairs(charCache) do
            if not model.Parent then
                if esp.Box then esp.Box:Remove() end
                if esp.Text then esp.Text:Remove() end
                charCache[model] = nil
            else
                local hrp = model:FindFirstChild("HumanoidRootPart")
                local head = model:FindFirstChild("Head")
                local humanoid = model:FindFirstChildOfClass("Humanoid")
                local player = Players:GetPlayerFromCharacter(model)

                if hrp and head and humanoid then
                    local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                    local isSleeping = (player == nil) or model:GetAttribute("Sleeping") or humanoid.Health <= 0
                    
                    if dist <= maxDistance then
                        local topPos, topOn = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.5, 0))
                        local botPos, botOn = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

                        if (topOn or botOn) and topPos.Z > 0 then
                            if espPlayers then
                                -- РЕАЛЬНЫЙ РАЗМЕР БЕЗ ИСКУССТВЕННОГО УВЕЛИЧЕНИЯ
                                local h = math.abs(topPos.Y - botPos.Y)
                                local w = h / 2

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

                    -- АИМБОТ
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

-- ==================== СКАНЕР КАРТЫ ====================
task.spawn(function()
    local lootNames = {"Chest", "Crate", "Loot", "Box", "Airdrop", "Supply", "Container", "Barrel", "Bag", "Backpack", "Safe", "Locker", "Cabinet", "Weapon", "Gun", "Ammo", "Item"}
    local doorNames = {"door", "gate", "fence", "keypad", "lock", "passcode", "code", "barrier", "entrance"}

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
                local isLoot, isDoor = false, false
                
                local objPos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetBoundingBox().Position) or obj.Position
                if localHRP and objPos and (localHRP.Position - objPos).Magnitude > 5000 then continue end

                for _, kw in ipairs(lootNames) do if name:find(kw) then isLoot = true break end end
                for _, kw in ipairs(doorNames) do if name:find(kw) then isDoor = true break end end

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

                if espDoors and isDoor and hasDrawing then
                    local code = nil
                    for _, child in ipairs(obj:GetChildren()) do
                        if child:IsA("StringValue") or child:IsA("IntValue") then
                            if child.Name:lower():find("code") or child.Name:lower():find("pass") then
                                code = tostring(child.Value)
                            end
                        end
                    end
                    if not code then
                        for attr, val in pairs(obj:GetAttributes()) do
                            if attr:lower():find("code") or attr:lower():find("pass") then code = tostring(val) end
                        end
                    end

                    if code then
                        if not doorTexts[obj] then doorTexts[obj] = Drawing.new("Text") end
                        local screenPos, onScreen = Camera:WorldToViewportPoint(objPos + Vector3.new(0, 3, 0))
                        
                        doorTexts[obj].Visible = onScreen
                        if onScreen then
                            doorTexts[obj].Text = "Код: " .. code
                            doorTexts[obj].Position = Vector2.new(screenPos.X, screenPos.Y)
                            doorTexts[obj].Color = Color3.fromRGB(0, 255, 0)
                            doorTexts[obj].Size = 18
                            doorTexts[obj].Outline = true
                        end
                    end
                end
            end
        end
    end
end)
