-- [[ MRX_TBWAB V3 TARGET DETECTION & LOCK-ON ENGINE ]]
-- Role: Elite Targeting & Mechanics Framework
-- Status: Highly Optimized (V3)
-- Description: Advanced targeting systems with multi-point raycasting, 
-- humanized smoothing, prediction calculations, and dynamic FOV checks.

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Randomization Seed for Humanizer
math.randomseed(os.time())
math.random() math.random()

-- ==========================================
-- Core Configuration Bridge (shared)
-- ==========================================
-- We bridge local variables to the shared string dictionary for security 
-- and to ensure compatibility with MRX_TBWAB V2.0 GUI Engine.
if type(shared["MRX_Config"]) ~= "table" then
    shared["MRX_Config"] = {
        Enabled = false,
        Keybind = Enum.UserInputType.MouseButton2,
        LockMode = "Hold", -- "Hold" or "Toggle"
        
        FOV_Radius = 150,
        Smoothing = 0.2, -- 0.01 to 1.0
        
        Prioritize = "ClosestToCursor", -- "ClosestToCursor", "Distance", "LowestHealth"
        TargetPart = "HumanoidRootPart", -- Preferred part, but engine falls back if obstructed
        
        TeamCheck = true,
        WallCheck = true,
        
        -- Advanced Features (V3 Exclusives)
        Prediction = true,
        PredictionAmount = 0.145, -- Time in seconds to lead target
        Humanize = true,
        HumanizeFactor = 0.035, -- Spread / Jitter amount
        MaxDistance = 1500 -- Maximum unit lock distance
    }
end

-- ==========================================
-- Engine Architecture & Class
-- ==========================================
local AimEngine = {}
AimEngine.__index = AimEngine

AimEngine.CurrentTarget = nil
AimEngine.TargetPart = nil
AimEngine.IsLocked = false
AimEngine.Connections = {}

AimEngine.VisibilityCache = {}
AimEngine.LastCacheClear = tick()

-- Raycast offset adjustments
local RAYCAST_OFFSET = Vector3.new(0, 0.1, 0)
local VISIBILITY_POINTS = {
    "Head",
    "HumanoidRootPart",
    "UpperTorso",
    "LowerTorso",
    "Torso"
}

-- ==========================================
-- Utilities & Mathematics
-- ==========================================
local function GetScreenCenter()
    return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local function GetVectorDistance(v1, v2)
    return (v1 - v2).Magnitude
end

local function IsAlive(character)
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function IsValidTarget(player)
    if not player or player == LocalPlayer then return false end
    
    local char = player.Character
    if not char then return false end
    
    if not IsAlive(char) then return false end
    
    -- Team Check Logic
    if shared["MRX_Config"]["TeamCheck"] and player.Team and LocalPlayer.Team then
        if player.Team == LocalPlayer.Team then return false end
    end
    
    -- Force Field Protection (Spawn invincibility)
    if char:FindFirstChildOfClass("ForceField") then return false end
    
    return true
end

-- ==========================================
-- Core Engine Methods
-- ==========================================

-- Optimized Raycasting for WallCheck with Multi-Point Fallback
function AimEngine:GetVisiblePart(character)
    if not shared["MRX_Config"]["WallCheck"] then 
        local preferred = character:FindFirstChild(shared["MRX_Config"]["TargetPart"])
        if preferred then return preferred end
        return character:FindFirstChild("HumanoidRootPart") 
    end
    
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Head") then return nil end
    
    local origin = Camera.CFrame.Position
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.IgnoreWater = true
    
    -- Check preferred part first
    local preferredPart = character:FindFirstChild(shared["MRX_Config"]["TargetPart"])
    if preferredPart then
        local direction = (preferredPart.Position - origin)
        local result = Workspace:Raycast(origin, direction, rayParams)
        if not result or result.Instance:IsDescendantOf(character) then
            return preferredPart
        end
    end
    
    -- Fallback multi-point visibility check
    for _, partName in ipairs(VISIBILITY_POINTS) do
        local part = character:FindFirstChild(partName)
        if part and part ~= preferredPart then
            local direction = (part.Position - origin)
            local result = Workspace:Raycast(origin, direction, rayParams)
            
            if not result or result.Instance:IsDescendantOf(character) then
                return part -- Found an alternative visible part
            end
        end
    end
    
    return nil -- Fully obstructed
