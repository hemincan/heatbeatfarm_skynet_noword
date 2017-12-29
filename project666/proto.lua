local proto = {
	"gamestatus",
    gamestatus = {
		"dealer",
		"dealermoney",
		"score",
		"reselect",
		"luobo",
		"baicai",
		"wandou",
		"nangua",
		"gangzhe",
		"mogu",
		"guangchangsu",
		"yidianhong",
		"waitinglist",--从此变成数字
		"mystatus",
		-- "onlinepeople",--不要
		"session",
		-- waitinglist={},
		-- onlinepeople={},
		mystatus={
			  "money",
		      "luobo",
		      "baicai",
		      "wandou",
		      "nangua",
		      "gangzhe",
		      "mogu",
		      "guangchangsu",
		      "yidianhong",
		      "currentwin",
		      "win",
		      "mylistnum",
		},
	},

	"onlinepeople",
	onlinepeople={
		"onlinepeople",
		onlinepeople={},
		"session",
	},

	"prepare",
	prepare={
		"time",
		"session",
	},

	"busy",
	busy={
		"time",
		"session",
	},

	"result",
	result={
		"time",
		"result",
		"index",
		"session",
	},
	"show",
	show={
		"session"
		},
		
	"error",
	error={
		"code",
		"session",
	},
	"leavehoursesuccess",
	leavehoursesuccess={
		"session",
	},
	"history",
	history={
		"session",
		"historylist",
		historylist={},
	},
--------客户请求-----------
	"getgamestatus",
	"getonlinepeople",
	"wantdealer",
	"exitdearlerlist",
	"exitdealer",
	"leavehourse",
	"gethistorylist",

	"yaluobo",
	 yaluobo={"money"},

	"yabaicai",
	 yabaicai={"money"},

	"yawandou",
	 yawandou={"money"},	

	"yanangua",
	yanangua={"money"},

	"yagangzhe",
	yagangzhe={"money"},

	"yamogu",
	yamogu={"money"},

	"yaguangchangsu",
	yaguangchangsu={"money"},

	"yayidianhong",
	yayidianhong={"money"},

	
----------------------------------------
------------------------------xwx
	--登陆请求
	"login",
	login={
		"uaccount",
		"upassword",
		"handshake",
		"visitor",
	},	

	--响应
	"responselogin",
	responselogin={
		"handshake",
		"session",
	},
	--游客登陆
	"visitor",
	visitor={"uaccount","upassword","handshake","visitor",},
	--游客登陆响应
	"responsevisitor",
	responsevisitor={"handshake","uaccount","upassword","session",},
	"Recharge",--假充值
	Recharge={
		"cash",
		"uaccount",
	},

	--假充值响应
	"responseRecharge",
	responseRecharge={"session"},

	--请求注册
	"register",
	register={
		"repassword",
		"uaccount",
		"username",
		"upassword",
	},
	--注册返回
	"responseregister",
	responseregister={
		"handshake",
		"session",
	},
	--重连
	"reconnect",
	reconnect={	"uaccount","upassword","handshake","visitor",},

	"responsereconnect",
	responsereconnect={
		"session",
	},

	--查看用户信息
	"usermsg",
	--响应
	"responseusermsg",
	responseusermsg={"uaccount","cash","username","session","ishavehourse","portrait",},
	--修改昵称
	"editeusername",
	editeusername={
		"newusername",
	},
	--修改昵称返回
	"responseediteusername",
	responseediteusername={
		"session",
	},
	--修改密码
	"editupassword",
	editupassword={
		"upassword",
		"newupassword",
	},
	--修改密码返回
	"responseeditupassword",
	responseeditupassword={
		"session",
	},

	--修改银行卡密码
	"editbankpassword",
	editbankpassword={
		"bpassword",
		"newbpassword",
	},
	--修改银行密码返回
	"responseeditbankpassword",
	responseeditbankpassword={
		"session",
	},
	--快速进入房间
	"fastinnerHourse",
	--退出游戏
	"logout",
	--心跳
	"heart",
	--创建房间
	"createhourse",
	--日排行榜
	--金币总榜
	--银行信息
	"bankmoney",


	----何敏灿
	"getyesdaylist",
	"yesdaylist",--日排行
	yesdaylist={
		"session",
		"list",
		list={},
	},

	"getyesdayalllist",
	"yesdayalllist",--昨日总排行 
	yesdayalllist={
		"session",
		"list",
		list={},
	},
	---谢武幸
	--快速进入房间，创建房间返回
	"responsehoursesuccess",
	responsehoursesuccess={session,},
	--在线奖励详情
	"onlineRewards",
	--银行信息返回
	"responsebankmoney",
	responsebankmoney={"cash","deposit","session",},
	--存款
	"depositbank",
	depositbank={"money",},
	--存款返回
	"responsedepositbank",
	responsedepositbank={"session",},
	--取款
	"Withdrawbank",
	Withdrawbank={"money","bpassword",},
	--取款返回
	"responseWithdrawbank",
	responseWithdrawbank={session},
	
	--在线奖励详情返回
	"responseonlineRewards",
	responseonlineRewards={"session","onlineTime","status",status={"stage1","stage2","stage3","stage4",},},
	--领取奖励30分钟
	"getrewardsstage1",
	--领取奖励1小时
	"getrewardsstage2",
	--领取奖励3小时
	"getrewardsstage3",
	--领取奖励5小时
	"getrewardsstage4",
	--领奖成功
	"responsestage1",
	responsestage1={"session","money",},
	"responsestage2",
	responsestage2={"session","money",},
	"responsestage3",
	responsestage3={"session","money",},
	"responsestage4",
	responsestage4={"session","money",},
	--是否有救济金
	"reliefmoney",
	--
	"responsereliefmoney",
	responsereliefmoney={"session","status",},
	--领取救济金
	"getreliefmoney",
	--返回
	"responsegetreliefmoney",
	responsegetreliefmoney={"session","money",},
	--商城
	"shoppingmall",
	--返回
	"responsemall",
	responsemall={"item1","item2","item3","item4","session",},
	--提交商品订单
	"submitorder",
	submitorder={"item",},
	--返回
	"responseorder",
	responseorder={"session","itemcode"},
	--支付
	"paymoney",
	--返回
	"responsepay",
	responsepay={"session",},
	
	"messsage",
	messsage={
		"newmsg",
		"session",
	},
	--编辑用户信息
	"editeusermsg",
	editeusermsg={"username","portrait",},
	--返回
	"responsemsg",
	responsemsg={"session",},

    --编辑用户头像
	"editeportrait",
	editeportrait={"portrait",},
	--返回
	"responseportrait",
	responsemsg={"session",},
}
return proto	