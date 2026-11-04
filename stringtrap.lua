-- ============================================================
--  STRINGTRAP HUB / BANANA CAT REPLICA (DELTA COMPATIBLE)
-- ============================================================
local ANTIBAN_URL = "https://raw.githubusercontent.com/contadeteste9013-a11y/stringtrap-hub/main/stringtrap.lua"
local ANTIBAN_MIN = 30
local ANTIBAN_MAX = 40

if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local uis     = game:GetService("UserInputService")
local vim     = game:GetService("VirtualInputManager")
local ts      = game:GetService("TweenService")
local rs      = game:GetService("ReplicatedStorage")
local vu      = game:GetService("VirtualUser")
local p       = Players.LocalPlayer
local pGui    = p:WaitForChild("PlayerGui")

if pGui:FindFirstChild("StringtrapHub") then pGui.StringtrapHub:Destroy() end

local cfg = {
    unlocked = false,
    showStatusBar = true,
    selectedItemBuy = "Death Step",
    selectedWeapon = "Melee",
    attackNoAnim = false,
    killAuraOnlyBaldAndVolcano = false,
    timeDelayKill = 5,
    autoClick = false,
    killAuraWithDragonStorm = false,
    autoTurnOnBuso = true,
    autoKen = false,
    autoV3 = false,
    autoV4 = false,
    skillsMelee = {Z = false, X = false, C = false, V = false},
    skillsSword = {Z = false, X = false},
    skillsGun = {Z = false, X = false},
    skillsFruit = {Z = false, X = false, C = false, V = false, F = false},
    useSkillFastDontHold = false,
    setDelayMelee = 0.1,
    setDelaySword = 0.1,
    farmMethod = "Level Farm",
    distanceFarmAura = 300,
    ignoreAttackKatakuri = false,
    hopFindKatakuri = false,
    autoQuestKatakuriBone = true,
    startFarm = false,
    farmMastery = false,
    masteryMethod = "Melee",
    autoNewWorld = false,
    autoThirdWorld = false,
    collectChestGodsChaliceOrFOD = false,
    teleportToFruit = false,
    teleportToFruitHopServer = false,
    autoFactory = false,
    autoPirateRaid = false,
    autoEliteHunter = false,
    hopServerEliteHunter = false,
    hopIfHaveGodChalice = false,
    autoTouchPadHaki = false,
    autoSummonRipIndra = false,
    attackRipIndra = false,
    attackSoulReaper = false,
    summonSoulReaper = false,
    bossDoughKing = false,
    summonDoughKing = false,
    hopFindDoughKing = false,
    autoCollectEggEaster = false,
    changeSizeReel = false,
    autoSlapBattle = false,
    selectedBait = "Default",
    autoTweenToEventFishingSpot = false,
    autoSellFishing = false,
    autoOpenChest = false,
    selectedQuestFishing = "None",
    autoAcceptQuestFishing = false,
    autoQuestDojoTrainer = false,
    autoQuestDragonHunter = false,
    autoAttackAllMobAndBoss = false,
    hopFindBerry = false,
    autoCollectBerry = false,
    randomDevilFruit = false,
    autoStoreFruit = false,
    buyBloxFruitSniperShop = false,
    selectedRaid = "Flame",
    getFruitInInventoryLowBeli = false,
    autoRaid = false,
    hopSeverRaid = false,
    autoAwakeFruit = false,
    multiRaid = false,
    autoSeaEvent = false,
    selectedTeam = "Pirates",
    noclip = false,
    selectedNpc = "",
    selectedIsland = 1,
    teleportMirage = false,
    teleportPrehistoricIsland = false,
    autoDetectSea = true,
    selectedSea = "Sea 1",
    fastMode = false,
    noRender = false,
}

local KEY = "williamafton2026"
local IMG = "rbxassetid://77611955682353"

local function detectCurrentSea()
    local pid = game.PlaceId
    if pid == 4442272183 then return "Sea 2"
    elseif pid == 7449423635 then return "Sea 3" end
    return "Sea 1"
end
cfg.selectedSea = detectCurrentSea()

local autoReload = false
local getgenv = getgenv or function() return _G end
if getgenv().StringtrapHub_AutoReload == true then
    autoReload = true
    getgenv().StringtrapHub_AutoReload = nil
end

local function queueTeleport(source)
    local qot = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
    if qot then
        return pcall(qot, source)
    end
    return false, "Nao suportado"
end

local function hopServer()
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local ok, res = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    if not ok or not res or not res.data then
        local rj = pcall(function() TeleportService:Teleport(game.PlaceId, p) end)
        if rj then return true, "rejoin" end
        return false, "API bloqueada"
    end
    local candidates = {}
    for _, s in ipairs(res.data) do
        if s.id ~= game.JobId and s.playing < s.maxPlayers then
            table.insert(candidates, s)
        end
    end
    if #candidates == 0 then
        local rj = pcall(function() TeleportService:Teleport(game.PlaceId, p) end)
        if rj then return true, "rejoin" end
        return false, "Sem servers"
    end
    table.sort(candidates, function(a, b) return a.playing < b.playing end)
    local target = candidates[1]
    local hopOk, hopErr = pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, target.id, p) end)
    if not hopOk then return false, tostring(hopErr) end
    return true, target.playing .. "/" .. target.maxPlayers
end

