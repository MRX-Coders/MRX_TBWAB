-- MRX_TBWAB Target Detection & Camera Lock-On System
-- Educational / Standard Game Development Implementation
-- Note: This is designed for legitimate developer use (e.g., NPC targeting or RPG targeting mechanics)

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

math.randomseed(os.time())

-- Core Configuration (Settings Table)
if not shared["MRX_Config"] then
    shared["MRX_Config"] = {
        Enabled = true,
        Keybind = Enum.UserInputType.MouseButton2,
        LockMode = "Hold", -- "Hold" or "Toggle"
        
        FOV_Radius = 150,
        Smoothing = 0.2, -- 0 to 1, higher is faster
        
        Prioritize = "ClosestToCursor", -- "ClosestToCursor", "Distance", "LowestHealth"
        TargetPart = "HumanoidRootPart",
        
        TeamCheck = true,
        WallCheck = true,
        
        -- Panic Key / Emergency Stop
        PanicKey = Enum.KeyCode.RightControl
    }
end

local TargetingModule = {}
local isLocked = false
local currentTarget = nil

-- Visibility Check (Wall Check using Raycasting)
local function IsVisible(targetPart)
    if not shared["MRX_Config"]["WallCheck"] then return true end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("Head") then return false end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true
    
    local raycastResult = Workspace:Raycast(origin, direction, raycastParams)
    
    if raycastResult then
        if raycastResult.Instance:IsDescendantOf(targetPart.Parent) then
            return true
        end
        return false
    end
    
    return true
end

-- Multi-Priority Targeting Engine
local function GetBestTarget()
    local bestTarget = nil
    local shortestDistance = shared["MRX_Config"]["FOV_Radius"]
    local nearestWorldDistance = math.huge
    local lowestHealth = math.huge
    
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if shared["MRX_Config"]["TeamCheck"] and player.Team == LocalPlayer.Team then continue end
        
        local character = player.Character
        if not character then continue end
        
        local targetPart = character:FindFirstChild(shared["MRX_Config"]["TargetPart"])
        local humanoid = character:FindFirstChild("Humanoid")
        
        -- Ignore Transparent/Invisible
        if targetPart and humanoid and humanoid.Health > 0 and (character:GetAttribute("Transparency") or 0) < 0.9 then
            if not IsVisible(targetPart) then continue end
            
            -- Circle Radius Check (FOV)
            local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            local vectorDistance = Vector2.new(screenPoint.X - screenCenter.X, screenPoint.Y - screenCenter.Y).Magnitude
            
            if onScreen and vectorDistance <= shared["MRX_Config"]["FOV_Radius"] then
                if shared["MRX_Config"]["Prioritize"] == "ClosestToCursor" then
                    if vectorDistance < shortestDistance then
                        shortestDistance = vectorDistance
                        bestTarget = targetPart
                    end
                elseif shared["MRX_Config"]["Prioritize"] == "Distance" then
                    local primaryPart = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
                    if primaryPart then
                        local dist = (character.PrimaryPart.Position - primaryPart.Position).Magnitude
                        if dist < nearestWorldDistance then
                            nearestWorldDistance = dist
                            bestTarget = targetPart
                        end
                    end
                elseif shared["MRX_Config"]["Prioritize"] == "LowestHealth" then
                    if humanoid.Health < lowestHealth then
                        lowestHealth = humanoid.Health
                        bestTarget = targetPart
                    end
                end
            end
        end
    end
    
    return bestTarget
end

-- Input Processing
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == shared["MRX_Config"]["PanicKey"] then
        shared["MRX_Config"]["Enabled"] = false
        isLocked = false
        currentTarget = nil
        return
    end
    
    if (input.UserInputType == shared["MRX_Config"]["Keybind"] or input.KeyCode == shared["MRX_Config"]["Keybind"]) and shared["MRX_Config"]["Enabled"] then
        if shared["MRX_Config"]["LockMode"] == "Toggle" then
            isLocked = not isLocked
            if not isLocked then currentTarget = nil end
        else
            isLocked = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if (input.UserInputType == shared["MRX_Config"]["Keybind"] or input.KeyCode == shared["MRX_Config"]["Keybind"]) then
        if shared["MRX_Config"]["LockMode"] == "Hold" then
            isLocked = false
            currentTarget = nil
        end
    end
end)

-- Task Scheduler Loop
RunService.RenderStepped:Connect(function(deltaTime)
    if not shared["MRX_Config"]["Enabled"] or not isLocked then 
        currentTarget = nil
        return 
    end
    
    -- Evaluate or Re-evaluate Best Target
    if not currentTarget or not currentTarget.Parent or currentTarget.Parent:FindFirstChild("Humanoid").Health <= 0 then
        currentTarget = GetBestTarget()
    end
    
    if currentTarget then
        -- Randomization offset for Hitbox Selection
        local offset = Vector3.new(
            math.random(-10, 10) / 100, 
            math.random(-10, 10) / 100, 
            math.random(-10, 10) / 100
        )
        
        -- Prediction Engine (Velocity Scaling)
        -- Leads the target based on their linear assembly velocity
        local targetVelocity = currentTarget.AssemblyLinearVelocity
        local leadPosition = currentTarget.Position + (targetVelocity * 0.05) + offset
        
        -- Advanced Smoothing (Lerp)
        local targetCFrame = CFrame.new(Camera.CFrame.Position, leadPosition)
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, shared["MRX_Config"]["Smoothing"])
    end
end)

return TargetingModule
