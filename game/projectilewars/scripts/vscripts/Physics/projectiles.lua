---@class projectile : CBaseEntity

-- These projectiles only work in with Physics.lua
if not Physics2D then Warning("Physics file not found") end

-- Declaring values for projectile interactions
--- @type ProjectileType_t
PROJECTILES_IGNORE = 0 -- Ignore any other interaction defined by units/other projectiles
--- @type ProjectileType_t
PROJECTILES_NOTHING = 1
--- @type ProjectileType_t
PROJECTILES_DESTROY = 2
--- @type ProjectileType_t
PROJECTILES_BOUNCE = 3
--- @type ProjectileType_t
PROJECTILES_BOUNCE_OTHER_ONLY = 4

--vSpawnOrigin: Spawn location
--hCaster
--hTarget: Target to move to
--flDuration: Whenever this projectile expires, optional
--flSpeed
--flTurnRate: Use this to make the bouncing turn rate smaller
--flAcceleration: Speed * this, ran every frame, optional
--flStartRadius
--flEndRadius, Optional will default to startRadius
--flMaxDistance -- Max distance from target for tracking, linear max elapsed distance
--nSourceAttachment = the attachment the projectile originates from. Optional
--sEffectName, optional
--sSoundName, optional
--sDestructionEffectName, optional
--PlatformBehavior
--UnitBehavior
--ProjectileBehavior
--Debug?
--Functions: All optional
--OnUnitHit(self,unit)
--OnPlatformHit(self,platform)
--OnProjectileHit(self,projectile)
--OnProjectileThink(self)
--OnFinish(self)
--- @param keys table
--- @return projectile
function Physics2D:CreateTrackingProjectile(keys)
  local location
  if keys.vSpawnOrigin then
    location = keys.vSpawnOrigin
  elseif keys.iSourceAttachment then
    location = keys.hCaster:GetAttachmentOrigin( keys.iSourceAttachment )
  else
    location = keys.hCaster:GetAbsOrigin() + Vec(0,50)
  end
  local unit = keys.hUnit
  if not unit then
    unit =SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/development/invisiblebox.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  end
  unit:SetAbsOrigin(location)
  local sType = keys.sType or "circle"
  --[[if sType == "polygon" then
    Physics2D:CreatePolygon(unit,false,true,{unit:GetAbsOrigin()+Vec(-keys.flRadius,-keys.flRadius),unit:GetAbsOrigin()+Vec(keys.flRadius,-keys.flRadius),unit:GetAbsOrigin()+Vec(keys.flRadius,keys.flRadius),unit:GetAbsOrigin()+Vec(-keys.flRadius,keys.flRadius)})
  else
    Physics2D:CreateCircle(unit,false,true,keys.flRadius)
  end]]
  --Physics2D:CreateObject(sType,keys.vSpawnOrigin,false,true,unit,keys.flRadius,keys.flRadius,"Platform")

  Physics2D:CreateCircle(unit,keys.flRadius,"Projectile")
  unit.IsProjectile = "Tracking"
  --unit.dummy = dummy
  unit.startLoc = location
  unit.target = keys.hTarget
  unit.caster = keys.hCaster

  unit.creationTime = GameRules:GetGameTime()
  if keys.flDuration then unit.duration = keys.flDuration end
  unit.speed = keys.flSpeed * FrameTime()
  if keys.flAcceleration then unit.acceleration = keys.flAcceleration end
  unit.turnRate = keys.flTurnRate or 100
  unit.startRadius = keys.flRadius
  unit.controlPoint = keys.controlPoint or 0
  unit.destroyImmediatly = keys.destroyImmediatly or false
  if keys.flMaxDistance then unit.maxDistance = keys.flMaxDistance end
  if keys.sEffectName then unit.effectName = keys.sEffectName end
  if keys.sSoundName then unit.soundName = keys.sSoundName end
  if keys.sDestructionEffectName then unit.destructionEffectName = keys.sDestructionEffectName end
  if keys.WallBehavior then unit.WallBehavior = keys.WallBehavior end
  if keys.OnWallHit then unit.OnWallHit = keys.OnWallHit end
  if keys.TreeBehavior then unit.TreeBehavior = keys.TreeBehavior end
  if keys.OnTreeHit then unit.OnTreeHit = keys.OnTreeHit end
  if keys.ItemBehavior then unit.ItemBehavior = keys.ItemBehavior end
  if keys.OnItemHit then unit.OnItemHit = keys.OnItemHit end
  if keys.UnitBehavior then unit.UnitBehavior = keys.UnitBehavior end
  if keys.ProjectileBehavior then unit.ProjectileBehavior = keys.ProjectileBehavior end
  if keys.OnProjectileHit then unit.OnProjectileHit = keys.OnProjectileHit end
  if keys.UnitTest then unit.UnitTest = keys.UnitTest end
  if keys.OnProjectileThink then unit.OnProjectileThink = keys.OnProjectileThink end
  if keys.OnFinish then unit.OnFinish = keys.OnFinish end
  if keys.OnUnitHit then unit.OnUnitHit = keys.OnUnitHit end
  if keys.bCantBeStolen then unit.bCantBeStolen = keys.bCantBeStolen end



  unit.distanceTravelled = 0
  unit.location = unit:GetAbsOrigin()
  unit.direction = (unit.target:GetAbsOrigin() - unit.location):Normalized()
  unit.velocity = unit.direction * unit.speed
  unit.hitByProjectile = {}

  --Make the particle
  unit.particle = ParticleManager:CreateParticle(unit.effectName, PATTACH_CUSTOMORIGIN, unit.caster)
  ParticleManager:SetParticleControl(unit.particle,unit.controlPoint,unit:GetAbsOrigin())
  ParticleManager:SetParticleControlEnt(unit.particle,1,unit,PATTACH_POINT_FOLLOW,"attach_hitloc",unit:GetAbsOrigin(),true)
  ParticleManager:SetParticleControl(unit.particle,2,Vec(unit.speed *30,0))

  unit.maxSpeed = unit.speed
  return unit
