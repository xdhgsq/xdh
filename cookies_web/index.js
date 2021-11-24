const UA =`jdapp;iPhone;10.1.2;14.7.1;${randomString(40)};network/wifi;model/iPhone10,2;addressid/4091160336;appBuild/167802;jdSupportDarkMode/0;Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148;supportJDSHWK/1`;

const express = require('express');
const got = require('got');
const path = require('path');
const QR = require('qrcode');
const bodyParser = require('body-parser');
const cors = require('cors');
const app = express();
app.use(cors());
app.use(bodyParser.json({ limit: '50mb' }));
app.use(bodyParser.urlencoded({ limit: '50mb', extended: true }));
const qs = require('querystring');
/**
 * 字符串工具函数
 * 从 'xxx=yyy' 中提取 'yyy'
 *
 * @param {*} key
 * @return {string} value
 */
const transformKey = (key) => {
  return key.substring(key.indexOf('=') + 1, key.indexOf(';'));
};

/**
 * 随机字符串
 *
 * @param {number} [length=6]
 * @return {*}
 */
const ramdomString = (length = 6) => {
  var str = 'abcdefghijklmnopqrstuvwxyz';
  str += str.toUpperCase();
  str += '0123456789';
  var _str = '';
  for (let i = 0; i < length; i++) {
    var rand = Math.floor(Math.random() * str.length);
    _str += str[rand];
  }
  return _str;
};

/**
 * 通过res获取cookie
 * 此cookie用来请求二维码
 *
 * @param {*} response
 * @return {*}
 */
const praseSetCookies = (response) => {
  const s_token = response.body.s_token;
  const guid = transformKey(response.headers['set-cookie'][0]);
  const lsid = transformKey(response.headers['set-cookie'][2]);
  const lstoken = transformKey(response.headers['set-cookie'][3]);
  const cookies = `guid=${guid}; lang=chs; lsid=${lsid}; lstoken=${lstoken};`;
  return {
    s_token,
    guid,
    lsid,
    lstoken,
    cookies,
  };
};

/**
 * 通过res解析headers获得cookie
 *
 * @param {*} response
 * @return {string} userCookie
 */
const getCookie = (response) => {
  // 注释的参数没用，如果二次修改请自行研究
  // const TrackerID = transformKey(response.headers['set-cookie'][0]);
  // const pt_token = transformKey(response.headers['set-cookie'][3]);
  // const pwdt_id = transformKey(response.headers['set-cookie'][4]);
  // const s_key = transformKey(response.headers['set-cookie'][5]);
  // const s_pin = transformKey(response.headers['set-cookie'][6]);

  const pt_key = transformKey(response.headers['set-cookie'][1]);
  const pt_pin = transformKey(response.headers['set-cookie'][2]);
  const userCookie = `pt_key=${pt_key};pt_pin=${pt_pin};`;
  console.log({
    msg: '登录成功',
    time: new Date().toISOString(),
    userCookie,
    pt_pin,
  });
    const update_ok = `更新完成,后台自动更新你的ck，稍后自己查看`;

    var child = require('child_process');
    child.exec(`echo "${userCookie}" > /tmp/getcookie.txt && sh /usr/share/jd_openwrt_script/JD_Script/jd.sh addcookie && sh /usr/share/jd_openwrt_script/JD_Script/jd.sh concurrent_js_update`, function(err, sto) {
	 console.log(sto);//sto才是真正的输出，要不要打印到控制台，由你自己啊
    });

    return update_ok
};

/**
 * 初始化请求二维码的参数
 *
 */
async function step1() {
  const timeStamp = new Date().getTime();
  const loginUrl =
    'https://plogin.m.jd.com/cgi-bin/mm/new_login_entrance?lang=chs&appid=300' +
    `&returnurl=https://wq.jd.com/passport/LoginRedirect?state=${timeStamp}` +
    '&returnurl=https://home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport';

  const response = await got(loginUrl, {
    responseType: 'json',
    headers: {
      Connection: 'Keep-Alive',
      'Content-Type': 'application/x-www-form-urlencoded',
      Accept: 'application/json, text/plain, */*',
      'Accept-Language': 'zh-cn',

      Referer:
        'https://plogin.m.jd.com/login/login?appid=300' +
        `&returnurl=https://wq.jd.com/passport/LoginRedirect?state=${timeStamp}` +
        '&returnurl=https://home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport',
      'User-Agent': UA,
      Host: 'plogin.m.jd.com',
    },
  });

  return praseSetCookies(response);
}

/**
 * 获取二维码链接
 *
 * @param {*} cookiesObj
 * @return {*}
 */
