-- FOLIX MONTHLY KEY (UTC) from October 2026 through September 2029.
-- Each month uses exactly the key in the user-provided table.
-- Client-side access gates can be inspected and bypassed: this is not DRM.
do
    local P=game:GetService('Players')
    local player=P.LocalPlayer
    if not player then return end
    -- Fixed list of monthly keys, 2026-10 through 2029-09 (UTC).
    local MONTHLY_KEYS = {
            ['2026-10']='XLPH-2KBZ-6LZB',
            ['2026-11']='8Y82-MLJ4-9NRP',
            ['2026-12']='HCRL-9NR8-CPH3',
            ['2027-01']='TR95-UPYB-GR9E',
            ['2027-02']='45SP-FQ7F-KSZS',
            ['2027-03']='EJB8-2SDJ-NUR6',
            ['2027-04']='PWUS-MTLN-SWHJ',
            ['2027-05']='YBDB-9UTR-VXAV',
            ['2027-06']='APVV-UW2V-YZ29',
            ['2027-07']='K4EE-FX9Y-42SM',
            ['2027-08']='UGXY-2ZG4-74JZ',
            ['2027-09']='6VGH-N2P7-A5AC',
            ['2027-10']='F9Z3-93WB-E72Q',
            ['2027-11']='RNJL-U55E-H8S4',
            ['2027-12']='2226-F6BJ-LAJG',
            ['2028-01']='BEKP-27JM-QCAT',
            ['2028-02']='MT49-N9RR-TD27',
            ['2028-03']='W7MS-9AYU-WFSK',
            ['2028-04']='7L6C-UC7X-2GJX',
            ['2028-05']='HYPV-FDE3-5JAA',
            ['2028-06']='SD7F-2EM6-8K2N',
            ['2028-07']='4RQY-NGUA-BMS2',
            ['2028-08']='D69J-9H3D-FPJE',
            ['2028-09']='NJS3-UJ9H-JQAR',
            ['2028-10']='YXBM-FLGL-MS25',
            ['2028-11']='9BT6-2MPQ-RTSH',
            ['2028-12']='JQCQ-NPWT-UVJV',
            ['2029-01']='U4V9-9Q5X-XWA8',
            ['2029-02']='5GET-URC2-3Y2L',
            ['2029-03']='FVXC-FTK6-6ZSY',
            ['2029-04']='Q9GW-2US9-93JC',
            ['2029-05']='ZNYF-NVZD-D5AP',
            ['2029-06']='B2HZ-9X7G-G623',
            ['2029-07']='LF2J-UYEL-K8SF',
            ['2029-08']='VTK4-F2MP-P9JT',
            ['2029-09']='784M-33UT-SBA6',
    }
    local function currentKey()
        local now=os.date('!*t',os.time())
        return MONTHLY_KEYS[string.format('%04d-%02d',now.year,now.month)]
    end
    local parent=player:WaitForChild('PlayerGui')
    local previous=parent:FindFirstChild('FolixMonthlyKeyGate')
    if previous then previous:Destroy() end
    local gui=Instance.new('ScreenGui')
    gui.Name='FolixMonthlyKeyGate'
    gui.ResetOnSpawn=false
    gui.IgnoreGuiInset=false
    gui.DisplayOrder=1000
    gui.Parent=parent
    local frame=Instance.new('Frame')
    frame.Name='KeyWindow'
    frame.AnchorPoint=Vector2.new(.5,.5)
    frame.Position=UDim2.fromScale(.5,.5)
    frame.Size=UDim2.fromOffset(350,225)
    frame.BorderSizePixel=0
    frame.BackgroundColor3=Color3.fromRGB(29,29,33)
    frame.Parent=gui
    Instance.new('UICorner',frame).CornerRadius=UDim.new(0,12)
    local stroke=Instance.new('UIStroke',frame)
    stroke.Color=Color3.fromRGB(210,210,210)
    stroke.Thickness=1.5
    local scale=Instance.new('UIScale',frame)
    local camera=workspace.CurrentCamera
    local function resize()
        local view=camera and camera.ViewportSize or Vector2.new(800,600)
        scale.Scale=math.clamp(math.min((view.X-24)/350,(view.Y-24)/225),.35,1)
    end
    resize()
    local sizeConnection=camera and camera:GetPropertyChangedSignal('ViewportSize'):Connect(resize)
    local function label(name,value,y,height,size,color)
        local t=Instance.new('TextLabel')
        t.Name=name;t.BackgroundTransparency=1
        t.Position=UDim2.fromOffset(14,y);t.Size=UDim2.new(1,-28,0,height)
        t.Text=value;t.Font=Enum.Font.GothamBold;t.TextSize=size
        t.TextColor3=color or Color3.fromRGB(245,245,245)
        t.TextWrapped=true;t.Parent=frame
        return t
    end
    label('Title','FOLIX  •  KEY SYSTEM',12,35,21)
    label('Subtitle','Ключи: октябрь 2026 — сентябрь 2029 (UTC)',49,32,12,Color3.fromRGB(184,184,194))
    local input=Instance.new('TextBox')
    input.Name='KeyInput';input.ClearTextOnFocus=false
    input.PlaceholderText='XXXX-XXXX-XXXX';input.Text=''
    input.Size=UDim2.new(1,-28,0,42)
    input.Position=UDim2.fromOffset(14,88)
    input.BackgroundColor3=Color3.fromRGB(52,52,58)
    input.TextColor3=Color3.fromRGB(255,255,255)
    input.PlaceholderColor3=Color3.fromRGB(165,165,170)
    input.Font=Enum.Font.Code;input.TextSize=19;input.Parent=frame
    Instance.new('UICorner',input).CornerRadius=UDim.new(0,7)
    local enter=Instance.new('TextButton')
    enter.Name='Unlock';enter.Text='АКТИВИРОВАТЬ'
    enter.Font=Enum.Font.GothamBold;enter.TextSize=15
    enter.TextColor3=Color3.fromRGB(30,30,30)
    enter.BackgroundColor3=Color3.fromRGB(238,238,238)
    enter.Position=UDim2.fromOffset(14,141)
    enter.Size=UDim2.new(1,-28,0,40);enter.Parent=frame
    Instance.new('UICorner',enter).CornerRadius=UDim.new(0,7)
    local feedback=label('Status','Введи ключ этого месяца',187,27,12,Color3.fromRGB(180,180,190))
    local unlocked=false
    local event=Instance.new('BindableEvent')
    local function checkKey()
        local cleaned=input.Text:upper():gsub('%s+','')
        if currentKey() and cleaned==currentKey() then
            unlocked=true
            event:Fire()
        else
            feedback.Text=currentKey() and 'Неверный ключ для текущего месяца' or 'Срок списка ключей закончился'
            feedback.TextColor3=Color3.fromRGB(255,116,116)
        end
    end
    enter.Activated:Connect(checkKey)
    input.FocusLost:Connect(function(submitted) if submitted then checkKey() end end)
    event.Event:Wait()
    if sizeConnection then sizeConnection:Disconnect() end
    event:Destroy()
    gui:Destroy()
end

-- FOLIX pink reference GUI, rebuilt from user-provided visual. Original mechanics preserved.
-- Legends Battleground | XDev-inspired menu (independent implementation)
-- Local client script. Visual hitbox is NOT guaranteed to extend server hit range.
-- V16: Larger anime background; M1 zone visibility separate from targeting; zone is acquisition radius, not damage range.
-- Re-run safely replaces prior instance of THIS UI only.
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local UIS = game:GetService('UserInputService')
local Workspace = game:GetService('Workspace')
local Lighting = game:GetService('Lighting')
local CoreGui = game:GetService('CoreGui')
local TextChatService = game:GetService('TextChatService')
local me = Players.LocalPlayer
local old = CoreGui:FindFirstChild('LegendsXDevReplicaV3')
if old then old:Destroy() end
if getgenv and getgenv().LegendsXDevReplicaStop then pcall(getgenv().LegendsXDevReplicaStop) end
local state = {
    catch=false, zone=50, zoneAlpha=1, showCatchZone=false, approach=2.4, followHeight=0,
    hitbox=false, hitSize=20, hitAlpha=.9, realParts=false,
    esp=false, speed=false, speedValue=35, jump=false, jumpPower=60,
    fullbright=false, followOnlyOnClick=true,
    fly=false, flySpeed=48, flyDistance=20, basicJump=false, noclip=false, teleportTarget=nil,
    shiftLock=false, watchIdle=false, coolIdle=false, customWalk=false, uwu=true,
    followRange=300, flyHeight=5, windowAlpha=.28, ignored={}, manualIgnore={}, friendAuto={}, friendPending={},
}
local originalParts, boxes, espGui = {}, {}, {}
local waypointList={}
local savedPosition=nil
local tpSelected=nil
local currentPage='Home'
local selectedGame='Legends Battleground' -- Legends / JJS / TSB / Examination
local selectedTheme='Cinema'
local examSafeCFrame=nil
local examAntiVoid=false
local lastVoidRescue=0
local cinemaSoundEnabled=true
local npcEnabled=false
local npcEspEnabled=false
local npcEspObjects={}
local npcSize=4
local npcOriginals={}
local flyVelocity=nil
local collisionOld={}
local lightingOld={Brightness=Lighting.Brightness, ClockTime=Lighting.ClockTime, FogEnd=Lighting.FogEnd}
local catchZone
local connections = {}
local actionPose = nil
local poseJoints, poseBase = {}, {}
local customWalkTrack, customWalkHum, customWalkAnimation = nil, nil, nil
local shiftHum, shiftAutoRotate, shiftCameraOffset = nil, nil, nil
local originalMouseBehavior = UIS.MouseBehavior
local walkJoints = {}
local function resetWalkJoints()
    for joint,base in pairs(walkJoints) do
        if joint and joint.Parent then joint.C0=base end
    end
    table.clear(walkJoints)
end
local ANIM_R6_WALK = 'rbxassetid://180426354' -- official Roblox R6 walk loop
local function stopCustomWalk()
    if customWalkTrack then pcall(function() customWalkTrack:Stop(.18); customWalkTrack:Destroy() end) end
    if customWalkAnimation then customWalkAnimation:Destroy() end
    customWalkTrack,customWalkAnimation,customWalkHum=nil,nil,nil
end
local function resetPose()
    for joint, initial in pairs(poseBase) do
        if joint and joint.Parent then pcall(function()joint.C0=initial end) end
    end
    table.clear(poseBase)
    table.clear(poseJoints)
    actionPose=nil
end
local function setPose(name)
    resetPose()
    if not name then return end
    local ch=me.Character
    local h=ch and ch:FindFirstChildOfClass('Humanoid')
    local torso=ch and ch:FindFirstChild('Torso')
    if not torso or not h or h.RigType~=Enum.HumanoidRigType.R6 then return end
    for _,jointName in ipairs({'Right Shoulder','Left Shoulder','Neck','RootJoint'}) do
        local joint=torso:FindFirstChild(jointName)
        if not joint and jointName=='RootJoint' then
            local root=ch:FindFirstChild('HumanoidRootPart')
            joint=root and root:FindFirstChild('RootJoint')
        end
        if joint then poseJoints[jointName]=joint;poseBase[joint]=joint.C0 end
    end
    actionPose=name
end
local function releaseShiftLock()
    if shiftHum and shiftHum.Parent then
        shiftHum.AutoRotate=shiftAutoRotate
        shiftHum.CameraOffset=shiftCameraOffset
    end
    shiftHum,shiftAutoRotate,shiftCameraOffset=nil,nil,nil
    if UIS.MouseBehavior==Enum.MouseBehavior.LockCenter then UIS.MouseBehavior=originalMouseBehavior end
end

local active = true
local ui = Instance.new('ScreenGui')
ui.Name='LegendsXDevReplicaV3'; ui.ResetOnSpawn=false; ui.IgnoreGuiInset=true; ui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ui.Parent=CoreGui
ui.Enabled=true
local function new(cl, props, parent)
    local o=Instance.new(cl)
    for k,v in pairs(props or {}) do o[k]=v end
    if parent then o.Parent=parent end
    return o
end
local function round(x,r)
    new('UICorner',{CornerRadius=UDim.new(0,r or 8)},x)
end
local function styleStroke(x,color,t)
    new('UIStroke',{Color=color or Color3.fromRGB(70,75,84),Transparency=t or .55,Thickness=1},x)
end
local bg=Color3.fromRGB(22,8,25)
local panel=Color3.fromRGB(57,22,53)
local white=Color3.fromRGB(255,221,242)
local muted=Color3.fromRGB(241,169,219)
local blue=Color3.fromRGB(246,55,164)
-- Mobile fix: measure the ACTUAL GUI canvas, not camera.ViewportSize.
-- Some mobile executors report camera dimensions in a different scale.
local screenRoot = new('Frame', {
    Name='ScreenRoot', BackgroundTransparency=1, BorderSizePixel=0,
    Size=UDim2.fromScale(1,1), Position=UDim2.fromScale(0,0),
    Active=false
}, ui)
local window=new('Frame',{Name='Window',Size=UDim2.fromOffset(850,580),
    AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
    BackgroundColor3=bg,BackgroundTransparency=.08,BorderSizePixel=0},screenRoot)
