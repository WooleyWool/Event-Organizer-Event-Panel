local module = {}

local ConnectionsHandler = require(script.ConnectionsHandler)
local UIObjectHandler = require(script.Parent.UIObjectHandler)
local EventUpdater = require(script.EventUpdater)

local UIAssets = script:WaitForChild("UIAssets")

local ScreenGui

function SetupInfiniteScrolling(ScreenGui: ScreenGui)
	for i, frame in pairs(ScreenGui:GetDescendants()) do
		if frame:IsA("ScrollingFrame") and frame:FindFirstChildOfClass("UIGridLayout") then
			UIObjectHandler.SetupInfiniteScrolling(frame)
		end
	end 
end

function module.InitializeManagerUI(AssociatedScreenGui: ScreenGui, EventData)
	ScreenGui = AssociatedScreenGui
	local EventPanelUI = ScreenGui.EventPanel
	local PresenterModeFrame = ScreenGui.PresenterMode
	
	local ButtonFrameRelation = {
		EventManageBtn = EventPanelUI,
		InitiateCreateEventBtn = EventPanelUI,
		CreateEventBtn = EventPanelUI,
		CancelEventCreationBtn = EventPanelUI,
		AttendeeListBtn = EventPanelUI,
		BackBtn = EventPanelUI,
		GlobalBanListBtn = EventPanelUI,
		ChatPreventBtn = EventPanelUI.EventListFrame.RobloxCoreManagerFrame.ChatPreventBtn,
		ResetPreventBtn = EventPanelUI.EventListFrame.RobloxCoreManagerFrame.ResetPreventBtn,
		ServerLockBtn = EventPanelUI.EventListFrame.RobloxCoreManagerFrame.ServerLockBtn,
		RobloxCoreFunctionBtn = EventPanelUI.EventListFrame,
		AttendeeQABtn = EventPanelUI.EventFrame.Buttons.AttendeeQABtn,
		ViewQABtn = EventPanelUI.EventFrame,
		SlideshowBtn = EventPanelUI.EventFrame,
		CreateSlideBtn = EventPanelUI.EventFrame.SlideshowList.NewSlideEditorFrame,
		AddSlideBtn = EventPanelUI.EventFrame.SlideshowList.NewSlideEditorFrame,
		PresenterModeBtn = PresenterModeFrame,
		ExitPesenterBtn = PresenterModeFrame,
		AddPinnedMessageBtn = EventPanelUI.EventFrame.PinnedMessage,
		PinnedMessagesBtn = EventPanelUI.EventFrame.PinnedMessage,
		DeleteEventBtn = EventPanelUI
	}
	
	SetupInfiniteScrolling(ScreenGui)
	
	EventUpdater.SetupClientEvents(EventData, EventPanelUI)
	
	for i, v in pairs(ScreenGui:GetDescendants()) do
		if v:IsA("TextButton") or v:IsA("ImageButton") then
			ConnectionsHandler.SetupBtnConnection(v, ButtonFrameRelation[v.Name])
		end
	end
	
	UIObjectHandler.SetupSearchSystem(EventPanelUI.EventFrame.AttendeeList.AttendeeSearch)
	UIObjectHandler.SetupSearchSystem(EventPanelUI.EventListFrame.GlobalBanList.AttendeeSearch)
	UIObjectHandler.SetupSlideTextboxIDUpdater(EventPanelUI.EventFrame.SlideshowList.NewSlideEditorFrame.NewSlideImageTextBox)
	UIObjectHandler.SetupSlideTextboxIDUpdater(EventPanelUI.EventFrame.SlideshowList.SlideshowEditorFrame.SlideImageTextBox)
end

return module
