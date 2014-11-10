------------------------------------------------------------
-- | MalOrbs											| --
-- | Creates orbs for various purposes.					| --
-- | Copyright (c) 2014 Malakahh. All Rights Reserved.	| --
------------------------------------------------------------

local _, ns = ...

local lib = LibStub("MalUI-1.0")
if not lib then return end

local FRAME_PADDING = 14
local FRAME_PADDING_TOP = 20 + FRAME_PADDING
local FRAME_PADDING_BOTTOM = 24 + FRAME_PADDING
local BUTTON_SPACING = 4

local tooltipBackdrop = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = {
        left = 5,
        right = 5,
        top = 5,
        bottom = 4
    }
}

local currOrb

-----
---Create all frames
-----
local baseFrame = CreateFrame("Frame", "MalOrbs_PopupOptions", UIParent)
local genericFrame = CreateFrame("Frame", baseFrame:GetName().."Generic", baseFrame)
local expFrame = CreateFrame("Frame", baseFrame:GetName().."Exp", baseFrame)
local repFrame = CreateFrame("Frame", baseFrame:GetName().."Rep", baseFrame)
local castingFrame = CreateFrame("Frame", baseFrame:GetName().."Casting", baseFrame)

local function HideFrames()
    baseFrame:Hide()
    genericFrame:Hide()
    expFrame:Hide()
    repFrame:Hide()
    castingFrame:Hide()
end

HideFrames()

-----
---Base frame
-----

baseFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = {
        left = 11,
        right = 12,
        top = 12,
        bottom = 9
    }
})
baseFrame:SetBackdropColor(0.09, 0.09, 0.09);
baseFrame:SetClampedToScreen(true)
baseFrame:SetSize(600, 300)
baseFrame:SetFrameLevel(10)
baseFrame:SetMovable(true)
baseFrame:EnableMouse(true)
baseFrame:RegisterForDrag("LeftButton")
baseFrame:SetScript("OnDragStart", function(s)
    s:StartMoving()
end)
baseFrame:SetScript("OnDragStop", function(s)
    s:StopMovingOrSizing()
end)

local function discard()
    if not currOrb then return end

    currOrb:ApplySettings(currOrb.oldSettings)
    currOrb.settings = currOrb:UpdateSettings()

    currOrb:ConfigmodeLeave()
    baseFrame:Hide()
end

local function save()
    if not currOrb then return end

    currOrb.settings = currOrb:UpdateSettings()

    currOrb:ConfigmodeLeave()
    baseFrame:Hide()
end

local function remove()
    if not currOrb then return end

    ns.RemoveOrb(currOrb)
    baseFrame:Hide()
end

local function ShowColorPicker()

end

--titles
local genericTitle = baseFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
genericTitle:SetPoint("TOPLEFT", FRAME_PADDING, -FRAME_PADDING)
genericTitle:SetPoint("TOPRIGHT", -baseFrame:GetWidth() / 2 - FRAME_PADDING / 3, -FRAME_PADDING)
genericTitle:SetJustifyH("CENTER")
genericTitle:SetText("Generic Settings:")

local typeTitle = baseFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
typeTitle:SetPoint("TOPRIGHT", -FRAME_PADDING, -FRAME_PADDING)
typeTitle:SetPoint("TOPLEFT", baseFrame:GetWidth() / 2 + FRAME_PADDING / 3, -FRAME_PADDING)
typeTitle:SetJustifyH("CENTER")
typeTitle:SetText("Type Specific Settings:")

--buttons
local saveBtn = CreateFrame("Button", baseFrame:GetName().."SaveBtn", baseFrame, "UIPanelButtonTemplate")
local discardBtn = CreateFrame("Button", baseFrame:GetName().."DiscardBtn", baseFrame, "UIPanelButtonTemplate")
local removeBtn = CreateFrame("Button", baseFrame:GetName().."RemoveBtn", baseFrame, "UIPanelButtonTemplate")

discardBtn:SetPoint("BOTTOM", baseFrame, "BOTTOM", 0, FRAME_PADDING)
discardBtn:SetSize(120, 24)
discardBtn:SetText("Discard Changes")
discardBtn:SetScript("OnClick", discard)

saveBtn:SetPoint("RIGHT", discardBtn, "LEFT", -BUTTON_SPACING, 0)
saveBtn:SetSize(120, 24)
saveBtn:SetText("Save Changes")
saveBtn:SetScript("OnClick", save)

removeBtn:SetPoint("LEFT", discardBtn, "RIGHT", BUTTON_SPACING, 0)
removeBtn:SetSize(120, 24)
removeBtn:SetText("Remove Orb")
removeBtn:SetScript("OnClick", remove)

-----
---Generic frame
-----

