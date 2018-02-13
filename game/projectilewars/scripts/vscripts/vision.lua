---@type VisionEnum
BASIC_DAY_VISION = 1540
---@type VisionEnum
BASIC_NIGHT_VISION = 1175

--- Finds units in the radius, in a certain direction
---@param nTeamNumber DOTATeam_t|number
---@param vVector vector
---@param flRadius number
---@param nTargetTeam DOTA_UNIT_TARGET_TEAM|number
---@param nTargetUnit DOTA_UNIT_TARGET_TYPE|number
---@param nFlagFilter DOTA_UNIT_TARGET_FLAGS|number
---@param nSearchOrder LIST_ORDER_TYPE|number
---@param vTestDirection vector
---@param flDotDirection number
---@return table
function FindUnitsInRadiusAndDirection(nTeamNumber,vVector,flRadius,nTargetTeam,nTargetUnit,nFlagFilter,nSearchOrder,vTestDirection,flDotDirection)
  local ents = FindUnitsInRadius(nTeamNumber,vVector,nil,flRadius,nTargetTeam ,nTargetUnit,nFlagFilter,nSearchOrder,false)
  local t = {}
  for k,v in pairs(ents) do
    if v:GetAbsOrigin().z <= vVector.z then
      if vTestDirection:Dot(vVector-v:GetAbsOrigin()) < flDotDirection then
        table.insert(t,k,v)
      end
    end
  end
  return t
end

LinkLuaModifier("modifier_vision_handler","vision.lua",LUA_MODIFIER_MOTION_NONE)
---@class modifier_vision_handler : CDOTA_Modifier_Lua
modifier_vision_handler = class({})

---@override
function modifier_vision_handler:IsHidden() return true end
---@override
function modifier_vision_handler:IsPermanent() return true end

---@param tTableWithUnits table
---@param vVector vector
---@param flRadius number
---@param hCaster CDOTA_BaseNPC
---@return boolean
function modifier_vision_handler:AreNoUnitsInArea(tTableWithUnits,vVector,flRadius,hCaster)

  --flRadius = flRadius * 1.5
  for _,unit in pairs(tTableWithUnits) do

    if not unit.IsInvisible or not unit:IsInvisible() then
      --Add radius from unit

      if unit.radius then flRadius = flRadius + unit.radius end
      local lengthSq = LengthSquared(unit:GetAbsOrigin() - vVector)
      if lengthSq <= flRadius * flRadius then
        -- Chose the position so that it will only clip the end of the unit
        local direction = (hCaster:GetAbsOrigin() - unit:GetAbsOrigin()):Normalized()
        local l = math.sqrt(lengthSq)
        local new_position = unit:GetAbsOrigin() + direction * (l + 0)
        -- Should this unit be revealed?
        if GetGroundHeight(new_position,nil) <= hCaster:GetAbsOrigin().z then
          if not self.unitsRevealed[unit] then
            self.unitsRevealed[unit] = true
            self.fows = self.fows +1
            self.unitfows = self.unitfows +1
            AddFOWViewer(hCaster:GetTeamNumber(),new_position,l  ,5*FrameTime(),true)
            DebugDrawCircle(new_position, Vector(255,255,255), 1, l, false, FrameTime())
          end
        end
        return false
      end
    end
  end
  return true
end


function modifier_vision_handler:CheckState()
  return {
    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
  }
end

---@override
function modifier_vision_handler:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_DISABLE_AUTOATTACK,
  }
end
---@return number
function modifier_vision_handler:GetDisableAutoAttack()
  return 1
end
---@override
function modifier_vision_handler:OnCreated()
  if IsServer() then
    self:StartIntervalThink(FrameTime())
  end
end

