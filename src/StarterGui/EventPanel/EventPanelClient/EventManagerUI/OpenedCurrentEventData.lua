local module = {}

local OpenedEvent = "None"

-- Sets the OpenedEvent to whatever event button you pressed on
function module.UpdateEvent(NewEvent: string)
	OpenedEvent = NewEvent
end

-- Returns the current opened event
function module.ReturnEventName()
	return OpenedEvent
end

return module
