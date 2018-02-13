require('items/base_item')

---@class item_spell_hookshot : base_item
item_spell_hookshot = class(item_base_item)

LinkLuaModifier("modifier_charges_hookshot","items/item_hookshot.lua",LUA_MODIFIER_MOTION_NONE)
---@class modifier_charges_hookshot : modifier_charges_base_item
modifier_charges_hookshot = class(modifier_charges_base_item)