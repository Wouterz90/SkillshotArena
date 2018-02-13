"use strict";
function SetUpHotKeys() {
    $.Schedule(0.1, function () { SetUpHotKeys(); });
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
    var hero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    var j = 0;
    var abilities = 0;
    for (var i = 0; i <= 6; i++) {
        ability = Entities.GetAbility(hero, i);
        if (ability && Abilities.GetAbilityName(ability) != "") {
            pan = DotaAbilityList.FindChildTraverse("Ability" + (i - j));
            pan.style.visibility = "visible";
            key = inputs[i];
            pan.style.width = "100px";
            var textP = pan.FindChildTraverse("HotkeyText");
            textP.text = key;
            pan.FindChildTraverse("AbilityLevelContainer").style.visibility = "collapse";
            pan.FindChildTraverse("ButtonWell").style.width = "100px";
            pan.FindChildTraverse("ButtonWell").style.height = "100px";
            pan.FindChildTraverse("ButtonSize").style.width = "100px";
            pan.FindChildTraverse("ButtonSize").style.height = "100px";
            pan.FindChildTraverse("HotkeyContainer").style.marginTop = "13%";
            pan.FindChildTraverse("HotkeyContainer").style.marginLeft = "10%";
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
var DotaAbilityList = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("abilities");
SetUpHotKeys();
