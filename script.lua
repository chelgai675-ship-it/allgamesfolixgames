local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if not Drawing then
	warn("Executor của bạn không hỗ trợ thư viện Drawing!")
	return
end

-- Dọn dẹp GUI và Drawing cũ nếu chạy lại script
if PlayerGui:FindFirstChild("UniversalAimbotHub") then PlayerGui.UniversalAimbotHub:Destroy() end
if PlayerGui:FindFirstChild("UniversalFovGui") then PlayerGui.UniversalFovGui:Destroy() end

if getgenv()._EspCache then
	for _, cache in pairs(getgenv()._EspCache) do
		if cache.Box then cache.Box:Remove() end
		if cache.Tracer then cache.Tracer:Remove() end
	end
end
getgenv()._EspCache = {}
local espCache = getgenv()._EspCache
local lootHighlights = {} -- Кэш для хайлайтов сундуков

-- ==================== 1. ТРẠNG THÁI & CÀI ĐẶT ====================
local aimbotEnabled = false
local fovEnabled = true
local espBoxEnabled = true
local espLineEnabled = true
local wallCheckEnabled = true
local teamCheckEnabled = false
local lootEspEnabled = true -- Включаем Loot ESP по умолчанию

local currentFovRadius = 150
local maxAimDistance = 500

-- ==================== 2. ВЬЮХА FOV ====================
local FovCircle = Drawing.new("Circle")
FovCircle.Visible = fovEnabled
FovCircle.Radius = currentFovRadius
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Thickness = 1.5
FovCircle.Filled = false
FovCircle.Transparency = 0.8
FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

RunService.RenderStepped:Connect(function()
	FovCircle.Visible = fovEnabled
	FovCircle.Radius = currentFovRadius
	FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

-- ==================== 3. ИНТЕРФЕЙС ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalAimbotHub"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 420)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 10)
UICornerMain.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local UICornerTitle = Instance.new("UICorner")
UICornerTitle.CornerRadius = UDim.new(0, 10)
UICornerTitle.Parent = TitleBar

local FixTitle = Instance.new("Frame")
FixTitle.Size = UDim2.new(1, 0, 0, 6)
FixTitle.Position = UDim2.new(0, 0, 1, -6)
FixTitle.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
FixTitle.BorderSizePixel = 0
FixTitle.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -50, 1, 0)
TitleText.Position = UDim2.new(0, 12, 0, 0)
TitleText.Text = "Universal Aimbot & Loot ESP"
TitleText.TextColor3 = Color3.fromRGB(240, 240, 240)
TitleText.TextSize = 14
TitleText.Font = Enum.Font.GothamBold
TitleText.BackgroundTransparency = 1
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 26, 0, 26)
MinimizeButton.Position = UDim2.new(1, -32, 0, 5)
MinimizeButton.Text = "-"
MinimizeButton.BackgroundColor3 = Color3.fromRGB(210, 60, 60)
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 16
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = TitleBar

local UICornerMin = Instance.new("UICorner")
UICornerMin.CornerRadius = UDim.new(0, 6)
UICornerMin.Parent = MinimizeButton

local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -50)
Container.Position = UDim2.new(0, 10, 0, 42)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.CanvasSize = UDim2.new(0, 0, 0, 480) -- Увеличено под новые кнопки
Container.ScrollBarThickness = 4
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = Container

local function CreateToggleItem(text, defaultState, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 42)
	btn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
	btn.BorderSizePixel = 0
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = Container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -60, 1, 0)
	label.Position = UDim2.new(0, 12, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.TextSize = 13
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = btn

	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.new(0, 22, 0, 22)
	indicator.Position = UDim2.new(1, -32, 0.5, -11)
	indicator.BackgroundColor3 = defaultState and Color3.fromRGB(50, 205, 50) or Color3.fromRGB(60, 60, 75)
	indicator.BorderSizePixel = 0
	indicator.Parent = btn

	local indCorner = Instance.new("UICorner")
	indCorner.CornerRadius = UDim.new(0, 6)
	indCorner.Parent = indicator

	local state = defaultState
	btn.MouseButton1Click:Connect(function()
		state = not state
		indicator.BackgroundColor3 = state and Color3.fromRGB(50, 205, 50) or Color3.fromRGB(60, 60, 75)
		callback(state)
	end)
end

local function CreateSliderItem(text, min, max, defaultVal, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 56)
	frame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
	frame.BorderSizePixel = 0
	frame.Parent = Container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -24, 0, 25)
	label.Position = UDim2.new(0, 12, 0, 4)
	label.BackgroundTransparency = 1
	label.Text = text .. ": " .. defaultVal
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.TextSize = 13
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local sliderBar = Instance.new("Frame")
	sliderBar.Size = UDim2.new(1, -24, 0, 6)
	sliderBar.Position = UDim2.new(0, 12, 0, 36)
	sliderBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	sliderBar.BorderSizePixel = 0
	sliderBar.Parent = frame

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(1, 0)
	barCorner.Parent = sliderBar

	local sliderFill = Instance.new("Frame")
	sliderFill.Size = UDim2.new((defaultVal - min) / (max - min), 0, 1, 0)
	sliderFill.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
	sliderFill.BorderSizePixel = 0
	sliderFill.Parent = sliderBar

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = sliderFill

	local dragging = false

	sliderBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local mousePos = UserInputService:GetMouseLocation().X
			local barPos = sliderBar.AbsolutePosition.X
			local barSize = sliderBar.AbsoluteSize.X
			local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
			
			local val = math.floor(min + (max - min) * percent)
			sliderFill.Size = UDim2.new(percent, 0, 1, 0)
			label.Text = text .. ": " .. val
			callback(val)
		end
	end)
