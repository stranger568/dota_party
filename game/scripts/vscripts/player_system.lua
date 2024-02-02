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

    if is_bot then
        playerinfo.bRegistred = true
        playerinfo.bLoaded = true
    end

    player_system.PLAYERS[id] = playerinfo

    CustomNetTables:SetTableValue("players_system", tostring(id), playerinfo)

    return playerinfo
end

function player_system:RegisterPlayerHero(id, hero)
    if hero and player_system.PLAYERS[id] then
	    player_system.PLAYERS[id].hero = hero
    end
end

function player_system:HeroModifyHealth(id, new_health)
    if new_health > 0 and player_system.PLAYERS[id].health < player_system.PLAYERS[id].max_health then
	    player_system.PLAYERS[id].health = player_system.PLAYERS[id].health + new_health
    elseif new_health < 0 then
        player_system.PLAYERS[id].health = player_system.PLAYERS[id].health + new_health
    end
    CustomNetTables:SetTableValue("players_system", tostring(id), player_system.PLAYERS[id])
end

function player_system:HeroModifyKeys(id, new_keys)
	player_system.PLAYERS[id].keys = player_system.PLAYERS[id].keys + new_keys
    CustomNetTables:SetTableValue("players_system", tostring(id), player_system.PLAYERS[id])
end

function player_system:UpdatePlayer(id)
    CustomNetTables:SetTableValue("players_system", tostring(id), player_system.PLAYERS[id])
end