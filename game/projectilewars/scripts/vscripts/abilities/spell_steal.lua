require("typescript_lualib")
require("abilities/base_ability")
spellsteal = base_ability.new()
spellsteal.__index = spellsteal
spellsteal.__base = base_ability
function spellsteal.new(construct, ...)
    local instance = setmetatable({}, spellsteal)
    if construct and spellsteal.constructor then spellsteal.constructor(instance, ...) end
    return instance
end
function spellsteal.GetProjectileParticleName(self)
    return "particles/units/heroes/hero_rubick/rubick_spell_steal.vpcf"
end
function spellsteal.GetProjectileUnitBehavior(self)
    return PROJECTILES_DESTROY
end
function spellsteal.GetProjectileWallBehavior(self)
    return PROJECTILES_BOUNCE
end
function spellsteal.GetProjectileItemBehavior(self)
    return PROJECTILES_IGNORE
end
function spellsteal.GetSound(self)
    return "Hero_Rubick.SpellSteal.Cast"
end
function spellsteal.OnProjectileHitUnit(self,projectile,target,caster)
    CBaseEntity.EmitSound(target,"Hero_Rubick.SpellSteal.Target")
    local spells = {}

    local randomSpell = CDOTA_BaseNPC.GetAbilityByIndex(target,1)

    local abilityName = nil

    local modifierName = nil

    local oldStackCount = 0

    abilityName=CDOTABaseAbility.GetAbilityName(randomSpell)
    local pTable = {hCaster=caster,hTarget=caster,vSpawnOrigin=CBaseEntity.GetAbsOrigin(target),flRadius=1,flSpeed=base_ability.GetProjectileSpeed(self),flTurnRate=100,UnitBehavior=PROJECTILES_DESTROY,sEffectName=spellsteal.GetProjectileParticleName(self),UnitTest=function(projectile,target,caster)
        return target==caster
    end
,OnUnitHit=function(projectile,target,caster)
        CBaseEntity.EmitSound(caster,"Hero_Rubick.SpellSteal.Complete")
        CreatePhysicsItem("item_spell_" .. abilityName,CBaseEntity.GetAbsOrigin(caster))
    end
}

    local proj = Physics2D.CreateTrackingProjectile(Physics2D,pTable)

end