end

MinimizeButton.MouseButton1Click:Connect(function()
	local menuVisible = MinimizeButton.Text == "-"
	MinimizeButton.Text = menuVisible and "+" or "-"
	Container.Visible = not menuVisible
	MainFrame.Size = menuVisible and UDim2.new(0, 480, 0, 36) or UDim2.new(0, 480, 0, 420)
end)

-- ==================== 4. НАСТРОЙКИ МЕНЮ ====================
CreateToggleItem("Aimbot", false, function(state) aimbotEnabled = state end)
CreateToggleItem("FOV Circle", true, function(state) fovEnabled = state end)
CreateSliderItem("FOV Size", 50, 400, currentFovRadius, function(val) currentFovRadius = val end)
CreateToggleItem("ESP Box", true, function(state) espBoxEnabled = state if not state then for _, data in pairs(espCache) do if data.Box then data.Box.Visible = false end end end end)
CreateToggleItem("ESP Line (Tracer)", true, function(state) espLineEnabled = state if not state then for _, data in pairs(espCache) do if data.Tracer then data.Tracer.Visible = false end end end end)
CreateToggleItem("Wall Check", true, function(state) wallCheckEnabled = state end)
CreateSliderItem("Aim Distance", 100, 2000, maxAimDistance, function(val) maxAimDistance = val end)
CreateToggleItem("Team Check", false, function(state) teamCheckEnabled = state end)
CreateToggleItem("Loot & Chest ESP", true, function(state) 
	lootEspEnabled = state 
	if not state then
		for _, hl in pairs(lootHighlights) do hl:Destroy() end
		lootHighlights = {}
	end
end)

-- ==================== 5. ESP ДЛЯ ИГРОКОВ ====================
local function createEspObjects(player)
	if espCache[player] then return end
	local box = Drawing.new("Square")
	box.Visible = false
	box.Color = Color3.fromRGB(255, 0, 0)
	box.Thickness = 1
	box.Filled = false
	box.Transparency = 0.8

	local tracer = Drawing.new("Line")
	tracer.Visible = false
	tracer.Color = Color3.fromRGB(255, 255, 0)
	tracer.Thickness = 1
	tracer.Transparency = 0.7

	espCache[player] = { Box = box, Tracer = tracer }
end

local function removeEspObjects(player)
	if espCache[player] then
		if espCache[player].Box then espCache[player].Box:Remove() end
		if espCache[player].Tracer then espCache[player].Tracer:Remove() end
		espCache[player] = nil
	end
end

for _, p in ipairs(Players:GetPlayers()) do
	if p ~= LocalPlayer then createEspObjects(p) end
end
Players.PlayerAdded:Connect(createEspObjects)
Players.PlayerRemoving:Connect(removeEspObjects)

-- ==================== 6. ПОИСК ЛУТА И СУНДУКОВ ====================
local LootESP_Update_Interval = 0.5
local lastLootUpdate = 0
local lootNames = {
	"Chest", "Crate", "Loot", "Box", "Airdrop", "Supply", "Container", "Barrel", "Bag"
}

