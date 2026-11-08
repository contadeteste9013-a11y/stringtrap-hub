--=====================================================================
-- STRINGTRAP HUB - DELTA ULTRA-LIGHT (UPDATE 30 HALLOWEEN)
-- Arquivo: stringtrap45.lua | Nivel Maximo: 2870+
--=====================================================================
local ANTIBAN_URL = "https://raw.githubusercontent.com/contadeteste9013-a11y/stringtrap-hub/refs/heads/main/stringtrapupd_fixed.lua"
local ANTIBAN_MIN = 30
local ANTIBAN_MAX = 40

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local uis      = game:GetService("UserInputService")
local vim      = game:GetService("VirtualInputManager")
local rs       = game:GetService("ReplicatedStorage")
local vu       = game:GetService("VirtualUser")
local runS     = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local p = Players.LocalPlayer
local getgenv = getgenv or function() return _G end

-- Proteção de GUI para Delta / Mobile
local function getSafeGuiParent()
    local ok, core = pcall(function()
        if typeof(gethui) == "function" then return gethui() end
        return game:GetService("CoreGui")
    end)
    if ok and core then return core end
    return p:WaitForChild("PlayerGui", 10) or p:FindFirstChildOfClass("PlayerGui")
end

local guiContainer = getSafeGuiParent()
if guiContainer and guiContainer:FindFirstChild("StringtrapHub") then
    pcall(function() guiContainer.StringtrapHub:Destroy() end)  -- FIX #1
end

-- Limpeza de conexões antigas
if getgenv().StringtrapConnections then
    for _, conn in ipairs(getgenv().StringtrapConnections) do
        pcall(function() conn:Disconnect() end)
    end
end
getgenv().StringtrapConnections = {}

local cfg = {
    unlocked = false,
    showStatusBar = true,
    selectedWeapon = "Melee",
    fastAttack = true,
    fastAttackDelay = 0.035,
    fastRange = 60,
    maxTargets = 10,
    autoClick = false,
    autoClickDelay = 0.08,
    autoTurnOnBuso = true,
    startFarm = false,
    autoQuest = true,
    bringMobs = true,
    farmPumpkins = false,
    skipJackOLantern = false,
    autoGreatPumpkin = false,
    autoTrickOrTreat = false,
    autoSpookyGacha = false,
    noclip = false,
    noRender = false,
}

local KEY = "williamafton2026"
local IMG = "rbxassetid://77611955682353"
local autoReload = false

if getgenv().StringtrapHub_AutoReload == true then
    autoReload = true
    getgenv().StringtrapHub_AutoReload = nil
end

-- Cache de Remotes e CombatFramework
local Remotes    = rs:WaitForChild("Remotes", 10)
local CommF      = Remotes and Remotes:WaitForChild("CommF_", 5)
local Validator  = Remotes and Remotes:FindFirstChild("Validator")
local RegisterHit = rs:FindFirstChild("Hit", true) or (Remotes and Remotes:FindFirstChild("RegisterHit"))
local CachedCF   = nil

pcall(function()
    local cfModule = p:WaitForChild("PlayerScripts", 5) and p.PlayerScripts:FindFirstChild("CombatFramework")
    if cfModule then
        local loaded = require(cfModule)
        if loaded and loaded.Framework then CachedCF = loaded.Framework end
    end
end)

local function queueTeleport(source)
    local qot = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
    if qot then return pcall(qot, source) end
    return false
end

local function hopServer()
    local ok, res = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        ))
    end)

    if not ok or not res or not res.data then  -- FIX #9
        pcall(function() TeleportService:Teleport(game.PlaceId, p) end)
        return
    end

    local candidates = {}
    for _, s in ipairs(res.data) do
        if s.id ~= game.JobId and s.playing < s.maxPlayers then
            table.insert(candidates, s)
        end
    end

    if #candidates == 0 then
        pcall(function() TeleportService:Teleport(game.PlaceId, p) end)
        return
    end

    table.sort(candidates, function(a, b) return a.playing < b.playing end)
    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, candidates[1].id, p)
    end)
end

-- Teleporte leve (com SetNetworkOwner)
local function absoluteTP(hrp, targetCFrame)
    if not hrp then return end
    pcall(function() hrp:SetNetworkOwner(nil) end)
    hrp.CFrame = targetCFrame
    hrp.AssemblyLinearVelocity   = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
end

local function getEnemies() return workspace:FindFirstChild("Enemies") end

local function invokeCommF(...)
    if CommF then return pcall(function(...) return CommF:InvokeServer(...) end, ...) end
    return false
