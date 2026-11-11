const string  PLUGIN_COLOR = "\\$c0c";
const string  PLUGIN_ICON  = Icons::User;
Meta::Plugin@ PLUGIN_META  = Meta::ExecutingPlugin();
const string  PLUGIN_TITLE = PLUGIN_COLOR + PLUGIN_ICON + "\\$g " + PLUGIN_META.Name;

void Main() {
    auto App = cast<CTrackMania>(GetApp());

    string lastUid, uid;

    while (true) {
        yield();

        auto Playground = cast<CTrackManiaRace>(App.CurrentPlayground);

        if (false
            or App.Challenge is null
            or Playground is null
            or App.Editor !is null
        ) {
            lastUid = uid = "";
            continue;
        }

        uid = App.Challenge.EdChallengeId;
        if (true
            and uid.Length > 0
            and uid != lastUid
        ) {
            lastUid = uid;
            OnEnteredMapAsync();
        }

#if DEPENDENCY_PLAYCHALLENGE

        if (true
            and S_Opponent != Opponent::None
            and S_ReloadMapOnFinish
            and App.Challenge.MapInfo !is null
            and Playground.UIConfigs.Length > 0
            and Playground.UIConfigs[0] !is null
            and Playground.UIConfigs[0].UISequence == CGamePlaygroundUIConfig::EUISequence::EndRound
        ) {
            warn("reloading map");
            PlayChallenge::Map(App.Challenge.MapInfo).Play();

            while (true
                and App.Challenge !is null
                and App.Challenge.EdChallengeId.Length > 0
            ) {
                yield();
            }
        }

#endif
    }
}

void RenderMenu() {
    if (UI::BeginMenu(PLUGIN_TITLE)) {
        if (UI::RadioButton("None (disabled)", S_Opponent == Opponent::None)) {
            S_Opponent = Opponent::None;
        }
        if (UI::RadioButton("Gold", S_Opponent == Opponent::Gold)) {
            S_Opponent = Opponent::Gold;
        }
        if (UI::RadioButton("Silver", S_Opponent == Opponent::Silver)) {
            S_Opponent = Opponent::Silver;
        }
        if (UI::RadioButton("Bronze", S_Opponent == Opponent::Bronze)) {
            S_Opponent = Opponent::Bronze;
        }
        if (UI::RadioButton("Alone", S_Opponent == Opponent::Alone)) {
            S_Opponent = Opponent::Alone;
        }

#if DEPENDENCY_PLAYCHALLENGE

        UI::Separator();
        S_ReloadMapOnFinish = UI::Checkbox("Reload map on finish", S_ReloadMapOnFinish);

#endif

        UI::EndMenu();
    }
}

void OnEnteredMapAsync() {
    trace("OnEnteredMapAsync");

    auto App = cast<CTrackMania>(GetApp());

    const int64 start = Time::Stamp;

    while (true) {
        yield();

        if (Time::Stamp - start > 10) {
            warn("OnEnteredMapAsync timed out");
            return;
        }

        if (S_Opponent == Opponent::None) {
            return;
        }

        auto Playground = cast<CTrackManiaRace>(App.CurrentPlayground);
        if (Playground is null) {
            // warn("Playground");
            continue;
        }

        auto Interface = cast<CTrackManiaRaceInterface>(Playground.Interface);
        if (false
            or Interface is null
            or Interface.ManialinkPage is null
            or Interface.ManialinkPage.Childs.Length < 27
        ) {
            // warn("Interface");
            continue;
        }

        /*
        25 end race
        26 opponent selection
        27 pause
        30 insert coin
        */

        auto OpponentFrame = cast<CControlFrame>(Interface.ManialinkPage.Childs[26]);
        if (false
            or OpponentFrame is null
            or OpponentFrame.Childs.Length < 2
        ) {
            // warn("OpponentFrame");
            continue;
        }

        const uint oppIndex = uint(S_Opponent);
        auto OpponentMenu = cast<CControlFrame>(OpponentFrame.Childs[1]);
        if (false
            or OpponentMenu is null
            or int(oppIndex) < 0
            or oppIndex >= OpponentMenu.Childs.Length
            or !OpponentMenu.IsVisible
            or !OpponentMenu.IsFocused
        ) {
            // warn("OpponentMenu");
            continue;
        }

        auto Opponent = cast<CControlFrame>(OpponentMenu.Childs[oppIndex]);
        if (false
            or Opponent is null
            or Opponent.Childs.Length < 2
        ) {
            // warn("Opponent");
            continue;
        }

        auto Button = cast<CControlQuad>(Opponent.Childs[1]);
        if (Button is null) {
            // warn("Button");
            continue;
        }

        Button.OnAction();
        trace("selected opponent '" + tostring(S_Opponent) + "'");
        return;
    }
}
