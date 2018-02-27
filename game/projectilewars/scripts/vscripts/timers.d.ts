declare interface Timers {
    CreateTimer(delay: number, callback: () => void|number): void;
    CreateTimer<T>(delay: number, callback: (context: T) => void|number, context: T): void;
}
declare const Timers: Timers;