LinkLuaModifier("modifier_zone_dummy","zones.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE)
class modifier_zone_dummy extends CDOTA_Modifier_Lua {
  // Variables
  particle:ParticleID
  IsPermanent() {return true}
  GetAuraRadius() {return 190}

  DeclareFunctions() {
    return [
      //modifierfunction.MODIFIER_PROPERTY_MODEL_CHANGE,
    ]
  }

  GetModifierModelChange() {
    return "models/item_zone.vmdl"
  }

  OnCreated(kv:{pIndex:ParticleID}) {
    this.particle = kv.pIndex
    this.StartIntervalThink(FrameTime())
  }

  OnIntervalThink() {
    let parent = this.GetParent()
    let units = FindUnitsInRadius(parent.GetTeamNumber(),parent.GetAbsOrigin(),null,this.GetAuraRadius(),DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_NONE,FindType_t.FIND_ANY_ORDER,false)
    if (units.length == 1) {
      let unit = units[0]
      parent.SetHealth(parent.GetHealth() -1)
      // Reveal this for all teams
      for (let i=0;i <= DOTATeam_t.DOTA_TEAM_CUSTOM_MAX;i++) {
        if (PlayerResource.GetPlayerCountForTeam(i) > 0) {
          AddFOWViewer(i,parent.GetAbsOrigin(),this.GetAuraRadius(),FrameTime()*3,false)
        }
      }
      if (parent.GetHealth() <= 0) {
        CreatePhysicsItem(GetRandomItemName(),unit.GetAbsOrigin())
        ParticleManager.DestroyParticle(this.particle,false)
        ParticleManager.ReleaseParticleIndex(this.particle)
        let parentOrigin = parent.GetAbsOrigin()
        UTIL_Remove(parent)
        Timers.CreateTimer(15,()=>{
          CreateItemZone(parentOrigin)
        })
        return
      } 
    } else if (units.length == 0) {
      parent.SetHealth(Math.min(parent.GetMaxHealth(),parent.GetHealth()+1))
    } else {
      parent.SetHealth(Math.min(parent.GetMaxHealth(),parent.GetHealth()+1))
      // Reveal for the other players
      for (let i=0;i <= DOTATeam_t.DOTA_TEAM_CUSTOM_MAX;i++) {
        if (PlayerResource.GetPlayerCountForTeam(i) > 0) {
          AddFOWViewer(i,parent.GetAbsOrigin(),this.GetAuraRadius(),FrameTime()*3,false)
        }
      }
    }
  }
}

function CreateItemZone(location:Vec):CDOTA_BaseNPC {
  let dummy = CreateUnitByName("npc_dummy_unit",location,false,null,null,DOTATeam_t.DOTA_TEAM_NEUTRALS)
  //dummy.SetAbsOrigin(location+Vector(0,0,150))
  let particle = ParticleManager.CreateParticle("particles/ping_waypoint_drop.vpcf",ParticleAttachment_t.PATTACH_ABSORIGIN,dummy)
  dummy.AddNewModifier(null,null,"modifier_zone_dummy",{pIndex : particle})

  return dummy
}