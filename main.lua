-- [[ MRX_TBWAB PROJECT: MAIN LOADER ]]
-- Description: Connects GUI Engine with Aim Logic via GitHub RAW

local function Fetch(url)
    return loadstring(game:HttpGet(url))()
end

-- 1. Загружаем модули (используем твои ссылки)
local ThunderLib = Fetch("https://raw.githubusercontent.com/MRX-Coders/MRX_TBWAB/refs/heads/main/gui.lua")
local AimLogic = Fetch("https://raw.githubusercontent.com/MRX-Coders/MRX_TBWAB/refs/heads/main/AIMbot.lua")

-- 2. Инициализация Окна
local Window = ThunderLib:CreateWindow("MRX_TBWAB [V2.0]")

-- 3. Вкладка COMBAT (Связка с Аимботом)
local Combat = Window:CreateTab("Combat")

Combat:AddToggle("Enable Aimbot", function(state)
    _G.MRX_Config.Enabled = state
    Window:SendNotification("AIMBOT", state and "Activated" or "Deactivated", 2)
end)

Combat:AddToggle("Team Check", function(state)
    _G.MRX_Config.TeamCheck = state
end)

Combat:AddToggle("Wall Check", function(state)
    _G.MRX_Config.WallCheck = state
end)

Combat:AddSlider("Aim Smoothness", 1, 100, function(val)
    -- Превращаем 1-100 в 0.01-1.0 для конфига
    _G.MRX_Config.Smoothing = val / 100
end)

Combat:AddSlider("FOV Radius", 30, 800, function(val)
    _G.MRX_Config.FOV_Radius = val
end)

-- 4. Вкладка SETTINGS
local Settings = Window:CreateTab("Settings")

Settings:AddButton("Destroy GUI", function()
    Window:SendNotification("SYSTEM", "Cleaning up resources...", 2)
    task.wait(1)
    -- Тут можно добавить логику удаления ScreenGui
end)

-- Сообщение о запуске
Window:SendNotification("WELCOME", "MRX_TBWAB Loaded Successfully!", 4)