end

-- Multi-Priority Targeting System
function AimEngine:FindBestTarget()
    local bestPlayer = nil
    local bestPart = nil
    
    local cfgFOV = shared["MRX_Config"]["FOV_Radius"]
    local cfgPrioritize = shared["MRX_Config"]["Prioritize"]
    local cfgMaxDist = shared["MRX_Config"]["MaxDistance"] or 1500
    
    local shortestDistance = cfgFOV
    local nearestWorldDistance = cfgMaxDist
    local lowestHealth = math.huge
    
    local screenCenter = GetScreenCenter()
    local originPos = Camera.CFrame.Position
    
    for _, player in ipairs(Players:GetPlayers()) do
        if not IsValidTarget(player) then continue end
        
        local character = player.Character
        
        -- World distance check
        local primary = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
        if primary then
            local pDist = (primary.Position - originPos).Magnitude
            if pDist > cfgMaxDist then continue end
        end
        
        -- Visibility Check
        local visiblePart = self:GetVisiblePart(character)
        if not visiblePart then continue end
        
        -- Screen Position Calculation
        local screenPoint, onScreen = Camera:WorldToViewportPoint(visiblePart.Position)
        if not onScreen then continue end
        
        local vectorDistance = GetVectorDistance(Vector2.new(screenPoint.X, screenPoint.Y), screenCenter)
        
        -- FOV Check
        if vectorDistance <= cfgFOV then
            
            if cfgPrioritize == "ClosestToCursor" then
                if vectorDistance < shortestDistance then
                    shortestDistance = vectorDistance
                    bestPlayer = player
                    bestPart = visiblePart
                end
                
            elseif cfgPrioritize == "Distance" then
                local myChar = LocalPlayer.Character
                if myChar and myChar.PrimaryPart then
                    local dist = (visiblePart.Position - myChar.PrimaryPart.Position).Magnitude
                    if dist < nearestWorldDistance then
                        nearestWorldDistance = dist
                        bestPlayer = player
                        bestPart = visiblePart
                    end
                end
                
            elseif cfgPrioritize == "LowestHealth" then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health < lowestHealth then
                    lowestHealth = humanoid.Health
                    bestPlayer = player
                    bestPart = visiblePart
                end
            end
        end
    end
    
    return bestPlayer, bestPart
end

-- Trajectory & Position Forecasting
function AimEngine:CalculateLeadPosition(part)
    local targetPosition = part.Position
    
    -- Add Velocity Prediction
    if shared["MRX_Config"]["Prediction"] then
        local velocity = Vector3.new(0, 0, 0)
        
        -- Check for AssemblyLinearVelocity (Modern Roblox Physics)
        if part:IsA("BasePart") then
            velocity = part.AssemblyLinearVelocity
        end
        
        -- Ignore falling velocity to prevent aiming at the floor during jumps
        local modifiedVelocity = Vector3.new(velocity.X, math.clamp(velocity.Y, -10, 50), velocity.Z)
        
        local leadTime = shared["MRX_Config"]["PredictionAmount"] or 0.145
        targetPosition = targetPosition + (modifiedVelocity * leadTime)
    end
    
    -- Add Humanized Jitter
    if shared["MRX_Config"]["Humanize"] then
        local factor = shared["MRX_Config"]["HumanizeFactor"] or 0.035
        local rx = (math.random() - 0.5) * factor
        local ry = (math.random() - 0.5) * factor
        local rz = (math.random() - 0.5) * factor
        
        targetPosition = targetPosition + Vector3.new(rx, ry, rz)
    end
    
    return targetPosition
end

