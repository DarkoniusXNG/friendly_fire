-- In this file you can set up all the properties and settings for your game mode.
ENABLE_HERO_RESPAWN = true              -- Should the heroes automatically respawn on a timer or stay dead until manually respawned
UNIVERSAL_SHOP_MODE = false             -- Should the main shop contain Secret Shop items as well as regular items
ALLOW_SAME_HERO_SELECTION = false       -- Should we let people select the same hero as each other

CUSTOM_GAME_SETUP_TIME = 25.0			-- How long should custom game setup last?
HERO_SELECTION_TIME = 30.0              -- How long should we let people select their hero?
STRATEGY_TIME = 20.0					-- How long should strategy time last?
SHOWCASE_TIME = 0.0						-- How long should show case time be?
PRE_GAME_TIME = 90.0                    -- How long after loading heroes into the map should the horn blow and the game start?
POST_GAME_TIME = 60.0                   -- How long should we let people look at the scoreboard before closing the server automatically?
TREE_REGROW_TIME = 60.0                 -- How long should it take individual trees to respawn after being cut down/destroyed?

if IsInToolsMode() then
	PRE_GAME_TIME = 90.0
	GOLD_PER_TICK = 0
	GOLD_TICK_TIME = 10.0
	NORMAL_START_GOLD = 9000
	RANDOM_START_GOLD = 10000
else
	GOLD_PER_TICK = 2                     	-- How much gold should players get per tick?
	GOLD_TICK_TIME = 1.0                    -- How long should we wait in seconds between gold ticks?
	NORMAL_START_GOLD = 600					-- Starting Gold if picked normally
	RANDOM_START_GOLD = 800					-- Starting Gold if randomed
end

RECOMMENDED_BUILDS_DISABLED = false     -- Should we disable the recommended builds for heroes
CAMERA_DISTANCE_OVERRIDE = 1134.0       -- How far out should we allow the camera to go?  1134 is the default in Dota

MINIMAP_ICON_SIZE = 1                   -- What icon size should we use for our heroes?
MINIMAP_CREEP_ICON_SIZE = 1             -- What icon size should we use for creeps?
MINIMAP_RUNE_ICON_SIZE = 1              -- What icon size should we use for runes?

CUSTOM_BUYBACK_COST_ENABLED = false     -- Should we use a custom buyback cost setting?
CUSTOM_BUYBACK_COOLDOWN_ENABLED = false -- Should we use a custom buyback time?
BUYBACK_ENABLED = true                 	-- Should we allow people to buyback when they die?
--BUYBACK_COOLDOWN_TIME = 360.0

DISABLE_FOG_OF_WAR_ENTIRELY = false     -- Should we disable fog of war entirely for both teams?
USE_UNSEEN_FOG_OF_WAR = false           -- Should we make unseen and fogged areas of the map completely black until uncovered by each team? 
                                            -- Note: DISABLE_FOG_OF_WAR_ENTIRELY must be false for USE_UNSEEN_FOG_OF_WAR to work
USE_STANDARD_DOTA_BOT_THINKING = false  -- Should we have bots act like they would in Dota? (This requires 3 lanes, normal items, etc)
USE_STANDARD_HERO_GOLD_BOUNTY = true    -- Should we give gold for hero kills the same as in Dota, or allow those values to be changed?

HERO_KILL_GOLD_BASE = 110				-- Hero gold bounty base value
HERO_KILL_GOLD_PER_LEVEL = 8			-- Hero gold bounty increase per level

USE_CUSTOM_TOP_BAR_VALUES = true		-- Should we do customized top bar values or use the default kill count per team?
TOP_BAR_VISIBLE = true                  -- Should we display the top bar score/count at all?
SHOW_KILLS_ON_TOPBAR = true             -- Should we display kills only on the top bar? (No denies, suicides, kills by neutrals)  Requires USE_CUSTOM_TOP_BAR_VALUES

ENABLE_TOWER_BACKDOOR_PROTECTION = true	-- Should we enable backdoor protection for our towers?
REMOVE_ILLUSIONS_ON_DEATH = false       -- Should we remove all illusions if the main hero dies?
DISABLE_GOLD_SOUNDS = false             -- Should we disable the gold sound when players get gold?

END_GAME_ON_KILLS = false               -- Should the game end after a certain number of kills?
--KILLS_TO_END_GAME_FOR_TEAM = 50       -- How many kills for a team should signify an end of game?

USE_CUSTOM_HERO_LEVELS = true           -- Should we allow heroes to have custom levels?
MAX_LEVEL = 25                          -- What level should we let heroes get to?
USE_CUSTOM_XP_VALUES = true      --false? broken?-- Should we use custom XP values to level up heroes, or the default Dota numbers?

-- Fill this table up with the required XP per level if you want to change it
XP_PER_LEVEL_TABLE = {}
XP_PER_LEVEL_TABLE[1] = 0
XP_PER_LEVEL_TABLE[2] = 200
XP_PER_LEVEL_TABLE[3] = 600
XP_PER_LEVEL_TABLE[4] = 1000
XP_PER_LEVEL_TABLE[5] = 1600
XP_PER_LEVEL_TABLE[6] = 2300
XP_PER_LEVEL_TABLE[7] = 2900
XP_PER_LEVEL_TABLE[8] = 3600
XP_PER_LEVEL_TABLE[9] = 4200
XP_PER_LEVEL_TABLE[10] = 5000
XP_PER_LEVEL_TABLE[11] = 5900
XP_PER_LEVEL_TABLE[12] = 6700
XP_PER_LEVEL_TABLE[13] = 7600
XP_PER_LEVEL_TABLE[14] = 8800
XP_PER_LEVEL_TABLE[15] = 9900
XP_PER_LEVEL_TABLE[16] = 11000
XP_PER_LEVEL_TABLE[17] = 12690
XP_PER_LEVEL_TABLE[18] = 14000
XP_PER_LEVEL_TABLE[19] = 15400
XP_PER_LEVEL_TABLE[20] = 16900
XP_PER_LEVEL_TABLE[21] = 18400
XP_PER_LEVEL_TABLE[22] = 20150
XP_PER_LEVEL_TABLE[23] = 22150
XP_PER_LEVEL_TABLE[24] = 24400
XP_PER_LEVEL_TABLE[25] = 26000

