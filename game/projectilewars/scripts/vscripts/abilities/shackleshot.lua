require('abilities/base_ability')
---@class shackleshot : base_ability
shackleshot = class(base_ability)
---@override
function shackleshot:GetProjectileParticleName() return "particles/units/heroes/hero_windrunner/windrunner_shackleshot.vpcf" end
---@override
function shackleshot:GetProjectileUnitBehavior() return PROJECTILES_DESTROY end
---@override
function shackleshot:GetProjectileProjectileBehavior() return PROJECTILES_NOTHING end
---@override
function shackleshot:GetProjectileWallBehavior() return PROJECTILES_BOUNCE end
---@override
function shackleshot:GetProjectileTreeBehavior() return PROJECTILES_BOUNCE end
---@override
function shackleshot:GetSound() return "" end

---@override
function shackleshot:OnProjectileHitUnit(hProjectile,hTarget,hCaster)
  -- Fire a new projectile that drags the unit till the modifier runs out, if the projectile hits something the unit is attached to that
  local direction = hProjectile.direction
  self.modifier = hTarget:AddNewModifier(hCaster,self,"modifier_shackled"{duration =self.duration,unit = hProjectile:entindex()})
  --Fire the projectile
  local projectile_table = {
    vDirection = direction,
    hCaster = caster,
    vSpawnOrigin = self:GetSpawnOrigin(),
    flSpeed = self:GetProjectileSpeed(),
    flRadius = self.radius,
    flMaxDistance = self:GetProjectileRange(),
    sEffectName = self:GetProjectileParticleName(),

    OnProjectileThink = function(projectile,projectile_location)
      local loc = projectile_location + projectile.direction * 200
      DebugDrawCircle(projectile_location, Vector(255,255,255), 1, self.radius*2, true, FrameTime()*2)
      AddFOWViewer(projectile.caster:GetTeamNumber(),loc  ,self.radius*4,0.5,false)

      self:OnProjectileThink(projectile,projectile_location)
    end,
    ItemBehavior = self:GetProjectileItemBehavior(),
    OnItemHit = function(a,b)
      self:OnSecondProjectileHitSomething(a,b)
    end,
    WallBehavior = PROJECTILES_DESTROY,
    TreeBehavior = PROJECTILES_DESTROY,
    OnTreeHit = function(a,b)
      self:OnSecondProjectileHitSomething(a,b)
    end,
    ProjectileBehavior = PROJECTILES_NOTHING,
    UnitBehavior = self:GetProjectileUnitBehavior(),
    UnitTest = function(projectile, unit,caster)
      return self:UnitTest(projectile,unit,caster)
    end,
    OnUnitHit = function(projectile,unit,caster)
      self:OnSecondProjectileHitSomething(projectile,unit)
    end,
    OnFinish = function(projectile)
      self:OnSecondProjectileFinish(projectile)
    end,
  }
  self.projectile = Physics2D:CreateLinearProjectile(projectile_table)

end

LinkLuaModifier("modifier_shackled","abilities/shackleshot.lua",LUA_MODIFIER_MOTION_NONE)

---@class modifier_shackled : CDOTA_Modifier_Lua
modifier_shackled = class({})
---@override
function modifier_shackled:OnCreated(keys)
  if IsServer then
    self.unit = EntIndexToHScript(keys.unit)
    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_windrunner/windrunner_shackleshot_pair.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
    ParticleManager:SetParticleControlEnt(self.particle, 0, target, PATTACH_POINT, "attach_hitloc", self.unit:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.particle, 1, caster, PATTACH_POINT, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
    self:StartIntervalThink(FrameTime())
  end
  return
end

---@override
function modifier_shackled:OnRefresh(keys)
  if IsServer then
    self.unit = EntIndexToHScript(keys.unit)
    ParticleManager:SetParticleControlEnt(self.particle, 1, caster, PATTACH_POINT, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
  end
  return
end

---@override
function modifier_shackled:OnDestroy()
  if IsServer() then
    ParticleManager:DestroyParticle(self.particle,false)
    ParticleManager:ReleaseParticleIndex(self.particle)
  end
end