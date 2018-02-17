require('abilities/base_ability')
---@class hook : base_ability
hook = class(base_ability)
---@override
function hook:GetProjectileProjectileBehavior() return PROJECTILES_IGNORE end
---@override
function hook:GetProjectileParticleName() return "" end
---@override
function hook:GetSound() return "Hero_Pudge.AttackHookExtend" end
---@override
function hook:HitsItems() return true end
---@override
function hook:GetProjectileUnitBehavior() return PROJECTILES_DESTROY end
---@override
function hook:GetProjectileItemBehavior() return PROJECTILES_DESTROY end
---@override
function hook:GetProjectileWallBehavior() return PROJECTILES_DESTROY end
---@override
function hook:OnOwnerSpawned()
  self:SetLevel(1)
end
---@override
function hook:OnSpellStarted()
  local caster = self:GetCaster()
  local point = self:GetCursorPosition()
  local direction = (point-caster:GetAbsOrigin()):Normalized()


  -- Remove weapon
  local hHook = caster:GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
  if hHook ~= nil then
    hHook:AddEffects( EF_NODRAW )
  end
  --particles/abilities/punch/ranged_punch.vpcf
  --particles/abilities/hook/pudge_meathook.vpcf
  self.end_position = caster:GetAbsOrigin() + direction * self.range
  self.particle = ParticleManager:CreateParticle( "particles/abilities/hook/pudge_meathook.vpcf", PATTACH_CUSTOMORIGIN, nil)
  ParticleManager:SetParticleAlwaysSimulate( self.particle)
  ParticleManager:SetParticleControlEnt( self.particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", caster:GetAbsOrigin(), true )
  ParticleManager:SetParticleControl( self.particle, 1, self.end_position  )
  ParticleManager:SetParticleControl( self.particle, 2, Vector( self.projectile_speed , 0, 0 ) )
  ParticleManager:SetParticleControl( self.particle, 3, Vector(100,0,0) )
  ParticleManager:SetParticleControl( self.particle, 4, Vector( 1, 0, 0 ) )
  ParticleManager:SetParticleControl( self.particle, 5, Vector( 0, 0, 0 ) )
  ParticleManager:SetParticleControlEnt( self.particle, 7, caster, PATTACH_CUSTOMORIGIN, nil, caster:GetAbsOrigin(), true )
  -- Store it in the projectile for multishot
  self.projectile.projParticle = self.particle
end
function hook:OnProjectileThink(projectile,location)

  ParticleManager:SetParticleControl( projectile.projParticle, 2, Vector( self.projectile.velocity:Length2D() /FrameTime() , 0, 0 ) )
end

---@override
function hook:OnProjectileHitItem(hProjectile, hItem)
  self:OnProjectileHitUnit(hProjectile,hItem,hProjectile)
  Physics2D:DestroyProjectile(hProjectile)

end

---@override
function hook:OnProjectileHitUnit(hProjectile,hTarget,hCaster)

  hCaster:EmitSound("Hero_Pudge.AttackHookImpact")
  -- Stun the unit, and move it back to the hero

  hTarget.motion = hProjectile

  if hTarget.AddNewModifier then
    hTarget:AddNewModifier(hCaster,self,"modifier_hook_motion",{})

  end
  hProjectile.target = hTarget
  -- Update the particles
  ParticleManager:SetParticleControlEnt( hProjectile.projParticle, 1, hCaster, PATTACH_POINT_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), true )
  ParticleManager:SetParticleControl( hProjectile.projParticle, 4, Vector( 0, 0, 0 ) )
  ParticleManager:SetParticleControl( hProjectile.projParticle, 5, Vector( 1, 0, 0 ) )

  local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf", PATTACH_CUSTOMORIGIN, hTarget)
  ParticleManager:SetParticleControlEnt( nFXIndex, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), true )
  ParticleManager:ReleaseParticleIndex( nFXIndex )

