require("typescript_lualib")
require("abilities/base_ability")
shards = base_ability.new()
shards.__index = shards
shards.__base = base_ability
function shards.new(construct, ...)
    local instance = setmetatable({}, shards)
    if construct and shards.constructor then shards.constructor(instance, ...) end
    return instance
end
function shards.GetProjectileParticleName(self)
    return "particles/abilities/shards/tusk_ice_shards_projectile.vpcf"
end
function shards.GetSound(self)
    return "Hero_Tusk.IceShards.Projectile"
end
function shards.GetProjectileRange(self)
    local normal = CDOTABaseAbility.GetCursorPosition(self)-CBaseEntity.GetAbsOrigin(CDOTABaseAbility.GetCaster(self))

    return normal.Length2D(normal)
end
function shards.GetProjectileUnitBehavior(self)
    return PROJECTILES_NOTHING
end
function shards.GetProjectileWallBehavior(self)
    return PROJECTILES_DESTROY
end
function shards.GetProjectileItemBehavior(self)
    return PROJECTILES_IGNORE
end
function shards.GetProjectileTreeBehavior(self)
    return PROJECTILES_DESTROY
end
function shards.OnProjectileHitUnit(self)
end
function shards.OnProjectileFinish(self,projectile)
    local caster = projectile.caster

    CBaseEntity.EmitSound(caster,"Hero_Tusk.IceShards")
    local shard_distance = CDOTABaseAbility.GetSpecialValueFor(self,"shard_distance")

    local shard_duration = CDOTABaseAbility.GetSpecialValueFor(self,"shard_duration")

    local shards = {}

    local blockers = {}

    local particle = CScriptParticleManager.CreateParticle(ParticleManager,"particles/units/heroes/hero_tusk/tusk_ice_shards.vpcf",PATTACH_WORLDORIGIN,caster)

    CScriptParticleManager.SetParticleControl(ParticleManager,particle,0,Vector(shard_duration,0,0))
    for i=0,6,1 do
        local angle = -120+(i*40)

        local direction = RotatePosition(Vector(0,0,0),QAngle(0,angle,0),projectile.direction)

        local position = GetGroundPosition(projectile.pos+(direction*shard_distance),nil)

        shards[i+1]=Physics2D.CreatePolygon(Physics2D,position,{(GetRightPerpendicular(direction)*shard_distance)/2,(-GetRightPerpendicular(direction)*shard_distance)/2},nil)
        CScriptParticleManager.SetParticleControl(ParticleManager,particle,i+1,position)
        blockers[i+1]=SpawnEntityFromTableSynchronous("point_simple_obstruction",{origin=position})
    end
    Timers.CreateTimer(Timers,shard_duration,function()
        for i=0,6,1 do
            UTIL_Remove(blockers[i+1])
            UTIL_Remove(shards[i+1])
        end
    end
)
end
