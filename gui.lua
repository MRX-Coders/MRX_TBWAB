-- MRX_TBWAB V2.0 GUI Engine [Studio-Safe Version]
-- Aesthetic: Raiden, God of Thunder
-- Built for standard Roblox Game environments (PlayerGui)

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ThunderLibrary = {}
ThunderLibrary.__index = ThunderLibrary

-- [THUNDER LOGIC] Theme Constants
ThunderLibrary.Theme = {
    Background = Color3.fromRGB(10, 10, 12),     -- Deep Obsidian
    Primary = Color3.fromRGB(0, 180, 255),       -- Electric Cyan
    Secondary = Color3.fromRGB(75, 0, 130),      -- Phantom Purple
    Inactive = Color3.fromRGB(30, 30, 35),       -- Dim Gray
    Text = Color3.fromRGB(240, 240, 255)         -- Bright White/Cyan tint
}

-- [THUNDER LOGIC] Utility Functions
local function ApplyCorner(target, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = target
    return corner
end

local function ApplyStroke(target, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = target
    return stroke
end

-- Frame-Independent Smooth Dragging Using Sine Easing
local function MakeDraggableSmooth(topbar, object)
    local dragging = false
    local dragInput, dragStart, startPos

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local targetPos = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X, 
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            TweenService:Create(object, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = targetPos}):Play()
        end
    end)
end

