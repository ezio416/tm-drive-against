const string  pluginColor = "\\$C0C";
const string  pluginIcon  = Icons::User;
Meta::Plugin@ pluginMeta  = Meta::ExecutingPlugin();
const string  pluginTitle = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;

bool loading = false;

void Main() {
    auto App = cast<CTrackMania>(GetApp());

    string lastUid, uid;

    while (true) {
        yield();

        auto Playground = cast<CTrackManiaRaceNew>(App.CurrentPlayground);

        if (false
            or !S_Enabled
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

        if (true
            and S_ReloadMapOnFinish
            and !loading
            and App.Challenge.MapInfo !is null
            and Playground.UIConfigs.Length > 0
            and Playground.UIConfigs[0] !is null
            and Playground.UIConfigs[0].UISequence == CGamePlaygroundUIConfig::EUISequence::EndRound
        ) {
            print("RELOADING MAP");
            Map(App.Challenge.MapInfo).Play();
        }
    }
}

void RenderMenu() {
    if (UI::MenuItem(pluginTitle, "", S_Enabled)) {
        S_Enabled = !S_Enabled;
    }
}

void OnEnteredMapAsync() {
    print("OnEnteredMap");

    auto App = cast<CTrackMania>(GetApp());

    const int64 start = Time::Stamp;

    while (true) {
        yield();

        if (Time::Stamp - start > 10) {
            warn("OnEnteredMap timed out");
            return;
        }

        auto Playground = cast<CTrackManiaRaceNew>(App.CurrentPlayground);
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

        uint oppIndex = uint(S_Opponent);
        auto OpponentMenu = cast<CControlFrame>(OpponentFrame.Childs[1]);
        if (false
            or OpponentMenu is null
            or OpponentMenu.Childs.Length < oppIndex + 1
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
        print("selected opponent '" + tostring(S_Opponent) + "'");
        return;
    }
}

class Map {
    string name;
    string path;

    Map(CGameCtnChallengeInfo@ map) {
        name = map.Name;
        path = map.FileName;
    }

    void Play() {
        if (loading) {
            return;
        }
        loading = true;

        startnew(CoroutineFunc(PlayAsync));
    }

    private void PlayAsync() {
        print("loading map " + name + " from path " + path);

        auto App = cast<CTrackMania>(GetApp());
        App.BackToMainMenu();
        while (!App.ManiaTitleFlowScriptAPI.IsReady) {
            yield();
        }
        App.ManiaTitleFlowScriptAPI.PlayMap(path, "TMC_CampaignSolo", "");
        while (!App.ManiaTitleFlowScriptAPI.IsReady) {
            yield();
        }

        sleep(10000);
        loading = false;
    }
}