---TODO write more comments
---@override
function modifier_vision_handler:OnIntervalThink()
  local caster = self:GetParent()

  local caster_origin = caster:GetAbsOrigin()
  local range = 1500--caster:GetVision()
  local angles = 32
  --local radius = 50
  local vision_angles = 16
  local dot_direction = 0.7
  self.fows = 0
  self.unitfows = 0
  self.unitsRevealed = {}
  local array = {}

  AddFOWViewer(caster:GetTeamNumber(),caster_origin,250,FrameTime(),true)
  local units_in_vision_range = FindUnitsInRadiusAndDirection(caster:GetTeamNumber(),caster_origin,range,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,0,FIND_CLOSEST,caster:GetForwardVector(),dot_direction)

  local trees = GridNav:GetAllTreesAroundPoint(caster_origin,range,true)
  for k,v in pairs(trees) do
    if caster_origin.z >= GetGroundHeight(v:GetAbsOrigin(),nil) then
      if caster:GetForwardVector():Dot((v:GetAbsOrigin()-caster_origin):Normalized()) > dot_direction then
        table.insert(units_in_vision_range,v)
      end
    end
  end
  local nearest = math.huge
  for _,ent in pairs(units_in_vision_range) do
    local lsq = LengthSquared(ent:GetAbsOrigin()-caster_origin)
    if lsq < nearest then
      nearest = lsq
    end
  end

  if nearest < 175*175 then return end

  for i= -2,2 do
    local actually_needed_radius
    local dist = 50
    local radius = 50
    local direction = er
    local pos = caster_origin
    local ents = {}
    local is_vision_blocked_because_height = false
    local blocked = false
    -- Exclude units that are outside this angle scope
    for a,ent in pairs(units_in_vision_range) do
      if LengthSquared(ent:GetAbsOrigin()-caster_origin)  < 250*250 and  direction:Dot((ent:GetAbsOrigin()-caster_origin):Normalized()) > 0.75 and caster ~= ent then blocked = true end
      if direction:Dot((ent:GetAbsOrigin()-caster_origin):Normalized()) > 0.96 then
        table.insert(ents,ent)
      end
    end

    local blocking_unit
    local nearest = math.huge
    for _,ent in pairs(ents) do
      local lsq = LengthSquared(ent:GetAbsOrigin()-caster_origin)
      if lsq < nearest then
        blocking_unit = ent
        nearest = lsq
      end
    end

    if not blocked then

      local distance_to_blocking_unit = range
      if ents[1] then
        distance_to_blocking_unit = math.sqrt(nearest)
      end
      distance_to_blocking_unit = math.min(range,distance_to_blocking_unit)

      --DebugDrawCircle(caster:GetAbsOrigin()+direction *distance_to_blocking_unit, Vector(0,255,0), 1, 50, false, FrameTime())
      -- Make circles till the circle would surpass the entity
      local count = 0
      while dist + (radius*2) < distance_to_blocking_unit - (radius*2) do
        count = count +1
        dist = dist + (radius * 1)
        -- Calculate next radius
        local vision_circle_radius = 2*math.pi*dist
        actually_needed_radius = vision_circle_radius/(360/vision_angles)
        radius = actually_needed_radius
        pos = pos + direction * radius

        if GetGroundHeight(pos,caster) > caster_origin.z +100 then
          is_vision_blocked_because_height = true
          break
        end
        --Give vision and debug stuff
        -- The first rows overlap a lot, save on entities with that
        if count > 7 or count <= 7 and math.fmod(i,2) == 0 and count > 5 then
          if caster:GetPlayerOwnerID() == 0 and IsInToolsMode() then
            --DebugDrawCircle(pos-direction*radius*1, Vector(255,255,255), 1, radius/1.33, false, FrameTime())
          end
          AddFOWViewer(caster:GetTeamNumber(),pos-direction*radius*1,radius/1.33,FrameTime(),true)
        end
      end

      --Cover the distance to the last unit
      if dist < distance_to_blocking_unit and not is_vision_blocked_because_height then
        dist = distance_to_blocking_unit

        local vision_circle_radius = 2*math.pi*dist
        actually_needed_radius = vision_circle_radius/(360/vision_angles)
        local radius_diff = actually_needed_radius - radius
        radius = actually_needed_radius
        pos = caster_origin + direction * (dist-(radius*1.5))
        if caster:GetPlayerOwnerID() == 0 and IsInToolsMode() then
          --DebugDrawCircle(pos, Vector(255,0,0), 1, radius/2, false, FrameTime())
        end
        AddFOWViewer(caster:GetTeamNumber(),pos,radius/2,FrameTime(),true)
        if blocking_unit and not (blocking_unit:GetClassname()  == "ent_dota_tree" or blocking_unit:GetClassname()  == "dota_temp_tree") then
          local p = blocking_unit:GetAbsOrigin() + (caster_origin-blocking_unit:GetAbsOrigin()):Normalized() *100
          if caster:GetPlayerOwnerID() == 0 and IsInToolsMode() then
            --DebugDrawCircle(p, Vector(0,0,255), 1, 50, false, FrameTime())
          end
          AddFOWViewer(caster:GetTeamNumber(),p,25,FrameTime(),true)
        end
      end

    end
    --DebugDrawLine(caster_origin ,(caster_origin + direction * dist),255,255,255,true,FrameTime())
end
  --print(self.fows,self.unitfows)
end

if IsServer() then
  ---@return VisionEnum
  function CDOTA_BaseNPC:GetVision()
    if GameRules:IsDaytime() then
      return BASIC_DAY_VISION
    else
      return BASIC_NIGHT_VISION
    end
  end


  --- Gets influenced by 3 modifier properties,
  --- GetBonusVisionPercentage()
  --- GetBonusDayVisionPercentage()
  --- GetBonusNightVisionPercentage()
  ---@return number
  function CDOTA_BaseNPC:GetBonusVisionPercentage()
    local factor = 1
    for i=0,self:GetModifierCount()-1 do
      local modifier_name = self:GetModifierNameByIndex(i)
      local modifier = self:FindModifierByName(modifier_name)
      if modifier then
        if modifier.GetBonusVision then
          factor = factor + (modifier:GetBonusVisionPercentage() / 100)
        elseif modifier.GetBonusDayVisionPercentage and GameRules:IsDaytime() then
          factor = factor + (modifier:GetBonusDayVisionPercentage() / 100)
        elseif modifier.GetBonusNightVisionPercentage and not GameRules:IsDaytime() then
          factor = factor + (modifier:GetBonusNightVisionPercentage() / 100)
        end
      end
    end
    return factor
  end
end