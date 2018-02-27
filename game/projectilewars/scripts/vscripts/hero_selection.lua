require("typescript_lualib")
function ConfirmHeroPick(keys)
    if _G.options.AllowDuplicatePicksInRound and _G.pickedHeroes[keys.heroName] then
        if IsInToolsMode() then
            print("Duplicate hero picked in this round")
        end
        return false
    end
    if _G.options.AllowDuplicatePicksForPlayers and _G.pickedHeroes["player"..keys.playerID][keys.heroName] then
        if IsInToolsMode() then
            print("Duplicate hero picked for player")
        end
        return false
    end
    StoreHeroPick(keys.heroName,keys.PlayerID)
    return true
end
function StoreHeroPick(heroname,pid)
    _G.pickedHeroes[heroname]=true
    _G.pickedHeroes[pid][heroname]=true
    local hero = CreateHeroForPlayer(heroname,CDOTA_PlayerResource.GetPlayer(PlayerResource,pid))

    UTIL_Remove(hero)
end
function GetRandomHero(pid)
    local heroes = LoadKeyValues("scripts/npc/npc_heroes.txt")

    local rand = RandomInt(0,#heroes-1)

    local heroname = heroes[rand+1]

    local t = {heroName=heroname,PlayerID=pid}

    local b = ConfirmHeroPick(t)

    while not b do
        rand=RandomInt(0,#heroes-1)
        heroname=heroes[rand+1]
        t={heroName=heroname,PlayerID=pid}
    end
end
function HeroPickPhaseStarted()
    _G.pickedHeroes={}
    for i=-1,23,1 do
        _G.pickedHeroes["player"..i]=(_G.pickedHeroes["player"..i] or {})
    end
end
function HeroPickPhaseEnded()
    for i=1,DOTA_MAX_TEAM,1 do
        if CDOTA_PlayerResource.IsValidTeamPlayerID(PlayerResource,i) and not CDOTA_PlayerResource.GetSelectedHeroEntity(PlayerResource,i) then
        end
    end
end
