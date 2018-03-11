"use strict";
var points = [];
function VectorTargetStart(ability) {
    var startingPoint = GameUI.GetScreenWorldPosition(GameUI.GetCursorPosition());
    var vectorParticle = Particles.CreateParticle("particles/ui_mouseactions/range_finder_cone.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN, Abilities.GetCaster(ability));
    Particles.SetParticleControl(vectorParticle, 1, startingPoint);
    Particles.SetParticleControl(vectorParticle, 3, [125, 125, 0]);
    Particles.SetParticleControl(vectorParticle, 4, [0, 255, 0]);
    VectorTargetLoop(ability, vectorParticle, true, GameUI.GetScreenWorldPosition(GameUI.GetCursorPosition()), GameUI.IsMouseDown(0));
}
function VectorTargetLoop(ability, particle, goNext, startingPoint, wasMouseDown) {
    if (!goNext) {
        // Fire ability
        $.Msg("Firing ability");
        Particles.DestroyParticleEffect(particle, true);
        Particles.ReleaseParticleIndex(particle);
        GameEvents.SendCustomGameEventToServer("VectorTargettedAbilityCastFinished", { abilityIndex: ability, startPos: startingPoint, endPos: GameUI.GetScreenWorldPosition(GameUI.GetCursorPosition()), allPoints: points });
        points = [];
    }
    else {
        $.Schedule(0.01, function () { return VectorTargetLoop(ability, particle, goNext, startingPoint, wasMouseDown); });
        Particles.SetParticleControl(particle, 2, GameUI.GetScreenWorldPosition(GameUI.GetCursorPosition()));
        var abilityRange = Abilities.GetSpecialValueFor(ability, "max_vector_range") == 0 ? 500 : Abilities.GetSpecialValueFor(ability, "max_vector_range");
        points.push(GameUI.GetScreenWorldPosition(GameUI.GetCursorPosition()));
        $.Msg(points.length);
        var endPoint = ArrayToVector(GameUI.GetScreenWorldPosition(GameUI.GetCursorPosition()));
        if (abilityRange < ArrayToVector(startingPoint).DistanceTo(endPoint)) {
            //$.Msg("range"," ",ArrayToVector(startingPoint).DistanceTo(endPoint)," ",abilityRange)
            goNext = false;
            return;
        }
        if (GameUI.IsMouseDown(0) != wasMouseDown) {
            //$.Msg("Mouse")
            goNext = false;
            return;
        }
    }
}