end --=====================================================================
-- QUESTS DATA (Niveis 1 -> 2800+)
--=====================================================================
local QuestsData = {
    {1, "BanditQuest1", CFrame.new(1059, 16, 1549), "Bandit", CFrame.new(1145, 17, 1630), 1},
    {10, "JungleQuest", CFrame.new(-1598, 36, 153), "Monkey", CFrame.new(-1442, 61, 38), 1},
    {15, "JungleQuest", CFrame.new(-1598, 36, 153), "Gorilla", CFrame.new(-1240, 6, -490), 2},
    {30, "BuggyQuest1", CFrame.new(-1140, 4, 3828), "Pirate", CFrame.new(-1219, 4, 3916), 1},
    {40, "BuggyQuest1", CFrame.new(-1140, 4, 3828), "Brute", CFrame.new(-1146, 77, 4476), 2},
    {60, "DesertQuest", CFrame.new(897, 6, 4389), "Desert Bandit", CFrame.new(932, 6, 4484), 1},
    {75, "DesertQuest", CFrame.new(897, 6, 4389), "Desert Officer", CFrame.new(1572, 10, 4373), 2},
    {90, "SnowQuest", CFrame.new(1385, 87, -1298), "Snow Bandit", CFrame.new(1287, 150, -1443), 1},
    {100, "SnowQuest", CFrame.new(1385, 87, -1298), "Snowman", CFrame.new(1198, 105, -1443), 2},
    {120, "MarineQuest2", CFrame.new(-5039, 28, 4324), "Chief Petty Officer", CFrame.new(-4855, 20, 4308), 1},
    {150, "SkyQuest", CFrame.new(-4842, 717, -2623), "Sky Bandit", CFrame.new(-4970, 717, -2622), 1},
    {175, "SkyQuest", CFrame.new(-4842, 717, -2623), "Dark Master", CFrame.new(-5230, 391, -2250), 2},
    {190, "PrisonerQuest", CFrame.new(5308, 2, 474), "Prisoner", CFrame.new(5411, 88, 514), 1},
    {210, "PrisonerQuest", CFrame.new(5308, 2, 474), "Dangerous Prisoner", CFrame.new(5540, 88, 710), 2},
    {250, "ColosseumQuest", CFrame.new(-1580, 7, -2986), "Toga Warrior", CFrame.new(-1850, 7, -2740), 1},
    {300, "MagmaQuest", CFrame.new(-5314, 12, 8516), "Military Soldier", CFrame.new(-5428, 15, 8454), 1},
    {325, "MagmaQuest", CFrame.new(-5314, 12, 8516), "Military Spy", CFrame.new(-5815, 77, 8820), 2},
    {375, "FishmanQuest", CFrame.new(61122, 18, 1569), "Fishman Warrior", CFrame.new(60880, 18, 1500), 1},
    {400, "FishmanQuest", CFrame.new(61122, 18, 1569), "Fishman Commando", CFrame.new(61800, 18, 1450), 2},
    {450, "SkyExpQuest", CFrame.new(-4721, 845, -1954), "God's Guard", CFrame.new(-4650, 845, -1900), 1},
    {525, "SkyExp2Quest", CFrame.new(-7903, 5635, -1412), "Royal Squad", CFrame.new(-7663, 5610, -1443), 1},
    {625, "FountainQuest", CFrame.new(5259, 38, 4050), "Galley Pirate", CFrame.new(5360, 38, 4120), 1},
    {650, "FountainQuest", CFrame.new(5259, 38, 4050), "Galley Captain", CFrame.new(5650, 38, 4950), 2},
    {700, "Area1Quest", CFrame.new(-427, 72, 1835), "Raider", CFrame.new(-220, 72, 1950), 1},
    {725, "Area1Quest", CFrame.new(-427, 72, 1835), "Mercenary", CFrame.new(-380, 72, 1500), 2},
    {775, "Area2Quest", CFrame.new(-775, 73, 865), "Swan Pirate", CFrame.new(-920, 73, 1020), 1},
    {800, "Area2Quest", CFrame.new(-775, 73, 865), "Factory Staff", CFrame.new(600, 80, 200), 2},
    {875, "MarineQuest3", CFrame.new(-2440, 73, -3218), "Marine Lieutenant", CFrame.new(-2280, 73, -3100), 1},
    {900, "MarineQuest3", CFrame.new(-2440, 73, -3218), "Marine Captain", CFrame.new(-2100, 73, -3300), 2},
    {950, "ZombieQuest", CFrame.new(-5495, 48, -794), "Zombie", CFrame.new(-5560, 48, -700), 1},
    {1000, "ZombieQuest", CFrame.new(-5495, 48, -794), "Vampire", CFrame.new(-6000, 6, -1300), 2},
    {1050, "SnowMountainQuest", CFrame.new(607, 401, -5370), "Snow Trooper", CFrame.new(520, 401, -5250), 1},
    {1100, "SnowMountainQuest", CFrame.new(607, 401, -5370), "Winter Warrior", CFrame.new(1150, 430, -5180), 2},
    {1150, "IceSideQuest", CFrame.new(-6060, 15, -4902), "Lab Subordinate", CFrame.new(-6200, 15, -4800), 1},
    {1175, "IceSideQuest", CFrame.new(-6060, 15, -4902), "Horned Warrior", CFrame.new(-6400, 15, -5800), 2},
    {1250, "ShipQuest1", CFrame.new(923, 125, 32852), "Ship Deckhand", CFrame.new(910, 125, 33000), 1},
    {1275, "ShipQuest1", CFrame.new(923, 125, 32852), "Ship Engineer", CFrame.new(850, 125, 33200), 2},
    {1350, "FrostQuest", CFrame.new(5505, 28, -6225), "Arctic Warrior", CFrame.new(5650, 28, -6300), 1},
    {1425, "ForgottenQuest", CFrame.new(-3054, 236, -10148), "Sea Soldier", CFrame.new(-3150, 236, -10000), 1},
    {1450, "ForgottenQuest", CFrame.new(-3054, 236, -10148), "Water Fighter", CFrame.new(-3400, 236, -10500), 2},
    {1500, "PiratePortQuest", CFrame.new(-290, 43, 5430), "Pirate Millionaire", CFrame.new(-450, 73, 5550), 1},
    {1525, "PiratePortQuest", CFrame.new(-290, 43, 5430), "Pistol Billionaire", CFrame.new(-200, 73, 5900), 2},
    {1575, "AmazonQuest", CFrame.new(5210, 604, 345), "Dragon Crew Warrior", CFrame.new(5100, 604, 480), 1},
    {1600, "AmazonQuest", CFrame.new(5210, 604, 345), "Dragon Crew Archer", CFrame.new(6200, 604, 200), 2},
    {1700, "MarineTreesland", CFrame.new(2192, 28, -6732), "Marine Commodore", CFrame.new(2350, 28, -6600), 1},
    {1725, "MarineTreesland", CFrame.new(2192, 28, -6732), "Marine Rear Admiral", CFrame.new(2600, 28, -7000), 2},
    {1775, "DeepForestIsland", CFrame.new(-13275, 332, -7768), "Forest Pirate", CFrame.new(-13400, 332, -7600), 1},
    {1800, "DeepForestIsland", CFrame.new(-13275, 332, -7768), "Mythological Pirate", CFrame.new(-13600, 332, -7000), 2},
    {1975, "HauntedQuest1", CFrame.new(-9515, 142, 6078), "Reborn Skeleton", CFrame.new(-9504, 172, 6050), 1},
    {2000, "HauntedQuest1", CFrame.new(-9515, 142, 6078), "Living Zombie", CFrame.new(-9700, 172, 6200), 2},
    {2075, "TreatQuest1", CFrame.new(-2020, 38, -12026), "Cookie Crafter", CFrame.new(-1900, 38, -11900), 1},
    {2100, "TreatQuest1", CFrame.new(-2020, 38, -12026), "Cake Guard", CFrame.new(-1600, 38, -12400), 2},
    {2200, "TreatQuest2", CFrame.new(-2020, 38, -12026), "Baking Staff", CFrame.new(-1800, 38, -12800), 1},
    {2225, "TreatQuest2", CFrame.new(-2020, 38, -12026), "Head Baker", CFrame.new(-2100, 38, -13000), 2},
    {2450, "TikiQuest1", CFrame.new(-16547, 55, -173), "Isle Outlaw", CFrame.new(-16400, 55, -100), 1},
    {2500, "TikiQuest1", CFrame.new(-16547, 55, -173), "Island Boy", CFrame.new(-16600, 55, -300), 2},
    {2550, "TikiQuest2", CFrame.new(-16547, 55, -173), "Sun-kissed Warrior", CFrame.new(-16100, 55, -400), 1},
    {2600, "TikiQuest2", CFrame.new(-16547, 55, -173), "Isle Champion", CFrame.new(-16200, 55, -800), 2},
    {2750, "HauntedQuest2", CFrame.new(-9515, 142, 6078), "Demonic Soul", CFrame.new(-9500, 172, 6100), 1},
    {2800, "HauntedQuest2", CFrame.new(-9515, 142, 6078), "Zombie Pirate", CFrame.new(-9300, 142, 6300), 2},
}

