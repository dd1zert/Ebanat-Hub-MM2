local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local players = game:GetService("Players")
local teleportService = game:GetService("TeleportService")
local workspace = game:GetService("Workspace")

local SETTINGS = {
    walkSpeed = 50,
    jumpPower = 80,
    autoHopTime = 300,
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
    silentAim = false,
    antiBan = false,
    godMode = false,
    showMenu = true
}

local function getPlayerRole(plr)
    if not plr then return "INNOCENT" end
    
    -- Проверка через объекты в модели персонажа (САМЫЙ НАДЁЖНЫЙ СПОСОБ)
    if plr.Character then
        -- Ищем объекты с ролями
        for _, child in ipairs(plr.Character:GetChildren()) do
            local name = child.Name
            if name == "Murderer" or name == "Убийца" then
                return "MURDERER"
            elseif name == "Sheriff" or name == "Шериф" then
                return "SHERIFF"
            elseif name == "Innocent" or name == "Невиновный" then
                return "INNOCENT"
            end
        end
    end
    
    -- Проверка через теги в Humanoid
    if plr.Character then
        local humanoid = plr.Character:FindFirstChild("Humanoid")
        if humanoid then
            local roleTag = humanoid:FindFirstChild("RoleTag")
            if roleTag then
                local roleValue = roleTag.Value
                if roleValue == "Murderer" then
                    return "MURDERER"
                elseif roleValue == "Sheriff" then
                    return "SHERIFF"
                elseif roleValue == "Innocent" then
                    return "INNOCENT"
                end
            end
        end
    end
    
    -- Проверка через PlayerGui
    local playerGui = plr:FindFirstChild("PlayerGui")
    if playerGui then
        if playerGui:FindFirstChild("MurdererGUI") or playerGui:FindFirstChild("KillGUI") or playerGui:FindFirstChild("KnifeGUI") then
            return "MURDERER"
        end
        if playerGui:FindFirstChild("SheriffGUI") or playerGui:FindFirstChild("GunGUI") or playerGui:FindFirstChild("RevolverGUI") then
            return "SHERIFF"
        end
    end
    
    -- Проверка через оружие (как запасной вариант)
    if plr.Character then
        local tool = plr.Character:FindFirstChildOfClass("Tool")
        if tool then
            local toolName = tool.Name:lower()
            if toolName:find("knife") or toolName:find("нож") then
                return "MURDERER"
            elseif toolName:find("gun") or toolName:find("пистолет") or toolName:find("revolver") then
                return "SHERIFF"
            end
        end
    end
    
    -- Проверка через имя игрока (в некоторых версиях MM2)
    local name = plr.Name:lower()
    if name:find("murderer") or name:find("убийца") then
        return "MURDERER"
    elseif name:find("sheriff") or name:find("шериф") then
        return "SHERIFF"
    end
    
    return "INNOCENT"
end

local function isPlayerAlive(plr)
    if not plr or not plr.Character then return false end
    local humanoid = plr.Character:FindFirstChild("Humanoid")
    if not humanoid then return false end
    return humanoid.Health > 0
end

