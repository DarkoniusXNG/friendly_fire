if sven_great_cleave_ff == nil then
	sven_great_cleave_ff = class({})
end

LinkLuaModifier("modifier_sven_great_cleave_ff", "heroes/sven/modifier_sven_great_cleave_ff.lua", LUA_MODIFIER_MOTION_NONE)

function sven_great_cleave_ff:GetIntrinsicModifierName()
	return "modifier_sven_great_cleave_ff"
end
