require("abilities/base_ability")
LinkLuaModifier("modifier_laser_blind","abilities/laser.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE)
class laser extends base_ability {
  GetProjectileParticleName() {return  "particles/abilities/laser/tinker_laser2.vpcf"}
  GetProjectileUnitBehavior() {return ProjectileInteractionType.PROJECTILES_NOTHING}
  GetProjectileProjectileBehavior() {return ProjectileInteractionType.PROJECTILES_NOTHING}
  GetProjectileWallBehavior() {return ProjectileInteractionType.PROJECTILES_BOUNCE}
  GetProjectileTreeBehavior() {return ProjectileInteractionType.PROJECTILES_DESTROY}
  GetSound() {return "Hero_Tinker.Laser"}
  GetProjectileControlPoint() {return 9}
  destroyImmediatly() {return true}
  OnProjectileHitUnit(projectile:PhysicsProjectile,target:CDOTA_BaseNPC,caster:CDOTA_BaseNPC) {
    let duration = this.GetSpecialValueFor("duration")
    target.EmitSound("Hero_Tinker.LaserImpact")
    target.AddNewModifier(caster,this,"modifier_laser_blind",{duration : duration})
  }
}

class modifier_laser_blind extends CDOTA_Modifier_Lua {
  DeclareFunctions() {return [
    modifierfunction.MODIFIER_PROPERTY_FIXED_NIGHT_VISION,
    modifierfunction.MODIFIER_PROPERTY_FIXED_DAY_VISION,
  ]}

  GetFixedDayVision() { return this.GetAbility().GetSpecialValueFor("vision_radius")}
  GetFixedNightVision() { return this.GetAbility().GetSpecialValueFor("vision_radius")}
}