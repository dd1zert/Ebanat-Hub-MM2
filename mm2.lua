local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local players = game:GetService("Players")
local teleportService = game:GetService("TeleportService")
local workspace = game:GetService("Workspace")
local userInputService = game:GetService("UserInputService")

local SETTINGS = {
    walkSpeed = 50,
    jumpPower = 80,
    autoHopTime = 300,
    flySpeed = 50,
    farmDelay = 0.2,
    farmSpeed = 16,
}

local ESP_COLORS = {
    MURDERER = Color3.fromRGB(255, 0, 0),
    SHERIFF = Color3.fromRGB(0, 100, 255),
    INNOCENT = Color3.fromRGB(0, 255, 100),
    DEAD = Color3.fromRGB(200, 200, 200),
}

local state = {
    farmMode = false,
    aimbotMode = false,
    espMode = false,
    autoCollect = false,
    autoServerHop = false,
    noClip = false,
    speedHack = false,
    jumpPower = false,
    antiBan = false,
    godMode = false,
    flyMode = false,
    isMinimized = false
}

local flyConnections = {}
local flying = false
local bodyVelocity
local coinCache = {}
local lastFarmTime = 0
local lastCoinUpdate = 0
local isFarming = false

local function getPlayerRole(plr)
    if not plr or not plr.Character then return "INNOCENT" end
    local tool = plr.Character:FindFirstChildOfClass("Tool")
    if tool then
        local name = tool.Name:lower()
        if name:find("knife") or name:find("нож") then return "MURDERER"
        elseif name:find("gun") or name:find("пистолет") or name:find("revolver") then return "SHERIFF" end
    end
    return "INNOCENT"
end

local function isPlayerAlive(plr)
    if not plr or not plr.Character then return false end
    local humanoid = plr.Character:FindFirstChild("Humanoid")
    if not humanoid then return false end
    return humanoid.Health > 0
end

local function getMurderer()
    for _, plr in ipairs(players:GetPlayers()) do
        if plr ~= player and getPlayerRole(plr) == "MURDERER" and isPlayerAlive(plr) then
            return plr
        end
    end
    return nil
end

local function getSheriff()
    for _, plr in ipairs(players:GetPlayers()) do
        if plr ~= player and getPlayerRole(plr) == "SHERIFF" and isPlayerAlive(plr) then
            return plr
        end
    end
    return nil
end

local function killTarget(target, isMurderer)
    if not target or not target.Character then return false end
    local char = player.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return false end
    
    root.CFrame = targetRoot.CFrame + Vector3.new(0, 2, 0)
    
    local tool = char:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Handle") then
        tool:Activate()
        wait(0.05)
        tool:Deactivate()
    else
        local targetHumanoid = target.Character:FindFirstChild("Humanoid")
        if targetHumanoid then
            targetHumanoid.Health = 0
        end
    end
    
    wait(0.1)
    return true
end

local function updateCoinCache()
    coinCache = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:find("Coin") or obj.Name:find("Money") or obj.Name:find("Cash")) then
            if obj.Parent and obj.Transparency < 0.5 then
                table.insert(coinCache, obj)
            end
        end
    end
end

