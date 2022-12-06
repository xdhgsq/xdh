# JD_Script 简单说明（2022.12.06编辑，by：ITdesk）
##  1.目录结构
###  JD_Script仓库目录说明
/usr/share/jd_openwrt_script/JD_Script/                    

          |-- ccr_js                        # 并发文件夹，开启需要到jd_openwrt_script_config.txt
          |-- config                        # 没啥大用（之前单独安装留下的，但不能删）
          |-- cookies_web                   # 网页扫码代码（暂时没人修）
          |-- doc                           # 编译说明文档和简单使用说明
          |-- git_clone                     # 存放个别库文件
          |-- git_log                       # 记录log文件夹（用于推送）
          |-- jd_try_file                   # 多账号试用文件夹，开启需要到jd_openwrt_script_config.txt
          |-- JSON                          # 存放一些未修改的重要文件
          |-- js *                          # 所有js脚本存放地方，可以cd $jd_file/js到达（重要）
          |
          |-- jd.sh *                       # 核心脚本
          |-- get-pip.py                    # 辅助安装python
          |
          |-- jd_random.py                  # 生成随机数
          |-- LICENSE                       
          |-- README.md                 
          |-- Explain.md                    # 说明文档
    
 ### JD_Script配置文件存放
/usr/share/jd_openwrt_script/script_config/                 

          |-- wskey                         # wskey转换文件夹
              ||   -- js                    # wskey js脚本文件夹
              || --  jdCookie.js
              || --  jd_wskey.js            # 旧js转换脚本
              || --  wskey.py               # 新的py转换脚本（默认）
              ||   -- wskey.sh              # wkey转换shell脚本
          
          |-- jd_openwrt_script_config.txt  # 重要的配置文件
          |-- jdCookie.js                   # cookie填写到此
          |-- sendNotify.js                 # node推送脚本（用于填写推送key）
          |   
          |-- backnas_config.txt            # 将文件备份到nas需要填写的
          |-- Script_blacklist.txt          # 脚本黑名单（后面可能会合并）
          | 
          |-- sendNotify.py                 # python的推送脚本
          |-- CK_WxPusherUid.json           # 一对一推送需要的文件                ----- | 号少忽略
          |-- sendNotify_ccwav.js           # 一对一推送脚本（用于填写推送key）   ----- | 号少忽略
          |-- ql.js                         # 一对一推送依赖                      ----- | 号少忽略
          | 
          |-- JS_USER_AGENTS.js             # JS_UA文件
          |-- USER_AGENTS.js                # UA文件

### 监控脚本目录
/usr/share/jd_openwrt_script/Checkjs  

          |-- tg                                 # 存放tg监控信息
          |-- checkjs.sh                         # 监控脚本
          
### node模块存放的文件夹       
/usr/share/jd_openwrt_script/node_modules 


##  2.可用命令
          sh $jd run_0  run_07                  #运行全部脚本(除个别脚本不运行）
          
          sh $jd wskey                          #用wskey转换
           
          sh $jd checkjs                        #用checkjs监控上游脚本更新
            
          sh $jd checkjs_tg                     #调用checkjs监控tg频道变量（需要docker容器）

          sh $jd npm_install                    #安装 npm 模块

          sh $jd zcbh                           #资产变化一对一

          sh $jd opencard                       #开卡(默认不执行，你可以执行这句跑)

          sh $jd jx                             #查询京喜商品生产使用时间

          sh $jd jd_sharecode                   #查询京东所有助力码

          sh $jd checklog                       #检测log日志是否有错误并推送

          sh $jd that_day                       #检测JD_script仓库今天更新了什么

          sh $jd check_cookie_push              #推送cookie大概到期时间和是否有效

          sh $jd script_name                    #显示所有JS脚本名称与作用

          sh $jd backnas                        #备份脚本到NAS存档

          sh $jd stop_script                    #删除定时任务停用所用脚本

          sh $jd kill_ccr                       #终止并发

          sh $jd checktool                      #检测后台进程，方便排除问题
    
    如果不喜欢这样，你也可以直接 cd $jd_file/js,然后用 node 脚本名字.js
    
##  3.cookie，推送填写位置（ck优先级wskey>ck,wskey存活时间久,ck只有一个月，抓到wskey以后用wskey转换脚本，转换为ck即可使用）

1.wskey填写

    /usr/share/jd_openwrt_script/script_config/wskey/jdwskey.txt  将抓到wskey填写在这里
   
    sh $jd wskey  测试是否能否转换完成，自动将转好ck填写到jdCookie.js
   
2.cookie填写（有wskey忽略这里）

    /usr/share/jd_openwrt_script/script_config/jdCookie.js  在此脚本内填写JD Cookie 脚本内有说明
       
3.推送填写

    /usr/share/jd_openwrt_script/script_config/sendNotify.js  在此脚本内填写推送服务的KEY，可以不填
   
4.UA文件自定义

    /usr/share/jd_openwrt_script/script_config/USER_AGENTS.js  京东UA文件可以自定义也可以默认
  
    /usr/share/jd_openwrt_script/script_config/JS_USER_AGENTS.js  京东极速版UA文件可以自定义也可以默认
    
5.资产变化一对一填写

    1.先网页搞定WxPusher，详细教程有人写了，不知道是幸运还是不幸: https://www.kejiwanjia.com/jiaocheng/27909.html
    2.更新到最新脚本
    3.填好/usr/share/jd_openwrt_script/script_config/CK_WxPusherUid.json
    4.将WxPusher的token填入/usr/share/jd_openwrt_script/script_config/sendNotify_ccwav.js 中的WP_APP_TOKEN_ONE
    5.重启路由
    6.sh $jd zcbh #测试

    定时任务我已经设置好，每天早上十点推送，不喜欢可以复制单独推

