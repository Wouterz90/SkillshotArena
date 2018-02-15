require("items/base_item")
LinkLuaModifier("modifier_charges_laser","items/item_laser.lua",LUA_MODIFIER_MOTION_NONE)
item_spell_laser = class(item_base_item)
function item_spell_laser.new(construct, ...)
    local instance = setmetatable({}, item_spell_laser)
    if construct and item_spell_laser.constructor then item_spell_laser.constructor(instance, ...) end
    return instance
end
modifier_charges_laser = class(modifier_charges_base_item)
function modifier_charges_laser.new(construct, ...)
    local instance = setmetatable({}, modifier_charges_laser)
    if construct and modifier_charges_laser.constructor then modifier_charges_laser.constructor(instance, ...) end
    return instance
end
