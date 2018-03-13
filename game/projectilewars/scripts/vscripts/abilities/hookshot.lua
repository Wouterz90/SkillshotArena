require('abilities/base_ability')
---@class hookshot : base_ability
hookshot = class(base_ability)
---@override
function hookshot:GetProjectileProjectileBehavior() return PROJECTILES_IGNORE end
function hookshot:GetProjectileTreeBehavior() return PROJECTILES_DESTROY end
---@override
function hookshot:GetProjectileParticleName() return "" end
---@override
function hookshot:GetSound() return "Hero_Rattletrap.Hookshot.Fire" end
---@override
function hookshot:HitsItems() return true end
---@override
function hookshot:GetProjectileItemBehavior() return true end

---@override
function hookshot:OnProjectileHitItem(hProjectile, hItem)
  self:OnProjectileHitUnit(hProjectile,hItem,self:GetCaster())
  Physics2D:DestroyProjectile(hProjectile)
end

---@override
function hookshot:OnOwnerSpawned()
  self:SetLevel(1)
end
---@override
function hookshot:OnSpellStarted()
  self.target = nil
  local caster = self:GetCaster()
  local point = self:GetCursorPosition()
  local direction = (point-caster:GetAbsOrigin()):Normalized()
  self.end_position = caster:GetAbsOrigin() + direction * math.min(self:GetProjectileRange(),(caster:GetAbsOrigin()-point):Length2D())
  
  self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_hookshot_b.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
  ParticleManager:SetParticleControlEnt(self.particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
  ParticleManager:SetParticleControl(self.particle, 3, caster:GetAbsOrigin()+Vector(0,0,128))
end

function hookshot:OnProjectileThink(projectile)
  local caster = self:GetCaster()
  ParticleManager:SetParticleControlEnt(self.particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
  ParticleManager:SetParticleControl(self.particle, 3, projectile.location+Vector(0,0,128))
end
---@override
function hookshot:OnProjectileHitUnit(hProjectile,hTarget,hCaster)

  hCaster:EmitSound("Hero_Rattletrap.Hookshot.Impact")
  -- Stun the unit, and fire another projectile that controls the casters movement
  hCaster.motion = self
  self.target = hTarget
  self.targetOrigin = hTarget:GetAbsOrigin()
  local caster = hCaster
  -- Launch an invisible projectile back to control the particle
  local projectile_table = {
    hTarget = hTarget,
    hCaster = caster,
    --vSpawnOrigin = hProjectile:GetAbsOrigin(),
    flSpeed = self:GetProjectileSpeed()*2,
    flRadius =  50,
    sEffectName = "",
    ProjectileBehavior = PROJECTILES_NOTHING,
    UnitBehavior = PROJECTILES_NOTHING,
    ItemBehavior = PROJECTILES_NOTHING,
    UnitTest = function(projectile, unit,caster)
      return hTarget == unit
    end,
    OnUnitHit = function(projectile,unit,caster)
      ParticleManager:DestroyParticle(self.particle,false)
      ParticleManager:ReleaseParticleIndex(self.particle)
      Physics2D:DestroyProjectile(projectile)
      caster.motion = nil

      if unit.HasModifier then
        unit:AddNewModifier(caster,self,"modifier_stunned",{duration = self.stun_duration})
      end
    end,
    OnProjectileThink = function(projectile,projectile_location)
      if self.target:IsNull() then
        ParticleManager:DestroyParticle(self.particle,false)
        ParticleManager:ReleaseParticleIndex(self.particle)
        Physics2D:DestroyProjectile(projectile)
        return
      end
      if caster.motion == self then
        hCaster:SetAbsOrigin(projectile_location)
        local origin = (not self.target:IsNull() and self.target:GetAbsOrigin()) or self.targetOrigin
        ParticleManager:SetParticleControlEnt(self.particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(self.particle, 3, projectile_location+Vector(0,0,128))
        if LengthSquared(origin-projectile_location) < 50*50 then
          ParticleManager:DestroyParticle(self.particle,false)
          ParticleManager:ReleaseParticleIndex(self.particle)
          Physics2D:DestroyProjectile(projectile)
          caster.motion = nil

          if self.target.HasModifier then
            self.target:AddNewModifier(caster,self,"modifier_stunned",{duration = self.stun_duration})
          end
        end
        if LengthSquared(hCaster:GetAbsOrigin()) > MAP_SIZE * MAP_SIZE then
          caster.motion = nil
        end

      end
    end,
  }
  self.projectile = Physics2D:CreateTrackingProjectile(projectile_table)

end

---@override
function hookshot:OnProjectileFinish(hProjectile)
  if self.target then return end

  local caster = self:GetCaster()
  caster:EmitSound("Hero_Rattletrap.Hookshot.Retract")
  -- Launch an invisible projectile back to control the particle
  local projectile_table = {
    hTarget = caster,
    hCaster = caster,
    vSpawnOrigin = hProjectile:GetAbsOrigin(),
    flSpeed = self:GetProjectileSpeed(),
    flRadius = 0,
    sEffectName = "",
    ProjectileBehavior = PROJECTILES_NOTHING,
    UnitBehavior = PROJECTILES_NOTHING,
    UnitTest = function(projectile, unit,caster)
      return caster == unit
    end,
    OnUnitHit = function(projectile,unit,caster)
      ParticleManager:DestroyParticle(self.particle,false)
      ParticleManager:ReleaseParticleIndex(self.particle)
      Physics2D:DestroyProjectile(projectile)
    end,
    OnProjectileThink = function(projectile,projectile_location)
      ParticleManager:SetParticleControlEnt(self.particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
      ParticleManager:SetParticleControl(self.particle, 3, projectile.location+Vector(0,0,128))
    end,
  }
  self.projectile = Physics2D:CreateTrackingProjectile(projectile_table)
end