local function getPlayerLevel()
    local ok, lvl = pcall(function() return p.Data.Level.Value end)
    return (ok and lvl) or 1
end

local function getCurrentQuest()
    local myLvl = getPlayerLevel()
    local best = QuestsData[1]
    for _, q in ipairs(QuestsData) do  -- FIX #3
        if myLvl >= q[1] then best = q else break end
    end
    return best
end

local function hasActiveQuest()
    local active = false
    pcall(function()
        local pGuiSafe = p:FindFirstChild("PlayerGui")  -- FIX #2
        local main = pGuiSafe and pGuiSafe:FindFirstChild("Main")
        local qFrame = main and main:FindFirstChild("Quest")
        if qFrame then active = qFrame.Visible end
    end)
    return active
end

local function equipTool()
    local char = p.Character
    if not char then return nil end
    local targetTip = string.lower(cfg.selectedWeapon)
    for _, t in ipairs(char:GetChildren()) do  -- FIX #4a
        if t:IsA("Tool") and t:FindFirstChild("ToolTip") and string.find(string.lower(t.ToolTip), targetTip) then
            return t
        end
    end
    local bp = p:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do  -- FIX #4b
            if t:IsA("Tool") and t:FindFirstChild("ToolTip") and string.find(string.lower(t.ToolTip), targetTip) then
                t.Parent = char
                return t
            end
        end
    end
    return char:FindFirstChildOfClass("Tool")
end

-- Click nativo leve
local function triggerClick()
    local char = p.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool") or equipTool()
    if tool then pcall(function() tool:Activate() end) end
    pcall(function()
        if vu then
            vu:CaptureController()
            vu:ClickButton1(Vector2.zero)
        elseif vim and vim.SendMouseButtonEvent then
            vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end
    end)
