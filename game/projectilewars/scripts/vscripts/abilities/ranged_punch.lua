require("abilities/base_ability")
LinkLuaModifier("modifier_ranged_punch_knockback","abilities/ranged_punch.lua",LUA_MODIFIER_MOTION_NONE)
ranged_punch = class(base_ability)
function ranged_punch.new(construct, ...)
    local instance = setmetatable({}, ranged_punch)
    if construct and ranged_punch.constructor then ranged_punch.constructor(instance, ...) end
    return instance
end
function ranged_punch.GetProjectileParticleName(self)
    return ""
end
function ranged_punch.GetSound(self)
    return "Hero_Pudge.AttackHookExtend"
end
function ranged_punch.HitsItems(self)
    return true
end
function ranged_punch.GetProjectileProjectileBehavior(self)
    return PROJECTILES_BOUNCE_OTHER_ONLY
end
function ranged_punch.GetProjectileUnitBehavior(self)
    return PROJECTILES_NOTHING
end
function ranged_punch.GetProjectileItemBehavior(self)
    return PROJECTILES_NOTHING
end
function ranged_punch.GetProjectileWallBehavior(self)
    return PROJECTILES_DESTROY
end
function ranged_punch.OnSpellStarted(self)
    local caster = self.GetCaster(self)
    local point = self.GetCursorPosition(self)
    local direction = point-caster.GetAbsOrigin(caster)
    direction=direction.Normalized(direction)
    self.end_position=(caster.GetAbsOrigin(caster)+(direction*self.range))
    self.particle=ParticleManager.CreateParticle(ParticleManager,"particles/abilities/punch/ranged_punch.vpcf",PATTACH_CUSTOMORIGIN,nil)
    ParticleManager.SetParticleAlwaysSimulate(ParticleManager,self.particle)
    ParticleManager.SetParticleControlEnt(ParticleManager,self.particle,0,self.GetCaster(self),PATTACH_POINT_FOLLOW,"attach_weapon_chain_rt",caster.GetAbsOrigin(caster),true)
    ParticleManager.SetParticleControl(ParticleManager,self.particle,1,self.end_position)
    ParticleManager.SetParticleControl(ParticleManager,self.particle,2,Vector(self.projectile_speed,0,0))
    ParticleManager.SetParticleControl(ParticleManager,self.particle,3,Vector(100,0,0))
    ParticleManager.SetParticleControl(ParticleManager,self.particle,4,Vector(1,0,0))
    ParticleManager.SetParticleControl(ParticleManager,self.particle,5,Vector(0,0,0))
    ParticleManager.SetParticleControlEnt(ParticleManager,self.particle,7,caster,PATTACH_CUSTOMORIGIN,nil,caster.GetAbsOrigin(caster),true)
    self.projectile.projParticle=self.particle
end
function ranged_punch.OnProjectileThink(self,projectile,location)
    ParticleManager.SetParticleControl(ParticleManager,projectile.projParticle,2,Vector(self.projectile.velocity.Length2D(self.projectile.velocity)/FrameTime(),0,0))
end
function ranged_punch.OnProjectileHitItem(self,hProjectile,hItem)
    self.OnProjectileHitUnit(self,hProjectile,hItem,hProjectile.caster)
