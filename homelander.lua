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

-- Draggable GUI
local sg = Instance.new("ScreenGui")
sg.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 340)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(15,15,15)
frame.BorderSizePixel = 0
frame.Parent = sg

-- Dragging
local dragging = false
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then update(input) end
end)

-- Title
local title = Instance.new("TextLabel")
title.Text = "🦸 HOMELANDER"
title.Size = UDim2.new(1,0,0,40)
title.BackgroundColor3 = Color3.fromRGB(139,0,0)
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- Laser Status
local laserStatus = Instance.new("TextLabel")
laserStatus.Text = "Laser Standby: OFF"
laserStatus.Size = UDim2.new(1,-20,0,30)
laserStatus.Position = UDim2.new(0,10,0,50)
laserStatus.BackgroundTransparency = 1
laserStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
laserStatus.Font = Enum.Font.GothamBold
laserStatus.Parent = frame

-- Keybinds
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

-- Hole Creation
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

        root.Velocity = Vector3.new(0, 110, 0)
        wait(0.5)

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

-- X-Ray
local xrayParts = {}
local function toggleXray()
    xrayActive = not xrayActive
    if xrayActive then
        xrayParts = {}
        local rootPos = root.Position
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Transparency < 1 and (obj.Position - rootPos).Magnitude < 150 then
                table.insert(xrayParts, obj)
                obj.Transparency = 0.7
            end
        end
    else
        for _, obj in pairs(xrayParts) do
            if obj and obj.Parent then obj.Transparency = 0 end
        end
        xrayParts = {}
    end
end

-- Laser
local laserStartTime = 0
local function fireLaser()
    if not laserStandby then return end

    head.CFrame = CFrame.new(head.Position, workspace.CurrentCamera.CFrame.Position)

    local chargeTime = tick() - laserStartTime
    local damage = chargeTime > 7 and 200 or 100
    local size = chargeTime > 7 and Vector3.new(1,1,120) or Vector3.new(0.5,0.5,90)

    local laser = Instance.new("Part")
    laser.Size = size
    laser.Color = Color3.fromRGB(255, 0, 0)
    laser.Material = Enum.Material.Neon
    laser.Anchored = true
    laser.CanCollide = false
    laser.CFrame = head.CFrame * CFrame.new(0,0,-size.Z/2)
    laser.Parent = workspace
    Debris:AddItem(laser, 0.3)

    local result = workspace:Raycast(head.Position, head.CFrame.LookVector * 300)
    if result and result.Instance.Parent:FindFirstChild("Humanoid") then
        local hum = result.Instance.Parent.Humanoid
        hum:TakeDamage(damage)
        if hum.Health <= 0 then
            hum:ChangeState(Enum.HumanoidStateType.Ragdoll)
        end
    end
end

-- Punch
local function superPunch()
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://522635514"
    humanoid:LoadAnimation(anim):Play()

    local punchPos = root.Position
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character then
            local targetRoot = v.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local dist = (targetRoot.Position - punchPos).Magnitude
                if dist < 15 then
                    local hum = v.Character:FindFirstChild("Humanoid")
                    if hum then
                        local damage = dist < 8 and 100 or 30
                        hum:TakeDamage(damage)
                        local force = (targetRoot.Position - punchPos).Unit * 120 + Vector3.new(0, 50, 0)
                        targetRoot.Velocity = force
                        if dist < 10 then
                            hum:ChangeState(Enum.HumanoidStateType.Ragdoll)
                            task.delay(2, function() if hum then hum:ChangeState(Enum.HumanoidStateType.Physics) end end)
                        end
                    end
                end
            end
        end
    end
end

-- Super Strength
local superStrengthActive = false
local function superStrengthThrow()
    superStrengthActive = not superStrengthActive
    print("Super Strength: " .. (superStrengthActive and "ON" or "OFF"))
end

