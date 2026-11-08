-- ============================================================
--  STRINGTRAP HUB - BLOX FRUITS (UPDATE 30 / HALLOWEEN 2026)
--  VERSÃO CORRIGIDA COMPLETA: BUGS FIX + HALLOWEEN + ESP FRUTAS + OTIMIZAÇÕES
-- ============================================================
local ANTIBAN_URL = "https://raw.githubusercontent.com/contadeteste9013-a11y/stringtrap-hub/main/stringtrap.lua"
local ANTIBAN_MIN = 30
local ANTIBAN_MAX = 40

if not game:IsLoaded() then
    pcall(function() game.Loaded:Wait() end)
end

local Players = game:GetService("Players")
local uis = game:GetService("UserInputService")
local vim = game:GetService("VirtualInputManager")
local ts = game:GetService("TweenService")
local rs = game:GetService("ReplicatedStorage")
local vu = game:GetService("VirtualUser")
local runS = game:GetService("RunService")
local httpS = game:GetService("HttpService")
local tsService = game:GetService("TeleportService")
local p = Players.LocalPlayer

local function getSafeGuiParent()
    local success, core = pcall(function()
        if typeof(gethui) == "function" then
            return gethui()
        end
        return game:GetService("CoreGui")
    end)
    if success and core then return core end
    return p:WaitForChild("PlayerGui", 10) or p:FindFirstChildOfClass("PlayerGui")
end

local guiContainer = getSafeGuiParent()
if guiContainer and guiContainer:FindFirstChild("StringtrapHub") then
    pcall(function() guiContainer.StringtrapHub:Destroy() end)
end

local getgenv = getgenv or function() return _G end

-- ============================================================
--  CONFIGURAÇÕES GERAIS & HALLOWEEN 2026 COMPLETO
-- ============================================================
local cfg = {
    unlocked = false,
    showStatusBar = true,
    selectedWeapon = "Melee",
    fastAttack = true,
    fastAttackMode = "Banana Fast Click",
    fastAttackDelay = 0.03,
    attackNoAnim = true,
    autoClick = false, -- FIX: FALSE POR PADRÃO (EVITA BAN)
    autoTurnOnBuso = true,
    autoKen = false,
    autoV3 = false,
    autoV4 = false,
    farmMethod = "Level Farm",
    distanceFarmAura = 300,
    startFarm = false,
    autoQuest = true,
    autoEquipWeapon = true,
    farmMastery = false,
    masteryMethod = "Melee",
    bringMobs = true,

    -- HALLOWEEN 2026 / UPDATE 30 - EXPANDIDO
    autoHalloweenEvent = false,
    farmPumpkins = false,
    prioritizeBossGreatPumpkin = false,
    skipJackOfLantern = false,
    autoTrickOrTreat = false,
    autoGreatPumpkinBoss = false,
    summonGreatPumpkin = false,
    autoGachaHalloween = false,
    autoRollSpookyGacha = false,
    autoCloseGachaUI = true,
    spookyGachaAllowSilverKey = false,
    autoCandyGravePumpkinHunt = false,
    mysteryHallSolver = false,
    autoBreakGraveUnlockEgg = false,
    sweetRiddleSolver = false,
    travelViaHalloweenPortal = false,
    witchCauldronAuto = false,
    autoFarmMagnetToken = false,
    autoRollMagnetGacha = false,
    autoCollectCandy = false,
    autoExchangeCandy = false,
    farmCandyCorn = false,
    autoHalloweenRace = false,
    autoSoulGuitar = false,

    -- OUTROS & ESP DE FRUTAS FIX
    selectedTeam = "Pirates",
    noclip = false,
    selectedIsland = 1,
    selectedSea = "Sea 1",
    selectedRaid = "Flame",
    autoRaid = false,
    fastMode = false,
    noRender = false,
    espFruit = false, -- FIX: FALSE POR PADRÃO (PERFORMANCE)

    -- NOVOS: Config persistência
    configVersion = 2,
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
if getgenv().StringtrapHub_AutoReload == true then
    autoReload = true
    getgenv().StringtrapHub_AutoReload = nil
end

local function queueTeleport(source)
    local qot = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
    if qot then return pcall(qot, source) end
    return false, "Nao suportado"
end

local function hopServer()
    local ok, res = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return httpS:JSONDecode(game:HttpGetAsync(url))
    end)
    if not ok or not res or not res.data then
        local rj = pcall(function() tsService:Teleport(game.PlaceId, p) end)
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
        local rj = pcall(function() tsService:Teleport(game.PlaceId, p) end)
        if rj then return true, "rejoin" end
        return false, "Sem servers"
    end
    table.sort(candidates, function(a, b) return a.playing < b.playing end)
    local target = candidates[1]
    local hopOk, hopErr = pcall(function() tsService:TeleportToPlaceInstance(game.PlaceId, target.id, p) end)
    if not hopOk then return false, tostring(hopErr) end
    return true, target.playing .. "/" .. target.maxPlayers
end

