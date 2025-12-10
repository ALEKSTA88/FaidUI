-- Пример использования библиотеки
local ExecutorUILibrary = loadstring(game:HttpGet('https://raw.githubusercontent.com/ALEKSTA88/FaidUI/refs/heads/main/Lib.lua'))() -- или loadstring, если загружаете удаленно

-- Создаем экземпляр библиотеки
local ui = ExecutorUILibrary.new()

-- Создаем кнопку
local button = ui:CreateButton({
    Name = "TestButton",
    Text = "Click me!",
    Position = UDim2.new(0, 20, 0, 20),
    OnClick = function()
        print("Button clicked!")
    end
})

-- Создаем переключатель
local toggle = ui:CreateToggle({
    Name = "GodMode",
    Text = "God Mode",
    Position = UDim2.new(0, 20, 0, 80),
    Default = false,
    OnToggle = function(state)
        print("God Mode:", state)
    end
})

-- Создаем слайдер
local slider = ui:CreateSlider({
    Name = "Speed",
    Text = "Speed",
    Position = UDim2.new(0, 20, 0, 140),
    Min = 16,
    Max = 100,
    Default = 16,
    OnChange = function(value)
        print("Speed changed to:", value)
    end
})

-- Создаем панель исполнителя
local executor = ui:CreateExecutorPanel({
    Name = "MainExecutor",
    Title = "Script Executor v1.0",
    Position = UDim2.new(0.5, -250, 0.5, -200),
    Size = UDim2.new(0, 500, 0, 400),
    DefaultScript = "print('Hello from executor!')"
})

-- Создаем консоль
local console = ui:CreateConsole({
    Name = "DebugConsole",
    Title = "Debug Console",
    Position = UDim2.new(0, 300, 0, 20),
    Size = UDim2.new(0, 400, 0, 200),
    OnCommand = function(cmd)
        if cmd == "help" then
            return "Commands: help, clear, info, theme [dark/light]"
        elseif cmd == "clear" then
            console:Clear()
            return "Console cleared"
        elseif cmd == "info" then
            local info = ui:GetInfo()
            return string.format("UI v%s, Elements: %d", info.Version, info.ElementsCount)
        elseif cmd:sub(1,6) == "theme " then
            local theme = cmd:sub(7)
            ui:SetTheme(theme)
            return "Theme set to: " .. theme
        else
            return "Executed: " .. cmd
        end
    end
})

-- Выводим информацию о библиотеке
local info = ui:GetInfo()
print("Executor UI Library loaded!")
print("Version:", info.Version)
print("Elements:", info.ElementsCount)
print("Theme:", info.CurrentTheme)
