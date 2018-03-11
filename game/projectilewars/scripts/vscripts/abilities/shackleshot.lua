require("typescript_lualib")
shackleshot = base_ability.new()
shackleshot.__index = shackleshot
shackleshot.__base = base_ability
function shackleshot.new(construct, ...)
    local instance = setmetatable({}, shackleshot)
    if construct and shackleshot.constructor then shackleshot.constructor(instance, ...) end
    return instance
end
function shackleshot.GetProjectileParticleName(self)
    return "particles/units/heroes/hero_windrunner/windrunner_shackleshot.vpcf"
end