end
---@override
function hook:OnProjectileFinish(hProjectile)
  local caster = self:GetCaster()
  local origin = hProjectile:GetAbsOrigin()
  local projParticle = hProjectile.projParticle
  local target = hProjectile.target

  -- Launch an invisible projectile back to control the particle and the unit
  local projectile_table = {
    hTarget = caster,
    hCaster = caster,
    vSpawnOrigin = origin,
    flSpeed = self:GetProjectileSpeed() ,
    flRadius = 20,
    sEffectName = "",
    ProjectileBehavior = PROJECTILES_NOTHING,
    UnitBehavior = PROJECTILES_DESTROY,
    ItemBehavior = PROJECTILES_NOTHING,
    UnitTest = function(projectile, unit,caster)
      return caster == unit
    end,
    OnUnitHit = function(projectile,unit,caster)
      if target then
        self:HookReturned(projectile,target)
        target.motion = nil
      end
      self:HookReturned(projectile)

    end,
    OnProjectileThink = function(projectile,projectile_location)
      if target and not target:IsNull() then
        if target.motion == projectile then
          target:SetAbsOrigin(projectile.location)
        end
      end
    end,
  }

  self.projectile = Physics2D:CreateTrackingProjectile(projectile_table)
  self.projectile.projParticle = projParticle
  if target then
    target.motion = self.projectile
  end
  ParticleManager:SetParticleControlEnt( self.projectile.projParticle, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetAbsOrigin(), true);
  CreateModifierThinker(caster,self,"modifier_hook_motion",{},hProjectile:GetAbsOrigin(),self:GetCaster():GetTeamNumber(),false)
  self:GetCaster():StopSound("Hero_Pudge.AttackHookExtend")
  self:GetCaster():EmitSound("Hero_Pudge.ability")
end

---@param hTarget CDOTA_BaseNPC
function hook:HookReturned(projectile,hTarget)
  local caster = self:GetCaster()
  local hHook = caster:GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
  if hHook ~= nil then
    hHook:RemoveEffects( EF_NODRAW )
  end
  if hTarget and hTarget.AddNewModifier then
    hTarget:RemoveModifierByName("modifier_hook_motion")
  end
  ParticleManager:DestroyParticle(projectile.projParticle,false)
  ParticleManager:ReleaseParticleIndex(projectile.projParticle)
  self:GetCaster():StopSound( "Hero_Pudge.AttackHookRetract")
  self:GetCaster():EmitSound( "Hero_Pudge.AttackHookRetractStop")
end

LinkLuaModifier("modifier_hook_motion","abilities/hook.lua",LUA_MODIFIER_MOTION_NONE)
---@class modifier_hook_motion : CDOTA_Modifier_Lua
modifier_hook_motion = {}

function modifier_hook_motion:OnCreated()
  if IsServer() then
    local ability = self:GetAbility()
    self.projectile_speed = ability.projectile_speed
    self:StartIntervalThink(FrameTime())
  end
end

function modifier_hook_motion:OnIntervalThink()
  local parent = self:GetParent()
  local caster = self:GetCaster()
  local ability = self:GetAbility()
  if not ability then self:Destroy() return end
  if not ability.projectile then self:Destroy() return end
  -- Destroy when this is not the motion controller
  --if parent.motion ~= ability then self:Destroy() return end
  --parent.velocity = 0

  --parent:SetAbsOrigin(ability.projectile.location)
  AddFOWViewer(caster:GetTeamNumber(),ability.projectile.location,20,FrameTime(),false)

end

function modifier_hook_motion:OnDestroy()
  if IsServer() then
    --self:GetAbility():HookReturned()
  end
end
---@return table
function modifier_hook_motion:CheckState()
  -- Only stun serverside so no "STUNNED" bar
  if IsServer() then
    --local team = (parent:GetTeamNumber() ~= caster:GetTeamNumber())
    -- Stun allies too
    return {
      [MODIFIER_STATE_STUNNED] = true,
      [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
  end
end

---@return table
function modifier_hook_motion:DeclareFunctions()
  return {MODIFIER_PROPERTY_PROVIDES_FOW_POSITION}
end
---@return number
function modifier_hook_motion:GetModifierProvidesFOWVision()
  return 1
end
