[Setting category="General" name="Enabled"]
bool S_Enabled = true;

enum Opponent {
    Gold   = 6,
    Silver = 7,
    Bronze = 8,
    Alone  = 9
}

[Setting category="General" name="Opponent"]
Opponent S_Opponent = Opponent::Alone;

[Setting category="General" name="Reload map on finish" description="Since the game doesn't give you the full menu after finishing, this allows for ghost selection"]
bool S_ReloadMapOnFinish = false;
