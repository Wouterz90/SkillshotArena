require("abilities/base_ability")
class shards extends base_ability {
  GetProjectileParticleName() {return "particles/abilities/shards/tusk_ice_shards_projectile.vpcf"}
  GetSound() {return "Hero_Tusk.IceShards.Projectile"}

  GetProjectileRange() {
    let normal = this.GetCursorPosition() - this.GetCaster().GetAbsOrigin()
    return normal.Length2D() 
  }

  GetProjectileUnitBehavior() {return ProjectileInteractionType.PROJECTILES_NOTHING}
  GetProjectileWallBehavior() {return ProjectileInteractionType.PROJECTILES_DESTROY}
  GetProjectileItemBehavior() {return ProjectileInteractionType.PROJECTILES_IGNORE}
  GetProjectileTreeBehavior() {return ProjectileInteractionType.PROJECTILES_DESTROY}

  // Damage is handled in base_ability.lua
  OnProjectileHitUnit() {}


  OnProjectileFinish(projectile:PhysicsProjectile) {
    let caster = projectile.caster
    caster.EmitSound("Hero_Tusk.IceShards")
    let shard_distance = this.GetSpecialValueFor("shard_distance")
    let shard_duration =  this.GetSpecialValueFor("shard_duration")
    let shards:PhysicsObject[] = []
    let blockers:CBaseEntity[] = []

    let particle  = ParticleManager.CreateParticle("particles/units/heroes/hero_tusk/tusk_ice_shards.vpcf",ParticleAttachment_t.PATTACH_WORLDORIGIN,caster)
    ParticleManager.SetParticleControl(particle,0,Vector(shard_duration,0,0))

    for (let i =0;i<=6;i++) {
      let angle = -120 + i * 40
      //@ts-ignore
      let direction = RotatePosition(Vector(0,0,0), QAngle(0,angle,0), projectile.direction)
      let position = GetGroundPosition(projectile.location + direction * shard_distance,null)
      shards[i] = Physics2D.CreatePolygon(position,[GetRightPerpendicular(direction)*shard_distance/2,-GetRightPerpendicular(direction)*shard_distance/2],null)
      ParticleManager.SetParticleControl(particle,i+1,position)

      blockers[i] = SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin : position})
    }

    Timers.CreateTimer(shard_duration,()=>{
      for (let i =0;i<=6;i++) {
        UTIL_Remove(blockers[i])
        UTIL_Remove(shards[i])
      }
    })
  }

}