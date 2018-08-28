-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advanced physics/motion/collision of units.  See PhysicsReadme.txt for more information.
--require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
--require('libraries/projectiles')
-- This library can be used for starting customized animations on units from lua
--require('libraries/animations')
-- This library can be used for performing "Frankenstein" attachments on units
--require('libraries/attachments')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
require('libraries/notifications')
-- This library (by Noya) provides player selection inspection and management from server lua
require('libraries/selection')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')


--[[
  This function should be used to set up Async precache calls at the beginning of the gameplay.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).

  This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function friendly_fire_gamemode:PostLoadPrecache()

end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
]]
function friendly_fire_gamemode:OnFirstPlayerLoaded()

end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function friendly_fire_gamemode:OnAllPlayersLoaded()
	
	-- Find all buildings on the map
	local buildings = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0,0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)

	-- Iterate through each one
	for _, building in pairs(buildings) do
		local building_name = building:GetName()
		-- Check if its a fountain
		if string.find(building_name, "fountain") then
			-- Add abilities to fountains
			building:AddAbility("custom_building_true_strike")
			local fountain_true_strike = building:FindAbilityByName("custom_building_true_strike")
			fountain_true_strike:SetLevel(1)
			building:AddAbility("custom_fountain_true_sight")
			local fountain_true_sight = building:FindAbilityByName("custom_fountain_true_sight")
			fountain_true_sight:SetLevel(1)
		end
		-- Check if its a tower
		if string.find(building_name, "tower") then
			-- Add abilities to towers
			building:AddAbility("custom_building_true_strike")
			local towers_true_strike = building:FindAbilityByName("custom_building_true_strike")
			towers_true_strike:SetLevel(1)
		end
	end
end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.
  The hero parameter is the hero entity that just spawned in
]]
function friendly_fire_gamemode:OnHeroInGame(hero)
	
	-- Innate abilities (this is applied to custom created heroes/illusions too)
	InitializeInnateAbilities(hero)
	
	Timers:CreateTimer(0.5, function()
		local playerID = hero:GetPlayerID()	-- never nil (-1 by default), needs delay 1 or more frames
		
		GameRules.Heroes[playerID] = hero
		if hero.positions == nil then
			hero.positions = {}
		end
		
		if PlayerResource:IsFakeClient(playerID) then
			-- This is happening only for bots
			-- Set starting gold for bots
			hero:SetGold(NORMAL_START_GOLD, false)
		else
			-- Set some hero stuff on first spawn or on every spawn (custom or not)
			if PlayerResource.PlayerData[playerID].already_set_hero == true then
				-- This is happening only when players create new heroes with custom hero-create spells:
				-- Custom Illusion spells
			else
				-- This is happening for players when their first hero spawn for the first time
				
				-- Make heroes briefly visible on spawn (to prevent bad fog interactions)
				hero:MakeVisibleToTeam(DOTA_TEAM_GOODGUYS, 0.5)
				hero:MakeVisibleToTeam(DOTA_TEAM_BADGUYS, 0.5)
				
				-- Set the starting gold for the player's hero
				if PlayerResource:HasRandomed(playerID) then
					PlayerResource:ModifyGold(playerID, RANDOM_START_GOLD-600, false, 0)
				else
					-- If the NORMAL_START_GOLD is smaller then 600, don't use this line of code
					PlayerResource:ModifyGold(playerID, NORMAL_START_GOLD-600, false, 0)
				end
				
				-- This ensures that this will not happen again if some other hero spawns for the first time during the game
				PlayerResource.PlayerData[playerID].already_set_hero = true
				print("Hero "..hero:GetUnitName().." set for player with ID "..playerID)
			end
		end
	end)
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function friendly_fire_gamemode:OnGameInProgress()

end

