_G.player_system = class({})
player_system.PLAYERS = {}

function player_system:RegisterPlayerInfo(id, is_bot)
	if not IsInToolsMode() then 
		if not PlayerResource:IsValidPlayerID(id) then return end
   		if tostring( PlayerResource:GetSteamAccountID( id ) ) == nil then return end
    	if PlayerResource:GetSteamAccountID( id ) == 0 then return end
    	if PlayerResource:GetSteamAccountID( id ) == "0" then return end
    end

    local playerinfo = player_system.PLAYERS[id] or 
    {
    	hero = nil,
        steamid = PlayerResource:GetSteamAccountID(id),
        is_lose = false,
        steps = 0,
        health = 30,
        max_health = 30,
        keys = 35,
        rewards_count = 0,
        is_ready = false,
        selected_hero = nil,
        bRegistred = false,
        bLoaded = false,
    }

    if IsInToolsMode() then
        playerinfo.keys = 40
    end

    if is_bot and IsInToolsMode() then
        playerinfo.bRegistred = true
        playerinfo.bLoaded = true
        playerinfo.is_ready = true
        playerinfo.selected_hero = "npc_dota_hero_pudge"
        playerinfo.is_bot = true
    end

    player_system.PLAYERS[id] = playerinfo

    CustomNetTables:SetTableValue("players_system", tostring(id), playerinfo)

    return playerinfo
end

function player_system:GetPlayersCount()
    local count = 0
    for _, info in pairs(player_system.PLAYERS) do
        if not info.is_lose then
            count = count + 1
        end
    end
    return count
end

function player_system:RegisterPlayerHero(id, hero)
    if hero and player_system.PLAYERS[id] then
	    player_system.PLAYERS[id].hero = hero
    end
end

function player_system:HeroModifyHealth(id, new_health)
    player_system.PLAYERS[id].health = math.max(0, math.min(player_system.PLAYERS[id].health + new_health, player_system.PLAYERS[id].max_health))
    CustomNetTables:SetTableValue("players_system", tostring(id), player_system.PLAYERS[id])
    return player_system.PLAYERS[id].health
end

function player_system:HeroModifyKeys(id, new_keys)
	player_system.PLAYERS[id].keys = player_system.PLAYERS[id].keys + new_keys
    CustomNetTables:SetTableValue("players_system", tostring(id), player_system.PLAYERS[id])
    return player_system.PLAYERS[id].keys
end

function player_system:HeroModifyRewards(id, new_rewards)
	player_system.PLAYERS[id].rewards_count = player_system.PLAYERS[id].rewards_count + new_rewards
    CustomNetTables:SetTableValue("players_system", tostring(id), player_system.PLAYERS[id])
    return player_system.PLAYERS[id].rewards_count
end

function player_system:UpdatePlayer(id)
    CustomNetTables:SetTableValue("players_system", tostring(id), player_system.PLAYERS[id])
end