end

-- Fast Attack otimizado
local function doFastAttack()
    local char = p.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local tool = equipTool()
    if not tool then return end

    if CachedCF then
        pcall(function()
            CachedCF.attackTime = 0
            if CachedCF.attacking == false then
                CachedCF:CreateHitbox()
            end
        end)
    end

    local hitTargets = {}
    local enemies = getEnemies()
    if enemies then
        for _, mob in ipairs(enemies:GetChildren()) do
            local mHrp = mob:FindFirstChild("HumanoidRootPart")
            local mHum = mob:FindFirstChildOfClass("Humanoid")
            if mHrp and mHum and mHum.Health > 0
               and (mHrp.Position - hrp.Position).Magnitude <= cfg.fastRange then
                table.insert(hitTargets, mHrp)
                if #hitTargets >= cfg.maxTargets then break end
            end
        end
    end

    if #hitTargets > 0 then
        pcall(function()
            if Validator then Validator:FireServer(math.floor(tick())) end  -- FIX #5
            if RegisterHit then RegisterHit:FireServer(hitTargets[1], hitTargets) end
            tool:Activate()
        end)
    end
end

-- FPS Boost / Limpeza de RAM
local function applyFPSBoost()
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                v.Enabled = false
            elseif v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
                v.CastShadow = false
            end
        end
        collectgarbage("collect")
    end)
end--=====================================================================
-- INTERFACE GRAFICA (UI)
--=====================================================================
local C_Bg     = Color3.fromRGB(18, 18, 24)  -- FIX #8
local C_Side   = Color3.fromRGB(24, 24, 32)
local C_Card   = Color3.fromRGB(30, 32, 44)
local C_Accent = Color3.fromRGB(255, 180, 0)
local C_Green  = Color3.fromRGB(80, 200, 80)
local C_Text   = Color3.fromRGB(240, 240, 245)
local C_Gray   = Color3.fromRGB(140, 145, 165)
local C_Off    = Color3.fromRGB(50, 52, 68)

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
    h.InputBegan:Connect(function(i)  -- FIX #10
        if i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseButton1 then
            d = true; ds = i.Position; sp = t.Position
        end
    end)
    table.insert(getgenv().StringtrapConnections, uis.InputChanged:Connect(function(i)
        if d and (i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = i.Position - ds
            t.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
        end
    end))
    table.insert(getgenv().StringtrapConnections, uis.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseButton1 then
            d = false
        end
    end))
end

local function setStatus(txt)
    pcall(function()
        if statusLbl then statusLbl.Text = "Status : " .. tostring(txt) end
    end)
end

local gui = Instance.new("ScreenGui")
gui.Name = "StringtrapHub"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = guiContainer end)

-- Status bar
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(0, 340, 0, 46)
statusBar.Position = UDim2.new(0.5, -170, 0, 8)
statusBar.BackgroundColor3 = C_Side
statusBar.ZIndex = 200
statusBar.Visible = false
statusBar.Parent = gui
Instance.new("UICorner", statusBar).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", statusBar).Color = C_Accent

local statusTitle = Instance.new("TextLabel", statusBar)
statusTitle.Size = UDim2.new(1, 0, 0, 18)
statusTitle.Position = UDim2.new(0, 0, 0, 2)
statusTitle.BackgroundTransparency = 1
statusTitle.Text = "Stringtrap Status (Update 30)"
statusTitle.TextColor3 = C_Accent
statusTitle.Font = Enum.Font.GothamBlack
statusTitle.TextSize = 11

statusLbl = Instance.new("TextLabel", statusBar)
statusLbl.Size = UDim2.new(1, -12, 0, 20)
statusLbl.Position = UDim2.new(0, 6, 0, 22)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "Status : Idle"
statusLbl.TextColor3 = C_Text
statusLbl.Font = Enum.Font.GothamSemibold
statusLbl.TextSize = 10

-- Keyframe
local kf = Instance.new("Frame", gui)
kf.Size = UDim2.new(0, 320, 0, 180)
kf.Position = UDim2.new(0.5, -160, 0.5, -90)
kf.BackgroundColor3 = C_Bg
kf.ZIndex = 9999
Instance.new("UICorner", kf).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", kf).Color = C_Accent

local kft = Instance.new("Frame", kf)
kft.Size = UDim2.new(1, 0, 0, 34)
kft.BackgroundColor3 = C_Side
kft.ZIndex = 10000
Instance.new("UICorner", kft).CornerRadius = UDim.new(0, 8)
drag(kft, kf)

local ktt = Instance.new("TextLabel", kft)
ktt.Size = UDim2.new(1, -20, 1, 0)
ktt.Position = UDim2.new(0, 10, 0, 0)
ktt.BackgroundTransparency = 1
ktt.Text = "Stringtrap Hub"
ktt.TextColor3 = C_Accent
ktt.Font = Enum.Font.GothamBlack
ktt.TextSize = 13
ktt.TextXAlignment = Enum.TextXAlignment.Left
ktt.ZIndex = 10001

