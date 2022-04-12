local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventsFolder = ReplicatedStorage:WaitForChild("EventPanel"):WaitForChild("Events")
local EventPanelFolder = ReplicatedStorage:WaitForChild("EventPanel")

local OpenedCurrentEventData = require(script.Parent.OpenedCurrentEventData)

-- All the button connections that are initially set up based on the button's name
local ConnectionsList = {
	["EventManageBtn"] = function(EventPanel)
		EventPanel.Visible = not EventPanel.Visible
	end,
	["InitiateCreateEventBtn"] = function(EventPanel: Frame)
		EventPanel.EventListFrame.Visible = false
		EventPanel.CreateEventFrame.Visible = true
		EventPanel.BackBtn.Visible = false
	end,
	["CreateEventBtn"] = function(EventPanel: Frame)
		local CreateEventFrame = EventPanel.CreateEventFrame
		local TextBoxFolder = CreateEventFrame.TextBoxes
				
		local Blanks = false
		
		for i, v in pairs(TextBoxFolder:GetChildren()) do
			if v.Text == "" or v.Text == nil then
				Blanks = true
			end
		end
		
		if not Blanks then
			local StartTimeTable = {
				year = tonumber(TextBoxFolder.YearStartTextBox.Text),
				month = tonumber(TextBoxFolder.MonthStartTextBox.Text),
				day = tonumber(TextBoxFolder.DayStartTextBox.Text),
				hour = tonumber(TextBoxFolder.HourStartTextBox.Text),
				min = tonumber(TextBoxFolder.MinuteStartTextBox.Text)
			}
			
			local EndTimeTable = {
				year = tonumber(TextBoxFolder.YearEndTextBox.Text),
				month = tonumber(TextBoxFolder.MonthEndTextBox.Text),
				day = tonumber(TextBoxFolder.DayEndTextBox.Text),
				hour = tonumber(TextBoxFolder.HourEndTextBox.Text),
				min = tonumber(TextBoxFolder.MinuteEndTextBox.Text)
			}			
			
			
			local EventStartTime = os.time(StartTimeTable)
			local EventEndTime = os.time(EndTimeTable)
			
			local AttendeeJoinEarlyTime
			
			if tonumber(TextBoxFolder.MinuteJoinTimeTextBox.Text) > tonumber(TextBoxFolder.MinuteStartTextBox.Text) then
				local LeftoverMinutes = tonumber(TextBoxFolder.MinuteJoinTimeTextBox.Text) - tonumber(TextBoxFolder.MinuteStartTextBox.Text)
				
				local AttendeeJoinTimeTable = {
					year = tonumber(TextBoxFolder.YearStartTextBox.Text),
					month = tonumber(TextBoxFolder.MonthStartTextBox.Text),
					day = tonumber(TextBoxFolder.DayStartTextBox.Text),
					hour = tonumber(TextBoxFolder.HourEndTextBox.Text) - 1,
					min = 60 + LeftoverMinutes
				}	
				
				AttendeeJoinEarlyTime = os.time(AttendeeJoinTimeTable)
			else
				local AttendeeJoinTimeTable = {
					year = tonumber(TextBoxFolder.YearStartTextBox.Text),
					month = tonumber(TextBoxFolder.MonthStartTextBox.Text),
					day = tonumber(TextBoxFolder.DayStartTextBox.Text),
					hour = tonumber(TextBoxFolder.HourEndTextBox.Text) - 1,
					min = (tonumber(TextBoxFolder.MinuteStartTextBox.Text) - tonumber(TextBoxFolder.MinuteJoinTimeTextBox.Text * 60))
				}	
				
				AttendeeJoinEarlyTime = os.time(AttendeeJoinTimeTable)
			end
			
			local CreatedEventData = {
				EventName = TextBoxFolder.EventNameTextBox.Text,
				EventStartTime = EventStartTime,
				EventEndTime = EventEndTime,
				AttendeeJoinTime = AttendeeJoinEarlyTime,
				EventIcon = tonumber(TextBoxFolder.EventIconTextBox.Text)
			}		
						
			EventPanelFolder.Events.ClientCreateEvent:FireServer(CreatedEventData)

			EventPanel.EventListFrame.Visible = true
			EventPanel.CreateEventFrame.Visible = false	
			EventPanel.BackBtn.Visible = true
			
			for i, v in pairs(TextBoxFolder:GetChildren()) do
				v.Text = ""
			end
			
			TextBoxFolder.MinuteJoinTimeTextBox.Text = "15"
			TextBoxFolder.EventIconTextBox.Text = "none"
		end
	end,
	["CancelEventCreationBtn"] = function(EventPanel: Frame)
		EventPanel.EventListFrame.Visible = true
		EventPanel.CreateEventFrame.Visible = false
		
		EventPanel.BackBtn.Visible = true
	end,
	["AttendeeListBtn"] = function(EventPanel: Frame)
		EventPanel.EventFrame.AttendeeList.Visible = true 
	end,
	["BackBtn"] = function(EventPanel: Frame)
		local SomethingVisible = false
		local Location

		for _, v in pairs(EventPanel.EventFrame:GetChildren()) do
			if v:IsA("Frame") then
				if v.Visible  then
					SomethingVisible = true
					Location = EventPanel.EventFrame
				end
			end
		end
		
		for _, v in pairs(EventPanel.EventListFrame:GetChildren()) do
			if v:IsA("Frame") then
				if v.Visible  then
					SomethingVisible = true
					Location = EventPanel.EventListFrame
				end
			end
		end
		
		if SomethingVisible then
			for _, v in pairs(Location:GetChildren()) do
				if v:IsA("Frame") then
					v.Visible = false
				end
			end
		else
			EventPanel.EventFrame.Visible = false
			EventPanel.EventListFrame.Visible = true
		end
	end,
	["GlobalBanListBtn"] = function(EventPanel: Frame)
		for _, v in pairs(EventPanel.EventListFrame:GetChildren()) do
			if v:IsA("Frame") then
				v.Visible = false
			end
		end
		
		EventPanel.EventListFrame.GlobalBanList.Visible = true
	end,
	["ChatPreventBtn"] = function(Button: TextButton)
		local Value
		
		if Button.Text == "Disabled" then
			Value = true
			Button.Text = "Enabled"
			Button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)			
		else
			Value = false
			Button.Text = "Disabled"
			Button.BackgroundColor3= Color3.fromRGB(255, 0, 0)
		end
		
		EventsFolder.ServerUpdateCoreFunction:FireServer("ChatPrevent", Value)
	end,
	["ResetPreventBtn"] = function(Button: TextButton)
		local Value

		if Button.Text == "Disabled" then
			Value = true
			Button.Text = "Enabled"
			Button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)			
		else
			Value = false
			Button.Text = "Disabled"
			Button.BackgroundColor3= Color3.fromRGB(255, 0, 0)
		end

		EventsFolder.ServerUpdateCoreFunction:FireServer("ResetPrevent", Value)
	end,
	["ServerLockBtn"] = function(Button: TextButton)
		local Value

		if Button.Text == "Disabled" then
			Value = true
			Button.Text = "Enabled"
			Button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)			
		else
			Value = false
			Button.Text = "Disabled"
			Button.BackgroundColor3= Color3.fromRGB(255, 0, 0)
		end

		EventsFolder.ServerUpdateCoreFunction:FireServer("ServerLock", Value)
	end,
	["RobloxCoreFunctionBtn"] = function(EventListFrame: Frame)
		EventListFrame.RobloxCoreManagerFrame.Visible = not EventListFrame.RobloxCoreManagerFrame.Visible
	end,
	["AttendeeQABtn"] = function(Button: TextButton)
		local Value

		if Button.Text == "Enable QA" then
			Value = true
			Button.Text = "Disable QA"
			Button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)			
		else
			Value = false
			Button.Text = "Enable QA"
			Button.BackgroundColor3= Color3.fromRGB(255, 0, 0)
		end

		EventsFolder.ServerUpdateEventSystemData:FireServer("QAEnabled", Value)
	end,
	["ViewQABtn"] = function(EventFrame: Frame)
		EventFrame.QAList.Visible = true
	end,
	["SlideshowBtn"] = function(EventFrame: Frame)
		EventFrame.SlideshowList.Visible = true
	end,
	["AddSlideBtn"] = function(NewSlideEditorFrame: Frame)
		for i, v in pairs(NewSlideEditorFrame:GetChildren()) do
			if v:IsA("TextBox") then
				v.Text = ""			
			end
		end
		
		NewSlideEditorFrame.Parent.SlideshowEditorFrame.Visible = false
		
		NewSlideEditorFrame.NewSlidePosTextBox.Text = (#NewSlideEditorFrame.Parent.SlideshowScrollingFrame:GetChildren() - 1)
		
		NewSlideEditorFrame.Visible = true
	end,
	["CreateSlideBtn"] = function(NewSlideEditorFrame: Frame)
		local Blanks = false

		for i, v in pairs(NewSlideEditorFrame:GetChildren()) do
			if v:IsA("TextBox") then
				if v.Text == "" or v.Text == nil then
					Blanks = true
				end				
			end
		end
		
		if not Blanks then
			local SlideshowData = {}
			
			if tonumber(NewSlideEditorFrame.NewSlidePosTextBox.Text) and tonumber(NewSlideEditorFrame.NewSlideImageTextBox.Text) then
				SlideshowData["SlideshowImageID"] = NewSlideEditorFrame.NewSlideImageTextBox.Text
				SlideshowData["SlidePosition"] = NewSlideEditorFrame.NewSlidePosTextBox.Text	
				
				EventsFolder.ServerSlideshowAction:FireServer("New", OpenedCurrentEventData.ReturnEventName(), SlideshowData)
				NewSlideEditorFrame.Visible = false
			end						
		end
	end,
	["PresenterModeBtn"] = function(PresenterModeFrame: Frame)
		PresenterModeFrame.Visible = true
		PresenterModeFrame.Parent.EventPanel.Visible = false
		
		EventsFolder.ServerSwitchSlide:FireServer(OpenedCurrentEventData.ReturnEventName(), "Start")
	end,
	["PreviousSlideBtn"] = function()
		EventsFolder.ServerSwitchSlide:FireServer(OpenedCurrentEventData.ReturnEventName(), "Previous")
	end,
	["NextSlideBtn"] = function()
		EventsFolder.ServerSwitchSlide:FireServer(OpenedCurrentEventData.ReturnEventName(), "Next")
	end,
	["ExitPesenterBtn"] = function(PresenterModeFrame: Frame)
		PresenterModeFrame.Visible = false
	end,	
	["PinnedMessagesBtn"] = function(PinnedMessage: Frame)
		PinnedMessage.Visible =  true
	end,
	["AddPinnedMessageBtn"] = function(PinnedMessage: Frame)
		if PinnedMessage.PinnedMessageDraft.Text ~= "" or PinnedMessage.PinnedMessageDraft.Text ~= nil then
			EventsFolder.ServerUpdatePinnedMessage:FireServer(PinnedMessage.PinnedMessageDraft.Text)
			
			PinnedMessage.PinnedMessageDraft.Text = ""
		end
	end,
	["DeleteEventBtn"] = function(EventPanel: Frame)
		EventsFolder.ServerUpdateEventData:FireServer("Remove", OpenedCurrentEventData.ReturnEventName())
		
		OpenedCurrentEventData.UpdateEvent("None")
		
		EventPanel.EventFrame.Visible = false
		EventPanel.EventListFrame.Visible = true
	end,
}

-- Setup the button connection by calling the function in ConnectionsList
function module.SetupBtnConnection(Button: TextButton, Frame)
	if ConnectionsList[Button.Name] then
		Button.MouseButton1Click:Connect(function()
			ConnectionsList[Button.Name](Frame)
		end)		
	end
end

return module
