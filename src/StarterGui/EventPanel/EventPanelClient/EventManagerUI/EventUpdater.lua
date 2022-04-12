local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local EventPanelFolder = ReplicatedStorage.EventPanel

local ConnectionsHandler = require(script.Parent.ConnectionsHandler)
local OpenedCurrentEventData = require(script.Parent.OpenedCurrentEventData)
local AttendeeListHandler = require(script.Parent.AttendeeListHandler)
local QAListHandler = require(script.Parent.QAListHandler)
local SlideshowHandler = require(script.Parent.SlideshowListHandler)

local UIAssets = script.Parent.UIAssets

local ClientEventData

local EventPanel

local ButtonConnections = {}

-- When pressing the event icon, it will setup the UI based on the data associated with it. If it's already open, will update data too.
function SetupEventUIView(EventName)
	local EventFrame = EventPanel.EventFrame
	local RespectiveEventData = ClientEventData[EventName]

	EventFrame.EventNameHeader.Text = RespectiveEventData.EventName
	
	for _, Frame in pairs(EventFrame.AttendeeList.AttendeeScrollingFrame:GetChildren()) do
		if Frame:IsA("Frame") then
			Frame:Destroy()
		end
	end
	
	for _, Frame in pairs(EventFrame.QAList.QAScrollingFrame:GetChildren()) do
		if Frame:IsA("Frame") then
			Frame:Destroy()
		end
	end
	
	for _, Frame in pairs(EventFrame.SlideshowList.SlideshowScrollingFrame:GetChildren()) do
		if Frame:IsA("ImageButton") then
			Frame:Destroy()
		end
	end
	
	for AttendeeName: string, AttendeeId: number in pairs(RespectiveEventData.AttendeeList) do
		local GlobalBan = false
		local EventBan = false
		
		if table.find(ClientEventData.GlobalBanList, AttendeeId) then
			GlobalBan = true
		end
		
		if table.find(RespectiveEventData.AttendeeBanlist, AttendeeId) then
			EventBan = true
		end		
		
		AttendeeListHandler.SetupAttendeeList(EventFrame.AttendeeList.AttendeeScrollingFrame, AttendeeName, AttendeeId, EventBan, GlobalBan)
	end
	
	for AttendeeName: string, Question: string in pairs(RespectiveEventData.QAList) do
		local success, errorMsg = pcall(function()
			QAListHandler.SetupQA(EventFrame.QAList.QAScrollingFrame, AttendeeName, Question)
		end)
		
		if not success then
			warn(errorMsg)
		end
	end
	
	for SlideNumber: string, SlideImageID: string in pairs(RespectiveEventData.SlideshowSlides) do
		local success, errorMsg = pcall(function()
			SlideshowHandler.SetupSlide(SlideNumber, SlideImageID)
		end)
		
		if not success then
			warn(errorMsg)
		end
	end
	
	EventFrame.Visible = true
	EventPanel.EventListFrame.Visible = false
end

function SetupNewEvent(EventName, EventData)
	local EventFrameClone = UIAssets.EventTemplate:Clone()
	EventFrameClone.Name = tostring(EventName)
	EventFrameClone.EventName.Text = EventData.EventName
	EventFrameClone.Parent = EventPanel.EventListFrame.EventScrollingFrame
	
	ButtonConnections[EventName] = EventFrameClone.EnterBtn.MouseButton1Click:Connect(function()
		OpenedCurrentEventData.UpdateEvent(EventName)
		SetupEventUIView(EventName)
	end)
end

function UpdateEvents(NewEventsData, EventPanel)
	local EventFrame = EventPanel.EventFrame

	for Event, EventData in pairs(NewEventsData) do
		if ClientEventData[tostring(Event)] == nil then
			SetupNewEvent(tostring(Event), EventData)
		end
	end
	
	for Event, EventData in pairs(ClientEventData) do
		if NewEventsData[tostring(Event)] == nil then			
			EventPanel.EventListFrame.EventScrollingFrame[tostring(Event)]:Destroy()
			
			EventFrame.Visible = false
		end
	end
	
	ClientEventData = NewEventsData
end

-- Initial setup of connections with remote events
function module.SetupClientEvents(EventData, SentEventPanel)
	ClientEventData = EventData
	
	EventPanel = SentEventPanel
	
	local EditEventDataFrame = EventPanel.EventFrame.UpdateEventFrame
	local EditEventTextBoxes = EditEventDataFrame.TextBoxes
	
	for Event, Data in pairs(ClientEventData) do
		if Data.EventName ~= nil then
			SetupNewEvent(tostring(Event), Data)
		end
	end
	
	EventPanelFolder.Events.ClientUpdateEvents.OnClientEvent:Connect(function(NewEventsData)
		UpdateEvents(NewEventsData, EventPanel)
		
		if OpenedCurrentEventData.ReturnEventName() ~= "None" then
			SetupEventUIView(OpenedCurrentEventData.ReturnEventName())
		end
	end)
	
	EventPanelFolder.Events.ClientUpdateEventSystemData.OnClientEvent:Connect(function(EventSystemData)
		EventPanel.EventFrame.PinnedMessage.CurrentPinnedMessage.Text = EventSystemData.PinnedMessage
	end)
	
	
	--TODO: Need to figure out a way to better assign values for inputted times
	--[[
	EventPanel.EventFrame.Buttons.EditEventBtn.MouseButton1Click:Connect(function()
		local RespectiveData = ClientEventData[OpenedCurrentEventData.ReturnEventName()]
		local StartTime = RespectiveData["EventStartTime"]
		local EndTime = RespectiveData["EventEndTime"]
		
		EditEventTextBoxes.MinuteJoinTimeTextBox.Text = tostring(RespectiveData.AttendeeJoinTime)
		
		EditEventTextBoxes.DayStartTextBox.Text = tostring(os.date("%d", StartTime))
		EditEventTextBoxes.HourStartTextBox.Text = tostring(os.date("%H", StartTime))
		EditEventTextBoxes.MinuteStartTextBox.Text = tostring(os.date("%m", StartTime))
		EditEventTextBoxes.MonthStartTextBox.Text = tostring(os.date("%M", StartTime))
		EditEventTextBoxes.YearStartTextBox.Text = tostring(os.date("%Y", StartTime))
		
		EditEventTextBoxes.DayEndTextBox.Text = tostring(os.date("%d", EndTime))
		EditEventTextBoxes.HourEndTextBox.Text = tostring(os.date("%H", EndTime))
		EditEventTextBoxes.MinuteEndTextBox.Text = tostring(os.date("%m", EndTime))
		EditEventTextBoxes.MonthEndTextBox.Text = tostring(os.date("%M", EndTime))
		EditEventTextBoxes.YearEndTextBox.Text = tostring(os.date("%Y", EndTime))
		
		EditEventTextBoxes.EventIconTextBox.Text = RespectiveData.EventIcon
		EditEventTextBoxes.EventNameTextBox.Text = RespectiveData.EventName
		
		EditEventDataFrame.Visible = true
	end)
	]]
end


return module