end

function Physics2D:ManageTrackingProjectile(hProjectile)
  -- This gets called in the Physics Think function before
  if hProjectile.OnProjectileThink then
    local status, out = pcall(hProjectile.OnProjectileThink, hProjectile, hProjectile.location)
    if not status then
      print('[TRACKING PROJECTILE] OnProjectileThink Error!: ' .. out)
    end
  end

  -- Add this acceleration to the unit's max speed
  if hProjectile.acceleration then
    hProjectile.velocity = hProjectile.velocity * hProjectile.acceleration
    hProjectile.maxSpeed = hProjectile.maxSpeed * hProjectile.acceleration
  end

  -- Detect trees and act on them
  -- Tree radius is 50
  local tree
  local allTrees = GridNav:GetAllTreesAroundPoint(hProjectile.location,hProjectile.radius,true)
  trees = {}
  for _,tree in pairs(allTrees) do
    if IsTreeStanding(tree) then
      table.insert(trees,tree)
    end
  end

  if trees[1] then tree = trees[1] end
  if tree then
    tree.radius = 50
    tree.velocity = Vector(0,0,0)
    tree.restitution = 1
    tree.inv_mass = 1
    if hProjectile.TreeBehavior and hProjectile.TreeBehavior ~= PROJECTILES_NOTHING then
      if hProjectile.OnTreeHit then
        local status, out = pcall(hProjectile.OnTreeHit, hProjectile,tree)
        if not status then
          print('[TRACKING PROJECTILE] OnTreeHit Error!: ' .. out)
        end
      end
      if hProjectile.TreeBehavior == PROJECTILES_DESTROY then
        Physics2D:DestroyProjectile(hProjectile)
      elseif hProjectile.TreeBehavior == PROJECTILES_BOUNCE then
        local collision = CirclevsCircle(hProjectile,tree)
        if collision then
          ResolveCollision(collision)
        end
      end
    end
  end

  -- Extend the duration in case of timelock
  if hProjectile.IsTimeLocked then
    hProjectile.duration = hProjectile.duration + FrameTime()
    return
  end
  --Update the velocity
  -- I think I should add it, get the length and math.min the speed with the length
  if hProjectile.target and IsValidEntity(hProjectile.target) then
    hProjectile.direction  = (hProjectile.target:GetAbsOrigin() - hProjectile.location):Normalized()
  else
    hProjectile.direction = hProjectile.velocity:Normalized()
  end

  hProjectile.velocity = hProjectile.velocity + (hProjectile.direction * hProjectile.turnRate)
  hProjectile.speed = math.min(hProjectile.velocity:Length(),hProjectile.maxSpeed)
  hProjectile.velocity = hProjectile.velocity:Normalized() * hProjectile.speed

  hProjectile.distanceTravelled = hProjectile.distanceTravelled + hProjectile.speed

  if hProjectile.IsTimeLocked then
    ParticleManager:SetParticleControl(hProjectile.particle, 2, Vector(0,0,0))
  else
    ParticleManager:SetParticleControl(hProjectile.particle, 2, Vec(hProjectile.speed/FrameTime(),0))
  end

  -- Run all checks why this projectile could be destroyed
  if hProjectile.duration and hProjectile.creationTime + hProjectile.duration < GameRules:GetGameTime() then
    Physics2D:DestroyProjectile(hProjectile)
  end


  if hProjectile.maxDistance and hProjectile.maxDistance <= hProjectile.distanceTravelled then
    Physics2D:DestroyProjectile(hProjectile)
  end
