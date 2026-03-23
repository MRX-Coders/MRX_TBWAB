-- [[ MRX_TBWAB V4 TARGET DETECTION (EXECUTOR OPTIMIZED) ]]
-- Description: Aimbot optimized for external execution via script runners.
-- Integrates with MRX_TBWAB Configuration Engine and uses Drawing API.

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==========================================
-- ИНТЕГРАЦИЯ С ГЛАВНЫМ КОНФИГОМ
-- ==========================================
if type(shared["MRX_Config"]) ~= "table" then
    shared["MRX_Config"] = {
        Enabled = false,
        FOV_Radius = 150,
        Smoothing = 0.2,
        TeamCheck = true,
        WallCheck = true,
        Keybind = Enum.UserInputType.MouseButton2,
        LockMode = "Hold"
    }
end

local Config = shared["MRX_Config"]

-- ==========================================
-- РИСОВАНИЕ FOV (Только для Executors)
-- ==========================================
local FOVring = nil
if Drawing then
    FOVring = Drawing.new("Circle")
    FOVring.Visible = true
    FOVring.Thickness = 1.5
    FOVring.Transparency = 1
    FOVring.Color = Color3.fromRGB(255, 128, 128)
else
    warn("[MRX_TBWAB] Внимание: Выполняется в Roblox Studio. Drawing API недоступен, круг FOV будет скрыт.")
end

-- ==========================================
-- ЛОГИКА АКТИВАЦИИ
-- ==========================================
local function isAiming()
    if not Config["Enabled"] then return false end
    
    if Config["LockMode"] == "Hold" then
        -- Проверка нажатия кнопки (по умолчанию ПКМ)
        local key = Config["Keybind"]
        if key == Enum.UserInputType.MouseButton2 then
            return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        end
        return UserInputService:IsKeyDown(key)
    elseif Config["LockMode"] == "Toggle" then
        -- При Toggle режиме скрипт полагается на то, что Config["Enabled"] 
        -- сам контролирует состояние через GUI в main.lua
        return true 
    end
    
    return true
end

-- ==========================================
-- МАТЕМАТИКА И ПОИСК ЦЕЛИ ПО ЛУЧУ (RAY)
-- ==========================================
local function getClosest(cframe)
    local target = nil
    local mag = math.huge
    local ray = Ray.new(cframe.Position, cframe.LookVector).Unit
    
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character and v.Character:FindFirstChild("Head") and v ~= LocalPlayer then
            -- Проверка команды (TeamCheck)
            if not Config["TeamCheck"] or (v.Team ~= LocalPlayer.Team) then
                local headPos = v.Character.Head.Position
                
                -- Рассчитываем расстояние выстрела до линии прицеливания луча 
                -- (поиск ближайшего к перекрестию)
                local magBuf = (headPos - ray:ClosestPoint(headPos)).Magnitude
                if magBuf < mag then
                    mag = magBuf
                    target = v
                end
            end
        end
    end
    return target
end

-- ==========================================
-- ГЛАВНЫЙ ЦИКЛ ОБНОВЛЕНИЯ (RENDER STEP)
-- ==========================================
RunService.RenderStepped:Connect(function()
    local isLocking = isAiming()
    local currentFOV = Config["FOV_Radius"] or 200
    
    -- Обновляем визуал FOV Круга
    if FOVring then
        FOVring.Position = Camera.ViewportSize / 2
        FOVring.Radius = currentFOV
        
        if Config["Enabled"] then
            FOVring.Visible = true
            -- Зеленый при захвате, красный при бездействии
            if isLocking then
                FOVring.Color = Color3.fromRGB(0, 255, 0)
            else
                FOVring.Color = Color3.fromRGB(255, 128, 128)
            end
        else
            FOVring.Visible = false
        end
    end
    
    -- Выполнение Захвата
    if isLocking then
        local screenCenter = Camera.ViewportSize / 2
        local closestTarget = getClosest(Camera.CFrame)

        if closestTarget and closestTarget.Character and closestTarget.Character:FindFirstChild("Head") then
            local head = closestTarget.Character.Head
            
            -- Проверка по 2D ScreenPoint для дополнительной строгости FOV
            local ssHeadPoint, onScreen = Camera:WorldToScreenPoint(head.Position)
            local vectorPos = Vector2.new(ssHeadPoint.X, ssHeadPoint.Y)
            
            if onScreen and (vectorPos - screenCenter).Magnitude < currentFOV then
                local targetCFrame = CFrame.new(Camera.CFrame.Position, head.Position)
                
                -- Плавная доводка
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config["Smoothing"] or 0.2)
            end
        end
    end
end)
