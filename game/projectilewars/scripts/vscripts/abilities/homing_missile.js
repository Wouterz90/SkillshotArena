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
require("abilities/base_ability");
var homing_missile = /** @class */ (function (_super) {
    __extends(homing_missile, _super);
    function homing_missile() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    homing_missile.prototype.GetProjectileParticleName = function () { return ""; };
    //GetSound() { return "Hero_Gyrocopter.HomingMissile"}
    homing_missile.prototype.OnAbilityPhaseStart = function () {
        var caster = this.GetCaster();
        this.unit = CreateUnitByName("npc_dota_unit_homing_missile", caster.GetAbsOrigin(), true, caster, caster.GetPlayerOwner(), caster.GetTeamNumber());
        this.unit.StartGesture(GameActivity_t.ACT_DOTA_RUN);
        return true;
    };
    homing_missile.prototype.OnAbilityPhaseInterrupted = function () {
        UTIL_Remove(this.unit);
        this.unit = null;
    };
    homing_missile.prototype.OnSpellStart = function () {
        var _this = this;
        var ability = this;
        var caster = this.GetCaster();
        var target = this.GetCursorTarget();
        var unit = this.unit;
        //let unit = CreateUnitByName("npc_dota_unit_homing_missile",caster.GetAbsOrigin(),true,caster,caster.GetPlayerOwner(),caster.GetTeamNumber())
        //unit.StartGesture(GameActivity_t.ACT_DOTA_CAPTURE)
        var projectileTable = {
            hCaster: caster,
            hTarget: target,
            flRadius: this.GetSpecialValueFor("radius"),
            flSpeed: this.GetProjectileSpeed(),
            flTurnRate: 1.5,
            sEffectName: this.GetProjectileParticleName(),
            hUnit: unit,
            UnitBehavior: ProjectileInteractionType.PROJECTILES_DESTROY,
            ProjectileBehavior: ProjectileInteractionType.PROJECTILES_NOTHING,
            WallBehavior: ProjectileInteractionType.PROJECTILES_BOUNCE,
            ItemBehavior: ProjectileInteractionType.PROJECTILES_IGNORE,
            OnProjectileHit: function (myProjectile, otherProjectile) {
                if (!myProjectile.hitByProjectile.indexOf(otherProjectile) && myProjectile.caster.GetTeamNumber() != otherProjectile.caster.GetTeamNumber()) {
                    myProjectile.hitByProjectile.push(otherProjectile);
                    var unit_1 = myProjectile.unit;
                    unit_1.SetHealth(unit_1.GetHealth() - 1);
                    if (unit_1.GetHealth() <= 0) {
                        Physics2D.DestroyProjectile(myProjectile);
                    }
                }
            },
            OnProjectileThink: function (hProjectile, location) {
                if (hProjectile.speed < 5 && !hProjectile.IsTimeLocked) {
                    Physics2D.DestroyProjectile(hProjectile);
                }
                var dir = hProjectile.unit.GetAbsOrigin() - location;
                //hProjectile.unit.SetForwardVector(dir.Normalized())
            },
            // Normal unit test, projectile can hit other units while chasing
            UnitTest: function (hProjectile, hTarget, hCaster) { return _this.UnitTest(hProjectile, hTarget, hCaster); },
            OnUnitHit: function (hProjectile, hTarget, hCaster) {
                ApplyDamage({
                    ability: _this,
                    attacker: hCaster,
                    victim: hTarget,
                    damage: _this.GetAbilityDamage(),
                    damage_type: DAMAGE_TYPES.DAMAGE_TYPE_MAGICAL
                });
            },
            OnFinish: function (projectile) {
                ParticleManager.DestroyParticle(projectile.projParticle, false);
                ParticleManager.ReleaseParticleIndex(projectile.projParticle);
                var particle = ParticleManager.CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_guided_missile_death.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN, caster);
                ParticleManager.SetParticleControl(particle, 0, projectile.location);
                ParticleManager.ReleaseParticleIndex(particle);
                if (!projectile.unit.IsNull()) {
                    UTIL_Remove(projectile.unit);
                }
            }
        };
        var projectile = Physics2D.CreateTrackingProjectile(projectileTable);
        // Particle on unit
        projectile.projParticle = ParticleManager.CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_homing_missile_fuse.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, unit);
        ParticleManager.SetParticleControlEnt(projectile.projParticle, 0, unit, ParticleAttachment_t.PATTACH_POINT_FOLLOW, "attach_hitloc", unit.GetAbsOrigin(), true);
        ParticleManager.SetParticleControlEnt(projectile.projParticle, 1, unit, ParticleAttachment_t.PATTACH_POINT_FOLLOW, "attach_hitloc", unit.GetAbsOrigin(), true);
    };
    return homing_missile;
}(base_ability));