end
--- @param keys table
--- @return projectile
function Physics2D:CreateLinearProjectile(keys)
  local location
  if keys.vSpawnOrigin then
    location = keys.vSpawnOrigin
  elseif keys.iSourceAttachment then
    location = keys.hCaster:GetAttachmentOrigin( keys.iSourceAttachment )
  else
    location = keys.hCaster:GetAbsOrigin()
  end

  local unit = keys.hUnit
  if not unit then
    unit =SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/development/invisiblebox.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  end
  unit:SetAbsOrigin(location)

  local sType = keys.sType or "circle"

  --[[if sType == "polygon" then
    Physics2D:CreatePolygon(unit,false,true,{unit:GetAbsOrigin()+Vec(-keys.flRadius,-keys.flRadius),unit:GetAbsOrigin()+Vec(keys.flRadius,-keys.flRadius),unit:GetAbsOrigin()+Vec(keys.flRadius,keys.flRadius),unit:GetAbsOrigin()+Vec(-keys.flRadius,keys.flRadius)})
  else
    Physics2D:CreateCircle(unit,false,true,keys.flRadius)
  end]]
  Physics2D:CreateCircle(unit,keys.flRadius,"Projectile")
  unit.IsProjectile = "Linear"
  --unit.dummy = dummy
  unit.startLoc = location
  unit.direction = keys.vDirection:Normalized()
  unit.caster = keys.hCaster
  unit.creationTime = GameRules:GetGameTime()
  if keys.flDuration then unit.duration = keys.flDuration end
  unit.speed = keys.flSpeed * FrameTime()
  if keys.flAcceleration then unit.acceleration = keys.flAcceleration end
  unit.turnRate = keys.flTurnRate or 1
  unit.startRadius = keys.flRadius
  unit.controlPoint = keys.controlPoint or 0
  unit.destroyImmediatly = keys.destroyImmediatly or false
  --if not keys.flEndRadius then unit.endRadius = keys.flStartRadius end
  if keys.flMaxDistance then unit.maxDistance = keys.flMaxDistance end
  if keys.sEffectName then unit.effectName = keys.sEffectName end
  if keys.sSoundName then unit.soundName = keys.sSoundName end
  if keys.sDestructionEffectName then unit.destructionEffectName = keys.sDestructionEffectName end
  if keys.WallBehavior then unit.WallBehavior = keys.WallBehavior end
  if keys.OnWallHit then unit.OnWallHit = keys.OnWallHit end
  if keys.TreeBehavior then unit.TreeBehavior = keys.TreeBehavior end
  if keys.OnTreeHit then unit.OnTreeHit = keys.OnTreeHit end
  if keys.ItemBehavior then unit.ItemBehavior = keys.ItemBehavior end
  if keys.OnItemHit then unit.OnItemHit = keys.OnItemHit end
  if keys.UnitBehavior then unit.UnitBehavior = keys.UnitBehavior end
  if keys.ProjectileBehavior then unit.ProjectileBehavior = keys.ProjectileBehavior end
  if keys.OnProjectileHit then unit.OnProjectileHit = keys.OnProjectileHit end
  if keys.UnitTest then unit.UnitTest = keys.UnitTest end
  if keys.OnProjectileThink then unit.OnProjectileThink = keys.OnProjectileThink end
  if keys.OnFinish then unit.OnFinish = keys.OnFinish end
  if keys.OnUnitHit then unit.OnUnitHit = keys.OnUnitHit end
  if keys.bCantBeStolen then unit.bCantBeStolen = keys.bCantBeStolen end

  unit:SetAbsOrigin(location + (unit.direction * unit.speed * FrameTime()))
  unit.location = unit:GetAbsOrigin()
  unit.velocity = unit.direction * unit.speed
  unit.distanceTravelled = 0
  unit.hitByProjectile = {}
  --Make the particle
  unit.particle = ParticleManager:CreateParticle(unit.effectName, PATTACH_CUSTOMORIGIN, unit.caster)
  ParticleManager:SetParticleControl(unit.particle,unit.controlPoint,unit:GetAbsOrigin())
  ParticleManager:SetParticleControlEnt(unit.particle,1,unit,PATTACH_POINT_FOLLOW,"attach_hitloc",unit:GetAbsOrigin(),true)
  ParticleManager:SetParticleControl(unit.particle,2,Vec(unit.speed *30,0))
  unit.maxSpeed = unit.speed
  return unit