local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EbanatHubV2"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 420, 0, 520)
    mainFrame.Position = UDim2.new(0.5, -210, 0.5, -260)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 8, 20)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(0, 200, 255)
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1.05, 0, 1.05, 0)
    shadow.Position = UDim2.new(-0.025, 0, -0.025, 0)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316044015"
    shadow.ImageColor3 = Color3.fromRGB(0, 200, 255)
    shadow.ImageTransparency = 0.7
    shadow.Parent = mainFrame

    local gradientFrame = Instance.new("Frame")
    gradientFrame.Size = UDim2.new(1, 0, 1, 0)
    gradientFrame.BackgroundColor3 = Color3.fromRGB(15, 12, 30)
    gradientFrame.BackgroundTransparency = 0.7
    gradientFrame.BorderSizePixel = 0
    gradientFrame.Parent = mainFrame

    local uiGradient = Instance.new("UIGradient")
    uiGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 0, 120)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 80, 160)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 180, 200))
    })
    uiGradient.Rotation = 30
    uiGradient.Parent = gradientFrame

    local titleFrame = Instance.new("Frame")
    titleFrame.Size = UDim2.new(1, 0, 0, 60)
    titleFrame.Position = UDim2.new(0, 0, 0, 0)
    titleFrame.BackgroundTransparency = 1
    titleFrame.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.Text = "EBANAT HUB V2"
    titleLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextScaled = true
    titleLabel.TextStrokeTransparency = 0.2
    titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 100, 200)
    titleLabel.Parent = titleFrame

    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1.2, 0, 1.5, 0)
    glow.Position = UDim2.new(-0.1, 0, -0.25, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://1316044015"
    glow.ImageColor3 = Color3.fromRGB(0, 200, 255)
    glow.ImageTransparency = 0.7
    glow.Parent = titleLabel

    local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    tweenService:Create(glow, tweenInfo, {ImageTransparency = 0.3}):Play()

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 15)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = mainFrame
    closeBtn.MouseButton1Click:Connect(function()
        state.showMenu = not state.showMenu
        mainFrame.Visible = state.showMenu
    end)

    local dragButton = Instance.new("TextButton")
    dragButton.Size = UDim2.new(1, -80, 0, 60)
    dragButton.Position = UDim2.new(0, 0, 0, 0)
    dragButton.BackgroundTransparency = 1
    dragButton.Text = ""
    dragButton.Parent = mainFrame

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
    tabFrame.Size = UDim2.new(1, -20, 0, 40)
    tabFrame.Position = UDim2.new(0, 10, 0, 65)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Parent = mainFrame

    local categories = {
        {name = "⚡ БОЕВЫЕ", color = Color3.fromRGB(255, 80, 80)},
        {name = "🌀 УТИЛИТЫ", color = Color3.fromRGB(80, 200, 255)},
        {name = "💀 ЧИТЫ", color = Color3.fromRGB(200, 80, 255)},
        {name = "🎯 АИМ", color = Color3.fromRGB(255, 200, 80)}
    }

    local currentCategory = 1
    local categoryButtons = {}
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 1, -100)
    scrollFrame.Position = UDim2.new(0, 10, 0, 110)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 650)
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
    scrollFrame.ScrollBarImageTransparency = 0.5
    scrollFrame.Parent = mainFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = scrollFrame

    local allButtons = {
        {cat = 1, name = "💰 Auto-Farm", key = "farmMode"},
        {cat = 1, name = "🎁 Auto-Collect", key = "autoCollect"},
        {cat = 1, name = "🏆 God Mode", key = "godMode"},
        {cat = 2, name = "🔄 Auto-Server-Hop", key = "autoServerHop"},
        {cat = 2, name = "🧱 No-Clip", key = "noClip"},
        {cat = 2, name = "🏃 Speed Hack", key = "speedHack"},
        {cat = 2, name = "🦘 Jump Power", key = "jumpPower"},
        {cat = 3, name = "👁️ ESP (Роли)", key = "espMode"},
        {cat = 3, name = "🛡️ Anti-Ban", key = "antiBan"},
        {cat = 4, name = "🎯 Aimbot", key = "aimbotMode"},
        {cat = 4, name = "🤫 Silent Aim", key = "silentAim"},
    }

    local function updateButtons()
        for _, child in ipairs(scrollFrame:GetChildren()) do
            if child:IsA("TextButton") and child:GetAttribute("Category") then
                child.Visible = (child:GetAttribute("Category") == currentCategory)
            end
        end
    end

    for i, cat in ipairs(categories) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(0.25, -2, 1, 0)
        tabBtn.Position = UDim2.new((i-1)*0.25, 2, 0, 0)
        tabBtn.Text = cat.name
        tabBtn.BackgroundColor3 = (i == currentCategory) and cat.color or Color3.fromRGB(30, 25, 50)
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabBtn.TextScaled = true
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.BorderSizePixel = 1
        tabBtn.BorderColor3 = cat.color
        tabBtn.BackgroundTransparency = 0.3
        tabBtn.Parent = tabFrame

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 6)
        tabCorner.Parent = tabBtn

        tabBtn.MouseButton1Click:Connect(function()
            currentCategory = i
            for j, btn in ipairs(categoryButtons) do
                btn.BackgroundColor3 = (j == i) and categories[j].color or Color3.fromRGB(30, 25, 50)
            end
            updateButtons()
        end)

        categoryButtons[i] = tabBtn
    end

    for _, btnData in ipairs(allButtons) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 45)
        btn.BackgroundColor3 = Color3.fromRGB(25, 20, 45)
        btn.Text = btnData.name
        btn.TextColor3 = Color3.fromRGB(230, 230, 255)
        btn.TextSize = 18
        btn.Font = Enum.Font.GothamSemibold
        btn.BorderSizePixel = 0
        btn.BackgroundTransparency = 0.2
        btn.Parent = scrollFrame
        btn:SetAttribute("Category", btnData.cat)

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn

        btn.MouseEnter:Connect(function()
            tweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.05}):Play()
        end)
        btn.MouseLeave:Connect(function()
            tweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
        end)

        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 16, 0, 16)
        indicator.Position = UDim2.new(1, -30, 0.5, -8)
        indicator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        indicator.BackgroundTransparency = 0.5
        indicator.BorderSizePixel = 2
        indicator.BorderColor3 = Color3.fromRGB(200, 200, 200)
        indicator.Parent = btn

        local indicatorCorner = Instance.new("UICorner")
        indicatorCorner.CornerRadius = UDim.new(1, 0)
        indicatorCorner.Parent = indicator

        local indicatorInner = Instance.new("Frame")
        indicatorInner.Size = UDim2.new(0, 10, 0, 10)
        indicatorInner.Position = UDim2.new(0.5, -5, 0.5, -5)
        indicatorInner.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        indicatorInner.BackgroundTransparency = 0.8
        indicatorInner.BorderSizePixel = 0
        indicatorInner.Parent = indicator

        local indicatorInnerCorner = Instance.new("UICorner")
        indicatorInnerCorner.CornerRadius = UDim.new(1, 0)
        indicatorInnerCorner.Parent = indicatorInner

        btn.MouseButton1Click:Connect(function()
            local key = btnData.key
            state[key] = not state[key]
            local color = state[key] and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(100, 100, 100)
            indicator.BackgroundColor3 = color
            indicatorInner.BackgroundColor3 = color
            indicator.BorderColor3 = state[key] and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(200, 200, 200)
            tweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.4}):Play()
            wait(0.1)
            tweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.2}):Play()
        end)
    end

    local killBtn = Instance.new("TextButton")
    killBtn.Size = UDim2.new(1, -20, 0, 50)
    killBtn.Position = UDim2.new(0, 10, 0, 450)
    killBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    killBtn.BackgroundTransparency = 0.2
    killBtn.Text = "💀 УНИЧТОЖИТЬ ВСЁ (KILL ALL)"
    killBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    killBtn.TextScaled = true
    killBtn.Font = Enum.Font.GothamBold
    killBtn.BorderSizePixel = 2
    killBtn.BorderColor3 = Color3.fromRGB(255, 0, 0)
    killBtn.Parent = mainFrame

    local killCorner = Instance.new("UICorner")
    killCorner.CornerRadius = UDim.new(0, 8)
    killCorner.Parent = killBtn

    killBtn.MouseButton1Click:Connect(function()
        killBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        wait(0.1)
        killBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        game:Shutdown()
    end)

    wait(0.1)
    updateButtons()
    return screenGui, mainFrame
