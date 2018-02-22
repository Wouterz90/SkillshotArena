require("abilities/base_ability")

class wall extends base_ability {
  OnSpellStart() {
    let caster = this.GetCaster()
    let origin = caster.GetAbsOrigin()
    let point = caster.GetCursorPosition()
    let forward = caster.GetForwardVector()
    //let forward =point-origin
    //forward = forward.Normalized()  
    let right = GetRightPerpendicular(forward)
    let pos = origin + forward* 200
    let locs = [right* 200, -right* 200]
    
    //let wall = Physics2D.CreatePolygon(pos,locs,null)
    let wall = Physics2D.CreatePolygon(Vector(0,0,0),locs,null)
    wall.caster = caster

    for (let i=0;i<locs.length;i++) {
      locs[i] = locs[i] + pos
    }

    let wallParticles = CreateProjectileWall(wall,locs)


    this.ConsumeCharge()

    Timers.CreateTimer(5,()=>{
      if (wall && !wall.IsNull()) {
        if (wallParticles) {
          for (let p of wallParticles) {
            ParticleManager.DestroyParticle(p,true)
            ParticleManager.ReleaseParticleIndex(p)
          }
        }
        UTIL_Remove(wall)
      }
    })
  }
}