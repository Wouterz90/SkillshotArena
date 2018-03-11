require("typescript_lualib")
require("items/base_item")
LinkLuaModifier("modifier_charges_shards","items/item_shards.lua",LUA_MODIFIER_MOTION_NONE)
item_spell_shards = item_base_item.new()
item_spell_shards.__index = item_spell_shards
item_spell_shards.__base = item_base_item
function item_spell_shards.new(construct, ...)
    local instance = setmetatable({}, item_spell_shards)
    if construct and item_spell_shards.constructor then item_spell_shards.constructor(instance, ...) end
    return instance
end
modifier_charges_shards = modifier_charges_base_item.new()
modifier_charges_shards.__index = modifier_charges_shards
modifier_charges_shards.__base = modifier_charges_base_item
function modifier_charges_shards.new(construct, ...)
    local instance = setmetatable({}, modifier_charges_shards)
    if construct and modifier_charges_shards.constructor then modifier_charges_shards.constructor(instance, ...) end
    return instance
end
