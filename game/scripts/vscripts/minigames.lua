_G.MiniGamesLib = class({})
MiniGamesLib.CurrentMiniGame = nil
MiniGamesLib.PLAYERS_READY_LIST = {}
MiniGamesLib.MINI_GAME_TIMER = nil
MiniGamesLib.SCORES_COUNTER = {}
MiniGamesLib.QUEUE_PLAYERS = {}
MiniGamesLib.MiniGamesList =
{
    "warning_light",
    "sniper_duel",
    "destroy_blocks_lava",
    "kennon_circle",
    "magma_game",
    "grab_crown",
    "hot_potato",
    "gift_or_ability",

    --"dota_run",
    --"danger_spike",
}
MiniGamesLib.CURRENT_MINIGAMES_LIST = table.deepcopy(MiniGamesLib.MiniGamesList)

MiniGamesLib.OnlyDieGames =
{
    ["warning_light"] = true,
    ["kennon_circle"] = true,
    ["destroy_blocks_lava"] = true,
    ["magma_game"] = true,
    ["hot_potato"] = true,
}

MiniGamesLib.GameWithScore = 
{
    ["sniper_duel"] = true,
    ["grab_crown"] = true,
    ["gift_or_ability"] = true,
    ["dota_run"] = true,
}

--[[
    - Доделать дотаран и гифты
    11. Снежный спин - Проложите себе путь к победе, сталкивая других игроков с края этой скользкой платформы в мрачную пропасть. Очередность смерти игроков определяет количество очков за раунд: побеждает игрок, набравший больше всего очков после 3 раундов!
    12. Спринт волшебников - Избегайте препятствий, пролетая по этому опасному маршруту. Пролетайте сквозь магические кольца, чтобы набрать очки. Игрок, набравший больше всего очков, побеждает.
    13. Жуткие Шипы - Уклоняйтесь от шипов, прыгая или приседая, чтобы стать последним оставшимся игроком.
    14. Эгоистичный шаг - Выбирайте, быть эгоистичным или нет, выбирайте мост осторожно, потому что если несколько игроков выберут один и тот же мост, он рухнет, и вы ничего не получите.
    9. Минный хаос - Запомните стрелки, показанные в каждом раунде, и двигайтесь так, чтобы уклоняться от взрывов мин. Побеждает последний выживший игрок.
    15. Зевс - Один игрок Зевс, он бьет молнией по полу, разрушая его, открывая шипы внизу. Если игрок с молнией убьет всех остальных, он победит. Побеждает тот кто продержиться отведённое время и не упадёт!
]]

