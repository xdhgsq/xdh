const child_process = require('child_process');
const fs = require('fs');
const express = require('express');
const got = require('got');
const path = require('path');
const bodyParser = require('body-parser');
const app = express();
app.use(bodyParser.json({ limit: '50mb' }));
app.use(bodyParser.urlencoded({ limit: '50mb', extended: true }));
const crypto = require('crypto');
const md5 = function (str) {
  const encode = crypto.createHash('md5');
  return encode.update(str).digest('hex');
};

async function sendSms(phone) {
  let appid = 959;
  let version = '1.0.0';
  let countryCode = 86;
  let timestamp = new Date().getTime();
  let subCmd = 1;
  let gsalt = 'sb2cwlYyaCSN1KUv5RHG3tmqxfEb8NKN';
  let gsign = md5('' + appid + version + timestamp + '36' + subCmd + gsalt);
  let res = await got.post('https://qapplogin.m.jd.com/cgi-bin/qapp/quick', {
    method: 'post',
    headers: {
      'user-agent':
        'Mozilla/5.0 (Linux; Android 10; V1838T Build/QP1A.190711.020; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/98.0.4758.87 Mobile Safari/537.36 hap/1.9/vivo com.vivo.hybrid/1.9.6.302 com.jd.crplandroidhap/1.0.3 ({packageName:com.vivo.hybrid,type:deeplink,extra:{}})',
      'accept-language': 'zh-CN,zh;q=0.9,en;q=0.8',
      'content-type': 'application/x-www-form-urlencoded; charset=utf-8',
      'accept-encoding': '',
      cookie: '',
    },
    body:
      'client_ver=' +
      version +
      '&gsign=' +
      gsign +
      '&appid=' +
      appid +
      '&return_page=https%3A%2F%2Fcrpl.jd.com%2Fn%2Fmine%3FpartnerId%3DWBTF0KYY%26ADTAG%3Dkyy_mrqd%26token%3D&cmd=36&sdk_ver=1.0.0&sub_cmd=' +
      subCmd +
      '&qversion=' +
      version +
      '&ts=' +
      timestamp,
    dataType: 'json',
  });
  let data = JSON.parse(res.body).data;
  subCmd = 2;
  timestamp = new Date().getTime();
  gsalt = data.gsalt;
  gsign = md5('' + appid + version + timestamp + '36' + subCmd + gsalt);
  let sign = md5(
    '' +
      appid +
      version +
      countryCode +
      phone +
      '4dtyyzKF3w6o54fJZnmeW3bVHl0$PbXj'
  );
  let ck =
    'guid=' +
    data.guid +
    ';lsid=' +
    data.lsid +
    ';gsalt=' +
    data.gsalt +
    ';rsa_modulus=' +
    data.rsa_modulus +
    ';';
  res = await got.post('https://qapplogin.m.jd.com/cgi-bin/qapp/quick', {
    method: 'post',
    headers: {
      'user-agent':
        'Mozilla/5.0 (Linux; Android 10; V1838T Build/QP1A.190711.020; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/98.0.4758.87 Mobile Safari/537.36 hap/1.9/vivo com.vivo.hybrid/1.9.6.302 com.jd.crplandroidhap/1.0.3 ({packageName:com.vivo.hybrid,type:deeplink,extra:{}})',
      'accept-language': 'zh-CN,zh;q=0.9,en;q=0.8',
      'content-type': 'application/x-www-form-urlencoded; charset=utf-8',
      'accept-encoding': '',
      cookie: ck,
    },
    body:
      'country_code=' +
      countryCode +
      '&client_ver=' +
      version +
      '&gsign=' +
      gsign +
      '&appid=' +
      appid +
      '&mobile=' +
      phone +
      '&sign=' +
      sign +
      '&cmd=36&sub_cmd=' +
      subCmd +
      '&qversion=' +
      version +
      '&ts=' +
      timestamp,
    dataType: 'json',
  });
  data = JSON.parse(res.body).data;

  if (data.err_code > 0) {
    return { ok: false, msg: '发送验证码失败:' + data.err_msg };
  } else {
    return { ok: true, msg: 'success', data: { ck: ck, gsalt: gsalt } };
  }
}

