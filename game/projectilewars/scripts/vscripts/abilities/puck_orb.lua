require('abilities/base_ability')
-- Not using the consumable baseclass because of the 2nd ability
---@class puck_orb : base_ability
puck_orb = class(base_ability)
---@override
function puck_orb:GetProjectileParticleName() return "particles/abilities/illusory_orb/puck_illusory_orb_aproset.vpcf" end
---@override
function puck_orb:GetProjectileUnitBehavior() return PROJECTILES_NOTHING end
---@override
function puck_orb:GetProjectileProjectileBehavior() return PROJECTILES_NOTHING end
---@override
function puck_orb:GetProjectileWallBehavior() return PROJECTILES_BOUNCE end
---@override
function puck_orb:GetProjectileTreeBehavior() return PROJECTILES_NOTHING end
---@override
function puck_orb:GetProjectileItemBehavior() return PROJECTILES_NOTHING end
---@override
function puck_orb:GetSound() return "" end
---@override
function puck_orb:OnSpellStart()
  local caster = self:GetCaster()
  local point = self:GetCursorPosition()
  local direction = (point-caster:GetAbsOrigin()):Normalized()
  StoreSpecialKeyValues(self)

  if not self.projectile or self.projectile:IsNull() then
    caster:EmitSound("Hero_Puck.Illusory_Orb")
    -- All values should be declared the same in the kv file
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
        AddFOWViewer(projectile.caster:GetTeamNumber(),loc  ,self.radius*4,0.5,false)
      end,
      ItemBehavior = self:GetProjectileItemBehavior(),
      WallBehavior = self:GetProjectileWallBehavior(),
      TreeBehavior = self:GetProjectileTreeBehavior(),
      ProjectileBehavior = self:GetProjectileProjectileBehavior(),
      UnitBehavior = self:GetProjectileUnitBehavior(),
      UnitTest = function(projectile, unit,caster)
        return self:UnitTest(projectile,unit,caster)
      end,
      OnUnitHit = function(projectile,unit,caster)
        if unit.GetHealth then
            
          ApplyDamage({
            ability = self,
            attacker = caster,
            victim = unit,
            damage = self:GetAbilityDamage(),
            damage_type = self:GetAbilityDamageType(),
          })
        end  
        self:OnProjectileHitUnit(projectile,unit,caster)
      end,
      OnFinish = function(projectile)
        self:OnProjectileFinish(projectile)
      end,
    }
    self.projectile = Physics2D:CreateLinearProjectile(projectile_table)
    self:EndCooldown()
  else -- Move to orb and remove orb
    --caster:SetAbsOrigin(self.projectile:GetAbsOrigin())
    FindClearSpaceForUnit(caster,self.projectile:GetAbsOrigin(),true)

    --caster:StopSound("Hero_Puck.Illusory_Orb")
    caster:EmitSound("Hero_Puck.EtherealJaunt")

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_puck/puck_illusory_orb_blink_out.vpcf", PATTACH_POINT, caster)
    ParticleManager:SetParticleControl(particle,0,self.projectile.location)
    ParticleManager:ReleaseParticleIndex(particle)
    Physics2D:DestroyProjectile(self.projectile)
  end
end

---@override
function puck_orb:OnProjectileHitUnit(hProjectile,hTarget,hCaster)

end

---@override
function puck_orb:OnProjectileFinish(projectile)
  self:GetCaster():StopSound("Hero_Puck.Illusory_Orb")
  self:StartCooldown(self:GetCooldown(self:GetLevel()))
  self:ConsumeCharge()
  self.orb = nil
end