genericFrame:SetBackdrop(lib.Helper.CopyTable(tooltipBackdrop))
genericFrame:SetBackdropColor(0.09, 0.09, 0.09);
genericFrame:SetPoint("TOPLEFT", baseFrame, "TOPLEFT", FRAME_PADDING, -FRAME_PADDING_TOP)
genericFrame:SetPoint("BOTTOMRIGHT", baseFrame, "BOTTOM", -FRAME_PADDING / 3, FRAME_PADDING_BOTTOM)

--Set X
local fontX = genericFrame:CreateFontString()
fontX:SetFont(ns.Fonts.FRIZQT__, 11)
fontX:SetPoint("TOPLEFT", genericFrame, "TOPLEFT", 10, -10)
fontX:SetText("X Position:")

local editboxX = CreateFrame("EditBox", genericFrame:GetName().."EditBoxX", genericFrame, "InputBoxTemplate")
editboxX:SetNumeric(true)
editboxX:SetSize((baseFrame:GetWidth() / 2) - FRAME_PADDING * 2 - 10, 24)
editboxX:SetAutoFocus(false)
editboxX:SetPoint("TOPLEFT", fontX, "BOTTOMLEFT", 2, -3)
editboxX:SetScript("OnEnterPressed", function()
    if not currOrb then return end
    local point = currOrb:UpdateSettings().point
    local p, rt, rp, x, y = point.point, point.relativeTo, point.relativePoint, point.ofsx, point.ofsy
    currOrb:SetPoint(p, rt, rp, editboxX:GetText(), y)
end)

--Set Y
local fontY = genericFrame:CreateFontString()
fontY:SetFont(ns.Fonts.FRIZQT__, 11)
fontY:SetPoint("TOPLEFT", editboxX, "BOTTOMLEFT", -2, -3)
fontY:SetText("Y Position:")

local editboxY = CreateFrame("EditBox", genericFrame:GetName().."EditBoxY", genericFrame, "InputBoxTemplate")
editboxY:SetNumeric(true)
editboxY:SetSize((baseFrame:GetWidth() / 2) - FRAME_PADDING * 2 - 10, 24)
editboxY:SetAutoFocus(false)
editboxY:SetPoint("TOPLEFT", fontY, "BOTTOMLEFT", 2, -3)
editboxY:SetScript("OnEnterPressed", function()
    if not currOrb then return end
    local point = currOrb:UpdateSettings().point
    local p, rt, rp, x, y = point.point, point.relativeTo, point.relativePoint, point.ofsx, point.ofsy
    currOrb:SetPoint(p, rt, rp, x, editboxY:GetText())
end)

--Set radius
local fontR = genericFrame:CreateFontString()
fontR:SetFont(ns.Fonts.FRIZQT__, 11)
fontR:SetPoint("TOPLEFT", editboxY, "BOTTOMLEFT", -2, -3)
fontR:SetText("Radius:")

local editboxR = CreateFrame("EditBox", genericFrame:GetName().."EditBoxR", genericFrame, "InputBoxTemplate")
editboxR:SetNumeric(true)
editboxR:SetSize((baseFrame:GetWidth() / 2) - FRAME_PADDING * 2 - 10, 24)
editboxR:SetAutoFocus(false)
editboxR:SetPoint("TOPLEFT", fontR, "BOTTOMLEFT", 2, -3)
editboxR:SetScript("OnEnterPressed", function()
    if not currOrb then return end
    currOrb:SetSize(editboxR:GetText() * 2, editboxR:GetText() * 2)
end)

--Fill Direction
local fillDirection = CreateFrame("CheckButton", genericFrame:GetName().."PrimaryFillDirectionCheckButton", genericFrame, "ChatConfigCheckButtonTemplate")
fillDirection:SetPoint("TOPLEFT", editboxR, "BOTTOMLEFT", -8, -3)
_G[fillDirection:GetName().."Text"]:SetText("Clockwise Primary Fill Direction")
fillDirection:SetScript("OnClick", function()
    if fillDirection:GetChecked() and currOrb.settings.progressFillDirection ~= 1 then
        currOrb:SetProgressFillDirection(1)
        currOrb:SetSecondaryProgressFillDirection(currOrb.settings.secondaryProgressFillDirection * -1)
    elseif currOrb.settings.progressFillDirection ~= -1 then
        currOrb:SetProgressFillDirection(-1)
        currOrb:SetSecondaryProgressFillDirection(currOrb.settings.secondaryProgressFillDirection * -1)
    end

    currOrb:Update()
end)

--ColorPicker
local colorPickerBtn = CreateFrame("Button", genericFrame:GetName().."ColorPicketButton", genericFrame)
colorPickerBtn:SetPoint("TOPLEFT", fillDirection, "BOTTOMLEFT", 0, -3)
colorPickerBtn:SetSize(24, 24)
colorPickerBtn:SetScript("OnClick", ShowColorPicker)

local colorPickerBtnTexture = colorPickerBtn:CreateTexture()
colorPickerBtnTexture:SetAllPoints()


