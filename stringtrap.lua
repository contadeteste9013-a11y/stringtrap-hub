-- ============================================================
--  STRINGTRAP HUB - UPDATE 30 / HALLOWEEN 2026 (FIXED)
-- ============================================================
local ANTIBAN_URL = "https://raw.githubusercontent.com/contadeteste9013-a11y/stringtrap-hub/refs/heads/main/stringtrap.lua"
local ANTIBAN_MIN = 30
local ANTIBAN_MAX = 40

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local uis     = game:GetService("UserInputService")
local vim     = game:GetService("VirtualInputManager")
local ts      = game:GetService("TweenService")
local rs      = game:GetService("ReplicatedStorage")
local vu      = game:GetService("VirtualUser")
local runS    = game:GetService("RunService")
local p       = Players.LocalPlayer
local pGui    = p:WaitForChild("PlayerGui")

if pGui:FindFirstChild("StringtrapHub") then pGui.StringtrapHub:Destroy() end
local getgenv = getgenv or function() return _G end

local cfg = {
    unlocked = false, showStatusBar = true, selectedWeapon = "Melee",
    fastAttack = true, fastAttackDelay = 0.08, attackNoAnim = true,
    autoClick = false, autoTurnOnBuso = true, autoKen = false,
    startFarm = false, autoQuest = true, autoEquipWeapon = true,
    bringMobs = true, distanceFarmAura = 300, farmMastery = false,
    farmPumpkins = false, autoHalloweenEvent = false, autoTrickOrTreat = false,
    autoGachaHalloween = false, autoRollSpookyGacha = false, spookyGachaAllowSilverKey = false,
    autoCloseGachaUI = true, summonGreatPumpkin = false,
    selectedTeam = "Pirates", noclip = false, fastMode = false, noRender = false,
}

local KEY = "williamafton2026"
local IMG = "rbxassetid://77611955682353"

local autoReload = false
if getgenv().StringtrapHub_AutoReload == true then
    autoReload = true; getgenv().StringtrapHub_AutoReload = nil
end

local function queueTeleport(source)
    local qot = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
    if qot then return pcall(qot, source) end
    return false, "Nao suportado"
end

local function hopServer()
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local ok, res = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if not ok or not res or not res.data then
        pcall(function() TeleportService:Teleport(game.PlaceId, p) end); return true, "rejoin"
    end
    local candidates = {}
    for _, s in ipairs(res.data) do
        if s.id ~= game.JobId and s.playing < s.maxPlayers then table.insert(candidates, s) end
    end
    if #candidates == 0 then
        pcall(function() TeleportService:Teleport(game.PlaceId, p) end); return true, "rejoin"
    end
    table.sort(candidates, function(a, b) return a.playing < b.playing end)
    local target = candidates[1]
    local hopOk, hopErr = pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, target.id, p) end)
    if not hopOk then return false, tostring(hopErr) end
    return true, target.playing .. "/" .. target.maxPlayers
end

local function getEnemies() return workspace:FindFirstChild("Enemies") end
local function invokeCommF(...)
    local remotes = rs:FindFirstChild("Remotes")
    local commF = remotes and remotes:FindFirstChild("CommF_")
    if commF then return pcall(function(...) return commF:InvokeServer(...) end, ...) end
    return false, "CommF_ não encontrado"
end

-- TELEPORTE BLINDADO (Evita o personagem voltar/tremer)
local function absoluteTP(hrp, targetCFrame)
    pcall(function() hrp:SetNetworkOwner(p) end)
    hrp.CFrame = targetCFrame
    hrp.Velocity = Vector3.new(0, 0, 0)
    hrp.RotVelocity = Vector3.new(0, 0, 0)
