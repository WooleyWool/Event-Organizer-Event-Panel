local module = {}

-- Please do not tinker with group information. This is for Event Managers.
-- PlayerIDs should include the list of organizers that you want access to your event panel.
local VIPList = {
	PlayerIDs = {34355831},
	Group = {
		GroupID = 9420522,
		AllowedRankID = 254
	}
}

function module.ReturnData()
	return VIPList
end

return module
