local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventPanel = ReplicatedStorage:WaitForChild("EventPanel")
local EventsFolder = EventPanel:WaitForChild("Events")

local EventManagerUI = require(script.EventManagerUI)
local AttendeeUI = require(script.AttendeeUI)

-- Sets up the Event Manager UI
ReplicatedStorage.EventPanel.Events.ClientSetupEventManager.OnClientEvent:Connect(function(EventData)
	local ScreenUI = script.Parent.Parent.EventManager
	ScreenUI.Enabled = true
	
	print(EventData)
	
	EventManagerUI.InitializeManagerUI(ScreenUI, EventData)
end)

-- Sets up the Attendee UI
EventsFolder.ClientSetupAttendeeView.OnClientEvent:Connect(function(EventName, EventSystemsData)
	local ScreenUI = script.Parent.Parent.AttendeeManager
	ScreenUI.Enabled = true
	
	AttendeeUI.Initialize(ScreenUI, EventName, EventSystemsData)
end)