if friendly_fire_gamemode == nil then
	_G.friendly_fire_gamemode = class({})
end

require('util')
require('customgamemode')
require('player')

function Precache(context)
	
end

-- Create the game mode when we activate
function Activate()
	print("Friendly Fire game mode activated.")
	friendly_fire_gamemode:InitGameMode()
end
