require('abilities/base_ability')
class shoot_ extends base_ability {
  CastFilterResult() {
    if (this.GetCaster().IsDisarmed()) {
      return UnitFilterResult.UF_FAIL_CUSTOM
    }
    return UnitFilterResult.UF_SUCCESS
  }
  GetCustomCastError() {
    if (this.GetCaster().IsRooted()) {
      return "#Can't attack while rooted."
    }
  }

  GetProjectileSpeed() {
    return 900
  }

  GetPlaybackRateOverride() {
    return 2
  }

  destroyImmediatly() { return false}

  GetCastRange() {
    return this.GetCaster().GetAttackRange() *1.33
  }
  GetSound() {
    // This doesn't work, sounds file uses attack and Attack
    // This could be done in a table somewhere
    /*
    let a = "Hero_"
    let b = this.GetCaster().GetUnitName().substr(15)
    b = b.substr(1,1).toUpperCase()+b.substr(2)
    let c = ".Attack"*/
    return "Hero_Windrunner.Attack"
  }
  GetProjectileRange() {
    return this.GetCaster().GetAttackRange() * 1.33
  }
  GetProjectileParticleName() {
    return this.GetCaster().GetRangedProjectileName()
  }

  GetProjectileUnitBehavior() {return ProjectileInteractionType.PROJECTILES_NOTHING}
  GetProjectileProjectileBehavior() {return ProjectileInteractionType.PROJECTILES_NOTHING}
  GetProjectileWallBehavior() {return ProjectileInteractionType.PROJECTILES_BOUNCE}
  GetProjectileItemBehavior() {return ProjectileInteractionType.PROJECTILES_NOTHING}

  OnProjectileHitUnit(projectile:PhysicsProjectile,unit:CDOTA_BaseNPC,caster:CDOTA_BaseNPC):void {

    let range = this.GetCaster().GetAttackRange() //- 150
    let mult = range/650
    mult = 1-mult
    let damageTable:DamageTable = {
      damage : this.GetSpecialValueFor("damage") *mult,
      victim : unit,
      attacker : this.GetCaster(),
      ability : this,
      damage_type : DAMAGE_TYPES.DAMAGE_TYPE_PHYSICAL,
    }
    ApplyDamage(damageTable)
  }
}