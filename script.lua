-- Загрузка Rayfield
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Ошибка",
        Text = "Codex не может загрузить Rayfield. Используй Delta или Xeno!",
        Duration = 10
    })
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
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
local espCache = getgenv()._EspCache
local lootHighlights = {}
local doorTexts = {}

-- Настройки (Дистанция по умолчанию 5000)
local aimbotEnabled = false
local aimSmoothness = 1
local fovSize = 150
local maxDistance = 5000 
local espPlayers = true
local espLoot = true
local espDoors = true

-- ==================== ОКНО RAYFIELD ====================
local Window = Rayfield:CreateWindow({
    Name = "Decay Hub | 5K Distance",
    LoadingTitle = "Загрузка...",
    LoadingSubtitle = "by AI Assistant",
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
    Callback = function(v) fovSize = v end,
})

-- ==================== ВКЛАДКА: ESP ====================
local TabEsp = Window:CreateTab("ESP & Wallhack", 4483362458)

TabEsp:CreateSlider({
    Name = "Макс. Дистанция (ESP)",
    Range = {100, 10000},
    Increment = 100,
    Suffix = "m",
    CurrentValue = 5000, -- СТОИТ 5000
    Flag = "EspDist",
    Callback = function(v) maxDistance = v end,
})

TabEsp:CreateToggle({
    Name = "ESP Игроков (Ники, HP)",
    CurrentValue = true,
    Flag = "EspPlr",
    Callback = function(v) 
        espPlayers = v 
        if not v then
            for _, d in pairs(espCache) do
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

-- ==================== ЛОГИКА ОТРИСОВКИ ====================
if hasDrawing then
    local FovCircle = Drawing.new("Circle")
    FovCircle.Visible = true
    FovCircle.Radius = fovSize
    FovCircle.Color = Color3.fromRGB(255, 255, 255)
    FovCircle.Thickness = 1.5
    FovCircle.Filled = false
    FovCircle.Transparency = 0.8

    local function setupEsp(p)
        if p == LocalPlayer or espCache[p] then return end
        local box = Drawing.new("Square")
        box.Visible = false; box.Color = Color3.fromRGB(255, 0, 0); box.Thickness = 1
        
        local text = Drawing.new("Text")
        text.Visible = false; text.Size = 16; text.Center = true; text.Outline = true; text.Color = Color3.fromRGB(255, 255, 255)
        
        espCache[p] = { Box = box, Text = text }
    end

    for _, p in ipairs(Players:GetPlayers()) do setupEsp(p) end
    Players.PlayerAdded:Connect(setupEsp)

    RunService.RenderStepped:Connect(function()
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        FovCircle.Position = center
        FovCircle.Radius = fovSize

        local closestTarget = nil
        local minDist = fovSize

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local esp = espCache[player]
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local head = char and char:FindFirstChild("Head")
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")

                if esp and char and hrp and head and humanoid and humanoid.Health > 0 then
                    local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                    
                    -- ТУТ ПРОВЕРКА НА 5000 МЕТРОВ
                    if dist <= maxDistance then
                        local topPos, topOn = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
                        local botPos, botOn = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.5, 0))

                        if (topOn or botOn) and topPos.Z > 0 then
                            if espPlayers then
                                local h = math.abs(topPos.Y - botPos.Y)
                                esp.Box.Size = Vector2.new(h / 2, h)
                                esp.Box.Position = Vector2.new(topPos.X - h/4, topPos.Y)
                                esp.Box.Visible = true
                                
                                esp.Text.Text = player.Name .. " | " .. math.floor(humanoid.Health) .. " HP | " .. math.floor(dist) .. "m"
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

                    if aimbotEnabled then
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

-- ==================== СКАНЕР КАРТЫ (ЛУТ И ДВЕРИ НА 5К) ====================
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
                local isLoot, isDoor, isNpc, isDeadPlayer = false, false, false, false
                
                local objPos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetBoundingBox().Position) or obj.Position
                
                -- Сканируем в радиусе 5000
                if localHRP and objPos and (localHRP.Position - objPos).Magnitude > 5000 then continue end

                local plr = Players:GetPlayerFromCharacter(obj)
                local humanoid = obj:FindFirstChildOfClass("Humanoid")
                if plr and humanoid and humanoid.Health <= 0 then isDeadPlayer = true end
                if not plr and humanoid and humanoid.Health > 0 then isNpc = true end

                for _, kw in ipairs(lootNames) do if name:find(kw) then isLoot = true break end end
                for _, kw in ipairs(doorNames) do if name:find(kw) then isDoor = true break end end

                -- ЛУТ
                if espLoot and (isLoot or isDeadPlayer) and not isNpc then
                    if not lootHighlights[obj] then
                        local hl = Instance.new("Highlight")
                        hl.Adornee = obj
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        if isDeadPlayer then
                            hl.FillColor = Color3.fromRGB(255, 0, 0); hl.OutlineColor = Color3.fromRGB(255, 100, 100)
                        else
                            hl.FillColor = Color3.fromRGB(255, 255, 0); hl.OutlineColor = Color3.fromRGB(255, 165, 0)
                        end
                        hl.FillTransparency = 0.6
                        hl.Parent = workspace
                        lootHighlights[obj] = hl
                    end
                end

                -- ДВЕРИ
                if espDoors and isDoor and hasDrawing then
                    local code = nil
                    for _, child in ipairs(obj:GetChildren()) do
                        if child:IsA("StringValue") or child:IsA("IntValue") then
                            if child.Name:lower():find("code") or child.Name:lower():find("pass") then
                                code = tostring(child.Value)
                            end
                        end
                    end
                    for attr, val in pairs(obj:GetAttributes()) do
                        if attr:lower():find("code") or attr:lower():find("pass") then code = tostring(val) end
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
