---@return string
function GetRandomTreeModel()
  --return "models/arrows.vmdl"
  return "models/props_tree/dire_tree00"..tostring(RandomInt(2,8)) ..".vmdl"
end

function SpawnRandomTree()
  local location = RandomVector(RandomInt(500,2500))
  --#GridNav:GetAllTreesAroundPoint(location,150,true) > 0 or math.abs(location.x) < 200 or math.abs(location.y) < 200
  while #Entities:FindAllByClassnameWithin("dota_temp_tree",location,200) > 0 do
    location = RandomVector(RandomInt(500,2500))
  end
  CreateTempTree(GetGroundPosition(location,nil),99999)
  --local tree = SpawnEntityFromTableSynchronous("prop_dynamic", {model = GetRandomTreeModel(), DefaultAnim=animation, targetname=DoUniqueString("ent_dota_tree")})
  --tree:SetAbsOrigin(GetGroundPosition(location,nil))
end

function CreateAllTrees()
  if GetMapName() == "forest_solo" then return end
  for i=1,75 do

    SpawnRandomTree()
  end

  for _,tree in pairs(GridNav:GetAllTreesAroundPoint(Vec(),100000,true)) do
    --tree:SetModel(GetRandomTreeModel())
    
    tree:SetModelScale(2)
    --[[if tree:GetAbsOrigin():Length2D() < 550 then
      UTIL_Remove(tree)
    end]]
  end
end

---@param tree CBaseEntity
function CutDownTree(tree)



  if tree:GetClassname() == "ent_dota_tree" then
    tree:CutDown(-1)
    return
  end
  local model = tree:GetModelName()
  local location = tree:GetAbsOrigin()
  local particle = ParticleManager:CreateParticle("particles/world_destruction_fx/dire_tree007_destruction.vpcf",PATTACH_CUSTOMORIGIN,nil)
  ParticleManager:SetParticleControl(particle,0,tree:GetAbsOrigin())
  GridNav:DestroyTreesAroundPoint( tree:GetAbsOrigin(), 1, true )
  -- Stump
  local unit =SpawnEntityFromTableSynchronous("prop_dynamic", {model = "maps/journey_assets/props/trees/journey_armandpine/journey_armandpine_0"..RandomInt(1,3).."_stump.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  unit:SetAbsOrigin(location)

  Timers:CreateTimer(TREE_REGROW_TIME,function()
    UTIL_Remove(unit)
    CreateTempTree(location,99999)
    local trees = GridNav:GetAllTreesAroundPoint(location,1,true)
    trees[1]:SetModel(model)
    trees[1]:SetModelScale(2)
  end)
end

function IsTreeStanding(tree)
  if not tree then print(debug.traceback()) end
  if tree.IsStanding then
    if tree:IsStanding() then
      return true
    else
      return false
    end
  --[[else
    if tree.IsChopped then
      return true
    else
      return false
    end]]
  end
  return true
end