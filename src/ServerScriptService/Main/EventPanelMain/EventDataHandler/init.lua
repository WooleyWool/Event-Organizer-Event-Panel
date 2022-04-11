local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventPanelFolder = ReplicatedStorage.EventPanel

local Players = game:GetService("Players")

local ProfileService = require(script.ProfileService)

local EventOrganizerID = 34355831

local ProfileTemplate = {
	GlobalBanList = {}
}

local ProfileStore = ProfileService.GetProfileStore(
	"PlayerData",
	ProfileTemplate
)

local Profiles = {}

local DataLoaded = false

function module.SetupNewEventData(EventDataTable)
	--[[
	EventData consists of the following:
		EventName = string
		EventStartTime = Using DateTime.FromUniversalTime
		EventEndTime = Using DateTime.FromUniversalTime
		AttendeeJoinEarlyTime = nil or number (in seconds)
		EventIcon = ID - int
	]]
	
	local EventData = Profiles[EventOrganizerID].Data
		
	local ExistantEvents = 0
	
	for i, v in pairs(EventData) do
		ExistantEvents += 1
	end
		
	local NewEventTable = EventData["Event"..tostring(ExistantEvents)] or {};
	EventData["Event"..tostring(ExistantEvents)] = NewEventTable;
	
	NewEventTable.EventName = EventDataTable.EventName
	NewEventTable.EventStartTime = EventDataTable.EventStartTime
	NewEventTable.EventEndTime = EventDataTable.EventEndTime
	NewEventTable.AttendeeJoinTime = EventDataTable.AttendeeJoinEarly
	NewEventTable.EventIcon = "rbxassetid://"..tostring(EventDataTable.EventIcon)
	
	NewEventTable.AttendeeList = {}
	NewEventTable.AttendeeBanlist = {}
	NewEventTable.QAList = {} -- Index: PlayerName /t/t PlayerID - Question Number, Value is the question
	NewEventTable.SlideshowSlides = {}
	
	EventPanelFolder.Events.ClientUpdateEvents:FireAllClients(EventData)
end

function module.SetupData()
	local profile = ProfileStore:LoadProfileAsync("Player_" .. EventOrganizerID)
		
	if profile ~= nil then
		profile:AddUserId(EventOrganizerID) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
		
		Profiles[EventOrganizerID] = profile
	end
	
	for i, v in pairs(Profiles[EventOrganizerID].Data) do
		if tostring(i) ~= "GlobalBanList" then
			if v["SlideshowSlides"] == nil then
				v["SlideshowSlides"] = {}
			end
		end
	end
	
	DataLoaded = true
		
	ReplicatedStorage.EventPanel.Events.ClientUpdateEvents:FireAllClients(Profiles[EventOrganizerID].Data)
end

function module.RemoveEvent(EventID: string)
	local EventData = Profiles[EventOrganizerID].Data

	EventData[EventID] = nil
	
	local Position = tonumber(string.sub(EventID, 6))
	
	for i, v in pairs(EventData) do
		if tostring(i) ~= "GlobalBanList" then
			if tonumber(string.sub(i, 6)) > Position then
				local OldPosition = tonumber(string.sub(i, 6))
				local NewPos = OldPosition - 1
				
				EventData["Event"..tostring(NewPos)] = v
				EventData[i] = nil
			end
		end
	end
	
	print(EventData)
	
	EventPanelFolder.Events.ClientUpdateEvents:FireAllClients(EventData)
end

function module.GlobalBanListUpdate(BanFunction, PlayerId)
	local EventData = Profiles[EventOrganizerID].Data

	local GlobalBanList = EventData.GlobalBanList
	
	if BanFunction == "Ban" then
		table.insert(GlobalBanList, PlayerId)	
	elseif BanFunction == "Unban" then
		table.remove(GlobalBanList, table.find(GlobalBanList, PlayerId))
	end
	
	EventPanelFolder.Events.ClientUpdateEvents:FireAllClients(EventData)
end

