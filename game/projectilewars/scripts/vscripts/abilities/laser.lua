require("abilities/base_ability")
LinkLuaModifier("modifier_laser_blind","abilities/laser.lua",LUA_MODIFIER_MOTION_NONE)
laser = class(base_ability)
function laser.new(construct, ...)
    local instance = setmetatable({}, laser)
    if construct and laser.constructor then laser.constructor(instance, ...) end
    return instance
end
function laser.GetProjectileParticleName(self)
    return "particles/abilities/laser/tinker_laser2.vpcf"
end
function laser.GetProjectileUnitBehavior(self)
    return PROJECTILES_NOTHING
end
function laser.GetProjectileProjectileBehavior(self)
    return PROJECTILES_NOTHING
end
function laser.GetProjectileWallBehavior(self)
    return PROJECTILES_BOUNCE
end
function laser.GetSound(self)
    return "Hero_Tinker.Laser"
end
function laser.GetProjectileControlPoint(self)
    return 9
end
function laser.destroyImmediatly(self)
    return true
end
function laser.OnProjectileHitUnit(self,projectile,target,caster)
    local duration = self.GetSpecialValueFor(self,"duration")
    target.EmitSound(target,"Hero_Tinker.LaserImpact")
    target.AddNewModifier(target,caster,self,"modifier_laser_blind",{duration=duration})
end
modifier_laser_blind = {}
function modifier_laser_blind.new(construct, ...)
    local instance = setmetatable({}, modifier_laser_blind)
    if construct and modifier_laser_blind.constructor then modifier_laser_blind.constructor(instance, ...) end
    return instance
end
function modifier_laser_blind.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_FIXED_NIGHT_VISION,MODIFIER_PROPERTY_FIXED_DAY_VISION}
end
function modifier_laser_blind.GetFixedDayVision(self)
    return self.GetAbility(self).GetSpecialValueFor(self.GetAbility(self),"vision_radius")
end
function modifier_laser_blind.GetFixedNightVision(self)
    return self.GetAbility(self).GetSpecialValueFor(self.GetAbility(self),"vision_radius")
end
