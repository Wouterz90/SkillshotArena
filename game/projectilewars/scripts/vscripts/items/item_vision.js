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
require('items/base_item');
var item_rune_vision = /** @class */ (function (_super) {
    __extends(item_rune_vision, _super);
    function item_rune_vision() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    return item_rune_vision;
}(item_base_rune));
LinkLuaModifier("modifier_rune_vision", "items/item_vision.lua", LuaModifierType.LUA_MODIFIER_MOTION_NONE);
var modifier_rune_vision = /** @class */ (function (_super) {
    __extends(modifier_rune_vision, _super);
    function modifier_rune_vision() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    modifier_rune_vision.prototype.DeclareFunctions = function () {
        return [
            modifierfunction.MODIFIER_PROPERTY_BONUS_DAY_VISION,
            modifierfunction.MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
        ];
    };
    modifier_rune_vision.prototype.OnCreated = function () {
        this.vision = this.GetAbility().GetSpecialValueFor("bonus_vision");
    };
    modifier_rune_vision.prototype.GetBonusDayVision = function () {
        return this.vision;
    };
    modifier_rune_vision.prototype.GetBonusNightVision = function () {
        return this.vision;
    };
    return modifier_rune_vision;
}(CDOTA_Modifier_Lua));