-- ============================================================
--  BANCO DE DADOS DE QUESTS POR SEA (COMPLETO)
-- ============================================================
local QuestsData = {
    -- Sea 1
    {sea = "Sea 1", lvl = 1, quest = "BanditQuest1", npcPos = CFrame.new(1059, 16, 1549), mob = "Bandit", mobPos = CFrame.new(1145, 17, 1630), questNum = 1},
    {sea = "Sea 1", lvl = 10, quest = "JungleQuest", npcPos = CFrame.new(-1598, 36, 153), mob = "Monkey", mobPos = CFrame.new(-1442, 61, 38), questNum = 1},
    {sea = "Sea 1", lvl = 15, quest = "JungleQuest", npcPos = CFrame.new(-1598, 36, 153), mob = "Gorilla", mobPos = CFrame.new(-1240, 6, -490), questNum = 2},
    {sea = "Sea 1", lvl = 30, quest = "BuggyQuest1", npcPos = CFrame.new(-1140, 4, 3828), mob = "Pirate", mobPos = CFrame.new(-1219, 4, 3916), questNum = 1},
    {sea = "Sea 1", lvl = 40, quest = "BuggyQuest1", npcPos = CFrame.new(-1140, 4, 3828), mob = "Brute", mobPos = CFrame.new(-1146, 77, 4476), questNum = 2},
    {sea = "Sea 1", lvl = 60, quest = "DesertQuest", npcPos = CFrame.new(897, 6, 4389), mob = "Desert Bandit", mobPos = CFrame.new(932, 6, 4484), questNum = 1},
    {sea = "Sea 1", lvl = 75, quest = "DesertQuest", npcPos = CFrame.new(897, 6, 4389), mob = "Desert Officer", mobPos = CFrame.new(1572, 10, 4373), questNum = 2},
    {sea = "Sea 1", lvl = 90, quest = "SnowQuest", npcPos = CFrame.new(1385, 87, -1298), mob = "Snow Bandit", mobPos = CFrame.new(1287, 150, -1443), questNum = 1},
    {sea = "Sea 1", lvl = 100, quest = "SnowQuest", npcPos = CFrame.new(1385, 87, -1298), mob = "Snowman", mobPos = CFrame.new(1198, 105, -1443), questNum = 2},
    {sea = "Sea 1", lvl = 120, quest = "MarineQuest2", npcPos = CFrame.new(-5039, 28, 4324), mob = "Chief Petty Officer", mobPos = CFrame.new(-4855, 20, 4308), questNum = 1},
    {sea = "Sea 1", lvl = 150, quest = "SkyQuest", npcPos = CFrame.new(-4842, 717, -2623), mob = "Sky Bandit", mobPos = CFrame.new(-4970, 717, -2622), questNum = 1},
    {sea = "Sea 1", lvl = 175, quest = "SkyQuest", npcPos = CFrame.new(-4842, 717, -2623), mob = "Dark Master", mobPos = CFrame.new(-5230, 391, -2250), questNum = 2},
    {sea = "Sea 1", lvl = 190, quest = "PrisonerQuest", npcPos = CFrame.new(5308, 2, 474), mob = "Prisoner", mobPos = CFrame.new(5411, 88, 514), questNum = 1},
    {sea = "Sea 1", lvl = 210, quest = "PrisonerQuest", npcPos = CFrame.new(5308, 2, 474), mob = "Dangerous Prisoner", mobPos = CFrame.new(5540, 88, 710), questNum = 2},
    {sea = "Sea 1", lvl = 250, quest = "ColosseumQuest", npcPos = CFrame.new(-1580, 7, -2986), mob = "Toga Warrior", mobPos = CFrame.new(-1850, 7, -2740), questNum = 1},
    {sea = "Sea 1", lvl = 300, quest = "MagmaQuest", npcPos = CFrame.new(-5314, 12, 8516), mob = "Military Soldier", mobPos = CFrame.new(-5428, 15, 8454), questNum = 1},
    {sea = "Sea 1", lvl = 325, quest = "MagmaQuest", npcPos = CFrame.new(-5314, 12, 8516), mob = "Military Spy", mobPos = CFrame.new(-5815, 77, 8820), questNum = 2},
    {sea = "Sea 1", lvl = 375, quest = "FishmanQuest", npcPos = CFrame.new(61122, 18, 1569), mob = "Fishman Warrior", mobPos = CFrame.new(60880, 18, 1500), questNum = 1},
    {sea = "Sea 1", lvl = 400, quest = "FishmanQuest", npcPos = CFrame.new(61122, 18, 1569), mob = "Fishman Commando", mobPos = CFrame.new(61800, 18, 1450), questNum = 2},
    {sea = "Sea 1", lvl = 450, quest = "SkyExp1Quest", npcPos = CFrame.new(-4721, 845, -1954), mob = "God's Guard", mobPos = CFrame.new(-4650, 845, -1900), questNum = 1},
    {sea = "Sea 1", lvl = 525, quest = "SkyExp2Quest", npcPos = CFrame.new(-7903, 5635, -1412), mob = "Royal Squad", mobPos = CFrame.new(-7663, 5610, -1443), questNum = 1},
    {sea = "Sea 1", lvl = 625, quest = "FountainQuest", npcPos = CFrame.new(5259, 38, 4050), mob = "Galley Pirate", mobPos = CFrame.new(5360, 38, 4120), questNum = 1},
    {sea = "Sea 1", lvl = 650, quest = "FountainQuest", npcPos = CFrame.new(5259, 38, 4050), mob = "Galley Captain", mobPos = CFrame.new(5650, 38, 4950), questNum = 2},
    {sea = "Sea 1", lvl = 700, quest = "Area1Quest", npcPos = CFrame.new(-427, 72, 1835), mob = "Raider", mobPos = CFrame.new(-220, 72, 1950), questNum = 1},
    {sea = "Sea 1", lvl = 725, quest = "Area1Quest", npcPos = CFrame.new(-427, 72, 1835), mob = "Mercenary", mobPos = CFrame.new(-380, 72, 1500), questNum = 2},
    {sea = "Sea 1", lvl = 775, quest = "Area2Quest", npcPos = CFrame.new(-775, 73, 865), mob = "Swan Pirate", mobPos = CFrame.new(-920, 73, 1020), questNum = 1},
    {sea = "Sea 1", lvl = 800, quest = "Area2Quest", npcPos = CFrame.new(-775, 73, 865), mob = "Factory Staff", mobPos = CFrame.new(600, 80, 200), questNum = 2},
    {sea = "Sea 1", lvl = 875, quest = "MarineQuest3", npcPos = CFrame.new(-2440, 73, -3218), mob = "Marine Lieutenant", mobPos = CFrame.new(-2280, 73, -3100), questNum = 1},
    {sea = "Sea 1", lvl = 900, quest = "MarineQuest3", npcPos = CFrame.new(-2440, 73, -3218), mob = "Marine Captain", mobPos = CFrame.new(-2100, 73, -3300), questNum = 2},
    {sea = "Sea 1", lvl = 950, quest = "ZombieQuest", npcPos = CFrame.new(-5495, 48, -794), mob = "Zombie", mobPos = CFrame.new(-5560, 48, -700), questNum = 1},
    {sea = "Sea 1", lvl = 1000, quest = "ZombieQuest", npcPos = CFrame.new(-5495, 48, -794), mob = "Vampire", mobPos = CFrame.new(-6000, 6, -1300), questNum = 2},
    {sea = "Sea 1", lvl = 1050, quest = "SnowMountainQuest", npcPos = CFrame.new(607, 401, -5370), mob = "Snow Trooper", mobPos = CFrame.new(520, 401, -5250), questNum = 1},
    {sea = "Sea 1", lvl = 1100, quest = "SnowMountainQuest", npcPos = CFrame.new(607, 401, -5370), mob = "Winter Warrior", mobPos = CFrame.new(1150, 430, -5180), questNum = 2},
    {sea = "Sea 1", lvl = 1150, quest = "IceSideQuest", npcPos = CFrame.new(-6060, 15, -4902), mob = "Lab Subordinate", mobPos = CFrame.new(-6200, 15, -4800), questNum = 1},
    {sea = "Sea 1", lvl = 1175, quest = "IceSideQuest", npcPos = CFrame.new(-6060, 15, -4902), mob = "Horned Warrior", mobPos = CFrame.new(-6400, 15, -5800), questNum = 2},
    -- Sea 2
    {sea = "Sea 2", lvl = 1250, quest = "ShipQuest1", npcPos = CFrame.new(923, 125, 32852), mob = "Ship Deckhand", mobPos = CFrame.new(910, 125, 33000), questNum = 1},
    {sea = "Sea 2", lvl = 1275, quest = "ShipQuest1", npcPos = CFrame.new(923, 125, 32852), mob = "Ship Engineer", mobPos = CFrame.new(850, 125, 33200), questNum = 2},
    {sea = "Sea 2", lvl = 1350, quest = "FrostQuest", npcPos = CFrame.new(5505, 28, -6225), mob = "Arctic Warrior", mobPos = CFrame.new(5650, 28, -6300), questNum = 1},
    {sea = "Sea 2", lvl = 1425, quest = "ForgottenQuest", npcPos = CFrame.new(-3054, 236, -10148), mob = "Sea Soldier", mobPos = CFrame.new(-3150, 236, -10000), questNum = 1},
    {sea = "Sea 2", lvl = 1450, quest = "ForgottenQuest", npcPos = CFrame.new(-3054, 236, -10148), mob = "Water Fighter", mobPos = CFrame.new(-3400, 236, -10500), questNum = 2},
    {sea = "Sea 2", lvl = 1500, quest = "PiratePortQuest", npcPos = CFrame.new(-290, 43, 5430), mob = "Pirate Millionaire", mobPos = CFrame.new(-450, 73, 5550), questNum = 1},
    {sea = "Sea 2", lvl = 1525, quest = "PiratePortQuest", npcPos = CFrame.new(-290, 43, 5430), mob = "Pistol Billionaire", mobPos = CFrame.new(-200, 73, 5900), questNum = 2},
    {sea = "Sea 2", lvl = 1575, quest = "AmazonQuest", npcPos = CFrame.new(5210, 604, 345), mob = "Dragon Crew Warrior", mobPos = CFrame.new(5100, 604, 480), questNum = 1},
    {sea = "Sea 2", lvl = 1600, quest = "AmazonQuest", npcPos = CFrame.new(5210, 604, 345), mob = "Dragon Crew Archer", mobPos = CFrame.new(6200, 604, 200), questNum = 2},
    {sea = "Sea 2", lvl = 1700, quest = "MarineTreeIsland", npcPos = CFrame.new(2192, 28, -6732), mob = "Marine Commodore", mobPos = CFrame.new(2350, 28, -6600), questNum = 1},
    {sea = "Sea 2", lvl = 1725, quest = "MarineTreeIsland", npcPos = CFrame.new(2192, 28, -6732), mob = "Marine Rear Admiral", mobPos = CFrame.new(2600, 28, -7000), questNum = 2},
    {sea = "Sea 2", lvl = 1775, quest = "DeepForestIsland", npcPos = CFrame.new(-13275, 332, -7768), mob = "Forest Pirate", mobPos = CFrame.new(-13400, 332, -7600), questNum = 1},
    {sea = "Sea 2", lvl = 1800, quest = "DeepForestIsland", npcPos = CFrame.new(-13275, 332, -7768), mob = "Mythological Pirate", mobPos = CFrame.new(-13600, 332, -7000), questNum = 2},
    -- Sea 3
    {sea = "Sea 3", lvl = 1975, quest = "HauntedQuest1", npcPos = CFrame.new(-9515, 142, 6078), mob = "Reborn Skeleton", mobPos = CFrame.new(-9504, 172, 6050), questNum = 1},
    {sea = "Sea 3", lvl = 2000, quest = "HauntedQuest1", npcPos = CFrame.new(-9515, 142, 6078), mob = "Living Zombie", mobPos = CFrame.new(-9700, 172, 6200), questNum = 2},
    {sea = "Sea 3", lvl = 2075, quest = "TreatQuest1", npcPos = CFrame.new(-2020, 38, -12026), mob = "Cookie Crafter", mobPos = CFrame.new(-1900, 38, -11900), questNum = 1},
    {sea = "Sea 3", lvl = 2100, quest = "TreatQuest1", npcPos = CFrame.new(-2020, 38, -12026), mob = "Cake Guard", mobPos = CFrame.new(-1600, 38, -12400), questNum = 2},
    {sea = "Sea 3", lvl = 2200, quest = "TreatQuest2", npcPos = CFrame.new(-2020, 38, -12026), mob = "Baking Staff", mobPos = CFrame.new(-1800, 38, -12800), questNum = 1},
    {sea = "Sea 3", lvl = 2225, quest = "TreatQuest2", npcPos = CFrame.new(-2020, 38, -12026), mob = "Head Baker", mobPos = CFrame.new(-2100, 38, -13000), questNum = 2},
    {sea = "Sea 3", lvl = 2450, quest = "TikiQuest1", npcPos = CFrame.new(-16547, 55, -173), mob = "Isle Outlaw", mobPos = CFrame.new(-16400, 55, -100), questNum = 1},
    {sea = "Sea 3", lvl = 2500, quest = "TikiQuest1", npcPos = CFrame.new(-16547, 55, -173), mob = "Island Boy", mobPos = CFrame.new(-16600, 55, -300), questNum = 2},
    {sea = "Sea 3", lvl = 2550, quest = "TikiQuest2", npcPos = CFrame.new(-16547, 55, -173), mob = "Sun-kissed Warrior", mobPos = CFrame.new(-16800, 55, -500), questNum = 1},
}

