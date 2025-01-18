const english_language_button = 
{
    "q" : "й",
    "w" : "ц",
    "e" : "у",
    "r" : "к",
    "t" : "е",
    "y" : "н",
    "u" : "г",
    "i" : "ш",
    "o" : "щ",
    "p" : "з",
    "a" : "ф",
    "s" : "ы",
    "d" : "в",
    "f" : "а",
    "g" : "п",
    "h" : "р",
    "j" : "о",
    "k" : "л",
    "l" : "д",
    "z" : "я",
    "x" : "ч",
    "c" : "с",
    "v" : "м",
    "b" : "и",
    "n" : "т",
    "m" : "ь",
}

const russian_language_button = 
{
    "й" : "q",
    "ц" : "w",
    "у" : "e",
    "к" : "r",
    "е" : "t",
    "н" : "y",
    "г" : "u",
    "ш" : "i",
    "щ" : "o",
    "з" : "p",
    "ф" : "a",
    "ы" : "s",
    "в" : "d",
    "а" : "f",
    "п" : "g",
    "р" : "h",
    "о" : "j",
    "л" : "k",
    "д" : "l",
    "я" : "z",
    "ч" : "x",
    "с" : "c",
    "м" : "v",
    "и" : "b",
    "т" : "n",
    "ь" : "m",
}

function GetGameKeybind(command) 
{
    return Game.GetKeybindForCommand(command);
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