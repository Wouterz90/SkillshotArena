require("typescript_lualib")
require("abilities/base_ability")
LinkLuaModifier("modifier_defeaning_blast_disarm","abilities/deafening_blast.lua",LUA_MODIFIER_MOTION_NONE)
deafeaning_blast = base_ability.new()
deafeaning_blast.__index = deafeaning_blast
deafeaning_blast.__base = base_ability
function deafeaning_blast.new(construct, ...)
    local instance = setmetatable({}, deafeaning_blast)
    if construct and deafeaning_blast.constructor then deafeaning_blast.constructor(instance, ...) end
    return instance
end
function deafeaning_blast.GetProjectileParticleName(self)
    return ""
end
function deafeaning_blast.GetSound(self)
    return "Hero_Invoker.DeafeningBlast"
end
function deafeaning_blast.GetProjectileUnitBehavior(self)
    return PROJECTILES_NOTHING
end
function deafeaning_blast.GetProjectileWallBehavior(self)
    return PROJECTILES_DESTROY
end
function deafeaning_blast.GetProjectileItemBehavior(self)
    return PROJECTILES_IGNORE
end
function deafeaning_blast.OnProjectileHitUnit(self,projectile,target,caster)
    CDOTA_BaseNPC.AddNewModifier(target,caster,self,"modifier_defeaning_blast_disarm",{duration=CDOTABaseAbility.GetSpecialValueFor(self,"duration")})
end
