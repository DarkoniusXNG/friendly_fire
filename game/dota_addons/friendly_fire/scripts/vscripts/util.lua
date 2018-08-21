-- Given element and table, returns true if element is in the table.
function TableContains(table1, element)
    if table1 == nil then return false end
    for k,v in pairs(table1) do
        if k == element then
            return true
        end
    end
    return false
end

function TableLength(t)
    if t == nil or t == {} then
        return 0
    end
    local length = 0
    for k,v in pairs(t) do
        length = length + 1
    end
    return length
end

function PrintTable(t, indent, done)
  --print ( string.format ('PrintTable type %s', type(keys)) )
  if type(t) ~= "table" then return end

  done = done or {}
  done[t] = true
  indent = indent or 0

  local l = {}
  for k, v in pairs(t) do
    table.insert(l, k)
  end

  table.sort(l)
  for k, v in ipairs(l) do
    -- Ignore FDesc
    if v ~= 'FDesc' then
      local value = t[v]

      if type(value) == "table" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..":")
        PrintTable (value, indent + 2, done)
      elseif type(value) == "userdata" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
      else
        if t.FDesc and t.FDesc[v] then
          print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
        else
          print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        end
      end
    end
  end
end

-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'

--[[ This function is showing Error Messages using notifications library from BMD's Barebones
	Author: Noya
]]
function SendErrorMessage(pID, string)
    Notifications:ClearBottom(pID)
    Notifications:Bottom(pID, {text=string, style={color='#E62020'}, duration=2})
    EmitSoundOnClient("General.Cancel", PlayerResource:GetPlayer(pID))
end

--[[ This function hides all hats (wearables) from the hero and store them into a handle variable
  Date: 09.08.2015.
  Author: Noya (Part of BMD Barebones)
]]
function HideWearables(hero)
	hero.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
	local model = hero:FirstMoveChild()
	while model ~= nil do
		if model:GetClassname() == "dota_item_wearable" then
			model:AddEffects(EF_NODRAW) -- Set model hidden
			table.insert(hero.hiddenWearables, model)
		end
		model = model:NextMovePeer()
	end
end

--[[ This function unhides/shows wearables that were hidden with HideWearables() function.
	Author: Noya (Part of BMD Barebones)
]]
function ShowWearables(hero)
  for i,v in pairs(hero.hiddenWearables) do
    v:RemoveEffects(EF_NODRAW)
  end
end

--[[ This function is needed for changing models (for Arcanas for example)
	Author: Noya
]]
function SwapWearable(unit, target_model, new_model)
    local wearable = unit:FirstMoveChild()
    while wearable ~= nil do
        if wearable:GetClassname() == "dota_item_wearable" then
            if wearable:GetModelName() == target_model then
                wearable:SetModel( new_model )
                return
            end
        end
        wearable = wearable:NextMovePeer()
    end
end
 
-- This function checks if a given unit is Roshan, returns boolean value;
function IsRoshan(unit)
	if unit:IsAncient() and unit:GetName() == "npc_dota_roshan" then
		return true
	else
		return false
	end
end

-- This function checks if this unit/entity is a fountain or not; returns boolean value;
function IsFountain(unit)
	if unit:GetName() == "ent_dota_fountain_bad" or unit:GetName() == "ent_dota_fountain_good" then
		return true
	end
	
	return false
end

-- Initializes heroes' innate abilities
function InitializeInnateAbilities(hero)

	-- List of innate abilities
	local innate_abilities = {
		"innate_ability1",
		"innate_ability2"
	}

	-- Cycle through any innate abilities found, then upgrade them
	for i = 1, #innate_abilities do
		local current_ability = hero:FindAbilityByName(innate_abilities[i])
		if current_ability then
			current_ability:SetLevel(1)
		end
	end
end

