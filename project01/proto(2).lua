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
		"waitinglist",
		"mystatus",
		"onlinepeople",
		waitinglist={},
		onlinepeople={},
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
		}
	},
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
		"ispromit",
		"handshake",
		"msg",
		"session",
	},

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
		"ispromit",
		"msg",
		"session",
	},
	--修改昵称
	"editeusername",
	editeusername={
		"username",
		"newusername",
	},
	--修改昵称返回
	"responseediteusername",
	responseediteusername={
		"ispromit",
		"msg",
		"session",
	},
	--修改密码
	"editpassword",
	editpassword={

	},
	--修改密码返回
	"responseeditpassword",
	responseeditpassword={
		"ispromit",
		"error"
	}

	--修改银行卡密码
	"editbankpassword",
	editbankpassword={
		"oldpassword",
		"newbankpassword",
	}
	--修改密码返回
	"responseeditbankpassword",
	responseeditbankpassword={
	
	}
	
	--快速进入房间
	"fastenterhourse",

	--退出房间
	"logouthourse",
	--退出房间返回
	"responselogouthourse"
	responselogouthourse={
		"session",
	}
	--退出游戏
	"logout",
	--心跳
	"heart",
	--创建房间
	"createhourse",



}
return proto