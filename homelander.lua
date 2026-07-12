-- === FINAL HOMELANDER FE SCRIPT ===
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
local hovering = false
local flySpeed = 130
local xrayActive = false
local laserStandby = false
local locatorActive = false
local grabMode = false
local grabbed = nil
local espLabels = {}

-- Draggable GUI (same)
local sg = Instance.new("ScreenGui")
sg.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 340)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(15,15,15)
frame.BorderSizePixel = 0
frame.Parent = sg

-- Dragging (same)
-- [Paste dragging code]

-- Title, Status, Keybinds, Close (same)
local title = Instance.new("TextLabel")
title.Text = "🦸 HOMELANDER"
title.Size = UDim2.new(1,0,0,40)
title.BackgroundColor3 = Color3.fromRGB(139,0,0)
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.Parent = frame

local laserStatus = Instance.new("TextLabel")
laserStatus.Text = "Laser Standby: OFF"
laserStatus.Size = UDim2.new(1,-20,0,30)
laserStatus.Position = UDim2.new(0,10,0,50)
laserStatus.BackgroundTransparency = 1
laserStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
laserStatus.Font = Enum.Font.GothamBold
laserStatus.Parent = frame

local info = Instance.new("TextLabel")
info.Text = "F = Fast Flight\nH = Hover Mode\nX = X-Ray\nR = Laser Standby\nLMB = Fire Laser\nQ = Punch\nG = Super Strength\nC = Grab Player\nL = Player Locator"
info.Size = UDim2.new(1,-20,0,180)
info.Position = UDim2.new(0,10,0,90)
info.BackgroundTransparency = 1
info.TextColor3 = Color3.new(1,1,1)
info.TextXAlignment = Enum.TextXAlignment.Left
info.TextYAlignment = Enum.TextYAlignment.Top
info.Font = Enum.Font.Gotham
info.TextSize = 14
info.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0,30,0,30)
closeBtn.Position = UDim2.new(1,-35,0,5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

-- Hole Creation (same)
local holeDebounce = {}
local function createHole(pos, normal)
    local key = tostring(math.floor(pos.X)) .. tostring(math.floor(pos.Y))
    if holeDebounce[key] then return end
    holeDebounce[key] = true

    local hole = Instance.new("Part")
    hole.Shape = Enum.PartType.Cylinder
    hole.Size = Vector3.new(9, 0.5, 9)
    hole.CFrame = CFrame.new(pos, pos + normal) * CFrame.Angles(0,0,math.rad(90))
    hole.Color = Color3.fromRGB(30,30,30)
    hole.Material = Enum.Material.CrackedLava
    hole.CanCollide = false
    hole.Anchored = true
    hole.Parent = workspace
    Debris:AddItem(hole, 10)

    task.delay(10, function() holeDebounce[key] = nil end)
end

-- Flight
local flightTrack, bv, bg
local function toggleFlight()
    flying = not flying
    if flying then
        hovering = false
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://10921238421"
        flightTrack = humanoid:LoadAnimation(anim)
        flightTrack:Play()

        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e5,1e5,1e5)
        bv.Parent = root

        bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
        bg.Parent = root

        humanoid.PlatformStand = true

        for _, p in pairs(character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end

        RunService:BindToRenderStep("HomelanderFly", Enum.RenderPriority.Camera.Value, function(dt)
            if not flying then return end
            local cam = workspace.CurrentCamera
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end

            bv.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.new()
            bg.CFrame = cam.CFrame

            local ray = workspace:Raycast(root.Position, root.Velocity * dt * 1.5)
            if ray and ray.Instance.CanCollide and root.Velocity.Magnitude > 60 then
                createHole(ray.Position, ray.Normal)
            end
        end)
    else
        RunService:UnbindFromRenderStep("HomelanderFly")
        if flightTrack then flightTrack:Stop() end
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
        humanoid.PlatformStand = false

        for _, p in pairs(character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
end

-- Hover Mode
local function toggleHover()
    if not flying then return end
    hovering = not hovering
    if hovering then
        bv.Velocity = Vector3.new(0, 8, 0)
    else
        bv.Velocity = Vector3.new(0, 0, 0)
    end
end

-- X-Ray (same)
-- [Paste toggleXray]

-- Laser (same)
-- [Paste fireLaser]

-- Inputs (same)
-- [Paste inputs]

-- Infinite Health & Crash (same)
-- [Paste infinite health and crash]

print("✅ Final Homelander Script Loaded!")
