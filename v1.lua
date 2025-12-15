--[[  UI นี้ Open src ถ้ามึงจะก็อปก็เอาไปเถอะถ้าขยันนั่งแก้ Src ที่กูเขียน ;)
       
MMMMMMMW0xlcloxOXWMMMMN0dc'..'cONMMMMMMM
MMMMMNkc,',;;,,,;ldxxo;.       .;kNMMMMM
MMMWOc,''..',,;;;,'....          .:OWMMM
MMNx,''.     ..',;,'...            .dNMM
MMO;'.  ..     ..,,'..        ..    .OMM
MMx'. 'd0k'  .;:;,.....,;;'  'kXk,  .dWM
MMk' ,OWMXc ,OOx0XOxxOX0x0K: ;KMMK: .dWM
MWk..lNMWd..;:'.c0K000Oc..:;..lNMWd..dWM
M0:...kMWd..c:.  .,cc;.   ;c..lNM0;..'OM
MKl'.:0MMK:.lKd;cl;,,:oo:o0o.:0MMKl,'cKM
MMWXXWMWNKx,,ddxK0o:;oKKkdx;,d0NWMWXXWMM
MMMMW0dc,.. .:c'.;lllc;.'lc. ..,cd0NMMMM
MMMWKl. ...  .;c.      .oc.      .l0WMMM
MMMMNd'.'''.   .c;....,c,        .oXMMMM
MMWO:..,,'..    .cdxxdc.   .   ....;kNMM
MMNl.'d0Oc        ....  ...'..;kKk;.:KMM
MMMNKXWMWd. .,;'.       'c:,..lNMWNKNWMM
MMMMMMMMXc .xNWXx,    'oKWNk, ;KMMMMMMMM
MMMMMMMMWOdkNMMMMO'  .kMMMMWOdkNMMMMMMMM
MMMMMMMMMMMMMMMMMXl'.cKMMMMMMMMMMMMMMMMM

                เข้าดิสกูมา

]]

local SomtankUI = {}

--// Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

--// Library State (No more _G spam)
local Library = {
    State = {
        OldPosition = {},
        OldSize = {},
        ButtonPressCount = {},
        LastPressTime = {},
        ActiveDropdown = nil,
        NoSound = false,
        Dragging = false,
    },
    Connections = {},
    Icons = nil
}

--// Constants & Theming
local Themes = {
    Default = {
        BackgroundImage = "rbxassetid://127073445525528",
        DragIconImage = "rbxassetid://84408196679900",
        BackgroundColor = Color3.fromRGB(152, 62, 255),
        ColorSequence = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(154, 0, 247)),
            ColorSequenceKeypoint.new(0.46, Color3.fromRGB(154, 0, 247)),
            ColorSequenceKeypoint.new(0.85, Color3.fromRGB(163, 103, 247)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(213, 153, 247))
        },
        TextColor1 = Color3.fromRGB(144, 46, 255),
        TextColor2 = Color3.fromRGB(192, 121, 255),
        UIStroke1 = Color3.fromRGB(14, 6, 26),
        UIStroke2 = Color3.fromRGB(150, 102, 217),
        BackgroundColor1 = Color3.fromRGB(50, 29, 79),
        BackgroundColor2 = Color3.fromRGB(149, 74, 241),
        Accent = Color3.fromRGB(172, 131, 255),
    },
    Halloween = { -- Fixed spelling
        BackgroundImage = "rbxassetid://121558710773414",
        DragIconImage = "rbxassetid://130714476462777",
        BackgroundColor = Color3.fromRGB(134, 82, 23),
        ColorSequence = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 161, 0)),
            ColorSequenceKeypoint.new(0.46, Color3.fromRGB(255, 161, 0)),
            ColorSequenceKeypoint.new(0.85, Color3.fromRGB(247, 179, 43)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(247, 239, 131))
        },
        TextColor1 = Color3.fromRGB(255, 140, 0),
        TextColor2 = Color3.fromRGB(255, 211, 34),
        UIStroke1 = Color3.fromRGB(26, 13, 0),
        UIStroke2 = Color3.fromRGB(217, 73, 16),
        BackgroundColor1 = Color3.fromRGB(79, 48, 14),
        BackgroundColor2 = Color3.fromRGB(241, 161, 70),
        Accent = Color3.fromRGB(255, 180, 50),
    },
}

