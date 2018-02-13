require('abilities/base_ability')
---@class timelock : base_ability
timelock = class(base_ability)

---@override
function timelock:OnSpellStart()
  local ents = Entities:FindAllInSphere(Vec(0,0),FIND_UNITS_EVERYWHERE)
  local phys = Physics2D.units

  for k,v in pairs(phys) do
    if not ents[v] then
      table.insert(ents,v)
    end
  end

  EmitGlobalSound("Hero_FacelessVoid.Chronosphere")
  for k,v in pairs(ents) do
    if not v.caster or v.caster ~= self:GetCaster() then
      v.IsTimeLocked = GameRules:GetGameTime() + 1.5
      if v.HasModifier and v ~= self:GetCaster() then
        v:AddNewModifier(self:GetCaster(),self,"modifier_faceless_void_timelock_freeze",{duration = 1.5})
      end
    end
  end
  self:ConsumeCharge()
end