local IslandsData = {
    ["Sea 1"] = {
        {Name="1 - Starter Island",   Npc=CFrame.new(1059,16,1549),     MobPos=CFrame.new(1145,17,1630),     Mobs={"Bandit"}},
        {Name="2 - Jungle",           Npc=CFrame.new(-1598,36,153),     MobPos=CFrame.new(-1442,61,38),      Mobs={"Monkey","Gorilla"}},
        {Name="3 - Pirate Village",   Npc=CFrame.new(-1140,4,3828),     MobPos=CFrame.new(-1219,4,3916),     Mobs={"Pirate","Brute"}},
        {Name="4 - Desert",           Npc=CFrame.new(897,6,4389),       MobPos=CFrame.new(932,6,4484),       Mobs={"Desert Bandit","Desert Officer"}},
        {Name="5 - Frozen Village",   Npc=CFrame.new(1385,87,-1298),    MobPos=CFrame.new(1198,105,-1443),   Mobs={"Snow Bandit","Snowman","Yeti"}},
        {Name="6 - Marine Fortress",  Npc=CFrame.new(-5039,28,4324),    MobPos=CFrame.new(-4855,20,4308),    Mobs={"Chief Petty Officer","Vice Admiral"}},
        {Name="7 - Skylands",         Npc=CFrame.new(-4842,717,-2623),  MobPos=CFrame.new(-4970,717,-2622),  Mobs={"Sky Bandit","Dark Master"}},
        {Name="8 - Prison",           Npc=CFrame.new(5308,2,474),       MobPos=CFrame.new(5411,88,514),      Mobs={"Prisoner","Dangerous Prisoner","Warden"}},
        {Name="9 - Colosseum",        Npc=CFrame.new(-1580,7,-2986),    MobPos=CFrame.new(-1850,7,-2740),    Mobs={"Toga Warrior","Gladiator"}},
        {Name="10 - Magma Village",   Npc=CFrame.new(-5314,12,8516),    MobPos=CFrame.new(-5428,15,8454),    Mobs={"Military Soldier","Military Spy"}},
        {Name="11 - Underwater City", Npc=CFrame.new(61122,18,1569),    MobPos=CFrame.new(60880,18,1500),    Mobs={"Fishman Warrior","Fishman Commando"}},
        {Name="12 - Upper Skylands",  Npc=CFrame.new(-4721,845,-1954),  MobPos=CFrame.new(-4650,845,-1900),  Mobs={"God's Guard","Shanda","Wysper"}},
        {Name="13 - Fountain City",   Npc=CFrame.new(5259,38,4050),     MobPos=CFrame.new(5360,38,4120),     Mobs={"Galley Pirate","Galley Captain","Cyborg"}},
    },
    ["Sea 2"] = {
        {Name="1 - Kingdom of Rose",  Npc=CFrame.new(-427,72,1835),     MobPos=CFrame.new(-220,72,1950),     Mobs={"Raider","Mercenary","Diamond"}},
        {Name="2 - Kingdom of Rose 2",Npc=CFrame.new(-775,73,865),      MobPos=CFrame.new(-920,73,1020),     Mobs={"Swan Pirate","Factory Staff","Jeremy"}},
        {Name="3 - Green Zone",       Npc=CFrame.new(-2440,73,-3218),   MobPos=CFrame.new(-2280,73,-3100),   Mobs={"Marine Lieutenant","Marine Captain"}},
        {Name="4 - Graveyard",        Npc=CFrame.new(-5495,48,-794),    MobPos=CFrame.new(-5560,48,-700),    Mobs={"Zombie","Vampire"}},
        {Name="5 - Snow Mountain",    Npc=CFrame.new(607,401,-5370),    MobPos=CFrame.new(520,401,-5250),    Mobs={"Snow Lurker","Winter Warrior"}},
        {Name="6 - Hot and Cold",     Npc=CFrame.new(-6060,15,-4902),   MobPos=CFrame.new(-6200,15,-4800),   Mobs={"Lab Subordinate","Horned Warrior"}},
        {Name="7 - Cursed Ship",      Npc=CFrame.new(923,125,32852),    MobPos=CFrame.new(910,125,33000),    Mobs={"Ship Deckhand","Ship Engineer"}},
        {Name="8 - Ice Castle",       Npc=CFrame.new(5505,28,-6225),    MobPos=CFrame.new(5650,28,-6300),    Mobs={"Arctic Warrior","Snow Lurker"}},
        {Name="9 - Forgotten Island", Npc=CFrame.new(-3054,236,-10148), MobPos=CFrame.new(-3150,236,-10000), Mobs={"Sea Soldier","Water Fighter"}},
        {Name="10 - Great Tree",      Npc=CFrame.new(-9515,172,142),    MobPos=CFrame.new(-9400,172,200),    Mobs={"Grand Devotee","Cursed Skeleton"}},
        {Name="11 - Floating Turtle", Npc=CFrame.new(-13275,332,-7768), MobPos=CFrame.new(-13400,332,-7600), Mobs={"Forest Pirate","Mythological Pirate"}},
    },
    ["Sea 3"] = {
        {Name="1 - Port Town",        Npc=CFrame.new(-290,43,5430),     MobPos=CFrame.new(-450,73,5550),     Mobs={"Pirate Millionaire","Pistol Billionaire"}},
        {Name="2 - Hydra Island",     Npc=CFrame.new(5210,604,345),     MobPos=CFrame.new(5100,604,480),     Mobs={"Dragon Crew Warrior","Dragon Crew Archer"}},
        {Name="3 - Great Tree",       Npc=CFrame.new(2192,28,-6732),    MobPos=CFrame.new(2350,28,-6600),    Mobs={"Marine Commodore","Marine Rear Admiral","Kilo Admiral"}},
        {Name="4 - Floating Turtle",  Npc=CFrame.new(-13275,332,-7768), MobPos=CFrame.new(-13400,332,-7600), Mobs={"Forest Pirate","Mythological Pirate","Captain Elephant"}},
        {Name="5 - Haunted Castle",   Npc=CFrame.new(-9515,142,6078),   MobPos=CFrame.new(-9504,172,6050),   Mobs={"Reborn Skeleton","Living Zombie","Demonic Soul"}},
        {Name="6 - Sea of Treats",    Npc=CFrame.new(-2020,38,-12026),  MobPos=CFrame.new(-1900,38,-11900),  Mobs={"Cookie Crafter","Cake Guard","Head Baker"}},
        {Name="7 - Tiki Outpost",     Npc=CFrame.new(-16547,55,-173),   MobPos=CFrame.new(-16400,55,-100),   Mobs={"Isle Outlaw","Island Boy","Sun-kissed Warrior"}},
        {Name="8 - Sharkman Arena",   Npc=CFrame.new(-13000,350,-7800), MobPos=CFrame.new(-13100,350,-7700), Mobs={"Sharkman","Sea Beast"}},
    }
}

