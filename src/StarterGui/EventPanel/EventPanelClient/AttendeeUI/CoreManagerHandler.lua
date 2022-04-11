local module = {}

local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventsFolder = ReplicatedStorage.EventPanel.Events

local Connections = {}

local coreCall do
	local MAX_RETRIES = 8

	function coreCall(method, ...)
		local result = {}
		for retries = 1, MAX_RETRIES do
			result = {pcall(StarterGui[method], StarterGui, ...)}
			if result[1] then
				break
			end
			RunService.Stepped:Wait()
		end
		return unpack(result)
	end
end

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