local responsiveScale = Instance.new('UIScale')
responsiveScale.Name='ResponsiveScale'
responsiveScale.Scale=0.5 -- safe initial value before the first layout pass
responsiveScale.Parent=window
local function updateResponsiveScale()
    local canvas=screenRoot.AbsoluteSize
    local camera=Workspace.CurrentCamera
    local view=camera and camera.ViewportSize or canvas
    -- Use the smaller valid viewport to handle mobile executor scaling.
    local w=(canvas.X>50 and canvas.X or view.X)
    local h=(canvas.Y>50 and canvas.Y or view.Y)
    if view.X>50 and view.Y>50 then
        w=math.min(w,view.X); h=math.min(h,view.Y)
    end
    if w<50 or h<50 then return end
    local margin=UIS.TouchEnabled and 36 or 36
    responsiveScale.Scale=math.clamp(math.min((w-margin)/850,(h-margin)/580),.08,1)
    -- Do not reset position on viewport updates: that causes visible jumps.
end
local rootSizeConnection=screenRoot:GetPropertyChangedSignal('AbsoluteSize'):Connect(updateResponsiveScale)
ui.Destroying:Connect(function() rootSizeConnection:Disconnect() end)
task.defer(updateResponsiveScale)
task.delay(.5,updateResponsiveScale)
if Workspace.CurrentCamera then
    table.insert(connections,Workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(updateResponsiveScale))
end
round(window,12);styleStroke(window,Color3.fromRGB(250,48,164),.03)
local title=new('TextLabel',{BackgroundTransparency=1,Text='',TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.GothamBold,TextSize=20,TextColor3=blue,Position=UDim2.fromOffset(18,8),Size=UDim2.new(1,-90,0,28)},window)
local close=new('TextButton',{Text='×',Font=Enum.Font.Gotham,TextSize=24,TextColor3=Color3.fromRGB(255,111,216),BackgroundTransparency=1,Position=UDim2.new(1,-40,0,5),Size=UDim2.fromOffset(30,30)},window)
local hideBtn=new('TextButton',{Text='−',Font=Enum.Font.Gotham,TextSize=21,TextColor3=Color3.fromRGB(255,111,216),BackgroundTransparency=1,Position=UDim2.new(1,-112,0,5),Size=UDim2.fromOffset(30,30)},window)
-- Three top-right window controls: minimize, maximize/restore, close.
local maximizeBtn=new('TextButton',{
    Name='MaximizeRestore',Text='□',Font=Enum.Font.GothamBold,TextSize=23,
    TextColor3=Color3.fromRGB(255,111,216),BackgroundTransparency=1,
    Position=UDim2.new(1,-76,0,5),Size=UDim2.fromOffset(30,30)
},window)
-- Keep window controls visible above the anime image and all overlays.
local controlsBar=new('Frame',{
    Name='WindowControlsBar',BackgroundColor3=Color3.fromRGB(24,7,27),
    BackgroundTransparency=.08,BorderSizePixel=0,
    Position=UDim2.new(1,-124,0,3),Size=UDim2.fromOffset(120,38),
    ZIndex=60,Active=false
},window)
round(controlsBar,9)
styleStroke(controlsBar,Color3.fromRGB(255,73,183),.05)
for _,button in ipairs({hideBtn,maximizeBtn,close}) do
    button.ZIndex=70
    button.BackgroundTransparency=1
    button.TextColor3=Color3.fromRGB(255,115,220)
    button.TextStrokeColor3=Color3.fromRGB(65,0,43)
    button.TextStrokeTransparency=.3
    button.Active=true
    button.AutoButtonColor=true
end
-- Ensure the three controls sit inside the top-right strip.
hideBtn.Position=UDim2.new(1,-117,0,7)
maximizeBtn.Position=UDim2.new(1,-79,0,7)
close.Position=UDim2.new(1,-41,0,7)
local expanded=false
local normalWindowPosition=window.Position
local normalWindowSize=window.Size
maximizeBtn.Activated:Connect(function()
    expanded=not expanded
    -- Keep the same design proportions; change only the UI scale.
    if expanded then
        responsiveScale.Scale=math.min(1,responsiveScale.Scale*1.1)
        maximizeBtn.Text='▣'
    else
        maximizeBtn.Text='□'
        updateResponsiveScale()
    end
    window.Position=UDim2.fromScale(.5,.5)
end)
local side=new('Frame',{BackgroundColor3=Color3.fromRGB(20,8,25),BackgroundTransparency=.8,BorderSizePixel=0,Position=UDim2.fromOffset(12,10),Size=UDim2.fromOffset(172,555)},window);round(side,8)
local content=new('Frame',{BackgroundTransparency=1,Position=UDim2.fromOffset(215,45),Size=UDim2.fromOffset(614,522)},window)
-- Anime portrait with tongue, EMBEDDED inside this Lua script.
-- Works with executors supporting writefile + getcustomasset/getsynasset.
local ANIME_FALLBACK = 'rbxassetid://6675147486'
local encodedAnime = [[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]]
local encodedWink = [[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]]
local function decodeBase64(s)
    if crypt and crypt.base64 and crypt.base64.decode then
        local ok, result = pcall(crypt.base64.decode, s)
        if ok and result then return result end
    end
    local alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    s=s:gsub('[^'..alphabet..'=]', '')
    local bits=s:gsub('.', function(c)
        if c=='=' then return '' end
        local n=alphabet:find(c,1,true)-1
        local out=''
        for i=6,1,-1 do out=out..(n%2^i-n%2^(i-1)>0 and '1' or '0') end
        return out
    end)
    return bits:gsub('%d%d%d%d%d%d%d%d',function(byte)
        return string.char(tonumber(byte,2))
    end)
end
local animeImage=ANIME_FALLBACK
local assetLoader=getcustomasset or getsynasset
if writefile and assetLoader then
    local ok, result=pcall(function()
        local filename='folix_ref_anime_v3.jpg'
        writefile(filename,decodeBase64(encodedAnime))
        return assetLoader(filename)
    end)
    if ok and result then animeImage=result
    else warn('[FOLIX] Custom anime asset unavailable; showing fallback image') end
else
    warn('[FOLIX] Executor needs writefile + getcustomasset for embedded anime art')
end
encodedAnime=nil
local winkImage=animeImage
if type(writefile)=='function' and assetLoader then
    local ok, result=pcall(function()
        local filename='folix_ref_wink_v3.jpg'
        writefile(filename,decodeBase64(encodedWink))
        return assetLoader(filename)
    end)
    if ok and result then winkImage=result end
end
encodedWink=nil
local backgroundArt=new('ImageLabel',{
    Name='AnimeBackground',BackgroundTransparency=1,BorderSizePixel=0,
    Image=animeImage,ImageTransparency=.02,ScaleType=Enum.ScaleType.Stretch,
    Position=UDim2.fromScale(0,0),Size=UDim2.fromScale(1,1),ZIndex=1
},window)
round(backgroundArt,10)

-- Second THEME: the exact user-provided Absolute Cinema meme.
local CINEMA_IMG_B64 = [[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]]
local CINEMA_SOUND_B64 = [[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]]
local function fileAsset(filename, payload)
    if type(writefile) ~= 'function' then return nil end
    local provider=(type(getcustomasset)=='function' and getcustomasset)
        or (type(getsynasset)=='function' and getsynasset)
    if not provider then return nil end
    local ok, asset = pcall(function()
        writefile(filename, decodeBase64(payload))
        return provider(filename)
    end)
    if ok then return asset end
    warn('[FOLIX] Cannot load '..filename..': '..tostring(asset))
    return nil
end
local cinemaImage=fileAsset('folix_absolute_cinema.jpg',CINEMA_IMG_B64)
CINEMA_IMG_B64=nil
local cinemaSound=Instance.new('Sound')
cinemaSound.Name='AbsoluteCinemaSound'
cinemaSound.Volume=.65
cinemaSound.SoundId=fileAsset('folix_absolute_cinema.mp3',CINEMA_SOUND_B64) or ''
cinemaSound.Parent=ui
CINEMA_SOUND_B64=nil

local backgroundVeil=new('Frame',{
    Name='RoseGlass',BackgroundColor3=Color3.fromRGB(64,35,61),
    BackgroundTransparency=.95,BorderSizePixel=0,
    Position=UDim2.fromScale(0,0),Size=UDim2.fromScale(1,1),ZIndex=2
},window)
round(backgroundVeil,10)
content.ZIndex=3
side.ZIndex=3
-- Decorations are not interactive and never intercept menu touches.
local neonAccent = new('TextLabel', {
    Name='NeonAccent', Text='♥ UwU ♡', BackgroundTransparency=1,
    TextColor3=Color3.fromRGB(255,74,181), TextSize=25,
    Font=Enum.Font.GothamBold, Position=UDim2.fromOffset(335,5),
    Size=UDim2.fromOffset(190,34), ZIndex=2
}, window)

local heading=new('TextLabel',{Text='Combat',BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=22,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=white,Size=UDim2.new(1,0,0,34)},content)
local scroll=new('ScrollingFrame',{BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=muted,Position=UDim2.fromOffset(0,40),Size=UDim2.new(1,0,1,-40),CanvasSize=UDim2.new(0,0,0,0)},content)
local layout=new('UIListLayout',{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,7)},scroll)
local function refreshCanvas() scroll.CanvasSize=UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+12) end
layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(refreshCanvas)
local pages={}
local sliderConnections={}
local function category(name)
    local f=new('TextLabel',{BackgroundTransparency=1,Text=name,Font=Enum.Font.GothamBold,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=white,Size=UDim2.new(1,-3,0,25)},scroll)
    return f
end
local function note(msg)
    local f=new('TextLabel',{BackgroundTransparency=1,Text=msg,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,Font=Enum.Font.Gotham,TextSize=12,TextColor3=muted,Size=UDim2.new(1,-5,0,50)},scroll)
    return f
end
-- Original user-provided UwU recording embedded in this Lua file.
local UWU_VOICE_B64 = [[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]]
local uwuVoice = Instance.new('Sound')
uwuVoice.Name = 'FolixUwUVoice'
uwuVoice.Volume = 0.9
uwuVoice.Parent = ui
local voiceReady = false
if type(writefile)=='function' then
    local assetFn = (type(getcustomasset)=='function' and getcustomasset)
        or (type(getsynasset)=='function' and getsynasset)
    if assetFn then
        local ok, asset = pcall(function()
            local filename = 'folix_uwu_hannah.mp3'
            writefile(filename, decodeBase64(UWU_VOICE_B64))
            return assetFn(filename)
        end)
        if ok and asset then
            uwuVoice.SoundId = asset
            voiceReady = true
        end
    end
end
if not voiceReady then
    -- No fake beep: set ORIGINAL_UWU_SOUND_ID below to the actual voice asset.
    uwuVoice.SoundId = ''
end
-- Insert the Roblox audio ID of the ORIGINAL streamer 'uwu' here.
-- An exact original recording cannot be recreated from a text description.
local ORIGINAL_UWU_SOUND_ID = '' -- example: 'rbxassetid://123456789'
if ORIGINAL_UWU_SOUND_ID ~= '' then uwuVoice.SoundId = ORIGINAL_UWU_SOUND_ID end

-- On each switch, change the SAME ImageLabel for 1 second.
-- Position, size and crop stay unchanged. No emoji overlays.
local winkToken = 0
local function wink()
    winkToken += 1
    local token = winkToken
    backgroundArt.Image = winkImage
    task.delay(1, function()
        if winkToken == token and backgroundArt.Parent then
            backgroundArt.Image = animeImage
        end
    end)
end
local function playThemeSound()
    if selectedTheme=='Cinema' then
        if cinemaSoundEnabled and cinemaSound.SoundId~='' then
            cinemaSound:Stop();cinemaSound.TimePosition=0;cinemaSound:Play()
        end
    else
        if state.uwu and uwuVoice.SoundId~='' then
            uwuVoice:Stop();uwuVoice.TimePosition=0;uwuVoice:Play()
        end
    end
end

local function playUwu()
    if not ui.Parent then return end
    if selectedTheme=='UwU' then wink() end
    playThemeSound()
end
-- Remember original accent colors. Cinema is monochrome, UwU restores them.
local originalUiColors=setmetatable({}, {__mode='k'})
local COLOR_FIELDS={
    BackgroundColor3=true, TextColor3=true, TextStrokeColor3=true,
    ImageColor3=true, ScrollBarImageColor3=true, Color=true,
}
local function cinemaColor(c)
    local h,s,v=c:ToHSV()
    -- In Cinema theme even pink/purple accents become neutral grays.
    if s>.075 then
        local lum=(c.R*.2126+c.G*.7152+c.B*.0722)
        local gray=math.clamp(lum*.8+v*.2,.06,1)
        return Color3.new(gray,gray,gray)
    end
    return c
