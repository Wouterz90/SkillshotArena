require("typescript_lualib")
CCustomGameEventManager.RegisterListener(CustomGameEventManager,"VectorTargettedAbilityCastFinished",ExecuteVectorTargetAbility)
function ExecuteVectorTargetAbility(pID,data)
    local startPos = Vector(data.startPos["0"],data.startPos["1"],data.startPos["2"])

    local endPos = Vector(data.endPos["0"],data.endPos["1"],data.endPos["2"])

    local points = {}

    TS_forEach(data.allPoints, function(point)
        table.insert(points, Vector(point["0"],point["1"],point["2"]))
    end
)
    print(#points)
    local ability = EntIndexToHScript(data.abilityIndex)

    local hero = CDOTABaseAbility.GetCaster(ability)

    ability.startPos=startPos
    ability.endPos=endPos
    ability.points=points
    CDOTA_BaseNPC.CastAbilityNoTarget(hero,ability,CDOTA_BaseNPC.GetPlayerOwnerID(hero))
end
