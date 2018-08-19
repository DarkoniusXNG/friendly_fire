if friendly_fire_gamemode == nil then
	_G.friendly_fire_gamemode = class({})
end

require('util')
require('customgamemode')
require('player')

function Precache( context )
	PrecacheItemByNameSync("item_ultimate_king_bar", context)
	PrecacheItemByNameSync("item_infused_robe", context)
end

-- Create the game mode when we activate
function Activate()
	--GameRules.AddonTemplate = friendly_fire_gamemode()
	print("Friendly Fire game mode activated.")
	friendly_fire_gamemode:InitGameMode()
end