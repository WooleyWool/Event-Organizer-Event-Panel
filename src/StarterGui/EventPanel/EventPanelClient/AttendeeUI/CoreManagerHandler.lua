local module = {}

local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventsFolder = ReplicatedStorage.EventPanel.Events

local Connections = {}

-- Setup core functions (ChatPrevent & ResetPrevent)
function module.SetupCoreFunctionConnections()
	EventsFolder.ClientUpdateCoreFunction.OnClientEvent:Connect(function(CoreFunctionsTable)
		for CoreFunction, Value in pairs(CoreFunctionsTable) do
			if tostring(CoreFunction) == "ChatPrevent" then
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, Value)
			else
				StarterGui:SetCore("ResetButtonCallback", Value)
			end
		end
	end)
end

return module
