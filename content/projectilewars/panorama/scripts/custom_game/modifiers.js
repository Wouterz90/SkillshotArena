"use strict";
var modifiers = {};
var modifierContainerPanel;
function CreateModifierPanel(name, abilityName, starttime, endtime, buff, buffindex) {
    if (!modifierContainerPanel) {
        var pan = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("CustomUIContainer_Hud");
        modifierContainerPanel = $.CreatePanel("Panel", pan, "modifier_container");
        modifierContainerPanel.style.verticalAlign = "bottom";
        //@ts-ignore
        modifierContainerPanel.style.horizontalAlign = "center";
        //@ts-ignore
        modifierContainerPanel.style.flowChildren = "right";
        modifierContainerPanel.style.marginBottom = "130px";
    }
    if (abilityName.match("item")) {
        abilityName = "_" + abilityName;
    }
    var modifierContainer = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("modifier_container") || modifierContainerPanel;
    var bg = $.CreatePanel("Panel", modifierContainer, "modifier_border");
    bg.style.width = "42.5px";
    bg.style.height = "42.5px";
    bg.style.borderRadius = "100%";
    bg.style.zIndex = "1";
    bg.style.backgroundColor = buff ? "green" : "red";
    bg.style.verticalAlign = "center";
    //@ts-ignore
    bg.style.horizontalAlign = "center";
    var main = $.CreatePanel("DOTAAbilityImage", bg, "modifier");
    main.abilityname = abilityName;
    main.style.width = "40px";
    main.style.height = "40px";
    main.style.borderRadius = "100%";
    main.style.zIndex = "2";
    main.style.margin = "1px 1px 1px 1px";
    main.style.verticalAlign = "center";
    //@ts-ignore
    main.style.horizontalAlign = "center";
    main.SetPanelEvent("onmouseover" /* ON_MOUSE_OVER */, function () {
        $.DispatchEvent("DOTAShowTitleTextTooltip", "#" + name, "#" + name + "_description");
    });
    main.SetPanelEvent("onmouseout" /* ON_MOUSE_OUT */, function () {
        $.DispatchEvent("DOTAHideTitleTextTooltip");
    });
    var m = new modifier(name, abilityName, starttime, endtime, buff, main, bg, buffindex);
    modifiers[buffindex] = m;
}
var modifier = /** @class */ (function () {
    function modifier(name, abilityName, starttime, endtime, buff, panel, ring, buffindex) {
        this.modifierName = name;
        this.abilityname = abilityName;
        this.startTime = starttime;
        this.endTime = endtime;
        this.isBuff = buff;
        this.panel = panel;
        this.ring = ring;
        this.buffIndex = buffindex;
    }
    return modifier;
}());
//CreateModifierPanel("modifier_laser_blind","pudge_meat_hook",30,true) 
//CreateModifierPanel("modifier_laser_blind","pudge_rot",30,true) 
function ManageModifiers() {
    if (!modifierContainerPanel) {
        var pan = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("CustomUIState_HUD");
        if (pan) {
            modifierContainerPanel = $.CreatePanel("Panel", pan, "modifier_container");
        }
    }
    $.Schedule(0.01, function () { ManageModifiers(); });
    var hero = Players.GetSelectedEntities(Players.GetLocalPlayer())[0];
    for (var i = 0; i < Entities.GetNumBuffs(hero); i++) {
        var buff = Entities.GetBuff(hero, i);
        if (modifiers && !Buffs.IsHidden(hero, buff) && !modifiers[buff]) {
            var name_1 = Buffs.GetName(hero, buff);
            var ability = Buffs.GetAbility(hero, buff);
            var startTime = Buffs.GetCreationTime(hero, buff);
            var endTIme = Buffs.GetDieTime(hero, buff);
            var isBuff = !Buffs.IsDebuff(hero, buff);
            CreateModifierPanel(name_1, Abilities.GetAbilityName(ability), startTime, endTIme, isBuff, buff);
        }
    }
    for (var j in modifiers) {
        var modifier_1 = modifiers[j];
        var mod = modifier_1.panel;
        var ring = modifier_1.ring;
        ring.style.backgroundColor = modifier_1.isBuff ? "green" : "red";
        var totalDuration = modifier_1.endTime - modifier_1.startTime;
        var elapsedTime = Game.GetGameTime() - modifier_1.startTime;
        var percent = 1 - (elapsedTime / totalDuration);
        ring.style.clip = "radial(50% 50%, 0deg, " + percent * 360 + "deg)";
        if (percent <= 0) {
            mod.DeleteAsync(0);
            ring.DeleteAsync(0);
            delete modifiers[j];
            //let i = modifiers.indexOf(modifier)
            //if (i != -1) {
            //modifiers.slice(i)
            //}
        }
    }
}
ManageModifiers();
