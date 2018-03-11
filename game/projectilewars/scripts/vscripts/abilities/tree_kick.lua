require("typescript_lualib")
require("abilities/base_ability")
tree_kick = base_ability.new()
tree_kick.__index = tree_kick
tree_kick.__base = base_ability
function tree_kick.new(construct, ...)
    local instance = setmetatable({}, tree_kick)
    if construct and tree_kick.constructor then tree_kick.constructor(instance, ...) end
    return instance
end
function tree_kick.CastFilterResult(self)
    if IsServer() then
        local caster = CDOTABaseAbility.GetCaster(self)

        local caster_origin = CBaseEntity.GetAbsOrigin(caster)

        local trees = GridNav.GetAllTreesAroundPoint(GridNav,caster_origin,150,true)

        if #trees==0 then
            return UF_FAIL_INVALID_LOCATION
        end
    end
    return UF_SUCCESS
end
function tree_kick.OnSpellStart(self)
    local caster = CDOTABaseAbility.GetCaster(self)

    local caster_origin = CBaseEntity.GetAbsOrigin(caster)

    local trees = GridNav.GetAllTreesAroundPoint(GridNav,caster_origin,150,true)

    TS_forEach(trees, function(tree)
        print(CBaseEntity.GetModelName(tree))
        CEntityInstance.GetName(tree)
    end
)
end