ENABLE_FIRST_BLOOD = true               -- Should we enable first blood for the first kill in this game?
HIDE_KILL_BANNERS = false               -- Should we hide the kill banners that show when a player is killed?
LOSE_GOLD_ON_DEATH = false              -- Should we have players lose the normal amount of dota gold on death?
SHOW_ONLY_PLAYER_INVENTORY = false      -- Should we only allow players to see their own inventory even when selecting other units?
DISABLE_STASH_PURCHASING = false        -- Should we prevent players from being able to buy items into their stash when not at a shop?
DISABLE_ANNOUNCER = false               -- Should we disable the announcer from working in the game?
FORCE_PICKED_HERO = nil                 -- What hero should we force all players to spawn as? (e.g. "npc_dota_hero_axe").  Use nil to allow players to pick their own hero.

FIXED_RESPAWN_TIME = -1                 -- What time should we use for a fixed respawn timer?  Use -1 to keep the default dota behavior.
MAX_RESPAWN_TIME = 90.0					-- Dota Default is 100.0 (there is no limit in normal dota)

FOUNTAIN_CONSTANT_MANA_REGEN = -1       -- What should we use for the constant fountain mana regen?  Use -1 to keep the default dota behavior.
FOUNTAIN_PERCENTAGE_MANA_REGEN = -1    	-- What should we use for the percentage fountain mana regen?  Use -1 to keep the default dota behavior.
FOUNTAIN_PERCENTAGE_HEALTH_REGEN = 6   	-- What should we use for the percentage fountain health regen?  Use -1 to keep the default dota behavior.
MAXIMUM_ATTACK_SPEED = 600              -- What should we use for the maximum attack speed?
MINIMUM_ATTACK_SPEED = 20               -- What should we use for the minimum attack speed?

DISABLE_DAY_NIGHT_CYCLE = false         -- Should we disable the day night cycle from naturally occurring? (Manual adjustment still possible)
DISABLE_KILLING_SPREE_ANNOUNCER = false -- Shuold we disable the killing spree announcer?
DISABLE_STICKY_ITEM = false             -- Should we disable the sticky item button in the quick buy area?

--ENABLED_RUNES = {}                      -- Which runes should be enabled to spawn in our game mode?
--ENABLED_RUNES[DOTA_RUNE_DOUBLEDAMAGE] = true
--ENABLED_RUNES[DOTA_RUNE_HASTE] = true
--ENABLED_RUNES[DOTA_RUNE_ILLUSION] = true
--ENABLED_RUNES[DOTA_RUNE_INVISIBILITY] = true
--ENABLED_RUNES[DOTA_RUNE_REGENERATION] = true
--ENABLED_RUNES[DOTA_RUNE_BOUNTY] = true
--ENABLED_RUNES[DOTA_RUNE_ARCANE] = true

MAX_NUMBER_OF_TEAMS = 2                		-- How many potential teams can be in this game mode?
USE_CUSTOM_TEAM_COLORS = false          	-- Should we use custom team colors?
USE_CUSTOM_TEAM_COLORS_FOR_PLAYERS = true	-- Should we use custom team colors to color the players/minimap?

TEAM_COLORS = {}                        -- If USE_CUSTOM_TEAM_COLORS is set, use these colors.
TEAM_COLORS[DOTA_TEAM_GOODGUYS] = { 0, 255, 0 }  	--    Teal  61, 210, 150
TEAM_COLORS[DOTA_TEAM_BADGUYS]  = { 255, 0, 0 }   	--    Yellow 243, 201, 9
TEAM_COLORS[DOTA_TEAM_CUSTOM_1] = { 197, 77, 168 }  --    Pink
TEAM_COLORS[DOTA_TEAM_CUSTOM_2] = { 255, 108, 0 }   --    Orange
TEAM_COLORS[DOTA_TEAM_CUSTOM_3] = { 52, 85, 255 }   --    Blue
TEAM_COLORS[DOTA_TEAM_CUSTOM_4] = { 101, 212, 19 }  --    Green
TEAM_COLORS[DOTA_TEAM_CUSTOM_5] = { 129, 83, 54 }   --    Brown
TEAM_COLORS[DOTA_TEAM_CUSTOM_6] = { 27, 192, 216 }  --    Cyan
TEAM_COLORS[DOTA_TEAM_CUSTOM_7] = { 199, 228, 13 }  --    Olive
TEAM_COLORS[DOTA_TEAM_CUSTOM_8] = { 140, 42, 244 }  --    Purple

USE_AUTOMATIC_PLAYERS_PER_TEAM = true  -- Should we set the number of players to 10 / MAX_NUMBER_OF_TEAMS?

CUSTOM_TEAM_PLAYER_COUNT = {}	-- If we're not automatically setting the number of players per team, use this table

CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] = 5
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]  = 5
