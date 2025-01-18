function UpdatePlayersListHub()
{
    var teamsList = [];
	for ( var teamId of Game.GetAllTeamIDs() )
	{
		teamsList.push( Game.GetTeamDetails( teamId ) );
	}
    for ( var i = 0; i < teamsList.length; ++i )
	{
		let teamId = teamsList[i].team_id;
        let teamPlayers = Game.GetPlayerIDsOnTeam( teamId )
        for ( var d = 0; d < teamPlayers.length; ++d )
	    {
            HubPlayerUpdate(teamPlayers[d])
        }
	}
    $.Schedule(1/144, UpdatePlayersListHub)
}

function InitHub()
{
    let table_s = CustomNetTables.GetTableValue("game_info", "round_number")
    if (table_s)
    {
        $("#ProgressCountMainLabel").text = table_s.number + " / ∞"
    }

    let stats_container = FindDotaHudElement("stats_container")
    if (stats_container)
    {
        stats_container.style.opacity = "0"
    }
    let left_flare = FindDotaHudElement("left_flare")
    if (left_flare)
    {
        left_flare.style.opacity = "0"
    }
    let StatBranch = FindDotaHudElement("StatBranch")
    if (StatBranch)
    {
        StatBranch.style.opacity = "0"
    }
    let AghsStatusContainer = FindDotaHudElement("AghsStatusContainer")
    if (AghsStatusContainer)
    {
        AghsStatusContainer.style.opacity = "0"
    }
    let health_mana = FindDotaHudElement("health_mana")
    if (health_mana)
    {
        health_mana.style.opacity = "0"
    }
    let inventory = FindDotaHudElement("inventory")
    if (inventory)
    {
        inventory.style.opacity = "0"
    }
    let AbilityInsetShadowRight = FindDotaHudElement("AbilityInsetShadowRight")
    if (AbilityInsetShadowRight)
    {
        AbilityInsetShadowRight.style.opacity = "0"
    }
    let right_flare = FindDotaHudElement("right_flare")
    if (right_flare)
    {
        right_flare.style.opacity = "0"
    }
    let xp = FindDotaHudElement("xp")
    if (xp)
    {
        xp.style.opacity = "0"
    }
    let inventory_composition_layer_container = FindDotaHudElement("inventory_composition_layer_container")
    if (inventory_composition_layer_container)
    {
        inventory_composition_layer_container.style.opacity = "0"
    }
    let center_with_stats = FindDotaHudElement("center_with_stats")
    if (center_with_stats)
    {
        center_with_stats.style.opacity = "0"
    }
    let BuffContainer = FindDotaHudElement("BuffContainer")
    if (BuffContainer)
    {
        BuffContainer.style.opacity = "0"
    }
}

