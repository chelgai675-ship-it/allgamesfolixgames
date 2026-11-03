max denis admin V2.6.2 — Fully Fixed Edition
    Все исправления из аудита V2.6.1:
    #1  fly → fly 20 меняет скорость без перезапуска
    #2  noclip не перезаписывает исходный CanCollide
    #3  invisible не перезаписывает исходную Transparency
    #4  god сохраняет исходный MaxHealth/Health
    #5  freeze сохраняет исходный WalkSpeed/PlatformStand
    #6  superjump сохраняет исходный JumpPower
    #7  wallhack/xray — единый режим мира
    #8  ESP обновляет Adornee при респавне цели
    #9  добавлена команда unorbit
    #10 исправлены emotes (не врут)
    #11 car — Base и Seat соединены WeldConstraint
    #12 serverhop не выбирает текущий сервер
    #13 material/part/mesh — регистронезависимо
    #14 kick/ban — честно сообщают про client-side
    #15 message — pcall, без deprecated ChatColor
    #16 view/spy — можно сменить цель без выключения
    #17 autoclick — проверка VirtualInputManager
    #18 camerashake — единый коннект
    #19 freeze переживает респавн цели
    #20 ReapplyEffects восстанавливает spinbot
    #21 sitdown/standup работают напрямую с Player
    #22 добавлены unsize/unheadsize
    #23 nofall сохраняет исходное FallingDown
    #24-26 косметика
]]

local Players            = game:GetService("Players")
local Player             = Players.LocalPlayer
local UserInputService   = game:GetService("UserInputService")
local RunService         = game:GetService("RunService")
local CoreGui            = game:GetService("CoreGui")
local Camera             = workspace.CurrentCamera
local Lighting           = game:GetService("Lighting")
local ChatService        = game:GetService("Chat")
local SoundService       = game:GetService("SoundService")
local Debris             = game:GetService("Debris")
local HttpService        = game:GetService("HttpService")

local TargetGuiParent = pcall(function() return CoreGui.Name end) and CoreGui or Player:WaitForChild("PlayerGui")
if TargetGuiParent:FindFirstChild("maxdenisadmin") then
    TargetGuiParent.maxdenisadmin:Destroy()
end

local Theme = {
    Background = Color3.fromRGB(15, 15, 15),
    Panel      = Color3.fromRGB(22, 22, 22),
    PanelLight = Color3.fromRGB(35, 35, 35),
    Border     = Color3.fromRGB(100, 100, 100),
    Text       = Color3.fromRGB(255, 255, 255),
    TextGray   = Color3.fromRGB(170, 170, 170),
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "maxdenisadmin"
ScreenGui.Parent = TargetGuiParent
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function CreateFrame(parent, size, position, bgColor, cornerRadius, transparency)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundColor3 = bgColor or Theme.Panel
    frame.BackgroundTransparency = transparency or 0
    frame.Size = size
    frame.Position = position
    frame.BorderSizePixel = 0
    if cornerRadius then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, cornerRadius)
        corner.Parent = frame
    end
    return frame
end

-- ===================== УВЕДОМЛЕНИЯ =====================
local NotificationsContainer = CreateFrame(ScreenGui, UDim2.new(0, 320, 0, 400), UDim2.new(1, -20, 1, -20), Color3.new(), 0, 1)
NotificationsContainer.AnchorPoint = Vector2.new(1, 1)
local UIList = Instance.new("UIListLayout", NotificationsContainer)
UIList.VerticalAlignment   = Enum.VerticalAlignment.Bottom
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Right
UIList.SortOrder           = Enum.SortOrder.LayoutOrder
UIList.Padding             = UDim.new(0, 8)

local notificationCounter = 0
local function AddNotification(title, message, duration)
    notificationCounter += 1
    local notif = CreateFrame(NotificationsContainer, UDim2.new(0, 300, 0, 80), UDim2.new(0, 0, 0, 0), Theme.Panel, 6, 0.1)
    notif.LayoutOrder = notificationCounter
    local stroke = Instance.new("UIStroke", notif)
    stroke.Color = Theme.Border
    stroke.Transparency = 0.5

    local titleLbl = Instance.new("TextLabel", notif)
    titleLbl.Text = title
    titleLbl.Position = UDim2.new(0, 15, 0, 10)
    titleLbl.Size = UDim2.new(1, -20, 0, 20)
    titleLbl.BackgroundTransparency = 1
    titleLbl.TextColor3 = Theme.Text
    titleLbl.TextSize = 12
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local msgLbl = Instance.new("TextLabel", notif)
    msgLbl.Text = message
    msgLbl.Position = UDim2.new(0, 15, 0, 30)
    msgLbl.Size = UDim2.new(1, -20, 0, 40)
    msgLbl.BackgroundTransparency = 1
    msgLbl.TextColor3 = Theme.TextGray
    msgLbl.TextSize = 11
    msgLbl.Font = Enum.Font.Gotham
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.TextYAlignment = Enum.TextYAlignment.Top
    msgLbl.TextWrapped = true

    if duration then
        task.delay(duration, function()
            if notif and notif.Parent then notif:Destroy() end
        end)
    end
end

-- ===================== ИНТЕРФЕЙС КОМАНД =====================
local CmdUIContainer = CreateFrame(ScreenGui, UDim2.new(0, 500, 0, 300), UDim2.new(0.5, -250, 0.5, -150), Color3.new(), 0, 1)
CmdUIContainer.Visible = false
CmdUIContainer.ZIndex = 50

local SuggestionsFrame = CreateFrame(CmdUIContainer, UDim2.new(1, 0, 1, -45), UDim2.new(0, 0, 0, 0), Color3.new(), 0, 1)
local SuggestionsLayout = Instance.new("UIListLayout", SuggestionsFrame)
SuggestionsLayout.VerticalAlignment   = Enum.VerticalAlignment.Bottom
SuggestionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SuggestionsLayout.SortOrder           = Enum.SortOrder.LayoutOrder
SuggestionsLayout.Padding             = UDim.new(0, 4)

local MainBar = CreateFrame(CmdUIContainer, UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 1, -40), Theme.Background, 6, 0.1)
local MainBarStroke = Instance.new("UIStroke", MainBar)
MainBarStroke.Color = Theme.Border
MainBarStroke.Transparency = 0.3

local PromptIcon = Instance.new("TextLabel", MainBar)
PromptIcon.Text = ">"
PromptIcon.Size = UDim2.new(0, 30, 1, 0)
PromptIcon.Position = UDim2.new(0, 10, 0, 0)
PromptIcon.BackgroundTransparency = 1
PromptIcon.TextColor3 = Theme.Text
PromptIcon.TextSize = 14
PromptIcon.Font = Enum.Font.GothamBold

local UmbrellaIcon = Instance.new("TextLabel", MainBar)
UmbrellaIcon.Text = "☂"
UmbrellaIcon.Size = UDim2.new(0, 20, 1, 0)
UmbrellaIcon.Position = UDim2.new(0, 30, 0, 0)
UmbrellaIcon.BackgroundTransparency = 1
UmbrellaIcon.TextColor3 = Color3.fromRGB(255, 80, 80)
UmbrellaIcon.TextSize = 14
UmbrellaIcon.Font = Enum.Font.GothamBold

local CmdInput = Instance.new("TextBox", MainBar)
CmdInput.Size = UDim2.new(1, -220, 1, 0)
CmdInput.Position = UDim2.new(0, 55, 0, 0)
CmdInput.BackgroundTransparency = 1
CmdInput.Text = ""
CmdInput.PlaceholderText = "max denis admin V2.6.2 — type 'commands'"
CmdInput.TextColor3 = Theme.Text
CmdInput.PlaceholderColor3 = Theme.TextGray
CmdInput.TextSize = 13
CmdInput.Font = Enum.Font.Gotham
CmdInput.TextXAlignment = Enum.TextXAlignment.Left
CmdInput.ClearTextOnFocus = false

local function CreateBarButton(parent, text, size, pos)
    local btn = Instance.new("TextButton", parent)
    btn.Size = size
    btn.Position = pos
    btn.BackgroundColor3 = Theme.PanelLight
    btn.BackgroundTransparency = 0.2
    btn.Text = text
    btn.TextColor3 = Theme.Text
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Theme.Border
    stroke.Transparency = 0.5
    return btn
end

local TabBtn   = CreateBarButton(MainBar, "TAB AUTOFILL", UDim2.new(0, 90, 0, 24), UDim2.new(1, -160, 0.5, -12))
local EnterBtn = CreateBarButton(MainBar, "ENTER",        UDim2.new(0, 60, 0, 24), UDim2.new(1, -65,  0.5, -12))

-- ===================== СПИСОК КОМАНД =====================
local AllCommands = {
    "fly", "unfly", "speed", "unspeed", "esp", "unesp", "f3x", "re",
    "noclip", "unnoclip", "goto", "god", "ungod", "infjump", "uninfjump",
    "view", "unview", "invisible", "visible", "freeze", "unfreeze",
    "spy", "unspy", "loopkill", "unloopkill", "loopfling", "unloopfling",
    "tp", "antiafk", "unantiafk", "bring", "kill", "explode", "fling",
    "sit", "unsit", "jail", "unjail", "mute", "unmute", "tools", "sword",
    "remove", "music", "stopmusic", "notify", "hint", "message", "clone",
    "kick", "ban", "size", "unsize", "headsize", "unheadsize",
    "health", "jumppower", "hipheight", "walkspeed", "maxhealth",
    "gravity", "time", "fog", "skybox",
    "transparency", "color", "material", "reflectance",
    "killaura", "unkillaura", "spinbot", "unspinbot",
    "aimbot", "unaimbot", "autofarm", "unautofarm",
    "wallhack", "unwallhack", "xray", "unxray",
    "nofall", "unnofall", "superjump", "unsuperjump",
    "bhop", "unbhop", "autoclick", "unautoclick",
    "fov", "resetcamera", "thirdperson", "firstperson",
    "camerashake", "zoom", "unzoom",
    "shake", "flash", "smoke", "fire", "lightning",
    "part", "mesh", "npc", "car", "teleport", "join", "serverhop",
    "rejoin", "leave", "savepos", "loadpos", "printpos",
    "serverinfo", "ping", "fps",
    "give", "hat", "face", "shirt", "pants", "animation",
    "emote", "dance", "wave", "point", "smile", "laugh", "cry", "angry", "sleep",
    "sitdown", "standup", "lookat", "unlookat", "stare",
    "follow", "unfollow", "orbit", "unorbit", "waypoint", "navigate",
    "commands", "settings",
    -- Nameless Admin LARP
    "unload", "pluginmaker", "addallplugins", "addplugin", "reloadplugin",
    "removeplugin", "removeallplugins", "cmdbar2", "url", "loadstring",
    "nocooldown", "unnocooldown", "waitcap", "unwaitcap", "notween", "unnotween",
    "gcsearch", "autopatchtool", "unautopatchtool", "tailsway", "scriptlogger",
    "tas", "scriptload", "shaders", "unshaders", "ibtools", "unibtools",
    "setfflag", "addalias", "removealias", "clearaliases", "addbutton",
    "removebutton", "clearbuttons", "addautoexec", "removeautoexec", "clearautoexec",
    "executor", "lastcommand", "ifundone", "commandloop", "stoploop", "scripthub",
    "gamescripts", "uiscale", "prefix", "saveprefix", "chatlogs",
    "gotocampos", "teleportgui", "imagescanner", "audiologger", "serverremotespy",
    "cig", "cigar", "pipe", "discord", "clickfling", "unclickfling", "offset",
    "upsidedown", "unoffset", "unupsidedown", "clickscare", "unclickscare",
    "hovername", "unhovername", "hoverinventory", "unhoverinventory", "resetfilter",
    "fpsping", "stats", "speedometer", "closespeedometer",
    "commandkeybinds", "inspectoutfit", "avatarpreview",
    "char", "unchar", "clearavatarpreview", "waypoints", "binders", "showwaypoints",
    "hidewaypoints", "showpathwaypoint", "hidepathwaypoint", "pathfindwaypoint",
    "looppath", "looptweenpath", "loopteleportpath", "loopwalkpath", "unlooppath",
    "looppathtweenspeed", "looppathteleportdelay", "setwaypoint", "setwaypointpos",
    "gotowaypoint", "removewaypoint", "chardebug", "unchardebug", "naked",
    "somersault", "unsomersault", "rolewatch", "rolewatchstop", "rolewatchleave",
    "joingroup", "trackstaff", "stoptrackstaff", "antistaff", "unantistaff",
    "rewind", "unrewind", "rewindspeed", "rewindtime", "freemouse", "hideacc",
    "backview", "worldmodelfp", "frontview", "deletevelocity", "screenorientation",
    "sensorrotationscreen", "landscaperotationscreen",
}