local CurrentTheme = Themes.Default

--// Pre-defined Sounds
local Sounds = {
    Button = Instance.new("Sound"),
    Enter = Instance.new("Sound"),
    Hover = Instance.new("Sound")
}
Sounds.Button.SoundId = "rbxassetid://139800881181209"; Sounds.Button.Volume = 0.1
Sounds.Enter.SoundId = "rbxassetid://134390474890852"; Sounds.Enter.Volume = 0.05
Sounds.Hover.SoundId = "rbxassetid://6042053626"; Sounds.Hover.Volume = 0.1

for _, s in pairs(Sounds) do s.Parent = SoundService end

--// Utility Functions

local function SafeLoadIcons()
    local success, result = pcall(function()
        return loadstring(game:HttpGet('https://raw.githubusercontent.com/HJSIWN/SomtankLib/refs/heads/main/Icon.lua'))()
    end)
    if success then Library.Icons = result else warn("⚠️ Failed to load icons.") end
end
task.spawn(SafeLoadIcons)

local function SetIcon(Name, Parent, Size, Position, Color, ZIndex)
    if not Library.Icons then return end
    local icon = Library.Icons.Image({Icon = Name})
    icon.IconFrame.Parent = Parent
    icon.IconFrame.Size = Size or UDim2.fromScale(1,1)
    icon.IconFrame.Position = Position or UDim2.fromScale(0,0)
    icon.IconFrame.ImageColor3 = Color or Color3.new(1,1,1)
    icon.IconFrame.ZIndex = ZIndex or 5
end

local function Tween(instance, properties, time, style, direction)
    local info = TweenInfo.new(time or 0.5, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

local function ApplyStyler(instance, props)
    for k, v in pairs(props) do instance[k] = v end
    return instance
end

local function AddDecoration(instance, type, p1, p2, p3)
    local item
    if type == "Corner" then
        item = Instance.new("UICorner", instance)
        item.CornerRadius = UDim.new(p1 or 0, p2 or 8)
    elseif type == "Stroke" then
        item = Instance.new("UIStroke", instance)
        item.Color = p1 or CurrentTheme.UIStroke1
        item.Thickness = p2 or 2
        item.Transparency = p3 or 0
    elseif type == "Ratio" then
        item = Instance.new("UIAspectRatioConstraint", instance)
    end
    return item
end
print("Debug Check:", CurrentTheme, CurrentTheme and CurrentTheme.TextColor2)
local function MakeDraggable(dragHandle, moveTarget)
    if not dragHandle or not moveTarget then return end
    
    local dragging, dragInput, dragStart, startPos
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = moveTarget.Position
            
            if dragHandle.Name == "DragIconButton" then -- Special case for minimized icon
                Library.State.DragIconOldPosition = moveTarget.Position
            end
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local smoothSpeed = 0.2 -- Adjust for smoothness vs responsiveness
            local targetPos = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            -- Direct update for responsiveness, can use Tween for super smooth drag but might lag
            moveTarget.Position = targetPos 
        end
    end)
end

local function AnimateButton(button, playSound)
    if not button then return end
    local name = button.Name
    
    -- Cache initial state
    if not Library.State.OldSize[name] then Library.State.OldSize[name] = button.Size end
    if not Library.State.OldPosition[name] and not button:GetAttribute("IsDragIcon") then 
        Library.State.OldPosition[name] = button.Position 
    end

    if playSound and not Library.State.NoSound then
        Sounds.Button:Play()
    end

    local originalSize = Library.State.OldSize[name]
    
    -- Pop Animation
    Tween(button, {Size = UDim2.new(originalSize.X.Scale * 0.9, originalSize.X.Offset * 0.9, originalSize.Y.Scale * 0.9, originalSize.Y.Offset * 0.9)}, 0.05).Completed:Connect(function()
        Tween(button, {Size = originalSize}, 0.1, Enum.EasingStyle.Bounce)
    end)
end

local function UpdateCanvasSize(scrollingFrame)
    local layout = scrollingFrame:FindFirstChildOfClass("UIListLayout") or scrollingFrame:FindFirstChildOfClass("UIGridLayout")
    if layout then
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end
end

