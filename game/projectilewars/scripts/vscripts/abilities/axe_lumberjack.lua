require('abilities/base_ability')
---@class axe_lumberjack : base_ability
axe_lumberjack = class(base_ability)

---@override
function axe_lumberjack:GetBehavior()
  return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end
---@override
function axe_lumberjack:GetAbilityTargetType()
  return DOTA_UNIT_TARGET_TREE + DOTA_UNIT_TARGET_CUSTOM
end

---@override
function axe_lumberjack:GetCastRange(vLocation, hTarget)
  return self:GetSpecialValueFor("range")
end


---@override
function axe_lumberjack:OnSpellStart()
  -- Hit the first UNIT in a half circle around you
  local caster = self:GetCaster()
  local caster_origin = caster:GetAbsOrigin()
  local tree = self:GetCursorTarget()
  local direction = (tree:GetAbsOrigin()-caster_origin):Normalized()
  local range = self:GetProjectileRange()
  local stun_duration = self:GetSpecialValueFor("stun_duration")

  caster:EmitSound("Hero_Tiny_Tree.Impact")

  -- Cut down a tree and hurt every unit on the other side in a small radius
  CutDownTree(tree)

  --[[tree:CutDown(caster:GetTeamNumber())
  local target_origin = tree:GetAbsOrigin() + range * direction

  local units = FindUnitsInRadius(caster:GetTeamNumber(),target_origin,nil,range,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,DOTA_DAMAGE_FLAG_NONE,FIND_CLOSEST,false)
  for _,unit in pairs(units) do
    local damageTable = {
      damage = self:GetSpecialValueFor("damage"),
      victim = unit,
      attacker = caster,
      ability = self,
      damage_type = DAMAGE_TYPE_PURE,
    }
    ApplyDamage(damageTable)

    unit:AddNewModifier(caster,self,"modifier_stunned",{duration = stun_duration})
  end]]
  self:ConsumeCharge()
end