async function step2(cookiesObj) {
  const { s_token, guid, lsid, lstoken, cookies } = cookiesObj;
  if (cookies == '') {
    throw new Error('获取失败');
  }
  const timeStamp = new Date().getTime();
  const getQRUrl =
    'https://plogin.m.jd.com/cgi-bin/m/tmauthreflogurl?s_token=' +
    `${s_token}&v=${timeStamp}&remember=true`;
  const response = await got.post(getQRUrl, {
    responseType: 'json',
    json: {
      lang: 'chs',
      appid: 300,
      returnurl:
        `https://wqlogin2.jd.com/passport/LoginRedirect?state=${timeStamp}` +
        '&returnurl=//home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action',
      source: 'wq_passport',
    },
    headers: {
      'Client-IP': '0.0.0.0',
      Connection: 'Keep-Alive',
      'Content-Type': 'application/x-www-form-urlencoded; Charset=UTF-8',
      Accept: 'application/json, text/plain, */*',
      'X-Forwarded-For': '0.0.0.0',
      Cookie: cookies,
      Referer:
        'https://plogin.m.jd.com/login/login?appid=300' +
        `&returnurl=https://wqlogin2.jd.com/passport/LoginRedirect?state=${timeStamp}` +
        '&returnurl=//home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport',
      'User-Agent': UA,
      Host: 'plogin.m.jd.com',
    },
  });
  const token = response.body.token;
  // console.log(response.body);
  const oneKeyLog = response.body['onekeylog_url'];

  const okl_token = transformKey(response.headers['set-cookie'][0]);
  const qrCodeUrl = `https://plogin.m.jd.com/cgi-bin/m/tmauth?appid=300&client_type=m&token=${token}`;
  return {
    ...cookiesObj,
    qrCodeUrl,
    oneKeyLog,
    okl_token,
    token,
    cookies: `okl_token=${okl_token};` + cookies,
  };
}

/**
 * 通过前端传回的参数获得cookie
 *
 * @param {*} user
 * @return {*}
 */
async function checkLogin(user) {
  const { s_token, guid, lsid, lstoken, cookies, okl_token, token } = user;
  const timeStamp = new Date().getTime();
  const getUserCookieUrl =
    `https://plogin.m.jd.com/cgi-bin/m/tmauthchecktoken?&token=${token}` +
    `&ou_state=1&okl_token=${okl_token}`;
  const response = await got.post(getUserCookieUrl, {
    responseType: 'json',
    body: qs.stringify({
      lang: 'chs',
      appid: 300,
      returnurl:
        'https://wqlogin2.jd.com/passport/LoginRedirect?state=1100399130787&returnurl=//home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action',
      source: 'wq_passport',
    }),
    headers: {
      'Client-IP': '0.0.0.0',
      'X-Forwarded-For': '0.0.0.0',
      Referer:
        'https://plogin.m.jd.com/login/login?appid=300' +
        `&returnurl=https://wqlogin2.jd.com/passport/LoginRedirect?state=${timeStamp}` +
        '&returnurl=//home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport',
      Cookie: cookies,
      Connection: 'Keep-Alive',
      'Content-Type': 'application/x-www-form-urlencoded; Charset=UTF-8',
      Accept: 'application/json, text/plain, */*',
      'User-Agent': UA,
    },
  });
  return response;
}


/**
 * 对ck进行处理的流程
 *
 * @param {*} cookie
 * @return {*}
 */
async function cookieFlow(cookie, userMsg) {
  try {
    const updateMsg = await updateCookie(cookie, userMsg);
    await sendMsg(updateMsg, cookie, userMsg);
    return msg;
  } catch (err) {
    return '';
  }
}

/**
 * API 获取二维码链接
 */
app.get('/qrcode', async function (request, response) {
  try {
    const cookiesObj = await step1();
    const user = await step2(cookiesObj);
    const qrCodeImg = await QR.toDataURL(user.qrCodeUrl, {
      margin: 0,
      width: 300,
      scale: 0,
    });
    response.send({
      err: 0,
      qrCodeUrl: user.qrCodeUrl,
      oneKeyLog: user.oneKeyLog,
      qrCodeImg,
      user,
    });
  } catch (err) {
    response.send({ err: 2, msg: '错误' });
  }
});

const sleep = (ms) => {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
};

/**
 * API 获取返回的cookie信息
 */
app.post('/cookie', async function (request, response) {
  const user = request.body.user;
  const userMsg = request.body.msg;
  if (user && user.cookies != '') {
    (async () => {
      try {
        const cookie = await checkLogin(user);
        if (cookie.body.errcode == 0) {
          let ucookie = getCookie(cookie);
          response.send({ err: 0, cookie: ucookie, msg: '更新成功' });
          await cookieFlow(ucookie, userMsg);
        } else {
          response.send({
            err: cookie.body.errcode,
            msg: cookie.body.message,
            body: cookie.body,
          });
        }
      } catch (err) {
        response.send({ err: 1, msg: err });
      }
    })();
  } else {
    response.send({ err: 2, msg: '获取失败' });
  }
});

function randomWord(randomFlag, min, max){
  var str = "",
      range = min,
      arr = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'];
  // 随机产生
  if(randomFlag){
    range = Math.round(Math.random() * (max-min)) + min;
  }
  for(var i=0; i<range; i++){
    pos = Math.round(Math.random() * (arr.length-1));
    str += arr[pos];
  }
  return str;
}

/**
 * 生成随机 iPhoneID
 * @returns {string}
 */
 function randomString(e) {
  e = e || 32;
  let t = "abcdef0123456789", a = t.length, n = "";
  for (i = 0; i < e; i++)
    n += t.charAt(Math.floor(Math.random() * a));
  return n
}

// 用于修复云函数的图标显示问题
app.get('/favicon.ico', async function (request, response) {
  response.status(200);
  response.sendFile(path.join(__dirname, 'public', 'favicon.ico'));
});

app.use(express.static(path.join(__dirname, 'public')));

// 本地运行开启以下
const PORT = 6789;
app.listen(PORT, () => {
  console.log(`应用正在监听 ${PORT} 端口!`);
});

// 云函数运行开启以下
module.exports = app;