function HubPlayerUpdate(id)
{
    var playerInfo = Game.GetPlayerInfo( id );
    let PlayersList = $("#PlayersList")
    if (PlayersList)
    {
        let player_panel = PlayersList.FindChildTraverse("player_panel_" + id)
        if (player_panel == null)
        {
            let player_color = GameUI.CustomUIConfig().player_colors[id]

            player_panel = $.CreatePanel("Panel", PlayersList, "player_panel_" + id)
            player_panel.AddClass("player_panel")

            let player_info = $.CreatePanel("Panel", player_panel, "")
            player_info.AddClass("player_info")
            player_info.AddClass("player_info_style_"+id);

            // Информация об игроке имя + герой
            let portrait_style = "width: 42px;height:42px;border:2px solid " + player_color + "vertical-align:center;margin-left:10px;"
            let player_portrait = $.CreatePanel("DOTAAvatarImage", player_info, "", {steamid : playerInfo.player_steamid, style: portrait_style})
 
            let player_name_label = $.CreatePanel("Label", player_info, "")
            player_name_label.AddClass("player_name_label")
            player_name_label.style.color = player_color
            player_name_label.text = Players.GetPlayerName(id)
 
            // Количество ключей
            let player_keys_panel = $.CreatePanel("Panel", player_panel, "")
            player_keys_panel.AddClass("player_keys_panel")
            player_keys_panel.style.border = "2px solid " + player_color
            let player_key_image = $.CreatePanel("Panel", player_keys_panel, "")
            player_key_image.AddClass("player_key_image")
            player_key_image.AddClass("player_key_image_"+id)
            let player_key_count = $.CreatePanel("Label", player_keys_panel, "player_block_keys_count_label")
            player_key_count.AddClass("player_key_count")
            player_key_count.text = "0"

            // Количество наград
            let player_rewards_panel = $.CreatePanel("Panel", player_info, "")
            player_rewards_panel.AddClass("player_rewards_panel")
            let player_reward_image = $.CreatePanel("Panel", player_rewards_panel, "")
            player_reward_image.AddClass("player_reward_image")
            let player_reward_count = $.CreatePanel("Label", player_rewards_panel, "player_reward_count")
            player_reward_count.AddClass("player_reward_count")
            player_reward_count.text = "0"
        }
        else
        {
            let players_system = CustomNetTables.GetTableValue("players_system", String(id))
            if (players_system)
            {
                player_panel.FindChildTraverse("player_block_keys_count_label").text = players_system.keys
                player_panel.FindChildTraverse("player_reward_count").text = players_system.rewards_count
            }
        }
    }
}

CustomNetTables.SubscribeNetTableListener( "players_system", UpdatePlayerSystem );

function UpdatePlayerSystem(table, key, data ) 
{
	if (table == "players_system") 
	{
		let player_panel = $("#PlayersList").FindChildTraverse("player_panel_" + key)
        if (player_panel)
        {
            let player_health_label = player_panel.FindChildTraverse("player_health_label")
            if (player_health_label)
            {
                player_health_label.text = data.health
            }
            let player_health_line = player_panel.FindChildTraverse("player_health_line")
            if (player_health_line)
            {
                player_health_line.style.width = (100 - ((data.max_health-data.health)*100) / data.max_health) + "%"
            }
            let player_block_keys_count_label = player_panel.FindChildTraverse("player_block_keys_count_label")
            if (player_block_keys_count_label)
            {
                player_block_keys_count_label.text = data.keys
            }
        }
	}
}

CustomNetTables.SubscribeNetTableListener( "game_info", UpdateGameInfo );

function UpdateGameInfo(table, key, data )
{
    if (key == "round_number") 
	{
        $("#ProgressCountMainLabel").text = data.number + " / ∞"
	}
    if (key == "round_queue") 
	{
        $("#PlayersMoveCountMain").RemoveAndDeleteChildren()
        UpdateRoundQueue(data)
	}
}

function UpdateRoundQueue(data)
{
    for ( var i = 0; i <= Object.keys(data.players).length; ++i )
    {
        if (data.players[i] != null)
        {
            let player_queue_block = $.CreatePanel("Panel", $("#PlayersMoveCountMain"), "")
            player_queue_block.AddClass("player_queue_block")
            var playerInfo = Game.GetPlayerInfo( data.players[i] );
            if (playerInfo)
            {
                if (GameUI.CustomUIConfig().team_colors[playerInfo.player_team_id] != null)
                {
                    player_queue_block.style.backgroundColor = GameUI.CustomUIConfig().team_colors[playerInfo.player_team_id]
                }
            }
        }
    }
}

GameEvents.Subscribe( 'notification_player_start_game', notification_player_start_game );

function notification_player_start_game(data)
{
    var time_notification = $.CreatePanel('Label', $.GetContextPanel(), '');
    time_notification.AddClass("time_notification_start")
    time_notification.AddClass("time_notification_low")
    time_notification.DeleteAsync(3)
    time_notification.html = true
    time_notification.text = $.Localize("#player_first_start_game")
    Game.EmitSound("Tutorial.TaskProgress");
    $.Schedule( 2.7, function()
    {
        time_notification.AddClass("time_notification_close")
    })
}

