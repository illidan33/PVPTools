-- app global vars
TargetCooldowns = LibStub("AceAddon-3.0"):NewAddon("TargetCooldowns", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TargetCooldowns")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local AppName = "TargetCooldowns"
local Spells = {}
local GUID

-- default config
local options = {
    name = "|cffDDA0DDPVPInfo|r",
    handler = PVPInfo,
    type = "group",
    args = {
        clearCache = {
            type = "execute",
            name = L["clearCache"],
            order = 1,
            func = function()
                PVPInfo.db.profile.cache = {}
            end,
        },
        showDuel = {
            type = "toggle",
            name = L["showDuel"],
            desc = L["toggleDuel"],
            get = function(info)
                return PVPInfo.db.profile.showDuel
            end,
            set = function(info, value)
                PVPInfo.db.profile.cache = {}
                PVPInfo.db.profile.showDuel = value or nil
            end,
        },
    },
}

local defaults = {
    profile = {
        showDuel = true,
        spells = DefaultSpells,
        currentSpells = {},
    },
}

function TargetCooldowns:OnInitialize()
    -- Called when the addon is loaded
    self.db = LibStub("AceDB-3.0"):New("TargetCooldownsDB", defaults, true)
    LibStub("AceConfig-3.0"):RegisterOptionsTable(AppName, options, { "tc", "targetcd" })
    self.optionsFrame = AceConfigDialog:AddToBlizOptions(AppName, AppName)

    self:RegisterChatCommand("tc", "ShowConfig")
    self:RegisterChatCommand("targetcd", "ShowConfig")
end

function TargetCooldowns:OnEnable()
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED");
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED");
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
end

function TargetCooldowns:PLAYER_TARGET_CHANGED()
    self:Print("PLAYER_TARGET_CHANGED")

    if not UnitIsVisible("target") then
        return
    end

    local guid = UnitGUID("target")
    if not guid and guid == "" then
        return
    end

    GUID = guid
end

function TargetCooldowns:COMBAT_LOG_EVENT_UNFILTERED()
    self:Print("COMBAT_LOG_EVENT_UNFILTERED")

    local currentTime = GetTime()
    local _, eventType, _, _, srcName, srcFlags, _, _, _, _, _, spellID, spellName = CombatLogGetCurrentEventInfo();
    if bit.band(srcFlags, COMBATLOG_OBJECT_TARGET) > 0 then
        if (eventType == "SPELL_CAST_SUCCESS" or eventType == "SPELL_AURA_APPLIED" or eventType == "SPELL_MISSED" or eventType == "SPELL_SUMMON") then
            local name, _, icon, castTime, _, _, _ = GetSpellInfo(spellID)
            for sID, cd in pairs(self.db.profile.spells) do
                if sID == spellID then
                    local spellInfo = {
                        spellID = spellID,
                        spellName = spellName,
                        enabled = true,
                        cooldown = cd,
                        icon = icon,
                        expireTime = currentTime + cd,
                    }
                    table.insert(self.db.profile.currentSpells, spellID, spellInfo)

                    TatgetSpell = TargetFrame:CreateTexture("Icon")
                    TatgetSpell:SetImage(spellInfo.icon)
                    TatgetSpell:SetLabel(cd .. "-" .. spellInfo.spellName)
                    TatgetSpell:SetPoint("TOPLEFT", TargetFrame, "LEFT", 7, 45)
                end
            end

        end

    end
end

function TargetCooldowns:ShowConfig()
    AceConfigDialog:SetDefaultSize(AppName, 800, 600)
    AceConfigDialog:Open(AppName)
end

function TargetCooldowns:ChatCommand(input)
    InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
end

-- functions

