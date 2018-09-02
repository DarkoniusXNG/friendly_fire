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
	local parent = self:GetParent()
	local ability = self:GetAbility()
		
	if IsServer() then
		if self.weapon_pfx == nil then
			-- Plays an audio effect (only heard by Kunkka) when going off cooldown.
			EmitSoundOnClient("Hero_Kunkaa.Tidebringer", parent:GetPlayerOwner())
			self.weapon_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_weapon_tidebringer.vpcf", PATTACH_CUSTOMORIGIN, parent)
			ParticleManager:SetParticleControlEnt(self.weapon_pfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_tidebringer", parent:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(self.weapon_pfx, 2, parent, PATTACH_POINT_FOLLOW, "attach_sword", parent:GetAbsOrigin(), true)
		end
	end
end

modifier_tidebringer_ff_weapon_effect.OnRefresh = modifier_tidebringer_ff_weapon_effect.OnCreated

function modifier_tidebringer_ff_weapon_effect:OnDestroy()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	if IsServer() then
		ParticleManager:DestroyParticle(self.weapon_pfx, true)
		ParticleManager:ReleaseParticleIndex(self.weapon_pfx)
		self.weapon_pfx = nil
	end
end
