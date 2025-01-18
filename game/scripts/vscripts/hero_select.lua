_G.pp_hero_selection = class({})

-- Статусы
PP_PICK_STATE_PLAYERS_LOADED = "PP_PICK_STATE_PLAYERS_LOADED"
PP_PICK_STATE_SELECT = "PP_PICK_STATE_SELECT"
PP_PICK_STATE_PRE_END = "PP_PICK_STATE_PRE_END"
PP_PICK_STATE_END = "PP_PICK_STATE_END"
PICK_STATE_STATUS = {}
PICK_STATE_STATUS[1] = PP_PICK_STATE_PLAYERS_LOADED
PICK_STATE_STATUS[2] = PP_PICK_STATE_SELECT
PICK_STATE_STATUS[3] = PP_PICK_STATE_PRE_END
PICK_STATE_STATUS[4] = PP_PICK_STATE_END
TIME_OF_STATE = {}
TIME_OF_STATE[1] = 10
TIME_OF_STATE[2] = 30
TIME_OF_STATE[3] = 2

if IsInToolsMode() then
    TIME_OF_STATE[2] = 1000
end

IN_STATE = false
PICK_STATE = PP_PICK_STATE_PLAYERS_LOADED
FULL_ENABLE_HEROES =
{
    "npc_dota_hero_pudge",
    "npc_dota_hero_wisp",
    "npc_dota_hero_sven",
    "npc_dota_hero_lina",
    "npc_dota_hero_crystal_maiden",
    "npc_dota_hero_snapfire",
    "npc_dota_hero_phantom_assassin",
    "npc_dota_hero_abaddon",
    "npc_dota_hero_alchemist",
    "npc_dota_hero_templar_assassin",
}

function pp_hero_selection:Init()
	IN_STATE = true
	CustomGameEventManager:RegisterListener( 'pp_pick_select_hero', Dynamic_Wrap( self, 'PlayerSelect'))
	CustomGameEventManager:RegisterListener( 'pp_pick_player_registred', Dynamic_Wrap( self, 'PlayerRegistred' ) )
	CustomGameEventManager:RegisterListener( 'pp_pick_player_loaded', Dynamic_Wrap( self, 'PlayerLoaded' ) )
end

function pp_hero_selection:StartCheckingToStart()
	Schedule( 1, function()
		pp_hero_selection:CheckReadyPlayers()
	end)
end

function pp_hero_selection:CheckReadyPlayers( attempt )
	if PICK_STATE ~= PP_PICK_STATE_PLAYERS_LOADED then
		return
	end
	local bAllReady = true
	for pid, pinfo in pairs( player_system.PLAYERS ) do
		if pinfo.bRegistred and not pinfo.bLoaded then
			bAllReady = false
		end
	end
	if bAllReady then
		Timers:CreateTimer(2, function()
			pp_hero_selection:Start()
		end)
	else
		local check_interval = 5
		attempt = ( attempt or 0 ) + check_interval
		if attempt > TIME_OF_STATE[1] then
			pp_hero_selection:Start()
		else
			Schedule( check_interval, function()
				pp_hero_selection:CheckReadyPlayers( attempt )
			end )
		end
	end
end

function pp_hero_selection:PlayerRegistred( params )
	if params.PlayerID == nil then return end
    local id = params.PlayerID
	player_system.PLAYERS[id].bRegistred = true
	player_system.PLAYERS[id].bLoaded = true
end

function pp_hero_selection:PlayerLoaded( params )
	if params.PlayerID == nil then return end
	local pid = params.PlayerID
	local player = PlayerResource:GetPlayer( pid )
	if player == nil then return end
    local player_info = player_system.PLAYERS[pid]
	if player_info == nil then
		CustomGameEventManager:Send_ServerToPlayer( player, 'pp_pick_end', {} )
		return
	end
	player_info.bLoaded = true
	if not IN_STATE then
		CustomGameEventManager:Send_ServerToPlayer( player, 'pp_pick_end', {} )
		return
	end
	if PICK_STATE ~= PP_PICK_STATE_PLAYERS_LOADED then
		if player_info.picked_hero ~= nil then
			CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pid), 'hero_is_picked', {hero = player_info.picked_hero})
		end
		if PICK_STATE == PP_PICK_STATE_SELECT then
			CustomGameEventManager:Send_ServerToPlayer( player, 'pp_pick_start_selection', {} )
		elseif PICK_STATE == PP_PICK_STATE_PRE_END then
			CustomGameEventManager:Send_ServerToPlayer( player, 'pp_pick_preend_start', {} )
		elseif PICK_STATE == PP_PICK_STATE_END then
			CustomGameEventManager:Send_ServerToPlayer( player, 'pp_pick_end', {} )
		end
	end
end

-- Стадии
function pp_hero_selection:Start()
	pp_hero_selection:StartSelectionStage()
end

