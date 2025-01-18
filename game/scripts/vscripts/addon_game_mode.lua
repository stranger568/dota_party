if PummelPartyMain == nil then
	_G.PummelPartyMain = class({})
end

require("utils/timers")
require("utils/functions")
require("utils/table")
require("hub")
require("player_system")
require("hero_select")
require("player_control")
require("minigames")

PummelPartyMain.FREE_TEST = false and IsInToolsMode()
PummelPartyMain.IS_BOT_ENABLED = true and IsInToolsMode()

Precache = require "utils/precache"

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
    GameRules:GetGameModeEntity():SetHudCombatEventsDisabled(true)
    GameRules:GetGameModeEntity():SetBuybackEnabled(false)
    GameRules:GetGameModeEntity():SetDaynightCycleDisabled(true)
    GameRules:SetCustomGameSetupAutoLaunchDelay(2)
    GameRules:SetCustomGameSetupTimeout(-1)
    GameRules:SetPreGameTime( 0 )
    GameRules:SetHideKillMessageHeaders( true )
    GameRules:SetStrategyTime( 0 )
    GameRules:SetShowcaseTime( 0 )
    GameRules:GetGameModeEntity():SetCustomGameForceHero("npc_dota_hero_wisp")
    ListenToGameEvent("player_connect_full", Dynamic_Wrap(self, "OnConnectFull"), self )
    ListenToGameEvent("game_rules_state_change", Dynamic_Wrap( self, "OnGameRulesStateChange" ), self )
    ListenToGameEvent("npc_spawned", Dynamic_Wrap( self, "OnNPCSpawned" ), self )
    ListenToGameEvent("player_chat", Dynamic_Wrap( self, "OnChat" ), self )
    ListenToGameEvent("entity_killed", Dynamic_Wrap( self, 'OnEntityKilled' ), self )
    CustomGameEventManager:RegisterListener("PLAYER_IS_READY_MINIGAME", Dynamic_Wrap(MiniGamesLib, "PlayerReadyUpdate"))
    CustomGameEventManager:RegisterListener("PLAYER_CHECKED_OPEN_CHEST", Dynamic_Wrap(HubGame, "PlayerChestOpenedChecked"))
    CustomGameEventManager:RegisterListener("PLAYER_SELECTED_ROTATION", Dynamic_Wrap(HubGame, "PlayerRotatePointNext"))
    GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( self, "ExecuteOrderFilter" ), self )
end

function PummelPartyMain:OnEntityKilled( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	local killedTeam = killedUnit:GetTeam()
    local hero = nil
    -- Если существует убийца
	if event.entindex_attacker then
		hero = EntIndexToHScript( event.entindex_attacker )
	end
    if event.entindex_inflictor then
        local abilities_dies = 
        {
            ["pudge_meat_hook"] = true,
            ["mirana_arrow"] = true,
            ["rattletrap_hookshot"] = true,
            ["tiny_toss_tree"] = true,
            ["tiny_tree_grab"] = true,
            ["mars_spear"] = true,
            ["shredder_chakram"] = true,
            ["magnataur_shockwave"] = true,
            ["hoodwink_sharpshooter"] = true,
            ["ancient_apparition_ice_blast"] = true,
            ["queenofpain_sonic_wave"] = true,
            ["snapfire_mortimer_kisses"] = true,
            ["invoker_chaos_meteor"] = true,
        }
        local ability = EntIndexToHScript( event.entindex_inflictor )
        if ability and MiniGamesLib.CurrentMiniGame == "kennon_circle" and (abilities_dies[ability:GetAbilityName()]) then
            table.insert(MiniGamesLib.QUEUE_PLAYERS, killedUnit:GetPlayerOwnerID())
        end
    end
    if MiniGamesLib.CurrentMiniGame and MiniGamesLib.CurrentMiniGame == "gift_or_ability" then
        Timers:CreateTimer(0.2, function()
            local respawnpoint = killedUnit.MINIGAME_RESPAWN_POS
            if respawnpoint == nil then
                respawnpoint = killedUnit:GetAbsOrigin()
            end
            killedUnit:RespawnHero(false, false)
            FindClearSpaceForUnit(killedUnit, respawnpoint, true)
            Timers:CreateTimer(1, function()
                local modifier_fountain_invulnerability = killedUnit:FindModifierByName("modifier_fountain_invulnerability")
                if modifier_fountain_invulnerability then
                    modifier_fountain_invulnerability:SetDuration(1, true)
                end
            end)
        end)
    end
end

function PummelPartyMain:OnChat(data)
    if not GameRules:IsCheatMode() then return end
	if data.text == "test" then
        HubGame:StartPreMiniGame()
	end
end

function PummelPartyMain:OnNPCSpawned(data)
    local hero = EntIndexToHScript(data.entindex)
    if hero and hero:IsRealHero() and hero.is_first_spawn == nil and MiniGamesLib.CurrentMiniGame == nil then
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
    if PummelPartyMain.IS_BOT_ENABLED then
        player_system:RegisterPlayerInfo(1, true)
        player_system:RegisterPlayerInfo(2, true)
        player_system:RegisterPlayerInfo(3, true)
        player_system:RegisterPlayerInfo(4, true)
    end
end

function PummelPartyMain:OnGameRulesStateChange(data)
	local nNewState = GameRules:State_Get()
    if nNewState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		pp_hero_selection:Init()
        if PummelPartyMain.IS_BOT_ENABLED then
            Timers:CreateTimer(0.2, function()
                SendToServerConsole('dota_bot_populate')
            end)
        end
	end
	if nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        pp_hero_selection:StartCheckingToStart()
	end
end