function module.EventBanListUpdate(EventName, BanFunction, PlayerId)
	local EventData = Profiles[EventOrganizerID].Data

	local AttendeeBanList = EventData[EventName]["AttendeeBanlist"]

	if BanFunction == "Ban" then
		table.insert(AttendeeBanList, PlayerId)	
	elseif BanFunction == "Unban" then
		table.remove(AttendeeBanList, table.find(AttendeeBanList, PlayerId))
	end
	
	EventPanelFolder.Events.ClientUpdateEvents:FireAllClients(EventData)
end

function module.AddAttendee(EventName, AttendeeId: number, AttendeeName: string)
	local EventData = Profiles[EventOrganizerID].Data

	EventData[EventName]["AttendeeList"][AttendeeName] = AttendeeId
	
	EventPanelFolder.Events.ClientUpdateEvents:FireAllClients(EventData)
end

function module.AddQAQuestion(EventName, Attendee: Player, FilteredQuestion: string)	
	local EventData = Profiles[EventOrganizerID].Data
	local EventQADirectory = EventData[EventName].QAList
	
	local NumberQA = 0
	
	for i, v in pairs(EventQADirectory) do
		NumberQA += 1
	end
	
	EventQADirectory[Attendee.Name.."\t\t"..Attendee.UserId.." Q"..tostring(NumberQA)] = FilteredQuestion
	
	EventPanelFolder.Events.ClientUpdateEvents:FireAllClients(EventData)
end

function module.AddSlideshow(EventName, SlideshowData)
	local EventData = Profiles[EventOrganizerID].Data
	local EventDirectory = EventData[EventName]
	local SlideshowDirectory
	
	if EventDirectory.SlideshowSlides == nil then
		EventDirectory["SlideshowSlides"] = {}
		SlideshowDirectory = EventDirectory["SlideshowSlides"]
	else
		SlideshowDirectory = EventDirectory["SlideshowSlides"]
	end
	
	if SlideshowDirectory["Slide"..SlideshowData.SlidePosition] == nil then
		SlideshowDirectory["Slide"..SlideshowData.SlidePosition] = SlideshowData.SlideshowImageID
	else
		local OldSlideImage = SlideshowDirectory["Slide"..SlideshowData.SlidePosition]
		
		SlideshowDirectory["Slide"..SlideshowData.SlidePosition] = SlideshowData.SlideshowImageID
		
		SlideshowDirectory["Slide"..tostring(#SlideshowDirectory+1)] = OldSlideImage
	end
	
	EventPanelFolder.Events.ClientUpdateEvents:FireAllClients(EventData)
end

function module.DeleteSlide(EventName, SlideName)
	local EventData = Profiles[EventOrganizerID].Data
	local EventDirectory = EventData[EventName]
	local SlideshowDirectory

	if EventDirectory.SlideshowSlides == nil then
		EventDirectory["SlideshowSlides"] = {}
		return
	else
		SlideshowDirectory = EventDirectory["SlideshowSlides"]
	end
		
	SlideshowDirectory[SlideName] = nil
		
	EventPanelFolder.Events.ClientUpdateEvents:FireAllClients(EventData)
end

function module.EditSlide(EventName, SlideshowData)
	local EventData = Profiles[EventOrganizerID].Data
	local EventDirectory = EventData[EventName]
	local SlideshowDirectory
	
	if EventDirectory.SlideshowSlides == nil then
		EventDirectory["SlideshowSlides"] = {}
		SlideshowDirectory = EventDirectory["SlideshowSlides"]
	else
		SlideshowDirectory = EventDirectory["SlideshowSlides"]
	end
	
	SlideshowDirectory["SlideshowNumber"] = nil
	
	
	SlideshowDirectory["Slide"..SlideshowData.SlidePosition] = SlideshowData.SlideshowImageID

	EventPanelFolder.Events.ClientUpdateEvents:FireAllClients(EventData)
	print(SlideshowDirectory)
end

function module.ReturnEventData()
	repeat
		task.wait(.01)
	until DataLoaded
	
	local EventData = Profiles[EventOrganizerID].Data

	return EventData
end

function module.ReturnSpecificEvent(EventName)
	return Profiles[EventOrganizerID].Data[EventName]
end

return module
