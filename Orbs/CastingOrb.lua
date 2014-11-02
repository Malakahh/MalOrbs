------------------------------------------------------------
-- | MalOrbs											| --
-- | Creates orbs for various purposes.					| --
-- | Copyright (c) 2014 Malakahh. All Rights Reserved.	| --
------------------------------------------------------------

local _, ns = ...

local lib = LibStub("MalUI-1.0")
if not lib then return end

--Class table
ns.CastingOrb = {}
ns.CastingOrb.__index = ns.CastingOrb

--Returns the type of the orb
function ns.CastingOrb.GetOrbType()
	return "CastingOrb"
end

--Register orbtype
ns.RegisterOrbType(ns.CastingOrb.GetOrbType())

--Gets percentage progress, used by self:Update()
function ns.CastingOrb.GetProgressOnUpdate(self)
	if not UnitName(self.settings.CastingOrb.unit) then
		if not self.settings.isConfigmodeEnabled then self:Hide() end
        --self:Hide()
		return 100
	end

	local normalizedMax = (self.endTime / 1000) - (self.startTime / 1000)
	local normalizedVal = GetTime() - (self.startTime / 1000)
	local ret = (normalizedVal / normalizedMax) * 100

	local _, _, _, ms = GetNetStats()
	ms = ((ms / 1000) / normalizedMax) * 100

	--time remaining text
	local castText = normalizedMax - normalizedVal
	if castText < 0 then castText = 0 end
	self.fontCasting:SetText(format("%.1f", castText))

	--Security
	if ms > 100 then ms = 100
	elseif ms < 0 then ms = 0 end

	if ret < 0 then ret = 0
	elseif ret > 100 then ret = 100 end

	--Is this a channel? Reverse direction
	if self.channeling == 1 then
		ret = 100 - ret
		self:SetSecondaryProgressFillDirection(self.settings.progressFillDirection) --counter clickwise
	elseif self.casting == 1 then
		self:SetSecondaryProgressFillDirection(self.settings.progressFillDirection * -1) --clockwise
	end

	return ret, ms
end

--Sets the orb color, used by self:Update()
function ns.CastingOrb.SetOrbColorOnUpdate(self)
	--Idea: Change color of castbar based on how many delays are caused by attacks? (i.e. go more and more red)

	self:SetProgressColor(lib.Helper.HexColorToColor( 0x5184BDCC ))
	self:SetSecondaryProgressColor(lib.Helper.HexColorToColor( 0xFF88008C ))
end

--Applies a given set of settings, or reapplies the current set
function ns.CastingOrb.ApplySettings(self, settings)
	self.base.ApplySettings(self, settings)

	self.settings.type = self:GetOrbType()

    do
        local p = settings.CastingOrb.fontCastingPoint
        self.fontCasting:SetPoint(p.point, self.glassFrame:GetName(), p.relativePoint, p.ofsx, p.ofsy)
    end

    do
        local p = settings.CastingOrb.fontSpellNamePoint
        self.fontSpellName:SetPoint(p.point, self.glassFrame:GetName(), p.relativePoint, p.ofsx, p.ofsy)
    end

    self:SetUnit(settings.CastingOrb.unit)
end

--Returns a table of updated settings
function ns.CastingOrb.UpdateSettings(self)
	local newSettings = self.base.UpdateSettings(self)

	newSettings.type = self:GetOrbType()

	newSettings.CastingOrb = {}
	newSettings.CastingOrb.unit = self.settings.CastingOrb.unit

	--fontCasting
	do
		local p, _, rp, x, y = self.fontCasting:GetPoint()
		newSettings.CastingOrb.fontCastingPoint = {
			point = p,
			relativePoint = rp,
			ofsx = x,
			ofsy = y
		}
	end

	--fontSpellName
	do
		local p, _, rp, x, y = self.fontSpellName:GetPoint()
		newSettings.CastingOrb.fontSpellNamePoint = {
			point = p,
			relativePoint = rp,
			ofsx = x,
			ofsy = y
		}
	end

	return newSettings
end