-- [THUNDER LOGIC] Core Window Class
function ThunderLibrary:CreateWindow(titleText)
    local Window = {}
    
    -- Main Gui Setup (Memory Safe parenting to PlayerGui)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MRX_TBWAB_ENGINE"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui
    Window.ScreenGui = ScreenGui

    -- Destroy method for memory cleanups
    function Window:Destroy()
        -- Handles full garbage collection internally when ScreenGui is destroyed
        Self.ScreenGui:Destroy()
    end
    
    -- Main Layout Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 550, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
    MainFrame.BackgroundColor3 = self.Theme.Background
    MainFrame.Parent = ScreenGui
    ApplyCorner(MainFrame, 8)
    ApplyStroke(MainFrame, self.Theme.Primary, 2, 0.2)
    
    -- Header Segment
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundTransparency = 1
    Header.Parent = MainFrame
    
    MakeDraggableSmooth(Header, MainFrame)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = titleText or "MRX_TBWAB [STABLE]"
    Title.TextColor3 = self.Theme.Text
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    local LightningIcon = Instance.new("TextLabel")
    LightningIcon.Size = UDim2.new(0, 40, 1, 0)
    LightningIcon.Position = UDim2.new(1, -45, 0, 0)
    LightningIcon.BackgroundTransparency = 1
    LightningIcon.Text = "⚡"
    LightningIcon.TextColor3 = self.Theme.Primary
    LightningIcon.TextSize = 22
    LightningIcon.Parent = Header

    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(1, 0, 0, 1)
    Divider.Position = UDim2.new(0, 0, 1, 0)
    Divider.BackgroundColor3 = self.Theme.Primary
    Divider.BorderSizePixel = 0
    Divider.BackgroundTransparency = 0.5
    Divider.Parent = Header

    -- Body Container
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -20, 1, -65)
    Content.Position = UDim2.new(0, 10, 0, 55)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame
    
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(0, 140, 1, 0)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Content
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 6)
    TabListLayout.Parent = TabContainer
    
    local PagesContainer = Instance.new("Frame")
    PagesContainer.Size = UDim2.new(1, -150, 1, 0)
    PagesContainer.Position = UDim2.new(0, 150, 0, 0)
    PagesContainer.BackgroundTransparency = 1
    PagesContainer.Parent = Content
    
    Window.Tabs = {}
    Window.CurrentTab = nil
    
    -- [THUNDER LOGIC] Tab System Constructor
    function Window:CreateTab(tabName)
        local Tab = {}
        
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 36)
        TabButton.BackgroundColor3 = ThunderLibrary.Theme.Inactive
        TabButton.Text = tabName
        TabButton.TextColor3 = ThunderLibrary.Theme.Text
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.TextSize = 13
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabContainer
        ApplyCorner(TabButton, 6)
        
        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.ScrollBarThickness = 3
        TabPage.ScrollBarImageColor3 = ThunderLibrary.Theme.Primary
        TabPage.Visible = false
        TabPage.Parent = PagesContainer
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.Parent = TabPage
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 15)
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
                TweenService:Create(t.Button, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundColor3 = ThunderLibrary.Theme.Inactive}):Play()
            end
            TabPage.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundColor3 = ThunderLibrary.Theme.Secondary}):Play()
        end)
        
        if not Window.CurrentTab then
            TabPage.Visible = true
            TabButton.BackgroundColor3 = ThunderLibrary.Theme.Secondary
            Window.CurrentTab = tabName
        end
        
        Tab.Button = TabButton
        Tab.Page = TabPage
        table.insert(Window.Tabs, Tab)
        
        -- [THUNDER LOGIC] Interactive Components
        function Tab:AddButton(text, callback)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, -10, 0, 42)
            Button.BackgroundColor3 = ThunderLibrary.Theme.Inactive
            Button.Text = text
            Button.TextColor3 = ThunderLibrary.Theme.Text
            Button.Font = Enum.Font.GothamSemibold
            Button.TextSize = 14
            Button.AutoButtonColor = false
            Button.Parent = TabPage
            ApplyCorner(Button, 6)
            
            local BtnStroke = ApplyStroke(Button, ThunderLibrary.Theme.Primary, 1, 1)
            
            Button.MouseEnter:Connect(function()
                TweenService:Create(BtnStroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
            end)
            Button.MouseLeave:Connect(function()
                TweenService:Create(BtnStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
            end)
            
            Button.MouseButton1Click:Connect(function()
                -- Thunder Flash Effect Overlay
                local flash = Instance.new("Frame")
                flash.Size = UDim2.new(1, 0, 1, 0)
                flash.BackgroundColor3 = ThunderLibrary.Theme.Primary
                flash.BackgroundTransparency = 0.3
                flash.Parent = Button
                ApplyCorner(flash, 6)
                
                local flashTween = TweenService:Create(flash, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
                flashTween:Play()
                flashTween.Completed:Connect(function() flash:Destroy() end)
                
                if callback then task.spawn(callback) end
            end)
        end
        
        function Tab:AddToggle(text, callback)
            local toggled = false
            
            local ToggleFrame = Instance.new("TextButton")
            ToggleFrame.Size = UDim2.new(1, -10, 0, 42)
            ToggleFrame.BackgroundColor3 = ThunderLibrary.Theme.Inactive
            ToggleFrame.Text = ""
            ToggleFrame.AutoButtonColor = false
            ToggleFrame.Parent = TabPage
            ApplyCorner(ToggleFrame, 6)
            
            local TitleFrame = Instance.new("TextLabel")
            TitleFrame.Size = UDim2.new(1, -60, 1, 0)
            TitleFrame.Position = UDim2.new(0, 15, 0, 0)
            TitleFrame.BackgroundTransparency = 1
            TitleFrame.Text = text
            TitleFrame.TextColor3 = ThunderLibrary.Theme.Text
            TitleFrame.Font = Enum.Font.GothamSemibold
            TitleFrame.TextSize = 14
            TitleFrame.TextXAlignment = Enum.TextXAlignment.Left
            TitleFrame.Parent = ToggleFrame
            
            local SwitchBg = Instance.new("Frame")
            SwitchBg.Size = UDim2.new(0, 44, 0, 22)
            SwitchBg.Position = UDim2.new(1, -55, 0.5, -11)
            SwitchBg.BackgroundColor3 = ThunderLibrary.Theme.Background
            SwitchBg.Parent = ToggleFrame
            ApplyCorner(SwitchBg, 12)
            
            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 18, 0, 18)
            Switch.Position = UDim2.new(0, 2, 0.5, -9)
            Switch.BackgroundColor3 = ThunderLibrary.Theme.Inactive
            Switch.Parent = SwitchBg
            ApplyCorner(Switch, 12)
            
            ToggleFrame.MouseButton1Click:Connect(function()
                toggled = not toggled
                local newPos = toggled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                local newColor = toggled and ThunderLibrary.Theme.Primary or ThunderLibrary.Theme.Inactive
                
                TweenService:Create(Switch, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = newPos, BackgroundColor3 = newColor}):Play()
                TweenService:Create(TitleFrame, TweenInfo.new(0.3), {TextColor3 = toggled and ThunderLibrary.Theme.Primary or ThunderLibrary.Theme.Text}):Play()
                
                if callback then task.spawn(callback, toggled) end
            end)
        end
        
        -- [THUNDER LOGIC] The Raiden Slider
        function Tab:AddSlider(text, min, max, callback)
            local sliderValue = min
            local isDragging = false
            
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, -10, 0, 60)
            SliderFrame.BackgroundColor3 = ThunderLibrary.Theme.Inactive
            SliderFrame.Parent = TabPage
            ApplyCorner(SliderFrame, 6)
            
            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, -20, 0, 25)
            Title.Position = UDim2.new(0, 15, 0, 4)
            Title.BackgroundTransparency = 1
            Title.Text = text
            Title.TextColor3 = ThunderLibrary.Theme.Text
            Title.Font = Enum.Font.GothamSemibold
            Title.TextSize = 13
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = SliderFrame
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 50, 0, 25)
            ValueLabel.Position = UDim2.new(1, -65, 0, 4)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(min)
            ValueLabel.TextColor3 = ThunderLibrary.Theme.Primary
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.TextSize = 13
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliderFrame
            
            local BarBg = Instance.new("TextButton")
            BarBg.Size = UDim2.new(1, -30, 0, 6)
            BarBg.Position = UDim2.new(0, 15, 0, 40)
            BarBg.BackgroundColor3 = ThunderLibrary.Theme.Background
            BarBg.AutoButtonColor = false
            BarBg.Text = ""
            BarBg.Parent = SliderFrame
            ApplyCorner(BarBg, 6)
            
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(0, 0, 1, 0)
            Fill.BackgroundColor3 = ThunderLibrary.Theme.Primary
            Fill.Parent = BarBg
            ApplyCorner(Fill, 6)
            
            local Pointer = Instance.new("TextLabel")
            Pointer.Size = UDim2.new(0, 16, 0, 16)
            Pointer.Position = UDim2.new(1, -8, 0.5, -8)
            Pointer.BackgroundTransparency = 1
            Pointer.Text = "⚡"
            Pointer.TextColor3 = Color3.fromRGB(255, 255, 255)
            Pointer.TextSize = 12
            Pointer.Parent = Fill
            
            local function updateSlider(input)
                local mathClamped = math.clamp((input.Position.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
                sliderValue = math.floor(min + ((max - min) * mathClamped))
                
                TweenService:Create(Fill, TweenInfo.new(0.1, Enum.EasingStyle.Quart), {Size = UDim2.new(mathClamped, 0, 1, 0)}):Play()
                ValueLabel.Text = tostring(sliderValue)
                
                -- Dynamic Glow: Colors shift slightly to pure white the closer the max is
                local targetGlow = ThunderLibrary.Theme.Primary:Lerp(Color3.fromRGB(255, 255, 255), mathClamped * 0.4)
                TweenService:Create(Fill, TweenInfo.new(0.1), {BackgroundColor3 = targetGlow}):Play()
                
                if callback then task.spawn(callback, sliderValue) end
            end
            
            BarBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = true; updateSlider(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement) then
                    updateSlider(input)
                end
            end)
        end
        return Tab
    end
    
    -- [THUNDER LOGIC] Thunder-Strike Notification System
    local NotificationContainer = Instance.new("Frame")
    NotificationContainer.Size = UDim2.new(0, 260, 1, -20)
    NotificationContainer.Position = UDim2.new(1, -280, 0, 10)
    NotificationContainer.BackgroundTransparency = 1
    NotificationContainer.Parent = ScreenGui
    
    local NotifLayout = Instance.new("UIListLayout")
    NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifLayout.Padding = UDim.new(0, 10)
    NotifLayout.Parent = NotificationContainer
    
    function Window:SendNotification(title, text, duration)
        local Notif = Instance.new("Frame")
        Notif.Size = UDim2.new(1, 0, 0, 65)
        Notif.BackgroundColor3 = self.Theme.Background
        Notif.BackgroundTransparency = 1
        Notif.Parent = NotificationContainer
        ApplyCorner(Notif, 6)
        ApplyStroke(Notif, self.Theme.Primary, 1, 0)
        
        local NTitle = Instance.new("TextLabel")
        NTitle.Size = UDim2.new(1, -20, 0, 20)
        NTitle.Position = UDim2.new(0, 15, 0, 8)
        NTitle.BackgroundTransparency = 1
        NTitle.Text = title
        NTitle.TextColor3 = self.Theme.Primary
        NTitle.Font = Enum.Font.GothamBold
        NTitle.TextSize = 14
        NTitle.TextXAlignment = Enum.TextXAlignment.Left
        NTitle.TextTransparency = 1
        NTitle.Parent = Notif
        
        local NText = Instance.new("TextLabel")
        NText.Size = UDim2.new(1, -20, 0, 25)
        NText.Position = UDim2.new(0, 15, 0, 30)
        NText.BackgroundTransparency = 1
        NText.Text = text
        NText.TextColor3 = self.Theme.Text
        NText.Font = Enum.Font.Gotham
        NText.TextSize = 12
        NText.TextWrapped = true
        NText.TextXAlignment = Enum.TextXAlignment.Left
        NText.TextTransparency = 1
        NText.Parent = Notif
        
        -- Animation Entrances
        Notif.Position = UDim2.new(1, 50, 0, 0)
        TweenService:Create(Notif, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0.05}):Play()
        TweenService:Create(NTitle, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
        TweenService:Create(NText, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
        
        task.delay(duration or 3, function()
            local hideTween = TweenService:Create(Notif, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1})
            TweenService:Create(NTitle, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
            TweenService:Create(NText, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
            hideTween:Play()
            hideTween.Completed:Connect(function() Notif:Destroy() end)
        end)
    end
    
    return Window
end

return ThunderLibrary

