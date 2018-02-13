"use strict";
var Vector = /** @class */ (function () {
    function Vector(x, y, z) {
        this.x = x || 0;
        this.y = y || 0;
        this.z = z || 0;
    }
    Vector.prototype.toString = function () {
        return "Vector(" + this.x + ", " + this.y + ", " + this.z + ")";
    };
    Vector.prototype.Length = function () {
        return Math.sqrt(this.x * this.x + this.y * this.y + this.z * this.z);
    };
    Vector.prototype.LengthSquared = function () {
        return this.x * this.x + this.y * this.y + this.z * this.z;
    };
    Vector.prototype.DistanceTo = function (v2) {
        return Math.sqrt((v2.x - this.x) * (v2.x - this.x) + (v2.y - this.y) * (v2.y - this.y) + (v2.z - this.z) * (v2.z - this.z));
    };
    Vector.prototype.Substract = function (v2) {
        return new Vector(this.x - v2.x, this.y - v2.y, this.z - v2.z);
    };
    Vector.prototype.Add = function (v2) {
        return new Vector(this.x + v2.x, this.y + v2.y, this.z + v2.z);
    };
    Vector.prototype.Scale = function (s) {
        return new Vector(this.x * s, this.y * s, this.z * s);
    };
    Vector.prototype.ScaleTo = function (s) {
        var length = this.Length();
        if (length == 0) {
            return new Vector(0, 0, 0);
        }
        else {
            return this.Scale(s / length);
        }
    };
    Vector.prototype.Normalize = function () {
        var length = this.Length();
        return new Vector(this.x / length, this.y / length, this.z / length);
    };
    Vector.prototype.Dot = function (v2) {
        return this.x * v2.x + this.y * v2.y + this.z * v2.z;
    };
    Vector.prototype.Cross = function (v2) {
        return new Vector(this.y * v2.z - this.z * v2.y, this.z * v2.x - this.x * v2.z, this.x * v2.y - this.y * v2.x);
    };
    return Vector;
}());
function ArrayToVector(array) {
    //if (!array) { return new Vector(0, 0, 0);     
    if (array.length == 2) {
        return new Vector(array[0], array[1], 0);
    }
    else if (array.length == 3) {
        return new Vector(array[0], array[1], array[2]);
    }
    else {
        return new Vector(0, 0, 0);
    }
}
function VectorToArray(v) {
    //if (!v == undefined || !v.x) {return [0,0,0];}
    var a = v.x || 0;
    var b = v.y || 0;
    var c = v.z || 0;
    return [a, b, c];
}
