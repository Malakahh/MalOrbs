------------------------------------------------------------
-- | MalOrbs											| --
-- | Creates orbs for various purposes.					| --
-- | Copyright (c) 2014 Malakahh. All Rights Reserved.	| --
------------------------------------------------------------

local _, ns = ...

local lib = LibStub("MalUI-1.0")
if not lib then return end

ns.Orb = {}
ns.Orb.__index = ns.Orb

-----------
--Methods--
-----------

--Dummy function to return OrbType
function ns.Orb.GetOrbType()
    return "DummyOrb"
end

--Makes the orb enter configmode
function ns.Orb.ConfigmodeEnter(self)
    if ns.ProfileManager:GetCurrentProfile().configmode then return end

    self.preConfigmodeShown = self:IsShown()

	--Backup old settings for possible discard of new settings
	self.oldSettings = self:UpdateSettings()

	self.settings.isConfigmodeEnabled = true

    self.configmodeTexture:Show()
    self:Show()
end

--Makes the orb leave configmode
function ns.Orb.ConfigmodeLeave(self)
    if ns.ProfileManager:GetCurrentProfile().configmode then return end

	--get rid of old settings
	self.oldSettings = nil

	self.settings.isConfigmodeEnabled = nil

    self.configmodeTexture:Hide()

    if not self.preConfigmodeShown then
        self:Hide()
        self.preConfigmodeShown = nil
    end
end

--Initializes the orb
function ns.Orb.Init(self, parentFrame, width, height)
	--Escape if already initialized
	if not self.initialized then
		self.initialized = true

		--Increment number of orbs initialized
		ns.orbCount = ns.orbCount + 1
        ns.Orbs[ns.orbCount] = self

		--Create settings
		self.settings.parentFrame = parentFrame
		self.settings.width = width
		self.settings.height = height
		self.settings.isShown = true

		self:SetProgressFillDirection(1)
		self:SetSecondaryProgressFillDirection(1)

		----
		--Create frame
		----
		local frame = CreateFrame("Frame", "MalOrbsOrb"..ns.orbCount, parentFrame or UIParent)
		frame:SetSize(self.settings.width, self.settings.height)
        frame:SetPoint("CENTER")

        local x,y = frame:GetCenter()
        self.settings.point = {
            point = "BOTTOMLEFT",
            relativeTo = "UIParent",
            relativePoint = "BOTTOMLEFT",
            ofsx = x * frame:GetEffectiveScale() - frame:GetWidth() / 2 ,
            ofsy = y * frame:GetEffectiveScale() - frame:GetHeight() / 2
        }

		----
		--Configmode texture. Green. Not initially shown
		----
		local configmodeTexture = frame:CreateTexture(nil, "BACKGROUND")
		configmodeTexture:SetTexture(0,1,0,.5)
		configmodeTexture:SetAllPoints(frame)
		configmodeTexture:Hide()

		----
		--Right Scroll Frame and child
		----
		local rightScrollFrame = CreateFrame("ScrollFrame", nil, frame)
		rightScrollFrame:SetPoint("Right")

		local rightScrollChild = CreateFrame("Frame")
		rightScrollFrame:SetScrollChild(rightScrollChild)

		local rightScrollChildProgressTexture = rightScrollChild:CreateTexture(nil, "BORDER")
		rightScrollChildProgressTexture:SetTexture(ns.Textures.HalfCircle)
		rightScrollChildProgressTexture:SetPoint("LEFT", frame, "LEFT", -rightScrollFrame:GetWidth())

		local rightScrollChildSecondaryProgressTexture = rightScrollChild:CreateTexture(nil, "BACKGROUND")
		rightScrollChildSecondaryProgressTexture:SetTexture(ns.Textures.HalfCircle)
		rightScrollChildSecondaryProgressTexture:SetPoint("LEFT", frame, "LEFT", -rightScrollFrame:GetWidth())

		----
		--Left Scroll Frame and child
		----
		local leftScrollFrame = CreateFrame("ScrollFrame", nil, frame)
		leftScrollFrame:SetPoint("LEFT")

		local leftScrollChild = CreateFrame("Frame")
		leftScrollFrame:SetScrollChild(leftScrollChild)

		local leftScrollChildProgressTexture = leftScrollChild:CreateTexture(nil, "BORDER")
		leftScrollChildProgressTexture:SetTexture(ns.Textures.HalfCircle)
		leftScrollChildProgressTexture:SetPoint("LEFT", frame)

		local leftScrollChildSecondaryProgressTexture = leftScrollChild:CreateTexture(nil, "BACKGROUND")
		leftScrollChildSecondaryProgressTexture:SetTexture(ns.Textures.HalfCircle)
		leftScrollChildSecondaryProgressTexture:SetPoint("Left", frame)

		----
		--Glass
		----
		local glassFrame = CreateFrame("Frame", frame:GetName().."GlassFrame", rightScrollFrame)
		glassFrame:SetPoint("CENTER", frame)

		local glassFrameTexture = glassFrame:CreateTexture(nil, "BACKGROUND")
		glassFrameTexture:SetTexture(ns.Textures.GlassShiny)
		glassFrameTexture:SetPoint("CENTER")

		local glassBorder = glassFrame:CreateTexture(nil, "BORDER")
		glassBorder:SetTexture(ns.Textures.BorderTexture)
		glassBorder:SetVertexColor(1, 1, 1, .8)
		glassBorder:SetPoint("CENTER")

		----
		--Hide all, because they're not shown, right?
		----
		rightScrollChildProgressTexture:Hide()
		leftScrollChildProgressTexture:Hide()
		rightScrollChildSecondaryProgressTexture:Hide()
		leftScrollChildSecondaryProgressTexture:Hide()

		----
		--Reference in self
		----
		self.frame = frame
		self.configmodeTexture = configmodeTexture
		
		self.rightScrollFrame = rightScrollFrame
		self.rightScrollChild = rightScrollChild
		self.rightScrollChildProgressTexture = rightScrollChildProgressTexture
		self.rightScrollChildSecondaryProgressTexture = rightScrollChildSecondaryProgressTexture
		
		self.leftScrollFrame = leftScrollFrame
		self.leftScrollChild = leftScrollChild
		self.leftScrollChildProgressTexture = leftScrollChildProgressTexture
		self.leftScrollChildSecondaryProgressTexture = leftScrollChildSecondaryProgressTexture

		self.glassFrame = glassFrame
		self.glassFrameTexture = glassFrameTexture
		self.glassBorder = glassBorder

        -----
        ---Popupmenu
        -----
        self.frame:SetMovable(true)
        self.frame:EnableMouse(true)
        self.frame:RegisterForDrag("LeftButton", "RightButton")
        self:AppendScript("OnDragStart", function(s, btn)
            if (self.settings.isConfigmodeEnabled or IsShiftKeyDown()) and
              btn == "LeftButton" then
                s:StartMoving()
            end
        end)
        self:AppendScript("OnDragStop", function(s)
            s:StopMovingOrSizing()
            self.settings = self:UpdateSettings()
        end)
        self:AppendScript("OnMouseDown", function(s, btn)
            if (self.settings.isConfigmodeEnabled or IsShiftKeyDown()) and
              MouseIsOver(s) and btn == "RightButton" then
                if not ns.IsPopupMenuOpen() then
                    ns.OpenPopupMenu(self)
                else
                    ns.ClosePopupMenu()
                end
            end
        end)
	end
