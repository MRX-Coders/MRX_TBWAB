-- [[ THE THUNDER GOD GUI ENGINE (MRX_TBWAB V2.0 - V3 UPDATE) ]]
-- Role: Elite UI/UX Engineer Framework
-- Aesthetics: Raiden, God of Thunder
-- Colors: Deep Obsidian (#0A0A0C), Electric Cyan (#00B4FF), Phantom Purple (#4B0082)
-- Goal: Modular, high-performance library handling UI separately from script logic.

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- Core Execution & Safety
-- ==========================================
local GUI_NAME = "MRX_TBWAB_ENGINE"

-- Clean up previous instances to prevent memory leaks
local function CleanUp()
    if CoreGui:FindFirstChild(GUI_NAME) then
        CoreGui:FindFirstChild(GUI_NAME):Destroy()
    end
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(GUI_NAME) then
        LocalPlayer.PlayerGui:FindFirstChild(GUI_NAME):Destroy()
    end
end
CleanUp()

-- Determine the safest parent for the GUI
local ParentGui = nil
local success, err = pcall(function()
    ParentGui = CoreGui
end)
if not success then 
    ParentGui = LocalPlayer:WaitForChild("PlayerGui") 
end

-- ==========================================
-- Utility Functions
-- ==========================================
local function CreateTween(instance, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.3, 
        style or Enum.EasingStyle.Quart, 
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function CreateInstance(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do
        inst[k] = v
    end
    return inst
end

-- ==========================================
-- Library Metatables & Architecture
-- ==========================================
local ThunderLibrary = {}
ThunderLibrary.__index = ThunderLibrary

-- Theme Definitions
local Theme = {
    DeepObsidian = Color3.fromRGB(10, 10, 12),
    ElectricCyan = Color3.fromRGB(0, 180, 255),
    PhantomPurple = Color3.fromRGB(75, 0, 130),
    DarkGray = Color3.fromRGB(20, 20, 25),
    LightGray = Color3.fromRGB(150, 150, 150),
    White = Color3.fromRGB(255, 255, 255)
}

-- ==========================================
-- Window Class
-- ==========================================
function ThunderLibrary:CreateWindow(titleText)
    local Window = {}
    Window.__index = Window
    Window.Tabs = {}
    Window.CurrentTab = nil
    
    -- Main ScreenGui
    local ThunderGui = CreateInstance("ScreenGui", {
        Name = GUI_NAME,
        Parent = ParentGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        ResetOnSpawn = false
    })
    Window.Gui = ThunderGui
    
    -- Thunder-Strike Notification System Container
    local NotifContainer = CreateInstance("Frame", {
        Name = "NotifContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -240, 1, -40),
        Size = UDim2.new(0, 220, 1, 0),
        AnchorPoint = Vector2.new(0, 1),
        Parent = ThunderGui
    })
    
    local NotifLayout = CreateInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 10),
        Parent = NotifContainer
    })
    Window.Container = NotifContainer
    
    -- Main Frame (Deep Obsidian Base)
    local MainFrame = CreateInstance("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 550, 0, 400),
        Position = UDim2.new(0.5, -275, 0.5, -200),
        BackgroundColor3 = Theme.DeepObsidian,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        Parent = ThunderGui
    })
    
    CreateInstance("UICorner", { CornerRadius = UDim.new(0, 8), Parent = MainFrame })
    
    -- Electric Cyan Stroke Glow Effect
    local MainStroke = CreateInstance("UIStroke", {
        Color = Theme.ElectricCyan,
        Thickness = 2,
        Parent = MainFrame
    })
    
    -- Header (Drag Area)
    local Header = CreateInstance("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = Color3.fromRGB(15, 15, 18),
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    CreateInstance("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Header })
    
    -- Hide bottom corners of header to blend with body
    CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 1, -8),
        BackgroundColor3 = Color3.fromRGB(15, 15, 18),
        BorderSizePixel = 0,
        Parent = Header
    })
    
    -- Separator Line (Glowing Cyan)
    CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.ElectricCyan,
        BorderSizePixel = 0,
        Parent = Header
    })
    
    -- Title Text with Lightning Bolt Icon
    local Title = CreateInstance("TextLabel", {
        Text = "⚡ " .. (titleText or "MRX_TBWAB [STABLE]"),
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.White,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        Parent = Header
    })
    
    -- ==========================================
    -- Frame-Independent Smooth Dragging
    -- ==========================================
    local dragging, dragInput, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            -- Sine easing for silky smooth dragging
            CreateTween(MainFrame, {Position = targetPos}, 0.1, Enum.EasingStyle.Sine)
        end
    end)
    
    -- Tab Container (Left Sidebar)
    local TabContainer = CreateInstance("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 140, 1, -46),
        Position = UDim2.new(0, 0, 0, 46),
        BackgroundColor3 = Color3.fromRGB(15, 15, 18),
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    local TabContainerLayout = CreateInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = TabContainer
    })
    
    CreateInstance("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = TabContainer
    })
    
    -- Content Container (Right Side)
    local ElementsContainer = CreateInstance("Frame", {
        Name = "ElementsContainer",
        Size = UDim2.new(1, -141, 1, -46),
        Position = UDim2.new(0, 141, 0, 46),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })
    
    Window.ElementsContainer = ElementsContainer
    
    -- ==========================================
    -- Thunder-Strike Notification System
    -- ==========================================
    function Window:SendNotification(title, text, duration)
        duration = duration or 3
        
        local Notif = CreateInstance("Frame", {
            Size = UDim2.new(1, 0, 0, 65),
            BackgroundColor3 = Theme.DeepObsidian,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            Parent = Window.Container
        })
        
        CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Notif })
        
        local NStroke = CreateInstance("UIStroke", {
            Color = Theme.ElectricCyan,
            Thickness = 1.5,
            Transparency = 1,
            Parent = Notif
        })
        
        local NTitle = CreateInstance("TextLabel", {
            Text = "⚡ " .. title,
            Size = UDim2.new(1, -10, 0, 20),
            Position = UDim2.new(0, 10, 0, 8),
            BackgroundTransparency = 1,
            TextColor3 = Theme.ElectricCyan,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextTransparency = 1,
            Parent = Notif
        })
        
        local NText = CreateInstance("TextLabel", {
            Text = text,
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.new(0, 10, 0, 28),
            BackgroundTransparency = 1,
            TextColor3 = Theme.LightGray,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextTransparency = 1,
            Parent = Notif
        })
        
        -- Strike Appearance Tween
        Notif.Position = UDim2.new(1, 50, 0, 0)
        CreateTween(Notif, {BackgroundTransparency = 0, Position = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Quint)
        CreateTween(NStroke, {Transparency = 0}, 0.4)
        CreateTween(NTitle, {TextTransparency = 0}, 0.4)
        CreateTween(NText, {TextTransparency = 0}, 0.4)
        
        -- Strike Disappearance Tween
        task.delay(duration, function()
            local fadeOut = CreateTween(Notif, {BackgroundTransparency = 1, Position = UDim2.new(1, 50, 0, 0)}, 0.4, Enum.EasingStyle.Quint)
            CreateTween(NStroke, {Transparency = 1}, 0.4)
            CreateTween(NTitle, {TextTransparency = 1}, 0.4)
            CreateTween(NText, {TextTransparency = 1}, 0.4)
            
            fadeOut.Completed:Connect(function() Notif:Destroy() end)
        end)
    end
    
    -- ==========================================
    -- Tab Class
    -- ==========================================
    function Window:CreateTab(tabName)
        local TabBtn = CreateInstance("TextButton", {
            Name = tabName.."_Tab",
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Theme.DarkGray,
            BorderSizePixel = 0,
            Text = tabName,
            Font = Enum.Font.GothamSemibold,
            TextColor3 = Theme.LightGray,
            TextSize = 14,
            Parent = TabContainer
        })
        
        CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TabBtn })
        
        local TabStroke = CreateInstance("UIStroke", {
            Color = Theme.ElectricCyan,
            Thickness = 1,
            Transparency = 1,
            Parent = TabBtn
        })
        
        -- The Scrolling Canvas for Tab Elements
        local TabPage = CreateInstance("ScrollingFrame", {
            Name = tabName.."_Page",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.ElectricCyan,
            Visible = false,
            Parent = ElementsContainer
        })
        
        local PageLayout = CreateInstance("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = TabPage
        })
        
        CreateInstance("UIPadding", {
            PaddingTop = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 16),
            PaddingBottom = UDim.new(0, 12),
            Parent = TabPage
        })
        
        -- Auto-scale layout
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 24)
        end)
        
        -- Handle Selection
        if not Window.CurrentTab then
            Window.CurrentTab = TabBtn
            TabPage.Visible = true
            TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            TabBtn.TextColor3 = Theme.ElectricCyan
            TabStroke.Transparency = 0
        end
        
        TabBtn.MouseButton1Click:Connect(function()
            if Window.CurrentTab then
                CreateTween(Window.CurrentTab, {BackgroundColor3 = Theme.DarkGray}, 0.2)
                CreateTween(Window.CurrentTab, {TextColor3 = Theme.LightGray}, 0.2)
                CreateTween(Window.CurrentTab:FindFirstChild("UIStroke"), {Transparency = 1}, 0.2)
                for _, page in pairs(ElementsContainer:GetChildren()) do
                    if page:IsA("ScrollingFrame") then page.Visible = false end
                end
            end
            Window.CurrentTab = TabBtn
            TabPage.Visible = true
            CreateTween(TabBtn, {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}, 0.2)
            CreateTween(TabBtn, {TextColor3 = Theme.ElectricCyan}, 0.2)
            CreateTween(TabStroke, {Transparency = 0}, 0.2)
        end)
        
        local TabObj = {}
        
        -- ==========================================
        -- Component Elements
        -- ==========================================
        
        -- [Toggle Switch component]
        function TabObj:AddToggle(text, callback)
            local ToggleFrame = CreateInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Color3.fromRGB(16, 16, 20),
                Parent = TabPage
            })
            
            CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ToggleFrame })
            
            local ToggleLabel = CreateInstance("TextLabel", {
                Size = UDim2.new(1, -70, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme.LightGray,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ToggleFrame
            })
            
            local ToggleBtn = CreateInstance("TextButton", {
                Size = UDim2.new(0, 44, 0, 22),
                Position = UDim2.new(1, -56, 0.5, -11),
                BackgroundColor3 = Color3.fromRGB(35, 35, 40),
                Text = "",
                Parent = ToggleFrame
            })
            
            CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ToggleBtn })
            
            local Indicator = CreateInstance("Frame", {
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0, 2, 0.5, -9),
                BackgroundColor3 = Theme.LightGray,
                Parent = ToggleBtn
            })
            
            CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Indicator })
            
            local state = false
            ToggleBtn.MouseButton1Click:Connect(function()
                state = not state
                if state then
                    CreateTween(Indicator, {Position = UDim2.new(1, -20, 0.5, -9), BackgroundColor3 = Theme.ElectricCyan}, 0.25, Enum.EasingStyle.Back)
                    CreateTween(ToggleBtn, {BackgroundColor3 = Color3.fromRGB(0, 60, 90)}, 0.25)
                    CreateTween(ToggleLabel, {TextColor3 = Theme.White}, 0.2)
                else
                    CreateTween(Indicator, {Position = UDim2.new(0, 2, 0.5, -9), BackgroundColor3 = Theme.LightGray}, 0.25, Enum.EasingStyle.Quart)
                    CreateTween(ToggleBtn, {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}, 0.25)
                    CreateTween(ToggleLabel, {TextColor3 = Theme.LightGray}, 0.2)
                end
                
                -- Lightning Flash Overlay
                local flash = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Theme.ElectricCyan,
                    BackgroundTransparency = 0.5,
                    Parent = ToggleFrame
                })
                CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6), Parent = flash })
                local t = CreateTween(flash, {BackgroundTransparency = 1}, 0.4)
                t.Completed:Connect(function() flash:Destroy() end)
                
                if callback then callback(state) end
            end)
        end
        
        -- [Interactive Button component]
        function TabObj:AddButton(text, callback)
            local Button = CreateInstance("TextButton", {
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Theme.DarkGray,
                Text = text,
                TextColor3 = Theme.LightGray,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                Parent = TabPage
            })
            
            CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Button })
            
            local UIStroke = CreateInstance("UIStroke", {
                Color = Theme.ElectricCyan,
                Thickness = 1,
                Transparency = 1,
                Parent = Button
            })
            
            -- Hover effects
            Button.MouseEnter:Connect(function()
                CreateTween(Button, {BackgroundColor3 = Color3.fromRGB(30, 30, 35), TextColor3 = Theme.White}, 0.2)
                CreateTween(UIStroke, {Transparency = 0}, 0.2)
            end)
            
            Button.MouseLeave:Connect(function()
                CreateTween(Button, {BackgroundColor3 = Theme.DarkGray, TextColor3 = Theme.LightGray}, 0.2)
                CreateTween(UIStroke, {Transparency = 1}, 0.2)
            end)
            
            -- Click / Lightning Flash Effect
            Button.MouseButton1Down:Connect(function()
                CreateTween(Button, {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}, 0.1)
                
                -- Lightning Flash Layer
                local flash = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Theme.ElectricCyan,
                    BackgroundTransparency = 0.3,
                    Parent = Button
                })
                CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6), Parent = flash })
                
                local ftween = CreateTween(flash, {BackgroundTransparency = 1}, 0.4)
                ftween.Completed:Connect(function() flash:Destroy() end)
            end)
            
            Button.MouseButton1Up:Connect(function()
                CreateTween(Button, {BackgroundColor3 = Color3.fromRGB(30, 30, 35)}, 0.1)
            end)
            
            Button.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
        end
        
        -- [Raiden FOV Slider Component]
        function TabObj:AddSlider(text, min, max, default, callback)
            local SliderFrame = CreateInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 55),
                BackgroundColor3 = Color3.fromRGB(16, 16, 20),
                Parent = TabPage
            })
            
            CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6), Parent = SliderFrame })
            
            local Label = CreateInstance("TextLabel", {
                Text = text,
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 12, 0, 8),
                BackgroundTransparency = 1,
                TextColor3 = Theme.LightGray,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SliderFrame
            })
            
            local ValueLabel = CreateInstance("TextLabel", {
                Text = tostring(default),
                Size = UDim2.new(0, 50, 0, 20),
                Position = UDim2.new(1, -62, 0, 8),
                BackgroundTransparency = 1,
                TextColor3 = Theme.ElectricCyan,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = SliderFrame
            })
            
            local Track = CreateInstance("Frame", {
                Size = UDim2.new(1, -24, 0, 4),
                Position = UDim2.new(0, 12, 0, 40),
                BackgroundColor3 = Color3.fromRGB(35, 35, 40),
                BorderSizePixel = 0,
                Parent = SliderFrame
            })
            CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Track })
            
            local Fill = CreateInstance("Frame", {
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Theme.ElectricCyan,
                BorderSizePixel = 0,
                Parent = Track
            })
            CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Fill })
            
            -- Glowing Bolt Pointer Effect (Uses rotated square for a diamond shape)
            local Pointer = CreateInstance("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(1, -7, 0.5, -7),
                BackgroundColor3 = Theme.White,
                Rotation = 45,
                Parent = Fill
            })
            CreateInstance("UICorner", { CornerRadius = UDim.new(0, 3), Parent = Pointer })
            
            -- Neon Trail (Glow effect behind pointer)
            local NeonGlow = CreateInstance("UIStroke", {
                Color = Theme.ElectricCyan,
                Thickness = 3,
                Transparency = 0.5,
                Parent = Pointer
            })
            
            local isDragging = false
            
            local function updateSlider(input)
                local pos = math.clamp(input.Position.X - Track.AbsolutePosition.X, 0, Track.AbsoluteSize.X)
                local scale = pos / Track.AbsoluteSize.X
                local value = math.floor(min + ((max - min) * scale))
                
                CreateTween(Fill, {Size = UDim2.new(scale, 0, 1, 0)}, 0.1, Enum.EasingStyle.Sine)
                ValueLabel.Text = tostring(value)
                
                -- Intensify neon glow based on value percentage
                local glowIntensity = 0.8 - (0.5 * scale)
                CreateTween(NeonGlow, {Transparency = glowIntensity}, 0.1)
                
                if callback then pcall(callback, value) end
            end
            
            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = true
                    updateSlider(input)
                    CreateTween(Pointer, {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -9, 0.5, -9)}, 0.2)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                    CreateTween(Pointer, {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -7, 0.5, -7)}, 0.2)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)
        end
        
        -- [Section Header Component]
        function TabObj:AddSection(text)
            local SectionFrame = CreateInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 25),
                BackgroundTransparency = 1,
                Parent = TabPage
            })
            
            CreateInstance("TextLabel", {
                Text = text,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                BackgroundTransparency = 1,
                TextColor3 = Theme.PhantomPurple,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionFrame
            })
            
            -- Divider Line
            CreateInstance("Frame", {
                Size = UDim2.new(1, -10, 0, 1),
                Position = UDim2.new(0, 5, 1, -1),
                BackgroundColor3 = Theme.PhantomPurple,
                BackgroundTransparency = 0.5,
                BorderSizePixel = 0,
                Parent = SectionFrame
            })
        end
        
        return TabObj
    end
    
    return Window
end

return ThunderLibrary
