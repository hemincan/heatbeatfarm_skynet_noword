local ERRORCODE = {
	moneyandtype=10011,--钱和水果类型不合法
	[10011]="钱和水果类型不合法",
	nopeople=10012,--此人不存在
	[10012]="此人不存在",
	dealerya=10013,--地主不能压
	[10013]="地主不能压",
	havedya=10014,--已经压过此类型
	[10014]="已经压过此类型",
	yanoenoughmoney=10015,--没有足够的钱
	[10015]="没有足够的钱",
	uppermoneylimit=10016,--压钱超上限
	[10016]="压钱超上限",
	gameisprepare=10017,--游戏正在准备中，稍后再压
	[10017]="游戏正在准备中，稍后再压",
	--新玩家
	useralreadyexit=10021,--已经存在该玩家
	[10021]="已经存在该玩家",
	--退出队列
	notinlist=10022,--不在队列列表
	[10022]="不在队列列表",
	--想加入庄家队列
	alreadyisdealer=10031,--已经是庄家，不要再排队
	[10031]="已经是庄家，不要再排队",
	wantdealernoenoughmoney=10032,--想当庄家没有那么多钱
	[10032]="想当庄家没有那么多钱",
	alreadyonlist=10033,--已经在排队中
	[10033]="已经在排队中",
	notadealernexttime=10041,--下庄成功,下回不是庄家了
	[10041]="下庄成功,下回不是庄家了",
	------------------------------------------------------xwx
	--登陆
	nameorpwd=20001,
	[20001]="用户名或密码错误",
	nouacount=20002,
	[20002]="不存在该用户",
	havedlogin=20003,--
	[20003]="不能重复登陆",
	nameorpwdnill=20004,
	[20004]="帐号或密码不能为空",
	--获取用户信息
	getusermsgfailed=20005,
	[20005]="获取用户信息失败",
	--注册
	haveduacount=20101,
	[20101]="已存在该用户",
	pwdandrepwd=20102,
	[20102]="两次密码不一致",
	registerfailed=20103,
	[20103]="注册失败",
	emptyuaccount=20104,
	[20104]="账户名不能为空",
	emptyupassword=20105,
	[20105]="密码不能为空",
	illegal=20106,
	[20106]="含有非法字符yk",
	uaccounttoolong=20107,
	[20107]="帐号长度不能超过8位",
	uaccountchinese=20108,
	[20108]="帐号不能包含中文",
	upasswordchinese=20109,
	[20109]="密码不能包含中文",
	upasswordMempty=20110,
	[20110]="密码不能包含空格" ,
	upasswordtoolong=20111,
	[20111]="密码长度不能超过20位",
	upasswordtooshort=20112,
	[20112]="密码长度不能低于6位",

	 	
	--修改昵称
	editeusername=20201,
	[20201]="修改昵称失败",
	havethisusername=20202,
	[20202]="该昵称已被使用",
	usernametoolong=20203,
	[20203]="昵称长度不能超过8位",
	emptyusername="20204",
	[20204]="昵称不能为空",
	containempty=20205,
	[20205]="昵称不能包含空格符",
	illegalusername=20206,
	[20206]="昵称包含非法字符",
	--创建房间/快速进入房间
	createhourse=20301,
	[20301]="创建房间失败",
	fastinnerhourse=20302,
	[20302]="快速进入房间失败",
	havehourse=20303,
	[20303]="已有房间请等待房间结算完毕之后操作",
	--修改登陆密码
	editupassword=20401,
	[20401]="修改密码失败",
	upassworderror=20402,
	[20402]="原登陆密码填写错误",
	--[[upasswordchinese=20109,
	[20109]="密码不能包含中文",
	upasswordMempty=20110,
	[20110]="密码不能包含空格" ,
	--]]
	--修改银行卡密码
	editbankpassword=20501,
	[20501]="修改银行卡密码失败",
	bankpassworderror=20502,
	[20502]="原银行卡密码填写错误",
	--[[upasswordchinese=20109,
	[20109]="密码不能包含中文",
	upasswordMempty=20110,
	[20110]="密码不能包含空格" ,
	--]]	
	--连接超时
	overtime=20601,
	[20601]="连接超时,请重新登陆",
	reconnecterror=20602,
	[20602]="重连出错,请重新登陆",

	getmsgovertime=20603,
	[20603]="获取信息超时",

	--
	deposittoobig=20701,
	[20701]="存钱金额不能大于现金",
	Withdrawtoobig=20702,
	[20702]="取钱金额不能大于银行金额",
	moneyisnegative=20503,
	[20703]="金额不能为负数",


}
return ERRORCODE