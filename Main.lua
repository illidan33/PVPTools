require("./Libs/ALibStub/LibStub.lua")
-- app global vars
PVPTools = LibStub("AceAddon-3.0"):NewAddon("PVPTools", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("PVPTools")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local AppName = "PVPTools"
local BtnFrame, BtnEnemy, BtnNotifyStealth

BINDING_HEADER_PVPTools = "PVPTools";
BINDING_NAME_PVPTools_Enemy_Coming = L["keyEnemyComing"]

-- default config
local options = {
    name = AppName,
    handler = PVPTools,
    type = "group",
    args = {
        notifyStealth = {
            type = "toggle",
            name = L["notifyStealth"],
            desc = L["toggleNotify"],
            get = function(info)
                return PVPInfo.db.profile.notifyStealth;
            end,
            set = function(info, value)
                if value == true then
                    BtnNotifyStealth:Show()
                else
                    BtnNotifyStealth:Hide()
                end
                PVPInfo.db.profile.notifyStealth = value or false;
            end,
        },
    },
}

local defaults = {
    profile = {
        notifyStealth = false,
    },
}

function PVPTools:OnInitialize()
    -- Called when the addon is loaded
    self.db = LibStub("AceDB-3.0"):New("PVPToolsDB", defaults, true)
    LibStub("AceConfig-3.0"):RegisterOptionsTable(AppName, options, { "pt", "pvptools" })
    self.optionsFrame = AceConfigDialog:AddToBlizOptions(AppName, AppName)

    self:RegisterChatCommand("pt", "ShowConfig")
    self:RegisterChatCommand("pvptools", "ShowConfig")
end

function PVPTools:ShowConfig()
    AceConfigDialog:SetDefaultSize(AppName, 800, 600)
    AceConfigDialog:Open(AppName)
end

function PVPTools:OnEnable()
    PVPTools_Init_Frame()

    --self:RegisterEvent("NAME_PLATE_UNIT_ADDED");
    --self:RegisterEvent("NAME_PLATE_UNIT_REMOVED");
    --self:RegisterEvent("PLAYER_TARGET_CHANGED");
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED");

    --self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    --self:RegisterEvent("COMBAT_LOG_EVENT");

    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA");

    self:RegisterEvent("ARENA_OPPONENT_UPDATE");
    self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS");
    self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE");
    self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
    self:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
end

function PVPTools:PLAYER_TARGET_CHANGED()
    self:Print("PLAYER_TARGET_CHANGED");

    if not UnitIsVisible("target") then
        return ;
    end

    local guid = UnitGUID("target")
    if not guid and guid == "" then
        return ;
    end

    self:Print("GUID:" .. guid);
end

function PVPTools:COMBAT_LOG_EVENT()
    self:Print("COMBAT_LOG_EVENT")
end

function PVPTools:NAME_PLATE_UNIT_ADDED(_, unitToken)
    self:Print("NAME_PLATE_UNIT_ADDED")

    if self.db.profile.notifyStealth ~= true then
        return
    end
    local unit = unitToken;
    --if not UnitIsVisible(unit) then
    --    return
    --end
    if not UnitIsPlayer(unit) then
        return
    end
    if not UnitIsEnemy("player", unit) then
        return
    end

    SendMessage(unit)
end

function PVPTools:PLAYER_REGEN_ENABLED()
    self:Print("PLAYER_REGEN_ENABLED")
end

function PVPTools:PLAYER_REGEN_DISABLED()
    self:Print("PLAYER_REGEN_DISABLED")
end

function PVPTools:PLAYER_ENTERING_WORLD()
    self:Print("PLAYER_ENTERING_WORLD")
end

function PVPTools:ZONE_CHANGED_NEW_AREA()
    self:Print("ZONE_CHANGED_NEW_AREA")
end

function PVPTools:ARENA_OPPONENT_UPDATE()
    self:Print("ARENA_OPPONENT_UPDATE")
end

function PVPTools:ARENA_PREP_OPPONENT_SPECIALIZATIONS()
    self:Print("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
end

function PVPTools:UPDATE_BATTLEFIELD_SCORE()
    self:Print("UPDATE_BATTLEFIELD_SCORE")
end

function PVPTools:UPDATE_BATTLEFIELD_STATUS()
    self:Print("UPDATE_BATTLEFIELD_STATUS")
end

function PVPTools:UPDATE_MOUSEOVER_UNIT()
    self:Print("UPDATE_MOUSEOVER_UNIT")
end

function SendMessage(unit)
    unitName, unitRealName = UnitName(unit)
    if unitRealName == nil then
        unitRealName = GetRealmName()
    end
    className, classFileName = UnitClass(unit)

    local notifyText = L["textEnemy"] .. "「" .. unitName .. " - " .. unitRealName .. " - " .. className .. "」" .. L["textNotifyEnemy"] .. GetSubZoneText() .. L["textHelp"];
    if UnitInRaid("player") then
        SendChatMessage(notifyText, "RAID");
        SendChatMessage(notifyText, "INSTANCE_CHAT");
    elseif UnitInParty("player") then
        SendChatMessage(notifyText, "PARTY");
    else
        SendChatMessage(notifyText, "");
    end
end

function PVPTools_Enemy_Coming()
    local unit = "mouseover";
    --if not UnitIsVisible(unit) then
    --    return
    --end
    if not UnitIsPlayer(unit) then
        return
    end
    if not UnitIsEnemy("player", unit) then
        return
    end
    SendMessage(unit)
end

function PVPTools_Init_Frame()
    -- Create a container frame
    BtnFrame = AceGUI:Create("Frame")
    BtnFrame:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
    end)
    BtnFrame:SetTitle("PVPTools")
    BtnFrame:SetStatusText("Status Text")
    BtnFrame:SetLayout("Flow")
    BtnFrame:SetScript("OnMouseDown", function(frame)
        frame:StartMoving();
    end)
    BtnFrame:SetScript("OnMouseUp", function(frame)
        frame:StopMovingOrSizing()
    end)
    BtnFrame:Show()

    local BtnSafe = AceGUI:Create("Button")
    BtnSafe:SetWidth(30)
    BtnSafe:SetText(L["textSafe"])
    BtnSafe:SetCallback("OnClick", PVPTools_Enemy_Coming)
    BtnSafe:AddChild(BtnSafe)

    BtnEnemy = AceGUI:Create("Button")
    BtnEnemy:SetWidth(30)
    BtnEnemy:SetText(L["textEnemy"])
    BtnEnemy:SetCallback("OnClick", PVPTools_Enemy_Coming)
    BtnFrame:AddChild(BtnEnemy)

    BtnNotifyStealth = AceGUI:Create("Button")
    BtnNotifyStealth:SetAutoWidth(true)
    BtnNotifyStealth:SetCallback("OnClick", function()
        local flag = PVPTools.db.profile.notifyStealth
        if flag == true then
            BtnNotifyStealth:SetText(L["textStealth"] .. ":" .. L["close"])
            PVPTools.db.profile.notifyStealth = false
            self:UnregisterEvent("NAME_PLATE_UNIT_ADDED");
        else
            BtnNotifyStealth:SetText(L["textStealth"] .. ":" .. L["open"])
            PVPTools.db.profile.notifyStealth = true
            self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        end
    end)
    BtnFrame:AddChild(BtnNotifyStealth)
    if PVPTools.db.profile.notifyStealth == false then
        BtnNotifyStealth:Hide()
    end
end