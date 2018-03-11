ITEM_DROP_CHANCE_COMMON = 10
ITEM_DROP_CHANCE_UNCOMMON = 5
ITEM_DROP_CHANCE_RARE = 3
ITEM_DROP_CHANCE_LEGENDARY = 1
ITEM_DROP_CHANCE_TOTAL = ITEM_DROP_CHANCE_COMMON+ITEM_DROP_CHANCE_UNCOMMON+ITEM_DROP_CHANCE_RARE+ITEM_DROP_CHANCE_LEGENDARY 

--- @param sItemName String
--- @param vVector vector
--- @return CDOTA_Item_Physical
function CreatePhysicsItem(sItemName,vVector)
  local item = CreateItem(sItemName,nil,nil)
  vVector = GetGroundPosition(vVector, nil)
  local item_p = CreateItemOnPositionSync(vVector,item)
  item_p:SetContainedItem(item)
  
  
  item_p:SetModelScale(ALLITEMS[sItemName]["modelsize"])
  --UTIL_Remove(item)
  Physics2D:CreateCircle(item_p,35)
  Physics2D.items = Physics2D.items or {}
  table.insert(Physics2D.items,item_p)
  return item_p
end

---@class item_base_item : CDOTA_Item_Lua
item_base_item = class({})
item_base_item.__index = item_base_item
function item_base_item.new(construct, ...)
  --local instance = setmetatable({}, item_base_item)
  --if construct and item_base_item.constructor then item_base_item.constructor(instance, ...) end
  --return instance
  return class(item_base_item)
end

--- @param caster CDOTA_BaseNPC
function item_base_item:OnItemEquip(caster)
  local name = string.sub(self:GetAbilityName(),12)
  local charges = 2 --self:GetSpecialValueFor("charges")
  local max_charges = 5
  local modifier = caster:FindModifierByName("modifier_charges_"..name)
  if modifier then
    modifier:SetStackCount(modifier:GetStackCount()+1)
    modifier:SetStackCount(math.min(modifier:GetStackCount(),max_charges))
  else
    modifier = caster:AddNewModifier(caster,self,"modifier_charges_"..name,{})
    modifier:SetStackCount(math.min(charges,max_charges))
  end

  if not modifier then print("Something went wrong with",name) end
end
LinkLuaModifier("modifier_charges_base_item","items/base_item.lua",LUA_MODIFIER_MOTION_NONE)
---@class modifier_charges_base_item : CDOTA_Modifier_Lua
modifier_charges_base_item = class({})

function modifier_charges_base_item.new(construct, ...)
  local instance = setmetatable({}, modifier_charges_base_item)
  if construct and modifier_charges_base_item.constructor then modifier_charges_base_item.constructor(instance, ...) end
  return class(modifier_charges_base_item)
end
--- Keep alive, destroying is done 10 seconds after with OnFunctionalEnd
---@override
function modifier_charges_base_item:DestroyOnExpire()
  return false
end

function modifier_charges_base_item:RemoveOnDeath() return true end
---@override
function modifier_charges_base_item:OnCreated()
 -- Spell is added via the item added filter, since the item checks are done there anyway
  if IsServer() then
    self:StartIntervalThink(FrameTime())
  end
end
---@override
function modifier_charges_base_item:OnRefresh()
end

---@override
function modifier_charges_base_item:OnIntervalThink()
  if self:GetRemainingTime() > -1 and self:GetRemainingTime() < 0 then
    self:OnFunctionalEnd()
  end
end

---@override
function modifier_charges_base_item:OnDestroy()
  if IsServer() then
    local caster = self:GetParent()
    local name = self:GetName()
    name = string.sub(name,18)
    local ab = caster:FindAbilityByName(name)
    if ab and IsValidEntity(ab) then

      caster:RemoveAbility(name)
    end
  end
end
--- Called when the modifier should be destroyed
function modifier_charges_base_item:OnFunctionalEnd()
  local caster = self:GetParent()
  local name = self:GetName()
  name = string.sub(name,18)
  local ab = caster:FindAbilityByName(name)
  ab:SetActivated(false)
  -- Safely remove it later
  Timers:CreateTimer(6,function()
    if not self:IsNull() then
      if not ab.StopRemove then
        self:Destroy()
      else
        ab:SetActivated(true)
      end
    end
  end)
