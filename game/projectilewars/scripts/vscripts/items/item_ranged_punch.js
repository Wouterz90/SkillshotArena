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
LinkLuaModifier("modifier_charges_ranged_punch", "items/item_ranged_punch.lua", LuaModifierType.LUA_MODIFIER_MOTION_NONE);
var item_spell_ranged_punch = /** @class */ (function (_super) {
    __extends(item_spell_ranged_punch, _super);
    function item_spell_ranged_punch() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    return item_spell_ranged_punch;
}(item_base_item));
var modifier_charges_ranged_punch = /** @class */ (function (_super) {
    __extends(modifier_charges_ranged_punch, _super);
    function modifier_charges_ranged_punch() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    return modifier_charges_ranged_punch;
}(modifier_charges_base_item));