endlocal QuestsData = {
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
    {450, "SkyExp1Quest", CFrame.new(-4721, 845, -1954), "God's Guard", CFrame.new(-4650, 845, -1900), 1},
    {625, "FountainQuest", CFrame.new(5259, 38, 4050), "Galley Pirate", CFrame.new(5360, 38, 4120), 1},
    {700, "Area1Quest", CFrame.new(-427, 72, 1835), "Raider", CFrame.new(-220, 72, 1950), 1},
    {775, "Area2Quest", CFrame.new(-775, 73, 865), "Swan Pirate", CFrame.new(-920, 73, 1020), 1},
    {875, "MarineQuest3", CFrame.new(-2440, 73, -3218), "Marine Lieutenant", CFrame.new(-2280, 73, -3100), 1},
    {950, "ZombieQuest", CFrame.new(-5495, 48, -794), "Zombie", CFrame.new(-5560, 48, -700), 1},
    {1050, "SnowMountainQuest", CFrame.new(607, 401, -5370), "Snow Trooper", CFrame.new(520, 401, -5250), 1},
    {1150, "IceSideQuest", CFrame.new(-6060, 15, -4902), "Lab Subordinate", CFrame.new(-6200, 15, -4800), 1},
    {1250, "ShipQuest1", CFrame.new(923, 125, 32852), "Ship Deckhand", CFrame.new(910, 125, 33000), 1},
    {1350, "FrostQuest", CFrame.new(5505, 28, -6225), "Arctic Warrior", CFrame.new(5650, 28, -6300), 1},
    {1425, "ForgottenQuest", CFrame.new(-3054, 236, -10148), "Sea Soldier", CFrame.new(-3150, 236, -10000), 1},
    {1500, "PiratePortQuest", CFrame.new(-290, 43, 5430), "Pirate Millionaire", CFrame.new(-450, 73, 5550), 1},
    {1575, "AmazonQuest", CFrame.new(5210, 604, 345), "Dragon Crew Warrior", CFrame.new(5100, 604, 480), 1},
    {1700, "MarineTreeIsland", CFrame.new(2192, 28, -6732), "Marine Commodore", CFrame.new(2350, 28, -6600), 1},
    {1775, "DeepForestIsland", CFrame.new(-13275, 332, -7768), "Forest Pirate", CFrame.new(-13400, 332, -7600), 1},
    {1975, "HauntedQuest1", CFrame.new(-9515, 142, 6078), "Reborn Skeleton", CFrame.new(-9504, 172, 6050), 1},
    {2075, "TreatQuest1", CFrame.new(-2020, 38, -12026), "Cookie Crafter", CFrame.new(-1900, 38, -11900), 1},
    {2450, "TikiQuest1", CFrame.new(-16547, 55, -173), "Isle Outlaw", CFrame.new(-16400, 55, -100), 1},
}

local function getPlayerLevel()
    local d = p:FindFirstChild("Data")
    if d and d:FindFirstChild("Level") then return d.Level.Value end
    return 1
end

local function getCurrentQuest()
    local myLvl = getPlayerLevel()
    local best = QuestsData[1]
    for _, q in ipairs(QuestsData) do
        if myLvl >= q[1] then best = q else break end
    end
    return best
end

local function hasActiveQuest()
    local pData = p:FindFirstChild("PlayerGui")
    if pData and pData:FindFirstChild("Main") and pData.Main:FindFirstChild("Quest") then
        return pData.Main.Quest.Visible
    end
    return false
end

local function equipTool()
    if not p.Character then return end
    local char = p.Character
    for _, t in pairs(char:GetChildren()) do
        if t:IsA("Tool") and t:FindFirstChild("ToolTip") and t.ToolTip == cfg.selectedWeapon then return t end
    end
    local bp = p:FindFirstChild("Backpack")
    if bp then
        for _, t in pairs(bp:GetChildren()) do
            if t:IsA("Tool") and t:FindFirstChild("ToolTip") and t.ToolTip == cfg.selectedWeapon then
                t.Parent = char; return t
            end
        end
    end
end

