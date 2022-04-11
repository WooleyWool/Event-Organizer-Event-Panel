local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventsFolder = ReplicatedStorage:WaitForChild("EventPanel"):WaitForChild("Events")
local EventPanelFolder = ReplicatedStorage:WaitForChild("EventPanel")

local EventSystemHandler = require(script.Parent.EventSystemsHandler)

local ConnectionsList = {
	["AttendeePanelBtn"] = function(EventPanel)
		EventPanel.Visible = not EventPanel.Visible
	end,
	["BackBtn"] = function(EventPanel: Frame)
		local SomethingVisible = false
		local Location

		for _, v in pairs(EventPanel:GetChildren()) do
			if v:IsA("Frame") then
				if v.Visible  then
					SomethingVisible = true
					Location = EventPanel
				end
			end
		end
		
		if SomethingVisible then
			for _, v in pairs(Location:GetChildren()) do
				if v:IsA("Frame") then
					v.Visible = false
				end
			end
		end
	end,
	["QABtn"] = function(QAView: Frame)
		if EventSystemHandler.ReturnEventSystemData()["QAEnabled"] == false then
			return
		end
		
		QAView.Visible = true
	end,
	["PinnedMessageBtn"] = function(PinnedMessage: Frame)
		PinnedMessage.Visible = true
	end,
}

function module.SetupConnection(ConnectionName, UIElement)	
	if ConnectionName == "EventManageBtn" then
		UIElement.Parent.EventManageBtn.MouseButton1Click:Connect(function()
			ConnectionsList[ConnectionName](UIElement)
		end)
	end 
end

function module.SetupBtnConnection(Button: TextButton, Frame)
	if ConnectionsList[Button.Name] then
		Button.MouseButton1Click:Connect(function()
			ConnectionsList[Button.Name](Frame)
		end)		
	end
end

return module
