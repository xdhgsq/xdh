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
    [ $Source != /*  ] && Source="$dir_file/$Source"
done
dir_file="$( cd -P "$( dirname "$Source"  )" && pwd  )"
dir_file_js="$dir_file/js"

openwrt_script="/usr/share/jd_openwrt_script"
openwrt_script_config="/usr/share/jd_openwrt_script/script_config"


ccr_js_file="$dir_file/ccr_js"
run_sleep=$(sleep 1)

version="2.3"
node="/usr/bin/node"
tsnode="/usr/bin/ts-node"
python3="/usr/bin/python3"
bash="/usr/bin/bash"
uname_version=$(uname -a | awk -v i="+" '{print $1i $2i $3}')

if [ -z $uname_if ];then
	uname_if=$(cat /etc/profile | grep -o Ubuntu |sort -u)
fi

if [ "$uname_if" = "Ubuntu" ];then
	echo "当前环境为ubuntu"
	cron_file="/etc/cron.d/jd-cron"
	NODE_PATH="NODE_PATH=/usr/share/jd_openwrt_script/script_config/node_modules"
	cron_user="root export uname_if="Ubuntu" &&"
	echo_num=""
else
	cron_user=""
	cron_file="/etc/crontabs/root"
	sys_model=$(cat /tmp/sysinfo/model | awk -v i="+" '{print $1i$2i$3i$4}')
	wan_ip=$(cat /etc/config/network | grep "wan" | wc -l)
	echo_num="-e"
	if [ ! $wan_ip ];then
		wan_ip="找不到Wan IP"
	else
		wan_ip=$(ubus call network.interface.wan status | grep \"address\" | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
	fi

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

if [ "$dir_file" = "/usr/share/jd_openwrt_script/JD_Script" ];then
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

export JD_JOY_REWARD_NAME="500"

#开卡变量
export guaopencard_All="true"
export guaopencard_addSku_All="true"
export guaopencardRun_All="true"
export guaopencard_draw="true"

#资产变化，不推送以下内容变化
export BEANCHANGE_DISABLELIST="汪汪乐园&金融养猪＆喜豆查询"

#农场开启存水模式
export DO_TEN_WATER_AGAIN="false"

task() {
	cron_version="4.46"
	if [ `grep -o "JD_Script的定时任务$cron_version" $cron_file |wc -l` = "0" ]; then
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
sed -i '/jd_fruit_help.js/d' $cron_file >/dev/null 2>&1
sed -i '/jd_try/d' $cron_file >/dev/null 2>&1
cat >>$cron_file <<EOF
#**********这里是JD_Script的定时任务$cron_version版本#100#**********#
0 0,6 * * * $cron_user $dir_file/jd.sh run_0  >/tmp/jd_run_0.log 2>&1 #0点0分执行全部脚本#100#
0 8 * * * $cron_user $node $dir_file_js/jd_bean_info.js  >>/tmp/jd_tmp/jd.txt	#京豆详情统计#100#
0 20 6 * * $cron_user $node $dir_file_js/jd_new_vote.js  >>/tmp/jd_tmp/jd.txt	#新奇投票#100#
0 19 * * * $cron_user $node $dir_file_js/jd_y1y.js >>/tmp/jd_tmp/jd.txt #摇一摇#100#
#15 8,10,12,14,16,18,20 * * * $cron_user $node $dir_file_js/jd_daycj.js >>/tmp/jd_tmp/jd.txt		#外卖整点抽#100#
0 */8 * * * $cron_user $node $dir_file_js/jd_baglx.js >>/tmp/jd_tmp/jd.txt	#红树林养育8小时执行一次#100#
0 */2 * * * $cron_user $node $dir_file_js/jd_kd_fruit.js >>/tmp/jd_tmp/jd.txt			#快递种树两个小时执行一次#100#
0 12,18 * * * $cron_user $node $dir_file_js/jd_fruit_new.js >>/tmp/jd_tmp/jd.txt #新农场，6-9点 11-14点 17-21点可以领水滴#100#
0 3-23/1 * * * $cron_user $node $dir_file_js/jd_plantBean.js >>/tmp/jd_tmp/jd.txt		#种豆得豆任务#100#
0 20 * * * $cron_user $node $dir_file_js/jd_cjzzj.js >>/tmp/jd_tmp/jd.txt		#超级抓抓机 每晚8点开放兑换，100币兑10豆，200币兑20豆#100#
50 23 * * * $cron_user $dir_file/jd.sh kill_ccr #杀掉所有并发进程，为零点准备#100#
46 23 * * * $cron_user rm -rf /tmp/*.log #删掉所有log文件，为零点准备#100#
20 22 * * * $cron_user $dir_file/jd.sh update_script that_day >/tmp/jd_update_script.log 2>&1 #22点20更新JD_Script脚本#100#
###########100##########请将其他定时任务放到底下###############
#**********这里是backnas定时任务#100#******************************#
#45 12,19 * * * $cron_user $dir_file/jd.sh backnas  >/tmp/jd_backnas.log 2>&1 #12点，19点备份一次script,如果没有填写参数不会运行#100#
############100###########请将其他定时任务放到底下###############
EOF

	/etc/init.d/cron restart
	cron_help="${yellow}定时任务更新完成，记得看下你的定时任务${white}"
}

task_delete() {
        sed -i '/#100#/d' $cron_file >/dev/null 2>&1
}

ds_setup() {
	echo "JD_Script删除定时任务设置"
	task_delete
	echo "JD_Script删除全局变量"
	sed -i '/JD_Script/d' /etc/profile >/dev/null 2>&1
	 . /etc/profile
	echo "JD_Script定时任务和全局变量删除完成，脚本彻底不会自动运行了"
}

update() {

	cat $openwrt_script_config/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | grep -v "//'" |grep -v "// '" > $openwrt_script_config/js_cookie.txt
	
	#删除js文件
	rm -rf $dir_file_js/*
	rm -rf /tmp/jd_tmp/*

	#检测库下载
	if [ ! -d $dir_file/git_clone ];then
		mkdir $dir_file/git_clone
	fi

	if [ ! -d $dir_file/git_clone/6dylan6_script ];then
		echo ""
		git clone https://github.com/6dylan6/jdpro.git $dir_file/git_clone/6dylan6_script
	else
		cd $dir_file/git_clone/6dylan6_script
		git fetch --all
		git reset --hard origin/main
		cp -r $dir_file/git_clone/6dylan6_script/* $dir_file_js
	fi
	
	if [ ! -d $dir_file/git_clone/faker2_script ];then
		echo ""
		git clone https://github.com/shufflewzc/faker2.git $dir_file/git_clone/faker2_script
	else
		cd $dir_file/git_clone/faker2_script
		git fetch --all
		git reset --hard origin/main
	fi
	
	#临时删除之前的库
	rm -rf $dir_file/git_clone/lxk0301_back
	rm -rf $dir_file/git_clone/KingRan_script

	echo $echo_num "${green} update$start_script_time ${white}"
	echo $echo_num "${green}开始下载JS脚本，请稍等${white}"
#cat script_name.txt | awk '{print length, $0}' | sort -rn | sed 's/^[0-9]\+ //'按照文件名长度降序：
#cat script_name.txt | awk '{print length, $0}' | sort -n | sed 's/^[0-9]\+ //' 按照文件名长度升序

	


#faker2_script
cat >/tmp/jd_tmp/faker2_script.txt <<EOF
	jd_quanyi_sign.js		#jd_quanyi_sign.js
	jd_by_sign.js			#捕鱼签到（需要手动进行点一下）
	jd_10dou.js			#5.31 任务10豆
	jd_day.js			#每日抽
	jd_daycj.js			#外卖整点抽
	jd_tjfb.js			#推金风暴
	jd_fish_help.js			#金融捕鱼助力
	jd_ttthb_help.js		#推推红包助力
	jd_Advent_exchange.js		#临期京豆续命
	jd_beanday.js			#天天领豆
	jd_channel_follow.js		#频道关注
	jd_channel_venue_sign.js	#频道场馆批量签到
	jd_kd_bean.js			#快递领豆
	jd_kd_fruit.js			#快递种树两个小时执行一次
	jd_market_draw.js		#超市答题抽奖
	jd_market_new.js		#超市新人奖励
	jd_market_task.js		#超市做任务赚汪贝
	jd_pro_sign.js			#频道签到
	jd_seckillViewTask.js		#秒杀浏览商品领豆
	jd_try.js			#京东试用
	jd_try_notify.js		#京东试用通知
	jd_wechat_signRedpacket.js	#京东微信签到红包
EOF

for script_name in `cat /tmp/jd_tmp/faker2_script.txt | grep -v "#.*js" | awk '{print $1}'`
do
	echo $echo_num "${yellow} copy ${green}$script_name${white}"
	cp  $dir_file/git_clone/faker2_script/$script_name  $dir_file_js/$script_name
	cp_if
done

cp -r $dir_file/git_clone/faker2_script/utils/*  $dir_file_js/utils

sleep 5

rm -rf $dir_file/config

#删掉过期脚本(后面废弃)
cat >/tmp/del_js.txt <<EOF
	jd_vipgrowth.js			#京享值任务领豆，每周一次
EOF

for script_name in `cat /tmp/del_js.txt | grep -v "#.*js" | awk '{print $1}'`
do
	rm -rf $dir_file_js/$script_name
done


	if [ $? -eq 0 ]; then
		echo $echo_num ">>${green}脚本下载完成${white}"
	else
		clear
		echo "脚本下载没有成功，重新执行代码"
		update
	fi
	chmod 755 $dir_file_js/*
	#kill_index
	#index_js
	echo "删除重复的文件"
	rm -rf $dir_file_js/*.js.*
	rm -rf $dir_file_js/*.py.*
	rm -rf $openwrt_script_config/check_cookie.txt
	additional_settings
	#恢复依赖（要在复制脚本以后，不然会被覆盖掉）
	system_variable
	concurrent_js_update
	 . /etc/profile
	echo $echo_num "${green} update$stop_script_time ${white}"
	if [ -f /tmp/jd_tmp/wget_eeror.txt ];then
		if [ ! `cat /tmp/jd_tmp/wget_eeror.txt | wc -l` = "0" ];then
			echo $echo_num "${yellow}此次下载失败的脚本有以下：${white}"
			cat /tmp/jd_tmp/wget_eeror.txt
		fi
	fi
	task #更新完全部脚本顺便检查一下计划任务是否有变
	
}

cp_if() {
	if [ $? -eq 0 ]; then
			echo  ""
	else
		echo "$script_name" >>/tmp/jd_tmp/wget_eeror.txt
	fi

}

update_if() {
	if [ $? -eq 0 ]; then
			echo  ""
	else
		num="1"
		eeror_num="1"
		while [ "${num}" -gt "0" ]; do
			wget $url/$script_name -O $dir_file_js/$script_name
			if [ $? -eq 0 ]; then
				num=$(expr $num - 1)
			else
				if [ $eeror_num -ge 3 ];then
					echo ">> ${yellow}$script_name${white}下载$eeror_num次都失败，跳过这个下载"
					num=$(expr $num - 1)
					echo "$script_name" >>/tmp/jd_tmp/wget_eeror.txt
				else
					echo  ">> ${yellow}$script_name${white}下载失败,开始尝试第$eeror_num次下载，3次下载失败就不再重试。"
					eeror_num=$(expr $eeror_num + 1)
				fi
			fi
		done
	fi
}

update_script() {
	echo $echo_num "${green} update_script$start_script_time ${white}"
	cd $dir_file
	git fetch --all
	git reset --hard origin/main
	echo $echo_num "${green} update_script$stop_script_time ${white}"
}


ccr_run() {
#农场助力
export FRUIT_HELPNUM="8" #多少个助力停止,不检测助力码已获得助力数
if [ -z "$NEWFRUITCODES" ];then
	export NEWFRUITCODES="ycXdOaS1kgvMCBcBeJ2tKaWY52FrSwgjLg" #可指定助力码，多个用&分割，不指定则自动搜寻日志或缓存的助力码
else
	export NEWFRUITCODES="ycXdOaS1kgvMCBcBeJ2tKaWY52FrSwgjLg&${NEWFRUITCODES}" #可指定助力码，多个用&分割，不指定则自动搜寻日志或缓存的助力码
fi

#种豆得豆助力
if [ -z "$BEANCODES" ];then
	export BEANCODES="4npkonnsy7xi3n46rivf5vyrszud7yvj7hcdr5a" #可指定助力码，多个用&分割，不指定则自动搜寻日志或缓存的助力码
else
	export BEANCODES="4npkonnsy7xi3n46rivf5vyrszud7yvj7hcdr5a&${NEWFRUITCODES}" #可指定助力码，多个用&分割，不指定则自动搜寻日志或缓存的助力码
fi

#欢乐挖宝助力
if [ -z "$JD_FCWB_InviterId" ];then
	export JD_FCWB_InviterId="VYlzzuDz-Y8seOROZFxje-gusZ0qMCAXkWRSg4DzCCQ&6f5661eb762741e083c729da9af9ca4911971747585491086"
else
	export JD_FCWB_InviterId="VYlzzuDz-Y8seOROZFxje-gusZ0qMCAXkWRSg4DzCCQ&6f5661eb762741e083c729da9af9ca4911971747585491086&${NEWFRUITCODES}"
fi


#端午节焕新周 粽享生活抽奖
export opencard_draw="5"
#脚本填这里不会并发
cat >/tmp/jd_tmp/ccr_run <<EOF
	jd_qy_sign.js			#权益中心签到
	jd_fs_sign.js			#签到领红包
	jd_quanyi_sign.js		#jd_quanyi_sign.js
	jd_video_task.js		#看视频赚现金-任务
	jd_video_view.js		#看视频赚现金-浏览
	jd_tjfb_help.js			#推金风暴助力
	jd_ttthb_help.js		#推推红包助力
	jd_farmnew_code_help.js		#新农场code助力
	jd_plantBean_help.js		#种豆得豆助力
	jd_10dou.js			#5.31 任务10豆
	jd_AutoEval.js			#带图评价默认不执行, 请设置变量 ONEVAL='true'
EOF
	for i in `cat /tmp/jd_tmp/ccr_run | grep -v "#.*js" | awk '{print $1}'`
	do
	{
		num=$($python3 $dir_file/jd_random.py 30,1)
		echo "$i脚本延迟$num秒以后再开始跑，请耐心等待"
		sleep $num
		$node $openwrt_script/JD_Script/js/$i
		$run_sleep
		wait
		echo $echo_num "${green} ccr_run $stop_script_time ${white}"
	}&
	done
}

run_0() {
cat >/tmp/jd_tmp/run_0 <<EOF
	jd_by_sign.js		#捕鱼签到（需要手动进行点一下）
 	jd_fdshkj.js		#每日浏览5豆
	jd_xinqi_draw.js	#新奇抽奖
	jd_sldraw.js		#SL任务抽奖合集
	jd_lmdraw.js		#LM任务抽奖合集
	jd_taskgBean.js		#做任务赚豆
	jd_day.js		#每日抽
	jd_jjg.js		#家居馆
	jd_tjfb.js		#推金风暴
	jd_tuitui_red_task.js	#推推红包每日任务
	jd_jrsign.js		#金融签到
	jd_global_task_.js	#京豆国际频道任务
	jd_yssign.js		#ys每日签到
	jd_signbeanact_.js	#领京豆签到
	jd_kjsign.js		#kj每日签到
	jd_bean_home.js		#领京豆-升级赚豆
	jd_dailysign.js		#每日签到得豆
	jd_daka_bean.js		#打卡领豆
	jd_deliverySign_sign.js	#天天领豆
	jd_fl_draw.js		#任务抽小豆
	jd_pkabeans.js		#礼品卡领豆
	jd_plantBean.js		#种豆得豆任务
	jd_red_Task.js		#每日领红包_任务
	jd_gRed.js		#每日领红包
	jd_fruit_new.js		#新农场
	jd_water_new.js		#新农场浇水
	jd_newfarmlottery.js	#新农场幸运转盘
	jd_zzhb_draw_new.js	#Jd转赚红包_抽奖
	jd_zzhb_new.js		#Jd转赚红包2
	jd_vu50.js		#V你50超市卡
	jd_sq_draw.js		#社区抽奖
	jd_msDraw.js		#秒送抽奖
	jd_luckyDraw.js		#幸运抽奖
	jd_mkt_answer.js	#超市答题抽奖
	jd_jiaju_draw.js	#0元家具_抽奖
	jd_jiaz_draw.js		#家装_抽奖
	jd_dyf_draw.js		#dyf抽奖
	jd_dplhbshop.js		#大牌浏览店铺
	jd_delLjq.js		#批量删垃圾券
	jd_bgcity.js		#集碎片点亮城市
	jd_book_draw.js 	#图书抽奖
	jd_cjzzj.js		#超级抓抓机 每晚8点开放兑换，100币兑10豆，200币兑20豆
	jd_hssign.js		#hs每日签到
	jd_health.js		#东东健康社区
	jd_health_task.js	#健康能量任务
	jd_health_collect.js	#健康社区收集能量
	jd_health_draw.js	#健康_抽奖
	jd_mk_game.js		#赚汪贝兑礼品
	jd_wbDraw.js		#汪贝刮超市卡
	jd_market_exchange.js	#超市汪贝兑好礼
	jd_joypark_task.js	#汪汪庄园任务
	jd_wwmanor_merge.js	#汪汪庄园合成
	jd_qqxing.js		#QQ星系牧场
	jd_gwfd.js		#购物返豆领取
	jx_fcwb_auto.js		#特价现金挖宝任务
	jd_video_task.js	#看视频赚现金-任务
	jd_video_view.js	#看视频赚现金-浏览
	jd_wduoyu.js		#多投多赚
	jd_wyw_check.js		#玩一玩_兑换检测
	jd_wyw_ffl_.js		#玩一玩-翻翻乐
	jd_y1y.js		#摇一摇每天19点开始
	jd_mohe.js		#plus天天盲盒
	jd_dwapp.js		#积分换话费
	jd_unsubscribe.js	#批量取消关注店铺
	jd_OnceApply.js		#一键价保
	jd_rmvcart.js		#清空购物车默认不执行清空购物车，清设置变量RMVCART='true
	jd_Advent_exchange.js		#临期京豆续命
	jd_beanday.js			#天天领豆
	jd_channel_follow.js		#频道关注
	jd_channel_venue_sign.js	#频道场馆批量签到
	jd_kd_bean.js			#快递领豆
	jd_market_draw.js		#超市答题抽奖
	jd_market_new.js		#超市新人奖励
	jd_market_task.js		#超市做任务赚汪贝
	jd_pro_sign.js			#频道签到
	jd_seckillViewTask.js		#秒杀浏览商品领豆
	jd_try.js			#京东试用
	jd_try_notify.js		#京东试用通知
	jd_wechat_signRedpacket.js	#京东微信签到红包
EOF
	echo $echo_num "${green} run_0$start_script_time ${white}"

	for i in `cat /tmp/jd_tmp/run_0 | grep -v "#.*js" | awk '{print $1}'`
	do
		num=$($python3 $dir_file/jd_random.py 30,1)
		echo "$i脚本延迟$num秒以后再开始跑，请耐心等待"
		sleep $num
		$node $dir_file_js/$i
		$run_sleep
	done
	wait
	#$node $dir_file_js/jd_bean_info.js		#京豆详细统计
	echo $echo_num "${green} run_0$stop_script_time ${white}"
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
			echo $echo_num "${green}jd_speed_sign.js后台进程一共有${yellows}${ps_speed}${green}个，${white}已满$ck_num个暂时不跑了"
			while true; do
				if [ ${num} -gt ${file_num} ];then
					echo $echo_num "${green}所有账号已经跑完了，停止脚本${white}"
					break
				else
					if [ "$ps_speed" -gt "$ck_num" ];then
						if [ ${num} -gt ${file_num} ];then
							echo $echo_num "${green}所有账号已经跑完了，停止脚本${white}"
							break
						else
							echo $echo_num "${green}开始休息60秒以后再干活${white}"
							sleep 60
						fi
					else
						echo $echo_num "${yellow}休息结束开始干活${white}"
						break
					fi
				fi
			done
		else
			echo $echo_num "${green}开始跑${yellow}js_${num}${green}文件里的jd_speed_sign.js${white}"
			$node $ccr_js_file/js_${num}/jd_speed_sign.js &
			sleep 5
			echo $echo_num "${green}jd_speed_sign.js后台进程一共有${yellows}${ps_speed}${green}个"
		fi
		num=$(($num + 1))
	done
}


script_name() {
	clear
	echo $echo_num "${green} 显示所有JS脚本名称与作用${white}"
	cat /tmp/jd_tmp/collect_script.txt
}

Tjs()	{
	#测试模块
	for i in `ls $jd_file/ccr_js/js_1 | grep  "js" |grep -v "json" | grep -Ev "sendNotify_ccwav.js|sendNotify.js|ql.js|jd_CheckCK.js|jdCookie.js|USER_AGENTS.js|JS_USER_AGENTS.js|JDJRValidator_Pure.js|jd_enen.js|jd_delCoupon.js|sign_graphics_validate.js|JDSignValidator.js|JDJRValidator_Aaron.js|jd_get_share_code.js|jd_bean_sign.js|getJDCookie.js|.*py|jdPetShareCodes.js|jdJxncShareCodes.js|jdFruitShareCodes.js|jdFactoryShareCodes.js|jdPlantBeanShareCodes.js|jdDreamFactoryShareCodes.js" | awk '{print $1}' |grep -v "#"`;do
		echo $echo_num "${green}>>>开始执行${yellow}$i${white}"
		if [ `echo "$i" | grep -o "py"| wc -l` = "1" ];then
			$python3 $jd_file/ccr_js/js_1/$i &
		else
			$node $jd_file/ccr_js/js_1/$i &
		fi
		echo $echo_num "${green}>>>${yellow}$i${green}执行完成，回车测试下一个${white}"
		read a
	done

}

jd_time()  {
TimeError=2
#copy SuperManito
 local Interface="https://api.m.jd.com/client.action?functionId=queryMaterialProducts&client=wh5"
    if [ $(echo $(($(curl -sSL "${Interface}" | awk -F '\"' '{print$8}') - $(eval echo "$(date +%s)$(date +%N | cut -c1-3)"))) | sed "s|\-||g") -lt "10" ]; then
        echo  "\n\033[32m------------ 检测到当前本地时间与京东服务器的时间差小于 10ms 因此不同步 ------------\033[0m\n"
    else
        echo  "\n❖ 同步京东服务器时间"
        echo n "\n当前设置的允许误差时间为 ${TimeError}m，脚本将在 3s 后开始运行..."
        sleep 3
        echo  ''
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
            echo  "\n京东时间戳：\033[34m${JDTimeStamp}\033[0m"
            echo  "本地时间戳：\033[34m${LocalTimeStamp}\033[0m"
            if [ ${TimeDifference} -lt ${TimeError} ]; then
                echo  "\n\033[32m------------ 同步完成 ------------\033[0m\n"
                if [ -s /etc/apt/sources.list ]; then
                    #apt-get install -y figlet toilet >/dev/null
                    local ExitStatus=$?
                else
                    local ExitStatus=1
                fi
                if [ "$ExitStatus" -eq "0" ]; then
                    echo  "$(toilet -f slant -F border --gay SuperManito)\n"
                else
                    echo  '\033[35m    _____                       __  ___            _ __       \033[0m'
                    echo  '\033[31m   / ___/__  ______  ___  _____/  |/  /___ _____  (_) /_____  \033[0m'
                    echo  '\033[33m   \__ \/ / / / __ \/ _ \/ ___/ /|_/ / __ `/ __ \/ / __/ __ \ \033[0m'
                    echo  '\033[32m  ___/ / /_/ / /_/ /  __/ /  / /  / / /_/ / / / / / /_/ /_/ / \033[0m'
                    echo  '\033[36m /____/\__,_/ .___/\___/_/  /_/  /_/\__,_/_/ /_/_/\__/\____/  \033[0m'
                    echo  '\033[34m           /_/                                                \033[0m\n'
                fi
                break
            else
                sleep 1s
                echo  "\n未达到允许误差范围设定值，继续同步..."
            fi
        done
    fi

}

concurrent_js_update() {
	if [ "$ccr_if" = "yes" ];then
		if [ ! -d "$ccr_js_file" ]; then
			mkdir  $ccr_js_file
		fi
	else
		if [ ! -d "$ccr_js_file" ]; then
			echo ""
		else
			rm -rf $ccr_js_file
		fi
	fi

	if [ "$ccr_if" = "yes" ];then
		js_amount=$(cat $openwrt_script_config/js_cookie.txt |wc -l)
		echo $echo_num "${green}>> 你有$js_amount个ck要创建并发文件夹${white}"
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
		echo $echo_num "${yellow} 耗时:${green}$result_date秒${white}"
		echo $echo_num "${green}>> 创建$js_amount个并发文件夹完成${white}"
	else
		echo $echo_num "${yellow}>> 并发开关没有打开${white}"
	fi

}

concurrent_js_clean(){
		if [ "$ccr_if" = "yes" ];then
			echo $echo_num "${yellow}收尾一下${white}"
			for i in `ps -ww | grep "$action" | grep -v 'grep\|index.js\|ssrplus\|opencard' | awk '{print $1}'`
			do
				echo "开始kill $i"
				kill -9 $i
			done
		fi
}

kill_ccr() {
	if [ "$ccr_if" = "yes" ];then
		echo $echo_num "${green}>>终止并发程序启动。请稍等。。。。${white}"
		if [ `ps -ww | grep "js$" | grep "JD_Script"| grep -v 'grep\|index.js\|ssrplus\|opencard' | awk '{print $1}' |wc -l` = "0" ];then
			sleep 2
			echo ""
			echo $echo_num "${green}我曾经跨过山和大海，也穿过人山人海。。。${white}"
			sleep 2
			echo $echo_num "${green}直到来到你这里。。。${white}"
			sleep 2
			echo $echo_num "${green}逛了一圈空空如也，你确定不是在消遣我？？？${white}"
			sleep 2
			echo $echo_num "${green}后台都没有进程妹子，散了散了。。。${white}"
		else
			for i in `ps -ww | grep "js$" | grep "JD_Script"| grep -v 'grep\|index.js\|ssrplus\|opencard' | awk '{print $1}'`
			do
				kill -9 $i
				echo "kill $i"
			done
			concurrent_js_clean
			clear
			echo $echo_num "${green}再次检测一下并发程序是否还有存在${white}"
			if [ `ps -ww | grep "js$" | grep "JD_Script"| grep -v 'grep\|index.js\|ssrplus\|opencard' | awk '{print $1}' |wc -l` = "0" ];then
				echo $echo_num "${yellow}>>并发程序已经全部结束${white}"
			else
				echo $echo_num "${yellow}！！！检测到并发程序还有存在，再继续杀，请稍等。。。${white}"
				sleep 1
				kill_ccr
			fi
		fi
	else
		echo $echo_num "${green}>>你并发开关都没有打开，我终止啥？？？${white}"
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
	echo $echo_num "${green}>> $action并发程序还有${yellow}$process_num${green}进程在后台，等待(30秒)，后再检测一下${white}"
	echo -ne "\r"
	sleep $num1

	echo ""
	if [ "$process_num" = "0" ];then
		echo $echo_num "${yellow}>>并发程序已经结束${white}"
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
		echo $echo_num "${green}>>并发文件夹为空开始下载${white}"
			update
			concurrent_js_if
	fi
}

concurrent_js_if() {
	if [ "$ccr_if" = "yes" ];then
		echo $echo_num "${green}>>检测到开启了账号并发模式${white}"
		case "$action1" in
		run_0)
			action="$action1"
			ccr_run &
			concurrent_js
		;;
		esac
	else
		case "$action1" in
			run_0)
			ccr_run &
			$action1
			;;
		esac

		if [ -z $action2 ]; then
			echo ""
		else
			case "$action2" in
			run_0)
			ccr_run &
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
		echo $echo_num  "		检测者工具第${green}$i${white}次循环输出(ctrl+c终止)"
		echo "---------------------------------------------------------------------------"
		echo "负载情况：`uptime`"
		echo ""
		echo "进程状态："
		if [ "$ps_check" = "0"  ];then
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
	echo $echo_num "${yellow} 温馨提示，如果你已经有cookie，不想扫码直接添加，可以用${green} sh \$jd addcookie${white} 增加cookie ${green} sh \$jd delcookie${white} 删除cookie"
	$node $dir_file_js/getJDCookie.js && addcookie && addcookie_wait
}

addcookie() {
	
	if [ `cat /tmp/getcookie.txt | wc -l` = "1" ];then
		clear
		you_cookie=$(cat /tmp/getcookie.txt)
		if [ -z $you_cookie ]; then
			echo $echo_num "$red cookie为空值，不做其他操作。。。${white}"
			exit 0
		else
			echo $echo_num "\n${green}已经获取到cookie，稍等。。。${white}"
			sleep 1
		fi
	else
		clear
		echo "---------------------------------------------------------------------------"
		echo $echo_num "		新增cookie或者更新cookie"
		echo "---------------------------------------------------------------------------"
		echo ""
		echo $echo_num "${yellow}单账号例子：${white}"
		echo ""
		echo  "pt_key=xxxxxx;pt_pin=jd_xxxxxx; //二狗子"
		echo ""
		echo $echo_num "${yellow}多账号例子：（用＆分割账号）${white}"
		echo ""
		echo  "pt_key=xxxxxx;pt_pin=jd_xxxxxx; //二狗子&pt_key=xxxxxx;pt_pin=jd_xxxxxx; //雪糕兄"
		echo ""
		echo $echo_num "${yellow} pt_key=${green}密码  ${yellow} pt_pin=${green} 账号  ${yellow}// 二狗子 ${green}(备注这个账号是谁的)${white}"
		echo ""
		echo $echo_num "${yellow} 请不要乱输，如果输错了可以用${green} sh \$jd delcookie${yellow}删除,\n 或者你手动去${green}$openwrt_script_config/jdCookie.js${yellow}删除也行\n${white}"
		echo "---------------------------------------------------------------------------"
		read -p "请填写你获取到的cookie(一次只能一个cookie,多个cookie要用＆连接起来)：" you_cookie
		if [ -z $you_cookie ]; then
			echo $echo_num "$red请不要输入空值。。。${white}"
			exit 0
		fi

	fi
	echo "$you_cookie" > /tmp/you_cookie.txt
	sed -i "s/&/\n/g" /tmp/you_cookie.txt
	echo $echo_num "${yellow}\n开始为你查找是否存在这个cookie，有就更新，没有就新增。。。${white}\n"
	sleep 2
	if_you_cookie=$(cat /tmp/you_cookie.txt | wc -l)
	if [ $if_you_cookie = "1" ];then
		you_cookie=$(cat /tmp/you_cookie.txt)
		new_pt=$(echo $you_cookie)
		pt_pin=$(echo $you_cookie | awk -F "pt_pin=" '{print $2}' | awk -F ";" '{print $1}')
		pt_key=$(echo $you_cookie | awk -F "pt_key=" '{print $2}' | awk -F ";" '{print $1}')
		you_remark=$(echo $you_cookie | awk -F "\/\/" '{print $2}')
		if [ `echo "$pt_pin" | wc -l` = "1"  ] && [ `echo "$pt_key" | wc -l` = "1" ];then
			addcookie_replace
		else
			echo "$pt_pin $pt_key　$you_remark $red异常${white}"
			sleep 2
		fi
	else
		num="1"
		while [ $if_you_cookie -ge $num ];do
			clear
			echo $echo_num "------------------------------------------------------------------------------"
			echo $echo_num "你一共输入了${yellow}$if_you_cookie${white}条cookie现在开始替换第${green}$num${white}条cookie"
			you_cookie=$(sed -n "$num p" /tmp/you_cookie.txt)
			new_pt=$(echo $you_cookie)
			pt_pin=$(echo $you_cookie | awk -F "pt_pin=" '{print $2}' | awk -F ";" '{print $1}')
			pt_key=$(echo $you_cookie | awk -F "pt_key=" '{print $2}' | awk -F ";" '{print $1}')
			you_remark=$(echo $you_cookie | awk -F "\/\/" '{print $2}')

			if [ `echo "$pt_pin" | wc -l` = "1"  ] && [ `echo "$pt_key" | wc -l` = "1" ];then
				addcookie_replace
				sleep 2
			else
				echo $echo_num "$pt_pin $pt_key $you_remark　$red异常${white}"
				sleep 2
			fi
			num=$(( $num + 1))
		done

	fi
	del_expired_cookie

	if [ `cat /tmp/getcookie.txt  | wc -l` = "1"  ];then
		echo ""
		rm -rf /tmp/getcookie.txt
	else
		rm -rf /tmp/getcookie.txt
		addcookie_wait
	fi

	
}

addcookie_replace(){
	if [ `cat $openwrt_script_config/jdCookie.js | grep "$pt_pin;" | wc -l` = "1" ];then
		echo $echo_num "${green}检测到 ${yellow}${pt_pin}${white} 已经存在，开始更新cookie。。${white}\n"
		sleep 2
		old_pt=$(cat $openwrt_script_config/jdCookie.js | grep "$pt_pin" | sed -e "s/',//g" -e "s/'//g")
		old_pt_key=$(cat $openwrt_script_config/jdCookie.js | grep "$pt_pin" | awk -F "pt_key=" '{print $2}' | awk -F ";" '{print $1}')
		sed -i "s/$old_pt_key/$pt_key/g" $openwrt_script_config/jdCookie.js
		echo $echo_num "${green} 旧cookie：${yellow}${old_pt}${white}\n\n${green}更新为${white}\n\n${green}   新cookie：${yellow}${new_pt}${white}\n"
		echo $echo_num "------------------------------------------------------------------------------"
	else
		echo $echo_num "${green}检测到 ${yellow}${pt_pin}${white} 不存在，开始新增cookie。。${white}\n"
		sleep 2
		cookie_quantity=$( cat $openwrt_script_config/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | wc -l)
		i=$(expr $cookie_quantity + 5)
		if [ $i = "5" ];then
			sed -i "5a \  'pt_key=${pt_key};pt_pin=${pt_pin};\', \/\/$you_remark" $openwrt_script_config/jdCookie.js
		else
			sed -i "$i a\  'pt_key=${pt_key};pt_pin=${pt_pin};\', \/\/$you_remark" $openwrt_script_config/jdCookie.js
		fi
		echo $echo_num "\n已将新cookie：${green}${you_cookie}${white}\n\n插入到${yellow}$openwrt_script_config/jdCookie.js${white} 第$i行\n"
		cookie_quantity1=$( cat $openwrt_script_config/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | wc -l)
		echo  "------------------------------------------------------------------------------"
		echo $echo_num "${yellow}你增加了账号：${green}${pt_pin}${white}${yellow} 现在cookie一共有$cookie_quantity1个，具体以下：${white}"
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
	if [ "$cookie_continue" = "1" ];then
		echo "请稍等。。。"
		sleep 1
		clear
		addcookie
	elif [ "$cookie_continue" = "2" ];then
		echo "退出脚本。。。"
		exit 0
	else
		echo "请不要乱输，退出脚本。。。"
		exit 0
	fi

}

del_expired_cookie() {
	echo $echo_num "${green}整理一下check_cookie.txt,删掉一些过期的信息${white}"
	for i in `cat $openwrt_script_config/check_cookie.txt | awk '{print $1}'| grep -v "Cookie"`
	do
		jd_cookie=$(grep "$i" $openwrt_script_config/jdCookie.js | awk -F "pt_pin=" '{print $2}' | awk -F ";" '{print $1}' | sed '/^\s*$/d' | grep -v "(.+?)")
		if [ ! $jd_cookie ];then
			#echo  "$red$i${white}在$openwrt_script_config/jdCookie.js找不到"
			echo "" >/dev/null 2>&1
		else
			if [ "$jd_cookie" = "$i" ];then
				#echo  "${green}$i${white}在$openwrt_script_config/jdCookie.js正常存在"
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
		echo  "		删除cookie"
		echo "---------------------------------------------------------------------------"
		echo $echo_num "${green}例子：${white}"
		echo ""
		echo $echo_num "${green} pt_key=jd_10086jd_10086jd_10086jd_10086jd_10086jd_10086jd_10086;pt_pin=jd_10086; //二狗子${white}"
		echo ""
		echo $echo_num "${yellow} 请填写你要删除的cookie（// 备注 或者pt_pin 名都行）：${green}二狗子 ${white}"
		echo $echo_num "${yellow} 请填写你要删除的cookie（// 备注 或者pt_pin 名都行）：${green} jd_10086${white} "
		echo "---------------------------------------------------------------------------"
		echo $echo_num "${yellow}你的cookie有$cookie_quantity个，具体如下：${white}"
		cat $openwrt_script_config/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | sed -e "s/',//g" -e "s/'//g"
		echo "---------------------------------------------------------------------------"
		echo ""
		read -p "请填写你要删除的cookie（// 备注 或者pt_pin 名都行）：" you_cookie
		if [ -z $you_cookie ]; then
			echo $echo_num "$red请不要输入空值。。。${white}"
			exit 0
		fi
	
		sed -i "/$you_cookie/d" $openwrt_script_config/jdCookie.js
		clear
		echo "---------------------------------------------------------------------------"
		echo $echo_num "${yellow}你删除账号或者备注：${green}${you_cookie}${white}${yellow} 现在cookie还有`cat $openwrt_script_config/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | wc -l`个，具体以下：${white}"
		cat $openwrt_script_config/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | sed -e "s/',//g" -e "s/'//g"
		echo "---------------------------------------------------------------------------"
		echo ""
		read -p "是否需要删除cookie（1.需要  2.不需要 ）：" cookie_continue
		if [ "$cookie_continue" = "1" ];then
			echo "请稍等。。。"
			delcookie
		elif [ "$cookie_continue" = "2" ];then
			echo "退出脚本。。。"
			exit 0
		else
			echo "请不要乱输，退出脚本。。。"
			exit 0
		fi
	else
		echo $echo_num "${yellow}你的cookie空空如也，比地板都干净，你想删啥。。。。。${white}"
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
	if [ "$Current_date_m" = "12"  ];then
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
			echo $echo_num "${green} jd_openwrt_script_config.txt${white}的${yellow} push_if参数${white}$red填写错误，不进行推送${white}"
		;;
	esac

}

server_push() {

if [ ! $SCKEY ];then
	echo "没找到Server酱key不做操作"
else
	echo $echo_num "${green} server酱开始推送$title${white}"
	curl -s "http://sc.ftqq.com/$SCKEY.send?text=$title++`date +%Y-%m-%d`++`date +%H:%M`" -d "&desp=$server_content" >/dev/null 2>&1

	if [ "$?" -eq "0" ]; then
		echo $echo_num "${green} server酱推送完成${white}"
	else
		echo $echo_num "$red server酱推送失败。请检查报错代码$title${white}"
	fi
fi

}

weixin_push() {
current_time=$(date +%s)
expireTime="7200"
if [ $push_if = "3" ];then
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
	echo $echo_num "${green} 企业微信开始推送$title${white}"
	curl -s "https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=$access_token" -d "$msg_body"

	if [ $? -eq "0" ]; then
		echo $echo_num "${green} 企业微信推送成功$title${white}"
	else
		echo $echo_num "$red 企业微信推送失败。请检查报错代码$title${white}"
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
	echo  "$line#### Model：$sys_model\n#### Wan+IP地址：+$wan_ip\n#### 系统版本:++$uname_version\n$line" >>$log3
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
		echo $echo_num "${green} log日志没有发现错误，一切风平浪静${white}"
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
	if [ $? -eq 0 ]; then
		cd $dir_file
		git fetch
		if [ $? -eq "0" ]; then
			echo ""
		else
			echo "请检查你的网络，github更新失败，建议科学上网"
		fi
	else
		echo "请检查你的网络，github更新失败，建议科学上网"
	fi
	clear
	git_branch=$(git branch -v | grep -o behind )
	if [ "$git_branch" = "behind" ]; then
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
		echo  "$line#### Model：$sys_model\n#### Wan+IP地址：+$wan_ip\n#### 系统版本:++$uname_version\n$line\n#### $current_time+`date +%H:%M`点+更新日志\n" >> $dir_file/git_log/${current_time}.log
		echo "  时间       +作者          +操作" >> $dir_file/git_log/${current_time}.log
		echo "$git_log" >> $dir_file/git_log/${current_time}.log
		echo "#### 当前脚本是否最新：$Script_status" >>$dir_file/git_log/${current_time}.log
	else
		echo  "$line#### Model：$sys_model\n#### Wan+IP地址：+$wan_ip\n#### 系统版本:++$uname_version\n$line\n#### $current_time+更新日志\n" >> $dir_file/git_log/${current_time}.log
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
	if [ "$dir_file" = "$openwrt_script/JD_Script" ];then
		backnas_config_file="$jd_openwrt_config"
		back_file_patch="$openwrt_script"
		if [ ! -f "$jd_openwrt_config" ]; then
			backnas_config
		fi
	else
		backnas_config_file="$jd_openwrt_config"
		back_file_patch="$dir_file"
		if [ ! -f "$jd_openwrt_config" ]; then
			backnas_config
		fi
	fi

	#判断config文件
	backnas_config_version="1.0"
	if [ `grep -o "backnas_config版本$backnas_config_version" $backnas_config_file |wc -l` = "0" ]; then
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
		echo $echo_num "${yellow} 用户名:$red    空 ${white}"
		echo "空" >/tmp/backnas_if.log
	else
		echo $echo_num "${yellow} 用户名：${green} $nas_user ${white}"
		echo "正常" >/tmp/backnas_if.log
	fi

	#判断密码
	if [ ! $nas_pass ];then
		echo $echo_num "${yellow} 密码：$red     空 ${white}"
		echo "空" >>/tmp/backnas_if.log
	else
		echo $echo_num "${yellow} 密码：${green}这是机密不显示给你看 ${white}"
		echo "正常" >>/tmp/backnas_if.log
	fi

	#判断密钥
	if [ ! $nas_secret_key ];then
		echo $echo_num "${yellow} NAS 密钥：${green} 空(可以为空)${white}"
	else
		echo $echo_num "${yellow} NAS 密钥：${green} $nas_secret_key ${white}"
		echo "正常" >>/tmp/backnas_if.log
	fi

	#判断IP
	if [ ! $nas_ip ];then
		echo $echo_num "${yellow} NAS IP:$red    空 ${white}"
		echo "空" >>/tmp/backnas_if.log
	else
		echo $echo_num "${yellow} NAS IP：${green}$nas_ip ${white}"
		echo "正常" >>/tmp/backnas_if.log
	fi

	#判断NAS文件夹
	if [ ! $nas_file ];then
		echo $echo_num "${yellow} NAS文件夹:$red 空 ${white}"
		echo "空" >>/tmp/backnas_if.log
	else
		echo $echo_num "${yellow} NAS备份目录：${green} $nas_file ${white}"
		echo "正常" >>/tmp/backnas_if.log
	fi

	#判断端口
	if [ ! $nas_prot ];then
		echo $echo_num "${yellow} NAS 端口:$red   空 ${white}"
	else
		echo $echo_num "${yellow} NAS 端口：${green} $nas_prot ${white}"
	fi

	echo $echo_num "${yellow} 使用协议：${green} SCP${white}"
	echo ""
	echo $echo_num "${yellow} 参数填写${green}$backnas_config_file${white}"
	echo "#########################################"

	back_if=$(cat /tmp/backnas_if.log | sort -u )
	if [ $back_if = "空" ];then
		echo ""
		echo $echo_num "$red重要参数为空 不执行备份操作，需要备份的，把参数填好,${white}填好以后运行${green} sh \$jd backnas ${white}测试一下是否正常${white}"
		exit 0
	fi

	echo $echo_num "${green}>> 开始备份到nas${white}"
	sleep 5

	echo $echo_num "${green}>> 打包前处理，删除ccr_js文件"
	rm -rf $back_file_patch/JD_Script/ccr_js/*
	echo $echo_num "${green}>> 删除完成${white}"
	sleep 5

	echo $echo_num "${green}>> 复制/etc/profile到$back_file_patch/profile${white}"
	cp /etc/profile $back_file_patch/profile
	echo "复制完成"
	sleep 5

	echo $echo_num "${green}>> 开始打包文件${white}"
	tar -zcvf /tmp/$back_file_name $back_file_patch

	#解压命令 tar -zxvf script_2023-06-01-19_45.tar.gz -C /
	sleep 5

	clear
	echo $echo_num "${green}>> 开始上传文件 ${white}"
	echo $echo_num "${yellow}注意事项: 首次连接NAS的ssh会遇见${green} Do you want to continue connecting?${white}然后你输入y卡住不动"
	echo $echo_num "${yellow}解决办法:ctrl+c ，然后${green} ssh -p $nas_prot $nas_user@$nas_ip ${white}连接成功以后输${green} logout${white}退出NAS，重新执行${green} sh \$jd backnas${white}"
	echo ""
	echo $echo_num "${green}>> 上传文件中，请稍等。。。。 ${white}"

	if [ ! $nas_secret_key ];then
		if [ ! $nas_pass ];then
			echo $echo_num "$red 密码：为空 ${white}参数填写${green}$backnas_config_file${white}"
			read a
			backnas
		else
			sshpass -p "$nas_pass" scp -P $nas_prot -r /tmp/$back_file_name $nas_user@$nas_ip:$nas_file
		fi
	else
		scp -P $nas_prot -i $nas_secret_key -O /tmp/$back_file_name $nas_user@$nas_ip:$nas_file
	fi

	if [ $? -eq 0 ]; then
		sleep 5
		echo $echo_num "${green}>> 上传文件完成 ${white}"
		echo ""
		echo "#############################################################################"
		echo ""
		echo $echo_num "${green} $date_time将$back_file_name上传到$nas_ip 的$nas_file目录${white}"
		echo ""
		echo "#############################################################################"
	else
		echo $echo_num "$red>> 上传文件失败，请检查你的参数是否正确${white}"
	fi
	echo ""
	echo $echo_num "${green}>> 清理tmp文件 ${white}"
	rm -rf /tmp/*.tar.gz
	sleep 5

	echo $echo_num "${green}>> 开始更新脚本并恢复并发文件夹${white}"
	update
	echo $echo_num "${green}>> 脚本更新完成${white}"
}

start_script() {
	echo $echo_num "${green} 开始回复定时任务${white}"
	wskey
	help
}

stop_script() {
	echo $echo_num "${green} 删掉定时任务，这样就不会定时运行脚本了${white}"
	task_delete
	sed -i '/#120#/d' $cron_file >/dev/null 2>&1
	sleep 3
	killall -9 node 
	echo $echo_num "${green}处理完成，需要重新启用，重新跑脚本${yellow}sh \$jd start_script$green就会添加定时任务了${white}"
}


help() {
	#检查脚本是否最新
	echo "稍等一下，正在取回远端脚本源码，用于比较现在脚本源码，速度看你网络"
	cd $dir_file
	git fetch
	if [ $? -eq "0" ]; then
		echo ""
	else
		echo $echo_num "$red>> 取回分支没有成功，重新执行代码${white}"
		system_variable
	fi
	clear
	git_branch=$(git branch -v | grep -o behind )
	if [ "$git_branch" = "behind" ]; then
		Script_status="$red建议更新${white} (可以运行${green} sh \$jd update_script && sh \$jd update && source /etc/profile && sh \$jd ${white}更新 )"
	else
		Script_status="${green}最新${white}"
	fi
	task
	clear
	echo ----------------------------------------------------
	echo "	     JD.sh $version 简单使用说明"
	echo ----------------------------------------------------
	echo $echo_num "${yellow} 1.ck填入${white}"
	echo $echo_num "  获取到ck手动填入${green}  $openwrt_script_config/jdCookie.js ${white} 在此脚本内填写脚本内有说明"
	echo $echo_num "  获取到ck使用命令填入 ${green}  sh \$jd addcookie ${white} "
	echo ""
	echo $echo_num "${green}  如果你获取到的是wskey，请填入 /usr/share/jd_openwrt_script/script_config/wskey/jdwskey.txt${white} "
	echo $echo_num "${green}  并执行sh \$jd wskey 看下是否成功${white} "
	echo ""
	echo $echo_num "${yellow} 2.推送到手机${white}"
	echo ""
	echo $echo_num "${green}  填写$openwrt_script_config/sendNotify.js${white} (必须填写)"
	echo ""
	echo $echo_num "${green}  填写/usr/share/jd_openwrt_script/script_config/jd_openwrt_script_config.txt ${white}（按需填写） "
	echo ""
	echo $echo_num "${yellow} 3.测试是否能正常使用${white}"
	echo ""
	echo $echo_num "${green}  cd \$jd_file/js && node jd_bean_home.js  ${white} "
	echo ""
	echo $echo_num "${yellow} 4.jd.sh其他脚本命令${white}"
	echo ""
	echo $echo_num "${green}  sh \$jd run_0 ${white}  			#运行全部jd脚本"
	echo ""
	echo $echo_num "${green}  sh \$jd wskey ${white}  			#调用wskey转换"
	echo ""
	echo $echo_num "${green}  sh \$jd npm_install ${white}  			#安装 npm 模块"
	echo ""
	echo $echo_num "${green}  sh \$jd backnas ${white}  			#备份脚本到NAS存档"
	echo ""
	echo $echo_num "${green}  sh \$jd stop_script ${white}  			#删除定时任务停用所用脚本"
	echo ""
	echo $echo_num "${yellow} 5.常见报错${white}"
	echo ""
	echo "  运行node jd_bean_home.js，报错，请检测你的ck是否正常，正确可以运行sh \$jd npm_install"
	echo "  如果还不行请运行sh \$jd update_script && sh \$jd update && sh \$jd 更新到最新版本"
	echo "  "
	echo ""
	echo $echo_num "${yellow}   检测定时任务:${white} $cron_help"
	echo $echo_num "${yellow}   定时任务路径:${white}${green}$cron_file${white}"
	echo $echo_num "${yellow}   检测脚本是否最新:${white} $Script_status "
	echo $echo_num "${yellow}   JD_Script报错你可以反馈到这里:${white}${green} https://github.com/xdhgsq/xdh/issues${white}"
	echo ""
	echo $echo_num "本脚本基于${green} x86主机测试${white}，一切正常，其他的机器自行测试，满足依赖一般问题不大"
	echo ----------------------------------------------------
	echo " 		by：ITdesk"
	echo ----------------------------------------------------

}


additional_settings() {

	if [ `cat $openwrt_script_config/sendNotify.js | grep "采用lxk0301开源JS脚本" | wc -l` = "0" ];then
	sed -i "s/本脚本开源免费使用 By：https:\/\/gitee.com\/lxk0301\/jd_docker/#### 脚本仓库地址:https:\/\/github.com\/xdhgsq\/xdh/g" $openwrt_script_config/sendNotify.js
	sed -i "s/本脚本开源免费使用 By：https:\/\/github.com\/LXK0301\/jd_scripts/#### 脚本仓库地址:https:\/\/github.com\/xdhgsq\/xdh/g" $openwrt_script_config/sendNotify.js
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

path_install() {
#临时删除一下
sed -i '/wskey/d' /etc/profile >/dev/null 2>&1
sed -i '/checkjs/d' /etc/profile >/dev/null 2>&1
sed -i '/Checkjs/d' /etc/profile >/dev/null 2>&1
sed -i '/uname_if/d' /etc/profile >/dev/null 2>&1
sed -i '/NODE_PATH/d' /etc/profile >/dev/null 2>&1


cat > /tmp/path_if.txt <<EOF
export uname_if=Ubuntu
export NODE_PATH=/usr/share/jd_openwrt_script/script_config/node_modules
export wskey=/usr/share/jd_openwrt_script/script_config/wskey/wskey.sh
export wskey_file=/usr/share/jd_openwrt_script/script_config/wskey
export checkjs=/usr/share/jd_openwrt_script/Checkjs/checkjs.sh
export checkjs_file=/usr/share/jd_openwrt_script/Checkjs
EOF
	path_num=$(cat /tmp/path_if.txt|wc -l)
	num="1"
	while [ $path_num -ge $num ];do
		path_value=$(sed -n ${num}p /tmp/path_if.txt)
		path_name=$(echo $path_value | awk -F "=" '{print $1}' | sed "s/export //g")

		if [ "$(cat /etc/profile |grep -o "$path_name" |sort -u)" != "$path_name" ];then
			echo "$path_value" >> /etc/profile
			 . /etc/profile
		else
			echo "$path_name变量已导入"
		fi
		num=$(( $num + 1))
	done
}


npm_install() {
	echo $echo_num "${green} 开始安装npm模块${white}"
	#安装js模块到script_config,然后再ln过去

	if [ "$uname_if" = "Ubuntu" ];then
		echo "当前环境为ubuntu"
		npm install --prefix $openwrt_script_config \
		got@11.5.1 \
		crc@4.3.2 \
		http-cookie-agent@7.0.1 \
		qs@6.14.0 \
		sharp@0.34.2 \
		curl@0.1.4 \
		cheerio@1.0.0 \
		tough-cookie@5.1.2 \
		ds@2.0.2 \
		audit@0.0.6 \
		crypto@1.0.1 \
		crypto-js@4.2.0 \
		date-fns@4.1.0 \
		dotenv@16.5.0 \
		download@8.0.0 \
		fs@0.0.1-security \
		http@0.0.1-security \
		js-base64@3.7.7 \
		jsdom@26.1.0 \
		md5@2.3.0 \
		png-js@1.0.0 \
		request@2.88.2 \
		requests@0.3.0 \
		set-cookie-parser@2.7.1 \
		stream@0.0.3 \
		ts-md5@1.3.1 \
		vm@0.1.0 \
		zlib@1.0.5 \
		iconv-lite@0.6.3 \
		qrcode-terminal@0.12.0 \
		ws@8.18.2 \
		express@4.17.1 \
		body-parser@1.19.2 \
		moment@2.30.1

		npm install --prefix $openwrt_script_config --save axios@1.9.0

		#npm install npm@11.4.1
		#npm install got
		#npm install request uuid har-validator crc http-cookie-agent@latest qs sharp curl cheerio ds audit crypto-js date-fns dotenv download fs http js-base64 jsdom md5 png-js request requests set-cookie-parser stream tough-cookie ts-md5 vm iconv-lite qrcode-terminal ws express@4.17.1 body-parser@1.19.2 moment
		#npm install --save axios
	else
		cd $openwrt_script
		npm install -g npm@8.3.0
		npm install -g got@11.5.1
		npm install -g crc http-cookie-agent qs sharp curl cheerio tough-cookie ds audit crypto crypto-js date-fns dotenv download fs http js-base64 jsdom@26.1.0 md5 png-js request requests set-cookie-parser stream tough-cookie ts-md5 vm zlib iconv-lite qrcode-terminal ws express@4.17.1 body-parser@1.19.2 moment
		npm install --save axios

	fi

	#安装python模块
	python_install
	echo ""
}

python_install() {
	echo $echo_num "${green} 开始安装python模块${white}"
	if [ "$uname_if" = "Ubuntu" ];then
		echo ""
	else
		python3 $dir_file/get-pip.py
		pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple jieba requests rsa

	fi
	echo $echo_num "${green}命令执行完成，如果一直报错我建议你重置系统或者重新编译重新刷${white}"
}

system_variable() {

	if [ ! -d "/tmp/jd_tmp/" ]; then
		mkdir -p /tmp/jd_tmp/
	fi
	
	if [ ! -d "$dir_file/js" ]; then
		mkdir  $dir_file/js
	fi

	if [ ! -d "/tmp/jd_tmp" ]; then
		mkdir  /tmp/jd_tmp
	fi

	if [ "$dir_file" = "$openwrt_script/JD_Script" ];then
		echo $echo_num "》》${green}检查常用依赖是否正常${white}"
cat > /tmp/path_if.txt <<EOF
-f jdCookie.js
-f sendNotify.js
-f CK_WxPusherUid.json
-f ql.js
-d node_modules
EOF
		path_num=$(cat /tmp/path_if.txt|wc -l)
		num="1"
		while [ $path_num -ge $num ];do
			path_value=$(sed -n ${num}p /tmp/path_if.txt)
			path_if=$(echo $path_value | awk '{print $1}')
			path_name=$(echo $path_value | awk '{print $2}')
			if [ $path_if "$openwrt_script_config/$path_name" ]; then
				echo $echo_num "${green}$path_name文件存在${white}"
				if [ -L "$dir_file_js/$path_name" ];then
					echo $echo_num "》${green}$dir_file_js/$path_name软连接已创建${white}"
				else
					echo $echo_num "》${red}$path_name软连接没有创建，开始创建${green}(执行sh \$jd update 出现这个提示是正常的)${white}"
					rm -rf $dir_file_js/$path_name
					ln -s $openwrt_script_config/$path_name $dir_file_js/$path_name
					echo $echo_num "》》${green}$dir_file_js/$path_name软连接已创建${white}"
				fi
			else
				if [ "$uname_if" = "Ubuntu" ];then
					echo $echo_num "${red}$path_name文件不存在${white}"
					if [ "$path_name" = "node_modules" ];then
						echo $echo_num "${red}$openwrt_script_config/$path_name不存在，${green}请手动执行sh \$jd npm_install && sh \$jd update进行安装${white}"
					else
						cp  $dir_file/back/JSON/$path_name  $openwrt_script_config/$path_name
						rm -rf $dir_file_js/$path_name
						ln -s $openwrt_script_config/$path_name $dir_file_js/$path_name
					fi
				fi
			fi
			num=$(( $num + 1))
		done
	fi


	#添加系统变量
	jd_script_path=$(cat /etc/profile | grep -o jd.sh | wc -l)
	if [ "$jd_script_path" -eq "0" ]; then
		echo "export jd_file=$dir_file" >> /etc/profile
		echo "export jd=$dir_file/jd.sh" >> /etc/profile
		 . /etc/profile
	fi

	jd_openwrt_config

}

wskey() {
	if [ -z "$wskey" ];then
		echo $echo_num "${red}wskey脚本为空,$white请检查${green}/usr/share/jd_openwrt_script/script_config/wskey/wskey.sh${white}　是否存在"
		echo "如果存在,请重启路由使全局变量生效"
		echo "如果不存在请去https://github.com/xdhgsq/wskey_convert.git下载"
	else
		sh $wskey
	fi

}

checkjs() {
	if [ -z "$checkjs" ];then
		echo $echo_num "${red}checkjs脚本为空,$white请检查${green}/usr/share/jd_openwrt_script/Checkjs/checkjs.sh${white}　是否存在"
		echo "如果存在,请重启路由使全局变量生效"
		echo "如果不存在请去https://github.com/ITdesk01/Checkjs.git下载"
	else
		sh $checkjs
	fi

}

checkjs_tg() {
	if [ -z "$checkjs" ];then
		echo $echo_num "${red}checkjs脚本为空,$white请检查${green}/usr/share/jd_openwrt_script/Checkjs/checkjs.sh${white}　是否存在"
		echo "如果存在,请重启路由使全局变量生效"
		echo "如果不存在请去https://github.com/ITdesk01/Checkjs.git下载"
	else
		sh $checkjs tg
	fi

}



pj() {
	pj_ck_num=$(cat /usr/share/jd_openwrt_script/script_config/js_cookie.txt |wc -l)
	pj_ck=$(cat /usr/share/jd_openwrt_script/script_config/js_cookie.txt | awk -F "'," '{print $1}' | sed "s/'//g" |sed "s/$/\&/g" | sed 's/[:space:]//g' | sed ':t;N;s/\n//;b t' | sed "s/&$//")
	if [ -f $dir_file/js/pinjia-amd64 ];then
		clear
		echo $echo_num "$green开始进行评价,你一共有$pj_ck_num个账号$white"
		export JD_COOKIE="$pj_ck"
		$dir_file/js/pinjia-amd64
	else
		clear
		echo $echo_num "$yellow没有发现评价程序开始下载$white"
		wget https://raw.githubusercontent.com/chendianwu0828/jd_pinjia/main/pinjia-amd64 -O $dir_file/js/pinjia-amd64
		chmod +x $dir_file/js/pinjia-amd64
		export JD_COOKIE="pj_ck"
		echo $echo_num "$green开始进行评价,你一共有$pj_ck_num个账号$white"
		$dir_file/js/pinjia-amd64
	fi
}

index_js() {
#后台默认运行index.js
	openwrt_ip=$(ubus call network.interface.lan status | grep address  | grep -oE '([0-9]{1,3}.){3}[0-9]{1,3}')
	index_if=$(ps -ww | grep "index.js" | grep -v grep | wc -l)
	if [ $index_if = "1" ];then
		index_num="${yellow} 8.网页获取CK功能已启动，网页输入${green}$openwrt_ip:6789${white}${yellow},就可以访问了${white}"
	else
		echo $echo_num "${green}启动网页获取CK功能${white}"
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

jd_openwrt_config() {
	jd_openwrt_config_version="1.8"
	if [ "$dir_file" = "$openwrt_script/JD_Script" ];then
		jd_openwrt_config="$openwrt_script_config/jd_openwrt_script_config.txt"
		if [ ! -f "$jd_openwrt_config" ]; then
			jd_openwrt_config_description
		fi
	fi

	if [ `grep "jd_openwrt_config $jd_openwrt_config_version" $jd_openwrt_config |wc -l` = "1"  ];then
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

**********************************************************************************

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

system_variable
action1="$1"
action2="$2"
if [ -z $action1 ]; then
	help
else
	case "$action1" in
		run_0)
		concurrent_js_if
		;;
		path_install|ccr_run|start_script|wskey|checkjs|checkjs_tg|pj|system_variable|update|update_script|task|ds_setup|checklog|that_day|stop_script|script_name|backnas|npm_install|checktool|concurrent_js_clean|if_ps|getcookie|addcookie|delcookie|python_install|concurrent_js_update|kill_index|del_expired_cookie|jd_time|run_jsqd|Tjs|test)
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

	if [ -z $action2 ]; then
		echo ""
	else
		case "$action2" in
		run_0)
		concurrent_js_if
		;;
		path_install|ccr_run|start_script|wskey|checkjs|checkjs_tg|pj|system_variable|update|update_script|task|ds_setup|checklog|that_day|stop_script|script_name|backnas|npm_install|checktool|concurrent_js_clean|if_ps|getcookie|addcookie|delcookie|python_install|concurrent_js_update|kill_index|del_expired_cookie|jd_time|run_jsqd|Tjs|test)
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

