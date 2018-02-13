require('items/base_item')

---@class item_spell_arrow : base_item
item_spell_arrow = class(item_base_item)

LinkLuaModifier("modifier_charges_arrow","items/item_arrow.lua",LUA_MODIFIER_MOTION_NONE)
---@class modifier_charges_arrow : modifier_charges_base_item
modifier_charges_arrow = class(modifier_charges_base_item)