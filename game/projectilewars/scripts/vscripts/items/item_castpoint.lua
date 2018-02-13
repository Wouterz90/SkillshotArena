require('items/base_item')
item_rune_castpoint = class(item_base_rune)


LinkLuaModifier("modifier_rune_castpoint","items/item_castpoint.lua",LUA_MODIFIER_MOTION_NONE)
---@class modifier_rune_speedshot : modifier_charges_base_item
modifier_rune_castpoint = class({})



function modifier_rune_castpoint:GetBonusCastTimePercentage()
  if IsServer() then
    return -75
  end
end
