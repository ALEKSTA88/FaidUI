local DragWindowUILibrary = {}
DragWindowUILibrary.__index = DragWindowUILibrary

-- Конфигурация
local CONFIG = {
    DEFAULT_THEME = "Dark",
    ANIMATIONS_ENABLED = true,
    WINDOW_HEADER_HEIGHT = 40,
    ELEMENT_SPACING = 10
}

-- Текущая тема
local currentTheme = {
    Dark = {
        Background = Color3.fromRGB(30, 30, 30),
        WindowBackground = Color3.fromRGB(40, 40, 40),
        Header = Color3.fromRGB(50, 50, 50),
        Primary = Color3.fromRGB(0, 120, 215),
        Secondary = Color3.fromRGB(60, 60, 60),
        Text = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(0, 200, 0),
        Error = Color3.fromRGB(255, 50, 50),
        Warning = Color3.fromRGB(255, 165, 0),
        CloseButton = Color3.fromRGB(255, 80, 80)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 240),
        WindowBackground = Color3.fromRGB(255, 255, 255),
        Header = Color3.fromRGB(220, 220, 220),
        Primary = Color3.fromRGB(0, 90, 180),
        Secondary = Color3.fromRGB(200, 200, 200),
        Text = Color3.fromRGB(0, 0, 0),
        Success = Color3.fromRGB(0, 150, 0),
        Error = Color3.fromRGB(200, 0, 0),
        Warning = Color3.fromRGB(200, 120, 0),
        CloseButton = Color3.fromRGB(255, 100, 100)
    }
}

-- Служебные функции
local function createRoundedFrame(parent, size, position, backgroundColor)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = backgroundColor or currentTheme[CONFIG.DEFAULT_THEME].Secondary
    frame.BackgroundTransparency = 0
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = frame
    
    if parent then
        frame.Parent = parent
    end
    
    return frame
end

local function createTextLabel(parent, text, size, position, options)
    options = options or {}
    local label = Instance.new("TextLabel")
    label.Size = size
    label.Position = position
    label.Text = text or ""
    label.TextColor3 = options.TextColor or currentTheme[CONFIG.DEFAULT_THEME].Text
    label.BackgroundTransparency = options.BackgroundTransparency or 1
    label.TextSize = options.TextSize or 14
    label.Font = options.Font or Enum.Font.Gotham
    label.TextXAlignment = options.TextXAlignment or Enum.TextXAlignment.Left
    label.TextYAlignment = options.TextYAlignment or Enum.TextYAlignment.Center
    
    if parent then
        label.Parent = parent
    end
    
    return label
end

-- Основной класс библиотеки
function DragWindowUILibrary.new(windowConfig)
    local self = setmetatable({}, DragWindowUILibrary)
    
    windowConfig = windowConfig or {}
    
    -- Создаем ScreenGui
    self._screenGui = Instance.new("ScreenGui")
    self._screenGui.Name = "DragWindowUILibrary"
    self._screenGui.ResetOnSpawn = false
    self._screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local player = game:GetService("Players").LocalPlayer
    if player then
        local playerGui = player:WaitForChild("PlayerGui")
        self._screenGui.Parent = playerGui
    else
        self._screenGui.Parent = game:GetService("StarterGui")
    end
    
    -- Создаем основное окно
    self._window = self:CreateWindow({
        Title = windowConfig.Title or "UI Window",
        Size = windowConfig.Size or UDim2.new(0, 400, 0, 500),
        Position = windowConfig.Position or UDim2.new(0.5, -200, 0.5, -250),
        Minimizable = windowConfig.Minimizable or true,
        Closable = windowConfig.Closable or true
    })
    
    self._elements = {}
    self._currentTheme = CONFIG.DEFAULT_THEME
    self._themes = currentTheme
    self._contentYOffset = CONFIG.WINDOW_HEADER_HEIGHT + CONFIG.ELEMENT_SPACING
    
    print("[DragWindowUILibrary] Библиотека инициализирована")
    return self
end