-- ==========================================
-- Input & State Management
-- ==========================================
function AimEngine:HandleInput(input, isBegan)
    if not shared["MRX_Config"]["Enabled"] then return end
    
    local keybind = shared["MRX_Config"]["Keybind"]
    local isTargetKey = (input.UserInputType == keybind or input.KeyCode == keybind)
    
    if isTargetKey then
        if isBegan then
            if shared["MRX_Config"]["LockMode"] == "Toggle" then
                self.IsLocked = not self.IsLocked
                if not self.IsLocked then self:ClearTarget() end
            else
                self.IsLocked = true
            end
        else
            if shared["MRX_Config"]["LockMode"] == "Hold" then
                self.IsLocked = false
                self:ClearTarget()
            end
        end
    end
end

function AimEngine:ClearTarget()
    self.CurrentTarget = nil
    self.TargetPart = nil
end

-- ==========================================
-- Render Loop Hook
-- ==========================================
function AimEngine:UpdatePipeline(deltaTime)
    if not shared["MRX_Config"]["Enabled"] or not self.IsLocked then 
        self:ClearTarget()
        return 
    end
    
    -- Cache maintenance 
    if tick() - self.LastCacheClear > 1 then
        self.VisibilityCache = {}
        self.LastCacheClear = tick()
    end
    
    -- Target Re-Evaluation
    local needsNewTarget = false
    if not self.CurrentTarget or not self.TargetPart then
        needsNewTarget = true
    elseif not IsAlive(self.CurrentTarget.Character) then
        needsNewTarget = true
    else
        -- Break lock if out of FOV or obstructed (Strict Locking)
        local screenPoint, onScreen = Camera:WorldToViewportPoint(self.TargetPart.Position)
        if not onScreen then 
            needsNewTarget = true 
        else
            local dist = GetVectorDistance(Vector2.new(screenPoint.X, screenPoint.Y), GetScreenCenter())
            if dist > shared["MRX_Config"]["FOV_Radius"] * 1.2 then -- 20% buffer to prevent stuttering
                needsNewTarget = true
            end
        end
        
        if not self:GetVisiblePart(self.CurrentTarget.Character) then
            needsNewTarget = true
        end
    end
    
    if needsNewTarget then
        self.CurrentTarget, self.TargetPart = self:FindBestTarget()
    end
    
    -- Execute Camera Movement
    if self.CurrentTarget and self.TargetPart then
        local targetPos = self:CalculateLeadPosition(self.TargetPart)
        
        local currentCFrame = Camera.CFrame
        local targetCFrame = CFrame.new(currentCFrame.Position, targetPos)
        
        -- Smooth Dampening Algorithm
        local smoothing = shared["MRX_Config"]["Smoothing"] or 0.2
        -- Clamp to prevent division by zero or inverse tracking
        smoothing = math.clamp(smoothing, 0.01, 1)
        
        -- Apply Interpolation
        Camera.CFrame = currentCFrame:Lerp(targetCFrame, smoothing)
    end
end

-- ==========================================
-- Initialization & Cleanup
-- ==========================================
function AimEngine:Start()
    -- Disconnect old connections if re-initialized
    for _, cxn in pairs(self.Connections) do
        if cxn.Disconnect then cxn:Disconnect() end
    end
    self.Connections = {}
    
    local inputBegan = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        self:HandleInput(input, true)
    end)
    table.insert(self.Connections, inputBegan)
    
    local inputEnded = UserInputService.InputEnded:Connect(function(input, gp)
        if gp then return end
        self:HandleInput(input, false)
    end)
    table.insert(self.Connections, inputEnded)
    
    local renderStep = RunService.RenderStepped:Connect(function(dt)
        -- Protective pcall to prevent execution crashes
        pcall(function()
            self:UpdatePipeline(dt)
        end)
    end)
    table.insert(self.Connections, renderStep)
    
    print("[MRX_TBWAB] Target Engine V3 Initialized Successfully.")
end

function AimEngine:Stop()
    for _, cxn in pairs(self.Connections) do
        if cxn.Disconnect then cxn:Disconnect() end
    end
    self.Connections = {}
    self:ClearTarget()
    self.IsLocked = false
    print("[MRX_TBWAB] Target Engine V3 Shutdown.")
end

-- Auto-start the engine internally
AimEngine:Start()

return AimEngine