end

local gui, mainFrame = createGUI()
mainFrame.BackgroundTransparency = 1
tweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.1}):Play()

local function esp()
    pcall(function()
        if not state.espMode then
            for _, plr in ipairs(players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    local highlight = plr.Character:FindFirstChild("ROCKET_ESP")
                    if highlight then
                        highlight:Destroy()
                    end
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
                if not isAlive then
                    color = ESP_COLORS.DEAD
                elseif role == "MURDERER" then
                    color = ESP_COLORS.MURDERER
                elseif role == "SHERIFF" then
                    color = ESP_COLORS.SHERIFF
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
                if state.speedHack then
                    humanoid.WalkSpeed = SETTINGS.walkSpeed
                else
                    humanoid.WalkSpeed = 16
                end
            end
        end
    end)
end

local function jumpPower()
    pcall(function()
        if player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                if state.jumpPower then
                    humanoid.JumpPower = SETTINGS.jumpPower
                else
                    humanoid.JumpPower = 50
                end
            end
        end
    end)
end

local function autoFarm()
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:find("Coin") or obj.Name:find("Money") or obj.Name:find("Cash")) then
                if obj.Parent and obj.Transparency < 0.5 then
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                        firetouchinterest(char.HumanoidRootPart, obj, 0)
                        firetouchinterest(char.HumanoidRootPart, obj, 1)
                        wait(0.05)
                    end
                end
            end
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
        local target = nil
        local minDist = math.huge
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
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPos)
            local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Handle") then
                tool:Activate()
                wait(0.05)
                tool:Deactivate()
            end
        end
    end)
end

local function autoServerHop()
    pcall(function()
        teleportService:Teleport(game.PlaceId, player)
    end)
end

local function noClip()
    pcall(function()
        if state.noClip and player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        elseif player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end)
end

local function silentAim()
    pcall(function()
        if state.silentAim then
            local target = nil
            local minDist = math.huge
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
                local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Handle") then
                    tool:Activate()
                    wait(0.05)
                    tool:Deactivate()
                end
            end
        end
    end)
end

local function godMode()
    pcall(function()
        if state.godMode and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.MaxHealth = math.huge
                humanoid.Health = math.huge
                humanoid.BreakJointsOnDeath = false
            end
        elseif player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.MaxHealth = 100
                humanoid.Health = 100
                humanoid.BreakJointsOnDeath = true
            end
        end
    end)
end

local function antiBan()
end

local hopTimer = 0

runService.Heartbeat:Connect(function()
    pcall(function()
        if state.farmMode then autoFarm() end
        if state.autoCollect then autoCollect() end
        if state.aimbotMode then aimbot() end
        if state.espMode then esp() end
        if state.noClip then noClip() end
        speedHack()
        jumpPower()
        if state.silentAim then silentAim() end
        if state.godMode then godMode() end
        if state.antiBan then antiBan() end
        if state.autoServerHop then
            hopTimer = hopTimer + 0.016
            if hopTimer > SETTINGS.autoHopTime then
                hopTimer = 0
                autoServerHop()
            end
        end
    end)
end)

print("[EBANAT HUB V2] УСПЕШНО ЗАГРУЖЕН!")
print("[EBANAT HUB V2] ESP определяет роли по объектам в модели персонажа!")
