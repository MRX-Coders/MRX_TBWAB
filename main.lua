-- [[ MRX_TBWAB ULTIMATE MAIN V3 ]]
local UIS = game:GetService("UserInputService")

-- Создаем таблицу в shared через строковый ключ (строгая защита и совместимость с V3)
shared["MRX_Config"] = {
    Enabled = false,
    FOV_Radius = 150,
    Smoothing = 0.2,
    TeamCheck = true,
    WallCheck = true,
    Keybind = Enum.UserInputType.MouseButton2,
    LockMode = "Hold",
    Prediction = true,
    PredictionAmount = 0.145,
    Humanize = true,
    HumanizeFactor = 0.035,
    MaxDistance = 1500,
    Prioritize = "ClosestToCursor"
}

local function Fetch(url)
    local success, result = pcall(function() return game:HttpGet(url) end)
    if success and result then
        return loadstring(result)()
    end
end

-- Загружаем RAW файлы (Настоятельно рекомендуется заменить на локальные пути во время тестирования в Studio)
local ThunderLib = Fetch("https://raw.githubusercontent.com/MRX-Coders/MRX_TBWAB/refs/heads/main/gui.lua")
local AimLogic = Fetch("https://raw.githubusercontent.com/MRX-Coders/MRX_TBWAB/refs/heads/main/AIMbot.lua")

if not ThunderLib then
    warn("[MRX_TBWAB] Ошибка загрузки GUI Engine! Проверьте ссылку.")
    return
end

local Window = ThunderLib:CreateWindow("MRX_TBWAB [V3 ULTIMATE]")

-- ==========================================
-- Вкладка COMBAT
-- ==========================================
local Combat = Window:CreateTab("Combat")

Combat:AddSection("Main Controls")

Combat:AddToggle("Enable Target Lock", function(state)
    shared["MRX_Config"]["Enabled"] = state
    Window:SendNotification("AIMBOT", state and "Activated" or "Deactivated", 2)
end)

-- Обрати внимание: в V3 AddSlider принимает (текст, мин, макс, по умолчанию, коллбек)
Combat:AddSlider("FOV Radius", 30, 800, 150, function(val)
    shared["MRX_Config"]["FOV_Radius"] = val
end)

Combat:AddSlider("Aim Smoothness (%)", 1, 100, 20, function(val)
    shared["MRX_Config"]["Smoothing"] = math.clamp(val / 100, 0.01, 1)
end)

Combat:AddSection("Target Checks")

Combat:AddToggle("Team Check", function(state)
    shared["MRX_Config"]["TeamCheck"] = state
end)

Combat:AddToggle("Wall Check (Multi-Point)", function(state)
    shared["MRX_Config"]["WallCheck"] = state
end)

Combat:AddSection("Advanced AI Mechanics")

Combat:AddToggle("Velocity Prediction", function(state)
    shared["MRX_Config"]["Prediction"] = state
end)

Combat:AddSlider("Lead Time (ms)", 10, 500, 145, function(val)
    shared["MRX_Config"]["PredictionAmount"] = val / 1000
end)

Combat:AddToggle("Humanize Aim (Jitter)", function(state)
    shared["MRX_Config"]["Humanize"] = state
end)

Combat:AddSlider("Humanize Factor", 1, 100, 35, function(val)
    shared["MRX_Config"]["HumanizeFactor"] = val / 1000
end)

-- ==========================================
-- Вкладка SETTINGS
-- ==========================================
local Settings = Window:CreateTab("Settings")

Settings:AddSection("System Management")

Settings:AddButton("Full Unload (Destroy GUI)", function()
    Window:SendNotification("SYSTEM", "Cleaning up...", 2)
    
    -- 1. Выключаем логику
    shared["MRX_Config"]["Enabled"] = false
    
    -- 2. Ищем и удаляем ВСЕ GUI проекта
    local targets = {game:GetService("CoreGui"), game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")}
    for _, container in pairs(targets) do
        if container then
            for _, child in pairs(container:GetChildren()) do
                if child.Name == "MRX_TBWAB_ENGINE" or child.Name == "MRX_TBWAB_GUI" then
                    child:Destroy()
                end
            end
        end
    end
    
    Window:SendNotification("SYSTEM", "GUI Cleaned!", 2)
end)

Window:SendNotification("SUCCESS", "MRX_TBWAB V3 Ready for Battle!", 4)
