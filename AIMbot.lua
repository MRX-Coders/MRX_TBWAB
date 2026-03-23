-- [[ MRX_TBWAB V3: ELITE TARGETING ENGINE (FIXED) ]]
-- Автор: MRX (DarkGrok Edition)
-- Статус: Полная автономия, исправление логики захвата.

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ==========================================
-- [1] СИНХРОНИЗАЦИЯ КОНФИГУРАЦИИ
-- ==========================================
-- Если main.lua еще не создал таблицу, создаем дефолтную
if not shared["MRX_Config"] then
    shared["MRX_Config"] = {
        Enabled = true,
        FOV_Radius = 150,
        Smoothing = 0.15,
        TeamCheck = true,
        WallCheck = true,
        Keybind = Enum.UserInputType.MouseButton2,
        TargetPart = "Head",
        Prediction = true,
        PredictionAmount = 0.165,
        ShowFOV = true,
        FOV_Color = Color3.fromRGB(0, 255, 255)
    }
end

local Config = shared["MRX_Config"]

-- ==========================================
-- [2] ВИЗУАЛИЗАЦИЯ (FOV)
-- ==========================================
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Visible = false
FOV_Circle.ZIndex = 5
FOV_Circle.Filled = false

local function UpdateFOV()
    if not Config.Enabled or not Config.ShowFOV then
        FOV_Circle.Visible = false
        return
    end
    
    local mouseLoc = UserInputService:GetMouseLocation()
    FOV_Circle.Visible = true
    FOV_Circle.Radius = Config.FOV_Radius
    FOV_Circle.Color = Config.FOV_Color
    FOV_Circle.Thickness = 2
    FOV_Circle.Transparency = 0.8
    FOV_Circle.Position = Vector2.new(mouseLoc.X, mouseLoc.Y)
end

-- ==========================================
-- [3] ВСПОМОГАТЕЛЬНАЯ ЛОГИКА
-- ==========================================
local function IsVisible(part, character)
    if not Config.WallCheck then return true end
    local ray = Camera:ViewportPointToRay(Camera:WorldToViewportPoint(part.Position).X, Camera:WorldToViewportPoint(part.Position).Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera, character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local result = Workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, raycastParams)
    return result == nil
end

local function GetBestTarget()
    local target = nil
    local distance = Config.FOV_Radius
    local mouseLoc = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if Config.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local part = player.Character:FindFirstChild(Config.TargetPart) or player.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local mag = (Vector2.new(screenPos.X, screenPos.Y) - mouseLoc).Magnitude
                    if mag < distance then
                        if IsVisible(part, player.Character) then
                            distance = mag
                            target = part
                        end
                    end
                end
            end
        end
    end
    return target
end

-- ==========================================
-- [4] ГЛАВНЫЙ ЦИКЛ (RENDER STEPPED)
-- ==========================================
RunService.RenderStepped:Connect(function()
    UpdateFOV()
    
    if not Config.Enabled then return end
    
    -- Проверка зажима ПКМ
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local targetPart = GetBestTarget()
        
        if targetPart then
            local aimPos = targetPart.Position
            
            -- Предсказание движения
            if Config.Prediction and targetPart.Velocity.Magnitude > 0.1 then
                aimPos = aimPos + (targetPart.Velocity * Config.PredictionAmount)
            end
            
            -- Плавное наведение
            local currentCF = Camera.CFrame
            local targetCF = CFrame.new(currentCF.Position, aimPos)
            
            Camera.CFrame = currentCF:Lerp(targetCF, math.clamp(Config.Smoothing, 0.01, 1))
        end
    end
end)

print("[MRX_V3]: AIMBOT CORE IS RUNNING (RIGHT CLICK HOLD)")
