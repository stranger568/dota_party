function InitKeyBind()
{
    InitKeyBindButton("a", "A")
    InitKeyBindButton("d", "D")
    InitKeyBindButton("w", "W")
    InitKeyBindButton("s", "S")
    InitKeyBindButton("Space", "Space")
    InitKeyBindButton("1", "1")
    $.Schedule( 1, InitKeyBind );
}

function InitKeyBindButton(button_name, code_button)
{
    if (russian_language_button[button_name])
    {
        button_name = russian_language_button[button_name]
    }
    SetKeyBindEvent(button_name, code_button)
    if (english_language_button[button_name])
    {
        SetKeyBindEvent(english_language_button[button_name], code_button)  
    }
}

function SetKeyBindEvent(button_bind, code_button)
{
    const name_bind = "CustomBindEvent" + Math.floor(Math.random() * 99999999);
    Game.AddCommand("+" + name_bind, () => SendGameEventBindPressed(code_button), "", 0);
    Game.AddCommand("-" + name_bind, () => SendGameEventBindUnPressed(code_button), "", 0);
    Game.CreateCustomKeyBind(button_bind, "+" + name_bind);
}

function SendGameEventBindPressed(code_button)
{
    GameEvents.SendCustomGameEventToServer("RL_BUTTON_PRESSED", {button : code_button});
}

function SendGameEventBindUnPressed(code_button)
{
    GameEvents.SendCustomGameEventToServer("RL_BUTTON_UNPRESSED", {button : code_button});
}

function SetMousePosition()
{
    const cursor = GameUI.GetCursorPosition();
    let vPos = GameUI.GetScreenWorldPosition(cursor);
    if (vPos)
    {
        GameEvents.SendCustomGameEventToServer("RL_MOUSE_POSITION", {vPos : vPos});
    }
    $.Schedule( 1/144, SetMousePosition );
}

InitKeyBind()
SetMousePosition()