GameEvents.Subscribe( 'notification_player_step', notification_player_step );
function notification_player_step(data)
{
    var time_notification = $.CreatePanel('Label', $.GetContextPanel(), '');
    time_notification.AddClass("time_notification")
    time_notification.AddClass("time_notification_low")
    time_notification.DeleteAsync(2)
    time_notification.html = true
    let player_color = "#ffffff"
    var playerInfo = Game.GetPlayerInfo(data.id);
    if (playerInfo)
    {
        if (GameUI.CustomUIConfig().team_colors[playerInfo.player_team_id] != null)
        {
            player_color = GameUI.CustomUIConfig().team_colors[playerInfo.player_team_id]
        }
    }
    Game.EmitSound("Tutorial.TaskProgress");
    time_notification.text = "<b><font color='" + player_color + "'>" + Players.GetPlayerName(data.id) + "</font></b> " + $.Localize("#player_step_current")
    $.Schedule( 1.7, function()
    {
        time_notification.AddClass("time_notification_close")
    })
}

GameEvents.Subscribe( 'starting_pre_game_window', starting_pre_game_window );

function starting_pre_game_window(data)
{
    $("#PreMiniGameHud").style.opacity = "1"
    $("#ReadyButton").style.opacity = "1"
    $("#MiniGameInfoName").text = $.Localize("#"+data.game_name+"_name")
    $("#MiniGameInfoDescription").text = $.Localize("#"+data.game_name+"_description")
    $("#InstructionDescription").text = $.Localize("#"+data.game_name+"_full_description")
    CreatePlayersListPreGame()
}

function CreatePlayersListPreGame()
{
    $("#PlayersListPreGame").RemoveAndDeleteChildren()
    var players = [];
	for (var teamId of Game.GetAllTeamIDs()) 
    {
        var teamPlayers = Game.GetPlayerIDsOnTeam(teamId)
		for (var playerId of teamPlayers) 
        {
			var playerInfo = Game.GetPlayerInfo(playerId);
            players.push(playerInfo)
		}
	}
    for (var i = 0; i < players.length; i++)
    {
        PlayerUpdatePreGame(true, players[i], i)
    }
}

function PlayerUpdatePreGame(open, info, i)
{
    let player_panel = null
    if (open)
    {
        player_panel = CreatePlayerCard(info, i)
    }
    if (player_panel == null)
    {
        player_panel = $("#PlayersListPreGame").FindChildTraverse("player_"+info.player_id)
    }
}

function CreatePlayerCard(player, player_c)
{
    let main_panel = $("#PlayersListPreGame")

    var PlayerPanel = $.CreatePanel("Panel", main_panel, "player_"+player.player_id );
    PlayerPanel.AddClass("PlayerPanel");
    PlayerPanel.AddClass("PlayerPanel_style_"+player_c);

    $.CreatePanel("DOTAAvatarImage", PlayerPanel, "PlayerAvatarPre", { style: "width:64px;height:64px;vertical-align:center;margin-left:20px;border-radius:10px;", accountid: player.player_steamid });

    var PlayerInformation = $.CreatePanel("Panel", PlayerPanel, "" );
    PlayerInformation.AddClass("PlayerInformation");

    var PlayerName = $.CreatePanel("Label", PlayerInformation, "PlayerName" );
    PlayerName.AddClass("PlayerName");
    PlayerName.text = player.player_name

    var PlayerReadyOff = $.CreatePanel("Panel", PlayerPanel, "PlayerReady" );
    PlayerReadyOff.AddClass("PlayerReadyOff");

    return PlayerPanel
} 

GameEvents.Subscribe( 'pregame_minigame_timer', pregame_minigame_timer );

function pregame_minigame_timer(data)
{
    $("#MiniGamePreTimer").text = data.time
}

GameEvents.Subscribe( 'close_pre_minigame_info', close_pre_minigame_info );