-- Создание перетаскиваемого окна
function DragWindowUILibrary:CreateWindow(config)
    config = config or {}
    
    local windowFrame = createRoundedFrame(self._screenGui, config.Size, config.Position, self._themes[self._currentTheme].WindowBackground)
    windowFrame.Name = "WindowFrame"
    
    -- Добавляем возможность перетаскивания
    local header = createRoundedFrame(windowFrame, UDim2.new(1, 0, 0, CONFIG.WINDOW_HEADER_HEIGHT), UDim2.new(0, 0, 0, 0), self._themes[self._currentTheme].Header)
    header.Name = "WindowHeader"
    
    -- Заголовок окна
    local titleLabel = createTextLabel(header, config.Title, UDim2.new(1, -80, 1, 0), UDim2.new(0, 10, 0, 0), {
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Контейнер для контента
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -CONFIG.WINDOW_HEADER_HEIGHT - CONFIG.ELEMENT_SPACING)
    contentFrame.Position = UDim2.new(0, 10, 0, CONFIG.WINDOW_HEADER_HEIGHT + 5)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ScrollBarThickness = 6
    contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentFrame.ScrollBarImageColor3 = self._themes[self._currentTheme].Secondary
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, CONFIG.ELEMENT_SPACING)
    contentLayout.Parent = contentFrame
    
    contentFrame.Parent = windowFrame
    
    -- Кнопка закрытия
    if config.Closable then
        local closeButton = Instance.new("TextButton")
        closeButton.Size = UDim2.new(0, 30, 0, 30)
        closeButton.Position = UDim2.new(1, -35, 0.5, -15)
        closeButton.Text = "×"
        closeButton.TextColor3 = self._themes[self._currentTheme].Text
        closeButton.BackgroundColor3 = self._themes[self._currentTheme].CloseButton
        closeButton.TextSize = 20
        closeButton.Font = Enum.Font.GothamBold
        
        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(1, 0)
        closeCorner.Parent = closeButton
        
        closeButton.Parent = header
        
        -- Анимация наведения для кнопки закрытия
        if CONFIG.ANIMATIONS_ENABLED then
            closeButton.MouseEnter:Connect(function()
                game:GetService("TweenService"):Create(closeButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                }):Play()
            end)
            
            closeButton.MouseLeave:Connect(function()
                game:GetService("TweenService"):Create(closeButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = self._themes[self._currentTheme].CloseButton
                }):Play()
            end)
        end
        
        closeButton.MouseButton1Click:Connect(function()
            self:Destroy()
        end)
    end
    
    -- Функционал перетаскивания окна
    local dragging = false
    local dragStart
    local startPos
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = windowFrame.Position
            
            if CONFIG.ANIMATIONS_ENABLED then
                game:GetService("TweenService"):Create(header, TweenInfo.new(0.1), {
                    BackgroundTransparency = 0.3
                }):Play()
            end
        end
    end)
    
    header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            
            if CONFIG.ANIMATIONS_ENABLED then
                game:GetService("TweenService"):Create(header, TweenInfo.new(0.1), {
                    BackgroundTransparency = 0
                }):Play()
            end
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            windowFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Сохраняем ссылки на элементы окна
    self._windowFrame = windowFrame
    self._contentFrame = contentFrame
    self._windowHeader = header
    
    return {
        Frame = windowFrame,
        Content = contentFrame,
        Header = header,
        SetTitle = function(newTitle)
            titleLabel.Text = newTitle
        end
    }
end

-- Вспомогательная функция для добавления элемента в окно
function DragWindowUILibrary:_addElementToContent(elementFrame, config)
    elementFrame.Parent = self._contentFrame
    
    local elementName = config.Name or "Element_" .. tostring(#self._elements + 1)
    self._elements[elementName] = {
        Frame = elementFrame,
        Config = config
    }
    
    return elementName
end

-- Создание кнопки
function DragWindowUILibrary:CreateButton(config)
    config = config or {}
    
    local buttonFrame = createRoundedFrame(nil, config.Size or UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), self._themes[self._currentTheme].Primary)
    
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
    
    buttonText.MouseButton1Click:Connect(function()
        if config.OnClick then
            local success, err = pcall(config.OnClick)
            if not success then
                warn("[Button] Ошибка в обработчике OnClick:", err)
            end
        end
    end)
    
    local elementName = self:_addElementToContent(buttonFrame, config)
    
    return {
        Name = elementName,
        Frame = buttonFrame,
        SetText = function(newText)
            buttonText.Text = newText
        end,
        SetEnabled = function(enabled)
            buttonText.Active = enabled
            buttonText.TextTransparency = enabled and 0 or 0.5
        end
    }
end

