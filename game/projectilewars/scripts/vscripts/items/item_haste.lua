require('items/base_item')
item_rune_haste = class(item_base_rune)


LinkLuaModifier("modifier_rune_haste","items/item_haste.lua",LUA_MODIFIER_MOTION_NONE)
---@class modifier_rune_haste : modifier_charges_base_item
modifier_rune_haste = class({})

function modifier_rune_haste:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
  }
end

function modifier_rune_haste:GetModifierMoveSpeed_Absolute()
  if IsServer() then
    return 550
  end
end