end

function Physics2D:ManageLinearProjectile(hProjectile)
  if hProjectile.destroyed then return end
  -- This gets called in the Physics Think function before
  if hProjectile.OnProjectileThink then
    local status, out = pcall(hProjectile.OnProjectileThink, hProjectile, hProjectile.location)
    if not status then
      print('[LINEAR PROJECTILE] OnProjectileThink Error!: ' .. out)
    end
  end

  -- Detect trees and act on them
  -- Tree radius is 50
  local tree
  local allTrees = GridNav:GetAllTreesAroundPoint(hProjectile.location,hProjectile.radius,true)
  trees = {}
  for _,tree in pairs(allTrees) do
    if IsTreeStanding(tree) then
      table.insert(trees,tree)
    end
  end
  if trees[1] then tree = trees[1] end
  if tree then
    tree.radius = 50
    tree.velocity = Vector(0,0,0)
    tree.restitution = 1
    tree.inv_mass = 1
    if hProjectile.TreeBehavior and hProjectile.TreeBehavior ~= PROJECTILES_NOTHING then
      if hProjectile.OnTreeHit then
        local status, out = pcall(hProjectile.OnTreeHit, hProjectile,tree)
        if not status then
          print('[LINEAR PROJECTILE] OnTreeHit Error!: ' .. out)
        end
      end
      if hProjectile.TreeBehavior == PROJECTILES_DESTROY then
        Physics2D:DestroyProjectile(hProjectile)
      elseif hProjectile.TreeBehavior == PROJECTILES_BOUNCE then
        local collision = CirclevsCircle(hProjectile,tree)
        if collision then
          ResolveCollision(collision)
        end
      end
    end
  end

  -- Extend duration for timelocked
  if hProjectile.IsTimeLocked then
    hProjectile.duration = hProjectile.duration + FrameTime()
    return
  end
  -- Add this acceleration to the unit's max speed
  if hProjectile.acceleration then
    hProjectile.velocity = hProjectile.velocity * hProjectile.acceleration
    hProjectile.speed = hProjectile.speed * hProjectile.acceleration
  end
  hProjectile.distanceTravelled = hProjectile.distanceTravelled + hProjectile.speed
  if not hProjectile.gravity then
    hProjectile.velocity = hProjectile.velocity:Normalized() * hProjectile.speed
  end

  if hProjectile.IsTimeLocked then
    ParticleManager:SetParticleControl(hProjectile.particle, 2, Vec(0,0))
  else
    ParticleManager:SetParticleControl(hProjectile.particle, 2, Vec(hProjectile.speed/FrameTime(),0))
  end


  -- Run all checks why this projectile could be destroyed
  if hProjectile.duration and hProjectile.creationTime + hProjectile.duration < GameRules:GetGameTime() then
    Physics2D:DestroyProjectile(hProjectile)
  end

  if hProjectile.maxDistance and hProjectile.maxDistance <= hProjectile.distanceTravelled then
    Physics2D:DestroyProjectile(hProjectile)
  end
end

function Physics2D:DestroyProjectile(hProjectile)
  if hProjectile.destroyed then return end
  if hProjectile.OnFinish then
    local status, out = pcall(hProjectile.OnFinish, hProjectile)
    if not status then
      print('[PROJECTILE] OnFinish Failure!: ' .. out)
    end
  end
  hProjectile.destroyed = true
  
  -- Keep the unit for a while to have the destruction particle
  if hProjectile.destroyImmediatly then
    ParticleManager:DestroyParticle(hProjectile.particle, false)
    ParticleManager:ReleaseParticleIndex(hProjectile.particle)
    Timers:CreateTimer(0.1,function()
      hProjectile.RemoveProjectile = true
    end)
  else
    ParticleManager:DestroyParticle(hProjectile.particle, true)
    ParticleManager:ReleaseParticleIndex(hProjectile.particle)
    Timers:CreateTimer(0.5,function()
      hProjectile.RemoveProjectile = true
    end)
  end