end
---@override
function modifier_charges_base_item:OnStackCountChanged()
  if IsClient() then return end
  if self:GetStackCount() == 0 then
    self:OnFunctionalEnd()
  end
end
---@override
function modifier_charges_base_item:IsHidden()
  return true
  --return self:GetStackCount() == 0 or (self:GetRemainingTime() > -1 and self:GetRemainingTime() < 0)
end
---@override
function modifier_charges_base_item:IsDebuff() return false end

---@class item_base_rune : CDOTA_Item_Lua
item_base_rune = class({})
item_base_rune.__index = item_base_rune

function item_base_rune.new(construct, ...)
    --local instance = setmetatable({}, item_base_rune)
    --if construct and item_base_rune.constructor then item_base_rune.constructor(instance, ...) end
    --return instance
    return class(item_base_rune)
end

--- @param caster CDOTA_BaseNPC
function item_base_rune:OnItemEquip(caster)
  local name = string.sub(self:GetAbilityName(),11)
  local duration = self:GetSpecialValueFor("duration")
  local modifier = caster:FindModifierByName("modifier_rune_"..name)
  if modifier then
    modifier:SetDuration(modifier:GetRemainingTime()+duration, true)
  else
    modifier = caster:AddNewModifier(caster, self, "modifier_rune_"..name, {duration = duration})
  end
  if not modifier then print("Something went wrong with",name) end
end

ADDED_ITEMS = LoadKeyValues("scripts/kv/item_spells.kv")
ADDED_RUNES = LoadKeyValues("scripts/kv/item_runes.kv")
ALLITEMS = {}
for k,v in pairs(ADDED_ITEMS) do
  ALLITEMS[k] = v
end
for k,v in pairs(ADDED_RUNES) do
  ALLITEMS[k] = v
end

---@param t table
---@return boolean
function ItemAddedFilter(t)

  local item = EntIndexToHScript(t.item_entindex_const)

  local unit = EntIndexToHScript(t.inventory_parent_entindex_const)

  local function RestoreItem() -- Disabled for now because item location fails
    if unit then
      local item_origin = unit:GetAbsOrigin() + unit:GetForwardVector() * 100
      --CreatePhysicsItem(item:GetAbilityName(),item_origin)
    end
  end
  if item:GetAbilityName() == "item_tpscroll" then return false end

  if item:GetAbilityName() == "item_branches" then return true end

  if not item or not unit then  Warning("NO ITEM OR UNIT FOUND IN ITEM FILTER") return false end

  local item_name = item:GetAbilityName() -- item_NAME or rune_NAME
  -- I don't think runes should ever be rejected
  local name = string.sub(item_name,12)
  -- Add active item to the desired slots for that

  if ADDED_RUNES[item_name] then
    item:OnItemEquip(unit)
  end

  if ADDED_ITEMS[item_name] then
    local a = unit:FindAbilityByName(name)
    local ab
    if a and not a:IsConsumable() then return true end
    if not a then
      -- Find empty ability slot for this item
      for i=1,6 do
        a = unit:GetAbilityByIndex(i)

        if not a then
          ab = unit:AddAbility(name)
          ab:SetConsumable(true)
          ab:SetHidden(false)
          ab:SetActivated(true)
          ab:SetLevel(1)
          item:OnItemEquip(unit)
          return true
        end
      end

      if not ab then RestoreItem() return false end

    end
    ab = ab or unit:FindAbilityByName(name)
    -- Reinstate the spell and prevent it from being deleted

    ab.StopRemove = true
    local found = false
    for i=1,6 do
      local a = unit:GetAbilityByIndex(i)

      if a == ab then
        --ab:SetConsumable(true)
        ab:SetHidden(false)
        ab:SetActivated(true)
        ab:SetLevel(1)
        item:OnItemEquip(unit)
        found = true
        return true
      end
    end
    --if found == false then RestoreItem() return false end


    return true
  end

  -- Default to true
  return true
end