-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function friendly_fire_gamemode:InitGameMode()
	-- Setup rules
	GameRules:SetHeroRespawnEnabled(ENABLE_HERO_RESPAWN)
	GameRules:SetUseUniversalShopMode(UNIVERSAL_SHOP_MODE)
	GameRules:SetSameHeroSelectionEnabled(ALLOW_SAME_HERO_SELECTION)
	GameRules:SetHeroSelectionTime(HERO_SELECTION_TIME)
	GameRules:SetPreGameTime(PRE_GAME_TIME)
	GameRules:SetPostGameTime(POST_GAME_TIME)
	GameRules:SetShowcaseTime(SHOWCASE_TIME)
	GameRules:SetStrategyTime(STRATEGY_TIME)
	GameRules:SetTreeRegrowTime(TREE_REGROW_TIME)
	GameRules:SetUseCustomHeroXPValues(USE_CUSTOM_XP_VALUES)
	GameRules:SetGoldPerTick(GOLD_PER_TICK)
	GameRules:SetGoldTickTime(GOLD_TICK_TIME)
	--GameRules:SetRuneSpawnTime(RUNE_SPAWN_TIME)
	GameRules:SetUseBaseGoldBountyOnHeroes(USE_STANDARD_HERO_GOLD_BOUNTY)
	GameRules:SetHeroMinimapIconScale(MINIMAP_ICON_SIZE)
	GameRules:SetCreepMinimapIconScale(MINIMAP_CREEP_ICON_SIZE)
	GameRules:SetRuneMinimapIconScale(MINIMAP_RUNE_ICON_SIZE)	
  
	GameRules:SetFirstBloodActive(ENABLE_FIRST_BLOOD)
	GameRules:SetHideKillMessageHeaders(HIDE_KILL_BANNERS)
	
	-- This is multiteam configuration stuff
	if USE_AUTOMATIC_PLAYERS_PER_TEAM then
		local num = math.floor(10 / MAX_NUMBER_OF_TEAMS)
		local count = 0
		for team,number in pairs(TEAM_COLORS) do
			if count >= MAX_NUMBER_OF_TEAMS then
				GameRules:SetCustomGameTeamMaxPlayers(team, 0)
			else
				GameRules:SetCustomGameTeamMaxPlayers(team, num)
			end
			count = count + 1
		end
	else
		local count = 0
		for team,number in pairs(CUSTOM_TEAM_PLAYER_COUNT) do
			if count >= MAX_NUMBER_OF_TEAMS then
				GameRules:SetCustomGameTeamMaxPlayers(team, 0)
			else
				GameRules:SetCustomGameTeamMaxPlayers(team, number)
			end
			count = count + 1
		end
	end

	if USE_CUSTOM_TEAM_COLORS then
		for team,color in pairs(TEAM_COLORS) do
			SetTeamCustomHealthbarColor(team, color[1], color[2], color[3])
		end
	end
	
	-- Event Hooks
	ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(friendly_fire_gamemode, 'OnPlayerLevelUp'), self)
	ListenToGameEvent('dota_ability_channel_finished', Dynamic_Wrap(friendly_fire_gamemode, 'OnAbilityChannelFinished'), self)
	ListenToGameEvent('dota_player_learned_ability', Dynamic_Wrap(friendly_fire_gamemode, 'OnPlayerLearnedAbility'), self)
	ListenToGameEvent('entity_killed', Dynamic_Wrap(friendly_fire_gamemode, 'OnEntityKilled'), self)
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(friendly_fire_gamemode, 'OnConnectFull'), self)
	ListenToGameEvent('player_disconnect', Dynamic_Wrap(friendly_fire_gamemode, 'OnDisconnect'), self)
	ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(friendly_fire_gamemode, 'OnItemPurchased'), self)
	ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(friendly_fire_gamemode, 'OnItemPickedUp'), self)
	ListenToGameEvent('last_hit', Dynamic_Wrap(friendly_fire_gamemode, 'OnLastHit'), self)
	ListenToGameEvent('dota_non_player_used_ability', Dynamic_Wrap(friendly_fire_gamemode, 'OnNonPlayerUsedAbility'), self)
	ListenToGameEvent('player_changename', Dynamic_Wrap(friendly_fire_gamemode, 'OnPlayerChangedName'), self)
	ListenToGameEvent('dota_rune_activated_server', Dynamic_Wrap(friendly_fire_gamemode, 'OnRuneActivated'), self)
	ListenToGameEvent('dota_player_take_tower_damage', Dynamic_Wrap(friendly_fire_gamemode, 'OnPlayerTakeTowerDamage'), self)
	ListenToGameEvent('tree_cut', Dynamic_Wrap(friendly_fire_gamemode, 'OnTreeCut'), self)
	ListenToGameEvent('entity_hurt', Dynamic_Wrap(friendly_fire_gamemode, 'OnEntityHurt'), self)
	ListenToGameEvent('player_connect', Dynamic_Wrap(friendly_fire_gamemode, 'PlayerConnect'), self)
	ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(friendly_fire_gamemode, 'OnAbilityUsed'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(friendly_fire_gamemode, 'OnGameRulesStateChange'), self)
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(friendly_fire_gamemode, 'OnNPCSpawned'), self)
	ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(friendly_fire_gamemode, 'OnPlayerPickHero'), self)
	ListenToGameEvent('dota_team_kill_credit', Dynamic_Wrap(friendly_fire_gamemode, 'OnTeamKillCredit'), self)
	ListenToGameEvent("player_reconnected", Dynamic_Wrap(friendly_fire_gamemode, 'OnPlayerReconnect'), self)
	ListenToGameEvent("player_chat", Dynamic_Wrap(friendly_fire_gamemode, 'OnPlayerChat'), self)

	ListenToGameEvent("dota_illusions_created", Dynamic_Wrap(friendly_fire_gamemode, 'OnIllusionsCreated'), self)
	ListenToGameEvent("dota_item_combined", Dynamic_Wrap(friendly_fire_gamemode, 'OnItemCombined'), self)
	ListenToGameEvent("dota_player_begin_cast", Dynamic_Wrap(friendly_fire_gamemode, 'OnAbilityCastBegins'), self)
	ListenToGameEvent("dota_tower_kill", Dynamic_Wrap(friendly_fire_gamemode, 'OnTowerKill'), self)
	ListenToGameEvent("dota_player_selected_custom_team", Dynamic_Wrap(friendly_fire_gamemode, 'OnPlayerSelectedCustomTeam'), self)
	ListenToGameEvent("dota_npc_goal_reached", Dynamic_Wrap(friendly_fire_gamemode, 'OnNPCGoalReached'), self)
	
	--ListenToGameEvent("dota_tutorial_shop_toggled", Dynamic_Wrap(friendly_fire_gamemode, 'OnShopToggled'), self)
	--ListenToGameEvent('player_spawn', Dynamic_Wrap(friendly_fire_gamemode, 'OnPlayerSpawn'), self)
	--ListenToGameEvent('dota_unit_event', Dynamic_Wrap(friendly_fire_gamemode, 'OnDotaUnitEvent'), self)
	--ListenToGameEvent('nommed_tree', Dynamic_Wrap(friendly_fire_gamemode, 'OnPlayerAteTree'), self)
	--ListenToGameEvent('player_completed_game', Dynamic_Wrap(friendly_fire_gamemode, 'OnPlayerCompletedGame'), self)
	--ListenToGameEvent('dota_match_done', Dynamic_Wrap(friendly_fire_gamemode, 'OnDotaMatchDone'), self)
	--ListenToGameEvent('dota_combatlog', Dynamic_Wrap(friendly_fire_gamemode, 'OnCombatLogEvent'), self)
	--ListenToGameEvent('dota_player_killed', Dynamic_Wrap(friendly_fire_gamemode, 'OnPlayerKilled'), self)
	--ListenToGameEvent('player_team', Dynamic_Wrap(friendly_fire_gamemode, 'OnPlayerTeam'), self)

	-- Change random seed
	local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
	math.randomseed(tonumber(timeTxt))

	-- Initialized tables for tracking state
	self.bSeenWaitForPlayers = false
	
	local gamemode = GameRules:GetGameModeEntity()
	
	-- Setting the Order filter to start catching events
	gamemode:SetExecuteOrderFilter(Dynamic_Wrap(friendly_fire_gamemode, "OrderFilter"), self)
  
	-- Setting the Damage filter
	gamemode:SetDamageFilter(Dynamic_Wrap(friendly_fire_gamemode, "DamageFilter"), self)
  
	-- Lua Modifiers
	LinkLuaModifier("modifier_always_deniable", "libraries/modifiers/modifier_always_deniable", LUA_MODIFIER_MOTION_NONE)
	
	-- Initialize stuff for Disruptor Glimpse
	GameRules.Heroes = {}
	Timers:CreateTimer(function()
		glimpse_position_tracker() 
		return .01
	end)
	
	print("Friendly Fire game mode initialized.")
