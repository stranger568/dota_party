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
            player_panel = $.CreatePanel("Panel", PlayersList, "player_panel_" + id)
            player_panel.AddClass("player_panel")

            let player_info = $.CreatePanel("Panel", player_panel, "")
            player_info.AddClass("player_info")
            player_info.AddClass("player_info_style_"+id);

            // Информация об игроке имя + герой
            let player_portrait = $.CreatePanel("Panel", player_panel, "")
            player_portrait.AddClass("player_portrait")
            let player_name_bg = $.CreatePanel("Panel", player_panel, "")
            player_name_bg.AddClass("player_name_bg")
            let player_name_label = $.CreatePanel("Label", player_name_bg, "")
            player_name_label.AddClass("player_name_label")
            player_name_label.text = Players.GetPlayerName(id)
            $.CreatePanel(`DOTAHeroImage`, player_portrait, "DOTAHeroImageContainer", {scaling: "stretch-to-cover-preserve-aspect", heroname : String(playerInfo.player_selected_hero), tabindex : "auto", class: "hero_image_interface", heroimagestyle : "portrait"});

            // Количество ключей
            let player_keys_panel = $.CreatePanel("Panel", player_info, "")
            player_keys_panel.AddClass("player_keys_panel")
            let player_key_image = $.CreatePanel("Panel", player_keys_panel, "")
            player_key_image.AddClass("player_key_image")
            let player_key_quad = $.CreatePanel("Label", player_keys_panel, "")
            player_key_quad.AddClass("player_key_quad")
            player_key_quad.text = "/"
            let player_key_count = $.CreatePanel("Label", player_keys_panel, "player_block_keys_count_label")
            player_key_count.AddClass("player_key_count")
            player_key_count.text = "0"

            // Количество наград
            let player_rewards_panel = $.CreatePanel("Panel", player_info, "")
            player_rewards_panel.AddClass("player_rewards_panel")
            let player_reward_image = $.CreatePanel("Panel", player_rewards_panel, "")
            player_reward_image.AddClass("player_reward_image")
            let player_reward_quad = $.CreatePanel("Label", player_rewards_panel, "")
            player_reward_quad.AddClass("player_reward_quad")
            player_reward_quad.text = "/"
            let player_reward_count = $.CreatePanel("Label", player_rewards_panel, "")
            player_reward_count.AddClass("player_reward_count")
            player_reward_count.text = "0"

            // Здоровье

            let player_health_line_main = $.CreatePanel("Panel", player_info, "")
            player_health_line_main.AddClass("player_health_line_main")

            let player_health_line = $.CreatePanel("Panel", player_health_line_main, "player_health_line")
            player_health_line.AddClass("player_health_line")

            let player_health_label = $.CreatePanel("Label", player_health_line_main, "player_health_label")
            player_health_label.AddClass("player_health_label")
            player_health_label.text = "0"
        }
        else
        {
            let DOTAHeroImageContainer = player_panel.FindChildTraverse("DOTAHeroImageContainer")
            if (DOTAHeroImageContainer)
            {
                DOTAHeroImageContainer.heroname = String(playerInfo.player_selected_hero)
            }

            let players_system = CustomNetTables.GetTableValue("players_system", String(id))
            if (players_system)
            {
                player_panel.FindChildTraverse("player_health_label").text = players_system.health
                player_panel.FindChildTraverse("player_health_line").style.width = (100 - ((players_system.max_health-players_system.health)*100) / players_system.max_health) + "%"
                player_panel.FindChildTraverse("player_block_keys_count_label").text = players_system.keys
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

function GetDotaHud()
{
	let hPanel = $.GetContextPanel();
	while ( hPanel && hPanel.id !== 'Hud')
	{
        hPanel = hPanel.GetParent();
	}
	if (!hPanel)
	{
        throw new Error('Could not find Hud root from panel with id: ' + $.GetContextPanel().id);
	}
	return hPanel;
}

function FindDotaHudElement(sId)
{
	return GetDotaHud().FindChildTraverse(sId);
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

(function()
{
	UpdatePlayersListHub()
    InitHub()
})();