--Initializes the orb
function ns.CastingOrb.Init(self, parentFrame, width, height)
	self.base.Init(self, parentFrame, width, height)

	self.settings.CastingOrb = {}

	--Create settings
	self.settings.type = self:GetOrbType()
	self.settings.CastingOrb.fontCastingPoint = {
		point = "TOP",
		relativeTo = self.glassFrame:GetName(),
		relativePoint = nil,
		ofsx = 0,
		ofsy = self.frame:GetHeight() * -.124
	}
	self.settings.CastingOrb.fontSpellNamePoint = {
		point = "BOTTOM",
		relativeTo = self.glassFrame:GetName(),
		relativePoint = nil,
		ofsx = 0,
		ofsy = -10
	}

	self.basicEventsRegistered = false
	self.casting = nil
	self.channeling = nil
	self.startTime = 0
	self.endTime = 0

	--Hide deafult castbar
	CastingBarFrame:UnregisterAllEvents()

    --default unit to player
    self.settings.CastingOrb.unit = "player"

	----
	--Icon Frame
	----
	local iconFrame = CreateFrame("Frame")
	iconFrame:SetSize(self:CenterContentGetSize())

	local iconFrameTexture = iconFrame:CreateTexture(nil, "BACKGROUND")
	iconFrameTexture:SetPoint("CENTER", iconFrame, "CENTER")

	self:SetCenterContent(iconFrame)

	----
	--Casting text
	----
	local fontCasting = self.glassFrame:CreateFontString(self.frame:GetName().."_fontCasting")
	fontCasting:SetFont(ns.Fonts.FRIZQT__, 13, "OUTLINE")

	local fontSpellName = self.glassFrame:CreateFontString(self.frame:GetName().."_fontSpellName")
	fontSpellName:SetFont(ns.Fonts.FRIZQT__, 15, "OUTLINE")

	----
	--Reference in self
	----
	self.iconFrame = iconFrame
	self.iconFrameTexture = iconFrameTexture
	self.fontCasting = fontCasting
	self.fontSpellName = fontSpellName

	--Event handler for casting
	self:AppendScript("OnEvent", function(s, event, ...)
		if self.settings.CastingOrb.unit == nil then return end

		local arg1 = ...

		if event == "PLAYER_ENTERING_WORLD" then
			local nameChannel = UnitChannelInfo(self.settings.CastingOrb.unit)
			local nameCast = UnitCastingInfo(self.settings.CastingOrb.unit)
			if nameChannel then
				event = "UNIT_SPELLCAST_CHANNEL_START"
			elseif nameCast then
				event = "UNIT_SPELLCAST_START"
			else
				self:StopCast()
			end
		end

		if event == "UNIT_SPELLCAST_START" then
			if UnitName(self.settings.CastingOrb.unit) then
				self:UpdateCast()
			else
				self:Hide()
			end
		elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
			if UnitName(self.settings.CastingOrb.unit) then
				self:UpdateChannel()
			else
				self:Hide()
			end
		elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
			self:StopCast()
		elseif event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" then
			self:StopCast()
		elseif event == "UNIT_SPELLCAST_DELAYED" then
			if UnitName(self.settings.CastingOrb.unit) then
				self:UpdateCast()
			else
				self:Hide()
			end
		elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
			if UnitName(self.settings.CastingOrb.unit) then
				self:UpdateChannel()
			else
				self:Hide()
			end
		end
	end)

    self:Hide()
	self:SetSecondaryProgressFillDirection(-1) --CounterClockwise
	self:SetSecondaryProgressShown(true)
	self:ApplySettings(self.settings)
end

--Resizes the orb given a width and a height
function ns.CastingOrb.SetSize(self, width, height)
	self.base.SetSize(self, width, height)

	self.iconFrame:SetSize(self:CenterContentGetSize())
	self.iconFrameTexture:SetSize(self.iconFrame:GetWidth() * .8, self.iconFrame:GetHeight() * .8)
	self.fontCasting:SetPoint(
		self.settings.CastingOrb.fontCastingPoint.point,
        self.glassFrame:GetName(),
		self.settings.CastingOrb.fontCastingPoint.relativePoint,
		self.settings.CastingOrb.fontCastingPoint.ofsx,
		self.settings.CastingOrb.fontCastingPoint.ofsy)
	self.fontSpellName:SetPoint(
		self.settings.CastingOrb.fontSpellNamePoint.point,
        self.glassFrame:GetName(),
		self.settings.CastingOrb.fontSpellNamePoint.relativePoint,
		self.settings.CastingOrb.fontSpellNamePoint.ofsx,
		self.settings.CastingOrb.fontSpellNamePoint.ofsy)