local function getPlayerLevel()
    local ok, lvl = pcall(function()
        return p.Data.Level.Value
    end)
    return (ok and lvl) or 1
end

local function getCurrentQuest()
    local myLvl = getPlayerLevel()
    local mySea = cfg.selectedSea
    local best = nil
    for _, q in ipairs(QuestsData) do
        if q.sea == mySea and myLvl >= q.lvl then
            best = q
        elseif q.sea == mySea and myLvl < q.lvl then
            break
        end
    end
    if not best then
        for _, q in ipairs(QuestsData) do
            if q.sea == "Sea 1" and myLvl >= q.lvl then
                best = q
            elseif q.sea == "Sea 1" and myLvl < q.lvl then
                break
            end
        end
    end
    return best or QuestsData[1]
end

local function hasActiveQuest()
    local active = false
    pcall(function()
        local pGuiSafe = p:FindFirstChildOfClass("PlayerGui")
        if pGuiSafe and pGuiSafe:FindFirstChild("Main") and pGuiSafe.Main:FindFirstChild("Quest") then
            active = pGuiSafe.Main.Quest.Visible
        end
    end)
    return active
end

local function getActiveQuestName()
    local name = nil
    pcall(function()
        local pGuiSafe = p:FindFirstChildOfClass("PlayerGui")
        if pGuiSafe and pGuiSafe:FindFirstChild("Main") and pGuiSafe.Main:FindFirstChild("Quest") then
            local q = pGuiSafe.Main.Quest
            if q.Visible and q:FindFirstChild("Container") and q.Container:FindFirstChild("QuestTitle") then
                name = q.Container.QuestTitle.Text
            end
        end
    end)
    return name
end

-- ============================================================
--  SISTEMA FAST ATACK & AUTO CLICK OTIMIZADO
-- ============================================================
local CombatController = nil
task.spawn(function()
    pcall(function()
        local ps = p:WaitForChild("PlayerScripts", 5)
        if ps and ps:FindFirstChild("CombatFramework") then
            CombatController = require(ps.CombatFramework)
        end
    end)
end)

local function equipTool(toolType)
    if not p.Character then return end
    local char = p.Character
    for _, t in pairs(char:GetChildren()) do
        if t:IsA("Tool") and t:FindFirstChild("ToolTip") and string.find(string.lower(t.ToolTip), string.lower(toolType)) then
            return t
        end
    end
    local bp = p:FindFirstChild("Backpack")
    if bp then
        for _, t in pairs(bp:GetChildren()) do
            if t:IsA("Tool") and t:FindFirstChild("ToolTip") and string.find(string.lower(t.ToolTip), string.lower(toolType)) then
                t.Parent = char
                return t
            end
        end
    end
end

local hitRemoteCache = nil
local validatorRemoteCache = nil
local commFCache = nil

local function getHitRemote()
    if hitRemoteCache and hitRemoteCache.Parent then return hitRemoteCache end
    local remotes = rs:FindFirstChild("Remotes")
    if remotes then
        hitRemoteCache = remotes:FindFirstChild("RegisterHit") or rs:FindFirstChild("Hit", true)
    else
        hitRemoteCache = rs:FindFirstChild("Hit", true)
    end
    return hitRemoteCache
end

local function getValidatorRemote()
    if validatorRemoteCache and validatorRemoteCache.Parent then return validatorRemoteCache end
    local remotes = rs:FindFirstChild("Remotes")
    if remotes then
        validatorRemoteCache = remotes:FindFirstChild("Validator")
    end
    return validatorRemoteCache
end

local function getCommF()
    if commFCache and commFCache.Parent then return commFCache end
    commFCache = rs:FindFirstChild("Remotes") and rs.Remotes:FindFirstChild("CommF_") or rs:FindFirstChild("CommF_", true)
    return commFCache
end

local function safeInvoke(remote, ...)
    local ok, result = pcall(function() return remote:InvokeServer(...) end)
    if not ok then
        warn("[Stringtrap] InvokeServer falhou:", remote.Name, result)
    end
    return ok, result
end

local function safeFire(remote, ...)
    local ok, result = pcall(function() remote:FireServer(...) end)
    if not ok then
        warn("[Stringtrap] FireServer falhou:", remote.Name, result)
    end
    return ok
end

