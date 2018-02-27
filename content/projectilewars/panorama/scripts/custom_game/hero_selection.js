"use strict";
// FUCK THIS
function SetupHeroSelection() {
    var hudElements = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("HUDElements");
    var dotaHud = $.GetContextPanel().GetParent().GetParent().GetParent();
    var customUI = dotaHud.FindChildTraverse("PreGame");
    var heroSelection;
    if (heroSelection == null) {
        heroSelection = $.CreatePanel("Panel", customUI, "HeroSelection");
        heroSelection.BLoadLayout("file://{resources}/layout/custom_game/hero_selection.xml", false, false);
        heroSelection.style.visibility = "visible";
    }
}
function MarkUnavailableHeroes(kv) {
}
function SubmitHeroPick(heroname) {
    GameEvents.SendCustomGameEventToServer("submit_hero_pick", { heroName: heroname });
}
GameEvents.Subscribe("mark_unavailable_heroes", MarkUnavailableHeroes);
