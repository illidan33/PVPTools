local L = LibStub("AceLocale-3.0"):NewLocale("PVPTools", "zhCN")

if not L then
    return
end

-- config description
L["keyEnemyComing"] = "发送敌方奔袭预警。"
L["notifyStealth"] = "潜形预警"
L["toggleNotify"] = "开/关 潜形预警。"
L["textSafe"] = "安全"
L["textEnemy"] = "敌方"
L["textNotifyEnemy"] = "正在奔袭"
L["textStealth"] = "潜形"
L["close"] = "关"
L["open"] = "开"
L["textHelp"] = "需要支援！！！"
L["showMessageAuto"] = "在不同频道发送警报"
L["textShowMessageAuto"] = "自动判断所在队伍，在团队或者队伍中发送警报 或者 仅仅显示白字。"
L["isPlayer"] = "判断玩家"
L["textIsPlayer"] = "是否当敌人是玩家时才提示。（建议勾选）"
L["enemyCache"] = "启动缓存"
L["textEnemyCache"] = "是否使用缓存（有缓存时，同一个目标只会提示一次。）"
L["top"] = "设置按钮框的上下高度（下为负数）"
L["left"] = "设置按钮框的左右距离（左为负数）"