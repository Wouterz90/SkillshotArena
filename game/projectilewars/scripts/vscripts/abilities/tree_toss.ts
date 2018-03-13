require("abilities/base_ability")
LinkLuaModifier("modifier_tree_toss_check","abilities/tree_toss.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE)

class tree_toss extends base_ability {
  tree:CDOTA_MapTree|null = null

  GetIntrinsicModifierName() {
    return "modifier_tree_toss_check"
  }

  GetCastRange() {
    if (this.GetCaster().GetModifierStackCount("modifier_tree_toss_check",this.GetCaster()) == 0) {
      return 200
    } else {
      return this.GetSpecialValueFor("range")
    }
  }

  GetAbilityTargetType() {
    if (this.GetCaster().GetModifierStackCount("modifier_tree_toss_check",this.GetCaster()) == 0) {
      
      return DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_TREE + DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_CUSTOM

    } else {
      
      return DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_NONE
    }
  }

  GetBehavior() {
    if (this.GetCaster().GetModifierStackCount("modifier_tree_toss_check",this.GetCaster()) == 0) {
      return DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
    } else {
      return DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_POINT
    }
  }

  // Those shouldnt happen
  CastFilterResultLocation() {
    if (this.GetCaster().GetModifierStackCount("modifier_tree_toss_check",this.GetCaster()) == 0) {
      return UnitFilterResult.UF_FAIL_OTHER
    }
  }
  CastFilterResultTarget(target:CBaseEntity) {
    if (target.IsNPC){return UnitFilterResult.UF_FAIL_OTHER}
    if (this.GetCaster().GetModifierStackCount("modifier_tree_toss_check",this.GetCaster()) != 0) {
      return UnitFilterResult.UF_FAIL_OTHER
    }
  }

  GetProjectileParticleName() {
    return "particles/abilities/tree_toss/tiny_tree_proj.vpcf"
  }

  GetProjectileRange() {
    if (!this.GetCursorPosition()) { return 0}
    let normal = this.GetCursorPosition() - this.GetCaster().GetAbsOrigin()
    return normal.Length2D() 
  }

  GetProjectileUnitBehavior() {return ProjectileInteractionType.PROJECTILES_IGNORE  }
  GetProjectileWallBehavior() {return ProjectileInteractionType.PROJECTILES_BOUNCE}
  GetProjectileItemBehavior() {return ProjectileInteractionType.PROJECTILES_IGNORE}
  GetProjectileTreeBehavior() {return ProjectileInteractionType.PROJECTILES_NOTHING}

  OnSpellStart() {
    let caster = this.GetCaster()
    if (this.GetCaster().GetModifierStackCount("modifier_tree_toss_check",this.GetCaster()) == 0) {
      let tree = this.GetCursorTarget() as CDOTA_MapTree
      caster.FindModifierByName("modifier_tree_toss_check").SetStackCount(1)
      //UTIL_Remove(tree)
      tree.CutDownRegrowAfter(9999,-1)
      //this.tree = ReplaceTreeWithTempTree(tree)
      this.EndCooldown()
    } else {
      this.tree = CreateTempTreeWithFuncs(caster.GetAbsOrigin())
      //@ts-ignore EF_NODRAW not declared
      this.tree.AddEffects( EF_NODRAW)

      let projectileTable:PhysicsLinearProjectile = {
        flRadius : this.GetSpecialValueFor("radius"),
        vDirection: (this.GetCursorPosition() - caster.GetAbsOrigin()).Normalized(),
        hCaster:caster,
        flSpeed:this.GetProjectileSpeed(),
        sEffectName:this.GetProjectileParticleName(),
        flMaxDistance:this.GetProjectileRange(),
        TreeBehavior:this.GetProjectileTreeBehavior(),
        UnitBehavior:this.GetProjectileUnitBehavior(),
        WallBehavior:this.GetProjectileWallBehavior(),
        ItemBehavior:this.GetProjectileItemBehavior(),
        UnitTest:(projectile:PhysicsProjectile,unit:CDOTA_BaseNPC,caster:CDOTA_BaseNPC) => {
          if (!unit.HasModifier) { return false}
          if (unit.IsOutOfGame() || unit.IsInvulnerable() || unit.GetUnitName() == "npc_unit_dodgedummy") {
            return false
          } else {
            return caster.GetTeamNumber() != unit.GetTeamNumber()
          }
        },
        OnUnitHit:(projectile:PhysicsProjectile,unit:CDOTA_BaseNPC,caster:CDOTA_BaseNPC)=>{
          ApplyDamage({
            victim:unit,
            attacker:caster,
            ability:this,
            damage:this.GetAbilityDamage(),
            damage_type:DAMAGE_TYPES.DAMAGE_TYPE_MAGICAL,
          })

        },
        OnFinish:(projectile:PhysicsProjectile)=>{
          let loc = projectile.location
          let tree = this.tree as CDOTA_MapTree
          //@ts-ignore
          tree.RemoveEffects(EF_NODRAW)
          tree.SetAbsOrigin(loc)
          
          ReplaceTreeWithTempTree(tree)
          FindClearSpaceForUnit(caster,caster.GetAbsOrigin(),true)
          
          //UTIL_Remove(this.tree)
          this.tree = null
        },
        OnProjectileThink:(projectile:PhysicsProjectile,location:Vec) => {
          //this.GetSpecialValueFor("vision_radius")
          AddFOWViewer(projectile.caster.GetTeamNumber(),location+projectile.direction*100,200,FrameTime() *2,false)
          //this.CreateVisibilityNode(location,this.GetSpecialValueFor("vision_radius"),FrameTime())
          let tree = this.tree as CDOTA_MapTree
          tree.SetAbsOrigin(location)
          this.tree = ReplaceTreeWithTempTree(tree)
          //@ts-ignore
          this.tree.AddEffects(EF_NODRAW)
        }
      }
      Physics2D.CreateLinearProjectile(projectileTable)
      caster.FindModifierByName("modifier_tree_toss_check").SetStackCount(0)
      this.ConsumeCharge()

    }
  }
}

class modifier_tree_toss_check extends CDOTA_Modifier_Lua {
  IsHidden() {return true}
  IsPermanent() {return true}
  tree:CBaseEntity  

  OnCreated() {
    if (IsServer()) {
      this.tree = SpawnEntityFromTableSynchronous("prop_dynamic", {model : "models/heroes/tiny_01/tiny_01_tree.vmdl"})
      this.tree.FollowEntity(this.GetCaster(),this.GetCaster().GetUnitName() == "npc_dota_hero_tiny")
      //@ts-ignore
      this.tree.AddEffects(EF_NODRAW)
    }
  }

  OnStackCountChanged() {
    if (IsServer()) {
      if (this.GetStackCount() == 0) {
        //@ts-ignore
        this.tree.AddEffects(EF_NODRAW)
      } else {
        //@ts-ignore
        this.tree.RemoveEffects(EF_NODRAW)
      }
    }
  }
}
