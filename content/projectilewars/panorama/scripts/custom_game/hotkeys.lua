require("typescript_lualib")
local abilityPanels = {}

function SetUpHotKeys()
    DollarStatic.Schedule($,0.01,function()
        SetUpHotKeys()
    end
)
    local inputs = nil

    inputs={"_",CScriptBindingPR_Game.GetKeybindForAbility(Game,0),CScriptBindingPR_Game.GetKeybindForAbility(Game,1),CScriptBindingPR_Game.GetKeybindForAbility(Game,2),CScriptBindingPR_Game.GetKeybindForAbility(Game,3),CScriptBindingPR_Game.GetKeybindForAbility(Game,4),CScriptBindingPR_Game.GetKeybindForAbility(Game,5)}
    local abName = nil

    local ability = nil

    local key = nil

    local pan = nil

    local hero = CScriptBindingPR_Players.GetSelectedEntities(Players,CScriptBindingPR_Players.GetLocalPlayer(Players))[0+1]

    if not hero then
        return
    end
    local j = 0

    local abilities = 0

    local hbar = Panel.FindChildTraverse(Panel.GetParent(Panel.GetParent(Panel.GetParent(DollarStatic.GetContextPanel($)))),"BottomHealthbar")

    hbar.style.width=(CScriptBindingPR_Entities.GetHealthPercent(Entities,hero)*7).."px"
    local red = math.round(255-(CScriptBindingPR_Entities.GetHealthPercent(Entities,hero)*2.55))

    local green = math.round(CScriptBindingPR_Entities.GetHealthPercent(Entities,hero)*2.55)

    hbar.style.backgroundColor="gradient( linear, 0% 33%, 66% 100%, from( rgb("..(red*0.5)..","..(green*0.5)..",0) ), to( rgb("..red..","..green..",0) ) )"
    for i=0,6,1 do
        ability=CScriptBindingPR_Entities.GetAbility(Entities,hero,i)
        if ability and (CScriptBindingPR_Abilities.GetAbilityName(Abilities,ability)~="") then
            pan=Panel.FindChildTraverse(DotaAbilityList,"Ability"..(i-j))
            if not abilityPanels[i+1] then
                abilityPanels[i+1]=pan
            end
            if pan.style.visibility~="visible" then
                pan.style.visibility="visible"
            end
            key=inputs[i+1]
            pan.style.width="100px"
            local textP = Panel.FindChildTraverse(pan,"HotkeyText")

            textP.text=key
            if Panel.FindChildTraverse(pan,"AbilityLevelContainer").style.visibility~="collapse" then
                Panel.FindChildTraverse(pan,"AbilityLevelContainer").style.visibility="collapse"
            end
            if Panel.FindChildTraverse(pan,"ButtonWell").style.width~="100px" then
                Panel.FindChildTraverse(pan,"ButtonWell").style.width="100px"
                Panel.FindChildTraverse(pan,"ButtonWell").style.height="100px"
                Panel.FindChildTraverse(pan,"ButtonSize").style.width="100px"
                Panel.FindChildTraverse(pan,"ButtonSize").style.height="100px"
                Panel.FindChildTraverse(pan,"Hotkey").style.visibility="visible"
                Panel.FindChildTraverse(pan,"HotkeyContainer").style.marginTop="13%"
                Panel.FindChildTraverse(pan,"HotkeyContainer").style.marginLeft="10%"
                local numPanel = Panel.FindChildTraverse(pan,"GoldCostBG")

                numPanel.style.width="50px"
                numPanel.style.height="50px"
                local numPanelText = Panel.FindChildTraverse(pan,"GoldCost")

                if numPanelText.text and (Number(numPanelText.text)>0) then
                    numPanelText.style.fontSize="30px"
                end
            end
            abilities=(abilities+1)
        else
            j=(j+1)
        end
    end
    for i=6,abilities,-1 do
        pan=Panel.FindChildTraverse(DotaAbilityList,"Ability"..(i))
        if pan then
            pan.style.visibility="collapse"
        end
    end
end
function MouseTooltipManager()
    DollarStatic.DispatchEvent($,"DOTAHideAbilityTooltip")
end
local DotaAbilityList = Panel.FindChildTraverse(Panel.GetParent(Panel.GetParent(DollarStatic.GetContextPanel($))),"abilities")

SetUpHotKeys()
MouseTooltipManager()
function GetBuffAbility(textureName)
    if textureName=="kobold_taskmaster_speed_aura" then
        return "item_rune_speedshot"
    else
        if textureName=="medusa_split_shot" then
            return "item_rune_multishot"
        else
            if textureName=="rune_haste" then
                return "item_rune_haste"
            else
                if textureName=="obsidian_destroyer_essence_aura" then
                    return "item_rune_castpoint"
                else
                    if textureName=="wisp_spirits" then
                        return "item_rune_turnrate"
                    end
                end
            end
        end
    end
    return ""
end
