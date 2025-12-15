
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

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local GetIcons = nil

pcall(function()
	GetIcons = loadstring(game:HttpGet('https://raw.githubusercontent.com/HJSIWN/SomtankLib/refs/heads/main/Icon.lua'))()
end)

if GetIcons then print("✅ Icon loaded!") else print("❌ Icon failed to load!") end

local function SetIcon(Name, Parent, Size, Position, Color31, ZIndex)
	local icon = GetIcons.Image({Icon = Name})
	icon.IconFrame.Parent = Parent or nil
	icon.IconFrame.Size = Size
	icon.IconFrame.Position = Position
	icon.IconFrame.ImageColor3 = Color31
	icon.IconFrame.ZIndex = ZIndex
end

local function SpinFrame(Frame)
	local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local tween = TweenService:Create(Frame, tweenInfo, {Rotation = Frame.Rotation - 360})
	tween:Play()
end

local function TweenFrame(frame, goalProperties, tweenTime, easingStyle, easingDirection)
	tweenTime = tweenTime or 0.5
	easingStyle = easingStyle or Enum.EasingStyle.Quad
	easingDirection = easingDirection or Enum.EasingDirection.Out
	local tweenInfo = TweenInfo.new(tweenTime,easingStyle,easingDirection)
	local tween = TweenService:Create(frame, tweenInfo, goalProperties)
	tween:Play()
	return tween
end

local function updateCanvasSize(scrollingFrame, paddingPx)
	-- Backward compatible: if there is a UIListLayout, trust AbsoluteContentSize (faster + correct with Wraps).
	if not scrollingFrame then return end

	local layout = scrollingFrame:FindFirstChildOfClass("UIListLayout")
	local extra = 0
	if typeof(paddingPx) == "number" then
		-- old code passes 0.02 (scale-ish). treat small numbers as 0px.
		extra = (paddingPx >= 1) and paddingPx or 0
	elseif typeof(paddingPx) == "UDim" then
		extra = paddingPx.Offset
	end

	if layout then
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + extra)
		return
	end

	-- Fallback loop
	local totalHeight = 0
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if child:IsA("GuiObject") and child.Visible then
			totalHeight += child.AbsoluteSize.Y + extra
		end
	end
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end

local function BindAutoCanvasSize(scrollingFrame, layout, extraPx)
	if not scrollingFrame or not layout then return end
	extraPx = extraPx or 0

	local function recalc()
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + extraPx)
	end

	recalc()
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(recalc)
	scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(recalc) -- helps when Wraps reflows
end

	end
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end

local function MakeDraggable(dragHandle, moveTarget)
	-- Fix: do NOT leave a permanent UserInputService.InputChanged connection per draggable.
	-- We only connect while dragging, then disconnect.
	if not dragHandle or not moveTarget then return end

	local dragging = false
	local dragStart, startPos
	local moveConn

	local function stopDrag()
		dragging = false
		if moveConn then
			moveConn:Disconnect()
			moveConn = nil
		end
	end

	dragHandle.InputBegan:Connect(function(input)
		if dragHandle.Parent and dragHandle.Parent.Name == "DragIcon" then
			_G.DragIconOldPosition = dragHandle.Parent.Position
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = moveTarget.Position

			-- connect movement only during active drag
			moveConn = UserInputService.InputChanged:Connect(function(moveInput)
				if not dragging then return end
				if moveInput.UserInputType ~= Enum.UserInputType.MouseMovement and moveInput.UserInputType ~= Enum.UserInputType.Touch then
					return
				end
				local delta = moveInput.Position - dragStart
				moveTarget.Position = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + delta.X,
					startPos.Y.Scale, startPos.Y.Offset + delta.Y
				)
			end)

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					stopDrag()
				end
			end)
		end
	end)

	-- If UI gets removed mid-drag, cleanup
	moveTarget.AncestryChanged:Connect(function(_, parent)
		if not parent then
			stopDrag()
		end
	end)
end

	local dragging, dragInput, dragStart, startPos
	local function update(input)
		local delta = input.Position - dragStart
		moveTarget.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
	dragHandle.InputBegan:Connect(function(input)
		if dragHandle.Parent and dragHandle.Parent.Name == "DragIcon" then
			_G.DragIconOldPosition = dragHandle.Parent.Position
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = moveTarget.Position
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
			update(input)
		end
	end)
end

local function AddJipaTaUI(item, parent, input1, input2, input3)
	-- Small helper to reduce repeated boilerplate and avoid typos (IsA vs isA)
	if not item or not parent then
		return item
	end

	if item:IsA("UIAspectRatioConstraint") then
		item.Parent = parent
		return item
	end

	if item:IsA("UICorner") then
		if input1 ~= nil and input2 ~= nil then
			item.CornerRadius = UDim.new(input1, input2)
		end
		item.Parent = parent
		return item
	end

	if item:IsA("UIStroke") then
		if input2 ~= nil then item.Thickness = input2 end
		if input1 ~= nil then item.Color = input1 end
		if input3 ~= nil then item.Transparency = input3 end
		item.Parent = parent
		return item
	end

	-- Fallback: just parent it
	item.Parent = parent
	return item
end

		Item.Parent = Parent
	elseif Item:IsA("UIStroke") then
		Item.Thickness = input2
		Item.Color = input1
		Item.Transparency = input3
		Item.Parent = Parent
	end
	return Item
end

local function GetScaledSizeAndPos(gui, factor)
	local oldSize = gui.Size
	local newSize = UDim2.new(
		oldSize.X.Scale * factor,
		oldSize.X.Offset * factor,
		oldSize.Y.Scale * factor,
		oldSize.Y.Offset * factor)
	local offsetX = (oldSize.X.Offset - newSize.X.Offset) / 2
	local offsetY = (oldSize.Y.Offset - newSize.Y.Offset) / 2
	local newPos = UDim2.new(
		gui.Position.X.Scale,
		gui.Position.X.Offset + offsetX,
		gui.Position.Y.Scale,
		gui.Position.Y.Offset + offsetY)
	return newSize, newPos
end

-- Sounds
local SoundService = game:GetService("SoundService")

local Sound_Button = Instance.new("Sound", SoundService)
Sound_Button.SoundId = "rbxassetid://139800881181209"
Sound_Button.Volume = 0.1
local Sound_Enter = Instance.new("Sound", SoundService)
Sound_Enter.SoundId = "rbxassetid://134390474890852"
Sound_Enter.Volume = 0.05
local Sound_Hower = Instance.new("Sound", SoundService)
Sound_Hower.SoundId = "rbxassetid://6042053626"
Sound_Hower.Volume = 0.1

_G.OldPosition = {}
_G.OldSize = {}
_G.ButtonPressCount = {}
_G.LastPressTime = {}

local SomtankTheameAll = {
	Default = {
		BackgroundImage = "rbxassetid://127073445525528",
		DragIconImage = "rbxassetid://84408196679900",
		BackgroundColor = Color3.new(0.596078, 0.243137, 1),
		ColorSequence = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(154, 0, 247)),
			ColorSequenceKeypoint.new(0.46, Color3.fromRGB(154, 0, 247)),
			ColorSequenceKeypoint.new(0.85, Color3.fromRGB(163, 103, 247)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(213, 153, 247))},
		TextColor1 = Color3.new(0.564706, 0.180392, 1),
		TextColor2 = Color3.new(0.752941, 0.47451, 1),
		UIStroke1 = Color3.new(0.054902, 0.0235294, 0.101961),
		UIStroke2 = Color3.new(0.588235, 0.4, 0.85098),
		
		BackgroundColor1 = Color3.new(0.196078, 0.113725, 0.309804),
		BackgroundColor2 = Color3.new(0.584314, 0.290196, 0.945098),
		
	},
	Holloween = {
		BackgroundImage = "rbxassetid://121558710773414",
		DragIconImage = "rbxassetid://130714476462777",
		BackgroundColor = Color3.new(0.52549, 0.321569, 0.0901961),
		ColorSequence = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 161, 0)),
			ColorSequenceKeypoint.new(0.46, Color3.fromRGB(255, 161, 0)),
			ColorSequenceKeypoint.new(0.85, Color3.fromRGB(247, 179, 43)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(247, 239, 131))},
		TextColor1 = Color3.new(1, 0.54902, 0),
		TextColor2 = Color3.new(1, 0.827451, 0.133333),
		UIStroke1 = Color3.new(0.101961, 0.0509804, 0),
		UIStroke2 = Color3.new(0.85098, 0.286275, 0.0627451),
		
		
		BackgroundColor1 = Color3.new(0.309804, 0.188235, 0.054902),
		BackgroundColor2 = Color3.new(0.945098, 0.631373, 0.27451),
		
	},
}

local NowTheame = SomtankTheameAll.Default

local function AnimateButton(button, PlaySound)
	if not button or not button:IsA("GuiObject") then return end
	local name = button.Name--ItsDragIcon
	if not _G.OldPosition[button.Name] and not button:GetAttribute("ItsDragIcon") then
		_G.OldPosition[button.Name] = button.Position
	end
	if not _G.OldSize[button.Name] then
		_G.OldSize[button.Name] = button.Size
	end
	if not _G.ButtonPressCount[name] then _G.ButtonPressCount[name] = 0 end
	if not _G.LastPressTime[name] then _G.LastPressTime[name] = 0 end
	_G.ButtonPressCount[name] += 1
	_G.LastPressTime[name] = tick()
	if PlaySound and not _G.NoSoundWindow then
		Sound_Button.PlaybackSpeed = 1 + (_G.ButtonPressCount[name] * 0.1)
		Sound_Button.Volume = 0.1 + (_G.ButtonPressCount[name] * 0.05)
		Sound_Button:Play()
	end
	local size1, pos1 = GetScaledSizeAndPos(button, 0.9)
	local size2, pos2 = GetScaledSizeAndPos(button, 1.1)
	local tween1 = TweenService:Create(button, TweenInfo.new(0.1), {Size = size1, Position = pos1})
	local tween2 = TweenService:Create(button, TweenInfo.new(0.1), {Size = size2, Position = pos2})
	local tween3 = TweenService:Create(button, TweenInfo.new(0.1), {Size = _G.OldSize[button.Name], Position = _G.OldPosition[button.Name]})
	tween1:Play()
	tween1.Completed:Connect(function()
		tween2:Play()
		tween2.Completed:Connect(function()
			if button:GetAttribute("ItsDragIcon") then return end
			tween3:Play()
			tween3.Completed:Connect(function()				
				if _G.OldPosition[button.Name] then
					button.Position = _G.OldPosition[button.Name]
				end
				if _G.OldSize[button.Name] then
					button.Size = _G.OldSize[button.Name]
				end
				task.spawn(function()
					wait(1)
					for name, lastTime in pairs(_G.LastPressTime) do
						if tick() - lastTime > 1 then
							_G.ButtonPressCount[name] = 0
							Sound_Button.PlaybackSpeed = 1
							Sound_Button.Volume = 0.1
						end
					end
				end)
			end)
		end)
	end)