end

--Updates the progress of the orb
function ns.Orb.Update(self)
	--Escape if GetProgressOnUpdate() doesn't exist
	if not self.GetProgressOnUpdate then
		return
	end

	--Escape if SetOrbColorOnUpdate() doesn't exist
	if not self.SetOrbColorOnUpdate then
		return
	end

	local progress, secondaryProgress = self:GetProgressOnUpdate()

	--Is progress a valid value?
	if progress then
		if progress < 0 or progress > 100 then
			return
		end
	else
		return
	end

	--Is secondaryProgress a valid value?
	if secondaryProgress then
		if secondaryProgress < 0 or secondaryProgress > 100 then
			return
		end
	end

	self:SetOrbColorOnUpdate()

	--Rotate textures
	local progressAngle = progress * 3.6 * self.settings.progressFillDirection
	self:RotateProgressTexture(progressAngle)
	if secondaryProgress then
		local secondaryProgressAngle = secondaryProgress * 3.6 * self.settings.secondaryProgressFillDirection
		self:RotateSecondaryProgressTexture(secondaryProgressAngle)
	end
end

--Rotates the progress texture to a given angle
function ns.Orb.RotateProgressTexture(self, angle)
	if type(angle) ~= "number" then
		return
	end

	if self:GetProgressFillDirection() == 1 then --Is clockwise?
		if angle <= 180 then
			lib.Helper.RotateTexture(self.rightScrollChildProgressTexture, angle)

			self.rightScrollChildProgressTexture:Show()
			self.leftScrollChildProgressTexture:Hide()
		elseif angle <= 360 then
			lib.Helper.RotateTexture(self.rightScrollChildProgressTexture, 180)
			lib.Helper.RotateTexture(self.leftScrollChildProgressTexture, angle)

			self.rightScrollChildProgressTexture:Show()
			self.leftScrollChildProgressTexture:Show()
		end
	else
		if angle >= -180 then
			lib.Helper.RotateTexture(self.leftScrollChildProgressTexture, angle - 180)

			self.leftScrollChildProgressTexture:Show()
			self.rightScrollChildProgressTexture:Hide()
		elseif angle >= -360 then
			lib.Helper.RotateTexture(self.leftScrollChildProgressTexture, -360)
			lib.Helper.RotateTexture(self.rightScrollChildProgressTexture, angle - 180)

			self.rightScrollChildProgressTexture:Show()
			self.leftScrollChildProgressTexture:Show()
		end
	end
