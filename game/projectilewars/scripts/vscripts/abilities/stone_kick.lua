require('abilities/base_ability')
---@class stone_kick : base_ability
stone_kick = class(base_ability)
---@override
function stone_kick:GetProjectileParticleName() return "" end
---@override
function stone_kick:GetSound() return "Hero_EarthSpirit.BoulderSmash.Target"  end
---@override
function stone_kick:GetProjectileUnitBehavior() return PROJECTILES_NOTHING end
---@override
function stone_kick:GetProjectileProjectileBehavior()
  if not self.target then return PROJECTILES_NOTHING end
  --if self.target:IsHero() then return PROJECTILES_NOTHING end
  return PROJECTILES_BOUNCE_OTHER_ONLY
end

---@override
function stone_kick:OnOwnerSpawned()
  self:SetLevel(1)
end
---@override
function stone_kick:GetCastRange()
  return self.cast_range or self:GetSpecialValueFor("cast_range")
end
---@override
function stone_kick:GetProjectileRange()
  --if self.target:IsHero() then
    return self.range
  --else
    --return self.range * self.non_hero_range_factor
 -- end
end
--[[function stone_kick:GetBehavior()
  return DOTA_ABILITY_BEHAVIOR_POINT_TARGET
end]]
---@return number
function stone_kick:GetAOERadius()
  return self.search_range or self:GetSpecialValueFor("search_range")
end

---@return UnitFilterResult
---@field target CDOTA_BaseNPC
function stone_kick:CastFilterResultLocation(vLocation)
  if IsClient() then return UF_SUCCESS end
  local caster = self:GetCaster()
  --local caster_origin = caster:GetAbsOrigin()
  --local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,vLocation,nil,self.search_range,DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_ALL,0,FIND_CLOSEST,false)
  local units =Physics2D:GetPhysicsUnitsInRange(self.search_range,vLocation,false)
  for i=1,#units do
    if units[i] ~= caster then
      self.target = units[i]
      --caster:FaceTowards(units[i]:GetAbsOrigin())
      --if caster:GetForwardVector():Dot(caster:GetAbsOrigin()-units[i]:GetAbsOrigin()) < 0.7 then
      return UF_SUCCESS
      --else
      --  self.error = 1
      -- return UF_FAIL_CUSTOM
      --end
    end
  end
  self.target = nil
  --self.error = 0
  return UF_FAIL_CUSTOM
end
---@override
function stone_kick:GetCustomCastErrorLocation()
  if IsClient() then return "" end
  --if self.error == 0 then
    return "#No valid units nearby"
  --elseif self.error == 1 then
    --return "#You need to face your unit to kick it"
  --end
end
---@override
---@field target CDOTA_BaseNPC
function stone_kick:GetCursorPosition()
  return self.target:GetAbsOrigin()
end
---@override
---@field target CDOTA_BaseNPC
function stone_kick:OnSpellStarted()
  self.target.motion = self
  if self.target.AddNewModifier then
    self.target:AddNewModifier(self:GetCaster(),self,"modifier_stone_kick_motion",{})
  end
end

---@override
function stone_kick:OnProjectileHitUnit(hProjectile,hTarget,hCaster)
  self.target.motion = self
  hCaster:EmitSound("Hero_EarthSpirit.BoulderSmash.Silence")

end
---@override
---@field target CDOTA_BaseNPC
function stone_kick:OnProjectileThink(projectile,location)
  if self.target.motion == self then
    self.target:SetAbsOrigin(location)
  end
end
---@override
---@field target CDOTA_BaseNPC
function stone_kick:OnProjectileFinish(projectile)
  self.target.motion = nil
  if self.target.HasModifier then
    self.target:RemoveModifierByNameAndCaster("modifier_stone_kick_motion",self:GetCaster())
  end
end
---@override
---@field target CDOTA_BaseNPC
function stone_kick:GetSpawnOrigin() return self.target:GetAbsOrigin()  end


LinkLuaModifier("modifier_stone_kick_motion","abilities/stone_kick.lua",LUA_MODIFIER_MOTION_NONE)
---@class modifier_stone_kick_motion : CDOTA_Modifier_Lua
modifier_stone_kick_motion = {}
---@override
function modifier_stone_kick_motion:OnCreated()
  if IsServer() then
    --
    --local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_rollingboulder.vpcf",PATTACH_ABSORIGIN_FOLLOW,self:GetParent())
    --self:AddParticle(particle, true, false, 1, false, false)
    --self:GetParent().motion = self:GetAbility()
    local parent = self:GetParent()
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    self.projectile_speed = ability.projectile_speed

    local parent_origin = parent:GetAbsOrigin()
    local caster_origin = caster:GetAbsOrigin()
    local normal = (parent_origin-caster_origin)
    self.direction = normal:Normalized()

    self:StartIntervalThink(FrameTime())
  end
end

function modifier_stone_kick_motion:OnIntervalThink()
  local parent = self:GetParent()
  local ability = self:GetAbility()
  parent:SetForwardVector(ability.projectile.velocity)
end

---@return table
function modifier_stone_kick_motion:CheckState()
  -- Only stun serverside so no "STUNNED" bar
  if IsServer() then
    --local team = (parent:GetTeamNumber() ~= caster:GetTeamNumber())
    -- Stun allies too
    return {
      [MODIFIER_STATE_STUNNED] = true,
      [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
  end
end
---@return table
function modifier_stone_kick_motion:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
    MODIFIER_PROPERTY_OVERRIDE_ANIMATION
  }
end
---@return number
function modifier_stone_kick_motion:GetModifierProvidesFOWVision()
  return 1
end
---@return GameActivity_t
function modifier_stone_kick_motion:GetOverrideAnimation()
  return ACT_DOTA_FLAIL
end