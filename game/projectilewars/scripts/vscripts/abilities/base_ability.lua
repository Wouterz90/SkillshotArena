---@class base_ability : CDOTA_Ability_Lua
---@overload base_ability  : CDOTA_Ability_Lua
base_ability = class({})

-- These functions should/could be overridden
---@return string
function base_ability:GetProjectileParticleName() return "particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf" end
---@return ProjectileType_t
function base_ability:GetProjectileWallBehavior() return PROJECTILES_BOUNCE end
---@return ProjectileType_t
function base_ability:GetProjectileTreeBehavior() return PROJECTILES_NOTHING end
---@return ProjectileType_t
function base_ability:GetProjectileUnitBehavior() return PROJECTILES_DESTROY end
---@return ProjectileType_t
function base_ability:GetProjectileItemBehavior() return PROJECTILES_NOTHING end
---@return ProjectileType_t
function base_ability:GetProjectileProjectileBehavior() return PROJECTILES_NOTHING end
---@return string
function base_ability:GetSound() return "Damage_Melee.Hero" end
function base_ability:GetProjectileControlPoint() return 0 end
function base_ability:OnSpellDodged(hCaster,hTarget) end
---@param hProjectile CBaseEntity
---@param hTarget CDOTA_BaseNPC
---@param hCaster CDOTA_BaseNPC
function base_ability:OnProjectileHitUnit(hProjectile,hTarget,hCaster) end
---@param hProjectile CBaseEntity
---@param hWall CBaseEntity
function base_ability:OnProjectileHitWall(hProjectile,hWall) end
---@param hProjectile CBaseEntity
---@param hTree CDOTA_MapTree
function base_ability:OnProjectileHitTree(hProjectile,hTree) end
---@param a CBaseEntity
---@param b CBaseEntity
function base_ability:OnProjectileHitProjectile(a,b) end
---@param hProjectile CBaseEntity
---@param hItem CDOTA_Item_Physical
function base_ability:OnProjectileHitItem(hProjectile,hItem) end
---@param projectile CBaseEntity
---@param projectile_location Vector
function base_ability:OnProjectileThink(projectile,projectile_location) end
---@param projectile CBaseEntity
function base_ability:OnProjectileFinish(projectile) end
function base_ability:OnSpellStarted() end
---@return vector
function base_ability:GetSpawnOrigin() return self:GetCaster():GetAbsOrigin() end
---@return number
function base_ability:GetProjectileRange() return self.range end
---@param projectile CBaseEntity
---@param unit CDOTA_BaseNPC
---@param caster CDOTA_BaseNPC
---@return boolean
function base_ability:UnitTest(projectile, unit,caster)
  if not unit.HasModifier then return false end
  if (unit:IsOutOfGame() or unit:IsInvulnerable()) or unit:GetUnitName() == "npc_unit_dodgedummy" then
    self:OnSpellDodged(caster,unit)
    PlayerDodgedProjectile(caster,unit,projectile)
    return false
  end
  return self:ShouldHitThisTeam(unit)
end

function base_ability:DestroyImmediatly() return false end
---@return boolean
function base_ability:HitsItems() return false end

-- This doesn't seem to work, so recreating it with the in game event
---@override
function base_ability:OnOwnerSpawned()
  self:SetLevel(1)
end
----------------------------------------------------------
--- Basic functions
----------------------------------------------------------
---@return number
function base_ability:GetCastSoundRadius() return self:GetSpecialValueFor("cast_sound_radius") end

function base_ability:ConsumeCharge()
  local caster = self:GetCaster()
  if self:IsConsumable() then
    local modifier = caster:FindModifierByName("modifier_charges_"..self:GetAbilityName())
    if not modifier then self:Destroy() caster:Interrupt() return false end
    modifier:DecrementStackCount()
  end
  return true
end
---@override
function base_ability:GetCastPoint()
  if IsClient() then return self:GetSpecialValueFor("cast_point") end
  local caster = self:GetCaster()
  local constant = caster:GetBonusCastTimeConstant()
  local percentage = caster:GetBonusCastTimePercentage()/100
  local cast_point =  self:GetSpecialValueFor("cast_point")

  return (cast_point * percentage) + constant
  --return 0
end
---@override
function base_ability:GetCastRange(vLocation, hTarget)
  --if IsClient() then
    return self:GetSpecialValueFor("range")
  --end
end

---@return number
function base_ability:GetProjectileSpeed()
  local caster = self:GetCaster()
  local constant = caster:GetBonusProjectileSpeedConstant()
  local percentage = caster:GetBonusProjectileSpeedPercentage()/100
  self.projectile_speed = self.projectile_speed or self:GetSpecialValueFor("projectile_speed")

  return (self.projectile_speed * percentage) + constant
