_G.MiniGamesLib = class({})

MiniGamesLib.MiniGamesList =
{
    "sniper_duel",
    --"couriers_run",
    --"pudge_wars",
}

MiniGamesLib.CurrentMiniGame = nil
MiniGamesLib.PLAYERS_READY_LIST = {}

function MiniGamesLib:StartRandomMiniGamesPre()
    local get_random_minigame = MiniGamesLib.MiniGamesList[RandomInt(1, #MiniGamesLib.MiniGamesList)]
    MiniGamesLib.CurrentMiniGame = get_random_minigame
    MiniGamesLib.PLAYERS_READY_LIST = {}
    self:TeleportToMiniGamePre()
end

function MiniGamesLib:TeleportToMiniGamePre()
    local teleport_point = 1
    for id, player_info in pairs(player_system.PLAYERS) do
        if player_info.hero then
            local teleport_position = Entities:FindByName(nil, MiniGamesLib.CurrentMiniGame.."_spawn_"..teleport_point)
            if teleport_position then
                local hero = player_info.hero
                hero.MINIGAME_RESPAWN_POS = teleport_position:GetAbsOrigin()
                FindClearSpaceForUnit(hero, teleport_position:GetAbsOrigin(), true)
                hero:SetCamera(hero)
                Timers:CreateTimer(FrameTime(), function()
                    hero:UnlockCamera()
                end)
            end
            teleport_point = teleport_point + 1
        end
    end
    RemoveModifierForAllHeroes("modifier_pummel_party_hub")
    AddNewModifierForAllHeroes("modifier_pummel_party_pre_mini_game", -1)
    CustomGameEventManager:Send_ServerToAllClients("starting_pre_game_window", {game_name = MiniGamesLib.CurrentMiniGame})

    local mini_game_timer_pre = 30
    CustomGameEventManager:Send_ServerToAllClients("pregame_minigame_timer", {time = mini_game_timer_pre})
    Timers:CreateTimer(1, function()
        mini_game_timer_pre = mini_game_timer_pre - 1
        CustomGameEventManager:Send_ServerToAllClients("pregame_minigame_timer", {time = mini_game_timer_pre})
        if mini_game_timer_pre <= 0 or (self:HowMuchPlayersReady() >= player_system:GetPlayersCount()) then
            self:StartMiniGame(MiniGamesLib.CurrentMiniGame)
            return
        end
        return 1
    end)
end

function MiniGamesLib:HowMuchPlayersReady()
    local count = 0
    for _, cc in pairs(MiniGamesLib.PLAYERS_READY_LIST) do
        count = count + 1
    end
    return count
end

function MiniGamesLib:PlayerReadyUpdate(data)
    if data.PlayerID == nil then return end
    local id = data.PlayerID
    if player_system.PLAYERS[id] == nil then return end
    if player_system.PLAYERS[id].is_lose then return end
    MiniGamesLib.PLAYERS_READY_LIST[id] = true
    CustomGameEventManager:Send_ServerToAllClients("update_player_ready_list", {players = MiniGamesLib.PLAYERS_READY_LIST})
end

function MiniGamesLib:StartMiniGame(game_name)
    CustomGameEventManager:Send_ServerToAllClients("close_pre_minigame_info", {})
    RemoveModifierForAllHeroes("modifier_pummel_party_pre_mini_game")
    if game_name == "sniper_duel" then
        --AddNewAbilityForAllHeroes({"ability_sniper_mini_game"})
        for id, player_info in pairs(player_system.PLAYERS) do
            if player_info.hero then
                hero = player_info.hero
                hero:SetCamera(hero)
                local ability_sniper_mini_game = hero:AddAbility("ability_sniper_mini_game")
                if ability_sniper_mini_game then
                    ability_sniper_mini_game:SetHidden(false)
                    ability_sniper_mini_game:SetLevel(1)
                end
            end
        end
    end
    local game_time = 120
    if IsInToolsMode() then
        game_time = 10
    end
    Timers:CreateTimer(game_time, function()
        self:MiniGameIsEnd()
    end)
end

function MiniGamesLib:MiniGameIsEnd()
    self:DeletedGamesAbility()
    HubGame:ReturnToHub()
    HubGame:RandomPlayersQueue()
    HubGame:StartQueuePlayers()
    Timers:CreateTimer(FrameTime(), function()
        UnlockCameraAll()
    end)
end
function MiniGamesLib:DeletedGamesAbility()
    local games_abilities = 
    {
        "ability_sniper_mini_game"
    }
    for id, player_info in pairs(player_system.PLAYERS) do
        if player_info.hero then
            hero = player_info.hero
            for _, ability_name in pairs(games_abilities) do
                hero:RemoveAbility(ability_name)
            end
        end
    end
end