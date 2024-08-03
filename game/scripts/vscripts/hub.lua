_G.HubGame = class({})

HubGame.CURRENT_POINT_STEP = {}
HubGame.CURRENT_STATE = "HUB"
HubGame.QUEUE_HUB_PLAYERS = {}
HubGame.ROUND_NUMBER = 0

HubGame.POINTS_WITH_ROTATE = 
{
    ["hub_point_up_15"] = 
    {
        ["ability_change_rotate_down"] = "hub_point_down_1",
        ["ability_change_rotate_up"] = "hub_point_up_16",
    },
    ["hub_point_up_15"] = 
    {
        ["ability_change_rotate_down"] = "hub_point_down_1",
        ["ability_change_rotate_up"] = "hub_point_up_16",
    },
    ["hub_point_down_6"] = 
    {
        ["ability_change_rotate_left"] = "hub_point_left_1",
        ["ability_change_rotate_down"] = "hub_point_down_7",
    },
    ["hub_point_up_22"] = 
    {
        ["ability_change_rotate_up"] = "hub_point_up_23",
        ["ability_change_rotate_right"] = "hub_point_right_1",
    },
}

HubGame.POINTS_CONNECTION = {}
HubGame.POINTS_CONNECTION["hub_point_center"] = "hub_point_up_1"
HubGame.POINTS_CONNECTION["hub_point_up_32"] = "hub_point_center"
HubGame.POINTS_CONNECTION["hub_point_left_3"] = "hub_point_up_17"
HubGame.POINTS_CONNECTION["hub_point_right_7"] = "hub_point_up_24"
HubGame.POINTS_CONNECTION["hub_point_down_11"] = "hub_point_up_17"

-- Инициализия текущей точки на старте
for i=0, 4 do
    HubGame.CURRENT_POINT_STEP[i] = "hub_point_center"
end

HubGame.POINT_TYPE = 
{
    [1] = "chest", -- Сундук
    [2] = "useless", -- Вопросительный знак
    [3] = "damage", -- Нанесение урона
    [4] = "kill", -- Убийство
    [5] = "hp_regen", -- Хп реген
    [6] = "keys", -- Ключи
}

HubGame.CURRENT_TYPE_POINTS = {}
HubGame.CURRENT_TYPE_POINTS_UNITS = {}
HubGame.GET_CURRENT_PLAYERS_POINTS_IN_HUB = {}

function HubGame:ChangeRandomPointCup()
    local max = 0
    for _, point in pairs(HubGame.POINTS_CONNECTION) do
        max = max + 1
    end
    local random_point = RandomInt(15, max)
    local cringe_random = 0
    local point_cup = nil
    for _, point in pairs(HubGame.POINTS_CONNECTION) do
        cringe_random = cringe_random + 1
        if cringe_random >= random_point then
            point_cup = point
            break
        end
    end
    if point_cup ~= nil then
        local unit = HubGame.CURRENT_TYPE_POINTS_UNITS[point_cup]
        if unit then
            unit:SetMaterialGroup("skin8")
            SetCameraAll(unit)
            Timers:CreateTimer(3.5, function()
                UnlockCameraAll()
            end)
        end
        local pummel_cup_origin = unit:GetAbsOrigin() + RandomVector(150)
        pummel_cup_origin.z = GetGroundHeight(pummel_cup_origin, nil) + 350
        local pummel_cup = CreateUnitByName("pummel_cup", pummel_cup_origin, false, nil, nil, DOTA_TEAM_NEUTRALS)
        pummel_cup:SetAbsOrigin(pummel_cup_origin)
        pummel_cup:AddNewModifier(pummel_cup, nil, "modifier_pummel_cup", {})
        HubGame.CURRENT_TYPE_POINTS[point_cup] = "cup"
    end
end