end
local function recolorUi(root, cinematic)
    local nodes={root}
    for _,obj in ipairs(root:GetDescendants()) do table.insert(nodes,obj) end
    for _,obj in ipairs(nodes) do
        local saved=originalUiColors[obj]
        if not saved then saved={};originalUiColors[obj]=saved end
        for field in pairs(COLOR_FIELDS) do
            local supports=(field=='Color' and obj:IsA('UIStroke'))
                or (field=='BackgroundColor3' and obj:IsA('GuiObject'))
                or (field=='TextColor3' and (obj:IsA('TextLabel') or obj:IsA('TextButton') or obj:IsA('TextBox')))
                or (field=='TextStrokeColor3' and (obj:IsA('TextLabel') or obj:IsA('TextButton') or obj:IsA('TextBox')))
                or (field=='ImageColor3' and (obj:IsA('ImageLabel') or obj:IsA('ImageButton')))
                or (field=='ScrollBarImageColor3' and obj:IsA('ScrollingFrame'))
            if supports then
                if saved[field]==nil then saved[field]=obj[field] end
                if cinematic then
                    obj[field]=cinemaColor(obj[field])
                else
                    -- Restore original UwU palette instead of retaining Cinema grays.
                    obj[field]=saved[field]
                end
            end
        end
    end
end
-- Theme colors updated on existing elements. This does not touch gameplay callbacks.
local function applyTheme(theme)
    cinemaSound:Stop()
    uwuVoice:Stop()
    selectedTheme=theme
    local pink=(theme=='UwU')
    local accent=pink and Color3.fromRGB(246,55,164) or Color3.fromRGB(240,240,240)
    local panels=pink and Color3.fromRGB(57,22,53) or Color3.fromRGB(37,37,40)
    local foreground=pink and Color3.fromRGB(255,221,242) or Color3.fromRGB(252,252,252)
    local soft=pink and Color3.fromRGB(241,169,219) or Color3.fromRGB(198,198,200)
    bg=pink and Color3.fromRGB(22,8,25) or Color3.fromRGB(19,19,21)
    panel=panels;blue=accent;white=foreground;muted=soft
    window.BackgroundColor3=bg
    backgroundArt.Image=pink and animeImage or (cinemaImage or animeImage)
    backgroundArt.ImageTransparency=0
    backgroundVeil.BackgroundColor3=pink and Color3.fromRGB(64,35,61) or Color3.fromRGB(8,8,8)
    backgroundVeil.BackgroundTransparency=pink and .94 or .67
    neonAccent.Text=pink and '♥ UwU ♡' or 'ABSOLUTE CINEMA'
    neonAccent.TextColor3=accent
    for _,o in ipairs(window:GetDescendants()) do
        if o:IsA('TextLabel') or o:IsA('TextButton') then
            if o~=neonAccent and o.Name~='FOLIXLogo' then
                o.TextColor3=foreground
            end
        end
        if o:IsA('Frame') or o:IsA('TextButton') then
            if o.Name=='WindowControlsBar' then
                o.BackgroundColor3=bg
            elseif o.Parent==scroll and o.BackgroundTransparency<.99 then
                o.BackgroundColor3=panels
            end
        end
    end
    -- Apply after all legacy pink style setters. Includes logo, nav, strokes and launcher.
    recolorUi(ui,not pink)
end
local function toggle(label,key)
    local row=new('Frame',{BackgroundColor3=panel,BackgroundTransparency=.35,BorderSizePixel=0,Size=UDim2.new(1,-6,0,43)},scroll);round(row,7)
    new('TextLabel',{Text=label,BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=13,TextColor3=white,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.fromOffset(12,0),Size=UDim2.new(1,-85,1,0)},row)
    local btn=new('TextButton',{BackgroundColor3=state[key] and blue or Color3.fromRGB(72,76,82),Text='',Position=UDim2.new(1,-53,.5,-10),Size=UDim2.fromOffset(39,20)},row);round(btn,10)
    local dot=new('Frame',{BackgroundColor3=Color3.fromRGB(205,211,220),Position=UDim2.fromOffset(state[key] and 21 or 3,3),Size=UDim2.fromOffset(14,14)},btn);round(dot,8)
    btn.MouseButton1Click:Connect(function()
        state[key]=not state[key]
        playUwu()
        btn.BackgroundColor3=state[key] and blue or Color3.fromRGB(72,76,82)
        dot.Position=UDim2.fromOffset(state[key] and 21 or 3,3)
        if selectedTheme=='Cinema' then
            btn.BackgroundColor3=cinemaColor(btn.BackgroundColor3)
        end
        if key=='realParts' or key=='hitbox' then
            for p,s in pairs(originalParts) do
                if p and p.Parent then p.Size=s.size; p.CanCollide=s.collide end
                originalParts[p]=nil
            end
        end
    end)
end
local function slider(label,key,low,high,step)
    local row=new('Frame',{BackgroundColor3=panel,BackgroundTransparency=.35,BorderSizePixel=0,Size=UDim2.new(1,-6,0,55)},scroll);round(row,7)
    new('TextLabel',{Text=label,Font=Enum.Font.Gotham,TextSize=13,TextColor3=white,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.fromOffset(12,3),Size=UDim2.new(.67,0,0,24)},row)
    local value=new('TextLabel',{Text=tostring(state[key]),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=12,TextColor3=muted,TextXAlignment=Enum.TextXAlignment.Right,Position=UDim2.new(.65,0,0,3),Size=UDim2.new(.32,-14,0,24)},row)
    local track=new('Frame',{BackgroundColor3=Color3.fromRGB(79,83,88),BorderSizePixel=0,Position=UDim2.new(0,13,0,37),Size=UDim2.new(1,-27,0,4)},row);round(track,3)
    local fill=new('Frame',{BackgroundColor3=blue,BorderSizePixel=0,Size=UDim2.new((state[key]-low)/(high-low),0,1,0)},track);round(fill,3)
    local dot=new('Frame',{BackgroundColor3=blue,BorderSizePixel=0,Size=UDim2.fromOffset(15,15),Position=UDim2.new((state[key]-low)/(high-low),-7,0,-5)},track);round(dot,8)
    -- Mobile-friendly hit area: the original 4px track was too small to touch.
    local hitArea=new('TextButton',{
        Name='SliderTouchArea',Text='',AutoButtonColor=false,
        BackgroundTransparency=1,BorderSizePixel=0,Active=true,
        Position=UDim2.new(0,7,0,25),Size=UDim2.new(1,-14,0,30),ZIndex=10
    },row)
    local dragging=false
    local activeInput=nil
    local function update(input)
        local t=math.clamp((input.Position.X-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1)
        local v=math.clamp(math.floor((low+t*(high-low))/step+.5)*step,low,high)
        state[key]=v
        value.Text=string.format(step<1 and '%.2f' or '%d',v)
        local exactT=(v-low)/(high-low)
        fill.Size=UDim2.new(exactT,0,1,0)
        dot.Position=UDim2.new(exactT,-7,0,-5)
    end
    hitArea.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true
            activeInput=input
            update(input)
        end
    end)
    local link=UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType==Enum.UserInputType.MouseMovement then
            if activeInput and activeInput.UserInputType==Enum.UserInputType.MouseButton1 then update(input) end
        elseif input.UserInputType==Enum.UserInputType.Touch and input==activeInput then
            update(input)
        end
    end)
    table.insert(sliderConnections,link)
    local stop=UIS.InputEnded:Connect(function(input)
        if input==activeInput or (activeInput and activeInput.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseButton1) then
            dragging=false
            activeInput=nil
        end
    end)
    table.insert(sliderConnections,stop)
end
local function button(label, fn)
    local b=new('TextButton',{Size=UDim2.new(1,-6,0,40),BackgroundColor3=panel,BackgroundTransparency=.45,
        Text='   '..label,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.GothamMedium,
        TextSize=13,TextColor3=white,BorderSizePixel=0},scroll);round(b,7)
    b.MouseButton1Click:Connect(function() playUwu(); local ok,err=pcall(fn);if not ok then warn('[LB] '..tostring(err)) end end)
    return b
