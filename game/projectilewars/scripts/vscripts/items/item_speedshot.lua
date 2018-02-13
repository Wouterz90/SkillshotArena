require('items/base_item')
item_rune_speedshot = class(item_base_rune)


LinkLuaModifier("modifier_rune_speedshot","items/item_speedshot.lua",LUA_MODIFIER_MOTION_NONE)
---@class modifier_rune_speedshot : modifier_charges_base_item
modifier_rune_speedshot = class({})



function modifier_rune_speedshot:GetBonusProjectileSpeedPercentage()
  if IsServer() then
    return 50
  end
end
