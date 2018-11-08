-- app global vars
PVPTools = LibStub("AceAddon-3.0"):NewAddon("PVPTools", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("PVPTools")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local AppName = "PVPTools"
local BtnFrame, BtnSafe, BtnEnemy, BtnNotifyStealth

BINDING_HEADER_PVPTools = "PVPTools";
BINDING_NAME_PVPTools_Enemy_Coming = L["keyEnemyComing"]


-- default config
local options = {
    name = AppName,
    handler = PVPTools,
    type = "group",
    args = {
        showMessageAuto = {
            type = "toggle",
            name = L["showMessageAuto"],
            desc = L["textShowMessageAuto"],
            get = function(info)
                return PVPTools.db.profile.showMessageAuto
            end,
            set = function(info, value)
                PVPTools.db.profile.showMessageAuto = value or false
            end,
        },
        isPlayer = {
            type = "toggle",
            name = L["isPlayer"],
            desc = L["textIsPlayer"],
            get = function(info)
                return PVPTools.db.profile.isPlayer
            end,
            set = function(info, value)
                PVPTools.db.profile.isPlayer = value or false
            end,
        },
        enemyCache = {
            type = "toggle",
            name = L["enemyCache"],
            desc = L["textEnemyCache"],
            get = function(info)
                return PVPTools.db.profile.enemyCache
            end,
            set = function(info, value)
                PVPTools.db.profile.enemy = {}
                PVPTools.db.profile.enemyCache = value or false
            end,
        },
        top = {
            type = "input",
            name = "top",
            desc = L["top"],
            get = function(info)
                return PVPTools.db.profile.frameTop
            end,
            set = function(info, value)
                PVPTools.db.profile.frameTop = value or -540
                BtnFrame:SetPoint("CENTER", UIParent, "CENTER", PVPTools.db.profile.frameLeft, PVPTools.db.profile.frameTop)
            end,
        },
        left = {
            type = "input",
            name = "left",
            desc = L["left"],
            get = function(info)
                return PVPTools.db.profile.frameLeft
            end,
            set = function(info, value)
                PVPTools.db.profile.frameLeft = value or 550
                BtnFrame:SetPoint("CENTER", UIParent, "CENTER", PVPTools.db.profile.frameLeft, PVPTools.db.profile.frameTop)
            end,
        },
    },
}

local defaults = {
    profile = {
        notifyStealth = true,
        enemy = {},
        showMessageAuto = true,
        isPlayer = true,
        enemyCache = false,
        frameTop = -540,
        frameLeft = 550,
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
    PVPTools.db.profile.enemy = {}
    PVPTools_Init_Frame()
end

function SendMessageByUnit(unit)
    --print("SendMessageByUnit:" .. unit)
    local unitName, _ = UnitName(unit)
    local className, _ = UnitClass(unit)

    if PVPTools.db.profile.enemyCache == true then
        if unit ~= "target" or unit ~= "mouseover" then
            local flag = unitName .. "-" .. className
            for _, v in pairs(PVPTools.db.profile.enemy) do
                if v == flag then
                    return
                end
            end
            table.insert(PVPTools.db.profile.enemy, flag)
        end
    end
    local zone = GetSubZoneText()
    if not zone then
        return
    end
    local notifyText = L["textEnemy"] .. "「" .. unitName .. "-" .. className .. "」" .. L["textNotifyEnemy"] .. "「" .. zone .. "」," .. L["textHelp"];

    SendMessage(notifyText)
end

function SendMessage(notifyText)
    if PVPTools.db.profile.showMessageAuto == true then
        if UnitInRaid("player") then
            --SendChatMessage(notifyText, "RAID");
            SendChatMessage(notifyText, "INSTANCE_CHAT");
        elseif UnitInParty("player") then
            SendChatMessage(notifyText, "PARTY");
        else
            SendChatMessage(notifyText, "SAY");
        end
    else
        PVPTools:Print(notifyText);
    end
end

function PVPTools_Enemy_Coming(unit)
    --print("PVPTools_Enemy_Coming:" .. unit)
    local unitName, _ = UnitName(unit)
    local className, _ = UnitClass(unit)
    if PVPTools.db.profile.isPlayer == true then
        if not UnitIsPlayer(unit) then
            return
        end
    end
    if not UnitIsEnemy("player", unit) then
        return
    end
    local zone = GetSubZoneText()
    if not zone then
        return
    end
    local notifyText = L["textEnemy"] .. "「" .. unitName .. "-" .. className .. "」" .. L["textNotifyEnemy"] .. "「" .. zone .. "」," .. L["textHelp"];

    SendMessage(notifyText)
end

function PVPTools:NAME_PLATE_UNIT_ADDED(_, unitToken)
    --self:Print("NAME_PLATE_UNIT_ADDED")

    if self.db.profile.notifyStealth ~= true then
        return
    end
    local unit = unitToken;

    if PVPTools.db.profile.isPlayer == true and not UnitIsPlayer(unit) then
        return
    end
    if not UnitIsEnemy("player", unit) then
        return
    end
    local className, classFileName, _ = UnitClass(unitToken)
    if classFileName == "HUNTER" and classFileName == "ROGUE" and classFileName == "DRUID" then
        if CheckInteractDistance("target", 1) then
            SendMessageByUnit(unit)
        end
    end

end

function PVPTools_Init_Frame()
    -- Create a container frame
    BtnFrame = AceGUI:Create("ScrollFrame")
    BtnFrame:SetWidth(300)
    BtnFrame:SetHeight(100)
    BtnFrame:SetLayout("Flow")
    BtnFrame:SetPoint("CENTER", UIParent, "CENTER", PVPTools.db.profile.frameLeft, PVPTools.db.profile.frameTop)
    --end

    BtnSafe = AceGUI:Create("Button")
    BtnSafe:SetWidth(70)
    BtnSafe:SetText(L["textSafe"])
    BtnSafe:SetCallback("OnClick", function()
        local zone = GetSubZoneText()
        if zone then
            local notifyText = "【" .. zone .. "】已安全，两点之间的机动点留人随时支援！"
            SendMessage(notifyText)
        end
    end)
    BtnFrame:AddChild(BtnSafe)

    BtnEnemy = AceGUI:Create("Button")
    BtnEnemy:SetWidth(70)
    BtnEnemy:SetText(L["textEnemy"])
    BtnEnemy:SetCallback("OnClick", function()
        PVPTools_Enemy_Coming("target")
    end)
    BtnFrame:AddChild(BtnEnemy)

    BtnNotifyStealth = AceGUI:Create("Button")
    BtnNotifyStealth:SetWidth(90)
    if PVPTools.db.profile.notifyStealth == false then
        BtnNotifyStealth:SetText(L["textStealth"] .. ":" .. L["close"])
        PVPTools:UnregisterEvent("NAME_PLATE_UNIT_ADDED");
    else
        BtnNotifyStealth:SetText(L["textStealth"] .. ":" .. L["open"])
        PVPTools:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    end
    BtnNotifyStealth:SetCallback("OnClick", function()
        if PVPTools.db.profile.enemyCache == true then
            PVPTools.db.profile.enemy = {}
        end
        local flag = PVPTools.db.profile.notifyStealth
        if flag == true then
            BtnNotifyStealth:SetText(L["textStealth"] .. ":" .. L["close"])
            PVPTools:UnregisterEvent("NAME_PLATE_UNIT_ADDED");
            PVPTools.db.profile.notifyStealth = false
        else
            BtnNotifyStealth:SetText(L["textStealth"] .. ":" .. L["open"])
            PVPTools.db.profile.notifyStealth = true
            PVPTools:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        end
    end)
    BtnFrame:AddChild(BtnNotifyStealth)
end