end
-- M1 picks nearest available HIT; no AUTO button is displayed.
-- Friends are protected even when they join after the script started.
local function playerOptions()
    local out={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=me then table.insert(out,p.Name) end
    end
    table.sort(out)
    return out
end

-- V11: friend status stays IGNORE; nearest target skips friends and manual ignores.
local friendStatusListeners = {}
local friendChecking = {} -- prevent duplicate asynchronous lookups
local function refreshFriendStatus(p)
    local listener = friendStatusListeners[p]
    if listener then listener() end
end
-- Friends are always protected, even if the HIT/IGNORE button is clicked.
-- While friendship is being checked, the player is temporarily ignored.
local function isProtected(p)
    return p and (state.friendPending[p.UserId] or
        (state.friendAuto[p.UserId] and state.manualIgnore[p.UserId]~=false))
end
local function ignoredTarget(p)
    return not p or state.ignored[p.UserId] or isProtected(p)
end
local function checkFriend(p)
    if not p or p==me or p.Parent~=Players then return end
    local uid=p.UserId
    if friendChecking[uid] then return end
    friendChecking[uid]=true
    -- While the first lookup is pending, keep the target protected.
    -- Rechecks keep the previous result so the UI doesn't flicker.
    if state.friendAuto[uid]==nil and state.friendPending[uid]~=true then
        state.friendPending[uid]=true
        state.ignored[uid]=true
        refreshFriendStatus(p)
    end
    task.spawn(function()
        local ok,friend=pcall(function() return me:IsFriendsWith(uid) end)
        friendChecking[uid]=nil
        if not active or p.Parent~=Players then return end
        if ok then
            state.friendAuto[uid]=(friend==true)
            state.friendPending[uid]=nil
            state.ignored[uid]=(state.manualIgnore[uid]==true or
                (state.friendAuto[uid] and state.manualIgnore[uid]~=false))
        else
            -- Keep this player ignored until friendship can be verified.
            state.friendPending[uid]=true
            state.ignored[uid]=true
            warn('[LB] Friend lookup failed for '..p.Name..'; IGNORE until verified')
        end
        refreshFriendStatus(p)
    end)
end
for _,p in ipairs(Players:GetPlayers()) do
    if p~=me then checkFriend(p) end
end

local function chooser(label,options,selected,fn)
    if #options==0 then button(label..'  →  нет игроков',function() end);return end
    local idx=table.find(options,selected) or 1
    local b=button(label..'  →  '..options[idx],function() end)
    b.MouseButton1Click:Connect(function()
        idx=idx%#options+1
        b.Text='   '..label..'  →  '..options[idx]
        fn(options[idx])
    end)
end
local function myRoot()
    local ch=me.Character
    return ch and ch:FindFirstChild('HumanoidRootPart')
end
local function teleportTo(cf)
    local root=myRoot()
    if root and cf then
        local ch=me.Character
        if ch then ch:PivotTo(cf*CFrame.new(0,3,0)) end
    end
end
local function mapCandidates()
    -- Live map inspection only; NEVER invent coordinates for unfamiliar updates.
    local options={}
    local added={}
    local anchors=Workspace:GetDescendants()
    for _,inst in ipairs(anchors) do
        if #options>=40 then break end
        local lower=string.lower(inst.Name)
        if inst:IsA('BasePart') and inst.Anchored and inst.Size.Magnitude>12 and
            (lower:find('spawn') or lower:find('arena') or lower:find('lobby') or
             lower:find('park') or lower:find('tower') or lower:find('roof') or
             lower:find('bridge') or lower:find('dojo') or lower:find('shop')) then
            local key=inst:GetFullName()
            if not added[key] then
                added[key]=true
                table.insert(options,{label=string.format('%s [%d]',inst.Name,#options+1),pos=inst.Position,instance=inst})
            end
        end
    end
    return options
end
local function clearPage()
    table.clear(friendStatusListeners)
    for _,c in ipairs(sliderConnections) do c:Disconnect() end
    table.clear(sliderConnections)
    for _,ch in ipairs(scroll:GetChildren()) do if ch~=layout then ch:Destroy() end end
    -- Do not force the list to jump to the top on every click.
end
-- Examination leaves Roblox's default camera and rotation in control.
local function enterExamination()
    selectedGame='Examination'
    state.catch=false
    state.shiftLock=false
    releaseShiftLock()
    local hum=me.Character and me.Character:FindFirstChildOfClass('Humanoid')
    if hum then hum.AutoRotate=true; hum.CameraOffset=Vector3.zero end
end
local EXECUTOR_PRESET = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/solarastuff/legendsbattlegrounds/refs/heads/main/legendary.lua"))()'
-- Examination: only NPCs, with reversible local head resizing.
local function resetNpcHeads()
    for head,original in pairs(npcOriginals) do
        if head and head.Parent then pcall(function()
            head.Size=original.size
            head.CanCollide=original.collide
            head.Massless=original.massless
            head.Transparency=original.transparency
        end) end
        npcOriginals[head]=nil
    end
end
local function applyNpc(model)
    if not npcEnabled or not model or not model:IsA('Model') then return end
    if Players:GetPlayerFromCharacter(model) or model==me.Character then return end
    if not model:FindFirstChildOfClass('Humanoid') then return end
    local head=model:FindFirstChild('Head')
    if not head or not head:IsA('BasePart') then return end
    if not npcOriginals[head] then
        npcOriginals[head]={size=head.Size,collide=head.CanCollide,
            massless=head.Massless,transparency=head.Transparency}
    end
    pcall(function()
        head.CanCollide=false
        head.Massless=true
        local wanted=Vector3.new(npcSize,npcSize,npcSize)
        if head.Size~=wanted then head.Size=wanted end
        if head.Transparency~=.5 then head.Transparency=.5 end
    end)
end
local npcResizeScanVersion=0
local function refreshNpc()
    npcResizeScanVersion+=1
    local version=npcResizeScanVersion
    if not npcEnabled then resetNpcHeads();return end
    task.spawn(function()
        local descendants=Workspace:GetDescendants()
        for i,inst in ipairs(descendants) do
            if not active or not npcEnabled or version~=npcResizeScanVersion then return end
            if inst:IsA('Model') then applyNpc(inst) end
            if i%60==0 then task.wait() end
        end
    end)
end
local npcAdded=Workspace.DescendantAdded:Connect(function(obj)
    if not npcEnabled then return end
    if not obj:IsA('Model') and not obj:IsA('Humanoid') and not (obj:IsA('BasePart') and obj.Name=='Head') then return end
    task.defer(function()
        if not active or not npcEnabled then return end
        local m=obj:IsA('Model') and obj or obj:FindFirstAncestorOfClass('Model')
        applyNpc(m)
    end)
end)
table.insert(connections,npcAdded)

-- NPC TP (local): attempt to move a limited number of NPCs in front of the player.
-- Server-owned NPCs may snap back; damage is ALWAYS evaluated by the game server.
local npcGroupEnabled=false
local npcGroupLocation=nil
local npcGroupLast=0
local function bringNpcLocally()
    local ch=me.Character
    local root=ch and ch:FindFirstChild('HumanoidRootPart')
    if not root then return 0 end
    local spot=npcGroupLocation or (root.CFrame*CFrame.new(0,0,-12))
    local seen={}
    local moved=0
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA('Humanoid') and obj.Health>0 then
            local model=obj.Parent
            if model and model:IsA('Model') and model~=ch
                and not Players:GetPlayerFromCharacter(model)
                and model:FindFirstChild('HumanoidRootPart') and not seen[model] then
                seen[model]=true
                moved+=1
                -- Small offsets prevent exact overlap and severe physics collisions.
                local column=(moved-1)%5-2
                local row=math.floor((moved-1)/5)
                pcall(function()
                    model:PivotTo(spot*CFrame.new(column*3,0,-row*3))
                end)
                if moved>=20 then break end
            end
        end
    end
    return moved
end
-- Examination NPC ESP: event-driven tracking instead of scanning the whole map every 2 seconds.
local npcEspScanVersion=0
local npcEspConnections={}
local function disposeNpcEsp(model)
    local items=npcEspObjects[model]
    if not items then return end
    if items.hpConnection then items.hpConnection:Disconnect() end
    if items.maxHpConnection then items.maxHpConnection:Disconnect() end
    if items.ancestryConnection then items.ancestryConnection:Disconnect() end
    if items.highlight then items.highlight:Destroy() end
    if items.label then items.label:Destroy() end
    npcEspObjects[model]=nil
end
local function clearNpcEsp()
    npcEspScanVersion+=1
    for model in pairs(npcEspObjects) do disposeNpcEsp(model) end
end
local function npcEspTarget(model)
    if not model or not model:IsA('Model') or model==me.Character then return nil end
    if Players:GetPlayerFromCharacter(model) then return nil end
    local hum=model:FindFirstChildOfClass('Humanoid')
    local anchor=model:FindFirstChild('Head') or model:FindFirstChild('HumanoidRootPart')
    if hum and hum.Health>0 and anchor and anchor:IsA('BasePart') then return anchor,hum end
end
local function addNpcEsp(model)
    if not active or not npcEspEnabled or selectedGame~='Examination' then return end
    if npcEspObjects[model] then return end
    local head,hum=npcEspTarget(model)
    if not head then return end
    local glow=Instance.new('Highlight')
    glow.Name='FOLIX_Examination_NPC_ESP'
    glow.Adornee=model
    glow.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    glow.FillTransparency=1 -- outline-only ESP: much lower mobile GPU overdraw
    glow.OutlineTransparency=0
    glow.Parent=model
    local bb=Instance.new('BillboardGui')
    bb.Name='FOLIX_NPC_Name'
    bb.AlwaysOnTop=true
    bb.Size=UDim2.fromOffset(180,34)
    bb.StudsOffset=Vector3.new(0,2.4,0)
    bb.Adornee=head
    bb.Parent=ui
    local txt=Instance.new('TextLabel')
    txt.Size=UDim2.fromScale(1,1)
    txt.BackgroundTransparency=1
    txt.Font=Enum.Font.GothamBold
    txt.TextSize=13
    txt.TextStrokeTransparency=.45
    txt.Parent=bb
    local color=selectedTheme=='Cinema' and Color3.fromRGB(235,235,235) or Color3.fromRGB(255,90,177)
    glow.FillColor=color; glow.OutlineColor=color; txt.TextColor3=color
    local items={highlight=glow,label=bb,text=txt}
    npcEspObjects[model]=items
    local lastText=nil
    local function updateHp()
        if not active or not hum.Parent or hum.Health<=0 then
            disposeNpcEsp(model)
            return
        end
        local maxHp=math.max(0,math.floor(hum.MaxHealth+0.5))
        local hp=math.clamp(math.floor(hum.Health+0.5),0,maxHp)
        local value=model.Name..'  '..hp..'/'..maxHp
        if value~=lastText and txt.Parent then txt.Text=value;lastText=value end
    end
    items.hpConnection=hum.HealthChanged:Connect(updateHp)
    items.maxHpConnection=hum:GetPropertyChangedSignal('MaxHealth'):Connect(updateHp)
    items.ancestryConnection=model.AncestryChanged:Connect(function(_,parent)
        if not parent then disposeNpcEsp(model) end
    end)
    updateHp()
end
local function updateNpcEsp()
    if not npcEspEnabled or selectedGame~='Examination' then
        clearNpcEsp()
        return
    end
    -- One initial scan split across frames; later NPCs are picked up by DescendantAdded.
    npcEspScanVersion+=1
    local version=npcEspScanVersion
    task.spawn(function()
        local descendants=Workspace:GetDescendants()
        for i,obj in ipairs(descendants) do
            if not active or not npcEspEnabled or selectedGame~='Examination' or version~=npcEspScanVersion then return end
            if obj:IsA('Model') then addNpcEsp(obj) end
            if i%60==0 then task.wait() end
        end
    end)
end
local npcEspAdded=Workspace.DescendantAdded:Connect(function(obj)
    if not active or not npcEspEnabled or selectedGame~='Examination' then return end
    if obj:IsA('Model') then
        task.defer(addNpcEsp,obj)
    elseif obj:IsA('Humanoid') or (obj:IsA('BasePart') and (obj.Name=='Head' or obj.Name=='HumanoidRootPart')) then
        local model=obj:FindFirstAncestorOfClass('Model')
        if model then task.defer(addNpcEsp,model) end
    end
end)
table.insert(connections,npcEspAdded)

-- Mobile attack binding state must exist BEFORE selectPage callbacks.
local mobileAttackButton = nil
local mobileAttackTouch = nil
local bindingAttackButton = false
local mobileFollowHeld = false
local boundAttackCenter = nil
local boundAttackRadius = 42
local boundAttackGui = nil
local function selectPage(name)
    local samePage=(currentPage==name)
    local previousScroll=samePage and scroll.CanvasPosition or Vector2.zero
    currentPage=name
    clearPage(); heading.Text=name
    if name=='Home' then
        category('SELECT GAME / ВЫБЕРИ ИГРУ')
        note('Текущая игра: '..selectedGame)
        button('LEGENDS BATTLEGROUND',function()
            selectedGame='Legends Battleground';selectPage('Scripts')
        end)
        button('JUJUTSU SHENANIGANS (JJS)',function()
            selectedGame='Jujutsu Shenanigans';state.catch=false;state.realParts=false;selectPage('JJS')
        end)
        button('THE STRONGEST BATTLEGROUNDS (TSB)',function()
            selectedGame='The Strongest Battlegrounds'
            state.realParts=false
            restore()
            selectPage('TSB')
        end)
        button('EXAMINATION (NPC)',function()
            enterExamination();selectPage('Examination')
        end)
        category('THEME / ТЕМА')
        button('◻ CINEMA  (серый / белый)'..(selectedTheme=='Cinema' and '  ✓' or ''),function()
            applyTheme('Cinema');selectPage('Home')
        end)
        button('♡ UWU  (розовый)'..(selectedTheme=='UwU' and '  ✓' or ''),function()
            applyTheme('UwU');selectPage('Home')
        end)
        note('Настройки тем и звука также есть во вкладке Settings.')
    elseif name=='JJS' then
        category('JUJUTSU SHENANIGANS — ALL FEATURES')
        note('Профиль JJS: функции Legends перенесены. Урон/хитбоксы и телепортации проверяет сервер игры.')
        category('Combat / PvP')
        button('M1 Catch / Следование',function()selectPage('Combat')end)
        button('Targets / HIT и IGNORE друзей',function()selectPage('Targets')end)
        category('Movement / Передвижение')
        button('Speed, Fly, Jump, Noclip, Shift Lock',function()selectPage('Main')end)
        category('Visuals / Экран')
        button('Player ESP, Fullbright, Hitbox',function()selectPage('Exploits')end)
        category('Other / Другое')
        button('Teleport и закладки',function()selectPage('Teleport')end)
        button('Custom Animations (R6 only)',function()selectPage('Custom Animations')end)
        button('Settings / Cinema / UwU',function()selectPage('Settings')end)
        note('R15-анимации JJS не заменяются классическими анимациями R6; функции зависят от рига.')
    elseif name=='TSB' then
        category('THE STRONGEST BATTLEGROUNDS / TSB')
        note('TSB: M1 — удар, F — блок, Q — рывок, G — ульта. Используй игровые кнопки на телефоне. Сервер определяет попадания.')
        category('Combat / PvP')
        button('M1 Catch / Следование',function()selectPage('Combat')end)
        button('Targets / HIT и IGNORE',function()selectPage('Targets')end)
        category('Movement / Передвижение')
        button('Speed / Fly / Jump / Noclip',function()selectPage('Main')end)
        category('Visuals / Экран')
        button('Player ESP / Fullbright / Hitbox',function()selectPage('Exploits')end)
        category('Other / Другое')
        button('Teleport / закладки',function()selectPage('Teleport')end)
        button('Custom Animations (R6)',function()selectPage('Custom Animations')end)
        button('Settings / тема',function()selectPage('Settings')end)
        note('Для стабильности TSB физическое увеличение частей других персонажей выключено; hitbox-индикатор только визуальный.')
    elseif name=='Examination' then
        category('EXAMINATION — PLAYER')
        button('Открыть Main / Speed / Fly',function()selectPage('Main')end)
        toggle('Fullbright / Яркое освещение', 'fullbright')
        toggle('Noclip / Сквозь стены', 'noclip')
        toggle('Fly / Полёт', 'fly')
        slider('Fly Speed / Скорость полёта', 'flySpeed', 10, 150, 1)
        category('EXAMINATION — RESPAWN / ANTI-VOID')
        button('Респавн персонажа / Reset',function()
            local character=me.Character
            local hum=character and character:FindFirstChildOfClass('Humanoid')
            if hum then hum.Health=0 end
        end)
        note('Reset запрашивает обычное возрождение персонажа. Миссия может сброситься, если так настроен сервер.')
        button('Сохранить безопасную точку',function()
            local character=me.Character
            local root=character and character:FindFirstChild('HumanoidRootPart')
            if root then examSafeCFrame=root.CFrame end
            selectPage('Examination')
        end)
        button('Вернуться к точке'..(examSafeCFrame and ' ✓' or ' (не сохранена)'),function()
            local character=me.Character
            local root=character and character:FindFirstChild('HumanoidRootPart')
            if root and examSafeCFrame then
                root.AssemblyLinearVelocity=Vector3.zero
                root.AssemblyAngularVelocity=Vector3.zero
                root.CFrame=examSafeCFrame
            end
        end)
        button('Anti-Void: '..(examAntiVoid and 'ON ✓' or 'OFF'),function()
            examAntiVoid=not examAntiVoid
            selectPage('Examination')
        end)
        note('Anti-Void возвращает к сохранённой точке при падении ниже карты. Это не завершает миссию и не гарантирует серверный респавн.')
        category('EXAMINATION — NPC ESP')
        button('NPC ESP: '..(npcEspEnabled and 'ON ✓' or 'OFF'),function()
            npcEspEnabled=not npcEspEnabled
            updateNpcEsp()
            selectPage('Examination')
        end)
        note('Подсвечивает NPC и показывает их имена. Игроков не подсвечивает. Цвет зависит от темы Cinema / UwU.')
        category('NPC TP / СОБРАТЬ БОТОВ')
        button('NPC TP → передо мной (локально)',function()
            npcGroupLocation=nil
            bringNpcLocally()
        end)
        button('NPC TP Авто: '..(npcGroupEnabled and 'ON ✓' or 'OFF'),function()
            npcGroupEnabled=not npcGroupEnabled
            if npcGroupEnabled then
                local ch=me.Character
                local root=ch and ch:FindFirstChild('HumanoidRootPart')
                npcGroupLocation=root and (root.CFrame*CFrame.new(0,0,-12)) or nil
                bringNpcLocally()
            else
                npcGroupLocation=nil
            end
            selectPage('Examination')
        end)
        note('Локальный NPC TP: сервер может вернуть NPC назад. Попадания и урон зависят от сервера, даже если NPC виден перед тобой.')
        note('NPC Hitbox: сервер может не учитывать изменённый размер. Настройка ниже влияет на локальную модель.')
        category('EXAMINATION — NPC HEAD SIZE')
        note('Меняется размер настоящей головы NPC только локально; попадания определяет сервер. Большие размеры могут нарушить движение ботов.')
        button('NPC HEAD: '..(npcEnabled and 'ON ✓' or 'OFF'),function()
            npcEnabled=not npcEnabled;refreshNpc();selectPage('Examination')
        end)
        button('−  Размер: '..npcSize..'  /  100  +',function()
            npcSize=math.min(100,npcSize+1);refreshNpc();selectPage('Examination')
        end)
        button('−  Уменьшить размер',function()
            npcSize=math.max(2,npcSize-1);refreshNpc();selectPage('Examination')
        end)
        button('СБРОС NPC',function()npcEnabled=false;refreshNpc();selectPage('Examination')end)
    elseif name=='Scripts' then
        if selectedGame=='Jujutsu Shenanigans' then
            category('JJS / JUJUTSU SHENANIGANS')
            button('Открыть функции JJS',function()selectPage('JJS')end)
        elseif selectedGame=='The Strongest Battlegrounds' then
            category('TSB / THE STRONGEST BATTLEGROUNDS')
            button('Открыть функции TSB',function()selectPage('TSB')end)
        elseif selectedGame=='Examination' then
            category('EXAMINATION')
            button('NPC Hitbox / Размер голов',function()selectPage('Examination')end)
        else
        category('FOLIX / GAME FEATURES')
        note('Выбери раздел ниже. Все функции исходного скрипта сохранены.')
        button('♙  Main / Speed / Fly',function()selectPage('Main')end)
        button('⚡  Exploits',function()selectPage('Exploits')end)
        button('⚔  Combat',function()selectPage('Combat')end)
        button('◎  Teleport',function()selectPage('Teleport')end)
        button('♫  Custom Animations',function()selectPage('Custom Animations')end)
        button('◉  Targets',function()selectPage('Targets')end)
        end
    elseif name=='Combat' then
        if selectedGame=='Examination' then
            note('M1 Catch отключён в Examination. Для игровых функций выбери Legends Battleground.')
            return
        end
        category(selectedGame=='Jujutsu Shenanigans' and 'JJS / M1 Catch' or (selectedGame=='The Strongest Battlegrounds' and 'TSB / M1 Catch' or 'M1 Catch'))
        if selectedGame=='Jujutsu Shenanigans' then
            note('JJS может использовать собственные анимации/захваты. M1 Catch — локальное следование, без гарантии урона; при рывках выключи.')
        elseif selectedGame=='The Strongest Battlegrounds' then
            note('TSB: M1 Catch — экспериментальное локальное следование. Рывки и серверные коррекции возможны; на телефоне привязывай только игровую кнопку удара.')
        end
        toggle(UIS.TouchEnabled and 'M1 Catch (кнопка УДАР)' or 'M1 Catch (hold left mouse)', 'catch')
        if UIS.TouchEnabled then
            button('📱 Привязать кнопку УДАР', function()
                bindingAttackButton=true
                mobileAttackTouch=nil
                mobileFollowHeld=false
                boundAttackCenter=nil
                boundAttackGui=nil
                window.Visible=false
            end)
            note('Нажми «Привязать», затем коснись ИГРОВОЙ кнопки удара. Обычные касания экрана не включают M1 Catch.')
        end
        slider('Zone Size / Radius (V60)', 'zone', 10, 300, 1)
        toggle('Show M1 Zone (visual only)', 'showCatchZone')
        slider('Zone Transparency (visual only)', 'zoneAlpha', 0, 1, .05)
        note('Зона работает даже когда Show M1 Zone выключен или прозрачность = 1. Радиус — выбор цели, не дальность удара.')
        slider('Offset (studs, V60)', 'approach', 1, 5, .1)
        slider('Follow Height', 'followHeight', 0, 5, .1)
        note('Максимальная дистанция выбора цели = Zone Size. Второй ограничитель Target Distance убран.')
        note('Удерживай M1: ближайший игрок со статусом HIT в зоне выбирается автоматически. Друзья IGNORE по умолчанию, изменить можно в Targets.')
        button('Refresh Target List',function()selectPage('Combat')end)
        note('M1: поиск цели по дистанции даже при скрытой зоне. Позиция за спиной — попытка, не защита от ударов. Сервер может отклонить быстрое перемещение.')
        category('Hitbox')
        toggle('Grey Hitbox Indicator', 'hitbox')
        slider('Hitbox Size', 'hitSize', 1, 50, 1)
        slider('Hitbox Transparency', 'hitAlpha', .1, 1, .05)
        if selectedGame~='Jujutsu Shenanigans' and selectedGame~='The Strongest Battlegrounds' then
            toggle('Experimental Real Parts (breaks character visuals)', 'realParts')
        else
            note('JJS / TSB: изменение физических частей отключено ради стабильности ragdoll / персонажей.')
        end
        note('Grey box = VISUAL ONLY, not an actual server hitbox. Experimental Real Parts changes local limb dimensions and may break physics; server hit registration not guaranteed. Do not enable to fix visuals.')
    elseif name=='Targets' then
        category('TARGET MANAGER (Backstab v60)')
        note('HIT / IGNORE: друзья по умолчанию IGNORE, но их можно вручную переключить в HIT. При проверке дружбы цель временно IGNORE.')
        button('Refresh Player List',function()selectPage('Targets')end)
        local players={}
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=me then table.insert(players,p) end
        end
        table.sort(players,function(a,b) return a.Name:lower()<b.Name:lower() end)
        for _,p in ipairs(players) do
            local row=new('Frame',{
                BackgroundColor3=panel,BackgroundTransparency=.48,BorderSizePixel=0,
                Size=UDim2.new(1,-6,0,43)
            },scroll)
            round(row,7)
            new('TextLabel',{
                Text='   '..p.Name,
                BackgroundTransparency=1,Font=Enum.Font.GothamBold,
                TextColor3=white,TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left,
                Size=UDim2.new(1,-116,1,0),Position=UDim2.fromOffset(12,0)
            },row)
            local ignoreButton=new('TextButton',{
                Text='',BackgroundColor3=Color3.fromRGB(48,50,60),
                Font=Enum.Font.GothamBold,TextSize=12,
                Position=UDim2.new(1,-102,.5,-14),Size=UDim2.fromOffset(90,28)
            },row)
            round(ignoreButton,5)
            local function refreshIgnore()
                local ignored=ignoredTarget(p)
                ignoreButton.Text=ignored and 'IGNORE' or 'HIT'
                ignoreButton.TextColor3=ignored and Color3.fromRGB(80,220,100) or Color3.fromRGB(230,100,100)
            end
            friendStatusListeners[p]=refreshIgnore
            refreshIgnore()
            ignoreButton.MouseButton1Click:Connect(function()
                if state.friendPending[p.UserId] then
                    -- Wait for friendship lookup before allowing manual override.
                    return
                end
                state.ignored[p.UserId]=not ignoredTarget(p)
                state.manualIgnore[p.UserId]=state.ignored[p.UserId]
                refreshIgnore()
            end)
        end
    elseif name=='Main' then
        category('Movement')
        toggle('Speed', 'speed');slider('Speed Value', 'speedValue', 16, 150, 1)
        category('Fly')
        toggle('Fly (WASD + Space/Ctrl)', 'fly')
        slider('Fly Speed', 'flySpeed', 10, 150, 1)
        note('Fly без ограничения дальности. Space — вверх, Ctrl — вниз. На телефоне используется джойстик.')
        toggle('Jump', 'jump');slider('Jump Power','jumpPower',50,150,1)
        toggle('Basic Jump (repeat on Space)', 'basicJump')
        toggle('Noclip', 'noclip')
        category('Camera / Shift Lock')
        toggle('Camera Orbit / Fixed Facing (Shift)', 'shiftLock')
        note('Shift = free shoulder camera. During M1 Catch your character faces the opponent\'s back regardless of camera direction. Ctrl opens menu.')
    elseif name=='Exploits' then
        category('Visuals');toggle('Player ESP', 'esp');toggle('Fullbright','fullbright')
        category('Movement');toggle('Fly', 'fly');slider('Fly Speed','flySpeed',10,150,1)
        toggle('Basic Jump','basicJump');toggle('Noclip','noclip')
        toggle('Shift Lock (Shift)','shiftLock')
        note('Interface inspired by XDevHub. Features adapted for Legends Battlegrounds; hit registration is not guaranteed.')
    elseif name=='Info' then
        category(selectedGame)
        note('Общие функции адаптированы для '..selectedGame..'. Урон и перемещения могут ограничиваться сервером.')
        note('Avoid running older folix scripts alongside this one: their loops can continue to modify characters.')
    elseif name=='Settings' then
        category('THEME / ТЕМА')
        button('✓ CINEMA / серо-белая тема'..(selectedTheme=='Cinema' and ' [ON]' or ''),function()
            applyTheme('Cinema');selectPage('Settings')
        end)
        button('♡ UwU / розовая тема'..(selectedTheme=='UwU' and ' [ON]' or ''),function()
            applyTheme('UwU');selectPage('Settings')
        end)
        button('Звук Cinema: '..(cinemaSoundEnabled and 'ON' or 'OFF'),function()
            cinemaSoundEnabled=not cinemaSoundEnabled
            if not cinemaSoundEnabled then cinemaSound:Stop() end
            selectPage('Settings')
        end)
        category('UwU')
        toggle('🔊 Звук UwU (ВКЛ/ВЫКЛ)', 'uwu')
        note('Звук можно отключить. При переключении функций девушка подмигивает на 1 секунду даже без звука.')
        category('Settings');note('Ctrl = show/hide menu. Shift = toggle free camera / fixed character facing. X = close and stop.')
        slider('Window Alpha','windowAlpha',0,.75,.05)
    elseif name=='Teleport' then
        category('Players')
        chooser('Teleport target',playerOptions(),state.teleportTarget,function(v)state.teleportTarget=v end)
        button('Teleport to selected player',function()
            if not state.teleportTarget then return end
            local target=Players:FindFirstChild(state.teleportTarget)
            local root=target and target.Character and target.Character:FindFirstChild('HumanoidRootPart')
            if root then teleportTo(root.CFrame) end
        end)
        category('Bookmarks')
        button('Save this position',function()
            local r=myRoot();if not r then return end
            table.insert(waypointList,{name='Point '..(#waypointList+1),cf=r.CFrame})
            selectPage('Teleport')
        end)
        for _,pt in ipairs(waypointList) do
            button('Go to '..pt.name,function()teleportTo(pt.cf)end)
        end
        category('Map locations (live scan)')
        note('Scans names of anchored map objects in your actual server. Not a verified map directory; no made-up coordinates. Refresh after map changes.')
        button('Scan current map',function()
            state.scanned=mapCandidates();selectPage('Teleport')
        end)
        for _,loc in ipairs(state.scanned or {}) do
            button(loc.label,function()
                if loc.instance and loc.instance.Parent then
                    teleportTo(CFrame.new(loc.instance.Position))
                end
            end)
        end
    elseif name=='Executor' then
        category('Executor / Legendary')
        note('Твой скрипт загружен в поле ниже. Он НЕ запускается автоматически. Внешний код защищён обфускацией; проверяй источник перед запуском.')
        local editor=new('TextBox',{
            Name='ExecutorCode',Text=EXECUTOR_PRESET,ClearTextOnFocus=false,
            MultiLine=true,TextWrapped=false,TextXAlignment=Enum.TextXAlignment.Left,
            TextYAlignment=Enum.TextYAlignment.Top,Font=Enum.Font.Code,TextSize=13,
            TextColor3=white,BackgroundColor3=Color3.fromRGB(26,19,33),
            BackgroundTransparency=.10,BorderSizePixel=0,
            Size=UDim2.new(1,-6,0,185)
        },scroll)
        round(editor,8)
        button('Вставить Legendary заново',function() editor.Text=EXECUTOR_PRESET end)
        button('Выполнить код (вручную)',function()
            local compile=loadstring
            if type(compile)~='function' then
                warn('[FOLIX Executor] loadstring is unavailable')
                return
            end
            local fn,err=compile(editor.Text)
            if not fn then warn('[FOLIX Executor] '..tostring(err)); return end
            task.spawn(function()
                local ok,runErr=pcall(fn)
                if not ok then warn('[FOLIX Executor] '..tostring(runErr)) end
            end)
        end)
    elseif name=='Custom Animations' then
        category('R6 Idle / Poses')
        note('Watch Check = look at your wrist while standing. Cool Stance = relaxed arm pose. Animated locally. No R15 IDs.')
        button('⌚ Watch Check (R6)',function()setPose('watch')end)
        button('😎 Cool Stance (R6)',function()setPose('cool')end)
        button('Stop pose',function()resetPose()end)
        category('R6 Walk Animation')
        toggle('Custom R6 Walk (Roblox classic)', 'customWalk')
        note('Uses R6 walk animation 180426354 with a subtle swagger arm sway. Animations may be overridden by the game.')
    end
    refreshCanvas()
    task.defer(function()
        if ui.Parent then
            scroll.CanvasPosition=previousScroll
            applyTheme(selectedTheme)
        end
    end)
end
-- FOLIX navigation reproduced with native Roblox UI elements (no screenshot sprites).
-- Game features are accessed via Scripts; gameplay implementations are unchanged.
side.Position=UDim2.fromOffset(0,0)
side.Size=UDim2.fromOffset(200,580)
side.BackgroundTransparency=1
side.ClipsDescendants=false
local logo=new('TextLabel',{
    Name='FOLIXLogo',Text='FOLIX ♡',Font=Enum.Font.FredokaOne,TextSize=41,
    TextColor3=Color3.fromRGB(255,89,182),TextStrokeColor3=Color3.fromRGB(105,9,62),
    TextStrokeTransparency=.42,BackgroundTransparency=1,
    TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.fromOffset(18,12),
    Size=UDim2.fromOffset(192,53),ZIndex=11
},side)
new('TextLabel',{
    Name='Tagline',Text='Better than the rest.',Font=Enum.Font.Gotham,
    TextSize=12,TextColor3=Color3.fromRGB(250,108,189),BackgroundTransparency=1,
    TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.fromOffset(19,69),
    Size=UDim2.fromOffset(175,22),ZIndex=11
},side)
local navItems={
    {'⌂','Home','Info'},
    {'ϟ','Executor','Executor'},
    {'⚙','Scripts','Scripts'},
    {'⬡','Settings','Settings'},
    {'♟','Credits','Info'}
}
local navButtons={}
local function setActiveNav(active)
    for _,item in ipairs(navButtons) do
        local on=item.name==active
        item.bg.BackgroundTransparency=on and .05 or 1
        item.icon.TextColor3=selectedTheme=='Cinema' and (on and Color3.fromRGB(255,255,255) or Color3.fromRGB(185,185,185)) or (on and Color3.fromRGB(255,239,250) or Color3.fromRGB(255,181,225))
        item.nameLabel.TextColor3=selectedTheme=='Cinema' and (on and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,200,200)) or (on and Color3.fromRGB(255,248,253) or Color3.fromRGB(245,194,226))
    end
end
for i,item in ipairs(navItems) do
    local symbol,name,page=item[1],item[2],item[3]
    local y=106+(i-1)*47
    local buttonNav=new('TextButton',{
        Name='Navigation_'..name,Text='',AutoButtonColor=false,
        BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.fromOffset(184,41),Position=UDim2.fromOffset(9,y),ZIndex=11
    },side)
    local stripe=new('Frame',{
        Name='Highlight',BackgroundColor3=Color3.fromRGB(225,49,140),
        BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.fromScale(1,1),ZIndex=11
    },buttonNav)
    round(stripe,7)
    new('TextLabel',{
        Text=symbol,Font=Enum.Font.GothamBold,TextSize=23,BackgroundTransparency=1,
        TextColor3=Color3.fromRGB(255,181,225),Position=UDim2.fromOffset(10,1),
        Size=UDim2.fromOffset(32,39),ZIndex=12
    },buttonNav)
    local icon=buttonNav:FindFirstChildOfClass('TextLabel')
    local caption=new('TextLabel',{
        Text=name,Font=Enum.Font.GothamMedium,TextSize=17,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left,TextColor3=Color3.fromRGB(245,194,226),
        Position=UDim2.fromOffset(49,2),Size=UDim2.fromOffset(125,36),ZIndex=12
    },buttonNav)
    table.insert(navButtons,{name=name,bg=stripe,icon=icon,nameLabel=caption})
    buttonNav.MouseButton1Click:Connect(function()
        setActiveNav(name)
        selectPage(page)
        applyTheme(selectedTheme)
    end)
end
setActiveNav('Home')
-- Drag window by its title bar.
local moving, dragStart, windowStart=false,nil,nil
local dragRegion=new('TextButton',{Text='',BackgroundTransparency=1,Size=UDim2.new(1,-95,0,40)},window)
dragRegion.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then moving=true;dragStart=i.Position;windowStart=window.Position end
end)
table.insert(connections,UIS.InputChanged:Connect(function(i)
    if moving and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-dragStart
        local canvas=screenRoot.AbsoluteSize
        local scale=responsiveScale.Scale
        local cx=canvas.X*.5+d.X
        local cy=canvas.Y*.5+d.Y
        local hw=window.Size.X.Offset*scale*.5
        local hh=window.Size.Y.Offset*scale*.5
        cx=math.clamp(cx,hw,math.max(hw,canvas.X-hw))
        cy=math.clamp(cy,hh,math.max(hh,canvas.Y-hh))
        window.Position=UDim2.fromOffset(cx,cy)
    end
end))
table.insert(connections,UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then moving=false end end))
local visuals=new('Folder',{Name='LBVisuals'},ui)
local function restore()
    for p,s in pairs(originalParts) do
        if p and p.Parent then p.Size=s.size;p.CanCollide=s.collide end
        originalParts[p]=nil
    end
end
local function clearVisual(p)
    if boxes[p] then boxes[p]:Destroy();boxes[p]=nil end
    if espGui[p] then espGui[p]:Destroy();espGui[p]=nil end
end
local function targetForCatch()
    local myRoot=me.Character and me.Character:FindFirstChild('HumanoidRootPart')
    if not myRoot then return nil end
    local maxDistance=state.zone
    local nearestRoot=nil
    local bestDistance=maxDistance
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=me and not ignoredTarget(p) then
            local character=p.Character
            local root=character and character:FindFirstChild('HumanoidRootPart')
            local hum=character and character:FindFirstChildOfClass('Humanoid')
            if root and hum and hum.Health>0 then
                local distance=(root.Position-myRoot.Position).Magnitude
                if distance<=bestDistance then
                    nearestRoot=root
                    bestDistance=distance
                end
            end
        end
    end
    return nearestRoot
end
-- Reliable Noclip: cache own body parts and enforce before physics simulation.
local noclipChar=nil
local noclipParts={}
local noclipPartAdded=nil
local function refreshNoclipChar(ch)
    if ch==noclipChar then return end
    if noclipPartAdded then noclipPartAdded:Disconnect();noclipPartAdded=nil end
    noclipChar=ch
    table.clear(noclipParts)
    if not ch then return end
    for _,part in ipairs(ch:GetDescendants()) do
        if part:IsA('BasePart') then noclipParts[part]=true end
    end
    noclipPartAdded=ch.DescendantAdded:Connect(function(part)
        if part:IsA('BasePart') then noclipParts[part]=true end
    end)
end
table.insert(connections, RunService.Stepped:Connect(function()
    if not active then return end
    if not state.noclip then
        if next(collisionOld) then
            for part,oldValue in pairs(collisionOld) do
                if part and part.Parent then part.CanCollide=oldValue end
                collisionOld[part]=nil
            end
        end
        return
    end
    refreshNoclipChar(me.Character)
    for part in pairs(noclipParts) do
        if not part.Parent then
            noclipParts[part]=nil
            collisionOld[part]=nil
        else
            if collisionOld[part]==nil then collisionOld[part]=part.CanCollide end
            if part.CanCollide then part.CanCollide=false end
        end
    end
end))
local oldSpeed, oldJump
local flyOrigin=nil
local lastRoot
-- Локальное облачко UwU, не отправляет сообщения в общий чат.
local uwuBubble
local function updateUwuBubble()
    local head=me.Character and me.Character:FindFirstChild('Head')
    if not head then
        if uwuBubble then uwuBubble:Destroy(); uwuBubble=nil end
        return
    end
    if uwuBubble and uwuBubble.Adornee==head then return end
    if uwuBubble then uwuBubble:Destroy() end
    uwuBubble=Instance.new('BillboardGui')
    uwuBubble.Name='FolixUwUBubble'
    uwuBubble.Adornee=head
    uwuBubble.Size=UDim2.fromOffset(110,46)
    uwuBubble.StudsOffset=Vector3.new(0,3,0)
    uwuBubble.AlwaysOnTop=true
    uwuBubble.Parent=ui
    local text=Instance.new('TextLabel')
    text.Size=UDim2.fromScale(1,1)
    text.BackgroundColor3=Color3.fromRGB(255,220,240)
    text.BackgroundTransparency=.12
    text.TextColor3=Color3.fromRGB(100,35,85)
    text.Font=Enum.Font.GothamBold
    text.TextSize=22
    text.Text='uwu'
    text.Parent=uwuBubble
    round(text,18)
end

-- Тёплая надпись под персонажем: чередуется каждые 10 секунд.
-- Видна только на этом клиенте, как и стандартная надпись UwU.
local complimentGui=nil
local complimentText=nil
local complimentIndex=1
local complimentChangedAt=os.clock()
local compliments={
    'Ты силён и могучий!',
    'Ты красивый!',
    'У тебя всё получится!',
    'Ты настоящий чемпион!',
    'Твоя сила — в упорстве!',
    'Продолжай в том же духе!',
    'Ты умеешь удивлять!',
    'Сегодня твой день!',
    'Ты справишься с любой задачей!',
    'Не сдавайся — ты молодец!'
}
local function updateCompliment()
    local root=me.Character and me.Character:FindFirstChild('HumanoidRootPart')
    if not root then
        if complimentGui then complimentGui:Destroy() end
        complimentGui,complimentText=nil,nil
        return
    end
    if not complimentGui or complimentGui.Adornee~=root then
        if complimentGui then complimentGui:Destroy() end
        complimentGui=Instance.new('BillboardGui')
        complimentGui.Name='FolixCompliment'
        complimentGui.Adornee=root
        complimentGui.Size=UDim2.fromOffset(260,46)
        complimentGui.StudsOffset=Vector3.new(0,-3.2,0)
        complimentGui.AlwaysOnTop=true
        complimentGui.Parent=ui
        complimentText=Instance.new('TextLabel')
        complimentText.Size=UDim2.fromScale(1,1)
        complimentText.BackgroundColor3=Color3.fromRGB(46,18,49)
        complimentText.BackgroundTransparency=.24
        complimentText.TextColor3=Color3.fromRGB(255,182,223)
        complimentText.Font=Enum.Font.GothamBold
        complimentText.TextSize=17
        complimentText.TextScaled=true
        complimentText.Text=compliments[complimentIndex]
        complimentText.Parent=complimentGui
        round(complimentText,10)
    end
    if os.clock()-complimentChangedAt>=10 then
        complimentIndex=complimentIndex%#compliments+1
        complimentChangedAt=os.clock()
        complimentText.Text=compliments[complimentIndex]
    end
end

local function frame()
    if not active then return end
    local ch=me.Character
    local hum=ch and ch:FindFirstChildOfClass('Humanoid')
    local root=ch and ch:FindFirstChild('HumanoidRootPart')
    if selectedGame=='Examination' and examAntiVoid and root and examSafeCFrame then
        local floorY=Workspace.FallenPartsDestroyHeight
        if root.Position.Y < floorY+30 and os.clock()-lastVoidRescue>2 then
            lastVoidRescue=os.clock()
            root.AssemblyLinearVelocity=Vector3.zero
            root.AssemblyAngularVelocity=Vector3.zero
            root.CFrame=examSafeCFrame
        end
    end
    if hum then
        if hum~=lastRoot then oldSpeed=hum.WalkSpeed;oldJump=hum.JumpPower;lastRoot=hum end
        if state.speed then hum.WalkSpeed=state.speedValue elseif oldSpeed and hum.WalkSpeed==state.speedValue then hum.WalkSpeed=oldSpeed end
        if state.jump then hum.UseJumpPower=true;hum.JumpPower=state.jumpPower
        elseif oldJump and hum.JumpPower==state.jumpPower then hum.JumpPower=oldJump end
    end
    -- Fly, controlled locally, without a distance cap.
    if state.fly and root and hum and hum.Health>0 then
        if not flyOrigin then flyOrigin=root.Position end
        if not flyVelocity or flyVelocity.Parent~=root then
            if flyVelocity then flyVelocity:Destroy() end
            flyVelocity=Instance.new('BodyVelocity')
            flyVelocity.Name='LBFlyMotion'
            flyVelocity.MaxForce=Vector3.new(8e4,8e4,8e4)
            flyVelocity.P=1250
            flyVelocity.Parent=root
        end
        local cam=Workspace.CurrentCamera
        local look=cam and cam.CFrame.LookVector or Vector3.new(0,0,-1)
        local right=cam and cam.CFrame.RightVector or Vector3.new(1,0,0)
        local move=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then move=move+look end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move=move-look end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move=move+right end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move=move-right end
        if UIS.TouchEnabled or UIS.GamepadEnabled then
            -- MoveDirection receives the default mobile thumbstick/gamepad input.
            local stick=hum.MoveDirection
            if stick.Magnitude>0.05 then
                move=Vector3.new(stick.X,0,stick.Z)
            end
        end
        if UIS:IsKeyDown(Enum.KeyCode.Space) or hum.Jump then move=move+Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move=move-Vector3.yAxis end
        if move.Magnitude>0 then move=move.Unit end
        -- Unlimited Fly: no radius restriction from the activation point.
        flyVelocity.Velocity=move*state.flySpeed
    else
        flyOrigin=nil
        if flyVelocity then flyVelocity:Destroy();flyVelocity=nil end
    end
    -- Noclip physics is handled by Stepped below; no redundant Workspace scans here.
    -- Local indicator for the M1 Catch acquisition zone.
    if state.catch and state.showCatchZone and root and state.zoneAlpha < 1 then
        if not catchZone then
            catchZone=new('SphereHandleAdornment',{
                Name='M1CatchZone',AlwaysOnTop=false,
                Color3=Color3.fromRGB(65,180,242),ZIndex=0
            },visuals)
        end
        catchZone.Adornee=root
        catchZone.Radius=state.zone
        catchZone.Transparency=state.zoneAlpha
    elseif catchZone then
        catchZone:Destroy(); catchZone=nil
    end
    -- Back-follow orientation is updated separately AFTER camera controls.
    -- No M1 rotation here: competing per-frame writes cause flicker.
    -- Don't iterate through every player on each frame in Examination when Player ESP/hitbox are off.
    if state.hitbox or state.esp or next(boxes) or next(espGui) or (state.hitbox and state.realParts) then
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=me then
            local enemy=plr.Character
            local r=enemy and enemy:FindFirstChild('HumanoidRootPart')
            local head=enemy and enemy:FindFirstChild('Head')
            local eh=enemy and enemy:FindFirstChildOfClass('Humanoid')
            if r and eh and eh.Health>0 then
                if state.hitbox then
                    if not boxes[plr] then
                        local b=new('BoxHandleAdornment',{Name='GreyHitbox',Adornee=r,AlwaysOnTop=true,Color3=Color3.fromRGB(110,110,110),ZIndex=4},visuals)
                        boxes[plr]=b
                    end
                    local b=boxes[plr];b.Adornee=r;b.Size=Vector3.new(state.hitSize,state.hitSize,state.hitSize);b.Transparency=state.hitAlpha
                elseif boxes[plr] then boxes[plr]:Destroy();boxes[plr]=nil end
                if state.esp and head then
                    if not espGui[plr] then
                        local bb=new('BillboardGui',{Size=UDim2.fromOffset(175,42),StudsOffset=Vector3.new(0,2.8,0),AlwaysOnTop=true},visuals)
                        new('TextLabel',{Name='Label',BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Font=Enum.Font.GothamBold,TextSize=12,TextStrokeTransparency=.25,TextColor3=white},bb)
                        espGui[plr]=bb
                    end
                    espGui[plr].Adornee=head
                    espGui[plr].Label.Text=plr.DisplayName..'  '..math.floor(eh.Health/math.max(eh.MaxHealth,1)*100)..'%'
                elseif espGui[plr] then espGui[plr]:Destroy();espGui[plr]=nil end
                if state.hitbox and state.realParts and selectedGame~='Jujutsu Shenanigans' and selectedGame~='The Strongest Battlegrounds' then
                    for _,partName in ipairs({'Torso','Left Arm','Right Arm','Left Leg','Right Leg'}) do
                        local p=enemy:FindFirstChild(partName)
                        if p and p:IsA('BasePart') then
                            if not originalParts[p] then originalParts[p]={size=p.Size,collide=p.CanCollide} end
                            p.Size=Vector3.new(state.hitSize,state.hitSize,state.hitSize);p.CanCollide=false
                        end
                    end
                end
            else
                clearVisual(plr)
            end
        end
    end
    end -- player effect loop
    if not (state.hitbox and state.realParts) and next(originalParts) then restore() end
    -- Avoid redundant per-frame property writes that may trigger other scripts.
    if state.fullbright then
        if Lighting.Brightness~=3 then Lighting.Brightness=3 end
        if Lighting.ClockTime~=14 then Lighting.ClockTime=14 end
        if Lighting.FogEnd~=100000 then Lighting.FogEnd=100000 end
    else
        if Lighting.Brightness~=lightingOld.Brightness then Lighting.Brightness=lightingOld.Brightness end
        if Lighting.ClockTime~=lightingOld.ClockTime then Lighting.ClockTime=lightingOld.ClockTime end
        if Lighting.FogEnd~=lightingOld.FogEnd then Lighting.FogEnd=lightingOld.FogEnd end
    end
    if state.windowAlpha and window.BackgroundTransparency~=state.windowAlpha then window.BackgroundTransparency=state.windowAlpha end
end
-- Camera shoulder lock + local R6 animation controls
local function animationAndCamera(dt)
    if not active then return end
    local ch=me.Character
    local hum=ch and ch:FindFirstChildOfClass('Humanoid')
    local root=ch and ch:FindFirstChild('HumanoidRootPart')
    local cam=Workspace.CurrentCamera
    local locked=selectedGame~='Examination' and state.shiftLock and hum and root and cam and not window.Visible
    if locked then
        if shiftHum~=hum then
            releaseShiftLock()
            shiftHum=hum;shiftAutoRotate=hum.AutoRotate;shiftCameraOffset=hum.CameraOffset
        end
        hum.AutoRotate=false
        hum.CameraOffset=Vector3.new(1.6,.45,0)
        UIS.MouseBehavior=Enum.MouseBehavior.LockCenter
        -- Camera is independent: while M1 is held, face the opponent's back, not the camera.
        -- AutoRotate=false prevents movement input from turning the Humanoid.
        -- Do NOT rotate HumanoidRootPart here: doing so would force facing to camera.
    else
        if shiftHum then releaseShiftLock() end
    end
    if not hum or hum.Health<=0 then
        resetWalkJoints()
        stopCustomWalk()
        if actionPose then resetPose() end
        return
    end
    if hum.RigType~=Enum.HumanoidRigType.R6 then
        resetWalkJoints()
        stopCustomWalk()
        if actionPose then resetPose() end
        return
    end
    local running=hum.MoveDirection.Magnitude>.08 and hum.FloorMaterial~=Enum.Material.Air
    if state.customWalk and running then
        if customWalkHum~=hum or not customWalkTrack then
            stopCustomWalk()
            local animator=hum:FindFirstChildOfClass('Animator')
            if not animator then animator=Instance.new('Animator');animator.Parent=hum end
            customWalkAnimation=Instance.new('Animation')
            customWalkAnimation.AnimationId=ANIM_R6_WALK
            local ok,track=pcall(function() return animator:LoadAnimation(customWalkAnimation) end)
            if ok then
                customWalkTrack=track
                customWalkHum=hum
                track.Priority=Enum.AnimationPriority.Movement
                track.Looped=true
            else
                warn('[LB] R6 walk failed to load: '..tostring(track))
                stopCustomWalk()
            end
        end
        if customWalkTrack and not customWalkTrack.IsPlaying then customWalkTrack:Play(.18) end
        if customWalkTrack then customWalkTrack:AdjustSpeed(math.clamp(hum.WalkSpeed/16,.6,2)) end
    elseif customWalkTrack and customWalkTrack.IsPlaying then
        customWalkTrack:Stop(.18)
    end
    -- Walk swagger: small R6 C0 offsets, restores without replacing the rest of the rig.
    if state.customWalk and running and not actionPose then
        local torso=ch:FindFirstChild('Torso')
        local t=os.clock()
        for _,name in ipairs({'Right Shoulder','Left Shoulder'}) do
            local j=torso and torso:FindFirstChild(name)
            if j then
                if not walkJoints[j] then walkJoints[j]=j.C0 end
                local sign=name=='Right Shoulder' and 1 or -1
                j.C0=walkJoints[j]*CFrame.Angles(math.rad(8*math.sin(t*9)*sign),0,math.rad(sign*8))
            end
        end
    elseif next(walkJoints) then resetWalkJoints() end
    if actionPose then
        local t=os.clock()
        local still=not running and hum.FloorMaterial~=Enum.Material.Air and not state.catch
        for joint,base in pairs(poseBase) do
            if joint and joint.Parent then
                local poseOffset=CFrame.new()
                if still then
                    if actionPose=='watch' then
                        if joint==poseJoints['Left Shoulder'] then poseOffset=CFrame.Angles(math.rad(-88+5*math.sin(t*2)),0,math.rad(-35)) end
                        if joint==poseJoints['Right Shoulder'] then poseOffset=CFrame.Angles(math.rad(10),0,math.rad(10)) end
                        if joint==poseJoints['Neck'] then poseOffset=CFrame.Angles(math.rad(12),math.rad(-10),0) end
                    elseif actionPose=='cool' then
                        if joint==poseJoints['Right Shoulder'] then poseOffset=CFrame.Angles(math.rad(-16),0,math.rad(22)) end
                        if joint==poseJoints['Left Shoulder'] then poseOffset=CFrame.Angles(math.rad(-25),0,math.rad(-26)) end
                        if joint==poseJoints['Neck'] then poseOffset=CFrame.Angles(0,math.rad(8*math.sin(t*.6)),0) end
                    end
                end
                joint.C0=base:Lerp(base*poseOffset,still and .96 or .0)
            end
        end
    end
end

-- V12: M1 BACK FOLLOW. Root LookVector points TOWARD the front of an R6 body.
-- Back position uses target.Position - LookVector * offset;
-- on a standing R6 target this lies opposite its forward-facing direction.
local backFollowTarget = nil
local lastStableForward = nil
local followHeldLastFrame = false
-- Mobile: pair with the game's real attack control. Ordinary screen taps never activate catch.
local GuiService = game:GetService('GuiService')
local function isAttackControl(btn)
    if not btn or not btn:IsA('GuiButton') or btn:IsDescendantOf(ui) then return false end
    local name = string.lower(btn.Name or '')
    local label = btn:IsA('TextButton') and string.lower(btn.Text or '') or ''
    return name:find('attack',1,true) or name:find('punch',1,true)
        or name=='m1' or name:find('combatbutton',1,true)
        or label=='attack' or label=='punch' or label=='удар' or label=='m1'
end
local function guiAtTouch(pos, boundOnly)
    local ok, objects = pcall(function() return GuiService:GetGuiObjectsAtPosition(pos.X, pos.Y) end)
    if not ok then return nil end
    for _,obj in ipairs(objects) do
        local cur=obj
        while cur and cur~=game do
            if cur:IsA('GuiButton') and not cur:IsDescendantOf(ui) then
                if (boundOnly and cur==mobileAttackButton) or
                   (not boundOnly and (isAttackControl(cur) or cur==mobileAttackButton)) then
                    return cur
                end
            end
            cur=cur.Parent
        end
    end
    return nil
end
-- Buttons are found once on first launch, then by their actual pressed touch.
local function autoFindAttackButton()
    local pg=me:FindFirstChildOfClass('PlayerGui')
    if not pg then return end
    for _,obj in ipairs(pg:GetDescendants()) do
        if isAttackControl(obj) and obj.Visible then
            mobileAttackButton=obj
            break
        end
    end
end
if UIS.TouchEnabled then task.defer(autoFindAttackButton) end
local function touchIsAttack(position)
    -- Prefer the exact button chosen by the user, never any arbitrary GUI tap.
    if mobileAttackButton and mobileAttackButton.Parent then
        local pt=mobileAttackButton.AbsolutePosition
        local sz=mobileAttackButton.AbsoluteSize
        if position.X>=pt.X and position.X<=pt.X+sz.X
            and position.Y>=pt.Y and position.Y<=pt.Y+sz.Y then
            return true
        end
    end
    -- Some games draw attack controls without accessible GuiButtons.
    -- In that case use only a small, manually calibrated touch region.
    if boundAttackCenter then
        return (Vector2.new(position.X,position.Y)-boundAttackCenter).Magnitude <= boundAttackRadius
    end
    return false
end
local mobileBeginConnection = UIS.InputBegan:Connect(function(input, processed)
    if input.UserInputType~=Enum.UserInputType.Touch or not active then return end
    if bindingAttackButton then
        if window.Visible then return end
        local selected=guiAtTouch(input.Position,false)
        if not selected then
            local ok, arr=pcall(function()return GuiService:GetGuiObjectsAtPosition(input.Position.X,input.Position.Y)end)
            if ok then
                for _,obj in ipairs(arr) do
                    local b=obj
                    while b and b~=game do
                        if b:IsA('GuiButton') and not b:IsDescendantOf(ui) then selected=b;break end
                        b=b.Parent
                    end
                    if selected then break end
                end
            end
        end
        mobileAttackButton=selected
        boundAttackCenter=Vector2.new(input.Position.X,input.Position.Y)
        boundAttackGui=selected
        if selected then
            boundAttackRadius=math.max(20, math.min(selected.AbsoluteSize.X, selected.AbsoluteSize.Y)*.5)
        else
            boundAttackRadius=38
        end
        bindingAttackButton=false
        mobileAttackTouch=nil
        mobileFollowHeld=false
        return
    end
    if window.Visible or not state.catch or selectedGame=='Examination' then return end
    if not mobileAttackButton and not boundAttackCenter then return end
    if mobileAttackTouch == nil and touchIsAttack(input.Position) then
        mobileAttackTouch=input
        mobileFollowHeld=true
    end
end)
local mobileEndConnection = UIS.InputEnded:Connect(function(input)
    if input==mobileAttackTouch then
        mobileFollowHeld=false
        mobileAttackTouch=nil
    end
end)
ui.Destroying:Connect(function()
    mobileBeginConnection:Disconnect()
    mobileEndConnection:Disconnect()
end)
local lastFollowTime=nil
local backFollowStepName = 'LBF_BackFollow_V12'
local function updateBackFollow()
    if not active or selectedGame=='Examination' then return end
    local char = me.Character
    local hum = char and char:FindFirstChildOfClass('Humanoid')
    local root = char and char:FindFirstChild('HumanoidRootPart')
    -- On mobile only the bound ATTACK button can hold catch; camera / joystick taps cannot.
    local attackHeld = (UIS.TouchEnabled and mobileFollowHeld)
        or ((not UIS.TouchEnabled) and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1))
    local pressed = attackHeld and state.catch and not state.fly and not window.Visible
        and not UIS:GetFocusedTextBox()
        and hum and hum.Health > 0 and root
    if not pressed then
        backFollowTarget = nil
        lastFollowTime=nil
        lastStableForward = nil
        if followHeldLastFrame and hum and not state.shiftLock then
            hum.AutoRotate = true
        end
        followHeldLastFrame = false
        return
    end
    followHeldLastFrame = true
    -- Retain target while LMB is held, instead of jumping between nearby players.
    local targetRoot = backFollowTarget
    local targetPlayer = targetRoot and Players:GetPlayerFromCharacter(targetRoot.Parent)
    local targetHum = targetRoot and targetRoot.Parent and targetRoot.Parent:FindFirstChildOfClass('Humanoid')
    local maxDistance = state.zone
    if not targetRoot or not targetRoot.Parent or not targetPlayer
        or ignoredTarget(targetPlayer) or not targetHum or targetHum.Health <= 0
        or (targetRoot.Position - root.Position).Magnitude > maxDistance + 8 then
        local nextTarget = targetForCatch()
        if nextTarget ~= backFollowTarget then lastStableForward = nil end
        targetRoot = nextTarget
        backFollowTarget = targetRoot
    end
    if not targetRoot then return end
    -- Follow the opponent's back, but ALWAYS remain upright.
    -- For prone or tumbling targets the back can point upwards; do not copy
    -- their roll/pitch into the local character (that caused flying/tilting).
    local targetChar=targetRoot.Parent
    local targetTorso=targetChar and (targetChar:FindFirstChild('UpperTorso') or targetChar:FindFirstChild('Torso'))
    local body=targetTorso or targetRoot
    local backDirection=-body.CFrame.LookVector
    if backDirection.Magnitude<0.01 then return end
    backDirection=backDirection.Unit
    local targetPos=body.Position
    -- Back offset is full 3D: when opponent lies face-down this is above them.
    local behind=targetPos+backDirection*state.approach + body.CFrame.UpVector*state.followHeight
    -- Always stay upright. When the target is prone, the vector toward
    -- its back can become vertical, so choose a horizontal heading from
    -- the target torso's axes instead of freezing the previous direction.
    local horizontal=Vector3.new(targetPos.X-behind.X,0,targetPos.Z-behind.Z)
    if horizontal.Magnitude > 0.03 then
        lastStableForward=horizontal.Unit
    else
        local torsoForward=body.CFrame.LookVector
        local flatForward=Vector3.new(torsoForward.X,0,torsoForward.Z)
        if flatForward.Magnitude < 0.03 then
            local torsoRight=body.CFrame.RightVector
            flatForward=Vector3.new(torsoRight.X,0,torsoRight.Z)
        end
        if flatForward.Magnitude > 0.03 then
            lastStableForward=flatForward.Unit
        elseif not lastStableForward then
            lastStableForward=Vector3.new(0,0,-1)
        end
    end
    local desired=CFrame.lookAt(behind,behind+lastStableForward,Vector3.yAxis)
    hum.AutoRotate=false
    -- No artificial interpolation or waits. Each frame uses the latest position.
    -- Network ownership/server corrections may still cause visible snaps.
    root.CFrame=desired
    root.AssemblyAngularVelocity=Vector3.zero
end
-- Runs just after Roblox's default camera update, countering camera-facing code.
RunService:BindToRenderStep(backFollowStepName, Enum.RenderPriority.Camera.Value + 10, updateBackFollow)

local npcGroupLoopId=0
task.spawn(function()
    while active do
        task.wait(2)
        if active and npcGroupEnabled and selectedGame=='Examination' then
            bringNpcLocally()
        end
    end
end)
table.insert(connections,RunService.Heartbeat:Connect(frame))
-- Infinite Stamina removed at user's request.

table.insert(connections,RunService.RenderStepped:Connect(animationAndCamera))
-- Friend requests can be accepted while both players are already in the server.
-- A one-time PlayerAdded lookup misses those changes, so refresh periodically.
-- This also retries failed Roblox friendship lookups.
local friendRefreshElapsed=0
table.insert(connections,RunService.Heartbeat:Connect(function(dt)
    if not active then return end
    friendRefreshElapsed += dt
    if friendRefreshElapsed < 8 then return end
    friendRefreshElapsed=0
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=me then checkFriend(p) end
    end
end))
table.insert(connections,Players.PlayerAdded:Connect(function(p) checkFriend(p) end))
table.insert(connections,Players.PlayerRemoving:Connect(function(p)
    clearVisual(p)
    state.ignored[p.UserId]=nil
    state.manualIgnore[p.UserId]=nil
    state.friendAuto[p.UserId]=nil
    state.friendPending[p.UserId]=nil
    friendChecking[p.UserId]=nil
    friendStatusListeners[p]=nil
end))
table.insert(connections,UIS.InputBegan:Connect(function(i,processed)
    if processed or UIS:GetFocusedTextBox() then return end
    if i.KeyCode==Enum.KeyCode.LeftControl or i.KeyCode==Enum.KeyCode.RightControl then
        window.Visible=not window.Visible
    elseif selectedGame~='Examination' and (i.KeyCode==Enum.KeyCode.LeftShift or i.KeyCode==Enum.KeyCode.RightShift) then
        state.shiftLock=not state.shiftLock
        if not state.shiftLock then releaseShiftLock() end
    end
end))
table.insert(connections,UIS.JumpRequest:Connect(function()
    if state.basicJump and me.Character then
        local h=me.Character:FindFirstChildOfClass('Humanoid')
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))
local function cleanup()
    if not active then return end
    active=false
    npcGroupEnabled=false
    if noclipPartAdded then noclipPartAdded:Disconnect();noclipPartAdded=nil end
    RunService:UnbindFromRenderStep(backFollowStepName)
    releaseShiftLock()
    resetWalkJoints()
    resetPose()
    stopCustomWalk()
    restore()
    if flyVelocity then flyVelocity:Destroy();flyVelocity=nil end
    for p,c in pairs(collisionOld) do if p and p.Parent then p.CanCollide=c end end
    Lighting.Brightness=lightingOld.Brightness;Lighting.ClockTime=lightingOld.ClockTime;Lighting.FogEnd=lightingOld.FogEnd
    if catchZone then catchZone:Destroy();catchZone=nil end
    for _,c in ipairs(connections) do pcall(function()c:Disconnect()end)end
    for _,c in ipairs(sliderConnections) do pcall(function()c:Disconnect()end)end
    local h=me.Character and me.Character:FindFirstChildOfClass('Humanoid')
    if h and oldSpeed then h.WalkSpeed=oldSpeed end
    if h and oldJump then h.JumpPower=oldJump end
    resetNpcHeads()
    clearNpcEsp()
    if uwuBubble then uwuBubble:Destroy(); uwuBubble=nil end
    if complimentGui then complimentGui:Destroy(); complimentGui=nil end
    ui:Destroy()
end
if getgenv then getgenv().LegendsXDevReplicaStop=cleanup end
close.MouseButton1Click:Connect(cleanup)
hideBtn.Activated:Connect(function() window.Visible=false end)
-- Small launcher on phone and PC; stays visible while window is minimized.
local mobileLove = new('TextButton', {
    Name='MobileILoveButton',
    Text='i love',
    Font=Enum.Font.GothamBold,
    TextSize=13,
    TextColor3=Color3.fromRGB(255,235,248),
    BackgroundColor3=Color3.fromRGB(210,55,139),
    BackgroundTransparency=.08,
    BorderSizePixel=0,
    AnchorPoint=Vector2.new(0,1),
    Position=UDim2.new(0,12,1,-50),
    Size=UDim2.fromOffset(66,32),
    ZIndex=100,
    Visible=true
}, ui)
round(mobileLove,9)
styleStroke(mobileLove,Color3.fromRGB(255,150,210),.2)
mobileLove.Activated:Connect(function()
    window.Visible=not window.Visible
    if window.Visible then updateResponsiveScale() end
end)

-- Compact game drop-down, always accessible on desktop and mobile.
local gamePicker=new('TextButton',{
    Name='GamePicker',Text='Игра  ▾',Font=Enum.Font.GothamBold,TextSize=13,
    TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(48,48,51),
    BorderSizePixel=0,Position=UDim2.fromOffset(204,8),Size=UDim2.fromOffset(126,31),
    ZIndex=80,AutoButtonColor=true
},window)
round(gamePicker,7)
local gamePopup=new('Frame',{
    Name='GamePickerPopup',Visible=false,BackgroundColor3=Color3.fromRGB(29,29,32),
    BorderSizePixel=0,Position=UDim2.fromOffset(204,42),Size=UDim2.fromOffset(204,180),ZIndex=80
},window)
round(gamePopup,8)
local function gameOption(label,y,value,page)
    local b=new('TextButton',{
        Name='Game_'..value,Text=label,Font=Enum.Font.GothamMedium,
        TextSize=13,TextXAlignment=Enum.TextXAlignment.Center,
        TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(57,57,61),
        BorderSizePixel=0,Position=UDim2.fromOffset(6,y),Size=UDim2.fromOffset(192,38),
        ZIndex=81
    },gamePopup)
    round(b,6)
    b.Activated:Connect(function()
        if value=='Examination' then
            enterExamination()
        else
            selectedGame=value
            if value=='Jujutsu Shenanigans' or value=='The Strongest Battlegrounds' then
                state.realParts=false
                restore()
            end
        end
        gamePicker.Text=(value=='Examination' and 'Exam  ▾' or
            (value=='Jujutsu Shenanigans' and 'JJS  ▾' or
            (value=='The Strongest Battlegrounds' and 'TSB  ▾' or 'Legends  ▾')))
        gamePopup.Visible=false
        selectPage(page)
        applyTheme(selectedTheme)
    end)
end
gameOption('Legends Battleground',5,'Legends Battleground','Scripts')
gameOption('Jujutsu Shenanigans',49,'Jujutsu Shenanigans','JJS')
gameOption('The Strongest Battlegrounds',93,'The Strongest Battlegrounds','TSB')
gameOption('Examination  /  NPC',137,'Examination','Examination')
gamePicker.Activated:Connect(function()
    gamePopup.Visible=not gamePopup.Visible
end)

applyTheme('Cinema')
selectPage('Home')
