require('items/base_item')

---@class item_spell_hook : base_item
item_spell_hook = class(item_base_item)

LinkLuaModifier("modifier_charges_hook","items/item_hook.lua",LUA_MODIFIER_MOTION_NONE)
---@class modifier_charges_hook : modifier_charges_base_item
modifier_charges_hook = class(modifier_charges_base_item)