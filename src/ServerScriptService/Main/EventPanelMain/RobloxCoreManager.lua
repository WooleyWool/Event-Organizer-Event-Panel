local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventPanel = ReplicatedStorage.EventPanel
local EventsFolder = EventPanel.Events

local VIPListHandler = require(script.Parent:WaitForChild("EventPanelVIPList"))
local AttendeeHandler = require(script.Parent:WaitForChild("AttendeeHandler"))

local AllowedPlayerList = VIPListHandler.ReturnData()

local CoreFunctions = {
	ServerLocking = false,
	ResetPrevent = true,
	ChatPrevent = true
}

function module.SetupCoreFunction()
	--[[
		ServerLocking: Prevent new users from joining the server
		ResetPrevent: Prevent users from resetting in-game
		ChatPrevent: Prevent users from hatting (EventManagers can still chat)
	]]
	EventsFolder.ServerUpdateCoreFunction.OnServerEvent:Connect(function(player, CoreFunction, Value)
		local EventManager = AttendeeHandler.CheckPlayerRole(player, AllowedPlayerList)
		
		if EventManager then
			CoreFunctions[CoreFunction] = Value

			EventsFolder.ClientUpdateCoreFunction:FireAllClients(CoreFunctions)			
		end
	end)
end

function module.ReturnCoreFunctions()
	return CoreFunctions
end

return module
