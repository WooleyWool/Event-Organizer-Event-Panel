local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage.EventPanel.Events

local EventSystemsData

function SetData(EventPanel, EventSystemsData)
	if EventSystemsData["QAEnabled"] == false then
		EventPanel.QABtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		EventPanel.QABtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		EventPanel.QABtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		EventPanel.QABtn.TextColor3 = Color3.fromRGB(85, 170, 255)
	end

	EventPanel.PinnedMessage.PinnedTextLabel.Text = EventSystemsData["PinnedMessage"]
end

function module.SetupReceivedData(ReceivedData, EventPanel: Frame)
	EventSystemsData = ReceivedData
	
	SetData(EventPanel, EventSystemsData)
	
	Events.ClientUpdateEventSystemData.OnClientEvent:Connect(function(NewData)
		EventSystemsData = NewData
		
		SetData(EventPanel, EventSystemsData)
	end)
end

function module.ReturnEventSystemData()
	return EventSystemsData
end

return module
