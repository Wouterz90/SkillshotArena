require('items/base_item')

---@class item_spell_timelock : base_item
item_spell_timelock = class(item_base_item)

LinkLuaModifier("modifier_charges_timelock","items/item_timelock.lua",LUA_MODIFIER_MOTION_NONE)
---@class modifier_charges_timelock : modifier_charges_base_item
modifier_charges_timelock = class(modifier_charges_base_item)