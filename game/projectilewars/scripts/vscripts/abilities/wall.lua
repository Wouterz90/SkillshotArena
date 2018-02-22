require("abilities/base_ability")
wall = class(base_ability)
function wall.new(construct, ...)
    local instance = setmetatable({}, wall)
    if construct and wall.constructor then wall.constructor(instance, ...) end
    return instance
end
function wall.OnSpellStart(self)
    local caster = self.GetCaster(self)
    local origin = caster.GetAbsOrigin(caster)
    local point = caster.GetCursorPosition(caster)
    local forward = caster.GetForwardVector(caster)
    local right = GetRightPerpendicular(forward)
    local pos = origin+(forward*200)
    local locs = {right*200,-right*200}
    local wall = Physics2D.CreatePolygon(Physics2D,Vector(0,0,0),locs,nil)
    wall.caster=caster
    for i=0,#locs-1,1 do
        locs[i+1]=(locs[i+1]+pos)
    end
    local wallParticles = CreateProjectileWall(wall,locs)
    self.ConsumeCharge(self)
    Timers.CreateTimer(Timers,5,function()
        if wall and not wall.IsNull(wall) then
            if wallParticles then
                for _, p in pairs(wallParticles) do
                    ParticleManager.DestroyParticle(ParticleManager,p,true)
                    ParticleManager.ReleaseParticleIndex(ParticleManager,p)
                end
            end
            UTIL_Remove(wall)
        end
    end
)
end
