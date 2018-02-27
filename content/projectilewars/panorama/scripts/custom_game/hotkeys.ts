let abilityPanels:Panel[] = []

function SetUpHotKeys() : void {
  $.Schedule(0.01,function(){SetUpHotKeys();})
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
    let hero = Players.GetSelectedEntities(Players.GetLocalPlayer())[0]
    if (!hero) {return}
    //let hero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    let j = 0;
    let abilities:number = 0

    let hbar = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("BottomHealthbar")
    hbar.style.width = Entities.GetHealthPercent(hero)*7 + "px"
    
    let red = Math.round(255 - (Entities.GetHealthPercent(hero) * 2.55))
    let green =  Math.round(Entities.GetHealthPercent(hero) * 2.55)
    
    hbar.style.backgroundColor = "gradient( linear, 0% 33%, 66% 100%, from( rgb("+red*0.5+","+green*0.5+",0) ), to( rgb("+red+","+green+",0) ) )";

    for(let i = 0 ; i <=6 ; i++) {
      ability = Entities.GetAbility(hero,i)
      if (ability && Abilities.GetAbilityName(ability) != "") {
        pan = DotaAbilityList.FindChildTraverse("Ability"+(i-j  ));
        if (!abilityPanels[i]) {
          abilityPanels[i] = pan
        }

        if (pan.style.visibility != "visible") {
          pan.style.visibility = "visible"
        }
        key = inputs[i];

        pan.style.width = "100px";
        let textP = pan.FindChildTraverse("HotkeyText") as LabelPanel
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

          let numPanel = pan.FindChildTraverse("GoldCostBG")
          numPanel.style.width = "50px"
          numPanel.style.height = "50px"
          let numPanelText = pan.FindChildTraverse("GoldCost") as LabelPanel
          if (numPanelText.text && Number(numPanelText.text) > 0) {
            numPanelText.style.fontSize = "30px"
          }
        }
        


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
  
  if (Game.GetState() < DOTA_GameState.DOTA_GAMERULES_STATE_PRE_GAME) { 
    return
  } 
  // Abilities
  for (let panel of abilityPanels) {
    //$.Msg(panel)
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

function SilenceAbilities(kv:{silenceIndex:number[]}) {
  for (let i of kv.silenceIndex) {
    if (DotaAbilityList.FindChildTraverse("Ability"+i)) {
      let silencePanel = $.CreatePanel("Image",DotaAbilityList.FindChildTraverse("Ability"+i).FindChildTraverse("AbilityButton"),"SilencedAbility")
      silencePanel.AddClass("SilenceAbility")
      silencePanel.SetImage("file://{images}/custom_game/silence.png")
    }

  }
}

function UnSilenceAbilities(kv) {
  for (let i of kv.silenceIndex) {
    let pan = DotaAbilityList.FindChildTraverse("Ability"+i)

    if (pan) {
      let panel = pan.FindChildTraverse("SilencedAbility")
      if (panel) {
        panel.DeleteAsync(0)
      }
    }
  }
}

const DotaAbilityList = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("abilities");
SetUpHotKeys();
MouseTooltipManager();
GameUI.SetMouseCallback( (eventName,arg) => {
  if (eventName == "pressed" && arg === 0 && GameUI.GetClickBehaviors() == CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE) {
    CastAbility_0()
    return true
  }
  return false
})

GameEvents.Subscribe("hero_silence_created",SilenceAbilities)
GameEvents.Subscribe("hero_silence_removed",UnSilenceAbilities)