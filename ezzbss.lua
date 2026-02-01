local GuiService = game:GetService("GuiService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")


local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "ezzbss"

local ImageButton = Instance.new("ImageButton", ScreenGui)
ImageButton.Size = UDim2.new(0,60,0,60)
ImageButton.Position = UDim2.new(0.893,0,0.464,0)
ImageButton.Image = "rbxassetid://91356972133906"
ImageButton.Visible = false

local ContentProvider = game:GetService("ContentProvider")
ContentProvider:PreloadAsync({ImageButton}, function()
    ImageButton.Visible = true 
end)

local UiCorner1 = Instance.new("UICorner", ImageButton)

local frame = Instance.new("Frame", ScreenGui)
frame.Size = UDim2.new(0,241,0,78)
frame.Position = UDim2.new(0.406,0,0.453,0)
frame.BackgroundColor3 = Color3.fromRGB(39, 39, 39)
frame.Visible = false

local UICorner2 = Instance.new("UICorner", frame)

local textframe = Instance.new("Frame", frame)
textframe.Size = UDim2.new(0,200,0,27)
textframe.Position = UDim2.new(0.087,0,0.322,0)
textframe.BackgroundColor3 = Color3.fromRGB(85, 85, 85)

local UICorner3 = Instance.new("UICorner", textframe)

local TextLabel = Instance.new("TextLabel", textframe)
TextLabel.Size = UDim2.new(0,100,0,27)
TextLabel.Text = "Restart time:"
TextLabel.TextColor3 = Color3.fromRGB(0,0,0)
TextLabel.TextSize = 10
TextLabel.BackgroundTransparency = 1

local TextBox = Instance.new("TextBox", textframe)
TextBox.Size = UDim2.new(0,71,0,27)
TextBox.Position = UDim2.new(0.607,0,-0.012,0)
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.PlaceholderText = "0(hours)"
TextBox.TextTruncate = Enum.TextTruncate.AtEnd
TextBox.TextXAlignment = Enum.TextXAlignment.Right
TextBox.BackgroundTransparency = 1
TextBox.TextSize = 10
TextBox.Text = "5"

ImageButton.MouseButton1Click:Connect(function()
	if frame.Visible == false then
		frame.Visible = true
	else
		frame.Visible = false
	end
end)

local reconnectTime = 0 
local timerStart = 0 

TextBox:GetPropertyChangedSignal("Text"):Connect(function()
	local newHours = tonumber(TextBox.Text) or 0
	reconnectTime = newHours * 3600 

	local now = os.time()
	local elapsed = now - timerStart

	if elapsed >= reconnectTime and reconnectTime > 0 then
		TeleportService:Teleport(game.PlaceId)
	end
end)

task.spawn(function()
	timerStart = os.time()

	while true do
		task.wait(1) 

		local now = os.time()
		local elapsed = now - timerStart


		if elapsed >= reconnectTime and reconnectTime > 0 then
			TeleportService:Teleport(game.PlaceId)
			break
		end
	end
end)

local function onErrorMessageChanged(errorMessage)
	if errorMessage and errorMessage ~= "" then
		print("Error detected: " .. errorMessage)

		if player then
			wait()
			TeleportService:Teleport(game.PlaceId, player)
		end
	end
end

GuiService.ErrorMessageChanged:Connect(onErrorMessageChanged)

local UIS = game:GetService("UserInputService")
local function makeFrameDraggable()
	local dragging = false
	local dragStart = nil
	local startPos = nil

	local function moveFrame(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			moveFrame(input)
		end
	end)
end

local function makeImageDraggable()
	local dragging = false
	local dragStart = nil
	local startPos = nil

	local function moveImage(input)
		local delta = input.Position - dragStart
		ImageButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	ImageButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = ImageButton.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			moveImage(input)
		end
	end)
end

makeFrameDraggable()
makeImageDraggable()