end

function SomtankUI:CreateWindow(Setting_Input)
	task.wait()
	
	if _G.NoSoundWindow then
		_G.NoSoundWindow = false
	end
	
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "SomtankUI_"..math.random(0,99)
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = game:GetService("CoreGui") or game.Players.LocalPlayer.PlayerGui
	local UIScale = Instance.new("UIScale", ScreenGui)
	UIScale.Scale = Setting_Input and Setting_Input.Scale or 0.89
	local BGFrame = Instance.new("ImageLabel", ScreenGui)
	BGFrame.Position = UDim2.new(0.108, 0,0.097, 0)
	BGFrame.Size = UDim2.new(0, 516,0, 332)	
	BGFrame.BackgroundTransparency = 1
	BGFrame.Image = NowTheame.BackgroundImage
	local DragIcon = Instance.new("ImageLabel", ScreenGui)
	DragIcon.Position = UDim2.new(0.04, 0,0.431, 0)
	DragIcon.Size = UDim2.new(0, 67,0, 61)
	DragIcon.BackgroundTransparency = 1
	DragIcon.Image = NowTheame.DragIconImage
	DragIcon.Name = "DragIcon"
	local DragIconButton, UserOpenned = Instance.new("TextButton", DragIcon), false
	DragIconButton.Size = UDim2.new(1, 0,1, 0)
	DragIconButton.Position = UDim2.new(0, 0,0, 0)
	DragIconButton.BackgroundTransparency = 1
	DragIconButton.TextTransparency = 1
	MakeDraggable(DragIconButton, DragIcon)
	DragIcon:SetAttribute("ItsDragIcon", true)
	DragIconButton.Activated:Connect(function()
		if not UserOpenned then
			UserOpenned = true
			if _G.DragIconOldPosition and DragIcon.Position == _G.DragIconOldPosition then
				AnimateButton(DragIcon, true)
				BGFrame.Visible = not BGFrame.Visible
			end
			task.wait(0.7)
			UserOpenned = false
		end
	end)
	AddJipaTaUI(Instance.new("UIAspectRatioConstraint"), DragIcon)
	local ScalMainFrame = Instance.new("TextButton", BGFrame)
	ScalMainFrame.Size = UDim2.new(0, 38,0, 38)
	ScalMainFrame.Position = UDim2.new(0.93, 0,0.89, 0)
	ScalMainFrame.BackgroundTransparency = 1
	ScalMainFrame.TextTransparency = 1
	ScalMainFrame.Name = "ScalMainFrame"
	Instance.new("UIAspectRatioConstraint", ScalMainFrame)
	local BGIcon = Instance.new("ImageLabel", BGFrame)
	BGIcon.Size = UDim2.new(0, 87,0, 87)
	BGIcon.Position = UDim2.new(0.019, 0,0.04, 0)
	BGIcon.BackgroundTransparency = 1
	BGIcon.Image = Setting_Input and Setting_Input.Icon or "rbxassetid://108281745434228"
	BGIcon.Name = "Icon"
	Instance.new("UIAspectRatioConstraint", BGIcon)
	
	----- Main Scale Function
	local dragging, startPos, startScale = false, nil, nil	
	ScalMainFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startPos = input.Position
			startScale = UIScale.Scale
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement 
			or input.UserInputType == Enum.UserInputType.Touch then
			if dragging then
				local delta = input.Position - startPos
				local newScale = startScale + (delta.X + delta.Y) * 0.0012
				UIScale.Scale = newScale
			end
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	----- End Main Scale Function
	
	local TopFrame = Instance.new("Frame", BGFrame)
	TopFrame.Position = UDim2.new(0.207, 0,0.031, 0)
	TopFrame.Size = UDim2.new(0, 391,0, 37)	
	TopFrame.BackgroundTransparency = 1
	local DestroyButton = Instance.new("TextButton", TopFrame)
	DestroyButton.Position = UDim2.new(0.912, 0,0.046, 0)
	DestroyButton.Size = UDim2.new(0, 38,0, 33)	
	DestroyButton.BackgroundColor3 = NowTheame.BackgroundColor
	DestroyButton.Text = "X"
	DestroyButton.TextColor3 = Color3.new(1, 1, 1)
	DestroyButton.TextScaled = true
	DestroyButton.Name = "DestroyButton"
	DestroyButton.Font = Enum.Font.FredokaOne
	AddJipaTaUI(Instance.new("UIAspectRatioConstraint"), DestroyButton)
	AddJipaTaUI(Instance.new("UICorner"), DestroyButton)
	AddJipaTaUI(Instance.new("UIStroke"), DestroyButton, NowTheame.UIStroke1, 2.7, 0.52)
	DestroyButton.Activated:Connect(function()
		DestroyButton.Active = false
		AnimateButton(DestroyButton, true)
		task.wait(1)
		ScreenGui:Destroy()
	end)
	local EyeButton = Instance.new("TextButton", TopFrame)
	EyeButton.Position = UDim2.new(0.804, 0,0.046, 0)
	EyeButton.Size = UDim2.new(0, 38,0, 33)	
	EyeButton.BackgroundColor3 = NowTheame.BackgroundColor
	EyeButton.Text = "-"
	EyeButton.TextScaled = true
	EyeButton.TextColor3 = Color3.new(1, 1, 1)
	EyeButton.Font = Enum.Font.FredokaOne
	EyeButton.Name = "EyeButton"
	AddJipaTaUI(Instance.new("UIAspectRatioConstraint"), EyeButton)
	AddJipaTaUI(Instance.new("UICorner"), EyeButton)
	AddJipaTaUI(Instance.new("UIStroke"), EyeButton, NowTheame.UIStroke1, 2.7, 0.52)
	EyeButton.Activated:Connect(function()
		AnimateButton(EyeButton, true)
		BGFrame.Visible = not BGFrame.Visible
	end)
	local TitleMainFrame = Instance.new("TextButton", TopFrame)
	TitleMainFrame.Position = UDim2.new(0.01, 0,0, 0)
	TitleMainFrame.Size = UDim2.new(-0.008, 306,0.938, 0)	
	TitleMainFrame.BackgroundColor3 = NowTheame.BackgroundColor
	TitleMainFrame.Text = Setting_Input and Setting_Input.Title or "SomtankUI"
	TitleMainFrame.TextSize = 29
	TitleMainFrame.TextColor3 = NowTheame.TextColor1
	TitleMainFrame.Font = Enum.Font.FredokaOne
	TitleMainFrame.TextXAlignment = Enum.TextXAlignment.Left
	TitleMainFrame.BackgroundTransparency = 1
	AddJipaTaUI(Instance.new("UIStroke"), TitleMainFrame, NowTheame.UIStroke1, 2.7, 0.52)
	MakeDraggable(TitleMainFrame, BGFrame)
	MakeDraggable(TopFrame, BGFrame)
	
	local Mode_ScrollingFrame = Instance.new("ScrollingFrame", BGFrame)
	Mode_ScrollingFrame.Size = UDim2.new(0, 179,0, 208)
	Mode_ScrollingFrame.Position = UDim2.new(0.034, 0,0.325, 0)
	Mode_ScrollingFrame.BackgroundTransparency = 1
	Mode_ScrollingFrame.Name = "Mode_ScrollingFrame"
	Mode_ScrollingFrame.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left
	Mode_ScrollingFrame.ScrollBarThickness = 0
	Mode_ScrollingFrame.BorderSizePixel = 0
	Mode_ScrollingFrame.MidImage = ""
	Mode_ScrollingFrame.ScrollBarImageColor3 = Color3.new(0.494118, 0.494118, 0.494118)
	local UIListLayout_Mode_ScrollingFrame = Instance.new("UIListLayout", Mode_ScrollingFrame)
	UIListLayout_Mode_ScrollingFrame.Padding = UDim.new(0.01, 0)
	BindAutoCanvasSize(Mode_ScrollingFrame, UIListLayout_Mode_ScrollingFrame, 8)
	
	local Modes = {}
	Modes.Gui = ScreenGui
	
	_G.ModesOnoff = {}
	_G.ModesTitle = {}
	_G.ModesNext = {}
	_G.ModesNeedOn = {}
	
	local SelectFrameMain = Instance.new("Frame", BGFrame)
	SelectFrameMain.Position = UDim2.new(0.207, 0,0.154, 0)
	SelectFrameMain.Size = UDim2.new(0, 390,0, 262)
	SelectFrameMain.BackgroundTransparency = 1
	
	function Modes:Tab(options)		
		task.wait()
		
		local MainFrame = Instance.new("Frame", Mode_ScrollingFrame)
		MainFrame.Size = UDim2.new(1, 0,0.08, 0)	
		MainFrame.BackgroundTransparency = 1
		MainFrame.Name = options and options.Title or "Tab"
		
		local BGFrame_ = Instance.new("Frame", MainFrame)
		BGFrame_.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		BGFrame_.Size = UDim2.new(0.301, 0,1, 0)
		BGFrame_.ZIndex = 9
		
		local BGFrame_UICorner = Instance.new("UICorner", BGFrame_)
		BGFrame_UICorner.CornerRadius = UDim.new(0.3, 0)
		
		local BGFrame_UIGradient = Instance.new("UIGradient", BGFrame_)
		BGFrame_UIGradient.Color = NowTheame.ColorSequence
		
		local Button = Instance.new("TextButton", MainFrame)
		Button.Size = UDim2.new(0.300, 0,1, 0)
		Button.BackgroundTransparency = 1
		Button.TextTransparency = 1
		Button.Name = "Button"
		Button.ZIndex = 10
		
		local IconBG = Instance.new("Frame", MainFrame)
		IconBG.Position = UDim2.new(0.02, 0,0.048, 0)
		IconBG.Size = UDim2.new(0, 47,0, 62)
		IconBG.BackgroundTransparency = 0.6
		IconBG.BackgroundColor3 = Color3.new(0.152941, 0.152941, 0.152941)
		IconBG.Name = "MainFrame"
		IconBG.ZIndex = 10
		Instance.new("UIAspectRatioConstraint", IconBG)
		local IconBG_UICorner = AddJipaTaUI(Instance.new("UICorner"), IconBG, 1, 0)
		
		local Title = Instance.new("TextLabel", IconBG)
		Title.Size = UDim2.new(0, 0,0, 45)
		Title.Position = UDim2.new(1.07, 0,0.018, 0)
		Title.BackgroundTransparency = 1
		Title.Text = ""
		Title.Name = "Button"
		Title.Font = Enum.Font.FredokaOne
		Title.TextColor3 = NowTheame.TextColor2
		Title.TextScaled = true
		Title.ZIndex = 10
		Title.Visible = true
		local UIStroke_Title = AddJipaTaUI(Instance.new("UIStroke"), Title, NowTheame.UIStroke1, 2.7, 0.52)
		
		_G.ModesTitle[options.Title] = options.Title
		
		local RealIcon, TweenModeFrame, ModeName = nil, nil, options.Title.."_Function"
		
		if GetIcons and options.Icon then
			SetIcon(options.Icon, IconBG, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), Color3.new(0.67451, 0.513725, 1), 10)
		end
		
		local function CloseChilSelectFrameMain(ModeNameNeed)
			if not ModeNameNeed then ModeNameNeed = "S" end
			for _, item in ipairs(SelectFrameMain:GetChildren()) do
				if item:IsA("ScrollingFrame") then
					if item.Name ~= ModeNameNeed then
						item.Visible = false
					else
						item.Visible = true
					end
				end
			end
		end
		
		local Function_ScrollingFrame = Instance.new("ScrollingFrame", SelectFrameMain)
		Function_ScrollingFrame.Size = UDim2.new(1,0,1,0)
		Function_ScrollingFrame.Position = UDim2.new(0, 0,0, 0)
		Function_ScrollingFrame.BackgroundTransparency = 1
		Function_ScrollingFrame.Name = ModeName or "Bug"
		Function_ScrollingFrame.ScrollBarThickness = 0
		Function_ScrollingFrame.ScrollBarImageColor3 = Color3.new(0.490196, 0.490196, 0.490196)
		Function_ScrollingFrame.Visible = false
		Function_ScrollingFrame.MidImage = ""
		local UIListLayout_Function_ScrollingFrame = Instance.new("UIListLayout", Function_ScrollingFrame)
		UIListLayout_Function_ScrollingFrame.Padding = UDim.new(0.02, 0)
		UIListLayout_Function_ScrollingFrame.Wraps = true
		UIListLayout_Function_ScrollingFrame.FillDirection = Enum.FillDirection.Horizontal
		
		BindAutoCanvasSize(Function_ScrollingFrame, UIListLayout_Function_ScrollingFrame, 8)
		Button.Activated:Connect(function()
			if _G.ModesOnoff then
				_G.ModesOnoff[MainFrame.Name] = not _G.ModesOnoff[MainFrame.Name]
				if _G.ModesOnoff[MainFrame.Name] then
					if _G.ModesNext and _G.ModesNext[MainFrame.Name] then
						_G.ModesNext[MainFrame.Name] = false
					end
					if _G.ModesNeedOn and _G.ModesNeedOn[MainFrame.Name] then
						_G.ModesNeedOn[MainFrame.Name] = false
					end
					Title.Text = _G.ModesTitle[options.Title]
					CloseChilSelectFrameMain(ModeName)
					if not _G.NoSoundWindow then
						Sound_Enter:Stop()
						Sound_Enter.PlaybackSpeed = tonumber("1."..math.random(1,5)) or 1
						Sound_Enter.TimePosition = 0
						Sound_Enter:Play()	
					end
					TweenFrame(UIStroke_Title, {Thickness = 2.7}
					, 0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)	
					TweenFrame(Title, {Size = UDim2.new(0, 118,0, 45)}
					, 0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)					
					TweenModeFrame = TweenFrame(BGFrame_, {Size = UDim2.new(1, 0, 1, 0)}
					, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
					TweenModeFrame.Completed:Connect(function()
						TweenFrame(BGFrame_UICorner, {CornerRadius = UDim.new(0.1, 0)}
						, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
						if Title.Text == "" then
							Title.Text = _G.ModesTitle[options.Title]
							TweenFrame(Title, {Size = UDim2.new(0, 118,0, 45)}
							, 0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)								
						end
					end)
				else
					if not _G.NoSoundWindow then
						Sound_Hower:Stop()
						Sound_Hower.TimePosition = 0
						Sound_Hower:Play()	
					end			
					TweenFrame(UIStroke_Title, {Thickness = 0}
					, 0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)	
					TweenFrame(Title, {Size = UDim2.new(0, 0,0, 45)}
					, 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)					
					TweenModeFrame = TweenFrame(BGFrame_, {Size = UDim2.new(0.301, 0,1, 0)}
					, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
					TweenModeFrame.Completed:Connect(function()
						Title.Text = ""
						TweenFrame(BGFrame_UICorner, {CornerRadius = UDim.new(0.3, 0)}
						, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
					end)
				end
			end
		end)		
		Button.MouseEnter:Connect(function()
			if _G.ModesNext and _G.ModesNext[MainFrame.Name] then
				_G.ModesNext[MainFrame.Name] = false
			end
			TweenFrame(IconBG, {BackgroundTransparency = 0.3}
			, 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			TweenFrame(IconBG_UICorner, {CornerRadius = UDim.new(0.3, 0)}
			, 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			if not _G.NoSoundWindow then
				Sound_Hower:Stop()
				Sound_Hower.TimePosition = 0
				Sound_Hower:Play()
			end
			task.spawn(function()
				if _G.ModesNeedOn then
					_G.ModesNeedOn[MainFrame.Name] = true
					for i=1,5 do
						if _G.ModesNeedOn[MainFrame.Name] then
							wait(0.1)
						end
					end
					if _G.ModesNext and _G.ModesNext[MainFrame.Name] then
						_G.ModesNext[MainFrame.Name] = false
					end
					if _G.ModesNeedOn[MainFrame.Name] then
						Title.Text = _G.ModesTitle[options.Title]
						TweenFrame(UIStroke_Title, {Thickness = 2.7}
						, 0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)	
						TweenFrame(Title, {Size = UDim2.new(0, 118,0, 45)}
						, 0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)					
						TweenModeFrame = TweenFrame(BGFrame_, {Size = UDim2.new(1, 0, 1, 0)}
						, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
						TweenModeFrame.Completed:Connect(function()
							TweenFrame(BGFrame_UICorner, {CornerRadius = UDim.new(0.1, 0)}
							, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
							if Title.Text == "" then
								Title.Text = _G.ModesTitle[options.Title]
								TweenFrame(Title, {Size = UDim2.new(0, 118,0, 45)}
								, 0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)								
							end
						end)
					end
				end
			end)
		end)
		Button.MouseLeave:Connect(function()
			if _G.ModesNeedOn and _G.ModesNeedOn[MainFrame.Name] then
				_G.ModesNeedOn[MainFrame.Name] = false
			end
			task.spawn(function()
				TweenFrame(UIStroke_Title, {Thickness = 0}
				, 0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)	
				TweenFrame(Title, {Size = UDim2.new(0, 0,0, 45)}
				, 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)					
				TweenModeFrame = TweenFrame(BGFrame_, {Size = UDim2.new(0.301, 0,1, 0)}
				, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				TweenModeFrame.Completed:Connect(function()
					Title.Text = ""
					TweenFrame(BGFrame_UICorner, {CornerRadius = UDim.new(0.3, 0)}
					, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				end)						
				TweenFrame(UIStroke_Title, {Thickness = 0}
				, 0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)	
				TweenFrame(IconBG, {BackgroundTransparency = 0.6}
				, 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)	
				TweenFrame(IconBG_UICorner, {CornerRadius = UDim.new(1, 0)}
				, 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			end)
		end)
		
		-- End of Function_ScrollingFrame
		
		local Functions = {}
		Functions.Gui = Function_ScrollingFrame

		function Functions:MiniTab(options)
			task.wait()
			
			local BGFuncFrame = Instance.new("Frame", Function_ScrollingFrame)
			BGFuncFrame.Size = UDim2.new(0, 191,0, 210)
			BGFuncFrame.BackgroundColor3 = NowTheame.TextColor1
			BGFuncFrame.BackgroundTransparency = 0.5			
			BGFuncFrame.Name = "BGFuncFrame"
			Instance.new("UICorner", BGFuncFrame)
			
			local UIListLayout_BGFuncFrame = Instance.new("UIListLayout", BGFuncFrame)
			UIListLayout_BGFuncFrame.Padding = UDim.new(0.02, 0)
			UIListLayout_BGFuncFrame.SortOrder = Enum.SortOrder.LayoutOrder
			
			local TitleFrame = Instance.new("Frame", BGFuncFrame)
			TitleFrame.Size = UDim2.new(1, 0,0.18, 0)
			TitleFrame.BackgroundColor3 = NowTheame.TextColor1
			TitleFrame.Name = "TitleFrame"
			Instance.new("UICorner", TitleFrame)
			
			local Title_Textlabel = Instance.new("TextLabel", TitleFrame)
			Title_Textlabel.Size = UDim2.new(0.975, 0,0.9, 0)
			Title_Textlabel.Position = UDim2.new(0.015, 0,0.05, 0)
			Title_Textlabel.BackgroundTransparency = 1
			Title_Textlabel.Name = "Title"
			Title_Textlabel.Text = options and options.Title or "ห๊ะ"
			Title_Textlabel.Font = Enum.Font.FredokaOne
			Title_Textlabel.TextColor3 = NowTheame.TextColor2
			Title_Textlabel.TextSize = 34
			Title_Textlabel.ZIndex = 1
			AddJipaTaUI(Instance.new("UIStroke"), Title_Textlabel, NowTheame.UIStroke1, 2.7, 0.52)
			local UIStroke_Title_Textlabel = AddJipaTaUI(Instance.new("UIStroke"), Title_Textlabel, NowTheame.UIStroke2, 1.6, 0.52)
			UIStroke_Title_Textlabel.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			
			-- End of TitleFrame
			
			local MiniFunction = {}
			MiniFunction.Gui = Function_ScrollingFrame

			function MiniFunction:Click(options)
				task.wait()
				
				local Click_options, NameFunction = {}, options and options.Title
				Click_options.Callback = options.Callback
				
				local FuncClick = Instance.new("Frame", BGFuncFrame)
				FuncClick.Size = UDim2.new(1, 0,0.185, 0)
				FuncClick.BackgroundTransparency = 0.6
				FuncClick.BackgroundColor3 = NowTheame.BackgroundColor2
				FuncClick.Name = "Func"..NameFunction
				Instance.new("UICorner", FuncClick)
				
				local Title_Func = Instance.new("TextLabel", FuncClick)
				Title_Func.Size = UDim2.new(0.77, 0,0.9, 0)
				Title_Func.Position = UDim2.new(0.02, 0,0.06, 0)
				Title_Func.BackgroundTransparency = 1
				Title_Func.Text = NameFunction
				Title_Func.Font = Enum.Font.FredokaOne
				Title_Func.TextColor3 = NowTheame.TextColor2
				Title_Func.TextSize = 19
				Title_Func.ZIndex = 1
				Title_Func.TextXAlignment = Enum.TextXAlignment.Left
				AddJipaTaUI(Instance.new("UIStroke"), Title_Func, NowTheame.UIStroke1, 2.7, 0.52)
				
				local Button = Instance.new("ImageButton", FuncClick)
				Button.Position = UDim2.new(0.8, 0,0.06, 0)
				Button.Size = UDim2.new(0.18, 0,0.9, 0)	
				Button.BackgroundTransparency = 1
				Button.ImageColor3 = Color3.new(0.733333, 0.6, 1)
				Button.Image = "rbxassetid://75478984455074"
				Button.Name = NameFunction
				
				FuncClick:SetAttribute("Stage", false)
				
				Button.Activated:Connect(function()
					AnimateButton(Button, true)
					Button.ImageColor3 = Color3.new(1, 1, 1)
					TweenFrame(Button, {ImageColor3 = Color3.new(0.733333, 0.6, 1)}, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)	
					if Click_options.Callback then
						Click_options.Callback()
					end
				end)
				
				FuncClick:GetAttributeChangedSignal("Stage"):Connect(function()
					if FuncClick:GetAttribute("Stage") then
						if Click_options.Callback then
							Click_options.Callback()
						end
						FuncClick:SetAttribute("Stage", false)
					end
				end)
				
				return Click_options
			end
			
			function MiniFunction:Input(options)
				task.wait()
				
				local Input_options, NameFunction = {}, options and options.Title or "ห๊ะ"
				Input_options.Callback = options.Callback

				local FuncClick = Instance.new("Frame", BGFuncFrame)
				FuncClick.Size = UDim2.new(1, 0,0.185, 0)
				FuncClick.BackgroundTransparency = 0.6
				FuncClick.BackgroundColor3 = NowTheame.BackgroundColor2
				FuncClick.Name = "Func"..NameFunction
				Instance.new("UICorner", FuncClick)

				local Title_Func = Instance.new("TextLabel", FuncClick)
				Title_Func.Size = UDim2.new(0.45, 0,0.9, 0)
				Title_Func.Position = UDim2.new(0.02, 0,0.06, 0)
				Title_Func.BackgroundTransparency = 1
				Title_Func.Text = NameFunction
				Title_Func.Font = Enum.Font.FredokaOne
				Title_Func.TextColor3 = NowTheame.TextColor2
				Title_Func.TextSize = 19
				Title_Func.ZIndex = 1
				Title_Func.TextXAlignment = Enum.TextXAlignment.Left
				AddJipaTaUI(Instance.new("UIStroke"), Title_Func, NowTheame.UIStroke1, 2.7, 0.52)

				local TextBox = Instance.new("TextBox", FuncClick)
				TextBox.Position = UDim2.new(0.484, 0,0.06, 0)
				TextBox.Size = UDim2.new(0.505, 0,0.9, 0)	
				TextBox.BackgroundTransparency = 0.9
				TextBox.Font = Enum.Font.FredokaOne
				TextBox.TextColor3 = NowTheame.TextColor2
				TextBox.PlaceholderColor3 = Color3.new(0.733333, 0.6, 1)
				TextBox.TextSize = 12
				TextBox.Text = ""
				TextBox.PlaceholderText = options and options.Placeholder or "ใส่ค่าตรงนี้..."
				TextBox.Name = NameFunction
				Instance.new("UICorner", TextBox)
				
				FuncClick:SetAttribute("Value", TextBox.Text)
				
				TextBox:GetPropertyChangedSignal("Text"):Connect(function()
					if Input_options.Callback then
						Input_options.Callback(TextBox.Text)
					end
				end)
				
				FuncClick:GetAttributeChangedSignal("Value"):Connect(function()
					TextBox.Text = FuncClick:GetAttribute("Value")
					if Input_options.Callback then
						Input_options.Callback(TextBox.Text)
					end
				end)

				return Input_options
			end
			
			_G.ToggleButtonSomtank = {}
			
			function MiniFunction:Toggle(options)
				task.wait()
				
				local Toggle_options, NameFunction, StageText = {}, options and options.Title or "ห๊ะ", nil
				Toggle_options.Callback = options.Callback
				Toggle_options.Stage = options and options.Stage or false
				
				if not StageText and Toggle_options.Stage then
					if Toggle_options.Stage then
						StageText = "เปิด"
					else
						StageText = "ปิด"
					end
				end				

				local FuncClick = Instance.new("Frame", BGFuncFrame)
				FuncClick.Size = UDim2.new(1, 0,0.185, 0)
				FuncClick.BackgroundTransparency = 0.6
				FuncClick.BackgroundColor3 = NowTheame.BackgroundColor2
				FuncClick.Name = "Func"..NameFunction
				Instance.new("UICorner", FuncClick)

				local Title_Func = Instance.new("TextLabel", FuncClick)
				Title_Func.Size = UDim2.new(0.739, 0,0.9, 0)
				Title_Func.Position = UDim2.new(0.02, 0,0.06, 0)
				Title_Func.BackgroundTransparency = 1
				Title_Func.Text = NameFunction
				Title_Func.Font = Enum.Font.FredokaOne
				Title_Func.TextColor3 = NowTheame.TextColor2
				Title_Func.TextSize = 19
				Title_Func.ZIndex = 1
				Title_Func.TextXAlignment = Enum.TextXAlignment.Left
				AddJipaTaUI(Instance.new("UIStroke"), Title_Func, NowTheame.UIStroke1, 2.7, 0.52)

				local ToggleBg = Instance.new("Frame", FuncClick)
				ToggleBg.Size = UDim2.new(0.178, 0,0.448, 0)
				ToggleBg.Position = UDim2.new(0.8, 0,0.271, 0)
				ToggleBg.BackgroundColor3 = NowTheame.BackgroundColor1
				ToggleBg.Name = "ToggleBg"
				Instance.new("UICorner", ToggleBg)
				
				local Toggle = Instance.new("Frame", ToggleBg)
				Toggle.Size = UDim2.new(0, 17,0, 21)
				Toggle.Position = UDim2.new(0, 0,-0.152, 0)
				Toggle.BackgroundColor3 = NowTheame.BackgroundColor2
				Toggle.Name = "Toggle"
				Instance.new("UICorner", Toggle)
				
				local TextLabel_ValueOfToggle = Instance.new("TextLabel", Toggle)
				TextLabel_ValueOfToggle.Size = UDim2.new(0, 51,0, 16)
				TextLabel_ValueOfToggle.Position = UDim2.new(-1.015, 0,-0.971, 0)
				TextLabel_ValueOfToggle.BackgroundTransparency = 1
				TextLabel_ValueOfToggle.Text = StageText
				TextLabel_ValueOfToggle.Font = Enum.Font.FredokaOne
				TextLabel_ValueOfToggle.TextColor3 = NowTheame.TextColor2
				TextLabel_ValueOfToggle.TextSize = 19
				TextLabel_ValueOfToggle.TextTransparency = 1
				TextLabel_ValueOfToggle.ZIndex = 1
				TextLabel_ValueOfToggle.FontFace.Weight = Enum.FontWeight.Bold
				local UIStroke_TextLabel_ValueOfToggle = AddJipaTaUI(Instance.new("UIStroke"), TextLabel_ValueOfToggle, NowTheame.UIStroke1, 2.7, 1)
				
				local Button = Instance.new("TextButton", FuncClick)
				Button.Size = UDim2.new(0, 38,0, 28)
				Button.Position = UDim2.new(0.787, 0,0.113, 0)
				Button.BackgroundTransparency = 1
				Button.TextTransparency = 1
				Button.Name = "Button"..NameFunction
				Button.ZIndex = 3
				
				FuncClick:SetAttribute("Stage", false)
				
				local function MakeToggle(input)
					if input then
						Toggle.BackgroundColor3 = Color3.new(1, 1, 1)
						TweenFrame(Toggle, {BackgroundColor3 = Color3.new(0.619608, 0.368627, 1)}, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)	
						TweenFrame(Toggle, {Position = UDim2.new(0.5, 0,-0.152, 0)}, 0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
						if Toggle_options.Callback then
							Toggle_options.Callback(true)
						end
						FuncClick:SetAttribute("Stage", true)
						TextLabel_ValueOfToggle.Text = "เปิด"
					else
						Toggle.BackgroundColor3 = Color3.new(1, 1, 1)
						TweenFrame(Toggle, {BackgroundColor3 = Color3.new(0.619608, 0.368627, 1)}, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)	
						TweenFrame(Toggle, {Position = UDim2.new(0, 0,-0.152, 0)}, 0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
						if Toggle_options.Callback then
							Toggle_options.Callback(false)
						end
						FuncClick:SetAttribute("Stage", false)
						TextLabel_ValueOfToggle.Text = "ปิด"
					end
				end
				
				Button.Activated:Connect(function()
					if _G.ToggleButtonSomtank then
						_G.ToggleButtonSomtank[Button.Name] = not _G.ToggleButtonSomtank[Button.Name]
						if _G.ToggleButtonSomtank[Button.Name] then
							MakeToggle(true)
						else
							MakeToggle(false)
						end
					end
				end)
				
				Button.MouseEnter:Connect(function()
					TweenFrame(TextLabel_ValueOfToggle, {TextTransparency = 0}, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
					TweenFrame(UIStroke_TextLabel_ValueOfToggle, {Transparency = 0.52}, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
					if FuncClick:GetAttribute("Stage") then
						TextLabel_ValueOfToggle.Text = "เปิด"
					else
						TextLabel_ValueOfToggle.Text = "ปิด"
					end
				end)

				Button.MouseLeave:Connect(function()
					TweenFrame(TextLabel_ValueOfToggle, {TextTransparency = 1}, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
					TweenFrame(UIStroke_TextLabel_ValueOfToggle, {Transparency = 1}, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
					if FuncClick:GetAttribute("Stage") then
						TextLabel_ValueOfToggle.Text = "เปิด"
					else
						TextLabel_ValueOfToggle.Text = "ปิด"
					end
				end)
				
				FuncClick:GetAttributeChangedSignal("Stage"):Connect(function()
					if FuncClick:GetAttribute("Stage") then
						MakeToggle(true)
					else
						MakeToggle(false)
					end
				end)

				return Toggle_options
			end
			
			function MiniFunction:Slider(options)
				task.wait()
				
				local Slider_options, NameFunction = {}, options and options.Title or "ห๊ะ"
				Slider_options.Callback = options.Callback
				Slider_options.SlideStep = options.Value.Step
				Slider_options.SlideMin = options.Value.Min
				Slider_options.SlideMax = options.Value.Max
				Slider_options.SlideDefault = options.Value.Default
				
				local FuncClick = Instance.new("Frame", BGFuncFrame)
				FuncClick.Size = UDim2.new(1, 0,0.185, 0)
				FuncClick.BackgroundTransparency = 0.6
				FuncClick.BackgroundColor3 = NowTheame.BackgroundColor2
				FuncClick.Name = "Func"..NameFunction
				Instance.new("UICorner", FuncClick)

				local SlideBar = Instance.new("Frame", FuncClick)
				SlideBar.Size = UDim2.new(0, 139,0, 12)
				SlideBar.Position = UDim2.new(0.041, 0,0.362, 0)
				SlideBar.BackgroundTransparency = 0.6
				SlideBar.BackgroundColor3 = NowTheame.BackgroundColor2
				SlideBar.Name = "Func"..NameFunction
				Instance.new("UICorner", SlideBar)
				
				local Slide = Instance.new("Frame", SlideBar)
				Slide.Size = UDim2.new(0, 12,0, 23)
				Slide.Position = UDim2.new(0, 0,-0.484, 0)
				Slide.BackgroundColor3 = NowTheame.BackgroundColor2
				Slide.Name = "Func"..NameFunction
				Instance.new("UICorner", Slide)
				
				local Title_Func = Instance.new("TextLabel", Slide)
				Title_Func.Size = UDim2.new(0, 51,0, 16)
				Title_Func.Position = UDim2.new(-1.681, 0,-0.836, 0)
				Title_Func.BackgroundTransparency = 1
				Title_Func.Text = Slider_options.SlideDefault
				Title_Func.Font = Enum.Font.FredokaOne
				Title_Func.TextColor3 = NowTheame.TextColor2
				Title_Func.TextSize = 19
				Title_Func.ZIndex = 1
				Title_Func.TextTransparency = 1
				Title_Func.Name = "TextLabel_ValueOfSlide"
				local UIStroke_Title_Func = AddJipaTaUI(Instance.new("UIStroke"), Title_Func, NowTheame.UIStroke1, 2.7, 1)
				
				local ResetButton = Instance.new("ImageButton", FuncClick)
				ResetButton.Position = UDim2.new(0.8, 0,0.06, 0)
				ResetButton.Size = UDim2.new(0.18, 0,0.9, 0)
				ResetButton.BackgroundTransparency = 1
				ResetButton.ImageColor3 = Color3.new(0.733333, 0.6, 1)
				ResetButton.Image = "rbxassetid://87453335489922"
				ResetButton.Name = "ResetButton"
				
				local Button = Instance.new("TextButton", Slide)
				Button.Size = UDim2.new(0, 26,0, 38)
				Button.Position = UDim2.new(-0.585, 0,-0.343, 0)
				Button.BackgroundTransparency = 1
				Button.TextTransparency = 1
				Button.Name = "Button"..NameFunction
				Button.ZIndex = 3
				
				FuncClick:SetAttribute("Value", Slider_options.SlideDefault)
								
				local barSize, OldThisSlideValue = SlideBar.AbsoluteSize.X, 0

				local function positionToValue(x)
					local ratio = math.clamp(x / barSize, 0, 1)
					local rawValue = Slider_options.SlideMin + (Slider_options.SlideMax - Slider_options.SlideMin) * ratio					
					local steppedValue = math.floor(rawValue / Slider_options.SlideStep + 0.5) * Slider_options.SlideStep
					return math.clamp(steppedValue, Slider_options.SlideMin, Slider_options.SlideMax)
				end
				
				local function valueToPosition(value)
					local ratio = (value - Slider_options.SlideMin) / (Slider_options.SlideMax - Slider_options.SlideMin)
					return UDim2.new(0, barSize * ratio, Slide.Position.Y.Scale, Slide.Position.Y.Offset)
				end
				
				local function formatNumber(num)
					local result = tonumber(string.format("%.2f", num))
					return tonumber(tostring(result))
				end
				
				local function updateSlide(value)
					Slide.Position = valueToPosition(value)
					Title_Func.Text = tostring(formatNumber(value))
					if Slider_options.Callback then
						Slider_options.Callback(value)
					end
					Slide:SetAttribute("Value", value)
				end

				updateSlide(Slider_options.SlideDefault)

				local dragging = false

				local function startDrag(input)
					dragging = true
					local moveConn, endConn
					moveConn = UserInputService.InputChanged:Connect(function(moveInput)
						if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
							if dragging then
								local relX = moveInput.Position.X - SlideBar.AbsolutePosition.X
								updateSlide(positionToValue(relX))
							end
						end
					end)
					endConn = input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
							moveConn:Disconnect()
							endConn:Disconnect()
							if Slide:GetAttribute("Value") then
								Slide:SetAttribute("EndValue", Slide:GetAttribute("Value"))
							end
							task.spawn(function()
								wait(1)
								if Slide:GetAttribute("Value") and Slide:GetAttribute("EndValue") and Slide:GetAttribute("EndValue") == Slide:GetAttribute("Value") then
									TweenFrame(Title_Func, {TextTransparency = 1}, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
									TweenFrame(UIStroke_Title_Func, {Transparency = 1}, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
								end
							end)
						end
					end)
				end
				Button.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						TweenFrame(Title_Func, {TextTransparency = 0}, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
						TweenFrame(UIStroke_Title_Func, {Transparency = 0.52}, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
						startDrag(input)						
					end
				end)
				
				Button.MouseEnter:Connect(function()
					TweenFrame(Title_Func, {TextTransparency = 0}, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
					TweenFrame(UIStroke_Title_Func, {Transparency = 0.52}, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
					if Slide:GetAttribute("Value") then
						Slide:SetAttribute("HoverValue", Slide:GetAttribute("Value"))
					end
				end)
				
				Button.MouseLeave:Connect(function()
					if Slide:GetAttribute("Value") and Slide:GetAttribute("HoverValue") and Slide:GetAttribute("HoverValue") == Slide:GetAttribute("Value") then
						TweenFrame(Title_Func, {TextTransparency = 1}, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
						TweenFrame(UIStroke_Title_Func, {Transparency = 1}, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
					end
				end)
				
				ResetButton.Activated:Connect(function()
					updateSlide(Slider_options.SlideDefault)
					AnimateButton(ResetButton, true)
					SpinFrame(ResetButton)
					ResetButton.ImageColor3 = Color3.new(1, 1, 1)
					TweenFrame(ResetButton, {ImageColor3 = Color3.new(0.733333, 0.6, 1)}, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)	
					if Slider_options.Callback then
						Slider_options.Callback(Slider_options.SlideDefault)
					end
					task.spawn(function()
						wait(0.5)
						TweenFrame(Title_Func, {TextTransparency = 1}, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
						TweenFrame(UIStroke_Title_Func, {Transparency = 1}, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
					end)
				end)
				
				FuncClick:GetAttributeChangedSignal("Value"):Connect(function()
					if FuncClick:GetAttribute("Value") then
						updateSlide(FuncClick:GetAttribute("Value"))
					end
				end)
				
				return Slider_options
			end
			
			function MiniFunction:SliderEnum(options)
				task.wait()

				local Slider_options, NameFunction = {}, options and options.Title or "EnumSlider"
				Slider_options.Callback = options.Callback
				Slider_options.EnumList = options.Options or {"Option1", "Option2", "Option3"}
				Slider_options.DefaultIndex = options.Default or 1
				local totalOptions = (options.Options and #options.Options) or 1
				
				local FuncClick = Instance.new("Frame", BGFuncFrame)
				FuncClick.Size = UDim2.new(1, 0, 0.185, 0)
				FuncClick.BackgroundTransparency = 0.6
				FuncClick.BackgroundColor3 = NowTheame.BackgroundColor2
				FuncClick.Name = "Func"..NameFunction
				Instance.new("UICorner", FuncClick)

				local SlideBar = Instance.new("Frame", FuncClick)
				SlideBar.Size = UDim2.new(0, 174,0, 12)
				SlideBar.Position = UDim2.new(0.051, 0,0.338, 0)
				SlideBar.BackgroundTransparency = 0.6
				SlideBar.BackgroundColor3 = NowTheame.BackgroundColor2
				Instance.new("UICorner", SlideBar)

				local Slide = Instance.new("Frame", SlideBar)
				Slide.Size = UDim2.new(0, 12, 0, 23)
				Slide.Position = UDim2.new(0, 0, -0.484, 0)				
				Slide.BackgroundColor3 = NowTheame.BackgroundColor2
				Instance.new("UICorner", Slide)

				local Title_Func = Instance.new("TextLabel", SlideBar)
				Title_Func.Size = UDim2.new(0, 177,0, 29)
				Title_Func.Position = UDim2.new(-0.011, 0,-0.786, 0)
				Title_Func.BackgroundTransparency = 1
				Title_Func.Text = Slider_options.EnumList[Slider_options.DefaultIndex]
				Title_Func.Font = Enum.Font.FredokaOne
				Title_Func.TextColor3 = NowTheame.TextColor2
				Title_Func.TextSize = 18
				Title_Func.ZIndex = 1
				Title_Func.TextTransparency = 1
				Title_Func.Name = "TextLabel_ValueOfSlide"
				local UIStroke_Title_Func = AddJipaTaUI(Instance.new("UIStroke"), Title_Func, NowTheame.UIStroke1, 2.7, 1)

				local Button = Instance.new("TextButton", FuncClick)
				Button.Size = UDim2.new(1, 0,1, 0)
				Button.BackgroundTransparency = 1
				Button.TextTransparency = 1
				Button.Name = "Button"..NameFunction
				Button.ZIndex = 3

				local barSize = SlideBar.AbsoluteSize.X

				local function positionToIndex(x)
					local ratio = math.clamp(x / barSize, 0, 1)
					local index = math.clamp(math.floor(ratio * totalOptions + 1 + 0.5), 1, totalOptions)
					return index
				end

				local function indexToPosition(index)
					local ratio = (index - 1) / (totalOptions - 1)
					return UDim2.new(0, barSize * ratio, Slide.Position.Y.Scale, Slide.Position.Y.Offset)
				end

				local function updateSlide(index)
					local name = Slider_options.EnumList[index]
					Slide.Position = indexToPosition(index)
					Title_Func.Text = tostring(name)
					if Slider_options.Callback then
						Slider_options.Callback(name, index)
					end
					FuncClick:SetAttribute("ValueIndex", index)
				end

				updateSlide(Slider_options.DefaultIndex)

				local dragging = false

				local function startDrag(input)
					dragging = true
					local moveConn, endConn
					moveConn = UserInputService.InputChanged:Connect(function(moveInput)
						if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
							if dragging then
								local relX = moveInput.Position.X - SlideBar.AbsolutePosition.X
								local index = positionToIndex(relX)
								updateSlide(index)
							end
						end
					end)
					endConn = input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
							moveConn:Disconnect()
							endConn:Disconnect()
						end
					end)
				end

				Button.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						TweenFrame(Title_Func, {TextTransparency = 0}, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
						TweenFrame(UIStroke_Title_Func, {Transparency = 0.52}, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
						startDrag(input)
					end
				end)
				
				Button.MouseEnter:Connect(function()
					TweenFrame(Title_Func, {TextTransparency = 0}, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
					TweenFrame(UIStroke_Title_Func, {Transparency = 0.52}, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				end)

				Button.MouseLeave:Connect(function()
					TweenFrame(Title_Func, {TextTransparency = 1}, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
					TweenFrame(UIStroke_Title_Func, {Transparency = 1}, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				end)

				return Slider_options
			end
			
			_G.NowThisFrameIsOpenDropdown = nil
									
			function MiniFunction:Dropdown(options)
				task.wait()
				
				local Dropdown_options, NameFunction = {}, options and options.Title
				Dropdown_options.Callback = options.Callback
				
				Dropdown_options.Value = options.Value
				Dropdown_options.Values = options.Value.Values
				Dropdown_options.SelectNow = options.Value.SelectNow
				Dropdown_options.Multi = options.Value.Multi
				Dropdown_options.AllowNone = options.Value.AllowNone
				
				Dropdown_options.OldValue = nil
				
				local FuncClick = Instance.new("Frame", BGFuncFrame)
				FuncClick.Size = UDim2.new(1, 0,0.185, 0)
				FuncClick.BackgroundTransparency = 0.6
				FuncClick.BackgroundColor3 = NowTheame.BackgroundColor2
				FuncClick.Name = "Func"..NameFunction
				Instance.new("UICorner", FuncClick)

				local Title_Func = Instance.new("TextLabel", FuncClick)
				Title_Func.Size = UDim2.new(0.45, 0,0.9, 0)
				Title_Func.Position = UDim2.new(0.02, 0,0.06, 0)
				Title_Func.BackgroundTransparency = 1
				Title_Func.Text = NameFunction
				Title_Func.Font = Enum.Font.FredokaOne
				Title_Func.TextColor3 = NowTheame.TextColor2
				Title_Func.TextScaled = true
				Title_Func.ZIndex = 1
				Title_Func.TextXAlignment = Enum.TextXAlignment.Left
				AddJipaTaUI(Instance.new("UIStroke"), Title_Func, NowTheame.UIStroke1, 2.7, 0.52)
				
				local FakeButtonFrame = Instance.new("Frame", FuncClick)
				FakeButtonFrame.Size = UDim2.new(0.486, 0,0.9, 0)
				FakeButtonFrame.Position = UDim2.new(0.484, 0,0.06, 0)
				FakeButtonFrame.BackgroundTransparency = 0.9
				FakeButtonFrame.BackgroundColor3 = Color3.new(0.945098, 0.945098, 0.945098)
				FakeButtonFrame.Name = "Func"..NameFunction
				Instance.new("UICorner", FakeButtonFrame)

				local FakeButtonFrame_Text = Instance.new("TextLabel", FakeButtonFrame)
				FakeButtonFrame_Text.Size = UDim2.new(0.75, 0,1, 0)
				FakeButtonFrame_Text.BackgroundTransparency = 1
				FakeButtonFrame_Text.Name = "Func"..NameFunction
				FakeButtonFrame_Text.Text = Dropdown_options.SelectNow
				FakeButtonFrame_Text.Font = Enum.Font.FredokaOne
				FakeButtonFrame_Text.TextColor3 = NowTheame.TextColor2
				FakeButtonFrame_Text.TextScaled = true
				FakeButtonFrame_Text.ZIndex = 1
				FakeButtonFrame_Text.TextXAlignment = Enum.TextXAlignment.Left
				AddJipaTaUI(Instance.new("UIStroke"), Title_Func, NowTheame.UIStroke1, 2.7, 0.52)
								
				local ButtonFake = Instance.new("ImageButton", FuncClick)
				ButtonFake.Position = UDim2.new(0.8, 0,0.06, 0)
				ButtonFake.Size = UDim2.new(0.18, 0,0.9, 0)	
				ButtonFake.BackgroundTransparency = 1
				ButtonFake.ImageColor3 = Color3.new(1, 1, 1)
				ButtonFake.Image = "rbxassetid://95008508528230"
				ButtonFake.Name = NameFunction
				
				local Button = Instance.new("ImageButton", FakeButtonFrame)
				Button.Size = UDim2.new(1, 0,1, 0)	
				Button.BackgroundTransparency = 1
				Button.Image = ""
				Button.Name = "Button"
				Button.ZIndex = 5
				
				local Select_ScrollingFrame = Instance.new("ScrollingFrame", BGFrame)
				Select_ScrollingFrame.Size = UDim2.new(0.179, 0,4.435, 0)
				Select_ScrollingFrame.Position = UDim2.new(0.772, 0,0.283, 0)
				Select_ScrollingFrame.BackgroundTransparency = 1
				Select_ScrollingFrame.Name = "DropdownSelect_"..NameFunction
				Select_ScrollingFrame.ScrollBarThickness = 0
				Select_ScrollingFrame.Visible = false
				Select_ScrollingFrame.MidImage = ""
				local UIListLayout_Select_ScrollingFrame = Instance.new("UIListLayout", Select_ScrollingFrame)
				UIListLayout_Select_ScrollingFrame.Padding = UDim.new(0.001, 0)
				UIListLayout_Select_ScrollingFrame.FillDirection = Enum.FillDirection.Vertical
				local FolderDropDown = Instance.new("Folder", Select_ScrollingFrame)
				FolderDropDown.Name = "FolderDropDown_Select"
				FolderDropDown:SetAttribute("DropdownOwner", NameFunction)
				
				local function CallbackDropdown()
					local AllDropdown = {}
					for i, Object in pairs(FolderDropDown:GetChildren()) do
						if Object and Object:IsA("BoolValue") then							
							if Object.Value then
								table.insert(AllDropdown, Object.Name)
							end						
						end
					end
					if AllDropdown and Dropdown_options.Callback then
						Dropdown_options.Callback(AllDropdown)
					end	
				end
				
				local function MoveFrameToMatch(Frame1, Frame2, speed)
					if not (Frame1 and Frame2) then return end
					local targetPos = Frame2.AbsolutePosition
					local parentGui = Frame1.Parent
					local relativePos = UDim2.fromOffset(targetPos.X - parentGui.AbsolutePosition.X,targetPos.Y - parentGui.AbsolutePosition.Y)
					local tweenInfo = TweenInfo.new(speed or 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					local tween = TweenService:Create(Frame1, tweenInfo, {Position = relativePos})
					tween:Play()
				end
								
				local function UpdateSelect()
					for i,v in pairs(Select_ScrollingFrame:GetChildren()) do
						if v:IsA("TextButton") then
							v:Destroy()
						end
					end					
					Select_ScrollingFrame.Visible = true					
					for i,v in pairs(Dropdown_options.Values) do						
						local ThisDropIsOn = false
						if #FolderDropDown:GetChildren() < #Dropdown_options.Values then
							local BoolValue = Instance.new("BoolValue", FolderDropDown)
							BoolValue.Name = v
							if v == Dropdown_options.SelectNow then
								BoolValue.Value = true
							end
						else
							if FolderDropDown:FindFirstChild(v) and FolderDropDown:FindFirstChild(v).Value == true then
								ThisDropIsOn = true
							end
						end
						local TextButton = Instance.new("TextButton", Select_ScrollingFrame)
						TextButton.Size = UDim2.new(1, 0,0, 0)	
						TextButton.BackgroundTransparency = 0.1
						TextButton.BackgroundColor3 = NowTheame.BackgroundColor1
						TextButton.Name = "Button"..v
						TextButton.Text = v
						TextButton.Font = Enum.Font.FredokaOne
						TextButton.TextColor3 = NowTheame.TextColor2
						TextButton.TextSize = 14
						TextButton.ZIndex = 5
						Instance.new("UICorner", TextButton)
						AddJipaTaUI(Instance.new("UIStroke"), TextButton, NowTheame.UIStroke1, 2.7, 0.52)	
						local FakeButtonFrame = Instance.new("Frame", TextButton)
						FakeButtonFrame.Size = UDim2.new(0, 3,0, 23)
						FakeButtonFrame.Position = UDim2.new(0, 0,0, 3)
						FakeButtonFrame.BackgroundColor3 = NowTheame.BackgroundColor1
						FakeButtonFrame.Name = "ColorSelect"
						FakeButtonFrame.ZIndex = 6
						Instance.new("UICorner", FakeButtonFrame)
						TextButton.Activated:Connect(function()
							if FolderDropDown:FindFirstChild(v) and TextButton:FindFirstChild("ColorSelect") then
								local ValueObject, ColorSelect = FolderDropDown:FindFirstChild(v), TextButton:FindFirstChild("ColorSelect")
								ValueObject.Value = not ValueObject.Value
								if ValueObject.Value then
									if not Dropdown_options.Multi then
										for i,v in pairs(FolderDropDown:GetChildren()) do
											if v.Name ~= ValueObject.Name then
												v.Value = false
											end
										end
										for i,v in pairs(Select_ScrollingFrame:GetChildren()) do
											if v:IsA("TextButton") and v:FindFirstChild("ColorSelect") then
												v:FindFirstChild("ColorSelect").BackgroundColor3 = NowTheame.BackgroundColor1
											end
										end
									end
									Dropdown_options.OldValue = ValueObject.Name
									TweenFrame(FakeButtonFrame, {BackgroundColor3 = Color3.new(0.47451, 0.313725, 1)}, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
								else
									if not Dropdown_options.AllowNone then
										local NowSelectCount = 0
										for i,v in pairs(FolderDropDown:GetChildren()) do
											if v.Value and v.Value == true then
												NowSelectCount = NowSelectCount +1
											end
										end
										if NowSelectCount == 0 then
											ValueObject.Value = true
										else
											TweenFrame(FakeButtonFrame, {BackgroundColor3 = Color3.new(0.137255, 0.0941176, 0.294118)}, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
										end
									else
										TweenFrame(FakeButtonFrame, {BackgroundColor3 = Color3.new(0.137255, 0.0941176, 0.294118)}, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
									end
								end
							end
							CallbackDropdown()
						end)
						local TweenScale = TweenFrame(TextButton, {Size = UDim2.new(1, 0,0.02, 0)}, 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
						TweenScale.Completed:Connect(function()
							TextButton.Size = UDim2.new(1, 0,0.02, 0)
							if Dropdown_options.SelectNow then
								if Dropdown_options.SelectNow == v then
									if #FolderDropDown:GetChildren() < #Dropdown_options.Values then
										TweenFrame(FakeButtonFrame, {BackgroundColor3 = Color3.new(0.47451, 0.313725, 1)}, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
									else
										if ThisDropIsOn then
											TweenFrame(FakeButtonFrame, {BackgroundColor3 = Color3.new(0.47451, 0.313725, 1)}, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
										end
									end
								else
									if ThisDropIsOn then
										TweenFrame(FakeButtonFrame, {BackgroundColor3 = Color3.new(0.47451, 0.313725, 1)}, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
									end
								end								
							end
						end)
						wait(0.08)
					end
				end
				
				local function CloseSelect(ScrollingFrame)
					if not ScrollingFrame then return end
					local LastTween = nil
					for i,v in pairs(ScrollingFrame:GetChildren()) do
						if v:IsA("TextButton") then
							task.spawn(function()
								AddJipaTaUI(Instance.new("UIStroke"), v, NowTheame.UIStroke1, 2.7, 0.52)						
								local TweenScale = TweenFrame(v, {Size = UDim2.new(1, 0,0, 0)}, 0.07, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)						
								TweenScale.Completed:Connect(function()
									v.Size = UDim2.new(1, 0,0, 0)
								end)
								LastTween = TweenScale
							end)
							wait(0.05)
						end
					end
					ScrollingFrame.Visible = false
				end
				
				Function_ScrollingFrame:GetPropertyChangedSignal("Visible"):Connect(function()
					if not Function_ScrollingFrame.Visible then
						if _G.NowThisFrameIsOpenDropdown then
							CloseSelect(_G.NowThisFrameIsOpenDropdown)
							if _G.NowThisFrameIsOpenDropdown:GetAttribute("IsOpen") then
								_G.NowThisFrameIsOpenDropdown:SetAttribute("IsOpen", false)
							end
						end	
					end
				end)
				
				Button.MouseButton1Click:Connect(function()
					Select_ScrollingFrame:SetAttribute("IsOpen", not Select_ScrollingFrame:GetAttribute("IsOpen"))
					if Select_ScrollingFrame:GetAttribute("IsOpen") then
						CloseSelect(Select_ScrollingFrame)
						CallbackDropdown()
					else
						if _G.NowThisFrameIsOpenDropdown then
							CloseSelect(_G.NowThisFrameIsOpenDropdown)
							CallbackDropdown()
							if _G.NowThisFrameIsOpenDropdown:GetAttribute("IsOpen") then
								_G.NowThisFrameIsOpenDropdown:SetAttribute("IsOpen", false)
							end
						end		
						MoveFrameToMatch(Select_ScrollingFrame, FakeButtonFrame_Text, 0.1)
						UpdateSelect()						
						_G.NowThisFrameIsOpenDropdown = Select_ScrollingFrame						
					end
				end)
				
				for i,v1 in pairs(Dropdown_options.Values) do
					FuncClick:SetAttribute(v1, false)
					FuncClick:GetAttributeChangedSignal(v1):Connect(function()						
						for i,v in pairs(FolderDropDown:GetChildren()) do
							if v.Name == v1 then
								if FuncClick:GetAttribute(v1) then
									v.Value = true
								else
									v.Value = false
								end								
							end
						end
						UpdateSelect()
					end)
				end
				
				function Dropdown_options:ShowThisItem(Values)
					if Values then
						Dropdown_options.Values = Values
					end
				end
				
				return Dropdown_options
			end
			
			function MiniFunction:Frame3DShow(options)
				task.wait()

				local Frame3DShow_options, NameFunction = {}, options and options.Title
				Frame3DShow_options.ItemShow = options.ItemShow
				Frame3DShow_options.Setting = options.Setting
				Frame3DShow_options.Radius = options.Setting.Radius
				Frame3DShow_options.Spin = options.Setting.Spin
				Frame3DShow_options.Height = options.Setting.Height
				Frame3DShow_options.SpinSpeed = options.Setting.SpinSpeed
				
				local FuncClick = Instance.new("Frame", BGFuncFrame)
				FuncClick.Size = UDim2.new(1, 0,0.595, 0)
				FuncClick.BackgroundTransparency = 0.6
				FuncClick.BackgroundColor3 = NowTheame.BackgroundColor2
				FuncClick.Name = "Func"..NameFunction
				Instance.new("UICorner", FuncClick)

				local Title_Func = Instance.new("TextLabel", FuncClick)
				Title_Func.Size = UDim2.new(0.825, 0,0.184, 0)
				Title_Func.Position = UDim2.new(0.02, 0,0.03, 0)
				Title_Func.BackgroundTransparency = 1
				Title_Func.Text = NameFunction
				Title_Func.Font = Enum.Font.FredokaOne
				Title_Func.TextColor3 = NowTheame.TextColor2
				Title_Func.TextSize = 19
				Title_Func.ZIndex = 1
				Title_Func.TextXAlignment = Enum.TextXAlignment.Left
				AddJipaTaUI(Instance.new("UIStroke"), Title_Func, NowTheame.UIStroke1, 2.7, 0.52)

				local Button = Instance.new("ImageButton", FuncClick)
				Button.Position = UDim2.new(0.88, 0,0.045, 0)
				Button.Size = UDim2.new(0.101, 0,0.154, 0)	
				Button.BackgroundTransparency = 1
				Button.ImageColor3 = Color3.new(0.733333, 0.6, 1)
				Button.Image = "rbxassetid://97010139919322"
				Button.Name = NameFunction
				
				local ViewportFrame = Instance.new("ViewportFrame", FuncClick)
				ViewportFrame.Size = UDim2.new(0, 176,0, 84)
				ViewportFrame.Position = UDim2.new(0.035, 0,0.265, 0)
				ViewportFrame.BackgroundTransparency = 0.65
				ViewportFrame.BackgroundColor3 = NowTheame.BackgroundColor1
				ViewportFrame.ZIndex = 2
				ViewportFrame.Name = "ViewportFrame"
				ViewportFrame.Ambient = Color3.new(1, 1, 1)
				ViewportFrame.LightColor = Color3.new(1, 1, 1)
				Instance.new("UICorner", ViewportFrame)
				local WorldModel = Instance.new("WorldModel", ViewportFrame)
				local Camera = Instance.new("Camera", FuncClick)
				ViewportFrame.CurrentCamera = Camera
								
				local NowShowItem, angle = nil, 0
				
				Button.Activated:Connect(function()
					FuncClick:SetAttribute("Hide", not FuncClick:GetAttribute("Hide"))
					if FuncClick:GetAttribute("Hide") then
						Button.Image = "rbxassetid://90717143381517"
						ViewportFrame.Visible = true
					else
						Button.Image = "rbxassetid://97010139919322"
						ViewportFrame.Visible = false
					end
				end)
				
				local function SetShowThis(Item)
					if NowShowItem then
						NowShowItem:Destroy()
					end
					if Item then
						NowShowItem = Item
						local size = Item:GetExtentsSize()
						local center = Item:GetBoundingBox().Position				
						local radius = math.max(size.X, size.Z) * Frame3DShow_options.Radius or 1
						local height = size.Y * Frame3DShow_options.Height or 0.1
						Camera.CameraType = Enum.CameraType.Scriptable
						task.spawn(function()
							while true do
								if NowShowItem then
									angle = angle + math.rad(Frame3DShow_options.SpinSpeed or 5) * 0.1
									local x = math.cos(angle) * radius
									local z = math.sin(angle) * radius
									local cameraPos = Vector3.new(center.X + x, center.Y + height, center.Z + z)
									Camera.CFrame = CFrame.new(cameraPos, center)
									task.wait()
									if Frame3DShow_options.Spin == false then
										break
									end
									print("Spin")
									if not FuncClick:GetAttribute("Hide") then
										repeat
											wait(0.1)
										until FuncClick:GetAttribute("Hide")
									end
								else
									task.wait(1)
								end
							end
						end)
					end
				end
				
				Function_ScrollingFrame:GetPropertyChangedSignal("Visible"):Connect(function()					
					if Function_ScrollingFrame.Visible then
						FuncClick:SetAttribute("Hide", true)
					else
						FuncClick:SetAttribute("Hide", false)
					end
				end)
				
				if Frame3DShow_options and Frame3DShow_options.ItemShow then
					if Frame3DShow_options.ItemShow then
						local ItemToShow = Instance.new("Model", WorldModel)
						for _, item in ipairs(Frame3DShow_options.ItemShow:GetChildren()) do
							pcall(function()
								local CloneThis = item:Clone()
								CloneThis.Parent = ItemToShow
							end)							
						end
						SetShowThis(ItemToShow)
					end
				end
				
				function Frame3DShow_options:ShowThisItem(Item)
					if Item then
						local ItemToShow = Instance.new("Model", WorldModel)
						for _, item in ipairs(Item:GetChildren()) do
							pcall(function()
								local CloneThis = item:Clone()
								CloneThis.Parent = ItemToShow
							end)							
						end
						task.wait(0.1)
						SetShowThis(ItemToShow)
					else
						if NowShowItem then
							NowShowItem:Destroy()
						end
					end
				end

				return Frame3DShow_options
			end
			
			return MiniFunction
		end
		
		function Functions:LineGraph(options)
			task.wait()

			local LineGraph_options, NameFunction = {}, options and options.Title
			LineGraph_options.Callback = options.Callback
			LineGraph_options.Values = options.Values
			LineGraph_options.Description = options.Description
			LineGraph_options.Values_date = options.Values_date or nil
			
			local BGFuncFrame = Instance.new("Frame", Function_ScrollingFrame)
			BGFuncFrame.Size = UDim2.new(0, 388,0, 222)
			BGFuncFrame.BackgroundColor3 = Color3.fromRGB(48, 35, 75)
			BGFuncFrame.BackgroundTransparency = 0.35			
			BGFuncFrame.Name = "BGFuncFrame"
			Instance.new("UICorner", BGFuncFrame)

			local TitleFrame = Instance.new("Frame", BGFuncFrame)
			TitleFrame.Size = UDim2.new(1, 0,0.18, 0)
			TitleFrame.BackgroundColor3 = Color3.fromRGB(73, 40, 122)
			TitleFrame.Name = "TitleFrame"
			TitleFrame.ZIndex = 5
			Instance.new("UICorner", TitleFrame)

			local Title_Textlabel = Instance.new("TextLabel", TitleFrame)
			Title_Textlabel.Size = UDim2.new(0.972, 0,0.9, 0)
			Title_Textlabel.Position = UDim2.new(0.015, 0,0.05, 0)
			Title_Textlabel.BackgroundTransparency = 1
			Title_Textlabel.Name = "Title"
			Title_Textlabel.Text = NameFunction or "บัคกิน"
			Title_Textlabel.Font = Enum.Font.FredokaOne
			Title_Textlabel.TextColor3 = NowTheame.TextColor2
			Title_Textlabel.TextSize = 34
			Title_Textlabel.ZIndex = 6
			AddJipaTaUI(Instance.new("UIStroke"), Title_Textlabel, NowTheame.UIStroke1, 2.7, 0.52)
			local UIStroke_Title_Textlabel = AddJipaTaUI(Instance.new("UIStroke"), Title_Textlabel, NowTheame.UIStroke2, 1.6, 0.52)
			UIStroke_Title_Textlabel.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			
			local GraphFrame = Instance.new("Frame", TitleFrame)
			GraphFrame.Size = UDim2.new(0, 378,0, 178)
			GraphFrame.Position = UDim2.new(0.012, 0,1.086, 0)
			GraphFrame.BackgroundTransparency = 0.95
			GraphFrame.Name = "GraphFrame"
			
			local Description = Instance.new("TextLabel", GraphFrame)
			Description.Size = UDim2.new(0.791, 0,0.107, 0)
			Description.Position = UDim2.new(0.008, 0,-0, 0)
			Description.BackgroundTransparency = 1
			Description.Name = "Description"
			Description.Text = LineGraph_options and LineGraph_options.Description or "บัคกิน"
			Description.Font = Enum.Font.FredokaOne
			Description.TextColor3 = NowTheame.TextColor2
			Description.TextScaled = true
			Description.ZIndex = 3
			Description.TextXAlignment = Enum.TextXAlignment.Left
			AddJipaTaUI(Instance.new("UIStroke"), Description, NowTheame.UIStroke1, 2.7, 0.52)
						
			local ButtonCheck = Instance.new("ImageButton", BGFuncFrame)
			ButtonCheck.Size = UDim2.new(0, 385,0, 216)	
			ButtonCheck.Position = UDim2.new(0.007, 0,0.004, 0)
			ButtonCheck.BackgroundTransparency = 1
			ButtonCheck.Image = ""
			ButtonCheck.Name = "Button"
			ButtonCheck.ZIndex = 5
			
			local LineGraphFunction = {}
			LineGraphFunction.Gui = Function_ScrollingFrame			
			
			local Table_Point = {}
			local Table_Line = {}
			local Table_HLineLabel = {}
			local Table_PointLabel = {}

			local graphHeight = GraphFrame.AbsoluteSize.Y

			local function createPoint(x, y)
				local point = Instance.new("Frame")
				table.insert(Table_Point, point)
				point.Size = UDim2.new(0, 10, 0, 10)
				point.AnchorPoint = Vector2.new(0.5, 0.5)
				point.Position = UDim2.new(0, x, 0, y)
				point.BackgroundColor3 = Color3.fromRGB(255, 185, 7)
				point.BorderSizePixel = 0
				point.BackgroundTransparency = 1
				point.Parent = GraphFrame
				point.Name = "pointer"
				point.ZIndex = 3
				local UICorner = Instance.new("UICorner", point)
				UICorner.CornerRadius = UDim.new(1, 0)
				return point
			end
			local function createLine(p1, p2)
				local line = Instance.new("Frame")
				table.insert(Table_Line, line)
				line.Name = "line"
				line.AnchorPoint = Vector2.new(0.5, 0.5)
				line.BackgroundColor3 = Color3.fromRGB(130, 20, 255)
				line.BorderSizePixel = 0
				line.Position = UDim2.new(0, (p1.X + p2.X)/2, 0, (p1.Y + p2.Y)/2)
				local UICorner = Instance.new("UICorner", line)
				UICorner.CornerRadius = UDim.new(0, 0.5)
				local dx = p2.X - p1.X
				local dy = p2.Y - p1.Y
				local length = math.sqrt(dx*dx + dy*dy)
				line.Size = UDim2.new(0, 0, 0, 2)
				line.Rotation = math.deg(math.atan2(dy, dx))
				line.Parent = GraphFrame
				local tween = TweenService:Create(line, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, length + 1, 0, 4)})
				tween:Play()
				return line
			end
			local function drawGraph(Values_Input)
				for _, obj in ipairs(Table_PointLabel) do
					if obj and obj.Parent then
						obj:Destroy()
					end
				end
				Table_PointLabel = {}

				local spacing = GraphFrame.AbsoluteSize.X / (#Values_Input - 1)
				local lastPos = nil
				for i, value in ipairs(Values_Input) do
					local x = (i - 1) * spacing
					local yPos = graphHeight - (value / 100) * graphHeight
					local point = createPoint(x, yPos)
					TweenService:Create(point, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
					local label = Instance.new("TextLabel")
					label.Name = "PointLabel_" .. i
					label.AnchorPoint = Vector2.new(0.5, 0)
					label.Position = UDim2.new(0, x, 1, -7)
					label.Size = UDim2.new(0, 50, 0, 20)
					label.BackgroundTransparency = 1
					label.Text = LineGraph_options.Values_date[i] or tostring(value)
					label.TextColor3 = NowTheame.TextColor2
					label.TextTransparency = 1
					label.Font = Enum.Font.SourceSansBold
					label.TextSize = 16
					label.ZIndex = 2
					label.Parent = GraphFrame
					AddJipaTaUI(Instance.new("UIStroke"), label, NowTheame.UIStroke1, 2.7, 0.52)
					table.insert(Table_PointLabel, label)

					task.delay(i * 0.05, function()
						TweenService:Create(label, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							TextTransparency = 0
						}):Play()
					end)
					if lastPos then
						task.wait(0.25)
						createLine(lastPos, Vector2.new(x, yPos))
					end
					lastPos = Vector2.new(x, yPos)
				end
			end			
			local function DrawHorizontalGridLines(parentFrame: Frame, numberTable: table, lineColor: Color3, lineThickness: number)
				local minVal, maxVal = math.huge, -math.huge
				for _, v in ipairs(numberTable) do
					if v < minVal then minVal = v end
					if v > maxVal then maxVal = v end
				end
				local range = maxVal - minVal
				local lineCount = math.clamp(math.floor(range / 2), 3, 8)
				for _, obj in ipairs(parentFrame:GetChildren()) do
					if obj:IsA("Frame") and obj.Name:match("^HLine") then
						obj:Destroy()
					end
				end
				for i = 0, lineCount do
					local lineY = i / lineCount
					local valueAtLine = maxVal - (range * (i / lineCount))
					local line = Instance.new("Frame")
					line.Name = "HLine_" .. i
					line.BackgroundColor3 = lineColor or Color3.fromRGB(255, 255, 255)
					line.BorderSizePixel = 0
					line.Size = UDim2.new(1, 0, 0, lineThickness or 1)
					line.AnchorPoint = Vector2.new(0, 0.5)
					line.Position = UDim2.new(0, 0, lineY, 0)
					line.BackgroundTransparency = 1
					line.Parent = parentFrame
					local label = Instance.new("TextLabel")
					label.Name = "HLineLabel_" .. i
					label.BackgroundTransparency = 1
					label.Text = string.format("%.1f", valueAtLine)
					label.Font = Enum.Font.SourceSansBold
					label.TextSize = 16
					label.TextColor3 = Color3.fromRGB(255, 185, 7)--NowTheame.TextColor2
					label.AnchorPoint = Vector2.new(0, 0.5)
					label.Position = UDim2.new(0.97, 0, lineY, 0)
					label.TextTransparency = 1
					label.ZIndex = 2
					label.Parent = parentFrame
					table.insert(Table_HLineLabel, label)
					AddJipaTaUI(Instance.new("UIStroke"), label, NowTheame.UIStroke1, 2.7, 0.52)
					task.delay(i * 0.05, function()
						local tweenLine = TweenService:Create(line, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							BackgroundTransparency = 0})
						local tweenLabel = TweenService:Create(label, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							TextTransparency = 0})
						tweenLine:Play()
						tweenLabel:Play()
					end)
				end
			end			
			local function RemoveAllGraph()
				for _, item in ipairs(Table_Point) do
					item:Destroy()
				end
				for _, item in ipairs(Table_Line) do
					item:Destroy()
				end
				for _, item in ipairs(Table_HLineLabel) do
					item:Destroy()
				end
				Table_Point = {}
				Table_Line = {}
				Table_HLineLabel = {}
			end
			
			ButtonCheck.MouseEnter:Connect(function()
				if not ButtonCheck:GetAttribute("FirstLoadGraph") then
					ButtonCheck:SetAttribute("FirstLoadGraph", true)
					DrawHorizontalGridLines(GraphFrame, LineGraph_options.Values, Color3.fromRGB(89, 44, 177), 2)			
					drawGraph(LineGraph_options.Values)
				end
			end)
			
			function LineGraphFunction:UpdateGraph(Input_Value)
				if Input_Value and Input_Value.Values then
					RemoveAllGraph()
					LineGraph_options.Values = Input_Value.Values
					LineGraph_options.Values_date = Input_Value.Values_date or nil
					DrawHorizontalGridLines(GraphFrame, LineGraph_options.Values, Color3.fromRGB(89, 44, 177), 2)			
					drawGraph(LineGraph_options.Values)
				end	
			end
			
			return LineGraphFunction
		end
		
		
		return Functions
	end
	
	return Modes
end

return SomtankUI