end

mode = nil
-- This function is called as the first player loads and sets up the game mode parameters
function friendly_fire_gamemode:CaptureGameMode()
	if mode == nil then
		-- Set GameMode parameters
		mode = GameRules:GetGameModeEntity()
		mode:SetRecommendedItemsDisabled(RECOMMENDED_BUILDS_DISABLED)
		mode:SetCameraDistanceOverride(CAMERA_DISTANCE_OVERRIDE)
		mode:SetCustomBuybackCostEnabled(CUSTOM_BUYBACK_COST_ENABLED)
		mode:SetCustomBuybackCooldownEnabled(CUSTOM_BUYBACK_COOLDOWN_ENABLED)
		mode:SetBuybackEnabled(BUYBACK_ENABLED)
		mode:SetTopBarTeamValuesOverride(USE_CUSTOM_TOP_BAR_VALUES)
		mode:SetTopBarTeamValuesVisible(TOP_BAR_VISIBLE)
		mode:SetUseCustomHeroLevels(USE_CUSTOM_HERO_LEVELS)
		mode:SetCustomXPRequiredToReachNextLevel(XP_PER_LEVEL_TABLE)

		mode:SetBotThinkingEnabled(USE_STANDARD_DOTA_BOT_THINKING)
		mode:SetTowerBackdoorProtectionEnabled(ENABLE_TOWER_BACKDOOR_PROTECTION)

		mode:SetFogOfWarDisabled(DISABLE_FOG_OF_WAR_ENTIRELY)
		mode:SetGoldSoundDisabled(DISABLE_GOLD_SOUNDS)
		mode:SetRemoveIllusionsOnDeath(REMOVE_ILLUSIONS_ON_DEATH)

		mode:SetAlwaysShowPlayerInventory(SHOW_ONLY_PLAYER_INVENTORY)
		mode:SetAnnouncerDisabled(DISABLE_ANNOUNCER)
		if FORCE_PICKED_HERO ~= nil then
			mode:SetCustomGameForceHero(FORCE_PICKED_HERO)
		end
		mode:SetFixedRespawnTime(FIXED_RESPAWN_TIME)
		mode:SetFountainConstantManaRegen(FOUNTAIN_CONSTANT_MANA_REGEN)
		mode:SetFountainPercentageHealthRegen(FOUNTAIN_PERCENTAGE_HEALTH_REGEN)
		mode:SetFountainPercentageManaRegen(FOUNTAIN_PERCENTAGE_MANA_REGEN)
		mode:SetLoseGoldOnDeath(LOSE_GOLD_ON_DEATH)
		mode:SetMaximumAttackSpeed(MAXIMUM_ATTACK_SPEED)
		mode:SetMinimumAttackSpeed(MINIMUM_ATTACK_SPEED)
		mode:SetStashPurchasingDisabled(DISABLE_STASH_PURCHASING)

		--for rune, spawn in pairs(ENABLED_RUNES) do
			--mode:SetRuneEnabled(rune, spawn)
		--end
		
		--mode:SetPowerRuneSpawnInterval(RUNE_SPAWN_TIME)
		--mode:SetBountyRuneSpawnInterval(BOUNTY_RUNE_TIME)
		mode:SetUseDefaultDOTARuneSpawnLogic(true)

		mode:SetUnseenFogOfWarEnabled(USE_UNSEEN_FOG_OF_WAR)
		
		mode:SetDaynightCycleDisabled(DISABLE_DAY_NIGHT_CYCLE)
		mode:SetKillingSpreeAnnouncerDisabled(DISABLE_KILLING_SPREE_ANNOUNCER)
		mode:SetStickyItemDisabled(DISABLE_STICKY_ITEM)

		self:OnFirstPlayerLoaded()
  end 
