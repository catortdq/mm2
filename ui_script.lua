-- Roblox UI Script - Loadstring Compatible
-- Usage: loadstring(game:HttpGet("YOUR_URL_HERE"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Remove existing UI if present
local existingUI = PlayerGui:FindFirstChild("CustomUI")
if existingUI then
    existingUI:Destroy()
end

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui

-- Create Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Add rounded corners
local corners = Instance.new("UICorner")
corners.CornerRadius = UDim.new(0, 12)
corners.Parent = mainFrame

-- Add shadow
local shadow = Instance.new("UIStroke")
shadow.Color = Color3.fromRGB(0, 0, 0)
shadow.Thickness = 2
shadow.Transparency = 0.5
shadow.Parent = mainFrame

-- Create Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorners = Instance.new("UICorner")
titleCorners.CornerRadius = UDim.new(0, 12)
titleCorners.Parent = titleBar

-- Create Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 1, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Custom UI"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

-- Create Content Frame
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -50)
contentFrame.Position = UDim2.new(0, 10, 0, 45)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Create Sample Button
local button = Instance.new("TextButton")
button.Name = "ActionButton"
button.Size = UDim2.new(1, 0, 0, 40)
button.Position = UDim2.new(0, 0, 0, 0)
button.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
button.BorderSizePixel = 0
button.Text = "Click Me!"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 18
button.Font = Enum.Font.GothamSemibold
button.Parent = contentFrame

local buttonCorners = Instance.new("UICorner")
buttonCorners.CornerRadius = UDim.new(0, 8)
buttonCorners.Parent = button

-- Button hover effect
button.MouseEnter:Connect(function()
    button.BackgroundColor3 = Color3.fromRGB(100, 149, 237)
end)

button.MouseLeave:Connect(function()
    button.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
end)

-- Button click action - Equip fake knife
button.MouseButton1Click:Connect(function()
    if tool then
        tool.Parent = lp.Character
        print("Fake Knife equipped!")
    end
end)

-- Create Close Button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 16
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = titleBar

local closeCorners = Instance.new("UICorner")
closeCorners.CornerRadius = UDim.new(0, 6)
closeCorners.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Make UI draggable
local dragToggle = nil
local dragSpeed = 0.25
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1) then
        dragToggle = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if (input.UserInputState == Enum.UserInputState.End) then
                dragToggle = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement) then
        if (dragToggle and startPos) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end
end)

print("UI Loaded Successfully!")

-- Fake Knife Script for MM2
local lp = game.Players.LocalPlayer
local tool
local handle
local knife

local animation1 = Instance.new("Animation")
animation1.AnimationId = "rbxassetid://2467567750"
local animation2 = Instance.new("Animation")
animation2.AnimationId = "rbxassetid://1957890538"
local anims = {animation1, animation2}

tool = Instance.new("Tool")
tool.Name = "Fake Knife"
tool.Grip = CFrame.new(0, -1.16999984, 0.0699999481, 1, 0, 0, 0, 1, 0, 0, 0, 1)
tool.GripForward = Vector3.new(-0, -0, -1)
tool.GripPos = Vector3.new(0, -1.17, 0.0699999)
tool.GripRight = Vector3.new(1, 0, 0)
tool.GripUp = Vector3.new(0, 1, 0)

handle = Instance.new("Part")
handle.Size = Vector3.new(0.310638815, 3.42103457, 1.08775854)
handle.Name = "Handle"
handle.Transparency = 1
handle.Parent = tool
tool.Parent = lp.Backpack

knife = lp.Character:WaitForChild("KnifeDisplay")
knife.Massless = true

lp:GetMouse().Button1Down:Connect(function()
    if tool and tool.Parent == lp.Character then
        local an = lp.Character.Humanoid:LoadAnimation(anims[math.random(1, 2)])
        an:Play()
    end
end)

local aa = Instance.new("Attachment")
local ba = Instance.new("Attachment", handle)
aa.Parent = knife

local hinge = Instance.new("HingeConstraint")
hinge.Attachment0 = aa
hinge.Attachment1 = ba
hinge.Parent = knife
hinge.LimitsEnabled = true
hinge.LowerAngle = 0
hinge.Restitution = 0
hinge.UpperAngle = 0

for _, v in pairs(lp.Character:WaitForChild("UpperTorso"):GetChildren()) do
    if v:IsA("Weld") and v.Part1 == knife then
        v:Destroy()
        break
    end
end

game:GetService("RunService").Heartbeat:Connect(function()
    setsimulationradius(1/0, 1/0)
    if tool.Parent == lp.Character then
        knife.CFrame = handle.CFrame
    elseif lp.Character and knife then
        knife.CFrame = lp.Character:WaitForChild("UpperTorso").CFrame * CFrame.new(-0.200027466, -0.399999619, 0.5, 3.22982669e-05, -0.707153201, 0.707060337, 1.33886933e-05, 0.707060337, 0.707153141, -1, -1.33812428e-05, 3.22982669e-05)
    end
end)
