-- Flight + Laser Test
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

local function fireLaser()
    if not laserStandby then return end

    local laser = Instance.new("Part")
    laser.Size = Vector3.new(0.5,0.5,90)
    laser.Color = Color3.fromRGB(255, 0, 0)
    laser.Material = Enum.Material.Neon
    laser.Anchored = true
    laser.CanCollide = false
    laser.CFrame = head.CFrame * CFrame.new(0,0,-45)
    laser.Parent = workspace
    Debris:AddItem(laser, 0.25)

    print("Laser Fired!")
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then toggleFlight()
    elseif input.KeyCode == Enum.KeyCode.R then 
        laserStandby = not laserStandby
        print("Laser Standby: " .. (laserStandby and "ON" or "OFF"))
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        fireLaser()
    end
end)

print("✅ Flight + Laser Test Loaded! F = Flight | R = Laser Standby | LMB = Fire")
