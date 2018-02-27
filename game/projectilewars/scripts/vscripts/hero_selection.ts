
function ConfirmHeroPick(keys):boolean {
  if (_G.options.AllowDuplicatePicksInRound && _G.pickedHeroes[keys.heroName] ) {
    if (IsInToolsMode()) {print("Duplicate hero picked in this round")}
    return false
  }
  if (_G.options.AllowDuplicatePicksForPlayers && _G.pickedHeroes["player"+keys.playerID][keys.heroName] ) {
    if (IsInToolsMode()) {print("Duplicate hero picked for player")}
    return false
  }
  StoreHeroPick(keys.heroName,keys.PlayerID)
  return true
}


function StoreHeroPick(heroname,pid:PlayerID):void {
  _G.pickedHeroes[heroname] = true
  _G.pickedHeroes[pid][heroname] = true
  let hero = CreateHeroForPlayer(heroname,PlayerResource.GetPlayer(pid))
  UTIL_Remove(hero)
}

function GetRandomHero(pid:PlayerID) {
  let heroes = LoadKeyValues("scripts/npc/npc_heroes.txt") as string[]
  let rand = RandomInt(0,heroes.length-1)
  let heroname = heroes[rand]
  let t = {heroName:heroname,PlayerID:pid}
  let b = ConfirmHeroPick(t)
  while(!b) {
    rand = RandomInt(0,heroes.length-1)
    heroname = heroes[rand]
    t = {heroName:heroname,PlayerID:pid}
  }
}

function HeroPickPhaseStarted() {
  _G.pickedHeroes = {}

  for (let i=-1;i<=23;i++) {
    _G.pickedHeroes["player"+i] = _G.pickedHeroes["player"+i] || {}
  }
}

function HeroPickPhaseEnded() {
  // Random for all players
  for (let i =1 as PlayerID;i<=DOTALimits_t.DOTA_MAX_TEAM;i++) {
    if (PlayerResource.IsValidTeamPlayerID(i) && !PlayerResource.GetSelectedHeroEntity(i)) {

    }
  }
}