end

--Rotates the secondary progress texture to a given angle
function ns.Orb.RotateSecondaryProgressTexture(self, angle)
	if type(angle) ~= "number" then
		return
	end

	if self:GetSecondaryProgressFillDirection() == 1 then --Is clockwise?
		if angle <= 180 then
			lib.Helper.RotateTexture(self.rightScrollChildSecondaryProgressTexture, angle)

			self.rightScrollChildSecondaryProgressTexture:Show()
			self.leftScrollChildSecondaryProgressTexture:Hide()
		elseif angle <= 360 then
			lib.Helper.RotateTexture(self.rightScrollChildSecondaryProgressTexture, 180)
			lib.Helper.RotateTexture(self.leftScrollChildSecondaryProgressTexture, angle)

			self.rightScrollChildSecondaryProgressTexture:Show()
			self.leftScrollChildSecondaryProgressTexture:Show()
		end
	else
		if angle >= -180 then
			lib.Helper.RotateTexture(self.leftScrollChildSecondaryProgressTexture, angle - 180)

			self.leftScrollChildSecondaryProgressTexture:Show()
			self.rightScrollChildSecondaryProgressTexture:Hide()
		elseif angle >= -360 then
			lib.Helper.RotateTexture(self.leftScrollChildSecondaryProgressTexture, -360)
			lib.Helper.RotateTexture(self.rightScrollChildProgressTexture, angle - 180)

			self.rightScrollChildSecondaryProgressTexture:Show()
			self.leftScrollChildSecondaryProgressTexture:Show()
		end
	end
end

--Gets the current progress fill direction for the orb.
--@return:
-- 1 is clockwise
-- -1 is counter clockwise
function ns.Orb.GetProgressFillDirection(self)
	return self.settings.progressFillDirection
end

--Gets the current secondary progress fill direction for the orb.
--@return:
-- 1 is clockwise
-- -1 is counter clockwise
function ns.Orb.GetSecondaryProgressFillDirection(self)
	return self.settings.secondaryProgressFillDirection
end

--Sets the current progress fill direction
-- 1 is clockwise
-- -1 is counter clockwise
function ns.Orb.SetProgressFillDirection(self, dir)
	if dir ~= 1 and dir ~= -1 then
		return
	end

	if self.settings.progressFillDirection ~= dir then
		self.settings.progressFillDirection = dir
	end
end

--Sets the current secondary progress fill direction
-- 1 is clockwise
-- -1 is counter clockwise
function ns.Orb.SetSecondaryProgressFillDirection(self, dir)
	if dir ~= 1 and dir ~= -1 then
		return
	end

	if self.settings.secondaryProgressFillDirection ~= dir then
		self.settings.secondaryProgressFillDirection = dir
	end
end

--Resizes the orb given a width and a height
function ns.Orb.SetSize(self, w, h)
	self.settings.width = w
	self.settings.height = h

	self.frame:SetSize(self.settings.width, self.settings.height)

	self.rightScrollFrame:SetSize(self.frame:GetWidth() / 2, self.frame:GetHeight())
	self.rightScrollChild:SetSize(self.frame:GetSize())
	self.rightScrollChildProgressTexture:SetSize(self.rightScrollChild:GetSize())
	self.rightScrollChildSecondaryProgressTexture:SetSize(self.rightScrollChild:GetSize())

	self.leftScrollFrame:SetSize(self.frame:GetWidth() /2, self.frame:GetHeight())
	self.leftScrollChild:SetSize(self.frame:GetSize())
	self.leftScrollChildProgressTexture:SetSize(self.leftScrollChild:GetSize())
	self.leftScrollChildSecondaryProgressTexture:SetSize(self.leftScrollChild:GetSize())

	self.glassFrame:SetSize(self.frame:GetSize())
	self.glassFrameTexture:SetSize(self.glassFrame:GetSize())
	self.glassBorder:SetSize(self.glassFrame:GetSize())

	--If very small, switch textures to avoid pixilation
	if self.glassFrame:GetWidth() <= 127 then
		self.glassFrameTexture:SetTexture(ns.Textures.GlassShiny_Small)
		self.glassBorder:SetTexture(ns.Textures.BorderTexture_Small)
	else
		self.glassFrameTexture:SetTexture(ns.Textures.GlassShiny)
		self.glassBorder:SetTexture(ns.Textures.BorderTexture)
	end