-- Создание переключателя
function DragWindowUILibrary:CreateToggle(config)
    config = config or {}
    
    local toggleFrame = createRoundedFrame(nil, config.Size or UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), self._themes[self._currentTheme].Secondary)
    
    local toggleText = createTextLabel(toggleFrame, config.Text or "Toggle", UDim2.new(0.7, 0, 1, 0), UDim2.new(0, 10, 0, 0), {
        TextYAlignment = Enum.TextYAlignment.Center
    })
    
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
    
    local elementName = self:_addElementToContent(toggleFrame, config)
    
    return {
        Name = elementName,
        Frame = toggleFrame,
        GetState = function() return state end,
        SetState = function(newState)
            state = newState
            updateToggle()
        end
    }
end

-- Создание слайдера
function DragWindowUILibrary:CreateSlider(config)
    config = config or {}
    
    local sliderFrame = createRoundedFrame(nil, config.Size or UDim2.new(1, 0, 0, 60), UDim2.new(0, 0, 0, 0), self._themes[self._currentTheme].Secondary)
    
    local sliderText = createTextLabel(sliderFrame, config.Text or "Slider: 50%", UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 5), {
        TextYAlignment = Enum.TextYAlignment.Top
    })
    
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
    
    local elementName = self:_addElementToContent(sliderFrame, config)
    
    return {
        Name = elementName,
        Frame = sliderFrame,
        GetValue = function() return value end,
        SetValue = function(newValue)
            value = math.clamp(newValue, min, max)
            sliderThumb.Position = UDim2.new((value - min) / (max - min), -10, 0.5, -10)
            sliderText.Text = string.format("%s: %d/%d", config.Text or "Slider", value, max)
        end
    }
end

-- Создание выпадающего списка
function DragWindowUILibrary:CreateDropdown(config)
    config = config or {}
    
    local dropdownFrame = createRoundedFrame(nil, config.Size or UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), self._themes[self._currentTheme].Secondary)
    
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
    optionsFrame.ZIndex = 10
    
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
            optionButton.ZIndex = 11
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
    
    -- Закрытие при клике вне списка
    local function closeDropdown()
        optionsFrame.Visible = false
    end
    
    dropdownFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = input.Position
            local absolutePos = optionsFrame.AbsolutePosition
            local absoluteSize = optionsFrame.AbsoluteSize
            
            if absolutePos and absoluteSize then
                if mousePos.X < absolutePos.X or mousePos.X > absolutePos.X + absoluteSize.X or
                   mousePos.Y < absolutePos.Y or mousePos.Y > absolutePos.Y + absoluteSize.Y then
                    closeDropdown()
                end
            end
        end
    end)
    
    local elementName = self:_addElementToContent(dropdownFrame, config)
    
    return {
        Name = elementName,
        Frame = dropdownFrame,
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
end

-- Создание текстового поля
function DragWindowUILibrary:CreateTextBox(config)
    config = config or {}
    
    local textBoxFrame = createRoundedFrame(nil, config.Size or UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), self._themes[self._currentTheme].Secondary)
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -20, 1, 0)
    textBox.Position = UDim2.new(0, 10, 0, 0)
    textBox.Text = config.Default or ""
    textBox.TextColor3 = self._themes[self._currentTheme].Text
    textBox.BackgroundTransparency = 1
    textBox.TextSize = 14
    textBox.Font = Enum.Font.Gotham
    textBox.PlaceholderText = config.Placeholder or "Enter text..."
    textBox.ClearTextOnFocus = config.ClearOnFocus or false
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.Parent = textBoxFrame
    
    if config.MultiLine then
        textBox.MultiLine = true
        textBox.TextYAlignment = Enum.TextYAlignment.Top
        textBoxFrame.Size = config.Size or UDim2.new(1, 0, 0, 80)
    end
    
    textBox.FocusLost:Connect(function(enterPressed)
        if config.OnTextChanged then
            local success, err = pcall(config.OnTextChanged, textBox.Text, enterPressed)
            if not success then
                warn("[TextBox] Ошибка в обработчике OnTextChanged:", err)
            end
        end
    end)
    
    local elementName = self:_addElementToContent(textBoxFrame, config)
    
    return {
        Name = elementName,
        Frame = textBoxFrame,
        GetText = function() return textBox.Text end,
        SetText = function(newText)
            textBox.Text = newText or ""
        end
    }
end