--// Main Window Creation
function SomtankUI:CreateWindow(Settings)
    Settings = Settings or {}
    local TitleText = Settings.Title or "SomtankUI"
    local IconId = Settings.Icon or "rbxassetid://108281745434228"
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Somtank_" .. TitleText
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui or Players.LocalPlayer.PlayerGui
    
    local UIScale = Instance.new("UIScale", ScreenGui)
    UIScale.Scale = Settings.Scale or 0.9

    -- Main Background
    local MainFrame = Instance.new("ImageLabel", ScreenGui)
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.fromOffset(516, 332)
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundTransparency = 1
    MainFrame.Image = CurrentTheme.BackgroundImage
    MainFrame.Active = true
    
    -- Draggable Header Area (Invisible)
    local HeaderDrag = Instance.new("Frame", MainFrame)
    HeaderDrag.Size = UDim2.new(1, 0, 0.15, 0)
    HeaderDrag.BackgroundTransparency = 1
    MakeDraggable(HeaderDrag, MainFrame)

    -- Minimized Icon (Floating)
    local DragIcon = Instance.new("ImageLabel", ScreenGui)
    DragIcon.Name = "DragIcon"
    DragIcon.Size = UDim2.fromOffset(67, 61)
    DragIcon.Position = UDim2.fromScale(0.1, 0.1)
    DragIcon.Image = CurrentTheme.DragIconImage
    DragIcon.BackgroundTransparency = 1
    DragIcon:SetAttribute("IsDragIcon", true)
    
    local DragIconButton = Instance.new("TextButton", DragIcon)
    DragIconButton.Name = "DragIconButton"
    DragIconButton.Size = UDim2.fromScale(1, 1)
    DragIconButton.BackgroundTransparency = 1
    DragIconButton.Text = ""
    MakeDraggable(DragIconButton, DragIcon)

    local isWindowOpen = true
    DragIconButton.Activated:Connect(function()
        isWindowOpen = not isWindowOpen
        MainFrame.Visible = isWindowOpen
        AnimateButton(DragIcon, true)
    end)

    -- Logo Icon
    local Logo = Instance.new("ImageLabel", MainFrame)
    Logo.Size = UDim2.fromOffset(87, 87)
    Logo.Position = UDim2.new(0.019, 0, 0.04, 0)
    Logo.BackgroundTransparency = 1
    Logo.Image = IconId
    AddDecoration(Logo, "Ratio")

    -- Top Bar Controls
    local TopBar = Instance.new("Frame", MainFrame)
    TopBar.Position = UDim2.new(0.207, 0, 0.031, 0)
    TopBar.Size = UDim2.new(0, 391, 0, 37)
    TopBar.BackgroundTransparency = 1

    local function CreateTopButton(text, pos, callback)
        local btn = Instance.new("TextButton", TopBar)
        btn.Size = UDim2.fromOffset(38, 33)
        btn.Position = pos
        btn.BackgroundColor3 = CurrentTheme.BackgroundColor
        btn.Text = text
        btn.TextColor3 = Color3.white
        btn.Font = Enum.Font.FredokaOne
        btn.TextScaled = true
        AddDecoration(btn, "Corner", 0, 8)
        AddDecoration(btn, "Stroke", CurrentTheme.UIStroke1, 2.7, 0.5)
        
        btn.Activated:Connect(function()
            AnimateButton(btn, true)
            if callback then callback() end
        end)
        return btn
    end

    CreateTopButton("X", UDim2.new(0.91, 0, 0.046, 0), function()
        Tween(MainFrame, {Size = UDim2.fromOffset(0,0), BackgroundTransparency = 1}, 0.3).Completed:Wait()
        ScreenGui:Destroy()
    end)

    CreateTopButton("-", UDim2.new(0.80, 0, 0.046, 0), function()
        isWindowOpen = false
        MainFrame.Visible = false
    end)

    local TitleLabel = Instance.new("TextLabel", TopBar)
    TitleLabel.Size = UDim2.new(0.7, 0, 0.9, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = TitleText
    TitleLabel.Font = Enum.Font.FredokaOne
    TitleLabel.TextSize = 29
    TitleLabel.TextColor3 = CurrentTheme.TextColor1
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    AddDecoration(TitleLabel, "Stroke", CurrentTheme.UIStroke1, 2.7, 0.5)

    -- Resizer
    local Resizer = Instance.new("TextButton", MainFrame)
    Resizer.Size = UDim2.fromOffset(30, 30)
    Resizer.Position = UDim2.new(1, -30, 1, -30)
    Resizer.BackgroundTransparency = 1
    Resizer.Text = ""
    
    local resizeDrag = false
    local resizeStartPos, resizeStartScale
    Resizer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizeDrag = true
            resizeStartPos = input.Position
            resizeStartScale = UIScale.Scale
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizeDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - resizeStartPos
            UIScale.Scale = math.clamp(resizeStartScale + (delta.X + delta.Y) * 0.001, 0.5, 2.0)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizeDrag = false
        end
    end)

    -- Tab Container
    local TabScroll = Instance.new("ScrollingFrame", MainFrame)
    TabScroll.Name = "TabScroll"
    TabScroll.Size = UDim2.new(0, 179, 0, 208)
    TabScroll.Position = UDim2.new(0.034, 0, 0.325, 0)
    TabScroll.BackgroundTransparency = 1
    TabScroll.ScrollBarThickness = 0
    local TabListLayout = Instance.new("UIListLayout", TabScroll)
    TabListLayout.Padding = UDim.new(0.02, 0)

    -- Page Container
    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Name = "PageContainer"
    PageContainer.Position = UDim2.new(0.207, 0, 0.154, 0)
    PageContainer.Size = UDim2.new(0, 390, 0, 262)
    PageContainer.BackgroundTransparency = 1
    -- Important for Dropdowns to not be clipped
    PageContainer.ClipsDescendants = false 

    local Tabs = {}
    local FirstTab = true

    function Tabs:Tab(options)
        options = options or {}
        local TabTitle = options.Title or "Tab"
        local TabIcon = options.Icon
        
        -- Tab Button UI
        local TabFrame = Instance.new("Frame", TabScroll)
        TabFrame.Size = UDim2.new(1, 0, 0.18, 0)
        TabFrame.BackgroundTransparency = 1
        
        local TabBG = Instance.new("Frame", TabFrame)
        TabBG.Size = UDim2.new(0.3, 0, 1, 0)
        TabBG.BackgroundColor3 = Color3.white
        local TabGradient = Instance.new("UIGradient", TabBG)
        TabGradient.Color = CurrentTheme.ColorSequence
        local TabCorner = AddDecoration(TabBG, "Corner", 0.3, 0)
        
        local TabIconBG = Instance.new("Frame", TabFrame)
        TabIconBG.Size = UDim2.fromScale(0.26, 0.8) -- Relative size
        TabIconBG.Position = UDim2.fromScale(0.02, 0.1)
        TabIconBG.BackgroundColor3 = Color3.fromRGB(39, 39, 39)
        TabIconBG.BackgroundTransparency = 0.6
        AddDecoration(TabIconBG, "Corner", 1, 0)
        
        if TabIcon then
            SetIcon(TabIcon, TabIconBG, UDim2.fromScale(0.8, 0.8), UDim2.fromScale(0.1, 0.1), CurrentTheme.Accent)
        end

        local TabText = Instance.new("TextLabel", TabFrame)
        TabText.Text = TabTitle
        TabText.Size = UDim2.new(0, 0, 1, 0) -- Start hidden
        TabText.Position = UDim2.new(0.35, 0, 0, 0)
        TabText.BackgroundTransparency = 1
        TabText.Font = Enum.Font.FredokaOne
        TabText.TextColor3 = CurrentTheme.TextColor2
        TabText.TextSize = 20
        TabText.TextTransparency = 1
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        
        local TabButton = Instance.new("TextButton", TabFrame)
        TabButton.Size = UDim2.fromScale(1, 1)
        TabButton.BackgroundTransparency = 1
        TabButton.Text = ""

        -- Page Content UI
        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Name = TabTitle .. "_Page"
        Page.Size = UDim2.fromScale(1, 1)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = CurrentTheme.Accent
        Page.Visible = false
        
        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.Padding = UDim.new(0.02, 0)
        PageLayout.FillDirection = Enum.FillDirection.Horizontal
        PageLayout.Wraps = true
        
        Page.ChildAdded:Connect(function() UpdateCanvasSize(Page) end)
        
        local function ActivateTab()
            -- Reset all tabs
            for _, t in pairs(TabScroll:GetChildren()) do
                if t:IsA("Frame") and t ~= TabFrame then
                    local bg = t:FindFirstChild("Frame") -- TabBG
                    local txt = t:FindFirstChild("TextLabel")
                    if bg then Tween(bg, {Size = UDim2.new(0.3, 0, 1, 0)}, 0.3) end
                    if txt then Tween(txt, {TextTransparency = 1}, 0.2) end
                end
            end
            
            -- Hide all pages
            for _, p in pairs(PageContainer:GetChildren()) do
                if p:IsA("ScrollingFrame") then p.Visible = false end
            end
            
            -- Animate Active Tab
            Tween(TabBG, {Size = UDim2.new(1, 0, 1, 0)}, 0.4, Enum.EasingStyle.Back)
            Tween(TabText, {TextTransparency = 0}, 0.5)
            
            -- Show Page
            Page.Visible = true
            
            if not Library.State.NoSound then
                Sounds.Enter:Play()
            end
        end

        TabButton.Activated:Connect(ActivateTab)
        
        if FirstTab then
            FirstTab = false
            ActivateTab()
        end

        --// Page Elements
        local Elements = {}

        function Elements:MiniTab(options)
            local SectionTitle = options.Title or "Section"
            
            local SectionFrame = Instance.new("Frame", Page)
            SectionFrame.Size = UDim2.new(0, 191, 0, 210) -- Half width approx
            SectionFrame.BackgroundColor3 = CurrentTheme.TextColor1
            SectionFrame.BackgroundTransparency = 0.5
            AddDecoration(SectionFrame, "Corner")
            
            local SectionHeader = Instance.new("Frame", SectionFrame)
            SectionHeader.Size = UDim2.new(1, 0, 0.18, 0)
            SectionHeader.BackgroundColor3 = CurrentTheme.TextColor1
            AddDecoration(SectionHeader, "Corner")
            
            local SectionLabel = Instance.new("TextLabel", SectionHeader)
            SectionLabel.Size = UDim2.new(0.9, 0, 1, 0)
            SectionLabel.Position = UDim2.fromScale(0.05, 0)
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Text = SectionTitle
            SectionLabel.Font = Enum.Font.FredokaOne
            SectionLabel.TextColor3 = CurrentTheme.TextColor2
            SectionLabel.TextSize = 22
            AddDecoration(SectionLabel, "Stroke", CurrentTheme.UIStroke1, 2)

            local SectionContent = Instance.new("ScrollingFrame", SectionFrame)
            SectionContent.Size = UDim2.new(1, 0, 0.82, 0)
            SectionContent.Position = UDim2.new(0, 0, 0.18, 0)
            SectionContent.BackgroundTransparency = 1
            SectionContent.ScrollBarThickness = 2
            
            local SectionLayout = Instance.new("UIListLayout", SectionContent)
            SectionLayout.Padding = UDim.new(0.02, 0)
            SectionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            SectionContent.ChildAdded:Connect(function() UpdateCanvasSize(SectionContent) end)

            local ItemFuncs = {}

            -- Helper for item background
            local function CreateItemBase(height)
                local item = Instance.new("Frame", SectionContent)
                item.Size = UDim2.new(0.95, 0, 0, height or 40)
                item.BackgroundColor3 = CurrentTheme.BackgroundColor2
                item.BackgroundTransparency = 0.6
                AddDecoration(item, "Corner", 0, 6)
                return item
            end

            function ItemFuncs:Click(options)
                local btnName = options.Title or "Button"
                local callback = options.Callback or function() end
                
                local frame = CreateItemBase(40)
                
                local label = Instance.new("TextLabel", frame)
                label.Size = UDim2.new(0.7, 0, 1, 0)
                label.Position = UDim2.fromScale(0.05, 0)
                label.BackgroundTransparency = 1
                label.Text = btnName
                label.Font = Enum.Font.FredokaOne
                label.TextColor3 = CurrentTheme.TextColor2
                label.TextSize = 16
                label.TextXAlignment = Enum.TextXAlignment.Left
                AddDecoration(label, "Stroke", CurrentTheme.UIStroke1, 2)
                
                local clickIcon = Instance.new("ImageButton", frame)
                clickIcon.Size = UDim2.fromOffset(25, 25)
                clickIcon.Position = UDim2.new(1, -30, 0.5, -12.5)
                clickIcon.BackgroundTransparency = 1
                clickIcon.Image = "rbxassetid://75478984455074"
                clickIcon.ImageColor3 = CurrentTheme.Accent
                
                local trigger = Instance.new("TextButton", frame)
                trigger.Size = UDim2.fromScale(1, 1)
                trigger.BackgroundTransparency = 1
                trigger.Text = ""
                
                trigger.Activated:Connect(function()
                    AnimateButton(clickIcon, true)
                    clickIcon.ImageColor3 = Color3.white
                    Tween(clickIcon, {ImageColor3 = CurrentTheme.Accent}, 0.5)
                    callback()
                end)
            end

            function ItemFuncs:Toggle(options)
                local togName = options.Title or "Toggle"
                local default = options.State or false
                local callback = options.Callback or function() end
                
                local frame = CreateItemBase(40)
                
                local label = Instance.new("TextLabel", frame)
                label.Size = UDim2.new(0.6, 0, 1, 0)
                label.Position = UDim2.fromScale(0.05, 0)
                label.BackgroundTransparency = 1
                label.Text = togName
                label.Font = Enum.Font.FredokaOne
                label.TextColor3 = CurrentTheme.TextColor2
                label.TextSize = 16
                label.TextXAlignment = Enum.TextXAlignment.Left
                AddDecoration(label, "Stroke", CurrentTheme.UIStroke1, 2)
                
                local toggleBg = Instance.new("Frame", frame)
                toggleBg.Size = UDim2.fromOffset(40, 20)
                toggleBg.Position = UDim2.new(1, -50, 0.5, -10)
                toggleBg.BackgroundColor3 = CurrentTheme.BackgroundColor1
                AddDecoration(toggleBg, "Corner", 1, 0)
                
                local toggleDot = Instance.new("Frame", toggleBg)
                toggleDot.Size = UDim2.fromOffset(16, 16)
                toggleDot.Position = UDim2.new(0, 2, 0.5, -8)
                toggleDot.BackgroundColor3 = CurrentTheme.TextColor2
                AddDecoration(toggleDot, "Corner", 1, 0)
                
                local trigger = Instance.new("TextButton", frame)
                trigger.Size = UDim2.fromScale(1, 1)
                trigger.BackgroundTransparency = 1
                trigger.Text = ""
                
                local state = default
                
                local function UpdateToggle(animated)
                    if state then
                        if animated then
                            Tween(toggleDot, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Color3.white}, 0.2)
                            Tween(toggleBg, {BackgroundColor3 = CurrentTheme.Accent}, 0.2)
                        else
                            toggleDot.Position = UDim2.new(1, -18, 0.5, -8)
                            toggleDot.BackgroundColor3 = Color3.white
                            toggleBg.BackgroundColor3 = CurrentTheme.Accent
                        end
                    else
                        if animated then
                            Tween(toggleDot, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = CurrentTheme.TextColor2}, 0.2)
                            Tween(toggleBg, {BackgroundColor3 = CurrentTheme.BackgroundColor1}, 0.2)
                        else
                            toggleDot.Position = UDim2.new(0, 2, 0.5, -8)
                            toggleDot.BackgroundColor3 = CurrentTheme.TextColor2
                            toggleBg.BackgroundColor3 = CurrentTheme.BackgroundColor1
                        end
                    end
                end
                
                UpdateToggle(false)
                
                trigger.Activated:Connect(function()
                    state = not state
                    UpdateToggle(true)
                    callback(state)
                    if not Library.State.NoSound then Sounds.Button:Play() end
                end)
            end

            function ItemFuncs:Slider(options)
                local sName = options.Title or "Slider"
                local min, max, default = options.Value.Min, options.Value.Max, options.Value.Default
                local callback = options.Callback or function() end
                
                local frame = CreateItemBase(60)
                
                local label = Instance.new("TextLabel", frame)
                label.Size = UDim2.new(1, -10, 0, 20)
                label.Position = UDim2.fromScale(0.05, 0.1)
                label.BackgroundTransparency = 1
                label.Text = sName
                label.Font = Enum.Font.FredokaOne
                label.TextColor3 = CurrentTheme.TextColor2
                label.TextSize = 16
                label.TextXAlignment = Enum.TextXAlignment.Left
                AddDecoration(label, "Stroke", CurrentTheme.UIStroke1, 2)
                
                local valLabel = Instance.new("TextLabel", frame)
                valLabel.Size = UDim2.new(0, 50, 0, 20)
                valLabel.Position = UDim2.new(1, -55, 0.1, 0)
                valLabel.BackgroundTransparency = 1
                valLabel.Text = tostring(default)
                valLabel.Font = Enum.Font.FredokaOne
                valLabel.TextColor3 = Color3.white
                valLabel.TextSize = 14
                
                local sliderBar = Instance.new("Frame", frame)
                sliderBar.Size = UDim2.new(0.9, 0, 0, 6)
                sliderBar.Position = UDim2.new(0.05, 0, 0.7, 0)
                sliderBar.BackgroundColor3 = CurrentTheme.BackgroundColor1
                AddDecoration(sliderBar, "Corner", 1, 0)
                
                local fill = Instance.new("Frame", sliderBar)
                fill.Size = UDim2.new(0, 0, 1, 0)
                fill.BackgroundColor3 = CurrentTheme.Accent
                AddDecoration(fill, "Corner", 1, 0)
                
                local knob = Instance.new("Frame", fill)
                knob.Size = UDim2.fromOffset(12, 12)
                knob.Position = UDim2.new(1, -6, 0.5, -6)
                knob.BackgroundColor3 = Color3.white
                AddDecoration(knob, "Corner", 1, 0)
                
                local trigger = Instance.new("TextButton", frame)
                trigger.Size = UDim2.new(0.9, 0, 0.5, 0)
                trigger.Position = UDim2.new(0.05, 0, 0.5, 0)
                trigger.BackgroundTransparency = 1
                trigger.Text = ""
                
                local dragging = false
                
                local function SetValue(val)
                    local percent = (val - min) / (max - min)
                    fill.Size = UDim2.new(percent, 0, 1, 0)
                    valLabel.Text = string.format("%.2f", val)
                    callback(val)
                end
                
                SetValue(default)
                
                trigger.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        local percent = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                        local val = min + (max - min) * percent
                        SetValue(val)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                         local percent = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                        local val = min + (max - min) * percent
                        SetValue(val)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
            end

            function ItemFuncs:Dropdown(options)
                local dName = options.Title or "Dropdown"
                local items = options.Value.Values or {}
                local defaultItem = options.Value.SelectNow or items[1]
                local callback = options.Callback or function() end
                
                local frame = CreateItemBase(40)
                
                local label = Instance.new("TextLabel", frame)
                label.Size = UDim2.new(0.4, 0, 1, 0)
                label.Position = UDim2.fromScale(0.05, 0)
                label.BackgroundTransparency = 1
                label.Text = dName
                label.Font = Enum.Font.FredokaOne
                label.TextColor3 = CurrentTheme.TextColor2
                label.TextSize = 16
                label.TextXAlignment = Enum.TextXAlignment.Left
                AddDecoration(label, "Stroke", CurrentTheme.UIStroke1, 2)
                
                local displayFrame = Instance.new("Frame", frame)
                displayFrame.Size = UDim2.new(0.5, 0, 0.7, 0)
                displayFrame.Position = UDim2.new(0.45, 0, 0.15, 0)
                displayFrame.BackgroundColor3 = CurrentTheme.BackgroundColor1
                AddDecoration(displayFrame, "Corner", 0, 4)
                
                local currentText = Instance.new("TextLabel", displayFrame)
                currentText.Size = UDim2.new(0.8, 0, 1, 0)
                currentText.Position = UDim2.fromScale(0.1, 0)
                currentText.BackgroundTransparency = 1
                currentText.Text = defaultItem
                currentText.TextColor3 = Color3.white
                currentText.Font = Enum.Font.FredokaOne
                currentText.TextScaled = true
                
                local arrow = Instance.new("ImageLabel", displayFrame)
                arrow.Size = UDim2.fromOffset(15, 15)
                arrow.Position = UDim2.new(1, -20, 0.5, -7.5)
                arrow.BackgroundTransparency = 1
                arrow.Image = "rbxassetid://6034818372" -- Down arrow
                arrow.ImageColor3 = CurrentTheme.Accent
                
                local trigger = Instance.new("TextButton", frame)
                trigger.Size = UDim2.fromScale(1, 1)
                trigger.BackgroundTransparency = 1
                trigger.Text = ""
                
                -- Dropdown List (Created in MainFrame to avoid clipping)
                local listFrame = Instance.new("ScrollingFrame", ScreenGui) -- Parent to ScreenGui or MainFrame with high ZIndex
                listFrame.Name = "DropdownList"
                listFrame.Size = UDim2.fromOffset(displayFrame.AbsoluteSize.X, 0)
                listFrame.BackgroundColor3 = CurrentTheme.BackgroundColor1
                listFrame.BorderSizePixel = 0
                listFrame.Visible = false
                listFrame.ScrollBarThickness = 2
                listFrame.ZIndex = 100
                AddDecoration(listFrame, "Corner", 0, 4)
                
                local listLayout = Instance.new("UIListLayout", listFrame)
                listLayout.Padding = UDim.new(0, 2)
                
                local isOpen = false
                
                local function Close()
                    isOpen = false
                    Tween(listFrame, {Size = UDim2.fromOffset(displayFrame.AbsoluteSize.X, 0)}, 0.2).Completed:Connect(function()
                        listFrame.Visible = false
                        Library.State.ActiveDropdown = nil
                    end)
                    Tween(arrow, {Rotation = 0}, 0.2)
                end
                
                local function Open()
                    if Library.State.ActiveDropdown and Library.State.ActiveDropdown ~= Close then
                        Library.State.ActiveDropdown() -- Close others
                    end
                    
                    isOpen = true
                    listFrame.Visible = true
                    listFrame.Position = UDim2.fromOffset(displayFrame.AbsolutePosition.X, displayFrame.AbsolutePosition.Y + displayFrame.AbsoluteSize.Y + 5)
                    local contentSize = math.min(#items * 25, 150)
                    Tween(listFrame, {Size = UDim2.fromOffset(displayFrame.AbsoluteSize.X, contentSize)}, 0.2)
                    Tween(arrow, {Rotation = 180}, 0.2)
                    Library.State.ActiveDropdown = Close
                end

                local function Populate()
                    for _, child in pairs(listFrame:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    
                    for _, item in pairs(items) do
                        local btn = Instance.new("TextButton", listFrame)
                        btn.Size = UDim2.new(1, 0, 0, 25)
                        btn.BackgroundTransparency = 1
                        btn.Text = item
                        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
                        btn.Font = Enum.Font.FredokaOne
                        btn.TextSize = 14
                        btn.ZIndex = 101
                        
                        btn.MouseEnter:Connect(function() btn.TextColor3 = CurrentTheme.Accent end)
                        btn.MouseLeave:Connect(function() btn.TextColor3 = Color3.fromRGB(200, 200, 200) end)
                        
                        btn.Activated:Connect(function()
                            currentText.Text = item
                            callback(item)
                            Close()
                        end)
                    end
                    listFrame.CanvasSize = UDim2.new(0, 0, 0, #items * 27)
                end
                
                Populate()
                
                trigger.Activated:Connect(function()
                    if isOpen then Close() else Open() end
                end)
                
                -- Update position if main UI moves
                RunService.RenderStepped:Connect(function()
                    if isOpen and displayFrame.Visible then
                         listFrame.Position = UDim2.fromOffset(displayFrame.AbsolutePosition.X, displayFrame.AbsolutePosition.Y + displayFrame.AbsoluteSize.Y + 5)
                    elseif isOpen and not displayFrame.Visible then
                        Close()
                    end
                end)
            end

            return ItemFuncs
        end
        return Elements
    end

    return Tabs
end

return SomtankUI
