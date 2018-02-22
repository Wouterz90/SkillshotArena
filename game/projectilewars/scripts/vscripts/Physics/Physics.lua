
---@class Physics2D
Physics2D = Physics2D or class({})
inv_ft = 1/FrameTime()
require('physics/physics_util')

--- Create a polygon attached to a unit
--- @param hUnit|Vector CBaseEntity The unit attached to the physics object
--- @param sMaterial string The name of the material
--- @param tEdges table table with coordinates for the edges
--- @return CBaseEntity the unit attached
function Physics2D:CreatePolygon(hUnit,tEdges,sMaterial)
  if hUnit.Dot then
    local v = hUnit
    hUnit = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/development/invisiblebox.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
    hUnit:SetAbsOrigin(v)
  end
  sMaterial = sMaterial or "Unit"
  hUnit.radius = 1
  local mass,inv_mass,restitution = Physics2D:CalculateMass(flRadius,nil)
  Physics2D.units = Physics2D.units or {}
  hUnit = hUnit or {}
  hUnit.unit = hUnit or nil
  hUnit.material = sMaterial
  hUnit.draw = false --IsInToolsMode()
  hUnit.type = "Polygon"
  hUnit.location = hUnit:GetAbsOrigin()
  hUnit.mass = mass
  hUnit.inv_mass = inv_mass
  hUnit.restitution = restitution
  hUnit.edges = tEdges
  hUnit.velocity = hUnit.velocity or Vec(0)

  -- Make sure edges are clockwise

  local sum = 0
  for i=1,#tEdges-1 do
    sum = sum + (tEdges[i+1].x-tEdges[i].x) * (tEdges[i+1].y+tEdges[i].y)
  end
  sum = sum + (tEdges[1].x-tEdges[#tEdges].x) * (tEdges[1].y+tEdges[#tEdges].y)

  if sum > 0 then
    -- Rotate array
    local reversedTable = {}
    local itemCount = #hUnit.edges
    for k, v in ipairs(hUnit.edges) do
      reversedTable[itemCount + 1 - k] = v
    end
    hUnit.edges = reversedTable
  end

  -- Add it into the table
  table.insert(Physics2D.units,hUnit)
  -- Return to show success
  return hUnit
end

--- Create a circle attached to a unit
--- @param hUnit CBaseEntity The unit attached to the physics object
--- @param sMaterial string The name of the material
--- @param tEdges table table with coordinates for the edges
--- @return CBaseEntity the unit attached
function Physics2D:CreateCircle(hUnit,flRadius,sMaterial)
  sMaterial = sMaterial or "Unit"
  hUnit.radius = flRadius
  local mass,inv_mass,restitution = Physics2D:CalculateMass(flRadius,nil)
  Physics2D.units = Physics2D.units or {}
  hUnit = hUnit or {}
  hUnit.unit = hUnit or nil
  hUnit.material = sMaterial
  hUnit.draw = false --IsInToolsMode()
  hUnit.type = "Circle"
  hUnit.location = hUnit:GetAbsOrigin()
  hUnit.mass = mass
  hUnit.inv_mass = inv_mass
  hUnit.restitution = restitution

  hUnit.velocity = hUnit.velocity or Vec(0)

  -- Add it into the table
  table.insert(Physics2D.units,hUnit)
  -- Return to show success
  return hUnit
end

function CirclevsPolygon(a,b)

  if a.type ~= "Circle" and b.type ~= "Polygon" then
    print("CirclevsPolygon fired with", "a",a.type,"b",b.type)
    return
  end
  a.pos = a.pos or a:GetAbsOrigin()
  b.pos = b.pos or b:GetAbsOrigin()
  local aRadiusSquared = a.radius * a.radius
  local normal
  local edge_1,edge_2
  local penetration = 0
  -- Check for all the edges if the circle is touching them
  local edges = {}
  for _,v in pairs(b.edges) do
    local e = v
    e.z = 0
    table.insert(edges,e+b.pos)
  end
  for i=1,#edges-1 do
    local direction = (edges[i+1]-edges[i]):Normalized()
    local sqDistance = GetSquareDistanceFromPointToLine(edges[i],edges[i+1],a.pos)
    if sqDistance <= aRadiusSquared then
      if aRadiusSquared - sqDistance > penetration then
        penetration = aRadiusSquared - sqDistance
        normal = -GetRightPerpendicular(direction)
        edge_1 = edges[i]
        edge_2 = edges[i+1]
      end
    end
  end

    local direction = (edges[1]-edges[#edges]):Normalized()
    local sqDistance = GetSquareDistanceFromPointToLine(edges[#edges],edges[1],a.pos)
    if sqDistance <= aRadiusSquared then
      if aRadiusSquared - sqDistance > penetration then
        penetration = aRadiusSquared - sqDistance
        normal = -GetRightPerpendicular(direction)
        edge_1 = edges[#edges]
        edge_2 = edges[1]
      end
    end

  if penetration ~= 0 then
    -- Rotate the normal
    if Physics2D:IsPointLeftFromLine(edge_1,edge_2,a.pos) then
      normal = normal * -1
    end
    local tab = {
      a=a,
      b=b,
      normal=normal,
      penetration=math.sqrt(penetration)
    }

    return tab
  end
end



function CirclevsCircle(a,b)

  local normal
  local penetration
  -- Vector from A to B
  a.pos = a.pos or a:GetAbsOrigin()
  b.pos = b.pos or b:GetAbsOrigin()
  local n = b.pos - a.pos
  local r = math.pow(a.radius + b.radius,2)

  local bCollision =  r > LengthSquared(n)
  if not bCollision then return end

  -- Circles have collided, now compute manifold
  local d = n:Length2D() -- Perform actual sqrt

  -- If distance between circles is not zero
  if d ~= 0 then
    -- Distance is differene between radius and distance
    penetration = r-d
    -- Utilize our d since we performed sqrt on it already within Length( )
    -- Points from A to B, and is a unit vector
    normal = n/d
    return {a,b,normal,penetration}
  else
    penetration = a.radius
    normal = Vec(1,0)
    local tab = {
      a=a,
      b=b,
      normal=normal,
      penetration=penetration
    }
    return tab
  end
end

function ResolveCollision( collision )
  -- Calculate relative velocity


  local a = collision.a or collision[1]
  local b = collision.b or collision[2]
  local normal = collision.normal or collision[3]
  --local penetration = collision.penetration or collision[4]

  if a:IsNull() or b:IsNull() then return end

  --DebugPrint(2,"Physics2D ResolveCollision")
  --DebugPrintTable(2,collision)
  local rv = b.velocity - a.velocity
  -- Calculate relative velocity in terms of the normal direction

  local velAlongNormal = rv:Dot(normal)
  -- Do not resolve if velocities are separating
  if velAlongNormal > 0 then return end

  if a.IsProjectile and b.IsProjectile then
    if a.ProjectileBehavior or b.ProjectileBehavior and not a.ProjectileBehavior == PROJECTILES_IGNORE or b.ProjectileBehavior == PROJECTILES_IGNORE then
      Physics2D:ProjectileHitProjectile(a,b)
    end
    local ignore = a.ProjectileBehavior == PROJECTILES_IGNORE or b.ProjectileBehavior == PROJECTILES_IGNORE and (a.ProjectileBehavior == PROJECTILES_BOUNCE_OTHER_ONLY and b.ProjectileBehavior == PROJECTILES_BOUNCE_OTHER_ONLY)
    if ignore then return end
    local a_bounces = a.ProjectileBehavior == PROJECTILES_BOUNCE or a.ProjectileBehavior == PROJECTILES_BOUNCE_OTHER_ONLY
    local b_bounces = b.ProjectileBehavior == PROJECTILES_BOUNCE or b.ProjectileBehavior == PROJECTILES_BOUNCE_OTHER_ONLY
    if not a_bounces and not b_bounces then return end
  end

  -- Check if one is a unit and the other a projectile
  -- Projectile vs projectile collision has already been handled here
  if a.IsProjectile and b.HasModifier then
    if a.UnitBehavior then
      if not Physics2D:ProjectileHitUnit(a,b) then
        return
      end
      if a.UnitBehavior ~= PROJECTILES_BOUNCE then
        return
      end
    end
    return
  elseif b.IsProjectile and a.HasModifier then
    if b.UnitBehavior  then
      if not Physics2D:ProjectileHitUnit(b,a) then
        return
      end
      if b.UnitBehavior ~= PROJECTILES_BOUNCE then
        return
      end
      return
    end
  end

  -- Trees are done in the projectile think functions
  if (b:GetClassname()  == "ent_dota_tree" or b:GetClassname() == "dota_temp_tree") and a.TreeBehavior ~= PROJECTILES_BOUNCE then
    return
  end

  if (a:GetClassname()  == "ent_dota_tree" or a:GetClassname()  == "dota_temp_tree") and b.TreeBehavior ~= PROJECTILES_BOUNCE then
    return
  end

  --Polygons are always walls
  if a.type == "Polygon" and b.IsProjectile then
    Physics2D:ProjectileHitWall(b,a)
    if b.WallBehavior ~= PROJECTILES_BOUNCE --[[or (a.caster and  a.caster == b.caster)]] then
      return
    end
  end
  if b.type == "Polygon" and a.IsProjectile then
    Physics2D:ProjectileHitWall(a,b)
    if a.WallBehavior ~= PROJECTILES_BOUNCE --[[or (b.caster and  a.caster == b.caster)]] then
      return
    end
  end

  if a.GetContainedItem then
    Physics2D:ProjectileHitItem(b,a)
    if b.ItemBehavior and b.ItemBehavior ~= PROJECTILES_BOUNCE then
      return
    end
  end
  if b.GetContainedItem then
    Physics2D:ProjectileHitItem(a,b)
    if a.ItemBehavior and a.ItemBehavior ~= PROJECTILES_BOUNCE then
      return
    end
  end
  -- Calculate restitution
  local e = math.min(a.restitution, b.restitution)

  -- Calculate impulse scalar
  local j = -(1 + e) * velAlongNormal
  j =  j / b.inv_mass + a.inv_mass

  local impulse = j * normal
  if not a.ProjectileBehavior or a.ProjectileBehavior ~= PROJECTILES_BOUNCE_OTHER_ONLY then

    if a.type == "Circle" then

      a.velocity =  a.velocity - a.inv_mass * impulse

    end
  end
  if not b.ProjectileBehavior or b.ProjectileBehavior ~= PROJECTILES_BOUNCE_OTHER_ONLY then
    if b.type == "Circle" then
      b.velocity =  b.velocity + b.inv_mass * impulse
    end
  end

end

function Physics2D:Think()
  -- dt is always FrameTime()
  -- Remove null values from table
  RemoveNullFromTable(Physics2D.units)

  for _,unit in pairs(Physics2D.units) do
    if unit.draw then
      local origin = unit:GetAbsOrigin() or unit.location
      if unit.type == "Circle" then
        DebugDrawSphere(origin,Vec(255,0),1,unit.radius,true,3*FrameTime())
      elseif unit.type == "Polygon" then
        DebugDrawLine(origin + unit.edges[1],origin + unit.edges[#unit.edges],255,255,255,true,3*FrameTime())
        for i=1,#unit.edges-1 do
          DebugDrawLine(origin + unit.edges[i],origin + unit.edges[i+1],255,255,255,true,3*FrameTime())
        end
      end
    end
  end

  -- Calculate next position for each unit based on physics position
  for n,unit in pairs(Physics2D.units) do
    local origin = unit:GetAbsOrigin() or unit.location
    origin.z = 0
    unit.velocity = Physics2D:CalculateVelocity(unit)
    unit.pos = origin + unit.velocity
  end
  -- Check for collision between them
  -- Don't check twice
  for i = 1,#Physics2D.units-1 do
    if not (Physics2D.units[i]["destroyed"]) then
      for j = i+1,#Physics2D.units do
        if not (Physics2D.units[j]["destroyed"]) then
          -- Dont bother calculating for objects that dont move (Trees,walls etc)
          if LengthSquared(Physics2D.units[i].velocity) > 0.5 or LengthSquared(Physics2D.units[j].velocity) > 0.5 then
            if Physics2D.units[i].type == "Circle" and Physics2D.units[j].type == "Circle" then
              collision = CirclevsCircle(Physics2D.units[i],Physics2D.units[j])
            elseif Physics2D.units[i].type == "Circle" and Physics2D.units[j].type == "Polygon" then
              collision = CirclevsPolygon(Physics2D.units[i],Physics2D.units[j])
            elseif Physics2D.units[j].type == "Circle" and Physics2D.units[i].type == "Polygon" then
              collision = CirclevsPolygon(Physics2D.units[j],Physics2D.units[i])
            end
          end
        end
        if collision then -- Collision is a table containing objects, normal and penetration
          ResolveCollision(collision)
        end
      end
    end
  end

  -- Update unit positions
  for _,unit in pairs(Physics2D.units) do
    -- Update velocity
    if not unit:IsNull() then
      unit.location = unit:GetAbsOrigin() + unit.velocity
      unit.location = GetGroundPosition(unit.location,unit)
      unit:SetAbsOrigin(unit.location)
    end
  end
end

function Physics2D:Init()
  -- Start a timer to run every frame to control interactions
  if Physics2D.started then return end
  Physics2D.started = true
  Physics2D.units = Physics2D.units or {}
  Physics2D.items = Physics2D.items or {}


  Timers:CreateTimer(FrameTime()*1,function()
    local status, out = pcall(Physics2D.Think)
    if not status then
      print('[PHYSICS2D LOOP] ERROR!: ' .. out)
    end

    if GameRules:State_Get() < DOTA_GAMERULES_STATE_POST_GAME then
      return FrameTime()
    end
  end)
end

Physics2D:Init()

Physics2D.materials = {
  Rock = {Density = 0.6,  Restitution = 0.1},
  Wood = {Density = 0.3,  Restitution = 0.2},
  Metal = {Density = 1.2,  Restitution = 0.05},
  Projectile = {Density = 0.01,  Restitution = 0.5},
  BouncyBall = {Density = 0.3,  Restitution = 0.5},
  SuperBall = {Density = 0.1,  Restitution = 0.95},
  Pillow = {Density = 0.1,  Restitution = 0.2},
  Static = {Density = 0.0,  Restitution = 0.4},
  BasePlatform = {Density = 0.1,  Restitution = 0.5},
  Platform = {Density = 0.1,  Restitution = 0.5},
  Unit = {Density = 0.25, Restitution = 0.00}
}


function Physics2D:CalculateMass(flRadius,sMaterial)
  --[[local mass = 1
  if not sMaterial or not Physics2D.materials[sMaterial] then
    sMaterial = "Unit"
  end


  mass = Physics2D.materials[sMaterial]["Density"] * math.pi * (flRadius * flRadius)
  local inv_mass = 1/mass
  if inv_mass == 0 or IsInf(inv_mass) then inv_mass = 1 end]]
  return 1,1,1
  --return mass, inv_mass, Physics2D.materials[sMaterial]["Restitution"]--,inertia,inv_intertia
end



function Vec(x,y) -- Turns a 2d vector into a 3d one
  if x == 0 and not y then --Vec(0)
    return Vector(0,0,0)
  end
  return Vector(x,y,0)
end


function Physics2D:CalculateVelocity(hUnit)
  -- This should return physics velocity + static velocity
  -- Static velocity is caused by movement and is stored by name so it can be removed
  if Physics2D.items[hUnit] then return Vec() end

  if hUnit.type == "Polygon" then return Vec() end
  if hUnit.GetContainedItem then return Vec() end
  -- Timelocked stuff
  --
  if hUnit.IsTimeLocked and hUnit.IsTimeLocked > GameRules:GetGameTime() then
    hUnit.vOriginalVelocity = hUnit.vOriginalVelocity or hUnit.velocity
    return Vec(0)
  else
    if hUnit.vOriginalVelocity then
      hUnit.velocity = hUnit.vOriginalVelocity
      hUnit.vOriginalVelocity = nil
    end
    hUnit.IsTimeLocked = nil
  end

  if hUnit.IsProjectile then
    if hUnit.IsProjectile == "Tracking" then
      Physics2D:ManageTrackingProjectile(hUnit)
    elseif hUnit.IsProjectile then
      Physics2D:ManageLinearProjectile(hUnit)
    end
  end
  if hUnit.velocity == 0 then hUnit.velocity = Vec() end
  if LengthSquared(hUnit.velocity) < 5*5 then hUnit.velocity = Vec() end
  local vel = hUnit.velocity * 0.99
  vel.z = 0
  return vel
end

function Physics2D:SetPhysicsVelocity(hUnit,vVelocity)
  hUnit.velocity = vVelocity
end

function Physics2D:AddPhysicsVelocity(hUnit,vVelocity)
  hUnit.velocity = hUnit.velocity + vVelocity
end

function Physics2D:ClearPhysicsVelocity(hUnit)
  hUnit.velocity = Vec(0)
end



