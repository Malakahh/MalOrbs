------------------------------------------------------------
-- | MalOrbs											| --
-- | Creates orbs for various purposes.					| --
-- | Copyright (c) 2014 Malakahh. All Rights Reserved.	| --
------------------------------------------------------------

local _, ns = ...

local lib = LibStub("MalUI-1.0")
if not lib then return end

----------
--Events--
----------
--UnknownStandingId(self, faction)





--Get a reference to the LibQTip
local LibQTip = LibStub('LibQTip-1.0')

--Class table
ns.RepOrb = {}
ns.RepOrb.__index = ns.RepOrb

--Returns the type of the orb
function ns.RepOrb.GetOrbType()
    return "RepOrb"
end

--Register orbtype
ns.RegisterOrbType(ns.RepOrb.GetOrbType())

--Applies a given set of settings, or reapplies the current set
function ns.RepOrb.ApplySettings(self, settings)
	self.base.ApplySettings(self, settings)

	--self.settings.type = self:GetOrbType()
end

--Returns a table of updated settings
function ns.RepOrb.UpdateSettings(self)
	local newSettings = self.base.UpdateSettings(self)

	newSettings.type = self:GetOrbType()

	return newSettings
end

--Initializes the RepOrb
function ns.RepOrb.Init(self, parentFrame, width, height)
	self.base.Init(self, parentFrame, width, height)
	self.settings.type = self:GetOrbType()

	--Register events and event handler
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UPDATE_FACTION")
	self:AppendScript("OnEvent", function(s, event, ...)
		if event == "PLAYER_ENTERING_WORLD" then
			local name = GetWatchedFactionInfo()

			if self:IsShown() and name == nil then
				self:Hide()
			elseif name then
				self:Show()
			end
		elseif event == "UPDATE_FACTION" then
			local name = GetWatchedFactionInfo()

			if self:IsShown() and name then
				self:Update()
			elseif self:IsShown() and name == nil then
				self:Hide()
			elseif name then
				self:Show()
			end
		end
	end)

	--Tooltip OnEnter func
	self.frame:SetScript("OnEnter", function(s)
		--Force update
		self:Update()

		--Acquire a tooltip with 2 columns
		local tooltip = LibQTip:Acquire("MalOrbsRepOrb-Tooltip", 2, "LEFT", "RIGHT")
		s.tooltip = tooltip

		local name, standing, min, max, val = GetWatchedFactionInfo()
		local normalizedMax = max - min
		local normalizedVal = val - min
		local standingName

		if standing == 0 then
			return
		elseif standing == 1 then standingName = "Hated"
		elseif standing == 2 then standingName = "Hostile"
		elseif standing == 3 then standingName = "Unfriendly"
		elseif standing == 4 then standingName = "Neutral"
		elseif standing == 5 then standingName = "Friendly"
		elseif standing == 6 then standingName = "Honored"
		elseif standing == 7 then standingName = "Revered"
		elseif standing == 8 then standingName = "Exalted"
		end

		--Get color
		local r,g,b = self:GetProgressColor()

		--Add a faction header
		tooltip:AddHeader(name)
		tooltip:SetLineTextColor(1,r,g,b)

		--add new line, showing standing
		tooltip:AddLine("Current standing:", standingName)
		tooltip:SetLineTextColor(2,r,g,b)

		--Add line showing standing (in numbers)
		tooltip:AddLine(lib.Helper.CommaValue(normalizedVal).." / "..lib.Helper.CommaValue(normalizedMax), string.format("%.2f%%", self:GetProgressOnUpdate()))

		--Use smart anchoring code to anchor the tooltip to our frame
		tooltip:SmartAnchorTo(s)

		tooltip:Show()
	end)

	--Tooltip OnLeave func
	self.frame:SetScript("OnLeave", function(s)
		--Release the tooltip
		LibQTip:Release(s.tooltip)
		s.tooltip = nil
	end)

	--Initial hiding if no rep is tracked
	do
		local name = GetWatchedFactionInfo()

		if name == nil then
			self:Hide()
			print("MalOrbs: RepOrb created, but it is hidden since no reputation is being tracked. Please track a reputation to show the orb.")
		end
	end

	self:ApplySettings(self.settings)
end

---Gets percentage progress, used by self.Update()
function ns.RepOrb.GetProgressOnUpdate(self)
	local _, _, min, max, val = GetWatchedFactionInfo()
	local normalizedMax = max - min
	local normalizedVal = val - min

	return (normalizedVal / normalizedMax) * 100
end

--Sets the orb color, used by self.Update()
function ns.RepOrb.SetOrbColorOnUpdate(self)
	local _, standing = GetWatchedFactionInfo()

	local r,g,b
	if standing == 1 then --Hated
		r,g,b = lib.Helper.HexColorToColor( 0xFF0000 )
	elseif standing == 2 then --Hostile
		r,g,b = lib.Helper.HexColorToColor( 0xFF5500 )
	elseif standing == 3 then --Unfriendly
		r,g,b = lib.Helper.HexColorToColor( 0xFFAA00 )
	elseif standing == 4 then --Neutral
		r,g,b = lib.Helper.HexColorToColor( 0xFFFF00 )
	elseif standing == 5 then --Friendly
		r,g,b = lib.Helper.HexColorToColor( 0xBDFF00 )
	elseif standing == 6 then --Honored
		r,g,b = lib.Helper.HexColorToColor( 0x7EFF00 )
	elseif standing == 7 then --Revered
		r,g,b = lib.Helper.HexColorToColor( 0x3FFF00 )
	elseif standing == 8 then --Exalted
		r,g,b = lib.Helper.HexColorToColor( 0x00FF00 )
	end

	if r and g and b then
		self:SetProgressColor(r,g,b)
	end
end

function ns.RepOrb.New()
	local self = ns.Orb.New()
	self.base = {}

    setmetatable(self, ns.RepOrb)
    for k,v in pairs(ns.Orb) do
        if self[k] then
            self.base[k] = v
        else
            self[k] = v
        end
    end

	return self
end