local function doFastAttack()
    if not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then return end
    equipTool()

    local hitTargets = {}
    local hrp = p.Character.HumanoidRootPart
    local enemies = getEnemies()
    
    if enemies then
        for _, mob in pairs(enemies:GetChildren()) do
            local mHrp = mob:FindFirstChild("HumanoidRootPart")
            local mHum = mob:FindFirstChildOfClass("Humanoid")
            if mHrp and mHum and mHum.Health > 0 and (mHrp.Position - hrp.Position).Magnitude <= 65 then
                table.insert(hitTargets, mHrp)
            end
        end
    end

    if #hitTargets > 0 then
        pcall(function()
            if p.Character:FindFirstChildOfClass("Tool") then
                if rs.Remotes:FindFirstChild("Validator") then rs.Remotes.Validator:FireServer(math.floor(tick())) end
                local hitRemote = rs:FindFirstChild("Hit", true) or rs.Remotes:FindFirstChild("RegisterHit")
                if hitRemote then hitRemote:FireServer(hitTargets[1], hitTargets) end
            end
        end)
    end
    pcall(function()
        if vim and vim.SendMouseButtonEvent then
            vim:SendMouseButtonEvent(0, 0, 0, true, game, 1); task.wait(0.01); vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        elseif vu and vu.Button1Down then
            vu:Button1Down(Vector2.new(0, 0)); task.wait(0.01); vu:Button1Up(Vector2.new(0, 0))
        end
    end)
    endlocal C_Bg=Color3.fromRGB(18,18,24); local C_Side=Color3.fromRGB(24,24,32)
local C_Card=Color3.fromRGB(30,32,44); local C_Accent=Color3.fromRGB(255,180,0)
local C_Green=Color3.fromRGB(80,200,80); local C_Text=Color3.fromRGB(240,240,245)
local C_Gray=Color3.fromRGB(140,145,165); local C_Off=Color3.fromRGB(50,52,68)
local statusLbl

local function safeClick(b, f)
    local busy = false
    b.Activated:Connect(function()
        if busy then return end; busy = true
        local ok, err = pcall(f); if not ok then warn("[UI Error]:", err) end
        task.wait(0.12); busy = false
    end)
end

local function drag(h, t)
    local d, ds, sp
    h.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then d = true; ds = i.Position; sp = t.Position end
    end)
    uis.InputChanged:Connect(function(i)
        if d and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = i.Position - ds
            t.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
        end
    end)
    uis.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end
    end)
end

local function setStatus(txt) if statusLbl then statusLbl.Text = "Status : " .. tostring(txt) end end

local gui = Instance.new("ScreenGui")
gui.Name = "StringtrapHub"; gui.ResetOnSpawn = false; gui.Parent = pGui

local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(0,340,0,46); statusBar.Position = UDim2.new(0.5,-170,0,8)
statusBar.BackgroundColor3 = C_Side; statusBar.ZIndex = 200; statusBar.Parent = gui; statusBar.Visible = false
Instance.new("UICorner", statusBar).CornerRadius = UDim.new(0,8); Instance.new("UIStroke", statusBar).Color = C_Accent

local statusTitle = Instance.new("TextLabel", statusBar)
statusTitle.Size = UDim2.new(1,0,0,18); statusTitle.Position = UDim2.new(0,0,0,2); statusTitle.BackgroundTransparency = 1
statusTitle.Text = "Stringtrap Status (Halloween 2026)"; statusTitle.TextColor3 = C_Accent; statusTitle.Font = Enum.Font.GothamBlack
statusTitle.TextSize = 11; statusTitle.TextXAlignment = Enum.TextXAlignment.Center

statusLbl = Instance.new("TextLabel", statusBar)
statusLbl.Size = UDim2.new(1,-12,0,20); statusLbl.Position = UDim2.new(0,6,0,22); statusLbl.BackgroundTransparency = 1
statusLbl.Text = "Status : Idle"; statusLbl.TextColor3 = C_Text; statusLbl.Font = Enum.Font.GothamSemibold
statusLbl.TextSize = 10; statusLbl.TextXAlignment = Enum.TextXAlignment.Center

