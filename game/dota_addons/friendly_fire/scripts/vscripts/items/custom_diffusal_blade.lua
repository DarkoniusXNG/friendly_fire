-- Called OnSpellStart
function Diffusal_Purge_Start(event)
	local target = event.target
	local caster = event.caster
	local ability = event.ability
	local ability_level = ability:GetLevel() - 1
	local damageType = ability:GetAbilityDamageType()
	local duration = ability:GetLevelSpecialValueFor("purge_slow_duration", ability_level)
	local summon_damage = ability:GetLevelSpecialValueFor("purge_summoned_damage", ability_level)
	local damage_table = {}
	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.damage_type = damageType
	damage_table.ability = ability
	
	-- Play cast sound
	caster:EmitSound("DOTA_Item.DiffusalBlade.Activate")
	
	-- Checking if target has spell block, if target has spell block, there is no need to execute the spell
	if not target:TriggerSpellAbsorb(ability) and target:GetTeamNumber() ~= caster:GetTeamNumber()  then
		-- Play hit sound
		target:EmitSound("DOTA_Item.DiffusalBlade.Target")
		
		if target:IsHero() then
			if target:IsRealHero() then
				if not target:IsMagicImmune() then
					ability:ApplyDataDrivenModifier(caster, target, "item_modifier_custom_purged_enemy_hero", {["duration"] = duration})
				end
			else
				-- Illusions are like creeps
				ability:ApplyDataDrivenModifier(caster, target, "item_modifier_custom_purged_enemy_creep", {["duration"] = duration})
			end
		else
			ability:ApplyDataDrivenModifier(caster, target, "item_modifier_custom_purged_enemy_creep", {["duration"] = duration})
		end
	end
end

-- Called when item_modifier_custom_purged_ally is created
function DispelAlly(event)
	local target = event.target
	-- Basic Dispel
	local RemovePositiveBuffs = false
	local RemoveDebuffs = true
	local BuffsCreatedThisFrameOnly = false
	local RemoveStuns = false
	local RemoveExceptions = false
	target:Purge(RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)
end

-- Not used
function DispelEnemy(unit)
	if unit then
		unit:RemoveModifierByName("modifier_eul_cyclone")
		unit:RemoveModifierByName("modifier_brewmaster_storm_cyclone")
		local RemovePositiveBuffs = true
		local RemoveDebuffs = false
		local BuffsCreatedThisFrameOnly = false
		local RemoveStuns = false
		local RemoveExceptions = false
		unit:Purge(RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)
	end
end

-- Called OnAttackLanded (Damage is dealt in a seperate instance - its added after attack damage. So its not completely the same as in regular dota)
function Mana_Break(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	
	-- If better version of mana break is present, do nothing
	if caster:HasModifier("modifier_antimage_mana_break") then
		return nil
	end
	
	-- Parameters
	local mana_burn = ability:GetLevelSpecialValueFor("mana_burn", ability_level)
	if attacker:IsIllusion() then
		if attacker:IsRangedAttacker() then
			mana_burn = ability:GetLevelSpecialValueFor("mana_burn_illusion_ranged", ability_level)
		else
			mana_burn = ability:GetLevelSpecialValueFor("mana_burn_illusion_melee", ability_level)
		end
	end

	-- Burn mana if target is not magic immune
	if not target:IsMagicImmune() then

		-- Burn mana
		local target_mana = target:GetMana()
		target:ReduceMana(mana_burn)
		
		-- Calculate damage
		local damage_per_mana = 0.8
		local actual_damage
		if target_mana > mana_burn then
			actual_damage = damage_per_mana*mana_burn
		else
			actual_damage = damage_per_mana*target_mana
		end
		
		-- Deal Damage
		ApplyDamage({attacker = caster, victim = target, ability = ability, damage = actual_damage, damage_type = DAMAGE_TYPE_PHYSICAL})
	end
	
	-- Sound and effect
	if not target:IsMagicImmune() and target:GetMana() > 1 then
		-- Plays the particle
		local manaburn_fx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(manaburn_fx, 0, target:GetAbsOrigin())
	end
end
