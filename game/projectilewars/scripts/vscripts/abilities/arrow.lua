require('abilities/base_ability')
---@class arrow : base_ability
arrow = class(base_ability)
---@override
function arrow:GetProjectileParticleName() return "particles/abilities/arrow/mirana_spell_arrow.vpcf" end
---@override
function arrow:GetProjectileUnitBehavior() return PROJECTILES_DESTROY end
---@override
function arrow:GetProjectileProjectileBehavior() return PROJECTILES_DESTROY end
---@override
function arrow:GetProjectileWallBehavior() return PROJECTILES_BOUNCE end
---@override
function arrow:GetSound() return "Hero_Mirana.ArrowCast" end

function arrow:OnSpellStarted()
 
end
---@override
function arrow:OnProjectileHitUnit(hProjectile,hTarget,hCaster)
  local distance = hProjectile.distanceTravelled
  local duration = math.min(self.max_stun,distance/self.stun_duration_distance_factor)

  hTarget:AddNewModifier(hCaster,self,"modifier_stunned",{duration = duration})
end

