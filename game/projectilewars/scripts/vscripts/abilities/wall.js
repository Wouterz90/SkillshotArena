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
var wall = /** @class */ (function (_super) {
    __extends(wall, _super);
    function wall() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    wall.prototype.OnSpellStart = function () {
        var caster = this.GetCaster();
        var origin = caster.GetAbsOrigin();
        var point = caster.GetCursorPosition();
        var forward = caster.GetForwardVector();
        //let forward =point-origin
        //forward = forward.Normalized()  
        var right = GetRightPerpendicular(forward);
        var pos = origin + forward * 200;
        var locs = [right * 200, -right * 200];
        //let wall = Physics2D.CreatePolygon(pos,locs,null)
        var wall = Physics2D.CreatePolygon(Vector(0, 0, 0), locs, null);
        wall.caster = caster;
        for (var i = 0; i < locs.length; i++) {
            locs[i] = locs[i] + pos;
        }
        var wallParticles = CreateProjectileWall(wall, locs);
        this.ConsumeCharge();
        Timers.CreateTimer(5, function () {
            if (wall && !wall.IsNull()) {
                if (wallParticles) {
                    for (var _i = 0, wallParticles_1 = wallParticles; _i < wallParticles_1.length; _i++) {
                        var p = wallParticles_1[_i];
                        ParticleManager.DestroyParticle(p, true);
                        ParticleManager.ReleaseParticleIndex(p);
                    }
                }
                UTIL_Remove(wall);
            }
        });
    };
    return wall;
}(base_ability));
