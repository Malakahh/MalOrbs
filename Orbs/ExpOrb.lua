------------------------------------------------------------
-- | MalOrbs											| --
-- | Creates orbs for various purposes.					| --
-- | Copyright (c) 2014 Malakahh. All Rights Reserved.	| --
------------------------------------------------------------

local _, ns = ...

-- Get a reference to the LibQTip
local LibQTip = LibStub('LibQTip-1.0')

local lib = LibStub("MalUI-1.0")
if not lib then return end

--Class table
ns.ExpOrb = {}
ns.ExpOrb.__index = ns.ExpOrb

--Returns the type of the orb
function ns.ExpOrb.GetOrbType()
	return "ExpOrb"
end

--Register orbtype
ns.RegisterOrbType(ns.ExpOrb.GetOrbType())

--Applies a given set of settings, or reapplies the current set
function ns.ExpOrb.ApplySettings(self, settings)
	self.base.ApplySettings(self, settings)

	--self.settings.type = self:GetOrbType()
end

--Returns a table of updated settings
function ns.ExpOrb.UpdateSettings(self)
	local newSettings = self.base.UpdateSettings(self)

	newSettings.type = self:GetOrbType()

	return newSettings
end

--Gets percentage progress, used by self.Update()
function ns.ExpOrb.GetProgressOnUpdate(self)
	local exp, expMax
	exp = UnitXP("player")
	expMax = UnitXPMax("player")

	local curr = (exp / expMax) * 100
	local rested

	if GetRestState() == 1 then --Rested
		rested = ((exp + GetXPExhaustion()) / expMax) * 100

		if rested > 100 then rested = 100
		elseif rested < 0 then rested = 0 end
	end

	return curr, rested
end

--Sets the orb color, used by self.Update()
function ns.ExpOrb.SetOrbColorOnUpdate(self)
	if GetRestState() == 1 then --Rested
		self:SetProgressColor(lib.Helper.HexColorToColor( 0x0033CC ))

		self:SetSecondaryProgressShown(true)
		self:SetSecondaryProgressColor(lib.Helper.AlphaHexColorToColor( 0x0033CC4D ))
	else --Not rested
		self:SetProgressColor(lib.Helper.HexColorToColor( 0xB8008A ))
		self:SetSecondaryProgressShown(false)
	end
end

--Initializes the ExpOrb
function ns.ExpOrb.Init(self, parentFrame, width, height)
	self.base.Init(self, parentFrame, width, height)
	self.settings.type = self:GetOrbType()

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_XP_UPDATE")
	self:RegisterEvent("PLAYER_LEVEL_UP")
	self:RegisterEvent("PLAYER_UPDATE_RESTING")
	self:AppendScript("OnEvent", function(s, event, ...)
		if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_XP_UPDATE" or event == "PLAYER_UPDATE_RESTING" then
			self:Update()
		elseif event == "PLAYER_LEVEL_UP" then
			newLevel = ...

			self:Update()

			if newLevel == 90 then
				self:Hide()
			end
		end
	end)

	--Tooltip OnEnter func
	self.frame:SetScript("OnEnter", function(s)
		--Force update
		self:Update()

		--Acquire a tooltip with 2 columns
		local tooltip = LibQTip:Acquire("MalOrbsExpOrb-Tooltip", 2, "LEFT", "RIGHT")
		s.tooltip = tooltip

		-- Add a header filling the first two columns
		if GetRestState() == 1 then --Rested
			tooltip:AddHeader("Experience (Rested):", string.format("%.2f%%", self.GetProgressOnUpdate()))
		else
			tooltip:AddHeader("Experience:", string.format("%.2f%%", self.GetProgressOnUpdate()))
		end

		tooltip:SetLineTextColor(1,
			self.settings.progressColor.r,
			self.settings.progressColor.g,
			self.settings.progressColor.b)

		-- Add a new line, using the first column
		local exp = UnitXP("player")
		local expMax = UnitXPMax("player")
		if GetRestState() == 1 then --Rested
			local rested = exp + GetXPExhaustion()
			if rested > expMax then rested = expMax end

			tooltip:AddLine(lib.Helper.CommaValue(exp).." / "..lib.Helper.CommaValue(expMax), "("..lib.Helper.CommaValue(rested)..")")
		else --normal
			tooltip:AddLine(lib.Helper.CommaValue(exp).." / "..lib.Helper.CommaValue(expMax))
		end

		-- Use smart anchoring code to anchor the tooltip to our frame
		tooltip:SmartAnchorTo(s)

		tooltip:Show()
	end)

	--Tooltip OnLeave func
	self.frame:SetScript("OnLeave", function(s)
		-- Release the tooptip
		LibQTip:Release(s.tooltip)
		s.tooltip = nil
	end)

	self:ApplySettings(self.settings)
end

function ns.ExpOrb.New()
	local self = ns.Orb.New()
	self.base = {}

    setmetatable(self, ns.ExpOrb)
    for k,v in pairs(ns.Orb) do
        if self[k] then
            self.base[k] = v
        else
            self[k] = v
        end
    end

	return self
end