function close_pre_minigame_info()
{
    $("#PreMiniGameHud").style.opacity = "0"
    $.DispatchEvent("DropInputFocus")
}

function PlayerIsReady()
{
    $("#ReadyButton").style.opacity = "0" 
    GameEvents.SendCustomGameEventToServer("PLAYER_IS_READY_MINIGAME", {});
}

GameEvents.Subscribe( 'update_player_ready_list', update_player_ready_list );

function update_player_ready_list(data)
{
    for (player_id in data.players)
    {
        let player_panel = $("#PlayersListPreGame").FindChildTraverse("player_"+player_id)
        if (player_panel)
        {
            let PlayerReady = player_panel.FindChildTraverse("PlayerReady")
            if (PlayerReady)
            {
                PlayerReady.SetHasClass("PlayerReadyOff", false)
                PlayerReady.SetHasClass("PlayerReady", true)
            }
        }
    }
}

var abilities_list = 
{
    "ability_random_steps" : ["false", "false"],
    // "ability_change_rotate_left" : ["false", "false"],
    // "ability_change_rotate_right" : ["false", "false"],
    // "ability_change_rotate_up" : ["false", "false"],
    // "ability_change_rotate_down" : ["false", "false"],

    "ability_sniper_mini_game" : ["false", "Space"],
    "ability_mirana_mini_game" : ["false", "Space"],
    "ability_walrus_punch_mini_game" : ["false", "Space"],
    "ability_normal_punch_mini_game" : ["false", "Space"],
    "ability_walrus_kick_mini_game" : ["false", "Space"],

    "ability_pummel_grab_crown_1" : ["false", "1"],
    "ability_pummel_grab_crown_2" : ["false", "1"],
    "ability_pummel_grab_crown_3" : ["false", "1"],
    "ability_pummel_grab_crown_4" : ["false", "1"],
    "ability_pummel_grab_crown_5" : ["false", "1"],
    "ability_pummel_grab_crown_6" : ["false", "1"],

    "ability_pummel_potato_1" : ["false", "1"],
    "ability_pummel_potato_2" : ["false", "1"],
    "ability_pummel_potato_3" : ["false", "1"],
    "ability_pummel_potato_4" : ["false", "1"],
    "ability_pummel_potato_5" : ["false", "1"],
    "ability_pummel_potato_6" : ["false", "1"],

    "ability_item_1" : ["false", "1"],
    "ability_item_2" : ["false", "2"],
    "ability_item_3" : ["false", "3"],
    "ability_item_4" : ["false", "4"],
    "ability_item_5" : ["false", "5"],
    "ability_item_6" : ["false", "6"],
    "ability_item_7" : ["false", "7"],
    "ability_item_8" : ["false", "8"],
    "ability_item_9" : ["false", "9"],
    "ability_item_10" : ["false", "-"],
}

function UpdateLocalHud()
{
    let local_unit = Players.GetLocalPlayerPortraitUnit()
    if (local_unit == null || local_unit == -1)
    {
        $.Schedule(1/144, UpdateLocalHud)
        return
    }
    if (!Entities.IsRealHero( local_unit ))
    {
        $.Schedule(1/144, UpdateLocalHud)
        return
    }
    let local_unit_id = Entities.GetPlayerOwnerID( local_unit )

    let players_system = CustomNetTables.GetTableValue("players_system", String(local_unit_id))
    if (players_system)
    {
        $("#HeroHealthPointsLabel").text = players_system.health
        $("#HeroHealthPointsBurner").style.width = (100 - ((players_system.max_health-players_system.health)*100) / players_system.max_health) + "%"
    }

    for (ability_name in abilities_list)
    {
        UpdateLocalAbility(ability_name, local_unit)
    }

    $.Schedule(1/144, UpdateLocalHud)
}

