-- Was used for fps like controls, plays shit.
--[[
LinkLuaModifier("modifier_control","controls.lua",LUA_MODIFIER_MOTION_NONE)
---@class control

control = class({})


function control:Init()
  if not IsServer() then return end
  for i=0,24 do
    control[i] = {
      Forward = 0,
      MouseLeft = 0,
      Left = 0,
      MouseRight = 0,
      Right = 0,
      Backward = 0,
    }
  end
  CustomGameEventManager:RegisterListener("ButtonPressed",Dynamic_Wrap(control, 'ButtonPressed' ))
end

function control:ButtonPressed(keys)
  local button = keys.button
  local action = keys.pressed
  local PlayerID = keys.PlayerID
  local hero = PlayerResource:GetSelectedHeroEntity(PlayerID)

  if not hero then return end

  control[PlayerID][button] = action

end

---@class modifier_control : CDOTA_Modifier_Lua
modifier_control = class({})

function modifier_control:IsPermanent() return true end
function modifier_control:IsHidden() return true end
function modifier_control:OnCreated()
  if IsServer() then
    self:StartIntervalThink(FrameTime())
  end
end

function modifier_control:OnIntervalThink()
  local hero = self:GetParent()
  local PID = hero:GetPlayerOwnerID()
  local turnrate = hero:GetTurnRate()
  local secondsToTurn180 = (FrameTime() * math.pi) / turnrate
  local degreesPerFrame = secondsToTurn180/180
  local vel = Vec(0,0)

  -- Print shit
  --for k,v in pairs(control[PID]) do print(k,v) end

  local direction = hero:GetForwardVector()

  if (hero:IsStunned() or hero:IsRooted()) then
    hero.velocity = Vec(0,0)
    hero:FaceTowards(hero:GetAbsOrigin()+direction* 1)
    return
  end

    -- Left rotation
  if control[PID]["MouseLeft"] > 0  then
    if not hero:GetCurrentActiveAbility() then
      degreesPerFrame = degreesPerFrame * control[PID]["MouseLeft"] * 450
      direction = RotatePosition(Vector(0,0,0), QAngle(0,degreesPerFrame,0), hero:GetForwardVector())
      --hero:FaceTowards(hero:GetAbsOrigin()+direction* 150)
      control[PID]["WasLeft"] = 1
    end
  elseif control[PID]["WasLeft"] == 1 then
    control[PID]["WasLeft"] = 0
    --hero:Interrupt()
    --hero:MoveToPosition(hero:GetAbsOrigin()+direction)
  end

  -- Right rotation
  if control[PID]["MouseRight"] > 0 then
    if not hero:GetCurrentActiveAbility() then
      degreesPerFrame = degreesPerFrame * control[PID]["MouseRight"]  * 450
      direction = RotatePosition(Vector(0,0,0), QAngle(0,-degreesPerFrame,0), hero:GetForwardVector())
      --hero:FaceTowards(hero:GetAbsOrigin()+direction* 100)
      --hero:FaceTowards(RotatePosition(Vector(0,0,0), QAngle(0,1,0), hero:GetForwardVector()))
      control[PID]["WasRight"] = 1
    end
  elseif control[PID]["WasRight"] == 1 then
    control[PID]["WasRight"] = 0
    --direction = hero:MoveToPosition(hero:GetAbsOrigin()+direction)
    --hero:FaceTowards(hero:GetForwardVector())
  end

  -- Left movement
  if control[PID]["Left"] == 1 then
    --hero:SetAbsOrigin(hero:GetAbsOrigin()+ GetRightPerpendicular(hero:GetForwardVector()*-1) * hero:GetIdealSpeed() *FrameTime() * 0.75)
    local desiredVel = GetRightPerpendicular(hero:GetForwardVector()*-1) * hero:GetIdealSpeed() *FrameTime()
    local trees = GridNav:GetAllTreesAroundPoint(hero:GetAbsOrigin() + desiredVel ,75,false)
    --print(#trees)
    if not trees[1] then
      vel = vel + desiredVel
    else
      local treePos = trees[1]:GetAbsOrigin()
      local n = (hero:GetAbsOrigin()-treePos):Normalized()
      vel = vel + n * hero:GetIdealSpeed() *FrameTime()
    end
  end

  -- Right movement
  if control[PID]["Right"] == 1 then
    --hero:SetAbsOrigin(hero:GetAbsOrigin()+ GetRightPerpendicular(hero:GetForwardVector()) * hero:GetIdealSpeed() *FrameTime() * 0.75)
    local desiredVel = GetRightPerpendicular(hero:GetForwardVector()) * hero:GetIdealSpeed() *FrameTime()
    local trees = GridNav:GetAllTreesAroundPoint(hero:GetAbsOrigin() + desiredVel ,75,false)
    --print(#trees)
    if not trees[1] then
      vel = vel + desiredVel
    else
      local treePos = trees[1]:GetAbsOrigin()
      local n = (hero:GetAbsOrigin()-treePos):Normalized()
      vel = vel + n * hero:GetIdealSpeed() *FrameTime()
    end
  end
  -- Forward movement
  if control[PID]["Forward"] == 1 then
    local desiredVel = hero:GetForwardVector() * hero:GetIdealSpeed() *FrameTime()
    local trees = GridNav:GetAllTreesAroundPoint(hero:GetAbsOrigin() + desiredVel ,75,false)
    if not trees[1] then
      vel = vel + desiredVel
    else
      local treePos = trees[1]:GetAbsOrigin()
      local n = (hero:GetAbsOrigin()-treePos):Normalized()
      vel = vel + n * hero:GetIdealSpeed() *FrameTime()
    end
  end

  -- Backwards movement
  if control[PID]["Backward"] == 1 then
    local desiredVel = -hero:GetForwardVector()
    local trees = GridNav:GetAllTreesAroundPoint(hero:GetAbsOrigin() + desiredVel ,75,false)
    if not trees[1] then
      vel = vel + desiredVel
    else
      local treePos = trees[1]:GetAbsOrigin()
      local n = (hero:GetAbsOrigin()-treePos):Normalized()
      vel = vel + n * hero:GetIdealSpeed() *FrameTime()
    end
  end
  if LengthSquared(vel) > 0.1 then
    hero:StartGesture(ACT_DOTA_RUN)
  else
    hero:RemoveGesture(ACT_DOTA_RUN)
  end
  hero.velocity = vel:Normalized() * hero:GetIdealSpeed() *FrameTime()
  hero:FaceTowards(hero:GetAbsOrigin()+direction* 100)

end

control:Init()]]