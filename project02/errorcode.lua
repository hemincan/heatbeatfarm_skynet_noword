local ERRORCODE = {
	moneyandtype=10011,--钱和水果类型不合法
	nopeople=10012,--此人不存在
	dealerya=10013,--地主不能压
	havedya=10014,--已经压过此类型
	yanoenoughmoney=10015,--没有足够的钱
	uppermoneylimit=10016,--压钱超上限

	gameisprepare=10017,--游戏正在准备中，稍后再压

	--新玩家
	useralreadyexit=10021,--已经存在该玩家
	--退出队列
	notinlist=10022,--不在队列列表
	--想加入庄家队列
	alreadyisdealer=10031,--已经是庄家，不要再排队
	wantdealernoenoughmoney=10032,--想当庄家没有那么多钱
	alreadyonlist=10033,--已经在排队中


	notadealernexttime=10041,--下庄成功,下回不是庄家了
}
return ERRORCODE