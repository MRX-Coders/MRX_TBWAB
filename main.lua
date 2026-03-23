-- [[ MRX_TBWAB ULTIMATE MAIN ]]
local UIS = game:GetService("UserInputService")

-- Создаем таблицу в shared через строковый ключ (защита от обфускатора)
shared["MRX_Config"] = {
    Enabled = false,
    FOV_Radius = 150,
    Smoothing = 0.2,
    TeamCheck = true,
    WallCheck = true,
    Keybind = Enum.UserInputType.MouseButton2,
    LockMode = "Hold"
}

local function Fetch(url)
    local success, result = pcall(function() return game:HttpGet(url) end)
    if success and result then
        return loadstring(result)()
    end
end

-- Загружаем твои RAW файлы
local ThunderLib = Fetch("https://raw.githubusercontent.com/MRX-Coders/MRX_TBWAB/refs/heads/main/gui.lua")
local AimLogic = Fetch("https://raw.githubusercontent.com/MRX-Coders/MRX_TBWAB/refs/heads/main/AIMbot.lua")

local Window = ThunderLib:CreateWindow("MRX_TBWAB [V2.1]")

-- Вкладка COMBAT
local Combat = Window:CreateTab("Combat")

Combat:AddToggle("Enable Aimbot", function(state)
    shared.MRX_Config.Enabled = state
    Window:SendNotification("AIMBOT", state and "Activated" or "Deactivated", 2)
end)

Combat:AddToggle("Team Check", function(state)
    shared.MRX_Config.TeamCheck = state
end)

Combat:AddToggle("Wall Check", function(state)
    shared.MRX_Config.WallCheck = state
end)

Combat:AddSlider("Aim Smoothness", 1, 100, function(val)
    -- Превращаем 1-100 в 0.01-1.0 для конфига
    shared.MRX_Config.Smoothing = val / 100
end)

Combat:AddSlider("FOV Radius", 30, 800, function(val)
    shared.MRX_Config.FOV_Radius = val
end)

-- Вкладка SETTINGS (Для очистки экрана)
local Settings = Window:CreateTab("Settings")

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

Window:SendNotification("SUCCESS", "MRX_TBWAB Ready for Battle!", 3)