local function doFastAttack()
    if not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then return end
    equipTool(cfg.selectedWeapon)

    local hrp = p.Character.HumanoidRootPart
    local hitTargets = {}

    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, mob in ipairs(enemiesFolder:GetChildren()) do
            local mHrp = mob:FindFirstChild("HumanoidRootPart")
            local mHum = mob:FindFirstChildOfClass("Humanoid")
            if mHrp and mHum and mHum.Health > 0 and (mHrp.Position - hrp.Position).Magnitude <= 65 then
                table.insert(hitTargets, mHrp)
                if #hitTargets >= 10 then break end
            end
        end
    end

    if #hitTargets > 0 then
        task.spawn(function()
            pcall(function()
                local activeTool = p.Character:FindFirstChildOfClass("Tool")
                if activeTool then
                    local validator = getValidatorRemote()
                    if validator then
                        -- FIX: tick() em vez de os.clock()
                        validator:FireServer(math.floor(tick() * 1000))
                    end

                    local hitRemote = getHitRemote()
                    if hitRemote then
                        hitRemote:FireServer(hitTargets[1], hitTargets)
                    end
                end
            end)
        end)
    end

    pcall(function()
        if vim and vim.SendMouseButtonEvent then
            vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        elseif vu and vu.Button1Down then
            vu:Button1Down(Vector2.new(0, 0))
            vu:Button1Up(Vector2.new(0, 0))
        end
    end)
end

-- ============================================================
--  CACHE PARA OTIMIZAÇÃO DE HALLOWEEN & ESP FRUTAS
-- ============================================================
local halloweenCache = {
    pumpkins = {},
    graves = {},
    candy = {},
    magnetTokens = {},
    lastScan = 0,
    scanInterval = 2.0
}

local fruitCache = {
    fruits = {},
    billboards = {},
    lastScan = 0,
    scanInterval = 3.0, -- FIX: 3s em vez de 1.5s
    validFruitNames = {
        -- Lista de frutas reais do Blox Fruits (parcial)
        "Rocket", "Spin", "Blade", "Spring", "Bomb", "Smoke", "Spike", "Flame", "Falcon", "Ice",
        "Sand", "Dark", "Diamond", "Light", "Rubber", "Barrier", "Magma", "Quake", "Human",
        "Spider", "Bird", "Phoenix", "Rumble", "Pain", "Gravity", "Dough", "Shadow", "Venom",
        "Control", "Spirit", "Dragon", "Leopard", "Kitsune", "T-Rex", "Mammoth", "Gas", "Yeti"
    }
}

local function isValidFruit(tool)
    if not tool:IsA("Tool") then return false end
    if tool:FindFirstChild("ToolTip") and tool.ToolTip.Value == "Blox Fruit" then return true end
    local name = tool.Name
    for _, v in ipairs(fruitCache.validFruitNames) do
        if string.find(string.lower(name), string.lower(v)) then return true end
    end
    return false
end

local function scanHalloweenObjects()
    local now = os.clock()
    if now - halloweenCache.lastScan < halloweenCache.scanInterval then return end
    halloweenCache.lastScan = now
    halloweenCache.pumpkins = {}
    halloweenCache.graves = {}
    halloweenCache.candy = {}
    halloweenCache.magnetTokens = {}

    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local lname = string.lower(obj.Name)
                local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if primary then
                    if string.find(lname, "pumpkin") or string.find(lname, "jack") then
                        table.insert(halloweenCache.pumpkins, {model = obj, part = primary, isBoss = string.find(lname, "great") or string.find(lname, "boss")})
                    elseif string.find(lname, "grave") or string.find(lname, "candy") then
                        table.insert(halloweenCache.graves, {model = obj, part = primary})
                    elseif string.find(lname, "candycorn") or string.find(lname, "candy_corn") then
                        table.insert(halloweenCache.candy, {model = obj, part = primary})
                    elseif string.find(lname, "magnet") then
                        table.insert(halloweenCache.magnetTokens, {model = obj, part = primary})
                    end
                end
            elseif obj:IsA("BasePart") then
                local lname = string.lower(obj.Name)
                if string.find(lname, "candy") or string.find(lname, "candycorn") then
                    table.insert(halloweenCache.candy, {model = obj, part = obj})
                elseif string.find(lname, "magnet") then
                    table.insert(halloweenCache.magnetTokens, {model = obj, part = obj})
                end
            end
        end
    end)
end

local function scanFruits()
    local now = os.clock()
    if now - fruitCache.lastScan < fruitCache.scanInterval then return end
    fruitCache.lastScan = now

    local containers = {workspace, rs:FindFirstChild("LoadedEnemies"), rs}
    local found = {}

    for _, container in ipairs(containers) do
        if container then
            pcall(function()
                for _, obj in ipairs(container:GetDescendants()) do
                    if isValidFruit(obj) then
                        local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                        if handle then
                            table.insert(found, {tool = obj, part = handle, name = obj.Name})
                        end
                    end
                end
            end)
        end
    end

    fruitCache.fruits = found

    -- Cleanup billboards inválidos
    for tool, bb in pairs(fruitCache.billboards) do
        if not tool or not tool.Parent or not bb or not bb.Parent then
            if bb and bb.Parent then pcall(function() bb:Destroy() end) end
            fruitCache.billboards[tool] = nil
        end
    end
end