local ki = Instance.new("TextBox", kf)
ki.Size = UDim2.new(0.86, 0, 0, 38)
ki.Position = UDim2.new(0.07, 0, 0.34, 0)
ki.BackgroundColor3 = C_Card
ki.TextColor3 = C_Text
ki.PlaceholderText = "Type the key..."
ki.Text = ""
ki.ClearTextOnFocus = false
ki.Font = Enum.Font.GothamSemibold
ki.TextSize = 12
ki.ZIndex = 10001
Instance.new("UICorner", ki).CornerRadius = UDim.new(0, 6)

local kb = Instance.new("TextButton", kf)
kb.Size = UDim2.new(0.86, 0, 0, 40)
kb.Position = UDim2.new(0.07, 0, 0.65, 0)
kb.BackgroundColor3 = C_Accent
kb.TextColor3 = Color3.fromRGB(15, 15, 20)
kb.Text = "LOAD HUB"
kb.Font = Enum.Font.GothamBlack
kb.TextSize = 13
kb.ZIndex = 10001
Instance.new("UICorner", kb).CornerRadius = UDim.new(0, 6)

-- Botão flutuante
local photo = Instance.new("ImageButton", gui)
photo.Size = UDim2.new(0, 54, 0, 54)
photo.Position = UDim2.new(0.02, 0, 0.5, -27)
photo.BackgroundColor3 = C_Bg
photo.Image = IMG
photo.Visible = false
Instance.new("UICorner", photo).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", photo).Color = C_Accent
drag(photo, photo)

-- Main frame
local mf = Instance.new("Frame", gui)
mf.Size = UDim2.new(0, 560, 0, 430)
mf.Position = UDim2.new(0.5, -280, 0.5, -215)
mf.BackgroundColor3 = C_Bg
mf.Visible = false
Instance.new("UICorner", mf).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", mf).Color = C_Accent

local top = Instance.new("Frame", mf)
top.Size = UDim2.new(1, 0, 0, 36)
top.BackgroundColor3 = C_Side
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 8)
drag(top, mf)

local ttl = Instance.new("TextLabel", top)
ttl.Size = UDim2.new(1, -50, 1, 0)
ttl.Position = UDim2.new(0, 10, 0, 0)
ttl.Text = "Stringtrap Hub (Update 30) (Delta Optimized)"
ttl.BackgroundTransparency = 1
ttl.TextColor3 = C_Accent
ttl.Font = Enum.Font.GothamBlack
ttl.TextSize = 13
ttl.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", top)
minBtn.Size = UDim2.new(0, 28, 0, 22)
minBtn.Position = UDim2.new(1, -36, 0.5, -11)
minBtn.BackgroundColor3 = C_Card
minBtn.Text = "-"
minBtn.TextColor3 = C_Text
minBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)
safeClick(minBtn, function() mf.Visible = false end)
safeClick(photo, function() mf.Visible = not mf.Visible end)

safeClick(kb, function()
    if ki.Text == KEY or autoReload then
        cfg.unlocked = true
        kf.Visible = false
        mf.Visible = true
        photo.Visible = true
        statusBar.Visible = cfg.showStatusBar
        setStatus(autoReload and "Auto-Reloaded" or "Idle")
    else
        kb.Text = "INVALID KEY"
        task.wait(1)
        kb.Text = "LOAD HUB"
    end
end)

if autoReload then
    cfg.unlocked = true
    kf.Visible = false
    mf.Visible = true
    photo.Visible = true
    statusBar.Visible = cfg.showStatusBar
    setStatus("Auto-Reloaded")
end

-- Sidebar
local side = Instance.new("Frame", mf)
side.Size = UDim2.new(0, 150, 1, -46)
side.Position = UDim2.new(0, 6, 0, 40)
side.BackgroundColor3 = C_Side
Instance.new("UICorner", side).CornerRadius = UDim.new(0, 6)

local sl = Instance.new("UIListLayout", side)
sl.Padding = UDim.new(0, 3)
sl.SortOrder = Enum.SortOrder.LayoutOrder
local sp = Instance.new("UIPadding", side)
sp.PaddingTop = UDim.new(0, 6)
sp.PaddingLeft = UDim.new(0, 6)
sp.PaddingRight = UDim.new(0, 6)

local cont = Instance.new("Frame", mf)
cont.Size = UDim2.new(1, -168, 1, -46)
cont.Position = UDim2.new(0, 162, 0, 40)
cont.BackgroundTransparency = 1

local ch = {}

