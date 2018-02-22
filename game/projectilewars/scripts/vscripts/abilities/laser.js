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
LinkLuaModifier("modifier_laser_blind", "abilities/laser.lua", LuaModifierType.LUA_MODIFIER_MOTION_NONE);
var laser = /** @class */ (function (_super) {
    __extends(laser, _super);
    function laser() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    laser.prototype.GetProjectileParticleName = function () { return "particles/abilities/laser/tinker_laser2.vpcf"; };
    laser.prototype.GetProjectileUnitBehavior = function () { return ProjectileInteractionType.PROJECTILES_NOTHING; };
    laser.prototype.GetProjectileProjectileBehavior = function () { return ProjectileInteractionType.PROJECTILES_NOTHING; };
    laser.prototype.GetProjectileWallBehavior = function () { return ProjectileInteractionType.PROJECTILES_BOUNCE; };
    laser.prototype.GetSound = function () { return "Hero_Tinker.Laser"; };
    laser.prototype.GetProjectileControlPoint = function () { return 9; };
    laser.prototype.destroyImmediatly = function () { return true; };
    laser.prototype.OnProjectileHitUnit = function (projectile, target, caster) {
        var duration = this.GetSpecialValueFor("duration");
        target.EmitSound("Hero_Tinker.LaserImpact");
        target.AddNewModifier(caster, this, "modifier_laser_blind", { duration: duration });
    };
    return laser;
}(base_ability));
var modifier_laser_blind = /** @class */ (function (_super) {
    __extends(modifier_laser_blind, _super);
    function modifier_laser_blind() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    modifier_laser_blind.prototype.DeclareFunctions = function () {
        return [
            modifierfunction.MODIFIER_PROPERTY_FIXED_NIGHT_VISION,
            modifierfunction.MODIFIER_PROPERTY_FIXED_DAY_VISION,
        ];
    };
    modifier_laser_blind.prototype.GetFixedDayVision = function () { return this.GetAbility().GetSpecialValueFor("vision_radius"); };
    modifier_laser_blind.prototype.GetFixedNightVision = function () { return this.GetAbility().GetSpecialValueFor("vision_radius"); };
    return modifier_laser_blind;
}(CDOTA_Modifier_Lua));
