require('items/base_item')

---@class item_spell_puck_orb : base_item
item_spell_puck_orb = class(item_base_item)

LinkLuaModifier("modifier_charges_puck_orb","items/item_puck_orb.lua",LUA_MODIFIER_MOTION_NONE)
---@class modifier_charges_puck_orb : modifier_charges_base_item
modifier_charges_puck_orb = class(modifier_charges_base_item)