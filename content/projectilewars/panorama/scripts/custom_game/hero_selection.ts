// FUCK THIS
function SetupHeroSelection() {
  let hudElements = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("HUDElements");
  let dotaHud = $.GetContextPanel().GetParent().GetParent().GetParent()
  let customUI = dotaHud.FindChildTraverse("PreGame")
  let heroSelection
  if (heroSelection == null) { 
    heroSelection = $.CreatePanel( "Panel", customUI, "HeroSelection" )
    heroSelection.BLoadLayout( "file://{resources}/layout/custom_game/hero_selection.xml", false, false )
    heroSelection.style.visibility = "visible"
  }
}

function MarkUnavailableHeroes(kv:{heronames:string[]}) {

}

function SubmitHeroPick(heroname:string) {
  GameEvents.SendCustomGameEventToServer("submit_hero_pick",{heroName:heroname})
}

GameEvents.Subscribe("mark_unavailable_heroes",MarkUnavailableHeroes)