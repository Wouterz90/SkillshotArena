declare interface PhysicsProjectileTable {
  vSpawnOrigin?: Vec,
  iSourceAttachment?: number,
  flRadius:number,
  vDirection?:Vec,
  hCaster?:CDOTA_BaseNPC,
  hTarget?:CBaseEntity,
  flDuration?:number,
  flSpeed:number,
  flTurnRate:number,
  flAcceleration?:number,
  flMaxDistance?:number,
  sEffectName:string,
  sSoundName?:string,
  hUnit?:CBaseEntity,
  sDestructionEffectName?:string,
  WallBehavior?:ProjectileInteractionType,
  TreeBehavior?:ProjectileInteractionType,
  UnitBehavior?:ProjectileInteractionType,
  ProjectileBehavior?:ProjectileInteractionType,
  ItemBehavior?:ProjectileInteractionType,
  OnWallHit?: (projectile:PhysicsProjectile,wall:CBaseEntity) => void,
  OnItemHit?: (projectile:PhysicsProjectile,item:CDOTA_Item_Physical) => void,
  OnTreeHit?: (projectile:PhysicsProjectile,tree:CDOTA_MapTree,) => void,
  OnUnitHit?: (projectile:PhysicsProjectile,unit:CDOTA_BaseNPC,caster:CDOTA_BaseNPC) => void,
  OnProjectileHit?: (a:PhysicsProjectile,b:PhysicsProjectile) => void,
  UnitTest?: (projectile:PhysicsProjectile,unit:CDOTA_BaseNPC,caster:CDOTA_BaseNPC) => boolean,
  OnProjectileThink?:(projectile:PhysicsProjectile,location:Vec) => void,
  OnFinish?: (projectile:PhysicsProjectile) => void,
  bCantBeStolen?: boolean,
}


/** !CompileMembersOnly */
declare enum ProjectileInteractionType {
  PROJECTILES_IGNORE = 0,
  PROJECTILES_NOTHING = 1,
  PROJECTILES_DESTROY = 2,
  PROJECTILES_BOUNCE = 3,
  PROJECTILES_BOUNCE_OTHER_ONLY = 4,
}

declare class PhysicsProjectile extends PhysicsObject {
  startLoc:Vec;
  direction:Vec;
  caster:CDOTA_BaseNPC;
  creationTime:number;
  duration:number;
  speed:number;
  acceleration:number;
  turnRate:number;
  startRadius:number;
  controlPoint:number;
  maxDistance:number;
  effectName:string;
  soundName:string;
  destructionEffectName:string;
  WallBehavior:ProjectileInteractionType;
  TreeBehavior:ProjectileInteractionType;
  UnitBehavior:ProjectileInteractionType;
  ProjectileBehavior:ProjectileInteractionType;
  ItemBehavior:ProjectileInteractionType;
  OnWallHit: (projectile:PhysicsProjectile,wall:CBaseEntity) => void;
  OnItemHit: (projectile:PhysicsProjectile,item:CDOTA_Item_Physical) => void;
  OnTreeHit: (projectile:PhysicsProjectile,tree:CDOTA_MapTree) => void;
  OnUnitHit: (projectile:PhysicsProjectile,unit:CDOTA_BaseNPC,caster:CDOTA_BaseNPC) => void;
  OnProjectileHit: (a:PhysicsProjectile,b:PhysicsProjectile) => void;
  UnitTest: (projectile:PhysicsProjectile,unit:CDOTA_BaseNPC,caster:CDOTA_BaseNPC) => boolean;
  OnProjectileThink:(projectile:PhysicsProjectile,location:Vec) => void;
  OnFinish: (projectile:PhysicsProjectile) => void;
  bCantBeStolen: boolean;
  location:Vec;
  velocity:Vec;
  distanceTravelled:number;
  hitByProjectile:CBaseEntity[];
  particle:ParticleID;
  maxSpeed:number;
  pos:Vec;
  projParticle:ParticleID
  target:CDOTA_BaseNPC
  trackingUnit:CBaseEntity

}

declare abstract class PhysicsObject extends CBaseEntity{
  caster:CDOTA_BaseNPC
  unit : CBaseEntity
  draw:boolean
  type: "Polygon" | "Circle"
  location:Vec
  velocity:Vec
  IsTimeLocked:boolean
}

declare interface Physics {

  CreateTrackingProjectile(PhysicsProjectileTable): PhysicsProjectile
  CreateLinearProjectile(PhysicsProjectileTable): PhysicsProjectile
  CreatePolygon(middle_location:Vec,edges:Vec[],material:null|string):PhysicsObject
  CreateCircle(middle_location:Vec,radius:number,material:null|string):PhysicsObject
  
  DestroyProjectile(projectile:PhysicsProjectile)

  SetPhysicsVelocity(unit:CBaseEntity,velocity:Vec):void
  AddPhysicsVelocity(unit:CBaseEntity,velocity:Vec):void
  ClearPhysicsVelocity(unit:CBaseEntity):void


}

declare const Physics2D:Physics

declare function LengthSquared(vector:Vec):number
declare function GetRightPerpendicular(vector:Vec):Vec
declare function CreatePhysicsItem(name:string,location:Vec):CDOTA_Item_Physical

declare function StoreSpecialKeyValues(storageobject:CDOTA_Modifier_Lua|CDOTA_Ability_Lua|CDOTA_Item_Lua,getobject?:CDOTA_Modifier_Lua|CDOTA_Ability_Lua|CDOTA_Item_Lua)
declare function CreateProjectileWall(unit:CBaseEntity,edges:Vec[]):ParticleID[]