local LarpOnlyCommands = {
    unload=true, pluginmaker=true, addallplugins=true, addplugin=true, reloadplugin=true,
    removeplugin=true, removeallplugins=true, cmdbar2=true, url=true, loadstring=true,
    nocooldown=true, unnocooldown=true, waitcap=true, unwaitcap=true, notween=true, unnotween=true,
    gcsearch=true, autopatchtool=true, unautopatchtool=true, tailsway=true, scriptlogger=true,
    tas=true, scriptload=true, shaders=true, unshaders=true, ibtools=true, unibtools=true,
    setfflag=true, addalias=true, removealias=true, clearaliases=true, addbutton=true,
    removebutton=true, clearbuttons=true, addautoexec=true, removeautoexec=true, clearautoexec=true,
    executor=true, lastcommand=true, ifundone=true, commandloop=true, stoploop=true, scripthub=true,
    gamescripts=true, uiscale=true, prefix=true, saveprefix=true, chatlogs=true,
    gotocampos=true, teleportgui=true, imagescanner=true, audiologger=true, serverremotespy=true,
    cig=true, cigar=true, pipe=true, discord=true, clickfling=true, unclickfling=true, offset=true,
    upsidedown=true, unoffset=true, unupsidedown=true, clickscare=true, unclickscare=true,
    hovername=true, unhovername=true, hoverinventory=true, unhoverinventory=true, resetfilter=true,
    fpsping=true, stats=true, speedometer=true, closespeedometer=true,
    commandkeybinds=true, inspectoutfit=true, avatarpreview=true,
    char=true, unchar=true, clearavatarpreview=true, waypoints=true, binders=true, showwaypoints=true,
    hidewaypoints=true, showpathwaypoint=true, hidepathwaypoint=true, pathfindwaypoint=true,
    looppath=true, looptweenpath=true, loopteleportpath=true, loopwalkpath=true, unlooppath=true,
    looppathtweenspeed=true, looppathteleportdelay=true, setwaypoint=true, setwaypointpos=true,
    gotowaypoint=true, removewaypoint=true, chardebug=true, unchardebug=true, naked=true,
    somersault=true, unsomersault=true, rolewatch=true, rolewatchstop=true, rolewatchleave=true,
    joingroup=true, trackstaff=true, stoptrackstaff=true, antistaff=true, unantistaff=true,
    rewind=true, unrewind=true, rewindspeed=true, rewindtime=true, freemouse=true, hideacc=true,
    backview=true, worldmodelfp=true, frontview=true, deletevelocity=true, screenorientation=true,
    sensorrotationscreen=true, landscaperotationscreen=true,
    give=true, hat=true, face=true, shirt=true, pants=true,
}

local function UpdateSuggestions()
    for _, child in ipairs(SuggestionsFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    local input = CmdInput.Text:lower()
    local count, topMatch = 0, nil
    for _, cmd in ipairs(AllCommands) do
        if input == "" or string.find(cmd, input, 1, true) then
            count += 1
            if count <= 5 then
                if count == 1 then topMatch = cmd end
                local sugFrame = CreateFrame(SuggestionsFrame, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), Theme.Background, 6, 0.1)
                local sugStroke = Instance.new("UIStroke", sugFrame)
                sugStroke.Color = Theme.Border
                sugStroke.Transparency = 0.3
                local sugText = Instance.new("TextLabel", sugFrame)
                sugText.Size = UDim2.new(1, -20, 1, 0)
                sugText.Position = UDim2.new(0, 10, 0, 0)
                sugText.BackgroundTransparency = 1
                sugText.Text = cmd .. (LarpOnlyCommands[cmd] and "  [larp]" or "")
                sugText.TextColor3 = LarpOnlyCommands[cmd] and Color3.fromRGB(120,120,120) or Theme.TextGray
                sugText.TextSize = 12
                sugText.Font = Enum.Font.Gotham
                sugText.TextXAlignment = Enum.TextXAlignment.Left
            end
        end
    end
    return topMatch
end

CmdInput:GetPropertyChangedSignal("Text"):Connect(UpdateSuggestions)
TabBtn.MouseButton1Click:Connect(function()
    local match = UpdateSuggestions()
    if match then
        CmdInput.Text = match .. " "
        CmdInput:CaptureFocus()
        CmdInput.CursorPosition = #CmdInput.Text + 1
    end
end)

-- ===================== LARP FALLBACK =====================
local function LarpRun(cmd, args)
    local msg
    if cmd:find("plugin") then
        msg = "Plugin '" .. (args ~= "" and args or cmd) .. "' loaded."
    elseif cmd:find("script") or cmd:find("loadstring") or cmd:find("executor") then
        msg = "Script '" .. (args ~= "" and args or cmd) .. "' injected."
    elseif cmd:find("^un") then
        msg = "Toggled " .. cmd .. " off."
    elseif cmd:find("scanner") or cmd:find("logger") or cmd:find("spy") then
        msg = cmd .. " started."
    else
        msg = "Command '" .. cmd .. "' executed successfully."
    end
    AddNotification("max denis admin", msg .. " [larp]", 2)
end

-- ===================== ПАРСЕР =====================
local function ParseCommand(cmdStr)
    local parts = {}
    for part in cmdStr:gmatch("%S+") do table.insert(parts, part) end
    if #parts == 0 then return nil end
    local main = parts[1]:lower()
    local raw = {}
    for i = 2, #parts do table.insert(raw, parts[i]) end
    return {
        main  = main,
        parts = parts,
        raw   = raw,
        arg   = raw[1],
        rest  = raw[2],
        rest2 = raw[3],
        rest3 = raw[4],
        tail  = table.concat(raw, " "),
    }
end

-- ===================== СОСТОЯНИЕ =====================
local Effects = {
    flyEnabled=false, flySpeed=50, flyConnections={},
    noclipEnabled=false, noclipConnection=nil,
    godEnabled=false,
    infjumpEnabled=false, infjumpConnection=nil,
    viewingPlayer=nil, viewConnection=nil,
    invisibleEnabled=false,
    frozenPlayers={},
    spyPlayer=nil, spyConnection=nil,
    loopkillEnabled=false, loopkillConnection=nil,
    loopflingEnabled=false, loopflingConnection=nil,
    antiafkEnabled=false, antiafkConnection=nil,
    musicSound=nil,
    mutedPlayers={},
    jailedPlayers={},
    killauraEnabled=false, killauraConnection=nil,
    spinbotEnabled=false, spinbotConnection=nil,
    aimbotEnabled=false, aimbotConnection=nil,
    autofarmEnabled=false, autofarmConnection=nil,
    wallhackEnabled=false,
    xrayEnabled=false,
    nofallEnabled=false,
    superjumpEnabled=false,
    bhopEnabled=false, bhopConnection=nil,
    autoclickEnabled=false, autoclickConnection=nil,
    espEnabled=false,
    followPlayer=nil, followConnection=nil,
    orbitPlayer=nil, orbitConnection=nil,
    lookAtPlayer=nil, lookAtConnection=nil,
    savedPosition=nil,
    fovOriginal = Camera.FieldOfView or 70,
}

-- Исходные состояния
local NoclipState        = {}
local InvisibleState     = {}
local OrigTransparency   = {}
local OrigColor          = {}
local OrigMaterial       = {}
local OrigReflectance    = {}
local OriginalSizes      = {}
local OriginalHeadSize   = {}
local OriginalLTM        = {}
local OriginalGod        = nil
local OriginalJumpPower  = nil
local OriginalFallingDown = nil
local WorldRenderConn    = nil
local shakeConnection    = nil

-- ===================== ХЕЛПЕРЫ =====================
local function FindPlayer(partialName)
    if not partialName or partialName == "" then return nil end
    partialName = partialName:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if string.find(p.Name:lower(), partialName, 1, true)
        or string.find(p.DisplayName:lower(), partialName, 1, true) then
            return p
        end
    end
    return nil
end

local function FindMaterialEnum(name)
    if not name then return nil end
    local lower = name:lower()
    for _, m in ipairs(Enum.Material:GetEnumItems()) do
        if m.Name:lower() == lower then return m end
    end
    return nil
end
local function FindPartTypeEnum(name)
    if not name then return nil end
    local lower = name:lower()
    for _, m in ipairs(Enum.PartType:GetEnumItems()) do
        if m.Name:lower() == lower then return m end
    end
    return nil
end
local function FindMeshTypeEnum(name)
    if not name then return nil end
    local lower = name:lower()
    for _, m in ipairs(Enum.MeshType:GetEnumItems()) do
        if m.Name:lower() == lower then return m end
    end
    return nil
end

-- ===================== 1. SPEED =====================
local activeSpeed = nil
local function SetSpeed(val)
    local targetSpeed = tonumber(val)
    if not targetSpeed then AddNotification("Speed", "Invalid speed value", 2) return end
    activeSpeed = targetSpeed
    local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = targetSpeed
        AddNotification("Speed", "Speed set to: " .. targetSpeed, 2)
    else
        AddNotification("Speed", "Character not found, will apply on respawn", 2)
    end
end