local function createCh(n, o)
    local b = Instance.new("TextButton", side)
    b.LayoutOrder = o
    b.Size = UDim2.new(1, 0, 0, 30)
    b.BackgroundColor3 = (o == 1) and C_Card or C_Bg
    b.Text = n
    b.TextColor3 = (o == 1) and C_Accent or C_Gray
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)

    local page = Instance.new("ScrollingFrame", cont)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = C_Accent
    page.Visible = (o == 1)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollingDirection = Enum.ScrollingDirection.Y

    local l = Instance.new("UIListLayout", page)
    l.Padding = UDim.new(0, 5)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    local pad = Instance.new("UIPadding", page)
    pad.PaddingTop = UDim.new(0, 4); pad.PaddingBottom = UDim.new(0, 4)
    pad.PaddingLeft = UDim.new(0, 4); pad.PaddingRight = UDim.new(0, 4)

    table.insert(ch, { btn = b, page = page })

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
    f.Size = UDim2.new(1, 0, 0, 22)
    f.BackgroundColor3 = C_Side
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -10, 1, 0)
    l.Position = UDim2.new(0, 8, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = C_Accent
    l.Font = Enum.Font.GothamBlack
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
end

local function addT(parent, txt, key, onToggle)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, 0, 0, 34)
    b.BackgroundColor3 = C_Card
    b.Text = ""
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

    local I = Instance.new("TextLabel", b)
    I.Size = UDim2.new(1, -55, 1, 0)
    I.Position = UDim2.new(0, 10, 0, 0)
    I.BackgroundTransparency = 1
    I.Text = txt
    I.TextColor3 = cfg[key] and C_Text or C_Gray
    I.TextXAlignment = Enum.TextXAlignment.Left
    I.Font = Enum.Font.GothamSemibold
    I.TextSize = 10

    local pill = Instance.new("Frame", b)
    pill.Size = UDim2.new(0, 34, 0, 16)
    pill.Position = UDim2.new(1, -44, 0.5, -8)
    pill.BackgroundColor3 = cfg[key] and C_Green or C_Off
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", pill)
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = cfg[key] and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    safeClick(b, function()
        cfg[key] = not cfg[key]
        local on = cfg[key]
        I.TextColor3 = on and C_Text or C_Gray
        pill.BackgroundColor3 = on and C_Green or C_Off
        knob.Position = on and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
        if onToggle then onToggle(on) end
    end)
end

local function addActionBtn(parent, txt, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = C_Card
    b.Text = txt
    b.TextColor3 = C_Accent
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    safeClick(b, callback)
end

local function addDropdown(parent, title, list, currentKey, callback, isStrDrop)
    local mb = Instance.new("TextButton", parent)
    mb.Size = UDim2.new(1, 0, 0, 36)
    mb.BackgroundColor3 = C_Card
    mb.Text = ""
    mb.AutoButtonColor = false
    Instance.new("UICorner", mb).CornerRadius = UDim.new(0, 6)

    local tl = Instance.new("TextLabel", mb)
    tl.Size = UDim2.new(0.48, 0, 1, 0)
    tl.Position = UDim2.new(0, 10, 0, 0)
    tl.BackgroundTransparency = 1
    tl.Text = title
    tl.TextColor3 = C_Gray
    tl.Font = Enum.Font.GothamSemibold
    tl.TextSize = 10
    tl.TextXAlignment = Enum.TextXAlignment.Left

    local vl = Instance.new("TextLabel", mb)
    vl.Size = UDim2.new(0.48, -10, 1, 0)
    vl.Position = UDim2.new(0.5, 0, 0, 0)
    vl.BackgroundTransparency = 1
    vl.Text = tostring(cfg[currentKey] or list[1])
    vl.TextColor3 = C_Accent
    vl.Font = Enum.Font.GothamBold
    vl.TextSize = 10
    vl.TextXAlignment = Enum.TextXAlignment.Right

    local If = Instance.new("ScrollingFrame", parent)
    If.Size = UDim2.new(1, 0, 0, 0)
    If.BackgroundColor3 = C_Side
    If.BorderSizePixel = 0
    If.Visible = false
    If.CanvasSize = UDim2.new(0, 0, 0, 0)
    If.AutomaticCanvasSize = Enum.AutomaticSize.Y
    If.ScrollBarThickness = 3
    Instance.new("UICorner", If).CornerRadius = UDim.new(0, 6)
    local II = Instance.new("UIListLayout", If)
    II.Padding = UDim.new(0, 2)

    for i, v in ipairs(list) do
        local vv, ii = v, i
        local opt = Instance.new("TextButton", If)
        opt.Size = UDim2.new(1, -4, 0, 26)
        opt.BackgroundColor3 = C_Card
        opt.Text = tostring(vv)
        opt.TextColor3 = C_Text
        opt.Font = Enum.Font.GothamSemibold
        opt.TextSize = 10
        Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 4)
        safeClick(opt, function()
            vl.Text = tostring(vv)
            cfg[currentKey] = isStrDrop and tostring(vv) or ii
            If.Visible = false
            If.Size = UDim2.new(1, 0, 0, 0)
            if callback then callback(vv, ii) end
        end)
    end

    safeClick(mb, function()
        If.Visible = not If.Visible
        If.Size = If.Visible and UDim2.new(1, 0, 0, 110) or UDim2.new(1, 0, 0, 0)
    end)
                    end--=====================================================================
-- ABAS E OPCOES
--=====================================================================
local pageFarm      = createCh("Auto Farm", 1)
local pageHalloween = createCh("Halloween", 2)
local pageCombat    = createCh("Combat & Click", 3)
local pageSettings  = createCh("Settings", 4)

-- ABA 1: AUTO FARM
addSection(pageFarm, "Auto Farm Level")
addDropdown(pageFarm, "Select Weapon:", {"Melee", "Sword", "Gun", "Fruit"}, "selectedWeapon", function(v)
    cfg.selectedWeapon = v
end, true)
addT(pageFarm, "Start Farm Level", "startFarm", function(on)
    setStatus(on and "Farm Ativado" or "Idle")
end)
addT(pageFarm, "Accept Quests", "autoQuest")
addT(pageFarm, "Bring Mobs (Cluster)", "bringMobs")