function MiniGamesLib:StartRandomMiniGamesPre()
    MiniGamesLib.SCORES_COUNTER = {}
    MiniGamesLib.QUEUE_PLAYERS = {}
    if #MiniGamesLib.CURRENT_MINIGAMES_LIST <= 0 then
        MiniGamesLib.CURRENT_MINIGAMES_LIST = table.deepcopy(MiniGamesLib.MiniGamesList)
    end
    local get_random_minigame = table.remove(MiniGamesLib.CURRENT_MINIGAMES_LIST, RandomInt(1, #MiniGamesLib.CURRENT_MINIGAMES_LIST))
    MiniGamesLib.CurrentMiniGame = get_random_minigame
    MiniGamesLib.PLAYERS_READY_LIST = {}
    if IsInToolsMode() then
        for id, player_info in pairs(player_system.PLAYERS) do
            if player_info.is_bot then
                MiniGamesLib.PLAYERS_READY_LIST[id] = true
            end
        end
    end
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

function MiniGamesLib:UpdateScore(id, score)
    if MiniGamesLib.SCORES_COUNTER[id] == nil then
        MiniGamesLib.SCORES_COUNTER[id] = 0
    end
    MiniGamesLib.SCORES_COUNTER[id] = MiniGamesLib.SCORES_COUNTER[id] + score
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
    local thinkers = {}
    local mini_game_timers = {}
    local lava_blocks = {}
    local magma_blocks = {}
    CustomGameEventManager:Send_ServerToAllClients("close_pre_minigame_info", {})
    RemoveModifierForAllHeroes("modifier_pummel_party_pre_mini_game")
    AddNewModifierForAllHeroes("modifier_move_control", -1)
    local game_time = 45
    if IsInToolsMode() then
        --game_time = 20
    end

    -- Снайперская дуэль
    if game_name == "sniper_duel" then
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

    -- Прожекторы
    if game_name == "warning_light" then
        game_time = 1200
        for id, player_info in pairs(player_system.PLAYERS) do
            if player_info.hero then
                hero = player_info.hero
                hero:SetCamera(hero)
            end
        end
        AddNewModifierForAllHeroes("modifier_flashlight_debuff", -1)
        local warning_light_spawn = Entities:FindByName(nil, "warning_light_spawn")
        if warning_light_spawn then
            for i=0, 20 do
                AddFOWViewer(i, warning_light_spawn:GetAbsOrigin(), 5000, 3, false)
            end
            local modifier_warning_light_thinker = CreateModifierThinker(nil, nil, "modifier_warning_light_thinker", {duration = game_time}, warning_light_spawn:GetAbsOrigin(), DOTA_TEAM_NEUTRALS, false)
            table.insert(thinkers, modifier_warning_light_thinker)
        end
    end

    -- kennon_circle
    if game_name == "kennon_circle" then
        game_time = 1200
        for id, player_info in pairs(player_system.PLAYERS) do
            if player_info.hero then
                hero = player_info.hero
                hero:SetCamera(hero)
            end
        end
        local level = 1
        local timer = Timers:CreateTimer(2, function()
            if game_time <= 1200 - 120 then
                level = 3
            elseif game_time <= 1200 - 60 then
                level = 2
            end
            local max_spawners = 1
            local kennon_circle_spawn_arrow_up = Entities:FindAllByName("kennon_circle_spawn_arrow_up")
            if kennon_circle_spawn_arrow_up then
                for i=1, max_spawners do
                    self:SpawnCircle(table.remove(kennon_circle_spawn_arrow_up, RandomInt(1, #kennon_circle_spawn_arrow_up)), level)
                end
            end
            local kennon_circle_spawn_arrow_right = Entities:FindAllByName("kennon_circle_spawn_arrow_right")
            if kennon_circle_spawn_arrow_right then
                for i=1, max_spawners do
                    self:SpawnCircle(table.remove(kennon_circle_spawn_arrow_right, RandomInt(1, #kennon_circle_spawn_arrow_right)), level)
                end
            end
            local kennon_circle_spawn_arrow_left = Entities:FindAllByName("kennon_circle_spawn_arrow_left")
            if kennon_circle_spawn_arrow_left then
                for i=1, max_spawners do
                    self:SpawnCircle(table.remove(kennon_circle_spawn_arrow_left, RandomInt(1, #kennon_circle_spawn_arrow_left)), level)
                end
            end
            local kennon_circle_spawn_arrow_down = Entities:FindAllByName("kennon_circle_spawn_arrow_down")
            if kennon_circle_spawn_arrow_down then
                for i=1, max_spawners do
                    self:SpawnCircle(table.remove(kennon_circle_spawn_arrow_down, RandomInt(1, #kennon_circle_spawn_arrow_down)), level)
                end
            end
            return 3
        end)
        table.insert(mini_game_timers, timer)
    end

    -- destroy_blocks_lava
    if game_name == "destroy_blocks_lava" then
        game_time = 1200
        for id, player_info in pairs(player_system.PLAYERS) do
            if player_info.hero then
                hero = player_info.hero
                hero:SetCamera(hero)
            end
        end
        local destroy_blocks_lava_center = Entities:FindAllByName("destroy_blocks_lava_center")
        for _, entity in pairs(destroy_blocks_lava_center) do
            local model_visual = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/lava.vmdl"})
            model_visual:SetAbsOrigin(entity:GetAbsOrigin())
            model_visual:SetRenderColor(255, 255, 255)
            table.insert(lava_blocks, model_visual)
        end
        local timer = Timers:CreateTimer(2, function()
            local timer_destroy_block = 2
            local blocks_counter = 2
            if game_time <= 1200 - 45 then
                blocks_counter = 1.5
            elseif game_time <= 1200 - 30 then
                blocks_counter = 1.1
            end
            local broken_blocks = table.random_some(lava_blocks, math.floor(#lava_blocks / blocks_counter))
            Timers:CreateTimer(FrameTime(), function()
                timer_destroy_block = timer_destroy_block - FrameTime()
                for _, red_block in pairs(broken_blocks) do
                    red_block:SetRenderColor(255 * (1 - (timer_destroy_block / 2)), 255 * ((timer_destroy_block / 2)), 255 * ((timer_destroy_block / 2)))
                end
                if timer_destroy_block > 0 then
                    return FrameTime()
                end
                for _, red_block in pairs(broken_blocks) do
                    self:SunstrikePoint(red_block:GetAbsOrigin())
                end
                Timers:CreateTimer(0.5, function()
                    for _, reset_block in pairs(lava_blocks) do
                        reset_block:SetRenderColor(255, 255, 255)
                    end
                end)
            end)
            return 7
        end)
        table.insert(mini_game_timers, timer)
    end

    if game_name == "magma_game" then
        game_time = 1200
        for id, player_info in pairs(player_system.PLAYERS) do
            if player_info.hero then
                hero = player_info.hero
                hero:SetCamera(hero)
                local ability_mirana_mini_game = hero:AddAbility("ability_mirana_mini_game")
                if ability_mirana_mini_game then
                    ability_mirana_mini_game:SetHidden(false)
                    ability_mirana_mini_game:SetLevel(1)
                end
            end
        end
        local magma_game_blocks = Entities:FindAllByName("magma_block")
        for _, entity in pairs(magma_game_blocks) do
            local model_visual = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/magma_base.vmdl"})
            model_visual:SetAbsOrigin(entity:GetAbsOrigin())
            table.insert(magma_blocks, model_visual)
        end
        local how_much_targets = #magma_blocks
        local timer = Timers:CreateTimer(1, function()
            local maximum_targets = 25
            local magma_center = Entities:FindByName(nil, "magma_center")
            local unactivate_blocks = {}
            local new_targets_to_lava = {}
            for _, magma_target in pairs(magma_blocks) do
                if magma_target and magma_target:GetModelName() == "models/magma_base.vmdl" then
                    table.insert(unactivate_blocks, magma_target)
                end
            end
            table.sort(unactivate_blocks, function(a, b)
                return (magma_center:GetAbsOrigin() - a:GetAbsOrigin()):Length2D() > (magma_center:GetAbsOrigin() - b:GetAbsOrigin()):Length2D()
            end)
            for _, unactivate_block in pairs(unactivate_blocks) do
                if maximum_targets > 0 then
                    maximum_targets = maximum_targets - 1
                    if how_much_targets > 4 then
                        local modifier_magma_block_custom = CreateModifierThinker(nil, nil, "modifier_magma_block_custom", {}, unactivate_block:GetAbsOrigin(), DOTA_TEAM_NEUTRALS, false)
                        table.insert(thinkers, modifier_magma_block_custom)
                        unactivate_block:SetModel("models/magma_lava.vmdl")
                        how_much_targets = how_much_targets - 1
                    end
                end
            end
            if how_much_targets > 4 then
                return 8
            end
        end)
        table.insert(mini_game_timers, timer)
    end

    if game_name == "grab_crown" then
        local random_abilities_list = 
        {
            "ability_pummel_grab_crown_1",
            "ability_pummel_grab_crown_2",
            "ability_pummel_grab_crown_3",
            "ability_pummel_grab_crown_4",
            "ability_pummel_grab_crown_5",
            "ability_pummel_grab_crown_6",
        }
        for id, player_info in pairs(player_system.PLAYERS) do
            if player_info.hero then
                hero = player_info.hero
                hero:SetCamera(hero)
                local ability_walrus_punch_mini_game = hero:AddAbility("ability_walrus_punch_mini_game")
                if ability_walrus_punch_mini_game then
                    ability_walrus_punch_mini_game:SetHidden(false)
                    ability_walrus_punch_mini_game:SetLevel(1)
                end
                local random_ability_in_game = hero:AddAbility(random_abilities_list[RandomInt(1, #random_abilities_list)])
                if random_ability_in_game then
                    random_ability_in_game:SetHidden(false)
                    random_ability_in_game:SetLevel(1)
                end
            end
        end
        local crown_spawn = Entities:FindByName(nil, "crown_spawn")
        if crown_spawn then
            local modifier_crown_spawn = CreateModifierThinker(nil, nil, "modifier_crown_spawn", {}, crown_spawn:GetAbsOrigin(), DOTA_TEAM_NEUTRALS, false)
            table.insert(thinkers, modifier_crown_spawn)
        end
    end

    if game_name == "hot_potato" then
        local random_abilities_list = 
        {
            "ability_pummel_potato_1",
            "ability_pummel_potato_2",
            "ability_pummel_potato_3",
            "ability_pummel_potato_4",
            "ability_pummel_potato_5",
            "ability_pummel_potato_6",
        }
        game_time = 1200
        for id, player_info in pairs(player_system.PLAYERS) do
            if player_info.hero then
                hero = player_info.hero
                hero:SetCamera(hero)
                local ability_normal_punch_mini_game = hero:AddAbility("ability_normal_punch_mini_game")
                if ability_normal_punch_mini_game then
                    ability_normal_punch_mini_game:SetHidden(false)
                    ability_normal_punch_mini_game:SetLevel(1)
                end
                local random_ability_in_game = hero:AddAbility(random_abilities_list[RandomInt(1, #random_abilities_list)])
                if random_ability_in_game then
                    random_ability_in_game:SetHidden(false)
                    random_ability_in_game:SetLevel(1)
                end
            end
        end
        self:UpdatePotato(nil, 30)
    end

    if game_name == "gift_or_ability" then
        print("kkk")
        local gift_or_ability_center = Entities:FindByName(nil, "gift_or_ability_center")
        local modifier_gift_or_ability_center = CreateModifierThinker(nil, nil, "modifier_gift_or_ability_center", {}, gift_or_ability_center:GetAbsOrigin(), DOTA_TEAM_NEUTRALS, false)
        table.insert(thinkers, modifier_gift_or_ability_center)
        for id, player_info in pairs(player_system.PLAYERS) do
            print("ddd")
            if player_info.hero then
                hero = player_info.hero
                hero:SetCamera(hero)
                local ability_walrus_kick_mini_game = hero:AddAbility("ability_walrus_kick_mini_game")
                if ability_walrus_kick_mini_game then
                    ability_walrus_kick_mini_game:SetHidden(false)
                    ability_walrus_kick_mini_game:SetLevel(1)
                end
            end
        end
    end

    if game_name == "dota_run" then
        game_time = 1200
    end

    MiniGamesLib.MINI_GAME_TIMER = Timers:CreateTimer(1, function()
        game_time = game_time - 1
        if MiniGamesLib.OnlyDieGames[game_name] then
            if self:HowMuchIsAlive() <= 1 then
                self:RemoveThinkerTable(thinkers)
                self:RemoveMiniGameTimers(mini_game_timers)
                Timers:CreateTimer(1, function()
                    self:RemoveThinkerTable(lava_blocks)
                    self:RemoveThinkerTable(magma_blocks)
                    local alive_hero = self:GetAliveHero()
                    if alive_hero then
                        self:MiniGameIsEnd(alive_hero:GetPlayerOwnerID())
                    else
                        self:MiniGameIsEnd()
                    end
                end)
                return
            end
        end
        if game_time <= 0 then
            self:RemoveThinkerTable(thinkers)
            self:MiniGameIsEnd()
            return
        end
        return 1
    end)
end

function MiniGamesLib:UpdatePotato(target, duration)
    if not target then
        local heroes = {}
        for id, player_info in pairs(player_system.PLAYERS) do
            if player_info.hero and player_info.hero:IsAlive() then
                table.insert(heroes, player_info.hero)
            end
        end
        if #heroes > 1 then
            target = heroes[RandomInt(1, #heroes)]
        end
    end
    if target then
        target:AddNewModifier(target, nil, "modifier_hot_potato_debuff", {duration = duration})
    end
end

function MiniGamesLib:RemoveThinkerTable(table)
    for _, thinker in pairs(table) do
        if thinker and not thinker:IsNull() then
            UTIL_Remove(thinker)
        end
    end
end

function MiniGamesLib:RemoveMiniGameTimers(table)
    for _, timer in pairs(table) do
        if timer then
            Timers:RemoveTimer(timer)
        end
    end
end

function MiniGamesLib:HowMuchIsAlive()
    local count = 0
    for id, player_info in pairs(player_system.PLAYERS) do
        if player_info.hero and player_info.hero:IsAlive() then
            count = count + 1
        end
    end
    return count
end

function MiniGamesLib:GetAliveHero()
    for id, player_info in pairs(player_system.PLAYERS) do
        if player_info.hero and player_info.hero:IsAlive() then
            return player_info.hero
        end
    end
    return nil
end

function MiniGamesLib:MiniGameIsEnd(winner)
    -- Отдельный подсчет для игр где есть смерть
    if MiniGamesLib.OnlyDieGames[MiniGamesLib.CurrentMiniGame] then
        if winner ~= nil then
            table.insert(MiniGamesLib.QUEUE_PLAYERS, winner)
            self:WinnerEffect(winner)
        end
        MiniGamesLib.QUEUE_PLAYERS = table.ReverseArray(MiniGamesLib.QUEUE_PLAYERS)
        MiniGamesLib:GiveWinnerKeys(MiniGamesLib.QUEUE_PLAYERS)
    end

    -- Для игр где есть счет
    if MiniGamesLib.GameWithScore[MiniGamesLib.CurrentMiniGame] then
        for id, player_info in pairs(player_system.PLAYERS) do
            if not MiniGamesLib.SCORES_COUNTER[id] then
                MiniGamesLib.SCORES_COUNTER[id] = 0
            end
        end
        local scores_table = {}
        for id, score in pairs(MiniGamesLib.SCORES_COUNTER) do
            local player_score = {}
            player_score.player_id = id
            player_score.score = score
            table.insert(scores_table, player_score)
        end
        if #scores_table > 0 then
            table.sort(scores_table, function(a, b)
                return a.score > b.score
            end)
            MiniGamesLib.QUEUE_PLAYERS = {}
            for _, info in pairs(scores_table) do
                table.insert(MiniGamesLib.QUEUE_PLAYERS, info.player_id)
            end
            self:WinnerEffect(MiniGamesLib.QUEUE_PLAYERS[1])
            MiniGamesLib:GiveWinnerKeys(MiniGamesLib.QUEUE_PLAYERS)
        end
    end

    RemoveModifierForAllHeroes("modifier_crown_spawn_buff")
    RemoveModifierForAllHeroes("modifier_move_control")
    RemoveModifierForAllHeroes("modifier_flashlight_debuff")
    self:DeletedGamesAbility()
    HubGame:ReturnToHub()
    HubGame:RandomPlayersQueue(MiniGamesLib.QUEUE_PLAYERS)
    Timers:CreateTimer(FrameTime(), function()
        UnlockCameraAll()
        HubGame:StartQueuePlayers()
    end)
end

function MiniGamesLib:GiveWinnerKeys(table)
    local keys_counter = 6
    for _, player_id in pairs(table) do
        player_system:HeroModifyKeys(player_id, keys_counter)
        keys_counter = keys_counter - 1
    end
end

function MiniGamesLib:WinnerEffect(id)
    if player_system.PLAYERS[id] then
        local hero = player_system.PLAYERS[id].hero
        local nWinnerParticleIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_OVERHEAD_FOLLOW, hero)
	    ParticleManager:ReleaseParticleIndex(nWinnerParticleIndex)
	    EmitSoundOn("Hero_LegionCommander.Duel.Victory", hero)
    end
end

function MiniGamesLib:DeletedGamesAbility()
    local games_abilities = 
    {
        "ability_sniper_mini_game",
        "ability_mirana_mini_game",
        "ability_walrus_punch_mini_game",
        "ability_normal_punch_mini_game",
        "ability_walrus_kick_mini_game",
        "ability_pummel_grab_crown_1",
        "ability_pummel_grab_crown_2",
        "ability_pummel_grab_crown_3",
        "ability_pummel_grab_crown_4",
        "ability_pummel_grab_crown_5",
        "ability_pummel_grab_crown_6",
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

function MiniGamesLib:SpawnCircle(entity, level)
    local random_units = 
    {
        [1] =
        {
            {"npc_dota_creep_badguys_melee", {"pudge_meat_hook"}},
            {"npc_dota_creep_badguys_melee", {"mirana_arrow"}},
            {"npc_dota_creep_badguys_melee", {"rattletrap_hookshot"}},
            {"npc_dota_creep_badguys_melee", {"tiny_tree_grab", "tiny_toss_tree"}},
        },
        [2] =
        {
            {"npc_dota_creep_badguys_melee", {"mars_spear"}},
            {"npc_dota_creep_badguys_melee", {"shredder_chakram", "shredder_return_chakram"}},
            {"npc_dota_creep_badguys_melee", {"magnataur_shockwave"}},
            {"npc_dota_creep_badguys_melee", {"hoodwink_sharpshooter", "hoodwink_sharpshooter_release"}},
        },
        [3] =
        {
            --{"npc_dota_creep_badguys_melee", {"ancient_apparition_ice_blast", "ancient_apparition_ice_blast_release"}},
            {"npc_dota_creep_badguys_melee", {"queenofpain_sonic_wave"}},
            {"npc_dota_creep_badguys_melee", {"snapfire_mortimer_kisses"}},
            {"npc_dota_creep_badguys_melee", {"invoker_chaos_meteor"}},
        },
    }
    if entity then
        local unit_info = random_units[level][RandomInt(1, #random_units[level])]
        local unit = CreateUnitByName(unit_info[1], entity:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
        if unit then
            if entity:GetName() == "kennon_circle_spawn_arrow_up" then
                unit:SetForwardVector(Vector(0,-1,0))
            elseif entity:GetName() == "kennon_circle_spawn_arrow_right" then
                unit:SetForwardVector(Vector(-1,0,0))
            elseif entity:GetName() == "kennon_circle_spawn_arrow_down" then
                unit:SetForwardVector(Vector(0,1,0))
            end
            unit:RemoveAllAbilities()
            unit:SetAbsOrigin(entity:GetAbsOrigin())
            for _, ability_name in pairs(unit_info[2]) do
                local ability = unit:AddAbility(ability_name)
                if ability then
                    ability:SetLevel(ability:GetMaxLevel())
                end
            end
            unit:AddNewModifier(unit, nil, "modifier_ability_cast_range_custom", {})
            local point = unit:GetAbsOrigin() + unit:GetForwardVector() * 5000
            if unit:GetUnitName() == "npc_dota_hero_tiny" then
                unit:AddNewModifier(unit, unit:FindAbilityByName("tiny_tree_grab"), "modifier_tiny_tree_grab", {})
                unit:SetCursorPosition(point)
                unit:FindAbilityByName("tiny_toss_tree"):OnSpellStart()
            else
                local ability = unit:GetAbilityByIndex(0)
                if ability:GetAbilityName() == "invoker_chaos_meteor" then
                    point = unit:GetAbsOrigin() + unit:GetForwardVector() * 500
                end
                if ability:GetAbilityName() == "snapfire_mortimer_kisses" then
                    point = unit:GetAbsOrigin() + unit:GetForwardVector() * RandomInt(500, 3000)
                end
                unit:SetCursorPosition(point)
                if ability:GetAbilityName() == "snapfire_mortimer_kisses" then
                    ability:SetChanneling(true)
                end
                ability:OnSpellStart()
                if (ability:GetAbilityName() == "hoodwink_sharpshooter" or ability:GetAbilityName() == "ancient_apparition_ice_blast" or ability:GetAbilityName() == "shredder_chakram") then
                    Timers:CreateTimer(1, function()
                        local second_ability = unit:FindAbilityByName(unit_info[2][2])
                        if second_ability then
                            second_ability:SetLevel(1)
                            second_ability:OnSpellStart()
                        end
                    end)
                end
                if ability:GetAbilityName() == "snapfire_mortimer_kisses" then
                    Timers:CreateTimer(1, function()
                        unit:Stop()
                    end)
                end
            end
            Timers:CreateTimer(2, function()
                if unit and not unit:IsNull() then
                    unit:Stop()
                    unit:AddNewModifier(unit, nil, "modifier_hero_hidden_custom", {})
                end
                Timers:CreateTimer(10, function()
                    if unit and not unit:IsNull() then
                        UTIL_Remove(unit)
                    end
                end)
            end)
        end
    end
end

function MiniGamesLib:SunstrikePoint(point)
    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf", PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( particle, 0, point )
	ParticleManager:SetParticleControl( particle, 1, Vector( 175, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( particle )
    local enemies = FindUnitsInRadius( DOTA_TEAM_NEUTRALS, point, nil, 175, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
    for _, enemy in pairs(enemies) do
        enemy:ForceKill(false)
        table.insert(MiniGamesLib.QUEUE_PLAYERS, enemy:GetPlayerOwnerID())
    end
end