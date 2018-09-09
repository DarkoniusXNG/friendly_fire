if modifier_acid_spray_ff_thinker == nil then
	modifier_acid_spray_ff_thinker = class({})
end

function modifier_acid_spray_ff_thinker:IsHidden()
	return true
end

function modifier_acid_spray_ff_thinker:IsPurgable()
	return false
end

function modifier_acid_spray_ff_thinker:IsAura()
	return true
end

function modifier_acid_spray_ff_thinker:GetModifierAura()
	return "modifier_acid_spray_ff_debuff"
end

function modifier_acid_spray_ff_thinker:GetAuraRadius()
	local ability = self:GetAbility()
	return ability:GetSpecialValueFor("radius")
end

function modifier_acid_spray_ff_thinker:GetAuraSearchTeam()
  return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_acid_spray_ff_thinker:GetAuraSearchType()
  return bit.bor(DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_BASIC)
end

function modifier_acid_spray_ff_thinker:GetAuraSearchFlags()
  return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_acid_spray_ff_thinker:OnCreated(kv)
	if IsServer() then
		local ability = self:GetAbility()
		local radius = ability:GetSpecialValueFor("radius")
		local duration = ability:GetSpecialValueFor("duration")
		local caster = ability:GetCaster()
		local location = ability:GetCursorPosition()
		
		local dummy = CreateUnitByName("npc_dota_custom_dummy_unit", location, true, caster, caster, caster:GetTeamNumber())
		
		-- Sound on dummy (thinker) that represents Acid Spray itself
		dummy:EmitSound("Hero_Alchemist.AcidSpray")
		dummy:AddNewModifier(caster, ability, "modifier_kill", {duration = duration})

		-- Stops the sound after the duration; a bit early to ensure the dummy still exists
		Timers:CreateTimer(duration-0.1, function() 
			dummy:StopSound("Hero_Alchemist.AcidSpray")
		end)
		
		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_alchemist/alchemist_acid_spray.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(self.particle, 0, location)
	   	ParticleManager:SetParticleControl(self.particle, 1, Vector(radius, 1, 1))
		ParticleManager:SetParticleControl(self.particle, 15, Vector(25, 150, 25))
		ParticleManager:SetParticleControl(self.particle, 16, Vector(0, 0, 0))
		--ParticleManager:SetParticleControl(self.particle, 1, Vector(radius, 1, radius))
		--ParticleManager:SetParticleControl(self.particle, 15, Vector(255,255,0))
		--ParticleManager:SetParticleControl(self.particle, 16, Vector(255,255,0))
	end
end

function modifier_acid_spray_ff_thinker:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.particle, false)
		ParticleManager:ReleaseParticleIndex(self.particle)
		self.particle = nil
	end
end
