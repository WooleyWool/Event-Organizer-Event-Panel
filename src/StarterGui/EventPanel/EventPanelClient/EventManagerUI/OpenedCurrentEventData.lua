local module = {}

local OpenedEvent = "None"

function module.UpdateEvent(NewEvent: string)
	OpenedEvent = NewEvent
end

function module.ReturnEventName()
	return OpenedEvent
end

return module