local RaidList = {"Flame", "Ice", "Rubber", "Quake", "Light", "Dark", "Magma", "Rumble", "Dough", "Spirit", "Dragon", "Phoenix"}

local C_Bg     = Color3.fromRGB(18,18,24)
local C_Side   = Color3.fromRGB(24,24,32)
local C_Card   = Color3.fromRGB(30,32,44)
local C_Accent = Color3.fromRGB(255,180,0)
local C_Green  = Color3.fromRGB(80,200,80)
local C_Text   = Color3.fromRGB(240,240,245)
local C_Gray   = Color3.fromRGB(140,145,165)
local C_Off    = Color3.fromRGB(50,52,68)

local statusLbl

local function safeClick(b, f)
    local busy = false
    b.Activated:Connect(function()
        if busy then return end
        busy = true
        local ok, err = pcall(f)
        if not ok then warn("[UI Error]:", err) end
        task.wait(0.12)
        busy = false
    end)
end

local function drag(h, t)
    local d, ds, sp
    h.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            d = true; ds = i.Position; sp = t.Position
        end
    end)
    uis.InputChanged:Connect(function(i)
        if d and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = i.Position - ds
            t.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
        end
    end)
    uis.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            d = false
        end
    end)
end

local function setStatus(txt)
    if statusLbl then statusLbl.Text = "Status : " .. tostring(txt) end
end

local gui = Instance.new("ScreenGui")
gui.Name = "StringtrapHub"
gui.ResetOnSpawn = false
gui.Parent = pGui

local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(0,340,0,46)
statusBar.Position = UDim2.new(0.5,-170,0,8)
statusBar.BackgroundColor3 = C_Side
statusBar.ZIndex = 200
statusBar.Parent = gui
statusBar.Visible = false
Instance.new("UICorner", statusBar).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", statusBar).Color = C_Accent

local statusTitle = Instance.new("TextLabel", statusBar)
statusTitle.Size = UDim2.new(1,0,0,18)
statusTitle.Position = UDim2.new(0,0,0,2)
statusTitle.BackgroundTransparency = 1
statusTitle.Text = "Stringtrap Status"
statusTitle.TextColor3 = C_Accent
statusTitle.Font = Enum.Font.GothamBlack
statusTitle.TextSize = 11
statusTitle.TextXAlignment = Enum.TextXAlignment.Center

statusLbl = Instance.new("TextLabel", statusBar)
statusLbl.Size = UDim2.new(1,-12,0,20)
statusLbl.Position = UDim2.new(0,6,0,22)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "Status : Idle"
statusLbl.TextColor3 = C_Text
statusLbl.Font = Enum.Font.GothamSemibold
statusLbl.TextSize = 10
statusLbl.TextXAlignment = Enum.TextXAlignment.Center

local kf = Instance.new("Frame")
kf.Size = UDim2.new(0,320,0,180)
kf.Position = UDim2.new(0.5,-160,0.5,-90)
kf.BackgroundColor3 = C_Bg
kf.ZIndex = 9999
kf.Parent = gui
Instance.new("UICorner", kf).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", kf).Color = C_Accent

local kft = Instance.new("Frame")
kft.Size = UDim2.new(1,0,0,34)
kft.BackgroundColor3 = C_Side
kft.ZIndex = 10000
kft.Parent = kf
Instance.new("UICorner", kft).CornerRadius = UDim.new(0,8)
drag(kft, kf)

local ktt = Instance.new("TextLabel", kft)
ktt.Size = UDim2.new(1,-20,1,0)
ktt.Position = UDim2.new(0,10,0,0)
ktt.BackgroundTransparency = 1
ktt.Text = "Stringtrap Hub"
ktt.TextColor3 = C_Accent
ktt.Font = Enum.Font.GothamBlack
ktt.TextSize = 13
ktt.TextXAlignment = Enum.TextXAlignment.Left
ktt.ZIndex = 10001

local ki = Instance.new("TextBox")
ki.Size = UDim2.new(0.86,0,0,38)
ki.Position = UDim2.new(0.07,0,0.34,0)
ki.BackgroundColor3 = C_Card
ki.TextColor3 = C_Text
ki.PlaceholderText = "Type the key..."
ki.Text = ""
ki.ClearTextOnFocus = false
ki.Font = Enum.Font.GothamSemibold
ki.TextSize = 12
ki.ZIndex = 10001
ki.Parent = kf
Instance.new("UICorner", ki).CornerRadius = UDim.new(0,6)

local kb = Instance.new("TextButton")
kb.Size = UDim2.new(0.86,0,0,40)
kb.Position = UDim2.new(0.07,0,0.65,0)
kb.BackgroundColor3 = C_Accent
kb.TextColor3 = Color3.fromRGB(15,15,20)
kb.Text = "LOAD STRINGTRAP HUB"
kb.Font = Enum.Font.GothamBlack
kb.TextSize = 13
kb.ZIndex = 10001
kb.Parent = kf
Instance.new("UICorner", kb).CornerRadius = UDim.new(0,6)

