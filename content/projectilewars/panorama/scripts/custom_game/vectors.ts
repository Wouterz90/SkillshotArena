class Vector {
  x: number;
  y: number;
  z: number;

  constructor(x:number,y:number,z:number) {
    this.x = x || 0
    this.y = y || 0
    this.z = z || 0
  }

  toString(): string {
    return "Vector(" + this.x + ", " + this.y + ", " + this.z + ")";
  }
  Length(): number {
    return Math.sqrt(this.x * this.x + this.y * this.y + this.z * this.z);
  }
  LengthSquared(): number {
    return this.x * this.x + this.y * this.y + this.z * this.z;
  }
  DistanceTo(v2:Vector): number {
    return Math.sqrt( (v2.x-this.x)*(v2.x-this.x) + (v2.y-this.y)*(v2.y-this.y) + (v2.z-this.z)*(v2.z-this.z) );
  }
  Substract(v2:Vector) {
    return new Vector( this.x - v2.x, this.y - v2.y, this.z - v2.z );
  }
  Add(v2:Vector) {
    return new Vector( this.x + v2.x, this.y + v2.y, this.z + v2.z );
  }
  Scale(s:number) {
    return new Vector( this.x * s, this.y * s, this.z * s );
  }
  ScaleTo(s:number) {
    let length = this.Length();
    if (length == 0){
      return new Vector( 0, 0, 0 ); 
    }
    else {
      return this.Scale( s / length );  
    }
  }
  Normalize() {
    let length = this.Length();
    return new Vector( this.x / length, this.y / length, this.z / length );
  }
  Dot(v2:Vector) {
    return this.x * v2.x + this.y * v2.y + this.z * v2.z;
  }
  Cross(v2:Vector) {
    return new Vector(this.y * v2.z - this.z * v2.y, this.z * v2.x - this.x * v2.z, this.x * v2.y - this.y * v2.x);
  }
}

function ArrayToVector(array:Array<number>):Vector {
  //if (!array) { return new Vector(0, 0, 0);     
  if (array.length == 2) {
    return new Vector( array[0], array[1], 0);
  } else if (array.length == 3) {
    return new Vector( array[0], array[1], array[2]);
  } else {
    return new Vector(0,0,0);
  }
}

function VectorToArray(v:Vector):[number,number,number] {
  //if (!v == undefined || !v.x) {return [0,0,0];}
  let a = v.x || 0
  let b = v.y || 0
  let c = v.z || 0
  return [a,b,c]
}