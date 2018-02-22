require("items/base_item")
LinkLuaModifier("modifier_charges_wall","items/item_wall.lua",LUA_MODIFIER_MOTION_NONE)
item_spell_wall = class(item_base_item)
function item_spell_wall.new(construct, ...)
    local instance = setmetatable({}, item_spell_wall)
    if construct and item_spell_wall.constructor then item_spell_wall.constructor(instance, ...) end
    return instance
end
modifier_charges_wall = class(modifier_charges_base_item)
function modifier_charges_wall.new(construct, ...)
    local instance = setmetatable({}, modifier_charges_wall)
    if construct and modifier_charges_wall.constructor then modifier_charges_wall.constructor(instance, ...) end
    return instance
end