-- Создание метки (текста)
function DragWindowUILibrary:CreateLabel(config)
    config = config or {}
    
    local labelFrame = createRoundedFrame(nil, config.Size or UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0))
    labelFrame.BackgroundTransparency = 1
    
    local label = createTextLabel(labelFrame, config.Text or "Label", UDim2.new(1, -20, 1, 0), UDim2.new(0, 10, 0, 0), {
        TextSize = config.TextSize or 14,
        Font = config.Font or Enum.Font.Gotham,
        TextYAlignment = Enum.TextYAlignment.Center
    })
    
    if config.Center then
        label.TextXAlignment = Enum.TextXAlignment.Center
    end
    
    local elementName = self:_addElementToContent(labelFrame, config)
    
    return {
        Name = elementName,
        Frame = labelFrame,
        SetText = function(newText)
            label.Text = newText
        end
    }
end

-- Создание разделителя
function DragWindowUILibrary:CreateSeparator(config)
    config = config or {}
    
    local separatorFrame = Instance.new("Frame")
    separatorFrame.Size = config.Size or UDim2.new(1, 0, 0, 1)
    separatorFrame.BackgroundColor3 = self._themes[self._currentTheme].Secondary
    separatorFrame.BorderSizePixel = 0
    
    local elementName = self:_addElementToContent(separatorFrame, config)
    
    return {
        Name = elementName,
        Frame = separatorFrame
    }
end

-- Изменение темы
function DragWindowUILibrary:SetTheme(themeName)
    if self._themes[themeName] then
        self._currentTheme = themeName
        
        -- Обновляем цвета окна
        if self._windowFrame then
            self._windowFrame.BackgroundColor3 = self._themes[themeName].WindowBackground
        end
        
        if self._windowHeader then
            self._windowHeader.BackgroundColor3 = self._themes[themeName].Header
        end
        
        print("[DragWindowUILibrary] Тема изменена на: " .. themeName)
    else
        warn("[DragWindowUILibrary] Тема не найдена: " .. tostring(themeName))
    end
end

-- Показать/скрыть окно
function DragWindowUILibrary:SetVisible(visible)
    if self._screenGui then
        self._screenGui.Enabled = visible
    end
end

-- Переместить окно
function DragWindowUILibrary:SetPosition(position)
    if self._windowFrame and position then
        self._windowFrame.Position = position
    end
end

-- Изменить размер окна
function DragWindowUILibrary:SetSize(size)
    if self._windowFrame and size then
        self._windowFrame.Size = size
        if self._contentFrame then
            self._contentFrame.Size = UDim2.new(1, -20, 1, -CONFIG.WINDOW_HEADER_HEIGHT - CONFIG.ELEMENT_SPACING)
        end
    end
end

-- Изменить заголовок окна
function DragWindowUILibrary:SetTitle(title)
    if self._window and title then
        self._window.SetTitle(title)
    end
end

-- Очистить все элементы
function DragWindowUILibrary:ClearContent()
    if self._contentFrame then
        self._contentFrame:ClearAllChildren()
        
        -- Восстанавливаем UIListLayout
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, CONFIG.ELEMENT_SPACING)
        contentLayout.Parent = self._contentFrame
        
        self._elements = {}
    end
end

-- Получить элемент по имени
function DragWindowUILibrary:GetElement(elementName)
    return self._elements[elementName]
end

-- Удалить элемент по имени
function DragWindowUILibrary:RemoveElement(elementName)
    local element = self._elements[elementName]
    if element and element.Frame then
        element.Frame:Destroy()
        self._elements[elementName] = nil
    end
end

-- Получить информацию о библиотеке
function DragWindowUILibrary:GetInfo()
    local elementsCount = 0
    for _ in pairs(self._elements) do
        elementsCount = elementsCount + 1
    end
    
    return {
        Version = "1.2.0",
        ElementsCount = elementsCount,
        CurrentTheme = self._currentTheme,
        WindowVisible = self._screenGui and self._screenGui.Enabled or false
    }
end

-- Уничтожить окно и все элементы
function DragWindowUILibrary:Destroy()
    if self._screenGui then
        self._screenGui:Destroy()
    end
    self._elements = {}
    print("[DragWindowUILibrary] Окно уничтожено")
end

-- Переключить видимость окна
function DragWindowUILibrary:ToggleVisibility()
    if self._screenGui then
        self._screenGui.Enabled = not self._screenGui.Enabled
    end
end

return DragWindowUILibrary
