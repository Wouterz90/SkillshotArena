require('abilities/base_ability')

class stab extends base_ability {

  GetCastAnimation() {
   
    //Stuff for tree!
    if (this.GetCaster().GetUnitName() == "npc_dota_hero_tiny" && this.GetCaster().GetModifierStackCount("modifier_tree_toss_check",this.GetCaster())== 1) {
      //@ts-ignore
      return GameActivity_t.ACT_TINY_TOSS 
    } else {
      return GameActivity_t.ACT_DOTA_ATTACK
    
    }
  }
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

  GetCastPoint() {
    if (this.GetCaster().GetModifierStackCount("modifier_tree_toss_check",this.GetCaster())== 1) {
      return this.GetSpecialValueFor("cast_point") * 1.5
    } else {
      return this.GetSpecialValueFor("cast_point")
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
    let min_range = 100
    if (caster.GetModifierStackCount("modifier_tree_toss_check",caster)== 1) {
      range = range * 1.5
      min_range = min_range * 1.5
    }

    caster.EmitSound("Hero_PhantomAssassin.Attack")
    let units = FindUnitsInRadius(caster.GetTeamNumber(),caster_origin,null,range,DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_NONE,FindType_t.FIND_CLOSEST,false)
    
    //let units: CDOTA_BaseNPC[] = []
    for (let unit of units) {
      let unit_origin = unit.GetAbsOrigin()
      let m = unit_origin-caster_origin
      if (caster_forward.Dot(m.Normalized()) > 0.5 || unit.GetRangeToUnit(caster) < min_range && caster_forward.Dot(m.Normalized()) > 0 ) {
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

