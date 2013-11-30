local _G = getfenv(0)
local object = _G.object

object.state = object.state or {}

runfile "bots/core.lua"
runfile "bots/botbraincore.lua"
runfile "bots/eventsLib.lua"
runfile "bots/metadata.lua"
runfile "bots/behaviorLib.lua"

local core, eventsLib, behaviorLib, metadata, skills, state = object.core, object.eventsLib, object.behaviorLib, object.metadata, object.skills, object.state


local function search (k, plist)
 for i=1, table.getn(plist) do
  local v = plist[i][k]     -- try `i'-th superclass
  if v then return v end
 end
end

    function createClass (...)
      local c = {}        -- new class
    
      -- class will search for each method in the list of its
      -- parents (`arg' is the list of parents)
      setmetatable(c, {__index = function (t, k)
        return search(k, arg)
      end})
    
      -- prepare `c' to be the metatable of its instances
      c.__index = c
    
      -- define a new constructor for this new class
      function c:new (o)
        o = o or {}
        setmetatable(o, c)
        return o
      end
    
      -- return new class
      return c
    end

ParentState = {}
function ParentState:oncombateventOverride(EventData)
end

function ParentState:CustomHarassUtilityFnOverride(hero)

end

function ParentState.PushingStrengthUtility(myHero)
  return .5
end

function ParentState.RetreatFromThreatExecuteOverride(botBrain)
   return true
end

LaningState = createClass(ParentState)

function LaningState:oncombateventOverride(EventData)
	if core.unitSelf ~= nil then
		local unitToAttack
		local tLocalEnemies = core.CopyTable(core.localUnits["EnemyHeroes"])
		
		for nID, unitEnemy in pairs(tLocalEnemies) do
		   if (unitEnemy:GetHealth() / unitEnemy:GetMaxHealth()) < .6 then unitToAttack = unitEnemy end
		end
		
		if unitToAttack ~= nil then 
		  --if already immobilized from crippling volley, use ultimate
		  if (unitToAttack:IsStunned() or unitToAttack:IsImmobilized()) and core.unitSelf:GetAbility(3):CanActivate() then
		    --core.AllChat("Ultimate time!")
		    core.OrderAbilityPosition(object, core.unitSelf:GetAbility(3), unitToAttack:GetPosition())
		  
		  --else use crippling volley
		  elseif core.unitSelf:GetAbility(0):CanActivate() then
		    --cast it a little ahead of where target is pointing
		    --if botBrain == nil then core.AllChat("Null bot brain") end
		    --core.AllChat("Take this!")
		    core.OrderAbilityPosition(object, core.unitSelf:GetAbility(0), unitToAttack:GetPosition() +  .75 * unitToAttack:GetMoveSpeed() * Vector3.Normalize(unitToAttack.storedPosition - unitToAttack.lastStoredPosition))
		  end
		end
	end
end

function LaningState:CustomHarassUtilityFnOverride(hero)
		-- attack if enemy is out of position
		-- and you wouldnt be put out of position by attacking
		return .5
end

function LaningState.PushingStrengthUtility(myHero)
  -- if late enough into the game, push, otherwise refrain
  return .5
end

function LaningState.RetreatFromThreatExecuteOverride(botBrain)
   -- If enough danger, use Energizer or Phase Boots to escape
   return true
end

LaneFarmingState = createClass(ParentState)

function LaneFarmingState:oncombateventOverride(EventData)
		--reasses if heroes are attacking you
		--or if its still safe to farm
end

function LaneFarmingState:CustomHarassUtilityFnOverride(hero)
		-- reasses how much you should be farming then
		return .5
end

function LaneFarmingState.PushingStrengthUtility(myHero)
  --encourage pushing, as long as you arent too weak for tower
  return .5
end

function LaneFarmingState.RetreatFromThreatExecuteOverride(botBrain)
   -- If enough danger, use Energizer or Phase Boots to escape
   return true
end

local laningstate = LaningState:new{}
local lanefarmingstate = LaneFarmingState:new{}
local actualstate = laningstate
local lastLaneApp = 0

function state.handleStateChange()
   -- if no enemies are in lane
   -- and there is no apparent danger of heroes coming
   -- and >= lvl 7, switch to lane farming
   
   --Dont go back to farming if saw an enemy as recently
   --as 30 seconds ago
   
   -- if enemies do come into
   -- the lane or there is a hero
   -- missing who could gank, 
   -- switch to laning
   
   if core.unitSelf ~= nil and core.unitSelf:GetLevel() > 6 then
      local flag = false   
      for i,v in pairs(core.localUnits["EnemyHeroes"]) do
         flag = true
      end
      if (flag and actualstate == lanefarmingstate) then 
         core.AllChat("Switching to Laning", 0)
         actualstate = laningstate 
         lastLaneApp = HoN.GetGameTime()
      elseif ((not flag) and actualstate == laningstate and (lastLaneApp == 0 or (HoN.GetGameTime() - lastLaneApp) > 1000*30)) then 
         core.AllChat("Switching to Lane Farming", 0) 
         actualstate = lanefarmingstate
      end
   end
   
end

function state.oncombateventOverride(EventData)
	actualstate.oncombateventOverride(EventData)
end

function state.CustomHarassUtilityFnOverride(hero)
	return actualstate.CustomHarassUtilityFnOverride(hero)
end

function state.PushingStrengthUtility(myHero)
  return actualstate.PushingStrengthUtility(myHero)
end

function state.RetreatFromThreatExecuteOverride(botBrain)
   return actualstate.RetreatFromThreatExecuteOverride(botBrain)
end