end

function Physics2D:ProjectileHitItem(a,b)
  if a.destroyed then return end
  if a.OnItemHit then
    local status, out = pcall(a.OnItemHit, a, b)
    if not status then
      print('[PROJECTILES] OnItemHit Error!: ' .. out)
    end
  end
end

function Physics2D:ProjectileHitUnit(projectile,unit)
  if projectile.destroyed then return end
  if projectile.hitByProjectile.unit then return end
  local status, test = pcall(projectile.UnitTest, projectile, unit, projectile.caster)
  if not status then
    print('[PROJECTILES] Projectile UnitTest Failure!: ' .. test)
  elseif test then
    projectile.hitByProjectile.unit = true
    if projectile.OnUnitHit then
      local status2, out = pcall(projectile.OnUnitHit, projectile, unit, projectile.caster)
      if not status2 then
        print('[PROJECTILES] OnUnitHit Error!: ' .. out)
      end
    end
    if projectile.UnitBehavior == PROJECTILES_DESTROY then
      Physics2D:DestroyProjectile(projectile)
    end
    return true
  end
  return false
end

function Physics2D:ProjectileHiTree(projectile,tree)
  if projectile.destroyed then return end
  if projectile.TreeBehavior == PROJECTILES_DESTROY then
    Physics2D:DestroyProjectile(projectile)
  end

  if projectile.OnTreeHit then
    local status, out = pcall(projectile.OnPlatformHit, projectile, tree)
    if not status then
      print('[PROJECTILES] OnTreeHit Error!: ' .. out)
    end
  end
  return
end

function Physics2D:ProjectileHitWall(projectile,wall)
  if projectile.destroyed then return end
  if projectile.WallBehavior == PROJECTILES_DESTROY and wall.caster and wall.caster ~= projectile.caster then
    Physics2D:DestroyProjectile(projectile)
  end

  if projectile.OnWallHit then
    -- Change projectile ownership if wall is owned by a unit
    if wall.caster then projectile.caster = wall.caster end
    local status, out = pcall(projectile.OnWallHit, projectile, wall)
    if not status then
      print('[PROJECTILES] OnWallHit Error!: ' .. out)
    end
  end
  return
end

function Physics2D:ProjectileHitProjectile(a,b)
  if a.destroyed then return end
  if b.destroyed then return end
  if a.OnProjectileHit then
    local status, out = pcall(a.OnProjectileHit, a, b)
    if not status then
      print('[PROJECTILES] OnProjectileHit Error!: ' .. out)
    end
  end
  if b.OnProjectileHit then
    local status, out = pcall(b.OnProjectileHit, b, a)
    if not status then
      print('[PROJECTILES] OnProjectileHit Error!: ' .. out)
    end
  end
end

--- Not needed to function as wall, but to show particles
---@param unit CBaseEntity
---@param edges table
function CreateProjectileWall(unit,edges)
  local t = {}
  for i=1,#edges-1 do
    local direction = (edges[i+1]-edges[i]):Normalized()
    local length = (edges[i+1]-edges[i]):Length2D()
    local midpoint = edges[i] + direction * length *0.5
    local particle = ParticleManager:CreateParticle("particles/dark_seer_wall_of_replica.vpcf", PATTACH_ABSORIGIN,unit )
    ParticleManager:SetParticleControlForward( particle, 0, direction)
    ParticleManager:SetParticleControl( particle, 0, ( edges[i]))
    ParticleManager:SetParticleControl( particle, 1, ( edges[i+1]))
    ParticleManager:SetParticleControl( particle, 2, direction)
    t[i] = particle
  end
  -- For the last to the first
  local direction = (edges[1]-edges[#edges]):Normalized()
  local length = (edges[1]-edges[#edges]):Length2D()
  local midpoint = edges[#edges] + direction * length *0.5
  local particle = ParticleManager:CreateParticle("particles/dark_seer_wall_of_replica.vpcf", PATTACH_ABSORIGIN,unit )
  ParticleManager:SetParticleControlForward( particle, 0, direction)
  ParticleManager:SetParticleControl( particle, 0, ( edges[#edges]))
  ParticleManager:SetParticleControl( particle, 1, ( edges[1]))
  ParticleManager:SetParticleControl( particle, 2, direction)
  t[#edges] = particle

  return t
end