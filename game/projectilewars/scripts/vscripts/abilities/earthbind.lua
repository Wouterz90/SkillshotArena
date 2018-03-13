require('abilities/base_ability')
---@class earthbind : base_ability
earthbind = class(base_ability)

function earthbind:GetAbilityDamage()
  if IsServer() then return 0 end
  return self:GetSpecialValueFor("net_damage")
end

---@override
function earthbind:GetProjectileParticleName() return "particles/abilities/earthbind/meepo_earthbind_projectile_fx.vpcf" end
---@override
function earthbind:GetProjectileUnitBehavior() return PROJECTILES_NOTHING end
---@override
function earthbind:GetProjectileProjectileBehavior() return PROJECTILES_NOTHING end
function earthbind:GetProjectileTreeBehavior() return PROJECTILES_DESTROY end
---@override
function earthbind:GetSound() return "Hero_Meepo.Earthbind.Cast" end
---@override
function earthbind:GetProjectileRange() return (self:GetCaster():GetAbsOrigin() - self:GetCursorPosition()):Length2D() end
---@override
function earthbind:OnProjectileFinish(projectile)
  local caster = self:GetCaster()
  local location = projectile.location
  EmitSoundOnLocationWithCaster(location,"Hero_Meepo.Earthbind.Target",caster)

  local units = FindUnitsInRadius(caster:GetTeamNumber(),location,nil,self.radius/1.5,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
  for _,unit in pairs(units) do
    unit:AddNewModifier(caster,self,"modifier_meepo_earthbind",{duration = self.duration})
    unit:AddNewModifier(caster,self,"modifier_meepo_earthbind_no_turning",{duration = self.duration})
    unit.motion = nil
    ApplyDamage({
      ability = self,
      attacker = caster,
      victim = unit,
      damage = self:GetSpecialValueFor("net_damage"),
      damage_type = DAMAGE_TYPE_MAGICAL,
    })
  end

end

LinkLuaModifier("modifier_meepo_earthbind_no_turning","abilities/earthbind.lua",LUA_MODIFIER_MOTION_NONE)
---@class modifier_meepo_earthbind_no_turning : CDOTA_Modifier_Lua
modifier_meepo_earthbind_no_turning = class({})
---@override
function modifier_meepo_earthbind_no_turning:IsHidden() return true end

---@override
function modifier_meepo_earthbind_no_turning:CheckState()
  return {
    [MODIFIER_STATE_DISARMED] = true,
  }
end

---@override
function modifier_meepo_earthbind_no_turning:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_DISABLE_TURNING,
  }
end

---@override
function modifier_meepo_earthbind_no_turning:GetModifierDisableTurning()
  return 1
end