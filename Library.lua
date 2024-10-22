local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Utility functions
local function formatNumber(number)
    if number >= 10^6 then
        return string.format("%.2fm", number / 10^6)
    elseif number >= 10^3 then
        return string.format("%.2fk", number / 10^3)
    end
    return tostring(number)
end

local function toInteger(number)
    local str = tostring(number)
    local dotIndex = str:find('%.')
    return dotIndex and tonumber(str:sub(1, dotIndex - 1)) or number
end

local function makeDraggable(frame)
    local dragToggle, dragSpeed, dragStart, startPos = nil, 0.25

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragToggle then
                local delta = input.Position - dragStart
                local position = UDim2.new(
                    startPos.X.Scale, 
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale, 
                    startPos.Y.Offset + delta.Y
                )
                TweenService:Create(frame, TweenInfo.new(dragSpeed), {Position = position}):Play()
            end
        end
    end)
end

-- Theme configuration
local DefaultTheme = {
    MainColor = Color3.fromRGB(0, 255, 179),
    BackgroundColor = Color3.fromRGB(18, 18, 18),
    BackgroundColor2 = Color3.fromRGB(33, 33, 33),
}

function Library:Create(name, theme)
    local gui = {
        theme = theme or DefaultTheme,
        elements = {}
    }

    -- Create main GUI elements
    gui.ScreenGui = Instance.new("ScreenGui")
    gui.ScreenGui.Name = name or "Enhanced UI Library"
    gui.ScreenGui.Parent = game.CoreGui
    gui.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    gui.MainFrame = Instance.new("Frame")
    gui.MainFrame.Name = "MainContainer"
    gui.MainFrame.Parent = gui.ScreenGui
    gui.MainFrame.BackgroundColor3 = gui.theme.BackgroundColor
    gui.MainFrame.BorderColor3 = gui.theme.MainColor
    gui.MainFrame.Position = UDim2.new(0.22, 0, 0.115, 0)
    gui.MainFrame.Size = UDim2.new(0, 412, 0, 441)

    -- Make the main frame draggable
    makeDraggable(gui.MainFrame)

    -- Create title
    gui.TitleLabel = Instance.new("TextLabel")
    gui.TitleLabel.Parent = gui.MainFrame
    gui.TitleLabel.BackgroundTransparency = 1
    gui.TitleLabel.Position = UDim2.new(0.02, 0, 0, 0)
    gui.TitleLabel.Size = UDim2.new(0, 170, 0, 23)
    gui.TitleLabel.Font = Enum.Font.Code
    gui.TitleLabel.Text = name or "Enhanced UI"
    gui.TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    gui.TitleLabel.TextSize = 14
    gui.TitleLabel.RichText = true
    gui.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Create background container
    gui.Background = Instance.new("ImageLabel")
    gui.Background.Name = "BackgroundContainer"
    gui.Background.Parent = gui.MainFrame
    gui.Background.BackgroundColor3 = gui.theme.BackgroundColor
    gui.Background.BorderColor3 = gui.theme.MainColor
    gui.Background.Position = UDim2.new(0.02, 0, 0.051, 0)
    gui.Background.Size = UDim2.new(0, 395, 0, 408)
    gui.Background.Image = "rbxassetid://10052054503"
    gui.Background.ImageColor3 = Color3.fromRGB(8, 8, 8)

    -- Create top bar
    gui.TopBar = Instance.new("Frame")
    gui.TopBar.Name = "TopBar"
    gui.TopBar.Parent = gui.Background
    gui.TopBar.BackgroundColor3 = gui.theme.BackgroundColor2
    gui.TopBar.BorderColor3 = gui.theme.MainColor
    gui.TopBar.Position = UDim2.new(0, 0, 0, 0)
    gui.TopBar.Size = UDim2.new(0, 395, 0, 23)

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = gui.TopBar
    UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    -- Enhanced API methods
    function gui:SetTitle(title)
        gui.TitleLabel.Text = title or "Enhanced UI"
    end

    function gui:CreateTab(name, visible)
        local tab = {
            name = name,
            visible = visible or false,
            elements = {}
        }

        -- Create tab button
        tab.Button = Instance.new("TextButton")
        tab.Button.Parent = gui.TopBar
        tab.Button.BackgroundColor3 = gui.theme.MainColor
        tab.Button.BackgroundTransparency = visible and 0 or 1
        tab.Button.BorderSizePixel = 0
        tab.Button.Size = UDim2.new(0, string.len(name) * 10, 0, 23)
        tab.Button.Font = Enum.Font.Code
        tab.Button.Text = name
        tab.Button.TextColor3 = visible and Color3.new(0, 0, 0) or Color3.fromRGB(163, 163, 163)
        tab.Button.TextSize = 13

        -- Create tab container
        tab.Container = Instance.new("Frame")
        tab.Container.Parent = gui.Background
        tab.Container.BackgroundTransparency = 1
        tab.Container.Position = UDim2.new(0.023, 0, 0.056, 0)
        tab.Container.Size = UDim2.new(0, 376, 0, 370)
        tab.Container.Visible = visible

        -- Setup tab switching
        tab.Button.MouseButton1Click:Connect(function()
            -- Hide all other tabs
            for _, otherTab in pairs(gui.elements) do
                if otherTab.Container then
                    otherTab.Container.Visible = false
                    TweenService:Create(otherTab.Button, TweenInfo.new(0.2), {
                        BackgroundTransparency = 1,
                        TextColor3 = Color3.fromRGB(163, 163, 163)
                    }):Play()
                end
            end

            -- Show this tab
            tab.Container.Visible = true
            TweenService:Create(tab.Button, TweenInfo.new(0.2), {
                BackgroundTransparency = 0,
                TextColor3 = Color3.new(0, 0, 0)
            }):Play()
        end)

        -- Add tab to GUI elements
        table.insert(gui.elements, tab)

        -- Enhanced tab methods
        function tab:CreateSection(title)
            local section = {
                elements = {}
            }

            -- Create section container
            section.Container = Instance.new("Frame")
            section.Container.Parent = tab.Container
            section.Container.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
            section.Container.BorderColor3 = Color3.fromRGB(53, 53, 53)
            section.Container.BorderMode = Enum.BorderMode.Inset
            section.Container.Size = UDim2.new(0, 184, 0, 30) -- Initial size

            -- Create section title
            section.Title = Instance.new("TextLabel")
            section.Title.Parent = section.Container
            section.Title.BackgroundTransparency = 1
            section.Title.Position = UDim2.new(0.05, 0, 0, 0)
            section.Title.Size = UDim2.new(0.95, 0, 0, 20)
            section.Title.Font = Enum.Font.Code
            section.Title.Text = title
            section.Title.TextColor3 = Color3.fromRGB(163, 163, 163)
            section.Title.TextSize = 12
            section.Title.TextXAlignment = Enum.TextXAlignment.Left

            -- Create elements container
            section.ElementsContainer = Instance.new("Frame")
            section.ElementsContainer.Parent = section.Container
            section.ElementsContainer.BackgroundTransparency = 1
            section.ElementsContainer.Position = UDim2.new(0, 0, 0, 25)
            section.ElementsContainer.Size = UDim2.new(1, 0, 0, 0)

            local UIListLayout = Instance.new("UIListLayout")
            UIListLayout.Parent = section.ElementsContainer
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout.Padding = UDim.new(0, 5)

            -- Auto-size section based on contents
            RunService.RenderStepped:Connect(function()
                section.Container.Size = UDim2.new(0, 184, 0, section.ElementsContainer.Size.Y.Offset + 35)
            end)

            -- Section methods (Button, Toggle, Slider, etc.)
            -- ... (Implementation of individual UI elements would go here)

            return section
        end

        return tab
    end

    return gui
end

return Library