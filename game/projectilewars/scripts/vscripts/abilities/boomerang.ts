/*const Physics2D = new Physics()
require("abilities/base_ability")
LinkLuaModifier("modifier_boomerang_rupture","abilities/boomerang.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE)
class boomerang extends base_ability {
  dummyUnit:CBaseEntity
  AimAtPoint:number
  points:Vec[]
  range:number
  radius:number
  GetProjectileParticleName() {return  "particles/units/heroes/hero_bounty_hunter/bounty_hunter_suriken_toss.vpcf"}
  GetProjectileUnitBehavior() {return ProjectileInteractionType.PROJECTILES_NOTHING}
  GetProjectileProjectileBehavior() {return ProjectileInteractionType.PROJECTILES_NOTHING}
  GetProjectileTreeBehavior() {return ProjectileInteractionType.PROJECTILES_BOUNCE}
  GetSound() {return "Hero_BountyHunter.Shuriken"}
  
  OnProjectileHitUnit(projectile:PhysicsProjectile,target:CBaseEntity,caster:CDOTA_BaseNPC) {
    let duration = this.GetSpecialValueFor("duration")
    target.EmitSound("")
    if (target.IsNPC()) {
      let modifier = target.FindModifierByName("modifier_boomerang_rupture")
      if (modifier) {
        modifier.SetDuration(modifier.GetRemainingTime()+duration,true)
      } else {
        target.AddNewModifier(caster,this,"modifier_boomerang_rupture",{duration : duration})
      }
    }
  }

  OnProjectileThink(projectile:PhysicsProjectile, projectile_location:Vec) {
    if (LengthSquared(projectile_location-this.dummyUnit.GetAbsOrigin()) < 150*150) {
      this.AimAtPoint += 1
      if (this.AimAtPoint <= this.points.length) {
        projectile.speed = projectile.speed * 0.8
        this.dummyUnit.SetAbsOrigin(this.points[this.AimAtPoint])
        projectile.hitByProjectile = []
      } else {
        Physics2D.DestroyProjectile(projectile)
      }
    }
  }
  OnSpellStart() {
    StoreSpecialKeyValues(this)
    this.ConsumeCharge()
    let caster = this.GetCaster()
    let ability = this
    let point = this.GetCursorPosition()
    let direction = point-caster.GetAbsOrigin().Normalized()
    let points = []
    let range = Math.min(this.range,point-caster.GetAbsOrigin().Length2D())
    point = caster.GetAbsOrigin() + direction * range

    points[0] = point
    points[1] = point + RandomVector(150)
    points[2] = caster.GetAbsOrigin()

    this.points = points
    this.AimAtPoint = 1
    this.dummyUnit = SpawnEntityFromTableSynchronous("prop_dynamic",{model:"models/development/invisiblebox.vmdl", targetname:DoUniqueString("prop_dynamic")})
    this.dummyUnit.SetAbsOrigin(points[1])

    let projectileTable:PhysicsProjectileTable = {
      hCaster:caster,
      hTarget:this.dummyUnit,
      vSpawnOrigin:this.GetSpawnOrigin(),
      flSpeed:this.GetProjectileSpeed(),
      flRadius:this.radius,
      sEffectName:this.GetProjectileParticleName(),
      flTurnRate:10,
      OnProjectileThink:(projectile:PhysicsProjectile,location:Vec) => {
        let loc = location + projectile.direction * 200
        AddFOWViewer(projectile.caster.GetTeamNumber(),loc,this.radius*5,0.5,false)
        ability.OnProjectileThink(projectile,location)
      },
      WallBehavior:this.GetProjectileWallBehavior(),
      TreeBehavior:this.GetProjectileTreeBehavior(),
      ProjectileBehavior:this.GetProjectileProjectileBehavior(),
      UnitBehavior: this.GetProjectileUnitBehavior(),
      UnitTest: (projectile:PhysicsProjectile,unit:CDOTA_BaseNPC,caster:CDOTA_BaseNPC) => {
        //if (unit.GetContainedItem) { return false}

        if (unit.IsNPC() && unit.IsOutOfGame() || unit.IsInvulnerable() || unit.GetUnitName() == "npc_unit_dodgedummy") {
          this.OnSpellDodged(caster,unit)
          //PlayerDodgedProjectile(caster,unit,projectile)
          return false
        }
        return this.ShouldHitThisTeam(unit)
      },
      OnUnitHit:(projectile:PhysicsProjectile,unit:CBaseEntity,caster:CDOTA_BaseNPC) => {
        ability.OnProjectileHitUnit(projectile,unit,caster)
      }
    }
  }
}




class modifier_boomerang_rupture extends CDOTA_Modifier_Lua {
  DeclareFunctions() {return [
    modifierfunction.MODIFIER_EVENT_ON_UNIT_MOVED,
    
  ]}

  OnUnitMoved(keys:ModifierEvent) {
    if (keys.unit == this.GetCaster()) {
      let damageTable:DamageTable = {
        ability:this.GetAbility(),
        attacker:this.GetCaster(),
        victim:this.GetParent(),
        damage:1,
        damage_type:DAMAGE_TYPES.DAMAGE_TYPE_PURE,
      }
    }
  }
}*/