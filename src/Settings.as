enum Opponent {
    None   = -1,
    Gold   = 6,
    Silver = 7,
    Bronze = 8,
    Alone  = 9,
}

[Setting category="General" name="Opponent"]
Opponent S_Opponent = Opponent::None;

[Setting category="General" name="Reload map on finish"
description="Since the game doesn't give you the full menu after finishing, this allows for ghost selection. Requires PlayChallenge dependency."]
bool S_ReloadMapOnFinish = false;
