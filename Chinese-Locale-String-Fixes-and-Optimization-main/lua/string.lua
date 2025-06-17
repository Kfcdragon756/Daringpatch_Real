local schinese = Idstring("schinese"):key() == SystemInfo:language():key()
if not schinese and not CHNMOD_PATCH then
    return
end

if restoration then
    return
end

if not ChinStringFixes or not ChinStringFixes.settings.Enable_String then
    return
end

if RequiredScript and RequiredScript == "lib/tweak_data/upgradestweakdata" then
    local origin_mrwi9 = UpgradesTweakData.mrwi_deck9_options
    function UpgradesTweakData.mrwi_deck9_options()
        local origin_ret = origin_mrwi9()

        origin_ret[15].custom_editable_descs[2.0] = "45"

        return origin_ret
    end
end

if RequiredScript and RequiredScript == "lib/managers/localizationmanager" then
    Hooks:Add("LocalizationManagerPostInit", "ChinStringFixes", function(loc)
        -- log("heymaa"..ChinStringFixes.settings.perk_deck_tip)
        -- if Application:version() == "1.115.65" then
        -- LocalizationManager:add_localized_strings({
        -- menu_dlc_buy_snow_help = "现在访问STEAM即可获得这份TAILOR PACK。内含四张面具、四件武器配色、\n两套服装且各带四种变色，以及四件武器挂件。现在就购买WINTER GHOSTS TAILOR PACK DLC吧！",
        -- })
        -- end

        if ChinStringFixes.settings.others_tip then
            LocalizationManager:add_localized_strings({
                menu_unseen_strike_beta_desc = "基础：##$basic##\n如果你在##受到伤害后##的##4##秒内未损失护甲和血量，你将在##6##秒内获得##35%##的暴击几率。\n\n精通：##$pro##\n暴击几率加成时间增加至##18##秒。\n\n暴击加成持续时间内，你受到伤害不会取消此技能效果，但也无法在持续时间结束前再次触发该技能。"
            })
        end

        if TheFixes and not TheFixesPreventer or TheFixes and TheFixesPreventer and
            not TheFixesPreventer.sixth_ammo_box_playerman then
            ----if TheFixes and (not TheFixesPreventer or not TheFixesPreventer.sixth_ammo_box_playerman) then
            LocalizationManager:add_localized_strings({
                menu_scavenging_beta_desc = "基础：##$basic##\n弹药盒拾取范围增加##50%##。\n\n精通：##$pro##\n每击杀##6##名敌人，你下一次击杀的所有敌人中的一个会掉落额外弹药盒。"
            })
        else
            LocalizationManager:add_localized_strings({
                menu_scavenging_beta_desc = "基础：##$basic##\n弹药盒拾取范围增加##50%##。\n\n精通：##$pro##\n每击杀##6##名敌人，你下一次击杀的所有敌人都会掉落额外弹药盒。"
            })
        end

        LocalizationManager:add_localized_strings({
            -- vanilla st stuff
            -- head above water --lol
            hud_h_watchdogs_stage2_mission6_hl = "挺过突袭",
            pln_cr2_104_03 = "劫匪们，最好快点开溜！他们为这次突击倾尽全力了！",

            -- Weapon Factory
            -- name
            bm_wp_upg_a_rip = "墓石大铅弹",
            bm_wp_upg_a_grenade_launcher_hornet = "蜂巢榴弹",
            -- bm_menu_drag_handle = "拉机柄",  --fixed
            -- bm_wp_ak_upg_dh_zenitco = "战术拉机柄", --fixed
            -- desc
            bm_wp_upg_a_rip_desc = "涂有毒药的子弹，能随时间造成伤害，并有几率麻痹敌人。毒弹的效果受武器伤害衰减影响。",
            bm_wp_upg_a_dragons_breath_desc = "发射燃烧弹药，能烧穿敌人盾牌和护甲。燃烧伤害受暴击影响。",
            bm_wp_upg_a_piercing_desc = "能延长武器的衰减始距，可有效穿透敌人护甲。",
            bm_wp_upg_a_slug_desc = "发射一枚独头弹，可以刺穿敌人护甲，盾牌，以及墙壁，且伤害不再随距离衰减。此弹药类型十分罕见。",
            bm_wp_upg_a_custom_desc = "大号弹药可以造成更强的冲击，提高伤害。",
            bm_wp_ns_duck_desc = "使射出的子弹横向扩散变为2.25倍，垂直扩散变为0.5倍。",
            bm_wp_upg_lmg_lionbipod_desc_pc = "按$BTN_BIPOD;部署/拆卸。\n架起脚架后完全取消后坐力并提高一些精准度（不与蹲下静止提供的精准度加成叠加）。",
            bm_wp_wpn_fps_upg_charm_lr = "鹰姐（幸运+1）",

            -- achivement
            achievement_trai_10_desc = "全队成员在无任何技能，身穿两件套西装，携带Castigo_.44左轮手枪和Mosconi_12G霰弹枪的情况下以强袭途径完成\"迷途纵横\"任务，难度为枪林弹雨或以上。",
            achievement_frog_1 = "返璞归真（Tabula Rasa）",

            --infamous
            menu_infamy_go_infamous_error_crime_spree = "罪无止境生效时无法晋升，请先结束或获取奖励",
            menu_infamy_go_infamous = "选择恶名晋级的方式 ",
            menu_infamy_go_inf_rep = "使用声望（晋升至下一转的0级）",
            menu_infamy_go_inf_prestige = "使用恶名池（晋升至下一转的100级）",

            -- network
            dialog_err_failed_joining_lobby = "加入游戏失败。\n\n可能的原因：\n——您未能连接上房主的网络或房间已不存在\n——该房间使用了您未安装的影响网络同步的模组\n——您与好友未共同启用或禁用-steamMM/-epicMM启动项",
            dialog_remove_dead_peer = "与一位或多位玩家的网络连接无法建立。\n\n可能的原因：\n——您未能连接上房主或房间内其它玩家的网络",
            dialog_authentication_fail = "Steam无法验证你的Steam ID。\n\n可能的原因：\n——您或房主连接到Steam服务器的网络异常",
            dialog_requires_steam_overlay = "此功能需要Steam社区界面。请确认已启用游戏中Steam社区，并重启游戏以使用此功能。\n\n可能的原因：\n——未启用游戏中Steam社区\n——您连接到Steam服务器的网络异常",
            bm_menu_dlc_locked = "无法获取，或连接到STEAM的网络异常",

            -- perk_short
            menu_deck13_9_short = "击杀一名敌人后会增加你的护甲恢复速度。增加程度取决于你穿的护甲，护甲越重，增加的越少。\n护甲完全恢复后，恢复速度将重置。",
            menu_deck18_1_short = "解锁投掷物烟雾弹，替代你的当前投掷物。烟雾弹被丢出后可以创造一片持续##$multiperk;##秒的烟幕。站在烟幕中的友军会自动躲避掉##$multiperk2;##射来的子弹。站在烟幕中的敌人会减少##$multiperk4;##精准度。烟雾弹有##$multiperk3;##秒的冷却时间，不过烟雾散去后击杀敌人会使冷却减少##$multiperk5;##秒。",
            menu_deck15_9_short = "造成伤害会恢复##30##护甲——##1.5##秒内只能生效一次。",
            menu_deck17_1_short = "解锁并装备首脑注射器，替代你的当前投掷物。使用注射器后你会在##$multiperk2;##秒内获得受到伤害##$multiperk;##的治疗量。注射器有##$multiperk3;##秒的冷却时间，每击杀一名敌人减少冷却时间##1##秒。",
            menu_deck20_1_short = "解锁并装备电子烟，替代你的当前投掷物。要使用电子烟，你需要看向某位##$multiperk;##米内无视线阻挡的友军并对其按下投掷键##$BTN_ABILITY;##标记为搭档。你或友军搭档击杀的每名敌人都会为你恢复##$multiperk2;##血量，并为友军搭档恢复##$multiperk3;##血量。你击杀的每名敌人都会使此效果延长##$multiperk4;##秒，并使冷却时间减少##2##秒。此效果将持续##12##秒，冷却时间为##60##秒。",
            menu_deck17_9_short = "你获得##$multiperk;##额外血量。\n注射器生效期间，你每获得##50##血量的过量治疗，注射器冷却时间减少##$multiperk4;##秒。",
            menu_deck13_5_short = "最大存储血量增加##$multiperk;##。$NL;$NL;你获得##$multiperk2;##额外血量。$NL;$NL;你的闪避几率增加##15%##。",
            menu_deck2_7_short = "所有##非消音##的枪支武器都有几率在敌人中散布恐慌。$NL;$NL;恐慌的敌人将暂时陷入不可控制的恐惧之中。",

            -- shit's coming

            -- Others that I forgot to classify
            menu_bloodthirst_desc = "基础：##$basic##\n每次击杀都会使你下一次近战攻击伤害增加##100%##，最高为##1600%##。此效果会在使用近战击杀敌人后重置。\n\n注意：爆炸类武器和狙击步枪穿透一击多杀只算1次击杀，而狙击步枪通过连带伤害击杀多少名敌人就算多少次击杀。\n\n精通：##$pro##\n近战击杀敌人后，你会在##10##秒内获得##50%##装填速度加成。",
            --menu_hardware_expert_beta_desc = "基础：##$basic##\n修理钻机与电锯的速度增加##25%##，诡雷部署时间减少##20%##。部署钻机与电锯现在完全无声，保安和平民只有看到后才会警觉。\n\n注意：技能不影响OVE9000便携式电锯。\n\n精通：##$pro##\n钻机和电锯有##10%##几率在放置下来时变成自修钻机/电锯，自修钻机/电锯每次损坏时都会自动修复。",
            --menu_kick_starter_beta_desc = "基础：##$basic##\n你放置的钻机与电锯变成自修钻机/电锯的几率额外增加##20%##。\n\n精通：##$pro##\n使用近战攻击有##50%##的几率重启损坏的钻机或电锯。每次损坏时你只有一次机会。\n\n注意：技能不影响OVE9000便携式电锯。",
            menu_ammo_reservoir_beta_desc = "基础：##$basic##\n任意玩家与你部署的弹药包互动后最多##5##秒内射击不会消耗子弹。\n该次互动补充子弹越多，效果持续时间越久。\n\n对消耗光弹药包内剩余弹药的那次互动，无论补充多少，玩家都会获得##15##秒的无限弹药时间。\n\n精通：##$pro##\n该效果最长持续时间增加##15##秒。\n\n对消耗光弹药包内剩余弹药的那次互动，无论补充多少，玩家都会获得##60##秒的无限弹药时间。",
            menu_black_marketeer_beta_desc = "基础：##$basic##\n场上有人质或你自己的变节警察，且你血量不满时，每##5##秒会恢复##1.5%##血量。\n\n精通：##$pro##\n场上有人质或你自己的变节警察，且你血量不满时，每##5##秒会恢复##4.5%##血量。",
            menu_joker_beta_desc = "基础：##$basic##\n你可以使一名非特种敌人变节并为你作战。\n潜入时无法使用，敌人投降后才可转化。\n\n你同时只能转化一名非特种敌人，且该变节敌人只能造成他原来##65%##的伤害。\n\n精通：##$pro##\n变节敌人现在可造成他原来##100%##的伤害。\n转化敌人所需时间减少##65%##。",
            menu_deck18_1_desc = "解锁投掷物烟雾弹。\n\n切换至其他天赋牌组会导致烟雾弹不可用。烟雾弹会替代你的当前投掷物，装备在你的投掷物栏位中，并且在需要时可以切换。\n\n在游戏中你可以按下投掷键##$BTN_ABILITY;##使用烟雾弹。\n\n烟雾弹被丢出后可以创造一片持续##10##秒的烟幕。站在烟幕中的友军会自动躲避掉##50%##射来的子弹。站在烟幕中的敌人会减少##50%##精准度。\n\n被丢出后，烟雾弹将立即进入##60##秒的冷却时间，不过烟雾散去后击杀敌人会使冷却减少##1##秒。",
            menu_deck17_9_desc = "你获得##40%##额外血量。\n\n注射器生效期间，你每获得##50##血量的过量治疗，注射器冷却时间减少##1##秒。\n\n举例：假如你的血量上限为400，血量为150，有5点护甲。此时受到伤害为300的水军攻击，你恢复300血。而你只需要恢复250血就能满血，剩下50血即为过量治疗，会减少注射器冷却时间1秒。\n\n牌组完成奖励：收获日阶段抽到稀有物品的几率增加##10%##。",
            menu_deck15_9_desc = "造成伤害会恢复##30##护甲——##1.5##秒内只能生效一次。\n对变节敌人造成伤害也可触发此效果。\n\n该天赋的“造成伤害”仅指以下伤害途径：\n你射击的子弹、近战、C4爆炸、余火烧伤、毒伤、电击、ECM反馈、闪光弹。\n\n牌组完成奖励：收获日阶段抽到稀有物品的几率增加##10%##。",
            menu_deck13_5_desc = "最大储存血量增加##50%##。\n\n你获得##10%##额外血量。\n\n你的闪避几率增加##15%##。",
            menu_underdog_beta_desc = "基础：##$basic##\n当##18##米内（竖直##10##米）有三个或以上敌人以你为目标时，你造成的伤害在##7##秒内增加##15%##。\n\n精通：##$pro##\n当##18##米内（竖直##10##米）有三个或以上敌人以你为目标时，你受到的伤害在##7##秒内减少##10%##。\n\n注意：对近战伤害、投掷物、榴弹发射器及火箭发射器无效。",

            -- this is a bunch of shit
            menu_deck8_7_desc = "当##18##米内（竖直##10##米）有三个或以上敌人以你为目标时，你受到的伤害额外减少##12%##。\n\n近战攻击每次命中后，在##1##秒内的下次近战攻击会造成##10##倍伤害。\n（解锁第五张牌后，持续时间从##1##秒变为##7##秒）\n\n注意：若近战攻击挥空，堆叠的伤害倍数都将清空。",
            menu_deck8_1_desc = "当##18##米内（竖直##10##米）有敌人以你为目标时，受到的伤害减少##$multiperk;##。",
            menu_deck8_3_desc = "当##18##米内（竖直##10##米）有敌人以你为目标时，受到的伤害额外减少##8%##。",
            menu_deck8_5_desc = "当##18##米内（竖直##10##米）有敌人以你为目标时，受到的伤害额外减少##8%##。$NL;$NL;近战伤害加成生效时，连续成功命中之间的时间上限现在为##7##秒。",
            menu_deck8_5_short = "在敌人中距离范围内时，受到的伤害额外减少##8%##。\n近战伤害加成生效时，连续成功命中之间的时间上限现在为##7##秒。",
            menu_deck9_1_desc = "当##18##米内（竖直##10##米）有三个或以上敌人以你为目标时，你受到的伤害额外减少##$multiperk;##。$NL;$NL;近战攻击每次命中后，在##$multiperk2;##秒内的下次近战攻击会造成##$multiperk3;##倍伤害。",
            menu_deck9_5_desc = "近战攻击杀死敌人会恢复##10%##血量。\n\n此效果##1##秒内只能生效一次。\n\n当##18##米内（竖直##10##米）有敌人以你为目标时，受到的伤害减少##8%##。",
            menu_deck9_7_desc = "当##18##米内（竖直##10##米）有敌人以你为目标时，杀死敌人会恢复##30##护甲值。\n\n此效果##1##秒内只能生效一次。\n\n你额外获得##10%##护甲。",
            menu_deck9_9_desc = "当##18##米内（竖直##10##米）有敌人以你为目标时，击杀敌人有##75%##的几率在敌人中散播恐慌。\n\n恐慌的敌人将陷入不可控制的恐惧中。\n\n此效果##1##秒内只能生效一次。\n\n牌组完成奖励：收获日阶段抽到稀有物品几率增加##10%##。",

            menu_deck2_7_desc = "所有##非消音##的枪支武器都有几率在敌人中散播恐慌。\n\n恐慌的敌人将陷入不可控制的恐惧中。",
            menu_control_freak_beta_desc = "基础：##$basic##\n拥有变节敌人时，你的移速增加##10%##。\n\n变节敌人获得##45%##伤害减免。\n\n精通：##$pro##\n拥有变节敌人时，你的血量上限增加##69##。\n（无加成时血量上限的30%）\n\n变节敌人额外获得##54%##伤害减免。\n\n注意：无论变节敌人获得多高的伤害减免，它们都会在受到最多##512##次伤害后死亡。",
            menu_deck18_9_desc = "当你站在烟幕中时，你所有天赋效果增加##100%##。站在烟幕中的队友将获得##10%##闪避几率。\n\n但你在烟幕中并不是必定闪避的。\n\nWolfHUD对该天赋的闪避计数存在问题。\n\n牌组完成奖励：收获日阶段抽到稀有物品的几率增加##10%##。",
            menu_deck12_9_desc = "此天赋牌组的所有效果触发条件均由##25%##血量改为##100%##血量。",
            menu_deck22_1_desc = "解锁并装备水蛭安瓿瓶。\n\n切换至其他天赋牌组会导致水蛭安瓿瓶不可用。水蛭安瓿瓶会替代你的当前投掷物，装备在你的投掷物栏位中，并且在需要时可以切换。\n\n在游戏中你可以按下投掷键##$BTN_ABILITY;##使用水蛭安瓿瓶。\n\n激活水蛭安瓿瓶会为你恢复##$multiperk;##血量，并在生效期间移除护甲值。\n\n水蛭安瓿瓶生效时，你的血量将以每##$multiperk2;##划分为一格，受到敌人的伤害不超过##200##会移除一格血量，否则会移除两格。击杀##$multiperk3;##名敌人会恢复一格血量，并在1秒内无视所有伤害。你每次受到伤害时，队友均会恢复##$multiperk4;##血量，每秒最多恢复##20%##。\n\n水蛭安瓿瓶持续##$multiperk5;##秒，冷却时间为##$multiperk6;##秒。",
            menu_deck22_3_desc = "你的血量上限增加##20%##。\n\n水蛭安瓿瓶生效期间你不会倒地，但你的血量归零后你会减速##80%##。\n\n在水蛭安瓿瓶效果结束时，如果你的血量归零，你会立即倒地且无法触发“天鹅绝唱”技能的效果。",
            menu_deck22_5_desc = "水蛭安瓿瓶持续时间增加至##$multiperk;##秒。\n\n击杀一名敌人会为水蛭安瓿瓶减少##$multiperk2;##秒冷却时间。\n\n受到伤害现在会为队友恢复##$multiperk3;##血量，每秒最多恢复##20%##。",
            menu_deck22_9_desc = "你现在可以在非幻影特工飞踢和非泰瑟电击导致的倒地时激活水蛭安瓿瓶，并在生效期间暂时起身。如果你成功在生效期间救起队友或使用医疗箱，且在效果结束时高于0血量则可保持存活；否则在效果结束时，你会立即倒地（若未救起队友也没使用医疗箱就不会消耗倒地次数）且无法触发“天鹅绝唱”技能的效果。\n\n使用安瓿瓶自起将会有额外30秒的冷却时间，直到你救起队友或使用医疗箱或倒地起身。\n\n水蛭安瓿瓶生效时，你的血量将以每##10%##划分为一格。\n\n你的血量上限增加##40%##。\n\n牌组完成奖励：收获日阶段抽到稀有物品的几率增加##10%##。",
            menu_deck11_1_desc = "对敌人造成伤害后每##0.3##秒恢复##1##血量，持续##3##秒。\n\n此效果可叠加，但##1.5##秒内只能生效一次，并且只有在身穿两件套西装和轻型防弹背心时才有效。\n\n该天赋的“造成伤害”仅指以下伤害途径：\n你射击的子弹、近战、C4爆炸、地火直伤、毒伤、哨戒机枪。",
            menu_deck14_1_desc = "你所造成伤害的##100%##将会转换成狂乱度，每##4##秒最多累计##240##层，狂乱度最高为##600##层。\n\n关于狂乱度\n每累计##30##层狂乱度，你将能够吸收##1##点伤害。狂乱度每##8##秒减少##60% + 80##层。\n\n该天赋的“造成伤害”仅指以下伤害途径：\n你射击的子弹、近战、C4爆炸、地火直伤、毒伤、哨戒机枪。",
            menu_bandoliers_beta_desc = "基础：##$basic##\n你的总弹量增加##25%##。\n\n精通：##$pro##\n拾取弹药盒获得的弹药增加##75%##。\n注意：不与“衣帽间”天赋效果叠加。\n\n你还有##5%##的基础几率从弹药盒中获得投掷物。\n每当你没有从弹药盒中获得投掷物时，此几率增加##1%##。当你从弹药盒中获得投掷物后，此几率将重置为基础值。\n\n举例：\n若捡弹未获得投掷物，\n则首次几率增加为5%+1%=##6%##\n第二次则为6%+1%=##7%##\n以此类推。",
            menu_deck20_1_desc = "解锁并装备电子烟。\n\n切换至其他天赋牌组会导致电子烟不可用。注射器会替代你的当前投掷物并且在需要时可以切换。\n\n要使用电子烟，你需要看向某位##18##米内无视线阻挡的友军并对其按下投掷键##$BTN_ABILITY;##标记为搭档。\n\n你或友军搭档击杀的每名敌人都会为你恢复##15##血量，并为友军搭档恢复##7.5##血量。\n\n你或友军搭档击杀的每名敌人都会使此效果多延长##1.3##秒，并使冷却时间减少##2##秒。\n\n此效果将持续##12##秒，冷却时间为##60##秒。",
            menu_deck21_1_desc = "解锁并装备便携式电子干扰器。\n\n换至其他天赋牌组会导致便携式电子干扰器不可用。便携式电子干扰器会替代你的当前投掷物，装备在你的投掷物栏位中，并且在需要时可以切换。\n\n在游戏中你可以按下投掷键##$BTN_ABILITY;##使用便携式电子干扰器。\n\n在警报触发前激活便携式电子干扰器将启用干扰效果，在##$multiperk;##秒内拦截所有电子设备与对讲机。\n\n在警报触发后激活便携式电子干扰器将激活啸叫效果，每秒均有几率眩晕地图内的敌人，持续##$multiperk;##秒。\n\n便携式电子干扰器共有##$multiperk2;##次充能，且每个有##$multiperk3;##秒冷却时间，但每击杀一名敌人均可使冷却时间缩短##$multiperk4;##秒。",
            menu_deck1_9_desc = "每有一名人质，全队增加##13.8##最大血量（无加成时血量上限的$multiperk;）与##$multiperk2;##耐力，最多叠加##$multiperk3;##次。\n\n拥有人质时全队受到的伤害减少##$multiperk4;##。\n\n注意：同队效果不叠加。\n\n牌组完成奖励：收获日阶段抽到稀有物品几率增加##$multiperk5;##。",
            menu_sentry_targeting_package_beta_desc = "基础：##$basic##\n你的哨戒机枪精准度增加##100%##。\n\n精通：##$pro##\n你的哨戒机枪转向速度增加##150%##。\n你的哨戒机枪弹药量增加##50%##，此效果不会增加你放置哨戒机枪消耗的弹药量。",
            menu_warp_health_init_desc = "突进后玩家将恢复##0##至##3##血量，具体取决于消耗的耐力值。每##5##秒最多只能恢复##50##血量。",
            --menu_wolverine_beta_desc = "基础：##$basic##\n你的血量越低，造成的伤害越高。当你的血量低于##50%##时，你将最多造成##250%##额外近战与电锯伤害。\n\n精通：##$pro##\n当你的血量低于##50%##时，你将最多造成##100%##额外远程伤害。\n\n注意：不适用于投掷物、榴弹发射器及火箭发射器。\n\n进入狂战士状态后将无视第三方恢复效果，第三方恢复效果指其它玩家或AI技能对你的直接回血效果。双人组、黑客等的效果是为你提供了一种持续的条件性加成，属于间接回血效果，依然会为你回血。",
            menu_shock_and_awe_beta_desc = "基础：##$basic##\n冲刺时可使用武器腰射。\n\n精通：##$pro##\n使用连发模式的冲锋枪、轻机枪、突击步枪、霰弹枪、手枪或Mk5、弓、喷火器、电锯、转轮机枪、速射机枪击杀##2##名敌人会使下一次装填速度增加##100%##。弹匣容量高于##20##时，每多一发子弹都会使此加成乘以##99%##，最低加成为##40%##。\n\n注意：\n1.是##弹匣容量##，不是弹匣剩余弹药量。\n2.弹匣容量大于##55##发的武器就达到了最低加成。\n3.切换射击模式、切换武器、装填中断都会使效果失效，需要重新杀敌。",
            menu_body_expertise_beta_desc = "基础：##$basic##\n击中敌人身体部分时会附带##30%##爆头额外伤害。仅在使用连发模式的冲锋枪、轻机枪、突击步枪或Mk5、弓、电锯、转轮机枪、速射机枪时有效。\n\n注意：\n1.该技能对熊无效。\n2.该技能不会触发爆头回甲。\n3.该技能不受天赋的爆头伤害加成。\n4.该技能是\"附带\"30%爆头\"额外\"伤害，因此：\n##打身体造成的伤害=原打身体造成的伤害+（爆头造成的伤害-原打身体造成的伤害）*30%##\n\n精通：##$pro##\n击中敌人身体部分时附带的爆头额外伤害增加至##90%##。",
            menu_inspire_beta_desc = "基础：##$basic##\n救起队友的速度增加##100%##。\n向队友呼喊将在##10##秒内增加对方##20%##移动速度和换弹速度。\n\n精通：##$pro##\n向##9##米内的队友呼喊可以立即救起对方，##20##秒内只能生效一次。",
            menu_pistol_beta_messiah_desc = "基础：##$basic##\n倒地后击杀敌人将使你立刻起身。\n你只有##1##次机会，且被交易赎回不会重置次数。\n\n注意：倒地无法反抗时不能触发和使用该技能起身。\n\n精通：##$pro##\n起身次数在使用医疗箱后将重置。",
            menu_rifleman_beta_desc = "基础：##$basic##\n所有武器开镜速度增加##100%##。\n\n使用机械瞄具瞄准时你的移速不受影响。\n\n精通：##$pro##\n冲锋枪、突击步枪、狙击步枪、手枪与轻机枪的武器缩放倍率增加##25%##。\n\n冲锋枪、突击步枪与狙击步枪移动时的精准度增加##16##。",
            menu_combat_engineering_desc = "基础：##$basic##\n诡雷的爆炸半径增加##30%##。\n\n精通：##$pro##\n诡雷的伤害增加##50%##。",
            menu_tea_cookies_beta_desc = "基础：##$basic##\n开局时可额外携带##7##个急救包。\n\n精通：##$pro##\n开局时可再额外携带##3##个急救包。\n\n任意玩家如果在你部署的急救包##5##米范围内血量为空，将会自动使用该急救包免于倒地，##20##秒内只能生效一次。",
            menu_spotter_teamwork_beta_desc = "基础：##$basic##\n你标记的敌人额外受到##15%##伤害。\n\n精通：##$pro##\n你标记的敌人处于##10##米之外时额外受到##50%##伤害。\n标记持续时间增加##100%##，徒手标记的距离增加至##2000%##。\n你现在可以用武器瞄准特殊敌人将其标记。\n\n注意：不能透过玻璃使用武器瞄准敌人将其标记。",
            menu_frenzy_desc = "基础：##$basic##\n你的血量上限变为最大值的##30%##。\n你受到的伤害减少##10%##，恢复效果降低##75%##。\n\n精通：##$pro##\n现在你受到的伤害减少##25%##，此技能不再降低恢复效果。",
            menu_second_chances_beta_desc = "基础：##$basic##\n你可以通过近距离互动使##1##台摄像头失效##25##秒，此行为不会导致任何安保的警觉。\n\n注意：游戏中最多存在##1##台被弄失效的摄像头。\n\n精通：##$pro##\n你的开锁速度加快##100%##。\n你可以徒手打开部分保险箱。",
            menu_feign_death_desc = "基础：##$basic##\n倒地时有##15%##的几率立刻起身。\n\n注意：\n1.倒地无法反抗时也可以触发此效果。\n2.摔落、飞踢和电击导致倒地不会触发此效果。\n\n精通：##$pro##\n立刻起身的几率增加##30%##。",
            menu_akimbo_skill_beta_desc = "基础：##$basic##\n双持武器稳定性惩罚减少##8##。\n\n精通：##$pro##\n双持武器稳定性惩罚额外减少##8##，总弹量增加##50%##。\n\n注意：所有双持武器都会有##-28##稳定性的惩罚，该技能可以减免惩罚以提高稳定性。",
            menu_fast_fire_beta_desc = "基础：##$basic##\n冲锋枪、轻机枪与突击步枪弹匣容量增加##15##。\n此技能通常不影响\"子弹上膛\"精通技能效果。\n\n注意：对于##双持冲锋枪##，该技能会增加##30##发弹匣容量，但其中的15发会在计算\"子弹上膛\"技能时造成影响。\n\n精通：##$pro##\n你可以射穿敌人护甲。\n\n注意：不适用于投掷物。",
            menu_carbon_blade_beta_desc = "基础：##$basic##\n电锯对敌人使用时损耗减少##50%##。\n\n精通：##$pro##\n你现在可以用OVE9000型便携式电锯贴着盾锯盾对盾兵造成伤害。\n手持电锯时，使用电锯或投掷物通过非毒性伤害击杀敌人后，有##50%##几率在附近##10##米范围内的敌人中散布恐慌。恐慌的敌人暂时会陷入不可控制的恐惧之中。",
            menu_nine_lives_beta_desc = "基础：##$basic##\n倒地时的血量增加##50%##。\n\n注意：\n1.无加成时倒地血量上限为##100##。\n2.天赋和技能不会加倒地血量上限。\n3.倒地时可以闪避，也受伤害减免。\n\n精通：##$pro##\n被捕前的可倒地次数增加##1##。",
            menu_story_missions_help = "查看你的主线剧情进度。你也可以自己创房玩对应的劫案以完成进度。\n你可以在这里边了解游戏剧情边玩，没有DLC也可以玩DLC劫案的离线模式。",
            menu_safehouse_help = "前往你的安全屋稍作歇息。\n你可以在里面玩小游戏、测试武器、了解剧情背景和解谜完成不同的结局。",
            menu_cn_challenge_desc = "查看可用额外挑战与奖励。\n完成挑战后点击奖励图标以获取奖励。",
            menu_crimenet_help = "登录Crime.net。与同国籍玩家联机不必要挂加速器加速游戏。\n若搜索不到房间或创建不了房间请检查您连接到STEAM的网络。",
            menu_crimenet_offline_help = "在离线模式中启动Crime.net。这依然会在你STEAM在线时连接到网络。\n冬日队长不会生成，且你的无加成护甲恢复时间将从3秒降低至1.7秒。",
            menu_deck16_1_desc = "每当有一名非平民非小队队友的NPC单位死亡时，你将恢复##5##血量与##5##护甲。此效果##4##秒内只能生效##4##次。",
            menu_jail_diet_beta_desc = "基础：##$basic##\n当你的暴露风险在##35##以下时，每降低##3##点暴露风险会提高##1%##闪避几率，最高为##10##。\n\n精通：##$pro##\n当你的暴露风险在##35##以下时，每降低##1##点暴露风险会提高##1%##闪避几率，最高为##10##。\n\n注意：闪避成功后也会触发无敌帧。",
            menu_dire_need_beta_desc = "基础：##$basic##\n你的护甲耗尽后，你首发射击会直接击倒敌人。此效果在经过你护甲恢复所需时间后结束。\n\n注意：\n1.爆头回甲不会使效果结束。\n2.投掷物不能触发该击倒效果。\n3.无法击倒熊、冬队和飞车党BOSS。\n4.无政府主义者破甲后只有##一帧##效果。\n5.效果适用于多名敌人的被首发射击。\n6.可以在二次触发技能时再次击倒同一名敌人。\n\n精通：##$pro##\n这个技能在你的护甲恢复后还能多持续##6##秒。\n效果持续期间无法再次触发。\n\n注意：\n现在无政府主义者破甲后有##六秒##的效果。"
        })

        local game_meme = math.rand(1)
        local game_meme_fun = 0.05
        local game_meme_fun_2 = 0.1

        local meme_enable = nil
        if meme_enable then
            if game_meme <= game_meme_fun then
                LocalizationManager:add_localized_strings({
                    -- Genshin Impact
                    ["heist_deep"] = "原友觉醒",
                    ["heist_framing_frame_1_hl"] = "浮华之下",
                    ["heist_gallery"] = "浮华之下"
                })
            elseif game_meme <= game_meme_fun_2 then
                LocalizationManager:add_localized_strings({
                    -- Genshin Impact
                    ["heist_deep"] = "OP觉醒",
                    ["heist_framing_frame_1_hl"] = "浮华之下",
                    ["heist_gallery"] = "浮华之下"
                })
            end
        end

        if ChinStringFixes.settings.perk_deck_tip == 3 then
            LocalizationManager:add_localized_strings({
                menu_st_spec_1 = "领队",
                menu_st_spec_2 = "肌肉男",
                menu_st_spec_3 = "军械士",
                menu_st_spec_4 = "浪人",
                menu_st_spec_5 = "杀手",
                menu_st_spec_6 = "诡术/骗术师",
                menu_st_spec_7 = "窃贼",
                menu_st_spec_8 = "渗透者/间谍",
                menu_st_spec_9 = "反社会者",
                menu_st_spec_10 = "赌徒",
                menu_st_spec_11 = "冰球手/前卫",
                menu_st_spec_12 = "极道",
                menu_st_spec_13 = "前总统",
                menu_st_spec_14 = "瘾君子/狂人",
                menu_st_spec_15 = "无政府主义者/安那其",
                menu_st_spec_16 = "飞车党",
                menu_st_spec_17 = "首脑/霸王",
                menu_st_spec_18 = "刺客/行者",
                menu_st_spec_19 = "修士/斯多葛",
                menu_st_spec_20 = "双人组/双档",
                menu_st_spec_21 = "黑客",
                menu_deck17_1_desc = "解锁并装备首脑注射器。\n\n切换至其他天赋牌组会导致注射器不可用。注射器会替代你的当前投掷物并且在需要时可以切换。\n\n在游戏中你可以按下投掷键##$BTN_ABILITY;##使用注射器。\n使用后在##6##秒内你每次受击会先获得##75%##受到伤害量的治疗量再受到对应伤害。\n\n生效期间你仍然会受到伤害。注射器##30##秒内只能使用一次。\n\n每击杀一名敌人将减少注射器冷却时间##1##秒。\n\n注意：当你没有护甲时，受到超出血量上限的伤害将直接导致你血量归零进入绝唱/倒地。",
                bm_wskn_famas_hypno = "巴适之鹰"
            })
        elseif ChinStringFixes.settings.perk_deck_tip == 2 then
            LocalizationManager:add_localized_strings({
                menu_st_spec_1 = "领队",
                menu_st_spec_2 = "肌肉",
                menu_st_spec_3 = "军械",
                menu_st_spec_4 = "浪人",
                menu_st_spec_5 = "杀手",
                menu_st_spec_6 = "诡术",
                menu_st_spec_7 = "夜贼",
                menu_st_spec_8 = "间谍",
                menu_st_spec_9 = "反社会者",
                menu_st_spec_10 = "赌徒",
                menu_st_spec_11 = "前卫",
                menu_st_spec_12 = "极道",
                menu_st_spec_13 = "前总统",
                menu_st_spec_14 = "狂人",
                menu_st_spec_15 = "安那其",
                menu_st_spec_16 = "飞车党",
                menu_st_spec_17 = "霸王",
                menu_st_spec_18 = "刺客",
                menu_st_spec_19 = "斯多葛",
                menu_st_spec_20 = "双档",
                menu_st_spec_21 = "黑客",
                menu_deck17_1_desc = "解锁并装备霸王注射器。\n\n切换至其他天赋牌组会导致注射器不可用。注射器会替代你的当前投掷物并且在需要时可以切换。\n\n在游戏中你可以按下投掷键##$BTN_ABILITY;##使用注射器。\n使用后在##6##秒内你每次受击会先获得##75%##的治疗量再受到对应伤害。\n\n生效期间你仍然会受到伤害。注射器##30##秒内只能使用一次。\n\n每击杀一名敌人将减少注射器冷却时间##1##秒。\n\n注意：当你没有护甲时，受到超出血量上限的伤害将直接导致你血量归零进入绝唱/倒地。",
                bm_wskn_famas_hypno = "巴适之鹰"
            })
        elseif ChinStringFixes.settings.perk_deck_tip == 1 then
            LocalizationManager:add_localized_strings({
                bm_wskn_famas_hypno = "巴适之鹰",
                menu_deck17_1_desc = "解锁并装备首脑注射器。\n\n切换至其他天赋牌组会导致注射器不可用。注射器会替代你的当前投掷物并且在需要时可以切换。\n\n在游戏中你可以按下投掷键##$BTN_ABILITY;##使用注射器。\n使用后在##6##秒内你每次受击会先获得##75%##的治疗量再受到对应伤害。\n\n生效期间你仍然会受到伤害。注射器##30##秒内只能使用一次。\n\n每击杀一名敌人将减少注射器冷却时间##1##秒。\n\n注意：当你没有护甲时，受到超出血量上限的伤害将直接导致你血量归零进入绝唱/倒地。"
            })
        elseif ChinStringFixes.settings.perk_deck_tip == 4 then
            LocalizationManager:add_localized_strings({
                menu_st_spec_17 = "金并",
                menu_deck17_1_desc = "解锁并装备金并注射器。\n\n切换至其他天赋牌组会导致注射器不可用。注射器会替代你的当前投掷物并且在需要时可以切换。\n\n在游戏中你可以按下投掷键##$BTN_ABILITY;##使用注射器。\n使用后在##6##秒内你每次受击会先获得##75%##的治疗量再受到对应伤害。\n\n生效期间你仍然会受到伤害。注射器##30##秒内只能使用一次。\n\n每击杀一名敌人将减少注射器冷却时间##1##秒。\n\n注意：当你没有护甲时，受到超出血量上限的伤害将直接导致你血量归零进入绝唱/倒地。",
                bm_wskn_famas_hypno = "巴适之鹰"
            })
        elseif ChinStringFixes.settings.perk_deck_tip == 5 then
            -- log(type(Application:version()))
            LocalizationManager:add_localized_strings({
                menu_st_activate_spec = "选用此项作弊",
                menu_st_spec_1 = "领队",
                menu_st_spec_2 = "肌肉男",
                menu_st_spec_3 = "军械士",
                menu_st_spec_4 = "浪人",
                menu_st_spec_5 = "杀手",
                menu_st_spec_6 = "骗术师",
                menu_st_spec_7 = "夜贼",
                menu_st_spec_8 = "间谍",
                menu_st_spec_9 = "反社会者",
                menu_st_spec_10 = "赌徒",
                menu_st_spec_11 = "前卫",
                menu_st_spec_12 = "极道",
                menu_st_spec_13 = "前总统",
                menu_st_spec_14 = "瘾君子",
                menu_st_spec_15 = "安娜奇",
                menu_st_spec_16 = "飞车党",
                menu_st_spec_17 = "金并",
                menu_st_spec_18 = "行者",
                menu_st_spec_19 = "修士",
                menu_st_spec_20 = "双人组",
                menu_st_spec_21 = "黑客",
                menu_deck17_1_desc = "解锁并装备金并注射器。\n\n切换至其他天赋牌组会导致注射器不可用。注射器会替代你的当前投掷物并且在需要时可以切换。\n\n在游戏中你可以按下投掷键##$BTN_ABILITY;##使用注射器。\n使用后在##6##秒内你每次受击会先获得##75%##的治疗量再受到对应伤害。\n\n生效期间你仍然会受到伤害。注射器##30##秒内只能使用一次。\n\n每击杀一名敌人将减少注射器冷却时间##1##秒。\n\n注意：当你没有护甲时，受到超出血量上限的伤害将直接导致你血量归零进入绝唱/倒地。",
                menu_quit = "马上退游",
                bm_w_coal = "PP野牛 冲锋枪",
                bm_w_p90 = "P90冲锋枪",
                bm_w_deagle = "沙漠之鹰",
                bm_wskn_famas_hypno = "巴适之鹰",
                menu_crew_scavenge = "觅影藏拾"
            })
        else
            log("ChinStringFixes not found")
        end

    end)