end
---@override
function base_ability:GetGoldCost(iLevel)
  if IsServer() then return end
  local name=self:GetName()
  local caster = self:GetCaster()
  local count = caster:GetModifierStackCount("modifier_charges_"..name, caster)
  return count
end

---@override
function base_ability:GetCooldown(iLevel)
  local cooldown = self:GetSpecialValueFor("cooldown")

  local caster = self:GetCaster()
  -- Uses 100 as base value
  local constant = -100 + caster:GetModifierStackCount("modifier_cooldown_constant_reduction_controller",caster)
  -- Uses 1000 as base value
  local percentage = -1000 + caster:GetModifierStackCount("modifier_cooldown_percentage_reduction_controller",caster)
  percentage = percentage/100
  cooldown = cooldown + constant
  cooldown = (cooldown * percentage)
  return cooldown
end
---@override
function base_ability:OnUpgrade()
  StoreSpecialKeyValues(self)
end
---@override
function base_ability:OnAbilityPhaseStart()
  local caster = self:GetCaster()
  --StartAnimation(caster,{duration = self:GetCastPoint(),activity = self:GetCastAnimation(),rate = })
  StartSoundEventFromPosition(self:GetSound(),caster:GetAbsOrigin())
  return true
end

---@override
function base_ability:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  --EndAnimation(caster)
  StopSoundEvent(self:GetSound(),caster)
end

---@return boolean
function base_ability:ShouldHitThisTeam(hUnit)
  local caster = self:GetCaster()
  local n = self:GetAbilityTargetTeam()
  if n == DOTA_UNIT_TARGET_TEAM_BOTH then return true end
  if n == DOTA_UNIT_TARGET_TEAM_FRIENDLY and hUnit:GetTeamNumber() == caster:GetTeamNumber() then return true end
  if n == DOTA_UNIT_TARGET_TEAM_ENEMY and hUnit:GetTeamNumber() ~= caster:GetTeamNumber() then return true end
  return false
end
--[[---@override
function base_ability:GetBehavior()
  return DOTA_ABILITY_BEHAVIOR_POINT
end]]
---@return number
function base_ability:GetPlaybackRateOverride()
  return self:GetCastPoint()/self.cast_point
end

---@param bConsumable boolean
function base_ability:SetConsumable(bConsumable)
  self.bConsumable = bConsumable
end

---@return boolean
function base_ability:IsConsumable()
  return self.bConsumable or false
end

---@override
function base_ability:OnSpellStart()
  StoreSpecialKeyValues(self)
  if not self:ConsumeCharge() then return end

  local caster = self:GetCaster()
  local point = self:GetCursorPosition()
  --local direction = caster:GetForwardVector()
  local direction = (point-caster:GetAbsOrigin()):Normalized()

  -- All values should be declared the same in the kv file
  local projectile_table = {
    vDirection = direction,
    hCaster = caster,
    vSpawnOrigin = self:GetSpawnOrigin(),
    flSpeed = self:GetProjectileSpeed(),
    flRadius = self.radius,
    flMaxDistance = self:GetProjectileRange(),
    sEffectName = self:GetProjectileParticleName(),
    controlPoint = self:GetProjectileControlPoint(),
    destroyImmediatly = self:DestroyImmediatly(),
    OnProjectileThink = function(projectile,projectile_location)
      local loc = projectile_location + projectile.direction * 200
      --DebugDrawCircle(projectile_location, Vector(255,255,255), 1, self.vision_radius, true, FrameTime()*2)
      AddFOWViewer(projectile.caster:GetTeamNumber(),loc  ,self.vision_radius,0.5,false)

      self:OnProjectileThink(projectile,projectile_location)
    end,
    ItemBehavior = self:GetProjectileItemBehavior(),
    OnItemHit = function(a,b)
      self:OnProjectileHitItem(a,b)
    end,
    WallBehavior = self:GetProjectileWallBehavior(),
    OnWallHit = function(a,b)
      self:OnProjectileHitWall(a,b)
    end,
    TreeBehavior = self:GetProjectileTreeBehavior(),
    OnTreeHit = function(a,b)
      self:OnProjectileHitTree(a,b)
    end,
    ProjectileBehavior = self:GetProjectileProjectileBehavior(),
    OnProjectileHitProjectile = function(a,b)
      self:OnProjectileHitProjectile(a,b)
    end,
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
  self:OnSpellStarted()
end


---@class base_ability_duration : base_ability
base_ability_duration = class(base_ability)

---@class generic_hidden1 : CDOTA_Ability_Lua
generic_hidden1 = class({})
---@class generic_hidden2 : CDOTA_Ability_Lua
generic_hidden2 = class({})
---@class generic_hidden3 : CDOTA_Ability_Lua
generic_hidden3 = class({})
---@class generic_hidden4 : CDOTA_Ability_Lua
generic_hidden4 = class({})
---@class generic_hidden5 : CDOTA_Ability_Lua
generic_hidden5 = class({})