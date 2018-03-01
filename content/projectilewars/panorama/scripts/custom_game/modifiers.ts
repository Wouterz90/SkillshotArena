let modifiers = {}
let modifierContainerPanel:Panel
function CreateModifierPanel(name:string,abilityName:string,starttime:number,endtime:number,buff:boolean,buffindex:number) {
  
  if (!modifierContainerPanel) {
    let pan = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("CustomUIContainer_Hud")
    modifierContainerPanel = $.CreatePanel("Panel",pan,"modifier_container")
    modifierContainerPanel.style.verticalAlign = "bottom"
    //@ts-ignore
    modifierContainerPanel.style.horizontalAlign = "center"
    //@ts-ignore
    modifierContainerPanel.style.flowChildren = "right"
    modifierContainerPanel.style.marginBottom = "130px"

  }

  if (abilityName.match("item")) {
    abilityName = "_" + abilityName
  }

  let modifierContainer = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("modifier_container") || modifierContainerPanel
  let bg = $.CreatePanel("Panel",modifierContainer,"modifier_border")
  bg.style.width = "42.5px"
  bg.style.height = "42.5px"
  bg.style.borderRadius = "100%"
  bg.style.zIndex = "1"
  bg.style.backgroundColor = buff ? "green" : "red"
  bg.style.verticalAlign = "center"
  //@ts-ignore
  bg.style.horizontalAlign = "center"

  let main = $.CreatePanel("DOTAAbilityImage",bg,"modifier")
  main.abilityname = abilityName
  main.style.width = "40px"
  main.style.height = "40px"
  main.style.borderRadius = "100%"
  main.style.zIndex = "2"
  main.style.margin = "1px 1px 1px 1px"
  main.style.verticalAlign = "center"
  //@ts-ignore
  main.style.horizontalAlign = "center"

  main.SetPanelEvent(PanelEvent.ON_MOUSE_OVER,()=>{
    $.DispatchEvent( "DOTAShowTitleTextTooltip", "#"+name,"#"+name + "_description"  );
  })

  main.SetPanelEvent(PanelEvent.ON_MOUSE_OUT,()=>{
    $.DispatchEvent( "DOTAHideTitleTextTooltip")
  })

  let m = new modifier(name,abilityName,starttime,endtime,buff,main,bg,buffindex)
  modifiers[buffindex] = m

}

class modifier  {
  modifierName:string
  abilityname:string
  endTime:number
  startTime:number
  isBuff:boolean
  panel:AbilityImage
  ring: Panel
  buffIndex:number

  constructor(name:string,abilityName:string,starttime:number,endtime,buff:boolean,panel:AbilityImage,ring:Panel,buffindex:number) {
    this.modifierName = name
    this.abilityname = abilityName
    this.startTime = starttime
    this.endTime =endtime
    this.isBuff = buff
    this.panel = panel
    this.ring = ring
    this.buffIndex = buffindex
  }
}


//CreateModifierPanel("modifier_laser_blind","pudge_meat_hook",30,true) 
//CreateModifierPanel("modifier_laser_blind","pudge_rot",30,true) 

function ManageModifiers() {
  if (!modifierContainerPanel) {
    let pan = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("CustomUIState_HUD")
    if (pan) {
      modifierContainerPanel = $.CreatePanel("Panel",pan,"modifier_container")
    }
  }
  $.Schedule(0.01,function(){ManageModifiers();})
  let hero = Players.GetSelectedEntities(Players.GetLocalPlayer())[0]
  for (let i =0;i< Entities.GetNumBuffs(hero);i++) {
    let buff = Entities.GetBuff(hero,i)
    if (modifiers && !Buffs.IsHidden(hero,buff) && !modifiers[buff]) {
      let name = Buffs.GetName(hero,buff)
      let ability = Buffs.GetAbility(hero,buff)
      let startTime = Buffs.GetCreationTime(hero,buff)
      let endTIme = Buffs.GetDieTime(hero,buff)
      let isBuff = !Buffs.IsDebuff(hero,buff)
      CreateModifierPanel(name,Abilities.GetAbilityName(ability),startTime,endTIme,isBuff,buff) 
    }
  }


  for (let j in modifiers) {
    let modifier = modifiers[j]
    let mod = modifier.panel
    let ring = modifier.ring
    ring.style.backgroundColor = modifier.isBuff ? "green" : "red"
    let totalDuration = modifier.endTime - modifier.startTime
    let elapsedTime = Game.GetGameTime() - modifier.startTime
    let percent = 1 - (elapsedTime / totalDuration)
   
    ring.style.clip = "radial(50% 50%, 0deg, " + percent * 360 + "deg)";
    if (percent <= 0) {
      mod.DeleteAsync(0)
      ring.DeleteAsync(0)
      delete modifiers[j]
      //let i = modifiers.indexOf(modifier)
      //if (i != -1) {
        //modifiers.slice(i)
      //}
    }
  }
}

ManageModifiers()