require("typescript_lualib")
require("abilities/base_ability")
LinkLuaModifier("modifier_timelock_bonus_speed","abilities/timelock2.lua",LUA_MODIFIER_MOTION_NONE)
timelock = base_ability.new()
timelock.__index = timelock
timelock.__base = base_ability
function timelock.new(construct, ...)
    local instance = setmetatable({}, timelock)
    if construct and timelock.constructor then timelock.constructor(instance, ...) end
    return instance
end
function timelock.OnSpellStart(self)
    local caster = CDOTABaseAbility.GetCaster(self)

    local ents = CEntities.FindAllInSphere(Entities,Vector(0,0,0),FIND_UNITS_EVERYWHERE)

    local phys = Physics2D.units

    local duration = 1.5

    TS_forEach(phys, function(ent)
        if TS_indexOf(ents, ent)==-1 then
            table.insert(ents, ent)
        end
    end
)
    for _, ent in ipairs(ents) do
        local e = ent

        if e.IsProjectile and (e.caster~=caster) then
            e.IsTimeLocked=(CDOTAGamerules.GetGameTime(GameRules)+duration)
        end
    end
    EmitGlobalSound("Hero_FacelessVoid.Chronosphere")
    base_ability.ConsumeCharge(self)
    CDOTA_BaseNPC.AddNewModifier(caster,caster,self,"modifier_timelock_bonus_speed",{duration=duration})
    CDOTA_BaseNPC.AddNewModifier(caster,caster,self,"modifier_faceless_void_chronosphere_speed",{duration=duration})
end
modifier_timelock_bonus_speed = {}
modifier_timelock_bonus_speed.__index = modifier_timelock_bonus_speed
function modifier_timelock_bonus_speed.new(construct, ...)
    local instance = setmetatable({}, modifier_timelock_bonus_speed)
    if construct and modifier_timelock_bonus_speed.constructor then modifier_timelock_bonus_speed.constructor(instance, ...) end
    return instance
end
function modifier_timelock_bonus_speed.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end
function modifier_timelock_bonus_speed.GetModifierMoveSpeedBonus_Percentage(self)
    return 400
end
function modifier_timelock_bonus_speed.GetModifierMoveSpeed_AbsoluteMin(self)
    return 1500
end
function modifier_timelock_bonus_speed.GetModifierMoveSpeed_Max(self)
    return 1500
end
function modifier_timelock_bonus_speed.GetModifierMoveSpeed_Limit(self)
    return 1500
end
