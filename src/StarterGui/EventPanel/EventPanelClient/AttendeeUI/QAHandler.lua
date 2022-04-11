local module = {}

local MaxCharacters = 250

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventsFolder = ReplicatedStorage:WaitForChild("EventPanel"):WaitForChild("Events")

function module.SetupQA(QAFrame: Frame, EventName)
	local QADraftTextBox: TextBox = QAFrame.QADraftTextBox
	local CharactersLeftText: TextLabel = QAFrame.CharactersLeftText
	local SubmitBtn: TextButton = QAFrame.SubmitBtn
	
	QADraftTextBox:GetPropertyChangedSignal("Text"):Connect(function()
		CharactersLeftText.Text = "Characters Left: "..(tostring(MaxCharacters - string.len(QADraftTextBox.Text)))
		
		QADraftTextBox.Text = string.sub(QADraftTextBox.Text, 1, MaxCharacters)
	end)
	
	SubmitBtn.MouseButton1Click:Connect(function()
		if QADraftTextBox.Text ~= "" or QADraftTextBox.Text ~= nil then
			EventsFolder.ServerQAQuestion:FireServer(EventName, QADraftTextBox.Text)
			
			QADraftTextBox.Text = ""
		end
	end)
end

return module
