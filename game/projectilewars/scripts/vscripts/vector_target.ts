_G["VectorTargetListener"] = _G["VectorTargetListener"] || CustomGameEventManager.RegisterListener("vector_targetted_ability_cast_finished",ExecuteVectorTargetAbility)

function ExecuteVectorTargetAbility(pID:PlayerID,data:{abilityIndex:number,startPos:{"0":number,"1":number,"2":number},endPos:{"0":number,"1":number,"2":number},allPoints:Vec[]}) {
  let startPos = Vector(data.startPos["0"],data.startPos["1"],data.startPos["2"])
  let endPos = Vector(data.endPos["0"],data.endPos["1"],data.endPos["2"])
  
  let points:Vec[] = []
  data.allPoints.forEach((point) => {
    points.push(Vector(point["0"],point["1"],point["2"]))
  })
  
  let ability = EntIndexToHScript(data.abilityIndex) as base_ability
  let hero = ability.GetCaster()
  ability.startPos = startPos
  ability.endPos = endPos
  ability.points = points
  hero.CastAbilityNoTarget(ability,hero.GetPlayerOwnerID())
}
