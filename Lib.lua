-- ExecutorUILibrary.lua
-- Исправленная библиотека UI для Roblox исполнителей

local ExecutorUILibrary = {}
ExecutorUILibrary.__index = ExecutorUILibrary

-- Конфигурация
local CONFIG = {
    DEFAULT_THEME = "Dark",
    SOUNDS_ENABLED = false, -- Отключаем звуки, так как SoundId требует правильных ID
    ANIMATIONS_ENABLED = true
}

-- Текущая тема
local currentTheme = {
    Dark = {
        Background = Color3.fromRGB(30, 30, 30),
        Primary = Color3.fromRGB(0, 120, 215),
        Secondary = Color3.fromRGB(60, 60, 60),
        Text = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(0, 200, 0),
        Error = Color3.fromRGB(255, 50, 50),
        Warning = Color3.fromRGB(255, 165, 0)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 240),
        Primary = Color3.fromRGB(0, 90, 180),
        Secondary = Color3.fromRGB(200, 200, 200),
        Text = Color3.fromRGB(0, 0, 0),
        Success = Color3.fromRGB(0, 150, 0),
        Error = Color3.fromRGB(200, 0, 0),
        Warning = Color3.fromRGB(200, 120, 0)
    }
}

-- Служебные функции
local function createRoundedFrame(parent, size, position)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = currentTheme[CONFIG.DEFAULT_THEME].Secondary
    frame.BackgroundTransparency = 0
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = frame
    
    if parent then
        frame.Parent = parent
    end
    
    return frame
end

local function createTextLabel(parent, text, size, position)
    local label = Instance.new("TextLabel")
    label.Size = size
    label.Position = position
    label.Text = text
    label.TextColor3 = currentTheme[CONFIG.DEFAULT_THEME].Text
    label.BackgroundTransparency = 1
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    if parent then
        label.Parent = parent
    end
    
    return label
end

-- Основной класс библиотеки
function ExecutorUILibrary.new(parentScreenGui)
    local self = setmetatable({}, ExecutorUILibrary)
    
    self._screenGui = parentScreenGui or Instance.new("ScreenGui")
    if not parentScreenGui then
        self._screenGui.Name = "ExecutorUILibrary"
        local player = game:GetService("Players").LocalPlayer
        if player then
            local playerGui = player:WaitForChild("PlayerGui")
            self._screenGui.Parent = playerGui
        else
            self._screenGui.Parent = game:GetService("StarterGui")
        end
    end
    
    self._elements = {}
    self._executors = {}
    self._themes = currentTheme
    self._currentTheme = CONFIG.DEFAULT_THEME
    
    print("[ExecutorUILibrary] Библиотека инициализирована")
    return self
end

