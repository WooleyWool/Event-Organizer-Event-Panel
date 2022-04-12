local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventsFolder = ReplicatedStorage.EventPanel.Events
local UIAssets = script.Parent.UIAssets

local OpenedCurrentEventData = require(script.Parent.OpenedCurrentEventData)

-- Specified button functions based on button name
local AttendeeListFunctions = {
	Kick = function(AttendeeId: number)
		EventsFolder.ServerAttendeeAction:FireServer("Kick", AttendeeId, OpenedCurrentEventData.ReturnEventName())
	end,
	EventBan = function(AttendeeId: number)
		EventsFolder.ServerAttendeeAction:FireServer("EventBan", AttendeeId, OpenedCurrentEventData.ReturnEventName())
	end,
	GlobalBan = function(AttendeeId: number)
		EventsFolder.ServerAttendeeAction:FireServer("GlobalBan", AttendeeId)
	end,
	EventUnban = function(AttendeeId: number)
		EventsFolder.ServerAttendeeAction:FireServer("EventUnban", AttendeeId, OpenedCurrentEventData.ReturnEventName())
	end,
	GlobalUnban = function(AttendeeId: number)
		EventsFolder.ServerAttendeeAction:FireServer("GlobalUnban", AttendeeId, OpenedCurrentEventData.ReturnEventName())
	end
}

-- Sets up the attendee frame with the respective user's username, id, event banned, and globally banned
function module.SetupAttendeeList(AttendeeList: ScrollingFrame, AttendeeName: string, AttendeeId: number, EventBan: boolean, GlobalBan: boolean)
	local AttendeeFrameClone = UIAssets.AttendeeSlider:Clone()
	
	AttendeeFrameClone.Name = tostring(AttendeeName)
	AttendeeFrameClone.AttendeeName.Text = AttendeeName.."\t\t"..tostring(AttendeeId)
	
	AttendeeFrameClone.EventBanPlayer.MouseButton1Click:Connect(function()
		AttendeeListFunctions["EventBan"](AttendeeId)
		
		AttendeeFrameClone.EventBanPlayer.Visible = false
		AttendeeFrameClone.EventUnbanPlayer.Visible = true
		AttendeeFrameClone.KickPlayer.Visible = false
	end)
	
	AttendeeFrameClone.EventUnbanPlayer.MouseButton1Click:Connect(function()
		AttendeeListFunctions["EventUnban"](AttendeeId)

		AttendeeFrameClone.EventBanPlayer.Visible = true
		AttendeeFrameClone.EventUnbanPlayer.Visible = false
		
		if AttendeeFrameClone.GlobalBanPlayer.Visible and AttendeeFrameClone.EventBanPlayer.Visible then
			AttendeeFrameClone.KickPlayer.Visible = true
		end
	end)
	
	AttendeeFrameClone.GlobalBanPlayer.MouseButton1Click:Connect(function()
		AttendeeListFunctions["GlobalBan"](AttendeeId)

		AttendeeFrameClone.GlobalBanPlayer.Visible = false
		AttendeeFrameClone.GlobalUnbanPlayer.Visible = true
		AttendeeFrameClone.KickPlayer.Visible = false
	end)
	
	AttendeeFrameClone.GlobalUnbanPlayer.MouseButton1Click:Connect(function()
		AttendeeListFunctions["GlobalUnban"](AttendeeId)

		AttendeeFrameClone.GlobalBanPlayer.Visible = true
		AttendeeFrameClone.GlobalUnbanPlayer.Visible = false
		
		if AttendeeFrameClone.GlobalBanPlayer.Visible and AttendeeFrameClone.EventBanPlayer.Visible then
			AttendeeFrameClone.KickPlayer.Visible = true
		end
	end)
	
	AttendeeFrameClone.KickPlayer.MouseButton1Click:Connect(function()
		AttendeeListFunctions["Kick"](AttendeeId)
	end)
	
	if EventBan then
		AttendeeFrameClone.EventBanPlayer.Visible = false
		AttendeeFrameClone.EventUnbanPlayer.Visible = true
		AttendeeFrameClone.KickPlayer.Visible = false
	end
	
	if GlobalBan then
		AttendeeFrameClone.GlobalBanPlayer.Visible = false
		AttendeeFrameClone.GlobalUnbanPlayer.Visible = true
		AttendeeFrameClone.KickPlayer.Visible = false
	end	
	
	AttendeeFrameClone.Parent = AttendeeList
end

return module
