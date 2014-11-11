------------------------------------------------------------
-- | MalOrbs											| --
-- | Creates orbs for various purposes.					| --
-- | Copyright (c) 2014 Malakahh. All Rights Reserved.	| --
------------------------------------------------------------

local _, ns = ...

local lib = LibStub("MalUI-1.0")
if not lib then return end

--Class table
ns.CenterContentOrb = {}
ns.CenterContentOrb.__index = ns.CenterContentOrb

--Initializes the orb
function ns.CenterContentOrb.Init(self, parentFrame, width, height)
	self.ccBase.Init(self, parentFrame, width, height)

	----
	--CenterContentFrame
	----
	local ccFrame = CreateFrame("Frame", self.frame:GetName().."ccFrame", self.glassFrame)
	ccFrame:SetPoint("CENTER")

	local ccFrameBackground = ccFrame:CreateTexture(nil, "BACKGROUND")
	ccFrameBackground:SetTexture(ns.Textures.GlassSolid)
	ccFrameBackground:SetVertexColor(0,0,0,1)
	ccFrameBackground:SetAllPoints()

	----
	--CenterContentGlass
	----
	local ccGlassFrame = CreateFrame("Frame", nil, ccFrame)
	ccGlassFrame:SetPoint("CENTER")

	local ccGlassFrameTexture = ccGlassFrame:CreateTexture(nil, "BACKGROUND")
	ccGlassFrameTexture:SetTexture(ns.Textures.GlassShiny)
	ccGlassFrameTexture:SetAllPoints()

	local ccGlassBorder = ccGlassFrame:CreateTexture(nil, "BORDER")
	ccGlassBorder:SetTexture(ns.Textures.BorderTexture)
	ccGlassBorder:SetVertexColor(lib.Helper.AlphaHexColorToColor( 0xFFFFFFCC ))
	ccGlassBorder:SetAllPoints()

	----
	--Reference in self
	----
	self.ccFrame = ccFrame
	self.ccFrameBackground = ccFrameBackground

	self.ccGlassFrame = ccGlassFrame
	self.ccGlassFrameTexture = ccGlassFrameTexture
	self.ccGlassBorder = ccGlassBorder
end

--Gets the size of the center content frame
function ns.CenterContentOrb.CenterContentGetSize(self)
	return self.ccFrame:GetSize()
end

--Places content in the center content frame
function ns.CenterContentOrb.SetCenterContent(self, contentFrame)
	contentFrame:SetParent(self.ccFrame)
	contentFrame:SetPoint("CENTER")
	self.ccGlassFrame:SetParent(contentFrame)
end

--Resizes the orb given a width and a height
function ns.CenterContentOrb.SetSize(self, width, height)
	self.ccBase.SetSize(self, width, height)

	do
		local w,h = self.frame:GetSize()
		self.ccFrame:SetSize(w / 2, h / 2)
	end

	self.ccFrameBackground:SetSize(self.ccFrame:GetSize())
	self.ccGlassFrame:SetSize(self.ccFrame:GetSize())
	self.ccGlassFrameTexture:SetSize(self.ccGlassFrame:GetSize())
	self.ccGlassBorder:SetSize(self.ccGlassFrame:GetSize())
	
	if self.ccGlassFrame:GetWidth() <= 127 then
		self.ccGlassFrameTexture:SetTexture(ns.Textures.GlassShiny_Small)
		self.ccGlassBorder:SetTexture(ns.Textures.BorderTexture_Small)
		self.ccFrameBackground:SetTexture(ns.Textures.GlassSolid_Small)
	else
		self.ccGlassFrameTexture:SetTexture(ns.Textures.GlassShiny)
		self.ccGlassBorder:SetTexture(ns.Textures.BorderTexture)
		self.ccFrameBackground:SetTexture(ns.Textures.GlassSolid)
	end
end

function ns.CenterContentOrb.New()
	local self = ns.Orb.New()
	self.ccBase = {}

    setmetatable(self, ns.CenterContentOrb)
    for k,v in pairs(ns.Orb) do
        if self[k] then
            self.ccBase[k] = v
        else
            self[k] = v
        end
    end

	return self
end