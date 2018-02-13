require('items/base_item')

---@class item_spell_laser : base_item
item_spell_laser = class(item_base_item)

LinkLuaModifier("modifier_charges_laser","items/item_laser.lua",LUA_MODIFIER_MOTION_NONE)
---@class modifier_charges_laser : modifier_charges_base_item
modifier_charges_laser = class(modifier_charges_base_item)