local function createFruitESP(tool, part, name)
    if fruitCache.billboards[tool] then return end
    local bb = Instance.new("BillboardGui")
    bb.Name = "StringtrapFruitESP"
    bb.Adornee = part
    bb.Size = UDim2.new(0, 120, 0, 40)
    bb.StudsOffset = Vector3.new(0, 5, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 5000
    bb.Parent = part

    local lbl = Instance.new("TextLabel", bb)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "🍎 " .. name
    lbl.TextColor3 = Color3.fromRGB(255, 200, 0)
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextSize = 14
    lbl.TextScaled = true

    fruitCache.billboards[tool] = bb
end

local function removeFruitESP(tool)
    local bb = fruitCache.billboards[tool]
    if bb then
        pcall(function() bb:Destroy() end)
        fruitCache.billboards[tool] = nil
    end
end

-- ============================================================
--  INTERFACE GRÁFICA (PROTEÇÃO CORE/DELTA HUI)
-- ============================================================
local C_Bg = Color3.fromRGB(18,18,24)
local C_Side = Color3.fromRGB(24,24,32)
local C_Card = Color3.fromRGB(30,32,44)
local C_Accent = Color3.fromRGB(255,180,0)
local C_Green = Color3.fromRGB(80,200,80)
local C_Text = Color3.fromRGB(240,240,245)
local C_Gray = Color3.fromRGB(140,145,165)
local C_Off = Color3.fromRGB(50,52,68)

local statusLbl

local function safeClick(b, f)
    local busy = false
    b.Activated:Connect(function()
        if busy then return end
        busy = true
        pcall(f)
        task.wait(0.08)
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
    pcall(function()
        if statusLbl then statusLbl.Text = "Status : " .. tostring(txt) end
    end)
end

local gui = Instance.new("ScreenGui")
gui.Name = "StringtrapHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    gui.Parent = guiContainer
end)

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
statusTitle.Text = "Stringtrap Status (Halloween 2026)"
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
ktt.Text = "Stringtrap Hub - Blox Fruits"
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
ttl.Text = "Stringtrap Hub · Update 30 Halloween"
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
        statusBar.Visible = cfg.showStatusBar and cfg.unlocked
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

    local vl = Instance.new("TextLabel", mb)
    vl.Size = UDim2.new(0.48,-10,1,0)
    vl.Position = UDim2.new(0.5,0,0,0)
    vl.BackgroundTransparency = 1
    vl.Text = tostring(cfg[currentKey] or list[1])
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

    for i, v in ipairs(list) do
        local opt = Instance.new("TextButton", lf)
        opt.Size = UDim2.new(1,-4,0,26)
        opt.BackgroundColor3 = C_Card
        opt.Text = tostring(v)
        opt.TextColor3 = C_Text
        opt.Font = Enum.Font.GothamSemibold
        opt.TextSize = 10
        Instance.new("UICorner", opt).CornerRadius = UDim.new(0,4)
        safeClick(opt, function()
            vl.Text = tostring(v)
            cfg[currentKey] = isStrDrop and tostring(v) or i
            lf.Visible = false
            lf.Size = UDim2.new(1,0,0,0)
            if callback then callback(v, i) end
        end)
    end

    safeClick(mb, function()
        lf.Visible = not lf.Visible
        lf.Size = lf.Visible and UDim2.new(1,0,0,120) or UDim2.new(1,0,0,0)
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

-- ============================================================
--  CRIAÇÃO DAS ABAS - EXPANDIDO (7 ABAS)
-- ============================================================
local pageHalloween = createCh("Halloween Event", 1)
local pageHalloween2 = createCh("Halloween Extras", 2)
local pageFarming = createCh("Farming", 3)
local pageSettings = createCh("Settings & FastAttack", 4)
local pageLocal = createCh("LocalPlayer & Teleport", 5)
local pageShop = createCh("Shop & Items", 6)
local pageESP = createCh("ESP & Visuals", 7) -- NOVA ABA

-- ABA 1: HALLOWEEN 2026 - EVENTO PRINCIPAL
addSection(pageHalloween, "Halloween Event 2026")
addT(pageHalloween, "Auto Halloween Event (Completo)", "autoHalloweenEvent")
addT(pageHalloween, "Farm Pumpkins (Fast)", "farmPumpkins")
addT(pageHalloween, "Prioritize Boss Great Pumpkin", "prioritizeBossGreatPumpkin")
addT(pageHalloween, "Skip Jack o' Lantern (Farm Cepat)", "skipJackOfLantern")
addT(pageHalloween, "Auto Trick or Treat (Fast)", "autoTrickOrTreat")
addT(pageHalloween, "Auto Great Pumpkin [Farm + Boss]", "autoGreatPumpkinBoss")
addT(pageHalloween, "Summon Great Pumpkin (Beta)", "summonGreatPumpkin")

addSection(pageHalloween, "Spooky Gacha & Rolls")
addT(pageHalloween, "Auto Gacha Halloween", "autoGachaHalloween")
addT(pageHalloween, "Auto Roll Spooky Gacha", "autoRollSpookyGacha")
addT(pageHalloween, "Auto Close Gacha UI", "autoCloseGachaUI")
addT(pageHalloween, "Spooky Gacha: Allow Silver Key", "spookyGachaAllowSilverKey")
addActionBtn(pageHalloween, "Open Spooky Gacha (Vendor)", function()
    local commF = getCommF()
    if commF then safeInvoke(commF, "HalloweenGacha", "Open") end
end)

addSection(pageHalloween, "Pumpkin Breaking & Secrets")
addT(pageHalloween, "Auto Candy Grave / Pumpkin Hunt", "autoCandyGravePumpkinHunt")
addT(pageHalloween, "Auto Break Grave [Unlock Egg]", "autoBreakGraveUnlockEgg")
addT(pageHalloween, "Sweet Riddle Solver (Pumpkin Key)", "sweetRiddleSolver")
addT(pageHalloween, "Mystery Hall Solver", "mysteryHallSolver")
addT(pageHalloween, "Witch Cauldron Auto", "witchCauldronAuto")
addT(pageHalloween, "Travel via Halloween Portal", "travelViaHalloweenPortal")

addSection(pageHalloween, "Magnet Event Update 30")
addT(pageHalloween, "Auto Farm Magnet Token", "autoFarmMagnetToken")
addT(pageHalloween, "Auto Roll Magnet Gacha", "autoRollMagnetGacha")

-- ABA 2: HALLOWEEN EXTRAS - NOVOS RECURSOS
addSection(pageHalloween2, "Candy & Soul Guitar")
addT(pageHalloween2, "Auto Collect Candy", "autoCollectCandy")
addT(pageHalloween2, "Auto Exchange Candy", "autoExchangeCandy")
addT(pageHalloween2, "Farm Candy Corn", "farmCandyCorn")
addT(pageHalloween2, "Auto Halloween Race Trials", "autoHalloweenRace")
addT(pageHalloween2, "Auto Soul Guitar Puzzle", "autoSoulGuitar")

addSection(pageHalloween2, "Bosses Especiais")
addActionBtn(pageHalloween2, "Teleport to Great Pumpkin", function()
    pcall(function()
        local boss = workspace.Enemies:FindFirstChild("Great Pumpkin")
        if boss and boss:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.CFrame = boss.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0)
        end
    end)
end)
addActionBtn(pageHalloween2, "Teleport to Jack o' Lantern", function()
    pcall(function()
        for _, mob in ipairs(workspace.Enemies:GetChildren()) do
            if string.find(string.lower(mob.Name), "jack") and mob:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0)
                break
            end
        end
    end)
end)

addSection(pageHalloween2, "Halloween Islands")
addActionBtn(pageHalloween2, "Teleport to Haunted Castle", function()
    pcall(function() p.Character.HumanoidRootPart.CFrame = CFrame.new(-9515, 142, 6078) end)
end)
addActionBtn(pageHalloween2, "Teleport to Candy Land", function()
    pcall(function() p.Character.HumanoidRootPart.CFrame = CFrame.new(-2020, 38, -12026) end)
end)
addActionBtn(pageHalloween2, "Teleport to Mystery Hall", function()
    pcall(function() p.Character.HumanoidRootPart.CFrame = CFrame.new(-5495, 48, -794) end)
end)

-- ABA 3: FARMING
addSection(pageFarming, "Auto Farm Level (Fix Auto Quest + Sea Detection)")
addDropdown(pageFarming, "Select Weapon:", {"Melee", "Sword", "Gun", "Fruit"}, "selectedWeapon", function(v) cfg.selectedWeapon = v end, true)
addT(pageFarming, "Start Farm (Auto Quest + Mob)", "startFarm", function(on)
    setStatus(on and "Farm Level Ativado" or "Idle")
end)
addT(pageFarming, "Accept Quests Automático", "autoQuest")
addT(pageFarming, "Auto Equip Weapon", "autoEquipWeapon")
addT(pageFarming, "Bring Mobs (Agrupar Inimigos)", "bringMobs")
addT(pageFarming, "Auto Turn On Buso (Haki)", "autoTurnOnBuso")
addT(pageFarming, "Auto Ken (Observation)", "autoKen")

addSection(pageFarming, "Mastery Farm")
addDropdown(pageFarming, "Mastery Method:", {"Melee", "Sword", "Gun", "Fruit"}, "masteryMethod", function(v) cfg.masteryMethod = v end, true)
addT(pageFarming, "Farm Mastery", "farmMastery")

addSection(pageFarming, "Sea Selection")
addDropdown(pageFarming, "Selected Sea:", {"Sea 1", "Sea 2", "Sea 3"}, "selectedSea", function(v)
    cfg.selectedSea = v
    setStatus("Sea alterado para: " .. v) -- FIX: .. em vez de +
end, true)

-- ABA 4: FAST ATTACK / AUTO CLICK
addSection(pageSettings, "Fast Attack & Click (Delta Safe)")
addT(pageSettings, "Enable Fast Attack", "fastAttack")
addT(pageSettings, "Auto Click (Continuous)", "autoClick")
addT(pageSettings, "Attack No Animation", "attackNoAnim")
addDropdown(pageSettings, "Fast Attack Delay:", {"0.03", "0.05", "0.08", "0.1", "0.15"}, "fastAttackDelay", function(v)
    cfg.fastAttackDelay = tonumber(v) or 0.03
end, true)

