--- @param vector Vvector
--- @return number
function LengthSquared(vVector)
  return vVector.x * vVector.x + vVector.y * vVector.y
end

function CrossProduct(a,b)
  if type(a) ~= "number" and type(b) ~= "number" then
    return (a.x * b.z - a.y * b.x)
  elseif type(a) ~= "number" then
    return Vec(b * a.y,-b*a.x)
  elseif type(b) ~= "number" then
    return Vec(-a * b.y,a*b.x)
  end
  print("Error! No Vector argument in CrossProduct!")
end


--- Get the right perpendicular vector
--- @param vVector vector
--- @return vector
function GetRightPerpendicular(vVector)
  return Vec(vVector.y,-vVector.x)
end

--- Get the left perpendicular vector
--- @param vVector vector
--- @return vector
function GetLeftPerpendicular(vVector)
  return Vec(vVector.y,vVector.x)
end

--- @param vStartPosition vector
--- @param vTargetPosition vector
--- @param hProjectile table
--- @return boolean
function Physics2D:IsLineUnobstructed(vStartPosition,vTargetPosition,hProjectile)
  -- TODO
  -- Create a lot of circle along the line??
end


--- @param flMaxRange number search range
--- @param vSearchLocation vector
--- @param nOwnerTeam number
--- @param bEnemy boolean
--- @return table
function Physics2D:GetNearestPhysicsUnit(flMaxRange,vSearchLocation,nOwnerTeam,bEnemy)
  local closest
  local range = 1
  for _,unit in pairs(Physics2D.units) do
    local b = unit:GetTeamNumber() == nOwnerTeam
    if not bEnemy then b = not b end
    if unit.IsSmashUnit and unit.HasModifier and not unit:IsNull() and unit:IsAlive() and b then
      local distSq = LengthSquared(vSearchLocation-unit.location)
      if flMaxRange * flMaxRange >= distSq then
        if range >= distSq then
          closest = unit
          range = distSq
        end
      end
    end
  end
  return closest
end

--- @param flMaxRange number search range
--- @param vSearchLocation vector
--- @param nOwnerTeam number
--- @param bEnemy boolean
--- @return table
function Physics2D:GetPhysicsUnitsInRange(flMaxRange,vSearchLocation,bIncludeProjectiles)
  local units = {}
  for _,unit in pairs(Physics2D.units) do
    if not unit:IsNull() then

      local b = false
      if unit.IsProjectile then b = true end
      if b == bIncludeProjectiles then
        if not unit.IsAlive or unit:IsAlive() then --unit.HasModifier and
          local distSq = LengthSquared(vSearchLocation-unit.location)
          if flMaxRange * flMaxRange >= distSq then
            table.insert(units,unit)
          end
        end
      end
    end
  end
  return units
end

--- @param hCaster table
--- @param flDot number
--- @param vBaseDirection vector
--- @param tUnits table
--- @return table
function Physics2D:GetUnitsInDirection(hCaster,flDot,vBaseDirection,tUnits)
  local units = {}
  for _,unit in pairs(tUnits) do
    if math.abs((hCaster.location-unit.location):Normalized():Dot(vBaseDirection)) > flDot then
      table.insert(units,unit)
    end
  end
  return units
end

function Physics2D:IsUnitInDirection(hCaster,flDot,vBaseDirection,hUnit)
  if math.abs((hCaster.location-hUnit.location):Normalized():Dot(vBaseDirection)) > flDot then
    return true
  end
  return false
end

function Physics2D:RemoveAllPhysicsObjects()
  for _,unit in pairs(Physics2D.units) do
    if not unit:IsNull() then
      UTIL_Remove(unit)
    end
  end
end

--- Get the closest distance from a line to a point
--- @param a vector edge
--- @param b vector edge
--- @param p vector point
function GetClosestDistanceFromLinetoPoint(a,b,p)
  local n = b-a
  local pa = a-p
  local c = n:Dot(p)
  -- Check if closest point is a
  if c > 0 then
    return pa:Dot(pa)
  end
  -- Check if closest point is b
  local bp = p-b
  if n:Dot(bp) > 0 then
    return bp:Dot(bp)
  end
  -- Closest point is between a and b
  local e = pa- n * (c/ n:Dot(n))
  return e:Dot(e)
end

function Physics2D:IsPhysicsUnit(hUnit)
  return Physics2D.units[hUnit]
end

-- Util functions
function math.clamp(min,max,number)
  if number > max then return max end
  if number < min then return min end
  return number
end

function IsNaN(value)
  return value ~= value
end

function IsInf(value)
  return value == math.huge or value == -math.huge
end



function RemoveNullFromTable(tab)
  for i=#tab,1,-1 do
    -- Remove weird positioned stuff first
    if tab[i].location and math.abs(tab[i].location.x) > 10000 or math.abs(tab[i].location.z) > 5000 then
      UTIL_Remove(tab[i])
    end
    if tab[i].RemoveProjectile then
      if IsValidEntity(tab[i]) then
        UTIL_Remove(tab[i])
      end
    end
    if tab[i]:IsNull() then
      table.remove(tab, i)
    end
  end
end

---@param a Vector
---@param b Vector
---@param p Vector
---@return number
function GetSquareDistanceFromPointToLine(a,b,p)
  if not a or not b or not p then print(debug.traceback()) end
  local n = b - a
  local pa = a - p
  local c = n:Dot(pa)
  -- Closest point is a
  if c > 0 then
    return pa:Dot(pa)
  end

  local bp = p - b
  -- Closest point is b
  if n:Dot(bp ) > 0 then
    return bp:Dot(bp)
  end

  -- Closest point is between a and b
  local e = pa-n*(c/(n:Dot(n)))

  return e:Dot(e)
end

function Physics2D:IsPointLeftFromLine(a,b,p)
  -- Determine on what side of the projectile direction line the hero is
  local side = (b.x-a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x)
  if side == 0 then
    return false -- Never happens
  elseif side > 0 then
    -- Left ( a -> b)
    return true
  else
    -- Right ( a -> b)
    return false
  end
end