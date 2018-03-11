require("typescript_lualib")
require("abilities/base_ability")
impetus = base_ability.new()
impetus.__index = impetus
impetus.__base = base_ability
function impetus.new(construct, ...)
    local instance = setmetatable({}, impetus)
    if construct and impetus.constructor then impetus.constructor(instance, ...) end
    return instance
end
function impetus.OnSpellStart(self)
    local caster = CDOTABaseAbility.GetCaster(self)

    local dummy = SpawnEntityFromTableSynchronous("prop_dynamic",{model="models/development/invisiblebox.vmdl",targetname=DoUniqueString("prop_dynamic")})

    CBaseEntity.SetAbsOrigin(dummy,CBaseEntity.GetAbsOrigin(caster))
    local projectileTable = {flRadius=CDOTABaseAbility.GetSpecialValueFor(self,"radius"),hCaster=CDOTABaseAbility.GetCaster(self),hTarget=dummy,flSpeed=base_ability.GetProjectileSpeed(self),flTurnRate=1000,sEffectName="particles/units/heroes/hero_enchantress/enchantress_impetus_orig.vpcf",WallBehavior=PROJECTILES_DESTROY,TreeBehavior=PROJECTILES_DESTROY,UnitBehavior=PROJECTILES_DESTROY,ItemBehavior=PROJECTILES_IGNORE,UnitTest=function(projectile,unit,caster)
        return base_ability.UnitTest(self,projectile,unit,caster)
    end
,OnUnitHit=function(projectile,unit,caster)
        local distance = projectile.distanceTravelled

        local dmgTable = {attacker=caster,ability=self,victim=unit,damage=distance/10,damage_type=DAMAGE_TYPE_MAGICAL}

        ApplyDamage(dmgTable)
    end
,OnProjectileThink=function(projectile,location)
        if projectile["pointCount"]==projectile["points"].length then
            Physics2D.DestroyProjectile(Physics2D,projectile)
            return
        end
        if LengthSquared(location-projectile["points"][projectile["pointCount"]])<25 then
            projectile["pointCount"]=(projectile["pointCount"]+1)
            CBaseEntity.SetAbsOrigin(projectile.target,projectile["points"][projectile["pointCount"]])
        end
    end
}

    local projectile = Physics2D.CreateTrackingProjectile(Physics2D,projectileTable)

    projectile["points"]=self.points
    projectile["pointCount"]=0
end
