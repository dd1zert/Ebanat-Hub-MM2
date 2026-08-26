local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EbanatHubV2"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 580, 0, 200)
mainFrame.Position = UDim2.new(0.5, -290, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 10, 26)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(120, 80, 255)
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 160, 0, 40)
title.Position = UDim2.new(0, 10, 0, 10)
title.Text = "EBANAT HUB V2"
title.TextColor3 = Color3.fromRGB(180, 140, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 10)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✖"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = mainFrame
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -75, 0, 10)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "—"
minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
minimizeBtn.TextScaled = true
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = mainFrame
local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 580, 0, 45) or UDim2.new(0, 580, 0, 200)
    mainFrame:TweenSize(targetSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    for _, child in ipairs(mainFrame:GetChildren()) do
        if child ~= title and child ~= closeBtn and child ~= minimizeBtn then
            child.Visible = not isMinimized
        end
    end
end)

local dragButton = Instance.new("TextButton")
dragButton.Size = UDim2.new(0, 170, 0, 40)
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
tabFrame.Size = UDim2.new(0, 390, 0, 30)
tabFrame.Position = UDim2.new(0, 180, 0, 10)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

local categories = {
    {name = "ОСНОВНЫЕ", color = Color3.fromRGB(80, 200, 255)},
    {name = "ИГРОК", color = Color3.fromRGB(255, 200, 80)},
    {name = "РАЗНОЕ", color = Color3.fromRGB(200, 80, 255)}
}

local currentCategory = 1
local categoryButtons = {}
local contentFrames = {}

for i, cat in ipairs(categories) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0.333, -4, 1, 0)
    tabBtn.Position = UDim2.new((i-1)*0.333, 2, 0, 0)
    tabBtn.Text = cat.name
    tabBtn.BackgroundColor3 = (i == currentCategory) and cat.color or Color3.fromRGB(35, 30, 55)
    tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabBtn.TextScaled = true
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.BorderSizePixel = 0
    tabBtn.BackgroundTransparency = (i == currentCategory) and 0.2 or 0.4
    tabBtn.Parent = tabFrame

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabBtn

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(0, 560, 0, 120)
    contentFrame.Position = UDim2.new(0, 10, 0, 50)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    contentFrame.Visible = (i == currentCategory)
    contentFrames[i] = contentFrame

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0, 130, 0, 35)
    grid.CellPadding = UDim2.new(0, 10, 0, 10)
    grid.FillDirection = Enum.FillDirection.Horizontal
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = contentFrame

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
    {cat = 1, name = "💰 Farm", key = "farm"},
    {cat = 1, name = "👁️ ESP", key = "esp"},
    {cat = 1, name = "🎯 Aimbot", key = "aimbot"},
    {cat = 1, name = "✈️ Fly", key = "fly"},
    {cat = 2, name = "🏃 Speed", key = "speed"},
    {cat = 2, name = "🦘 Jump", key = "jump"},
    {cat = 2, name = "🧱 NoClip", key = "noclip"},
    {cat = 2, name = "🏆 God", key = "god"},
    {cat = 3, name = "🎁 Collect", key = "collect"},
    {cat = 3, name = "🔄 Hop", key = "hop"},
    {cat = 3, name = "🛡️ AntiBan", key = "antiban"},
}

local states = {}
for _, btnData in ipairs(allButtons) do
    states[btnData.key] = false
end

for _, btnData in ipairs(allButtons) do
    local contentFrame = contentFrames[btnData.cat]
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 130, 0, 35)
    btn.Text = btnData.name
    btn.TextColor3 = Color3.fromRGB(240, 240, 255)
    btn.BackgroundColor3 = Color3.fromRGB(35, 30, 55)
    btn.BackgroundTransparency = 0.2
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Parent = contentFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 12, 0, 12)
    indicator.Position = UDim2.new(1, -18, 0.5, -6)
    indicator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    indicator.BackgroundTransparency = 0.3
    indicator.BorderSizePixel = 2
    indicator.BorderColor3 = Color3.fromRGB(200, 200, 200)
    indicator.Parent = btn

    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = indicator

    local indicatorInner = Instance.new("Frame")
    indicatorInner.Size = UDim2.new(0, 6, 0, 6)
    indicatorInner.Position = UDim2.new(0.5, -3, 0.5, -3)
    indicatorInner.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    indicatorInner.BackgroundTransparency = 0.8
    indicatorInner.BorderSizePixel = 0
    indicatorInner.Parent = indicator

    local indicatorInnerCorner = Instance.new("UICorner")
    indicatorInnerCorner.CornerRadius = UDim.new(1, 0)
    indicatorInnerCorner.Parent = indicatorInner

    btn.MouseButton1Click:Connect(function()
        local key = btnData.key
        states[key] = not states[key]
        local color = states[key] and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(100, 100, 100)
        indicator.BackgroundColor3 = color
        indicatorInner.BackgroundColor3 = color
        indicator.BorderColor3 = states[key] and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(200, 200, 200)
    end)
end

local killBtn = Instance.new("TextButton")
killBtn.Size = UDim2.new(0, 50, 0, 30)
killBtn.Position = UDim2.new(1, -60, 0, 160)
killBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
killBtn.BackgroundTransparency = 0.15
killBtn.Text = "💀"
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
    game:Shutdown()
end)

local killLabel = Instance.new("TextLabel")
killLabel.Size = UDim2.new(0, 50, 0, 14)
killLabel.Position = UDim2.new(1, -60, 0, 180)
killLabel.Text = "KILL"
killLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
killLabel.BackgroundTransparency = 1
killLabel.Font = Enum.Font.Gotham
killLabel.TextScaled = true
killLabel.Parent = mainFrame

print("[EBANAT HUB V2] Загружен!")
