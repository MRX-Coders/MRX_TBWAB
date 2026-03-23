-- [[ MRX_TBWAB ULTIMATE MAIN V4 (EXECUTOR OPTIMIZED) ]]
local UIS = game:GetService("UserInputService")

-- Создаем таблицу в shared через строковый ключ (строгая защита)
shared["MRX_Config"] = {
    Enabled = false,
    FOV_Radius = 200,
    Smoothing = 0.2,
    TeamCheck = true,
    Keybind = Enum.UserInputType.MouseButton2,
    LockMode = "Hold", -- "Hold" или "Always"
}

local function Fetch(url)
    local success, result = pcall(function() return game:HttpGet(url) end)
    if success and result then
        return loadstring(result)()
    end
end

-- Загружаем RAW файлы 
-- (Замените Fetch на loadstring(readfile("...")) при необходимости локального тестирования в экзекуторе)
local ThunderLib = Fetch("https://raw.githubusercontent.com/MRX-Coders/MRX_TBWAB/refs/heads/main/gui.lua")
local AimLogic = Fetch("https://raw.githubusercontent.com/MRX-Coders/MRX_TBWAB/refs/heads/main/AIMbot.lua")

if not ThunderLib then
    warn("[MRX_TBWAB] Ошибка загрузки GUI Engine! Проверьте ссылку.")
    return
end

local Window = ThunderLib:CreateWindow("MRX_TBWAB [V4 ULTIMATE]")

-- ==========================================
-- Вкладка COMBAT
-- ==========================================
local Combat = Window:CreateTab("Combat")

Combat:AddSection("Main Controls")

-- Глобальный выключатель Аимбота (эквивалент "Должен ли Аимбот работать в принципе")
Combat:AddToggle("Enable Target Lock", function(state)
    shared["MRX_Config"]["Enabled"] = state
    Window:SendNotification("AIMBOT", state and "System Activated" or "System Deactivated", 2)
end)

-- Переключатель режима: Hold (только по ПКМ) или Always (всегда наводить, если включен)
Combat:AddToggle("Require Hold (Right-Click)", function(state)
    local mode = state and "Hold" or "Always"
    shared["MRX_Config"]["LockMode"] = mode
    Window:SendNotification("AIM MODE", "Mode set to: " .. mode, 2)
end)

Combat:AddSection("Target Checks")

Combat:AddToggle("Team Check", function(state)
    shared["MRX_Config"]["TeamCheck"] = state
end)

Combat:AddSection("Mechanics & FOV")

-- Значение по умолчанию 200, как в твоем скрипте
Combat:AddSlider("FOV Radius", 30, 800, 200, function(val)
    shared["MRX_Config"]["FOV_Radius"] = val
end)

-- Уровень сглаживания (1-100 превращается в 0.01 - 1.0)
Combat:AddSlider("Aim Smoothness (%)", 1, 100, 20, function(val)
    shared["MRX_Config"]["Smoothing"] = math.clamp(val / 100, 0.01, 1)
end)

-- ==========================================
-- Вкладка SETTINGS
-- ==========================================
local Settings = Window:CreateTab("Settings")

Settings:AddSection("System Management")

Settings:AddButton("Full Unload (Destroy GUI)", function()
    Window:SendNotification("SYSTEM", "Cleaning up...", 2)
    
    -- Выключаем логику, чтобы убрать FOV круг из Drawing API
    shared["MRX_Config"]["Enabled"] = false
    
    -- Ищем и удаляем ВСЕ GUI проекта
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

Window:SendNotification("SUCCESS", "MRX_TBWAB V4 Ready for Battle!", 4)