-- ABA 2: HALLOWEEN EVENT
addSection(pageHalloween, "Update 30 — Halloween Event")
addT(pageHalloween, "Auto Farm Pumpkins", "farmPumpkins", function(on)
    setStatus(on and "Halloween: Pumpkins" or "Idle")
end)
addT(pageHalloween, "Skip Jack o' Lantern (Fast)", "skipJackOLantern")
addT(pageHalloween, "Auto Great Pumpkin (Boss)", "autoGreatPumpkin", function(on)
    setStatus(on and "Halloween: Boss" or "Idle")
end)
addT(pageHalloween, "Auto Trick or Treat (Doors)", "autoTrickOrTreat")
addSection(pageHalloween, "Halloween Gacha")
addT(pageHalloween, "Auto Roll Spooky Gacha", "autoSpookyGacha")
addActionBtn(pageHalloween, "Roll Spooky Gacha x1 Now", function()
    setStatus("Rolling Spooky Gacha...")
    invokeCommF("HalloweenGacha", "Roll")
    invokeCommF("Cousin", "Buy")
end)

-- ABA 3: COMBAT & AUTO CLICK
addSection(pageCombat, "Fast Attack & Auto Click")
addT(pageCombat, "Enable Fast Attack (Multi-Target)", "fastAttack")
addT(pageCombat, "Auto Click (Continuous / Standalone)", "autoClick", function(on)
    setStatus(on and "Auto Click ON" or "Idle")
end)
addT(pageCombat, "Auto Buso Haki", "autoTurnOnBuso")

-- ABA 4: SETTINGS
addSection(pageSettings, "Performance (Delta Mobile)")
addActionBtn(pageSettings, "FPS Boost + Clean RAM Now", function()
    setStatus("Otimizando FPS & RAM...")
    applyFPSBoost()
    setStatus("FPS Boost Aplicado!")
end)
addT(pageSettings, "No Renderer 3D (AFK Mode)", "noRender", function(on)
    pcall(function() runS:Set3dRenderingEnabled(not on) end)
end)
addSection(pageSettings, "Utilities")
addT(pageSettings, "Noclip", "noclip")
addActionBtn(pageSettings, "Server Hop (Less Players)", function()
    setStatus("Server Hop...")
    task.spawn(hopServer)
end)

--=====================================================================
-- LOOPS OTIMIZADOS (THREADS SEPARADAS)
--=====================================================================

-- 1. AUTO CLICK INDEPENDENTE
task.spawn(function()
    while true do
        task.wait(cfg.autoClickDelay)
        if cfg.unlocked and cfg.autoClick then
            pcall(triggerClick)
        end
    end
end)

-- 2. FAST ATTACK
task.spawn(function()
    while true do
        task.wait(cfg.fastAttackDelay)
        if cfg.unlocked and cfg.fastAttack
           and (cfg.startFarm or cfg.farmPumpkins or cfg.autoGreatPumpkin or cfg.autoClick) then
            pcall(doFastAttack)
        end
    end
end)

-- 3. AUTO FARM LEVEL
task.spawn(function()
    local qCooldown = 0
    while task.wait(0.35) do
        if cfg.unlocked and cfg.startFarm
           and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local myHrp = p.Character.HumanoidRootPart
            local quest = getCurrentQuest()
            if cfg.autoQuest and not hasActiveQuest() and tick() > qCooldown then
                setStatus("Pegando Quest: " .. quest[2])
                absoluteTP(myHrp, quest[3] + Vector3.new(0, 5, 0))
                task.wait(0.25)
                invokeCommF("StartQuest", quest[2], quest[6])
                qCooldown = tick() + 6
            end

            local target = nil
            local enemies = getEnemies()
            if enemies then
                for _, m in ipairs(enemies:GetChildren()) do
                    if string.find(m.Name, quest[4]) then
                        local mHrp = m:FindFirstChild("HumanoidRootPart")
                        local mHum = m:FindFirstChildOfClass("Humanoid")
                        if mHrp and mHum and mHum.Health > 0 then
                            target = m
                            break
                        end
                    end
                end
            end

            if target then
                setStatus("Atacando: " .. quest[4])
                local tCFrame = target.HumanoidRootPart.CFrame
                absoluteTP(myHrp, tCFrame * CFrame.new(0, 18, 0))
                if cfg.bringMobs and enemies then
                    for _, om in ipairs(enemies:GetChildren()) do
                        if om ~= target and om.Name == target.Name then
                            local omHrp = om:FindFirstChild("HumanoidRootPart")
                            local omHum = om:FindFirstChildOfClass("Humanoid")
                            if omHrp and omHum and omHum.Health > 0
                               and (omHrp.Position - tCFrame.Position).Magnitude <= 180 then
                                omHrp.CFrame = tCFrame
                                omHrp.AssemblyLinearVelocity   = Vector3.zero
                                omHrp.CanCollide = false
                            end
                        end
                    end
                end
            else
                setStatus("Aguardando Spawn: " .. quest[4])
                absoluteTP(myHrp, quest[5] + Vector3.new(0, 25, 0))
            end
        end
    end
end)

