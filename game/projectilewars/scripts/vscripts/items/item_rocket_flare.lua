require('items/base_item')

---@class item_spell_rocket_flare : base_item
item_spell_rocket_flare = class(item_base_item)

LinkLuaModifier("modifier_charges_rocket_flare","items/item_rocket_flare.lua",LUA_MODIFIER_MOTION_NONE)
---@class modifier_charges_rocket_flare : modifier_charges_base_item
modifier_charges_rocket_flare = class(modifier_charges_base_item)