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
    function AggLevel:action ()
    -- Do nothing. Abstract interface function
      return .5
    end

--Create a class Aggressive which implements AggLevel
    Aggressive = createClass(AggLevel)
    function Aggressive:action ()
    -- Attack nearby enemy
      return .5
    end

--Create a class Coward which implements AggLevel
    Coward = createClass(AggLevel)
    function Coward:action ()
    -- Run from nearby enemy
      return .5
    end

--Create a class Oblivious which implements AggLevel
    Oblivious = createClass(AggLevel)
    function Oblivious:action ()
    -- Ignore nearby enemy
      return .5
    end
    
    local actualbehavior = Oblivious:new{}

function aggroBehavior.action() 
   return actualbehavior.action()
end