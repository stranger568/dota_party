_G.HubGame = class({})

HubGame.CURRENT_POINT_STEP = {}
HubGame.START_RANDOM_STEPS = {}
HubGame.CURRENT_STATE = "HUB"
HubGame.QUEUE_HUB_PLAYERS = {}
HubGame.ROUND_NUMBER = 0

HubGame.POINTS_WITH_ROTATE = 
{
    ["hub_point_up_15"] = 1,
    ["hub_point_up_15"] = 2,
    ["hub_point_down_6"] = 3,
    ["hub_point_up_22"] = 4,
}

HubGame.POINTS_CONNECTION = {}
HubGame.POINTS_CONNECTION["hub_point_center"] = "hub_point_up_1"
HubGame.POINTS_CONNECTION["hub_point_up_32"] = "hub_point_center"
HubGame.POINTS_CONNECTION["hub_point_left_3"] = "hub_point_up_17"
HubGame.POINTS_CONNECTION["hub_point_right_7"] = "hub_point_up_24"
HubGame.POINTS_CONNECTION["hub_point_down_11"] = "hub_point_up_17"
HubGame.CURRENT_CUP_POINT = nil
HubGame.CURRENT_CUP_UNIT = nil

-- Инициализия текущей точки на старте
for i=0, 4 do
    HubGame.CURRENT_POINT_STEP[i] = "hub_point_center"
end

HubGame.POINT_TYPE = 
{
    [1] = "chest", -- Сундук
    [2] = "damage", -- Нанесение урона
    [3] = "kill", -- Убийство
    [4] = "hp_regen", -- Хп реген
    [5] = "keys", -- Ключи
}

HubGame.CURRENT_TYPE_POINTS = {}
HubGame.CURRENT_TYPE_POINTS_UNITS = {}
HubGame.GET_CURRENT_PLAYERS_POINTS_IN_HUB = {}

