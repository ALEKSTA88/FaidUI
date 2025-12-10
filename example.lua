-- Пример использования библиотеки с перетаскиваемым окном
local DragWindowUILibrary = loadstring(game:HttpGet('https://raw.githubusercontent.com/ALEKSTA88/FaidUI/refs/heads/main/Lib.lua'))()

-- Создаем окно
local ui = DragWindowUILibrary.new({
    Title = "Roblox UI Controls",
    Size = UDim2.new(0, 400, 0, 500),
    Position = UDim2.new(0.1, 0, 0.1, 0)
})

-- Добавляем заголовок
ui:CreateLabel({
    Text = "Control Panel",
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    Center = true
})

-- Добавляем разделитель
ui:CreateSeparator()

-- Добавляем кнопки
local button1 = ui:CreateButton({
    Name = "TestButton1",
    Text = "Click Me!",
    OnClick = function()
        print("Button 1 clicked!")
    end
})

local button2 = ui:CreateButton({
    Name = "TestButton2",
    Text = "Disable Button 1",
    OnClick = function()
        button1.SetEnabled(not button1.Frame:FindFirstChildOfClass("TextButton").Active)
        button2.SetText(button1.Frame:FindFirstChildOfClass("TextButton").Active and "Disable Button 1" or "Enable Button 1")
    end
})

-- Добавляем разделитель
ui:CreateSeparator()

-- Добавляем переключатели
local toggle1 = ui:CreateToggle({
    Name = "Feature1",
    Text = "Enable Feature 1",
    Default = false,
    OnToggle = function(state)
        print("Feature 1:", state)
    end
})

local toggle2 = ui:CreateToggle({
    Name = "Feature2",
    Text = "Enable Feature 2",
    Default = true,
    OnToggle = function(state)
        print("Feature 2:", state)
    end
})

-- Добавляем разделитель
ui:CreateSeparator()

-- Добавляем слайдер
local slider = ui:CreateSlider({
    Name = "Volume",
    Text = "Volume Level",
    Min = 0,
    Max = 100,
    Default = 50,
    OnChange = function(value)
        print("Volume changed to:", value)
    end
})

-- Добавляем разделитель
ui:CreateSeparator()

-- Добавляем выпадающий список
local dropdown = ui:CreateDropdown({
    Name = "GameModes",
    Options = {"Survival", "Creative", "Adventure", "Hardcore"},
    Default = "Survival",
    OnSelect = function(option)
        print("Selected game mode:", option)
    end
})

-- Добавляем разделитель
ui:CreateSeparator()

-- Добавляем текстовое поле
local textBox = ui:CreateTextBox({
    Name = "PlayerName",
    Placeholder = "Enter player name...",
    Default = "",
    OnTextChanged = function(text, enterPressed)
        if enterPressed and text ~= "" then
            print("Player name entered:", text)
        end
    end
})

-- Добавляем многострочное текстовое поле
local multiTextBox = ui:CreateTextBox({
    Name = "MultiLineText",
    Size = UDim2.new(1, 0, 0, 60),
    Placeholder = "Enter multi-line text...",
    MultiLine = true,
    OnTextChanged = function(text)
        print("Text length:", #text)
    end
})

-- Функция для изменения темы
ui:CreateButton({
    Name = "ThemeToggle",
    Text = "Switch to Light Theme",
    OnClick = function()
        if ui:GetInfo().CurrentTheme == "Dark" then
            ui:SetTheme("Light")
            button1.SetText("Light Theme Active")
        else
            ui:SetTheme("Dark")
            button1.SetText("Dark Theme Active")
        end
    end
})

-- Получаем информацию о UI
local info = ui:GetInfo()
print("UI Library loaded!")
print("Version:", info.Version)
print("Elements:", info.ElementsCount)
print("Theme:", info.CurrentTheme)

-- Дополнительные функции управления
-- ui:SetVisible(false) -- Скрыть окно
-- ui:ToggleVisibility() -- Переключить видимость
-- ui:SetPosition(UDim2.new(0.5, -200, 0.5, -250)) -- Переместить окно
-- ui:SetTitle("New Window Title") -- Изменить заголовок
-- ui:ClearContent() -- Очистить все элементы
-- ui:Destroy() -- Уничтожить окно
