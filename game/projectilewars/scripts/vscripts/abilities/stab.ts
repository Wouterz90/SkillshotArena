require('abilities/base_ability')

class stab extends base_ability {
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

  GetPlaybackRateOverride() {
    return 2
  }

  GetCastRange() {
    return 5000
  }

  


  OnSpellStart() {
    let caster = this.GetCaster()
    let caster_origin = caster.GetAbsOrigin()
    let caster_forward = caster.GetForwardVector()
    let range = this.GetProjectileRange()

    caster.EmitSound("Hero_PhantomAssassin.Attack")
    let units = FindUnitsInRadius(caster.GetTeamNumber(),caster_origin,null,range,DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_NONE,FindType_t.FIND_CLOSEST,false)
    
    //let units: CDOTA_BaseNPC[] = []
    for (let unit of units) {
      let unit_origin = unit.GetAbsOrigin()
      let m = unit_origin-caster_origin
      if (caster_forward.Dot(m.Normalized()) > 0.5 || unit.GetRangeToUnit(caster) < 100 && caster_forward.Dot(m.Normalized()) > 0 ) {
        let damageTable:DamageTable = {
          damage : this.GetSpecialValueFor("damage"),
          victim : unit,
          attacker : caster,
          ability : this,
          damage_type : DAMAGE_TYPES.DAMAGE_TYPE_PHYSICAL,
        }
        ApplyDamage(damageTable)

        caster.EmitSound("Hero_PhantomAssassin.CoupDeGrace")
        let particle = ParticleManager.CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, caster)
        ParticleManager.SetParticleControlEnt(particle, 0, unit, ParticleAttachment_t.PATTACH_POINT_FOLLOW, "attach_hitloc", unit_origin, true)
        ParticleManager.SetParticleControlEnt(particle, 1, unit, ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, "attach_origin", unit_origin, true)
        ParticleManager.ReleaseParticleIndex(particle)
        return null
      }
    }
   
    SendOverheadEventMessage(null,OverheadAlerts_t.OVERHEAD_ALERT_MISS,caster,1,null)
    caster.EmitSound("Hero_KeeperOfTheLight.Recall.Fail")
  }
}

