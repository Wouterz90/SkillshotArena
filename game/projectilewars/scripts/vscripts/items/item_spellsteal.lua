--=======================================================================================
-- Generated by TypescriptToLua transpiler https://github.com/Perryvw/TypescriptToLua 
-- Date: Tue Mar 13 2018
--=======================================================================================
require("typescript_lualib")
require("items/base_item")
LinkLuaModifier("modifier_charges_spellsteal","items/item_spellsteal.lua",LUA_MODIFIER_MOTION_NONE)
item_spell_spellsteal = item_base_item.new()
item_spell_spellsteal.__index = item_spell_spellsteal
item_spell_spellsteal.__base = item_base_item
function item_spell_spellsteal.new(construct, ...)
    local instance = setmetatable({}, item_spell_spellsteal)
    if construct and item_spell_spellsteal.constructor then item_spell_spellsteal.constructor(instance, ...) end
    return instance
end
modifier_charges_spellsteal = modifier_charges_base_item.new()
modifier_charges_spellsteal.__index = modifier_charges_spellsteal
modifier_charges_spellsteal.__base = modifier_charges_base_item
function modifier_charges_spellsteal.new(construct, ...)
    local instance = setmetatable({}, modifier_charges_spellsteal)
    if construct and modifier_charges_spellsteal.constructor then modifier_charges_spellsteal.constructor(instance, ...) end
    return instance
end