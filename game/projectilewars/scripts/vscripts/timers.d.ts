declare interface timers {
  CreateTimer:(time:number,callback:() => void) => void

}
declare const Timers: timers;