end

-- Order filter function
function friendly_fire_gamemode:OrderFilter(event)
	--PrintTable(event)
	
	local order = event.order_type
	local units = event.units
	
	if order == DOTA_UNIT_ORDER_HOLD_POSITION or order == DOTA_UNIT_ORDER_STOP then
		local caster = EntIndexToHScript(units["0"])
		if caster.original_team ~= nil then
			if caster.original_team == DOTA_TEAM_GOODGUYS then
				caster:SetTeam(DOTA_TEAM_GOODGUYS)
			else
				caster:SetTeam(DOTA_TEAM_BADGUYS)
			end
		end
	end
	
	if order == DOTA_UNIT_ORDER_CAST_POSITION or order == DOTA_UNIT_ORDER_CAST_NO_TARGET then
		local abilityIndex = event.entindex_ability
		local ability = EntIndexToHScript(abilityIndex)
		local caster = EntIndexToHScript(units["0"])
		local ability_name = ability:GetAbilityName()
		local exceptions_abilities = {
				"abaddon_borrowed_time",
				"alchemist_acid_spray",
				"alchemist_acid_spray_ff",
				"alchemist_chemical_rage",
				"alchemist_unstable_concoction",
				"ancient_apparition_chilling_touch",
				"ancient_apparition_ice_blast",
				"ancient_apparition_ice_vortex",
				"antimage_blink",
				"antimage_spell_shield",
				"arc_warden_magnetic_field",
				"arc_warden_tempest_double",
				"bane_nightmare_end",
				"batrider_firefly",
				"beastmaster_call_of_the_wild",
				"bloodseeker_blood_bath",
				"bounty_hunter_wind_walk",
				"brewmaster_primal_split",
				"brewmaster_storm_wind_walk",
				"broodmother_insatiable_hunger",
				"broodmother_spin_web",
				"centaur_stampede",
				"chaos_knight_phantasm",
				"chen_hand_of_god",
				"clinkz_strafe",
				"clinkz_wind_walk",
				"dark_seer_wall_of_replica",
				"dark_willow_bramble_maze",
				"dark_willow_shadow_realm",
				"dark_willow_bedlam",
				"dark_willow_terrorize",
				"dazzle_shallow_grave",
				"dazzle_weave",
				"death_prophet_silence",
				"death_prophet_silence_ff",
				"death_prophet_exorcism",
				"disruptor_static_storm",
				"disruptor_static_storm_ff",
				"doom_bringer_scorched_earth",
				"dragon_knight_elder_dragon_form",
				"drow_ranger_trueshot",
				"earth_spirit_boulder_smash",
				"earth_spirit_rolling_boulder",
				"earth_spirit_stone_caller",
				"elder_titan_ancestral_spirit",
				"elder_titan_return_spirit",
				"enchantress_natures_attendants",
				"enigma_midnight_pulse",
				"enigma_midnight_pulse_ff",
				"faceless_void_chronosphere",
				"faceless_void_time_walk",
				"faceless_void_time_dilation",
				"furion_force_of_nature",
				"furion_sprout",
				"furion_teleportation",
				"furion_wrath_of_nature",
				"gyrocopter_rocket_barrage",
				"gyrocopter_flak_cannon",
				"juggernaut_blade_fury",
				"juggernaut_blade_fury_ff",
				"juggernaut_healing_ward",
				"keeper_of_the_light_spirit_form",
				"kunkka_return",
				"kunkka_ghostship",
				"leshrac_diabolic_edict",
				"leshrac_pulse_nova",
				"life_stealer_rage",
				"lone_druid_rabid",
				"lone_druid_spirit_bear",
				"lone_druid_savage_roar_bear",
				"lone_druid_true_form",
				"lone_druid_true_form_battle_cry",
				"lone_druid_true_form_druid",
				"lycan_shapeshift",
				"lycan_summon_wolves",
				"medusa_mana_shield",
				"mirana_arrow",
				"mirana_arrow_ff",
				"mirana_invis",
				"mirana_leap",
				"mirana_starfall",
				"monkey_king_wukongs_command",
				"monkey_king_tree_dance",
				"morphling_morph",
				"morphling_morph_agi",
				"morphling_morph_str",
				"morphling_morph_replicate",
				"naga_siren_mirror_image",
				"necrolyte_death_pulse",
				"necrolyte_sadist",
				"necrolyte_sadist_stop",
				"night_stalker_darkness",
				"night_stalker_hunter_in_the_night",
				"nyx_assassin_vendetta",
				"omniknight_guardian_angel",
				"omniknight_guardian_angel_ff",
				"pangolier_gyroshell_stop",
				"phantom_lancer_doppelwalk",
				"phoenix_fire_spirits",
				"phoenix_sun_ray",
				"puck_phase_shift",
				--"pudge_meat_hook",
				"pudge_rot",
				"pudge_rot_ff",
				"pugna_nether_blast",
				"pugna_nether_ward",
				"queenofpain_blink",
				"rattletrap_battery_assault",
				"rattletrap_hookshot",
				"riki_tricks_of_the_trade",
				"rubick_null_field",
				"rubick_telekinesis",
				--"sandking_burrowstrike",
				"sandking_sand_storm",
				"sandking_epicenter",
				"shadow_shaman_mass_serpent_ward",
				"skeleton_king_mortal_strike",
				"slardar_sprint",
				"slark_shadow_dance",
				"spirit_breaker_empowering_haste",
				"storm_spirit_static_remnant",
				"sven_gods_strength",
				"sven_warcry",
				"templar_assassin_meld",
				"templar_assassin_refraction",
				"terrorblade_conjure_image",
				"terrorblade_metamorphosis",
				"troll_warlord_battle_trance",
				"troll_warlord_berserkers_rage",
				"tusk_frozen_sigil",
				"undying_flesh_golem",
				"ursa_enrage",
				"ursa_overpower",
				"venomancer_plague_ward",
				"visage_summon_familiars",
				"viper_nethertoxin",
				"viper_nethertoxin_ff",
				"weaver_the_swarm",
				"weaver_time_lapse",
				"windrunner_windrun",
				"winter_wyvern_arctic_burn",
				"wisp_overcharge",
				"wisp_relocate",
				"wisp_spirits",
				"witch_doctor_death_ward",
				"witch_doctor_voodoo_restoration",
				"item_blink",
				"item_faerie_fire",
				"item_branches",
				"item_cheese",
				"item_magic_stick",
				"item_magic_wand",
				"item_ghost",
				"item_enchanted_mango",
				"item_dust",
				"item_bottle",
				"item_ward_observer",
				"item_ward_sentry",
				"item_courier",
				"item_tpscroll",
				"item_phase_boots",
				"item_power_treads",
				"item_mekansm",
				"item_buckler",
				"item_ring_of_basilius",
				"item_pipe",
				"item_necronomicon",
				"item_necronomicon_2",
				"item_necronomicon_3",
				"item_refresher",
				"item_black_king_bar",
				"item_shivas_guard",
				"item_bloodstone",
				"item_meteor_hammer",
				"item_refresher_shard",
				"item_crimson_guard",
				"item_blade_mail",
				"item_hood_of_defiance",
				--"item_radiance",
				"item_butterfly",
				"item_manta",
				"item_armlet",
				"item_invis_sword",
				"item_silver_edge",
				"item_satanic",
				"item_mask_of_madness",
				"item_soul_ring",
				"item_arcane_boots",
				"item_ancient_janggo",
				"item_smoke_of_deceit",
				"item_tome_of_knowledge",
				"item_guardian_greaves",
				"item_ring_of_aquila"
			}
		local dont_change_team = false
		for i = 1, #exceptions_abilities do
			if ability_name == exceptions_abilities[i] then
				dont_change_team = true
			end
		end
		if dont_change_team == false then
			local target_team = ability:GetAbilityTargetTeam()
			local cast_time = ability:GetCastPoint()
			local backswing_time = ability:GetBackswingTime()
			local channel_time = ability:GetChannelTime()
			--local ability_duration = ability:GetDuration()
			local total_duration = backswing_time + cast_time + FrameTime()
			if channel_time ~= 0 then
				total_duration = total_duration + channel_time
			end
			-- if ability_duration ~= 0 then
				-- total_duration = total_duration + ability_duration
			-- end
			
			if target_team == DOTA_UNIT_TARGET_TEAM_NONE or target_team == DOTA_UNIT_TARGET_TEAM_ENEMY then
				if caster.original_team == nil then
					caster.original_team = caster:GetTeamNumber()
				end
				Timers:CreateTimer(cast_time, function()
					if caster.original_team == DOTA_TEAM_GOODGUYS then
						caster:SetTeam(6)
					else
						caster:SetTeam(7)
					end
				end)
				Timers:CreateTimer(total_duration, function()
					if caster.original_team == DOTA_TEAM_GOODGUYS then
						caster:SetTeam(DOTA_TEAM_GOODGUYS)
					else
						caster:SetTeam(DOTA_TEAM_BADGUYS)
					end
				end)
			end
		end
	end
	
	return true
end

-- Damage filter function
function friendly_fire_gamemode:DamageFilter(keys)
	--PrintTable(keys)
	
	local attacker
	local victim
	if keys.entindex_attacker_const and keys.entindex_victim_const then
		attacker = EntIndexToHScript(keys.entindex_attacker_const)
		victim = EntIndexToHScript(keys.entindex_victim_const)
	else
		return false
	end
	
	local damage_type = keys.damagetype_const
	local inflictor = keys.entindex_inflictor_const	-- keys.entindex_inflictor_const is nil if damage is not caused by an ability
	local damage_after_reductions = keys.damage 	-- keys.damage is damage after reductions
	
	local damaging_ability
	if inflictor then
		damaging_ability = EntIndexToHScript(inflictor)
	else
		damaging_ability = nil
	end
	
	-- Lack of entities handling (illusions error fix)
	if attacker:IsNull() or victim:IsNull() then
		return false
	end
		
	return true
end
