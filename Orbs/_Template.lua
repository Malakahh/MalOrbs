------------------------------------------------------------
-- | MalOrbs											| --
-- | Creates orbs for various purposes.					| --
-- | Copyright (c) 2014 Malakahh. All Rights Reserved.	| --
------------------------------------------------------------


--------------
--**********--
--**NOTICE**--
--**********--
--------------

MUST REPLACE All
<CLASS>
WITH SOMETHING PROPER.
ONLY DELETE THIS MESSAGE AFTERWARDS.

----
--Events
----
-- Any custom events created 
-- Should be listed here
-- Using comments
 


local _, ns = ...

--Get a reference to the LibQTip
local LibQTip = LibStub('LibQTip-1.0')

--Class table
ns.<CLASS> = {}
ns.<CLASS>.__index = ns.<CLASS>

--Returns the type of the orb
function ns.<CLASS>.GetOrbType()
	return "<CLASS>"
end

--Register orbtype
ns.RegisterOrbType(ns.<CLASS>.GetOrbType())

--Gets percentage progress, used by self:Update()
function ns.<CLASS>.GetProgressOnUpdate(self)
	--Body
end

--Sets the orb color, used by self:Update()
function ns.<CLASS>.SetOrbColorOnUpdate(self)
	-- body
end

--Applies a given set of settings, or reapplies the current set
function ns.<CLASS>.ApplySettings(self, settings)
	self.base.ApplySettings(self, settings)

	--Create Settings
	self.settings.type = self:GetOrbType()

	--Body

end

--Returns a table of updated settings
function ns.<CLASS>.UpdateSettings(self)
	local newSettings = self.base.UpdateSettings(self)

	newSettings.type = self:GetOrbType()

	--Body

	return newSettings
end

--Initializes the orb
function ns.<CLASS>.Init(self, parentFrame, width, height)
	self.base.Init(self, parentFrame, width, height)

	self.settings.type = self:GetOrbType()

	--Body

	self:ApplySettings(self.settings)
end

function ns.<CLASS>.New()
	local self = ns.Orb.New()
	self.base = {}

    setmetatable(self, ns.<CLASS>)
    for k,v in pairs(ns.Orb) do
        if self[k] then
            self.base[k] = v
        else
            self[k] = v
        end
    end

    ns.RegisterOrbType(self:GetOrbType())
	return self
end