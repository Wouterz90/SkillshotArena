require("abilities/base_ability")

class spellsteal extends base_ability {
  //GetProjectileParticleName() {return "particles/abilities/hex/hex_projectile.vpcf"}
 
  GetProjectileParticleName() {return  "particles/units/heroes/hero_rubick/rubick_spell_steal.vpcf"}
  GetProjectileUnitBehavior() {return ProjectileInteractionType.PROJECTILES_DESTROY}
  GetProjectileWallBehavior() {return ProjectileInteractionType.PROJECTILES_BOUNCE}
  GetProjectileItemBehavior() {return ProjectileInteractionType.PROJECTILES_IGNORE}
  GetSound() {return "Hero_Rubick.SpellSteal.Cast"}

  OnProjectileHitUnit(projectile:PhysicsProjectile,target:CDOTA_BaseNPC,caster:CDOTA_BaseNPC) {
    target.EmitSound("Hero_Rubick.SpellSteal.Target")
    // Find a randomly taken spell from the target
    let spells:base_ability[] = []
    /*for (let i = 2; i <6 ; i++) {
      let spell = target.GetAbilityByIndex(i) as base_ability
      if (spell) {
        spells.push(spell)
      }
    }*/
    let randomSpell = target.GetAbilityByIndex(1)
    let abilityName
    let modifierName
    let oldStackCount = 0 
    // Set the charges to 0, disable it etc
    
    //if (randomSpell) {
      // Get the modifier name
      //modifierName = "modifier_charges_" + randomSpell.GetAbilityName()
      abilityName = randomSpell.GetAbilityName()
      //let modifier = target.FindModifierByName(modifierName) as modifier_charges_base_item
      //oldStackCount = modifier.GetStackCount()
      //modifier.SetStackCount(0)
      //modifier.OnFunctionalEnd()
    //}

    let pTable:PhysicsTrackingProjectile = {
      hCaster:caster,
      hTarget:caster,
      vSpawnOrigin:target.GetAbsOrigin(),
      flRadius:1,
      flSpeed:this.GetProjectileSpeed(),
      flTurnRate:100,
      UnitBehavior:ProjectileInteractionType.PROJECTILES_DESTROY,
      sEffectName:this.GetProjectileParticleName(),
      UnitTest:(projectile:PhysicsProjectile,target:CDOTA_BaseNPC,caster:CDOTA_BaseNPC) => {
        return target == caster
      },
      OnUnitHit:(projectile:PhysicsProjectile,target:CDOTA_BaseNPC,caster:CDOTA_BaseNPC) => {
        caster.EmitSound("Hero_Rubick.SpellSteal.Complete")
        //if (randomSpell) {
          //let panel = projectile.data["icon"] as wp
          //panel.Delete()
          //let count = 0
          //let modifier = caster.FindModifierByName(modifierName)
          //if (modifier) {
          //  let count = modifier.GetStackCount()
          //}
          CreatePhysicsItem("item_spell_"+abilityName,caster.GetAbsOrigin())
          //modifier = caster.FindModifierByName(modifierName)
          //if (modifier) {
          //  modifier.SetStackCount(oldStackCount+count)
          //}
        //}
      },
    }
    let proj = Physics2D.CreateTrackingProjectile(pTable)
    //if (randomSpell) {
      
      //proj.data = {}
      //proj.data["icon"] = WorldPanels.CreateWorldPanelForAll(
      //{
      //  layout : "file://{resources}/layout/custom_game/worldpanels/empty.xml",
      //  ability : randomSpell.GetAbilityName(),
      //  entity : target.entindex(),
      //})
    //}
    
  }
}