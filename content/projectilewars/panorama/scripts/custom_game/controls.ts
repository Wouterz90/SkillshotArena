let inputSpell_0: string = "space"
let inputSpell_1: string = Game.GetKeybindForAbility(0);
let inputSpell_2: string = Game.GetKeybindForAbility(1);
let inputSpell_3: string = Game.GetKeybindForAbility(2);
let inputSpell_4: string = Game.GetKeybindForAbility(3);
let inputSpell_5: string = Game.GetKeybindForAbility(4);
let inputSpell_6: string = Game.GetKeybindForAbility(5);


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



function CastAbility_0(): void {
  let player = Players.GetLocalPlayer()
  let hero = Players.GetPlayerHeroEntityIndex(player)
  let ability = Entities.GetAbility(hero,0)
  Abilities.ExecuteAbility(ability, hero, true )
}

function CastAbility_1(): void {
  let player = Players.GetLocalPlayer()
  let hero = Players.GetPlayerHeroEntityIndex(player)
  let ability = Entities.GetAbility(hero,1)
  Abilities.ExecuteAbility(ability, hero, true )
}

function CastAbility_2(): void {
  let player = Players.GetLocalPlayer()
  let hero = Players.GetPlayerHeroEntityIndex(player)
  let ability = Entities.GetAbility(hero,2)
  Abilities.ExecuteAbility(ability, hero, true )
}

function CastAbility_3(): void {
  let player = Players.GetLocalPlayer()
  let hero = Players.GetPlayerHeroEntityIndex(player)
  let ability = Entities.GetAbility(hero,3)
  Abilities.ExecuteAbility(ability, hero, true )
}

function CastAbility_4(): void {
  let player = Players.GetLocalPlayer()
  let hero = Players.GetPlayerHeroEntityIndex(player)
  let ability = Entities.GetAbility(hero,4)
  Abilities.ExecuteAbility(ability, hero, true )
}

function CastAbility_5(): void {
  let player = Players.GetLocalPlayer()
  let hero = Players.GetPlayerHeroEntityIndex(player)
  let ability = Entities.GetAbility(hero,5)
  Abilities.ExecuteAbility(ability, hero, true )
}

function CastAbility_6(): void {
  let player = Players.GetLocalPlayer()
  let hero = Players.GetPlayerHeroEntityIndex(player)
  let ability = Entities.GetAbility(hero,6)
  Abilities.ExecuteAbility(ability, hero, true )
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

Game.AddCommand( "CastAbility_0", CastAbility_0, "", 0 );
Game.AddCommand( "CastAbility_1", CastAbility_1, "", 0 );
Game.AddCommand( "CastAbility_2", CastAbility_2, "", 0 );
Game.AddCommand( "CastAbility_3", CastAbility_3, "", 0 );
Game.AddCommand( "CastAbility_4", CastAbility_4, "", 0 );
Game.AddCommand( "CastAbility_5", CastAbility_5, "", 0 );
Game.AddCommand( "CastAbility_6", CastAbility_6, "", 0 );

/*
Game.AddCommand( "+MUpPressed", UpButtonPressedFunc, "", 0 );
Game.AddCommand( "-MUpPressed", UpButtonReleasedFunc, "", 0 );

Game.AddCommand( "+MRightPressed", RightButtonPressedFunc, "", 0 );
Game.AddCommand( "-MRightPressed", RightButtonReleasedFunc, "", 0 );

Game.AddCommand( "+MLeftPressed", LeftButtonPressedFunc, "", 0 );
Game.AddCommand( "-MLeftPressed", LeftButtonReleasedFunc, "", 0 );

Game.AddCommand( "+MDownPressed", DownButtonPressedFunc, "", 0 );
Game.AddCommand( "-MDownPressed", DownButtonReleasedFunc, "", 0 );*/