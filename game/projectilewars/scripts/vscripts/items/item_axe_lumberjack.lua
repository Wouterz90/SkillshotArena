require('items/base_item')

---@class item_spell_axe_lumberjack : base_item
item_spell_axe_lumberjack = class(item_base_item)


LinkLuaModifier("modifier_charges_axe_lumberjack","items/item_axe_lumberjack.lua",LUA_MODIFIER_MOTION_NONE)
---@class modifier_charges_axe_lumberjack : modifier_charges_base_item
modifier_charges_axe_lumberjack = class(modifier_charges_base_item)