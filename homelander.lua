-- Simple X-Ray Script (Press X to toggle)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local xrayActive = false
local xrayParts = {}

local function toggleXray()
    xrayActive = not xrayActive
    if xrayActive then
        xrayParts = {}
        local rootPos = root.Position
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Transparency < 1 and (obj.Position - rootPos).Magnitude < 200 then
                table.insert(xrayParts, obj)
                obj.Transparency = 0.7
            end
        end
    else
        for _, obj in pairs(xrayParts) do
            if obj and obj.Parent then
                obj.Transparency = 0
            end
        end
        xrayParts = {}
    end
end

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.X then
        toggleXray()
    end
end)

print("✅ Simple X-Ray Script Loaded! Press X to toggle.")
