local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage.EventPanel.Events
local AttendeeHandler = require(script.Parent.AttendeeHandler)
local EventPanelVIPList = require(script.Parent.EventPanelVIPList)
local FilteringTextHandler = require(script.Parent.FilteringTextHandler)
local EventOrganizer

local EventSystemData = {
	PinnedMessage = "No Pinned Message",
	QAEnabled = false
}

function module.InitializeEventSystem()
	-- Anything that is not a string will be edited after being fired. QAEnabled will be edited here.
	Events.ServerUpdateEventSystemData.OnServerEvent:Connect(function(player, Index, NewValue)
		local EventManager = AttendeeHandler.CheckPlayerRole(player, EventPanelVIPList.ReturnData())
		
		if not EventManager then
			return
		end
		
		EventSystemData[Index] = NewValue
		
		Events.ClientUpdateEventSystemData:FireAllClients(EventSystemData)
	end)
	
	-- Pinned messages will be filtered first then will be updated among all clients
	Events.ServerUpdatePinnedMessage.OnServerEvent:Connect(function(player, PinnedMessage)
		local EventManager = AttendeeHandler.CheckPlayerRole(player, EventPanelVIPList.ReturnData())

		if not EventManager then
			return
		end
		
		EventSystemData["PinnedMessage"] = FilteringTextHandler.FilterText(PinnedMessage, player.UserId)

		Events.ClientUpdateEventSystemData:FireAllClients(EventSystemData)
	end)
end

function module.ReturnEventSystemData()
	return EventSystemData
end

return module