end

--Returns the size as listed in the orb's settings
function ns.Orb.GetSize(self)
	return self.frame:GetSize()
end

--Sets the color of progress
function ns.Orb.SetProgressColor(self, r, g, b, a)
	if r < 0 or r > 1 then
		return
	end
	if g < 0 or g > 1 then
		return
	end
	if b < 0 or b > 1 then
		return
	end
	if a < 0 or a > 1 then
		return
	end

	self.settings.progressColor = {}
	self.settings.progressColor.r = r
	self.settings.progressColor.g = g
	self.settings.progressColor.b = b
	self.settings.progressColor.a = a or 1

	self.rightScrollChildProgressTexture:SetVertexColor(
		self.settings.progressColor.r,
		self.settings.progressColor.g,
		self.settings.progressColor.b,
		self.settings.progressColor.a)
	self.leftScrollChildProgressTexture:SetVertexColor(
		self.settings.progressColor.r,
		self.settings.progressColor.g,
		self.settings.progressColor.b,
		self.settings.progressColor.a)
end

--Gets the color of progress
function ns.Orb.GetProgressColor(self)
	return self.rightScrollChildProgressTexture:GetVertexColor()
end

--Sets the color of secondaryprogress
function ns.Orb.SetSecondaryProgressColor(self, r, g, b, a)
	if r < 0 or r > 1 then
		return
	end
	if g < 0 or g > 1 then
		return
	end
	if b < 0 or b > 1 then
		return
	end
	if a < 0 or a > 1 then
		return
	end

	self.settings.secondaryProgressColor = {}
	self.settings.secondaryProgressColor.r = r
	self.settings.secondaryProgressColor.g = g
	self.settings.secondaryProgressColor.b = b
	self.settings.secondaryProgressColor.a = a or 1

	self.rightScrollChildSecondaryProgressTexture:SetVertexColor(
		self.settings.secondaryProgressColor.r,
		self.settings.secondaryProgressColor.g,
		self.settings.secondaryProgressColor.b,
		self.settings.secondaryProgressColor.a)
	self.leftScrollChildSecondaryProgressTexture:SetVertexColor(
		self.settings.secondaryProgressColor.r,
		self.settings.secondaryProgressColor.g,
		self.settings.secondaryProgressColor.b,
		self.settings.secondaryProgressColor.a)
end

--Gets the color of secondaryProgress
function ns.Orb.GetSecondaryProgressColor(self)
	return self.rightScrollChildSecondaryProgressTexture:GetVertexColor()
end

--Sets whether the secondary progress texture is shown
function ns.Orb.SetSecondaryProgressShown(self, shown)
	self.settings.isSecondaryProgressShown = shown

	if not self.settings.isSecondaryProgressShown then
		self.rightScrollChildSecondaryProgressTexture:Hide()
		self.leftScrollChildSecondaryProgressTexture:Hide()
	else
		self.rightScrollChildSecondaryProgressTexture:Show()
		self.leftScrollChildSecondaryProgressTexture:Show()
	end
end

--Returns whether the secondary progress is shown
function ns.Orb.IsSecondaryProgressShown(self)
	if self.rightScrollChildSecondaryProgressTexture:IsShown() then
		return self.leftScrollChildSecondaryProgressTexture:IsShown()
	end

	return false
end

--Registers a non-custom event
function ns.Orb.RegisterEvent(self, event)
	self.frame:RegisterEvent(event)
end

--Unregisters a non-custom event
function ns.Orb.UnregisterEvent(self, event)
	self.frame:UnregisterEvent(event)
end

--Registers a non-custom unit event
function ns.Orb.RegisterUnitEvent(self, event, unit)
	self.frame:RegisterUnitEvent(event, unit)
end

--Appends a script to a handler
function ns.Orb.AppendScript(self, handler, func)
	local old = self.frame:GetScript(handler)
	self.frame:SetScript(handler, function( ... )
		if old ~= nil then
			old(...)
		end

		func(...)
	end)
