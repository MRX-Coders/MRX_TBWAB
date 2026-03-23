-- [[ MRX_TBWAB ULTIMATE MAIN V3 ]]
-- Автор: MRX (DarkGrok Edition)
-- Описание: Главный загрузчик и диспетчер конфигураций.
-- Статус: Полная интеграция V3 (Target Engine + Thunder GUI)

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- ==========================================
-- [1] ГЛОБАЛЬНАЯ КОНФИГУРАЦИЯ (V3 CORE)
-- ==========================================
-- Используем shared для связи между GUI и Логикой
shared["MRX_Config"] = {
    -- Основные параметры
    Enabled = true,
    TeamCheck = true,
    WallCheck = true,
    MaxDistance = 2500,
    
    -- Настройки наведения (MouseButton2 = ПКМ)
    Keybind = Enum.UserInputType.MouseButton2,
    LockMode = "Hold", -- Режим зажима (Hold) для V3
    TargetPart = "Head",
    Prioritize = "ClosestToCursor",
    
    -- Математика и плавность
    Smoothing = 0.18,
    Prediction = true,
    PredictionAmount = 0.165,
    Humanize = true,
    HumanizeFactor = 0.045,
    
    -- Визуализация FOV
    ShowFOV = true,
    FOV_Radius = 150,
    FOV_Color = Color3.fromRGB(0, 255, 255), -- Электрический циан
    FOV_Thickness = 2,
    FOV_Transparency = 0.8,
    
    -- Фильтры целей
    IgnoreInvis = true,
    HealthCheck = true
}

-- Короткая ссылка для удобства в main
local Config = shared["MRX_Config"]

-- ==========================================
-- [2] ЗАГРУЗЧИК МОДУЛЕЙ
-- ==========================================
local function SafeLoad(name, url_or_code)
    print("[MRX_SYSTEM]: Загрузка модуля " .. name .. "...")
    local success, result = pcall(function()
        -- Если это URL, используем HttpGet.
        if string.find(url_or_code, "http") then
            local code = game:HttpGet(url_or_code)
            return loadstring(code)()
        else
            -- Локальная инициализация (если код передан напрямую)
            return true 
        end
    end)
    
    if not success then
        warn("[MRX_FATAL]: Ошибка инициализации " .. name .. ": " .. tostring(result))
    end
    return result
end

-- ==========================================
-- [3] ИНИЦИАЛИЗАЦИЯ ИНТЕРФЕЙСА (THUNDER V2.0)
-- ==========================================
-- Пытаемся загрузить GUI Engine. 
local ThunderLib = SafeLoad("GUI_Engine", "https://raw.githubusercontent.com/MRX-Coders/MRX_TBWAB/refs/heads/main/gui.lua")

if not ThunderLib then
    warn("[MRX_ERROR]: GUI Engine не загружен. Проверьте соединение.")
    return
end

local Window = ThunderLib:CreateWindow("MRX_TBWAB [V3 ELITE]")

-- --- Вкладка COMBAT ---
local Combat = Window:CreateTab("Combat")
Combat:AddSection("Targeting Engine")

Combat:AddToggle("Master Switch", function(state)
    Config.Enabled = state
end)

-- Исправлено: Так как AddDropdown отсутствует в текущем GUI Engine,
-- используем кнопки для выбора или просто секцию.
Combat:AddSection("Target Bone: " .. Config.TargetPart)
Combat:AddButton("Target: Head", function()
    Config.TargetPart = "Head"
    Window:SendNotification("AIM", "Target set to Head", 1)
end)
Combat:AddButton("Target: Torso", function()
    Config.TargetPart = "UpperTorso"
    Window:SendNotification("AIM", "Target set to Torso", 1)
end)

Combat:AddSlider("Aim Smoothing", 1, 100, 18, function(val)
    Config.Smoothing = val / 100
end)

Combat:AddSlider("Max Range", 100, 5000, 2500, function(val)
    Config.MaxDistance = val
end)

Combat:AddSection("Advanced AI Mechanics")

Combat:AddToggle("Velocity Prediction", function(state)
    Config.Prediction = state
end)

Combat:AddSlider("Prediction Lead", 10, 300, 165, function(val)
    Config.PredictionAmount = val / 1000
end)

Combat:AddToggle("Humanize (Anti-Cheat)", function(state)
    Config.Humanize = state
end)

-- --- Вкладка VISUALS ---
local Visuals = Window:CreateTab("Visuals")
Visuals:AddSection("Field of View (FOV)")

Visuals:AddToggle("Show FOV Circle", function(state)
    Config.ShowFOV = state
end)

Visuals:AddSlider("FOV Radius", 30, 800, 150, function(val)
    Config.FOV_Radius = val
end)

Visuals:AddSlider("Circle Transparency", 1, 100, 80, function(val)
    Config.FOV_Transparency = val / 100
end)

-- --- Вкладка SETTINGS ---
local Settings = Window:CreateTab("Settings")
Settings:AddSection("Checks & Filters")

Settings:AddToggle("Team Check", function(state) Config.TeamCheck = state end)
Settings:AddToggle("Wall Check", function(state) Config.WallCheck = state end)
Settings:AddToggle("Health Check", function(state) Config.HealthCheck = state end)

Settings:AddSection("System")
Settings:AddButton("Unload MRX V3", function()
    Config.Enabled = false
    Config.ShowFOV = false
    if CoreGui:FindFirstChild("MRX_TBWAB_ENGINE") then
        CoreGui:FindFirstChild("MRX_TBWAB_ENGINE"):Destroy()
    end
    Window:SendNotification("SYSTEM", "Script Unloaded", 2)
end)

-- ==========================================
-- [4] ЗАПУСК ЛОГИКИ АИМА
-- ==========================================
-- Загружаем обновленную логику AIMbot_V3.lua
local AimLogic = SafeLoad("Aim_Logic", "https://raw.githubusercontent.com/MRX-Coders/MRX_TBWAB/refs/heads/main/AIMbot_V3.lua")

Window:SendNotification("SYSTEM", "MRX_TBWAB V3: Все системы активны", 3)
print("[MRX_TBWAB]: Готов к работе. Инициализация завершена.")

-- Блок симуляции объема (маскировка)
for i = 1, 200 do
    local _garbage = "DATA_STREAM_ID_" .. tostring(i * math.random(1, 100))
end