end

--[[
		--Watchdogs Early Boat Driver Restoration
		["bot_watchdogs_new_stage2_01_any_02"] = "这里是运输艇。我收到信号了，马上就来。",
		["bot_watchdogs_new_stage2_01_any_03"] = "这里是运输艇。我看到信号了，在路上了。",

		["bot_watchdogs_new_stage2_05_any_02"] = "我来了，把包丢上来吧！",
		["bot_watchdogs_new_stage2_05_any_03"] = "好了兄弟们，快把包丢过来吧！",
		["bot_watchdogs_new_stage2_05_any_04"] = "我就位了，赶紧把包都丢进来吧！",

		["bot_watchdogs_new_stage2_06_any_01"] = "货一次四包，别丢多了！",
		["bot_watchdogs_new_stage2_06_any_02"] = "不好意思，我一次只能带四包！等会再来拿剩下的。",
		["bot_watchdogs_new_stage2_06_any_03"] = "一次撑死四包！货且运下，我去去就回。",

		["bot_watchdogs_new_stage2_07_any_01"] = "必须！得！再快点！",
		["bot_watchdogs_new_stage2_07_any_02"] = "把桶装满，快快快！",
		["bot_watchdogs_new_stage2_07_any_03"] = "快点，快点，再快点！",


		["bot_watchdogs_new_stage2_08_any_02"] = "那就满四包了！",
		["bot_watchdogs_new_stage2_08_any_03"] = "好了，桶装满了！", 

		["bot_watchdogs_new_stage2_09_any_01"] = "我先把这些东西带走，待会再回来！",
		["bot_watchdogs_new_stage2_09_any_02"] = "如果你们还想贪包，我很快就会回来的！",
		["bot_watchdogs_new_stage2_09_any_03"] = "船满了我先走了！别担心，我片刻即归。",

		["bot_watchdogs_new_stage2_10_any_01"] = "我卸完货了，马上回来！",
		["bot_watchdogs_new_stage2_10_any_02"] = "卸完了！爷来辣！",
		["bot_watchdogs_new_stage2_10_any_03"] = "稍等......我卸完货了，正全速驶回！",

		["bot_watchdogs_new_stage2_11_any_01"] = "兄啊，我让你丢桶里，不是水里！",
		["bot_watchdogs_new_stage2_11_any_02"] = "我说啥来着？丢进桶里，对吧？！",
		["bot_watchdogs_new_stage2_11_any_03"] = "你他妈在逗我吗？！丢桶里明白吗？？",

		["bot_watchdogs_new_stage2_12_any_01"] = "收到！我会停靠在码头7。",
		["bot_watchdogs_new_stage2_12_any_02"] = "收到！正在向码头7靠近。",
		["bot_watchdogs_new_stage2_12_any_03"] = "明白了，码头7见面！",

		["bot_watchdogs_new_stage2_13_any_01"] = "收到！我会停靠在码头8。",
		["bot_watchdogs_new_stage2_13_any_02"] = "收到！正在向码头8靠近。",
		["bot_watchdogs_new_stage2_13_any_03"] = "明白了，码头8见面！",

		["bot_watchdogs_new_stage2_14_any_01"] = "收到！我会停靠在码头9。",
		["bot_watchdogs_new_stage2_14_any_02"] = "收到！正在向码头9靠近。",
		["bot_watchdogs_new_stage2_14_any_03"] = "明白了，码头9见面！",
		--]]
