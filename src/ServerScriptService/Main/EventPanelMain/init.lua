local module = {}

local GroupService = game:GetService("GroupService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InsertService = game:GetService("InsertService")

local EventDataHandler = require(script:WaitForChild("EventDataHandler"))
local VIPListHandler = require(script:WaitForChild("EventPanelVIPList"))
local CoreManagerHandler = require(script:WaitForChild("RobloxCoreManager"))
local AttendeeHandler = require(script:WaitForChild("AttendeeHandler"))
local EventSystemsHandler = require(script:WaitForChild("EventSystemsHandler"))
local FilteringTextHandler = require(script:WaitForChild("FilteringTextHandler"))
local SlideshowHandler = require(script:WaitForChild("SlideshowHandler"))


local AllowedPlayerList = VIPListHandler.ReturnData()

local TextConstants = {
	Kick = "Moderators have kicked you due to disruption during the event. Please be respectful while attending community events.",
	EventBan = "Due to event disruption, moderators have determined that you are banned from this specific event.",
	GlobalBan = "By event organizer choice, you have been banned from all current and future events.",
	ServerLock = "This server is locked, new users are prevented from joining."
}

-- Initial check player role, add them to attended events (if any are running), and check to see if they are an event manager to which they'll receive their panel.
function CheckPlayerRole(player: Player)
	local EventData = EventDataHandler.ReturnEventData()
	
	print(EventData)
	
	local EventManager = AttendeeHandler.CheckPlayerRole(player, AllowedPlayerList)
	
	if EventManager then				
		if #EventData == 1 then
			task.wait(1)
		end
				
		ReplicatedStorage.EventPanel.Events.ClientSetupEventManager:FireClient(player, EventData)
	end
		
	if table.find(EventData["GlobalBanList"], player.UserId) ~= nil and not EventManager then
		player:Kick(TextConstants["GlobalBan"])
	end
	
	local CurrentTime = os.time()
	local CurrentEvent
		
	for EventName, Data in pairs(EventData) do
		if Data["EventStartTime"] == nil or Data["EventEndTime"] == nil then
			continue
		end
		
		if CurrentTime >= Data["EventStartTime"] and CurrentTime <= Data["EventEndTime"] then
			if table.find(Data.AttendeeList, player.UserId) == nil then
				EventDataHandler.AddAttendee(EventName, player.UserId, player.Name)
				
				CurrentEvent = EventName
			end
		end
	end
	
	local IsEventBanned
	
	for _, Data in pairs(EventData) do
		if Data["AttendeeBanlist"] == nil then
			continue
		end
		
		if table.find(Data["AttendeeBanlist"], player.UserId) ~= nil and not EventManager then
			IsEventBanned = true
		end
	end
	
	if IsEventBanned then
		player:Kick(TextConstants["EventBan"])
	end
	
	if CoreManagerHandler.ReturnCoreFunctions()["ServerLocking"] and not EventManager then
		player:Kick(TextConstants["ServerLock"])
	end
	
	if not EventManager then
		ReplicatedStorage.EventPanel.Events.ClientSetupAttendeeView:FireClient(player, CurrentEvent, EventSystemsHandler.ReturnEventSystemData())
	end
end

function module.IntitializeSystem()
	Players.PlayerAdded:Connect(CheckPlayerRole)	

	EventDataHandler.SetupData()
		
	AttendeeHandler.InitializeSystem()
	CoreManagerHandler.SetupCoreFunction()
	EventSystemsHandler.InitializeEventSystem()
	SlideshowHandler.SetupSlideshowSystem()
		
	ReplicatedStorage.EventPanel.Events.ClientCreateEvent.OnServerEvent:Connect(function(player, ClientEventData)
		local EventManager = AttendeeHandler.CheckPlayerRole(player, AllowedPlayerList)
		
		if EventManager then
			EventDataHandler.SetupNewEventData(ClientEventData)			
		end
	end)
	
	ReplicatedStorage.EventPanel.Events.ServerUpdateEventData.OnServerEvent:Connect(function(player, Action, EventName)
		local EventManager = AttendeeHandler.CheckPlayerRole(player, AllowedPlayerList)
				
		if EventManager then
			if Action == "Remove" then
				EventDataHandler.RemoveEvent(EventName)
			end
		end
	end)
	
	ReplicatedStorage.EventPanel.Events.ServerReturnImageId.OnServerInvoke = function(player, ImageId)
		local InsertedObject = InsertService:LoadAsset(ImageId)
		local ReturnedImageID = InsertedObject:FindFirstChildOfClass("Decal").Texture
		InsertedObject:Destroy()
		
		return ReturnedImageID
	end
	
	ReplicatedStorage.EventPanel.Events.ServerQAQuestion.OnServerEvent:Connect(function(player, EventName, Question)
		EventDataHandler.AddQAQuestion(EventName, player, FilteringTextHandler.FilterText(Question, player.UserId))
	end)
end

return module
