ALL_TEAMS = {
  DOTA_TEAM_GOODGUYS,
  DOTA_TEAM_BADGUYS,
  DOTA_TEAM_CUSTOM_1,
  DOTA_TEAM_CUSTOM_2,
  DOTA_TEAM_CUSTOM_3,
  DOTA_TEAM_CUSTOM_4,
  DOTA_TEAM_CUSTOM_5,
  DOTA_TEAM_CUSTOM_6,
  DOTA_TEAM_CUSTOM_7,
  DOTA_TEAM_CUSTOM_8,
}


-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode
BAREBONES_VERSION = "1.00"

-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false 



if GameMode == nil then
    DebugPrint( '[BAREBONES] creating barebones game mode' )
    _G.GameMode = class({})
end
require('statcollection/init')
require('libraries/timers')
require('libraries/worldpanels')
require('physics/physics')
require('physics/projectiles')
require('abilities/base_ability')
require('items/base_item')
require('vector_target')
require('util')
require('funcs')
require('vision')
require('modifiers')
require('trees')
-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')
require('internal/events')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')
--require('controls')
require('api/modifier')


--require("examples/worldpanelsExample")

--[[
  This function should be used to set up Async precache calls at the beginning of the gameplay.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).

  This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function GameMode:PostLoadPrecache()
  DebugPrint("[BAREBONES] Performing Post-Load precache")    
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)

  --PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
  --PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
]]
function GameMode:OnFirstPlayerLoaded()
  DebugPrint("[BAREBONES] First Player has loaded")
  HEROES_TXT = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")


end

function GameMode:CreateOutsideWall()
  local round = {}
  for i=0,35 do
    round[i] = MAP_SIZE*RotatePosition(Vector(0,0,0), QAngle(0,i*10,0), Vector(1,0,0))
  end
  if not WALL then
    WALL = Physics2D:CreatePolygon(Vector(0,0,0),round,nil)
    WALL_PARTICLES = CreateProjectileWall(WALL,round)
  end
end

