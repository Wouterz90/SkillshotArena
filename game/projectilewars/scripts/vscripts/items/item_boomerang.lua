require('items/base_item')

---@class item_spell_boomerang : base_item
item_spell_boomerang = class(item_base_item)


LinkLuaModifier("modifier_charges_boomerang","items/item_boomerang.lua",LUA_MODIFIER_MOTION_NONE)
---@class modifier_charges_boomerang : modifier_charges_base_item
modifier_charges_boomerang = class(modifier_charges_base_item)