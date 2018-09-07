if kunkka_tidebringer_ff == nil then
	kunkka_tidebringer_ff = class({})
end

LinkLuaModifier("modifier_tidebringer_ff", "heroes/kunkka/modifier_tidebringer_ff.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tidebringer_ff_weapon_effect", "heroes/kunkka/modifier_tidebringer_ff_weapon_effect.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tidebringer_cd_reduction_talent", "heroes/kunkka/modifier_tidebringer_cd_reduction_talent.lua", LUA_MODIFIER_MOTION_NONE)

function kunkka_tidebringer_ff:GetCooldown(level)
	local caster = self:GetCaster()
	local cooldown = self.BaseClass.GetCooldown(self, level)
	
	if IsServer() then
		-- Talent that reduces cooldown
		local talent = caster:FindAbilityByName("special_bonus_unique_kunkka_5")
		if talent then
			if talent:GetLevel() ~= 0 then
				local reduction = talent:GetSpecialValueFor("value")
				cooldown = cooldown - reduction
			end
		end
	else
		if caster:HasModifier("modifier_tidebringer_cd_reduction_talent") then
			cooldown = cooldown - caster.tidebringer_cd_reduction_talent_value
		end
	end
	
	return cooldown
end

function kunkka_tidebringer_ff:IsStealable()
	return false
end

function kunkka_tidebringer_ff:GetIntrinsicModifierName()
	return "modifier_tidebringer_ff"
end

function kunkka_tidebringer_ff:CastFilterResultTarget(target)
	local caster = self:GetCaster()
	if target == caster then
		return UF_FAIL_CUSTOM
	end
	if IsServer() then
		local allowed = UnitFilter(target, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), caster:GetTeamNumber())
		return allowed
	end

	return UF_SUCCESS
end

function kunkka_tidebringer_ff:GetCustomCastErrorTarget(target)
	local caster = self:GetCaster()
	if target == caster then
		return "#dota_hud_error_cant_cast_on_self"
	end
end

function kunkka_tidebringer_ff:GetCastRange(location, target)
	return self:GetCaster():GetAttackRange()
end

function kunkka_tidebringer_ff:ShouldUseResources()
	return true
end

function kunkka_tidebringer_ff:OnUpgrade()
	-- First point to the ability
	if self:GetLevel() == 1 then
		-- Turn on autocast when the ability is leveled-up for the first time
		if not self:GetAutoCastState() then
			self:ToggleAutoCast()
		end
	end
end
