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
--Methods
----
function ns.GetFullUnitName(unit)
    local name, realm = UnitName(unit)

    if not realm then
        realm = GetRealmName()
    end

    return name.."-"..realm
end

----
--Profile Panel
----
function ns.InitProfilePanel()
    local frame = CreateFrame("Frame", "MalOrbsProfilePanel", UIParent)
    frame.name = "Profiles"
    frame.parent = ns.Options.OptionsPanel
    ns.Options.ProfilePanel = frame
    ns.ProfileManager = lib.ProfileManager.Create(MalOrbs_SV)

    local ProfileManager = ns.ProfileManager
    local myName = ns.GetFullUnitName("player")

    --Create player profile if it doesn't exist
    if not ProfileManager:GetProfile(myName) then
        ProfileManager:NewProfile(myName)
    end

    --Set current profile to curren player
    ProfileManager:SwitchProfile(myName)

    --Title
    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetPoint("TOPRIGHT", -16, -16)
    title:SetJustifyH("LEFT")
    title:SetText("Profiles")

    --Profile drop down
    local ProfileDropDown = lib.DropDown.Create(frame, "ProfileDropDown", 170, 24)
    ProfileDropDown:SetPoint("TOPLEFT", title, "BOTTOMLEFT", -16, -10)
    for k,_ in pairs(MalOrbs_SV.Profiles) do
        ProfileDropDown.list:NewItem(k)
    end
    ProfileDropDown:SetSelected(myName)

    --Copy Profile Btn
    local CopyBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    CopyBtn:SetSize(120,24)
    CopyBtn:SetText("Copy Profile")
    CopyBtn:SetScript("OnClick", function(self, mouseBtn, isPressed)
        local selected = ProfileDropDown:GetSelected()
        local popup = lib.DialogMessage.Acquire("Profile Copy",
            "You are about to copy the profile of "..selected..". \n Do you wish to proceed?",
            function()
                --Make sure we have selected the playerprofile
                ns.ProfileManager:SwitchProfile(ns.GetFullUnitName("player"))

                --Copy profile
                ns.ProfileManager:CopyProfile(selected)

                --Apply the profile
                local profile = ns.ProfileManager:GetCurrentProfile()

                ns.SpawnOrbsWithProfile(ns.ProfileManager:GetCurrentProfile())

                --Reset selected and release dialog
                ProfileDropDown:SetSelected(ns.GetFullUnitName("player"))
                lib.DialogMessage.Release()
            end,
            lib.DialogMessage.Release)
        popup:Show()
    end)
    CopyBtn:SetPoint("TOPLEFT", ProfileDropDown, "BOTTOMLEFT", 16, -3)

    --Delete Btn
    local DeleteBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    DeleteBtn:SetSize(120, 24)
    DeleteBtn:SetText("Delete Profile")
    DeleteBtn:SetScript("Onclick", function(self, mouseBtn, isPressed)
        local selected = ProfileDropDown:GetSelected()
        local popup = lib.DialogMessage.Acquire("Profile Deletion",
            "You are about to DELETE the profile of "..selected..". Do you wish to proceed?",
            function()
                ns.ProfileManager:DeleteProfile(selected)
                ProfileDropDown.list:Item(selected):Remove()

                local playerName = ns.GetFullUnitName("player")

                if selected == playerName then
                    ns.ProfileManager:NewProfile(playerName)
                    ns.ProfileManager:SwitchProfile(playerName)
                    ProfileDropDown.list:NewItem(playerName)
                    ProfileDropDown:SetSelected(playerName)
                    ns.SpawnOrbsWithProfile(ns.ProfileManager:GetCurrentProfile())
                else
                    ns.ProfileManager:SwitchProfile(playerName)
                    ProfileDropDown:SetSelected(playerName)
                end

                lib.DialogMessage.Release()
            end,
            lib.DialogMessage.Release)
        popup:Show()
    end)
    DeleteBtn:SetPoint("TOPLEFT", CopyBtn, "BOTTOMLEFT", 0, -3)

    --Add to interface options
    InterfaceOptions_AddCategory(ns.Options.ProfilePanel)
end