addSection(pageSettings, "Render & Otimização")
addT(pageSettings, "White Screen / Fast Mode", "fastMode", function(on)
    pcall(function()
        local pGuiSafe = p:FindFirstChildOfClass("PlayerGui")
        if pGuiSafe then
            for _, v in ipairs(pGuiSafe:GetChildren()) do
                if v:IsA("ScreenGui") and v ~= gui then v.Enabled = not on end
            end
        end
    end)
end)
addT(pageSettings, "Disable 3D Rendering", "noRender", function(on)
    pcall(function()
        if typeof(runS.Set3dRenderingEnabled) == "function" then
            runS:Set3dRenderingEnabled(not on)
        end
    end)
end)
addActionBtn(pageSettings, "Server Hop", function()
    setStatus("Buscando servidor...")
    task.spawn(function()
        local ok, info = hopServer()
        setStatus(ok and ("Hopping -> " .. tostring(info)) or ("Falha: " .. tostring(info)))
    end)
end)

addSection(pageSettings, "Anti-Ban & Reload")
addT(pageSettings, "Show Status Bar", "showStatusBar", function(on)
    statusBar.Visible = on and cfg.unlocked
end)
addActionBtn(pageSettings, "Force Reload Script", function()
    getgenv().StringtrapHub_AutoReload = true
    pcall(function() tsService:Teleport(game.PlaceId, p) end)
end)

-- ABA 5: LOCALPLAYER & TELEPORT
addSection(pageLocal, "Movement & Player")
addT(pageLocal, "Noclip", "noclip")
addDropdown(pageLocal, "Select Team:", {"Pirates", "Marines"}, "selectedTeam", function(v)
    cfg.selectedTeam = v
    local commF = getCommF()
    if commF then safeInvoke(commF, "SetTeam", v) end
end, true)

addSection(pageLocal, "Island Teleports (Sea 1)")
addActionBtn(pageLocal, "Starter Island", function() pcall(function() p.Character.HumanoidRootPart.CFrame = CFrame.new(1059, 16, 1549) end) end)
addActionBtn(pageLocal, "Jungle", function() pcall(function() p.Character.HumanoidRootPart.CFrame = CFrame.new(-1598, 36, 153) end) end)
addActionBtn(pageLocal, "Desert", function() pcall(function() p.Character.HumanoidRootPart.CFrame = CFrame.new(897, 6, 4389) end) end)
addActionBtn(pageLocal, "Snow Mountain", function() pcall(function() p.Character.HumanoidRootPart.CFrame = CFrame.new(607, 401, -5370) end) end)
addActionBtn(pageLocal, "Marine Fortress", function() pcall(function() p.Character.HumanoidRootPart.CFrame = CFrame.new(-5039, 28, 4324) end) end)
addActionBtn(pageLocal, "Sky Island", function() pcall(function() p.Character.HumanoidRootPart.CFrame = CFrame.new(-4842, 717, -2623) end) end)
addActionBtn(pageLocal, "Prison", function() pcall(function() p.Character.HumanoidRootPart.CFrame = CFrame.new(5308, 2, 474) end) end)
addActionBtn(pageLocal, "Colosseum", function() pcall(function() p.Character.HumanoidRootPart.CFrame = CFrame.new(-1580, 7, -2986) end) end)
addActionBtn(pageLocal, "Magma Village", function() pcall(function() p.Character.HumanoidRootPart.CFrame = CFrame.new(-5314, 12, 8516) end) end)
addActionBtn(pageLocal, "Fishman Island", function() pcall(function() p.Character.HumanoidRootPart.CFrame = CFrame.new(61122, 18, 1569) end) end)

addSection(pageLocal, "Island Teleports (Sea 2)")
addActionBtn(pageLocal, "Kingdom of Rose", function() pcall(function() p.Character.HumanoidRootPart.CFrame = CFrame.new(-290, 43, 5430) end) end)
addActionBtn(pageLocal, "Green Zone", function() pcall(function() p.Character.HumanoidRootPart.CFrame = CFrame.new(-13275, 332, -7768) end) end)
addActionBtn(pageLocal, "Graveyard", function() pcall(function() p.Character.HumanoidRootPart.CFrame = CFrame.new(-5495, 48, -794) end) end)
addActionBtn(pageLocal, "Hot & Cold", function() pcall(function() p.Character.HumanoidRootPart.CFrame = CFrame.new(-6060, 15, -4902) end) end)

addSection(pageLocal, "Island Teleports (Sea 3)")
addActionBtn(pageLocal, "Haunted Castle", function() pcall(function() p.Character.HumanoidRootPart.CFrame = CFrame.new(-9515, 142, 6078) end) end)
addActionBtn(pageLocal, "Candy Land / Tiki Outpost", function() pcall(function() p.Character.HumanoidRootPart.CFrame = CFrame.new(-16547, 55, -173) end) end)
addActionBtn(pageLocal, "Great Tree", function() pcall(function() p.Character.HumanoidRootPart.CFrame = CFrame.new(2192, 28, -6732) end) end)

-- ABA 6: SHOP
addSection(pageShop, "Abilities")
addActionBtn(pageShop, "Skyjump [10,000 Beli]", function() local c=getCommF() if c then safeInvoke(c, "BuyHaki", "Geppo") end end)
addActionBtn(pageShop, "Buso Haki [25,000 Beli]", function() local c=getCommF() if c then safeInvoke(c, "BuyHaki", "Buso") end end)
addActionBtn(pageShop, "Observation [750,000 Beli]", function() local c=getCommF() if c then safeInvoke(c, "BuyHaki", "Observation") end end)
addActionBtn(pageShop, "Soru [100,000 Beli]", function() local c=getCommF() if c then safeInvoke(c, "BuyHaki", "Soru") end end)

addSection(pageShop, "Fighting Styles")
addActionBtn(pageShop, "Buy Black Leg", function() local c=getCommF() if c then safeInvoke(c, "BuyBlackLeg") end end)
addActionBtn(pageShop, "Buy Electro", function() local c=getCommF() if c then safeInvoke(c, "BuyElectro") end end)
addActionBtn(pageShop, "Buy Fishman Karate", function() local c=getCommF() if c then safeInvoke(c, "BuyFishmanKarate") end end)
addActionBtn(pageShop, "Buy Dragon Claw", function() local c=getCommF() if c then safeInvoke(c, "BuyDragonClaw") end end)
addActionBtn(pageShop, "Buy Superhuman", function() local c=getCommF() if c then safeInvoke(c, "BuySuperhuman") end end)
addActionBtn(pageShop, "Buy Death Step", function() local c=getCommF() if c then safeInvoke(c, "BuyDeathStep") end end)
addActionBtn(pageShop, "Buy Sharkman Karate", function() local c=getCommF() if c then safeInvoke(c, "BuySharkmanKarate") end end)
addActionBtn(pageShop, "Buy Electric Claw", function() local c=getCommF() if c then safeInvoke(c, "BuyElectricClaw") end end)
addActionBtn(pageShop, "Buy Dragon Talon", function() local c=getCommF() if c then safeInvoke(c, "BuyDragonTalon") end end)
addActionBtn(pageShop, "Buy Godhuman", function() local c=getCommF() if c then safeInvoke(c, "BuyGodhuman") end end)
addActionBtn(pageShop, "Buy Sanguine Art", function() local c=getCommF() if c then safeInvoke(c, "BuySanguineArt") end end)

addSection(pageShop, "Weapons & Items")
addActionBtn(pageShop, "Buy Kabucha", function() local c=getCommF() if c then safeInvoke(c, "BuyKabucha") end end)
addActionBtn(pageShop, "Buy Pole v2", function() local c=getCommF() if c then safeInvoke(c, "BuyPoleV2") end end)

-- ABA 7: ESP & VISUALS (NOVA)
addSection(pageESP, "ESP Frutas (Otimizado)")
addT(pageESP, "Enable Fruit ESP", "espFruit", function(on)
    if not on then
        for tool, _ in pairs(fruitCache.billboards) do
            removeFruitESP(tool)
        end
    end
end)
addT(pageESP, "Show Fruit Names", "espFruitNames", function() end) -- placeholder para futuro
addActionBtn(pageESP, "Force Rescan Fruits", function()
    fruitCache.lastScan = 0
    scanFruits()
    setStatus("Fruit scan forçado")
end)

