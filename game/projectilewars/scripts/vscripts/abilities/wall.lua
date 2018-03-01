require("typescript_lualib")
require("abilities/base_ability")
wall = base_ability.new()
wall.__index = wall
wall.__base = base_ability
function wall.new(construct, ...)
    local instance = setmetatable({}, wall)
    if construct and wall.constructor then wall.constructor(instance, ...) end
    return instance
end
function wall.OnSpellStart(self)
    local caster = CDOTABaseAbility.GetCaster(self)

    local origin = CBaseEntity.GetAbsOrigin(caster)

    local point = CDOTA_BaseNPC.GetCursorPosition(caster)

    local forward = CBaseEntity.GetForwardVector(caster)

    local right = GetRightPerpendicular(forward)

    local pos = origin+(forward*200)

    local locs = {right*200,-right*200}

    local wall = Physics2D.CreatePolygon(Physics2D,Vector(0,0,0),locs,nil)

    wall.caster=caster
    for i=0,#locs-1,1 do
        locs[i+1]=(locs[i+1]+pos)
    end
    local wallParticles = CreateProjectileWall(wall,locs)

    base_ability.ConsumeCharge(self)
    Timers.CreateTimer(Timers,5,function()
        if wall and not CBaseEntity.IsNull(wall) then
            if wallParticles then
                for _, p in ipairs(wallParticles) do
                    CScriptParticleManager.DestroyParticle(ParticleManager,p,true)
                    CScriptParticleManager.ReleaseParticleIndex(ParticleManager,p)
                end
            end
            UTIL_Remove(wall)
        end
    end
)
end