RunService.RenderStepped:Connect(function()
	if not lootEspEnabled then return end
	if tick() - lastLootUpdate < LootESP_Update_Interval then return end
	lastLootUpdate = tick()

	-- Очистка старых хайлайтов
	for _, hl in pairs(lootHighlights) do
		if not hl.Parent or not hl.Adornee or not hl.Adornee.Parent then
			hl:Destroy()
		end
	end

	-- Поиск объектов в Workspace
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart") then
			local name = obj.Name:lower()
			local isLoot = false
			for _, keyword in ipairs(lootNames) do
				if name:find(keyword:lower()) then
					isLoot = true
					break
				end
			end

			if isLoot then
				if not lootHighlights[obj] then
					local hl = Instance.new("Highlight")
					hl.Name = "LootESP_Highlight"
					hl.Adornee = obj
					hl.FillColor = Color3.fromRGB(255, 255, 0) -- Жёлтый цвет для лута
					hl.OutlineColor = Color3.fromRGB(255, 165, 0)
					hl.FillTransparency = 0.6
					hl.OutlineTransparency = 0.2
					hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Видно сквозь стены
					hl.Parent = workspace
					lootHighlights[obj] = hl
				end
			end
		end
	end
end)

-- ==================== 7. AIMBOT ЛОГИКА ====================
local function IsVisible(targetPart)
	if not wallCheckEnabled then return true end
	local localChar = LocalPlayer.Character
	if not localChar then return false end
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {localChar, targetPart.Parent}
	raycastParams.IgnoreWater = true

	local origin = Camera.CFrame.Position
	local direction = (targetPart.Position - origin)
	local result = workspace:Raycast(origin, direction, raycastParams)
	return result == nil
end

local function GetClosestTarget()
	local bestTarget = nil
	local radius = currentFovRadius
	local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	local shortestDist = radius
	local localChar = LocalPlayer.Character
	local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local isTeam = teamCheckEnabled and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team
			if not isTeam then
				local char = player.Character
				local rootPart = char and char:FindFirstChild("HumanoidRootPart")
				local humanoid = char and char:FindFirstChildOfClass("Humanoid")
				local targetPart = char and (char:FindFirstChild("Head") or rootPart)
				
				if humanoid and humanoid.Health > 0 and targetPart and rootPart then
					local distToPlayer = localRoot and (localRoot.Position - rootPart.Position).Magnitude or 0
					if distToPlayer <= maxAimDistance then
						local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
						if screenPoint.Z > 0 then
							local screenPos = Vector2.new(screenPoint.X, screenPoint.Y)
							local dist = (screenPos - screenCenter).Magnitude
							if dist < shortestDist then
								if IsVisible(targetPart) then
									shortestDist = dist
									bestTarget = targetPart
								end
							end
						end
					end
				end
			end
		end
	end
	return bestTarget
end

RunService.RenderStepped:Connect(function()
	local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	local localChar = LocalPlayer.Character
	local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")

	if aimbotEnabled then
		pcall(function()
			local target = GetClosestTarget()
			if target then
				Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
			end
		end)
	end

	pcall(function()
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				local esp = espCache[player]
				local char = player.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				local humanoid = char and char:FindFirstChildOfClass("Humanoid")

				if esp and char and hrp and humanoid and humanoid.Health > 0 then
					local isTeam = teamCheckEnabled and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team
					local distToPlayer = localRoot and (localRoot.Position - hrp.Position).Magnitude or 999

					if distToPlayer > maxAimDistance or isTeam then
						if esp.Box then esp.Box.Visible = false end
						if esp.Tracer then esp.Tracer.Visible = false end
					else
						local topPosition = hrp.Position + Vector3.new(0, 3, 0)
						local bottomPosition = hrp.Position - Vector3.new(0, 3.5, 0)
						
						local topScreen, topVisible = Camera:WorldToViewportPoint(topPosition)
						local bottomScreen, bottomVisible = Camera:WorldToViewportPoint(bottomPosition)

						if (topVisible or bottomVisible) and topScreen.Z > 0 and bottomScreen.Z > 0 then
							local height = math.abs(topScreen.Y - bottomScreen.Y)
							local width = height / 2

							if espBoxEnabled and esp.Box then
								esp.Box.Size = Vector2.new(width, height)
								esp.Box.Position = Vector2.new(topScreen.X - width / 2, topScreen.Y)
								esp.Box.Color = isTeam and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(255, 0, 0)
								esp.Box.Visible = true
							elseif esp.Box then
								esp.Box.Visible = false
							end

							if espLineEnabled and esp.Tracer then
								esp.Tracer.From = Vector2.new(screenCenter.X, Camera.ViewportSize.Y)
								esp.Tracer.To = Vector2.new(bottomScreen.X, bottomScreen.Y)
								esp.Tracer.Visible = true
							elseif esp.Tracer then
								esp.Tracer.Visible = false
							end
						else
							if esp.Box then esp.Box.Visible = false end
							if esp.Tracer then esp.Tracer.Visible = false end
						end
					end
				else
					if esp then
						if esp.Box then esp.Box.Visible = false end
						if esp.Tracer then esp.Tracer.Visible = false end
					end
				end
			end
		end
	end)
end)

print("Aimbot Hub & Optimized Loot ESP Loaded Successfully!")
