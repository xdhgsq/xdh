#!/bin/sh

#set -x


red="\033[31m"
green="\033[32m"
yellow="\033[33m"
white="\033[0m"

#获取当前脚本目录copy脚本之家
Source="$0"
while [ -h "$Source"  ]; do
    dir_file="$( cd -P "$( dirname "$Source"  )" && pwd  )"
    Source="$(readlink "$Source")"
    [[ $Source != /*  ]] && Source="$dir_file/$Source"
done
dir_file="$( cd -P "$( dirname "$Source"  )" && pwd  )"
dir_file_js="$dir_file/js"

#检测当前位置
if [ "$dir_file" == "/usr/share/jd_openwrt_script/JD_Script" ];then
	openwrt_script="/usr/share/jd_openwrt_script"
	openwrt_script_config="/usr/share/jd_openwrt_script/script_config"
else
	clear
	echo -e "$red检测到你使用本地安装方式安装脚本，不再支持本地模式！！！${white}"
	exit 0
fi

ccr_js_file="$dir_file/ccr_js"
run_sleep=$(sleep 1)

version="2.3"
cron_file="/etc/crontabs/root"
node="/usr/bin/node"
tsnode="/usr/bin/ts-node"
python3="/usr/bin/python3"
sys_model=$(cat /tmp/sysinfo/model | awk -v i="+" '{print $1i$2i$3i$4}')
uname_version=$(uname -a | awk -v i="+" '{print $1i $2i $3}')

#给强迫症的福利
wan_ip=$(cat /etc/config/network | grep "wan" | wc -l)
if [ ! $wan_ip ];then
	wan_ip="找不到Wan IP"
else
	wan_ip=$(ubus call network.interface.wan status | grep \"address\" | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
fi

#Server酱
wrap="%0D%0A%0D%0A" #Server酱换行
wrap_tab="     "
line="%0D%0A%0D%0A---%0D%0A%0D%0A"
current_time=$(date +"%Y-%m-%d")
by="#### 脚本仓库地址:https://github.com/xdhgsq/xdh"

if [ ! -f $openwrt_script_config/Checkjs_Sckey.txt ];then
	echo >$openwrt_script_config/Checkjs_Sckey.txt
else
	echo >$dir_file/Checkjs_Sckey.txt
fi

if [ "$dir_file" == "/usr/share/jd_openwrt_script/JD_Script" ];then
	SCKEY=$(grep "let SCKEY" $openwrt_script_config/sendNotify.js  | awk -F "'" '{print $2}')
	if [ ! $SCKEY ];then
		SCKEY=$(cat $openwrt_script_config/Checkjs_Sckey.txt)
	fi
else
	SCKEY=$(cat $dir_file/Checkjs_Sckey.txt)
fi

#企业微信
weixin_line="------------------------------------------------"

start_script_time="脚本开始运行，当前时间：`date "+%Y-%m-%d %H:%M"`"
stop_script_time="脚本结束，当前时间：`date "+%Y-%m-%d %H:%M"`"
script_read=$(cat $dir_file/script_read.txt | grep "我已经阅读脚本说明"  | wc -l)

export JD_JOY_REWARD_NAME="500"

#开卡变量
export guaopencard_All="true"
export guaopencard_addSku_All="true"
export guaopencardRun_All="true"
export guaopencard_draw="true"

#资产变化，不推送以下内容变化
export BEANCHANGE_DISABLELIST="汪汪乐园&金融养猪"

task() {
	cron_version="4.02"
	if [[ `grep -o "JD_Script的定时任务$cron_version" $cron_file |wc -l` == "0" ]]; then
		echo "不存在计划任务开始设置"
		task_delete
		task_add
		echo "计划任务设置完成"
	else
			echo "计划任务与设定一致，不做改变"
			cron_help="${green}定时任务与设定一致${white}"
	fi
}

task_add() {
cat >>/etc/crontabs/root <<EOF
#**********这里是JD_Script的定时任务$cron_version版本#100#**********#
0 0 * * * $dir_file/jd.sh run_0  >/tmp/jd_run_0.log 2>&1 #0点0分执行全部脚本#100#
0 2-23/1 * * * $dir_file/jd.sh run_01 >/tmp/jd_run_01.log 2>&1 #种豆得豆收瓶子#100#
0 2-23/2 * * * $dir_file/jd.sh run_02 >/tmp/jd_run_02.log 2>&1 #摇钱树#100#
*/30 2-23 * * * $dir_file/jd.sh run_030 >/tmp/jd_run_030.log 2>&1 #两个工厂#100#
10 2-22/3 * * * $dir_file/jd.sh run_03 >/tmp/jd_run_03.log 2>&1 #天天加速 3小时运行一次，打卡时间间隔是6小时#100#
40 6-18/6 * * * $dir_file/jd.sh run_06_18 >/tmp/jd_run_06_18.log 2>&1 #不是很重要的，错开运行#100#
5 7 * * * $dir_file/jd.sh run_07 >/tmp/jd_run_07.log 2>&1 #不需要在零点运行的脚本#100#
35 10,15,20 * * * $dir_file/jd.sh run_10_15_20 >/tmp/jd_run_10_15_20.log 2>&1 #不是很重要的，错开运行#100#
10 8,12,16 * * * $dir_file/jd.sh run_08_12_16 >/tmp/jd_run_08_12_16.log 2>&1 #宠汪汪兑换礼品#100#
20 12,22 * * * $dir_file/jd.sh update_script that_day >/tmp/jd_update_script.log 2>&1 #22点20更新JD_Script脚本#100#
00 10 */7 * * $dir_file/jd.sh check_cookie_push >/tmp/check_cookie_push.log 2>&1 #每个7天推送cookie相关信息#100#
5 11,19,22 * * * $dir_file/jd.sh update >/tmp/jd_update.log 2>&1 && source /etc/profile #9,11,19,22点05分更新lxk0301脚本#100#
0 0,7 * * * $node $dir_file_js/jd_bean_sign.js >/tmp/jd_bean_sign.log #京东多合一签到#100#
0 */4 * * * $node $dir_file_js/jd_dreamFactory_tuan.js	>/tmp/jd_dreamFactory_tuan.log	#京喜开团#100#
0 8,15 * * * $python3 $dir_file/git_clone/curtinlv_script/OpenCard/jd_OpenCard.py  >/tmp/jd_OpenCard.log #开卡程序#100#
59 23 * * * sleep 50 && $dir_file/jd.sh run_jd_blueCoin >/tmp/jd_jd_blueCoin.log	#京东超市兑换#100#
59 */1 * * * $dir_file/jd.sh jd_time >/tmp/jd_time.log	#同步京东时间#100#
0 10 * * * $dir_file/jd.sh zcbh	>/tmp/jd_bean_change_ccwav.log	#资产变化一对一#100#
50 23 * * * $dir_file/jd.sh kill_ccr #杀掉所有并发进程，为零点准备#100#
46 23 * * * rm -rf /tmp/*.log #删掉所有log文件，为零点准备#100#
###########100##########请将其他定时任务放到底下###############
#**********这里是backnas定时任务#100#******************************#
45 12,19 * * * $dir_file/jd.sh backnas  >/tmp/jd_backnas.log 2>&1 #每4个小时备份一次script,如果没有填写参数不会运行#100#
############100###########请将其他定时任务放到底下###############
EOF
	/etc/init.d/cron restart
	cron_help="${yellow}定时任务更新完成，记得看下你的定时任务${white}"
}

task_delete() {
        sed -i '/#100#/d' /etc/crontabs/root >/dev/null 2>&1
}

ds_setup() {
	echo "JD_Script删除定时任务设置"
	task_delete
	echo "JD_Script删除全局变量"
	sed -i '/JD_Script/d' /etc/profile >/dev/null 2>&1
	source /etc/profile
	echo "JD_Script定时任务和全局变量删除完成，脚本彻底不会自动运行了"
}

update() {
	#ss_if

	cat $openwrt_script_config/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | grep -v "//'" |grep -v "// '" > $openwrt_script_config/js_cookie.txt

	if [ ! -d $dir_file/git_clone ];then
		mkdir $dir_file/git_clone
	fi

	if [ ! -d $dir_file/git_clone/lxk0301_back ];then
		echo ""
		#git clone -b master git@gitee.com:lxk0301/jd_scripts.git $dir_file/git_clone/lxk0301
		git clone https://github.com/ITdesk01/script_back.git $dir_file/git_clone/lxk0301_back
	else
		cd $dir_file/git_clone/lxk0301_back
		git fetch --all
		git reset --hard origin/main
	fi

	if [ ! -d $dir_file/git_clone/curtinlv_script ];then
		echo ""
		git clone https://github.com/curtinlv/JD-Script.git $dir_file/git_clone/curtinlv_script
		curtinlv_script_setup
	else
		cd $dir_file/git_clone/curtinlv_script
		git fetch --all
		git reset --hard origin/main
		curtinlv_script_setup
	fi

	echo -e "${green} update$start_script_time ${white}"
	echo -e "${green}开始下载JS脚本，请稍等${white}"
#cat script_name.txt | awk '{print length, $0}' | sort -rn | sed 's/^[0-9]\+ //'按照文件名长度降序：
#cat script_name.txt | awk '{print length, $0}' | sort -n | sed 's/^[0-9]\+ //' 按照文件名长度升序

rm -rf $dir_file/config/tmp/*

#lxk0301_back
cat >$dir_file/config/tmp/lxk0301_script.txt <<EOF
	jd_fruit.js			#东东农场
	jd_pet.js			#东东萌宠
	jd_dreamFactory.js		#京喜工厂
	jd_delCoupon.js			#删除优惠券（默认不运行，有需要手动运行）
	jd_unsubscribe.js		#取关京东店铺和商品
	jdPetShareCodes.js
	jdJxncShareCodes.js
	jdFruitShareCodes.js
	jdFactoryShareCodes.js
	jdPlantBeanShareCodes.js
	jdDreamFactoryShareCodes.js
EOF

for script_name in `cat $dir_file/config/tmp/lxk0301_script.txt | grep -v "#.*js" | awk '{print $1}'`
do
	echo -e "${yellow} copy ${green}$script_name${white}"
	cp  $dir_file/git_clone/lxk0301_back/$script_name  $dir_file_js/$script_name
done

sleep 5

#zero205
zero205_url="https://raw.githubusercontent.com/zero205/JD_tencent_scf/main"
cat >$dir_file/config/tmp/zero205_url.txt <<EOF
	sign_graphics_validate.js
	jd_bean_sign.js			#京东多合一签到
	JDSignValidator.js		#京东多合一签到依赖1
	JDJRValidator_Aaron.js		#京东多合一签到依赖2
	jd_try.js 			#京东试用（默认不启用）
	jd_get_share_code.js		#获取jd所有助力码脚本
	jd_joy_park_task.js		#汪汪乐园
	jd_nnfls.js			#牛牛福利
	jd_gold_creator.js		#金榜创造营
	jd_cfd_pearl_ex.js 		#财富岛珍珠兑换
	jd_jdzz.js			#京东赚赚
	jd_babel_sign.js		#通天塔签到
	jd_xmf.js			#京东小魔方
	jd_ms.js			#秒秒币
EOF

for script_name in `cat $dir_file/config/tmp/zero205_url.txt | grep -v "#.*js" | awk '{print $1}'`
do
{
	url="$zero205_url"
	wget $zero205_url/$script_name -O $dir_file_js/$script_name
	update_if
}&
done

#Aaron
Aaron_url="https://raw.githubusercontent.com/Aaron-lv/sync/jd_scripts"
cat >$dir_file/config/tmp/Aaron_url.txt <<EOF
	jd_ccSign.js			#领券中心签到
	#jd_cash.js			#签到领现金，每日2毛～5毛长期
	jd_connoisseur.js		#内容鉴赏官
	jd_jxmc.js			#京喜牧场
	jx_sign.js			#京喜签到
	jd_club_lottery.js		#摇京豆
	jd_kd.js			#京东快递签到 一天运行一次即可
	jd_speed_sign.js		#京东极速版签到+赚现金任务
	jd_exchangejxbeans.js		#过期京豆兑换为喜豆
	jd_plantBean.js			#种豆得豆
	jd_jxlhb.js			#惊喜领红包
	jd_bean_home.js			#领京豆额外奖励&抢京豆
EOF

for script_name in `cat $dir_file/config/tmp/Aaron_url.txt | grep -v "#.*js" | awk '{print $1}'`
do
	url="$Aaron_url"
	wget $Aaron_url/$script_name -O $dir_file_js/$script_name
	update_if
done


#smiek2221
smiek2221_url="https://raw.githubusercontent.com/smiek2121/scripts/master"
cat >$dir_file/config/tmp/smiek2221_url.txt <<EOF
	gua_MMdou.js                    #赚京豆MM豆
	jd_sign_graphics.js		#京东签到图形验证
EOF

for script_name in `cat $dir_file/config/tmp/smiek2221_url.txt | grep -v "#.*js" | awk '{print $1}'`
do
{
	url="$smiek2221_url"
	wget $smiek2221_url/$script_name -O $dir_file_js/$script_name
	update_if
}&
done

#6dylan6
github_6dylan6_url_url="https://raw.githubusercontent.com/6dylan6/jdpro/main"
cat >$dir_file/config/tmp/github_6dylan6_url_url.txt <<EOF
	jd_price.js			#京东价保
	jd_plusdraw.js			#PLUS转盘抽豆
	jd_wdz.js			#微定制瓜分京豆
	jd_kws.js 			#科沃斯联合活动抽奖机
	jd_jmofang.js			#京东集魔方
	jd_syj.js			#赚京豆
EOF

for script_name in `cat $dir_file/config/tmp/github_6dylan6_url_url.txt | grep -v "#.*js" | awk '{print $1}'`
do
{
	url="$github_6dylan6_url_url"
	wget $github_6dylan6_url_url/$script_name -O $dir_file_js/$script_name
	update_if
}&
done

#okyyds
okyyds_url="https://raw.githubusercontent.com/okyyds/yyds/master"
cat >$dir_file/config/tmp/okyyds_url.txt <<EOF
	jd_wq_wxsign.js 		#微信签到领红包
	jd_health_plant.py		#京东健康社区-种植园
	gua_cleancart_ddo.js		#清空购物车(需要设置)
	jd_computer.js			#电脑配件ID任务
EOF

for script_name in `cat $dir_file/config/tmp/okyyds_url.txt | grep -v "#.*js" | awk '{print $1}'`
do
{
	url="$okyyds_url"
	wget $okyyds_url/$script_name -O $dir_file_js/$script_name
	update_if
}&
done

#KingRan
KingRan_url="https://raw.githubusercontent.com/KingRan/KR/main"
cat >$dir_file/config/tmp/KingRan_url.txt <<EOF
	jd_cjzdgf.js			#CJ组队瓜分京豆
	jd_zdjr.js			#组队瓜分
	jd_29_8.js			#极速版抢29-8优惠券
	jd_5_2.js			#极速版抢5-2优惠券
	jd_19_6.js			#极速版抢19-6优惠券
	jd_nzmh.js			#女装盲盒
	jd_mpdzcar.js			#头文字Ｊ
	jd_mpdzcar_game.js		#头文字Ｊ游戏
	jd_mpdzcar_help.js		#头文字Ｊ助力
	jd_fanli.js			#京东饭粒
	jd_xtc.js			#小天才联合活动抽奖机
	jd_daily_lottery.js		#小鸽有礼 - 每日抽奖
EOF

for script_name in `cat $dir_file/config/tmp/KingRan_url.txt | grep -v "#.*js" | awk '{print $1}'`
do
	url="$KingRan_url"
	wget $KingRan_url/$script_name -O $dir_file_js/$script_name
	update_if
done

#yuannian1112
yuannian1112_url="https://raw.githubusercontent.com/yuannian1112/jd_scripts/main"
cat >$dir_file/config/tmp/yuannian1112_url.txt <<EOF
	jd_dwapp.js			#积分换话费
EOF

for script_name in `cat $dir_file/config/tmp/yuannian1112_url.txt | grep -v "#.*js" | awk '{print $1}'`
do
{
	url="$yuannian1112_url"
	#wget $yuannian1112_url/$script_name -O $dir_file_js/$script_name
	#update_if
}&
done



#star261
star261_url="https://raw.githubusercontent.com/star261/jd/main/scripts"
cat >$dir_file/config/tmp/star261_url.txt <<EOF
	#jd_dreamFactory_tuan.js 	#京喜开团　star261脚本
	jd_fan.js			#粉丝互动
EOF

for script_name in `cat $dir_file/config/tmp/star261_url.txt | grep -v "#.*js" | awk '{print $1}'`
do
	url="$star261_url"
	wget $star261_url/$script_name -O $dir_file_js/$script_name
	update_if
done

#X1a0He
X1a0He_url="https://raw.githubusercontent.com/X1a0He/jd_scripts_fixed/main"
cat >$dir_file/config/tmp/X1a0He_url.txt <<EOF
	jd_jin_tie_xh.js  		#领金贴
EOF

for script_name in `cat $dir_file/config/tmp/X1a0He_url.txt | grep -v "#.*js" | awk '{print $1}'`
do
	url="$X1a0He_url"
	wget $X1a0He_url/$script_name -O $dir_file_js/$script_name
	update_if
done

#ccwav
ccwav_url="https://raw.githubusercontent.com/ccwav/QLScript2/main"
cat >$dir_file/config/tmp/ccwav_url.txt <<EOF
	jd_bean_change.js		#资产变化强化版by-ccwav
EOF

for script_name in `cat $dir_file/config/tmp/ccwav_url.txt | grep -v "#.*js" | awk '{print $1}'`
do
	url="$ccwav_url"
	wget $ccwav_url/$script_name -O $dir_file_js/$script_name
	update_if
done

#cdle_carry
cdle_carry_url="https://raw.githubusercontent.com/cdle/carry/main"
cat >$dir_file/config/tmp/cdle_carry_url.txt <<EOF
	jd_angryKoi.js		#愤怒的锦鲤
EOF

for script_name in `cat $dir_file/config/tmp/cdle_carry_url.txt | grep -v "#.*js" | awk '{print $1}'`
do
	url="$cdle_carry_url"
	wget $cdle_carry_url/$script_name -O $dir_file_js/$script_name
	update_if
done


	wget https://raw.githubusercontent.com/whyour/hundun/master/quanx/jx_products_detail.js -O $dir_file_js/jx_products_detail.js #京喜工厂商品列表详情
	wget https://raw.githubusercontent.com/Aaron-lv/sync/jd_scripts/utils/JDJRValidator_Pure.js -O $dir_file_js/JDJRValidator_Pure.js #因为路径不同单独下载.
	
	wget https://raw.githubusercontent.com/curtinlv/JD-Script/main/jd_cookie.py -O $dir_file_js/jd_cookie.py
	wget https://raw.githubusercontent.com/curtinlv/JD-Script/main/msg.py -O $dir_file_js/msg.py
	wget https://raw.githubusercontent.com/curtinlv/JD-Script/main/sendNotify.py -O $dir_file_js/sendNotify.py
	wget https://raw.githubusercontent.com/curtinlv/JD-Script/main/jd_getFollowGift.py -O $dir_file_js/jd_getFollowGift.py #关注有礼

	wget https://raw.githubusercontent.com/qiu-lzsnmb/jd_lzsnmb/jd/Evaluation.py -O $dir_file_js/Evaluation.py #自动评价
	wget https://raw.githubusercontent.com/ccwav/QLScript2/main/jd_bean_change.js -O $dir_file_js/jd_bean_change_ccwav.js		#资产变化强化版by-ccwav


#将所有文本汇总
echo > $dir_file/config/collect_script.txt
for i in `ls  $dir_file/config/tmp`
do
	cat $dir_file/config/tmp/$i >> $dir_file/config/collect_script.txt
done

cat >>$dir_file/config/collect_script.txt <<EOF
	jd_enen.js			#嗯嗯（尚方宝剑，一波流）
	jd_zjd.js			#赚京豆
	jd_cjzdgf.js 			#CJ组队瓜分京豆
	jd_wxCollectionActivity.js 	#加购物车抽奖
	jd_price.js 			#京东价保
	jd_bean_change_ccwav.js		#资产变化强化版by-ccwav
	jd_tyt.js			#极速版赚金币推一推
	jd_dpqd.js			#店铺签到
	jd_goodMorning.js		#早起福利
	Evaluation.py 			#自动评价
	jd_OpenCard.py 			#开卡程序
	jd_check_cookie.js		#检测cookie是否存活（暂时不能看到还有几天到期）
	getJDCookie.js			#扫二维码获取cookie有效时间可以90天
	jx_products_detail.js		#京喜工厂商品列表详情
EOF

#删掉过期脚本
cat >/tmp/del_js.txt <<EOF
	jd_yiligf.js			#一次性脚本，蚊子腿
	jd_xinruimz.js			#颜究种植园(需要手动选择种植小样)
EOF

for script_name in `cat /tmp/del_js.txt | grep -v "#.*js" | awk '{print $1}'`
do
	rm -rf $dir_file_js/$script_name
done


	if [ $? -eq 0 ]; then
		echo -e ">>${green}脚本下载完成${white}"
	else
		clear
		echo "脚本下载没有成功，重新执行代码"
		update
	fi
	chmod 755 $dir_file_js/*
	kill_index
	#index_js
	#删除重复的文件
	rm -rf $dir_file_js/*.js.*
	rm -rf $dir_file_js/*.py.*
	rm -rf $openwrt_script_config/check_cookie.txt
	
	#删除之前的黑名单
	if [ -f $dir_file/config/tmp/wget_eeror.txt ];then
		rm　-rf $openwrt_script_config/Script_blacklist.txt
	fi

	additional_settings
	concurrent_js_update
	source /etc/profile
	echo -e "${green} update$stop_script_time ${white}"
	if [ -f $dir_file/config/tmp/wget_eeror.txt ];then
		if [ ! `cat $dir_file/config/tmp/wget_eeror.txt | wc -l` == "0" ];then
			echo -e "${yellow}此次下载失败的脚本有以下：${white}"
			cat $dir_file/config/tmp/wget_eeror.txt
		fi
	fi

	task #更新完全部脚本顺便检查一下计划任务是否有变

}

update_if() {
	if [ $? -eq 0 ]; then
			echo -e ""
	else
		num="1"
		eeror_num="1"
		while [[ ${num} -gt 0 ]]; do
			wget $url/$script_name -O $dir_file_js/$script_name
			if [ $? -eq 0 ]; then
				num=$(expr $num - 1)
			else
				if [ $eeror_num -ge 3 ];then
					echo ">> ${yellow}$script_name${white}下载$eeror_num次都失败，跳过这个下载"
					num=$(expr $num - 1)
					echo "$script_name" >>$dir_file/config/tmp/wget_eeror.txt
				else
					echo -e ">> ${yellow}$script_name${white}下载失败,开始尝试第$eeror_num次下载，3次下载失败就不再重试。"
					eeror_num=$(expr $eeror_num + 1)
				fi
			fi
		done
	fi
}

update_script() {
	echo -e "${green} update_script$start_script_time ${white}"
	cd $dir_file
	git fetch --all
	git reset --hard origin/main
	echo -e "${green} update_script$stop_script_time ${white}"
}

ccr_run() {
#赚京豆-瓜分京豆脚本变量
export JD_SYJ=true

#这里不会并发
cat >/tmp/jd_tmp/ccr_run <<EOF
	jd_connoisseur.js		#内容鉴赏官
	jd_nnfls.js			#牛牛福利
	jx_sign.js			#京喜签到
	jd_gold_creator.js		#金榜创造营
	jd_dpqd.js			#店铺签到
	jd_tyt.js			#极速版赚金币推一推
	jd_joy_park_task.js		#汪汪乐园
	jd_babel_sign.js		#通天塔签到
	jd_wq_wxsign.js 		#微信签到领红包
	jd_fan.js			#粉丝互动
	jd_nzmh.js			#女装盲盒
	jd_plusdraw.js			#PLUS转盘抽豆
	jd_fanli.js			#京东饭粒
	jd_bean_home.js			#领京豆额外奖励&抢京豆
	jd_jmofang.js			#京东集魔方
	jd_daily_lottery.js		#小鸽有礼 - 每日抽奖
EOF
	for i in `cat /tmp/jd_tmp/ccr_run | grep -v "#.*js" | awk '{print $1}'`
	do
	{
		$node $openwrt_script/JD_Script/js/$i
		$run_sleep
	}&
	done

	sleep 3600
	$node $openwrt_script/JD_Script/js/jd_fruit.js & #东东水果，6-9点 11-14点 17-21点可以领水滴
	$node $openwrt_script/JD_Script/js/jd_jxlhb.js & #惊喜领红包
	$node $openwrt_script/JD_Script/js/jd_mpdzcar.js			#头文字Ｊ
	$node $openwrt_script/JD_Script/js/jd_mpdzcar_game.js		#头文字Ｊ游戏
	$node $openwrt_script/JD_Script/js/jd_mpdzcar_help.js		#头文字Ｊ助力
	$node $openwrt_script/JD_Script/js/jd_syj.js			#赚京豆
	$node $openwrt_script/JD_Script/js/jd_syj.js			#赚京豆
	$node $openwrt_script/JD_Script/js/jd_syj.js			#赚京豆
}

concurrent_js_run_07() {
#这里不会并发
cat >/tmp/jd_tmp/concurrent_js_run_07 <<EOF
	jd_dreamFactory.js 		#京喜工厂
	＃jd_angryKoi.js			#愤怒的锦鲤
	jd_club_lottery.js 		#摇京豆，没时间要求
	jd_price.js 			#京东价保
EOF
	for i in `cat /tmp/jd_tmp/concurrent_js_run_07 | grep -v "#.*js" | awk '{print $1}'`
	do
	{
		$node $openwrt_script/JD_Script/js/$i
		$run_sleep
	}&
	done
	wait
	$node $openwrt_script/JD_Script/js/jd_bean_change.js 	#资产变动强化版
	checklog #检测log日志是否有错误并推送
}


run_0() {
cat >/tmp/jd_tmp/run_0 <<EOF
	jd_jin_tie_xh.js  		#领金贴
	jd_ddnc_farmpark.js		#东东乐园
	jd_club_lottery.js 		#摇京豆，没时间要求
	jd_computer.js			#电脑配件ID任务
	jd_xtc.js			#小天才联合活动抽奖机
	jd_kws.js 			#科沃斯联合活动抽奖机
EOF
	echo -e "${green} run_0$start_script_time ${white}"

	for i in `cat /tmp/jd_tmp/run_0 | grep -v "#.*js" | awk '{print $1}'`
	do
		num=$(python $dir_file/jd_random.py 20,1)
		echo "$i脚本延迟$num秒以后再开始跑，请耐心等待"
		sleep $num
		$node $dir_file_js/$i
		$run_sleep
	done
	run_08_12_16
	run_06_18
	run_10_15_20
	run_030
	run_01
	echo -e "${green} run_0$stop_script_time ${white}"
}

run_020() {
cat >/tmp/jd_tmp/run_020 <<EOF
	#空.js
EOF
	echo -e "${green} run_020$start_script_time ${white}"

	for i in `cat /tmp/jd_tmp/run_020 | grep -v "#.*js" | awk '{print $1}'`
	do
		num=$(python $dir_file/jd_random.py 20,1)
		echo "$i脚本延迟$num秒以后再开始跑，请耐心等待"
		sleep $num
		$node $dir_file_js/$i
		$run_sleep
	done
	echo -e "${green} run_020$stop_script_time ${white}"
}

run_030() {
cat >/tmp/jd_tmp/run_030 <<EOF
	jd_jxmc.js			#京喜牧场
	long_half_redrain.js		#半点红包雨
EOF
	echo -e "${green} run_030$start_script_time ${white}"

	for i in `cat /tmp/jd_tmp/run_030 | grep -v "#.*js" | awk '{print $1}'`
	do
		num=$(python $dir_file/jd_random.py 20,1)
		echo "$i脚本延迟$num秒以后再开始跑，请耐心等待"
		sleep $num
		$node $dir_file_js/$i
		$run_sleep
	done

	echo -e "${green} run_030$stop_script_time ${white}"
}

opencard() {
cat >/tmp/jd_tmp/opencard <<EOF
	#空.js
EOF

	echo -e "${green} opencard$start_script_time ${white}"

	for i in `cat /tmp/jd_tmp/opencard | grep -v "#.*js" | awk '{print $1}'`
	do
	{
		num=$(python $dir_file/jd_random.py 2000,1)
		echo "$i脚本延迟$num秒以后再开始跑，请耐心等待"
		sleep $num
		
		$node $dir_file_js/$i
	}&
	done
	wait

	echo -e "${green} opencard$stop_script_time ${white}"
}

run_01() {
cat >/tmp/jd_tmp/run_01 <<EOF
	jd_cfd_pearl_ex.js 		#财富岛珍珠兑换
	jd_plantBean.js 		#种豆得豆，没时间要求，一个小时收一次瓶子
	raw_main_jd_super_redrain.js	#整点红包雨
	jd_dreamFactory.js 		#京喜工厂
	gua_wealth_island.js		#京东财富岛
	jd_29_8.js			#极速版抢29-8优惠券
	jd_5_2.js			#极速版抢5-2优惠券
	jd_19_6.js			#极速版抢19-6优惠券
EOF
	echo -e "${green} run_01$start_script_time ${white}"
	for i in `cat /tmp/jd_tmp/run_01 | grep -v "#.*js" | awk '{print $1}'`
	do
		num=$(python $dir_file/jd_random.py 20,1)
		echo "$i脚本延迟$num秒以后再开始跑，请耐心等待"
		sleep $num
		$node $dir_file_js/$i
		$run_sleep
	done

	echo -e "${green} run_01$stop_script_time ${white}"
}

run_02() {
cat >/tmp/jd_tmp/run_02 <<EOF
	#空.js
EOF
	echo -e "${green} run_02$start_script_time ${white}"

	for i in `cat /tmp/jd_tmp/run_02 | grep -v "#.*js" | awk '{print $1}'`
	do
		num=$(python $dir_file/jd_random.py 20,1)
		echo "$i脚本延迟$num秒以后再开始跑，请耐心等待"
		sleep $num
		$node $dir_file_js/$i
		$run_sleep
	done

	echo -e "${green} run_02$stop_script_time ${white}"
}

run_03() {
#这里不会并发
cat >/tmp/jd_tmp/run_03 <<EOF
	jd_joy_park_task.js		#汪汪乐园
	jd_zjd.js			#赚京豆
	#jd_jdzz.js			#京东赚赚
EOF
	echo -e "${green} run_03$start_script_time ${white}"

	for i in `cat /tmp/jd_tmp/run_03 | grep -v "#.*js" | awk '{print $1}'`
	do
	{
		$node $dir_file_js/$i
		$run_sleep
	}&
	done
	wait
	
	#极速版签到
	run_jsqd

	echo -e "${green} run_03$stop_script_time ${white}"
}


run_06_18() {
#过期京豆兑换为喜豆变量
export exjxbeans="true"
cat >/tmp/jd_tmp/run_06_18 <<EOF
	jd_exchangejxbeans.js		#过期京豆兑换为喜豆
	jd_fruit.js 			#东东水果，6-9点 11-14点 17-21点可以领水滴
	jd_pet.js 			#东东萌宠，跟手机商城同一时间
	jd_goodMorning.js		#早起福利
	jd_dwapp.js			#积分换话费
	jd_ccSign.js			#领券中心签到
EOF
	echo -e "${green} run_06_18$start_script_time ${white}"

	for i in `cat /tmp/jd_tmp/run_06_18 | grep -v "#.*js" | awk '{print $1}'`
	do
		num=$(python $dir_file/jd_random.py 20,1)
		echo "$i脚本延迟$num秒以后再开始跑，请耐心等待"
		sleep $num
		$node $dir_file_js/$i
		$run_sleep
	done

	echo -e "${green} run_06_18$stop_script_time ${white}"
}

run_07() {
#清空购物车的变量
export JD_CART="true"
export gua_cleancart_Run="true"
#export gua_cleancart_products="*@&@所有账号清空"(这条默认不启用，自己写，然后扔到全局变量)
export gua_cleancart_SignUrl="https://api.jds.codes/jd/sign"
cat >/tmp/jd_tmp/run_07 <<EOF
	jd_kd.js 			#京东快递签到 一天运行一次即可
	jd_jin_tie_xh.js  		#领金贴
	jd_unsubscribe.js 		#取关店铺，没时间要求
        gua_MMdou.js                    #赚京豆MM豆
	jx_sign.js			#京喜签到
	gua_cleancart_ddo.js		#清空购物车
EOF
	echo -e "${green} run_07$start_script_time ${white}"

	for i in `cat /tmp/jd_tmp/run_07 | grep -v "#.*js" | awk '{print $1}'`
	do
		num=$(python $dir_file/jd_random.py 20,1)
		echo "$i脚本延迟$num秒以后再开始跑，请耐心等待"
		sleep $num
		$node $dir_file_js/$i
		$run_sleep
	done
	echo -e "${green} run_07$stop_script_time ${white}"
}


run_08_12_16() {
cat >/tmp/jd_tmp/run_08_12_16 <<EOF
	jd_xmf.js			#京东小魔方
	jd_ms.js			#秒秒币
EOF
	echo -e "${green} run_08_12_16$start_script_time ${white}"

	for i in `cat /tmp/jd_tmp/run_08_12_16 | grep -v "#.*js" | awk '{print $1}'`
	do
		num=$(python $dir_file/jd_random.py 20,1)
		echo "$i脚本延迟$num秒以后再开始跑，请耐心等待"
		sleep $num
		$node $dir_file_js/$i
		$run_sleep
	done

	echo -e "${green} run_08_12_16$stop_script_time ${white}"
}

run_10_15_20() {
cat >/tmp/jd_tmp/run_10_15_20 <<EOF
	#空.js
EOF

	echo -e "${green} run_10_15_20$start_script_time ${white}"

	for i in `cat /tmp/jd_tmp/run_10_15_20 | grep -v "#.*js" | awk '{print $1}'`
	do
		num=$(python $dir_file/jd_random.py 20,1)
		echo "$i脚本延迟$num秒以后再开始跑，请耐心等待"
		sleep $num
		$node $dir_file_js/$i
		$run_sleep
	done
	$python3  $dir_file_js/jd_getFollowGift.py #关注有礼
	echo -e "${green} run_10_15_20$stop_script_time ${white}"
}

test() {
	#京东健康社区-种植园
	js_amount=$(cat $openwrt_script_config/js_cookie.txt |wc -l)
	export plant_cookie=$(seq 1 $js_amount | sed "s/$/\&/g" | sed ':t;N;s/\n//;b t' | sed "s/&$//")

	export JD_COOKIE=$(cat $openwrt_script_config/js_cookie.txt | grep "pt_key" | grep -v "pt_key=xxx" | awk -F "'," '{print $1}' | sed "s/'//g" | sed "s/$/\&/" | sed 's/[[:space:]]//g' | sed ':t;N;s/\n//;b t' | sed "s/&$//")

	charge_num=$(for i in `seq 1 $js_amount`;do echo "101908";done )
	export charge_targe_id=$(echo "$charge_num" | sed "s/$/\&/g" | sed ':t;N;s/\n//;b t' | sed "s/&$//")


	$python3 $dir_file_js/jd_health_plant.py

}

run_jsqd(){
#极速版签到定制安排
num="1"
#允许10个任务一起跑，做个测试，看看403不
ck_num="10"
file_num=$(ls $ccr_js_file | wc -l)

	while [ ${file_num} -gt ${num} ]; do
		ps_speed=$(ps -ww |grep "jd_speed_sign.js" | grep -v grep | wc -l)
		if [ "$ps_speed" -gt "$ck_num" ];then
			echo -e "${green}jd_speed_sign.js后台进程一共有${yellows}${ps_speed}${green}个，${white}已满$ck_num个暂时不跑了"
			while true; do
				if [ ${num} -gt ${file_num} ];then
					echo -e "${green}所有账号已经跑完了，停止脚本${white}"
					break
				else
					if [ "$ps_speed" -gt "$ck_num" ];then
						if [ ${num} -gt ${file_num} ];then
							echo -e "${green}所有账号已经跑完了，停止脚本${white}"
							break
						else
							echo -e "${green}开始休息60秒以后再干活${white}"
							sleep 60
						fi
					else
						echo -e "${yellow}休息结束开始干活${white}"
						break
					fi
				fi
			done
		else
			echo -e "${green}开始跑${yellow}js_${num}${green}文件里的jd_speed_sign.js${white}"
			$node $ccr_js_file/js_${num}/jd_speed_sign.js &
			sleep 5
			echo -e "${green}jd_speed_sign.js后台进程一共有${yellows}${ps_speed}${green}个"
		fi
		num=$(($num + 1))
	done
}

run_jd_blueCoin() {
cat >/tmp/jd_tmp/run_jd_blueCoin <<EOF
	jd_blueCoin.py	#东东超市兑换
EOF
	jd_blueCoin_num="5"
	while [[ ${jd_blueCoin_num} -gt 0 ]]; do
		$python3 $dir_file_js/jd_blueCoin.py &
		sleep 1
		jd_blueCoin_num=$(($jd_blueCoin_num - 1))
	done
}



zcbh() {
	zcbh_token=$(cat /usr/share/jd_openwrt_script/script_config/sendNotify_ccwav.js | grep "let WP_APP_TOKEN_ONE" | awk -F "\"" '{print $2}')
	export WP_APP_TOKEN_ONE="$zcbh_token"
	cd $dir_file_js
	$node jd_bean_change_ccwav.js
}



curtinlv_script_setup() {
	#开卡
	curtinlv_cookie=$(cat $openwrt_script_config/jdCookie.js | grep "pt_key" | grep -v "pt_key=xxx" | awk -F "'," '{print $1}' | sed "s/'//g" | sed "s/$/\&/" | sed 's/[[:space:]]//g' | sed ':t;N;s/\n//;b t' | sed "s/&$//" )
	sed -i "/JD_COOKIE = ''/d" $dir_file/git_clone/curtinlv_script/OpenCard/OpenCardConfig.ini
	sed -i "3a \JD_COOKIE = '$curtinlv_cookie'" $dir_file/git_clone/curtinlv_script/OpenCard/OpenCardConfig.ini
	sed -i "s/sleepNum = 0/sleepNum = 0.5/g" $dir_file/git_clone/curtinlv_script/OpenCard/OpenCardConfig.ini
	sed -i "s/openCardBean = 5/openCardBean = 20/g" $dir_file/git_clone/curtinlv_script/OpenCard/OpenCardConfig.ini
	if [ ! -L "$dir_file_js/jd_OpenCard.py" ]; then
		rm -rf $dir_file_js/jd_OpenCard.py
		ln -s $dir_file/git_clone/curtinlv_script/OpenCard/jd_OpenCard.py $dir_file_js/jd_OpenCard.py
	fi

	if [ ! -L "$dir_file_js/OpenCardConfig.ini" ]; then
		rm -rf $dir_file_js/OpenCardConfig.ini
		ln -s $dir_file/git_clone/curtinlv_script/OpenCard/OpenCardConfig.ini $dir_file_js/OpenCardConfig.ini
	fi

	#软连接
	if [ ! -L "$dir_file_js/JDCookies.txt" ]; then
		rm -rf $dir_file_js/JDCookies.txt
		ln -s $dir_file/git_clone/curtinlv_script/JDCookies.txt  $dir_file_js/JDCookies.txt
	fi

	#赚京豆
	cat $openwrt_script_config/js_cookie.txt > $dir_file/git_clone/curtinlv_script/JDCookies.txt
	if [ ! -L "$dir_file_js/jd_zjd.py" ]; then
		rm -rf $dir_file_js/jd_zjd.py
		ln -s $dir_file/git_clone/curtinlv_script/jd_zjd.py  $dir_file_js/jd_zjd.py
	fi

	#东东超市商品兑换
	if [ ! -L "$dir_file_js/jd_blueCoin.py" ]; then
		rm -rf $dir_file_js/jd_blueCoin.py
		ln -s $dir_file/git_clone/curtinlv_script/jd_blueCoin.py  $dir_file_js/jd_blueCoin.py
	fi

	#安佳牛奶
	if [ ! -L "$dir_file_js/jd_kk_aj.py" ]; then
		rm -rf $dir_file_js/jd_kk_aj.py
		ln -s $dir_file/git_clone/curtinlv_script/jd_kk_aj.py  $dir_file_js/jd_kk_aj.py
	fi
}

script_name() {
	clear
	echo -e "${green} 显示所有JS脚本名称与作用${white}"
	cat $dir_file/config/collect_script.txt
}

Tjs()	{
	#测试模块
	for i in `cat $jd_file/config/collect_script.txt | grep -v "#.*js" | grep -Ev "jd_delCoupon.js|jd_unsubscribe.js|jd_dreamFactory_tuan.js|sign_graphics_validate.js|JDSignValidator.js|JDJRValidator_Aaron.js|jd_get_share_code.js|jd_bean_sign.js|jd_check_cookie.js|getJDCookie.js|jx_products_detail.js|.*py|jdPetShareCodes.js|jdJxncShareCodes.js|jdFruitShareCodes.js|jdFactoryShareCodes.js|jdPlantBeanShareCodes.js|jdDreamFactoryShareCodes.js|jd_try.js" | awk '{print $1}'`;do
		echo -e "${green}>>>开始执行${yellow}$i${white}"
		if [ `echo "$i" | grep -o "py"| wc -l` == "1" ];then
			$python3 $jd_file/ccr_js/js_1/$i &
		else
			$node $jd_file/ccr_js/js_1/$i &
		fi
		echo -e "${green}>>>${yellow}$i${green}执行完成，回车测试下一个${white}"
		read a
	done

}

jx() {
	echo -e "${green} 查询京喜商品生产所用时间$start_script_time ${white}"
	$node $dir_file_js/jx_products_detail.js
	echo -e "${green} 查询完成$stop_script_time ${white}"
}

jd_sharecode() {
	echo -e "${green} 查询京东助力码$start_script_time ${white}"
	$node $dir_file_js/jd_get_share_code.js #获取jd所有助力码脚本
	echo -e "${green}查询完成$start_script_time ${white}"
	echo ""
	jd_sharecode_if
}
jd_sharecode_if() {
	echo -e "${green}============是否生成提交助力码格式，方便提交助力码，1.生成 2.不生成============${white}"
	read -p "请输入：" code_Decide
	if [ "$code_Decide" == "1" ];then
		jd_sharecode_generate
	elif [ "$code_Decide" == "2" ];then
		echo "不做任何操作"
	else
		echo "请不要随便乱输！！！"
		jd_sharecode_if
	fi

}
jd_sharecode_generate() {
read -p "请输入你的名字和进群时间（例子：zhangsan_20210314，注意zhangsan是个例子，请写自己的名字～～～）：" you_name
echo -e "${green}请稍等，号越多生成会比较慢。。。${white}"
$node $dir_file_js/jd_get_share_code.js >/tmp/get_share_code

cat > /tmp/code_name <<EOF
京东农场 fr
京东萌宠 pet
种豆得豆 pb
京喜工厂 df
京东赚赚 jdzz
签到领现金 jdcash
闪购盲盒 jdsgmh
财富岛 cfd
EOF


code_number="0"
echo -e "${green}============整理$you_name的Code============${white}"

for i in `cat /tmp/code_name | awk '{print $1}'`
do
	code_number=$(expr $code_number + 1)
	o=$(cat /tmp/get_share_code | grep  "$i" | wc -l)
	p=$(cat /tmp/code_name | awk -v  a="$code_number" -v b="$you_name"  -v c="_" 'NR==a{print b c$2}')
	echo ""
	cat /tmp/get_share_code | grep  "$i" | awk -F '】' '{print $2}' | sed ':t;N;s/\n/@/;b t'  | sed "s/$/\"/" | sed "s/^/$i有$o个\Code：$p=\"/"
	echo ""
done
echo -e "${green}============整理完成，可以提交了（没加群的忽略）======${white}"

}


jd_try() {
cat >/tmp/jd_tmp/jd_try_variable <<EOF
	JD_TRY_TITLEFILTERS
	JD_TRY_WHITELIST
	JD_TRY_PRICE
	JD_TRY_MINSUPPLYNUM
	JD_TRY_TABID
	JD_TRY_PLOG
	JD_TRY_MAXLENGTH
	JD_TRY_APPLYNUMFILTER
	JD_TRY_TRIALPRICE
EOF

	for i in `cat /tmp/jd_tmp/jd_try_variable | grep -v "#.*js" | awk '{print $1}'`
	do
		export $i=$(cat $openwrt_script_config/jd_openwrt_script_config.txt | grep "$i" | awk -F "\"" '{print $2}')
	done

	JD_TRY=$(cat $openwrt_script_config/jd_openwrt_script_config.txt | grep "JD_TRY=" | awk -F "\"" '{print $2}')
	if [ $JD_TRY == "true" ];then
		export JD_TRY="true"
		echo -e "${green} >> 开始执行试用脚本${white}"
		for i in `ls $dir_file/jd_try_file/tmp | grep "jd_try"`
		do
		{
			echo -e "${green} >> 开始跑$i${white}"
			$node $dir_file/jd_try_file/tmp/$i
		} &
		done
		wait
	else
		echo -e "$red >> 试用脚本开关没有打开${white}"
	fi
}

jd_time()  {
TimeError=2
#copy SuperManito
 local Interface="https://api.m.jd.com/client.action?functionId=queryMaterialProducts&client=wh5"
    if [[ $(echo $(($(curl -sSL "${Interface}" | awk -F '\"' '{print$8}') - $(eval echo "$(date +%s)$(date +%N | cut -c1-3)"))) | sed "s|\-||g") -lt 10 ]]; then
        echo -e "\n\033[32m------------ 检测到当前本地时间与京东服务器的时间差小于 10ms 因此不同步 ------------\033[0m\n"
    else
        echo -e "\n❖ 同步京东服务器时间"
        echo -en "\n当前设置的允许误差时间为 ${TimeError}m，脚本将在 3s 后开始运行..."
        sleep 3
        echo -e ''
        while true; do
            ## 先同步京东服务器时间
            date -s $(date -d @$(curl -sSL "${Interface}" | awk -F '\"' '{print$8}' | cut -c1-10) "+%H:%M:%S") >/dev/null
            sleep 1
            ## 定义当前系统本地时间戳
            local LocalTimeStamp="$(date +%s)$(date +%N | cut -c1-3)"
            ## 定义当前京东服务器时间戳
            local JDTimeStamp="$(curl -sSL "${Interface}" | awk -F '\"' '{print$8}' | cut -c1-10)"
            ## 定义当前时间差
            local TimeDifference=$(echo $((${JDTimeStamp} - ${LocalTimeStamp})) | sed "s|\-||g")
            ## 输出时间
            echo -e "\n京东时间戳：\033[34m${JDTimeStamp}\033[0m"
            echo -e "本地时间戳：\033[34m${LocalTimeStamp}\033[0m"
            if [[ ${TimeDifference} -lt ${TimeError} ]]; then
                echo -e "\n\033[32m------------ 同步完成 ------------\033[0m\n"
                if [ -s /etc/apt/sources.list ]; then
                    #apt-get install -y figlet toilet >/dev/null
                    local ExitStatus=$?
                else
                    local ExitStatus=1
                fi
                if [ $ExitStatus -eq 0 ]; then
                    echo -e "$(toilet -f slant -F border --gay SuperManito)\n"
                else
                    echo -e '\033[35m    _____                       __  ___            _ __       \033[0m'
                    echo -e '\033[31m   / ___/__  ______  ___  _____/  |/  /___ _____  (_) /_____  \033[0m'
                    echo -e '\033[33m   \__ \/ / / / __ \/ _ \/ ___/ /|_/ / __ `/ __ \/ / __/ __ \ \033[0m'
                    echo -e '\033[32m  ___/ / /_/ / /_/ /  __/ /  / /  / / /_/ / / / / / /_/ /_/ / \033[0m'
                    echo -e '\033[36m /____/\__,_/ .___/\___/_/  /_/  /_/\__,_/_/ /_/_/\__/\____/  \033[0m'
                    echo -e '\033[34m           /_/                                                \033[0m\n'
                fi
                break
            else
                sleep 1s
                echo -e "\n未达到允许误差范围设定值，继续同步..."
            fi
        done
    fi

}

concurrent_js_update() {
	if [ "$ccr_if" == "yes" ];then
		if [[ ! -d "$ccr_js_file" ]]; then
			mkdir  $ccr_js_file
		fi
	else
		if [[ ! -d "$ccr_js_file" ]]; then
			echo ""
		else
			rm -rf $ccr_js_file
		fi
	fi

	if [ "$ccr_if" == "yes" ];then
		js_amount=$(cat $openwrt_script_config/js_cookie.txt |wc -l)
		echo -e "${green}>> 你有$js_amount个ck要创建并发文件夹${white}"
		start_date=$(date +%s)
		for i in `ls $ccr_js_file | grep -E "^js"`
		do
			rm -rf $ccr_js_file/$i
		done

		for ck_num in `seq 1 $js_amount`
		do
		{
			mkdir $ccr_js_file/js_$ck_num
			cp $openwrt_script_config/jdCookie.js $ccr_js_file/js_$ck_num/jdCookie.js

			if [ ! -L "$ccr_js_file/js_$ck_num/sendNotify.js" ]; then
				rm -rf $$ccr_js_file/js_$ck_num/sendNotify.js
				ln -s $openwrt_script_config/sendNotify.js $ccr_js_file/js_$ck_num/sendNotify.js
			fi

			js_cookie_obtain=$(sed -n $ck_num\p "$openwrt_script_config/js_cookie.txt") #获取pt
			sed -i '/pt_pin/d' $ccr_js_file/js_$ck_num/jdCookie.js >/dev/null 2>&1
			sed -i "5a $js_cookie_obtain" $ccr_js_file/js_$ck_num/jdCookie.js

			for i in `ls $dir_file_js | grep -v 'jdCookie.js\|sendNotify.js\|jddj_cookie.js\|log'`
			do
				cp -r $dir_file_js/$i $ccr_js_file/js_$ck_num/$i
			done
		} &
		done
		#wait
		sleep 3

		ps_cp=$(ps -ww | grep "cp -r" | grep -v grep | wc -l)
		while [ $ps_cp -gt 0 ];do
			sleep 1
			ps_cp=$(ps -ww | grep "cp -r" | grep -v grep| wc -l)
		done
		end_date=$(date +%s)
		result_date=$(( $start_date - $end_date ))
		echo -e "${yellow} 耗时:${green}$result_date秒${white}"
		echo -e "${green}>> 创建$js_amount个并发文件夹完成${white}"
	else
		echo -e "${yellow}>> 并发开关没有打开${white}"
	fi

}

concurrent_js_clean(){
		if [ "$ccr_if" == "yes" ];then
			echo -e "${yellow}收尾一下${white}"
			for i in `ps -ww | grep "$action" | grep -v 'grep\|index.js\|jd_try.js\|ssrplus\|opencard' | awk '{print $1}'`
			do
				echo "开始kill $i"
				kill -9 $i
			done
		fi
}

kill_ccr() {
	if [ "$ccr_if" == "yes" ];then
		echo -e "${green}>>终止并发程序启动。请稍等。。。。${white}"
		if [ `ps -ww | grep "js$" | grep "JD_Script"| grep -v 'grep\|index.js\|jd_try.js\|ssrplus\|opencard' | awk '{print $1}' |wc -l` == "0" ];then
			sleep 2
			echo ""
			echo -e "${green}我曾经跨过山和大海，也穿过人山人海。。。${white}"
			sleep 2
			echo -e "${green}直到来到你这里。。。${white}"
			sleep 2
			echo -e "${green}逛了一圈空空如也，你确定不是在消遣我？？？${white}"
			sleep 2
			echo -e "${green}后台都没有进程妹子，散了散了。。。${white}"
		else
			for i in `ps -ww | grep "js$" | grep "JD_Script"| grep -v 'grep\|index.js\|jd_try.js\|ssrplus\|opencard' | awk '{print $1}'`
			do
				kill -9 $i
				echo "kill $i"
			done
			concurrent_js_clean
			clear
			echo -e "${green}再次检测一下并发程序是否还有存在${white}"
			if [ `ps -ww | grep "js$" | grep "JD_Script"| grep -v 'grep\|index.js\|jd_try.js\|ssrplus\|opencard' | awk '{print $1}' |wc -l` == "0" ];then
				echo -e "${yellow}>>并发程序已经全部结束${white}"
			else
				echo -e "${yellow}！！！检测到并发程序还有存在，再继续杀，请稍等。。。${white}"
				sleep 1
				kill_ccr
			fi
		fi
	else
		echo -e "${green}>>你并发开关都没有打开，我终止啥？？？${white}"
	fi
}

if_ps() {
	#set -x
	sleep 30
	rm -rf /tmp/jd_tmp/ps_$action.log
	for i in `cat /tmp/jd_tmp/$action | grep -v "#.*js" | awk '{print $1}'`
	do
		js_num=$(ps -ww | grep "$i"| grep -v grep | wc -l)
		echo "$i $js_num进程" >> /tmp/jd_tmp/ps_$action.log
	done

	file_num=$(cat /tmp/jd_tmp/ps_$action.log | wc -l)
	process_num="0" #进程数
	num="1"
	while [ $file_num -ge $num ];do
		row_data=$(sed -n "$num p" /tmp/jd_tmp/ps_$action.log | awk '{print $2}' | sed "s/进程//g")
		process_num=$(( $process_num + $row_data ))	
		num=$(( $num + 1))
	done

	num1="5"
	echo -e "${green}>> $action并发程序还有${yellow}$process_num${green}进程在后台，等待(30秒)，后再检测一下${white}"
	echo -ne "\r"
	sleep $num1

	echo ""
	if [ "$process_num" == "0" ];then
		echo -e "${yellow}>>并发程序已经结束${white}"
	else
		sleep $num1
		echo -ne ">> $action并发程序还有${yellow}$process_num${green}进程在后台，等待(30秒)，后再检测一下${white}"
		echo -ne "\r"
		if_ps
	fi
	#for i in `ps -ww | grep "jd.sh run_" | grep -v grep | awk '{print $1}'`;do kill -9 $i ;done
}

concurrent_js() {
	if [ $(ls $ccr_js_file/ | wc -l ) -gt "0" ];then
		for i in `ls $ccr_js_file/`
		do
			dir_file_js="$ccr_js_file/$i"
			$action &
		done
	else
		echo -e "${green}>>并发文件夹为空开始下载${white}"
			update
			concurrent_js_if
	fi
}

concurrent_js_if() {
	if [ "$ccr_if" == "yes" ];then
		echo -e "${green}>>检测到开启了账号并发模式${white}"
		case "$action1" in
		run_0)
			action="$action1"
			ccr_run
			concurrent_js && if_ps
			if [ ! $action2 ];then
				if_ps
				concurrent_js_clean
			else
				case "$action2" in
				run_07)
					action="$action2"
					concurrent_js && if_ps
					concurrent_js_run_07 && if_ps
					concurrent_js_clean
				;;
				esac
			fi
		;;
		run_07)
			action="$action1"
			concurrent_js && if_ps
			concurrent_js_run_07 && if_ps
			concurrent_js_clean
		;;
		run_03)
			run_03
		;;
		run_030)
			action="$action1"
			concurrent_js
			if_ps
			concurrent_js_clean
		;;
		run_01|run_02|opencard|run_08_12_16|run_020|run_10_15_20|run_06_18)
			action="$action1"
			concurrent_js
			if_ps
			concurrent_js_clean
		;;
		esac
	else
		case "$action1" in
			run_0)
			ccr_run
			$action1
			;;
			run_07)
			ccr_run
			$action1
			concurrent_js_run_07
			;;
			run_01|run_06_18|run_10_15_20|run_03|run_02|opencard|run_08_12_16|run_07|run_030|run_020)
			$action1
			;;
		esac

		if [[ -z $action2 ]]; then
			echo ""
		else
			case "$action2" in
			run_0)
			ccr_run
			$action2
			;;
			run_07)
			ccr_run
			$action2
			concurrent_js_run_07
			;;
			run_01|run_06_18|run_10_15_20|run_03|run_02|opencard|run_08_12_16|run_07|run_020)
			$action2
			;;
		esac
		fi
	fi
}


checktool() {
	i=1
	while [ 100 -ge 0 ];do
		ps_check=$(ps -ww |grep "JD_Script" | grep -v "grep" |awk '{print $1}' | wc -l )
		echo "---------------------------------------------------------------------------"
		echo -e  "		检测者工具第${green}$i${white}次循环输出(ctrl+c终止)"
		echo "---------------------------------------------------------------------------"
		echo "负载情况：`uptime`"
		echo ""
		echo "进程状态："
		if [ "$ps_check" == "0"  ];then
			echo ""
			echo "	没有检测到并发进程"
		else
			ps -ww | grep "JD_Script" |grep -v 'grep\|checktool'
		fi
		sleep 2
		clear
		i=`expr $i + 1`
	done
}

getcookie() {
	#彻底完成感谢echowxsy大力支持
	echo "此功能暂停使用，请用sh \$jd addcookie添加cookie "
	exit 0
	echo -e "${yellow} 温馨提示，如果你已经有cookie，不想扫码直接添加，可以用${green} sh \$jd addcookie${white} 增加cookie ${green} sh \$jd delcookie${white} 删除cookie"
	$node $dir_file_js/getJDCookie.js && addcookie && addcookie_wait
}

addcookie() {
	
	if [ `cat /tmp/getcookie.txt | wc -l` == "1" ];then
		clear
		you_cookie=$(cat /tmp/getcookie.txt)
		if [[ -z $you_cookie ]]; then
			echo -e "$red cookie为空值，不做其他操作。。。${white}"
			exit 0
		else
			echo -e "\n${green}已经获取到cookie，稍等。。。${white}"
			sleep 1
		fi
	else
		clear
		echo "---------------------------------------------------------------------------"
		echo -e "		新增cookie或者更新cookie"
		echo "---------------------------------------------------------------------------"
		echo ""
		echo -e "${yellow}单账号例子：${white}"
		echo ""
		echo -e "pt_key=xxxxxx;pt_pin=jd_xxxxxx; //二狗子"
		echo ""
		echo -e "${yellow}多账号例子：（用＆分割账号）${white}"
		echo ""
		echo -e "pt_key=xxxxxx;pt_pin=jd_xxxxxx; //二狗子&pt_key=xxxxxx;pt_pin=jd_xxxxxx; //雪糕兄"
		echo ""
		echo -e "${yellow} pt_key=${green}密码  ${yellow} pt_pin=${green} 账号  ${yellow}// 二狗子 ${green}(备注这个账号是谁的)${white}"
		echo ""
		echo -e "${yellow} 请不要乱输，如果输错了可以用${green} sh \$jd delcookie${yellow}删除,\n 或者你手动去${green}$openwrt_script_config/jdCookie.js${yellow}删除也行\n${white}"
		echo "---------------------------------------------------------------------------"
		read -p "请填写你获取到的cookie(一次只能一个cookie,多个cookie要用＆连接起来)：" you_cookie
		if [[ -z $you_cookie ]]; then
			echo -e "$red请不要输入空值。。。${white}"
			exit 0
		fi

	fi
	echo "$you_cookie" > /tmp/you_cookie.txt
	sed -i "s/&/\n/g" /tmp/you_cookie.txt
	echo -e "${yellow}\n开始为你查找是否存在这个cookie，有就更新，没有就新增。。。${white}\n"
	sleep 2
	if_you_cookie=$(cat /tmp/you_cookie.txt | wc -l)
	if [ $if_you_cookie == "1" ];then
		you_cookie=$(cat /tmp/you_cookie.txt)
		new_pt=$(echo $you_cookie)
		pt_pin=$(echo $you_cookie | awk -F "pt_pin=" '{print $2}' | awk -F ";" '{print $1}')
		pt_key=$(echo $you_cookie | awk -F "pt_key=" '{print $2}' | awk -F ";" '{print $1}')
		you_remark=$(echo $you_cookie | awk -F "\/\/" '{print $2}')
		if [ `echo "$pt_pin" | wc -l` == "1"  ] && [ `echo "$pt_key" | wc -l` == "1" ];then
			addcookie_replace
		else
			echo "$pt_pin $pt_key　$you_remark $red异常${white}"
			sleep 2
		fi
	else
		num="1"
		while [ $if_you_cookie -ge $num ];do
			clear
			echo  "------------------------------------------------------------------------------"
			echo -e "你一共输入了${yellow}$if_you_cookie${white}条cookie现在开始替换第${green}$num${white}条cookie"
			you_cookie=$(sed -n "$num p" /tmp/you_cookie.txt)
			new_pt=$(echo $you_cookie)
			pt_pin=$(echo $you_cookie | awk -F "pt_pin=" '{print $2}' | awk -F ";" '{print $1}')
			pt_key=$(echo $you_cookie | awk -F "pt_key=" '{print $2}' | awk -F ";" '{print $1}')
			you_remark=$(echo $you_cookie | awk -F "\/\/" '{print $2}')

			if [ `echo "$pt_pin" | wc -l` == "1"  ] && [ `echo "$pt_key" | wc -l` == "1" ];then
				addcookie_replace
				sleep 2
			else
				echo -e "$pt_pin $pt_key $you_remark　$red异常${white}"
				sleep 2
			fi
			num=$(( $num + 1))
		done

	fi
	del_expired_cookie

	if [ `cat /tmp/getcookie.txt  | wc -l` == "1"  ];then
		echo ""
		rm -rf /tmp/getcookie.txt
	else
		rm -rf /tmp/getcookie.txt
		addcookie_wait
	fi

	
}

addcookie_replace(){
	if [ `cat $openwrt_script_config/jdCookie.js | grep "$pt_pin;" | wc -l` == "1" ];then
		echo -e "${green}检测到 ${yellow}${pt_pin}${white} 已经存在，开始更新cookie。。${white}\n"
		sleep 2
		old_pt=$(cat $openwrt_script_config/jdCookie.js | grep "$pt_pin" | sed -e "s/',//g" -e "s/'//g")
		old_pt_key=$(cat $openwrt_script_config/jdCookie.js | grep "$pt_pin" | awk -F "pt_key=" '{print $2}' | awk -F ";" '{print $1}')
		sed -i "s/$old_pt_key/$pt_key/g" $openwrt_script_config/jdCookie.js
		echo -e "${green} 旧cookie：${yellow}${old_pt}${white}\n\n${green}更新为${white}\n\n${green}   新cookie：${yellow}${new_pt}${white}\n"
		echo  "------------------------------------------------------------------------------"
	else
		echo -e "${green}检测到 ${yellow}${pt_pin}${white} 不存在，开始新增cookie。。${white}\n"
		sleep 2
		cookie_quantity=$( cat $openwrt_script_config/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | wc -l)
		i=$(expr $cookie_quantity + 5)
		if [ $i == "5" ];then
			sed -i "5a \  'pt_key=${pt_key};pt_pin=${pt_pin};\', \/\/$you_remark" $openwrt_script_config/jdCookie.js
		else
			sed -i "$i a\  'pt_key=${pt_key};pt_pin=${pt_pin};\', \/\/$you_remark" $openwrt_script_config/jdCookie.js
		fi
		echo -e "\n已将新cookie：${green}${you_cookie}${white}\n\n插入到${yellow}$openwrt_script_config/jdCookie.js${white} 第$i行\n"
		cookie_quantity1=$( cat $openwrt_script_config/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | wc -l)
		echo  "------------------------------------------------------------------------------"
		echo -e "${yellow}你增加了账号：${green}${pt_pin}${white}${yellow} 现在cookie一共有$cookie_quantity1个，具体以下：${white}"
		cat $openwrt_script_config/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | sed -e "s/',//g" -e "s/'//g"
		echo  "------------------------------------------------------------------------------"
	fi

	check_cooike
	sed -n  '1p' $openwrt_script_config/check_cookie.txt
	grep "$pt_pin" $openwrt_script_config/check_cookie.txt
}

addcookie_wait(){
	echo ""
	read -p "是否需要继续获取cookie（1.需要  2.不需要 ）：" cookie_continue
	if [ "$cookie_continue" == "1" ];then
		echo "请稍等。。。"
		sleep 1
		clear
		addcookie
	elif [ "$cookie_continue" == "2" ];then
		echo "退出脚本。。。"
		exit 0
	else
		echo "请不要乱输，退出脚本。。。"
		exit 0
	fi

}

del_expired_cookie() {
	echo -e "${green}整理一下check_cookie.txt,删掉一些过期的信息${white}"
	for i in `cat $openwrt_script_config/check_cookie.txt | awk '{print $1}'| grep -v "Cookie"`
	do
		jd_cookie=$(grep "$i" $openwrt_script_config/jdCookie.js | awk -F "pt_pin=" '{print $2}' | awk -F ";" '{print $1}' | sed '/^\s*$/d' | grep -v "(.+?)")
		if [ ! $jd_cookie ];then
			#echo -e "$red$i${white}在$openwrt_script_config/jdCookie.js找不到"
			echo "" >/dev/null 2>&1
		else
			if [ "$jd_cookie" == "$i" ];then
				#echo -e "${green}$i${white}在$openwrt_script_config/jdCookie.js正常存在"
				echo "" >/dev/null 2>&1
			else
				sed -i "/$i/d" $openwrt_script_config/check_cookie.txt
			fi
		fi
	done
}

delcookie() {
	cookie_quantity=$(cat $openwrt_script_config/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | wc -l)
	if [ `cat $openwrt_script_config/jdCookie.js | grep "$pt_pin" | wc -l` -ge "1" ];then
		echo "---------------------------------------------------------------------------"
		echo -e "		删除cookie"
		echo "---------------------------------------------------------------------------"
		echo -e "${green}例子：${white}"
		echo ""
		echo -e "${green} pt_key=jd_10086jd_10086jd_10086jd_10086jd_10086jd_10086jd_10086;pt_pin=jd_10086; //二狗子${white}"
		echo ""
		echo -e "${yellow} 请填写你要删除的cookie（// 备注 或者pt_pin 名都行）：${green}二狗子 ${white}"
		echo -e "${yellow} 请填写你要删除的cookie（// 备注 或者pt_pin 名都行）：${green} jd_10086${white} "
		echo "---------------------------------------------------------------------------"
		echo -e "${yellow}你的cookie有$cookie_quantity个，具体如下：${white}"
		cat $openwrt_script_config/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | sed -e "s/',//g" -e "s/'//g"
		echo "---------------------------------------------------------------------------"
		echo ""
		read -p "请填写你要删除的cookie（// 备注 或者pt_pin 名都行）：" you_cookie
		if [[ -z $you_cookie ]]; then
			echo -e "$red请不要输入空值。。。${white}"
			exit 0
		fi
	
		sed -i "/$you_cookie/d" $openwrt_script_config/jdCookie.js
		clear
		echo "---------------------------------------------------------------------------"
		echo -e "${yellow}你删除账号或者备注：${green}${you_cookie}${white}${yellow} 现在cookie还有`cat $openwrt_script_config/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | wc -l`个，具体以下：${white}"
		cat $openwrt_script_config/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | sed -e "s/',//g" -e "s/'//g"
		echo "---------------------------------------------------------------------------"
		echo ""
		read -p "是否需要删除cookie（1.需要  2.不需要 ）：" cookie_continue
		if [ "$cookie_continue" == "1" ];then
			echo "请稍等。。。"
			delcookie
		elif [ "$cookie_continue" == "2" ];then
			echo "退出脚本。。。"
			exit 0
		else
			echo "请不要乱输，退出脚本。。。"
			exit 0
		fi
	else
		echo -e "${yellow}你的cookie空空如也，比地板都干净，你想删啥。。。。。${white}"
	fi

}

check_cooike() {
#将cookie获取时间导入文本
	if [ ! -f $openwrt_script_config/check_cookie.txt  ];then
		echo "Cookie      添加时间      预计到期时间(不保证百分百准确)      备注" > $openwrt_script_config/check_cookie.txt
	fi
	sed -i "/添加时间/d" $openwrt_script_config/check_cookie.txt
	sed -i "1i\Cookie      添加时间      预计到期时间(不保证百分百准确)      备注" $openwrt_script_config/check_cookie.txt
	Current_date=$(date +%Y-%m-%d)
	Current_date_m=$(echo $Current_date | awk -F "-" '{print $2}')
	if [ "$Current_date_m" == "12"  ];then
		Expiration_date=$(date +%Y-01-%d)
	else
		m=$(expr $Current_date_m + 1)
		Expiration_date=$(date +%Y-$m-%d)
		#$这个不要改动，没有写错
	fi
	sed -i "/$pt_pin/d" $openwrt_script_config/check_cookie.txt
	remark=$(grep "$pt_pin" $openwrt_script_config/jdCookie.js | awk -F "," '{print $2$3}'|sed "s/\/\///g")
	echo "$pt_pin     $Current_date      $Expiration_date     $remark" >> $openwrt_script_config/check_cookie.txt
}

check_cookie_push() {
	echo "----------------------------------------------"
	cat $openwrt_script_config/check_cookie.txt
	echo "----------------------------------------------"
	echo "$line#### cookie数量:`cat $openwrt_script_config/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | wc -l`$line" >/tmp/jd_check_cookie.txt
	cat $openwrt_script_config/check_cookie.txt |sed "s/备注/$wrap$wrap_tab\# 备注/"  >>/tmp/jd_check_cookie.txt
	$node $dir_file_js/jd_check_cookie1.js | grep "京东账号" >/tmp/jd_check_cookie_sort.txt

	effective_cookie=$(cat /tmp/jd_check_cookie_sort.txt | grep "有效" )
	Invalid_cookie=$(cat /tmp/jd_check_cookie_sort.txt | grep "失效" )
	echo "$line#### cookie有效数量:`cat /tmp/jd_check_cookie_sort.txt | grep "有效"| wc -l`$line" >>/tmp/jd_check_cookie.txt

	echo "$effective_cookie"　>>/tmp/jd_check_cookie.txt

	if [ `echo $Invalid_cookie | wc -l` -ge "1" ];then
		echo "$line#### cookie失效数量:`cat /tmp/jd_check_cookie_sort.txt | grep "失效"| wc -l`$line" >>/tmp/jd_check_cookie.txt
		echo "$Invalid_cookie"　>>/tmp/jd_check_cookie.txt
	else
		echo "没有失效cookie"
	fi

	cookie_content=$(cat /tmp/jd_check_cookie.txt |sed "s/ /+/g"| sed "s/$/$wrap$wrap_tab/g" |  sed ':t;N;s/\n//;b t' )

	server_content=$(echo "${cookie_content}${by}" | sed "s/$wrap_tab####/####/g" )

	weixin_content_sort=$(cat /tmp/jd_check_cookie.txt |sed "s/####/<b>/g"   |sed "s/$line/<hr\/><\/b>/g" |sed "s/$wrap$wrap_tab/<br>/g" |sed "s/<br>#//g"  | sed "s/$/<br>/" |sed "s/<hr\/><\/b><br>/<hr\/><\/b>/g" |  sed ':t;N;s/\n//;b t' )
	weixin_content=$(echo "$weixin_content_sort<br><b>$by")
	weixin_desp=$(echo "$weixin_content" | sed "s/<hr\/><\/b><b>/$weixin_line\n/g" |sed "s/<hr\/><\/b>/\n$weixin_line\n/g"| sed "s/<b>/\n/g"| sed "s/<br>/\n/g" | sed "s/<br><br>/\n/g" | sed "s/#/\n/g" )

	title="JD Cookie状态"
	push_menu
}


push_menu() {
case "$push_if" in
		0)
			#server酱和微信同时推送
			server_push
			weixin_push
			push_if="3"
			weixin_push
		;;
		1)
			#server酱推送
			server_push
		;;
		2)
			#微信推送
			weixin_push
		;;
		3)
			#将shell模块检测推送到另外一个小程序上（举个例子，一个企业号，两个小程序，小程序１填到sendNotify.js,这样子js就会推送到哪里，小程序２填写到jd_openwrt_config这样jd.sh写的模块就会推送到小程序2
			weixin_push
		;;
		*)
			echo -e "${green} jd_openwrt_script_config.txt${white}的${yellow} push_if参数${white}$red填写错误，不进行推送${white}"
		;;
	esac

}

server_push() {

if [ ! $SCKEY ];then
	echo "没找到Server酱key不做操作"
else
	echo -e "${green} server酱开始推送$title${white}"
	curl -s "http://sc.ftqq.com/$SCKEY.send?text=$title++`date +%Y-%m-%d`++`date +%H:%M`" -d "&desp=$server_content" >/dev/null 2>&1

	if [[ $? -eq 0 ]]; then
		echo -e "${green} server酱推送完成${white}"
	else
		echo -e "$red server酱推送失败。请检查报错代码$title${white}"
	fi
fi

}

weixin_push() {
current_time=$(date +%s)
expireTime="7200"
if [ $push_if == "3" ];then
	weixinkey=$(grep "weixin2" $openwrt_script_config/jd_openwrt_script_config.txt | awk -F "'" '{print $2}')
else
	weixinkey=$(grep "let QYWX_AM" $openwrt_script_config/sendNotify.js | awk -F "'" '{print $2}')
fi

#企业名
corpid=$(echo $weixinkey | awk -F "," '{print $1}')
#自建应用，单独的secret
corpsecret=$(echo $weixinkey | awk -F "," '{print $2}')
# 接收者用户名,@all 全体成员
touser=$(echo $weixinkey | awk -F "," '{print $3}')
#应用ID
agentid=$(echo $weixinkey | awk -F "," '{print $4}')
#图片id
media_id=$(echo $weixinkey | awk -F "," '{print $5}')

weixin_file="$openwrt_script_config/weixin_token.txt"
time_before=$(cat $weixin_file |grep "$corpsecret" | awk '{print $4}')


if [ ! $time_before ];then
	#获取access_token
	access_token=$(curl "https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=${corpid}&corpsecret=${corpsecret}" | sed "s/,/\n/g" | grep "access_token" | awk -F ":" '{print $2}' | sed "s/\"//g")
	sed -i "/$corpsecret/d" $weixin_file
	echo "$corpid $corpsecret $access_token `date +%s`" >> $weixin_file
	echo ">>>刷新access_token成功<<<"
else
	if [ $(($current_time - $time_before)) -gt "$expireTime" ];then
		#获取access_token
		access_token=$(curl "https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=${corpid}&corpsecret=${corpsecret}" | sed "s/,/\n/g" | grep "access_token" | awk -F ":" '{print $2}' | sed "s/\"//g")
		sed -i "/$corpsecret/d" $weixin_file
		echo "$corpid $corpsecret $access_token `date +%s`" >>$weixin_file
		echo ">>>刷新access_token成功<<<"
	else
		echo "access_token 还没有过期，继续用旧的"
		access_token=$(cat $weixin_file |grep "$corpsecret" | awk '{print  $3}')
	fi
fi

if [ ! $media_id ];then
	msg_body="{\"touser\":\"$touser\",\"agentid\":$agentid,\"msgtype\":\"text\",\"text\":{\"content\":\"$title\n$weixin_desp\"}}"
else
	msg_body="{\"touser\":\"$touser\",\"agentid\":$agentid,\"msgtype\":\"mpnews\",\"mpnews\":{\"articles\":[{\"title\":\"$title\",\"thumb_media_id\":\"$media_id\",\"content\":\"$weixin_content\",\"digest\":\"$weixin_desp\"}]}}"
fi
	echo -e "${green} 企业微信开始推送$title${white}"
	curl -s "https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=$access_token" -d "$msg_body"

	if [[ $? -eq 0 ]]; then
		echo -e "${green} 企业微信推送成功$title${white}"
	else
		echo -e "$red 企业微信推送失败。请检查报错代码$title${white}"
	fi

}

checklog() {
	log1="checklog_jd.log" #用来查看tmp有多少jd log文件
	log2="checklog_jd_error.log" #筛选jd log 里面有几个是带错误的
	log3="checklog_jd_error_detailed.log" #将错误的都输出在这里

	cd /tmp
	rm -rf $log3

	#用来查看tmp有多少jd log文件
	ls ./ | grep -E "^j" | grep -v "jd_price.log" | sort >$log1

	#筛选jd log 里面有几个是带错误的
	echo -e "$line#### Model：$sys_model\n#### Wan+IP地址：+$wan_ip\n#### 系统版本:++$uname_version\n$line" >>$log3
	echo "#### $current_time+检测到错误日志的文件" >>$log3
	for i in `cat $log1`
	do
		grep -Elrn  "错误|失败" $i  >> $log2
		grep -Elrn  "错误|失败" $i  >> $log3
	done

	cat_log=$(cat $log2 | wc -l)
	if [ $cat_log -ge "1" ];then
		num="JD_Script发现有$cat_log个日志包含错误信息"
	else
		num="no_error"
	fi

	#将详细错误信息输出log3
	for i in `cat $log2`
	do
		echo "#### ${i}详细的错误" >> $log3
		grep -E  "错误|失败|module" $i | grep -v '京东天天\|京东商城\|京东拍拍\|京东现金\|京东秒杀\|京东日历\|京东金融\|京东金贴\|金融京豆\|检测\|参加团主\|参团失败\|node_modules\|sgmodule\|无助力机会\|不可以为自己助力\|助力次数耗尽\|礼包已抢完\|限流严重\|不能去好友工厂打工啦\|验证失败\|提现失败\|助力失败' | sort -u >> $log3
	done

	if [ $num = "no_error" ]; then
		echo "**********************************************"
		echo -e "${green} log日志没有发现错误，一切风平浪静${white}"
		echo "**********************************************"
	else
		log_sort=$(cat ${log3} | sed "s/&//g" | sed "s/$/$wrap$wrap_tab$sort_log/g" |  sed ':t;N;s/\n//;b t' )
		server_content=$(echo "${log_sort}${by}" | sed "s/$wrap_tab####/####/g" )

		weixin_content_sort=$(cat ${log3} |sed "s/}//g" | sed "s/{//g"| sed "s/####/<hr\/><b>/g"   |sed "s/$line/<hr\/><\/b>/g" |sed "s/$wrap$wrap_tab/<br>/g" |sed "s/<br>#//g"  | sed "s/$/<br>/" |sed "s/<hr\/><\/b><br>/<hr\/><\/b>/g"| sed "s/详细的错误<br>/详细的错误<b\/><hr\/><br>/g" | sed "s/错误日志的文件/错误日志的文件<b\/><hr\/>/g"| sed "s/<hr\/><b> Wan/<b> Wan/g" | sed "s/<hr\/><b> Model/<b> Model/g" | sed "s/<hr\/><b> 系统版本/<b> 系统版本/g"| sed "s/\"//g"  | sed "s/+/ /g" |  sed ':t;N;s/\n//;b t' | sed "s/<br><hr\/><\/b><hr\/><b>/<br><\/b><hr\/><b>/g")
		weixin_content=$(echo "$weixin_content_sort<br><b>$by")
		weixin_desp=$(echo "$weixin_content" | sed "s/<hr\/><\/b><b>/$weixin_line\n/g" |sed "s/<hr\/><\/b>/\n$weixin_line\n/g"| sed "s/<b>/\n/g"| sed "s/<br>/\n/g" | sed "s/<br><br>/\n/g" | sed "s/#/\n/g" | sed "s/<hr\/>//g" | sed "s/<b\/><hr\/>//g" | sed "s/<b\/>//g" | sed "s/<\/b>/$weixin_line\n/g" )

		title="$num"
		push_menu
	fi

	rm -rf $log1
	rm -rf $log2
}

#检测当天更新情况并推送
that_day() {
	 wget -t 1 -T 20 https://raw.githubusercontent.com/xdhgsq/xdh/main/README.md -O /tmp/test_README.md
	if [[ $? -eq 0 ]]; then
		cd $dir_file
		git fetch
		if [[ $? -eq 0 ]]; then
			echo ""
		else
			echo "请检查你的网络，github更新失败，建议科学上网"
		fi
	else
		echo "请检查你的网络，github更新失败，建议科学上网"
	fi
	clear
	git_branch=$(git branch -v | grep -o behind )
	if [[ "$git_branch" == "behind" ]]; then
		Script_status="建议更新"
	else
		Script_status="最新"
	fi

	if [ ! -d $dir_file/git_log ];then
		mkdir 	$dir_file/git_log
	fi

	echo > $dir_file/git_log/${current_time}.log


	git_log=$(git log --format=format:"%ai %an %s" --since="$current_time 00:00:00" --before="$current_time 23:59:59" | sed "s/+0800//g" | sed "s/$current_time //g" | sed "s/ /+/g")
	echo $git_log >/tmp/git_log_if.log
	git_log_if=$(cat /tmp/git_log_if.log | wc -l )
	if [ $git_log_if -ge 1  ];then
		echo -e "$line#### Model：$sys_model\n#### Wan+IP地址：+$wan_ip\n#### 系统版本:++$uname_version\n$line\n#### $current_time+`date +%H:%M`点+更新日志\n" >> $dir_file/git_log/${current_time}.log
		echo "  时间       +作者          +操作" >> $dir_file/git_log/${current_time}.log
		echo "$git_log" >> $dir_file/git_log/${current_time}.log
		echo "#### 当前脚本是否最新：$Script_status" >>$dir_file/git_log/${current_time}.log
	else
		echo -e "$line#### Model：$sys_model\n#### Wan+IP地址：+$wan_ip\n#### 系统版本:++$uname_version\n$line\n#### $current_time+更新日志\n" >> $dir_file/git_log/${current_time}.log
		echo "作者泡妹子或者干饭去了$wrap$wrap_tab今天没有任何更新$wrap$wrap_tab不要催佛系玩。。。" >>$dir_file/git_log/${current_time}.log
		echo "\n" >>$dir_file/git_log/${current_time}.log
		echo "#### 当前脚本是否最新：$Script_status" >>$dir_file/git_log/${current_time}.log
	fi

	log_sort=$(cat  $dir_file/git_log/${current_time}.log |sed "s/$/$wrap$wrap_tab/" | sed ':t;N;s/\n//;b t' | sed "s/$wrap_tab####/####/g")
	server_content=$(echo "${log_sort}${by}" | sed "s/$wrap_tab####/####/g" )

	weixin_content_sort=$(echo  $log_sort |sed "s/####/<b>/g"   |sed "s/$line/<hr\/><\/b>/g" |sed "s/$wrap/<br>/g" |sed "s/<br>#//g"  | sed "s/$/<br>/" |sed "s/<hr\/><\/b><br>/<hr\/><\/b>/g" |sed "s/+/ /g"| sed "s/<br> <br>/<br>/g"|  sed ':t;N;s/\n//;b t' )
	weixin_content=$(echo "$weixin_content_sort<br><b>$by")
	weixin_desp=$(echo "$weixin_content" | sed "s/<hr\/><\/b><b>/$weixin_line\n/g" |sed "s/<hr\/><\/b>/\n$weixin_line\n/g"| sed "s/<b>/\n/g"| sed "s/<br>/\n/g" | sed "s/<br><br>/\n/g" | sed "s/#/\n/g" )

	title="JD_Script仓库状态"
	push_menu
}

backnas() {
	date_time=$(date +%Y-%m-%d-%H_%M)
	back_file_name="script_${date_time}.tar.gz"
	#判断所在文件夹
	if [ "$dir_file" == "$openwrt_script/JD_Script" ];then
		backnas_config_file="$openwrt_script_config/backnas_config.txt"
		back_file_patch="$openwrt_script"
		if [ ! -f "$openwrt_script_config/backnas_config.txt" ]; then
			backnas_config
		fi
	else
		backnas_config_file="$dir_file/config/backnas_config.txt"
		back_file_patch="$dir_file"
		if [ ! -f "$dir_file/config/backnas_config.txt" ]; then
			backnas_config
		fi
	fi

	#判断config文件
	backnas_config_version="1.0"
	if [ `grep -o "backnas_config版本$backnas_config_version" $backnas_config_file |wc -l` == "0" ]; then
		echo "backnas_config有变，开始更新"
		backnas_config
		echo "backnas计划任务设置完成"
	fi
	clear


	#ssh 连接不需要填yes
	sed -i "s/#   StrictHostKeyChecking ask/StrictHostKeyChecking no/g" /etc/ssh/ssh_config

	#判断依赖
	sshpass_if=$(opkg list-installed | grep 'sshpass' |awk '{print $1}')
	if [ ! $sshpass_if ];then
		echo "未检测到sshpass依赖，开始安装"
		opkg update
		opkg install sshpass
	fi

	#开始传递参数
	nas_user=$(grep "user" $backnas_config_file | awk -F "'" '{print $2}')
	nas_secret_key=$(grep "secret_key" $backnas_config_file | awk -F "'" '{print $2}')
	nas_pass=$(grep "password" $backnas_config_file | awk -F "'" '{print $2}')
	nas_ip=$(grep "nas_ip" $backnas_config_file | awk -F "'" '{print $2}')
	nas_file=$(grep "nas_file" $backnas_config_file | awk -F "'" '{print $2}')
	nas_prot=$(grep "port" $backnas_config_file | awk -F "'" '{print $2}')

	echo "#########################################"
	echo "       backnas $backnas_version版本"
	echo "#########################################"
	#判断用户名
	if [ ! $nas_user ];then
		echo -e "${yellow} 用户名:$red    空 ${white}"
		echo "空" >/tmp/backnas_if.log
	else
		echo -e "${yellow} 用户名：${green} $nas_user ${white}"
		echo "正常" >/tmp/backnas_if.log
	fi

	#判断密码
	if [ ! $nas_pass ];then
		echo -e "${yellow} 密码：$red     空 ${white}"
		echo "空" >>/tmp/backnas_if.log
	else
		echo -e "${yellow} 密码：${green}这是机密不显示给你看 ${white}"
		echo "正常" >>/tmp/backnas_if.log
	fi

	#判断密钥
	if [ ! $nas_secret_key ];then
		echo -e "${yellow} NAS 密钥：${green} 空(可以为空)${white}"
	else
		echo -e "${yellow} NAS 密钥：${green} $nas_secret_key ${white}"
		echo "正常" >>/tmp/backnas_if.log
	fi

	#判断IP
	if [ ! $nas_ip ];then
		echo -e "${yellow} NAS IP:$red    空 ${white}"
		echo "空" >>/tmp/backnas_if.log
	else
		echo -e "${yellow} NAS IP：${green}$nas_ip ${white}"
		echo "正常" >>/tmp/backnas_if.log
	fi

	#判断NAS文件夹
	if [ ! $nas_file ];then
		echo -e "${yellow} NAS文件夹:$red 空 ${white}"
		echo "空" >>/tmp/backnas_if.log
	else
		echo -e "${yellow} NAS备份目录：${green} $nas_file ${white}"
		echo "正常" >>/tmp/backnas_if.log
	fi

	#判断端口
	if [ ! $nas_prot ];then
		echo -e "${yellow} NAS 端口:$red   空 ${white}"
	else
		echo -e "${yellow} NAS 端口：${green} $nas_prot ${white}"
	fi

	echo -e "${yellow} 使用协议：${green} SCP${white}"
	echo ""
	echo -e "${yellow} 参数填写${green}$backnas_config_file${white}"
	echo "#########################################"

	back_if=$(cat /tmp/backnas_if.log | sort -u )
	if [ $back_if == "空" ];then
		echo ""
		echo -e "$red重要参数为空 不执行备份操作，需要备份的，把参数填好,${white}填好以后运行${green} sh \$jd backnas ${white}测试一下是否正常${white}"
		exit 0
	fi

	echo -e "${green}>> 开始备份到nas${white}"
	sleep 5

	echo -e "${green}>> 打包前处理，删除ccr_js文件"
	rm -rf $back_file_patch/JD_Script/ccr_js/*
	echo -e "${green}>> 删除完成${white}"
	sleep 5

	echo -e "${green}>> 复制/etc/profile到$back_file_patch/JD_Script/profile${white}"
	cp /etc/profile $back_file_patch/JD_Script/profile
	echo "复制完成"
	sleep 5

	echo -e "${green}>> 开始打包文件${white}"
	tar -zcvf /tmp/$back_file_name $back_file_patch
	sleep 5

	clear
	echo -e "${green}>> 开始上传文件 ${white}"
	echo -e "${yellow}注意事项: 首次连接NAS的ssh会遇见${green} Do you want to continue connecting?${white}然后你输入y卡住不动"
	echo -e "${yellow}解决办法:ctrl+c ，然后${green} ssh -p $nas_prot $nas_user@$nas_ip ${white}连接成功以后输${green} logout${white}退出NAS，重新执行${green} sh \$jd backnas${white}"
	echo ""
	echo -e "${green}>> 上传文件中，请稍等。。。。 ${white}"

	if [ ! $nas_secret_key ];then
		if [ ! $nas_pass ];then
			echo -e "$red 密码：为空 ${white}参数填写${green}$backnas_config_file${white}"
			read a
			backnas
		else
			sshpass -p "$nas_pass" scp -P $nas_prot -r /tmp/$back_file_name $nas_user@$nas_ip:$nas_file
		fi
	else
		scp -P $nas_prot -i $nas_secret_key -r /tmp/$back_file_name $nas_user@$nas_ip:$nas_file
	fi

	if [ $? -eq 0 ]; then
		sleep 5
		echo -e "${green}>> 上传文件完成 ${white}"
		echo ""
		echo "#############################################################################"
		echo ""
		echo -e "${green} $date_time将$back_file_name上传到$nas_ip 的$nas_file目录${white}"
		echo ""
		echo "#############################################################################"
	else
		echo -e "$red>> 上传文件失败，请检查你的参数是否正确${white}"
	fi
	echo ""
	echo -e "${green}>> 清理tmp文件 ${white}"
	rm -rf /tmp/*.tar.gz
	sleep 5

	echo -e "${green}>> 开始更新脚本并恢复并发文件夹${white}"
	update
	echo -e "${green}>> 脚本更新完成${white}"
}

backnas_config() {
cat >$backnas_config_file <<EOF
################################################################
                 backnas_config版本$backnas_config_version
用于备份JD_script 到NAS 采用scp传输，请确保你的nas，ssh端口有打开
################################################################
#填入你的nas账号(必填)
user=''

#填入你nas的密码(密码和密钥必须填一个)
password=''

#填入你nas的密钥位置(可以留空)(密钥 > 密码,有密钥的情况优先使用密钥而不是密码)
secret_key=''

#填入nas IP地址可以是域名(必填)
nas_ip=''

#填入nas保存路径(必填)
nas_file=''

#端口(默认即可，ssh端口有变填这里)
port='22'
EOF
}

stop_script() {
	echo -e "${green} 删掉定时任务，这样就不会定时运行脚本了${white}"
	task_delete
	sleep 3
	killall -9 node 
	echo -e "${green}处理完成，需要重新启用，重新跑脚本sh \$jd 就会添加定时任务了${white}"
}


help() {
	#检查脚本是否最新
	echo "稍等一下，正在取回远端脚本源码，用于比较现在脚本源码，速度看你网络"
	cd $dir_file
	git fetch
	if [[ $? -eq 0 ]]; then
		echo ""
	else
		echo -e "$red>> 取回分支没有成功，重新执行代码${white}"
		system_variable
	fi
	clear
	git_branch=$(git branch -v | grep -o behind )
	if [[ "$git_branch" == "behind" ]]; then
		Script_status="$red建议更新${white} (可以运行${green} sh \$jd update_script && sh \$jd update && source /etc/profile && sh \$jd ${white}更新 )"
	else
		Script_status="${green}最新${white}"
	fi
	task
	clear
	echo ----------------------------------------------------
	echo "	     JD.sh $version 使用说明"
	echo ----------------------------------------------------
	echo -e "${yellow} 1.文件说明${white}"
	echo ""
	echo -e "${green}  $openwrt_script_config/jdCookie.js ${white} 在此脚本内填写JD Cookie 脚本内有说明"
	echo -e "${green}  $openwrt_script_config/sendNotify.js ${white} 在此脚本内填写推送服务的KEY，可以不填"
	echo -e "${green}  $openwrt_script_config/USER_AGENTS.js ${white} 京东UA文件可以自定义也可以默认"
	echo -e "${green}  $openwrt_script_config/JS_USER_AGENTS.js ${white} 京东极速版UA文件可以自定义也可以默认"
	echo ""
	echo -e "${yellow} JS脚本活动列表：${green} $dir_file/git_clone/lxk0301_back/README.md ${white}"
	echo -e "${yellow} 浏览器获取京东cookie教程：${green} $dir_file/git_clone/lxk0301_back/backUp/GetJdCookie.md ${white}"
	echo -e "${yellow} 获取到cookie填入脚本：${green} sh \$jd addcookie ${white}"
	echo ""
	echo -e "$red 注意：${white}请停掉你之前运行的其他jd脚本，然后把${green} JS脚本活动列表${white}的活动全部手动点开一次，不知活动入口的，$dir_file_js/你要的js脚本里有写"
	echo ""
	echo -e "${yellow} 2.jd.sh脚本命令${white}"
	echo ""
	echo -e "${green}  sh \$jd run_0  run_07			#运行全部脚本(除个别脚本不运行)${white}"
	echo ""
	echo -e "${yellow}个别脚本有以下："
	echo ""
	echo -e "${green}  sh \$jd npm_install ${white}  			#安装 npm 模块"
	echo ""
	echo -e "${green}  sh \$jd zcbh ${white}				#资产变化一对一"
	echo ""
	echo -e "${green}  sh \$jd opencard ${white}  			#开卡(默认不执行，你可以执行这句跑)"
	echo ""
	echo -e "${green}  sh \$jd jx ${white} 				#查询京喜商品生产使用时间"
	echo ""
	echo -e "${green}  sh \$jd jd_sharecode ${white} 			#查询京东所有助力码"
	echo ""
	echo -e "${green}  sh \$jd checklog ${white}  			#检测log日志是否有错误并推送"
	echo ""
	echo -e "${green}  sh \$jd that_day ${white}  			#检测JD_script仓库今天更新了什么"
	echo ""
	echo -e "${green}  sh \$jd check_cookie_push ${white}  		#推送cookie大概到期时间和是否有效"
	echo ""
	echo -e "${green}  sh \$jd script_name ${white}  			#显示所有JS脚本名称与作用"
	echo ""
	echo -e "${green}  sh \$jd backnas ${white}  			#备份脚本到NAS存档"
	echo ""
	echo -e "${green}  sh \$jd stop_script ${white}  			#删除定时任务停用所用脚本"
	echo ""
	echo -e "${green}  sh \$jd kill_ccr ${white}  			#终止并发"
	echo ""
	echo -e "${green}  sh \$jd checktool ${white}  			#检测后台进程，方便排除问题"
	echo ""
	echo -e " 如果不喜欢这样，你也可以直接${green} cd \$jd_file/js${white},然后用${green} node 脚本名字.js${white} "
	echo ""
	echo -e "${yellow} 3.检测定时任务:${white} $cron_help"
	echo -e "${yellow}   定时任务路径:${white}${green}/etc/crontabs/root${white}"
	echo ""
	echo -e "${yellow} 4.如何排错或者你想要的互助码:${white}"
	echo ""
	echo "  答1：如何排错有种东西叫更新，如sh \$jd update_script 和sh \$jd update"
	echo "  答2：如何排错有种东西叫查日志，如/tmp/里面的jd开头.log结果的日志文件"
	echo "  答3：你想要的互助码 sh \$jd jd_sharecode"
	echo ""
	echo "  看不懂代码又想白嫖，你还是洗洗睡吧，梦里啥都有，当然你可以用钞能力解决多数问题（你可以忽略这句，继续做梦）"
	echo ""
	echo -e "${yellow} 5.检测脚本是否最新:${white} $Script_status "
	echo ""
	echo -e "${yellow} 6.个性化配置：${white} $jd_config_version"
	echo ""
	echo -e "${yellow} 7.JD_Script报错你可以反馈到这里:${white}${green} https://github.com/xdhgsq/xdh/issues${white}"
	echo ""
	echo -e "$index_num"
	echo ""
	echo ""
	echo -e "本脚本基于${green} x86主机测试${white}，一切正常，其他的机器自行测试，满足依赖一般问题不大"
	echo ----------------------------------------------------
	echo " 		by：ITdesk"
	echo ----------------------------------------------------

	time &
}


additional_settings() {

	for i in `cat $dir_file/config/collect_script.txt | grep -v "#.*js" | awk '{print $1}'`
	do
	{
		sed -i "s/$.isNode() ? 20 : 5/0/g" $dir_file_js/$i
		sed -i "s/$.isNode() ? 10 : 5/0/g" $dir_file_js/$i
		#合并左右规则
		sed -i 's/helpShareFlag = "true"/helpShareFlag = "false"/g' $dir_file_js/$i
		sed -i 's/HelpAuthorFlag = true/HelpAuthorFlag = false/g' $dir_file_js/$i
		sed -i 's/ShHelpAuthorFlag = true/ShHelpAuthorFlag = false/g' $dir_file_js/$i
		sed -i 's/pKHelpAuthorFlag = true/pKHelpAuthorFlag = false/g' $dir_file_js/$i
		sed -i 's/helpAuthor = true/helpAuthor = false/g' $dir_file_js/$i
		sed -i 's/helpAuthor=true/helpAuthor=false/g' $dir_file_js/$i
		sed -i 's/helpAu = true/helpAu = false/g' $dir_file_js/$i
		#Aaron
		sed -i 's/master\/shareCodes/12345/g' $dir_file_js/$i
		sed -i "s/transfer.nz.lu\/jxmc/1234/g" $dir_file_js/$i
		#Cdle
		sed -i 's/jdsharecode.xyz/12345.xyz/g' $dir_file_js/$i
		#Zero
		sed -i 's/main\/shareCodes/12345/g' $dir_file_js/$i
		#Star261
		sed -i 's/lukelucky6\/code/12345/g' $dir_file_js/$i
		#Smiek
		sed -i 's/jd.smiek.tk/jd.12345.tk/g' $dir_file_js/$i

	}&
	done
	wait

	#东东超市兑换豆子
	sed -i "s/coinToBeans = ''/coinToBeans = '超值京豆包'/g" $dir_file_js/jd_blueCoin.py
	sed -i "s/blueCoin_Cc = False/blueCoin_Cc = True/g" $dir_file_js/jd_blueCoin.py

	#宠汪汪路径修改
	sed -i "s/..\/USER_AGENTS.js/.\/USER_AGENTS.js/g" $dir_file_js/JDJRValidator_Pure.js

	#sed -i "s/\/JDJRValidator_Pure/.\/JDJRValidator_Pure/g"　$dir_file_js/jd_joy.js
	#sed -i "s/.\/utils//g" $dir_file_js/jd_joy.js



	#取消店铺从20个改成50个(没有星推官先默认20吧)
	sed -i "s/|| 20/|| $jd_unsubscribe/g" $dir_file_js/jd_unsubscribe.js

	if [ `cat $openwrt_script_config/sendNotify.js | grep "采用lxk0301开源JS脚本" | wc -l` == "0" ];then
	sed -i "s/本脚本开源免费使用 By：https:\/\/gitee.com\/lxk0301\/jd_docker/#### 脚本仓库地址:https:\/\/github.com\/xdhgsq\/xdh/g" $openwrt_script_config/sendNotify.js
	sed -i "s/本脚本开源免费使用 By：https:\/\/github.com\/LXK0301\/jd_scripts/#### 脚本仓库地址:https:\/\/github.com\/xdhgsq\/xdh/g" $openwrt_script_config/sendNotify.js
	fi
	

	#东东农场
ITdesk_fr="6632c8135d5c4e2c9ad7f4aa964d4d11@f0319fde539a485abcf782197b1b919c@31a2097b10db48429013103077f2f037@5aa64e466c0e43a98cbfbbafcc3ecd02@bf0cbdb0083d443499a571796af20896"
ITdesk_random_fr="4a75d8a6233344b1965857ae23831ce7@392acd7b14d9476bb48ebf2ac171cffc@e1625e7dae2c4dfa9124f5371d72d723@d093cbe35e0e47e68195c8d2cde12d06@c38428e6a9d14a3c9af202fddd27e831@3c3b3e3738694355bb0307764a2fa692@9bd54e69fb174a5fa188961ec17dd931@10cae0f60a43485c9920943f22c44b3d@91f4dbb39a4346b39126786a3a5d3383@0282b62c955349bc80c67dca4e85d6b5@2879a2162d744572889098827b49165e@1b20a9b3d7004d179fd6a1031553b017@529972002f044c6ca466e8998ab5ba6b@60d5528a7d004692a5516094d3c7afd6@b1e184275cc24382a606dada8df0a3b2@f1d4e4d5a5324cb08784dc4afde19513@5e54362c4a294f66853d14e777584598@f0f5edad899947ac9195bf7319c18c7f@52f4e9bdc02b44e98d34c2df77bf4aae"
	
zuoyou_20190516_fr="367e024351fe49acaafec9ee705d3836@3040465d701c4a4d81347bc966725137@82c164278e934d5aaeb1cf19027a88a3@a2504cd52108495496460fc8624ae6d4@4eb7542e28714d6e86739151f8aadc6e"

zuoyou_20190516_random_fr="983be1208879492fa692c1b89a30fc15@ba02bdbac56a4b9c967443eae04bc8fa@3e3080883ea346d0a653afaeac74b357@e8bd1e69ccc24d65a4e183dcfb025606@ce0c26cd3375486c8ad41c4e1f61c449"

Javon_20201224_fr="926a1ec44ddd459ab2edc39005628bf4@d535648ffa3b45d79ff66b997ec8b629"
	Javon_random_fr="b2921984328744d7bc4302738235a4a8@8ac8cb7c9ded4a17b8057e27ed458104@e65a8b0cd1cc433a87bfd5925778fadc@669e5763877c4f97ab4ea64cd90c57fa@86ab77a88a574651827141e1e8c0b4c6@8ac8cb7c9ded4a17b8057e27ed458104@33b778b454a64b1e91add835e635256c@c9bb7ca2a80d4c8ab2cae6216d7a9fe6@dcfb05a919ff472680daca4584c832b8@0ce9d3a5f9cd40ccb9741e8f8cf5d801@54ac6b2343314f61bc4a6a24d7a2eba1@bad22aba416d4fffb18ad8534b56ea60@e5a87df07c914457b855cbb2f115d0a4@9a4370f99abb4eda8fa61d08be81c1d7@d535648ffa3b45d79ff66b997ec8b629@8b8b4872ab9d489896391cc5798a56e2"

chiyu_fr="f227e8bb1ea3419e9253682b60e17ae5"
	ashou_20210516_fr="9046fbd8945f48cb8e36a17fff9b0983@72abb03ca91a4569933c6c8a62a5622c@5e567ba1b9bd4389ae19fa09ca276f33@82b1494663f9484baa176589298ca4b3@616382e94efa476c90f241c1897742f1@d4e3080b06ed47d884e4ef9852cad568@ed2b2d28151a482eae49dff2e5a588f8@a8b204ae2a7541a18e54f5bfb7dcb04b"

xiaodengzi_20190516_fr="e24edc5de45341dd98f352533e23f83a@8284c080686b45c89a6c6f7d1ea7baac@8dda5802f0d54f38af48c4059c591007"
xiaodengzi_random_20190516_fr="e004a4244e244863b14d7210f8513113@f69821dde34540d39f95315c5290eb88@5e753c671d0644c7bb418523d3452975@c6f859ec57d74dda9dafc6b3c2af0a0f	"
	
jidiyangguang_20190516_fr="3e6f0b7a2d054331a0b5b956f36645a9@304b39f17d6c4dac87933882d4dec6bc"

baipiaoguai_fr="456e5601548642a5a9bcc86a54085154@61f21ef708c948568854ec50c3627085@72dd4d3e2245472986f729953c5be146@13be2ecb23344d86ada656a3d8a6cf92@3f67b8f4a53641ad992c2f0584cdf46d"

	if [ ! $jd_sharecode_fr ];then
		echo "东东农场本地助力码为空"
		new_fruit1="$ITdesk_fr"
	else
		echo "开始添加东东农场本地助力码"
		new_fruit1="$jd_sharecode_fr@$ITdesk_fr"
	fi

	random_fruit="$ITdesk_random_fr@$zuoyou_20190516_random_fr@$Javon_random_fr@$xiaodengzi_random_20190516_fr@$baipiaoguai_fr"
	random="$random_fruit"
	random_array
	new_fruit_set="'$new_fruit1@$zuoyou_20190516_fr@$Javon_20201224_fr@$jidiyangguang_20190516_fr@$ashou_20210516_fr@$xiaodengzi_20190516_fr@$xiaobandeng_fr@$chiyu_fr@$random_set',"

	js_amount=$(cat $openwrt_script_config/js_cookie.txt | wc -l)
	fr_rows=$(grep -n "shareCodes =" $dir_file_js/jd_fruit.js | awk -F ":" '{print $1}')
	while [[ ${js_amount} -gt 0 ]]; do
		sed -i "$fr_rows a \ $new_fruit_set " $dir_file_js/jd_fruit.js
		js_amount=$(($js_amount - 1))
	done

	js_amount=$(cat $openwrt_script_config/js_cookie.txt | wc -l)
	frcode_rows=$(grep -n "FruitShareCodes = \[" $dir_file_js/jdFruitShareCodes.js | awk -F ":" '{print $1}')
	while [[ ${js_amount} -gt 0 ]]; do
		sed -i "$frcode_rows a \ $new_fruit_set " $dir_file_js/jdFruitShareCodes.js
		js_amount=$(($js_amount - 1))
	done

	sed -i "s/dFruitBeanCard = false/dFruitBeanCard = $jd_fruit/g" $dir_file_js/jd_fruit.js #农场不浇水开始换豆

	#萌宠
ITdesk_pet="MTE1NDAxNzcwMDAwMDAwMzk1OTQ4Njk=@MTAxNzIxMDc1MTAwMDAwMDA1NTg4ODM0OQ==@MTE1NDQ5OTUwMDAwMDAwMzk3NDgyMDE=@MTAxODEyOTI4MDAwMDAwMDQwMTIzMzcx@MTEzMzI0OTE0NTAwMDAwMDA0MzI3NzE3MQ=="

ITdesk_random_pet="MTEzMzI1MTE4NDAwMDAwMDA1NDk0NzY0OQ==@MTEzMzI1MTE4NTAwMDAwMDA1NDk0NzYxMQ==@MTE1NDY3NTIwMDAwMDAwNTk0NjY5MDU=@MTEzMzI1MTE4NTAwMDAwMDA1OTQ2NjI2MQ==@MTEzMzI1MTE4NDAwMDAwMDA3MDk5NDQ1Nw==@MTAxNzIxMDc1MTAwMDAwMDA1MTk2NjQ4NQ==@MTEzMzI1MTE4NTAwMDAwMDA1MTgzMjM4MQ==@MTE1NDQ5MzYwMDAwMDAwNDUzMDI4NjM=@MTE0MDkyMjIwMDAwMDAwNDc4MzYyOTM=@MTE1NDUwMTI0MDAwMDAwMDQ1MzAyNjI5@MTE0MDkyMjEwMDAwMDAwNDg5MTA4MTE=@MTEyNzEzMjc0MDAwMDAwMDQ5OTA5Njg1@MTE1NDQ5OTIwMDAwMDAwNDUzMDYzMDc=@MTE5MzEwNTEzODAwMDAwMDA1MzIyNDQ1OQ==@MTAxODc2NTEzMTAwMDAwMDAwNjQ4MzU4NQ==@MTE5MzEwNTEzODAwMDAwMDA1NjQ5NjQ4Nw==@MTE1NDQ5OTUwMDAwMDAwNDAyNTYyMjM=@MTE1NDAxNzcwMDAwMDAwNDA4MzcyOTU=@MTEyNzEzMjc0MDAwMDAwMDQ4NjY4NjY3"
zuoyou_20190516_pet="MTEzMzI0OTE0NTAwMDAwMDAzODYzNzU1NQ==@MTE1NDAxNzgwMDAwMDAwMzg2Mzc1Nzc=@MTE1NDAxNzgwMDAwMDAwMzg4MzI1Njc=@MTE1NDQ5OTIwMDAwMDAwNDM3MTM3ODc=@MTAxNzIyNTU1NDAwMDAwMDA1MDIyMjIwMQ=="
	
zuoyou_20190516_random_pet="MTAxNzIxMDc1MTAwMDAwMDA1MDIyMjE2OQ==@MTEzMzI1MTE4NDAwMDAwMDA1MDA5Nzg4MQ==@MTAxNzIxMDc1MTAwMDAwMDA1MDA5NzczOQ==@MTEzMzI1MTE4NDAwMDAwMDA1MDExNTc2MQ==@MTEzMzI1MTE4NDAwMDAwMDA1MDEyMzYxNw=="

Javon_20201224_pet="MTE1NDUyMjEwMDAwMDAwNDE2NzYzNjc="
	Javon_random_pet="MTE0MDQ3MzIwMDAwMDAwNDczODQ2MTM=@MTAxODc2NTEzMDAwMDAwMDAxODU0NzI3Mw==@MTE1NDAxNzgwMDAwMDAwNDI1MjkxMDU=@MTE1NDQ5OTIwMDAwMDAwNDIxMjgyNjM=@MTE1NDAxNzYwMDAwMDAwMzYwNjg0OTE=@MTE1NDQ5OTIwMDAwMDAwNDI4Nzk3NTE=@MTE1NDQ5OTUwMDAwMDAwNDMwMTIxMzc=@MTE1NDQ5MzYwMDAwMDAwNDQ0NTA5MzM=@MTEzMzI0OTE0NTAwMDAwMDA0NDQ1ODY4NQ=="
	
chiyu_pet="MTAxODEyOTI4MDAwMDAwMDQwNzYxOTUx"
	ashou_20210516_pet="MTAxODEyOTI4MDAwMDAwMDM5NzM3Mjk5@MTEzMzI0OTE0NTAwMDAwMDAzOTk5ODU1MQ==@MTE1NDQ5OTIwMDAwMDAwNDIxMDIzMzM=@MTAxODEyMjkxMDAwMDAwMDQwMzc4ODU1@MTAxODc2NTEzMDAwMDAwMDAxOTcyMTM3Mw==@MTAxODc2NTEzMzAwMDAwMDAxOTkzMzM1MQ==@MTAxODc2NTEzNDAwMDAwMDAxNjA0NzEwNw=="

Jhone_Potte_20200824_pet="MTE1NDAxNzcwMDAwMDAwNDE3MDkwNzE=@MTE1NDUyMjEwMDAwMDAwNDE3NDU2MjU="

xiaodengzi_20190516_pet="MTE1NDUwMTI0MDAwMDAwMDM5NTc4ODQz@MTAxODExNDYxMTEwMDAwMDAwNDAxMzI0NTk="

jidiyangguang_20190516_pet="MTE1NDQ5OTUwMDAwMDAwMzk2NTY2MTk=@MTE1NDQ5MzYwMDAwMDAwMzk2NTY2MTE="

baipiaoguai_pet="MTE1NDQ5OTUwMDAwMDAwNDUyNzA4NDc=@MTEzMzI0OTE0NTAwMDAwMDA0NTIxOTk3MQ==@MTEyNjE4NjQ2MDAwMDAwMDQ4MTI4MjE3@MTEzMzE5ODE0NDAwMDAwMDA0OTYyMzYwNQ==@MTEyNzEzMjc0MDAwMDAwMDUzNjg2MTE5"

	if [ ! $jd_sharecode_pet ];then
		echo "萌宠本地助力码为空"
		new_pet="$ITdesk_pet"
	else
		echo "开始添加萌宠本地助力码"
		new_pet="$jd_sharecode_pet@$ITdesk_pet"
	fi

	random_pet="$ITdesk_random_pet@$zuoyou_20190516_random_pet@$Javon_random_pet@$baipiaoguai_pet"
	random="$random_pet"
	random_array
	new_pet_set="'$new_pet@$zuoyou_20190516_pet@$Javon_20201224_pet@$jidiyangguang_20190516_pet@$Jhone_Potte_20200824_pet@$chiyu_pet@$ashou_20210516_pet@$xiaodengzi_20190516_pet@$random_set',"

	js_amount=$(cat $openwrt_script_config/js_cookie.txt | wc -l)
	pet_rows=$(grep -n "shareCodes =" $dir_file_js/jd_pet.js | awk -F ":" '{print $1}')
	while [[ ${js_amount} -gt 0 ]]; do
		sed -i "$pet_rows a \ $new_pet_set " $dir_file_js/jd_pet.js
		js_amount=$(($js_amount - 1))
	done

	js_amount=$(cat $openwrt_script_config/js_cookie.txt | wc -l)
	petcode_rows=$(grep -n "PetShareCodes = \[" $dir_file_js/jdPetShareCodes.js | awk -F ":" '{print $1}')
	while [[ ${js_amount} -gt 0 ]]; do
		sed -i "$petcode_rows a \ $new_pet_set " $dir_file_js/jdPetShareCodes.js
		js_amount=$(($js_amount - 1))
	done

	#种豆
		  ITdesk_pb="4npkonnsy7xi3n46rivf5vyrszud7yvj7hcdr5a@fn5sjpg5zdejm2ebnsce2wsjvtu5xkzq4dvbdti@mlrdw3aw26j3xeqso5asaq6zechwcl76uojnpha@nkvdrkoit5o65lgaousaj4dqrfmnij2zyntizsa@u5lnx42k5ifivyrtqhfjikhl56zsnbmk6v66uzi"
ITdesk_random_pb="tnmcphpjys5icix3quq2q2em3bzzciltix2t6nq@u5lnx42k5ifiu6wgvad764nzeefohexgwsutp4y@e7lhibzb3zek3aczhci5fim2fjpypbw5y3pr3ky@l4ex6vx6yynovth6gd6nesvnkeimph3kozmj77i@mlrdw3aw26j3xv3imelq2znbjo2ksxcb5nyjsma@4npkonnsy7xi3fp63qlbql2mfudjnwmsbpc4egy@mlrdw3aw26j3xn447fyzg7h4kzlmyasgniqj4eq@aogye6x4cnc3pjc7clkvzuymko5xo6gnii54lua@e7lhibzb3zek2zfhyssxpnduf3vlv7xpfwbe3fq@llc3cyki3azsjryv3ovhiqpxtut2lkuv6hpeepa@bfgnkjwsawrkv7cnuqwybfujye3h7wlwy7o5jii@zalmhfy34qahymizttjksjba3bjixbgi6x2h7uy@olmijoxgmjutzy3d472v6l6xqdtegx4v4dpjo7q@mlrdw3aw26j3xwrjvz73nn6h3jwvnfsqe766zly@e7lhibzb3zek3giovoz45el7ymgcpt7ng5qq3ni@mlrdw3aw26j3xqggsyegc2itcc2h5yfpxyhctgq@e7lhibzb3zek234ckc2fm2yvkj5cbsdpe7y6p2a@u72q4vdn3zes24pmx6lh34pdcinjjexdfljybvi@bctcuetamr6idcvkftgulawwxu"

zuoyou_20190516_pb="sz5infcskhz3woqbns6eertieu@mxskszygpa3kaouswi7rele2ji@4npkonnsy7xi3vk7khql3p7gkpodivnbwjoziga@cq7ylqusen234wdwxxbkf23g6y@iu237u55hwjio2j4q6dveezrcun6yqgyh6iyj7a"
	
zuoyou_20190516_random_pb="qo77jw3hunt3nwx5wzintmzzyeetch6vbwqskmy@dhsx55vjyuzkxicr2ttrsc6c47dzqhvbnhxu33y@66nvo67oyxpycn4ikn3qhdxcdn6mteht2kjzfma@66nvo67oyxpycs3powuv6bovdtfmlunzvyx4roa@suqg5cye47cqmod5cabkwhsnvol5lpdrhgb3frq"
	

Javon_20201224_pb="wpwzvgf3cyawfvqim3tlebm3evajyxv67k5fsza"
			Javon_random_pb="g3ekvuxcunrery7ooivfylv2ci5ac3f4ijdgqji@wgkx2n7t2cr5oa6ro77edazro3kxfdgh6ixucea@qermg6jyrtndlahowraj6265fm@rug64eq6rdioosun4upct64uda5ac3f4ijdgqji@t4ahpnhib7i4hbcqqocijnecby@5a43e5atkvypfxat7paaht76zy@gdi2q3bsj3n4dgcs5lxnn2tyn4@mojrvk5gf5cfszku73tohtuwli@l4ex6vx6yynouzcgilo46gozezzpsoyqvp66rta@beda5sgrp3bnfrynnqutermxoe"
	

chiyu_pb="crydelzlvftgpeyuedndyctelq"
		ashou_20210516_pb="3wmn5ktjfo7ukgaymbrakyuqry3h7wlwy7o5jii@chcdw36mwfu6bh72u7gtvev6em@mlrdw3aw26j3w2hy5trqwqmzn6ucqiz2ribf7na@olmijoxgmjutzdb4pf2fwevfnx4fxdmgld5xu2a@yaxz3zbedmnzhemvhmrbdc7xhq@olmijoxgmjutyy7u5s57pouxi5teo3r4r2mt36i@olmijoxgmjutzh77gykzjkyd6zwvkvm6oszb5ni@dixtq55kenw3ykejvsax6y3xrq"
	
xiaodengzi_20190516_pb="kcpj4m5kmd4sfdp7ilsvvtkdvu@4npkonnsy7xi32mpzw3ekc36hh7feakdgbbfjky@j3yggpcyulgljlovo4pwsyi3xa@uvutkok52dcpuntu3gwko34qta@vu2gwcgpheqlm5vzyxutfzc774"
	
jidiyangguang_20190516_pb="e7lhibzb3zek2zin4gnao3gynqwqgrzjyopvbua@4npkonnsy7xi3smz2qmjorpg6ldw5otnabrmlei"

baipiaoguai_pb="nkiu2rskjyetbvmij6cinz4yh4gslwkrlieu3ki@uwgpfl3hsfqp3b4zn67l245x6cosobnqtyrbvaa@66nvo67oyxpycucmbw7emjhuj6xfe3d3ellmesq@h3cggkcy6agkgtvxoy76nn63ki7ans4blqb54vq@f5pavyxxlph5okvnqdbkpotqnauxqj6nyl5hm5a"

	if [ ! $jd_sharecode_pb ];then
		echo "种豆本地助力码为空"
		new_plantBean1="$ITdesk_pb"
	else
		echo "开始添加种豆本地助力码"
		new_plantBean1="$jd_sharecode_pb@$ITdesk_pb"
	fi
	random_plantBean="$ITdesk_random_pb@$zuoyou_20190516_random_pb@$Javon_random_pb@$baipiaoguai_pb"
	random="$random_plantBean"
	random_array
	new_plantBean_set="'$new_plantBean1@$zuoyou_20190516_pb@$Javon_20201224_pb@$jidiyangguang_20190516_pb@$chiyu_pb@$ashou_20210516_pb@$random_set',"

	js_amount=$(cat $openwrt_script_config/js_cookie.txt | wc -l)
	sed -i "s/shareCodes = \[/shareCodes = \[\n/g" $dir_file_js/jd_plantBean.js
	pb_rows=$(grep -n "shareCodes =" $dir_file_js/jd_plantBean.js | awk -F ":" '{print $1}')
	while [[ ${js_amount} -gt 0 ]]; do
		sed -i "$pb_rows a \ $new_plantBean_set " $dir_file_js/jd_plantBean.js
		js_amount=$(($js_amount - 1))
	done

	js_amount=$(cat $openwrt_script_config/js_cookie.txt | wc -l)
	pbcode_rows=$(grep -n "PlantBeanShareCodes = \[" $dir_file_js/jdPlantBeanShareCodes.js | awk -F ":" '{print $1}')
	while [[ ${js_amount} -gt 0 ]]; do
		sed -i "$pbcode_rows a \ $new_plantBean_set " $dir_file_js/jdPlantBeanShareCodes.js
		js_amount=$(($js_amount - 1))
	done

	#京喜工厂
	ITdesk_df="4HL35B_v85-TsEGQbQTfFg==@q3X6tiRYVGYuAO4OD1-Fcg==@Gkf3Upy3YwQn2K3kO1hFFg==@1s8ZZnxD6DVDyjdEUu-zXA==@MrEZ6KupbLvOQ_2LDf_xgQ==@jwk7hHoEWAsvQyBkNrBS1Q==@iqAUAWEQx86GvVthAu7-jQ=="
	
	ITdesk_random_df="ga_4DMiCZm_RqninySPJQw==@0_XIjHNNfhz2vahAPsORWg==@5fR4SoV03xlnfBTzPY537A==@hnWIPXiodM4iebGFG5-c_w==@YtnXm9MD-z3jPe4-0L0Zjw==@1s8ZZnxD6DVDyjdEUu-zXA==@oK5uN03nIPjodWxbtdxPPA==@7VHDTh1iDT3_YEtiZ1iRPA==@KPmB_yK4CEvytAyuVu1zpA==@2oz-ZbJy_cNdcrgSgRJ4Nw==@RNpsm77e351Rmo_R3KwC-g==@SY7JjLpgyYem-rsx1ezHyQ==@ziq14nX6tEIoto9iGTimVQ==@yHZcWiQpCym6GPplpjgwJQ=="

	zuoyou_20190516_df="oWcboKZa9XxTSWd28tCEPA==@sboe5PFeXgL2EWpxucrKYw==@rm-j1efPyFU50GBjacgEsw==@tZXnazfKhM0mZd2UGPWeCA==@9aUfCEmRqRW9fK7-P-eGnQ=="
	
	zuoyou_20190516_random_df="4yiyXPAaB_ReMPQy-st4AQ==@MmOfTa6Z79J9XRZA4roX1A==@rlJZquhGZTvDFksbDMhs2Q==@DriN9xUWha-XqE0cN3u7Fg==@krMPYOnVbZAAkZJiSz5cUw=="
	
	Javon_20201224_df="qXsC2yNWiylHJjOrjebXgQ==@P2nGgK6JgLtCqJBeQJ0f27XXLQwYAFHrKmA2siZTuj8=@LTyKtCPGU6v0uv-n1GSwfQ=="
	Javon_20201224_random_df="P2nGgK6JgLtCqJBeQJ0f27XXLQwYAFHrKmA2siZTuj8=@Y4r32JTAKNBpMoCXvBf7oA==@KDhTwFSjylKffc2V7dp5HQ==@UdTgtWxsEwypwH1v6GETfA==@LTyKtCPGU6v0uv-n1GSwfQ==@JuMHWNtZt4Ny_0ltvG6Ipg==@WnaDbsWYwImvOD1CpkeVWA==@Z2t6d_X8aMYIp7IwTnuNyA==@1Oob_S4cfK2z2gApmzRBgw==@BsCgeeTl_H2x5JQKGte6ow==@y7KhVRopnOwB1qFo2vIefg==@zS1ivJY43UFvaqOUiFijZQ==@USNexnDxgdW3h1M84IA8hQ==@QcxX97p7yNgImbEEZVEcyw==@N3AXGi-1Gt51bwdrCo76-Q=="
	chiyu_df="us6se4fFC6cSjHDSS_ScMw=="

	Jhone_Potte_20200824_df="Q4Rij5_6085kuANMaAvBMA==@gTLa05neWl8UFTGKpFLeog=="

	ashou_20210516_df="1rQLjMF_eWMiQ-RAWARW_w==@6h514zWW6JNRE_Kp-L4cjA==@2G-4uh8CqPAv48cQT7BbXQ==@cxWqqvvoGwDhojw6JDJzaA==@pvMjBwEJuWqNrupO6Pjn6w==@nNK5doo5rxvF1HjnP0Kwjw==@BoMD6oFV2DhQRRo_w-h83g==@PqXKBSk3K1QcHUS0QRsCBg=="

	jidiyangguang_20190516_df="w8B9d4EVh3e3eskOT5PR1A==@FyYWfETygv_4XjGtnl2YSg=="


	if [ ! $jd_sharecode_df ];then
		echo "京喜工厂本地助力码为空"
		new_dreamFactory="$ITdesk_df"
	else
		echo "开始添加京喜工厂本地助力码"
		new_dreamFactory="$jd_sharecode_df@$ITdesk_df"
	fi
	
	random_dreamFactory="$ITdesk_random_df@$zuoyou_20190516_random_df@$Javon_20201224_random_df"
	random="$random_dreamFactory"
	random_array
	new_dreamFactory_set="'$new_dreamFactory@$zuoyou_20190516_df@$Javon_20201224_df@$jidiyangguang_20190516_df@$ashou_20210516_df@$Jhone_Potte_20200824_df@$chiyu_df@$random_set',"

	df_rows=$(grep -n "inviteCodes =" $dir_file_js/jd_dreamFactory.js | awk -F ":" '{print $1}')
	while [[ ${js_amount} -gt 0 ]]; do
		sed -i "$df_rows a \ $new_dreamFactory_set " $dir_file_js/jd_dreamFactory.js
		js_amount=$(($js_amount - 1))
	done

	js_amount=$(cat $openwrt_script_config/js_cookie.txt | wc -l)
	dfcode_rows=$(grep -n "shareCodes = \[" $dir_file_js/jdDreamFactoryShareCodes.js | awk -F ":" '{print $1}')
	while [[ ${js_amount} -gt 0 ]]; do
		sed -i "$dfcode_rows a \ $new_dreamFactory_set " $dir_file_js/jdDreamFactoryShareCodes.js
		js_amount=$(($js_amount - 1))
	done


	#京喜开团
	sed -i "s/helpFlag = true/helpFlag = false/g" $dir_file_js/jd_dreamFactory_tuan.js


	#京东试用
	sed -i "/jd_try/d" $cron_file
	JD_TRY=$(cat $openwrt_script_config/jd_openwrt_script_config.txt | grep "JD_TRY=" | awk -F "\"" '{print $2}')
	if [ "$JD_TRY" == "true" ];then
		#jd_try变量(更多详细内容请查看/usr/share/jd_openwrt_script/JD_Script/js/jd_try.js)
		jd_try_ck=$(cat $openwrt_script_config/jd_openwrt_script_config.txt | grep "jd_try_ck" | awk -F "\"" '{print $2}')

		if [ ! -d "$dir_file/jd_try_file" ]; then
			mkdir $dir_file/jd_try_file
			mkdir $dir_file/jd_try_file/tmp
		else
			rm -rf $dir_file/jd_try_file/*
			mkdir $dir_file/jd_try_file/tmp
		fi

		ln -s $openwrt_script_config/sendNotify.js $dir_file/jd_try_file/tmp/sendNotify.js
		ln -s $openwrt_script_config/USER_AGENTS.js $dir_file/jd_try_file/tmp/USER_AGENTS.js
		cp $dir_file_js/jd_try.js $dir_file/jd_try_file/jd_try.js
		wget https://raw.githubusercontent.com/xdhgsq/xdh/main/JSON/jdCookie.js -O $dir_file/jd_try_file/jdCookie.js

		jd_try_if=$(grep "jd_try" $cron_file | wc -l)
		if [ "$jd_try_if" == "0" ];then
			echo "检测到试用开关开启，导入一下计划任务"
			echo "0 10 * * * $dir_file/jd.sh jd_try >/tmp/jd_try.log" >>$cron_file
			/etc/init.d/cron restart
		else
			echo "京东试用计划任务已经导入"
		fi

		if [ ! "$jd_try_ck" ];then
			ck_num=$(cat $openwrt_script_config/js_cookie.txt | wc -l)
			for i in `seq $ck_num`
			do
			{
				cp $dir_file/jd_try_file/jd_try.js  $dir_file/jd_try_file/tmp/jd_try$i.js
				cp $dir_file/jd_try_file/jdCookie.js $dir_file/jd_try_file/tmp/jdCookie$i.js
				sed -i "s/jdCookie.js/jdCookie$i.js/g" $dir_file/jd_try_file/tmp/jd_try$i.js

				jd_tryck=$(sed -n "$i p" $openwrt_script_config/js_cookie.txt)
				sed -i "5a $jd_tryck" $dir_file/jd_try_file/tmp/jdCookie$i.js
			}
			done
		else
			echo "$jd_try_ck" >/tmp/jd_tmp/jd_tryck.txt
			sed -i "s/@/\n/g" /tmp/jd_tmp/jd_tryck.txt
			ck_num=$(cat /tmp/jd_tmp/jd_tryck.txt |wc -l)
			for i in `seq $ck_num`
			do
			{
				cp $dir_file/jd_try_file/jd_try.js  $dir_file/jd_try_file/tmp/jd_try$i.js
				cp $dir_file/jd_try_file/jdCookie.js $dir_file/jd_try_file/tmp/jdCookie$i.js
				sed -i "s/jdCookie.js/jdCookie$i.js/g" $dir_file/jd_try_file/tmp/jd_try$i.js

				jd_tryck=$(sed -n "$i p" /tmp/jd_tmp/jd_tryck.txt)
				jd_tryck1=$(grep "$jd_tryck" $openwrt_script_config/js_cookie.txt)
				sed -i "5a $jd_tryck1" $dir_file/jd_try_file/tmp/jdCookie$i.js
			}
			done
		fi
	else
		jd_try_if=$(grep "jd_try" $cron_file | wc -l)
		if [ "$jd_try_if" == "1" ];then
			echo "检测到试用开关关闭，清理一下之前的导入"
			sed -i '/jd_try/d' /etc/crontabs/root >/dev/null 2>&1
			/etc/init.d/cron restart
		fi
		echo "京东试用计划任务不导入"
	fi
:<<'COMMENT'
	#签到领现金
	new_jdcash="eU9Ya-iyZ68kpWrRmXBFgw@eU9YEJLQI4h1kiqNogJA@eU9YabrkZ_h1-GrcmiJB0A@eU9YM7bzIptVshyjrwlt@eU9YCLTrH5VesRWnvw5t@eU9YC6nQAZhYoiqgtw9x@eU9YCLXXPrhnhCiQlCRg@P2nGgK6JgLtCqJBeQJ0f27XXLQwYAFHrKmA2siZTuj8=@JuMHWNtZt4Ny_0ltvG6Ipg==@IRM2beu1b-En9mzUwnU@eU9YaOSwMP8m-D_XzHpF0w@eU9Yau-yMv8ho2fcnXAQ1Q@eU9YCovbMahykhWdvS9R@JxwyaOWzbvk7-W3WzHcV1mw"
	zuoyou_20190516_jdcash="f1kwaQ@a1hzJOmy@eU9Ya7-wM_Qg-T_SyXIb0g@flpkLei3@eU9YD7rQHo1btTm9shR7@eU9YE67FOpl9hTG0mjNp@eU9YBJrlD5xcixKfrS1U@eU9YG7TVDLlhgAyBsRpw@eU9YG4X6HpZMixS8lBBu@eU9YH6THD4pXkiqTuCFi"
	chiyu_jdcash="cENuJam3ZP0"
	Jhone_Potte_20200824_jdcash="eU9Yaum1N_4j82-EzCUSgw@eU9Yar-7Nf518GyBniIWhw"
	jidiyangguang_20190516_jdcash="eU9YaOjhYf4v8m7dnnBF1Q@eU9Ya762N_h3oG_RmXoQ0A"
	ashou_20210516_jdcash="IhMxaeq0bvsj92i6iw@9qagtEUMPKtx@eU9YaenmYKhwpDyHySFChQ@eU9YariwMvp19G7WmXYU1w@YER3NLXuM6l4pg@eU9YaujjYv8moGrcnSFFgg@eU9Yar_kYvwjpD2DmXER3w@ZEFvJu27bvk"
	dreamer_20200524_jdcash="IhM0aOyybv4l8266iw@eU9Yaem2bqhz-WzSyHdG1Q@eU9Ya77hNakv8GaGyXUa0Q@eU9YaLnmYv909mvWnyUX0g@aUNoKb_qI6Im9m_S"
	test_jdcash="eU9YaO62NPh18j_dyHtA1Q@IhgybO66b_4g8me6iw@eU9YJJrOFbxPixuIshNw@eU9Yaey6MK4l9D3XwnQW1Q@eU9YaeThMqkn92vSn3Mb3w@eU9Ya-XkNfRypT_UmnRBhA"
	new_jdcash_set="'$new_jdcash@$chiyu_jdcash@$jidiyangguang_20190516_jdcash@$Jhone_Potte_20200824_jdcash@$ashou_20210516_jdcash@$zuoyou_20190516_jdcash@$dreamer_20200524_jdcash@$test_jdcash',"


	sed -i "s/$.isNode() ? 5 : 5/$.isNode() ? 5 : 0/g" $dir_file_js/jd_cash.js
	sed -i "s/helpAuthor = true/helpAuthor = false/g" $dir_file_js/jd_cash.js
	sed -i "s/https:\/\/raw.githubusercontent.com\/Aaron-lv\/updateTeam\/master\/shareCodes\/jd_updateCash.json//g" $dir_file_js/jd_cash.js
	sed -i "s/https:\/\/purge.jsdelivr.net\/gh\/Aaron-lv\/updateTeam@master\/shareCodes\/jd_updateCash.json//g" $dir_file_js/jd_cash.js
	sed -i "s/https:\/\/cdn.jsdelivr.net\/gh\/Aaron-lv\/updateTeam@master\/shareCodes\/jd_updateCash.json//g" $dir_file_js/jd_cash.js
	js_amount=$(cat $openwrt_script_config/js_cookie.txt | wc -l)
	sed -i "s/inviteCodes = \[/inviteCodes = \[\n/g" $dir_file_js/jd_cash.js
	cashcode_rows=$(grep -n "inviteCodes = \[" $dir_file_js/jd_cash.js | awk -F ":" '{print $1}')
	while [[ ${js_amount} -gt 0 ]]; do
		sed -i "$cashcode_rows a \ $new_jdcash_set " $dir_file_js/jd_cash.js
		js_amount=$(($js_amount - 1))
	done
COMMENT

	#京东赚赚长期活动
	new_jdzz="AUWE5mKmQzGYKXGT8j38cwA@AUWE5mvvGzDFbAWTxjC0Ykw@AUWE5wPfRiVJ7SxKOuQY0@S5KkcJEZAjD2vYGGG4Ip0@S5KkcREsZ_QXWIx31wKJZcA@S5KkcRUwe81LRIR_3xaNedw@Suvp2RBcY_VHKKBn3k_MMdNw@SvPVyQRke_EnWJxj1nfE@S5KkcRBYbo1fXKUv2k_5ccQ@S5KkcRh0ZoVfQchP9wvQJdw@S5KkcJnlwogCDQ2G84qtI"
	zuoyou_20190516_jdzz="S4r90RQ@S9r43CBsZ@S5KkcR00boFzRKEvzlvYCcA@S47wgARoc@S4qQkFUBOsgG4fQ@S7KQtF1dc8lbX@S5rQ3EUBOtA2Ifk0@S5KkcR0scpgDUdBnxkaEPcg@S5KkcOUt-tA2xfVuXyo9R@S-akMAUNKozyMcl6e_L8@S5KkcRRtL_VeBckj1xaYNfA@S5KkcRB8d9FLRKU6nkPQOdw"
	jidiyangguang_20190516_jdzz="S5KkcRBpK8lbeIxr8wfRcdw@S5KkcR0wdpFCGcRvwxv4Jcg"
	chiyu_jdzz="S7aUqCVsc91U"
	ashou_20210516_jdzz="Sv_V1RRgf_VPSJhyb1A@Sa0DkmLenrwOA@S5KkcRRtN8wCBdUimlqVbJw@S5KkcRkoboVKEJRr3xvINdQ@S_aIzGEdFoAGJdw@S5KkcRhpI8VfXcR79wqVcIA@S5KkcRk1P8VTSdUmixvUIfQ@S-acrCh8Q_VE"
	
	new_jdzz_set="$new_jdzz@$zuoyou_20190516_jdzz@$jidiyangguang_20190516_jdzz@$chiyu_jdzz@$ashou_20210516_jdzz"

	js_amount=$(cat $openwrt_script_config/js_cookie.txt | wc -l)
	jdzzcode_rows=$(grep -n "inviteCodes = \[" $dir_file_js/jd_jdzz.js | awk -F ":" '{print $1}')
	while [[ ${js_amount} -gt 0 ]]; do
		#sed -i "$jdzzcode_rows a \ '$new_jdzz_set', " $dir_file_js/jd_jdzz.js
		js_amount=$(($js_amount - 1))
	done

	#资产变化强化版by-ccwav
	sed -i "s/.\/sendNotify/.\/sendNotify_ccwav.js/g"  $dir_file_js/jd_bean_change_ccwav.js
}

del_if() {
	#脚本黑名单
	if [ ! $script_black ];then
		echo "脚本黑名单没有东西"
	else
		jd_num="black"
		del_js
		echo ""
	fi

	#不跑东东农场
	if [ ! $jd_ddfruit ];then
		echo "没有要删除的东东农场文件"
	else
		js_name="东东农场"
		jd_num="$jd_ddfruit"
		js_file="jd_fruit.js"
		del_js
		echo ""
	fi

	#不跑东东萌宠
	if [ ! $jd_ddpet ];then
		echo "没有要删除的东东萌宠文件"
	else
		js_name="东东萌宠"
		jd_num="$jd_ddpet"
		js_file="jd_pet.js"
		del_js
		echo ""
	fi

	#不跑宠汪汪
	if [ ! $jd_ddjoy ];then
		echo "没有要删除的宠汪汪文件"
	else
		js_name="宠汪汪"
		jd_num="$jd_ddjoy"
		js_file="jd_joy.js"
		del_js
		echo ""
	fi

	#不跑种豆得豆
	if [ ! $jd_ddplan ];then
		echo "没有要删除的种豆得豆文件"
	else
		js_name="种豆得豆"
		jd_num="$jd_ddplan"
		js_file="jd_plantBean.js"
		del_js
		echo ""
	fi

	#不跑京喜工厂
	if [ ! $jx_dddr ];then
		echo "没有要删除的京喜工厂文件"
	else
		js_name="京喜工厂"
		jd_num="$jx_dddr"
		js_file="jd_dreamFactory.js"
		del_js
		echo ""
	fi

	#不跑京喜牧场
	if [ ! $jx_ddmc ];then
		echo "没有要删除的京喜牧场文件"
	else
		js_name="京喜牧场"
		jd_num="$jx_ddmc"
		js_file="jd_jxmc.js"
		del_js
		echo ""
	fi

	#不跑京喜财富岛
	if [ ! $jx_ddcfd ];then
		echo "没有要删除的京喜财富岛文件"
	else
		js_name="京喜财富岛"
		jd_num="$jx_ddcfd"
		js_file="gua_wealth_island.js"
		del_js
		echo ""
	fi
	clear
}


del_js() {
	#检测变量删除对应并发文件夹的js文件，达到不跑的目的，缺点run文件会出现找不到文件提示，无伤大雅
	del_ck=$(echo $jd_num | sed "s/@/\n/g")
	for i in `echo "$del_ck"`
	do
		case "$i" in
			1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|52|53|54|55|56|57|58|59|60|61|62|63|64|65|66|67|68|69|70|71|72|73|74|75|76|77|78|79|80|81|82|83|84|85|86|87|88|89|90|91|92|93|94|95|96|97|98|99|100|101|102|103|104|105|106|107|108|109|110|111|112|113|114|115|116|117|118|119|120|121|122|123|124|125|126|127|128|129|130|131|132|133|134|135|136|137|138|139|140|141|142|143|144|145|146|147|148|149|150|151|152|153|154|155|156|157|158|159|160|161|162|163|164|165|166|167|168|169|170|171|172|173|174|175|176|177|178|179|180|181|182|183|184|185|186|187|188|189|190|191|192|193|194|195|196|197|198|199|200)
				#先支持删除200以内
				echo -e "******************${yellow}不跑${js_name}${white}******************"
				jx_file=$(ls $ccr_js_file/js_$i | grep "$js_file"  | wc -l)
				if [ "$jx_file" == "1" ];then
					echo -e "${yellow}开始删除并发文件${white}js_$i的${green}${js_name}${white}文件"
					rm -rf $ccr_js_file/js_$i/$js_file
				else
					echo -e "${yellow}并发文件${white}js_$i的${green}${js_name}${white}文件已经删除了"
				fi
				echo -e "*********${yellow}${js_name}${white}全部删除完毕，不会跑了*********"
			;;
			all)
				echo -e "******************${yellow}不跑${js_name}${white}******************"
				for i in `ls $ccr_js_file`
				do
					jx_file=$(ls $ccr_js_file/$i | grep "$js_file"  | wc -l)
					if [ "$jx_file" == "1" ];then
						echo -e "${yellow}开始删除并发文件${white}js_$i的${green}${js_name}${white}文件"
						rm -rf $ccr_js_file/$i/$js_file
					else
						echo -e "${yellow}并发文件${white}$i的${green}${js_name}${white}文件已经删除了"
					fi
				done
				#顺便删除一下js文件的脚本，做到真得不跑了
				rm -rf $dir_file_js/$js_file
				echo -e "*********${yellow}${js_name}${white}全部删除完毕，不会跑了*********"
			;;
			black)
				
				js_name="脚本黑名单"
				js_file=$(echo "$script_black" | sed "s/@/\n/g")
				echo -e "******************开始删除${yellow}${js_name}${white}里的脚本******************"
				#删除并发文件里的脚本
				for i in `ls $ccr_js_file`
				do
					for js_script in `echo $js_file`
					do
						jx_file=$(ls $ccr_js_file/$i | grep "$js_script"  | wc -l)
						if [ "$jx_file" == "1" ];then
							echo -e "${yellow}${js_name}${white}开始删除并发文件js_$i的${green}${js_script}${white}文件"
							rm -rf $ccr_js_file/$i/$js_script
						else
							echo -e "${yellow}${js_name}${white}检测到并发文件$i的${green}${js_script}${white}文件已经删除了"
						fi	
					done
				done
				
				#删除js文件夹中的脚本
				for js_script in `echo $js_file`
				do
					jx_file=$(ls $jd_file_js | grep "$js_script"  | wc -l)
					if [ "$jx_file" == "1" ];then
						echo -e "${yellow}${js_name}${white}开始删除JS文件夹里的${green}${js_script}${white}文件"
						rm -rf $jd_file_js/$js_script
					else
						echo -e "${yellow}${js_name}${white}检测到JS文件夹里的${green}${js_script}${white}文件已经删除了"
					fi	
				done
				echo -e "******************${yellow}${js_name}${white}里的脚本全部删除完毕******************"
			;;
			*)
				jx_site=$(cat $openwrt_script_config/js_cookie.txt  | grep -n  "$i"  | awk '{print $1}' |sed "s/://g")
				if [ ! $jx_site ];then
					echo "填写的用户名找不到，不删除$js_name文件"
				else
					echo -e "******************${yellow}不跑${js_name}${white}******************"
					jx_file=$(ls $ccr_js_file/js_$jx_site | grep "$js_file"  | wc -l)
					if [ "$jx_file" == "1" ];then
						echo -e "${yellow}开始删除并发文件${white}js_$jx_site的${green}${js_name}${white}文件"
						rm -rf $ccr_js_file/js_$jx_site/$js_file
					else
						echo -e "${yellow}并发文件${white}js_$jx_site的${green}${js_name}${white}文件已经删除了"
					fi
					echo -e "*********${yellow}${js_name}${white}全部删除完毕，不会跑了*********"
				fi
			;;
		esac
	done
	clear
}

share_code_generate() {
	js_amount="10"
	while [[ ${js_amount} -gt 0 ]]; do
		share_code_value="$share_code_value&$share_code"
		js_amount=$(($js_amount - 1))
	done
}

close_notification() {
	#农场和东东萌宠关闭通知
	if [ `date +%A` == "Monday" ];then
		echo -e "${green}今天周一不关闭农场萌宠通知${white}"
	else
		case `date +%H` in
		22|23|00|01)
			if [ "$ccr_if" == "yes" ];then
				for i in `ls $ccr_js_file | grep -E "^js"`
				do
				{
					sed -i "s/jdNotify = true/jdNotify = false/g" $ccr_js_file/$i/jd_fruit.js
					sed -i "s/jdNotify = true/jdNotify = false/g" $ccr_js_file/$i/jd_pet.js
				}&
				done
				ps_fr=$(ps -ww | grep "jd_fruit.js" | grep -v grep | wc -l)
				ps_pet=$(ps -ww | grep "jd_pet.js" | grep -v grep | wc -l)
				while [ $ps_fr -gt 0 ] && [ $ps_pet -gt 0 ];do
					sleep 1
					ps_fr=$(ps -ww | grep "jd_fruit.js" | grep -v grep | wc -l)
					ps_pet=$(ps -ww | grep "jd_pet.js" | grep -v grep | wc -l)
				done
			fi

			sed -i "s/jdNotify = true/jdNotify = false/g" $dir_file_js/jd_fruit.js
			sed -i "s/jdNotify = true/jdNotify = false/g" $dir_file_js/jd_pet.js

			echo -e "${green}暂时不关闭农场和萌宠通知${white}"
		;;
		*)
			if [ "$ccr_if" == "yes" ];then
				for i in `ls $ccr_js_file | grep -E "^js"`
				do
				{
					sed -i "s/jdNotify = false/jdNotify = true/g" $ccr_js_file/$i/jd_fruit.js
					sed -i "s/jdNotify = false/jdNotify = true/g" $ccr_js_file/$i/jd_pet.js
				}&
				done

				ps_fr=$(ps -ww | grep "jd_fruit.js" | grep -v grep | wc -l)
				ps_pet=$(ps -ww | grep "jd_pet.js" | grep -v grep | wc -l)
				while [ $ps_fr -gt 0 ] && [ $ps_pet -gt 0 ];do
					sleep 1
					ps_fr=$(ps -ww | grep "jd_fruit.js" | grep -v grep | wc -l)
					ps_pet=$(ps -ww | grep "jd_pet.js" | grep -v grep | wc -l)
				done
			fi

			sed -i "s/jdNotify = false/jdNotify = true/g" $dir_file_js/jd_fruit.js
			sed -i "s/jdNotify = false/jdNotify = true/g" $dir_file_js/jd_pet.js

			echo -e "${green}时间大于凌晨一点开始关闭农场和萌宠通知${white}"
		;;
		esac
	fi
}
random_array() {
	#彻底完善，感谢minty大力支援
	length=$(echo $random | awk -F '[@]' '{print NF}') #获取变量长度
	quantity_num=$(expr $length + 1)

	if [ "$length" -ge "20" ];then
		echo "random_array" > /tmp/random.txt
		random_num=$(python3 $dir_file/jd_random.py $quantity_num,$length  | sed "s/,/\n/g")
		for i in `echo $random_num`
		do
			echo $random | awk -va=$i -F '[@]' '{print $a}'  >>/tmp/random.txt
		done

		random_set=$(cat /tmp/random.txt | sed  "/random_array/d"| sed "s/$/@/" | sed ':t;N;s/\n//;b t' |sed 's/.$//g')
	else
		random_set="$random"
	fi
}

time() {
	if [ $script_read == "0" ];then
		echo ""
		echo -e  "${green}你是第一次使用脚本，请好好阅读以上脚本说明${white}"
		echo ""
		seconds_left=120
		while [[ ${seconds_left} -gt 0 ]]; do
			echo -ne "${green}${seconds_left}秒以后才能正常使用脚本，不要想结束我。我无处不在。。。${white}"
			sleep 1
			seconds_left=$(($seconds_left - 1))
			echo -ne "\r"
		done
		echo -e "${green}恭喜你阅读完成，祝玩的愉快，我也不想搞这波，但太多小白不愿意看说明然后一大堆问题，请你也体谅一下${white}"
		echo "我已经阅读脚本说明" > $dir_file/script_read.txt
		exit 0
	fi
}

npm_install() {
	echo -e "${green} 开始安装npm模块${white}"
	#安装js模块
	cd $openwrt_script
	npm install -g npm@8.3.0
	npm install got@11.5.1 -g
	npm install -g audit crypto crypto-js date-fns dotenv download fs http js-base64 jsdom md5 png-js request requests set-cookie-parser stream tough-cookie ts-md5 vm zlib iconv-lite qrcode-terminal ws express@4.17.1 body-parser@1.19.2
	npm install --save axios

	#安装python模块
	python_install
	echo ""
}

python_install() {
	echo -e "${green} 开始安装python模块${white}"
	python3 $dir_file/get-pip.py
	pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple jieba requests rsa
	echo -e "${green}命令执行完成，如果一直报错我建议你重置系统或者重新编译重新刷${white}"
}

system_variable() {

	if [[ ! -d "$dir_file/config/tmp" ]]; then
		mkdir -p $dir_file/config/tmp
	fi
	
	if [[ ! -d "$dir_file/js" ]]; then
		mkdir  $dir_file/js
	fi

	if [[ ! -d "/tmp/jd_tmp" ]]; then
		mkdir  /tmp/jd_tmp
	fi

	if [ "$dir_file" == "$openwrt_script/JD_Script" ];then
		#jdCookie.js
		if [ ! -f "$openwrt_script_config/jdCookie.js" ]; then
			cp  $dir_file/JSON/jdCookie.js  $openwrt_script_config/jdCookie.js
			rm -rf $dir_file_js/jdCookie.js #用于删除旧的链接
			ln -s $openwrt_script_config/jdCookie.js $dir_file_js/jdCookie.js
		fi

		#jdCookie.js用于升级以后恢复链接
		if [ ! -L "$dir_file_js/jdCookie.js" ]; then
			rm -rf $dir_file_js/jdCookie.js
			ln -s $openwrt_script_config/jdCookie.js $dir_file_js/jdCookie.js
		fi

		#sendNotify.js
		if [ ! -f "$openwrt_script_config/sendNotify.js" ]; then
			cp  $dir_file/JSON/sendNotify.js $openwrt_script_config/sendNotify.js
			rm -rf $dir_file_js/sendNotify.js  #用于删除旧的链接
			ln -s $openwrt_script_config/sendNotify.js $dir_file_js/sendNotify.js
		fi

		#sendNotify.js用于升级以后恢复链接
		if [ ! -L "$dir_file_js/sendNotify.js" ]; then
			rm -rf $dir_file_js/sendNotify.js  #临时删除，解决最近不推送问题
			ln -s $openwrt_script_config/sendNotify.js $dir_file_js/sendNotify.js
		fi

		#sendNotify_ccwav.js
		if [ ! -f "$openwrt_script_config/sendNotify_ccwav.js" ]; then
			cp  $dir_file/JSON/sendNotify_ccwav.js $openwrt_script_config/sendNotify_ccwav.js
			rm -rf $dir_file_js/sendNotify_ccwav.js  #用于删除旧的链接
			ln -s $openwrt_script_config/sendNotify_ccwav.js $dir_file_js/sendNotify_ccwav.js
		fi

		#sendNotify_ccwav.js用于升级以后恢复链接
		if [ ! -L "$dir_file_js/sendNotify_ccwav.js" ]; then
			rm -rf $dir_file_js/sendNotify_ccwav.js  #临时删除，解决最近不推送问题
			ln -s $openwrt_script_config/sendNotify_ccwav.js $dir_file_js/sendNotify_ccwav.js
		fi

		#CK_WxPusherUid.json
		if [ ! -f "$openwrt_script_config/CK_WxPusherUid.json" ]; then
			cp  $dir_file/JSON/CK_WxPusherUid.json $openwrt_script_config/CK_WxPusherUid.json
			rm -rf $dir_file_js/CK_WxPusherUid.json  #用于删除旧的链接
			ln -s $openwrt_script_config/CK_WxPusherUid.json $dir_file_js/CK_WxPusherUid.json
		fi

		#CK_WxPusherUid.json用于升级以后恢复链接
		if [ ! -L "$dir_file_js/CK_WxPusherUid.json" ]; then
			rm -rf $dir_file_js/CK_WxPusherUid.json  #临时删除，解决最近不推送问题
			ln -s $openwrt_script_config/CK_WxPusherUid.json $dir_file_js/CK_WxPusherUid.json
		fi

		#ql.js
		if [ ! -f "$openwrt_script_config/ql.js" ]; then
			cp  $dir_file/JSON/ql.js $openwrt_script_config/ql.js
			rm -rf $dir_file_js/ql.js  #用于删除旧的链接
			ln -s $openwrt_script_config/ql.js $dir_file_js/ql.js
		fi

		#ql.js用于升级以后恢复链接
		if [ ! -L "$dir_file_js/ql.js" ]; then
			rm -rf $dir_file_js/ql.js  #临时删除，解决最近不推送问题
			ln -s $openwrt_script_config/ql.js $dir_file_js/ql.js
		fi

		#USER_AGENTS.js
		if [ ! -f "$openwrt_script_config/USER_AGENTS.js" ]; then
			cp  $dir_file/git_clone/lxk0301_back/USER_AGENTS.js $openwrt_script_config/USER_AGENTS.js
			rm -rf $dir_file_js/USER_AGENTS.js #用于删除旧的链接
			ln -s $openwrt_script_config/USER_AGENTS.js $dir_file_js/USER_AGENTS.js
		fi

		#USER_AGENTS.js用于升级以后恢复链接
		if [ ! -L "$dir_file_js/USER_AGENTS.js" ]; then
			rm -rf $dir_file_js/USER_AGENTS.js
			ln -s $openwrt_script_config/USER_AGENTS.js $dir_file_js/USER_AGENTS.js
		fi

		#JS_USER_AGENTS.js
		if [ ! -f "$openwrt_script_config/JS_USER_AGENTS.js" ]; then
			cp  $dir_file/git_clone/lxk0301_back/JS_USER_AGENTS.js $openwrt_script_config/JS_USER_AGENTS.js
			rm -rf $dir_file_js/JS_USER_AGENTS.js #用于删除旧的链接
			ln -s $openwrt_script_config/JS_USER_AGENTS.js $dir_file_js/JS_USER_AGENTS.js
		fi

		#JS_USER_AGENTS.js用于升级以后恢复链接
		if [ ! -L "$dir_file_js/JS_USER_AGENTS.js" ]; then
			rm -rf $dir_file_js/JS_USER_AGENTS.js
			ln -s $openwrt_script_config/JS_USER_AGENTS.js $dir_file_js/JS_USER_AGENTS.js
		fi
	fi

	#添加系统变量
	jd_script_path=$(cat /etc/profile | grep -o jd.sh | wc -l)
	if [[ "$jd_script_path" == "0" ]]; then
		echo "export jd_file=$dir_file" >> /etc/profile
		echo "export jd=$dir_file/jd.sh" >> /etc/profile
		source /etc/profile
	fi

	jd_openwrt_config

	index_js
	#index_num="${yellow} 8.网页获取CK功能已关闭，没人修暂时就这样了${white}"

	#农场萌宠关闭通知
	close_notification

	#删除并发的文件
	del_if
}

index_js() {
#后台默认运行index.js
	openwrt_ip=$(ubus call network.interface.lan status | grep address  | grep -oE '([0-9]{1,3}.){3}[0-9]{1,3}')
	index_if=$(ps -ww | grep "index.js" | grep -v grep | wc -l)
	if [ $index_if == "1" ];then
		index_num="${yellow} 8.网页获取CK功能已启动，网页输入${green}$openwrt_ip:6789${white}${yellow},就可以访问了${white}"
	else
		echo -e "${green}启动网页获取CK功能${white}"
		node $dir_file/jd_sms_login/index.js &
		if [ $? -eq 0 ]; then
			index_num="${yellow} 8.网页获取CK功能已启动，网页输入${green}$openwrt_ip:6789${white}${yellow},就可以访问了${white}"
		else
			index_num="${yellow} 8.网页获取CK功能启动失败，请手动执行看下问题　node $dir_file/cookies_web/index.js${white}"
		fi
	fi
}

kill_index() {
	index_if=$(ps -ww | grep "index.js" | grep -v grep | awk '{print $1}')
	for i in `echo $index_if`
	do
		echo "终止网页获取CK功能，重新执行sh \$jd 就可以恢复"
		kill -9 $i
	done
}


ss_if() {
	if [ -f /etc/config/shadowsocksr ];then
		ss_server=$(grep "option global_server 'nil'" /etc/config/shadowsocksr | wc -l)
		echo -e "${green}开启检测github是否联通，请稍等。。${white}"
		if [ $ss_server == "0" ];then
			wget -t 1 -T 20 https://raw.githubusercontent.com/xdhgsq/xdh/main/README.md -O /tmp/test_README.md
			if [[ $? -eq 0 ]]; then
				echo "github正常访问，不做任何操作"
			else
				ss_pid=$(ps -ww | grep "ssrplus" | grep -v grep | awk '{print $1}')
				if [ $ss_pid == "2" ];then
					echo "后台有ss进程，不做处理"
				else
					echo "无法ping通Github,重新加载ss进程"
					/etc/init.d/shadowsocksr stop
					/etc/init.d/shadowsocksr start
					echo "重启进程完成"
					wget -t 1 -T 20 https://raw.githubusercontent.com/xdhgsq/xdh/main/README.md -O /tmp/test_README.md
					if [[ $? -eq 0 ]]; then
						echo -e "${green} github正常访问，不做任何操作${white}"
					else
						echo "检测到ss服务器故障"
						log_sort=$(echo "检测到ss故障，已经为你重启进程一次，但问题依旧，请手动检查，请尽快处理防止无法愉快跑脚本" |sed "s/$/$wrap$wrap_tab/" | sed ':t;N;s/\n//;b t' | sed "s/$wrap_tab####/####/g")
						server_content=$(echo "${log_sort}${by}" | sed "s/$wrap_tab####/####/g" )

						weixin_content_sort=$(echo  $log_sort |sed "s/####/<b>/g"   |sed "s/$line/<hr\/><\/b>/g" |sed "s/$wrap/<br>/g" |sed "s/<br>#//g"  | sed "s/$/<br>/" |sed "s/<hr\/><\/b><br>/<hr\/><\/b>/g" |sed "s/+/ /g"| sed "s/<br> <br>/<br>/g"|  sed ':t;N;s/\n//;b t' )
						weixin_content=$(echo "$weixin_content_sort<br><b>$by")
						weixin_desp=$(echo "$weixin_content" | sed "s/<hr\/><\/b><b>/$weixin_line\n/g" |sed "s/<hr\/><\/b>/\n$weixin_line\n/g"| sed "s/<b>/\n/g"| sed "s/<br>/\n/g" | sed "s/<br><br>/\n/g" | sed "s/#/\n/g" )
						title="检测到ss服务器故障"
						push_menu
						echo -e "$red JD_Script 检测到ss故障，已经为你重启进程一次，但问题依旧，请手动检查${white}"
						exit 0
					fi
				fi
			fi
		else
			wget -t 1 -T 20 https://raw.githubusercontent.com/xdhgsq/xdh/main/README.md -O /tmp/test_README.md
			if [[ $? -eq 0 ]]; then
				echo "github正常访问，不做任何操作"
			else
				echo "检测到ss没有选择服务器，发送通知"
				log_sort=$(echo "检测到ss没有选择服务器.无法联通网络，请尽快处理防止无法愉快跑脚本" |sed "s/$/$wrap$wrap_tab/" | sed ':t;N;s/\n//;b t' | sed "s/$wrap_tab####/####/g")
				server_content=$(echo "${log_sort}${by}" | sed "s/$wrap_tab####/####/g" )

				weixin_content_sort=$(echo  $log_sort |sed "s/####/<b>/g"   |sed "s/$line/<hr\/><\/b>/g" |sed "s/$wrap/<br>/g" |sed "s/<br>#//g"  | sed "s/$/<br>/" |sed "s/<hr\/><\/b><br>/<hr\/><\/b>/g" |sed "s/+/ /g"| sed "s/<br> <br>/<br>/g"|  sed ':t;N;s/\n//;b t' )
				weixin_content=$(echo "$weixin_content_sort<br><b>$by")
				weixin_desp=$(echo "$weixin_content" | sed "s/<hr\/><\/b><b>/$weixin_line\n/g" |sed "s/<hr\/><\/b>/\n$weixin_line\n/g"| sed "s/<b>/\n/g"| sed "s/<br>/\n/g" | sed "s/<br><br>/\n/g" | sed "s/#/\n/g" )
				title="检测到你的ss服务器没有启动"
				push_menu
				echo -e "$red JD_Script 检测到你的ss服务器没有启动,暂时不更新脚本${white}"
				exit 0
			fi
		fi
	else
		echo "在/etc/config没有找到shadowsocksr文件，不做任何操作"
	fi
}

jd_openwrt_config() {
	jd_openwrt_config_version="1.8"
	if [ "$dir_file" == "$openwrt_script/JD_Script" ];then
		jd_openwrt_config="$openwrt_script_config/jd_openwrt_script_config.txt"
		if [ ! -f "$jd_openwrt_config" ]; then
			jd_openwrt_config_description
		fi
		#jd_openwrt_script_config用于升级以后恢复链接
		if [ ! -L "$dir_file/config/jd_openwrt_script_config.txt" ]; then
			rm rf $dir_file/config/jd_openwrt_script_config.txt
			ln -s $jd_openwrt_config $dir_file/config/jd_openwrt_script_config.txt
		fi
	fi

	if [ `grep "jd_openwrt_config $jd_openwrt_config_version" $jd_openwrt_config |wc -l` == "1"  ];then
		jd_config_version="${green} jd_config最新 ${yellow}$jd_openwrt_config${white}"
	else
		jd_config_version="$red jd_config与新版不一致，请手动更新，更新办法先备份旧的jd_openwrt_config.txt/n，删除${green} rm -rf $jd_openwrt_config${white}然后更新一下脚本,再进去重新设置一下"
	fi

	ccr_if=$(grep "concurrent" $jd_openwrt_config | awk -F "'" '{print $2}')
	jd_fruit=$(grep "jd_fruit" $jd_openwrt_config | awk -F "'" '{print $2}')
	jd_joy_reward=$(grep "jd_joy_reward" $jd_openwrt_config | awk -F "'" '{print $2}')
	jd_joy_feedPets=$(grep "jd_joy_feedPets" $jd_openwrt_config | awk -F "'" '{print $2}')
	jd_joy_steal=$(grep "jd_joy_steal" $jd_openwrt_config | awk -F "'" '{print $2}')
	jd_unsubscribe=$(grep "jd_unsubscribe" $jd_openwrt_config | awk -F "'" '{print $2}')
	push_if=$(grep "push_if" $jd_openwrt_config | awk -F "'" '{print $2}')
	weixin2=$(grep "weixin2" $jd_openwrt_config | awk -F "'" '{print $2}')
	
	#不跑东东农场
	jd_ddfruit=$(grep "jd_ddfruit" $jd_openwrt_config | awk -F "'" '{print $2}')

	#不跑东东萌宠
	jd_ddpet=$(grep "jd_ddpet" $jd_openwrt_config | awk -F "'" '{print $2}')

	#不跑宠汪汪
	jd_ddjoy=$(grep "jd_ddjoy" $jd_openwrt_config | awk -F "'" '{print $2}')

	#不跑种豆得豆
	jd_ddplan=$(grep "jd_ddplan" $jd_openwrt_config | awk -F "'" '{print $2}')

	#不跑京喜工厂
	jx_dddr=$(grep "jx_dddr" $jd_openwrt_config | awk -F "'" '{print $2}')

	#不跑京喜牧场
	jx_ddmc=$(grep "jx_ddmc" $jd_openwrt_config | awk -F "'" '{print $2}')

	#不跑京喜财富岛
	jx_ddcfd=$(grep "jx_ddcfd" $jd_openwrt_config | awk -F "'" '{print $2}')

	#脚本黑名单
	script_black=$(grep "script_black" $jd_openwrt_config | awk -F "'" '{print $2}')
	
	

	jd_sharecode_fr=$(grep "jd_sharecode_fr" $jd_openwrt_config | awk -F "'" '{print $2}')
	jd_sharecode_pet=$(grep "jd_sharecode_pet" $jd_openwrt_config | awk -F "'" '{print $2}')
	jd_sharecode_pb=$(grep "jd_sharecode_pb" $jd_openwrt_config | awk -F "'" '{print $2}')
	jd_sharecode_df=$(grep "jd_sharecode_df" $jd_openwrt_config | awk -F "'" '{print $2}')
}

jd_openwrt_config_description() {
cat > $jd_openwrt_config <<EOF
####**************jd_openwrt_config $jd_openwrt_config_version***********####

这里主要定义一些脚本的个性化操作，如果你不需要微调，那么保持默认不理他就行了

这里的参数如果你看不懂或者想知道还有没有其他参数，你可以去$dir_file_js这里找相应的js脚本看说明

修改完参数如何生效：sh \$jd update && sh \$jd

####*********************************************************************####


******************并发开关，推送与一些脚本设置*************************************
#是否启用账号并发功能（多账号考虑打开，黑了不管） yes开启 默认no
concurrent='no'

#推送方式
0.server酱和微信同时推送   1.server酱推送     2.微信推送
3.将shell模块检测推送到另外一个小程序上（举个例子，一个企业号，两个小程序，小程序1填到sendNotify.js,这样子js就会推送到哪里，小程序2填写到jd_openwrt_config这样jd.sh写的模块就会推送到小程序2）

push_if='1'

(push_if填写为3，这里就必须要填，不然无法推送，不为3,可以不填)
weixin2=''

#农场不浇水换豆 false关闭 true打开
jd_fruit='false'

#宠汪汪积分兑换500豆子，(350积分兑换20豆子，8000积分兑换500豆子要求等级16级，16000积分兑换1000京豆16级以后不能兑换)
jd_joy_reward='500'


#宠汪汪喂食(更多参数自己去看js脚本描述)
jd_joy_feedPets='80'


#宠汪汪不给好友喂食 false不喂食 true喂食
jd_joy_steal='false'

#取消店铺200个(觉得太多你可以自己调整)
jd_unsubscribe='200'

**********************************************************************************



******************----------指定一些脚本不跑和黑名单---------------*******************************

#脚本黑名单,默认空全跑，指定格式 脚本1.js@脚本2.js@脚本3.js，这样子三个脚本就不跑了，指的是所有账号都不跑这个脚本
script_black=''

#指定账号不跑东东农场，默认空全跑，指定格式1@2@3，这样子123账号就不跑了，只针对并发，支持数字指定账号或者用户名,all删除全部
jd_ddfruit=''

#指定账号不跑东东萌宠，默认空全跑，指定格式1@2@3，这样子123账号就不跑了，只针对并发，支持数字指定账号或者用户名,all删除全部
jd_ddpet=''

#指定账号不跑宠汪汪，默认空全跑，指定格式1@2@3，这样子123账号就不跑了，只针对并发，支持数字指定账号或者用户名,all删除全部
jd_ddjoy=''

#指定账号不跑种豆得豆，默认空全跑，指定格式1@2@3，这样子123账号就不跑了，只针对并发，支持数字指定账号或者用户名,all删除全部
jd_ddplan=''

#指定账号不跑京喜工厂，默认空全跑，指定格式1@2@3，这样子123账号就不跑了，只针对并发，支持数字指定账号或者用户名,all删除全部
jx_dddr=''

#指定账号不跑京喜牧场，默认空全跑，指定格式1@2@3，这样子123账号就不跑了，只针对并发，支持数字指定账号或者用户名,all删除全部
jx_ddmc=''

#指定账号不跑京喜财富岛，默认空全跑，指定格式1@2@3，这样子123账号就不跑了，只针对并发，支持数字指定账号或者用户名,all删除全部
jx_ddcfd=''

******************----------------------------------------------------****************************


*****+++++**************自定义本地助力****************+++++*****
自定义助力（优先助力这里面的，有多的助力作者）
sh \$jd jd_sharecode                   #查询京东所有助力码

#东东农场（助力码1@助力码2）
jd_sharecode_fr=''

#萌宠（助力码1@助力码2）
jd_sharecode_pet=''

#种豆（助力码1@助力码2）
jd_sharecode_pb=''

#京喜工厂（助力码1@助力码2）
jd_sharecode_df=''

*****+++++*********************************************+++++*****

+++++++++++++++++++++++++++++++京东试用参数设置++++++++++++++++++++++++++++++++++++++++++++++++++++++
#京东试用 true开启  默认false(更多详细内容请查看/usr/share/jd_openwrt_script/JD_Script/js/jd_try.js)
JD_TRY="false"

#jd_try ck变量(那几个ck要跑，用@隔开，比如jd_01@jd_02(填写ck的用户名也就是pt_pin值)，这里不填就跑所有ck)
jd_try_ck=""

#jd_try黑名单
export JD_TRY_TITLEFILTERS="腰垫@紧肤露@身体露@瑜伽裤@紧身裤@背奶包@白虾@牙膏@舍得酒@葡萄干@腊肉@足底按摩@健身@小龙虾@胶原蛋白@胶囊@洁面@防晒@控油@润霜@手机解码线@肌肉收紧@骨盆@打呼噜@跑步鞋@羊毛裤@腹部按摩器@脚垫@太阳镜@腰部按摩器@化妆镜@书房灯@台灯@吊灯@短靴@瑜伽垫@羊毛衫@甩脂机@水果@五粮股份@护膝@笔记本电池@毛毯@泡脚桶@手机转接头@电视天线@门锁@保暖棉鞋@健身板@礼券@洁面巾@茅台旗下@茅台股份@郎酒@蛋黄酥@礼盒@考题@试卷@短筒靴@双面胶@沉香@香薰@充电宝@网红零食礼盒@网红@矿泉水@热身膏@按摩膏@芝士片@莆田@男鞋@精粹水@娇兰@帝皇峰@古龙香水@保暖护膝@小凳子@真皮笔袋@牛皮笔袋@触控手写@电容笔@SD卡@电池iPhone@摄像头@康复训练器@单肩包@防火毯@应急逃生衣@硒鼓@休闲零食@电动割草机@除草剂@膝盖贴@艾灸@茶叶@青梅酒@食用油@话筒@燃油宝@燃油添加剂@洗衣液@汽车应急启动电源@背景板@摆件@创意礼盒@烧水壶@果酒@注射器@浴巾@靴子@警告牌@被芯@手电筒@潮牌@土工布@安美琪@爽肤水@健身轮@懒人鞋@抛光@文玩@包浆@机油@户外鞋@白葡萄酒@宝珠笔@签字笔@台秤@麻将机@卡片@钱码@贵州名酒@葡萄酒@四件套@平底锅@休闲潮鞋@地图@茅台镇@贵州茅台镇@养殖围栏@平光@蜡油@花架子@水龙头@沐浴露@止痒@洗衣凝珠@记事本@灯泡@休闲鞋@运动鞋@女靴@男装@修复贴@冻干@保密袋@手机屏蔽袋@拖把池@冻干粉@修颜@牛仔裤@苏打水@代餐@精华@洗发露@鸡毛掸@拖把@咖啡豆@精油@维生素@降血压@活络油@隔离网@养生茶@减肥@喷雾@正骨@枕头@925@PVC@qq名片@按摩霜@奥咖蚕精参肽片压片@白富美@白玉@棒@棒球帽@包皮@孢子@保护膜@保护套@保健@保湿乳@杯@鼻@鼻炎@壁纸@避孕@便携装@饼干@玻尿酸@不限速@不锈钢@补钙@补水@布鞋@擦杯布@产后修复@尝鲜@长袖@超薄@超长@车载充电器@成功学@虫@宠物@除臭@床垫@春节@纯棉@瓷砖@打底裤@大米@单肩包女@淡化@蛋糕@档案袋@电话@电脑椅@电商@吊带@吊坠@钓鱼@定情@抖音@抖音作品@痘印@端午节@短裤@俄语@儿童@儿童牛奶@耳钉@耳环@耳坠@防臭地漏@防晒霜@翡翠@粉底@风湿@辅导@妇女@钙片@肛门@钢化@钢化膜@钢圈@高跟鞋@高血压@隔离带@宫颈@狗@股票@挂画@挂件@冠心病@罐@国庆节@果树@和田白玉@和田玉@黑丝@狐臭@互动课@护眼仪@花洒@化妆爽肤水@化妆水@活动@激素@甲醛@尖锐@监控补光灯@僵尸粉@降敏@教程@脚气@洁面乳@睫毛@睫毛胶水@解酒@戒烟@戒指@界家居@金刚石@精华@精华水@精华液@镜片@咀嚼片@卷尺@开发@看房@看房游@抗皱@克尤@刻字@课@口@口臭咀嚼片@口腔@口罩@快手@垃圾@垃圾桶@懒人支架@老太太@类纸膜@灵芝@领带@流量@流量卡@六级@旅游@玛瑙@猫@帽@眉@美白@美容仪@美少女@门把手@门票@糜烂@棉签@面膜@面霜@膜@墨水@奶粉@男用喷剂@内裤@尿不湿@女纯棉@女孩@女内裤@女内衣@女士上衣@女鞋@女性内裤@女性内衣@女友@女装@泡沫@疱疹@培训@盆栽@皮带@皮带扣@皮鞋@屏风底座@菩提@旗袍@亲子@轻奢@情人节@祛斑@祛痘@驱蚊@去黑头@染色@日租@肉苁蓉@乳霜@软件@腮红@三角短裤@三角裤@杀@少妇@少女@少女内衣@伸缩带@生殖器@施华洛世奇@湿疣@实战@手表@手抄报@手环@手机壳@手机膜@手机套@手机支架@手链@手套@手镯@树脂@刷头@水管@水晶@睡袍@睡衣@四级@四角短裤@四六级@素@随身wifi@损伤膏@太阳能@糖果@糖尿病@题库@体验装@贴膜@贴纸@铁@通话@童鞋@童装@褪黑素@娃娃@袜@袜子@袜子一双@外套@网课@网络@网络课程@网校@卫生巾@卫生条@卫衣@文胸@卧室灯@西服@西装@洗面@系统@癣@项链@小白鞋@小红书@小靓美@小胸@鞋拔@卸妆@卸妆水@心动@性感@胸部按摩@胸罩@休闲裤@Ｔ恤@玄关画@鸭舌帽@牙刷头@延时湿巾@演唱会@眼@眼镜@眼影@洋娃娃@羊脂白玉@羊脂玉@腰带@药@一次性@一米线栏杆@医用@衣架@姨妈巾@益生菌@益智@阴道@阴道炎@银@印度神油@婴儿@英语@疣@幼儿@鱼@鱼饵@羽绒服@语@玉@玉石@孕妇@在线@在线网络@在线直播@早餐奶@蟑螂@照明@遮斑@遮痘@遮瑕@职称@纸尿裤@中年@中秋节@中小学@种子@咨询@滋润@钻@钻石@坐垫"

#jd_try试用白名单
JD_TRY_WHITELIST="耳机@键盘"

#jd_try最小提供数量
JD_TRY_PRICE="119"
JD_TRY_PLOG="true"
JD_TRY_MINSUPPLYNUM="0"
JD_TRY_TABID="1@2@3@4@5@6@7@8@9@10@11@12@13@14@15@16"
JD_TRY_MAXLENGTH="200"
JD_TRY_APPLYNUMFILTER="10000"
JD_TRY_TRIALPRICE="10"

#这里的变量都可以自己修改，按自己的想法来
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
EOF
}

system_variable
action1="$1"
action2="$2"
if [[ -z $action1 ]]; then
	help
else
	case "$action1" in
		run_0|run_01|run_06_18|run_10_15_20|run_02|run_03|opencard|run_08_12_16|run_07|run_030|run_020)
		concurrent_js_if
		;;
		system_variable|update|update_script|task|jx|jd_sharecode|ds_setup|checklog|that_day|stop_script|script_name|backnas|npm_install|checktool|concurrent_js_clean|if_ps|getcookie|addcookie|delcookie|check_cookie_push|python_install|concurrent_js_update|kill_index|run_jd_blueCoin|del_expired_cookie|jd_try|ss_if|zcbh|jd_time|run_jsqd|Tjs|test)
		$action1
		;;
		kill_ccr)
			action="run_"
			kill_ccr
		;;
		*)
		help
		;;
	esac

	if [[ -z $action2 ]]; then
		echo ""
	else
		case "$action2" in
		run_0|run_01|run_06_18|run_10_15_20|run_02|run_03|opencard|run_08_12_16|run_07|run_030|run_020)
		concurrent_js_if
		;;
		system_variable|update|update_script|task|jx|jd_sharecode|ds_setup|checklog|that_day|stop_script|script_name|backnas|npm_install|checktool|concurrent_js_clean|if_ps|getcookie|addcookie|delcookie|check_cookie_push|python_install|concurrent_js_update|kill_index|run_jd_blueCoin|del_expired_cookie|jd_try|ss_if|zcbh|jd_time|run_jsqd|Tjs|test)
		$action2
		;;
		kill_ccr)
			action="run_"
			kill_ccr
		;;
		*)
		help
		;;
	esac
	fi
fi