-- ===================== 2. FLY (fix #1) =====================
local function StartFly(speed)
    -- Всегда обновляем скорость, даже если fly уже включён
    if speed and tonumber(speed) then
        Effects.flySpeed = tonumber(speed)
    end

    if Effects.flyEnabled then
        AddNotification("Fly", "Speed updated: " .. Effects.flySpeed, 2)
        return
    end

    local char = Player.Character
    if not char then return end
    local targetPart = char:FindFirstChild("HumanoidRootPart")
    local humanoid   = char:FindFirstChild("Humanoid")
    local seat       = humanoid and humanoid.SeatPart
    if seat and seat:IsA("VehicleSeat") then targetPart = seat.Parent.PrimaryPart or seat end
    if not targetPart then return end
    if humanoid then humanoid.PlatformStand = true end

    local bg = Instance.new("BodyGyro")
    bg.Name = "mdFlyGyro"
    bg.P = 9e4
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame = targetPart.CFrame
    bg.Parent = targetPart

    local bv = Instance.new("BodyVelocity")
    bv.Name = "mdFlyVel"
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = targetPart

    local ctrl = {F=0, B=0, L=0, R=0, U=0, D=0}
    local ib = UserInputService.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == Enum.KeyCode.W then ctrl.F = 1
        elseif i.KeyCode == Enum.KeyCode.S then ctrl.B = 1
        elseif i.KeyCode == Enum.KeyCode.A then ctrl.L = 1
        elseif i.KeyCode == Enum.KeyCode.D then ctrl.R = 1
        elseif i.KeyCode == Enum.KeyCode.Space then ctrl.U = 1
        elseif i.KeyCode == Enum.KeyCode.LeftShift then ctrl.D = 1 end
    end)
    local ie = UserInputService.InputEnded:Connect(function(i)
        if i.KeyCode == Enum.KeyCode.W then ctrl.F = 0
        elseif i.KeyCode == Enum.KeyCode.S then ctrl.B = 0
        elseif i.KeyCode == Enum.KeyCode.A then ctrl.L = 0
        elseif i.KeyCode == Enum.KeyCode.D then ctrl.R = 0
        elseif i.KeyCode == Enum.KeyCode.Space then ctrl.U = 0
        elseif i.KeyCode == Enum.KeyCode.LeftShift then ctrl.D = 0 end
    end)
    local rs = RunService.RenderStepped:Connect(function()
        if not Effects.flyEnabled then return end
        if not bg.Parent or not bv.Parent then return end
        bg.CFrame = Camera.CFrame
        local moveDir = (Camera.CFrame.LookVector  * (ctrl.F - ctrl.B))
                      + (Camera.CFrame.RightVector * (ctrl.R - ctrl.L))
                      + (Vector3.new(0, 1, 0)      * (ctrl.U - ctrl.D))
        if moveDir.Magnitude > 0 then
            bv.Velocity = moveDir.Unit * Effects.flySpeed
        else
            bv.Velocity = Vector3.new(0, 0, 0)
        end
    end)
    Effects.flyEnabled = true
    Effects.flyConnections = {ib, ie, rs}
    AddNotification("Fly", seat and "Car Fly Enabled" or ("Fly Enabled (speed " .. Effects.flySpeed .. ")"), 2)
end

local function StopFly()
    if not Effects.flyEnabled then return end
    local char = Player.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local bv = root:FindFirstChild("mdFlyVel");  if bv then bv:Destroy() end
            local bg = root:FindFirstChild("mdFlyGyro"); if bg then bg:Destroy() end
        end
        local seat = humanoid and humanoid.SeatPart
        if seat and seat.Parent then
            for _, p in ipairs(seat.Parent:GetDescendants()) do
                if p:IsA("BodyVelocity") or p:IsA("BodyGyro") then p:Destroy() end
            end
        end
    end
    for _, conn in ipairs(Effects.flyConnections) do
        if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
    end
    Effects.flyConnections = {}
    Effects.flyEnabled = false
    AddNotification("Fly", "Fly Disabled", 2)
end

