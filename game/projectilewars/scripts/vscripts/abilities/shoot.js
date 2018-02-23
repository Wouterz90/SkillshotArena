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
var shoot_ = /** @class */ (function (_super) {
    __extends(shoot_, _super);
    function shoot_() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    shoot_.prototype.CastFilterResult = function () {
        if (this.GetCaster().IsDisarmed()) {
            return UnitFilterResult.UF_FAIL_CUSTOM;
        }
        return UnitFilterResult.UF_SUCCESS;
    };
    shoot_.prototype.GetCustomCastError = function () {
        if (this.GetCaster().IsRooted()) {
            return "#Can't attack while rooted.";
        }
    };
    shoot_.prototype.GetProjectileSpeed = function () {
        return 900;
    };
    shoot_.prototype.GetPlaybackRateOverride = function () {
        return 2;
    };
    shoot_.prototype.destroyImmediatly = function () { return false; };
    shoot_.prototype.GetCastRange = function () {
        return this.GetCaster().GetAttackRange() * 1.33;
    };
    shoot_.prototype.GetSound = function () {
        // This doesn't work, sounds file uses attack and Attack
        // This could be done in a table somewhere
        /*
        let a = "Hero_"
        let b = this.GetCaster().GetUnitName().substr(15)
        b = b.substr(1,1).toUpperCase()+b.substr(2)
        let c = ".Attack"*/
        return "Hero_Windrunner.Attack";
    };
    shoot_.prototype.GetProjectileRange = function () {
        return this.GetCaster().GetAttackRange() * 1.33;
    };
    shoot_.prototype.GetProjectileParticleName = function () {
        return this.GetCaster().GetRangedProjectileName();
    };
    shoot_.prototype.GetProjectileUnitBehavior = function () { return ProjectileInteractionType.PROJECTILES_NOTHING; };
    shoot_.prototype.GetProjectileProjectileBehavior = function () { return ProjectileInteractionType.PROJECTILES_NOTHING; };
    shoot_.prototype.GetProjectileWallBehavior = function () { return ProjectileInteractionType.PROJECTILES_BOUNCE; };
    shoot_.prototype.GetProjectileItemBehavior = function () { return ProjectileInteractionType.PROJECTILES_NOTHING; };
    shoot_.prototype.OnProjectileHitUnit = function (projectile, unit, caster) {
        var range = this.GetCaster().GetAttackRange(); //- 150
        var mult = 650 / range;
        mult = 0.5 + mult / 2;
        var damageTable = {
            damage: this.GetSpecialValueFor("damage") * mult,
            victim: unit,
            attacker: this.GetCaster(),
            ability: this,
            damage_type: DAMAGE_TYPES.DAMAGE_TYPE_PHYSICAL
        };
        ApplyDamage(damageTable);
    };
    return shoot_;
}(base_ability));
