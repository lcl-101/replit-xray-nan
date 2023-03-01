#!/bin/bash

export PATH="~/nginx/sbin:~/app:$PATH"

chmod a+x ./nginx/sbin/nginx ./app/web

if [ ! -d ~/nginx ];then
    cp -ax ./nginx ~/nginx
fi

if [ ! -d ~/app ];then
    cp -ax ./app ~/app
fi

if [ -f ~/app/name ]
then
    exe_old=`cat ~/app/name`
else
    exe_old="web"
fi

exe=`openssl rand -hex 3`
echo $exe > ~/app/name
mv ~/app/$exe_old ~/app/$exe

version=`$exe version | head -1 | awk '{print $2}'`

UUID=${UUID:-$REPL_ID}

sed -i "s#uuid#$UUID#g" ~/app/config.json
sed -i "s#uuid#$UUID#g" ~/nginx/conf/conf.d/default.conf

HOST=${REPL_SLUG}.${REPL_OWNER}.repl.co

IPV4=`dig $HOST|grep ^$HOST|awk '{print $5}'`

VMESS_WSPATH="/${UUID}-vm"
VLESS_WSPATH="/${UUID}-vl"
TR_WSPATH="/${UUID}-tr"

vm_link=$(echo -e '\x76\x6d\x65\x73\x73')://$(echo -n "{\"v\":\"2\",\"ps\":\"replit-vmess\",\"add\":\"$HOST\",\"port\":\"443\",\"id\":\"$UUID\",\"aid\":\"0\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"$HOST\",\"path\":\"$VMESS_WSPATH\",\"tls\":\"tls\"}" | base64 -w 0)
vl_link=$(echo -e '\x76\x6c\x65\x73\x73')"://"$UUID"@"$HOST":443?encryption=none&security=tls&type=ws&host="$HOST"&path="$VLESS_WSPATH"#replit-vless"
tr_link=$(echo -e '\x74\x72\x6f\x6a\x61\x6e')"://"$UUID"@"$HOST":443?security=tls&type=ws&host="$HOST"&path="$TR_WSPATH"#replit-trojan"

vm_img="data:image/png;base64,`qrencode -o - $vm_link | base64`"
vl_img="data:image/png;base64,`qrencode -o - $vl_link | base64`"
tr_img="data:image/png;base64,`qrencode -o - $tr_link | base64`"

cat > ~/nginx/html/$UUID.html<<-EOF
<!DOCTYPE html>
<html>
<head>
<title>节点信息</title>
<style>
    body {
        width: auto;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
    p {
        margin: 0 auto;
        text-align: left;
        white-space: pre-wrap;
        word-break: break-all;
        max-width: 80%;
    }
    h1 {
        margin: 0 auto;
        text-align: left;
        white-space: pre-wrap;
        word-break: break-all;
        max-width: 80%;
        margin-bottom: 10px;
    }
</style>
</head>
<body>
<p>****************************************************************<p>
<h1>当前服务器IP信息</h1>
<p>IP地址：$IPV4<p>
<p>****************************************************************<p>
<p>================================================================<p>
<h1>Xray协议信息</h1>
<p>Xray版本号：$version<p>
<p>----------------------------------------------------------------<p>
<p>1：Vmess+ws+tls配置明文如下，相关参数可复制到客户端<p>
<p>服务器地址：$HOST<p>
<p>端口：443<p>
<p>uuid：$UUID<p>
<p>传输协议：ws<p>
<p>host/sni：$HOST<p>
<p>path路径：$VMESS_WSPATH<p>
<p>tls：开启<p>
<p>----------------------------------------------------------------<p>
<p>Vmess链接：<p>
<p>$vm_link<p>
<p>----------------------------------------------------------------<p>
<p>Vmess二维码：<p>
<img src="$vm_img"/>
<p>================================================================<p>
<p>2：Vless+ws+tls配置明文如下，相关参数可复制到客户端<p>
<p>服务器地址：$HOST<p>
<p>端口：443<p>
<p>uuid：$UUID<p>
<p>传输协议：ws<p>
<p>host/sni：$HOST<p>
<p>path路径：$VLESS_WSPATH<p>
<p>tls：开启<p>
<p>----------------------------------------------------------------<p>
<p>Vless链接：<p>
<p>$vl_link<p>
<p>----------------------------------------------------------------<p>
<p>Vless二维码：<p>
<img src="$vl_img"/>
<p>================================================================<p>
<p>3：Trjan+ws+tls配置明文如下，相关参数可复制到客户端<p>
<p>服务器地址：$HOST<p>
<p>端口：443<p>
<p>密码：$UUID<p>
<p>传输协议：ws<p>
<p>host/sni：$HOST<p>
<p>path路径：$TR_WSPATH<p>
<p>tls：开启<p>
<p>----------------------------------------------------------------<p>
<p>Trojan链接：<p>
<p>$tr_link<p>
<p>----------------------------------------------------------------<p>
<p>Trojan二维码：<p>
<img src="$tr_img"/>
<p>================================================================<p>
<p>4：shadowsocks+ws+tls配置明文如下，相关参数可复制到客户端<p>
<p>服务器地址：$HOST<p>
<p>端口：443<p>
<p>密码：$UUID<p>
<p>加密方式：chacha20-ietf-poly1305<p>
<p>传输协议：ws<p>
<p>host/sni：$HOST<p>
<p>path路径：/${UUID}-ss<p>
<p>tls：开启<p>
<p>================================================================<p>
<p>5：socks+ws+tls配置明文如下，相关参数可复制到客户端<p>
<p>服务器地址：$HOST<p>
<p>端口：443<p>
<p>用户名：$UUID<p>
<p>密码：$UUID<p>
<p>传输协议：ws<p>
<p>host/sni：$HOST<p>
<p>path路径：/${UUID}-so<p>
<p>tls：开启<p>
<p>================================================================<p>
</body>
</html>
EOF

echo -e "\e[31m点击以下链接获取节点信息：\n\e[0mhttps://$HOST/$UUID.html\n\n\e[31mReplit节点保活日志：\e[0m"

while true
do
curl -s "https://$HOST" >/dev/null 2>&1 && echo "$(date +'%Y-%m-%d %H:%M:%S') Keeping online ..." && sleep 300
done &

$exe -config ~/app/config.json >/dev/null 2>&1 &
nginx -g 'daemon off;'
