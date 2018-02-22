"use strict";
var __extends = (this && this.__extends) || (function () {
    var extendStatics = Object.setPrototypeOf ||
        ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
        function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
require('abilities/base_ability');
LinkLuaModifier("modifier_ranged_punch_knockback", "abilities/ranged_punch.lua", LuaModifierType.LUA_MODIFIER_MOTION_NONE);
var ranged_punch = /** @class */ (function (_super) {
    __extends(ranged_punch, _super);
    function ranged_punch() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    ranged_punch.prototype.GetProjectileParticleName = function () { return ""; };
    ranged_punch.prototype.GetSound = function () { return "Hero_Pudge.AttackHookExtend"; };
    ranged_punch.prototype.HitsItems = function () { return true; };
    ranged_punch.prototype.GetProjectileProjectileBehavior = function () { return ProjectileInteractionType.PROJECTILES_BOUNCE_OTHER_ONLY; };
    ranged_punch.prototype.GetProjectileUnitBehavior = function () { return ProjectileInteractionType.PROJECTILES_NOTHING; };
    ranged_punch.prototype.GetProjectileItemBehavior = function () { return ProjectileInteractionType.PROJECTILES_NOTHING; };
    ranged_punch.prototype.GetProjectileWallBehavior = function () { return ProjectileInteractionType.PROJECTILES_DESTROY; };
    ranged_punch.prototype.OnSpellStarted = function () {
        var caster = this.GetCaster();
        var point = this.GetCursorPosition();
        var direction = point - caster.GetAbsOrigin();
        direction = direction.Normalized();
        this.end_position = caster.GetAbsOrigin() + direction * this.range;
        this.particle = ParticleManager.CreateParticle("particles/abilities/punch/ranged_punch.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, null);
        ParticleManager.SetParticleAlwaysSimulate(this.particle);
        ParticleManager.SetParticleControlEnt(this.particle, 0, this.GetCaster(), ParticleAttachment_t.PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", caster.GetAbsOrigin(), true);
        ParticleManager.SetParticleControl(this.particle, 1, this.end_position);
        ParticleManager.SetParticleControl(this.particle, 2, Vector(this.projectile_speed, 0, 0));
        ParticleManager.SetParticleControl(this.particle, 3, Vector(100, 0, 0));
        ParticleManager.SetParticleControl(this.particle, 4, Vector(1, 0, 0));
        ParticleManager.SetParticleControl(this.particle, 5, Vector(0, 0, 0));
        ParticleManager.SetParticleControlEnt(this.particle, 7, caster, ParticleAttachment_t.PATTACH_CUSTOMORIGIN, null, caster.GetAbsOrigin(), true);
        this.projectile.projParticle = this.particle;
    };
    ranged_punch.prototype.OnProjectileThink = function (projectile, location) {
        ParticleManager.SetParticleControl(projectile.projParticle, 2, Vector(this.projectile.velocity.Length2D() / FrameTime(), 0, 0));
    };
    ranged_punch.prototype.OnProjectileHitItem = function (hProjectile, hItem) {
        this.OnProjectileHitUnit(hProjectile, hItem, hProjectile.caster);
    };
    ranged_punch.prototype.OnProjectileHitUnit = function (hProjectile, hTarget, hCaster) {
        // Check if the desired push direction is the same as the projectile direction
        var direction = hTarget.GetAbsOrigin() - hProjectile.location;
        direction = direction.Normalized();
        var projectile_direction = hProjectile.direction;
        if (direction.Dot(projectile_direction) < 0) {
            return null;
        }
        if (hTarget.IsNPC()) {
            hTarget.AddNewModifier(hCaster, this, "modifier_ranged_punch_knockback", {});
        }
        hCaster.EmitSound("");
        // Create a new projectile managing the unit's knockback
        var projectile_table = {
            vDirection: direction,
            flMaxDistance: this.GetSpecialValueFor("knockback_distance"),
            hCaster: hCaster,
            vSpawnOrigin: hTarget.GetAbsOrigin(),
            flSpeed: this.GetProjectileSpeed(),
            flRadius: 5,
            sEffectName: "",
            WallBehavior: ProjectileInteractionType.PROJECTILES_BOUNCE,
            OnProjectileThink: function (projectile, projectile_location) {
                var target = projectile.trackingUnit;
                if (target && !target.IsNull()) {
                    if (target.motion == projectile) {
                        target.SetAbsOrigin(projectile.location);
                    }
                }
            },
            OnFinish: function (projectile) {
                var target = projectile.trackingUnit;
                GridNav.DestroyTreesAroundPoint(target.GetAbsOrigin(), 50, true);
            }
        };
        var projectile = Physics2D.CreateLinearProjectile(projectile_table);
        projectile.trackingUnit = hTarget;
        hTarget.motion = projectile;
        // Particle on impact
        /*let nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf", PATTACH_CUSTOMORIGIN, hTarget)
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), true )
        ParticleManager:ReleaseParticleIndex( nFXIndex )*/
    };
    ranged_punch.prototype.OnProjectileFinish = function (hProjectile) {
        var _this = this;
        var caster = this.GetCaster();
        var origin = hProjectile.GetAbsOrigin();
        var projParticle = hProjectile.projParticle;
        var target = hProjectile.target;
        var projectile_table = {
            hTarget: caster,
            hCaster: caster,
            vSpawnOrigin: origin,
            flSpeed: this.GetProjectileSpeed(),
            flRadius: this.GetSpecialValueFor("radius"),
            sEffectName: "",
            ProjectileBehavior: ProjectileInteractionType.PROJECTILES_NOTHING,
            UnitBehavior: ProjectileInteractionType.PROJECTILES_NOTHING,
            ItemBehavior: ProjectileInteractionType.PROJECTILES_NOTHING,
            UnitTest: function (projectile, unit, caster) {
                return _this.UnitTest(projectile, unit, caster);
            },
            OnUnitHit: function (projectile, unit, caster) {
                if (unit == caster) {
                    if (target) {
                        _this.BallReturned(projectile, target);
                        target.motion = null;
                    }
                    _this.BallReturned(projectile);
                }
                else {
                    _this.OnProjectileHitUnit(projectile, unit, caster);
                }
            },
            OnProjectileThink: function (projectile, projectile_location) {
                if (target && !target.IsNull()) {
                    if (target.motion == projectile) {
                        target.SetAbsOrigin(projectile.location);
                    }
                    else {
                        if (target.IsNPC()) {
                            target.RemoveModifierByName("modifier_ranged_punch_knockback");
                        }
                    }
                }
            }
        };
        this.projectile = Physics2D.CreateTrackingProjectile(projectile_table);
        this.projectile.projParticle = projParticle;
        if (target) {
            target.motion = this.projectile;
        }
        ParticleManager.SetParticleControlEnt(this.projectile.projParticle, 1, this.GetCaster(), ParticleAttachment_t.PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", this.GetCaster().GetAbsOrigin(), true);
        //this.GetCaster():StopSound("Hero_Pudge.AttackHookExtend")
        //this.GetCaster():EmitSound("Hero_Pudge.ability")
    };
    ranged_punch.prototype.BallReturned = function (projectile, hTarget) {
        var caster = this.GetCaster();
        if (hTarget && hTarget.AddNewModifier) {
            hTarget.RemoveModifierByName("modifier_hook_motion");
        }
        ParticleManager.DestroyParticle(projectile.projParticle, false);
        ParticleManager.ReleaseParticleIndex(projectile.projParticle);
        //this:GetCaster().StopSound( "Hero_Pudge.AttackHookRetract")
        //this:GetCaster().EmitSound( "Hero_Pudge.AttackHookRetractStop")
    };
    return ranged_punch;
}(base_ability));
var modifier_ranged_punch_knockback = /** @class */ (function (_super) {
    __extends(modifier_ranged_punch_knockback, _super);
    function modifier_ranged_punch_knockback() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    modifier_ranged_punch_knockback.prototype.DeclareFunctions = function () {
        return [
            modifierfunction.MODIFIER_PROPERTY_OVERRIDE_ANIMATION
        ];
    };
    modifier_ranged_punch_knockback.prototype.GetOverrideAnimation = function () {
        return GameActivity_t.ACT_DOTA_FLAIL;
    };
    modifier_ranged_punch_knockback.prototype.CheckState = function () {
        return _a = {},
            _a[modifierstate.MODIFIER_STATE_STUNNED] = true,
            _a;
        var _a;
    };
    return modifier_ranged_punch_knockback;
}(CDOTA_Modifier_Lua));
