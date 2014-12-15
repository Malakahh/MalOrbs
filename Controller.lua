------------------------------------------------------------
-- | MalOrbs											| --
-- | Creates orbs for various purposes.					| --
-- | Copyright (c) 2014 Malakahh. All Rights Reserved.	| --
------------------------------------------------------------

local addonName, ns = ...

ns.orbCount = 0
ns.OrbTypes = {}

--Registers an orb type
function ns.RegisterOrbType(type)
    ns.OrbTypes[type] = true
end

----
--Textures
----
ns.Textures = {}
ns.Textures.BorderTexture = "Interface\\AddOns\\MalOrbs\\Assets\\RingBorder.tga"
ns.Textures.BorderTexture_Small = "Interface\\AddOns\\MalOrbs\\Assets\\RingBorder_Small.tga"
ns.Textures.HalfCircle = "Interface\\AddOns\\MalOrbs\\Assets\\HalfCircle.tga"
ns.Textures.GlassShiny = "Interface\\AddOns\\MalOrbs\\Assets\\GlassShiny.tga"
ns.Textures.GlassShiny_Small = "Interface\\AddOns\\MalOrbs\\Assets\\GlassShiny_Small.tga"
ns.Textures.GlassSolid = "Interface\\AddOns\\MalOrbs\\Assets\\GlassSolid.tga"
ns.Textures.GlassSolid_Small = "Interface\\AddOns\\MalOrbs\\Assets\\GlassSolid_Small"

----
--Fonts
----

ns.Fonts = {}
ns.Fonts.FRIZQT__ = "Fonts\\FRIZQT__.TTF"






if not ns.Orbs then
    ns.Orbs = {}
end

----
--Functions/Methods
----

local function GetCommandParam(msg)
    if msg ~= nil then
        return msg:match("^([a-zA-Z0-9]*)[,]*%s*(.-)$")
    else
        return nil
    end
end

function ns.SpawnOrbsWithProfile(profile)
    if not profile or not profile.Orbs then return end

    --Cleanup
    for _,v in pairs(ns.Orbs) do
        ns.RemoveOrb(v)
    end
    wipe(ns.Orbs)

    --Make new orbs
    local Orbs = profile.Orbs
    local orb
    for _,v in pairs(Orbs) do
        orb = ns.SpawnOrb(v.type, v.width, v.height)
        orb:ApplySettings(v)
        orb = nil
    end
end

----
--Commands
----

function ns.SpawnOrb(type, width, height)
	if type then
		width = width or 128
		height = height or 128
		type = string.lower(type)
		
		local orb

		if type == "exporb" then
			orb = ns.ExpOrb.New()
			orb:Init(nil, width, height)
		elseif type == "reporb" then
			orb = ns.RepOrb.New()
			orb:Init(nil, width, height)
		elseif type == "castingorb" then
			orb = ns.CastingOrb.New()
			orb:Init(nil, width, height)
		else
			print("MalOrbs: Unkown type")
			return
		end

		orb:Update()
		return orb
	else
		print("MalOrbs: Could not spawn orb. No type given.")
		return
	end
end

function ns.RemoveOrb(orb)
    if not orb then return end

    orb.frame:Hide() --Not using orb:Hide() as it is disabled during configmode
    local orbName = orb.frame:GetName()
    for k,v in pairs(ns.Orbs) do
        if v.frame:GetName() == orbName then
            wipe(ns.Orbs[k])
            ns.Orbs[k] = nil
            break;
        end
    end


    wipe(orb)
end

function ns.ConfigmodeToggle()
    local profile = ns.ProfileManager:GetCurrentProfile()
    if not profile.configmode then
        ns.ConfigmodeEnter()
    else
        ns.ConfigmodeLeave()
    end
end

function ns.ConfigmodeEnter()
    local profile = ns.ProfileManager:GetCurrentProfile()

    for _,v in pairs(ns.Orbs) do
        v:ConfigmodeEnter()
    end

    profile.configmode = true
end

function ns.ConfigmodeLeave()
    local profile = ns.ProfileManager:GetCurrentProfile()
    profile.configmode = nil

    for _,v in pairs(ns.Orbs) do
        v:ConfigmodeLeave()
    end
end

----
--Slash command handler
----


SLASH_MALORBSNEW1 = '/malorbs'
local function SlashCommandHandler(msg, editBox)
	local command, rest = GetCommandParam(msg)

	if command == "spawn" then
		local type, rest = GetCommandParam(rest)

		ns.SpawnOrb(type)
	elseif command == "types" then
		if ns.OrbTypes then
			print("MalOrbs - OrbTypes:")
			for k,v in pairs(ns.OrbTypes) do
				print(" - "..k)
			end
		else
			print("MalOrbs: No types found.")
        end
    elseif command == "configmode" or command == "cm" then
        ns.ConfigmodeToggle()
    elseif command == "test" then
        ns.Test()
	else --Help
		print("MalOrbs - help:")

		print("/malorbs spawn <type>")
		print(" - Creates an orb of the given type.")

		print("/malorbs types")
		print(" - Lists the different types of orbs")

        print("/malorbs configmode")
        print(" - Toggles configmode")

        print("/malorbs cm")
        print(" - Shorthand for /malorbs configmode")
	end
end
SlashCmdList["MALORBSNEW"] = SlashCommandHandler

----
--Initialize addon
----

function ns.Test()
    print("No test to be performed...")
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and addonName == ... then
        MalOrbs_SV = MalOrbs_SV or {}
        MalOrbs_SV.Profiles = MalOrbs_SV.Profiles or {}

        ns.InitOptionsPanel()
        ns.InitProfilePanel()

        --Make sure we have selected the player profile
        ns.ProfileManager:SwitchProfile(ns.GetFullUnitName("player"))
        ns.SpawnOrbsWithProfile(ns.ProfileManager:GetCurrentProfile())
    elseif event == "PLAYER_LOGOUT" then
        --Make sure the playerprofile is selected
        ns.ProfileManager:SwitchProfile(ns.GetFullUnitName("player"))

        --Get current profile
        local profile = ns.ProfileManager:GetCurrentProfile()

        --Delete what was previously known
        if profile.Orbs then
            wipe(profile.Orbs)
        else
            profile.Orbs = {}
        end

        --Repopulate
        for k,v in pairs(ns.Orbs) do
            v.settings = v:UpdateSettings()
            profile.Orbs[k] = v.settings
        end

        if profile.configmode then
            ns.ConfigmodeLeave()
        end
    end
end)