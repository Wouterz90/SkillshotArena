require('abilities/base_ability')
LinkLuaModifier("modifier_void_chronospehere_aura_stop", "abilities/timelock.lua", LUA_MODIFIER_MOTION_NONE)
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
  CreateModifierThinker(self:GetCaster(), self, "modifier_void_chronospehere_aura_stop", {duration = 1.5}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
  --self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_void_chronospehere_aura_stop", {duration = 1.5})
  
  self:ConsumeCharge()
end

modifier_void_chronospehere_aura_stop = class({})

function modifier_void_chronospehere_aura_stop:IsHidden() return true end
function modifier_void_chronospehere_aura_stop:IsPurgable() return false end

function modifier_void_chronospehere_aura_stop:OnCreated()
  if IsServer() then
    local caster = self:GetParent()
    self:StartIntervalThink(FrameTime())
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_chronosphere.vpcf", PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(600, 600, 600))
    self.particle = particle
  end
end

function modifier_void_chronospehere_aura_stop:OnIntervalThink()
  local caster = self:GetParent()
  local ents = Entities:FindAllInSphere(caster:GetAbsOrigin(),600)
  local phys = Physics2D.units

  --ParticleManager:SetParticleControl(self.particle, 0, caster:GetAbsOrigin())
  for k,v in pairs(phys) do
    if not ents[v] then
      table.insert(ents,v)
    end
  end
  for k,v in pairs(ents) do
    if not v.caster or v.caster ~= self:GetCaster() then
      v.IsTimeLocked = GameRules:GetGameTime() + FrameTime() *3
      if v.HasModifier and not (v == self:GetCaster() or v == self:GetParent()) then
        v:AddNewModifier(self:GetCaster(),self,"modifier_faceless_void_timelock_freeze",{duration = FrameTime()*3})
      end
    end
  end
end

function modifier_void_chronospehere_aura_stop:OnDestroy()
  if IsServer() then
    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)
  end
end