async function checkCode(phone, code, gsalt, ck) {
  let appid = 959;
  let version = '1.0.0';
  let countryCode = 86;
  let timestamp = new Date().getTime();
  let subCmd = 3;
  let gsign = md5('' + appid + version + timestamp + '36' + subCmd + gsalt);
  let body =
    'country_code=' +
    countryCode +
    '&client_ver=' +
    version +
    '&gsign=' +
    gsign +
    '&smscode=' +
    code +
    '&appid=' +
    appid +
    '&mobile=' +
    phone +
    '&cmd=36&sub_cmd=' +
    subCmd +
    '&qversion=' +
    version +
    '&ts=' +
    timestamp;
  res = await got.post('https://qapplogin.m.jd.com/cgi-bin/qapp/quick', {
    method: 'post',
    headers: {
      'user-agent':
        'Mozilla/5.0 (Linux; Android 10; V1838T Build/QP1A.190711.020; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/98.0.4758.87 Mobile Safari/537.36 hap/1.9/vivo com.vivo.hybrid/1.9.6.302 com.jd.crplandroidhap/1.0.3 ({packageName:com.vivo.hybrid,type:deeplink,extra:{}})',
      'accept-language': 'zh-CN,zh;q=0.9,en;q=0.8',
      'content-type': 'application/x-www-form-urlencoded; charset=utf-8',
      'accept-encoding': '',
      cookie: ck,
    },
    body: body,
    dataType: 'json',
  });
  let data = JSON.parse(res.body);
  return data;
}

/**
 * API 发验证码
 */
app.get('/sendSms', async function (request, response) {
  try {
    const phone = request.query.phone;
    if (!new RegExp('\\d{11}').test(phone)) {
      response.send({ ok: false, msg: '手机号格式错误' });
      return;
    }
    console.log(phone);
    const data = await sendSms(phone);
    response.send(data);
  } catch (err) {
    console.log(err);
    response.send({ ok: false, msg: '错误' });
  }
});

app.post('/checkCode', async function (request, response) {
  try {
    const phone = request.query.phone;
    if (!new RegExp('\\d{11}').test(phone)) {
      response.send({ ok: false, msg: '手机号格式错误' });
      return;
    }
    const code = request.query.code;
    if (!new RegExp('\\d{6}').test(code)) {
      response.send({ ok: false, msg: '验证码格式错误' });
      return;
    }
    const { gsalt, ck } = request.body;
    console.log(phone, code);
    const data = await checkCode(phone, code, gsalt, ck);

    if (data.err_code > 0) {
      response.send({ ok: false, msg: '登录失败:' + r.err_msg });
    } else {
      const cookie =
        'pt_key=' +
        data.data.pt_key +
        ';pt_pin=' +
        encodeURIComponent(data.data.pt_pin) +
        ';';
      console.log(`你的cookie为:`, cookie)
      await child_process.exec(`echo "${cookie}" >/tmp/getcookie.txt && /bin/sh /usr/share/jd_openwrt_script/JD_Script/jd.sh addcookie concurrent_js_update`, function(err, sto) {
	console.log(sto);//sto才是真正的输出，要不要打印到控制台，由你自己啊
      });
      response.send({
        ok: true,
        msg: '获取ck成功',
        data: {
          ck: cookie,
        },
      });
    }
  } catch (err) {
    console.log(err);
    response.send({ ok: false, msg: '错误' });
  }
});

const sleep = (ms) => {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
};

app.use(express.static(path.join(__dirname, 'public')));


// 本地运行开启以下
const PORT = 6789;
app.listen(PORT, () => {
  console.log(`应用正在监听 ${PORT} 端口!`);
});



// 云函数运行开启以下
module.exports = app;

