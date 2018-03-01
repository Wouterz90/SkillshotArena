require('abilities/base_ability')
LinkLuaModifier("modifier_ranged_punch_knockback","abilities/ranged_punch.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE)
class ranged_punch extends base_ability {
  end_position:Vec
  particle:ParticleID
  range:number
  projectile:PhysicsProjectile
  projectile_speed:number
  

  GetProjectileParticleName() {return ""}
  GetSound() { return "Hero_Pudge.AttackHookExtend"}
  HitsItems() {return true}
  GetProjectileProjectileBehavior() { return ProjectileInteractionType.PROJECTILES_BOUNCE_OTHER_ONLY}
  GetProjectileUnitBehavior() {return ProjectileInteractionType.PROJECTILES_NOTHING}
  GetProjectileItemBehavior() {return ProjectileInteractionType.PROJECTILES_NOTHING}
  GetProjectileWallBehavior() {return ProjectileInteractionType.PROJECTILES_DESTROY}

  OnSpellStarted() {
    let caster = this.GetCaster() as CDOTA_BaseNPC_Hero
    let point = this.GetCursorPosition()
    let direction = point-caster.GetAbsOrigin()
    direction = direction.Normalized()

    this.end_position = caster.GetAbsOrigin() + direction * this.range
    this.particle = ParticleManager.CreateParticle( "particles/abilities/punch/ranged_punch.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, null)
    ParticleManager.SetParticleAlwaysSimulate( this.particle)
    ParticleManager.SetParticleControlEnt( this.particle, 0, this.GetCaster(), ParticleAttachment_t.PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", caster.GetAbsOrigin(), true )
    ParticleManager.SetParticleControl( this.particle, 1, this.end_position  )
    ParticleManager.SetParticleControl( this.particle, 2, Vector( this.projectile_speed , 0, 0 ) )
    ParticleManager.SetParticleControl( this.particle, 3, Vector(100,0,0) )
    ParticleManager.SetParticleControl( this.particle, 4, Vector( 1, 0, 0 ) )
    ParticleManager.SetParticleControl( this.particle, 5, Vector( 0, 0, 0 ) )
    ParticleManager.SetParticleControlEnt( this.particle, 7, caster, ParticleAttachment_t.PATTACH_CUSTOMORIGIN, null, caster.GetAbsOrigin(), true )

    this.projectile.projParticle = this.particle
  }

  OnProjectileThink(projectile:PhysicsProjectile,location:Vec) {
    ParticleManager.SetParticleControl( projectile.projParticle, 2, Vector(this.projectile.velocity.Length2D() /FrameTime(),0,0))
  }

  OnProjectileHitItem(hProjectile:PhysicsProjectile, hItem:CDOTA_Item_Physical) {
    this.OnProjectileHitUnit(hProjectile,hItem,hProjectile.caster)
  }

  OnProjectileHitUnit(hProjectile:PhysicsProjectile,hTarget:CBaseEntity,hCaster:CDOTA_BaseNPC) {

    // Check if the desired push direction is the same as the projectile direction
    let direction = hTarget.GetAbsOrigin() - hProjectile.location
    direction = direction.Normalized()
    let projectile_direction = hProjectile.direction
    if (direction.Dot(projectile_direction) < 0 ) {return null}

    if (hTarget.IsNPC()) {
      hTarget.AddNewModifier(hCaster,this,"modifier_ranged_punch_knockback",{})
    }

    hCaster.EmitSound("Hero_Tusk.WalrusPunch.Target")
    // Create a new projectile managing the unit's knockback
    let projectile_table = {
      vDirection: direction,
      flMaxDistance:this.GetSpecialValueFor("knockback_distance"),
      hCaster:hCaster,
      vSpawnOrigin:hTarget.GetAbsOrigin(),
      flSpeed:this.GetProjectileSpeed(),
      flRadius:5,
      sEffectName:"",
      WallBehavior:ProjectileInteractionType.PROJECTILES_BOUNCE,
      OnProjectileThink:(projectile:PhysicsProjectile,projectile_location:Vec) => {
        let target = projectile.trackingUnit
        if ( target && !target.IsNull()) {
          if (target.motion == projectile){
            target.SetAbsOrigin(projectile.location)
          }
        }
      },
      OnFinish:(projectile:PhysicsProjectile) => {
        let target =  projectile.trackingUnit
        GridNav.DestroyTreesAroundPoint(target.GetAbsOrigin(),50,true)
      },
    }
    let projectile = Physics2D.CreateLinearProjectile(projectile_table)
    projectile.trackingUnit = hTarget
    hTarget.motion = projectile

    // Particle on impact
    /*let nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf", PATTACH_CUSTOMORIGIN, hTarget)
    ParticleManager:SetParticleControlEnt( nFXIndex, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), true )
    ParticleManager:ReleaseParticleIndex( nFXIndex )*/
  }

  OnProjectileFinish(hProjectile:PhysicsProjectile) {
    let caster = this.GetCaster()
    let origin = hProjectile.GetAbsOrigin()
    let projParticle = hProjectile.projParticle
    let target = hProjectile.target

    let projectile_table = {
      hTarget:caster,
      hCaster:caster,
      vSpawnOrigin:origin,
      flSpeed:this.GetProjectileSpeed() ,
      flRadius:this.GetSpecialValueFor("radius"),
      sEffectName:"",
      ProjectileBehavior:ProjectileInteractionType.PROJECTILES_NOTHING,
      UnitBehavior:ProjectileInteractionType.PROJECTILES_NOTHING,
      ItemBehavior:ProjectileInteractionType.PROJECTILES_NOTHING,
      UnitTest: (projectile:PhysicsProjectile, unit:CDOTA_BaseNPC,caster:CDOTA_BaseNPC) => {
        return this.UnitTest(projectile,unit,caster)
      },
      OnUnitHit: (projectile:PhysicsProjectile,unit:CDOTA_BaseNPC,caster:CDOTA_BaseNPC) => {
        if (unit == caster) {
          if (target) {
            this.BallReturned(projectile,target)
            target.motion = null
          }
          this.BallReturned(projectile)
        } else {
          this.OnProjectileHitUnit(projectile,unit,caster)
        }
      },
      OnProjectileThink:(projectile:PhysicsProjectile,projectile_location:Vec) => {
        if (target && !target.IsNull()) {
          if (target.motion == projectile){
            target.SetAbsOrigin(projectile.location)
          } else {
            if (target.IsNPC()) {
              target.RemoveModifierByName("modifier_ranged_punch_knockback")
            }
          }
        }
      },
    }
    this.projectile = Physics2D.CreateTrackingProjectile(projectile_table)
    this.projectile.projParticle = projParticle
    if (target) {
      target.motion = this.projectile
    }  
  ParticleManager.SetParticleControlEnt( this.projectile.projParticle, 1, this.GetCaster(), ParticleAttachment_t.PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", this.GetCaster().GetAbsOrigin(), true);
  
  //this.GetCaster():StopSound("Hero_Pudge.AttackHookExtend")
  //this.GetCaster():EmitSound("Hero_Pudge.ability")
  }
  
  BallReturned(projectile:PhysicsProjectile,hTarget?:CDOTA_BaseNPC) {
    let caster = this.GetCaster()

    if (hTarget && hTarget.AddNewModifier) {
      hTarget.RemoveModifierByName("modifier_hook_motion")
    }
    ParticleManager.DestroyParticle(projectile.projParticle,false)
    ParticleManager.ReleaseParticleIndex(projectile.projParticle)
    //this:GetCaster().StopSound( "Hero_Pudge.AttackHookRetract")
    //this:GetCaster().EmitSound( "Hero_Pudge.AttackHookRetractStop")
  }
}


class modifier_ranged_punch_knockback extends CDOTA_Modifier_Lua {
  DeclareFunctions() {
    return [
      modifierfunction.MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    ]
  }
  GetOverrideAnimation() {
    return GameActivity_t.ACT_DOTA_FLAIL
  }

  CheckState() {
    return {
      [modifierstate.MODIFIER_STATE_STUNNED]:true,
    }
  }

}