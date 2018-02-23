require("abilities/base_ability")

class homing_missile extends base_ability {
  unit:CDOTA_BaseNPC
  GetProjectileParticleName() { return ""}
  //GetSound() { return "Hero_Gyrocopter.HomingMissile"}

  OnAbilityPhaseStart() {
    let caster = this.GetCaster()
    this.unit = CreateUnitByName("npc_dota_unit_homing_missile",caster.GetAbsOrigin(),true,caster,caster.GetPlayerOwner(),caster.GetTeamNumber())
    this.unit.StartGesture(GameActivity_t.ACT_DOTA_RUN)
    return true
  }

  OnAbilityPhaseInterrupted() {
    UTIL_Remove(this.unit)
    this.unit = null
  }

  OnSpellStart() {
    let ability = this
    let caster = this.GetCaster()
    let target = this.GetCursorTarget()
    let unit = this.unit
    //let unit = CreateUnitByName("npc_dota_unit_homing_missile",caster.GetAbsOrigin(),true,caster,caster.GetPlayerOwner(),caster.GetTeamNumber())
    //unit.StartGesture(GameActivity_t.ACT_DOTA_CAPTURE)
    let projectileTable:PhysicsProjectileTable = {
      hCaster:caster,
      hTarget:target,
      flRadius:this.GetSpecialValueFor("radius"),
      flSpeed:this.GetProjectileSpeed(),
      flTurnRate:1,
      sEffectName:this.GetProjectileParticleName(),
      hUnit:unit,
      UnitBehavior:ProjectileInteractionType.PROJECTILES_DESTROY,
      ProjectileBehavior:ProjectileInteractionType.PROJECTILES_NOTHING,
      WallBehavior:ProjectileInteractionType.PROJECTILES_BOUNCE,
      ItemBehavior:ProjectileInteractionType.PROJECTILES_IGNORE,
      OnProjectileHit:(myProjectile:PhysicsProjectile,otherProjectile:PhysicsProjectile) => {
        if (myProjectile.hitByProjectile.indexOf(otherProjectile) && myProjectile.caster.GetTeamNumber() != otherProjectile.caster.GetTeamNumber()) {
          myProjectile.hitByProjectile.push(otherProjectile)
          let unit = myProjectile.unit as CDOTA_BaseNPC
          unit.SetHealth(unit.GetHealth()-1)
          if (unit.GetHealth() <= 0){
            Physics2D.DestroyProjectile(myProjectile)
          }
        }  
      },
      OnProjectileThink:(hProjectile:PhysicsProjectile,location:Vec) => {
        if (hProjectile.speed < 5 && !hProjectile.IsTimeLocked) {
          Physics2D.DestroyProjectile(hProjectile)
        }
        let dir = hProjectile.unit.GetAbsOrigin()-location
        //hProjectile.unit.SetForwardVector(dir.Normalized())
      },
      // Normal unit test, projectile can hit other units while chasing
      UnitTest: (hProjectile:PhysicsProjectile,hTarget:CDOTA_BaseNPC,hCaster:CDOTA_BaseNPC) => {return this.UnitTest(hProjectile,hTarget,hCaster)},
      OnUnitHit:(hProjectile:PhysicsProjectile,hTarget:CDOTA_BaseNPC,hCaster:CDOTA_BaseNPC) => {
        ApplyDamage({
          ability:this,
          attacker:hCaster,
          victim:hTarget,
          damage:this.GetAbilityDamage(),
          damage_type:DAMAGE_TYPES.DAMAGE_TYPE_MAGICAL,
        })    
      },
      OnFinish:(projectile:PhysicsProjectile)=>{
        ParticleManager.DestroyParticle(projectile.projParticle,false)
        ParticleManager.ReleaseParticleIndex(projectile.projParticle)

        let particle = ParticleManager.CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_guided_missile_death.vpcf",ParticleAttachment_t.PATTACH_ABSORIGIN,caster)
        ParticleManager.SetParticleControl(particle,0,projectile.location)
        ParticleManager.ReleaseParticleIndex(particle)
        if (!projectile.unit.IsNull()) {
          UTIL_Remove(projectile.unit)
        }
      }
    }
    let projectile  = Physics2D.CreateTrackingProjectile(projectileTable)

    // Particle on unit
    projectile.projParticle = ParticleManager.CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_homing_missile_fuse.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, unit) 
    ParticleManager.SetParticleControlEnt(projectile.projParticle, 0, unit, ParticleAttachment_t.PATTACH_POINT_FOLLOW, "attach_hitloc", unit.GetAbsOrigin(), true)
    ParticleManager.SetParticleControlEnt(projectile.projParticle, 1, unit, ParticleAttachment_t.PATTACH_POINT_FOLLOW, "attach_hitloc", unit.GetAbsOrigin(), true)
  }
}