require('items/base_item')

---@class item_spell_earthbind : base_item
item_spell_earthbind = class(item_base_item)

LinkLuaModifier("modifier_charges_earthbind","items/item_earthbind.lua",LUA_MODIFIER_MOTION_NONE)
---@class modifier_charges_earthbind : modifier_charges_base_item
modifier_charges_earthbind = class(modifier_charges_base_item)