-- Создание кнопки
function ExecutorUILibrary:CreateButton(config)
    config = config or {}
    
    local buttonFrame = createRoundedFrame(self._screenGui, config.Size or UDim2.new(0, 120, 0, 40), config.Position or UDim2.new(0, 20, 0, 20))
    
    local buttonText = Instance.new("TextButton")
    buttonText.Size = UDim2.new(1, 0, 1, 0)
    buttonText.Text = config.Text or "Button"
    buttonText.TextColor3 = self._themes[self._currentTheme].Text
    buttonText.BackgroundTransparency = 1
    buttonText.TextSize = 14
    buttonText.Font = Enum.Font.GothamBold
    buttonText.Parent = buttonFrame
    
    -- Анимация наведения
    if CONFIG.ANIMATIONS_ENABLED then
        buttonText.MouseEnter:Connect(function()
            local theme = self._themes[self._currentTheme]
            local darkerColor = Color3.fromRGB(
                math.floor(theme.Primary.R * 255 * 0.8),
                math.floor(theme.Primary.G * 255 * 0.8),
                math.floor(theme.Primary.B * 255 * 0.8)
            )
            game:GetService("TweenService"):Create(buttonFrame, TweenInfo.new(0.2), {
                BackgroundColor3 = darkerColor
            }):Play()
        end)
        
        buttonText.MouseLeave:Connect(function()
            game:GetService("TweenService"):Create(buttonFrame, TweenInfo.new(0.2), {
                BackgroundColor3 = self._themes[self._currentTheme].Primary
            }):Play()
        end)
    end
    
    buttonFrame.BackgroundColor3 = self._themes[self._currentTheme].Primary
    
    local button = {
        _frame = buttonFrame,
        _text = buttonText,
        Click = Instance.new("BindableEvent")
    }
    
    buttonText.MouseButton1Click:Connect(function()
        button.Click:Fire()
        
        if config.OnClick then
            local success, err = pcall(config.OnClick)
            if not success then
                warn("[Button] Ошибка в обработчике OnClick:", err)
            end
        end
    end)
    
    local elementName = config.Name or "Button_" .. tostring(#self._elements + 1)
    self._elements[elementName] = button
    
    return button
end

-- Создание переключателя
function ExecutorUILibrary:CreateToggle(config)
    config = config or {}
    
    local toggleFrame = createRoundedFrame(self._screenGui, config.Size or UDim2.new(0, 200, 0, 40), config.Position or UDim2.new(0, 20, 0, 80))
    
    local toggleText = createTextLabel(toggleFrame, config.Text or "Toggle", UDim2.new(0.7, 0, 1, 0), UDim2.new(0, 10, 0, 0))
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 50, 0, 24)
    toggleButton.Position = UDim2.new(0.85, -30, 0.5, -12)
    toggleButton.Text = ""
    toggleButton.BackgroundColor3 = self._themes[self._currentTheme].Secondary
    toggleButton.AutoButtonColor = false
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 20, 0, 20)
    toggleCircle.Position = UDim2.new(0, 3, 0.5, -10)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.Parent = toggleButton
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = toggleCircle
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = toggleButton
    
    toggleButton.Parent = toggleFrame
    
    local state = config.Default or false
    
    local function updateToggle()
        if state then
            game:GetService("TweenService"):Create(toggleCircle, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 27, 0.5, -10)
            }):Play()
            toggleButton.BackgroundColor3 = self._themes[self._currentTheme].Success
        else
            game:GetService("TweenService"):Create(toggleCircle, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 3, 0.5, -10)
            }):Play()
            toggleButton.BackgroundColor3 = self._themes[self._currentTheme].Secondary
        end
    end
    
    updateToggle()
    
    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        updateToggle()
        
        if config.OnToggle then
            local success, err = pcall(config.OnToggle, state)
            if not success then
                warn("[Toggle] Ошибка в обработчике OnToggle:", err)
            end
        end
    end)
    
    local toggle = {
        _frame = toggleFrame,
        _button = toggleButton,
        GetState = function() return state end,
        SetState = function(newState)
            state = newState
            updateToggle()
        end
    }
    
    local elementName = config.Name or "Toggle_" .. tostring(#self._elements + 1)
    self._elements[elementName] = toggle
    
    return toggle
end

-- Создание слайдера
function ExecutorUILibrary:CreateSlider(config)
    config = config or {}
    
    local sliderFrame = createRoundedFrame(self._screenGui, config.Size or UDim2.new(0, 250, 0, 60), config.Position or UDim2.new(0, 20, 0, 140))
    
    local sliderText = createTextLabel(sliderFrame, config.Text or "Slider: 50%", UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 5))
    
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, -20, 0, 10)
    sliderTrack.Position = UDim2.new(0, 10, 0, 35)
    sliderTrack.BackgroundColor3 = self._themes[self._currentTheme].Secondary
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = sliderTrack
    
    sliderTrack.Parent = sliderFrame
    
    local sliderThumb = Instance.new("Frame")
    sliderThumb.Size = UDim2.new(0, 20, 0, 20)
    sliderThumb.BackgroundColor3 = self._themes[self._currentTheme].Primary
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = sliderThumb
    
    sliderThumb.Parent = sliderTrack
    
    local min = config.Min or 0
    local max = config.Max or 100
    local value = config.Default or 50
    
    local function updateSlider(mouseX)
        if not sliderTrack then return end
        
        local absolutePosition = sliderTrack.AbsolutePosition
        local absoluteSize = sliderTrack.AbsoluteSize
        
        if not absolutePosition or not absoluteSize then return end
        
        local relativeX = math.clamp(mouseX - absolutePosition.X, 0, absoluteSize.X)
        local percentage = relativeX / absoluteSize.X
        
        value = math.floor(min + (max - min) * percentage)
        
        sliderThumb.Position = UDim2.new(percentage, -10, 0.5, -10)
        sliderText.Text = string.format("%s: %d/%d", config.Text or "Slider", value, max)
        
        if config.OnChange then
            local success, err = pcall(config.OnChange, value)
            if not success then
                warn("[Slider] Ошибка в обработчике OnChange:", err)
            end
        end
    end
    
    sliderThumb.Position = UDim2.new((value - min) / (max - min), -10, 0.5, -10)
    sliderText.Text = string.format("%s: %d/%d", config.Text or "Slider", value, max)
    
    local dragging = false
    
    sliderThumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    sliderThumb.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input.Position.X)
        end
    end)
    
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input.Position.X)
        end
    end)
    
    local slider = {
        _frame = sliderFrame,
        GetValue = function() return value end,
        SetValue = function(newValue)
            value = math.clamp(newValue, min, max)
            sliderThumb.Position = UDim2.new((value - min) / (max - min), -10, 0.5, -10)
            sliderText.Text = string.format("%s: %d/%d", config.Text or "Slider", value, max)
        end
    }
    
    local elementName = config.Name or "Slider_" .. tostring(#self._elements + 1)
    self._elements[elementName] = slider
    
    return slider
end

-- Создание выпадающего списка
function ExecutorUILibrary:CreateDropdown(config)
    config = config or {}
    
    local dropdownFrame = createRoundedFrame(self._screenGui, config.Size or UDim2.new(0, 200, 0, 40), config.Position or UDim2.new(0, 20, 0, 220))
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(1, 0, 1, 0)
    dropdownButton.Text = config.Default or "Select..."
    dropdownButton.TextColor3 = self._themes[self._currentTheme].Text
    dropdownButton.BackgroundTransparency = 1
    dropdownButton.TextSize = 14
    dropdownButton.Font = Enum.Font.Gotham
    dropdownButton.Parent = dropdownFrame
    
    local dropdownIcon = Instance.new("TextLabel")
    dropdownIcon.Size = UDim2.new(0, 20, 1, 0)
    dropdownIcon.Position = UDim2.new(1, -25, 0, 0)
    dropdownIcon.Text = "▼"
    dropdownIcon.TextColor3 = self._themes[self._currentTheme].Text
    dropdownIcon.BackgroundTransparency = 1
    dropdownIcon.TextSize = 12
    dropdownIcon.Font = Enum.Font.Gotham
    dropdownIcon.Parent = dropdownFrame
    
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Size = UDim2.new(1, 0, 0, 0)
    optionsFrame.Position = UDim2.new(0, 0, 1, 5)
    optionsFrame.BackgroundColor3 = self._themes[self._currentTheme].Secondary
    optionsFrame.Visible = false
    optionsFrame.ClipsDescendants = true
    
    local optionsCorner = Instance.new("UICorner")
    optionsCorner.CornerRadius = UDim.new(0, 8)
    optionsCorner.Parent = optionsFrame
    
    optionsFrame.Parent = dropdownFrame
    
    local selected = config.Default or "Select..."
    local options = config.Options or {"Option 1", "Option 2", "Option 3"}
    
    local function updateOptions()
        optionsFrame:ClearAllChildren()
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.Parent = optionsFrame
        
        for i, option in ipairs(options) do
            local optionButton = Instance.new("TextButton")
            optionButton.Size = UDim2.new(1, 0, 0, 30)
            optionButton.Text = option
            optionButton.TextColor3 = self._themes[self._currentTheme].Text
            optionButton.BackgroundColor3 = self._themes[self._currentTheme].Secondary
            optionButton.BackgroundTransparency = 0
            optionButton.TextSize = 14
            optionButton.Font = Enum.Font.Gotham
            optionButton.AutoButtonColor = false
            optionButton.Parent = optionsFrame
            
            optionButton.MouseEnter:Connect(function()
                optionButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            end)
            
            optionButton.MouseLeave:Connect(function()
                optionButton.BackgroundColor3 = self._themes[self._currentTheme].Secondary
            end)
            
            optionButton.MouseButton1Click:Connect(function()
                selected = option
                dropdownButton.Text = option
                optionsFrame.Visible = false
                
                if config.OnSelect then
                    local success, err = pcall(config.OnSelect, option)
                    if not success then
                        warn("[Dropdown] Ошибка в обработчике OnSelect:", err)
                    end
                end
            end)
        end
        
        optionsFrame.Size = UDim2.new(1, 0, 0, #options * 30)
    end
    
    updateOptions()
    
    dropdownButton.MouseButton1Click:Connect(function()
        optionsFrame.Visible = not optionsFrame.Visible
    end)
    
    local dropdown = {
        _frame = dropdownFrame,
        GetSelected = function() return selected end,
        SetOptions = function(newOptions)
            if type(newOptions) == "table" then
                options = newOptions
                updateOptions()
            else
                warn("[Dropdown] SetOptions ожидает таблицу")
            end
        end
    }
    
    local elementName = config.Name or "Dropdown_" .. tostring(#self._elements + 1)
    self._elements[elementName] = dropdown
    
    return dropdown
end

-- Создание консоли для вывода
function ExecutorUILibrary:CreateConsole(config)
    config = config or {}
    
    local consoleFrame = createRoundedFrame(self._screenGui, config.Size or UDim2.new(0, 400, 0, 300), config.Position or UDim2.new(0.5, -200, 0.5, -150))
    
    local consoleHeader = createTextLabel(consoleFrame, config.Title or "Console", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 5))
    consoleHeader.TextSize = 16
    consoleHeader.Font = Enum.Font.GothamBold
    
    local consoleOutput = Instance.new("ScrollingFrame")
    consoleOutput.Size = UDim2.new(1, -20, 1, -70)
    consoleOutput.Position = UDim2.new(0, 10, 0, 40)
    consoleOutput.BackgroundTransparency = 1
    consoleOutput.ScrollBarThickness = 6
    consoleOutput.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local outputList = Instance.new("UIListLayout")
    outputList.Parent = consoleOutput
    
    consoleOutput.Parent = consoleFrame
    
    local inputFrame = createRoundedFrame(consoleFrame, UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 1, -35))
    inputFrame.BackgroundColor3 = self._themes[self._currentTheme].Secondary
    
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, -10, 1, 0)
    inputBox.Position = UDim2.new(0, 5, 0, 0)
    inputBox.Text = ""
    inputBox.TextColor3 = self._themes[self._currentTheme].Text
    inputBox.BackgroundTransparency = 1
    inputBox.TextSize = 14
    inputBox.Font = Enum.Font.Gotham
    inputBox.PlaceholderText = "Type command here..."
    inputBox.Parent = inputFrame
    
    local function addMessage(message, messageType)
        if not message then return end
        
        local messageLabel = Instance.new("TextLabel")
        messageLabel.Size = UDim2.new(1, 0, 0, 20)
        messageLabel.Text = "> " .. tostring(message)
        
        if messageType == "error" then
            messageLabel.TextColor3 = self._themes[self._currentTheme].Error
        elseif messageType == "success" then
            messageLabel.TextColor3 = self._themes[self._currentTheme].Success
        elseif messageType == "warning" then
            messageLabel.TextColor3 = self._themes[self._currentTheme].Warning
        else
            messageLabel.TextColor3 = self._themes[self._currentTheme].Text
        end
        
        messageLabel.BackgroundTransparency = 1
        messageLabel.TextSize = 12
        messageLabel.Font = Enum.Font.Gotham
        messageLabel.TextXAlignment = Enum.TextXAlignment.Left
        messageLabel.TextYAlignment = Enum.TextYAlignment.Top
        messageLabel.TextWrapped = true
        
        messageLabel.Parent = consoleOutput
        
        -- Автоскролл вниз
        task.wait()
        consoleOutput.CanvasPosition = Vector2.new(0, consoleOutput.CanvasPosition.Y + 100)
    end
    
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and inputBox.Text ~= "" then
            local command = inputBox.Text
            inputBox.Text = ""
            
            addMessage(command, "input")
            
            if config.OnCommand then
                local success, result = pcall(config.OnCommand, command)
                if success then
                    addMessage(result or "Command executed", "success")
                else
                    addMessage("Error: " .. tostring(result), "error")
                end
            end
        end
    end)
    
    local console = {
        _frame = consoleFrame,
        Log = function(message, messageType)
            addMessage(message, messageType or "info")
        end,
        Clear = function()
            consoleOutput:ClearAllChildren()
            local listLayout = Instance.new("UIListLayout")
            listLayout.Parent = consoleOutput
        end
    }
    
    local elementName = config.Name or "Console"
    self._elements[elementName] = console
    
    return console