local function startFly()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not root or not humanoid then return end

    flying = true
    state.noClip = true

    humanoid.PlatformStand = true
    humanoid.AutoRotate = false

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = root

    local moveForward = false
    local moveBackward = false
    local moveLeft = false
    local moveRight = false
    local moveUp = false
    local moveDown = false

    local function onInputBegan(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.W then moveForward = true
        elseif input.KeyCode == Enum.KeyCode.S then moveBackward = true
        elseif input.KeyCode == Enum.KeyCode.A then moveLeft = true
        elseif input.KeyCode == Enum.KeyCode.D then moveRight = true
        elseif input.KeyCode == Enum.KeyCode.Space then moveUp = true
        elseif input.KeyCode == Enum.KeyCode.LeftShift then moveDown = true
        end
    end

    local function onInputEnded(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.W then moveForward = false
        elseif input.KeyCode == Enum.KeyCode.S then moveBackward = false
        elseif input.KeyCode == Enum.KeyCode.A then moveLeft = false
        elseif input.KeyCode == Enum.KeyCode.D then moveRight = false
        elseif input.KeyCode == Enum.KeyCode.Space then moveUp = false
        elseif input.KeyCode == Enum.KeyCode.LeftShift then moveDown = false
        end
    end

    local function updateFly()
        if not flying or not root or not root.Parent then
            stopFly()
            return
        end

        local camera = workspace.CurrentCamera
        local cameraCFrame = camera.CFrame

        local forward = cameraCFrame.LookVector
        local right = cameraCFrame.RightVector
        local up = Vector3.new(0, 1, 0)

        forward = Vector3.new(forward.X, 0, forward.Z).Unit
        right = Vector3.new(right.X, 0, right.Z).Unit

        local direction = Vector3.new(0, 0, 0)
        if moveForward then direction = direction + forward end
        if moveBackward then direction = direction - forward end
        if moveLeft then direction = direction - right end
        if moveRight then direction = direction + right end
        if moveUp then direction = direction + up end
        if moveDown then direction = direction - up end

        if direction.Magnitude > 0 then
            direction = direction.Unit * SETTINGS.flySpeed
        end

        bodyVelocity.Velocity = direction

        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    local inputBeganConnection = userInputService.InputBegan:Connect(onInputBegan)
    local inputEndedConnection = userInputService.InputEnded:Connect(onInputEnded)
    local heartbeatConnection = runService.Heartbeat:Connect(updateFly)

    flyConnections = {inputBeganConnection, inputEndedConnection, heartbeatConnection}
end

local function stopFly()
    flying = false
    state.noClip = false

    for _, conn in ipairs(flyConnections) do
        conn:Disconnect()
    end
    flyConnections = {}

    if bodyVelocity then bodyVelocity:Destroy() end

    local char = player.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
            humanoid.AutoRotate = true
        end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EbanatHubV2"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 600, 0, 260)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -130)
    mainFrame.BackgroundColor3 = Color3.fromRGB(12, 10, 26)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(120, 80, 255)
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    mainFrame.ZIndex = 1

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0, 200, 0, 40)
    titleLabel.Position = UDim2.new(0, 15, 0, 10)
    titleLabel.Text = "EBANAT HUB V2"
    titleLabel.TextColor3 = Color3.fromRGB(180, 140, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextScaled = true
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextStrokeTransparency = 0.2
    titleLabel.TextStrokeColor3 = Color3.fromRGB(120, 0, 255)
    titleLabel.Parent = mainFrame
    titleLabel.ZIndex = 3

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 34, 0, 34)
    closeBtn.Position = UDim2.new(1, -44, 0, 10)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✖"
    closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = mainFrame
    closeBtn.ZIndex = 3
    closeBtn.MouseButton1Click:Connect(function()
        stopFly()
        screenGui:Destroy()
    end)

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 34, 0, 34)
    minimizeBtn.Position = UDim2.new(1, -84, 0, 10)
    minimizeBtn.BackgroundTransparency = 1
    minimizeBtn.Text = "—"
    minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
    minimizeBtn.TextScaled = true
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Parent = mainFrame
    minimizeBtn.ZIndex = 3
    minimizeBtn.MouseButton1Click:Connect(function()
        state.isMinimized = not state.isMinimized
        local targetSize = state.isMinimized and UDim2.new(0, 600, 0, 45) or UDim2.new(0, 600, 0, 260)
        tweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = targetSize}):Play()
        for _, child in ipairs(mainFrame:GetChildren()) do
            if child ~= titleLabel and child ~= closeBtn and child ~= minimizeBtn then
                child.Visible = not state.isMinimized
            end
        end
    end)

    local dragButton = Instance.new("TextButton")
    dragButton.Size = UDim2.new(0, 200, 0, 40)
    dragButton.Position = UDim2.new(0, 0, 0, 0)
    dragButton.BackgroundTransparency = 1
    dragButton.Text = ""
    dragButton.Parent = mainFrame
    dragButton.ZIndex = 2

    local dragging = false
    local dragStart, startPos
    dragButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(0, 430, 0, 36)
    tabFrame.Position = UDim2.new(0, 15, 0, 55)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Parent = mainFrame
    tabFrame.ZIndex = 2

    local categories = {
        {name = "ОСНОВНЫЕ", color = Color3.fromRGB(80, 200, 255)},
        {name = "ИГРОК", color = Color3.fromRGB(255, 200, 80)},
        {name = "РАЗНОЕ", color = Color3.fromRGB(200, 80, 255)},
        {name = "ЭКСТРА", color = Color3.fromRGB(255, 50, 50)}
    }

    local currentCategory = 1
    local categoryButtons = {}
    local contentFrames = {}

    for i, cat in ipairs(categories) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(0.25, -4, 1, 0)
        tabBtn.Position = UDim2.new((i-1)*0.25, 2, 0, 0)
        tabBtn.Text = cat.name
        tabBtn.BackgroundColor3 = (i == currentCategory) and cat.color or Color3.fromRGB(35, 30, 55)
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabBtn.TextScaled = true
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.BorderSizePixel = 0
        tabBtn.BackgroundTransparency = (i == currentCategory) and 0.2 or 0.4
        tabBtn.Parent = tabFrame
        tabBtn.ZIndex = 3

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 8)
        tabCorner.Parent = tabBtn

        local contentFrame = Instance.new("ScrollingFrame")
        contentFrame.Size = UDim2.new(0, 430, 0, 145)
        contentFrame.Position = UDim2.new(0, 15, 0, 95)
        contentFrame.BackgroundTransparency = 1
        contentFrame.BorderSizePixel = 0
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
        contentFrame.ScrollBarThickness = 4
        contentFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 80, 255)
        contentFrame.ScrollBarImageTransparency = 0.4
        contentFrame.Parent = mainFrame
        contentFrame.ZIndex = 2
        contentFrame.Visible = (i == currentCategory)
        contentFrames[i] = contentFrame

        local gridLayout = Instance.new("UIGridLayout")
        gridLayout.CellSize = UDim2.new(0, 130, 0, 42)
        gridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
        gridLayout.FillDirection = Enum.FillDirection.Horizontal
        gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
        gridLayout.Parent = contentFrame

        tabBtn.MouseButton1Click:Connect(function()
            currentCategory = i
            for j, btn in ipairs(categoryButtons) do
                btn.BackgroundColor3 = (j == i) and categories[j].color or Color3.fromRGB(35, 30, 55)
                btn.BackgroundTransparency = (j == i) and 0.2 or 0.4
            end
            for j, frame in ipairs(contentFrames) do
                frame.Visible = (j == i)
            end
        end)

        categoryButtons[i] = tabBtn
    end

    local allButtons = {
        {cat = 1, name = "💰 Auto-Farm", key = "farmMode"},
        {cat = 1, name = "👁️ ESP", key = "espMode"},
        {cat = 1, name = "🎯 Aimbot", key = "aimbotMode"},
        {cat = 1, name = "✈️ Fly", key = "flyMode"},
        {cat = 2, name = "🏃 Speed Hack", key = "speedHack"},
        {cat = 2, name = "🦘 Jump Power", key = "jumpPower"},
        {cat = 2, name = "🧱 No-Clip", key = "noClip"},
        {cat = 2, name = "🏆 God Mode", key = "godMode"},
        {cat = 3, name = "🎁 Auto-Collect", key = "autoCollect"},
        {cat = 3, name = "🔄 Auto-Server-Hop", key = "autoServerHop"},
        {cat = 3, name = "🛡️ Anti-Ban", key = "antiBan"},
        {cat = 4, name = "🔪 Убить Мардера", key = "killMurderer"},
        {cat = 4, name = "🔫 Убить Шерифа", key = "killSheriff"},
    }

    local function handleKill(key)
        if key == "killMurderer" then
            local target = getMurderer()
            if target then
                local success = killTarget(target, true)
                if success then
                    print("[EBANAT] Мардер уничтожен!")
                else
                    print("[EBANAT] Не удалось убить мардера!")
                end
            else
                print("[EBANAT] Мардер не найден или уже мёртв!")
            end
        elseif key == "killSheriff" then
            local target = getSheriff()
            if target then
                local success = killTarget(target, false)
                if success then
                    print("[EBANAT] Шериф уничтожен!")
                else
                    print("[EBANAT] Не удалось убить шерифа!")
                end
            else
                print("[EBANAT] Шериф не найден или уже мёртв!")
            end
        end
    end

    for _, btnData in ipairs(allButtons) do
        local contentFrame = contentFrames[btnData.cat]
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 130, 0, 42)
        btn.BackgroundColor3 = (btnData.key == "killMurderer" or btnData.key == "killSheriff") and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(30, 25, 50)
        btn.Text = btnData.name
        btn.TextColor3 = Color3.fromRGB(240, 240, 255)
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamSemibold
        btn.BorderSizePixel = 0
        btn.BackgroundTransparency = (btnData.key == "killMurderer" or btnData.key == "killSheriff") and 0.3 or 0.25
        btn.Parent = contentFrame
        btn.ZIndex = 3

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = btn

        btn.MouseEnter:Connect(function()
            tweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.05}):Play()
        end)
        btn.MouseLeave:Connect(function()
            tweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = (btnData.key == "killMurderer" or btnData.key == "killSheriff") and 0.3 or 0.25}):Play()
        end)

        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 14, 0, 14)
        indicator.Position = UDim2.new(1, -22, 0.5, -7)
        indicator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        indicator.BackgroundTransparency = 0.3
        indicator.BorderSizePixel = 2
        indicator.BorderColor3 = Color3.fromRGB(200, 200, 200)
        indicator.Parent = btn
        indicator.ZIndex = 4

        local indicatorCorner = Instance.new("UICorner")
        indicatorCorner.CornerRadius = UDim.new(1, 0)
        indicatorCorner.Parent = indicator

        local indicatorInner = Instance.new("Frame")
        indicatorInner.Size = UDim2.new(0, 8, 0, 8)
        indicatorInner.Position = UDim2.new(0.5, -4, 0.5, -4)
        indicatorInner.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        indicatorInner.BackgroundTransparency = 0.8
        indicatorInner.BorderSizePixel = 0
        indicatorInner.Parent = indicator
        indicatorInner.ZIndex = 5

        local indicatorInnerCorner = Instance.new("UICorner")
        indicatorInnerCorner.CornerRadius = UDim.new(1, 0)
        indicatorInnerCorner.Parent = indicatorInner

        btn.MouseButton1Click:Connect(function()
            local key = btnData.key
            
            if key == "killMurderer" or key == "killSheriff" then
                handleKill(key)
                return
            end
            
            state[key] = not state[key]
            local color = state[key] and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(100, 100, 100)
            indicator.BackgroundColor3 = color
            indicatorInner.BackgroundColor3 = color
            indicator.BorderColor3 = state[key] and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(200, 200, 200)
            tweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.5}):Play()
            wait(0.1)
            tweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.25}):Play()
            
            if key == "flyMode" then
                if state.flyMode then
                    startFly()
                else
                    stopFly()
                end
            end
        end)
    end

    local killBtn = Instance.new("TextButton")
    killBtn.Size = UDim2.new(0, 50, 0, 34)
    killBtn.Position = UDim2.new(1, -60, 0, 195)
    killBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    killBtn.BackgroundTransparency = 0.15
    killBtn.Text = "💀"
    killBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    killBtn.TextScaled = true
    killBtn.Font = Enum.Font.GothamBold
    killBtn.BorderSizePixel = 2
    killBtn.BorderColor3 = Color3.fromRGB(255, 0, 0)
    killBtn.Parent = mainFrame
    killBtn.ZIndex = 3

    local killCorner = Instance.new("UICorner")
    killCorner.CornerRadius = UDim.new(0, 10)
    killCorner.Parent = killBtn

    killBtn.MouseEnter:Connect(function()
        tweenService:Create(killBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.05}):Play()
    end)
    killBtn.MouseLeave:Connect(function()
        tweenService:Create(killBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.15}):Play()
    end)

    killBtn.MouseButton1Click:Connect(function()
        killBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        wait(0.1)
        killBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        stopFly()
        game:Shutdown()
    end)

    local killLabel = Instance.new("TextLabel")
    killLabel.Size = UDim2.new(0, 50, 0, 16)
    killLabel.Position = UDim2.new(1, -60, 0, 232)
    killLabel.Text = "KILL ALL"
    killLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    killLabel.BackgroundTransparency = 1
    killLabel.Font = Enum.Font.Gotham
    killLabel.TextScaled = true
    killLabel.Parent = mainFrame
    killLabel.ZIndex = 3

    return screenGui, mainFrame
