require("typescript_lualib")
function SetupHeroSelection()
    local hudElements = Panel.FindChildTraverse(Panel.GetParent(Panel.GetParent(DollarStatic.GetContextPanel($))),"HUDElements")

    local dotaHud = Panel.GetParent(Panel.GetParent(Panel.GetParent(DollarStatic.GetContextPanel($))))

    local customUI = Panel.FindChildTraverse(dotaHud,"PreGame")

    local heroSelection = nil

    if heroSelection==nil then
        heroSelection=DollarStatic.CreatePanel($,"Panel",customUI,"HeroSelection")
        heroSelection.BLoadLayout(heroSelection,"file://{resources}/layout/custom_game/hero_selection.xml",false,false)
        heroSelection.style.visibility="visible"
    end
end
function MarkUnavailableHeroes(kv)
end
function SubmitHeroPick(heroname)
    CDOTA_PanoramaScript_GameEvents.SendCustomGameEventToServer(GameEvents,"submit_hero_pick",{heroName=heroname})
end
CDOTA_PanoramaScript_GameEvents.Subscribe(GameEvents,"mark_unavailable_heroes",MarkUnavailableHeroes)