function HubGame:CreatePoint(point_name, abs)
    local origin = abs
    origin.z = GetGroundHeight(origin, nil) + 10
    -- differnt height
    if (point_name == "hub_point_up_13" or point_name == "hub_point_up_14") then
        origin.z = origin.z + 10
    end
    if (point_name == "hub_point_down_6" or point_name == "hub_point_left_1" or point_name == "hub_point_up_17") then
        origin.z = origin.z + 15
    end
    if point_name == "hub_point_up_32" then
        print("kkk", point_name)
    end
    local pedestal = CreateUnitByName("pummel_point", origin, false, nil, nil, DOTA_TEAM_NEUTRALS)
    local random_effect = RandomInt(1, 6)
    pedestal:SetAbsOrigin(origin)
    pedestal:SetMaterialGroup("skin"..random_effect)
    pedestal:AddNewModifier(pedestal, nil, "modifier_pummel_party_pedestal", {})
    HubGame.CURRENT_TYPE_POINTS[point_name] = HubGame.POINT_TYPE[random_effect]
    HubGame.CURRENT_TYPE_POINTS_UNITS[point_name] = pedestal
    pedestal:SetForwardVector(Vector(0, 1, 0))

    -- different settings
    if (point_name == "hub_point_center") then
        pedestal:SetMaterialGroup("skin7")
        HubGame.CURRENT_TYPE_POINTS[point_name] = "start"
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
                HubGame:CreatePoint("hub_point_left_"..i, left:GetAbsOrigin())
            end
        end

        local right = Entities:FindByName(nil, "hub_point_right_"..i)
        if right then
            local next_number_point = right:Attribute_GetIntValue('next_point', -1)
            if next_number_point ~= -1 and next_number_point ~= 0 then
                HubGame.POINTS_CONNECTION["hub_point_right_"..i] = "hub_point_right_"..next_number_point
                HubGame:CreatePoint("hub_point_right_"..i, right:GetAbsOrigin())
            end
        end

        local up = Entities:FindByName(nil, "hub_point_up_"..i)
        if up then
            local next_number_point = up:Attribute_GetIntValue('next_point', -1)
            if next_number_point ~= -1 and next_number_point ~= 0 then
                HubGame.POINTS_CONNECTION["hub_point_up_"..i] = "hub_point_up_"..next_number_point
                HubGame:CreatePoint("hub_point_up_"..i, up:GetAbsOrigin())
            end
        end

        local down = Entities:FindByName(nil, "hub_point_down_"..i)
        if down then
            local next_number_point = down:Attribute_GetIntValue('next_point', -1)
            if next_number_point ~= -1 and next_number_point ~= 0 then
                HubGame.POINTS_CONNECTION["hub_point_down_"..i] = "hub_point_down_"..next_number_point
                HubGame:CreatePoint("hub_point_down_"..i, down:GetAbsOrigin())
            end
        end
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
            if IsInToolsMode() then
                AddNewModifierForAllHeroes("modifier_move_control", -1)
            end
            AddNewAbilityForAllHeroes({"ability_random_steps", "ability_change_rotate_left", "ability_change_rotate_right", "ability_change_rotate_up", "ability_change_rotate_down"})
            HubGame:ChangeRandomPointCup()
            Timers:CreateTimer(3, function()
                HubGame:RandomPlayersQueue()
                HubGame:StartQueuePlayers()
            end)
        else
            print("kkk")
            return 0.1
        end
    end)
end

-- Перерандом кто каким ходит
function HubGame:RandomPlayersQueue()
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
        for abilities, point in pairs(HubGame.POINTS_WITH_ROTATE[current_point]) do
            local find_ability = hero:FindAbilityByName(abilities)
            if find_ability then
                find_ability:SetHidden(false)
                find_ability.next_point = point 
            end
        end
        return true
    end
    return false
end

-- Начать движение по некст клетке 
-- current_point нужна для нахождения следующей точки
-- rotate_point игнорирует таблицу связей и игрок сразу идет на определенную точку
function HubGame:PlayerLetsStep(hero, current_point, rotate_point)
    local id = hero:GetPlayerOwnerID()
    if player_system.PLAYERS[id] then
        player_system.PLAYERS[id].steps = player_system.PLAYERS[id].steps - 1
    end
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
                if player_system.PLAYERS[id].steps > 0 then
                    if not HubGame:CheckMorePath(hero, next_point_name) then
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
                local modifier_ability_random_steps_count = hero:FindModifierByName("modifier_ability_random_steps_count")
                if modifier_ability_random_steps_count then
                    modifier_ability_random_steps_count:DecrementStackCount()
                    if modifier_ability_random_steps_count:GetStackCount() <= 0 then
                        modifier_ability_random_steps_count:Destroy()
                    end
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
        local effect_cast = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker )
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
        hero:EmitSound("Hero_Axe.Culling_Blade_Success")
        local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
        ParticleManager:SetParticleControl( effect_cast, 4, hero:GetOrigin() )
        ParticleManager:ReleaseParticleIndex( effect_cast )
        local kill_damage = 4
        Timers:CreateTimer(0.2, function()
            kill_damage = kill_damage - 1
            player_system:HeroModifyHealth(id, -1)
            if (kill_damage <= 0) then
                return nil
            end
            return 0.2
        end)
    elseif point_effect == "keys" then
        local midas_particle = ParticleManager:CreateParticle("particles/econ/items/alchemist/alchemist_midas_knuckles/alch_hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
	    ParticleManager:SetParticleControlEnt(midas_particle, 1, hero, PATTACH_POINT_FOLLOW, "attach_hitloc", hero:GetAbsOrigin(), false)
        ParticleManager:ReleaseParticleIndex(midas_particle)
        hero:EmitSound("DOTA_Item.Hand_Of_Midas")
        local keys_count = 4
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