local function SetGenericOrb(orb)
    if not orb then return end

    currOrb = orb

    HideFrames()
    baseFrame:Show()
    genericFrame:Show()

    --Enter configmode
    orb:ConfigmodeEnter()

    local horizontalCenter, _ = lib.Helper.GetScreenResolution()
    horizontalCenter = math.floor(horizontalCenter / 2 + 0.5)
    --verticalCenter = math.floor(verticalCenter / 2 + 0.5)


    local x,y = orb.frame:GetCenter() --This might act weird due to UI scaling. Don't know.
    local w,_ = orb:GetSize()

    --Baseframe position and size
    baseFrame:ClearAllPoints()
    if x > horizontalCenter then --orb is on the right side of the screen
        baseFrame:SetPoint("TOPRIGHT", orb.frame, "TOPLEFT", 0, 0)
    else --left
        baseFrame:SetPoint("TOPLEFT", orb.frame, "TOPRIGHT", 0, 0)
    end

    --Fill the editboxes
    editboxX:SetNumber(math.floor(x - orb.frame:GetWidth() / 2 + 0.5))
    editboxY:SetNumber(math.floor(y - orb.frame:GetHeight() / 2 + 0.5))
    editboxR:SetNumber(math.floor(w / 2 + 0.5))

    --Fill the checkboxes
    local primFill = false
    if orb:GetProgressFillDirection() == 1 then primFill = true end
    fillDirection:SetChecked(primFill)
end

-----
---Experience frame
-----

expFrame:SetBackdrop(lib.Helper.CopyTable(tooltipBackdrop))
expFrame:SetBackdropColor(0.09, 0.09, 0.09)
expFrame:SetPoint("TOPLEFT", baseFrame, "TOP", FRAME_PADDING / 3, -FRAME_PADDING_TOP)
expFrame:SetPoint("BOTTOMRIGHT", baseFrame, "BOTTOMRIGHT", -FRAME_PADDING, FRAME_PADDING_BOTTOM)

local function SetExpOrb(orb)
    SetGenericOrb(orb)
    expFrame:Show()
end

-----
---Reputation frame
-----

repFrame:SetBackdrop(lib.Helper.CopyTable(tooltipBackdrop))
repFrame:SetBackdropColor(0.09, 0.09, 0.09)
repFrame:SetPoint("TOPLEFT", baseFrame, "TOP", FRAME_PADDING / 3, -FRAME_PADDING_TOP)
repFrame:SetPoint("BOTTOMRIGHT", baseFrame, "BOTTOMRIGHT", -FRAME_PADDING, FRAME_PADDING_BOTTOM)

local function SetRepOrb(orb)
    SetGenericOrb(orb)
    repFrame:Show()
end

-----
---Casting frame
-----

castingFrame:SetBackdrop(lib.Helper.CopyTable(tooltipBackdrop))
castingFrame:SetBackdropColor(0.09, 0.09, 0.09)
castingFrame:SetPoint("TOPLEFT", baseFrame, "TOP", FRAME_PADDING / 3, -FRAME_PADDING_TOP)
castingFrame:SetPoint("BOTTOMRIGHT", baseFrame, "BOTTOMRIGHT", -FRAME_PADDING, FRAME_PADDING_BOTTOM)

--Unit
local fontUnit = castingFrame:CreateFontString()
fontUnit:SetFont(ns.Fonts.FRIZQT__, 11)
fontUnit:SetPoint("TOPLEFT", castingFrame, "TOPLEFT", 10, -3)
fontUnit:SetText("Unit:")

local unitDropDown = lib.DropDown.Create(castingFrame, "UnitDropDown", baseFrame:GetWidth() * 0.5 - FRAME_PADDING, 24)
unitDropDown:SetPoint("TOPLEFT", fontUnit, "BOTTOMLEFT", -10, -3)
local list = unitDropDown.list
list:NewItem("player")
list:NewItem("focus")
list:NewItem("pet")
list:NewItem("target")
list:NewItem("targettarget")
unitDropDown:SetSelected(list[1].text)
unitDropDown:SetOnSelectionChanged(function(self, selectedItem)
    currOrb:SetUnit(selectedItem.text)
end)

local function SetCastingOrb(orb)
    SetGenericOrb(orb)
    castingFrame:Show()
end

-----
---Methods
-----

function ns.OpenPopupMenu(orb)
    local type = orb:GetOrbType()
    if type == "ExpOrb" then
        SetExpOrb(orb)
    elseif type == "RepOrb" then
        SetRepOrb(orb)
    elseif type == "CastingOrb" then
        SetCastingOrb(orb)
    end
end

function ns.ClosePopupMenu()
    if not currOrb then return end
    HideFrames()
    currOrb:ConfigmodeLeave()
end

function ns.IsPopupMenuOpen()
    return baseFrame:IsShown()
end