-- Called OnSpellStart
function DispelMagic(keys)
	local caster = keys.caster
	local point = keys.target_points[1]
	local ability = keys.ability
	
	local caster_team = caster:GetTeamNumber()
	local ability_level = ability:GetLevel() - 1
	
	local radius = ability:GetLevelSpecialValueFor("radius", ability_level)
	local damage_to_summons = ability:GetLevelSpecialValueFor("damage_to_summons", ability_level)
	
	-- Apply the basic dispel to enemies around point and damage them if they are summoned, dominated or an illusion
	local enemies = FindUnitsInRadius(caster_team, point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	for k, enemy in pairs(enemies) do
		enemy:RemoveModifierByName("modifier_brewmaster_storm_cyclone")
		-- Basic Dispel (Removes Buffs)
		enemy:Purge(true, false, false, false, false)
		
		if enemy:IsDominated() or enemy:IsSummoned() or enemy:IsIllusion() then
			ApplyDamage({victim = enemy, attacker = caster, ability = ability, damage = damage_to_summons, damage_type = ability:GetAbilityDamageType()})
		end
	end
	
	-- Apply the basic dispel to allies around point
	local allies = FindUnitsInRadius(caster_team, point, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
	for k, ally in pairs(allies) do
		ally:RemoveModifierByName("modifier_brewmaster_storm_cyclone")
		-- Basic Dispel (Removes normal debuffs)
		ally:Purge(false, true, false, false, false)
	end
end