local photo = Instance.new("ImageButton")
photo.Size = UDim2.new(0,54,0,54)
photo.Position = UDim2.new(0,20,0.5,-27)
photo.BackgroundColor3 = C_Bg
photo.Image = IMG
photo.Visible = false
photo.Parent = gui
Instance.new("UICorner", photo).CornerRadius = UDim.new(0,10)
Instance.new("UIStroke", photo).Color = C_Accent
drag(photo, photo)

local mf = Instance.new("Frame")
mf.Size = UDim2.new(0,560,0,430)
mf.Position = UDim2.new(0.5,-280,0.5,-215)
mf.BackgroundColor3 = C_Bg
mf.Visible = false
mf.Parent = gui
Instance.new("UICorner", mf).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", mf).Color = C_Accent

local top = Instance.new("Frame")
top.Size = UDim2.new(1,0,0,36)
top.BackgroundColor3 = C_Side
top.Parent = mf
Instance.new("UICorner", top).CornerRadius = UDim.new(0,8)
drag(top, mf)

local ttl = Instance.new("TextLabel", top)
ttl.Size = UDim2.new(1,-50,1,0)
ttl.Position = UDim2.new(0,14,0,0)
ttl.BackgroundTransparency = 1
ttl.Text = "Stringtrap Hub"
ttl.TextColor3 = C_Accent
ttl.Font = Enum.Font.GothamBlack
ttl.TextSize = 13
ttl.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", top)
minBtn.Size = UDim2.new(0,28,0,22)
minBtn.Position = UDim2.new(1,-36,0.5,-11)
minBtn.BackgroundColor3 = C_Card
minBtn.Text = "-"
minBtn.TextColor3 = C_Text
minBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0,4)

safeClick(minBtn, function() mf.Visible = false end)
safeClick(photo, function() mf.Visible = not mf.Visible end)

safeClick(kb, function()
    if ki.Text == KEY or autoReload then
        cfg.unlocked = true
        kf.Visible = false
        mf.Visible = true
        photo.Visible = true
        statusBar.Visible = cfg.showStatusBar
        setStatus(autoReload and "Auto-Reloaded (Anti-Ban)" or "Idle")
    else
        kb.Text = "INVALID KEY"
        task.wait(1)
        kb.Text = "LOAD STRINGTRAP HUB"
    end
end)

if autoReload then
    cfg.unlocked = true
    kf.Visible = false
    mf.Visible = true
    photo.Visible = true
    statusBar.Visible = cfg.showStatusBar
    setStatus("Auto-Reloaded (Anti-Ban)")
end

local side = Instance.new("Frame")
side.Size = UDim2.new(0,150,1,-46)
side.Position = UDim2.new(0,6,0,40)
side.BackgroundColor3 = C_Side
side.Parent = mf
Instance.new("UICorner", side).CornerRadius = UDim.new(0,6)

local sl = Instance.new("UIListLayout", side)
sl.Padding = UDim.new(0,3)
sl.SortOrder = Enum.SortOrder.LayoutOrder

local sp = Instance.new("UIPadding", side)
sp.PaddingTop = UDim.new(0,6)
sp.PaddingLeft = UDim.new(0,6)
sp.PaddingRight = UDim.new(0,6)

local cont = Instance.new("Frame")
cont.Size = UDim2.new(1,-168,1,-46)
cont.Position = UDim2.new(0,162,0,40)
cont.BackgroundTransparency = 1
cont.Parent = mf

local ch = {}
local function createCh(n, o)
    local b = Instance.new("TextButton")
    b.LayoutOrder = o
    b.Size = UDim2.new(1,0,0,30)
    b.BackgroundColor3 = (o == 1) and C_Card or C_Bg
    b.Text = n
    b.TextColor3 = (o == 1) and C_Accent or C_Gray
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    b.Active = true
    b.Parent = side
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,5)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = C_Accent
    page.Visible = (o == 1)
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.Parent = cont

    local l = Instance.new("UIListLayout", page)
    l.Padding = UDim.new(0,5)
    l.SortOrder = Enum.SortOrder.LayoutOrder

    local pad = Instance.new("UIPadding", page)
    pad.PaddingTop = UDim.new(0,4)
    pad.PaddingBottom = UDim.new(0,4)
    pad.PaddingLeft = UDim.new(0,4)
    pad.PaddingRight = UDim.new(0,4)

    table.insert(ch, {btn = b, page = page})
    safeClick(b, function()
        for _, v in ipairs(ch) do
            v.page.Visible = false
            v.btn.BackgroundColor3 = C_Bg
            v.btn.TextColor3 = C_Gray
        end
        page.Visible = true
        b.BackgroundColor3 = C_Card
        b.TextColor3 = C_Accent
    end)
    return page
end

local function addSection(parent, txt)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1,0,0,22)
    f.BackgroundColor3 = C_Side
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,4)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1,-10,1,0)
    l.Position = UDim2.new(0,8,0,0)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = C_Accent
    l.Font = Enum.Font.GothamBlack
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
end

