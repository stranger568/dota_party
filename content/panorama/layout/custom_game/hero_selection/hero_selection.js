var dotahud = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent();
var selected_hero
var buttons;
var buttons_parent;
var chat;
var chat_parent;
var start_voice = true;
var heroes_list =
[
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
]

function IsSpectator() 
{
    const localPlayer = Players.GetLocalPlayer()
    if (Players.IsSpectator(localPlayer))
    {
        return true
    }
    const localTeam = Players.GetTeam(localPlayer)
    return localTeam !== 2 && localTeam !== 3 && localTeam !== 6 && localTeam !== 7 && localTeam !== 8 && localTeam !== 9 && localTeam !== 10 && localTeam !== 11 && localTeam !== 12 && localTeam !== 13
}

function HeroSelectionInit()
{
    if (IsSpectator())
    {
        return
    }
    GameEvents.Subscribe( 'pp_pick_load_heroes', LoadHeroes );
    GameEvents.Subscribe( 'pp_pick_timer_upd', TimerUpd );
    GameEvents.Subscribe( 'pp_pick_start_selection', StartSelection );
    GameEvents.Subscribe( 'pp_pick_preend_start', StartPreEnd );
    GameEvents.Subscribe( 'pp_pick_end', HeroSelectionEnd );
    GameEvents.Subscribe( 'hero_is_picked', HeroesIsPicked );
    GameEvents.Subscribe( 'UpdatePlayersPick', UpdatePlayersPick );
}

function LoadHeroSelection()
{
    if (IsSpectator())
    {
        $.GetContextPanel().AddClass('Deletion');
        $.GetContextPanel().style.opacity = "0"
        return
    }
    $.GetContextPanel().SetFocus();
    StealButtonsAndChat();
    $.Schedule( 1, function()
    {
        GameEvents.SendCustomGameEventToServer( 'pp_pick_player_registred', {} );
    });
    $.Schedule( 1.5, function()
    {
        GameEvents.SendCustomGameEventToServer( 'pp_pick_player_loaded', {} );
    });
    var game_start = CustomNetTables.GetTableValue('game_state', "pickstate");
    if (game_start)
    {
        if (game_start.v == "ended")
        {
            HeroSelectionEnd()
            return
        } 
    }
    LoadHeroes()
    LoadPlayers()
}

function LoadHeroes()
{
    $("#HeroesListChoose").RemoveAndDeleteChildren()
    for (var i = 0; i < heroes_list.length; i++) 
    {
        CreateHeroesCard(heroes_list[i])
    }
    ChangeHeroInfo(heroes_list[0]);
}

function CreateHeroesCard(hero_name)
{
    let main_panel = $("#HeroesListChoose")
    var SelectHeroImage = $.CreatePanel("Panel", main_panel, hero_name );
    SelectHeroImage.AddClass("SelectHeroImage");
    $.CreatePanel(`DOTAHeroImage`, SelectHeroImage, "", {scaling: "stretch-to-cover-preserve-aspect", heroname : String(hero_name), tabindex : "auto", class: "SelectHeroImageInclude", heroimagestyle : "portrait"});
    SetPSelectEvent(SelectHeroImage, hero_name);
}

function SetPSelectEvent(p, n)
{
    p.SetPanelEvent("onactivate", function() 
    { 
        ChangeHeroInfo(n);
    });        
}

function PanelDisabled(p)
{
    p.SetPanelEvent("onactivate", function() {});        
}

function ChangeHeroInfo(hero_name) 
{
    if (hero_name == selected_hero) {return}
    selected_hero = hero_name
    UpdateSelectedCurrentHero(hero_name, false)
    $("#HeroModel").RemoveAndDeleteChildren()
    $.CreatePanel("DOTAScenePanel", $("#HeroModel"), "hero_model_vmdl", { style: "width:100%;height:100%;", drawbackground: true, unit:hero_name, particleonly:"false", antialias:"false",allowrotation:"true" });
    $("#HeroNameInfo").text = $.Localize("#" + hero_name)
    UpdateLevel(hero_name)
    SetSelectCurrentHero(hero_name)
    Game.EmitSound("ui.set_favourite")
}

