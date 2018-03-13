require('items/base_item')
item_rune_multishot = class(item_base_rune)


LinkLuaModifier("modifier_rune_multishot","items/item_multishot.lua",LUA_MODIFIER_MOTION_NONE)
---@class modifier_charges_arrow : modifier_charges_base_item
modifier_rune_multishot = class({})

function modifier_rune_multishot:DeclareFunctions() 
  return {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
  }
end

function modifier_rune_multishot:OnAbilityFullyCast(keys)
  --for k,v in pairs(keys) do print(k,v) end
  if keys.unit ~= self:GetParent() then return end
  -- Get position, return when nil
  local position = keys.unit:GetCursorPosition()
  if not position then return end

  -- Return on unsuited projectile spells.
  local banned_abilities = {
    ["shoot_"] = true,
    ["puck_orb"] = true,
    ["rocket_flare"] = true,
    ["hookshot"] = true,
    ["tree_toss"] = true,
  }
  if banned_abilities[keys.ability:GetAbilityName()] then
    return 
  end

  local caster = keys.unit
  local l = (position - caster:GetAbsOrigin()):Length2D()

  local leftPos =  caster:GetAbsOrigin() + RotatePosition(Vector(0,0,0), QAngle(0,-25,0), (position-caster:GetAbsOrigin()):Normalized()) * l
  local rightPos = caster:GetAbsOrigin() + RotatePosition(Vector(0,0,0), QAngle(0,25,0), (position-caster:GetAbsOrigin()):Normalized()) * l
  caster:SetCursorPosition(leftPos)
  keys.ability:OnSpellStart()
  caster:SetCursorPosition(rightPos)
  keys.ability:OnSpellStart()
  

end

