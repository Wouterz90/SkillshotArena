require("abilities/base_ability")


class wall extends base_ability {

  OnSpellStart() {
    
    let direction
    let origin
    let caster = this.GetCaster()
    let distance
    
    if (this.endPos) {
    //let origin = caster.GetAbsOrigin()
      direction = this.endPos - this.startPos
      distance = direction.Length2D()
      direction = direction.Normalized()

      origin = this.startPos + direction * (distance /2)
    } else {
      direction = caster.GetForwardVector()
      origin = caster.GetAbsOrigin() + direction*200
      direction = GetRightPerpendicular(direction)
    }

    distance = 500
    let locs = [direction * distance/2,-direction *distance/2]
    
    //let wall = Physics2D.CreatePolygon(pos,locs,null)
    let wall = Physics2D.CreatePolygon(origin,locs,null)
    wall.caster = caster

    for (let i=0;i<locs.length;i++) {
      locs[i] = locs[i] + origin
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
    this.startPos = null
    this.endPos = null
  }
}