function pp_hero_selection:StartSelectionStage()
	PICK_STATE = PP_PICK_STATE_SELECT
	CustomGameEventManager:Send_ServerToAllClients( 'pp_pick_start_selection', {} )
	pp_hero_selection:StartTimers( TIME_OF_STATE[2], function()
		pp_hero_selection:EndSelectionStage()
	end)	
end

function pp_hero_selection:EndSelectionStage()
	if PICK_STATE ~= PP_PICK_STATE_SELECT then
		return
	end
	pp_hero_selection:StartPreEndSelection()
end

function pp_hero_selection:StartPreEndSelection()
    PICK_STATE = PP_PICK_STATE_PRE_END
    CustomGameEventManager:Send_ServerToAllClients( 'pp_pick_preend_start', {} )
    pp_hero_selection:GiveHeroes()
    pp_hero_selection:StartTimers( TIME_OF_STATE[3], function()
        pp_hero_selection:EndSelection()
    end)
end

function pp_hero_selection:EndSelection()
	IN_STATE = false
	PICK_STATE = PP_PICK_STATE_END
	pp_hero_selection.pick_ended = true
	CustomGameEventManager:Send_ServerToAllClients( 'pp_pick_end', {} )
    HubGame:GeneratePointsConnection()
    Timers:CreateTimer(1, function()
		HubGame:StartHub()
    end)
end

-- Выбор героя
function pp_hero_selection:PlayerSelect( params )
	if params.PlayerID == nil then return end
	local id = params.PlayerID
	local player_info = player_system.PLAYERS[id]
	if PICK_STATE == PP_PICK_STATE_SELECT then
		if player_info.selected_hero then return end
        player_info.selected_hero = params.hero_name
        player_info.is_ready = true
        player_system:UpdatePlayer(id)
        CustomGameEventManager:Send_ServerToAllClients("UpdatePlayersPick", {hero = params.hero_name, id = id})
        CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(id), 'hero_is_picked', {hero = params.hero_name, id = id})
        pp_hero_selection:GiveHeroPlayer(id, player_info.selected_hero)
        CheckPlayerHeroes()
	end
end

-- Менее важные функции

function pp_hero_selection:RandomHeroForPlayer()
	local hero 
    local array_heroes = table.shuffle(FULL_ENABLE_HEROES)
    local random_hero_number = RandomInt(1, #array_heroes)
    hero = array_heroes[random_hero_number]
	return hero
end

function CheckPlayerHeroes()
	if PICK_STATE == PP_PICK_STATE_PRE_END or PICK_STATE == PP_PICK_STATE_END then return end
	for pid, pinfo in pairs( player_system.PLAYERS ) do
		if pinfo.selected_hero == nil then
			return 
		end
	end
	pp_hero_selection:EndSelectionStage()
end

function pp_hero_selection:GiveHeroPlayer(id,hero)
	local wisp = PlayerResource:GetSelectedHeroEntity(id)
    UTIL_Remove(wisp)
	PlayerResource:ReplaceHeroWith(id, hero, 700, 0)
	local new_hero = PlayerResource:GetSelectedHeroEntity(id)
	if new_hero ~= nil then
		player_system.PLAYERS[id].hero = new_hero
        new_hero:SetBaseMoveSpeed(550)
	end
end

function pp_hero_selection:GiveHeroes()
	for pid, pinfo in pairs( player_system.PLAYERS ) do
		if pinfo.selected_hero == nil then
			local hero = pp_hero_selection:RandomHeroForPlayer()
            player_system.PLAYERS[pid].selected_hero = hero
            player_system.PLAYERS[pid].is_ready = true
            player_system:UpdatePlayer(pid)
            CustomGameEventManager:Send_ServerToAllClients("UpdatePlayersPick", {hero = hero, id = pid})
			CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pid), 'hero_is_picked', {hero = hero})
			pp_hero_selection:GiveHeroPlayer(pid, hero)
		end
	end
end

-- Дополнительные функции

function pp_hero_selection:StartTimers( delay, fExpire )
	local n = 1
	local f = function()
		n = n - 1
		if n == 0 then
			fExpire()
		end
	end
	self:StartTimer( delay, f )
end

function pp_hero_selection:StartTimer( delay, fExpire )
	local timer_number = ( self.StartTimerNumber or 0 ) + 1
	self.StartTimerNumber = timer_number
	self.Timers = delay
	local tick_interval = 1/30
	local delay_int
	
	Timer( function( dt )
		if self.StartTimerNumber ~= timer_number then
			return
		end
		
		delay = delay - dt
		self.Timers = delay
		
		if delay <= 0 then
			self.Timers = 0
			fExpire()
			return
		end
		
		local new_delay_int = math.floor( delay )
		if delay_int ~= new_delay_int then
			delay_int = new_delay_int
			CustomGameEventManager:Send_ServerToAllClients( 'pp_pick_timer_upd', { timer = delay_int })
		end

		return tick_interval
	end )
end