function UpdateLocalAbility(ability_name, local_unit)
{
    let PlayerAbilities = $("#PlayerAbilities")
    let local_ability = PlayerAbilities.FindChildTraverse(ability_name)
    if (local_ability == null)
    {
        local_ability = $.CreatePanel("Panel", PlayerAbilities, ability_name );
        local_ability.AddClass("PlayerAbility");

        let local_ability_bg = $.CreatePanel("Panel", local_ability, "" );
        local_ability_bg.AddClass("local_ability_bg");

        let local_ability_button = $.CreatePanel("Panel", local_ability, "" );
        local_ability_button.AddClass("local_ability_button");
        if (abilities_list[ability_name][0] == "false")
        {
            local_ability_button.style.border = "1px solid green"
        }

        let local_ability_button_text = $.CreatePanel("Label", local_ability_button, "local_ability_button_text" );
        local_ability_button_text.AddClass("local_ability_button_text");
        local_ability_button_text.html = true
        local_ability_button_text.text = ""

        let ability_image = $.CreatePanel("DOTAAbilityImage", local_ability, "" );
        ability_image.AddClass("local_ability_image");
        ability_image.abilityname = ability_name
    }
    
    let find_hero_ability = Entities.GetAbilityByName( local_unit, ability_name )
    let hidden_ability = false
    if (abilities_list[ability_name][0] == "false")
    {
        if (find_hero_ability == null || find_hero_ability == -1)
        {
            hidden_ability = true
        }
        else
        {
            if (Abilities.IsHidden( find_hero_ability ) || !Abilities.IsActivated( find_hero_ability ))
            {
                hidden_ability = true
            }
        }
    }
    if (!hidden_ability)
    {
        local_ability.style.visibility = "visible"
        let local_ability_button_text = local_ability.FindChildTraverse("local_ability_button_text")
        if (local_ability_button_text)
        {
            if (abilities_list[ability_name][1] == "false")
            {
                local_ability_button_text.text = Abilities.GetKeybind( find_hero_ability )
            }
            else
            {
                local_ability_button_text.text = abilities_list[ability_name][1]
            }
        }
    }
    else
    {
        local_ability.style.visibility = "collapse"
    }
}

function GetGameKeybind(command) 
{
    return Game.GetKeybindForCommand(command);
}

GameEvents.Subscribe( 'game_chest_notification', game_chest_notification );

function game_chest_notification(data)
{
    $("#ChestNotification").style.opacity = "1"
    $.Schedule(5, function()
    {
        $("#ChestNotification").style.opacity = "0" 
    })
}

GameEvents.Subscribe( 'game_is_notification_open_chest', game_is_notification_open_chest );

function game_is_notification_open_chest(data)
{
    $("#ChestNotificationIsOpened").style.opacity = "1"
    let players_system = CustomNetTables.GetTableValue("players_system", String(data.player_owner))

    if ((data.player_owner == Players.GetLocalPlayer()) || IsInToolsMode())
    {
        $("#CupButtonNoNotification").SetPanelEvent("onactivate", function() 
        { 
            $("#CupButtonNoNotification").ClearPanelEvent("onactivate")
            $("#CupButtonYesNotification").ClearPanelEvent("onactivate")
            $("#ChestNotificationIsOpened").style.opacity = "0"
            GameEvents.SendCustomGameEventToServer("PLAYER_CHECKED_OPEN_CHEST", {is_open : 0, next_point_name : data.next_point_name});
        });
        if (players_system)
        {
            if (Number(players_system.keys) >= 40)
            {
                $("#CupButtonYesNotification").SetPanelEvent("onactivate", function() 
                { 
                    $("#CupButtonNoNotification").ClearPanelEvent("onactivate")
                    $("#CupButtonYesNotification").ClearPanelEvent("onactivate")
                    $("#ChestNotificationIsOpened").style.opacity = "0"
                    GameEvents.SendCustomGameEventToServer("PLAYER_CHECKED_OPEN_CHEST", {is_open : 1, next_point_name : data.next_point_name});
                });
            }
        }
    }
}

