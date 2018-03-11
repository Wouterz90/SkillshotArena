require("abilities/base_ability")
LinkLuaModifier("modifier_timelock_bonus_speed","abilities/timelock2.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE)
class timelock extends base_ability {
  OnSpellStart() {
    let caster = this.GetCaster()
    let ents = Entities.FindAllInSphere(Vector(0,0,0),FIND_UNITS_EVERYWHERE)
    let phys = Physics2D.units
    let duration = 1.5
    phys.forEach((ent)=>{
      if (ents.indexOf(ent)==-1) {
        ents.push(ent)
      }
    })

    for (let ent of ents) {
      let e = ent as PhysicsObject
      if (e.IsProjectile && e.caster != caster) {
        e.IsTimeLocked = GameRules.GetGameTime() + duration
      }
    }
    EmitGlobalSound("Hero_FacelessVoid.Chronosphere")
    this.ConsumeCharge()

    caster.AddNewModifier(caster,this,"modifier_timelock_bonus_speed",{duration:duration})
    caster.AddNewModifier(caster,this,"modifier_faceless_void_chronosphere_speed",{duration:duration})


  }
}

class modifier_timelock_bonus_speed extends CDOTA_Modifier_Lua {
  DeclareFunctions() {
    return [
      modifierfunction.MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
      //modifierfunction.MODIFIER_PROPERTY_MOVESPEED_MAX,
      //modifierfunction.MODIFIER_PROPERTY_MOVESPEED_LIMIT,
      
    ]
  }

  
  GetModifierMoveSpeedBonus_Percentage() {
    return 400
  }
  GetModifierMoveSpeed_AbsoluteMin() {
    return 1500
  }
  GetModifierMoveSpeed_Max() {
    return 1500
  }
  GetModifierMoveSpeed_Limit() {
    return 1500
  }

}