-- 4. LOOP COMPLETO DE HALLOWEEN (UPDATE 30)
task.spawn(function()
    local gachaCooldown = 0
    while task.wait(0.4) do
        if cfg.unlocked and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local myHrp = p.Character.HumanoidRootPart
            local enemies = getEnemies()

            -- A) Auto Great Pumpkin Boss
            if cfg.autoGreatPumpkin and enemies then
                local boss = nil
                for _, m in ipairs(enemies:GetChildren()) do  -- FIX #11
                    local lower = string.lower(m.Name)
                    if string.find(lower, "great pumpkin") or string.find(lower, "pumpkin boss") then
                        local bHrp = m:FindFirstChild("HumanoidRootPart")
                        local bHum = m:FindFirstChildOfClass("Humanoid")
                        if bHrp and bHum and bHum.Health > 0 then
                            boss = m
                            break
                        end
                    end
                end
                if boss then
                    setStatus("Boss: " .. boss.Name)
                    absoluteTP(myHrp, boss.HumanoidRootPart.CFrame * CFrame.new(0, 18, 0))
                    pcall(triggerClick)
                end
            end

            -- B) Auto Farm Pumpkins / Skip Jack o' Lantern
            if cfg.farmPumpkins then
                local foundTarget = false
                if enemies then
                    for _, obj in ipairs(enemies:GetChildren()) do
                        local lower = string.lower(obj.Name)
                        local isPumpkin = string.find(lower, "pumpkin")
                        local isJack = string.find(lower, "jack")
                        if isPumpkin or (isJack and not cfg.skipJackOLantern) then
                            local primary = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            local hum = obj:FindFirstChildOfClass("Humanoid")
                            if primary and (not hum or hum.Health > 0) then
                                setStatus("Halloween: " .. obj.Name)
                                absoluteTP(myHrp, primary.CFrame * CFrame.new(0, 10, 0))
                                pcall(triggerClick)
                                foundTarget = true
                                break
                            end
                        end
                    end
                end
                if not foundTarget then
                    for _, obj in ipairs(workspace:GetChildren()) do
                        local lower = string.lower(obj.Name)
                        if string.find(lower, "pumpkin") then
                            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                            if part then
                                setStatus("Quebrando Abóbora...")
                                absoluteTP(myHrp, part.CFrame * CFrame.new(0, 6, 0))
                                pcall(triggerClick)
                                break
                            end
                        end
                    end
                end
            end

            -- C) Auto Trick or Treat (Portas do Evento)
            if cfg.autoTrickOrTreat then
                for _, d in ipairs(workspace:GetDescendants()) do
                    if d:IsA("ProximityPrompt") and d.Enabled then
                        local parentName = string.lower(d.Parent and d.Parent.Name or "")
                        local actionText = string.lower(d.ActionText or "")
                        if string.find(parentName, "door") or string.find(actionText, "trick") or string.find(actionText, "knock") then
                            local doorPart = d.Parent:IsA("BasePart") and d.Parent or d.Parent:FindFirstChildWhichIsA("BasePart")
                            if doorPart then
                                setStatus("Trick or Treat...")
                                absoluteTP(myHrp, doorPart.CFrame * CFrame.new(0, 0, 3))
                                task.wait(0.15)
                                if typeof(fireproximityprompt) == "function" then
                                    pcall(fireproximityprompt, d)
                                end
                                break
                            end
                        end
                    end
                end
            end

            -- D) Auto Spooky Gacha
            if cfg.autoSpookyGacha and tick() > gachaCooldown then
                invokeCommF("HalloweenGacha", "Roll")
                gachaCooldown = tick() + 5
            end
        end
    end
end)

-- 5. NOCLIP LEVE
table.insert(getgenv().StringtrapConnections, runS.Stepped:Connect(function()
    if cfg.unlocked and cfg.noclip and p.Character then
        for _, part in ipairs(p.Character:GetChildren()) do  -- FIX #6
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end))

-- 6. ANTI-AFK
table.insert(getgenv().StringtrapConnections, p.Idled:Connect(function()
    pcall(function()
        vu:CaptureController()
        vu:ClickButton2(Vector2.zero)
    end)
end))

-- 7. ANTI-BAN SERVER HOP
task.spawn(function()
    task.wait(15)
    local nextHop = math.random(ANTIBAN_MIN * 60, ANTIBAN_MAX * 60)
    local startedAt = tick()
    while task.wait(2) do
        if cfg.unlocked and (tick() - startedAt >= nextHop) then
            setStatus("Anti-Ban Hop...")
            if ANTIBAN_URL ~= "" then  -- FIX #7
                local src = string.format(
                    [=[getgenv().StringtrapHub_AutoReload = true; pcall(function() return loadstring(game:HttpGet("%s"))() end)]=],
                    ANTIBAN_URL
                )
                queueTeleport(src)
            end
            hopServer()
            nextHop = math.random(ANTIBAN_MIN * 60, ANTIBAN_MAX * 60)
            startedAt = tick()
        end
    end
end)
