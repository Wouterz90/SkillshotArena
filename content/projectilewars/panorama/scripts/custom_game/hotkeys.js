"use strict";
var abilityPanels = [];
function SetUpHotKeys() {
    $.Schedule(0.01, function () { SetUpHotKeys(); });
    var inputs;
    inputs = [
        "_",
        Game.GetKeybindForAbility(0),
        Game.GetKeybindForAbility(1),
        Game.GetKeybindForAbility(2),
        Game.GetKeybindForAbility(3),
        Game.GetKeybindForAbility(4),
        Game.GetKeybindForAbility(5),
    ];
    //if (DotaAbilityList) {
    var abName;
    var ability;
    var key;
    var pan;
    var hero = Players.GetSelectedEntities(Players.GetLocalPlayer())[0];
    if (!hero) {
        return;
    }
    //let hero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    var j = 0;
    var abilities = 0;
    var hbar = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("BottomHealthbar");
    hbar.style.width = Entities.GetHealthPercent(hero) * 7 + "px";
    var red = Math.round(255 - (Entities.GetHealthPercent(hero) * 2.55));
    var green = Math.round(Entities.GetHealthPercent(hero) * 2.55);
    hbar.style.backgroundColor = "gradient( linear, 0% 33%, 66% 100%, from( rgb(" + red * 0.5 + "," + green * 0.5 + ",0) ), to( rgb(" + red + "," + green + ",0) ) )";
    for (var i = 0; i <= 6; i++) {
        ability = Entities.GetAbility(hero, i);
        if (ability && Abilities.GetAbilityName(ability) != "") {
            pan = DotaAbilityList.FindChildTraverse("Ability" + (i - j));
            if (!abilityPanels[i]) {
                abilityPanels[i] = pan;
            }
            if (pan.style.visibility != "visible") {
                pan.style.visibility = "visible";
            }
            key = inputs[i];
            pan.style.width = "100px";
            var textP = pan.FindChildTraverse("HotkeyText");
            textP.text = key;
            if (pan.FindChildTraverse("AbilityLevelContainer").style.visibility != "collapse") {
                pan.FindChildTraverse("AbilityLevelContainer").style.visibility = "collapse";
            }
            if (pan.FindChildTraverse("ButtonWell").style.width != "100px") {
                pan.FindChildTraverse("ButtonWell").style.width = "100px";
                pan.FindChildTraverse("ButtonWell").style.height = "100px";
                pan.FindChildTraverse("ButtonSize").style.width = "100px";
                pan.FindChildTraverse("ButtonSize").style.height = "100px";
                pan.FindChildTraverse("Hotkey").style.visibility = "visible";
                pan.FindChildTraverse("HotkeyContainer").style.marginTop = "13%";
                pan.FindChildTraverse("HotkeyContainer").style.marginLeft = "10%";
                var numPanel = pan.FindChildTraverse("GoldCostBG");
                numPanel.style.width = "50px";
                numPanel.style.height = "50px";
                var numPanelText = pan.FindChildTraverse("GoldCost");
                if (numPanelText.text && Number(numPanelText.text) > 0) {
                    numPanelText.style.fontSize = "30px";
                }
            }
            abilities = abilities + 1;
        }
        else {
            j = j + 1;
        }
    }
    // Hide unused ability panels
    for (var i = 6; i >= abilities; i--) {
        pan = DotaAbilityList.FindChildTraverse("Ability" + (i));
        if (pan) {
            pan.style.visibility = "collapse";
        }
    }
    /*
    for (let i=2;i < 6;i++) {
      pan = DotaAbilityList.FindChildTraverse("Ability"+(i));
      if (pan) {
        let image:AbilityImage = pan.FindChildTraverse("AbilityImage");
        let s:string = image.abilityname;
        if (s == "") {
          pan.style.visibility = "collapse";
        }
      }
    }*/
    //} 
}
function MouseTooltipManager() {
    $.Schedule(0.01, function () { MouseTooltipManager(); });
    if (Game.GetState() < DOTA_GameState.DOTA_GAMERULES_STATE_PRE_GAME) {
        return;
    }
    // Abilities
    for (var _i = 0, abilityPanels_1 = abilityPanels; _i < abilityPanels_1.length; _i++) {
        var panel = abilityPanels_1[_i];
        //$.Msg(panel)
        if (panel.visible == true) {
            var x = Math.abs(panel.GetPositionWithinWindow().x + 35 - GameUI.GetCursorPosition()[0]);
            var y = Math.abs(panel.GetPositionWithinWindow().y + 70 - GameUI.GetCursorPosition()[1]);
            if (x < 35 && y < 35) {
                var name_1 = panel.id.substr(7);
                var hero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
                var ability = Entities.GetAbility(hero, Number(name_1));
                name_1 = Abilities.GetAbilityName(ability);
                $.DispatchEvent("DOTAShowAbilityTooltip", panel, name_1);
                return;
            }
            else {
                //$.DispatchEvent( "DOTAHideAbilityTooltip");
            }
        }
    }
    // Debuffs
    // No way to get the image source
    /*let debuffMainPanel = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("debuffs")
    for (let i =0; i <=7;i++) {
      let panel = debuffMainPanel.GetChild(i)
      if (!panel.BHasClass("Hidden")) {
        let x = Math.abs(panel.GetPositionWithinWindow().x+35 -GameUI.GetCursorPosition()[0])
        let y = Math.abs(panel.GetPositionWithinWindow().y+70-GameUI.GetCursorPosition()[1])
        if (x < 20 && y < 20) {
          let childPan = panel.FindChildTraverse("BuffImage") as ImagePanel
          if (childPan) {
            let name = childPan.src
  
            name = name.substr(40,name.length - 4)
            // Name is the texture icon now
            name = GetBuffAbility(name)
            let hero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
            
            
            $.DispatchEvent( "DOTAShowBuffTooltip", panel,name );
            return
          } else {
            //$.DispatchEvent( "DOTAHideBuffTooltip");
          }
        }
      }
    }
    // Buffs
    let buffMainPanel = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("buffs")
    for (let i =0; i <=7;i++) {
      let panel = buffMainPanel.GetChild(i)
      if (!panel.BHasClass("Hidden")) {
        let x = Math.abs(panel.GetPositionWithinWindow().x+10 -GameUI.GetCursorPosition()[0])
        let y = Math.abs(panel.GetPositionWithinWindow().y+10-GameUI.GetCursorPosition()[1])
        $.Msg(x,"  ",y  )
        if (x < 20 && y < 20) {
          let childPan = panel.FindChildTraverse("BuffImage") as ImagePanel
          if (childPan) {
            let name = childPan.src
            name = name.substr(40,name.length - 4)
            // Name is the texture icon now
            name = GetBuffAbility(name)
            let hero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
            
            
            $.DispatchEvent( "DOTAShowBuffTooltip", panel,name );
            return
          } else {
            //$.DispatchEvent( "DOTAHideBuffTooltip");
          }
        }
      }
    }
    */
    //$.DispatchEvent( "DOTAHideBuffTooltip");
    $.DispatchEvent("DOTAHideAbilityTooltip");
}
function SilenceAbilities(kv) {
    for (var _i = 0, _a = kv.silenceIndex; _i < _a.length; _i++) {
        var i = _a[_i];
        if (DotaAbilityList.FindChildTraverse("Ability" + i)) {
            var silencePanel = $.CreatePanel("Image", DotaAbilityList.FindChildTraverse("Ability" + i).FindChildTraverse("AbilityButton"), "SilencedAbility");
            silencePanel.AddClass("SilenceAbility");
            silencePanel.SetImage("file://{images}/custom_game/silence.png");
        }
    }
}
function UnSilenceAbilities(kv) {
    for (var _i = 0, _a = kv.silenceIndex; _i < _a.length; _i++) {
        var i = _a[_i];
        var pan = DotaAbilityList.FindChildTraverse("Ability" + i);
        if (pan) {
            var panel = pan.FindChildTraverse("SilencedAbility");
            if (panel) {
                panel.DeleteAsync(0);
            }
        }
    }
}
var DotaAbilityList = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("abilities");
SetUpHotKeys();
MouseTooltipManager();
GameUI.SetMouseCallback(function (eventName, arg) {
    if (eventName == "pressed" && arg === 0 && GameUI.GetClickBehaviors() == CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE) {
        CastAbility_0();
        return true;
    }
    return false;
});
GameEvents.Subscribe("hero_silence_created", SilenceAbilities);
GameEvents.Subscribe("hero_silence_removed", UnSilenceAbilities);