6.checkjs监控脚本变量（写到全局变量/etc/profile）

    #是否自动跑新增的脚本(默认no，跑yes)(也可以用export script_if="yes"写到全局变量)
    script_if="yes"

    #脚本名判断(* 代表无论新增什么脚本都跑，你可以这里填关键字用，隔开，如填opencard,gua  这样脚本含有这两个字符的就会开始跑)
    script_ifname="gua_opencard,jd_opencard"

    #脚本下载到那个路径并执行
     script_dir="/usr/share/jd_openwrt_script/script_config/zdiy"

     #脚本在那个时间自动跑(* 代表所有时间 7-18 代表7点到18点有符合的脚本更新就跑 7,9 代表7点 9点才会自己跑)
     script_date="*"


    #tg监控频道变量(也可以用export tg_if="yes"写到全局变量)
    tg_if="no"

    #tg_api(必填，不然无法启动监控，获取地址参考https://www.jianshu.com/p/3d047c7516cf')(也可以用export tg_api_id=""写到全局变量)
    tg_api_id=""

    #tg_hash(必填，不然无法启动监控，获取地址参考https://www.jianshu.com/p/3d047c7516cf')(也可以用export tg_api_hash=""写到全局变量)
    tg_api_hash=""

7.wskey全局变量（可选，可以不理）

    #使用那种进行转换wskey（py js）
    wskey_program="py" (默认)

    #是否再wskey转换失败的时候删除jdcookie.js里的失效ｃｋ（会打乱你的排序，wskey恢复以后会自己添加）
    ck_del="no"　(默认)

    #wskey白名单，用于转换失效但不删jdcookie.js里的ｃｋ（格式：pin1@pin2）
    wskey_ck_white=""　(默认为空)
          
8.其他全局变量，按需取

    #开卡变量
    export guaopencard_All="true"
    export guaopencard_addSku_All="true"
    export guaopencardRun_All="true"
    export guaopencard_draw="true"

    #清空购物车变量
    export gua_cleancart_Run="true"
    export gua_cleancart_SignUrl="https://jd.smiek.tk/jdcleancatr_21102717"
    export gua_cleancart_products="*@&@"

          


## 4.新手常见疑问

1.如何获取cookie(温馨提醒请勿泄露ck给不认识的人，尤其是代挂，ck等于你的账号密码)

   [获取CK教程](https://github.com/ITdesk01/script_back/blob/main/backUp/GetJdCookie.md)

2.填好cookie和推送以后如何测试

    sh $jd run_0  #查看是否运行正常
   
    node $jd_file/js/jd_bean_change.js  #或者执行单个脚本测试
   
3.如何查看定时任务是否正常运行

    sh $jd checktool                      #查看后台进程，方便排除问题 
    
    ps -ww | grep "脚本名"                #ps查询
    
4.当前可用脚本有那些

    sh $jd script_name                    #显示所有JS脚本名称与作用
    
    sh $jd script_name | grep "查询关键字" #用于快速查找某些脚本，比如你可以输入开卡，签到等等
    
5.多账号如何并发

    前提你有不低于5个号，太少了，并发不并发都一样
   
    开启并发需要去到/usr/share/jd_openwrt_script/script_config/jd_openwrt_script_config.txt 打开
    
5.如何杀掉后台进程

     sh $jd kill_ccr
     
6.查询日志文件（比如查看run_0每天的运行情况）

     cd /tmp
     ls 
     
     你就会发现很多这种前面jd 后面log的日志文件，自己打开可以看下运行情况
     
     jd_run_0.log
     
     jd_run_01.log
     
     jd_run_02.log
     
     jd_run_03.log
     
     jd_run_030.log
     
     jd_run_06_18.log
     
     jd_run_07.log
     
     jd_run_08_12_16.log
     
     
#### 解释一下这里的run_0  ，run_01， run_02 ，   这里分别代表时间段，run_0 代表0点运行的脚本日志，jd.sh有很多模块，我把同一个时间要跑的脚本都扔到了一起，所以你在里面会看到很多脚本的日志，会有点乱。
 
     
7.如何本地账号互相助力（现支持农场，萌宠，种豆，京喜工厂）

    1.更新到最新版本
    
    2.sh $jd jd_sharecode                   #查询京东所有助力码
    
    3.将获取到的助力码填入/usr/share/jd_openwrt_script/script_config/jd_openwrt_script_config.txt
    
    4.sh $jd script_name | grep "农场"       #这是一个例子
    
    5.node $jd_file/js/jd_fruit.js           #运行东东农场，测试一下是否正常

如果不理解请查阅 [JD_Script使用方法（入门版）.pdf](https://github.com/ITdesk01/JD_Script/blob/main/doc/JD_Script%E4%BD%BF%E7%94%A8%E6%96%B9%E6%B3%95%EF%BC%88%E5%85%A5%E9%97%A8%E7%89%88%EF%BC%89.pdf)，跟着教程走一次，就行了

## 5.报错排查口诀

遇事不决重启一下（尤其是变量问题尤其有效）

重启不行，更新一下

    sh $jd update_script && sh $jd update && source /etc/profile && sh $jd

模块报错一律 

    sh $jd npm_install 下载不下来就是你网络问题

下载下来的js都是空的

    强制代理raw.githubusercontent.com


#### 以上操作不行

    将/usr/share/jd_openwrt_script/script_config/整个文件夹备份

    /etc/init.d/jd_openwrt_script stop   #删除所有脚本文件

    /etc/init.d/jd_openwrt_script start  #重新下载安装脚本 （网络一定要好，能够wget下载github文件，不然一定报错）


**问题反馈：https://github.com/ITdesk01/JD_Script/issues (描述清楚问题或者上图片，不然可能没有人理)**







    

    
     
