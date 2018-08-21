if sven_storm_bolt_ff == nil then
	sven_storm_bolt_ff = class({})
end

LinkLuaModifier("modifier_sven_storm_bolt_ff", "heroes/sven/modifiers/modifier_sven_storm_bolt_ff.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_storm_bolt_cd_reduction_talent", "heroes/sven/modifiers/modifier_storm_bolt_cd_reduction_talent.lua", LUA_MODIFIER_MOTION_NONE)

function sven_storm_bolt_ff:GetAOERadius()
	return self:GetSpecialValueFor("bolt_aoe")
end

function sven_storm_bolt_ff:GetCooldown(nLevel)
	local caster = self:GetCaster()
	local cooldown = self.BaseClass.GetCooldown(self, nLevel)
	
	if IsServer() then
		-- Talent that reduces cooldown
		local talent = caster:FindAbilityByName("special_bonus_unique_sven")
		if talent then
			if talent:GetLevel() ~= 0 then
				local reduction = talent:GetSpecialValueFor("value")
				cooldown = cooldown - reduction
			end
		end
	else
		if caster:HasModifier("modifier_storm_bolt_cd_reduction_talent") then
			cooldown = cooldown - 6.0
		end
	end
	
	return cooldown
end

function sven_storm_bolt_ff:OnSpellStart()
	local vision_radius = self:GetSpecialValueFor("vision_radius")
	local bolt_speed = self:GetSpecialValueFor("bolt_speed")

	local info = {
			EffectName = "particles/units/heroes/hero_sven/sven_spell_storm_bolt.vpcf",
			Ability = self,
			iMoveSpeed = bolt_speed,
			Source = self:GetCaster(),
			Target = self:GetCursorTarget(),
			bDodgeable = true,
			bProvidesVision = true,
			iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
			iVisionRadius = vision_radius,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2, 
		}

	ProjectileManager:CreateTrackingProjectile(info)
	EmitSoundOn("Hero_Sven.StormBolt", self:GetCaster())
end

function sven_storm_bolt_ff:OnProjectileHit(hTarget, vLocation)
	if IsServer() then
		local caster = self:GetCaster()
		if hTarget ~= nil and (not hTarget:IsInvulnerable()) and (not hTarget:TriggerSpellAbsorb(self)) then
			EmitSoundOn("Hero_Sven.StormBoltImpact", hTarget)
			local bolt_aoe = self:GetSpecialValueFor("bolt_aoe")
			local bolt_damage = self:GetSpecialValueFor("bolt_damage")
			local bolt_stun_duration = self:GetSpecialValueFor("bolt_stun_duration")
			
			-- Talent that increases stun duration
			local talent1 = caster:FindAbilityByName("special_bonus_unique_sven_4")
			if talent1 then
				if talent1:GetLevel() ~= 0 then
					local bonus_duration = talent1:GetSpecialValueFor("value")
					bolt_stun_duration = bolt_stun_duration + bonus_duration
					print(bolt_stun_duration)
				end
			end
		
			local units = FindUnitsInRadius(caster:GetTeamNumber(), hTarget:GetOrigin(), hTarget, bolt_aoe, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
			if #units > 0 then
				for _,unit in pairs(units) do
					if unit then
						if unit ~= caster and (not unit:IsMagicImmune()) and (not unit:IsInvulnerable()) then
							local damage_table = {}
							damage_table.victim = unit
							damage_table.attacker = caster
							damage_table.damage = bolt_damage
							damage_table.damage_type = DAMAGE_TYPE_MAGICAL
							
							ApplyDamage(damage_table)
							unit:AddNewModifier(caster, self, "modifier_sven_storm_bolt_ff", {duration = bolt_stun_duration})
							
							-- Talent that dispels (Basic Dispel that removes buffs)
							local talent2 = caster:FindAbilityByName("special_bonus_unique_sven_3")
							if talent2 then
								if talent2:GetLevel() ~= 0 then
									unit:Purge(true, false, false, false, false)
								end
							end
						end
					end
				end
			end
		end
	end
	return true
end
