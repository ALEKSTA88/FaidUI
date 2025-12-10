-- Пример использования
local ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/ALEKSTA88/FaidUI/refs/heads/main/Lib.lua"))()

-- Создание кнопки
local myButton = ui:CreateButton({
    Name = "ExecuteBtn",
    Text = "Execute Script",
    Position = UDim2.new(0, 20, 0, 20),
    Size = UDim2.new(0, 150, 0, 40),
    OnClick = function()
        print("Button clicked!")
        -- Ваш код здесь
    end
})

-- Создание переключателя
local myToggle = ui:CreateToggle({
    Name = "GodMode",
    Text = "God Mode",
    Position = UDim2.new(0, 20, 0, 70),
    Default = false,
    OnToggle = function(state)
        print("God Mode: " .. tostring(state))
        -- Включение/выключение режима бога
    end
})

-- Создание слайдера
local mySlider = ui:CreateSlider({
    Name = "WalkSpeed",
    Text = "Walk Speed",
    Position = UDim2.new(0, 20, 0, 120),
    Min = 16,
    Max = 100,
    Default = 16,
    OnChange = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})

-- Создание выпадающего списка
local myDropdown = ui:CreateDropdown({
    Name = "Teleport",
    Position = UDim2.new(0, 20, 0, 190),
    Options = {"Spawn", "Baseplate", "Sky", "Secret Room"},
    OnSelect = function(option)
        print("Teleporting to: " .. option)
        -- Телепортация
    end
})

-- Создание консоли
local console = ui:CreateConsole({
    Name = "MainConsole",
    Title = "Executor Console",
    Position = UDim2.new(0.5, -200, 0, 20),
    Size = UDim2.new(0, 400, 0, 300),
    OnCommand = function(cmd)
        if cmd == "help" then
            return "Available commands: help, clear, info"
        elseif cmd == "clear" then
            console:Clear()
            return "Console cleared"
        elseif cmd == "info" then
            return "Executor UI Library v1.0.0"
        else
            return "Unknown command: " .. cmd
        end
    end
})

-- Создание панели исполнителя
local executorPanel = ui:CreateExecutorPanel({
    Name = "MainExecutor",
    Title = "Script Executor",
    Size = UDim2.new(0, 600, 0, 500),
    DefaultScript = "print('Hello from executor!')"
})

-- Изменение темы
ui:SetTheme("Dark") -- или "Light"

-- Получение информации
local info = ui:GetInfo()
print("UI Version: " .. info.Version)