end

--Displays the orb
function ns.Orb.Show(self)
	if not self.frame:IsShown() and self.frame ~= nil then
		self.frame:Show()
		self.settings.isShown = true
		self:Update()
	end
end

--Hides the orb
function ns.Orb.Hide(self)
	if self.frame:IsShown() and self.frame ~= nil and not self.settings.isConfigmodeEnabled then
		self.settings.isShown = false
		self.frame:Hide()
	end
end

--Returns whether the orb is shown or not
function ns.Orb.IsShown(self)
	return self.frame:IsShown() or false
end

--Sets the point of the orb
function ns.Orb.SetPoint(self, point, relativeTo, relativePoint, ofsx, ofsy)
	self.frame:SetPoint(point, relativeTo, relativePoint, ofsx, ofsy)
end

--Gets if the orb uses default coloring
function ns.Orb.GetUseDefaultColor(self)
    return self.settings.useDefaultColor
end

--Sets if the orb uses default coloring
function ns.Orb.SetUseDefaultColor(self, useDefault)
    self.settings.useDefaultColor = useDefault
end

--Applies a given set of settings, or reapplies the current set
function ns.Orb.ApplySettings(self, settings)
	--Visibility
	if settings.isShown then self:Show() else self:Hide() end

	--Size
	self:SetSize(settings.width, settings.height)

	--Positional
	self.frame:SetParent(settings.parentFrame)
	self:SetPoint(
		settings.point.point,
		settings.point.relativeTo,
		settings.point.relativePoint,
		settings.point.ofsx,
		settings.point.ofsy)

	--Fill direction
	self:SetProgressFillDirection(settings.progressFillDirection)
	self:SetSecondaryProgressFillDirection(settings.secondaryProgressFillDirection)

    --use default coloring
    self:SetUseDefaultColor(settings.useDefaultColor)

	--Progress color
	if settings.progressColor then
		self:SetProgressColor(
			settings.progressColor.r,
			settings.progressColor.g,
			settings.progressColor.b,
			settings.progressColor.a)
	end

	--Secondary Progress color
	if settings.secondaryProgressColor then
		self:SetSecondaryProgressColor(
			settings.secondaryProgressColor.r,
			settings.secondaryProgressColor.g,
			settings.secondaryProgressColor.b,
			settings.secondaryProgressColor.a)
    end
end

--Returns a table of updated settings
function ns.Orb.UpdateSettings(self)
	local newSettings = {}

	--Visibility
	newSettings.isShown = self:IsShown()
	newSettings.isSecondaryProgressShown = self:IsSecondaryProgressShown()

	--Size
	do
		local w,h = self:GetSize()
		newSettings.width = w
		newSettings.height = h
	end

	--Positional
	newSettings.parentFrame = self.frame:GetParent()
	do
		--local p, rt, rp, x, y = self.frame:GetPoint()
		--local _, rt = self.frame:GetPoint()
        local x,y = self.frame:GetCenter()
        newSettings.point = {
            point = "BOTTOMLEFT",
            relativeTo = "UIParent",
            relativePoint = "BOTTOMLEFT",
            ofsx = x * self.frame:GetEffectiveScale() - self.frame:GetWidth() / 2 ,
            ofsy = y * self.frame:GetEffectiveScale() - self.frame:GetHeight() / 2
		}
	end

	--Fill direction
	newSettings.progressFillDirection = self:GetProgressFillDirection()
	newSettings.secondaryProgressFillDirection = self:GetSecondaryProgressFillDirection()

    --use default coloring
    newSettings.useDefaultColor = self:GetUseDefaultColor()

	--Progress color
	do
		local r,g,b,a = self:GetProgressColor()
		newSettings.progressColor = {}
		newSettings.progressColor.r = r
		newSettings.progressColor.g = g
		newSettings.progressColor.b = b
		newSettings.progressColor.a = a
	end

	--Secondary Progress color
	do
		local r,g,b,a = self:GetSecondaryProgressColor()
		newSettings.secondaryProgressColor = {}
		newSettings.secondaryProgressColor.r = r
		newSettings.secondaryProgressColor.g = g
		newSettings.secondaryProgressColor.b = b
		newSettings.secondaryProgressColor.a = a	
	end

    --Configmode
    newSettings.isConfigmodeEnabled = self.settings.isConfigmodeEnabled

	--return the settings
	return newSettings
end

function ns.Orb.New()
	local self = {}
	self.settings = {}

    setmetatable(self, ns.Orb)

	return self
end