end

--Sets the icon of the spell being cast
function ns.CastingOrb.SetIconTexture(self, texture)
	SetPortraitToTexture(self.iconFrameTexture, texture)
	self.iconFrameTexture:SetTexCoord(.04, .96, .04, .96)
end

--Updates the spell being cast
function ns.CastingOrb.UpdateCast(self)
	local name, _, _, texture, startTime, endTime = UnitCastingInfo(self.settings.CastingOrb.unit)

	if not name then
		return
	end

	self.fontSpellName:SetText(name)

	self:SetIconTexture(texture)
	self.casting = 1
	self.startTime = startTime
	self.endTime = endTime

	self:Update()
	self:Show()
end

--Updates the spell being channeled
function ns.CastingOrb.UpdateChannel(self)
	local name, _, _, texture, startTime, endTime = UnitChannelInfo(self.settings.CastingOrb.unit)

	if not name then
		return
	end

	self.fontSpellName:SetText(name)

	self:SetIconTexture(texture)
	self.channeling = 1
	self.startTime = startTime
	self.endTime = endTime

	self:Update()
	self:Show()
end

--Stops casting and hides CastingOrb
function ns.CastingOrb.StopCast(self)
	self.casting = nil
	self.channeling = nil
	self.startTime = 0
	self.endTime = 0
	self:Hide()
end

--Sets the unit of the casting orb
function ns.CastingOrb.SetUnit(self, unit)
	self.settings.CastingOrb.unit = unit

	if not self.basicEventsRegistered then
		self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
		self:RegisterEvent("UNIT_SPELLCAST_DELAYED")
		self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
		self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
		self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		self:AppendScript("OnUpdate", function()
			self:Update()
		end)
		self.basicEventsRegistered = true
	end

	--Unregister previous events, in case unit changed
	self:UnregisterEvent("UNIT_SPELLCAST_START")
	self:UnregisterEvent("UNIT_SPELLCAST_STOP")
	self:UnregisterEvent("UNIT_SPELLCAST_FAILED")

	self:RegisterUnitEvent("UNIT_SPELLCAST_START", self.settings.CastingOrb.unit)
	self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self.settings.CastingOrb.unit)
	self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", self.settings.CastingOrb.unit)

	if self.settings.CastingOrb.unit == "target" then
		self:RegisterEvent("PLAYER_TARGET_CHANGED")
		self:AppendScript("OnEvent", function(s, event, ...)
			self:UpdateCast()
			self:UpdateChannel()
		end)
	elseif self.settings.CastingOrb.unit == "targettarget" then
		self:RegisterEvent("UNIT_TARGET")
		self:AppendScript("OnEvent", function(s, event, ...)
			if ... == "target" then
				self:UpdateCast()
				self:UpdateChannel()
			end
		end)
	elseif self.settings.CastingOrb.unit == "focus" then
		self.RegisterEvent("PLAYER_FOCUS_CHANGED")
		self:AppendScript("OnEvent", function(s, event, ...)
			self:UpdateCast()
			self:UpdateChannel()
		end)
	end
end

function ns.CastingOrb.New()
	local self = ns.CenterContentOrb.New()
	self.base = {}

    for k,v in pairs(ns.CastingOrb) do
        self[k] = v
    end
    --setmetatable(self, ns.CastingOrb)
    for k,v in pairs(ns.Orb) do
        if self[k] then
            self.base[k] = v
        else
            self[k] = v
        end
    end
    for k,v in pairs(ns.CenterContentOrb) do
        if self[k] then
            self.base[k] = v
        else
            self[k] = v
        end
    end

	return self
end