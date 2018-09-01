if modifier_tidebringer_ff_weapon_effect == nil then
	modifier_tidebringer_ff_weapon_effect = class({})
end

function modifier_tidebringer_ff_weapon_effect:IsHidden()
	return true
end

function modifier_tidebringer_ff_weapon_effect:IsPurgable()
	return false
end

function modifier_tidebringer_ff_weapon_effect:IsDebuff()
	return false
end

function modifier_tidebringer_ff_weapon_effect:RemoveOnDeath()
  return false
end

function modifier_tidebringer_ff_weapon_effect:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		self.weapon_pfx = self.weapon_pfx or 0
		if self.weapon_pfx == 0 then
			self.weapon_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_weapon_tidebringer.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControlEnt(self.weapon_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_tidebringer", caster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(self.weapon_pfx, 2, caster, PATTACH_POINT_FOLLOW, "attach_sword", caster:GetAbsOrigin(), true)
		end
	end
end

function modifier_tidebringer_ff_weapon_effect:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local cooldown = ability:GetCooldown(ability:GetLevel()-1)

		ParticleManager:DestroyParticle(self.weapon_pfx, true)
		ParticleManager:ReleaseParticleIndex(self.weapon_pfx)
		self.weapon_pfx = 0
	end
end
