local module = {}

local ScreenGui

local CoreManagerHandler = require(script.CoreManagerHandler)
local ConnectionsHandler = require(script.ConnectionsHandler)
local EventSystemHandler = require(script.EventSystemsHandler)
local QAHandler = require(script.QAHandler)

-- Initial setup for AttendeeUI
function module.Initialize(AssociatedScreenGui: ScreenGui, EventName, EventSystemData)
	ScreenGui = AssociatedScreenGui
	local EventPanelUI = ScreenGui.EventPanel

	local ButtonFrameRelation = {
		AttendeePanelBtn = EventPanelUI,
		BackBtn = EventPanelUI,
		QABtn = EventPanelUI.QAView,
		PinnedMessageBtn = EventPanelUI.PinnedMessage	
	}

	for i, v in pairs(ScreenGui:GetDescendants()) do
		if v:IsA("TextButton") or v:IsA("ImageButton") then
			ConnectionsHandler.SetupBtnConnection(v, ButtonFrameRelation[v.Name])
		end
	end
	
	CoreManagerHandler.SetupCoreFunctionConnections()
	QAHandler.SetupQA(EventPanelUI.QAView, EventName)
	EventSystemHandler.SetupReceivedData(EventSystemData, EventPanelUI)
end

return module