local kf = Instance.new("Frame")
kf.Size = UDim2.new(0,320,0,180); kf.Position = UDim2.new(0.5,-160,0.5,-90)
kf.BackgroundColor3 = C_Bg; kf.ZIndex = 9999; kf.Parent = gui
Instance.new("UICorner", kf).CornerRadius = UDim.new(0,8); Instance.new("UIStroke", kf).Color = C_Accent

local kft = Instance.new("Frame")
kft.Size = UDim2.new(1,0,0,34); kft.BackgroundColor3 = C_Side; kft.ZIndex = 10000; kft.Parent = kf
Instance.new("UICorner", kft).CornerRadius = UDim.new(0,8); drag(kft, kf)

local ktt = Instance.new("TextLabel", kft)
ktt.Size = UDim2.new(1,-20,1,0); ktt.Position = UDim2.new(0,10,0,0); ktt.BackgroundTransparency = 1
ktt.Text = "Stringtrap Hub - Blox Fruits"; ktt.TextColor3 = C_Accent; ktt.Font = Enum.Font.GothamBlack
ktt.TextSize = 13; ktt.TextXAlignment = Enum.TextXAlignment.Left; ktt.ZIndex = 10001

local ki = Instance.new("TextBox")
ki.Size = UDim2.new(0.86,0,0,38); ki.Position = UDim2.new(0.07,0,0.34,0); ki.BackgroundColor3 = C_Card
ki.TextColor3 = C_Text; ki.PlaceholderText = "Type the key..."; ki.Text = ""; ki.ClearTextOnFocus = false
ki.Font = Enum.Font.GothamSemibold; ki.TextSize = 12; ki.ZIndex = 10001; ki.Parent = kf
Instance.new("UICorner", ki).CornerRadius = UDim.new(0,6)

local kb = Instance.new("TextButton")
kb.Size = UDim2.new(0.86,0,0,40); kb.Position = UDim2.new(0.07,0,0.65,0); kb.BackgroundColor3 = C_Accent
kb.TextColor3 = Color3.fromRGB(15,15,20); kb.Text = "LOAD STRINGTRAP HUB"; kb.Font = Enum.Font.GothamBlack
kb.TextSize = 13; kb.ZIndex = 10001; kb.Parent = kf
Instance.new("UICorner", kb).CornerRadius = UDim.new(0,6)

local photo = Instance.new("ImageButton")
photo.Size = UDim2.new(0,54,0,54); photo.Position = UDim2.new(0,20,0.5,-27); photo.BackgroundColor3 = C_Bg
photo.Image = IMG; photo.Visible = false; photo.Parent = gui
Instance.new("UICorner", photo).CornerRadius = UDim.new(0,10); Instance.new("UIStroke", photo).Color = C_Accent; drag(photo, photo)

local mf = Instance.new("Frame")
mf.Size = UDim2.new(0,560,0,430); mf.Position = UDim2.new(0.5,-280,0.5,-215); mf.BackgroundColor3 = C_Bg
mf.Visible = false; mf.Parent = gui
Instance.new("UICorner", mf).CornerRadius = UDim.new(0,8); Instance.new("UIStroke", mf).Color = C_Accent

local top = Instance.new("Frame")
top.Size = UDim2.new(1,0,0,36); top.BackgroundColor3 = C_Side; top.Parent = mf
Instance.new("UICorner", top).CornerRadius = UDim.new(0,8); drag(top, mf)

local ttl = Instance.new("TextLabel", top)
ttl.Size = UDim2.new(1,-50,1,0); ttl.Position = UDim2.new(0,14,0,0); ttl.BackgroundTransparency = 1
ttl.Text = "Stringtrap Hub · Update 30 Halloween"; ttl.TextColor3 = C_Accent; ttl.Font = Enum.Font.GothamBlack
ttl.TextSize = 13; ttl.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", top)
minBtn.Size = UDim2.new(0,28,0,22); minBtn.Position = UDim2.new(1,-36,0.5,-11); minBtn.BackgroundColor3 = C_Card
minBtn.Text = "-"; minBtn.TextColor3 = C_Text; minBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0,4)

