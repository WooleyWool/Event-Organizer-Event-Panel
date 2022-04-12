local module = {}

local TextService = game:GetService("TextService")

-- Filter the text that is sent and will return the filtered string
function module.FilterText(Text: string, UserId: number)
	local FilteredStringResult
	local success, errorMsg = pcall(function()
		FilteredStringResult = TextService:FilterStringAsync(Text, UserId)
	end)
	
	if success then
		local FilteredString = FilteredStringResult:GetNonChatStringForBroadcastAsync()
		
		return FilteredString
	else
		warn("Text couldn't be filtered")
	end	
end

return module