addSection(pageESP, "Outros ESP (Futuro)")
addActionBtn(pageESP, "ESP Mobs (WIP)", function() setStatus("Em desenvolvimento") end)
addActionBtn(pageESP, "ESP Chests (WIP)", function() setStatus("Em desenvolvimento") end)

-- ============================================================
--  LOOP 1: FAST ATTACK / AUTO CLICK OTIMIZADO
-- ============================================================
task.spawn(function()
    while true do
        task.wait(cfg.fastAttackDelay or 0.03)
        if (cfg.autoClick or cfg.startFarm or cfg.farmPumpkins or cfg.autoGreatPumpkinBoss or cfg.autoHalloweenEvent or cfg.farmMastery) and cfg.fastAttack then
            pcall(doFastAttack)
        end
    end
end)

-- ============================================================
--  LOOP 2: AUTO QUEST & LEVEL FARM (CORRIGIDO + QUEST CHECK)
-- ============================================================
task.spawn(function()
    while true do
        task.wait(0.5)
        if cfg.startFarm and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local myHrp = p.Character.HumanoidRootPart
            local myHum = p.Character:FindFirstChildOfClass("Humanoid")
            if myHum and myHum.Health > 0 then
                local quest = getCurrentQuest()
                if not quest then
                    setStatus("Nenhuma quest encontrada para level/sea atual")
                    task.wait(2)
                else
                    local activeQuest = getActiveQuestName()
                    local questMatches = activeQuest and string.find(string.lower(activeQuest), string.lower(quest.mob))

                    if cfg.autoQuest and (not hasActiveQuest() or not questMatches) then
                        setStatus("Pegando Quest: " .. tostring(quest.quest))
                        local distNpc = (myHrp.Position - quest.npcPos.Position).Magnitude
                        if distNpc > 15 then
                            myHrp.CFrame = quest.npcPos + Vector3.new(0, 5, 0)
                            task.wait(0.3)
                        end
                        local commF = getCommF()
                        if commF then safeInvoke(commF, "StartQuest", quest.quest, quest.questNum) end
                        task.wait(0.5)
                    else
                        local targetMob = nil
                        local enemiesFolder = workspace:FindFirstChild("Enemies")
                        if enemiesFolder then
                            for _, mob in ipairs(enemiesFolder:GetChildren()) do
                                if mob.Name == quest.mob and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChildOfClass("Humanoid") and mob:FindFirstChildOfClass("Humanoid").Health > 0 then
                                    targetMob = mob
                                    break
                                end
                            end
                        end

                        if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                            local mobHrp = targetMob.HumanoidRootPart
                            myHrp.CFrame = mobHrp.CFrame * CFrame.new(0, 18, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                            setStatus("Matando: " .. tostring(quest.mob))

                            if cfg.fastAttack then
                                pcall(doFastAttack)
                            end

                            if cfg.bringMobs and enemiesFolder then
                                pcall(function()
                                    for _, otherMob in ipairs(enemiesFolder:GetChildren()) do
                                        if otherMob ~= targetMob and otherMob.Name == targetMob.Name and otherMob:FindFirstChild("HumanoidRootPart") and otherMob:FindFirstChildOfClass("Humanoid") and otherMob:FindFirstChildOfClass("Humanoid").Health > 0 then
                                            if (otherMob.HumanoidRootPart.Position - mobHrp.Position).Magnitude <= 200 then
                                                otherMob.HumanoidRootPart.CFrame = mobHrp.CFrame
                                                otherMob.HumanoidRootPart.CanCollide = false
                                            end
                                        end
                                    end
                                end)
                            end
                        else
                            setStatus("Indo ao spawn de: " .. tostring(quest.mob))
                            myHrp.CFrame = quest.mobPos + Vector3.new(0, 25, 0)
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================
--  LOOP 3: AUTO HALLOWEEN 2026 COMPLETO (OTIMIZADO COM CACHE)
-- ============================================================
local candyCollectIndex = 1
local candyCornIndex = 1

task.spawn(function()
    while true do
        task.wait(0.6)
        if not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then continue end
        local myHrp = p.Character.HumanoidRootPart
        local myHum = p.Character:FindFirstChildOfClass("Humanoid")
        if not myHum or myHum.Health <= 0 then continue end

        scanHalloweenObjects()

        -- Auto Halloween Event (completo)
        if cfg.autoHalloweenEvent then
            if #halloweenCache.pumpkins > 0 then
                local targets = halloweenCache.pumpkins
                if cfg.prioritizeBossGreatPumpkin then
                    table.sort(targets, function(a, b) return (a.isBoss and 1 or 0) > (b.isBoss and 1 or 0) end)
                end
                if cfg.skipJackOfLantern then
                    local filtered = {}
                    for _, t in ipairs(targets) do
                        if not string.find(string.lower(t.model.Name), "jack") then
                            table.insert(filtered, t)
                        end
                    end
                    targets = filtered
                end

                if #targets > 0 then
                    local target = targets[1]
                    setStatus("Quebrando: " .. target.model.Name)
                    myHrp.CFrame = target.part.CFrame * CFrame.new(0, 8, 0)
                    local commF = getCommF()
                    if commF then safeInvoke(commF, "HalloweenEvent", "HitPumpkin", target.model) end -- FIX: passa model, não Name
                    if cfg.fastAttack then pcall(doFastAttack) end
                end
            end
        end

        -- Farm Pumpkins standalone
        if cfg.farmPumpkins and not cfg.autoHalloweenEvent then
            if #halloweenCache.pumpkins > 0 then
                local target = halloweenCache.pumpkins[1]
                setStatus("Farm Pumpkin: " .. target.model.Name)
                myHrp.CFrame = target.part.CFrame * CFrame.new(0, 8, 0)
                local commF = getCommF()
                if commF then safeInvoke(commF, "HalloweenEvent", "HitPumpkin", target.model) end
                if cfg.fastAttack then pcall(doFastAttack) end
            end
        end

        -- Auto Great Pumpkin Boss
        if cfg.autoGreatPumpkinBoss then
            local bossFound = false
            for _, t in ipairs(halloweenCache.pumpkins) do
                if t.isBoss then
                    bossFound = true
                    setStatus("Boss Great Pumpkin!")
                    myHrp.CFrame = t.part.CFrame * CFrame.new(0, 20, 0)
                    if cfg.fastAttack then pcall(doFastAttack) end
                    break
                end
            end
            if not bossFound and cfg.summonGreatPumpkin then
                local commF = getCommF()
                if commF then safeInvoke(commF, "HalloweenEvent", "SummonGreatPumpkin") end
            end
        end

        -- Summon Great Pumpkin
        if cfg.summonGreatPumpkin and not cfg.autoGreatPumpkinBoss then
            local commF = getCommF()
            if commF then safeInvoke(commF, "HalloweenEvent", "SummonGreatPumpkin") end
        end

        -- Spooky Gacha
        if cfg.autoRollSpookyGacha or cfg.autoGachaHalloween then
            local commF = getCommF()
            if commF then safeInvoke(commF, "HalloweenGacha", "Roll", cfg.spookyGachaAllowSilverKey) end
            if cfg.autoCloseGachaUI then
                pcall(function()
                    local pGuiSafe = p:FindFirstChildOfClass("PlayerGui")
                    if pGuiSafe then
                        local gUi = pGuiSafe:FindFirstChild("SpookyGacha") or pGuiSafe:FindFirstChild("HalloweenUI")
                        if gUi then gUi.Enabled = false end
                    end
                end)
            end
        end

        -- Trick or Treat
        if cfg.autoTrickOrTreat then
            local commF = getCommF()
            if commF then safeInvoke(commF, "HalloweenEvent", "TrickOrTreat") end
        end

        -- Candy Grave / Pumpkin Hunt
        if cfg.autoCandyGravePumpkinHunt then
            if #halloweenCache.graves > 0 then
                local target = halloweenCache.graves[1]
                setStatus("Quebrando Grave: " .. target.model.Name)
                myHrp.CFrame = target.part.CFrame * CFrame.new(0, 5, 0)
                local commF = getCommF()
                if commF then safeInvoke(commF, "HalloweenEvent", "BreakGrave", target.model) end
                if cfg.fastAttack then pcall(doFastAttack) end
            end
        end

        -- Break Grave Unlock Egg
        if cfg.autoBreakGraveUnlockEgg then
            local commF = getCommF()
            if commF then safeInvoke(commF, "HalloweenEvent", "BreakGraveUnlockEgg") end
        end

        -- Sweet Riddle Solver
        if cfg.sweetRiddleSolver then
            local commF = getCommF()
            if commF then safeInvoke(commF, "HalloweenEvent", "SweetRiddleSolver") end
        end

        -- Mystery Hall Solver
        if cfg.mysteryHallSolver then
            local commF = getCommF()
            if commF then safeInvoke(commF, "HalloweenEvent", "MysteryHallSolver") end
        end

        -- Witch Cauldron Auto
        if cfg.witchCauldronAuto then
            local commF = getCommF()
            if commF then safeInvoke(commF, "HalloweenEvent", "WitchCauldron", "Auto") end
        end

        -- Travel via Halloween Portal
        if cfg.travelViaHalloweenPortal then
            local commF = getCommF()
            if commF then safeInvoke(commF, "HalloweenEvent", "TravelPortal") end
        end

        -- Magnet Token Farm (usa cache)
        if cfg.autoFarmMagnetToken then
            if #halloweenCache.magnetTokens > 0 then
                local target = halloweenCache.magnetTokens[1]
                myHrp.CFrame = target.part.CFrame * CFrame.new(0, 5, 0)
            end
        end

        -- Magnet Gacha
        if cfg.autoRollMagnetGacha then
            local commF = getCommF()
            if commF then safeInvoke(commF, "MagnetGacha", "Roll") end
        end

        -- Auto Collect Candy (FIX: um por ciclo, não todos de uma vez)
        if cfg.autoCollectCandy then
            if #halloweenCache.candy > 0 then
                if candyCollectIndex > #halloweenCache.candy then candyCollectIndex = 1 end
                local c = halloweenCache.candy[candyCollectIndex]
                myHrp.CFrame = c.part.CFrame * CFrame.new(0, 3, 0)
                candyCollectIndex = candyCollectIndex + 1
                task.wait(0.1) -- pequeno delay anti-cheat
            end
        end

        -- Auto Exchange Candy
        if cfg.autoExchangeCandy then
            local commF = getCommF()
            if commF then safeInvoke(commF, "HalloweenEvent", "ExchangeCandy") end
        end

        -- Farm Candy Corn (FIX: usa cache, um por ciclo)
        if cfg.farmCandyCorn then
            if #halloweenCache.candy > 0 then
                if candyCornIndex > #halloweenCache.candy then candyCornIndex = 1 end
                local c = halloweenCache.candy[candyCornIndex]
                myHrp.CFrame = c.part.CFrame * CFrame.new(0, 3, 0)
                candyCornIndex = candyCornIndex + 1
                task.wait(0.15)
            end
        end

        -- Halloween Race
        if cfg.autoHalloweenRace then
            local commF = getCommF()
            if commF then safeInvoke(commF, "HalloweenRace", "Start") end
        end

        -- Soul Guitar Puzzle
        if cfg.autoSoulGuitar then
            local commF = getCommF()
            if commF then safeInvoke(commF, "SoulGuitarPuzzle", "Auto") end
        end
    end
end)

-- ============================================================
--  LOOP 4: ESP FRUTAS (OTIMIZADO)
-- ============================================================
task.spawn(function()
    while true do
        task.wait(1)
        if cfg.espFruit then
            scanFruits()
            for _, f in ipairs(fruitCache.fruits) do
                createFruitESP(f.tool, f.part, f.name)
            end
        else
            for tool, _ in pairs(fruitCache.billboards) do
                removeFruitESP(tool)
            end
        end
    end
end)

-- ============================================================
--  LOOP 5: NOCLIP & UTILITÁRIOS (OTIMIZADO)
-- ============================================================
local noclipConnection = nil
local function updateNoclip()
    if cfg.noclip then
        if not noclipConnection then
            noclipConnection = runS.Stepped:Connect(function()
                if p.Character then
                    for _, part in ipairs(p.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
            if p.Character then
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
end

task.spawn(function()
    local lastNoclip = cfg.noclip
    while true do
        task.wait(1)
        if cfg.noclip ~= lastNoclip then
            lastNoclip = cfg.noclip
            updateNoclip()
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(3)
        if cfg.autoTurnOnBuso and p.Character then
            local hasBuso = p.Character:GetAttribute("HasBuso") or p.Character:FindFirstChild("HasBuso")
            if not hasBuso then
                local commF = getCommF()
                if commF then safeInvoke(commF, "Buso") end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(5)
        if cfg.autoKen and p.Character then
            local hasKen = p.Character:GetAttribute("HasKen")
            if not hasKen then
                local commF = getCommF()
                if commF then safeInvoke(commF, "Ken") end
            end
        end
    end
end)

-- Character respawn handler
p.CharacterAdded:Connect(function(char)
    task.wait(1)
    if cfg.noclip then updateNoclip() end
    if cfg.autoTurnOnBuso then
        task.wait(2)
        local commF = getCommF()
        if commF then safeInvoke(commF, "Buso") end
    end
end)

-- ============================================================
--  LOOP 6: ANTI-BAN SERVER HOP (CORRIGIDO + SEA UPDATE)
-- ============================================================
task.spawn(function()
    task.wait(15)
    local nextHop = math.random(ANTIBAN_MIN * 60, ANTIBAN_MAX * 60)
    local startedAt = tick()
    while true do
        task.wait(1)
        local elapsed = tick() - startedAt
        local remaining = math.max(0, math.floor(nextHop - elapsed))
        if cfg.showStatusBar and remaining % 30 == 0 and remaining > 0 then
            setStatus(string.format("Anti-Ban: Hop em %02d:%02d", math.floor(remaining / 60), remaining % 60))
        end
        if elapsed >= nextHop then
            setStatus("Anti-Ban: Trocando de servidor...")
            if ANTIBAN_URL and ANTIBAN_URL ~= "" then
                -- FIX: Atualiza selectedSea no source do queueTeleport
                local src = string.format([=[
getgenv().StringtrapHub_AutoReload = true
getgenv().StringtrapHub_PreSea = "%s"
local success, result = pcall(function() return loadstring(game:HttpGet("%s"))() end)
if not success then warn("Reload error:", result) end
                ]=], detectCurrentSea(), ANTIBAN_URL:gsub("%%", "%%%%"))
                local qOk, qErr = queueTeleport(src)
                if not qOk then
                    task.wait(30)
                    nextHop = math.random(ANTIBAN_MIN * 60, ANTIBAN_MAX * 60)
                    startedAt = tick()
                end
            end
            local ok, info = hopServer()
            if not ok then task.wait(30) end
            nextHop = math.random(ANTIBAN_MIN * 60, ANTIBAN_MAX * 60)
            startedAt = tick()
        end
    end
end)

-- Aplicar sea salvo no reload
if getgenv().StringtrapHub_PreSea then
    cfg.selectedSea = getgenv().StringtrapHub_PreSea
    getgenv().StringtrapHub_PreSea = nil
end

-- Inicialização do noclip se já estiver ativo
if cfg.noclip then updateNoclip() end

print("[Stringtrap Hub] Carregado com sucesso! Halloween 2026 + Bugfixes + ESP Frutas + Otimizações ativas.")