function HubGame:ChangeRandomPointCup()
    local point_cup = nil
    local random_points = {}
    for _, point in pairs(HubGame.POINTS_CONNECTION) do
        if point ~= "hub_point_center" and point ~= HubGame.CURRENT_CUP_POINT then
            table.insert(random_points, point)
        end
    end
    if HubGame.CURRENT_CUP_POINT then
        local unit = HubGame.CURRENT_TYPE_POINTS_UNITS[HubGame.CURRENT_CUP_POINT]
        if unit then
            local random_effect = RandomInt(1, 6)
            unit:SetMaterialGroup("skin"..random_effect)
            HubGame.CURRENT_TYPE_POINTS[HubGame.CURRENT_CUP_POINT] = HubGame.POINT_TYPE[random_effect]
        end
        if HubGame.CURRENT_CUP_UNIT then
            UTIL_Remove(HubGame.CURRENT_CUP_UNIT)
        end
    end
    point_cup = random_points[RandomInt(1, #random_points)]
    if point_cup ~= nil then
        local unit = HubGame.CURRENT_TYPE_POINTS_UNITS[point_cup]
        if unit then
            unit:SetMaterialGroup("skin8")
            SetCameraAll(unit)
            Timers:CreateTimer(3.5, function()
                UnlockCameraAll()
            end)
        end
        local pummel_cup_origin = unit:GetAbsOrigin() + RandomVector(200)
        pummel_cup_origin.z = GetGroundHeight(pummel_cup_origin, nil) + 350
        local pummel_cup = CreateUnitByName("pummel_cup", pummel_cup_origin, false, nil, nil, DOTA_TEAM_NEUTRALS)
        pummel_cup:SetForwardVector(Vector(0,-1,0))
        pummel_cup:SetAbsOrigin(pummel_cup_origin)
        pummel_cup:AddNewModifier(pummel_cup, nil, "modifier_pummel_cup", {})
        HubGame.CURRENT_CUP_UNIT = pummel_cup
        HubGame.CURRENT_TYPE_POINTS[point_cup] = "cup"
        HubGame.CURRENT_CUP_POINT = point_cup
    end
end

function HubGame:CreatePoint(point_name, abs)
    local origin = abs
    origin.z = GetGroundHeight(origin, nil)

    local pedestal = CreateUnitByName("pummel_point", origin, false, nil, nil, DOTA_TEAM_NEUTRALS)
    if pedestal then
        local random_effect = RandomInt(1, 6)
        pedestal:SetAbsOrigin(origin)
        pedestal:SetMaterialGroup("skin"..random_effect)
        pedestal:AddNewModifier(pedestal, nil, "modifier_pummel_party_pedestal", {})
        HubGame.CURRENT_TYPE_POINTS[point_name] = HubGame.POINT_TYPE[random_effect]
        HubGame.CURRENT_TYPE_POINTS_UNITS[point_name] = pedestal
        pedestal:SetForwardVector(Vector(0, 1, 0))
        local particle = ParticleManager:CreateParticle("particles/point_ring_effect.vpcf", PATTACH_WORLDORIGIN, pedestal)
        ParticleManager:SetParticleControl(particle, 0, origin)
        ParticleManager:SetParticleControl(particle, 1, Vector(255,208,0))
        ParticleManager:SetParticleControl(particle, 3, Vector(255,255,255))
        
        -- different settings
        if (point_name == "hub_point_center") then
            pedestal:SetMaterialGroup("skin7")
            HubGame.CURRENT_TYPE_POINTS[point_name] = "start"
        end
    end
end

-- Инициализация точек коннекта ходов
function HubGame:GeneratePointsConnection()
    for i = 1, 100 do
        local left = Entities:FindByName(nil, "hub_point_left_"..i)
        if left then
            local next_number_point = left:Attribute_GetIntValue('next_point', -1)
            if next_number_point ~= -1 and next_number_point ~= 0 then
                HubGame.POINTS_CONNECTION["hub_point_left_"..i] = "hub_point_left_"..next_number_point
            end
            HubGame:CreatePoint("hub_point_left_"..i, left:GetAbsOrigin())
        end
        local right = Entities:FindByName(nil, "hub_point_right_"..i)
        if right then
            local next_number_point = right:Attribute_GetIntValue('next_point', -1)
            if next_number_point ~= -1 and next_number_point ~= 0 then
                HubGame.POINTS_CONNECTION["hub_point_right_"..i] = "hub_point_right_"..next_number_point
            end
            HubGame:CreatePoint("hub_point_right_"..i, right:GetAbsOrigin())
        end
        local up = Entities:FindByName(nil, "hub_point_up_"..i)
        if up then
            local next_number_point = up:Attribute_GetIntValue('next_point', -1)
            if next_number_point ~= -1 and next_number_point ~= 0 then
                HubGame.POINTS_CONNECTION["hub_point_up_"..i] = "hub_point_up_"..next_number_point
            end
            HubGame:CreatePoint("hub_point_up_"..i, up:GetAbsOrigin())
        end
        local down = Entities:FindByName(nil, "hub_point_down_"..i)
        if down then
            local next_number_point = down:Attribute_GetIntValue('next_point', -1)
            if next_number_point ~= -1 and next_number_point ~= 0 then
                HubGame.POINTS_CONNECTION["hub_point_down_"..i] = "hub_point_down_"..next_number_point
            end
            HubGame:CreatePoint("hub_point_down_"..i, down:GetAbsOrigin())
        end
    end
    local hub_point_center = Entities:FindByName(nil, "hub_point_center")
    if hub_point_center then
        HubGame:CreatePoint("hub_point_center", hub_point_center:GetAbsOrigin())
    end
end

-- Запуск хаба с передвижением
function HubGame:StartHub()
    HubGame.ROUND_NUMBER = HubGame.ROUND_NUMBER + 1
    CustomNetTables:SetTableValue("game_info", "round_number", {number = HubGame.ROUND_NUMBER})
    Timers:CreateTimer(0, function()
        local all_heroes_loading = true
        for id, info in pairs(player_system.PLAYERS) do
            if info.hero == nil then
                all_heroes_loading = false
                break
            end
        end
        if all_heroes_loading then
            if not PummelPartyMain.FREE_TEST then
                AddNewModifierForAllHeroes("modifier_pummel_party_hub", -1)
            end
            AddNewAbilityForAllHeroes({"ability_random_steps", "ability_change_rotate_left", "ability_change_rotate_right", "ability_change_rotate_up", "ability_change_rotate_down"})
            StartFirstRandomQueue()
        else
            return 0.1
        end
    end)
end

-- Запуск первого хода
function StartFirstRandomQueue()
    for id, info in pairs(player_system.PLAYERS) do
        local ability_random_steps = info.hero:FindAbilityByName("ability_random_steps")
        if ability_random_steps then
            ability_random_steps:SetHidden(false)
            ability_random_steps.is_start = true
        end
        info.hero.particle_dice = ParticleManager:CreateParticle("particles/dice_particle.vpcf", PATTACH_OVERHEAD_FOLLOW, info.hero)
    end
    CustomGameEventManager:Send_ServerToAllClients( "notification_player_start_game", {})
end

function HubGame:SetStartGameRandomQueue(player_id, steps)
    local info = {player_id = player_id, steps = steps}
    table.insert(HubGame.START_RANDOM_STEPS, info)
    table.sort(HubGame.START_RANDOM_STEPS, function(a, b) return a.steps > b.steps end)
    if #HubGame.START_RANDOM_STEPS >= HubGame:HowMuchPlayersInGame() then
        local random_players = {}
        for _, info in pairs(HubGame.START_RANDOM_STEPS) do
            table.insert(random_players, info.player_id)
        end
        CustomNetTables:SetTableValue("game_info", "round_queue", {players = random_players})
        HubGame.QUEUE_HUB_PLAYERS = random_players
        Timers:CreateTimer(1, function()
            for id, info in pairs(player_system.PLAYERS) do
                local modifier_ability_random_steps_count = info.hero:FindModifierByName("modifier_ability_random_steps_count")
                if modifier_ability_random_steps_count then
                    modifier_ability_random_steps_count:Destroy()
                end
            end
            CustomGameEventManager:Send_ServerToAllClients( "game_chest_notification", {})
            HubGame:ChangeRandomPointCup()
            Timers:CreateTimer(5, function()
                HubGame:StartQueuePlayers()
            end)
        end)
    end
end

-- Перерандом кто каким ходит
function HubGame:RandomPlayersQueue(new_table)
    local random_players = {}
    local all_players_id = {}
    for id, info in pairs(player_system.PLAYERS) do
        table.insert(all_players_id, id)
    end
    for i=1, #all_players_id do
        table.insert(random_players, table.remove(all_players_id, RandomInt(1, #all_players_id)))
    end
    random_players = table.shuffle(random_players)
    random_players = table.shuffle(random_players)
    random_players = table.shuffle(random_players)
    if new_table and #new_table > 0 then
        random_players = new_table
    end
    CustomNetTables:SetTableValue("game_info", "round_queue", {players = random_players})
    HubGame.QUEUE_HUB_PLAYERS = random_players
end

-- Переход хода, если все походили то запускать мини игру
function HubGame:StartQueuePlayers()
    if #HubGame.QUEUE_HUB_PLAYERS > 0 then
        local random_player = table.remove(HubGame.QUEUE_HUB_PLAYERS, 1)
        if random_player ~= nil then
            HubGame:StartQueuePlayer(random_player)
        end
    else
        HubGame:StartPreMiniGame()
    end
end

-- Текущий игрок получает ход
function HubGame:StartQueuePlayer(id)
    if player_system.PLAYERS[id] then
        local ability_random_steps = player_system.PLAYERS[id].hero:FindAbilityByName("ability_random_steps")
        if ability_random_steps then
            ability_random_steps:SetHidden(false)
        end
        SetCameraAll(player_system.PLAYERS[id].hero)
        CustomGameEventManager:Send_ServerToAllClients( "notification_player_step", {id = id} )
        player_system.PLAYERS[id].hero.particle_dice = ParticleManager:CreateParticle("particles/dice_particle.vpcf", PATTACH_OVERHEAD_FOLLOW, player_system.PLAYERS[id].hero)
    end
end

-- Функция из абилки, получает выпадающие ходы и начинает двигаться
function HubGame:PlayerSelectSteps(id, steps)
    if player_system.PLAYERS[id] then
        player_system.PLAYERS[id].steps = steps
    end
    local current_point = HubGame.CURRENT_POINT_STEP[id]
    local hero = player_system.PLAYERS[id].hero
    if not HubGame:CheckMorePath(hero, current_point) then
        HubGame:PlayerLetsStep(hero, current_point)
    end
end

-- Проверка текущая позиция имеет несколько поворотов или нет?
function HubGame:CheckMorePath(hero, current_point)
    if HubGame.POINTS_WITH_ROTATE[current_point] ~= nil then
        CustomGameEventManager:Send_ServerToAllClients("game_is_select_rotation", {id = hero:GetPlayerOwnerID(), arrow_type = HubGame.POINTS_WITH_ROTATE[current_point]})
        return true
    end
    return false
end

function HubGame:IsChestPoint(current_point)
    if HubGame.CURRENT_TYPE_POINTS[current_point] == "cup" then
        return true
    end
    return false
end

-- Начать движение по некст клетке 
-- current_point нужна для нахождения следующей точки
-- rotate_point игнорирует таблицу связей и игрок сразу идет на определенную точку
function HubGame:PlayerLetsStep(hero, current_point, rotate_point)
    local id = hero:GetPlayerOwnerID()
    local next_point_name = nil
    if rotate_point ~= nil then
        next_point_name = rotate_point
    else
        next_point_name = HubGame.POINTS_CONNECTION[current_point]
    end

    local next_point_entities = Entities:FindByName(nil, next_point_name)
    if next_point_entities then
        Timers:CreateTimer(0.1, function()
            hero:MoveToPosition(next_point_entities:GetAbsOrigin())
            local length = hero:GetAbsOrigin() - next_point_entities:GetAbsOrigin()
            length.z = 0
            length = length:Length2D()
            if length <= 40 then
                local modifier_ability_random_steps_count = hero:FindModifierByName("modifier_ability_random_steps_count")
                if modifier_ability_random_steps_count then
                    modifier_ability_random_steps_count:DecrementStackCount()
                    if modifier_ability_random_steps_count:GetStackCount() <= 0 then
                        modifier_ability_random_steps_count:Destroy()
                    end
                end
                if player_system.PLAYERS[id] then
                    player_system.PLAYERS[id].steps = player_system.PLAYERS[id].steps - 1
                end
                if player_system.PLAYERS[id].steps > 0 then
                    if HubGame:IsChestPoint(next_point_entities:GetName()) then
                        CustomGameEventManager:Send_ServerToAllClients( "game_is_notification_open_chest", {player_owner = id, next_point_name = next_point_name})
                    elseif not HubGame:CheckMorePath(hero, next_point_name) then
                        HubGame.CURRENT_POINT_STEP[id] = next_point_name
                        HubGame:PlayerLetsStep(hero, next_point_name)
                    end
                else
                    HubGame.CURRENT_POINT_STEP[id] = next_point_name
                    Timers:CreateTimer(1, function()
                        HubGame:StartQueuePlayers()
                    end)
                    HubGame:CheckFreePosition(hero, next_point_name, id)
                    HubGame:CheckBonusFromThisPosition(id, next_point_name, hero)
                end
                return
            end
            return 0.1
        end)
    end
end

-- Если несколько игроков встали на одну и ту же точку, то подвинуть игроков
function HubGame:CheckFreePosition(hero, point, id_step)
    local find_hero = nil
    for id, info in pairs(player_system.PLAYERS) do
        if info.hero ~= hero then
            if HubGame.CURRENT_POINT_STEP[id] == HubGame.CURRENT_POINT_STEP[id_step] then
                local point_step = Entities:FindByName(nil, HubGame.CURRENT_POINT_STEP[id])
                if point_step then
                    local length = (point_step:GetAbsOrigin() - info.hero:GetAbsOrigin())
                    length.z = 0
                    length = length:Length2D()
                    if length < 100 then
                        info.hero:MoveToPosition(point_step:GetAbsOrigin() + RandomVector(150))
                    end
                end
            end
        end
    end
end

function HubGame:CheckBonusFromThisPosition(id, point_name, hero)
    local point_effect = HubGame.CURRENT_TYPE_POINTS[point_name]
    if point_effect == "hp_regen" then
        local heal = 4
        hero:EmitSound("Hero_Oracle.FalsePromise.Healed")
        local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_oracle/oracle_false_promise_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker )
        ParticleManager:ReleaseParticleIndex( effect_cast )
        Timers:CreateTimer(0.2, function()
            heal = heal - 1
            player_system:HeroModifyHealth(id, 1)
            if (heal <= 0) then
                return
            end
            return 0.2
        end)
    elseif point_effect == "kill" then
        
    elseif point_effect == "damage" then
        hero:EmitSound("Hero_Axe.Culling_Blade_Success")
        local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
        ParticleManager:SetParticleControl( effect_cast, 4, hero:GetOrigin() )
        ParticleManager:ReleaseParticleIndex( effect_cast )
        local kill_damage = 4
        Timers:CreateTimer(0.2, function()
            kill_damage = kill_damage - 1
            local new_health = player_system:HeroModifyHealth(id, -1)
            if new_health <= 0 then
                HubGame:KillPlayerAndRespawn(hero)
                return
            end
            if (kill_damage <= 0) then
                return
            end
            return 0.2
        end)
    elseif point_effect == "keys" then
        local midas_particle = ParticleManager:CreateParticle("particles/econ/items/alchemist/alchemist_midas_knuckles/alch_hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
	    ParticleManager:SetParticleControlEnt(midas_particle, 1, hero, PATTACH_POINT_FOLLOW, "attach_hitloc", hero:GetAbsOrigin(), false)
        ParticleManager:ReleaseParticleIndex(midas_particle)
        hero:EmitSound("DOTA_Item.Hand_Of_Midas")
        local keys_count = 10
        Timers:CreateTimer(0.2, function()
            keys_count = keys_count - 1
            player_system:HeroModifyKeys(id, 1)
            if (keys_count <= 0) then
                return nil
            end
            return 0.2
        end)
    end
end

function HubGame:StartPreMiniGame()
    HubGame.GET_CURRENT_PLAYERS_POINTS_IN_HUB = {}
    for id, player_info in pairs(player_system.PLAYERS) do
        if player_info.hero then
            HubGame.GET_CURRENT_PLAYERS_POINTS_IN_HUB[id] = player_info.hero:GetAbsOrigin()
        end
    end
    MiniGamesLib:StartRandomMiniGamesPre()
end

function HubGame:ReturnToHub()
    for id, player_info in pairs(player_system.PLAYERS) do
        if player_info.hero then
            player_info.hero.MINIGAME_RESPAWN_POS = nil
            player_info.hero:RespawnHero(false, false)
            player_info.hero:SetAbsOrigin(HubGame.GET_CURRENT_PLAYERS_POINTS_IN_HUB[id])
        end
    end
    Timers:CreateTimer(FrameTime(), function()
        AddNewModifierForAllHeroes("modifier_pummel_party_hub", -1)
        RemoveModifierForAllHeroes("modifier_fountain_invulnerability")
    end)
end

function HubGame:HowMuchPlayersInGame()
    local count = 0
    for id, player_info in pairs(player_system.PLAYERS) do
        if player_info.hero then
            count = count + 1
        end
    end
    return count
end

function HubGame:PlayerChestOpenedChecked(data)
    if data.PlayerID == nil then return end
    local player_id = data.PlayerID
    local is_open = data.is_open == 1
    CustomGameEventManager:Send_ServerToAllClients( "game_is_chest_select_all_clients", {} )
    if is_open then
        player_system:HeroModifyKeys(player_id, -40)
        local rewards_counter = player_system:HeroModifyRewards(player_id, 1)
        local particle = ParticleManager:CreateParticle("particles/crown_reached.vpcf", PATTACH_OVERHEAD_FOLLOW, player_system.PLAYERS[player_id].hero)
        ParticleManager:ReleaseParticleIndex(particle)
        if rewards_counter >= 5 then
            GameRules:SetGameWinner(player_system.PLAYERS[player_id].hero:GetTeamNumber())
            return
        end
        Timers:CreateTimer(3, function()
            HubGame:ChangeRandomPointCup()
        end)
        Timers:CreateTimer(9, function()
            SetCameraAll(player_system.PLAYERS[player_id].hero)
            HubGame:PlayerLetsStep(player_system.PLAYERS[player_id].hero, data.next_point_name)
        end)
    else
        HubGame:PlayerLetsStep(player_system.PLAYERS[player_id].hero, data.next_point_name)
    end
end

function HubGame:PlayerRotatePointNext(data)
    if data.PlayerID == nil then return end
    local player_id = data.PlayerID
    local hero = player_system.PLAYERS[player_id].hero
    HubGame:PlayerLetsStep(hero, nil, data.next_point)
    CustomGameEventManager:Send_ServerToAllClients( "game_is_close_arrows_select_all_clients", {} )
end

function HubGame:KillPlayerAndRespawn(hero)
    local save_point = hero:GetAbsOrigin()
    hero:ForceKill(false)
    HubGame:DroppedKeys(hero, save_point)
    local is_respawn = false
    Timers:CreateTimer(0.5, function()
        if not is_respawn then
            hero:RespawnHero(false, false)
            is_respawn = true
        end
        if hero:IsAlive() then
            local modifier_fountain_invulnerability = hero:FindModifierByName("modifier_fountain_invulnerability")
            if modifier_fountain_invulnerability then
                modifier_fountain_invulnerability:Destroy()
            end
            hero:SetAbsOrigin(save_point)
            return
        end
        return FrameTime()
    end)
end

function HubGame:DroppedKeys(hero, save_point)
    local player_id = hero:GetPlayerOwnerID()
    local keys_counter =  player_system.PLAYERS[player_id].keys
    if keys_counter > 0 then
        player_system:HeroModifyKeys(player_id, -keys_counter)
        for i=1, keys_counter do
            local random_pos = save_point + RandomVector(200)
            CreateModifierThinker(hero, nil, "modifier_soul_dropped_thinker", {}, random_pos, hero:GetTeamNumber(), false)
        end
    end
end