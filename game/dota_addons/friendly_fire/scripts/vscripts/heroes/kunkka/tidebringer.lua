if kunkka_tidebringer_ff == nil then
	kunkka_tidebringer_ff = class({})
end

LinkLuaModifier("modifier_tidebringer_ff_autocast", "heroes/kunkka/modifier_tidebringer_ff_autocast.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tidebringer_ff_cooldown", "heroes/kunkka/modifier_tidebringer_ff_cooldown.lua", LUA_MODIFIER_MOTION_NONE)
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
			-- I will fix this at another time (without nettables)
			cooldown = cooldown - 1.5
		end
	end
	
	return cooldown
end

function kunkka_tidebringer_ff:IsStealable()
	return false
end

function kunkka_tidebringer_ff:GetIntrinsicModifierName()
	return "modifier_kunkka_tidebringer_ff_autocast"
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
