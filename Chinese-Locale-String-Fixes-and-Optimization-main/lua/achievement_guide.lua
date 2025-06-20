local schinese = Idstring("schinese"):key() == SystemInfo:language():key()
if not schinese and not CHNMOD_PATCH then
	return
end

--[[if restoration then
	return
end--]]

if not ChinStringFixes.settings.Enable_String then
	return
end

if not ChinStringFixes or not ChinStringFixes.settings.Achievement_Guide then
	return
end



Hooks:Add("LocalizationManagerPostInit", "ChinStringFixes_Achei", function(loc)

	LocalizationManager:add_localized_strings({
		sm_17_obj = "完成\"石油大亨\"任务，难度为非常困难或以上。\n要完成此任务，你必须从头开始劫案。\n完成后要领取奖励，请使用鼠标滑轮滑下去点击奖励图标。\n\n注意事项：你将需要在第二天的豪宅中找到并收集正确的引擎。\n判断正确引擎的方法：（您可以使用截图或拍照记下该方法和需要搜集的线索）\n1.首先，搜集我们需要的线索。\n在豪宅中找到2个写有可识别英文字母的纸质笔记本，并在地下室楼梯前的墙上找到一块写有三个等于号的白板，以及在地下室的房间中找到一台写有5783psi或5812psi的计算机电脑。\n2.然后，分析辨别我们需要的线索。\n记住白板等于号左边的三个单词，检查笔记本和电脑，其中一个笔记本上写有三个单词中的一个，对应的是白板上等于号右边英文描述的颜色；另一个笔记本上写有H,2xH或3xH；电脑的数字左边会写有大于等于或小于等于的符号。\n3.再来，我们了解引擎的构成。\n引擎由1个斜着放的不同颜色的管子、1个正着放的大蓝管和1个气压表组成。\n4.最后，我们找出正确的引擎。\n单词和白板对应的颜色是斜管的颜色；H,2xH,3xH分别代表正大蓝管的顶部接着1,2,3条线；大于等于和小于等于分别代表气压大于等于或小于等于表上的红色线值。\n若有气压远大于或远小于红线的，那就一定不可能是气压接近红线的引擎。",
    	achievement_dark_5_desc = "在\"午夜车站\"任务中，在每个垃圾箱中藏匿一个尸体袋并完成劫案。\n\n总共有4个垃圾桶。",
    	achievement_mad_3_additional = "AI队友的击杀数将计入此成就。要完成此成就，你必须从头开始劫案。使用其他武器完成击杀会导致此成就失败。\n\n该成就检测敌人的死亡方式，当敌人被非近战武器杀死时成就失效。因此你不能带AI队友，不能用哨戒机枪，不能抓变节敌人。但你仍可以开火，对敌人射击（只要不杀死他），用便携式电锯开门，只要不用近战之外的方式杀死敌人都是可以的。",
    	achievement_cac_16_desc = "在\"石油大亨\"任务的第二天，让拜尔触发警报。\n\n以潜入流程拿到引擎并点燃信号棒，拜尔到来时就会触发警报，完成成就。",
    	achievement_doctor_fantastic_desc = "在\"石油大亨\"任务的第二天，第一次就拿到正确引擎并完成劫案。\n\n判断正确引擎的方法：（您可以使用截图或拍照记下该方法和需要搜集的线索）\n1.首先，搜集我们需要的线索。\n在豪宅中找到2个写有可识别英文字母的纸质笔记本，并在地下室楼梯前的墙上找到一块写有三个等于号的白板，以及在地下室的房间中找到一台写有5783psi或5812psi的计算机电脑。\n2.然后，分析辨别我们需要的线索。\n记住白板等于号左边的三个单词，检查笔记本和电脑，其中一个笔记本上写有三个单词中的一个，对应的是白板上等于号右边英文描述的颜色；另一个笔记本上写有H,2xH或3xH；电脑的数字左边会写有大于等于或小于等于的符号。\n3.再来，我们了解引擎的构成。\n引擎由1个斜着放的不同颜色的管子、1个正着放的大蓝管和1个气压表组成。\n4.最后，我们找出正确的引擎。\n单词和白板对应的颜色是斜管的颜色；H,2xH,3xH分别代表正大蓝管的顶部接着1,2,3条线；大于等于和小于等于分别代表气压大于等于或小于等于表上的红色线值。\n若有气压远大于或远小于红线的，那就一定不可能是气压接近红线的引擎。",
    	achievement_gage2_1_desc = "在\"石油大亨\"任务的第二天中，递交所有错误的引擎，并将正确的引擎最后递交，难度为枪林弹雨或以上。\n\n判断正确引擎的方法：（您可以使用截图或拍照记下该方法和需要搜集的线索）\n1.首先，搜集我们需要的线索。\n在豪宅中找到2个写有可识别英文字母的纸质笔记本，并在地下室楼梯前的墙上找到一块写有三个等于号的白板，以及在地下室的房间中找到一台写有5783psi或5812psi的计算机电脑。\n2.然后，分析辨别我们需要的线索。\n记住白板等于号左边的三个单词，检查笔记本和电脑，其中一个笔记本上写有三个单词中的一个，对应的是白板上等于号右边英文描述的颜色；另一个笔记本上写有H,2xH或3xH；电脑的数字左边会写有大于等于或小于等于的符号。\n3.再来，我们了解引擎的构成。\n引擎由1个斜着放的不同颜色的管子、1个正着放的大蓝管和1个气压表组成。\n4.最后，我们找出正确的引擎。\n单词和白板对应的颜色是斜管的颜色；H,2xH,3xH分别代表正大蓝管的顶部接着1,2,3条线；大于等于和小于等于分别代表气压大于等于或小于等于表上的红色线值。\n若有气压远大于或远小于红线的，那就一定不可能是气压接近红线的引擎。",
    	achievement_bob_8_desc = "在\"选举日\"任务的第一天，潜入并使用电脑找到正确的货车，并且全程不触碰地面。\n\n出生所在的位置以及窗台不属于地面，成就将在你与电脑互动后解锁。",
    	achievement_bob_5_desc = "在\"选举日\"任务的第一天，标记正确的卡车。\n\n找到并使用电脑进行多次互动，电脑上显示的标志即为错误卡车的标志。",
    	achievement_bob_4_desc = "在\"选举日\"任务的第二天，偷走仓库区全部的额外战利品。\n\n要用钥匙卡开的安全门内有多包现金，从安全门上方可以看到安全门内的物品情况。但在祸乱横行及以上难度下，安全门顶部会有东西遮挡视线，可携带手电筒调整角度观察安全门内的战利品情况。",
    	achievement_bob_3_desc = "在\"选举日\"任务中，潜入完成劫案并将选票结果改为对共和党有利。\n\n在第一天选择正确的卡车，并成功潜入完成第二天即可。",
    	achievement_bob_7_desc = "在\"选举日\"任务中，潜入完成劫案并将选票结果改为对共和党有利，难度为死亡之愿或以上。\n\n在第一天标记正确的卡车，并成功潜入完成第二天即可。",
    	achievement_bob_6_desc = "在\"选举日\"任务的第一天，标记错误的卡车，随后在金库中一无所获。\n\n在第一天标记错误的卡车后，第二天会进入C计划地图。第二天开始游戏后，有10%的几率金库中一包现金都没有，此时打开并进入金库就能完成成就。",
    	achievement_fish_6_desc = "在\"游艇结案\"任务中，击杀船上所有警卫并完成任务。\n\n普通难度下共有8名警卫。",
    	achievement_gage3_15_desc = "仅使用R93狙击步枪穿透墙壁或其它非盾兵盾牌物体击杀25名敌人。",
    	achievement_cow_3_desc = "在\"炸弹劫案：森林\"任务中，于5秒内砍倒全部5颗树。",
    	achievement_cac_11_desc = "在\"落水狗劫案\"任务的第一天，将加内特集团精品店的收银员变节并为你而战。\n\n注意：该劫案采用倒叙的手法，第一关为第二天，第二关才是第一天。",
    	achievement_cow_4_desc = "在\"炸弹劫案：森林\"任务中，使用水泵时不让警察断开水管。\n\n如果车厢靠近河边会选用水泵灌水的方案，所以建议预计划购买爆破专家，把车厢控制在河道附近。水管的每个连接口都是需要防守的地方，可以在预计划购买王牌飞行员和强化水泵，缩短防守需要的时间。"
	})

end)
