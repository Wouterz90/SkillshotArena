"use strict";
var inputSpell_0 = "space";
var inputSpell_1 = Game.GetKeybindForAbility(0);
var inputSpell_2 = Game.GetKeybindForAbility(1);
var inputSpell_3 = Game.GetKeybindForAbility(2);
var inputSpell_4 = Game.GetKeybindForAbility(3);
var inputSpell_5 = Game.GetKeybindForAbility(4);
var inputSpell_6 = Game.GetKeybindForAbility(5);
/*
function DownButtonPressedFunc(): void {
  GameEvents.SendCustomGameEventToServer("ButtonPressed",{button:"Backward",pressed:true})
}

function DownButtonReleasedFunc(): void {
  GameEvents.SendCustomGameEventToServer("ButtonPressed",{button:"Backward",pressed:false})
}

function UpButtonPressedFunc(): void {
  GameEvents.SendCustomGameEventToServer("ButtonPressed",{button:"Forward",pressed:true})
}

function UpButtonReleasedFunc(): void {
  GameEvents.SendCustomGameEventToServer("ButtonPressed",{button:"Forward",pressed:false})
}

function LeftButtonPressedFunc(): void {
  GameEvents.SendCustomGameEventToServer("ButtonPressed",{button:"Left",pressed:true})
}

function LeftButtonReleasedFunc(): void {
  GameEvents.SendCustomGameEventToServer("ButtonPressed",{button:"Left",pressed:false})
}

function RightButtonPressedFunc(): void {
  GameEvents.SendCustomGameEventToServer("ButtonPressed",{button:"Right",pressed:true})
}

function RightButtonReleasedFunc(): void {
  GameEvents.SendCustomGameEventToServer("ButtonPressed",{button:"Right",pressed:false})
}
*/
function CastAbility_0() {
    var player = Players.GetLocalPlayer();
    var hero = Players.GetPlayerHeroEntityIndex(player);
    var ability = Entities.GetAbility(hero, 0);
    SendAbilityEventToServer(ability, hero);
}
function CastAbility_1() {
    var player = Players.GetLocalPlayer();
    var hero = Players.GetPlayerHeroEntityIndex(player);
    var ability = Entities.GetAbility(hero, 1);
    SendAbilityEventToServer(ability, hero);
}
function CastAbility_2() {
    var player = Players.GetLocalPlayer();
    var hero = Players.GetPlayerHeroEntityIndex(player);
    var ability = Entities.GetAbility(hero, 2);
    SendAbilityEventToServer(ability, hero);
}
function CastAbility_3() {
    var player = Players.GetLocalPlayer();
    var hero = Players.GetPlayerHeroEntityIndex(player);
    var ability = Entities.GetAbility(hero, 3);
    SendAbilityEventToServer(ability, hero);
}
function CastAbility_4() {
    var player = Players.GetLocalPlayer();
    var hero = Players.GetPlayerHeroEntityIndex(player);
    var ability = Entities.GetAbility(hero, 4);
    SendAbilityEventToServer(ability, hero);
}
function CastAbility_5() {
    var player = Players.GetLocalPlayer();
    var hero = Players.GetPlayerHeroEntityIndex(player);
    var ability = Entities.GetAbility(hero, 5);
    SendAbilityEventToServer(ability, hero);
}
function CastAbility_6() {
    var player = Players.GetLocalPlayer();
    var hero = Players.GetPlayerHeroEntityIndex(player);
    var ability = Entities.GetAbility(hero, 6);
    SendAbilityEventToServer(ability, hero);
}
function SendAbilityEventToServer(ability, hero) {
    if (Abilities.GetBehavior(ability) <= DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_CHANNEL) {
        Abilities.ExecuteAbility(ability, hero, true);
    }
    else {
        if (Abilities.AbilityReady(ability) == -1) {
            $.Msg(Abilities.GetAbilityName(ability));
            VectorTargetStart(ability);
        }
        else {
            Abilities.ExecuteAbility(ability, hero, true);
        }
    }
}
/*GameUI.SetMouseCallback( (eventName,arg) => {
  if (eventName == "pressed" && arg === 0 && GameUI.GetClickBehaviors() == CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE) {
    CastAbility_0()
    return true
  }
  return false
})*/
Game.CreateCustomKeyBind(inputSpell_0, "CastAbility_0");
Game.CreateCustomKeyBind(inputSpell_1, "CastAbility_1");
Game.CreateCustomKeyBind(inputSpell_2, "CastAbility_2");
Game.CreateCustomKeyBind(inputSpell_3, "CastAbility_3");
Game.CreateCustomKeyBind(inputSpell_4, "CastAbility_4");
Game.CreateCustomKeyBind(inputSpell_5, "CastAbility_5");
Game.CreateCustomKeyBind(inputSpell_6, "CastAbility_6");
Game.AddCommand("CastAbility_0", CastAbility_0, "", 0);
Game.AddCommand("CastAbility_1", CastAbility_1, "", 0);
Game.AddCommand("CastAbility_2", CastAbility_2, "", 0);
Game.AddCommand("CastAbility_3", CastAbility_3, "", 0);
Game.AddCommand("CastAbility_4", CastAbility_4, "", 0);
Game.AddCommand("CastAbility_5", CastAbility_5, "", 0);
Game.AddCommand("CastAbility_6", CastAbility_6, "", 0);
/*
Game.AddCommand( "+MUpPressed", UpButtonPressedFunc, "", 0 );
Game.AddCommand( "-MUpPressed", UpButtonReleasedFunc, "", 0 );

Game.AddCommand( "+MRightPressed", RightButtonPressedFunc, "", 0 );
Game.AddCommand( "-MRightPressed", RightButtonReleasedFunc, "", 0 );

Game.AddCommand( "+MLeftPressed", LeftButtonPressedFunc, "", 0 );
Game.AddCommand( "-MLeftPressed", LeftButtonReleasedFunc, "", 0 );

Game.AddCommand( "+MDownPressed", DownButtonPressedFunc, "", 0 );
Game.AddCommand( "-MDownPressed", DownButtonReleasedFunc, "", 0 );*/
