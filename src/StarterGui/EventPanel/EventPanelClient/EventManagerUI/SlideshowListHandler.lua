local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local EventsFolder = ReplicatedStorage.EventPanel.Events
local UIAssets = script.Parent.UIAssets
local EventPanel = script.Parent.Parent.Parent.Parent:WaitForChild("EventManager")
local SlideshowFrame = EventPanel.EventPanel.EventFrame.SlideshowList
local OpenedCurrentEventData = require(script.Parent.OpenedCurrentEventData)

local SlideEditorConnections = {}

function module.SetupSlide(SlideNumber: string, SlideImageID: string)
	local SlideTemplateClone = UIAssets.SlideTemplate:Clone()
	SlideTemplateClone.Name = SlideNumber
	
	local ReturnedImageId
	
	ReturnedImageId = EventsFolder.ServerReturnImageId:InvokeServer(SlideImageID)
			
	SlideTemplateClone.Image = tostring(ReturnedImageId)
			
	SlideTemplateClone.MouseButton1Click:Connect(function()
		SlideshowFrame.SlideshowEditorFrame.SlideImageTextBox.Text = SlideImageID
		SlideshowFrame.SlideshowEditorFrame.SlidePosTextBox.Text = string.sub(SlideNumber, 6)
		SlideshowFrame.SlideshowEditorFrame.CurrentSlide.Image = ReturnedImageId
		
		if SlideEditorConnections["Delete"] ~= nil then
			for _, conn in pairs(SlideEditorConnections) do
				conn:Disconnect()
			end
		end
		
		SlideEditorConnections["Delete"] = SlideshowFrame.SlideshowEditorFrame.DeleteSlideBtn.MouseButton1Click:Connect(function()
			EventsFolder.ServerSlideshowAction:FireServer("Delete", OpenedCurrentEventData.ReturnEventName(), SlideNumber)
			SlideshowFrame.SlideshowEditorFrame.Visible = false
		end)
		
		SlideEditorConnections["Re-Number"] = SlideshowFrame.SlideshowEditorFrame.EditSlidePosBtn.MouseButton1Click:Connect(function()
			local SlideshowData = {}
			
			SlideshowData["SlideshowNumber"] = SlideNumber

			if tonumber(SlideshowFrame.SlideshowEditorFrame.SlidePosTextBox.Text) and tonumber(SlideshowFrame.SlideshowEditorFrame.SlideImageTextBox.Text) then
				SlideshowData["SlideshowImageID"] = SlideshowFrame.SlideshowEditorFrame.SlideImageTextBox.Text
				SlideshowData["SlidePosition"] = SlideshowFrame.SlideshowEditorFrame.SlidePosTextBox.Text
				EventsFolder.ServerSlideshowAction:FireServer("Edit", OpenedCurrentEventData.ReturnEventName(), SlideshowData)
			end
		end)
		
		SlideEditorConnections["ImageID"] = SlideshowFrame.SlideshowEditorFrame.EditSlideImageBtn.MouseButton1Click:Connect(function()
			local SlideshowData = {}
			
			SlideshowData["SlideshowNumber"] = SlideNumber

			if tonumber(SlideshowFrame.SlideshowEditorFrame.SlidePosTextBox.Text) and tonumber(SlideshowFrame.SlideshowEditorFrame.SlideImageTextBox.Text) then
				SlideshowData["SlideshowImageID"] = SlideshowFrame.SlideshowEditorFrame.SlideImageTextBox.Text
				SlideshowData["SlidePosition"] = SlideshowFrame.SlideshowEditorFrame.SlidePosTextBox.Text	
				
				EventsFolder.ServerSlideshowAction:FireServer("Edit", OpenedCurrentEventData.ReturnEventName(), SlideshowData)
			end
		end)
		
		SlideshowFrame.SlideshowEditorFrame.Visible = true
		SlideshowFrame.NewSlideEditorFrame.Visible = false
	end)
	
	SlideTemplateClone.Parent = SlideshowFrame.SlideshowScrollingFrame
end

return module
