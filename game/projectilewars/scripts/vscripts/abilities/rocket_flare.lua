require('abilities/base_ability')
---@class rocket_flare : base_ability
rocket_flare = class(base_ability)

-- These functions should/could be overridden
---@override
function rocket_flare:GetProjectileParticleName() return "particles/abilities/rocket_flare/rattletrap_rocket_flare.vpcf" end
---@override
function rocket_flare:GetProjectileUnitBehavior() return PROJECTILES_NOTHING end
---@override
function rocket_flare:GetProjectileProjectileBehavior() return PROJECTILES_NOTHING end
---@override
function rocket_flare:GetSound() return "Hero_Rattletrap.Rocket_Flare.Fire" end
---@override
function rocket_flare:GetProjectileRange() return (self:GetCaster():GetAbsOrigin() - self:GetCursorPosition()):Length2D() end
---@override
--Fire a projectile to target location, then flare the map for a frame, then reveal target place for some time
function rocket_flare:OnProjectileFinish(projectile)
  local caster = self:GetCaster()

  --Reveal everything

  for _,team in pairs(ALL_TEAMS) do
    if PlayerResource:GetPlayerCountForTeam(team) > 0 then
      AddFOWViewer(team,Vector(0,0,128),7500,0.33,false)
    end
  end
  AddFOWViewer(caster:GetTeamNumber(),projectile.location,600,3,false)



end