--[[ This function interrupts and hide the target hero, applies SuperStrongDispel and CustomPassiveBreak to the target,
    and creates a copy of the target for the caster, returns the hScript copy;
	Target hero has vision over the area where he is moved! You need a modifier to disable this vision;
	Copy/Clone of the target hero is not invulnerable! You need a modifier for that too;
	Used in some abilities ...
]]
function HideAndCopyHero(target, caster)
	if target and caster then
		local caster_team = caster:GetTeamNumber()
		local playerID = caster:GetPlayerOwnerID()
		local target_name = target:GetUnitName()
		local target_origin = target:GetAbsOrigin()
		local target_ability_count = target:GetAbilityCount()
		local target_HP = target:GetHealth()
		local target_MP = target:GetMana()
		local target_level = target:GetLevel()
		
		target:Interrupt()
		target:InterruptChannel()
		target:AddNoDraw() -- needed for hiding the original hero
		
		-- Moving the target (original hero) to the corner of the map
		local corner = Vector(0,0,0)
		if GetMapName() == "smaller_map" then
			corner = Vector(2300,-2300,-322)
		else
			corner = Vector(7500,-7200,-322)
		end
		target:SetAbsOrigin(corner)
		
		local hidden_modifiers = {
			"modifier_not_removed_on_death",
			"modifier_not_removed_with_super_strong_dispel_or_custom_passive_break"
		}
		
		-- Remove all buffs and debuffs from the target
		SuperStrongDispel(target, true, true)
		
		-- Remove passive modifiers from the target with Custom Passive Break
		CustomPassiveBreak(target, 100)
		
		-- Cycle through remaining hidden modifiers and bugging visual effects and remove them
		for i=1, #hidden_modifiers do
			target:RemoveModifierByName(hidden_modifiers[i])	
		end
		
		local ability_table = {}
		local item_table = {}
		ability_table[1] = "shredder_chakram"	-- crashes
		ability_table[2] = "shredder_chakram_2"	-- crashes
		
		item_table[1] = "item_tpscroll" 		-- preventing abuse
		item_table[2] = "item_travel_boots" 	-- preventing abuse
		item_table[3] = "item_travel_boots_2" 	-- preventing abuse
		
		-- Creating copy of the target hero
		local copy = CreateUnitByName(target_name, target_origin, true, caster, nil, caster_team) -- handle hUnitOwner MUST be nil, else it will crash the game.
		copy:SetPlayerID(playerID)
		copy:SetControllableByPlayer(playerID, true)
		copy:SetOwner(caster:GetOwner())
		FindClearSpaceForUnit(copy, target_origin, false)
		
		-- Levelling up the Copy of the hero
		for i=1,target_level-1 do
			copy:HeroLevelUp(false) -- false because we don't want to see level up effects
		end

		-- Recreate the items of the original, disabling some items, not ignoring items in backpack
		local disable_item = {}
		for item_slot=0,8 do
			local item = target:GetItemInSlot(item_slot)
			if item then
				local item_name = item:GetName()
				local new_item = CreateItem(item_name, copy, copy)
				local new_item_name = new_item:GetName()
				disable_item[item_slot+1] = 0
				for i=1, #item_table do
					if new_item_name == item_table[i] then
						--print("Disabling "..new_item_name)
						disable_item[item_slot+1] = 1
					end
				end
				if disable_item[item_slot+1] == 0 then
					copy:AddItem(new_item)
				end
			end
		end
		
		-- Enabling and disabling abilities on the Copy/Clone
		copy:SetAbilityPoints(0)
		local disable_ability = {}
		for ability_slot=0,target_ability_count-1 do
			local ability = target:GetAbilityByIndex(ability_slot)
			if ability then
				local ability_level = ability:GetLevel()
				local ability_name = ability:GetAbilityName()
				local copy_ability = copy:FindAbilityByName(ability_name)
				local copy_ability_name = copy_ability:GetAbilityName()
				disable_ability[ability_slot+1] = 0
				for i=1, #ability_table do
					if copy_ability_name == ability_table[i] then
						--print("Disabling "..copy_ability_name)
						disable_ability[ability_slot+1] = 1
					end
				end
				if disable_ability[ability_slot+1] == 0 then
					copy_ability:SetLevel(ability_level)
				end
			end
		end

		-- Setting health and mana to be the same as the original(target) hero at the moment of casting
		copy:SetHealth(target_HP)
		copy:SetMana(target_MP)
		-- Preventing dropping and selling items in inventory
		copy:SetHasInventory(false)
		copy:SetCanSellItems(false)
		-- Disabling bounties because copy can die (even if its invulnerable it can still die: suicide (bloodstone) or axe's cut from above/culling blade)
		copy:SetMaximumGoldBounty(0)
		copy:SetMinimumGoldBounty(0)
		copy:SetDeathXP(0)
		-- Preventing copy hero from respawning (IMPORTANT)
		copy:SetRespawnsDisabled(true)
		-- Storing the information about the original (IMPORTANT for placing the original at the position of the copy, for OnEntityKilled, for OnPlayerLevelUp, for OnHeroInGame)
		copy.original = target
		return copy
	else
		print("target or caster are nil values.")
		return nil
	end
end

--[[ This function interrupts, hides the hero and disables all his passives and auras; If he is not alive it revives him first;
	This function is meant to be used on heroes that will not be unhidden afterwards.
	Used in some abilities ...
]]
function HideTheCopyPermanently(copy)
	if copy then
		-- Effects and auras that are visual while hidden - Special cases
		local hidden_modifiers = {
		"modifier_custom_arcana",												-- Custom Arcana
		"modifier_drow_ranger_trueshot",										-- Precision Aura (built-in)
		"modifier_drow_ranger_trueshot_aura",									-- Precision Aura (built-in)
		"modifier_drow_ranger_trueshot_global",									-- Precision Aura (built-in)
		"modifier_black_king_bar_immune",										-- Black King Bar (built-in)
		"modifier_item_ring_of_basilius_aura",									-- Ring of Basilius Aura
		"modifier_item_ring_of_aquila_aura",									-- Ring of Aquila Aura
		"modifier_item_mekansm_aura",											-- Mekansm Aura
		"modifier_item_ancient_janggo",											-- Drums of Endurance Aura
		"modifier_item_vladmir",												-- Vladmir's Aura
		"modifier_item_guardian_greaves",										-- Guardian Greaves Aura
		"modifier_item_assault_positive_aura",									-- Assault Cuirass Positive Aura
		"modifier_item_assault_positive_buildings_aura",						-- Assault Cuirass Positive Aura (buildings)
		"modifier_item_assault_negative_armor_aura",							-- Assault Cuirass Negative Aura
		"modifier_item_pipe",													-- Pipe of Insight Aura
		"modifier_item_headdress",												-- Headdress Aura
		"modifier_item_radiance",												-- Radiance Aura
		"modifier_item_crimson_guard_extra",									-- Crimson Guard Active
		"modifier_item_shivas_guard"											-- Shiva's Guard Aura
		}
		if copy:IsAlive() then
			copy:Stop()
			copy:Interrupt()
			copy.died = false
		else
			-- MakeIllusion() and RemoveSelf() are not good here because:
			-- Illusions can't deal damage over time (poisons etc.) -> automatic crash to desktop if illusions have DoT
			-- Removed units cant deal damage over time -> automatic crash to desktop if DoT is still active after removing the unit
			copy:RespawnUnit()
			copy.died = true
		end
		copy:AddNoDraw() 	-- Hiding the copy visually only (base skeleton)
		HideWearables(copy)	-- Hiding hats/wearables if some are still visible
		-- Remove most buffs and most debuffs
		SuperStrongDispel(copy, true, true)
		-- Remove passive modifiers with Custom Break
		CustomPassiveBreak(copy, 100)
		-- Cycle through hidden modifiers and remove them (Death, SuperStrongDispel and CustomPassiveBreak remove most modifiers but we need to make sure for remaining modifiers)
		for i=1, #hidden_modifiers do
			copy:RemoveModifierByName(hidden_modifiers[i])	
		end
		-- Moving the copy to the corner of the map (Hiding him for sure)
		local corner = Vector(0,0,0)
		if GetMapName() == "smaller_map" then
			corner = corner_of_that_smaller_map
		else
			corner = Vector(7500,-7200,-322)
		end
		copy:SetAbsOrigin(corner)
	else
		print("Copy is nil!")
	end
end

--[[ This function reveals the original hero (that was hidden) at certain location;
	This function re-enables abilities and auras (some, not all! it's intentional!) that were disabled in HideAndCopyHero function
	Used in some abilities ...
]]
function UnhideOriginalOnLocation(original, location)
	if original then
		original:RemoveNoDraw()	-- Unhiding the hero (only visually)
		if location~= nil then
			original:SetAbsOrigin(location) -- Moving the original to location instantly
		else
			print("Original is revealed at the location where it was hidden")
		end
		FindClearSpaceForUnit(original, original:GetAbsOrigin(), false)
		
		-- List of auras and abilities with visual effect
		local hidden_abilities = {
		"custom_arcana_model",
		"hidden_ability_not_affected_with_custom_passive_break"
		}
		local passive_modifiers = {
		"modifier_custom_arcana",
		"modifier_not_removed_with_super_strong_dispel_or_custom_passive_break"
		}
		-- Re-enabling removed passive modifiers with CustomPassiveBreak
		CustomPassiveBreak(original, 0.1)
		-- Cycle through remaining hidden abilities found on the hero, then re-activate them
		for i=1, #hidden_abilities do
			local ability = original:FindAbilityByName(hidden_abilities[i])
			if ability then
				if ability:GetLevel() ~= 0 then
					ability:ApplyDataDrivenModifier(original, original, passive_modifiers[i], {})
				end
			end
		end
	else
		print("Hero that needed to be unhidden is nil.")
	end
end

--[[ This function disables passive modifiers from custom (datadriven) abilities for the duration.
	Attention: This only works with abilities that have 1 passive modifier and if the order of strings in tables is not random.
	If Duration is 100, passives are disabled forever / until death or removal of the hero.
	Used in HideAndCopyHero, HideTheCopyPermanently, UnhideOriginalOnLocation ...
]]
function CustomPassiveBreak(unit, duration)
	-- List of custom abilities with passive modifiers
	local abilities_with_passives = {
	"ability1",
	"ability2"
	}
	local passive_modifiers = {
	"modifier1",
	"modifier2"
	}
	if unit and duration then
		for i=1, #passive_modifiers do
			unit:RemoveModifierByName(passive_modifiers[i])
		end
		
		unit.custom_already_breaked = true
		
		if duration ~= 100 then
			Timers:CreateTimer(duration, function()
				for i=1, #abilities_with_passives do
					local ability = unit:FindAbilityByName(abilities_with_passives[i])
					if ability then
						if ability:GetLevel() ~= 0 then
							ability:ApplyDataDrivenModifier(unit, unit, passive_modifiers[i], {})
						end
					end
				end
				unit.custom_already_breaked = false
			end)
		end
	end
end

--[[ This function disables inventory and removes item passives.
]]
function CustomItemDisable(caster, unit)
	local passive_item_modifiers_exceptions ={
	"modifier_item_empty_bottle",
	"modifier_item_observer_ward",
	"modifier_item_tome_of_knowledge",
	"modifier_item_sentry_ward",
	"modifier_item_blink_dagger",
	"modifier_item_armlet_unholy_strength"
	}
	if unit then
		for item_slot=0,8 do
			local item = unit:GetItemInSlot(item_slot)
			if item then
				local item_owner = item:GetPurchaser()
				local unit_owner = unit:GetOwner()
				local caster_owner = caster:GetOwner()
				if item_owner == unit then
					item:SetPurchaser(caster)
				elseif item_owner == unit_owner then
					item:SetPurchaser(caster_owner)
				end
			end
		end
		-- Find All modifiers (ALL buffs, debuffs, passives)
		local all_modifiers = unit:FindAllModifiers()
		-- Iterate through each one and check their ability
		for _, modifier in pairs(all_modifiers) do
			local modifier_ability = modifier:GetAbility()			-- can be nil
			if modifier_ability then
				if modifier_ability:IsItem() then
					-- Get the duration of the item modifier
					local item_modifier_duration = modifier:GetDuration()
					-- If the modifier duration is -1 (infinite duration) there is a chance that this is a passive modifier
					if item_modifier_duration == -1 then
						-- Get the name of the item modifier
						local item_modifier_name = modifier:GetName()
						-- Initializing handle: safe_to_remove
						modifier.safe_to_remove = true
						for i=1, #passive_item_modifiers_exceptions do
							if item_modifier_name == passive_item_modifiers_exceptions[i] then
								modifier.safe_to_remove = false
							end
						end
						if modifier.safe_to_remove == true then
							unit:RemoveModifierByName(item_modifier_name)
						end
					end
				end
			end
		end
		
		-- Preventing dropping and selling items in inventory
		unit:SetHasInventory(false)
		unit:SetCanSellItems(false)
	else
		print("unit is nil!")
	end
end

--[[ This function enables inventory and item passives if they were disabled with CustomItemDisable
]]
function CustomItemEnable(caster, unit)
	if unit then
		for item_slot=0,8 do
			local item = unit:GetItemInSlot(item_slot)
			if item then
				local item_owner = item:GetPurchaser()
				local unit_owner = unit:GetOwner()
				local caster_owner = caster:GetOwner()
				if item_owner == caster then
					item:SetPurchaser(unit)
				elseif item_owner == caster_owner then
					item:SetPurchaser(unit_owner)
				end
			end
		end
		-- Enable dropping and selling items back
		unit:SetHasInventory(true)
		unit:SetCanSellItems(true)
		-- To reset unit's items and their passive modifiers: add an item and remove it
		local new_item = CreateItem("item_magic_wand", unit, unit)
		unit:AddItem(new_item)
		new_item:RemoveSelf()
	else
		print("unit is nil!")
	end
end

--[[ This function applies strong dispel and removes almost all debuffs; 
	Can remove most buffs that are not removable with basic dispel;
	Can remove most debuffs that are not removable with strong dispel;
	Used in many abilities, HideAndCopyHero, HideTheCopyPermanently, ...
]]
function SuperStrongDispel(target, bCustomRemoveAllDebuffs, bCustomRemoveAllBuffs)
	if target then
		local BuffsCreatedThisFrameOnly = false
		local RemoveExceptions = false
		local RemoveStuns = false
		
		if bCustomRemoveAllDebuffs == true then
			
			RemoveStuns = true -- this ensures removing modifiers debuffs with "IsStunDebuff" "1"
			-- Ability debuffs:
			target:RemoveModifierByName("modifier_venomancer_poison_sting")			-- pierces BKB, doesn't get removed with BKB
			target:RemoveModifierByName("modifier_bane_nightmare_invulnerable") 	-- invulnerable type
			-- Item debuffs:
			target:RemoveModifierByName("modifier_item_skadi_slow")					-- pierces BKB, doesn't get removed with BKB
			target:RemoveModifierByName("modifier_heavens_halberd_debuff")			-- doesn't pierce BKB, doesn't get removed with BKB
			target:RemoveModifierByName("modifier_sheepstick_debuff")				-- doesn't pierce BKB, doesn't get removed with BKB
			target:RemoveModifierByName("modifier_silver_edge_debuff")				-- doesn't pierce BKB, doesn't get removed with BKB
		end
		
		if bCustomRemoveAllBuffs == true then
			-- List of undispellable buffs that are safe to remove without making errors, crashes etc.
			local undispellable_with_normal_dispel_buffs = {
				"modifier_alchemist_chemical_rage",
				"modifier_custom_blade_fury_buff",
				"modifier_item_aeon_disk_buff",
				"modifier_item_blade_mail_reflect",
				"modifier_item_phase_boots_active",
				"modifier_item_hood_of_defiance_barrier",
				"modifier_item_pipe_barrier",
				"modifier_item_crimson_guard_extra",
				"modifier_black_king_bar_immune"
				-- Death Pact
			}
			
			for i=1, #undispellable_with_normal_dispel_buffs do
				target:RemoveModifierByName(undispellable_with_normal_dispel_buffs[i])	
			end
		end
		
		target:Purge(bCustomRemoveAllBuffs, bCustomRemoveAllDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)
	else
		print("Target for Super Strong Dispel is nil.")
	end
end

-- Disruptor Glimpse Position Tracker
function glimpse_position_tracker()
	local current_time = GameRules:GetGameTime()
	
	for i, hero in pairs(GameRules.Heroes) do
		if not hero.positions[math.floor(current_time)] then
			hero.positions[math.floor(current_time)] = hero:GetAbsOrigin()
		end

		for t, pos in pairs(hero.positions) do
			if (current_time-t) > 9 then
				hero.positions[t] = nil
			else -- the rest of the times in the table are <= 4.
				break
			end
		end
	end
end

-- Finding units in a trapezoid shape area
function FindUnitsinTrapezoid(team_number, direction, start_position, cache_unit, start_radius, end_radius, distance, target_team, target_type, target_flags, order, cache)
	local circle = FindUnitsInRadius(team_number, start_position, cache_unit, distance+end_radius, target_team, target_type, target_flags, order, cache)
	local direction = direction
	direction.z = 0.0
	direction = direction:Normalized()
	local perpendicular_direction = Vector(direction.y, -direction.x, 0.0)
	local end_position = start_position + direction*distance
	
	-- Trapezoid vertexes
	local vertex1 = start_position - perpendicular_direction*start_radius
	local vertex2 = start_position + perpendicular_direction*start_radius
	local vertex3 = end_position - perpendicular_direction*end_radius
	local vertex4 = end_position + perpendicular_direction*end_radius
	
	-- Trapezoid sides (vectors)
	local vector1 = vertex2 - vertex1	-- vector12
	local vector2 = vertex4 - vertex2	-- vector24
	local vector3 = vertex3 - vertex4	-- vector43
	local vector4 = vertex1 - vertex3	-- vector31
	
	local unit_table = {}
	
	for _, unit in pairs(circle) do
		if unit then
			local unit_location = unit:GetAbsOrigin()
			local vector1p = unit_location - vertex1
			local vector2p = unit_location - vertex2
			local vector3p = unit_location - vertex4
			local vector4p = unit_location - vertex3
			local cross1 = vector1.x * vector1p.y - vector1.y * vector1p.x
			local cross2 = vector2.x * vector2p.y - vector2.y * vector2p.x
			local cross3 = vector3.x * vector3p.y - vector3.y * vector3p.x
			local cross4 = vector4.x * vector4p.y - vector4.y * vector4p.x
			if (cross1 > 0 and cross2 > 0 and cross3 > 0 and cross4 > 0) or (cross1 < 0 and cross2 < 0 and cross3 < 0 and cross4 < 0) then
				table.insert(unit_table, unit)
			end
		end
    end
	return unit_table
end

-- Custom Cleave function
-- Required arguments: main_damage, damage_percent, cleave_origin, start_radius, end_radius, distance;
-- If start_radius is 0, it will behave like the old cleave(pre 7.00);
function CustomCleaveAttack(attacker, target, ability, main_damage, damage_percent, cleave_origin, start_radius, end_radius, distance, particle_cleave, particle_hit)
	if attacker == nil then
		print("Attacker/Cleaver is nil!")
		return nil
	end
	local team_number = attacker:GetTeamNumber()
	local direction = attacker:GetForwardVector()
	local cache_unit = nil
	local order = 0
	local cache = false
	
	local damage_table = {}
	damage_table.attacker = attacker
	
	local target_team
	local target_type
	local target_flags
	
	if ability then
		target_team = ability:GetAbilityTargetTeam()
		target_type = ability:GetAbilityTargetType()
		target_flags = ability:GetAbilityTargetFlags()
		damage_table.damage_type = ability:GetAbilityDamageType()
		damage_table.ability = ability
	else
		target_team = DOTA_UNIT_TARGET_TEAM_BOTH
		target_type = bit.bor(DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_HERO)
		target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
		damage_table.damage_type = DAMAGE_TYPE_PHYSICAL
	end
	
	if target == nil then
		print("Attacked target is nil!")
		return nil
	end
	
	if target:GetTeamNumber() == team_number then
		--print("Cleave doesn't work when attacking allies!")
		--return		-- Uncomment this if you don't want to cleave on allies
	end
	
	if target:IsTower() or target:IsBarracks() or target:IsBuilding() then
		--print("Cleave doesn't work when attacking buildings!")
		return
	end
	
	if target:IsOther() then
		--print("Cleave doesn't work when attacking ward-type units!")
		return
	end
	
	local affected_units = FindUnitsinTrapezoid(team_number, direction, cleave_origin, cache_unit, start_radius, end_radius, distance, target_team, target_type, target_flags, order, cache)
	
	-- Calculating damage and setting damage flags
	damage_table.damage = main_damage*damage_percent/100
	damage_table.damage_flags = bit.bor(DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR, DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL)
	
	for k, unit in pairs(affected_units) do
		if unit ~= target then
			damage_table.victim = unit
			ApplyDamage(damage_table)
		end
	end
	
	-- Main particle
	if particle_cleave then
		local cleave_pfx = ParticleManager:CreateParticle(particle_cleave, PATTACH_ABSORIGIN_FOLLOW, attacker)
		ParticleManager:SetParticleControl(cleave_pfx, 0, target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(cleave_pfx)
	end
	
	-- Hit particles
	if particle_hit then
		for _,unit in pairs(affected_units) do
			local cleave_hit_pfx = ParticleManager:CreateParticle(particle_hit, PATTACH_ABSORIGIN, unit)
			ParticleManager:SetParticleControl(cleave_hit_pfx, 0, unit:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(cleave_hit_pfx)
		end
	end
end