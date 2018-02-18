require("abilities/base_ability")
shoot_ = class(base_ability)
function shoot_.new(construct, ...)
    local instance = setmetatable({}, shoot_)
    if construct and shoot_.constructor then shoot_.constructor(instance, ...) end
    return instance
end
function shoot_.CastFilterResult(self)
    if self.GetCaster(self).IsDisarmed(self.GetCaster(self)) then
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end
function shoot_.GetCustomCastError(self)
    if self.GetCaster(self).IsRooted(self.GetCaster(self)) then
        return "#Can't attack while rooted."
    end
end
function shoot_.GetProjectileSpeed(self)
    return 900
end
function shoot_.GetPlaybackRateOverride(self)
    return 2
end
function shoot_.destroyImmediatly(self)
    return false
end
function shoot_.GetCastRange(self)
    return self.GetCaster(self).GetAttackRange(self.GetCaster(self))*1.33
end
function shoot_.GetSound(self)
    return "Hero_Windrunner.Attack"
end
function shoot_.GetProjectileRange(self)
    return self.GetCaster(self).GetAttackRange(self.GetCaster(self))*1.33
end
function shoot_.GetProjectileParticleName(self)
    return self.GetCaster(self).GetRangedProjectileName(self.GetCaster(self))
end
function shoot_.GetProjectileUnitBehavior(self)
    return PROJECTILES_NOTHING
end
function shoot_.GetProjectileProjectileBehavior(self)
    return PROJECTILES_NOTHING
end
function shoot_.GetProjectileWallBehavior(self)
    return PROJECTILES_BOUNCE
end
function shoot_.GetProjectileItemBehavior(self)
    return PROJECTILES_NOTHING
end
function shoot_.OnProjectileHitUnit(self,projectile,unit,caster)
    local range = self.GetCaster(self).GetAttackRange(self.GetCaster(self))
    local mult = range/650
    mult=1
    local damageTable = {damage=self.GetSpecialValueFor(self,"damage")*mult,victim=unit,attacker=self.GetCaster(self),ability=self,damage_type=DAMAGE_TYPE_PHYSICAL}
    ApplyDamage(damageTable)
end