safeClick(minBtn, function() mf.Visible = false end)
safeClick(photo, function() mf.Visible = not mf.Visible end)

safeClick(kb, function()
    if ki.Text == KEY or autoReload then
        cfg.unlocked = true; kf.Visible = false; mf.Visible = true; photo.Visible = true
        statusBar.Visible = cfg.showStatusBar; setStatus(autoReload and "Auto-Reloaded" or "Idle")
    else
        kb.Text = "INVALID KEY"; task.wait(1); kb.Text = "LOAD STRINGTRAP HUB"
    end
end)

if autoReload then
    cfg.unlocked = true; kf.Visible = false; mf.Visible = true; photo.Visible = true
    statusBar.Visible = cfg.showStatusBar; setStatus("Auto-Reloaded")
        endlocal side = Instance.new("Frame")
side.Size = UDim2.new(0,150,1,-46); side.Position = UDim2.new(0,6,0,40); side.BackgroundColor3 = C_Side; side.Parent = mf
Instance.new("UICorner", side).CornerRadius = UDim.new(0,6)

local sl = Instance.new("UIListLayout", side); sl.Padding = UDim.new(0,3); sl.SortOrder = Enum.SortOrder.LayoutOrder
local sp = Instance.new("UIPadding", side); sp.PaddingTop = UDim.new(0,6); sp.PaddingLeft = UDim.new(0,6); sp.PaddingRight = UDim.new(0,6)

local cont = Instance.new("Frame")
cont.Size = UDim2.new(1,-168,1,-46); cont.Position = UDim2.new(0,162,0,40); cont.BackgroundTransparency = 1; cont.Parent = mf

local ch = {}
local function createCh(n, o)
    local b = Instance.new("TextButton")
    b.LayoutOrder = o; b.Size = UDim2.new(1,0,0,30)
    b.BackgroundColor3 = (o == 1) and C_Card or C_Bg; b.Text = n
    b.TextColor3 = (o == 1) and C_Accent or C_Gray; b.Font = Enum.Font.GothamBold
    b.TextSize = 10; b.Active = true; b.Parent = side
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,5)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1; page.BorderSizePixel = 0
    page.ScrollBarThickness = 4; page.ScrollBarImageColor3 = C_Accent; page.Visible = (o == 1)
    page.CanvasSize = UDim2.new(0,0,0,0); page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollingDirection = Enum.ScrollingDirection.Y; page.Parent = cont

    local l = Instance.new("UIListLayout", page); l.Padding = UDim.new(0,5); l.SortOrder = Enum.SortOrder.LayoutOrder
    local pad = Instance.new("UIPadding", page)
    pad.PaddingTop = UDim.new(0,4); pad.PaddingBottom = UDim.new(0,4)
    pad.PaddingLeft = UDim.new(0,4); pad.PaddingRight = UDim.new(0,4)

    table.insert(ch, {btn = b, page = page})
    safeClick(b, function()
        for _, v in ipairs(ch) do v.page.Visible = false; v.btn.BackgroundColor3 = C_Bg; v.btn.TextColor3 = C_Gray end
        page.Visible = true; b.BackgroundColor3 = C_Card; b.TextColor3 = C_Accent
    end)
    return page
end

local function addSection(parent, txt)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(1,0,0,22); f.BackgroundColor3 = C_Side
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,4)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1,-10,1,0); l.Position = UDim2.new(0,8,0,0); l.BackgroundTransparency = 1
    l.Text = txt; l.TextColor3 = C_Accent; l.Font = Enum.Font.GothamBlack; l.TextSize = 10; l.TextXAlignment = Enum.TextXAlignment.Left
