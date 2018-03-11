require("abilities/base_ability")
class tree_kick extends base_ability {
  CastFilterResult() {
    if (IsServer()){
      let caster = this.GetCaster()
      let caster_origin = caster.GetAbsOrigin()
      let trees = GridNav.GetAllTreesAroundPoint(caster_origin,150,true) as CDOTA_MapTree[]
      if (trees.length == 0) {
        return UnitFilterResult.UF_FAIL_INVALID_LOCATION
      }
    }
    return UnitFilterResult.UF_SUCCESS
  }

  OnSpellStart() {
    let caster = this.GetCaster()
    let caster_origin = caster.GetAbsOrigin()
    let trees = GridNav.GetAllTreesAroundPoint(caster_origin,150,true) as CDOTA_MapTree[]
    trees.forEach((tree)=>{print(tree.GetModelName())
      tree.GetName()
    })
  }
}