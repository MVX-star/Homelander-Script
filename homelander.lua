-- Flight + Improved Laser
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
local laserStandby = false
local bv, bg
local laserConnection

local function toggleFlight()
    flying = not flying
    if flying then
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e5,1e5,1e5)
        bv.Parent = root

        bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
        bg.Parent = root

        humanoid.PlatformStand = true

        RunService:BindToRenderStep("FlyTest", Enum.RenderPriority.Camera.Value, function(dt)
            if not flying then return end
            local cam = workspace.CurrentCamera
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end

            bv.Velocity = dir.Magnitude > 0 and dir.Unit * 100 or Vector3.new()
            bg.CFrame = cam.CFrame
        end)
    else
        RunService:UnbindFromRenderStep("FlyTest")
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
        humanoid.PlatformStand = false
    end
end

local function startLaser()
    if laserConnection then return end

    laserConnection = RunService.Heartbeat:Connect(function()
        if not laserStandby then return end

        -- Two lasers
        for i = -1, 1, 2 do
            local laser = Instance.new("Part")
            laser.Size = Vector3.new(0.2,0.2,60)
            laser.Color = Color3.fromRGB(255, 0, 0)
            laser.Material = Enum.Material.Neon
            laser.Anchored = true
            laser.CanCollide = false
            laser.CFrame = head.CFrame * CFrame.new(i*0.3, 0, -30)
            laser.Parent = workspace
            Debris:AddItem(laser, 0.1)
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
    if input.KeyCode == Enum.KeyCode.F then toggleFlight()
    elseif input.KeyCode == Enum.KeyCode.R then 
        laserStandby = not laserStandby
        print("Laser Standby: " .. (laserStandby and "ON" or "OFF"))
        if laserStandby then startLaser() else stopLaser() end
    end
end)

print("✅ Flight + Continuous Laser Test Loaded!")
print("F = Flight | R = Laser Standby")
