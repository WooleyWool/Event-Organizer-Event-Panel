local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InsertService = game:GetService("InsertService")
local EventsFolder = ReplicatedStorage.EventPanel.Events

local AttendeeHandler = require(script.Parent.AttendeeHandler)
local EventDataHandler = require(script.Parent.EventDataHandler)
local EventPanelVIPList = require(script.Parent.EventPanelVIPList)

local PresentationModel

local AllowedPlayerList = EventPanelVIPList.ReturnData()

local CurrentSlideNumber = 1

function ReturnImageID(ImageId)
	local InsertedObject = InsertService:LoadAsset(ImageId)
	local ReturnedImageID = InsertedObject:FindFirstChildOfClass("Decal").Texture
	InsertedObject:Destroy()

	return ReturnedImageID
end

function module.SetupSlideshowSystem()
	if workspace:FindFirstChild("PresentationModel") then
		PresentationModel = workspace.PresentationModel
	else
		error("Slideshow stage doesn't exist, slideshow handler not intitalized")
	end	
	
	EventsFolder.ServerSwitchSlide.OnServerEvent:Connect(function(player, CurrentEvent, Action)
		local EventData = EventDataHandler.ReturnSpecificEvent(CurrentEvent)
		
		if AttendeeHandler.CheckPlayerRole(player, AllowedPlayerList) then
			if Action == "Start" then
				CurrentSlideNumber = 1

				PresentationModel.PresentationScreen.SurfaceGui.QAQuestion.Text = ""

				if EventData["SlideshowSlides"]["Slide"..(CurrentSlideNumber)] == nil then
					return
				end

				PresentationModel.PresentationScreen.SurfaceGui.SlideImage.Image = ReturnImageID(EventData["SlideshowSlides"]["Slide"..CurrentSlideNumber])
			elseif Action == "Next" then
				if EventData["SlideshowSlides"]["Slide"..(CurrentSlideNumber + 1)] == nil then
					return
				end

				CurrentSlideNumber += 1

				PresentationModel.PresentationScreen.SurfaceGui.SlideImage.Image = ReturnImageID(EventData["SlideshowSlides"]["Slide"..CurrentSlideNumber])
			elseif Action == "Previous" then	
				if EventData["SlideshowSlides"]["Slide"..(CurrentSlideNumber - 1)] == nil then
					return
				end

				CurrentSlideNumber -= 1

				PresentationModel.PresentationScreen.SurfaceGui.SlideImage.Image = ReturnImageID(EventData["SlideshowSlides"]["Slide"..CurrentSlideNumber])
			end	
		end
	end)
	
	EventsFolder.ServerSlideshowAction.OnServerEvent:Connect(function(player, Action, EventName, SlideshowData)
		if AttendeeHandler.CheckPlayerRole(player, AllowedPlayerList) then
			if Action == "New" then
				EventDataHandler.AddSlideshow(EventName, SlideshowData)
			elseif Action == "Delete" then
				EventDataHandler.DeleteSlide(EventName, SlideshowData) -- SlideshowData in this case is the slide name 
			elseif Action == "Edit" then
				EventDataHandler.EditSlide(EventName, SlideshowData)
			end
		end
	end)
	
	EventsFolder.ServerQAAction.OnServerEvent:Connect(function(player, AttendeeName, CurrentEvent, Action)
		if AttendeeHandler.CheckPlayerRole(player, AllowedPlayerList) then
			local EventData = EventDataHandler.ReturnSpecificEvent(CurrentEvent)

			if Action == "Hide" then
				PresentationModel.PresentationScreen.SurfaceGui.QAQuestion.Text = ""
			elseif Action == "Present" then
				PresentationModel.PresentationScreen.SurfaceGui.QAQuestion.Text = EventData["QAList"][AttendeeName]
			end			
		end
	end)
end

return module