end

local function addT(parent, txt, key, onToggle)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1,0,0,34); b.BackgroundColor3 = C_Card; b.Text = ""; b.AutoButtonColor = false; b.Active = true
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    local l = Instance.new("TextLabel", b)
    l.Size = UDim2.new(1,-55,1,0); l.Position = UDim2.new(0,10,0,0); l.BackgroundTransparency = 1
    l.Text = txt; l.TextColor3 = cfg[key] and C_Text or C_Gray; l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = Enum.Font.GothamSemibold; l.TextSize = 10
    local pill = Instance.new("Frame", b)
    pill.Size = UDim2.new(0,34,0,16); pill.Position = UDim2.new(1,-44,0.5,-8); pill.BackgroundColor3 = cfg[key] and C_Green or C_Off
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1,0)
    local knob = Instance.new("Frame", pill)
    knob.Size = UDim2.new(0,12,0,12); knob.Position = cfg[key] and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6)
    knob.BackgroundColor3 = Color3.fromRGB(240,240,240); Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
    safeClick(b, function()
        if cfg[key] == nil then cfg[key] = false end
        cfg[key] = not cfg[key]; local on = cfg[key]
        l.TextColor3 = on and C_Text or C_Gray; pill.BackgroundColor3 = on and C_Green or C_Off
        knob.Position = on and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6)
        if onToggle then onToggle(on) end
    end)
end

local function addDropdown(parent, title, list, currentKey, callback, isStrDrop)
    local mb = Instance.new("TextButton", parent)
    mb.Size = UDim2.new(1,0,0,36); mb.BackgroundColor3 = C_Card; mb.Text = ""; mb.AutoButtonColor = false; mb.Active = true
    Instance.new("UICorner", mb).CornerRadius = UDim.new(0,6)
    local tl = Instance.new("TextLabel", mb)
    tl.Size = UDim2.new(0.48,0,1,0); tl.Position = UDim2.new(0,10,0,0); tl.BackgroundTransparency = 1
    tl.Text = title; tl.TextColor3 = C_Gray; tl.Font = Enum.Font.GothamSemibold; tl.TextSize = 10; tl.TextXAlignment = Enum.TextXAlignment.Left
    local vl = Instance.new("TextLabel", mb)
    vl.Size = UDim2.new(0.48,-10,1,0); vl.Position = UDim2.new(0.5,0,0,0); vl.BackgroundTransparency = 1
    vl.Text = tostring(cfg[currentKey] or list[1]); vl.TextColor3 = C_Accent; vl.Font = Enum.Font.GothamBold; vl.TextSize = 10; vl.TextXAlignment = Enum.TextXAlignment.Right
    local lf = Instance.new("ScrollingFrame", parent)
    lf.Size = UDim2.new(1,0,0,0); lf.BackgroundColor3 = C_Side; lf.BorderSizePixel = 0; lf.Visible = false
    lf.CanvasSize = UDim2.new(0,0,0,0); lf.AutomaticCanvasSize = Enum.AutomaticSize.Y; lf.ScrollBarThickness = 3
    Instance.new("UICorner", lf).CornerRadius = UDim.new(0,6)
    local ll = Instance.new("UIListLayout", lf); ll.Padding = UDim.new(0,2)
    for i, v in ipairs(list) do
        local vv, ii = v, i
        local opt = Instance.new("TextButton", lf)
        opt.Size = UDim2.new(1,-4,0,26); opt.BackgroundColor3 = C_Card; opt.Text = tostring(vv)
        opt.TextColor3 = C_Text; opt.Font = Enum.Font.GothamSemibold; opt.TextSize = 10
        Instance.new("UICorner", opt).CornerRadius = UDim.new(0,4)
        safeClick(opt, function()
            vl.Text = tostring(vv); cfg[currentKey] = isStrDrop and tostring(vv) or ii
            lf.Visible = false; lf.Size = UDim2.new(1,0,0,0)
            if callback then callback(vv, ii) end
        end)
    end
    safeClick(mb, function() lf.Visible = not lf.Visible; lf.Size = lf.Visible and UDim2.new(1,0,0,120) or UDim2.new(1,0,0,0) end)