function UpdateSelectedCurrentHero(hero_name, final_select)
{
    for (var i = 0; i < $("#HeroesListChoose").GetChildCount(); i++) 
	{
		$("#HeroesListChoose").GetChild(i).SetHasClass("active_select_hero_choose", false)
	}
    let find = $("#HeroesListChoose").FindChildTraverse(hero_name)
    if (find)
    {
        find.SetHasClass("active_select_hero_choose", true)
    }
    if (final_select)
    {
        for (var i = 0; i < $("#HeroesListChoose").GetChildCount(); i++) 
        {
            PanelDisabled($("#HeroesListChoose").GetChild(i))
        }
    }
}

function SetSelectCurrentHero(hero_name)
{
    $("#ReadyButton").SetPanelEvent("onactivate", function() 
    { 
        SelectHero(hero_name);
    });
}

function SelectHero(hero_name)
{
    $("#ReadyButton").style.visibility = "collapse";
    UpdateSelectedCurrentHero(hero_name, true)
    $.Msg(hero_name)
    GameEvents.SendCustomGameEventToServer( 'pp_pick_select_hero', { hero_name : hero_name } );
    Game.EmitSound("ui.pick_select")
}

function OpenHeroesList()
{
    Game.EmitSound("ui.npd_play")
    $("#HeroesButtonSelectCheck").SetHasClass("select_active_button", true)
    $("#InventoryButtonSelectCheck").SetHasClass("select_active_button", false)
    $("#HeroesListChoose").style.visibility = "visible"
    $("#HeroesInventoryChoose").style.visibility = "collapse"
}

function OpenInventory()
{
    Game.EmitSound("ui.npd_play")
    $("#HeroesButtonSelectCheck").SetHasClass("select_active_button", false)
    $("#InventoryButtonSelectCheck").SetHasClass("select_active_button", true)
    $("#HeroesListChoose").style.visibility = "collapse"
    $("#HeroesInventoryChoose").style.visibility = "visible"
}

function LoadPlayers()
{
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
    $("#PlayersPanel").RemoveAndDeleteChildren()
    
    for (var i = 0; i < players.length; i++)
    {
        PlayerUpdate(true, players[i], i)
    }
}

function PlayerUpdate(open, info, i)
{
    let player_panel = null
    if (open)
    {
        player_panel = CreatePlayerCard(info, i)
    }
    if (player_panel == null)
    {
        player_panel = $("#PlayersPanel").FindChildTraverse("player_"+info.player_id)
    }
    let player_info = CustomNetTables.GetTableValue("players_system", String(info.player_id))
    if (player_info)
    {
        if (player_panel)
        {
            let PlayerLevel = player_panel.FindChildTraverse("PlayerLevel")
            let PlayerSelectedHero = player_panel.FindChildTraverse("PlayerSelectedHero")
            if (PlayerSelectedHero)
            {
                if (player_info.selected_hero != null)
                {
                    $.CreatePanel(`DOTAHeroImage`, PlayerSelectedHero, "", {scaling: "stretch-to-cover-preserve-aspect", heroname : String(player_info.selected_hero), tabindex : "auto", class: "SelectHeroImageInclude", heroimagestyle : "portrait"});
                }
            }
            if (PlayerLevel)
            {
                if (player_info.selected_hero != null)
                {
                    PlayerLevel.style.opacity = "1"
                    PlayerLevel.text = $.Localize("#pp_level") + " " + "0"
                }
            }
            let PlayerReady = player_panel.FindChildTraverse("PlayerReady")
            if (PlayerReady)
            {
                if (player_info.is_ready)
                {
                    PlayerReady.SetHasClass("PlayerReadyOff", false)
                    PlayerReady.SetHasClass("PlayerReady", true)
                }
                else
                {
                    PlayerReady.SetHasClass("PlayerReady", false)
                    PlayerReady.SetHasClass("PlayerReadyOff", true)
                }
            }
        }
    }
}

function CreatePlayerCard(player, player_c)
{
    let main_panel = $("#PlayersPanel")

    var PlayerPanel = $.CreatePanel("Panel", main_panel, "player_"+player.player_id );
    PlayerPanel.AddClass("PlayerPanel");
    PlayerPanel.AddClass("PlayerPanel_style_"+player_c);

    var PlayerSelectedHero = $.CreatePanel("Panel", PlayerPanel, "PlayerSelectedHero" );
    PlayerSelectedHero.AddClass("PlayerSelectedHero");

    var PlayerInformation = $.CreatePanel("Panel", PlayerPanel, "" );
    PlayerInformation.AddClass("PlayerInformation");

    var PlayerName = $.CreatePanel("Label", PlayerInformation, "PlayerName" );
    PlayerName.AddClass("PlayerName");
    PlayerName.text = player.player_name

    var PlayerLevel = $.CreatePanel("Label", PlayerInformation, "PlayerLevel" );
    PlayerLevel.AddClass("PlayerLevel");
    PlayerLevel.html = true
    PlayerLevel.text = $.Localize("#pp_level") + " " + "0"

    var PlayerReadyOff = $.CreatePanel("Panel", PlayerPanel, "PlayerReady" );
    PlayerReadyOff.AddClass("PlayerReadyOff");

    return PlayerPanel
} 

