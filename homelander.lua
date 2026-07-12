local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local flying = false
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

        RunService:BindToRenderStep("FlyTest", Enum.RenderPriority.Camera.Value, function()
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

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then toggleFlight() end
end)

print("✅ Minimal Flight Test Loaded! Press F")
