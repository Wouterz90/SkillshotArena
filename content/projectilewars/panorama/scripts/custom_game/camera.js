"use strict";
/*let previousMousePosition:[number,number] = [0.5,0.5]
const n = 0.45
function CameraThink() {
  $.Schedule(0.01,function(){CameraThink();})
  if (Game.GetState() < DOTA_GameState.DOTA_GAMERULES_STATE_PRE_GAME) { return;}
  if (!hidden) {HideStuff();}
  // Camera defaults
  let pan = $.GetContextPanel().GetParent().GetParent()
  

  let player = Players.GetLocalPlayer();
  let hero = Players.GetPlayerHeroEntityIndex(player);
  let hero_origin = ArrayToVector(Entities.GetAbsOrigin(hero));
  let forward = ArrayToVector(Entities.GetForward(hero));
  let target_origin = hero_origin.Add(forward.Scale(distance))
  let up = new Vector(0,1,0)
  let dot = up.Dot(forward)
  let a = dot/(up.Length() * forward.Length())
  let value = Math.acos(a)
  let degrees = value/Math.PI  * 180

  let cross = up.Cross(forward)
  if (cross.z < 0) {
    degrees = -degrees
  }

  
  GameUI.SetCameraTargetPosition(VectorToArray(target_origin),0.01);
  GameUI.SetCameraYaw(degrees)
  let mousePosition:[number,number] = [GameUI.GetCursorPosition()[0] / Game.GetScreenWidth(),GameUI.GetCursorPosition()[1] / Game.GetScreenHeight()]
  if (GameUI.IsControlDown()) {
    if (mousePosition[0] > 1-n) {
      let rotation = (mousePosition[0]-(1-n)) / n
      GameEvents.SendCustomGameEventToServer("ButtonPressed",{button:"MouseLeft",pressed:0})
      GameEvents.SendCustomGameEventToServer("ButtonPressed",{button:"MouseRight",pressed:(rotation+0.15)*150})
    } else if (mousePosition[0] < n  ) {
      let rotation = (n-mousePosition[0]) / n
      GameEvents.SendCustomGameEventToServer("ButtonPressed",{button:"MouseRight",pressed:0})
      GameEvents.SendCustomGameEventToServer("ButtonPressed",{button:"MouseLeft",pressed:(rotation+0.15)*150})
    } else {
      GameEvents.SendCustomGameEventToServer("ButtonPressed",{button:"MouseLeft",pressed:0})
      GameEvents.SendCustomGameEventToServer("ButtonPressed",{button:"MouseRight",pressed:0})
    }
  } else {
    GameEvents.SendCustomGameEventToServer("ButtonPressed",{button:"MouseLeft",pressed:0})
    GameEvents.SendCustomGameEventToServer("ButtonPressed",{button:"MouseRight",pressed:0})
  }



    let difference = mousePosition[0] - previousMousePosition[0]
    
    if (Math.abs(difference) < 0.0025 && mousePosition[0] < 0.999 && mousePosition[0] > 0.001) {
      GameEvents.SendCustomGameEventToServer("ButtonPressed",{button:"MouseLeft",pressed:0})
      GameEvents.SendCustomGameEventToServer("ButtonPressed",{button:"MouseRight",pressed:0})
    } else if (difference > 0 || mousePosition[0] > 0.999) {
      difference = mousePosition[0] < 0.999 ? difference : 0.025
      GameEvents.SendCustomGameEventToServer("ButtonPressed",{button:"MouseLeft",pressed:0})
      GameEvents.SendCustomGameEventToServer("ButtonPressed",{button:"MouseRight",pressed:difference*400})
    } else if (difference < 0 || mousePosition[0] < 0.001) {
      difference = mousePosition[0] > 0.001 ? difference : -0.025
      GameEvents.SendCustomGameEventToServer("ButtonPressed",{button:"MouseLeft",pressed:difference*-400})
      GameEvents.SendCustomGameEventToServer("ButtonPressed",{button:"MouseRight",pressed:0})
    }
  } else {
    GameEvents.SendCustomGameEventToServer("ButtonPressed",{button:"MouseLeft",pressed:0})
    GameEvents.SendCustomGameEventToServer("ButtonPressed",{button:"MouseRight",pressed:0})
  }
   
  previousMousePosition = mousePosition

  GameUI.SetCameraPitchMin(15);
  GameUI.SetCameraPitchMax(15);
  
  GameUI.SetCameraLookAtPositionHeightOffset(hero_origin.z-225);
  GameUI.SetCameraDistance(750);


const distance = 850;
let prevPitch = 0;
//CameraThink();
}*/
// Remove shitty things
function HideStuff() {
    var pan = $.GetContextPanel().GetParent().GetParent();
    var center_block = pan.FindChildTraverse("center_block");
    if (center_block) {
        hidden = true;
    }
    pan.FindChildTraverse("StatBranch").style.visibility = "collapse";
    pan.FindChildTraverse("inventory").style.visibility = "collapse";
    pan.FindChildTraverse("PortraitContainer").style.visibility = "collapse";
    pan.FindChildTraverse("PortraitBacker").style.visibility = "collapse";
    pan.FindChildTraverse("HUDSkinPortrait").style.visibility = "collapse";
    pan.FindChildTraverse("left_flare").style.visibility = "collapse";
    pan.FindChildTraverse("right_flare").style.visibility = "collapse";
    pan.FindChildTraverse("PortraitBackerColor").style.visibility = "collapse";
    pan.FindChildTraverse("xp").style.visibility = "collapse";
    pan.FindChildTraverse("health_mana").style.visibility = "collapse";
    pan.FindChildTraverse("stats_tooltip_region").style.visibility = "collapse";
    pan.FindChildTraverse("stats_container").style.visibility = "collapse";
    pan.FindChildTraverse("unitname").style.visibility = "collapse";
    pan.FindChildTraverse("HUDSkinAbilityContainerBG").style.visibility = "collapse";
    pan.FindChildTraverse("AbilityLevelContainer").style.visibility = "collapse";
    pan.GetParent().FindChildTraverse("debuffs").style.visibility = "collapse";
    pan.GetParent().FindChildTraverse("buffs").style.visibility = "collapse";
    for (var _i = 0, _a = pan.FindChildrenWithClassTraverse("AbilityInsetShadowRight"); _i < _a.length; _i++) {
        var p = _a[_i];
        p.style.visibility = "collapse";
    }
    for (var _b = 0, _c = pan.FindChildrenWithClassTraverse("AbilityInsetShadowLeft"); _b < _c.length; _b++) {
        var p = _c[_b];
        p.style.visibility = "collapse";
    }
    var panel = pan.FindChildTraverse("AbilitiesAndStatBranch");
    panel.style.marginBottom = "0px";
    pan.FindChildTraverse("buffs").style.marginBottom = "100px";
    /*let i = 0
    do {
      if (center_block.GetChild(i).id != "AbilitiesAndStatBranch") {
        center_block.GetChild(i).style.visibility = "collapse"
      }
      i = i+1
    } while (center_block.GetChild(i));*/
    pan.FindChildTraverse("AbilitiesAndStatBranch").FindChild("StatBranch").style.visibility = "collapse";
}
var hidden = false;
HideStuff();
