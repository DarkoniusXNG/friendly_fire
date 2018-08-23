if alchemist_acid_spray_ff == nil then
	alchemist_acid_spray_ff = class({})
end

LinkLuaModifier("modifier_acid_spray_ff_thinker", "heroes/alchemist/modifier_acid_spray_ff_thinker.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_acid_spray_ff_debuff", "heroes/alchemist/modifier_acid_spray_ff_debuff.lua", LUA_MODIFIER_MOTION_NONE)

function alchemist_acid_spray_ff:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function alchemist_acid_spray_ff:OnSpellStart()
	local caster = self:GetCaster()
	CreateModifierThinker(caster, self, "modifier_acid_spray_ff_thinker", {duration = self:GetSpecialValueFor("duration")}, self:GetCursorPosition(), caster:GetTeamNumber(), false)
end

function alchemist_acid_spray_ff:ProcsMagicStick()
	return true
end
