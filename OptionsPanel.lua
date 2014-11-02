------------------------------------------------------------
-- | MalOrbs											| --
-- | Creates orbs for various purposes.					| --
-- | Copyright (c) 2014 Malakahh. All Rights Reserved.	| --
------------------------------------------------------------

local _, ns = ...

local lib = LibStub("MalUI-1.0")
if not lib then return end

ns.Options = ns.Options or {}

----
--Options Panel
----
function ns.InitOptionsPanel()
    local frame = CreateFrame("Frame", "MalOrbsOptionsPanel", UIParent)
    frame.name = "MalOrbs"
    ns.Options.OptionsPanel = frame

    --Title
    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetPoint("TOPRIGHT", -16, -16)
    title:SetJustifyH("LEFT")
    title:SetText("MalOrbs")

    --Type drop down
    local TypeDropDown = lib.DropDown.Create(frame, "TypeDropDown", 170, 24)
    TypeDropDown:SetPoint("TOPLEFT", title, "BOTTOMLEFT", -16, -10)
    for k,_ in pairs(ns.OrbTypes) do
        TypeDropDown.list:NewItem(k)
    end
    TypeDropDown:SetSelected(TypeDropDown.list[1].text)

    --Add button
    local AddBtn = CreateFrame("Button", frame:GetName().."AddBtn", frame, "UIPanelButtonTemplate")
    AddBtn:SetSize(120, 24)
    AddBtn:SetText("New Orb")
    AddBtn:SetScript("OnClick", function(self, mouseBtn, isPressed)
        local selected = UIDropDownMenu_GetText(TypeDropDown)
        ns.SpawnOrb(selected)
    end)
    AddBtn:SetPoint("TOPLEFT", TypeDropDown, "TOPRIGHT", 3, -2)

    --Configmode button
    local ConfigmodeBtn = CreateFrame("Button", frame:GetName().."ConfigmodeBtn", frame, "UIPanelButtonTemplate")
    ConfigmodeBtn:SetSize(277, 24)
    ConfigmodeBtn:SetText("Config Mode")
    ConfigmodeBtn:SetScript("OnClick", function(self, mouseBtn, isPressed)
        ns.ProfileManager:SwitchProfile(ns.GetFullUnitName("player"))
        local profile = ns.ProfileManager:GetCurrentProfile()
        if profile.configmode then
            ns.ConfigmodeLeave()
        else
            ns.ConfigmodeEnter()
        end
    end)
    ConfigmodeBtn:SetPoint("TOPLEFT", TypeDropDown, "BOTTOMLEFT", 16, -3)


    --Add to interface options
    InterfaceOptions_AddCategory(ns.Options.OptionsPanel)
end
