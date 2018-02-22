require("abilities/base_ability")
homing_missile = class(base_ability)
function homing_missile.new(construct, ...)
    local instance = setmetatable({}, homing_missile)
    if construct and homing_missile.constructor then homing_missile.constructor(instance, ...) end
    return instance
end
function homing_missile.GetProjectileParticleName(self)
    return ""
end
function homing_missile.OnAbilityPhaseStart(self)
    local caster = self.GetCaster(self)
    self.unit=CreateUnitByName("npc_dota_unit_homing_missile",caster.GetAbsOrigin(caster),true,caster,caster.GetPlayerOwner(caster),caster.GetTeamNumber(caster))
    self.unit.StartGesture(self.unit,ACT_DOTA_RUN)
    return true
end
function homing_missile.OnAbilityPhaseInterrupted(self)
    UTIL_Remove(self.unit)
    self.unit=nil
end
function homing_missile.OnSpellStart(self)
    local ability = self
    local caster = self.GetCaster(self)
    local target = self.GetCursorTarget(self)
    local unit = self.unit
    local projectileTable = {hCaster=caster,hTarget=target,flRadius=self.GetSpecialValueFor(self,"radius"),flSpeed=self.GetProjectileSpeed(self),flTurnRate=1.5,sEffectName=self.GetProjectileParticleName(self),hUnit=unit,UnitBehavior=PROJECTILES_DESTROY,ProjectileBehavior=PROJECTILES_NOTHING,WallBehavior=PROJECTILES_BOUNCE,ItemBehavior=PROJECTILES_IGNORE,OnProjectileHit=function(myProjectile,otherProjectile)
        if not TS_indexOf(myProjectile.hitByProjectile, otherProjectile) and (myProjectile.caster.GetTeamNumber(myProjectile.caster)~=otherProjectile.caster.GetTeamNumber(otherProjectile.caster)) then
            table.insert(myProjectile.hitByProjectile, otherProjectile)
            local unit = myProjectile.unit
            unit.SetHealth(unit,unit.GetHealth(unit)-1)
            if unit.GetHealth(unit)<=0 then
                Physics2D.DestroyProjectile(Physics2D,myProjectile)
            end
        end
    end
,OnProjectileThink=function(hProjectile,location)
        if (hProjectile.speed<5) and not hProjectile.IsTimeLocked then
            Physics2D.DestroyProjectile(Physics2D,hProjectile)
        end
        local dir = hProjectile.unit.GetAbsOrigin(hProjectile.unit)-location
    end
,UnitTest=function(hProjectile,hTarget,hCaster)
        return self.UnitTest(self,hProjectile,hTarget,hCaster)
    end
,OnUnitHit=function(hProjectile,hTarget,hCaster)
        ApplyDamage({ability=self,attacker=hCaster,victim=hTarget,damage=self.GetAbilityDamage(self),damage_type=DAMAGE_TYPE_MAGICAL})
    end
,OnFinish=function(projectile)
        ParticleManager.DestroyParticle(ParticleManager,projectile.projParticle,false)
        ParticleManager.ReleaseParticleIndex(ParticleManager,projectile.projParticle)
        local particle = ParticleManager.CreateParticle(ParticleManager,"particles/units/heroes/hero_gyrocopter/gyro_guided_missile_death.vpcf",PATTACH_ABSORIGIN,caster)
        ParticleManager.SetParticleControl(ParticleManager,particle,0,projectile.location)
        ParticleManager.ReleaseParticleIndex(ParticleManager,particle)
        if not projectile.unit.IsNull(projectile.unit) then
            UTIL_Remove(projectile.unit)
        end
    end
}
    local projectile = Physics2D.CreateTrackingProjectile(Physics2D,projectileTable)
    projectile.projParticle=ParticleManager.CreateParticle(ParticleManager,"particles/units/heroes/hero_gyrocopter/gyro_homing_missile_fuse.vpcf",PATTACH_ABSORIGIN_FOLLOW,unit)
    ParticleManager.SetParticleControlEnt(ParticleManager,projectile.projParticle,0,unit,PATTACH_POINT_FOLLOW,"attach_hitloc",unit.GetAbsOrigin(unit),true)
    ParticleManager.SetParticleControlEnt(ParticleManager,projectile.projParticle,1,unit,PATTACH_POINT_FOLLOW,"attach_hitloc",unit.GetAbsOrigin(unit),true)
end
