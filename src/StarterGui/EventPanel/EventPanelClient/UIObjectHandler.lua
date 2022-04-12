local module = {}

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventsFolder = ReplicatedStorage:WaitForChild("EventPanel"):WaitForChild("Events")

local camera = game.Workspace.Camera

local RatioX, RatioY = camera.ViewportSize.X / 1239, camera.ViewportSize.Y / 730

local ButtonGrowthFactor = 1.1

local MouseHoverTweenInfo = TweenInfo.new(.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In)

-- Sets up infinite scrolling based on the number of elements in the scrolling frame
function module.SetupInfiniteScrolling(ScrollingFrame: ScrollingFrame)
	if ScrollingFrame:FindFirstChildOfClass("UIListLayout") or ScrollingFrame:FindFirstChildOfClass("UIGridLayout") then
		local UIGridLayout = ScrollingFrame:FindFirstChildOfClass("UIGridLayout")
		
		if UIGridLayout then
			local MaxOffsetSizeX, MaxOffsetSizeY = UIGridLayout.CellSize.X.Offset, UIGridLayout.CellSize.Y.Offset
			local MaxPaddingX, MaxPaddingY = UIGridLayout.CellPadding.X.Offset, UIGridLayout.CellPadding.Y.Offset
			
			UIGridLayout.CellPadding = UDim2.fromOffset(MaxPaddingX * RatioX, MaxPaddingY * RatioY)
			UIGridLayout.CellSize = UDim2.fromOffset(MaxOffsetSizeX * RatioX, MaxOffsetSizeY * RatioY)
		end		
		
		UIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIGridLayout.AbsoluteContentSize.Y)
		end)
	end
end

-- Sets up mouse hovering with UI buttons
function module.SetupHovering(Button)
	local CurrentSizeX, CurrentSizeY = Button.Size.X.Scale, Button.Size.Y.Scale

	local TweenSize = TweenService:Create(Button, MouseHoverTweenInfo, {
		Size = UDim2.fromScale(CurrentSizeX * ButtonGrowthFactor, CurrentSizeY * ButtonGrowthFactor),
	})
	local ReturnSizeTween = TweenService:Create(Button, MouseHoverTweenInfo, {Size = UDim2.fromScale(CurrentSizeX, CurrentSizeY)})

	Button.MouseEnter:Connect(function()
		TweenSize:Play()
	end)

	Button.MouseLeave:Connect(function()
		ReturnSizeTween:Play()
	end)
end

local Buttons = {}

function module.EnableHovering(Button)
	local CurrentSizeX, CurrentSizeY = Button.Size.X.Scale, Button.Size.Y.Scale

	if Buttons[Button.Name.."Enable"] == nil then
		Buttons[Button.Name.."Enable"] = TweenService:Create(Button, MouseHoverTweenInfo, {
			Size = UDim2.fromScale(CurrentSizeX * ButtonGrowthFactor, CurrentSizeY * ButtonGrowthFactor),
		})

		Buttons[Button.Name.."Disable"] = TweenService:Create(Button, MouseHoverTweenInfo, {
			Size = UDim2.fromScale(CurrentSizeX, CurrentSizeY),
		})
	end

	local TweenSize = Buttons[Button.Name.."Enable"]

	TweenSize:Play()
end

function module.DisableHovering(Button)
	if Buttons[Button.Name.."Enable"] ~= nil then
		local ReturnSizeTween = Buttons[Button.Name.."Disable"]

		ReturnSizeTween:Play()
	end	
end

local function GetColorDelta(Color : Color3, Delta : number)
	local H,S,V = Color:ToHSV()
	return Color3.fromHSV(H,S,V+(Delta/255))
end

function module.BrighterColorHover(Button)
	local ButtonColor = Button.BackgroundColor3
	local NewColor = GetColorDelta(ButtonColor, -50)

	Button.MouseEnter:Connect(function()
		Button.BackgroundColor3 = NewColor
	end)

	Button.MouseLeave:Connect(function()
		Button.BackgroundColor3 = ButtonColor
	end)
end

-- Sets up search system regarding the speific scrolling frame
function module.SetupSearchSystem(SearchTextBox: TextBox)
	local ScrollingFrame = SearchTextBox.Parent:FindFirstChildOfClass("ScrollingFrame") or SearchTextBox.Parent
	
	if ScrollingFrame ~= nil then
		SearchTextBox:GetPropertyChangedSignal("Text"):Connect(function()
			for i, UIFrame in pairs(ScrollingFrame:GetChildren()) do
				if UIFrame:IsA("Frame") then
					if string.find(UIFrame.Name, SearchTextBox.Text) or string.find(UIFrame:FindFirstChildOfClass("TextLabel").Text, SearchTextBox.Text) then
						UIFrame.Visible = true
					else
						UIFrame.Visible = false
					end
				end
			end
		end)		
	end
end

-- Updates current edited slide or entered ID
function module.SetupSlideTextboxIDUpdater(TextBox: TextBox)
	TextBox.FocusLost:Connect(function()
		if tonumber(TextBox.Text) then
			TextBox.Parent:FindFirstChildOfClass("ImageLabel").Image = EventsFolder.ServerReturnImageId:InvokeServer(TextBox.Text)
		end
	end)
end


return module
