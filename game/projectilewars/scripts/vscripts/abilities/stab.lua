require("abilities/base_ability")
stab = class(base_ability)
function stab.new(construct, ...)
    local instance = setmetatable({}, stab)
    if construct and stab.constructor then stab.constructor(instance, ...) end
    return instance
end
function stab.CastFilterResult(self)
    if self.GetCaster(self).IsDisarmed(self.GetCaster(self)) then
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end
function stab.GetCustomCastError(self)
    if self.GetCaster(self).IsRooted(self.GetCaster(self)) then
        return "#Can't attack while rooted."
    end
end
function stab.GetPlaybackRateOverride(self)
    return 2
end
function stab.GetCastRange(self)
    return 5000
end
function stab.OnSpellStart(self)
    local caster = self.GetCaster(self)
    local caster_origin = caster.GetAbsOrigin(caster)
    local caster_forward = caster.GetForwardVector(caster)
    local range = self.GetProjectileRange(self)
    caster.EmitSound(caster,"Hero_PhantomAssassin.Attack")
    local units = FindUnitsInRadius(caster.GetTeamNumber(caster),caster_origin,nil,range,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
    for _, unit in pairs(units) do
        local unit_origin = unit.GetAbsOrigin(unit)
        local m = unit_origin-caster_origin
        if (caster_forward.Dot(caster_forward,m.Normalized(m))>0.5) or ((unit.GetRangeToUnit(unit,caster)<100) and (caster_forward.Dot(caster_forward,m.Normalized(m))>0)) then
            local damageTable = {damage=self.GetSpecialValueFor(self,"damage"),victim=unit,attacker=caster,ability=self,damage_type=DAMAGE_TYPE_PHYSICAL}
            ApplyDamage(damageTable)
            caster.EmitSound(caster,"Hero_PhantomAssassin.CoupDeGrace")
            local particle = ParticleManager.CreateParticle(ParticleManager,"particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf",PATTACH_CUSTOMORIGIN,caster)
            ParticleManager.SetParticleControlEnt(ParticleManager,particle,0,unit,PATTACH_POINT_FOLLOW,"attach_hitloc",unit_origin,true)
            ParticleManager.SetParticleControlEnt(ParticleManager,particle,1,unit,PATTACH_ABSORIGIN_FOLLOW,"attach_origin",unit_origin,true)
            ParticleManager.ReleaseParticleIndex(ParticleManager,particle)
            return nil
        end
    end
    SendOverheadEventMessage(nil,OVERHEAD_ALERT_MISS,caster,1,nil)
    caster.EmitSound(caster,"Hero_KeeperOfTheLight.Recall.Fail")
end
