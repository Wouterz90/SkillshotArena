require("items/base_item")
LinkLuaModifier("modifier_charges_homing_missile","items/item_homing_missile.lua",LUA_MODIFIER_MOTION_NONE)
item_spell_homing_missile = class(item_base_item)
function item_spell_homing_missile.new(construct, ...)
    local instance = setmetatable({}, item_spell_homing_missile)
    if construct and item_spell_homing_missile.constructor then item_spell_homing_missile.constructor(instance, ...) end
    return instance
end
modifier_charges_homing_missile = class(modifier_charges_base_item)
function modifier_charges_homing_missile.new(construct, ...)
    local instance = setmetatable({}, modifier_charges_homing_missile)
    if construct and modifier_charges_homing_missile.constructor then modifier_charges_homing_missile.constructor(instance, ...) end
    return instance
end
