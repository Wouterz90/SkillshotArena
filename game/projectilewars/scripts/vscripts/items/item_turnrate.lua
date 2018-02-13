require('items/base_item')
item_rune_turnrate = class(item_base_rune)


LinkLuaModifier("modifier_rune_turnrate","items/item_turnrate.lua",LUA_MODIFIER_MOTION_NONE)
---@class modifier_rune_haste : modifier_charges_base_item
modifier_rune_turnrate = class({})

function modifier_rune_turnrate:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
  }
end

function modifier_rune_turnrate:GetModifierMoveSpeed_Absolute()
  if IsServer() then
    return 1000
  end
end