GameEvents.Subscribe( 'game_is_chest_select_all_clients', game_is_chest_select_all_clients );
function game_is_chest_select_all_clients()
{
    $("#CupButtonNoNotification").ClearPanelEvent("onactivate")
    $("#CupButtonYesNotification").ClearPanelEvent("onactivate")
    $("#ChestNotificationIsOpened").style.opacity = "0"
}

GameEvents.Subscribe( 'game_is_select_rotation', game_is_select_rotation );

function game_is_select_rotation(data)
{
    if (data.arrow_type == 2)
    {
        $("#ArrowCase").style.visibility = "visible"
        $("#ArrowCase2").style.visibility = "visible"
        if ((data.id == Players.GetLocalPlayer()) || IsInToolsMode())
        {
            $("#ArrowCase").SetPanelEvent("onactivate", function() {
                GameEvents.SendCustomGameEventToServer("PLAYER_SELECTED_ROTATION", {next_point : "hub_point_down_1"});
                CloseArrowsEvents()
            });
            $("#ArrowCase2").SetPanelEvent("onactivate", function() {
                GameEvents.SendCustomGameEventToServer("PLAYER_SELECTED_ROTATION", {next_point : "hub_point_up_16"});
                CloseArrowsEvents()
            });
        }
    }
    if (data.arrow_type == 3)
    {
        $("#ArrowCase3").style.visibility = "visible"
        $("#ArrowCase4").style.visibility = "visible"
        if ((data.id == Players.GetLocalPlayer()) || IsInToolsMode())
        {
            $("#ArrowCase3").SetPanelEvent("onactivate", function() {
                GameEvents.SendCustomGameEventToServer("PLAYER_SELECTED_ROTATION", {next_point : "hub_point_left_1"});
                CloseArrowsEvents()
            });
            $("#ArrowCase4").SetPanelEvent("onactivate", function() {
                GameEvents.SendCustomGameEventToServer("PLAYER_SELECTED_ROTATION", {next_point : "hub_point_down_7"});
                CloseArrowsEvents()
            });
        }
    }
    if (data.arrow_type == 4)
    {
        $("#ArrowCase5").style.visibility = "visible"
        $("#ArrowCase6").style.visibility = "visible"
        if ((data.id == Players.GetLocalPlayer()) || IsInToolsMode())
        {
            $("#ArrowCase5").SetPanelEvent("onactivate", function() {
                GameEvents.SendCustomGameEventToServer("PLAYER_SELECTED_ROTATION", {next_point : "hub_point_up_23"});
                CloseArrowsEvents()
            });
            $("#ArrowCase6").SetPanelEvent("onactivate", function() {
                GameEvents.SendCustomGameEventToServer("PLAYER_SELECTED_ROTATION", {next_point : "hub_point_right_1"});
                CloseArrowsEvents()
            });
        }
    }
}

function CloseArrowsEvents()
{
    $("#ArrowCase").ClearPanelEvent("onactivate")
    $("#ArrowCase2").ClearPanelEvent("onactivate")
    $("#ArrowCase3").ClearPanelEvent("onactivate")
    $("#ArrowCase4").ClearPanelEvent("onactivate")
    $("#ArrowCase5").ClearPanelEvent("onactivate")
    $("#ArrowCase6").ClearPanelEvent("onactivate")
}

GameEvents.Subscribe( 'game_is_close_arrows_select_all_clients', game_is_close_arrows_select_all_clients );

function game_is_close_arrows_select_all_clients()
{
    $("#ArrowCase").style.visibility = "collapse"
    $("#ArrowCase2").style.visibility = "collapse"
    $("#ArrowCase3").style.visibility = "collapse"
    $("#ArrowCase4").style.visibility = "collapse"
    $("#ArrowCase5").style.visibility = "collapse"
    $("#ArrowCase6").style.visibility = "collapse"
}

(function()
{
    UpdateLocalHud()
	UpdatePlayersListHub()
    InitHub()
})();