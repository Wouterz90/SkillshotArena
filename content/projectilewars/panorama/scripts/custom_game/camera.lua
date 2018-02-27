require("typescript_lualib")
local previousMousePosition = {0.5,0.5}

local n = 0.45

function CameraThink()
    DollarStatic.Schedule($,0.01,function()
        CameraThink()
    end
)
    if CScriptBindingPR_Game.GetState(Game)<DOTA_GameState.DOTA_GAMERULES_STATE_PRE_GAME then
        return
    end
    if not hidden then
        HideStuff()
    end
    local player = CScriptBindingPR_Players.GetLocalPlayer(Players)

    local hero = CScriptBindingPR_Players.GetPlayerHeroEntityIndex(Players,player)

    local hero_origin = ArrayToVector(CScriptBindingPR_Entities.GetAbsOrigin(Entities,hero))

    local forward = ArrayToVector(CScriptBindingPR_Entities.GetForward(Entities,hero))

    local target_origin = Vector.Add(hero_origin,Vector.Scale(forward,distance))

    local up = Vector.new(true,0,1,0)

    local dot = Vector.Dot(up,forward)

    local a = dot/(Vector.Length(up)*Vector.Length(forward))

    local value = math.acos(a)

    local degrees = (value/math.pi)*180

    local cross = Vector.Cross(up,forward)

    if cross.z<0 then
        degrees=-degrees
    end
    CDOTA_PanoramaScript_GameUI.SetCameraTargetPosition(GameUI,VectorToArray(target_origin),0.01)
    CDOTA_PanoramaScript_GameUI.SetCameraYaw(GameUI,degrees)
    local mousePosition = {CDOTA_PanoramaScript_GameUI.GetCursorPosition(GameUI)[0+1]/CScriptBindingPR_Game.GetScreenWidth(Game),CDOTA_PanoramaScript_GameUI.GetCursorPosition(GameUI)[1+1]/CScriptBindingPR_Game.GetScreenHeight(Game)}

    if CDOTA_PanoramaScript_GameUI.IsControlDown(GameUI) then
        if mousePosition[0+1]>(1-n) then
            local rotation = (mousePosition[0+1]-(1-n))/n

            CDOTA_PanoramaScript_GameEvents.SendCustomGameEventToServer(GameEvents,"ButtonPressed",{button="MouseLeft",pressed=0})
            CDOTA_PanoramaScript_GameEvents.SendCustomGameEventToServer(GameEvents,"ButtonPressed",{button="MouseRight",pressed=(rotation+0.15)*150})
        else
            if mousePosition[0+1]<n then
                local rotation = (n-mousePosition[0+1])/n

                CDOTA_PanoramaScript_GameEvents.SendCustomGameEventToServer(GameEvents,"ButtonPressed",{button="MouseRight",pressed=0})
                CDOTA_PanoramaScript_GameEvents.SendCustomGameEventToServer(GameEvents,"ButtonPressed",{button="MouseLeft",pressed=(rotation+0.15)*150})
            else
                CDOTA_PanoramaScript_GameEvents.SendCustomGameEventToServer(GameEvents,"ButtonPressed",{button="MouseLeft",pressed=0})
                CDOTA_PanoramaScript_GameEvents.SendCustomGameEventToServer(GameEvents,"ButtonPressed",{button="MouseRight",pressed=0})
            end
        end
    else
        CDOTA_PanoramaScript_GameEvents.SendCustomGameEventToServer(GameEvents,"ButtonPressed",{button="MouseLeft",pressed=0})
        CDOTA_PanoramaScript_GameEvents.SendCustomGameEventToServer(GameEvents,"ButtonPressed",{button="MouseRight",pressed=0})
    end
    CDOTA_PanoramaScript_GameUI.SetCameraPitchMin(GameUI,15)
    CDOTA_PanoramaScript_GameUI.SetCameraPitchMax(GameUI,15)
    CDOTA_PanoramaScript_GameUI.SetCameraLookAtPositionHeightOffset(GameUI,hero_origin.z-225)
    CDOTA_PanoramaScript_GameUI.SetCameraDistance(GameUI,750)
end
local distance = 850

local prevPitch = 0

function HideStuff()
    local pan = Panel.GetParent(Panel.GetParent(DollarStatic.GetContextPanel($)))

    local center_block = Panel.FindChildTraverse(pan,"center_block")

    if center_block then
        hidden=true
    end
    Panel.FindChildTraverse(pan,"StatBranch").style.visibility="collapse"
    Panel.FindChildTraverse(pan,"inventory").style.visibility="collapse"
    Panel.FindChildTraverse(pan,"PortraitContainer").style.visibility="collapse"
    Panel.FindChildTraverse(pan,"PortraitBacker").style.visibility="collapse"
    Panel.FindChildTraverse(pan,"HUDSkinPortrait").style.visibility="collapse"
    Panel.FindChildTraverse(pan,"left_flare").style.visibility="collapse"
    Panel.FindChildTraverse(pan,"right_flare").style.visibility="collapse"
    Panel.FindChildTraverse(pan,"PortraitBackerColor").style.visibility="collapse"
    Panel.FindChildTraverse(pan,"xp").style.visibility="collapse"
    Panel.FindChildTraverse(pan,"health_mana").style.visibility="collapse"
    Panel.FindChildTraverse(pan,"stats_tooltip_region").style.visibility="collapse"
    Panel.FindChildTraverse(pan,"stats_container").style.visibility="collapse"
    Panel.FindChildTraverse(pan,"unitname").style.visibility="collapse"
    Panel.FindChildTraverse(pan,"HUDSkinAbilityContainerBG").style.visibility="collapse"
    Panel.FindChildTraverse(pan,"AbilityLevelContainer").style.visibility="collapse"
    for _, p in ipairs(Panel.FindChildrenWithClassTraverse(pan,"AbilityInsetShadowRight")) do
        p.style.visibility="collapse"
    end
    for _, p in ipairs(Panel.FindChildrenWithClassTraverse(pan,"AbilityInsetShadowLeft")) do
        p.style.visibility="collapse"
    end
    local panel = Panel.FindChildTraverse(pan,"AbilitiesAndStatBranch")

    panel.style.marginBottom="0px"
    Panel.FindChildTraverse(pan,"buffs").style.marginBottom="100px"
    Panel.FindChild(Panel.FindChildTraverse(pan,"AbilitiesAndStatBranch"),"StatBranch").style.visibility="collapse"
end
local hidden = false

HideStuff()