end

-- Создание панели исполнителя
function ExecutorUILibrary:CreateExecutorPanel(config)
    config = config or {}
    
    local panelFrame = createRoundedFrame(self._screenGui, config.Size or UDim2.new(0, 500, 0, 400), config.Position or UDim2.new(0.5, -250, 0.5, -200))
    
    local header = createTextLabel(panelFrame, config.Title or "Executor Panel", UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 0, 5))
    header.TextSize = 20
    header.Font = Enum.Font.GothamBold
    
    local scriptInput = Instance.new("TextBox")
    scriptInput.Size = UDim2.new(1, -20, 0.6, -50)
    scriptInput.Position = UDim2.new(0, 10, 0, 50)
    scriptInput.Text = config.DefaultScript or "-- Enter your script here"
    scriptInput.TextColor3 = self._themes[self._currentTheme].Text
    scriptInput.BackgroundColor3 = self._themes[self._currentTheme].Secondary
    scriptInput.TextSize = 12
    scriptInput.Font = Enum.Font.Code
    scriptInput.TextXAlignment = Enum.TextXAlignment.Left
    scriptInput.TextYAlignment = Enum.TextYAlignment.Top
    scriptInput.TextWrapped = true
    scriptInput.ClearTextOnFocus = false
    scriptInput.MultiLine = true
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = scriptInput
    
    scriptInput.Parent = panelFrame
    
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(1, -20, 0, 40)
    buttonContainer.Position = UDim2.new(0, 10, 0.65, 10)
    buttonContainer.BackgroundTransparency = 1
    
    local executeButton = Instance.new("TextButton")
    executeButton.Size = UDim2.new(0, 120, 1, 0)
    executeButton.Position = UDim2.new(0, 0, 0, 0)
    executeButton.Text = "Execute"
    executeButton.TextColor3 = self._themes[self._currentTheme].Text
    executeButton.BackgroundColor3 = self._themes[self._currentTheme].Success
    executeButton.TextSize = 14
    executeButton.Font = Enum.Font.GothamBold
    
    local executeCorner = Instance.new("UICorner")
    executeCorner.CornerRadius = UDim.new(0, 6)
    executeCorner.Parent = executeButton
    
    executeButton.Parent = buttonContainer
    
    local clearButton = Instance.new("TextButton")
    clearButton.Size = UDim2.new(0, 120, 1, 0)
    clearButton.Position = UDim2.new(0, 130, 0, 0)
    clearButton.Text = "Clear"
    clearButton.TextColor3 = self._themes[self._currentTheme].Text
    clearButton.BackgroundColor3 = self._themes[self._currentTheme].Warning
    clearButton.TextSize = 14
    clearButton.Font = Enum.Font.GothamBold
    
    local clearCorner = Instance.new("UICorner")
    clearCorner.CornerRadius = UDim.new(0, 6)
    clearCorner.Parent = clearButton
    
    clearButton.Parent = buttonContainer
    
    buttonContainer.Parent = panelFrame
    
    local outputFrame = Instance.new("ScrollingFrame")
    outputFrame.Size = UDim2.new(1, -20, 0.3, -10)
    outputFrame.Position = UDim2.new(0, 10, 0.75, 0)
    outputFrame.BackgroundColor3 = self._themes[self._currentTheme].Secondary
    outputFrame.ScrollBarThickness = 6
    
    local outputCorner = Instance.new("UICorner")
    outputCorner.CornerRadius = UDim.new(0, 6)
    outputCorner.Parent = outputFrame
    
    local outputText = Instance.new("TextLabel")
    outputText.Size = UDim2.new(1, -10, 0, 100)
    outputText.Position = UDim2.new(0, 5, 0, 5)
    outputText.Text = "Output will appear here..."
    outputText.TextColor3 = self._themes[self._currentTheme].Text
    outputText.BackgroundTransparency = 1
    outputText.TextSize = 12
    outputText.Font = Enum.Font.Code
    outputText.TextXAlignment = Enum.TextXAlignment.Left
    outputText.TextYAlignment = Enum.TextYAlignment.Top
    outputText.TextWrapped = true
    outputText.Parent = outputFrame
    
    outputFrame.Parent = panelFrame
    
    local function executeScript()
        local script = scriptInput.Text
        outputText.Text = "Executing..."
        
        -- Безопасное выполнение
        local success, result = pcall(function()
            -- В реальном скрипте исполнителя здесь будет loadstring
            -- Пример для Roblox:
            -- local func, err = loadstring(script)
            -- if func then
            --     return func()
            -- else
            --     error(err)
            -- end
            
            -- Для демонстрации просто возвращаем сообщение
            return "Script executed (simulated mode)"
        end)
        
        if success then
            outputText.Text = "Success: " .. tostring(result)
        else
            outputText.Text = "Error: " .. tostring(result)
        end
    end
    
    executeButton.MouseButton1Click:Connect(executeScript)
    
    clearButton.MouseButton1Click:Connect(function()
        scriptInput.Text = ""
        outputText.Text = "Output cleared"
    end)
    
    local panel = {
        _frame = panelFrame,
        ExecuteScript = executeScript,
        GetScript = function() return scriptInput.Text end,
        SetScript = function(script) 
            if type(script) == "string" then
                scriptInput.Text = script 
            end
        end
    }
    
    local elementName = config.Name or "ExecutorPanel"
    self._elements[elementName] = panel
    self._executors[elementName] = panel
    
    return panel
end

-- Изменение темы
function ExecutorUILibrary:SetTheme(themeName)
    if self._themes[themeName] then
        self._currentTheme = themeName
        print("[ExecutorUILibrary] Тема изменена на: " .. themeName)
    else
        warn("[ExecutorUILibrary] Тема не найдена: " .. tostring(themeName))
    end
end

-- Показать/скрыть все элементы
function ExecutorUILibrary:ToggleVisibility(visible)
    if self._screenGui then
        self._screenGui.Enabled = visible
    end
end

-- Очистить все элементы
function ExecutorUILibrary:Clear()
    for _, element in pairs(self._elements) do
        if element and element._frame then
            element._frame:Destroy()
        end
    end
    self._elements = {}
    self._executors = {}
end

-- Получить информацию о библиотеке
function ExecutorUILibrary:GetInfo()
    local elementsCount = 0
    for _ in pairs(self._elements) do
        elementsCount = elementsCount + 1
    end
    
    local executorsCount = 0
    for _ in pairs(self._executors) do
        executorsCount = executorsCount + 1
    end
    
    return {
        Version = "1.1.0",
        ElementsCount = elementsCount,
        ExecutorsCount = executorsCount,
        CurrentTheme = self._currentTheme
    }
end

return ExecutorUILibrary
