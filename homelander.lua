-- Visible Laser Test
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local head = character:WaitForChild("Head")

local laserStandby = false
local laserConnection

local function startLaser()
    if laserConnection then return end

    laserConnection = RunService.Heartbeat:Connect(function()
        if not laserStandby then return end

        local direction = (mouse.Hit.p - head.Position).Unit

        head.CFrame = CFrame.new(head.Position, head.Position + direction)

        for i = -1, 1, 2 do
            local laser = Instance.new("Part")
            laser.Size = Vector3.new(0.3,0.3,150)
            laser.Color = Color3.fromRGB(255, 80, 0)
            laser.Material = Enum.Material.Neon
            laser.Anchored = true
            laser.CanCollide = false
            laser.CFrame = CFrame.new(head.Position, head.Position + direction) * CFrame.new(i*0.3, 0, -75)
            laser.Parent = workspace
            Debris:AddItem(laser, 0.15)

            -- Damage
            local result = workspace:Raycast(head.Position, direction * 300)
            if result and result.Instance.Parent:FindFirstChild("Humanoid") then
                result.Instance.Parent.Humanoid:TakeDamage(25)
            end
        end
    end)
end

local function stopLaser()
    if laserConnection then
        laserConnection:Disconnect()
        laserConnection = nil
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.R then 
        laserStandby = not laserStandby
        print("Laser Standby: " .. (laserStandby and "ON" or "OFF"))
        if laserStandby then startLaser() else stopLaser() end
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and laserStandby then
        startLaser()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        stopLaser()
    end
end)

print("✅ Laser Test Loaded! R = Standby | Hold LMB = Fire")
