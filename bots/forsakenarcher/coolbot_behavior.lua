local _G = getfenv(0)
local object = _G.object

object.aggroBehavior = object.aggroBehavior or {}

runfile "bots/core.lua"
runfile "bots/botbraincore.lua"
runfile "bots/eventsLib.lua"
runfile "bots/metadata.lua"
runfile "bots/behaviorLib.lua"

local core, eventsLib, behaviorLib, metadata, skills, aggroBehavior = object.core, object.eventsLib, object.behaviorLib, object.metadata, object.skills, object.aggroBehavior


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

-- Creates a class called AggLevel
    AggLevel = {}

    function AggLevel:attackWeight ()
    -- Do nothing. Abstract interface function
      return .5
    end

    function AggLevel:retreatWeight ()
    -- Do nothing. Abstract interface function
      return .5
    end

    function AggLevel:talk ()
    -- Do nothing. Abstract interface function
    end

--Create a class Aggressive which implements AggLevel
    Aggressive = createClass(AggLevel)

    function Aggressive:attackWeight ()
    -- Attack nearby enemy
      return 10
    end

    function Aggressive:retreatWeight ()
    -- Rarely retreat
      return .2
    end

    function Aggressive:talk ()
      --core.AllChat("I'm Aggressive!")
    end

--Create a class Coward which implements AggLevel
    Coward = createClass(AggLevel)

    function Coward:attackWeight ()
    -- Don't attack nearby enemy
      return 0
    end

    function Coward:retreatWeight ()
    -- Run from nearby enemy
      return 10
    end

    function Coward:talk ()
      --core.AllChat("I'm Cowardly!")
    end

--Create a class Oblivious which implements AggLevel
    Oblivious = createClass(AggLevel)

    function Oblivious:attackWeight ()
    -- Ignore nearby enemy
      return 0
    end

    function Oblivious:retreatWeight ()
    -- Ignore nearby enemy
      return 0
    end

    function Oblivious:talk ()
      --core.AllChat("I'm Oblivious!")
    end


--Sets bot's aggression level
	local actualbehavior = Aggressive:new{}
	--local actualbehavior = Oblivious:new{}

function aggroBehavior.attackWeight() 
   return actualbehavior.attackWeight()
end

function aggroBehavior.retreatWeight() 
   return actualbehavior.retreatWeight()
end

function aggroBehavior.talk() 
   return actualbehavior.talk()
end