function StoreSpecialKeyValues(object,ability)
  if not ABILITIES_TXT then
    ABILITIES_TXT = LoadKeyValues("scripts/npc/npc_abilities.txt")
    --for k,v in pairs(LoadKeyValues("scripts/npc/npc_abilities_override.txt")) do ABILITIES_TXT[k] = v end
    for k,v in pairs(LoadKeyValues("scripts/npc/npc_abilities_custom.txt")) do ABILITIES_TXT[k] = v end
  end


  if not ability then ability = object end
  if not ability.GetName then Warning("StoreSpecialKeyValues called with nil ability") return end
  if not ABILITIES_TXT[ability:GetName()] then Warning("StoreSpecialKeyValues called but"..ability:GetName().." not found") return end
  if not ABILITIES_TXT[ability:GetName()]["AbilitySpecial"] then Warning("StoreSpecialKeyValues called but"..ability:GetName().." has no special values") return end
  for k,v in pairs(ABILITIES_TXT[ability:GetName()]["AbilitySpecial"]) do
    for K,V in pairs(v) do
      if K ~= "var_type" and K ~= "LinkedSpecialBonus" then
        local array = StringToArray(V)
        object[tostring(K)] = tonumber(array[ability:GetLevel()]) or tonumber(array[#array])
      end
    end
  end
end

function StringToArray(inputString, seperator)
  if not seperator then seperator = " " end
  local array={}
  local i=1

  for str in string.gmatch(inputString, "([^"..seperator.."]+)") do
    array[i] = str
    i = i + 1
  end
  return array
end
