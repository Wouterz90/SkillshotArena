require('abilities/base_ability')
---@class stab : base_ability
stab = class(base_ability)

---@override
function stab:CastFilterResult()
  if self:GetCaster():IsDisarmed() then
    return UF_FAIL_CUSTOM
  end
  return UF_SUCCESS
end

---@override
function stab:GetCustomCastError()
  if self:GetCaster():IsRooted() then
    return "#Can't stab while rooted."
  end
end

---@override
function stab:GetPlaybackRateOverride()
  return 2
end

---@override
function stab:GetCastRange()
  return 5000
end

---@override
function stab:OnSpellStart()
  -- Hit the first UNIT in a half circle around you
  local caster = self:GetCaster()
  local caster_origin = caster:GetAbsOrigin()
  local caster_forward = caster:GetForwardVector()
  local range = self:GetProjectileRange()

  caster:EmitSound("Hero_PhantomAssassin.Attack")

  local units = FindUnitsInRadius(caster:GetTeamNumber(),caster_origin,nil,range,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,DOTA_DAMAGE_FLAG_NONE,FIND_CLOSEST,false)
  for _,unit in pairs(units) do
    local unit_origin = unit:GetAbsOrigin()
    if caster_forward:Dot((unit_origin-caster_origin):Normalized()) > 0.5 or (unit:GetRangeToUnit(caster) < 100 and caster_forward:Dot((unit_origin-caster_origin):Normalized()) > 0 ) then
      local damageTable = {
        damage = self:GetSpecialValueFor("damage"),
        victim = unit,
        attacker = caster,
        ability = self,
        damage_type = DAMAGE_TYPE_PURE,
      }
      ApplyDamage(damageTable)

      -- Play hit sound
      caster:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
      -- Show hit particle
      local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, caster)
      ParticleManager:SetParticleControlEnt(particle, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit_origin, true)
      ParticleManager:SetParticleControlEnt(particle, 1, unit, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", unit_origin, true)
      ParticleManager:ReleaseParticleIndex(particle)
      return
    end
  end
  -- Play miss sound
  SendOverheadEventMessage(nil,OVERHEAD_ALERT_MISS,caster,1,nil)
  caster:EmitSound("Hero_KeeperOfTheLight.Recall.Fail")
end
