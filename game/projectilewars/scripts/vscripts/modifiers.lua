LinkLuaModifier("modifier_control_area","modifiers.lua",LUA_MODIFIER_MOTION_NONE)

---@class modifier_control_area : CDOTA_Modifier_Lua
modifier_control_area = class({})

---@override
function modifier_control_area:IsHidden() return true end
function modifier_control_area:IsPermanent() return true end


---@override
function modifier_control_area:CheckState()
  return {
    --[MODIFIER_STATE_NO_HEALTH_BAR] = true,
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
  }
end

---@override
function modifier_control_area:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
  }
end

---@override
function modifier_control_area:GetModifierMoveSpeedBonus_Constant()
  if IsServer() then
    local caster = self:GetCaster()
    local forward = caster:GetForwardVector()
    local origin = caster:GetAbsOrigin()
    local max_distance = MAP_SIZE or 1500
    if LengthSquared(origin) > max_distance * max_distance --[[and forward:Dot(origin:Normalized()) > 0]] then
      self:SetStackCount(1)
      local knockback =	{
        should_stun = true,
        knockback_duration = 0.33,
        duration = 0.33,
        knockback_distance = -100,
        knockback_height = 0,
        center_x = 0,
        center_y = 0,
        center_z = GetGroundHeight(Vec(0,0),nil),
      }
      caster:AddNewModifier(nil,nil,"modifier_knockback",knockback)
    else
      self:SetStackCount(0)
    end
  end

end

---@override
function modifier_control_area:GetModifierMoveSpeed_Limit()
  if self:GetStackCount() == 1 then
    return 0.01
  else
    return 550
  end
end