end
function ranged_punch.OnProjectileHitUnit(self,hProjectile,hTarget,hCaster)
    local direction = hTarget.GetAbsOrigin(hTarget)-hProjectile.location
    direction=direction.Normalized(direction)
    local projectile_direction = hProjectile.direction
    if direction.Dot(direction,projectile_direction)<0 then
        return nil
    end
    if hTarget.IsNPC(hTarget) then
        hTarget.AddNewModifier(hTarget,hCaster,self,"modifier_ranged_punch_knockback",{})
    end
    hCaster.EmitSound(hCaster,"")
    local projectile_table = {vDirection=direction,flMaxDistance=self.GetSpecialValueFor(self,"knockback_distance"),hCaster=hCaster,vSpawnOrigin=hTarget.GetAbsOrigin(hTarget),flSpeed=self.GetProjectileSpeed(self),flRadius=5,sEffectName="",WallBehavior=PROJECTILES_BOUNCE,OnProjectileThink=function(projectile,projectile_location)
        local target = projectile.trackingUnit
        if target and not target.IsNull(target) then
            if target.motion==projectile then
                target.SetAbsOrigin(target,projectile.location)
            end
        end
    end
,OnFinish=function(projectile)
        local target = projectile.trackingUnit
        GridNav.DestroyTreesAroundPoint(GridNav,target.GetAbsOrigin(target),50,true)
    end
}
    local projectile = Physics2D.CreateLinearProjectile(Physics2D,projectile_table)
    projectile.trackingUnit=hTarget
    hTarget.motion=projectile
end
function ranged_punch.OnProjectileFinish(self,hProjectile)
    local caster = self.GetCaster(self)
    local origin = hProjectile.GetAbsOrigin(hProjectile)
    local projParticle = hProjectile.projParticle
    local target = hProjectile.target
    local projectile_table = {hTarget=caster,hCaster=caster,vSpawnOrigin=origin,flSpeed=self.GetProjectileSpeed(self),flRadius=self.GetSpecialValueFor(self,"radius"),sEffectName="",ProjectileBehavior=PROJECTILES_NOTHING,UnitBehavior=PROJECTILES_NOTHING,ItemBehavior=PROJECTILES_NOTHING,UnitTest=function(projectile,unit,caster)
        return self.UnitTest(self,projectile,unit,caster)
    end
,OnUnitHit=function(projectile,unit,caster)
        if unit==caster then
            if target then
                self.BallReturned(self,projectile,target)
                target.motion=nil
            end
            self.BallReturned(self,projectile)
        else
            self.OnProjectileHitUnit(self,projectile,unit,caster)
        end
    end
,OnProjectileThink=function(projectile,projectile_location)
        if target and not target.IsNull(target) then
            if target.motion==projectile then
                target.SetAbsOrigin(target,projectile.location)
            else
                if target.IsNPC(target) then
                    target.RemoveModifierByName(target,"modifier_ranged_punch_knockback")
                end
            end
        end
    end
}
    self.projectile=Physics2D.CreateTrackingProjectile(Physics2D,projectile_table)
    self.projectile.projParticle=projParticle
    if target then
        target.motion=self.projectile
    end
    ParticleManager.SetParticleControlEnt(ParticleManager,self.projectile.projParticle,1,self.GetCaster(self),PATTACH_POINT_FOLLOW,"attach_weapon_chain_rt",self.GetCaster(self).GetAbsOrigin(self.GetCaster(self)),true)
end
function ranged_punch.BallReturned(self,projectile,hTarget)
    local caster = self.GetCaster(self)
    if hTarget and hTarget.AddNewModifier then
        hTarget.RemoveModifierByName(hTarget,"modifier_hook_motion")
    end
    ParticleManager.DestroyParticle(ParticleManager,projectile.projParticle,false)
    ParticleManager.ReleaseParticleIndex(ParticleManager,projectile.projParticle)
end
modifier_ranged_punch_knockback = class({})
function modifier_ranged_punch_knockback.new(construct, ...)
    local instance = setmetatable({}, modifier_ranged_punch_knockback)
    if construct and modifier_ranged_punch_knockback.constructor then modifier_ranged_punch_knockback.constructor(instance, ...) end
    return instance
end
function modifier_ranged_punch_knockback.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end
function modifier_ranged_punch_knockback.GetOverrideAnimation(self)
    return ACT_DOTA_FLAIL
end
function modifier_ranged_punch_knockback.CheckState(self)
    return {[MODIFIER_STATE_STUNNED]=true}
end
