-- Called OnSpellStart
function Diffusal_Purge_Start(event)
	local target = event.target
	local caster = event.caster
	local ability = event.ability
	local damageType = ability:GetAbilityDamageType()
	local duration = ability:GetLevelSpecialValueFor("purge_slow_duration", ability:GetLevel() - 1)
	local summon_damage = ability:GetLevelSpecialValueFor("purge_summoned_damage", ability:GetLevel() - 1)
	local damage_table = {}
	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.damage_type = damageType
	damage_table.ability = ability
	
	-- Play cast sound
	caster:EmitSound("DOTA_Item.DiffusalBlade.Activate")
	
	-- Checking if target has spell block, if target has spell block, there is no need to execute the spell
	if not target:TriggerSpellAbsorb( ability ) and target:GetTeamNumber() ~= caster:GetTeamNumber()  then
		-- Play hit sound
		target:EmitSound("DOTA_Item.DiffusalBlade.Target")
		
		if target:IsHero() then
			if target:IsRealHero() then
				DispelEnemy(target)
				if not target:IsMagicImmune() then
					ability:ApplyDataDrivenModifier(caster, target, "item_modifier_custom_purged_enemy_hero", {["duration"] = duration})
				end
			else
				-- For illusions
				damage_table.damage = summon_damage
				ApplyDamage(damage_table)
			end
		else
			if target:IsSummoned() or target:IsDominated() then
				ability:ApplyDataDrivenModifier(caster, target, "item_modifier_custom_purged_enemy_creep", {["duration"] = duration})
				DispelEnemy(target)
				damage_table.damage = summon_damage
				ApplyDamage(damage_table)
			else
				ability:ApplyDataDrivenModifier(caster, target, "item_modifier_custom_purged_enemy_creep", {["duration"] = duration})
				DispelEnemy(target)
			end
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
-- Called inside function Diffusal_Purge_Start
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

function Mana_Break(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	
	-- If better version of mana break is present, do nothing
	if caster:HasModifier("modifier_item_staff_of_negation_mana_break") or caster:HasModifier("modifier_antimage_mana_break") then
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

		-- Deal bonus damage (Damage_per_burned_mana = 1)
		if target_mana > mana_burn then
			ApplyDamage({attacker = caster, victim = target, ability = ability, damage = mana_burn, damage_type = DAMAGE_TYPE_PHYSICAL})
		else
			ApplyDamage({attacker = caster, victim = target, ability = ability, damage = target_mana, damage_type = DAMAGE_TYPE_PHYSICAL})
		end
	end
	
	-- Sound and effect
	if not target:IsMagicImmune() and target:GetMana() > 1 then
		-- Plays the particle
		local manaburn_fx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(manaburn_fx, 0, target:GetAbsOrigin() )
	end
end