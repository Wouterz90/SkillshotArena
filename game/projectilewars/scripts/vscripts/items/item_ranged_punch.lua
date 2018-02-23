require("typescript_lualib")
require("items/base_item")
LinkLuaModifier("modifier_charges_ranged_punch","items/item_ranged_punch.lua",LUA_MODIFIER_MOTION_NONE)
item_spell_ranged_punch = item_base_item.new()
item_spell_ranged_punch.__index = item_spell_ranged_punch
item_spell_ranged_punch.__base = item_base_item
function item_spell_ranged_punch.new(construct, ...)
    local instance = setmetatable({}, item_spell_ranged_punch)
    if construct and item_spell_ranged_punch.constructor then item_spell_ranged_punch.constructor(instance, ...) end
    return instance
end
modifier_charges_ranged_punch = modifier_charges_base_item.new()
modifier_charges_ranged_punch.__index = modifier_charges_ranged_punch
modifier_charges_ranged_punch.__base = modifier_charges_base_item
function modifier_charges_ranged_punch.new(construct, ...)
    local instance = setmetatable({}, modifier_charges_ranged_punch)
    if construct and modifier_charges_ranged_punch.constructor then modifier_charges_ranged_punch.constructor(instance, ...) end
    return instance
end
