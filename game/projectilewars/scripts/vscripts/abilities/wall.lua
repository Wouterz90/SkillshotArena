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
    local direction = nil

    local origin = nil

    local caster = CDOTABaseAbility.GetCaster(self)

    local distance = nil

    if self.endPos then
        direction=(self.endPos-self.startPos)
        distance=direction.Length2D(direction)
        direction=direction.Normalized(direction)
        origin=(self.startPos+(direction*(distance/2)))
    else
        direction=CBaseEntity.GetForwardVector(caster)
        origin=(CBaseEntity.GetAbsOrigin(caster)+(direction*200))
        direction=GetRightPerpendicular(direction)
    end
    distance=500
    local locs = {(direction*distance)/2,(-direction*distance)/2}

    local wall = Physics2D.CreatePolygon(Physics2D,origin,locs,nil)

    wall.caster=caster
    for i=0,#locs-1,1 do
        locs[i+1]=(locs[i+1]+origin)
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
    self.startPos=nil
    self.endPos=nil
end
