local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GroupService = game:GetService("GroupService")
local Players = game:GetService("Players")
local EventsFolder = ReplicatedStorage.EventPanel.Events

local EventDataHandler = require(script.Parent.EventDataHandler)
local EventVIPList = require(script.Parent.EventPanelVIPList)
local EventOrganizersListCopy
local AllowedPlayerListCopy

local TextConstants = {
	Kick = "Moderators have kicked you due to disruption during the event. Please be respectful while attending community events.",
	EventBan = "Due to event disruption, moderators have determined that you are banned from this specific event.",
	GlobalBan = "By event organizer choice, you have been banned from all current and future events."
}

function module.CheckPlayerRole(player: Player, AllowedPlayerList)
	local userID = player.UserId
	local PlayerGroups = GroupService:GetGroupsAsync(userID)
	local EventData = EventDataHandler.ReturnEventData()
	local EventManager = false
	
	if AllowedPlayerList ~= nil then
		AllowedPlayerListCopy = AllowedPlayerList
	end
	
	if AllowedPlayerList == nil then
		if table.find(AllowedPlayerListCopy, userID) ~= nil then
			EventManager = true
		end 
	elseif AllowedPlayerList ~= nil then
		if table.find(AllowedPlayerList["PlayerIDs"], userID) ~= nil then
			EventManager = true
		end 
	else
		if table.find(AllowedPlayerList["PlayerIDs"], userID) ~= nil then
			EventManager = true
		end 		
	end

	for i, v in pairs(PlayerGroups) do
		if v["Id"] == AllowedPlayerList["Group"]['GroupID'] then			
			if v["Rank"] >= AllowedPlayerList["Group"]["AllowedRankID"] then
				EventManager = true
			end
		end
	end
		
	return EventManager
end

function module.InitializeSystem()
	EventsFolder.ServerAttendeeAction.OnServerEvent:Connect(function(player: Player, Action: string, CriminalPlayerId: number, EventName: string)
		local CriminalPlayer = Players:GetPlayerByUserId(CriminalPlayerId)
		
		local EventManager = module.CheckPlayerRole(player, EventVIPList.ReturnData())
		
		if EventManager then
			if Action == "Kick" then
				if CriminalPlayer then
					CriminalPlayer:Kick(TextConstants["Kick"])
				end
			elseif Action == "EventBan" then
				EventDataHandler.EventBanListUpdate(EventName, "Ban", CriminalPlayer.UserId)

				if CriminalPlayer then
					CriminalPlayer:Kick(TextConstants["EventBan"])
				end
			elseif Action == "GlobalBan" then
				EventDataHandler.GlobalBanListUpdate("Ban", CriminalPlayer.UserId)

				if CriminalPlayer then
					CriminalPlayer:Kick(TextConstants["GlobalBan"])
				end
			elseif Action == "EventUnban" then
				EventDataHandler.EventBanListUpdate(EventName, "Unban", CriminalPlayer.UserId)
			elseif Action == "GlobalUnban" then
				EventDataHandler.GlobalBanListUpdate("Unban", CriminalPlayer.UserId)
			end	
		end
	end)
end

return module
