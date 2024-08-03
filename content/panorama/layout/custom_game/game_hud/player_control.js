function InitKeyBind()
{
    SetKeyBindEvent("leftarrow", "A")
    SetKeyBindEvent("rightarrow", "D")
    SetKeyBindEvent("uparrow", "W")
    SetKeyBindEvent("downarrow", "S")
    SetKeyBindEvent("Space", "Space")
}

function SetKeyBindEvent(button_bind, code_button)
{
    const name_bind = "WheelButton" + Math.floor(Math.random() * 99999999);
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

InitKeyBind()