end

local function addActionBtn(parent, txt, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1,0,0,32); b.BackgroundColor3 = C_Card; b.Text = txt
    b.TextColor3 = C_Accent; b.Font = Enum.Font.GothamBold; b.TextSize = 10
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6); safeClick(b, callback)
end

local pageHalloween = createCh("Halloween Event", 1)
local pageFarming   = createCh("Farming", 2)
local pageSettings  = createCh("Settings", 3)addSection(pageHalloween, "Halloween Event 2026")
addT(pageHalloween, "Auto Halloween Event", "autoHalloweenEvent")
addT(pageHalloween, "Farm Pumpkins (Fast)", "farmPumpkins")
addT(pageHalloween, "Auto Trick or Treat", "autoTrickOrTreat")
addT(pageHalloween, "Summon Great Pumpkin", "summonGreatPumpkin")
addSection(pageHalloween, "Spooky Gacha")
addT(pageHalloween, "Auto Gacha Halloween", "autoGachaHalloween")
addT(pageHalloween, "Auto Roll Spooky Gacha", "autoRollSpookyGacha")
addT(pageHalloween, "Auto Close Gacha UI", "autoCloseGachaUI")
addT(pageHalloween, "Spooky Gacha: Allow Silver Key", "spookyGachaAllowSilverKey")
addActionBtn(pageHalloween, "Open Spooky Gacha (Vendor)", function() invokeCommF("HalloweenGacha", "Open") end)

addSection(pageFarming, "Auto Farm Level")
addDropdown(pageFarming, "Select Weapon:", {"Melee", "Sword", "Gun", "Fruit"}, "selectedWeapon", function(v) cfg.selectedWeapon = v end, true)
addT(pageFarming, "Start Farm (Auto Quest)", "startFarm", function(on) setStatus(on and "Farm Ativado" or "Idle") end)
addT(pageFarming, "Accept Quests Automático", "autoQuest")
addT(pageFarming, "Bring Mobs", "bringMobs")
addT(pageFarming, "Auto Turn On Buso", "autoTurnOnBuso")

addSection(pageSettings, "Fast Attack & Click")
addT(pageSettings, "Enable Fast Attack", "fastAttack")
addT(pageSettings, "Auto Click (Continuous)", "autoClick")
addDropdown(pageSettings, "Fast Attack Delay:", {"0.05", "0.08", "0.1", "0.15", "0.2"}, "fastAttackDelay", function(v) cfg.fastAttackDelay = tonumber(v) end, true)
addT(pageSettings, "Noclip", "noclip")
addActionBtn(pageSettings, "Server Hop", function()
    setStatus("Searching..."); task.spawn(function() local ok, info = hopServer(); setStatus(ok and ("Hopping -> " .. info) or ("Falha: " .. info)) end)
end)

task.spawn(function()
    while true do
        task.wait(cfg.fastAttackDelay or 0.08)
        if (cfg.autoClick or cfg.startFarm or cfg.farmPumpkins or cfg.autoHalloweenEvent) and cfg.fastAttack then doFastAttack() end
    end
end)