-- Grab
local function toggleGrab()
    if grabbed then
        grabbed = nil
        print("Dropped player")
    else
        grabMode = true
        print("Grab Mode ON - Click a player")
    end
end

-- Inputs
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then toggleFlight()
    elseif input.KeyCode == Enum.KeyCode.H then toggleHover()
    elseif input.KeyCode == Enum.KeyCode.X then toggleXray()
    elseif input.KeyCode == Enum.KeyCode.R then 
        laserStandby = not laserStandby
        laserStatus.Text = "Laser Standby: " .. (laserStandby and "ON" or "OFF")
        laserStatus.TextColor3 = laserStandby and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 80, 80)
        if laserStandby then laserStartTime = tick() end
    elseif input.KeyCode == Enum.KeyCode.Q then superPunch()
    elseif input.KeyCode == Enum.KeyCode.G then superStrengthThrow()
    elseif input.KeyCode == Enum.KeyCode.C then toggleGrab()
    elseif input.KeyCode == Enum.KeyCode.L then toggleLocator()
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if grabMode then
            local mouse = player:GetMouse()
            local target = mouse.Target
            if target and target.Parent:FindFirstChild("Humanoid") then
                grabbed = target.Parent
                grabMode = false
                print("Grabbed " .. grabbed.Name)
            end
        elseif superStrengthActive then
            local mouse = player:GetMouse()
            local target = mouse.Target
            if target then
                local rootTarget = target.Parent:FindFirstChild("HumanoidRootPart") or target
                if rootTarget then
                    local dir = (rootTarget.Position - root.Position).Unit
                    rootTarget.Velocity = dir * 150 + Vector3.new(0, 50, 0)
                    if target.Parent:FindFirstChild("Humanoid") then
                        target.Parent.Humanoid:TakeDamage(40)
                    end
                end
            end
        else
            fireLaser()
        end
    end
end)

-- Infinite Health
humanoid.HealthChanged:Connect(function()
    humanoid.Health = humanoid.MaxHealth
end)

-- Flying Collision Kill with Red Smoke
RunService.Heartbeat:Connect(function(dt)
    if flying and root.Velocity.Magnitude > 80 then
        local ray = workspace:Raycast(root.Position - root.Velocity * dt, root.Velocity * dt * 2)
        if ray and ray.Instance.Parent:FindFirstChild("Humanoid") then
            local targetChar = ray.Instance.Parent
            local hum = targetChar:FindFirstChild("Humanoid")
            if hum then
                hum:TakeDamage(1000)
                
                -- Red Smoke
                for i = 1, 8 do
                    local smoke = Instance.new("Part")
                    smoke.Size = Vector3.new(2,2,2)
                    smoke.Color = Color3.fromRGB(255, 0, 0)
                    smoke.Material = Enum.Material.Neon
                    smoke.Transparency = 0.4
                    smoke.Anchored = true
                    smoke.CanCollide = false
                    smoke.Position = targetChar.HumanoidRootPart.Position + Vector3.new(math.random(-3,3), math.random(0,5), math.random(-3,3))
                    smoke.Parent = workspace
                    Debris:AddItem(smoke, 3)
                end
                
                targetChar:Destroy()
            end
        end
    end
end)

-- Crash
RunService.Heartbeat:Connect(function()
    if (flying or hovering) and root.Velocity.Magnitude > 100 then
        local ray = workspace:Raycast(root.Position, Vector3.new(0,-15,0))
        if ray and ray.Distance < 12 then
            local crack = Instance.new("Part")
            crack.Size = Vector3.new(15,0.6,15)
            crack.Color = Color3.fromRGB(60,60,60)
            crack.Material = Enum.Material.CrackedLava
            crack.Position = ray.Position
            crack.Anchored = true
            crack.Parent = workspace
            Debris:AddItem(crack, 8)
            if flying then toggleFlight() else toggleHover() end
        end
    end
end)

print("✅ Final Homelander Script Loaded!")
