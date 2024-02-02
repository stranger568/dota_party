if PummelPartyMain == nil then
	_G.PummelPartyMain = class({})
end

require("utils/timers")
require("utils/functions")
require("utils/table")
require("hub")
require("player_system")
require("hero_select")

PummelPartyMain.FREE_TEST = true

function Precache( context )
    local heroes = LoadKeyValues("scripts/npc/activelist.txt")
    for k,v in pairs(heroes) do
        PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_" .. k:gsub('npc_dota_hero_','') ..".vsndevts", context )  
        PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_" .. k:gsub('npc_dota_hero_','') ..".vsndevts", context ) 
    end
end

function Activate()
	PummelPartyMain:InitGameMode()
    StartTimerLoading()
end

function PummelPartyMain:InitGameMode()
    GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_3, 1 )

    GameRules:SetHeroRespawnEnabled( false )
    GameRules:GetGameModeEntity():SetFixedRespawnTime(99990000)
    GameRules:GetGameModeEntity():SetBuybackEnabled(false)
    GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)

    GameRules:SetCustomGameSetupAutoLaunchDelay(2)
    GameRules:SetCustomGameSetupTimeout(-1)
    GameRules:SetPreGameTime( 0 )
    GameRules:SetStrategyTime( 0 )
    GameRules:SetShowcaseTime( 0 )

    GameRules:GetGameModeEntity():SetCustomGameForceHero("npc_dota_hero_wisp")
    ListenToGameEvent( "player_connect_full", Dynamic_Wrap(self, "OnConnectFull"), self )
    ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( self, "OnGameRulesStateChange" ), self )
    ListenToGameEvent( "npc_spawned", Dynamic_Wrap( self, "OnNPCSpawned" ), self )
    GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( self, "ExecuteOrderFilter" ), self )
end

function PummelPartyMain:OnNPCSpawned(data)
    local hero = EntIndexToHScript(data.entindex)
    if hero and hero:IsRealHero() and hero.is_first_spawn == nil then
        hero:RemoveAllAbilities()
        player_system:RegisterPlayerHero(hero:GetPlayerOwnerID(), hero)
        hero.is_first_spawn = true
        Timers:CreateTimer(0.1, function()
            hero:AddNewModifier(hero, nil, "modifier_pummel_party_hub", {})
        end)
    end
end

function PummelPartyMain:ExecuteOrderFilter( params )
    if PummelPartyMain.FREE_TEST then return true end
	local target = params.entindex_target ~= 0 and EntIndexToHScript(params.entindex_target) or nil
	local player = PlayerResource:GetPlayer(params["issuer_player_id_const"])
 	local unit
    if params.units and params.units["0"] then
        unit = EntIndexToHScript(params.units["0"])
    end
    if not player then return false end
    local hero = player:GetAssignedHero()
    if not hero then return end

    local ignore_move = 
    {
        DOTA_UNIT_ORDER_MOVE_TO_POSITION,
        DOTA_UNIT_ORDER_MOVE_TO_TARGET,
        DOTA_UNIT_ORDER_MOVE_TO_TARGET,
        DOTA_UNIT_ORDER_MOVE_ITEM,
        DOTA_UNIT_ORDER_MOVE_TO_DIRECTION,
        DOTA_UNIT_ORDER_MOVE_RELATIVE,
        DOTA_UNIT_ORDER_STOP,
    }

    for _, order_check in pairs(ignore_move) do
        if params.order_type == order_check then
            return false
        end
    end

	return true
end

function PummelPartyMain:OnConnectFull(data)
	local player_index = EntIndexToHScript( data.index )
	if player_index == nil then return end
	player_system:RegisterPlayerInfo(data.PlayerID)
    if IsInToolsMode() then
        --player_system:RegisterPlayerInfo(1, true)
        --player_system:RegisterPlayerInfo(2, true)
        --player_system:RegisterPlayerInfo(3, true)
        --player_system:RegisterPlayerInfo(4, true)
    end
end

function PummelPartyMain:OnGameRulesStateChange(data)
	local nNewState = GameRules:State_Get()
    if nNewState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		pp_hero_selection:Init()
	end
	if nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        pp_hero_selection:StartCheckingToStart()
	end
end