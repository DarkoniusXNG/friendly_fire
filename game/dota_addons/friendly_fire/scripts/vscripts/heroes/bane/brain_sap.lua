if bane_brain_sap_ff == nil then
	bane_brain_sap_ff = class({})
end

-- CastFilterResultTarget runs on client side first
function bane_brain_sap_ff:CastFilterResultTarget(target)
	local default_result = self.BaseClass.CastFilterResultTarget(self, target)

	if default_result == UF_FAIL_MAGIC_IMMUNE_ENEMY then
		local caster = self:GetCaster()
		-- If caster has Aghanim Scepter
		if caster:HasScepter() then
			return UF_SUCCESS
		end
	end

	return default_result
end

function bane_brain_sap_ff:GetCooldown(nLevel)
	local caster = self:GetCaster()
	local cooldown = self.BaseClass.GetCooldown(self, nLevel)
	
	if caster:HasScepter() then
		return self:GetSpecialValueFor("cooldown_scepter")
	end

	return cooldown
end

function bane_brain_sap_ff:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		
		if caster == nil or target == nil then
			return nil
		end
		
		-- Sound on caster
		caster:EmitSound("Hero_Bane.BrainSap")
		
		if not target:TriggerSpellAbsorb(self) then
			
			-- Sound on target
			target:EmitSound("Hero_Bane.BrainSap.Target")
			
			-- Particle
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_bane/bane_sap.vpcf", PATTACH_CUSTOMORIGIN, target)
			ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(particle)
			
			-- Damage
			local damage_and_heal = self:GetSpecialValueFor("damage_and_heal")
			
			-- Talent that increases damage and heal of Brain Sap
			local talent = caster:FindAbilityByName("special_bonus_unique_bane_2")
			if talent then
				if talent:GetLevel() ~= 0 then
					damage_and_heal = damage_and_heal + talent:GetSpecialValueFor("value")
				end
			end
			
			local damage_table = {}
			damage_table.victim = target
			damage_table.attacker = caster
			damage_table.damage = damage_and_heal
			damage_table.damage_type = self:GetAbilityDamageType()
			damage_table.ability = self
			ApplyDamage(damage_table)
			
			-- Heal
			caster:Heal(damage_and_heal, self)
		end
	end
end

function bane_brain_sap_ff:ProcsMagicStick()
	return true
end