end

local gui, mainFrame = createGUI()
mainFrame.BackgroundTransparency = 1
tweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.1}):Play()

local function esp()
    pcall(function()
        if not state.espMode then
            for _, plr in ipairs(players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    local highlight = plr.Character:FindFirstChild("ROCKET_ESP")
                    if highlight then highlight:Destroy() end
                end
            end
            return
        end
        for _, plr in ipairs(players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local highlight = plr.Character:FindFirstChild("ROCKET_ESP")
                local isAlive = isPlayerAlive(plr)
                local role = getPlayerRole(plr)
                local color = ESP_COLORS.INNOCENT
                if not isAlive then color = ESP_COLORS.DEAD
                elseif role == "MURDERER" then color = ESP_COLORS.MURDERER
                elseif role == "SHERIFF" then color = ESP_COLORS.SHERIFF
                end
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "ROCKET_ESP"
                    highlight.Parent = plr.Character
                    highlight.FillTransparency = 0.6
                    highlight.OutlineTransparency = 0.1
                end
                highlight.OutlineColor = color
                highlight.FillColor = color
                if role == "MURDERER" and isAlive then
                    highlight.FillTransparency = 0.4
                    highlight.OutlineTransparency = 0
                else
                    highlight.FillTransparency = 0.6
                    highlight.OutlineTransparency = 0.1
                end
            end
        end
    end)
end

local function speedHack()
    pcall(function()
        if player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = state.speedHack and SETTINGS.walkSpeed or 16
            end
        end
    end)
end

local function jumpPower()
    pcall(function()
        if player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.JumpPower = state.jumpPower and SETTINGS.jumpPower or 50
            end
        end
    end)
end

local function autoFarm()
    pcall(function()
        if not state.farmMode or isFarming then return end
        
        local currentTime = tick()
        if currentTime - lastFarmTime < SETTINGS.farmDelay then return end
        
        local char = player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        if #coinCache == 0 then
            updateCoinCache()
            return
        end
        
        local targetCoin = nil
        local minDist = math.huge
        local myPos = root.Position
        
        for i, coin in ipairs(coinCache) do
            if not coin.Parent or coin.Transparency >= 0.5 then
                table.remove(coinCache, i)
            else
                local dist = (coin.Position - myPos).Magnitude
                if dist < minDist then
                    minDist = dist
                    targetCoin = coin
                end
            end
        end
        
        if targetCoin then
            isFarming = true
            
            local oldCollide = {}
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    oldCollide[part] = part.CanCollide
                    part.CanCollide = false
                end
            end
            
            local targetPos = targetCoin.Position + Vector3.new(0, 3, 0)
            local distance = (targetPos - root.Position).Magnitude
            local speed = SETTINGS.farmSpeed
            local duration = math.max(distance / speed, 0.3)
            
            local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = tweenService:Create(root, tweenInfo, {CFrame = CFrame.new(targetPos)})
            tween:Play()
            tween.Completed:Wait()
            
            for part, collide in pairs(oldCollide) do
                if part and part.Parent then
                    part.CanCollide = collide
                end
            end
            
            firetouchinterest(root, targetCoin, 0)
            firetouchinterest(root, targetCoin, 1)
            
            local coinIndex = table.find(coinCache, targetCoin)
            if coinIndex then
                table.remove(coinCache, coinIndex)
            end
            
            lastFarmTime = tick()
            isFarming = false
        end
    end)
end

local function autoCollect()
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:find("Coin") or obj.Name:find("Money") or obj.Name:find("Gun") or obj.Name:find("Knife") or obj.Name:find("Weapon")) then
                if obj.Parent and obj.Transparency < 0.5 then
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 2, 0)
                        firetouchinterest(char.HumanoidRootPart, obj, 0)
                        firetouchinterest(char.HumanoidRootPart, obj, 1)
                        wait(0.05)
                    end
                end
            end
        end
    end)
end

local function aimbot()
    pcall(function()
        local target, minDist = nil, math.huge
        local myPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position or Vector3.new(0,0,0)
        for _, plr in ipairs(players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                if getPlayerRole(plr) == "MURDERER" and isPlayerAlive(plr) then
                    local dist = (plr.Character.HumanoidRootPart.Position - myPos).Magnitude
                    if dist < minDist then
                        minDist = dist
                        target = plr
                    end
                end
            end
        end
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local camera = workspace.CurrentCamera
            local targetPos = target.Character.HumanoidRootPart.Position
            camera.CFrame = CFrame.lookAt(camera