local function addDropdown(parent, title, list, currentKey, callback, isStrDrop)
    local mb = Instance.new("TextButton", parent)
    mb.Size = UDim2.new(1,0,0,36)
    mb.BackgroundColor3 = C_Card
    mb.Text = ""
    mb.AutoButtonColor = false
    mb.Active = true
    Instance.new("UICorner", mb).CornerRadius = UDim.new(0,6)

    local tl = Instance.new("TextLabel", mb)
    tl.Size = UDim2.new(0.48,0,1,0)
    tl.Position = UDim2.new(0,10,0,0)
    tl.BackgroundTransparency = 1
    tl.Text = title
    tl.TextColor3 = C_Gray
    tl.Font = Enum.Font.GothamSemibold
    tl.TextSize = 10
    tl.TextXAlignment = Enum.TextXAlignment.Left

    local initialIdx = 1
    local curVal = cfg[currentKey]
    if curVal ~= nil then
        for i, v in ipairs(list) do
            local tv = (type(v) == "table") and v.Name or tostring(v)
            if tostring(tv) == tostring(curVal) or i == curVal then
                initialIdx = i
                break
            end
        end
    end

    local vl = Instance.new("TextLabel", mb)
    vl.Size = UDim2.new(0.48,-10,1,0)
    vl.Position = UDim2.new(0.5,0,0,0)
    vl.BackgroundTransparency = 1
    local firstVal = list[initialIdx] or list[1]
    vl.Text = (type(firstVal) == "table") and firstVal.Name or tostring(firstVal)
    vl.TextColor3 = C_Accent
    vl.Font = Enum.Font.GothamBold
    vl.TextSize = 10
    vl.TextXAlignment = Enum.TextXAlignment.Right

    local lf = Instance.new("ScrollingFrame", parent)
    lf.Size = UDim2.new(1,0,0,0)
    lf.BackgroundColor3 = C_Side
    lf.BorderSizePixel = 0
    lf.Visible = false
    lf.CanvasSize = UDim2.new(0,0,0,0)
    lf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    lf.ScrollBarThickness = 3
    Instance.new("UICorner", lf).CornerRadius = UDim.new(0,6)
    local ll = Instance.new("UIListLayout", lf)
    ll.Padding = UDim.new(0,2)

    local function populate(lst)
        for _, v in pairs(lf:GetChildren()) do
            if v:IsA("TextButton") then v:Destroy() end
        end
        for i, v in ipairs(lst) do
            local vv, ii = v, i
            local opt = Instance.new("TextButton", lf)
            opt.Size = UDim2.new(1,-4,0,26)
            opt.BackgroundColor3 = C_Card
            opt.Text = (type(vv) == "table") and vv.Name or tostring(vv)
            opt.TextColor3 = C_Text
            opt.Font = Enum.Font.GothamSemibold
            opt.TextSize = 10
            Instance.new("UICorner", opt).CornerRadius = UDim.new(0,4)
            safeClick(opt, function()
                local valText = (type(vv) == "table") and vv.Name or tostring(vv)
                vl.Text = valText
                cfg[currentKey] = isStrDrop and valText or ii
                lf.Visible = false
                lf.Size = UDim2.new(1,0,0,0)
                if callback then callback(vv, ii) end
            end)
        end
    end
    populate(list)

    safeClick(mb, function()
        lf.Visible = not lf.Visible
        lf.Size = lf.Visible and UDim2.new(1,0,0,120) or UDim2.new(1,0,0,0)
    end)
    return {UpdateList = populate, SetText = function(txt) vl.Text = txt end}
end

local function addT(parent, txt, key, onToggle)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1,0,0,34)
    b.BackgroundColor3 = C_Card
    b.Text = ""
    b.AutoButtonColor = false
    b.Active = true
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)

    local l = Instance.new("TextLabel", b)
    l.Size = UDim2.new(1,-55,1,0)
    l.Position = UDim2.new(0,10,0,0)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = cfg[key] and C_Text or C_Gray
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = Enum.Font.GothamSemibold
    l.TextSize = 10

    local pill = Instance.new("Frame", b)
    pill.Size = UDim2.new(0,34,0,16)
    pill.Position = UDim2.new(1,-44,0.5,-8)
    pill.BackgroundColor3 = cfg[key] and C_Green or C_Off
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame", pill)
    knob.Size = UDim2.new(0,12,0,12)
    knob.Position = cfg[key] and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6)
    knob.BackgroundColor3 = Color3.fromRGB(240,240,240)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    safeClick(b, function()
        cfg[key] = not cfg[key]
        local on = cfg[key]
        l.TextColor3 = on and C_Text or C_Gray
        pill.BackgroundColor3 = on and C_Green or C_Off
        knob.Position = on and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6)
        if onToggle then onToggle(on) end
    end)
end

local function addActionBtn(parent, txt, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1,0,0,32)
    b.BackgroundColor3 = C_Card
    b.Text = txt
    b.TextColor3 = C_Accent
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    safeClick(b, callback)
end

local function addInputBox(parent, placeholder, callback)
    local box = Instance.new("TextBox", parent)
    box.Size = UDim2.new(1,0,0,32)
    box.BackgroundColor3 = C_Card
    box.PlaceholderText = placeholder
    box.Text = ""
    box.TextColor3 = C_Text
    box.Font = Enum.Font.GothamSemibold
    box.TextSize = 10
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)
    box.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then callback(box.Text) end
    end)
end

-- ============================================================
--  PAGES DEFINITIONS
-- ============================================================
local pageShop         = createCh("Shop", 1)
local pageStatusServer = createCh("Status And Server", 2)
local pageLocalPlayer  = createCh("LocalPlayer", 3)
local pageSettingFarm  = createCh("Setting Farm", 4)
local pageHoldSelect   = createCh("Hold and Select Skill", 5)
local pageFarming      = createCh("Farming", 6)
local pageStackFarm    = createCh("Stack Farming", 7)
local pageFarmingOther = createCh("Farming Other", 8)
local pageFruitRaid    = createCh("Fruit and Raid, Dungeo", 9)
local pageSeaEvent     = createCh("Sea Event", 10)
local pageUpgradeRace  = createCh("Upgrade Race", 11)
local pageGetItems     = createCh("Get and Upgrade Items", 12)
local pageVolcanoEvent = createCh("Volcano Event", 13)
local pageESP          = createCh("ESP", 14)
local pageTabWebhook   = createCh("Tab Webhook", 15)
local pageSetting      = createCh("Setting", 16)

