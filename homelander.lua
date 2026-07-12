local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local head = character:WaitForChild("Head")
local root = character:WaitForChild("HumanoidRootPart")

local flying = false
local xrayActive = false
local laserStandby = false

local sg = Instance.new("ScreenGui")
sg.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 160)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(15,15,15)
frame.Parent = sg

local title = Instance.new("TextLabel")
title.Text = "HOMELANDER"
title.Size = UDim2.new(1,0,0,40)
title.BackgroundColor3 = Color3.fromRGB(139,0,0)
title.TextColor3 = Color3.new(1,1,1)
title.Parent = frame

local laserStatus = Instance.new("TextLabel")
laserStatus.Text = "Laser: OFF"
laserStatus.Size = UDim2.new(1,-20,0,30)
laserStatus.Position = UDim2.new(0,10,0,50)
laserStatus.BackgroundTransparency = 1
laserStatus.TextColor3 = Color3.fromRGB(255,80,80)
laserStatus.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0,30,0,30)
closeBtn.Position = UDim2.new(1,-35,0,5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

local function toggleFlight()
    flying = not flying
    print("Flight: " .. (flying and "ON" or "OFF"))
end

local function toggleXray()
    xrayActive = not xrayActive
    print("X-Ray: " .. (xrayActive and "ON" or "OFF"))
end

local function fireLaser()
    if not laserStandby then return end
    print("Laser Fired!")
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then toggleFlight()
    elseif input.KeyCode == Enum.KeyCode.X then toggleXray()
    elseif input.KeyCode == Enum.KeyCode.R then 
        laserStandby = not laserStandby
        laserStatus.Text = "Laser: " .. (laserStandby and "ON" or "OFF")
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        fireLaser()
    end
end)

print("✅ Minimal Test Loaded!")
