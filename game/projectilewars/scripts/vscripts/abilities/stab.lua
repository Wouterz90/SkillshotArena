require("typescript_lualib")
require("abilities/base_ability")
stab = base_ability.new()
stab.__index = stab
stab.__base = base_ability
function stab.new(construct, ...)
    local instance = setmetatable({}, stab)
    if construct and stab.constructor then stab.constructor(instance, ...) end
    return instance
end
function stab.CastFilterResult(self)
    if CDOTA_BaseNPC.IsDisarmed(stab.GetCaster(self)) then
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end
function stab.GetCustomCastError(self)
    if CDOTA_BaseNPC.IsRooted(stab.GetCaster(self)) then
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
    local caster = stab.GetCaster(self)

    local caster_origin = CDOTA_BaseNPC.GetAbsOrigin(caster)

    local caster_forward = CDOTA_BaseNPC.GetForwardVector(caster)

    local range = stab.GetProjectileRange(self)

    CDOTA_BaseNPC.EmitSound(caster,"Hero_PhantomAssassin.Attack")
    local units = FindUnitsInRadius(CDOTA_BaseNPC.GetTeamNumber(caster),caster_origin,nil,range,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)

    for _, unit in ipairs(units) do
        local unit_origin = CDOTA_BaseNPC.GetAbsOrigin(unit)

        local m = unit_origin-caster_origin

        if (caster_forward.Dot(caster_forward,m.Normalized(m))>0.5) or ((CDOTA_BaseNPC.GetRangeToUnit(unit,caster)<100) and (caster_forward.Dot(caster_forward,m.Normalized(m))>0)) then
            local damageTable = {damage=stab.GetSpecialValueFor(self,"damage"),victim=unit,attacker=caster,ability=self,damage_type=DAMAGE_TYPE_PHYSICAL}

            ApplyDamage(damageTable)
            CDOTA_BaseNPC.EmitSound(caster,"Hero_PhantomAssassin.CoupDeGrace")
            local particle = CScriptParticleManager.CreateParticle(ParticleManager,"particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf",PATTACH_CUSTOMORIGIN,caster)

            CScriptParticleManager.SetParticleControlEnt(ParticleManager,particle,0,unit,PATTACH_POINT_FOLLOW,"attach_hitloc",unit_origin,true)
            CScriptParticleManager.SetParticleControlEnt(ParticleManager,particle,1,unit,PATTACH_ABSORIGIN_FOLLOW,"attach_origin",unit_origin,true)
            CScriptParticleManager.ReleaseParticleIndex(ParticleManager,particle)
            return nil
        end
    end
    SendOverheadEventMessage(nil,OVERHEAD_ALERT_MISS,caster,1,nil)
    CDOTA_BaseNPC.EmitSound(caster,"Hero_KeeperOfTheLight.Recall.Fail")
end
