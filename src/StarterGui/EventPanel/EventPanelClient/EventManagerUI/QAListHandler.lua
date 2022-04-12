local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventsFolder = ReplicatedStorage.EventPanel.Events
local UIAssets = script.Parent.UIAssets

local OpenedCurrentEventData = require(script.Parent.OpenedCurrentEventData)

-- Sets up the QA frame and button connections
function module.SetupQA(QAScrollingFrame: ScrollingFrame, AttendeeName: string, Question: string)
	local QASliderClone = UIAssets.QASlider:Clone()
	QASliderClone.AttendeeName.Text = AttendeeName
	QASliderClone.AttendeeQuestion.Text = Question
	QASliderClone.Name = "Question"..tostring(#QAScrollingFrame:GetChildren())
	
	QASliderClone.PresentQuestionBtn.MouseButton1Click:Connect(function()
		EventsFolder.ServerQAAction:FireServer(AttendeeName, OpenedCurrentEventData.ReturnEventName(), "Present")
	end)
	
	QASliderClone.HideQuestionBtn.MouseButton1Click:Connect(function()
		EventsFolder.ServerQAAction:FireServer(AttendeeName, OpenedCurrentEventData.ReturnEventName(), "Hide")
	end)
	
	QASliderClone.Parent = QAScrollingFrame
end

return module