-- TAB 1: Shop
addSection(pageShop, "Shop")
for _, item in ipairs({"Death Step", "Sharkman Karate", "Electric Claw", "Dragon Talon", "God Human", "Sanguine Art"}) do
    local it = item
    addT(pageShop, it, "buy_" .. it, function(on) if on then setStatus("Buying " .. it) end end)
end
addSection(pageShop, "Abilities Shop")
addActionBtn(pageShop, "Skyjump [10,000 Beli]", function()
    pcall(function() rs.Remotes.CommF_:InvokeServer("BuyHaki", "Geppo") end)
    setStatus("Purchased Skyjump")
end)
addActionBtn(pageShop, "Buso Haki [25,000 Beli]", function()
    pcall(function() rs.Remotes.CommF_:InvokeServer("BuyHaki", "Buso") end)
    setStatus("Purchased Buso Haki")
end)
addActionBtn(pageShop, "Observation haki [750,000 Beli]", function()
    pcall(function() rs.Remotes.CommF_:InvokeServer("BuyHaki", "Observation") end)
    setStatus("Purchased Observation Haki")
end)
addActionBtn(pageShop, "Soru [100,000 Beli]", function()
    pcall(function() rs.Remotes.CommF_:InvokeServer("BuyHaki", "Soru") end)
    setStatus("Purchased Soru")
end)

-- TAB 2: Status and Server
addSection(pageStatusServer, "Stringtrap Status UI")
addT(pageStatusServer, "Show Stringtrap Status UI", "showStatusBar", function(on) statusBar.Visible = on end)
addSection(pageStatusServer, "Status and Server")
for _, txt in ipairs({"Server Timer : 10h", "Next Time Spawn Fist of Darkness: 1h", "Elite Hunter : [Spawning]", "Tyrant Eyes : 4/5", "Cake Prince : 500 Mobs"}) do
    local lbl = Instance.new("TextLabel", pageStatusServer)
    lbl.Size = UDim2.new(1,-10,0,18)
    lbl.BackgroundTransparency = 1
    lbl.Text = "- " .. txt
    lbl.TextColor3 = C_Gray
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
end
addSection(pageStatusServer, "Server")
addActionBtn(pageStatusServer, "Open Gui Server Browser", function() setStatus("Opened Server Browser") end)
addInputBox(pageStatusServer, "Type JobId here...", function(txt) setStatus("JobId: " .. txt) end)
addActionBtn(pageStatusServer, "Spam Join", function() setStatus("Spam Join...") end)
addActionBtn(pageStatusServer, "Join JobId", function() setStatus("Joining...") end)

-- TAB 3: LocalPlayer
addSection(pageLocalPlayer, "LocalPlayer")
addDropdown(pageLocalPlayer, "Select Team:", {"Pirates", "Marines"}, "selectedTeam", function(v)
    cfg.selectedTeam = v
    setStatus("Team: " .. v)
end, true)
addActionBtn(pageLocalPlayer, "Change Team", function()
    local team = cfg.selectedTeam
    local oldTeam = p.Team and p.Team.Name or "Unknown"
    if oldTeam == team then setStatus("Already on " .. team) return end
    setStatus("Changing to " .. team .. "...")
    local ok, err = pcall(function() rs.Remotes.CommF_:InvokeServer("SetTeam", team) end)
    if not ok then setStatus("Failed: " .. tostring(err)) return end
    task.wait(0.6)
    if p.Character then
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 else p.Character:BreakJoints() end
    end
    setStatus("Switched: " .. oldTeam .. " -> " .. team)
end)
addT(pageLocalPlayer, "Noclip", "noclip", function(on) setStatus(on and "Noclip ON" or "Noclip OFF") end)
addInputBox(pageLocalPlayer, "Select Npc name...", function(txt) cfg.selectedNpc = txt end)
addActionBtn(pageLocalPlayer, "Teleport To Npc", function() setStatus("NPC: " .. tostring(cfg.selectedNpc)) end)
local currentSeaIslands = IslandsData[cfg.selectedSea] or IslandsData["Sea 1"]
addDropdown(pageLocalPlayer, "Select Island:", currentSeaIslands, "selectedIsland", function(v, i) cfg.selectedIsland = i end, false)
addActionBtn(pageLocalPlayer, "Teleport to Island", function()
    local island = currentSeaIslands[cfg.selectedIsland]
    if island and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        setStatus("Traveling: " .. island.Name)
        p.Character.HumanoidRootPart.CFrame = island.MobPos
    end
end)
addT(pageLocalPlayer, "Teleport Mirage", "teleportMirage")
addT(pageLocalPlayer, "Teleport Prehistoric Island", "teleportPrehistoricIsland")

-- TAB 4: Setting Farm
addSection(pageSettingFarm, "Setting Farm")
addDropdown(pageSettingFarm, "Select Weapon:", {"Melee", "Sword", "Gun", "Fruit"}, "selectedWeapon", function(v) cfg.selectedWeapon = v end, true)
addT(pageSettingFarm, "Attack No Animation", "attackNoAnim")
addT(pageSettingFarm, "Kill Aura Only Bald/Volcano", "killAuraOnlyBaldAndVolcano")
addDropdown(pageSettingFarm, "Time Delay Kill:", {1,2,3,4,5,6,7,8,9,10}, "timeDelayKill", function(v) cfg.timeDelayKill = tonumber(v) end, true)
addT(pageSettingFarm, "Auto Click", "autoClick")
addT(pageSettingFarm, "Kill Aura DragonStorm", "killAuraWithDragonStorm")
addT(pageSettingFarm, "Auto Turn On Buso", "autoTurnOnBuso")
addT(pageSettingFarm, "Auto Ken", "autoKen")
addT(pageSettingFarm, "Auto V3", "autoV3")
addT(pageSettingFarm, "Auto V4", "autoV4")