task.spawn(function()
    local questCooldown = 0
    while task.wait(0.5) do
        if cfg.startFarm and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local myHrp = p.Character.HumanoidRootPart
            local quest = getCurrentQuest()
            
            if cfg.autoQuest and tick() > questCooldown then
                setStatus("Pegando Quest: " .. quest[2])
                absoluteTP(myHrp, quest[3] + Vector3.new(0, 5, 0))
                task.wait(0.5)
                invokeCommF("StartQuest", quest[2], quest[6])
                questCooldown = tick() + 10 
            end

            local targetMob = nil; local enemies = getEnemies()
            if enemies then
                for _, mob in pairs(enemies:GetChildren()) do
                    if (mob.Name == quest[4] or string.find(mob.Name, quest[4])) and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChildOfClass("Humanoid") and mob:FindFirstChildOfClass("Humanoid").Health > 0 then
                        targetMob = mob; break
                    end
                end
            end

            if targetMob then
                local mobHrp = targetMob.HumanoidRootPart
                absoluteTP(myHrp, mobHrp.CFrame * CFrame.new(0, 18, 0) * CFrame.Angles(math.rad(-90), 0, 0))
                setStatus("Matando: " .. quest[4])

                if cfg.bringMobs and enemies then
                    for _, otherMob in pairs(enemies:GetChildren()) do
                        if otherMob ~= targetMob and otherMob.Name == targetMob.Name and otherMob:FindFirstChild("HumanoidRootPart") and otherMob:FindFirstChildOfClass("Humanoid") and otherMob:FindFirstChildOfClass("Humanoid").Health > 0 then
                            if (otherMob.HumanoidRootPart.Position - mobHrp.Position).Magnitude <= 200 then
                                otherMob.HumanoidRootPart.CFrame = mobHrp.CFrame; otherMob.HumanoidRootPart.CanCollide = false
                            end
                        end
                    end
                end
            else
                setStatus("Indo ao spawn de: " .. quest[4])
                absoluteTP(myHrp, quest[5] + Vector3.new(0, 25, 0))
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if cfg.farmPumpkins and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local myHrp = p.Character.HumanoidRootPart; local enemies = getEnemies()
            if enemies then
                for _, obj in pairs(enemies:GetChildren()) do
                    if string.find(string.lower(obj.Name), "pumpkin") or string.find(string.lower(obj.Name), "jack") then
                        local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                        if primary then
                            setStatus("Quebrando Abóbora..."); absoluteTP(myHrp, primary.CFrame * CFrame.new(0, 8, 0))
                            invokeCommF("HalloweenEvent", "HitPumpkin", primary); break
                        end
                    end
                end
            end
        end
        if cfg.autoRollSpookyGacha or cfg.autoGachaHalloween then
            invokeCommF("HalloweenGacha", "Roll", cfg.spookyGachaAllowSilverKey)
            if cfg.autoCloseGachaUI then
                local gUi = pGui:FindFirstChild("SpookyGacha") or pGui:FindFirstChild("HalloweenUI")
                if gUi then gUi.Enabled = false end
            end
        end
        if cfg.autoTrickOrTreat then invokeCommF("HalloweenEvent", "TrickOrTreat") end
        if cfg.summonGreatPumpkin then invokeCommF("HalloweenEvent", "SummonGreatPumpkin") end
    end
end)

runS.Stepped:Connect(function()
    if cfg.noclip and p.Character then
        for _, part in pairs(p.Character:GetDescendants()) do if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end end
    end
end)

task.spawn(function()
    while task.wait(3) do if cfg.autoTurnOnBuso and p.Character and not p.Character:FindFirstChild("HasBuso") then invokeCommF("Buso") end end
end)

task.spawn(function()
    task.wait(15); local nextHop = math.random(ANTIBAN_MIN * 60, ANTIBAN_MAX * 60); local startedAt = tick()
    while true do
        task.wait(1); local elapsed = tick() - startedAt
        if elapsed >= nextHop then
            setStatus("Anti-Ban: Trocando de servidor...")
            if ANTIBAN_URL and ANTIBAN_URL ~= "" then
                local src = string.format([=[getgenv().StringtrapHub_AutoReload = true; local ok,err=pcall(function() return loadstring(game:HttpGet("%s"))() end); if not ok then warn("Error:",err) end]=], ANTIBAN_URL)
                queueTeleport(src)
            end
            hopServer(); nextHop = math.random(ANTIBAN_MIN * 60, ANTIBAN_MAX * 60); startedAt = tick()
        end
    end
end)