-- ===================== 3. NOCLIP (fix #2) =====================
local function SaveNoclipState(char)
    NoclipState = {}
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            NoclipState[part] = part.CanCollide
        end
    end
end

local function RestoreNoclipState()
    for part, value in pairs(NoclipState) do
        if part and part.Parent then part.CanCollide = value end
    end
    NoclipState = {}
end

local function ToggleNoclip(state)
    local wasEnabled = Effects.noclipEnabled
    Effects.noclipEnabled = state

    if Effects.noclipConnection then
        Effects.noclipConnection:Disconnect()
        Effects.noclipConnection = nil
    end

    if state then
        if not wasEnabled then
            local char = Player.Character
            if char then SaveNoclipState(char) end
        end
        Effects.noclipConnection = RunService.Stepped:Connect(function()
            local c = Player.Character
            if c then
                for _, part in ipairs(c:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        RestoreNoclipState()
    end
    AddNotification("Noclip", state and "Noclip Enabled" or "Noclip Disabled", 2)
end

-- ===================== 4. GOTO =====================
local function GotoPlayer(name)
    local target = FindPlayer(name)
    if not target then AddNotification("Goto", "Player not found", 2) return end
    local myChar, targetChar = Player.Character, target.Character
    if not myChar or not targetChar then AddNotification("Goto", "Character not found", 2) return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local tRoot  = targetChar:FindFirstChild("HumanoidRootPart")
    if myRoot and tRoot then myRoot.CFrame = tRoot.CFrame + Vector3.new(0, 3, 0) end
    AddNotification("Goto", "Teleported to " .. target.Name, 2)
end

-- ===================== 5. GOD (fix #4) =====================
local function ToggleGod(state)
    local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
    if humanoid then
        if state then
            if not Effects.godEnabled then
                OriginalGod = { MaxHealth = humanoid.MaxHealth, Health = humanoid.Health }
            end
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
        else
            if OriginalGod then
                humanoid.MaxHealth = OriginalGod.MaxHealth
                humanoid.Health = math.min(OriginalGod.Health, OriginalGod.MaxHealth)
                OriginalGod = nil
            end
        end
    end
    Effects.godEnabled = state
    AddNotification("God Mode", state and "Enabled" or "Disabled", 2)
end

-- ===================== 6. INFJUMP =====================
local function ToggleInfJump(state)
    Effects.infjumpEnabled = state
    if Effects.infjumpConnection then
        Effects.infjumpConnection:Disconnect()
        Effects.infjumpConnection = nil
    end
    if state then
        Effects.infjumpConnection = UserInputService.JumpRequest:Connect(function()
            local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
            if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
    AddNotification("Infinite Jump", state and "Enabled" or "Disabled", 2)
end

-- ===================== 7. VIEW (fix #16) =====================
local function DisableView()
    if Effects.viewConnection then
        Effects.viewConnection:Disconnect(); Effects.viewConnection = nil
    end
    Camera.CameraSubject = Player.Character and Player.Character:FindFirstChild("Humanoid") or nil
    Effects.viewingPlayer = nil
end

local function ToggleView(name)
    -- Если уже смотрим — попытка переключить или выключить
    if Effects.viewingPlayer then
        if not name or name == "" then
            DisableView()
            AddNotification("View", "Camera view restored", 2)
            return
        end
        local target = FindPlayer(name)
        if target == Effects.viewingPlayer then
            DisableView()
            AddNotification("View", "Camera view restored", 2)
            return
        end
        DisableView()
    end

    if not name or name == "" then return end

    local target = FindPlayer(name)
    if not target then AddNotification("View", "Player not found", 2) return end
    if not target.Character then AddNotification("View", "Target character not found", 2) return end
    Camera.CameraSubject = target.Character
    Effects.viewingPlayer = target
    Effects.viewConnection = target.CharacterRemoving:Connect(function()
        if Effects.viewingPlayer == target then DisableView() end
    end)
    AddNotification("View", "Now viewing " .. target.Name, 2)
end

-- ===================== 8. INVISIBLE (fix #3) =====================
local function ToggleInvisible(state)
    local wasEnabled = Effects.invisibleEnabled
    Effects.invisibleEnabled = state
    local char = Player.Character
    if not char then return end

    if state then
        if not wasEnabled then
            InvisibleState = {}
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    InvisibleState[part] = part.Transparency
                end
            end
        end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.Transparency = 1 end
        end
    else
        for part, value in pairs(InvisibleState) do
            if part and part.Parent then part.Transparency = value end
        end
        InvisibleState = {}
    end
    AddNotification("Invisible", state and "You are now invisible" or "You are now visible", 2)
end

-- ===================== 9. FREEZE (fix #5, #19) =====================
local function ToggleFreeze(name, state)
    local target = FindPlayer(name)
    if not target then AddNotification("Freeze", "Player not found", 2) return end
    local humanoid = target.Character and target.Character:FindFirstChild("Humanoid")
    if not humanoid then return end

    if state then
        if not Effects.frozenPlayers[target] then
            Effects.frozenPlayers[target] = {
                WalkSpeed = humanoid.WalkSpeed,
                PlatformStand = humanoid.PlatformStand,
                Humanoid = humanoid,
            }
            humanoid.PlatformStand = true
            humanoid.WalkSpeed = 0
            -- переживаем респавн цели
            local conn = target.CharacterAdded:Connect(function(newChar)
                if not Effects.frozenPlayers[target] then return end
                task.wait(0.5)
                local newHum = newChar:FindFirstChild("Humanoid")
                if newHum then
                    newHum.PlatformStand = true
                    newHum.WalkSpeed = 0
                    Effects.frozenPlayers[target].Humanoid = newHum
                end
            end)
            Effects.frozenPlayers[target].RespawnConn = conn
            AddNotification("Freeze", "Frozen " .. target.Name, 2)
        end
    else
        local saved = Effects.frozenPlayers[target]
        if saved then
            if saved.RespawnConn then saved.RespawnConn:Disconnect() end
            if saved.Humanoid and saved.Humanoid.Parent then
                saved.Humanoid.PlatformStand = saved.PlatformStand
                saved.Humanoid.WalkSpeed = saved.WalkSpeed
            end
            Effects.frozenPlayers[target] = nil
            AddNotification("Freeze", "Unfrozen " .. target.Name, 2)
        end
    end
end

-- ===================== 10. SPY (fix #16) =====================
local function DisableSpy()
    if Effects.spyConnection then
        Effects.spyConnection:Disconnect(); Effects.spyConnection = nil
    end
    Effects.spyPlayer = nil
end

local function ToggleSpy(name)
    if Effects.spyPlayer then
        if not name or name == "" then
            DisableSpy()
            AddNotification("Spy", "Spy disabled", 2)
            return
        end
        local target = FindPlayer(name)
        if target == Effects.spyPlayer then
            DisableSpy()
            AddNotification("Spy", "Spy disabled", 2)
            return
        end
        DisableSpy()
    end

    if not name or name == "" then return end

    local target = FindPlayer(name)
    if not target then AddNotification("Spy", "Player not found", 2) return end
    Effects.spyPlayer = target
    Effects.spyConnection = target.Chatted:Connect(function(message)
        AddNotification("Spy: " .. target.Name, message, 3)
    end)
    AddNotification("Spy", "Now spying on " .. target.Name, 2)
end

-- ===================== 11. LOOPKILL =====================
local function ToggleLoopKill(state)
    Effects.loopkillEnabled = state
    if Effects.loopkillConnection then Effects.loopkillConnection:Disconnect(); Effects.loopkillConnection = nil end
    if state then
        Effects.loopkillConnection = RunService.Heartbeat:Connect(function()
            if Effects.loopkillEnabled and Player.Character then Player.Character:BreakJoints() end
        end)
    end
    AddNotification("Loop Kill", state and "Enabled" or "Disabled", 2)
end

-- ===================== 12. LOOPFLING =====================
local function ToggleLoopFling(state)
    Effects.loopflingEnabled = state
    if Effects.loopflingConnection then Effects.loopflingConnection:Disconnect(); Effects.loopflingConnection = nil end
    if state then
        Effects.loopflingConnection = RunService.Heartbeat:Connect(function()
            if Effects.loopflingEnabled and Player.Character then
                local root = Player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.Velocity    = Vector3.new(math.random(-500,500), math.random(100,500), math.random(-500,500))
                    root.RotVelocity = Vector3.new(math.random(-50,50),  math.random(-50,50),  math.random(-50,50))
                end
            end
        end)
    end
    AddNotification("Loop Fling", state and "Enabled" or "Disabled", 2)
end

-- ===================== 13. TP =====================
local function TeleportToCoords(x, y, z)
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    root.CFrame = CFrame.new(tonumber(x) or 0, tonumber(y) or 0, tonumber(z) or 0)
    AddNotification("TP", "Teleported", 2)
end

-- ===================== 14. ANTIAFK =====================
local function ToggleAntiAFK(state)
    Effects.antiafkEnabled = state
    if Effects.antiafkConnection then Effects.antiafkConnection:Disconnect(); Effects.antiafkConnection = nil end
    if state then
        Effects.antiafkConnection = RunService.Heartbeat:Connect(function()
            if Effects.antiafkEnabled and Player.Character then
                local root = Player.Character:FindFirstChild("HumanoidRootPart")
                if root then root.Velocity = root.Velocity + Vector3.new(0.1, 0, 0.1) end
            end
        end)
    end
    AddNotification("Anti AFK", state and "Enabled" or "Disabled", 2)
end

-- ===================== 15. ESP (fix #8) =====================
local espLoop
local espFolder       = Instance.new("Folder"); espFolder.Name = "mdESP_Folder"; espFolder.Parent = ScreenGui
local espHighlights   = {}
local espLabels       = {}

local function ClearESP()
    if espLoop then espLoop:Disconnect(); espLoop = nil end
    espFolder:ClearAllChildren()
    for _, hl in pairs(espHighlights) do if hl then hl:Destroy() end end
    espHighlights = {}
    espLabels = {}
end

local function ToggleESP(state)
    ClearESP()
    Effects.espEnabled = state
    if not state then AddNotification("ESP", "ESP Disabled", 2) return end

    espLoop = RunService.RenderStepped:Connect(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Player then
                local char = p.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                local head = char and char:FindFirstChild("Head")
                if char and hrp and head and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    local color = p.Team and p.Team.TeamColor.Color or Color3.fromRGB(255, 60, 60)
                    local shielded = char:FindFirstChildOfClass("ForceField") ~= nil
                    if shielded then color = Color3.fromRGB(255, 255, 255) end

                    -- Пересоздаём Highlight если он от другой модели или отсутствует
                    if not espHighlights[p] or espHighlights[p].Adornee ~= char then
                        if espHighlights[p] then espHighlights[p]:Destroy() end
                        local hl = Instance.new("Highlight")
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = TargetGuiParent
                        hl.Adornee = char
                        espHighlights[p] = hl
                    end
                    espHighlights[p].FillColor = color
                    espHighlights[p].OutlineColor = shielded and Color3.fromRGB(0,255,255) or Color3.fromRGB(255,255,255)

                    if not espLabels[p] then
                        local bgui = Instance.new("BillboardGui")
                        bgui.Adornee = head
                        bgui.Size = UDim2.new(0, 200, 0, 50)
                        bgui.StudsOffset = Vector3.new(0, 2, 0)
                        bgui.AlwaysOnTop = true
                        bgui.Parent = espFolder
                        local txt = Instance.new("TextLabel", bgui)
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.BackgroundTransparency = 1
                        txt.Font = Enum.Font.GothamBold
                        txt.TextSize = 11
                        txt.TextStrokeTransparency = 0.2
                        txt.RichText = true
                        espLabels[p] = {Gui = bgui, Label = txt}
                    else
                        espLabels[p].Gui.Adornee = head
                    end

                    local myHrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                    local distance = myHrp and math.floor((myHrp.Position - hrp.Position).Magnitude) or 0
                    local hex = string.format("#%02X%02X%02X", math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255))
                    espLabels[p].Label.Text = string.format(
                        "<font color='%s'>%s\n[%s]\n%dm</font>%s",
                        hex, p.DisplayName, p.Team and p.Team.Name or "No Team", distance,
                        shielded and "\n<font color='#00FFFF'>[SHIELD]</font>" or ""
                    )
                else
                    if espHighlights[p] then espHighlights[p]:Destroy(); espHighlights[p] = nil end
                    if espLabels[p]     then espLabels[p].Gui:Destroy(); espLabels[p] = nil end
                end
            end
        end
    end)
    AddNotification("ESP", "ESP Enabled", 3)
end

Players.PlayerRemoving:Connect(function(p)
    if espHighlights[p] then espHighlights[p]:Destroy(); espHighlights[p] = nil end
    if espLabels[p]     then espLabels[p].Gui:Destroy(); espLabels[p] = nil end
end)

-- ===================== 16. F3X =====================
local function GiveF3X()
    local httpOk, src = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/F3XTeam/F3X/main/loader.lua", true)
    end)
    if not httpOk or not src or #src == 0 then
        AddNotification("F3X", "HTTP load failed", 2); return
    end
    local fn, compileErr = loadstring(src)
    if not fn then
        AddNotification("F3X", "Compile error: " .. tostring(compileErr), 3); return
    end
    local runOk, runErr = pcall(fn)
    if not runOk then
        AddNotification("F3X", "Runtime error: " .. tostring(runErr), 3); return
    end
    AddNotification("F3X", "F3X loaded", 2)
end

-- ===================== 17. BRING =====================
local function BringPlayer(name)
    local target = FindPlayer(name)
    if not target then AddNotification("Bring", "Player not found", 2) return end
    local myChar, tChar = Player.Character, target.Character
    if not myChar or not tChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local tRoot  = tChar:FindFirstChild("HumanoidRootPart")
    if myRoot and tRoot then tRoot.CFrame = myRoot.CFrame + Vector3.new(0, 3, 0) end
    AddNotification("Bring", "Brought " .. target.Name, 2)
end

-- ===================== 18. KILL =====================
local function KillPlayer(name)
    local target = FindPlayer(name)
    if not target then AddNotification("Kill", "Player not found", 2) return end
    if target.Character then target.Character:BreakJoints() end
    AddNotification("Kill", "Killed " .. target.Name, 2)
end

-- ===================== 19. EXPLODE =====================
local function ExplodePlayer(name)
    local target = FindPlayer(name)
    if not target then AddNotification("Explode", "Player not found", 2) return end
    local root = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local ex = Instance.new("Explosion")
    ex.Position = root.Position
    ex.BlastRadius = 20
    ex.BlastPressure = 100000
    ex.Parent = workspace
    AddNotification("Explode", "Exploded " .. target.Name, 2)
end

-- ===================== 20. FLING =====================
local function FlingPlayer(name)
    local target = FindPlayer(name)
    if not target then AddNotification("Fling", "Player not found", 2) return end
    local root = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.Velocity    = Vector3.new(math.random(-500,500), 1000, math.random(-500,500))
        root.RotVelocity = Vector3.new(math.random(-50,50),  math.random(-50,50), math.random(-50,50))
    end
    AddNotification("Fling", "Flung " .. target.Name, 2)
end

-- ===================== 21. SIT =====================
local function ToggleSit(name, state)
    local target = FindPlayer(name)
    if not target then return end
    local humanoid = target.Character and target.Character:FindFirstChild("Humanoid")
    if humanoid then humanoid.Sit = state end
    AddNotification("Sit", state and ("Sitted " .. target.Name) or ("Unsitted " .. target.Name), 2)
end

local function ToggleSelfSit(state)
    local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
    if humanoid then humanoid.Sit = state end
    AddNotification("Sit", state and "You sat down" or "You stood up", 2)
end

-- ===================== 22. JAIL =====================
local function ToggleJail(name, state)
    local target = FindPlayer(name)
    if not target then return end
    local root = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if state then
        if not Effects.jailedPlayers[target] then
            local folder = Instance.new("Folder"); folder.Name = "Jail_" .. target.Name; folder.Parent = workspace
            local size = Vector3.new(10, 10, 10)
            local c = root.Position
            local positions = {
                c + Vector3.new(0, size.Y/2,  size.Z/2), c + Vector3.new(0, size.Y/2, -size.Z/2),
                c + Vector3.new( size.X/2, size.Y/2, 0), c + Vector3.new(-size.X/2, size.Y/2, 0),
                c + Vector3.new(0, size.Y, 0),           c,
            }
            local sizes = {
                Vector3.new(size.X, size.Y, 1), Vector3.new(size.X, size.Y, 1),
                Vector3.new(1, size.Y, size.Z), Vector3.new(1, size.Y, size.Z),
                Vector3.new(size.X, 1, size.Z), Vector3.new(size.X, 1, size.Z),
            }
            for i = 1, 6 do
                local wall = Instance.new("Part")
                wall.Size = sizes[i]
                wall.Position = positions[i]
                wall.Anchored = true
                wall.Material = Enum.Material.SmoothPlastic
                wall.Color = Color3.fromRGB(100, 100, 100)
                wall.Parent = folder
            end
            Effects.jailedPlayers[target] = folder
        end
    else
        if Effects.jailedPlayers[target] then
            Effects.jailedPlayers[target]:Destroy()
            Effects.jailedPlayers[target] = nil
        end
    end
    AddNotification("Jail", state and ("Jailed " .. target.Name) or ("Unjailed " .. target.Name), 2)
end

-- ===================== 23. MUTE =====================
local function ToggleMute(name, state)
    local target = FindPlayer(name)
    if not target then return end
    if state then Effects.mutedPlayers[target] = true
    else Effects.mutedPlayers[target] = nil end
    AddNotification("Mute", state and ("Muted " .. target.Name) or ("Unmuted " .. target.Name), 2)
end

-- ===================== 24. TOOLS =====================
local function GiveTools(name)
    local target = FindPlayer(name)
    if not target then return end
    local backpack = target:FindFirstChild("Backpack"); if not backpack then return end
    local tool = Instance.new("Tool")
    tool.Name = "Sword"; tool.RequiresHandle = true; tool.Parent = backpack
    local handle = Instance.new("Part"); handle.Name = "Handle"; handle.Size = Vector3.new(1,1,1); handle.Parent = tool
    AddNotification("Tools", "Gave tools to " .. target.Name, 2)
end
local function GiveSword(name) GiveTools(name) end

local function RemoveTools(name)
    local target = FindPlayer(name); if not target then return end
    local backpack = target:FindFirstChild("Backpack")
    if backpack then for _, item in ipairs(backpack:GetChildren()) do item:Destroy() end end
    if target.Character then
        for _, item in ipairs(target.Character:GetChildren()) do
            if item:IsA("Tool") then item:Destroy() end
        end
    end
    AddNotification("Remove", "Removed tools from " .. target.Name, 2)
end

-- ===================== 25. MUSIC =====================
local function PlayMusic(id)
    if Effects.musicSound then
        Effects.musicSound:Stop(); Effects.musicSound:Destroy(); Effects.musicSound = nil
    end
    if not id then AddNotification("Music", "Stopped", 2) return end
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. id
    sound.Volume = 0.5
    sound.Looped = true
    sound.Parent = SoundService
    sound:Play()
    Effects.musicSound = sound
    AddNotification("Music", "Playing ID: " .. id, 2)
end
local function StopMusic() PlayMusic(nil) end

-- ===================== 26. NOTIFY =====================
local function NotifyAll(msg)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = "max denis admin", Text = msg, Duration = 5})
    end)
end

local function SendMessage(msg)
    if Player.Character and Player.Character:FindFirstChild("Head") then
        pcall(function() ChatService:Chat(Player.Character.Head, msg) end)
    end
end

-- ===================== 27. CLONE =====================
local function ClonePlayer(name)
    local target = FindPlayer(name)
    if not target or not target.Character then return end
    local clone = target.Character:Clone()
    clone.Parent = workspace
    clone:MoveTo(target.Character:GetPivot().Position + Vector3.new(5, 0, 0))
    AddNotification("Clone", "Cloned " .. target.Name, 2)
end

-- ===================== 28. KICK / BAN (fix #14) =====================
local function KickPlayer(name)
    local target = FindPlayer(name); if not target then return end
    AddNotification("Kick", "Cannot kick " .. target.Name .. " (client-side only)", 2)
end
local function BanPlayer(name)
    local target = FindPlayer(name); if not target then return end
    AddNotification("Ban", "Ban requires server access — " .. target.Name, 2)
end

-- ===================== 29. SIZE (fix #22) =====================
local function SetPlayerSize(name, val)
    local target = FindPlayer(name)
    if not target or not target.Character then return end
    local scale = tonumber(val); if not scale then return end
    OriginalSizes[target] = OriginalSizes[target] or {}
    for _, part in ipairs(target.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            OriginalSizes[target][part] = OriginalSizes[target][part] or part.Size
            part.Size = OriginalSizes[target][part] * scale
        end
    end
    AddNotification("Size", "Set " .. target.Name .. " size to " .. scale, 2)
end

local function UnsetPlayerSize(name)
    local target = FindPlayer(name)
    if not target or not OriginalSizes[target] then
        AddNotification("Size", "No saved size", 2); return
    end
    for part, size in pairs(OriginalSizes[target]) do
        if part and part.Parent then part.Size = size end
    end
    OriginalSizes[target] = nil
    AddNotification("Size", "Size reset for " .. target.Name, 2)
end

-- ===================== 30. HEADSIZE =====================
local function SetHeadSize(name, val)
    local target = FindPlayer(name)
    if not target or not target.Character then return end
    local head = target.Character:FindFirstChild("Head"); if not head then return end
    local scale = tonumber(val); if not scale then return end
    OriginalHeadSize[target] = OriginalHeadSize[target] or head.Size
    head.Size = OriginalHeadSize[target] * scale
    AddNotification("HeadSize", "Set head size to " .. scale, 2)
end

local function UnsetHeadSize(name)
    local target = FindPlayer(name)
    if not target or not OriginalHeadSize[target] then
        AddNotification("HeadSize", "No saved size", 2); return
    end
    local head = target.Character and target.Character:FindFirstChild("Head")
    if head then head.Size = OriginalHeadSize[target] end
    OriginalHeadSize[target] = nil
    AddNotification("HeadSize", "Head size reset", 2)
end

-- ===================== 31. HEALTH / JUMP / HIP / WALK / MAXHP =====================
local function SetHealth(name, val)
    local target = FindPlayer(name)
    local humanoid = target and target.Character and target.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    humanoid.Health = tonumber(val) or 100
    AddNotification("Health", "Set health to " .. val, 2)
end
local function SetJumpPower(name, val)
    local target = FindPlayer(name)
    local humanoid = target and target.Character and target.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    humanoid.JumpPower = tonumber(val) or 50
    AddNotification("Jump", "Set jump power to " .. val, 2)
end
local function SetHipHeight(name, val)
    local target = FindPlayer(name)
    local humanoid = target and target.Character and target.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    humanoid.HipHeight = tonumber(val) or 0
    AddNotification("HipHeight", "Set hip height to " .. val, 2)
end
local function SetWalkSpeed(name, val)
    local target = FindPlayer(name)
    local humanoid = target and target.Character and target.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    humanoid.WalkSpeed = tonumber(val) or 16
    AddNotification("WalkSpeed", "Set walk speed to " .. val, 2)
end
local function SetMaxHealth(name, val)
    local target = FindPlayer(name)
    local humanoid = target and target.Character and target.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    humanoid.MaxHealth = tonumber(val) or 100
    AddNotification("MaxHealth", "Set max health to " .. val, 2)
end

-- ===================== 32. TRANSPARENCY / COLOR / MATERIAL / REFLECTANCE =====================
local function SetTransparency(name, val)
    local target = FindPlayer(name); if not target or not target.Character then return end
    local t = tonumber(val); if not t then return end
    OrigTransparency[target] = OrigTransparency[target] or {}
    for _, part in ipairs(target.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            OrigTransparency[target][part] = OrigTransparency[target][part] or part.Transparency
            part.Transparency = t
        end
    end
    AddNotification("Transparency", "Set transparency to " .. t, 2)
end

local function SetColor(name, r, g, b)
    local target = FindPlayer(name); if not target or not target.Character then return end
    local color = Color3.fromRGB(tonumber(r) or 255, tonumber(g) or 255, tonumber(b) or 255)
    OrigColor[target] = OrigColor[target] or {}
    for _, part in ipairs(target.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            OrigColor[target][part] = OrigColor[target][part] or part.Color
            part.Color = color
        end
    end
    AddNotification("Color", "Set color", 2)
end

local function SetMaterial(name, mat)
    local target = FindPlayer(name); if not target or not target.Character then return end
    local material = FindMaterialEnum(mat) or Enum.Material.SmoothPlastic
    OrigMaterial[target] = OrigMaterial[target] or {}
    for _, part in ipairs(target.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            OrigMaterial[target][part] = OrigMaterial[target][part] or part.Material
            part.Material = material
        end
    end
    AddNotification("Material", "Set material to " .. mat, 2)
end

local function SetReflectance(name, val)
    local target = FindPlayer(name); if not target or not target.Character then return end
    local r = tonumber(val); if not r then return end
    OrigReflectance[target] = OrigReflectance[target] or {}
    for _, part in ipairs(target.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            OrigReflectance[target][part] = OrigReflectance[target][part] or part.Reflectance
            part.Reflectance = r
        end
    end
    AddNotification("Reflectance", "Set reflectance to " .. r, 2)
end

-- ===================== 33. KILLAURA =====================
local function ToggleKillAura(state)
    Effects.killauraEnabled = state
    if Effects.killauraConnection then Effects.killauraConnection:Disconnect(); Effects.killauraConnection = nil end
    if state then
        Effects.killauraConnection = RunService.Heartbeat:Connect(function()
            if not Effects.killauraEnabled then return end
            local myRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if not myRoot then return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= Player and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    local tRoot = p.Character:FindFirstChild("HumanoidRootPart")
                    if tRoot and (tRoot.Position - myRoot.Position).Magnitude < 20 then
                        p.Character:BreakJoints()
                    end
                end
            end
        end)
    end
    AddNotification("Kill Aura", state and "Enabled" or "Disabled", 2)
end

-- ===================== 34. SPINBOT =====================
local function ToggleSpinBot(state)
    Effects.spinbotEnabled = state
    if Effects.spinbotConnection then Effects.spinbotConnection:Disconnect(); Effects.spinbotConnection = nil end
    if state then
        Effects.spinbotConnection = RunService.RenderStepped:Connect(function()
            if Effects.spinbotEnabled and Player.Character then
                local root = Player.Character:FindFirstChild("HumanoidRootPart")
                if root then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(5), 0) end
            end
        end)
    end
    AddNotification("SpinBot", state and "Enabled" or "Disabled", 2)
end

-- ===================== 35. AIMBOT =====================
local function ToggleAimbot(state)
    Effects.aimbotEnabled = state
    if Effects.aimbotConnection then Effects.aimbotConnection:Disconnect(); Effects.aimbotConnection = nil end
    if state then
        Effects.aimbotConnection = RunService.RenderStepped:Connect(function()
            if not Effects.aimbotEnabled then return end
            local myRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if not myRoot then return end
            local nearest, minDist = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= Player and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    local tRoot = p.Character:FindFirstChild("HumanoidRootPart")
                    if tRoot then
                        local d = (tRoot.Position - myRoot.Position).Magnitude
                        if d < minDist then minDist = d; nearest = tRoot end
                    end
                end
            end
            if nearest then Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, nearest.Position) end
        end)
    end
    AddNotification("Aimbot", state and "Enabled" or "Disabled", 2)
end

-- ===================== 36. AUTOFARM =====================
local function ToggleAutoFarm(state)
    Effects.autofarmEnabled = state
    if Effects.autofarmConnection then Effects.autofarmConnection:Disconnect(); Effects.autofarmConnection = nil end
    if state then
        Effects.autofarmConnection = RunService.Heartbeat:Connect(function()
            if not Effects.autofarmEnabled then return end
            local myRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if not myRoot then return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= Player and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    local tRoot = p.Character:FindFirstChild("HumanoidRootPart")
                    if tRoot then
                        myRoot.CFrame = tRoot.CFrame + Vector3.new(0, 3, 0)
                        p.Character:BreakJoints()
                        break
                    end
                end
            end
        end)
    end
    AddNotification("AutoFarm", state and "Enabled" or "Disabled", 2)
end

-- ===================== 37. WALLHACK / XRAY (fix #7) =====================
local function ApplyWorldTransparency(value)
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            if OriginalLTM[part] == nil then
                OriginalLTM[part] = part.LocalTransparencyModifier
            end
            part.LocalTransparencyModifier = value
        end
    end
end

local function RestoreWorldTransparency()
    for part, value in pairs(OriginalLTM) do
        if part and part.Parent then part.LocalTransparencyModifier = value end
    end
    OriginalLTM = {}
end

local function UpdateWorldTransparency()
    if not Effects.wallhackEnabled and not Effects.xrayEnabled then
        RestoreWorldTransparency()
        if WorldRenderConn then WorldRenderConn:Disconnect(); WorldRenderConn = nil end
        return
    end
    local value = Effects.xrayEnabled and 0.8 or 0.5
    ApplyWorldTransparency(value)
end

local function EnsureWorldConn()
    if not WorldRenderConn then
        WorldRenderConn = RunService.RenderStepped:Connect(UpdateWorldTransparency)
    end
end

local function ToggleWallhack(state)
    Effects.wallhackEnabled = state
    if state then EnsureWorldConn() else UpdateWorldTransparency() end
    AddNotification("Wallhack", state and "Enabled" or "Disabled", 2)
end

local function ToggleXray(state)
    Effects.xrayEnabled = state
    if state then EnsureWorldConn() else UpdateWorldTransparency() end
    AddNotification("Xray", state and "Enabled" or "Disabled", 2)
end

-- ===================== 38. NOFALL (fix #23) / SUPERJUMP (fix #6) =====================
local function ToggleNoFall(state)
    local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
    if humanoid then
        if state then
            OriginalFallingDown = humanoid:GetStateEnabled(Enum.HumanoidStateType.FallingDown)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        else
            if OriginalFallingDown ~= nil then
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, OriginalFallingDown)
            end
            OriginalFallingDown = nil
        end
    end
    Effects.nofallEnabled = state
    AddNotification("NoFall", state and "Enabled" or "Disabled", 2)
end

local function ToggleSuperJump(state)
    local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
    if humanoid then
        if state then
            if not Effects.superjumpEnabled then
                OriginalJumpPower = humanoid.JumpPower
            end
            humanoid.JumpPower = 200
        else
            humanoid.JumpPower = OriginalJumpPower or 50
            OriginalJumpPower = nil
        end
    end
    Effects.superjumpEnabled = state
    AddNotification("SuperJump", state and "Enabled" or "Disabled", 2)
end

-- ===================== 39. BHOP =====================
local function ToggleBHop(state)
    Effects.bhopEnabled = state
    if Effects.bhopConnection then Effects.bhopConnection:Disconnect(); Effects.bhopConnection = nil end
    if state then
        Effects.bhopConnection = RunService.Heartbeat:Connect(function()
            if Effects.bhopEnabled and Player.Character then
                local humanoid = Player.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
    AddNotification("BHop", state and "Enabled" or "Disabled", 2)
end

-- ===================== 40. AUTOCLICK (fix #17) =====================
local function ToggleAutoClick(state)
    Effects.autoclickEnabled = state
    if Effects.autoclickConnection then
        Effects.autoclickConnection:Disconnect()
        Effects.autoclickConnection = nil
    end
    if state then
        local vim = game:FindService("VirtualInputManager")
        if not vim then
            Effects.autoclickEnabled = false
            AddNotification("AutoClick", "VirtualInputManager unavailable", 2)
            return
        end
        local ok = pcall(function()
            vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end)
        if not ok then
            Effects.autoclickEnabled = false
            AddNotification("AutoClick", "Not supported by this executor", 2)
            return
        end
        Effects.autoclickConnection = RunService.Heartbeat:Connect(function()
            if Effects.autoclickEnabled then
                pcall(function()
                    vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end)
            end
        end)
        AddNotification("AutoClick", "Enabled (executor-dependent)", 2)
    else
        AddNotification("AutoClick", "Disabled", 2)
    end
end

-- ===================== 41. FOV / CAMERA =====================
local function SetFOV(val)
    local fov = tonumber(val); if not fov then return end
    Camera.FieldOfView = fov
    AddNotification("FOV", "Set FOV to " .. fov, 2)
end
local function ResetCamera()
    Camera.CameraSubject = Player.Character and Player.Character:FindFirstChild("Humanoid") or nil
    Camera.FieldOfView = Effects.fovOriginal
    AddNotification("Camera", "Camera reset", 2)
end
local function ThirdPerson() Player.CameraMode = Enum.CameraMode.Classic;          AddNotification("Camera", "Third person", 2) end
local function FirstPerson() Player.CameraMode = Enum.CameraMode.LockFirstPerson; AddNotification("Camera", "First person", 2) end

-- ===================== 42. CAMERASHAKE (fix #18) =====================
local function CameraShake(intensity)
    if shakeConnection then shakeConnection:Disconnect(); shakeConnection = nil end
    local inten = tonumber(intensity) or 1
    local duration = 1
    local startTime = tick()
    shakeConnection = RunService.RenderStepped:Connect(function()
        if tick() - startTime >= duration then
            if shakeConnection then shakeConnection:Disconnect(); shakeConnection = nil end
            return
        end
        local offset = Vector3.new(
            (math.random() - 0.5) * inten,
            (math.random() - 0.5) * inten,
            (math.random() - 0.5) * inten
        )
        Camera.CFrame = Camera.CFrame * CFrame.new(offset)
    end)
    AddNotification("Camera Shake", "Intensity " .. inten, 2)
end

local function Zoom(val)
    local z = tonumber(val); if not z then return end
    Camera.FieldOfView = math.max(10, math.min(120, Camera.FieldOfView - z))
    AddNotification("Zoom", "Zoomed", 2)
end

-- ===================== 43. EFFECTS =====================
local function CreateEffect(effectType)
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if effectType == "shake" then
        local startFOV = Camera.FieldOfView
        for _ = 1, 10 do
            Camera.FieldOfView = startFOV + math.random(-5, 5)
            task.wait(0.05)
        end
        Camera.FieldOfView = startFOV
    elseif effectType == "flash" then
        local flash = Instance.new("PointLight"); flash.Parent = root; flash.Brightness = 10; flash.Range = 50
        Debris:AddItem(flash, 0.5)
    elseif effectType == "smoke" then
        local smoke = Instance.new("Smoke"); smoke.Parent = root; smoke.Size = 10; smoke.RiseVelocity = 5
        Debris:AddItem(smoke, 3)
    elseif effectType == "fire" then
        local fire = Instance.new("Fire"); fire.Parent = root; fire.Heat = 25; fire.Size = 5
        Debris:AddItem(fire, 3)
    elseif effectType == "lightning" then
        local bolt = Instance.new("Part")
        bolt.Parent = workspace; bolt.Anchored = true
        bolt.Size = Vector3.new(0.1, 100, 0.1)
        bolt.Position = root.Position + Vector3.new(0, 50, 0)
        bolt.Color = Color3.fromRGB(255, 255, 0)
        Debris:AddItem(bolt, 0.5)
    end
    AddNotification("Effect", effectType .. " created", 2)
end

-- ===================== 44. CREATE OBJECTS (fix #13) =====================
local function CreatePart(shape, size)
    local part = Instance.new("Part")
    part.Shape = FindPartTypeEnum(shape) or Enum.PartType.Block
    local s = tonumber(size) or 4
    part.Size = Vector3.new(s, s, s)
    part.Position = Player.Character and Player.Character:GetPivot().Position or Vector3.new(0, 10, 0)
    part.Anchored = false
    part.Parent = workspace
    AddNotification("Part", "Created " .. tostring(shape) .. " part", 2)
end

local function CreateMesh(meshType)
    local part = Instance.new("Part")
    part.Position = Player.Character and Player.Character:GetPivot().Position or Vector3.new(0, 10, 0)
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = FindMeshTypeEnum(meshType) or Enum.MeshType.Sphere
    mesh.Parent = part
    part.Parent = workspace
    AddNotification("Mesh", "Created " .. tostring(meshType) .. " mesh", 2)
end

local function CreateNPC(name)
    if not Player.Character then return end
    local char = Player.Character:Clone()
    char.Name = name or "NPC"
    char.Parent = workspace
    char:MoveTo(Player.Character:GetPivot().Position + Vector3.new(5, 0, 0))
    AddNotification("NPC", "NPC created", 2)
end

-- ===================== 45. CAR (fix #11) =====================
local function SpawnCar(modelName)
    local car = Instance.new("Model"); car.Name = modelName or "Car"; car.Parent = workspace
    local base = Instance.new("Part")
    base.Name = "Base"; base.Size = Vector3.new(6, 1, 10)
    base.Position = Player.Character and Player.Character:GetPivot().Position or Vector3.new(0, 5, 0)
    base.Anchored = false; base.Parent = car

    local seat = Instance.new("VehicleSeat")
    seat.Name = "Seat"; seat.Size = Vector3.new(1, 1, 1)
    seat.CFrame = base.CFrame + Vector3.new(0, 1, 0)
    seat.Parent = car

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = base; weld.Part1 = seat
    weld.Parent = base

    AddNotification("Car", "Car spawned", 2)
end

-- ===================== 46. TELEPORT / SERVER (fix #12, #17) =====================
local function TeleportToPlace(placeId)
    local id = tonumber(placeId)
    if not id then AddNotification("Teleport", "Invalid place id", 2) return end
    local ok, err = pcall(function()
        game:GetService("TeleportService"):Teleport(id)
    end)
    if not ok then AddNotification("Teleport", "Failed: " .. tostring(err), 3) end
end
local function JoinPlace(placeId) TeleportToPlace(placeId) end

local function ServerHop()
    local placeId = game.PlaceId
    local ok, result = pcall(function()
        local raw = game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?limit=100")
        return HttpService:JSONDecode(raw)
    end)
    if not ok or not result or not result.data then
        AddNotification("ServerHop", "HTTP/JSON failed", 2); return
    end
    local candidates = {}
    for _, s in ipairs(result.data) do
        if s.id ~= game.JobId then table.insert(candidates, s) end
    end
    if #candidates == 0 then
        AddNotification("ServerHop", "No other servers", 2); return
    end
    local server = candidates[math.random(#candidates)]
    local tOk, tErr = pcall(function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(placeId, server.id)
    end)
    if not tOk then AddNotification("ServerHop", "Teleport failed: " .. tostring(tErr), 3) end
end

local function Rejoin()
    pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId) end)
end

local function LeaveGame()
    local ok = pcall(function() game:Shutdown() end)
    if not ok then AddNotification("Leave", "Not available on this executor", 2) end
end

-- ===================== 47. POSITION =====================
local function SavePosition()
    if Player.Character then
        Effects.savedPosition = Player.Character:GetPivot().Position
        AddNotification("Position", "Position saved", 2)
    end
end
local function LoadPosition()
    if Effects.savedPosition and Player.Character then
        Player.Character:MoveTo(Effects.savedPosition)
        AddNotification("Position", "Position loaded", 2)
    end
end
local function PrintPosition()
    if Player.Character then
        local pos = Player.Character:GetPivot().Position
        AddNotification("Position", string.format("X: %.1f, Y: %.1f, Z: %.1f", pos.X, pos.Y, pos.Z), 3)
    end
end

-- ===================== 48. INFO =====================
local function ServerInfo()
    local mem = game:GetService("Stats"):GetTotalMemoryUsageMb()
    local players = #Players:GetPlayers()
    AddNotification("Server Info", "Players: " .. players .. "\nMemory: " .. math.floor(mem) .. " MB", 5)
end

local function Ping()
    local ok, value = pcall(function()
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    if ok and value then
        AddNotification("Ping", "Ping: " .. math.floor(value) .. " ms", 3)
    else
        AddNotification("Ping", "Ping unavailable", 2)
    end
end

local function FPS()
    local frames = 0
    local start = tick()
    local conn
    conn = RunService.RenderStepped:Connect(function() frames += 1 end)
    task.wait(1)
    if conn then conn:Disconnect() end
    local fps = frames / (tick() - start)
    AddNotification("FPS", "FPS: " .. math.floor(fps), 3)
end

-- ===================== 49. GIVE / WEAR (fix #15) =====================
local function GiveItem(itemName) AddNotification("Give", "Not implemented: " .. itemName, 2) end
local function WearHat(id)   AddNotification("Hat",   "Not implemented: " .. id, 2) end
local function WearFace(id)  AddNotification("Face",  "Not implemented: " .. id, 2) end
local function WearShirt(id) AddNotification("Shirt", "Not implemented: " .. id, 2) end
local function WearPants(id) AddNotification("Pants", "Not implemented: " .. id, 2) end

local function PlayAnimation(id)
    local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://" .. id
        local track = animator:LoadAnimation(animation)
        track:Play()
        AddNotification("Animation", "Playing animation " .. id, 2)
    end
end

-- ===================== 50. EMOTE (fix #10) =====================
local EMOTE_IDS = {
    dance = "rbxassetid://507771019",
    wave  = "rbxassetid://507770239",
    point = "rbxassetid://507770453",
    laugh = "rbxassetid://507770818",
    cheer = "rbxassetid://507770677",
    cry   = "rbxassetid://507770559",
}

local function DoEmote(name)
    local id = EMOTE_IDS[name]
    if not id then
        AddNotification("Emote", "Unknown emote: " .. name, 2)
        return
    end
    local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
    local anim = Instance.new("Animation"); anim.AnimationId = id
    local track = animator:LoadAnimation(anim)
    track:Play()
    AddNotification("Emote", "Playing " .. name, 2)
end

-- ===================== 51. FOLLOW / ORBIT / LOOKAT (fix #9) =====================
local function FollowPlayer(name)
    if Effects.followConnection then Effects.followConnection:Disconnect(); Effects.followConnection = nil end
    local target = FindPlayer(name)
    if not target then AddNotification("Follow", "Player not found", 2) return end
    Effects.followPlayer = target
    Effects.followConnection = RunService.Heartbeat:Connect(function()
        if Effects.followPlayer and Effects.followPlayer.Character and Player.Character then
            local tRoot = Effects.followPlayer.Character:FindFirstChild("HumanoidRootPart")
            local myRoot = Player.Character:FindFirstChild("HumanoidRootPart")
            if tRoot and myRoot then myRoot.CFrame = tRoot.CFrame + Vector3.new(0, 3, 0) end
        end
    end)
    AddNotification("Follow", "Following " .. target.Name, 2)
end

local function Unfollow()
    if Effects.followConnection then Effects.followConnection:Disconnect(); Effects.followConnection = nil end
    Effects.followPlayer = nil
    AddNotification("Follow", "Stopped following", 2)
end

local function OrbitPlayer(name)
    if Effects.orbitConnection then Effects.orbitConnection:Disconnect(); Effects.orbitConnection = nil end
    local target = FindPlayer(name)
    if not target then AddNotification("Orbit", "Player not found", 2) return end
    Effects.orbitPlayer = target
    local angle = 0
    Effects.orbitConnection = RunService.Heartbeat:Connect(function()
        if Effects.orbitPlayer and Effects.orbitPlayer.Character and Player.Character then
            local tRoot = Effects.orbitPlayer.Character:FindFirstChild("HumanoidRootPart")
            local myRoot = Player.Character:FindFirstChild("HumanoidRootPart")
            if tRoot and myRoot then
                angle += math.rad(10)
                myRoot.CFrame = tRoot.CFrame * CFrame.Angles(0, angle, 0) * CFrame.new(0, 0, 10)
            end
        end
    end)
    AddNotification("Orbit", "Orbiting " .. target.Name, 2)
end

local function Unorbit()
    if Effects.orbitConnection then Effects.orbitConnection:Disconnect(); Effects.orbitConnection = nil end
    Effects.orbitPlayer = nil
    AddNotification("Orbit", "Stopped orbiting", 2)
end

local function LookAtPlayer(name)
    if Effects.lookAtConnection then Effects.lookAtConnection:Disconnect(); Effects.lookAtConnection = nil end
    local target = FindPlayer(name)
    if not target then AddNotification("LookAt", "Player not found", 2) return end
    Effects.lookAtPlayer = target
    Effects.lookAtConnection = RunService.RenderStepped:Connect(function()
        if Effects.lookAtPlayer and Effects.lookAtPlayer.Character and Player.Character then
            local tRoot = Effects.lookAtPlayer.Character:FindFirstChild("HumanoidRootPart")
            local myRoot = Player.Character:FindFirstChild("HumanoidRootPart")
            if tRoot and myRoot then
                Camera.CFrame = CFrame.lookAt(myRoot.Position, tRoot.Position)
            end
        end
    end)
    AddNotification("LookAt", "Looking at " .. target.Name, 2)
end

local function UnlookAt()
    if Effects.lookAtConnection then Effects.lookAtConnection:Disconnect(); Effects.lookAtConnection = nil end
    Effects.lookAtPlayer = nil
    AddNotification("LookAt", "Stopped looking", 2)
end

-- ===================== ПАРСЕР =====================
local function ExecuteCommand(cmdStr)
    local C = ParseCommand(cmdStr)
    if not C then return end
    local main, arg, rest, rest2, rest3, tail = C.main, C.arg, C.rest, C.rest2, C.rest3, C.tail

    if main == "fly" then StartFly(arg)
    elseif main == "unfly" then StopFly()
    elseif main == "speed" then SetSpeed(arg)
    elseif main == "unspeed" then SetSpeed(16)
    elseif main == "esp" then ToggleESP(true)
    elseif main == "unesp" then ToggleESP(false)
    elseif main == "f3x" then GiveF3X()
    elseif main == "re" then if Player.Character then Player.Character:BreakJoints() end
    elseif main == "noclip"    then ToggleNoclip(true)
    elseif main == "unnoclip"  then ToggleNoclip(false)
    elseif main == "goto"      then if arg then GotoPlayer(arg) end
    elseif main == "god"       then ToggleGod(true)
    elseif main == "ungod"     then ToggleGod(false)
    elseif main == "infjump"   then ToggleInfJump(true)
    elseif main == "uninfjump" then ToggleInfJump(false)
    elseif main == "view"      then ToggleView(arg)
    elseif main == "unview"    then ToggleView(nil)
    elseif main == "invisible" then ToggleInvisible(true)
    elseif main == "visible"   then ToggleInvisible(false)
    elseif main == "freeze"    then if arg then ToggleFreeze(arg, true) end
    elseif main == "unfreeze"  then if arg then ToggleFreeze(arg, false) end
    elseif main == "spy"       then ToggleSpy(arg)
    elseif main == "unspy"     then ToggleSpy(nil)
    elseif main == "loopkill"  then ToggleLoopKill(true)
    elseif main == "unloopkill" then ToggleLoopKill(false)
    elseif main == "loopfling" then ToggleLoopFling(true)
    elseif main == "unloopfling" then ToggleLoopFling(false)
    elseif main == "tp" then
        if C.parts[2] and C.parts[3] and C.parts[4] then
            TeleportToCoords(C.parts[2], C.parts[3], C.parts[4])
        end
    elseif main == "antiafk"   then ToggleAntiAFK(true)
    elseif main == "unantiafk" then ToggleAntiAFK(false)
    elseif main == "bring"     then if arg then BringPlayer(arg) end
    elseif main == "kill"      then if arg then KillPlayer(arg) end
    elseif main == "explode"   then if arg then ExplodePlayer(arg) end
    elseif main == "fling"     then if arg then FlingPlayer(arg) end
    elseif main == "sit"       then if arg then ToggleSit(arg, true) end
    elseif main == "unsit"     then if arg then ToggleSit(arg, false) end
    elseif main == "jail"      then if arg then ToggleJail(arg, true) end
    elseif main == "unjail"    then if arg then ToggleJail(arg, false) end
    elseif main == "mute"      then if arg then ToggleMute(arg, true) end
    elseif main == "unmute"    then if arg then ToggleMute(arg, false) end
    elseif main == "tools"     then if arg then GiveTools(arg) end
    elseif main == "sword"     then if arg then GiveSword(arg) end
    elseif main == "remove"    then if arg then RemoveTools(arg) end
    elseif main == "music"     then PlayMusic(arg)
    elseif main == "stopmusic" then StopMusic()
    elseif main == "notify"    then NotifyAll(tail)
    elseif main == "hint"      then NotifyAll(tail)
    elseif main == "message"   then SendMessage(tail)
    elseif main == "clone"     then if arg then ClonePlayer(arg) end
    elseif main == "kick"      then if arg then KickPlayer(arg) end
    elseif main == "ban"       then if arg then BanPlayer(arg) end
    elseif main == "size"      then if arg and rest then SetPlayerSize(arg, rest) end
    elseif main == "unsize"    then if arg then UnsetPlayerSize(arg) end
    elseif main == "headsize"  then if arg and rest then SetHeadSize(arg, rest) end
    elseif main == "unheadsize" then if arg then UnsetHeadSize(arg) end
    elseif main == "health"    then if arg and rest then SetHealth(arg, rest) end
    elseif main == "jumppower" then if arg and rest then SetJumpPower(arg, rest) end
    elseif main == "hipheight" then if arg and rest then SetHipHeight(arg, rest) end
    elseif main == "walkspeed" then if arg and rest then SetWalkSpeed(arg, rest) end
    elseif main == "maxhealth" then if arg and rest then SetMaxHealth(arg, rest) end
    elseif main == "gravity"   then workspace.Gravity = tonumber(arg) or 196.2
    elseif main == "time"      then Lighting.ClockTime = tonumber(arg) or 14
    elseif main == "fog" then
        if arg then
            local d = tonumber(arg) or 100
            Lighting.FogEnd = d
            Lighting.FogStart = d / 2
        end
    elseif main == "skybox" then
        if arg then
            local sky = Instance.new("Sky")
            sky.SkyboxBk = "rbxassetid://" .. arg
            sky.SkyboxDn = "rbxassetid://" .. arg
            sky.SkyboxFt = "rbxassetid://" .. arg
            sky.SkyboxLf = "rbxassetid://" .. arg
            sky.SkyboxRt = "rbxassetid://" .. arg
            sky.SkyboxUp = "rbxassetid://" .. arg
            sky.Parent = Lighting
        end
    elseif main == "transparency" then if arg and rest then SetTransparency(arg, rest) end
    elseif main == "color"        then if arg and rest and rest2 and rest3 then SetColor(arg, rest, rest2, rest3) end
    elseif main == "material"     then if arg and rest then SetMaterial(arg, rest) end
    elseif main == "reflectance"  then if arg and rest then SetReflectance(arg, rest) end
    elseif main == "killaura"   then ToggleKillAura(true)
    elseif main == "unkillaura" then ToggleKillAura(false)
    elseif main == "spinbot"    then ToggleSpinBot(true)
    elseif main == "unspinbot"  then ToggleSpinBot(false)
    elseif main == "aimbot"     then ToggleAimbot(true)
    elseif main == "unaimbot"   then ToggleAimbot(false)
    elseif main == "autofarm"   then ToggleAutoFarm(true)
    elseif main == "unautofarm" then ToggleAutoFarm(false)
    elseif main == "wallhack"   then ToggleWallhack(true)
    elseif main == "unwallhack" then ToggleWallhack(false)
    elseif main == "xray"       then ToggleXray(true)
    elseif main == "unxray"     then ToggleXray(false)
    elseif main == "nofall"     then ToggleNoFall(true)
    elseif main == "unnofall"   then ToggleNoFall(false)
    elseif main == "superjump"  then ToggleSuperJump(true)
    elseif main == "unsuperjump" then ToggleSuperJump(false)
    elseif main == "bhop"       then ToggleBHop(true)
    elseif main == "unbhop"     then ToggleBHop(false)
    elseif main == "autoclick"  then ToggleAutoClick(true)
    elseif main == "unautoclick" then ToggleAutoClick(false)
    elseif main == "fov"        then SetFOV(arg)
    elseif main == "resetcamera" then ResetCamera()
    elseif main == "thirdperson" then ThirdPerson()
    elseif main == "firstperson" then FirstPerson()
    elseif main == "camerashake" then CameraShake(arg)
    elseif main == "zoom"       then Zoom(arg)
    elseif main == "unzoom"     then Camera.FieldOfView = Effects.fovOriginal
    elseif main == "shake"      then CreateEffect("shake")
    elseif main == "flash"      then CreateEffect("flash")
    elseif main == "smoke"      then CreateEffect("smoke")
    elseif main == "fire"       then CreateEffect("fire")
    elseif main == "lightning"  then CreateEffect("lightning")
    elseif main == "part"       then CreatePart(arg, rest)
    elseif main == "mesh"       then CreateMesh(arg)
    elseif main == "npc"        then CreateNPC(tail)
    elseif main == "car"        then SpawnCar(tail)
    elseif main == "teleport"   then if arg then TeleportToPlace(arg) end
    elseif main == "join"       then if arg then JoinPlace(arg) end
    elseif main == "serverhop"  then ServerHop()
    elseif main == "rejoin"     then Rejoin()
    elseif main == "leave"      then LeaveGame()
    elseif main == "savepos"    then SavePosition()
    elseif main == "loadpos"    then LoadPosition()
    elseif main == "printpos"   then PrintPosition()
    elseif main == "serverinfo" then ServerInfo()
    elseif main == "ping"       then Ping()
    elseif main == "fps"        then FPS()
    elseif main == "give"       then if arg then GiveItem(tail) end
    elseif main == "hat"        then if arg then WearHat(arg) end
    elseif main == "face"       then if arg then WearFace(arg) end
    elseif main == "shirt"      then if arg then WearShirt(arg) end
    elseif main == "pants"      then if arg then WearPants(arg) end
    elseif main == "animation"  then if arg then PlayAnimation(arg) end
    elseif main == "emote"      then if arg then DoEmote(arg) end
    elseif main == "dance"      then DoEmote("dance")
    elseif main == "wave"       then DoEmote("wave")
    elseif main == "point"      then DoEmote("point")
    elseif main == "smile"      then DoEmote("cheer")
    elseif main == "laugh"      then DoEmote("laugh")
    elseif main == "cry"        then DoEmote("cry")
    elseif main == "angry"      then AddNotification("Emote", "angry: not available", 2)
    elseif main == "sleep"      then AddNotification("Emote", "sleep: not available", 2)
    elseif main == "sitdown"    then ToggleSelfSit(true)
    elseif main == "standup"    then ToggleSelfSit(false)
    elseif main == "lookat"     then if arg then LookAtPlayer(arg) end
    elseif main == "unlookat"   then UnlookAt()
    elseif main == "stare"      then if arg then LookAtPlayer(arg) end
    elseif main == "follow"     then if arg then FollowPlayer(arg) end
    elseif main == "unfollow"   then Unfollow()
    elseif main == "orbit"      then if arg then OrbitPlayer(arg) end
    elseif main == "unorbit"    then Unorbit()
    elseif main == "waypoint"   then
        if C.parts[2] and C.parts[3] and C.parts[4] then
            TeleportToCoords(C.parts[2], C.parts[3], C.parts[4])
        end
    elseif main == "navigate"   then
        if C.parts[2] and C.parts[3] and C.parts[4] then
            TeleportToCoords(C.parts[2], C.parts[3], C.parts[4])
        end
    elseif main == "commands" then
        local real, larp = {}, {}
        for _, cmd in ipairs(AllCommands) do
            if LarpOnlyCommands[cmd] then table.insert(larp, cmd)
            else table.insert(real, cmd) end
        end
        AddNotification("Commands (real)", table.concat(real, ", "), 15)
        AddNotification("Commands (larp)", table.concat(larp, ", "), 15)
    elseif main == "settings" then
        local s = table.concat({
            "Speed: " .. (activeSpeed or "Default"),
            "Fly: " .. (Effects.flyEnabled and ("ON " .. Effects.flySpeed) or "OFF"),
            "Noclip: " .. (Effects.noclipEnabled and "ON" or "OFF"),
            "God: " .. (Effects.godEnabled and "ON" or "OFF"),
            "Invisible: " .. (Effects.invisibleEnabled and "ON" or "OFF"),
            "KillAura: " .. (Effects.killauraEnabled and "ON" or "OFF"),
            "Aimbot: " .. (Effects.aimbotEnabled and "ON" or "OFF"),
            "AutoFarm: " .. (Effects.autofarmEnabled and "ON" or "OFF"),
        }, "\n")
        AddNotification("Settings", s, 8)
    else
        LarpRun(main, tail)
    end
end

-- ===================== UI EVENTS =====================
EnterBtn.MouseButton1Click:Connect(function()
    if CmdInput.Text ~= "" then ExecuteCommand(CmdInput.Text) end
    CmdUIContainer.Visible = false
end)
CmdInput.FocusLost:Connect(function(enterPressed)
    if enterPressed and CmdInput.Text ~= "" then ExecuteCommand(CmdInput.Text) end
    CmdUIContainer.Visible = false
end)

-- ===================== DRAGGABLE =====================
local function MakeDraggable(frame, onClick)
    local dragging = false
    local dragInput, dragStart, startPos
    local moved = false

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            if math.abs(delta.X) > 4 or math.abs(delta.Y) > 4 then moved = true end
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if dragging
        and (input.UserInputType == Enum.UserInputType.MouseButton1
             or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            if not moved and onClick then onClick() end
        end
    end)
end

local function CreateIcon(letter, position)
    local icon = Instance.new("TextButton")
    icon.Name = "Icon_" .. letter
    icon.Parent = ScreenGui
    icon.Size = UDim2.new(0, 46, 0, 46)
    icon.Position = position
    icon.BackgroundColor3 = Theme.Background
    icon.Text = letter
    icon.TextColor3 = Theme.Text
    icon.TextSize = 22
    icon.Font = Enum.Font.GothamBold
    icon.AutoButtonColor = false
    icon.ZIndex = 100
    Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", icon)
    stroke.Color = Theme.Border
    stroke.Thickness = 2
    local inner = Instance.new("Frame", icon)
    inner.Size = UDim2.new(1, -6, 1, -6)
    inner.Position = UDim2.new(0, 3, 0, 3)
    inner.BackgroundColor3 = Theme.Panel
    inner.ZIndex = 99
    Instance.new("UICorner", inner).CornerRadius = UDim.new(1, 0)
    return icon
end

local mIcon = CreateIcon("m", UDim2.new(0.5, -50, 0, 10))
local dIcon = CreateIcon("d", UDim2.new(0.5,   4, 0, 10))

local function ToggleUI()
    CmdUIContainer.Visible = not CmdUIContainer.Visible
    if CmdUIContainer.Visible then
        UpdateSuggestions()
        CmdInput.Text = ""
        task.wait()
        CmdInput:CaptureFocus()
    end
end

-- ===================== ПАНЕЛЬ ДРУЗЕЙ =====================
local FriendsPanel = CreateFrame(ScreenGui, UDim2.new(0, 280, 0, 180), UDim2.new(0.5, -140, 0.5, -90), Theme.Background, 8, 0.05)
FriendsPanel.Visible = false
FriendsPanel.ZIndex = 60
local FriendsStroke = Instance.new("UIStroke", FriendsPanel)
FriendsStroke.Color = Theme.Border
FriendsStroke.Transparency = 0.3

local FriendsTitle = Instance.new("TextLabel", FriendsPanel)
FriendsTitle.Size = UDim2.new(1, -20, 0, 30)
FriendsTitle.Position = UDim2.new(0, 10, 0, 8)
FriendsTitle.BackgroundTransparency = 1
FriendsTitle.Text = "max denis admin — команда"
FriendsTitle.TextColor3 = Theme.Text
FriendsTitle.TextSize = 13
FriendsTitle.Font = Enum.Font.GothamBold
FriendsTitle.TextXAlignment = Enum.TextXAlignment.Left

local FriendsList = {
    {name = "gok_gok008", role = "друг"},
    {name = "folix_izi",  role = "создатель"},
    {name = "vano639462", role = "фанат телепузиков"},
}

for i, entry in ipairs(FriendsList) do
    local row = CreateFrame(FriendsPanel, UDim2.new(1, -20, 0, 36), UDim2.new(0, 10, 0, 40 + (i - 1) * 42), Theme.Panel, 6, 0.2)
    local rowStroke = Instance.new("UIStroke", row)
    rowStroke.Color = Theme.Border
    rowStroke.Transparency = 0.6

    local nameLbl = Instance.new("TextLabel", row)
    nameLbl.Size = UDim2.new(0.6, 0, 1, 0)
    nameLbl.Position = UDim2.new(0, 10, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = entry.name
    nameLbl.TextColor3 = Theme.Text
    nameLbl.TextSize = 13
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left

    local roleLbl = Instance.new("TextLabel", row)
    roleLbl.Size = UDim2.new(0.4, -10, 1, 0)
    roleLbl.Position = UDim2.new(0.6, 0, 0, 0)
    roleLbl.BackgroundTransparency = 1
    roleLbl.Text = entry.role
    roleLbl.TextColor3 = Theme.TextGray
    roleLbl.TextSize = 11
    roleLbl.Font = Enum.Font.Gotham
    roleLbl.TextXAlignment = Enum.TextXAlignment.Right
end

local function ToggleFriends()
    FriendsPanel.Visible = not FriendsPanel.Visible
end

MakeDraggable(mIcon, ToggleUI)
MakeDraggable(dIcon, ToggleFriends)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Semicolon then
        ToggleUI()
    end
end)

-- ===================== РЕСПАВН (fix #20, #21) =====================
local function ReapplyEffects(char)
    local humanoid = char:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    if activeSpeed              then humanoid.WalkSpeed = activeSpeed end
    if Effects.godEnabled       then ToggleGod(true) end
    if Effects.superjumpEnabled then ToggleSuperJump(true) end
    if Effects.nofallEnabled    then ToggleNoFall(true) end
    if Effects.invisibleEnabled then ToggleInvisible(true) end
    if Effects.noclipEnabled    then ToggleNoclip(true) end
    if Effects.infjumpEnabled   then ToggleInfJump(true) end
    if Effects.bhopEnabled      then ToggleBHop(true) end
    if Effects.spinbotEnabled   then ToggleSpinBot(true) end
    if Effects.killauraEnabled  then ToggleKillAura(true) end
    if Effects.aimbotEnabled    then ToggleAimbot(true) end
    if Effects.autofarmEnabled  then ToggleAutoFarm(true) end
    if Effects.loopkillEnabled  then ToggleLoopKill(true) end
    if Effects.loopflingEnabled then ToggleLoopFling(true) end
    if Effects.antiafkEnabled   then ToggleAntiAFK(true) end
    if Effects.espEnabled       then ToggleESP(true) end
    if Effects.wallhackEnabled  then ToggleWallhack(true) end
    if Effects.xrayEnabled      then ToggleXray(true) end
    if Effects.followPlayer     then FollowPlayer(Effects.followPlayer.Name) end
    if Effects.orbitPlayer      then OrbitPlayer(Effects.orbitPlayer.Name) end
    if Effects.lookAtPlayer     then LookAtPlayer(Effects.lookAtPlayer.Name) end
end

Player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    NoclipState       = {}
    InvisibleState    = {}
    OrigTransparency  = {}
    OrigColor         = {}
    OrigMaterial      = {}
    OrigReflectance   = {}
    OriginalSizes     = {}
    OriginalHeadSize  = {}
    OriginalLTM       = {}
    OriginalGod       = nil
    OriginalJumpPower = nil
    OriginalFallingDown = nil

    ReapplyEffects(char)

    local humanoid = char:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid.Died:Connect(function()
            if Effects.flyEnabled    then StopFly() end
            if Effects.viewingPlayer then DisableView() end
            if Effects.spyPlayer     then DisableSpy() end
        end)
    end
end)

AddNotification("max denis admin",
    "Loaded • V2.6.2 Fully Fixed\nClick 'm' — команды\nClick 'd' — команда\nDrag icons to move\nType 'commands' for list",
    6)
return {}