-- TAB 5: Hold and Select Skill
addSection(pageHoldSelect, "Select Skills")
for k, _ in pairs(cfg.skillsMelee) do
    addT(pageHoldSelect, "Melee Skill [" .. k .. "]", "skill_melee_" .. k, function(on) cfg.skillsMelee[k] = on end)
end
for k, _ in pairs(cfg.skillsSword) do
    addT(pageHoldSelect, "Sword Skill [" .. k .. "]", "skill_sword_" .. k, function(on) cfg.skillsSword[k] = on end)
end
addSection(pageHoldSelect, "Hold Skills")
addT(pageHoldSelect, "Use Skill Fast Don't Hold", "useSkillFastDontHold")

-- TAB 6: Farming
addSection(pageFarming, "Farming")
addDropdown(pageFarming, "Select Method Farm:", {"Level Farm", "Bone Farm", "Katana Farm", "Near Mob"}, "farmMethod", function(v) cfg.farmMethod = v end, true)
addDropdown(pageFarming, "Distance Aura:", {"100", "200", "300", "400", "500"}, "distanceFarmAura", function(v) cfg.distanceFarmAura = tonumber(v) end, true)
addT(pageFarming, "Ignore Katakuri", "ignoreAttackKatakuri")
addT(pageFarming, "Hop Find Katakuri", "hopFindKatakuri")
addT(pageFarming, "Auto Quest Katakuri", "autoQuestKatakuriBone")
addT(pageFarming, "Start Farm", "startFarm", function(on) if on then setStatus(on and ("Farm: " .. cfg.farmMethod) or "Idle") end end)
addSection(pageFarming, "Mastery Farm")
addDropdown(pageFarming, "Select Method:", {"Melee", "Sword", "Gun", "Fruit"}, "masteryMethod", function(v) cfg.masteryMethod = v end, true)
addT(pageFarming, "Farm Mastery", "farmMastery")

-- TAB 7: Stack Farming
addSection(pageStackFarm, "Stack Farming")
addT(pageStackFarm, "Auto New World", "autoNewWorld")
addT(pageStackFarm, "Auto Third World", "autoThirdWorld")
addT(pageStackFarm, "Collect Chest / God's Chalice", "collectChestGodsChaliceOrFOD")
addT(pageStackFarm, "Teleport to Fruit", "teleportToFruit")
addT(pageStackFarm, "Teleport to Fruit [Hop Server]", "teleportToFruitHopServer")
addSection(pageStackFarm, "Event Game")
addT(pageStackFarm, "Auto Factory", "autoFactory")
addT(pageStackFarm, "Auto Pirate Raid", "autoPirateRaid")
addSection(pageStackFarm, "Boss Rip Indra")
addT(pageStackFarm, "Auto Elite Hunter", "autoEliteHunter")
addT(pageStackFarm, "Hop Server Elite Hunter", "hopServerEliteHunter")
addT(pageStackFarm, "Auto Touch Pad Haki", "autoTouchPadHaki")
addT(pageStackFarm, "Auto Summon Rip Indra", "autoSummonRipIndra")
addT(pageStackFarm, "Attack Rip Indra", "attackRipIndra")

-- TAB 8: Farming Other
addSection(pageFarmingOther, "Event Easter")
addActionBtn(pageFarmingOther, "Open Easter Shop", function() setStatus("Opened Easter Shop") end)
addT(pageFarmingOther, "Auto Collect Egg Easter", "autoCollectEggEaster")
addSection(pageFarmingOther, "Fishing")
addT(pageFarmingOther, "Change Size Reel", "changeSizeReel")
addT(pageFarmingOther, "Auto Slap Battle", "autoSlapBattle")
addDropdown(pageFarmingOther, "Select Bait:", {"Default", "Rare Bait", "Epic Bait", "Legendary Bait"}, "selectedBait", function(v) cfg.selectedBait = v end, true)
addT(pageFarmingOther, "Auto Tween To Event Fishing Spot", "autoTweenToEventFishingSpot")
addT(pageFarmingOther, "Auto Sell Fishing", "autoSellFishing")
addT(pageFarmingOther, "Auto Open Chest", "autoOpenChest")
addSection(pageFarmingOther, "Quest Dragon & Dojo")
addT(pageFarmingOther, "Auto Quest Dojo Trainer", "autoQuestDojoTrainer")
addT(pageFarmingOther, "Auto Quest Dragon Hunter", "autoQuestDragonHunter")
addT(pageFarmingOther, "Auto Attack All Mob & Boss", "autoAttackAllMobAndBoss")
addT(pageFarmingOther, "Auto Collect Berry", "autoCollectBerry")

-- TAB 9: Fruit and Raid
addSection(pageFruitRaid, "Devil Fruit")
addT(pageFruitRaid, "Random Devil Fruit", "randomDevilFruit", function(on)
    if on then pcall(function() rs.Remotes.CommF_:InvokeServer("Cousin", "Buy") end) end
end)
addT(pageFruitRaid, "Auto Store Fruit", "autoStoreFruit")
addT(pageFruitRaid, "Buy Fruit Sniper Shop", "buyBloxFruitSniperShop")
addSection(pageFruitRaid, "Raids")
addDropdown(pageFruitRaid, "Select Raid:", RaidList, "selectedRaid", function(v) cfg.selectedRaid = v end, true)
addT(pageFruitRaid, "Get Fruit In Inventory Low Beli", "getFruitInInventoryLowBeli")
addT(pageFruitRaid, "Auto Raid", "autoRaid", function(on) if on then setStatus("Auto Raid: " .. cfg.selectedRaid) end end)
addT(pageFruitRaid, "Hop Server Raid", "hopSeverRaid")
addT(pageFruitRaid, "Auto Awake Fruit", "autoAwakeFruit")

