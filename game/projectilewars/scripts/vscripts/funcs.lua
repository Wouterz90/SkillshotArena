
if IsServer() then
  --- Returns the turnrate of the unit
  ---@return number
  function CDOTA_BaseNPC:GetTurnRate()
    HEROES_TXT = HEROES_TXT or  LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
    local value = HEROES_TXT[self:GetUnitName()]["MovementTurnRate"]
    for _, modifier in pairs(self:FindAllModifiers()) do
      if modifier.GetModifierTurnRate_Percentage then
        value = value * (1-(modifier:GetModifierTurnRate_Percentage()/100))
      end
    end

    return value
  end

  -- Cast time
  ---@return number
  function CDOTA_BaseNPC:GetBonusCastTimeConstant()
    local value = 0
    for _, modifier in pairs(self:FindAllModifiers()) do
      if modifier.GetBonusCastTimeConstant then
        value = value + modifier:GetBonusCastTimeConstant()
      end
    end
    return value
  end
  function CDOTA_BaseNPC:GetBonusCastTimePercentage()
    local value = 100
    for _, modifier in pairs(self:FindAllModifiers()) do
      if modifier.GetBonusCastTimePercentage then
        value = value + modifier:GetBonusCastTimePercentage()
      end
    end
    return value
  end

  -- Projectile speed
  ---@return number
  function CDOTA_BaseNPC:GetBonusProjectileSpeedConstant()
    local value = 0
    for _, modifier in pairs(self:FindAllModifiers()) do
      if modifier.GetBonusProjectileSpeedConstant then
        value = value + modifier:GetBonusProjectileSpeedConstant()
      end
    end
    return value
  end
  ---@return number
  function CDOTA_BaseNPC:GetBonusProjectileSpeedPercentage()
    local value = 100
    for _, modifier in pairs(self:FindAllModifiers()) do
      if modifier.GetBonusProjectileSpeedPercentage then
        value = value + modifier:GetBonusProjectileSpeedPercentage()
      end
    end
    return value
  end

  -- Cooldowns
  ---@return number
  function CDOTA_BaseNPC:GetBonusCooldownConstant()
    local value = 0
    for _, modifier in pairs(self:FindAllModifiers()) do
      if modifier.GetBonusCooldownConstant then
        value = value + modifier:GetBonusCooldownConstant()
      end
    end
    return value
  end
  ---@return number
  function CDOTA_BaseNPC:GetBonusCooldownPercentage()
    local value = 100
    for _, modifier in pairs(self:FindAllModifiers()) do
      if modifier.GetBonusCooldownPercentage then
        value = value + modifier:GetBonusCooldownPercentage()
      end
    end
    return value
  end
else
  -- Cooldowns
  ---@return number
  function C_DOTA_BaseNPC:GetBonusCooldownConstant()
    local value = 0
    for _, modifier in pairs(self:FindAllModifiers()) do
      if modifier.GetBonusCooldownConstant then
        value = value + modifier:GetBonusCooldownConstant()
      end
    end
    return value
  end
  ---@return number
  function C_DOTA_BaseNPC:GetBonusCooldownPercentage()
    local value = 100
    for _, modifier in pairs(self:FindAllModifiers()) do
      if modifier.GetBonusCooldownPercentage then
        value = value + modifier:GetBonusCooldownPercentage()
      end
    end
    return value
  end
end
LinkLuaModifier("modifier_cooldown_constant_reduction_controller","funcs.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cooldown_percentage_reduction_controller","funcs.lua",LUA_MODIFIER_MOTION_NONE)
---@class modifier_cooldown_constant_reduction_controller : CDOTA_Modifier_Lua
---@class modifier_cooldown_percentage_reduction_controller : CDOTA_Modifier_Lua
modifier_cooldown_constant_reduction_controller = class({})
modifier_cooldown_percentage_reduction_controller = class({})
function modifier_cooldown_constant_reduction_controller:IsHidden() return true end
function modifier_cooldown_constant_reduction_controller:IsPermanent() return true end
function modifier_cooldown_percentage_reduction_controller:IsHidden() return true end
function modifier_cooldown_percentage_reduction_controller:IsPermanent() return true end


function modifier_cooldown_constant_reduction_controller:OnCreated()
  if IsServer() then
    self:StartIntervalThink(FrameTime())
  end
end

function modifier_cooldown_constant_reduction_controller:OnIntervalThink()
  local value = 100 + self:GetParent():GetBonusCooldownConstant()
  -- Add 100 because of negative values
  self:SetStackCount(value)
end

function modifier_cooldown_percentage_reduction_controller:OnCreated()
  if IsServer() then
    self:StartIntervalThink(FrameTime())
  end
end

function modifier_cooldown_percentage_reduction_controller:OnIntervalThink()
  local value = 1000 + self:GetParent():GetBonusCooldownPercentage()
  -- Add 1000 because of negative values
  self:SetStackCount(value)
end