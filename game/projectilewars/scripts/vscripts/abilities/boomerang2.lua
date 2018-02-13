---@class boomerang : base_ability
boomerang = class(base_ability)
---@override
function boomerang:GetProjectileParticleName()
  return "particles/units/heroes/hero_bounty_hunter/bounty_hunter_suriken_toss.vpcf"
end
---@override
function boomerang:GetProjectileUnitBehavior() return PROJECTILES_NOTHING end
---@override
function boomerang:GetProjectileProjectileBehavior() return PROJECTILES_NOTHING end
---@override
function boomerang:GetProjectileTreeBehavior() return PROJECTILES_NOTHING end
---@override
function boomerang:GetSound() return "Hero_BountyHunter.Shuriken" end
---@override
function boomerang:OnProjectileThink(projectile, projectile_location)
  if LengthSquared(projectile_location- self.dummyUnit:GetAbsOrigin()) < 150*150 then
    self.AimAtPoint = self.AimAtPoint +1
    if self.AimAtPoint <= #self.points then
      projectile.speed = projectile.speed * 0.8
      self.dummyUnit:SetAbsOrigin(self.points[self.AimAtPoint])
    else
      Physics2D:DestroyProjectile(projectile)
    end
  end
end
---@override
function boomerang:OnSpellStart()
  StoreSpecialKeyValues(self)
  self:ConsumeCharge()

  local caster = self:GetCaster()
  local point = self:GetCursorPosition()
  local direction = caster:GetForwardVector()
  --local direction = (point-caster:GetAbsOrigin()):Normalized()
  -- Create a table with points, 2 next to the points with 10 deg and startpoint
  local points = {}
  local range = math.min(self.range,(point-caster:GetAbsOrigin()):Length2D())
  point = caster:GetAbsOrigin() + direction * range

  points[1] = point
  points[2] = point + RandomVector(150)
  points[3] = caster:GetAbsOrigin()
  self.points = points
  self.AimAtPoint = 1
  self.dummyUnit =SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/development/invisiblebox.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})

  --self.dummyUnit = CreateUnitByName("npc_dummy_unit",points[1],false,caster,caster,caster:GetTeamNumber())
  self.dummyUnit:SetAbsOrigin(points[1])
  --local ab = self.dummyUnit:FindAbilityByName("dummy_unit")
  --ab:SetLevel(1)

  -- All values should be declared the same in the kv file
  local projectile_table = {
    hCaster = caster,
    hTarget = self.dummyUnit,
    vSpawnOrigin = self:GetSpawnOrigin(),
    flSpeed = self:GetProjectileSpeed(),
    flRadius = self.radius,
    sEffectName = self:GetProjectileParticleName(),
    flTurnRate = 10,
    OnProjectileThink = function(projectile,projectile_location)
      local loc = projectile_location + projectile.direction * 200
      AddFOWViewer(projectile.caster:GetTeamNumber(),loc  ,self.radius*5,0.5,false)
      self:OnProjectileThink(projectile,projectile_location)
    end,
    WallBehavior = PROJECTILES_DESTROY,
    TreeBehavior = PROJECTILES_NOTHING,
    ProjectileBehavior = self:GetProjectileProjectileBehavior(),
    UnitBehavior = self:GetProjectileUnitBehavior(),
    UnitTest = function(projectile, unit,caster)
      if self:HitsItems() and unit.GetContainedItem then return true end
      if unit.HasModifier and (unit:IsOutOfGame() or unit:IsInvulnerable()) or unit:GetUnitName() == "npc_unit_dodgedummy" then
        self:OnSpellDodged(caster,unit)
        PlayerDodgedProjectile(caster,unit,projectile)
        return false
      end

      return self:ShouldHitThisTeam(unit)
    end,
    OnUnitHit = function(projectile,unit,caster)
      self:OnProjectileHitUnit(projectile,unit,caster)
    end,
  }
  self.projectile = Physics2D:CreateTrackingProjectile(projectile_table)
  self:OnSpellStarted()
end



