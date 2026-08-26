local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EbanatHubV2"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 350)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 12, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(120, 80, 255)
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "EBANAT HUB V2"
title.TextColor3 = Color3.fromRGB(180, 140, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = mainFrame
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -50)
scrollFrame.Position = UDim2.new(0, 10, 0, 45)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 400)
scrollFrame.ScrollBarThickness = 4
scrollFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

local buttons = {
    "💰 Auto-Farm",
    "👁️ ESP",
    "🎯 Aimbot",
    "✈️ Fly",
    "🏃 Speed Hack",
    "🦘 Jump Power",
    "🧱 No-Clip",
    "🏆 God Mode",
    "🎁 Auto-Collect",
    "🔄 Auto-Server-Hop"
}

for _, name in ipairs(buttons) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(240, 240, 255)
    btn.BackgroundColor3 = Color3.fromRGB(35, 30, 55)
    btn.BackgroundTransparency = 0.2
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 16
    btn.BorderSizePixel = 0
    btn.Parent = scrollFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 14, 0, 14)
    indicator.Position = UDim2.new(1, -22, 0.5, -7)
    indicator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    indicator.BackgroundTransparency = 0.3
    indicator.BorderSizePixel = 2
    indicator.BorderColor3 = Color3.fromRGB(200, 200, 200)
    indicator.Parent = btn
    
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
    
    local indicatorInnerCorner = Instance.new("UICorner")
    indicatorInnerCorner.CornerRadius = UDim.new(1, 0)
    indicatorInnerCorner.Parent = indicatorInner
    
    local isActive = false
    btn.MouseButton1Click:Connect(function()
        isActive = not isActive
        local color = isActive and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(100, 100, 100)
        indicator.BackgroundColor3 = color
        indicatorInner.BackgroundColor3 = color
        indicator.BorderColor3 = isActive and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(200, 200, 200)
    end)
end

print("[EBANAT HUB V2] Загружен!")
