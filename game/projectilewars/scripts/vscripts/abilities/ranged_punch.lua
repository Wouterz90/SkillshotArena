--=======================================================================================
-- Generated by TypescriptToLua transpiler https://github.com/Perryvw/TypescriptToLua 
-- Date: Wed Mar 14 2018
--=======================================================================================
require("typescript_lualib")
require("abilities/base_ability")
LinkLuaModifier("modifier_ranged_punch_knockback","abilities/ranged_punch.lua",LUA_MODIFIER_MOTION_NONE)
ranged_punch = base_ability.new()
ranged_punch.__index = ranged_punch
ranged_punch.__base = base_ability
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
function ranged_punch.GetProjectileTreeBehavior(self)
    return PROJECTILES_DESTROY
end
function ranged_punch.OnSpellStarted(self)
    local caster = self:GetCaster()

    local point = self:GetCursorPosition()

    local direction = point-caster:GetAbsOrigin()

    direction=direction:Normalized()
    self.end_position=(caster:GetAbsOrigin()+(direction*self.range))
    self.particle=ParticleManager:CreateParticle("particles/abilities/punch/ranged_punch.vpcf",PATTACH_CUSTOMORIGIN,nil)
    ParticleManager:SetParticleAlwaysSimulate(self.particle)
    ParticleManager:SetParticleControlEnt(self.particle,0,self:GetCaster(),PATTACH_POINT_FOLLOW,"attach_weapon_chain_rt",caster:GetAbsOrigin(),true)
    ParticleManager:SetParticleControl(self.particle,1,self.end_position)
    ParticleManager:SetParticleControl(self.particle,2,Vector(self.projectile_speed,0,0))
    ParticleManager:SetParticleControl(self.particle,3,Vector(5,0,0))
    ParticleManager:SetParticleControl(self.particle,4,Vector(1,0,0))
    ParticleManager:SetParticleControl(self.particle,5,Vector(0,0,0))
    ParticleManager:SetParticleControlEnt(self.particle,7,caster,PATTACH_CUSTOMORIGIN,nil,caster:GetAbsOrigin(),true)
    self.projectile.projParticle=self.particle
end
function ranged_punch.OnProjectileThink(self,projectile,location)
    ParticleManager:SetParticleControl(projectile.projParticle,2,Vector(self.projectile.velocity:Length2D()/FrameTime(),0,0))
end
function ranged_punch.OnProjectileHitItem(self,hProjectile,hItem)
    self:OnProjectileHitUnit(hProjectile,hItem,hProjectile.caster)
end
function ranged_punch.OnProjectileHitUnit(self,hProjectile,hTarget,hCaster)
    local direction = hTarget:GetAbsOrigin()-hProjectile.location

    direction=direction:Normalized()
    local projectile_direction = hProjectile.direction

    if direction:Dot(projectile_direction)<0 then
        return nil
    end
    if hTarget:IsNPC() then
        hTarget:AddNewModifier(hCaster,self,"modifier_ranged_punch_knockback",{})
    end
    hCaster:EmitSound("Hero_Tusk.WalrusPunch.Target")
    local projectile_table = {vDirection=direction,flMaxDistance=self:GetSpecialValueFor("knockback_distance"),hCaster=hCaster,vSpawnOrigin=hTarget:GetAbsOrigin(),flSpeed=self:GetProjectileSpeed(),flRadius=5,sEffectName="",WallBehavior=PROJECTILES_BOUNCE,OnProjectileThink=function(projectile,projectile_location)
        local target = projectile.trackingUnit

        if target and not target:IsNull() then
            if target.motion==projectile then
                target:SetAbsOrigin(projectile.location)
            end
        end
    end
,OnFinish=function(projectile)
        if not projectile.trackingUnit:IsNull() then
            local target = projectile.trackingUnit

            GridNav:DestroyTreesAroundPoint(target:GetAbsOrigin(),50,true)
        end
    end
}

    local projectile = Physics2D:CreateLinearProjectile(projectile_table)

    projectile.trackingUnit=hTarget
    hTarget.motion=projectile
end
function ranged_punch.OnProjectileFinish(self,hProjectile)
    local caster = self:GetCaster()

    local origin = hProjectile:GetAbsOrigin()

    local projParticle = hProjectile.projParticle

    local target = hProjectile.target

    local projectile_table = {hTarget=caster,hCaster=caster,vSpawnOrigin=origin,flSpeed=self:GetProjectileSpeed(),flRadius=self:GetSpecialValueFor("radius"),flTurnRate=100,sEffectName="",ProjectileBehavior=PROJECTILES_NOTHING,UnitBehavior=PROJECTILES_NOTHING,ItemBehavior=PROJECTILES_NOTHING,UnitTest=function(projectile,unit,caster)
        return self:UnitTest(projectile,unit,caster)
    end
,OnUnitHit=function(projectile,unit,caster)
        if unit==caster then
            if target then
                self:BallReturned(projectile,target)
                target.motion=nil
            end
            self:BallReturned(projectile)
        else
            self:OnProjectileHitUnit(projectile,unit,caster)
        end
    end
,OnProjectileThink=function(projectile,projectile_location)
        if target and not target:IsNull() then
            if target.motion==projectile then
                target:SetAbsOrigin(projectile.location)
            else
                if target:IsNPC() then
                    target:RemoveModifierByName("modifier_ranged_punch_knockback")
                end
            end
        end
    end
}

    self.projectile=Physics2D:CreateTrackingProjectile(projectile_table)
    self.projectile.projParticle=projParticle
    if target then
        target.motion=self.projectile
    end
    ParticleManager:SetParticleControlEnt(self.projectile.projParticle,1,self:GetCaster(),PATTACH_POINT_FOLLOW,"attach_weapon_chain_rt",self:GetCaster():GetAbsOrigin(),true)
end
function ranged_punch.BallReturned(self,projectile,hTarget)
    local caster = self:GetCaster()

    if hTarget and hTarget.AddNewModifier then
        hTarget:RemoveModifierByName("modifier_hook_motion")
    end
    ParticleManager:DestroyParticle(projectile.projParticle,false)
    ParticleManager:ReleaseParticleIndex(projectile.projParticle)
end
modifier_ranged_punch_knockback = {}
modifier_ranged_punch_knockback.__index = modifier_ranged_punch_knockback
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
