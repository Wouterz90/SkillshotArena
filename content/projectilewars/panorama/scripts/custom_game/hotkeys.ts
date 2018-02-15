let abilityPanels:Panel[] = []

function SetUpHotKeys() : void {
  $.Schedule(0.1,function(){SetUpHotKeys();})
  let inputs: [string,string,string,string,string,string,string];
  inputs = [
    "_",
    Game.GetKeybindForAbility(0),
    Game.GetKeybindForAbility(1),
    Game.GetKeybindForAbility(2),
    Game.GetKeybindForAbility(3),
    Game.GetKeybindForAbility(4),
    Game.GetKeybindForAbility(5),
  ]
  

  //if (DotaAbilityList) {
    let abName:AbilityImage ;
    let ability:number;
    let key: string;
    let pan:Panel;
    let hero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    let j = 0;
    let abilities:number = 0

    for(let i = 0 ; i <=6 ; i++) {
      ability = Entities.GetAbility(hero,i)
      if (ability && Abilities.GetAbilityName(ability) != "") {
        pan = DotaAbilityList.FindChildTraverse("Ability"+(i-j  ));
        if (!abilityPanels[i]) {
          abilityPanels[i] = pan
        }

        pan.style.visibility = "visible"
        
        key = inputs[i];

        pan.style.width = "100px";
        let textP = pan.FindChildTraverse("HotkeyText") as LabelPanel
        textP.text = key;
        pan.FindChildTraverse("AbilityLevelContainer").style.visibility = "collapse";
        pan.FindChildTraverse("ButtonWell").style.width = "100px";
        pan.FindChildTraverse("ButtonWell").style.height = "100px";
        pan.FindChildTraverse("ButtonSize").style.width = "100px";
        pan.FindChildTraverse("ButtonSize").style.height = "100px";
        pan.FindChildTraverse("Hotkey").style.visibility = "visible";
        pan.FindChildTraverse("HotkeyContainer").style.marginTop = "13%";
        pan.FindChildTraverse("HotkeyContainer").style.marginLeft = "10%";



        abilities = abilities +1 
      } else { 
        j = j + 1
      }
    }
    // Hide unused ability panels
    for (let i=6;i >= abilities;i--) {
      pan = DotaAbilityList.FindChildTraverse("Ability"+(i));
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

function MouseTooltipManager():void {
  $.Schedule(0.01,function(){MouseTooltipManager();})
  // Abilities
  for (let panel of abilityPanels) {
    if (panel.visible == true) {
      let x = Math.abs(panel.GetPositionWithinWindow().x+35 -GameUI.GetCursorPosition()[0])
      let y = Math.abs(panel.GetPositionWithinWindow().y+70-GameUI.GetCursorPosition()[1])
      if (x < 35 && y < 35) {
        let name = panel.id.substr(7)
        let hero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
        let ability = Entities.GetAbility(hero,Number(name))
        name = Abilities.GetAbilityName(ability)
        
        $.DispatchEvent( "DOTAShowAbilityTooltip", panel,name );
        return
      } else {
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
  $.DispatchEvent( "DOTAHideAbilityTooltip");
  
}

const DotaAbilityList = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("abilities");
SetUpHotKeys();
MouseTooltipManager();


//DOTAShowBuffTooltip

function GetBuffAbility(textureName:string):string {
  if (textureName == "kobold_taskmaster_speed_aura") {
    return "item_rune_speedshot"
  } else if (textureName == "medusa_split_shot") {
    return "item_rune_multishot"
  } else if (textureName == "rune_haste") {
    return "item_rune_haste"
  } else if (textureName == "obsidian_destroyer_essence_aura") {
    return "item_rune_castpoint"
  } else if (textureName == "wisp_spirits") {
    return "item_rune_turnrate"
  }
  return ""
}