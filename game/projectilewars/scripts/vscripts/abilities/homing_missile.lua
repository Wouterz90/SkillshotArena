require("typescript_lualib")
require("abilities/base_ability")
homing_missile = base_ability.new()
homing_missile.__index = homing_missile
homing_missile.__base = base_ability
function homing_missile.new(construct, ...)
    local instance = setmetatable({}, homing_missile)
    if construct and homing_missile.constructor then homing_missile.constructor(instance, ...) end
    return instance
end
function homing_missile.GetProjectileParticleName(self)
    return ""
end
function homing_missile.OnAbilityPhaseStart(self)
    local caster = CDOTABaseAbility.GetCaster(self)

    self.unit=CreateUnitByName("npc_dota_unit_homing_missile",CBaseEntity.GetAbsOrigin(caster),true,caster,CDOTA_BaseNPC.GetPlayerOwner(caster),CBaseEntity.GetTeamNumber(caster))
    CDOTA_BaseNPC.StartGesture(self.unit,ACT_DOTA_RUN)
    return true
end
function homing_missile.OnAbilityPhaseInterrupted(self)
    UTIL_Remove(self.unit)
    self.unit=nil
end
function homing_missile.OnSpellStart(self)
    local ability = self

    local caster = CDOTABaseAbility.GetCaster(self)

    local target = CDOTABaseAbility.GetCursorTarget(self)

    local unit = self.unit

    local projectileTable = {hCaster=caster,hTarget=target,flRadius=CDOTABaseAbility.GetSpecialValueFor(self,"radius"),flSpeed=base_ability.GetProjectileSpeed(self),flTurnRate=1,sEffectName=homing_missile.GetProjectileParticleName(self),hUnit=unit,UnitBehavior=PROJECTILES_DESTROY,ProjectileBehavior=PROJECTILES_NOTHING,WallBehavior=PROJECTILES_BOUNCE,ItemBehavior=PROJECTILES_IGNORE,OnProjectileHit=function(myProjectile,otherProjectile)
        if TS_indexOf(myProjectile.hitByProjectile, otherProjectile) and (CBaseEntity.GetTeamNumber(myProjectile.caster)~=CBaseEntity.GetTeamNumber(otherProjectile.caster)) then
            table.insert(myProjectile.hitByProjectile, otherProjectile)
            local unit = myProjectile.unit

            CBaseEntity.SetHealth(unit,CBaseEntity.GetHealth(unit)-1)
            if CBaseEntity.GetHealth(unit)<=0 then
                Physics.DestroyProjectile(Physics2D,myProjectile)
            end
        end
    end
,OnProjectileThink=function(hProjectile,location)
        if (hProjectile.speed<5) and not hProjectile.IsTimeLocked then
            Physics.DestroyProjectile(Physics2D,hProjectile)
        end
        local dir = CBaseEntity.GetAbsOrigin(hProjectile.unit)-location

    end
,UnitTest=function(hProjectile,hTarget,hCaster)
        return base_ability.UnitTest(self,hProjectile,hTarget,hCaster)
    end
,OnUnitHit=function(hProjectile,hTarget,hCaster)
        ApplyDamage({ability=self,attacker=hCaster,victim=hTarget,damage=CDOTABaseAbility.GetAbilityDamage(self),damage_type=DAMAGE_TYPE_MAGICAL})
    end
,OnFinish=function(projectile)
        CScriptParticleManager.DestroyParticle(ParticleManager,projectile.projParticle,false)
        CScriptParticleManager.ReleaseParticleIndex(ParticleManager,projectile.projParticle)
        local particle = CScriptParticleManager.CreateParticle(ParticleManager,"particles/units/heroes/hero_gyrocopter/gyro_guided_missile_death.vpcf",PATTACH_ABSORIGIN,caster)

        CScriptParticleManager.SetParticleControl(ParticleManager,particle,0,projectile.location)
        CScriptParticleManager.ReleaseParticleIndex(ParticleManager,particle)
        if not CBaseEntity.IsNull(projectile.unit) then
            UTIL_Remove(projectile.unit)
        end
    end
}

    local projectile = Physics.CreateTrackingProjectile(Physics2D,projectileTable)

    projectile.projParticle=CScriptParticleManager.CreateParticle(ParticleManager,"particles/units/heroes/hero_gyrocopter/gyro_homing_missile_fuse.vpcf",PATTACH_ABSORIGIN_FOLLOW,unit)
    CScriptParticleManager.SetParticleControlEnt(ParticleManager,projectile.projParticle,0,unit,PATTACH_POINT_FOLLOW,"attach_hitloc",CBaseEntity.GetAbsOrigin(unit),true)
    CScriptParticleManager.SetParticleControlEnt(ParticleManager,projectile.projParticle,1,unit,PATTACH_POINT_FOLLOW,"attach_hitloc",CBaseEntity.GetAbsOrigin(unit),true)
end