-- TAB 10: Sea Event
addSection(pageSeaEvent, "Sea Event")
addT(pageSeaEvent, "Auto Sea Event", "autoSeaEvent")

-- TAB 11: Upgrade Race
addSection(pageUpgradeRace, "Upgrade Race")
addActionBtn(pageUpgradeRace, "Buy Race Reroll [3000 Frags]", function()
    pcall(function() rs.Remotes.CommF_:InvokeServer("Blackbeard", "Reroll") end)
end)

-- TAB 12: Get and Upgrade Items
addSection(pageGetItems, "Upgrade Items")
addActionBtn(pageGetItems, "Upgrade Equipped Weapon", function()
    setStatus("Upgraded Weapon")
end)

-- TAB 13: Volcano Event
addSection(pageVolcanoEvent, "Volcano Event")
addT(pageVolcanoEvent, "Auto Volcano Farm", "autoVolcanoFarm")

-- TAB 14: ESP
addSection(pageESP, "ESP Player & Fruits")
addT(pageESP, "ESP Players", "espPlayers")
addT(pageESP, "ESP Fruits", "espFruits")
addT(pageESP, "ESP Chests", "espChests")

-- TAB 15: Tab Webhook
addSection(pageTabWebhook, "Webhook Settings")
addInputBox(pageTabWebhook, "Input Webhook URL...", function(txt) cfg.webhookUrl = txt end)
addT(pageTabWebhook, "Ping Everyone / Discord", "webhookPing")
addT(pageTabWebhook, "Notify Fruit", "webhookFruit")

-- TAB 16: Setting
addSection(pageSetting, "Settings")
addT(pageSetting, "White Screen / Fast Mode", "fastMode", function(on)
    for _, v in ipairs(pGui:GetChildren()) do
        if v:IsA("ScreenGui") and v ~= gui then v.Enabled = not on end
    end
end)
addT(pageSetting, "Disable 3D Rendering", "noRender", function(on)
    game:GetService("RunService"):Set3dRenderingEnabled(not on)
end)
addActionBtn(pageSetting, "Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, p)
end)
addActionBtn(pageSetting, "Server Hop", function()
    setStatus("Searching...")
    task.spawn(function()
        local ok, info = hopServer()
        setStatus(ok and ("Hopping -> " .. info) or ("Failed: " .. info))
    end)
end)

-- ============================================================
--  BACKGROUND WORKERS (DELTA SAFE)
-- ============================================================
game:GetService("RunService").Stepped:Connect(function()
    if cfg.noclip and p.Character then
        for _, part in pairs(p.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

task.spawn(function()
    while task.wait(3) do
        if cfg.autoTurnOnBuso and p.Character then
            if not p.Character:FindFirstChild("HasBuso") then
                pcall(function() rs.Remotes.CommF_:InvokeServer("Buso") end)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.12) do
        if cfg.autoClick or cfg.startFarm or cfg.autoRaid then
            pcall(function()
                if vim and vim.SendMouseButtonEvent then
                    vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    task.wait(0.01)
                    vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                elseif vu and vu.Button1Down then
                    vu:Button1Down(Vector2.new(0, 0))
                    task.wait(0.01)
                    vu:Button1Up(Vector2.new(0, 0))
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if cfg.startFarm then
            local list = IslandsData[cfg.selectedSea] or IslandsData["Sea 1"]
            local target = list[cfg.selectedIsland] or list[1]
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and target then
                local hrp = p.Character.HumanoidRootPart
                local dist = (hrp.Position - target.MobPos.Position).Magnitude
                if dist > (tonumber(cfg.distanceFarmAura) or 350) then
                    setStatus("Traveling: " .. target.Name)
                    local t = TweenInfo.new(dist / 300, Enum.EasingStyle.Linear)
                    ts:Create(hrp, t, {CFrame = target.MobPos + Vector3.new(0, 30, 0)}):Play()
                else
                    setStatus("Fighting Mobs")
                end
            end
        elseif cfg.autoRaid then
            setStatus("Auto Raid [" .. cfg.selectedRaid .. "]")
        end
    end
end)

task.spawn(function()
    task.wait(15)
    local nextHop = math.random(ANTIBAN_MIN * 60, ANTIBAN_MAX * 60)
    local startedAt = tick()
    while true do
        task.wait(1)
        local elapsed = tick() - startedAt
        local remaining = math.max(0, math.floor(nextHop - elapsed))
        if cfg.showStatusBar and remaining % 30 == 0 and remaining > 0 then
            setStatus(string.format("Anti-Ban: hop em %02d:%02d", math.floor(remaining / 60), remaining % 60))
        end
        if elapsed >= nextHop then
            setStatus("Anti-Ban: Triggering...")
            if ANTIBAN_URL and ANTIBAN_URL ~= "" then
                local src = string.format([=[
getgenv().StringtrapHub_AutoReload = true
local success, result = pcall(function() return loadstring(game:HttpGet("%s"))() end)
if not success then warn("Reload error:", result) end
                ]=], ANTIBAN_URL)
                local qOk, qErr = queueTeleport(src)
                if not qOk then
                    warn("[Anti-Ban] queue falhou:", qErr)
                    task.wait(30)
                    nextHop = math.random(ANTIBAN_MIN * 60, ANTIBAN_MAX * 60)
                    startedAt = tick()
                    continue
                end
            else
                task.wait(3)
            end
            local ok, info = hopServer()
            if ok then
                setStatus("Anti-Ban: Hopping -> " .. info)
                task.wait(15)
            else
                setStatus("Failed: " .. info)
                task.wait(30)
            end
            nextHop = math.random(ANTIBAN_MIN * 60, ANTIBAN_MAX * 60)
            startedAt = tick()
        end
    end
end)
