---@override
function modifier_vision_handler:OnIntervalThink()
  local caster = self:GetParent()
  local caster_origin = caster:GetAbsOrigin()
  local range = caster:GetVision()
  local angles = 37.5
  --local radius = 50
  local vision_angles = 15
  local dot_direction = 0.75
  --local array = {}
  self.fows = 0
  self.unitfows = 0
  self.unitsRevealed = {}
  local units_in_vision_range = FindUnitsInRadiusAndDirection(caster:GetTeamNumber(),caster_origin,range,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,0,FIND_CLOSEST,caster:GetForwardVector(),dot_direction)

  local trees = GridNav:GetAllTreesAroundPoint(caster_origin,range,true)
  for k,v in pairs(trees) do
    if caster_origin.z >= GetGroundHeight(v:GetAbsOrigin(),nil) then
      --print(caster:GetForwardVector():Dot((v:GetAbsOrigin()-caster_origin):Normalized()))
      if caster:GetForwardVector():Dot((v:GetAbsOrigin()-caster_origin):Normalized()) > dot_direction then
        table.insert(units_in_vision_range,v)
      end
    end
  end

  local size_factor = 1--caster:GetBonusVisionPercentage()
  --angles = angles * size_factor
  vision_angles = vision_angles * size_factor
  range = range * size_factor


  for i= -angles,angles,angles/2.5 do
    local actually_needed_radius
    local dist = 250 * size_factor
    local radius = 5
    local direction = RotatePosition(Vector(0,0,0), QAngle(0,i,0), caster:GetForwardVector())
    local pos = caster_origin
    local j = 0
    --array[i] = {}
    -- Might need to merge circles, use the array for that
    local ents = {}
    -- Exclude units that are outside this angle scope

    for _,ent in pairs(units_in_vision_range) do
      if direction:Dot((ent:GetAbsOrigin()-caster_origin):Normalized()) > 0.95 then
        table.insert(ents,ent)
      end
    end
    while dist <  range and self:AreNoUnitsInArea(ents,pos,radius*2,caster) do
      dist = dist + radius * 2
      -- The circle should be bigger when further apart
      local vision_circle_radius = 2*math.pi*dist
      actually_needed_radius = vision_circle_radius/(360/vision_angles)
      radius = actually_needed_radius--math.max(radius,actually_needed_radius) /2
      pos = pos + direction * radius
      -- No need to reveal too close

      if j > 0 then
        -- Only do the uneven number when too close

        if (j > 1 or math.fmod(i/vision_angles,2) == 0) or size_factor > 1 then
          if GetGroundHeight(pos,nil) <= caster_origin.z then

            if caster:GetPlayerOwnerID() == 0 then
              DebugDrawCircle(pos, Vector(255,255,255), 1, radius*size_factor, false, FrameTime())
            end
            self.fows = self.fows +1
            AddFOWViewer(caster:GetTeamNumber(),pos,radius*size_factor,1*FrameTime(),true)
            --array[i][j] = {pos =pos,radius = radius}
          end
        end
        print(i/vision_angles)
      elseif size_factor > 1 then

        if math.fmod(i/vision_angles,2) == 0 then
          if GetGroundHeight(pos,nil) <= caster_origin.z then
            DebugDrawCircle(pos, Vector(255,255,255), 1, radius*size_factor, false, FrameTime())
            AddFOWViewer(caster:GetTeamNumber(),pos,radius*size_factor,1*FrameTime(),true)
          end
        end
      end
      j = j+1
      -- Up the distance to get the next point

    end

    DebugDrawLine(caster_origin ,(caster_origin + direction * dist),255,255,255,true,FrameTime())
  end
  --print(self.fows,self.unitfows)
end