function StartSelection()
{   
    $("#ReadyButton").style.visibility = "visible"
    if (start_voice) 
    {
        start_voice = false
        Game.EmitSound("announcer_dlc_rick_and_morty_choose_your_hero_02");
    }
}

function StartPreEnd( kv )
{
    $("#ReadyButton").style.visibility = "collapse"
}

function HeroSelectionEnd()
{
    $.GetContextPanel().AddClass('Deletion');
    RestoreButtonsAndChat();
    $.Schedule(1.5, function() 
    {
        if ($("#MovieBackground"))
        {
            $("#MovieBackground").DeleteAsync(1.5)
        }
        if ($("#pick_timer_particle"))
        {
            $("#pick_timer_particle").DeleteAsync(1.5)
        }
        if ($("#MovieBackground2"))
        {
            $("#MovieBackground2").DeleteAsync(1.5)
        }
        if ($("#MovieBackground2"))
        {
            $("#MovieBackground2").DeleteAsync(1.5)
        }
        $.GetContextPanel().style.opacity = "0"
    })
}

// Дополнительные функции

function StealButtonsAndChat()
{
    if( $.GetContextPanel().BHasClass('Deletion') ) return;

    buttons = dotahud.FindChildTraverse('MenuButtons');
    buttons_parent = buttons.GetParent();

    if( buttons )
    {
        buttons.SetParent( $.GetContextPanel() );
        buttons.FindChildTraverse('ToggleScoreboardButton').visible = false;
    }
    
    chat = dotahud.FindChildTraverse('HudChat');
    chat_parent = chat.GetParent();

    if( chat )
    {
        chat.SetParent( $.GetContextPanel() );
        chat.style.horizontalAlign = 'left';
        chat.style.y = '60px';
        chat.style.width = '660px';
    }
}

function RestoreButtonsAndChat()
{
    var HudElements = dotahud.FindChildTraverse('HUDElements');
    var button = dotahud.FindChildTraverse('MenuButtons');
    var chating = dotahud.FindChildTraverse('HudChat');

    if ( button && HudElements )
    {
        button.SetParent( HudElements );
        button.FindChildTraverse('ToggleScoreboardButton').visible = true;
    }
    
    if ( chating && HudElements )
    {
        chating.SetParent( HudElements );
        chating.style.horizontalAlign = 'center';
        chating.style.y = '-220px';
        chat.style.width = '800px';
    }
}

function TimerUpd( kv )
{
    var timer_panel = $('#PickTimer');
    if ( timer_panel )
    {
        let time = kv.timer
        var min = Math.trunc((time)/60) 
        var sec_n =  (time) - 60*Math.trunc((time)/60) 
        var hour = String( Math.trunc((min)/60) )
        var min = String(min - 60*( Math.trunc(min/60) ))
        var sec = String(sec_n)
        if (sec_n < 10) 
        {
            sec = '0' + sec

        }
        timer_panel.text = min + ':' + sec
    }
}

function HeroesIsPicked(kv) 
{
    let hero_name = kv.hero
    $("#ReadyButton").style.visibility = "collapse"
    ChangeHeroInfo(hero_name)
    PlayerUpdate(false, {player_id:kv.id}, null)
    UpdateSelectedCurrentHero(hero_name, true)
}

function UpdatePlayersPick(kv) 
{
    let hero_name = kv.hero
    PlayerUpdate(false, {player_id:kv.id}, null)
}

function UpdateLevel(hero_name)
{
    $("#LevelProgressActive").style.width = GetExpPercent(hero_name) + "%"
    $("#LevelProgressExpInfo").text = "<font color='#09f225'>" + GetExp(hero_name) + $.Localize("#pp_exp") + "</font> / " + "400" + $.Localize("#pp_exp")
}

function GetExp(hero_name)
{
    return 0
}

function GetExpPercent(hero_name)
{
    return 0
}

HeroSelectionInit();