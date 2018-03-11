require("abilities/base_ability")

class impetus extends base_ability {
  OnSpellStart() {
    let caster = this.GetCaster()
    //let dummy = CreateUnitByName("",caster.GetAbsOrigin(),false,caster,caster.GetPlayerOwner(),caster.GetTeamNumber())
    let dummy = SpawnEntityFromTableSynchronous("prop_dynamic", {model : "models/development/invisiblebox.vmdl", targetname:DoUniqueString("prop_dynamic")})
    dummy.SetAbsOrigin(caster.GetAbsOrigin())
    let projectileTable:PhysicsTrackingProjectile = {
      flRadius:this.GetSpecialValueFor("radius"),
      hCaster:this.GetCaster(),
      hTarget:dummy,
      flSpeed:this.GetProjectileSpeed(),
      flTurnRate:1000,
      sEffectName:"particles/units/heroes/hero_enchantress/enchantress_impetus_orig.vpcf",
      WallBehavior:ProjectileInteractionType.PROJECTILES_DESTROY,
      TreeBehavior:ProjectileInteractionType.PROJECTILES_DESTROY,
      UnitBehavior:ProjectileInteractionType.PROJECTILES_DESTROY,
      ItemBehavior:ProjectileInteractionType.PROJECTILES_IGNORE,
      UnitTest:(projectile:PhysicsProjectile,unit:CDOTA_BaseNPC,caster:CDOTA_BaseNPC) =>{
        return this.UnitTest(projectile,unit,caster)
      },
      OnUnitHit:(projectile:PhysicsProjectile,unit:CDOTA_BaseNPC,caster:CDOTA_BaseNPC) => {
        let distance = projectile.distanceTravelled
        let dmgTable:DamageTable = {
          attacker:caster,
          ability:this,
          victim:unit,
          damage:distance/10,
          damage_type:DAMAGE_TYPES.DAMAGE_TYPE_MAGICAL,
        }
        ApplyDamage(dmgTable)
      },
      OnProjectileThink:(projectile:PhysicsProjectile,location:Vec)=> {
        if (projectile["pointCount"] == projectile["points"].length) {
          Physics2D.DestroyProjectile(projectile)
          return
        }
        if (LengthSquared(location-projectile["points"][projectile["pointCount"]]) < 25) {
          projectile["pointCount"] = projectile["pointCount"] + 1
          projectile.target.SetAbsOrigin(projectile["points"][projectile["pointCount"]])
        }
      },
    }

    let projectile = Physics2D.CreateTrackingProjectile(projectileTable)
    projectile["points"] = this.points
    projectile["pointCount"] = 0
  }
}