function GameMode:UpdateOutsideWall()
  if not WALL then print("WALL is nil") return end
  if not WALL_PARTICLES then print("WALL_PARTICLES is nil") return end
  MAP_SIZE = MAP_SIZE * 0.9
  for i=1,#WALL.edges do
    WALL.edges[i] = MAP_SIZE*RotatePosition(Vector(0,0,0), QAngle(0,i*10,0), Vector(1,0,0))
  end

  for i=1,#WALL.edges-1 do
    ParticleManager:DestroyParticle(WALL_PARTICLES[i],true)
    ParticleManager:ReleaseParticleIndex(WALL_PARTICLES[i])
    local direction = (WALL.edges[i+1]-WALL.edges[i]):Normalized()
    local length = (WALL.edges[i+1]-WALL.edges[i]):Length2D()
    local midpoint = WALL.edges[i] + direction * length *0.5
    local particle = ParticleManager:CreateParticle("particles/dark_seer_wall_of_replica.vpcf", PATTACH_ABSORIGIN,WALL )
    ParticleManager:SetParticleControlForward( particle, 0, direction)
    ParticleManager:SetParticleControl( particle, 0, ( WALL.edges[i]))
    ParticleManager:SetParticleControl( particle, 1, ( WALL.edges[i+1]))
    ParticleManager:SetParticleControl( particle, 2, direction)
    WALL_PARTICLES[i] = particle
  end
  ParticleManager:DestroyParticle(WALL_PARTICLES[#WALL.edges],true)
  ParticleManager:ReleaseParticleIndex(WALL_PARTICLES[#WALL.edges])
  local direction = (WALL.edges[1]-WALL.edges[#WALL.edges]):Normalized()
  local length = (WALL.edges[1]-WALL.edges[#WALL.edges]):Length2D()
  local midpoint = WALL.edges[#WALL.edges] + direction * length *0.5
  local particle = ParticleManager:CreateParticle("particles/dark_seer_wall_of_replica.vpcf", PATTACH_ABSORIGIN,WALL )
  ParticleManager:SetParticleControlForward( particle, 0, direction)
  ParticleManager:SetParticleControl( particle, 0, ( WALL.edges[#WALL.edges]))
  ParticleManager:SetParticleControl( particle, 1, ( WALL.edges[1]))
  ParticleManager:SetParticleControl( particle, 2, direction)
  WALL_PARTICLES[#WALL.edges] = particle

end
--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function GameMode:OnAllPlayersLoaded()
  DebugPrint("[BAREBONES] All Players have loaded into the game")

  MAP_SIZE = 1500 + (PlayerResource:GetTeamPlayerCount() -1) * 200
  GameMode:CreateOutsideWall()


  CreateAllTrees()

  --[[local edges = {
    Vector(0,100,0),
    Vector(100,0,0),
    Vector(0,-100,0),
    Vector(-100,0,0),

  }
  local u = Physics2D:CreatePolygon(Vector(0,0,0),edges,nil)
  CreateProjectileWall(u,edges)]]


  --[[local particle = ParticleManager:CreateParticle("particles/disruptor_kineticfield.vpcf",PATTACH_WORLDORIGIN, nil)
  ParticleManager:SetParticleControl(particle, 0, Vector(0,0,0))
  ParticleManager:SetParticleControl(particle, 1, Vector(2900, 1, 128))
  ParticleManager:SetParticleControl(particle, 2, Vector(10000, 0, 0))
  GameRules.particle_ring = particle]]

end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
---@param hero CDOTA_BaseNPC_Hero
function GameMode:OnHeroInGame(hero)
  DebugPrint("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())
  SendToServerConsole("script_reload")
  
  if not FIRST then
    FIRST = true
    -- Fix a spike with rocket flare
    for _,team in pairs(ALL_TEAMS) do
      if PlayerResource:GetPlayerCountForTeam(team) > 0 then
        AddFOWViewer(team,Vector(0,0,128),7500,0.33,false)
      end
    end
  end

  Physics2D:CreateCircle(hero,50,"unit")
  hero:AddNewModifier(hero,nil,"modifier_cooldown_constant_reduction_controller",{})
  hero:AddNewModifier(hero,nil,"modifier_cooldown_percentage_reduction_controller",{})
  hero:ModifyGold(20000, true, DOTA_ModifyGold_Unspecified)
  --hero:AddNewModifier(hero,nil,"modifier_vision_handler",{})
  --hero:AddNewModifier(hero,nil,"modifier_control",{})
  hero:AddNewModifier(hero,nil,"modifier_control_area",{})
  hero:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)


  -- Fix the broken OnOwnerSpawned for abilities
  for i=0,2 do
    local ab = hero:GetAbilityByIndex(i)
    if ab then
      ab:OnOwnerSpawned()
    end
  end

end

-- An NPC has spawned somewhere in game.  This includes heroes
---@param keys table
function GameMode:OnNPCSpawned(keys)
  DebugPrint("[BAREBONES] NPC Spawned")
  DebugPrintTable(keys)
  local npc = EntIndexToHScript(keys.entindex)
  Timers:CreateTimer(0.1,function()
    if npc and not npc:IsNull() and npc:IsRealHero() then
      local vector = RandomVector(RandomInt(1000,MAP_SIZE))
      while not GridNav:CanFindPath(vector,Vec()) do
        vector = RandomVector(RandomInt(1000,MAP_SIZE))
      end
      FindClearSpaceForUnit(npc,vector,true)
      PlayerResource:SetCameraTarget(npc:GetPlayerOwnerID(),npc)
      npc:AddNewModifier(npc,nil,"modifier_invulnerable",{duration =1.5})
      npc:ModifyGold(20000, true, DOTA_ModifyGold_Unspecified)
    end
  end)
  Timers:CreateTimer(1,function()
    if npc and not npc:IsNull() and npc:IsRealHero() then
      PlayerResource:SetCameraTarget(npc:GetPlayerOwnerID(),nil)
    end
  end)
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()
  DebugPrint("[BAREBONES] The game has officially begun")

  Timers:CreateTimer(0, -- Start this timer 30 game-time seconds later
    function()
      GameMode:CreateItems()
      return 30.0 -- Rerun this timer every 30 game-time seconds
    end)
end



-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
  --GameMode = self
  DebugPrint('[BAREBONES] Starting to load Barebones gamemode...')
  StartItemTimer()
  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  Convars:RegisterCommand( "command_example", Dynamic_Wrap(GameMode, 'ExampleConsoleCommand'), "A console command example", FCVAR_CHEAT )
  Convars:RegisterCommand( "reload_vision", Dynamic_Wrap(GameMode, 'ReloadVision'), "reload vision modifier", FCVAR_CHEAT )
  Convars:RegisterCommand( "create_item", Dynamic_Wrap(GameMode, 'CreateTestItem'), "create a test arrow at 0,0", FCVAR_CHEAT )


  CustomGameEventManager:RegisterListener("VectorTargettedAbilityCastFinished",ExecuteVectorTargetAbility)

  DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')
  GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(GameMode,"FilterExecuteOrder"),self)

  GameRules:GetGameModeEntity():SetItemAddedToInventoryFilter(function(ctx, event)
    ItemAddedFilter(event)
  end,
  self)
end


function GameMode:ReloadVision()
  SendToServerConsole("script_reload")
  for _,hero in pairs(HeroList:GetAllHeroes()) do
    --hero:RemoveModifierByName("modifier_vision_handler")
    --hero:AddNewModifier(hero,nil,"modifier_vision_handler",{})
    --hero:RemoveModifierByName("modifier_control")
    --hero:AddNewModifier(hero,nil,"modifier_control",{})
  end


end

function GameMode:CreateTestItem()
  SendToServerConsole("script_reload")
  for item,_ in pairs (ADDED_ITEMS) do
    CreatePhysicsItem(item,RandomVector(RandomInt(50,200)))
  end

  for item,_ in pairs (ADDED_RUNES) do
    CreatePhysicsItem(item,RandomVector(RandomInt(300,500)))
  end
  --[[CreatePhysicsItem("item_spell_timelock",Vec(100,100))
  CreatePhysicsItem("item_spell_axe_lumberjack",Vec(-100,-100))
  CreatePhysicsItem("item_spell_puck_orb",Vec())
  CreatePhysicsItem("item_spell_hook",Vec(100,-100))
  CreatePhysicsItem("item_spell_hookshot",Vec(-100,100))
  CreatePhysicsItem("item_spell_rocket_flare",Vec(-150,150))]]

end

-- This is an example console command
function GameMode:ExampleConsoleCommand()
  print( '******* Example Console Command ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      -- Do something here for the player who called this command
      PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_viper", 1000, 1000)
    end
  end

  print( '*********************************************' )
end


---@param caster CDOTA_BaseNPC_Hero
---@param unit CDOTA_BaseNPC
---@param projectile projectile
function PlayerDodgedProjectile(caster,unit,projectile)
  --local PID = caster:GetPlayerOwnerID()
  caster:HeroLevelUp(true)
end



function GameMode:CreateItems()
  local items = {}
  local allHeroes = HeroList:GetAllHeroes()
  local itemHeroPairs = LoadKeyValues("scripts/kv/item_hero_pairs.kv")

  for k,v in pairs(ALLITEMS) do
    for _,hero in pairs(allHeroes) do
      if itemHeroPairs[k] == hero:GetUnitName() then
        goto endCreateItemsLoop
      end
    end
    table.insert(items,k)
    ::endCreateItemsLoop::
  end
  --[[local points = {
    [1] = GetGroundPosition(Vector(0,1,0),nil),
    [2] = GetGroundPosition(Vector(1664,1664,0),nil),
    [3] = GetGroundPosition(Vector(2432,0,0),nil),
    [4] = GetGroundPosition(Vector(1664,-1664,0),nil),
    [5] = GetGroundPosition(Vector(0,-2432,0),nil),
    [6] = GetGroundPosition(Vector(-1664,-1664,0),nil),
    [7] = GetGroundPosition(Vector(-2432,0,0),nil),
    [8] = GetGroundPosition(Vector(-1664,1664,0),nil),
  }
  local rand = RandomInt(0,1)
  for i =1,#points do
    for k,v in pairs(Physics2D.items) do
      if not v:IsNull() then
        if LengthSquared(points[i]-v:GetAbsOrigin()) < 100*100 then
          UTIL_Remove(v)
        end
      end
    end
    -- Create item at even or uneven spots
    if math.fmod(i,2) == rand then
      CreatePhysicsItem(items[RandomInt(1,#items)],points[i])
    end
  end]]
  DROP_ITEMS = DROP_ITEMS or {}
  for i = 1,3 do
    if IsValidEntity(DROP_ITEMS[i]) then
      UTIL_Remove(DROP_ITEMS[i])
    end
    if i ~= 1 then
      DROP_ITEMS[i] = CreatePhysicsItem(items[RandomInt(1,#items)],RandomVector(RandomInt(750,MAP_SIZE)))
    end
  end

  DROP_ITEMS[1] = CreatePhysicsItem(items[RandomInt(1,#items)],Vec())



end

function StartItemTimer()
  Timers:CreateTimer(0,function() ManageItems() return FrameTime() end)
end
function ManageItems()
  if not Physics2D.items then return end
  for _,item in pairs(Physics2D.items) do
    if not item:IsNull() then
      local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS,item:GetAbsOrigin(),nil,100,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,0,FIND_CLOSEST,false)
      if units[1] then
        units[1]:PickupDroppedItem(item)
      end
    end
  end
end



function GameMode:FilterExecuteOrder(filterTable)
  local units = filterTable["units"]
  local issuer = filterTable["issuer_player_id_const"]
  local order_type = filterTable["order_type"]
  local abilityIndex = filterTable["entindex_ability"]
  local ability = EntIndexToHScript(abilityIndex)
  local targetIndex = filterTable["entindex_target"]
  local target = EntIndexToHScript(targetIndex)

  --[[for k,v in pairs(filterTable) do
    print(k,v)
  end]]
  local allowed_order_types = {
    [DOTA_UNIT_ORDER_CAST_POSITION] = true,
    [DOTA_UNIT_ORDER_CAST_TARGET] = true,
    [DOTA_UNIT_ORDER_CAST_TARGET_TREE] = true,
    [DOTA_UNIT_ORDER_CAST_NO_TARGET] = true,

  }

  --if not allowed_order_types[order_type] then return false end

  return true
end


function GameMode:OnDisconnect(keys)


  local name = keys.name
  local networkid = keys.networkid
  local reason = keys.reason
  local userid = keys.PlayerID

  if GameRules:State_Get() == DOTA_GAMERULES_STATE_POST_GAME or GameRules:State_Get() == DOTA_GAMERULES_STATE_DISCONNECT then
    return
  end
  Timers:CreateTimer(1,function()

    local hero = PlayerResource:GetSelectedHeroEntity(userid)
    if not hero:IsAlive() then
      hero:RespawnHero(false,false,false)
    end

    PlayerTables:SetTableValue(tostring(userid),"lifes",0)
    hero:ForceKill(false)
    local team = GameMode:FindTheOnlyConnectedTeam()
    if team  then

      DeclareWinningTeam(team)
    end

  end)
end

function GameMode:FindTheOnlyConnectedTeam()

  local teams = {}
  local winning
  local teamsLeft = 0
  for i=0,10 do
    teams[i] = 0
  end

  for i=0,10 do
    if PlayerResource:IsValidTeamPlayerID(i) then
      if PlayerResource:GetTeam(i) == DOTA_TEAM_NOTEAM or PlayerResource:GetConnectionState(i) ~= DOTA_CONNECTION_STATE_ABANDONED or PlayerResource:GetConnectionState(i) ~= DOTA_CONNECTION_STATE_DISCONNECTED then
        teams[PlayerResource:GetTeam(i)] = teams[PlayerResource:GetTeam(i)] + 1
      end
    end
  end

  for i=0,10 do
    if teams[i] > 0 then
      teamsLeft = teamsLeft + 1
      winning = i
    end
  end

  if teamsLeft == 0 then
    return teams[1]
  elseif
  teamsLeft == 1 then
    return winning
  else
    return
  end
  return
end
