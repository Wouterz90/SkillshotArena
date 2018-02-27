require("typescript_lualib")
local inputSpell_0 = "space"

local inputSpell_1 = CScriptBindingPR_Game.GetKeybindForAbility(Game,0)

local inputSpell_2 = CScriptBindingPR_Game.GetKeybindForAbility(Game,1)

local inputSpell_3 = CScriptBindingPR_Game.GetKeybindForAbility(Game,2)

local inputSpell_4 = CScriptBindingPR_Game.GetKeybindForAbility(Game,3)

local inputSpell_5 = CScriptBindingPR_Game.GetKeybindForAbility(Game,4)

local inputSpell_6 = CScriptBindingPR_Game.GetKeybindForAbility(Game,5)

function CastAbility_0()
    local player = CScriptBindingPR_Players.GetLocalPlayer(Players)

    local hero = CScriptBindingPR_Players.GetPlayerHeroEntityIndex(Players,player)

    local ability = CScriptBindingPR_Entities.GetAbility(Entities,hero,0)

    CScriptBindingPR_Abilities.ExecuteAbility(Abilities,ability,hero,true)
end
function CastAbility_1()
    local player = CScriptBindingPR_Players.GetLocalPlayer(Players)

    local hero = CScriptBindingPR_Players.GetPlayerHeroEntityIndex(Players,player)

    local ability = CScriptBindingPR_Entities.GetAbility(Entities,hero,1)

    CScriptBindingPR_Abilities.ExecuteAbility(Abilities,ability,hero,true)
end
function CastAbility_2()
    local player = CScriptBindingPR_Players.GetLocalPlayer(Players)

    local hero = CScriptBindingPR_Players.GetPlayerHeroEntityIndex(Players,player)

    local ability = CScriptBindingPR_Entities.GetAbility(Entities,hero,2)

    CScriptBindingPR_Abilities.ExecuteAbility(Abilities,ability,hero,true)
end
function CastAbility_3()
    local player = CScriptBindingPR_Players.GetLocalPlayer(Players)

    local hero = CScriptBindingPR_Players.GetPlayerHeroEntityIndex(Players,player)

    local ability = CScriptBindingPR_Entities.GetAbility(Entities,hero,3)

    CScriptBindingPR_Abilities.ExecuteAbility(Abilities,ability,hero,true)
end
function CastAbility_4()
    local player = CScriptBindingPR_Players.GetLocalPlayer(Players)

    local hero = CScriptBindingPR_Players.GetPlayerHeroEntityIndex(Players,player)

    local ability = CScriptBindingPR_Entities.GetAbility(Entities,hero,4)

    CScriptBindingPR_Abilities.ExecuteAbility(Abilities,ability,hero,true)
end
function CastAbility_5()
    local player = CScriptBindingPR_Players.GetLocalPlayer(Players)

    local hero = CScriptBindingPR_Players.GetPlayerHeroEntityIndex(Players,player)

    local ability = CScriptBindingPR_Entities.GetAbility(Entities,hero,5)

    CScriptBindingPR_Abilities.ExecuteAbility(Abilities,ability,hero,true)
end
function CastAbility_6()
    local player = CScriptBindingPR_Players.GetLocalPlayer(Players)

    local hero = CScriptBindingPR_Players.GetPlayerHeroEntityIndex(Players,player)

    local ability = CScriptBindingPR_Entities.GetAbility(Entities,hero,6)

    CScriptBindingPR_Abilities.ExecuteAbility(Abilities,ability,hero,true)
end
CScriptBindingPR_Game.CreateCustomKeyBind(Game,inputSpell_0,"CastAbility_0")
CScriptBindingPR_Game.CreateCustomKeyBind(Game,inputSpell_1,"CastAbility_1")
CScriptBindingPR_Game.CreateCustomKeyBind(Game,inputSpell_2,"CastAbility_2")
CScriptBindingPR_Game.CreateCustomKeyBind(Game,inputSpell_3,"CastAbility_3")
CScriptBindingPR_Game.CreateCustomKeyBind(Game,inputSpell_4,"CastAbility_4")
CScriptBindingPR_Game.CreateCustomKeyBind(Game,inputSpell_5,"CastAbility_5")
CScriptBindingPR_Game.CreateCustomKeyBind(Game,inputSpell_6,"CastAbility_6")
CScriptBindingPR_Game.AddCommand(Game,"CastAbility_0",CastAbility_0,"",0)
CScriptBindingPR_Game.AddCommand(Game,"CastAbility_1",CastAbility_1,"",0)
CScriptBindingPR_Game.AddCommand(Game,"CastAbility_2",CastAbility_2,"",0)
CScriptBindingPR_Game.AddCommand(Game,"CastAbility_3",CastAbility_3,"",0)
CScriptBindingPR_Game.AddCommand(Game,"CastAbility_4",CastAbility_4,"",0)
CScriptBindingPR_Game.AddCommand(Game,"CastAbility_5",CastAbility_5,"",0)
CScriptBindingPR_Game.AddCommand(Game,"CastAbility_6",CastAbility_6,"",0)
