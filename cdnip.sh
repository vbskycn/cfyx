#!/bin/bash
export LANG=en_US.UTF-8
point=443
IP_ADDR=ipv4
x_email=zhoujie218@gmail.com
hostname=(cf1.dnwx.vip cf2.dnwx.vip cf3.dnwx.vip cf4.dnwx.vip cf5.dnwx.vip)
zone_id=2780d5c24bd4273415b4a34089a1fe3a
api_key=e57322a8e3f13979c6427991ba8ecdeb3b19f
pause=true
clien=1
 
CFST_URL_R="-url https://speed.bestip.one/__down?bytes=50000000"

CFST_N=200

CFST_T=4

CFST_DN=10

CFST_TL=250

CFST_TLL=40

CFST_SL=5

telegramBotToken=6498531824:AAH3r_jkiSBS4kQzJ_8r5hBzimjci8z6Zc8
telegramBotUserId=615392780

CFST_SPD=""
ymorip=1

tgaction(){
echo $pushmessage
message_text=$pushmessage
#解析模式，可选HTML或Markdown
MODE='HTML'
#api接口
URL="https://api.telegram.org/bot${telegramBotToken}/sendMessage"
if [[ -z ${telegramBotToken} ]]; then
   echo "未配置TG推送"
else
   res=$(timeout 20s curl -s -X POST $URL -d chat_id=${telegramBotUserId}  -d parse_mode=${MODE} -d text="${message_text}")
   if [ $? == 124 ];then
      echo 'TG_api请求超时,请检查网络是否重启完成并是否能够访问TG'          
      exit 1
   fi
   resSuccess=$(echo "$res" | jq -r ".ok")
   if [[ $resSuccess = "true" ]]; then
      echo "TG推送成功";
	  cd /root/cfipopw/ && bash sudu.sh
      else
      echo "TG推送失败，请检查TG机器人token和ID";
   fi
fi
}
cd /root/cfipopw/ && rm -rf informlog && bash cdnac.sh
if [ "$ymorip" == "1" ]; then
ipv4Regex="((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])";
proxy="false";
res=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}" -H "X-Auth-Email:$x_email" -H "X-Auth-Key:$api_key" -H "Content-Type:application/json");
resSuccess=$(echo "$res" | jq -r ".success");
if [[ $resSuccess != "true" ]]; then
    pushmessage="登陆错误,检查cloudflare邮箱、区域ID、API Key，这三者的信息填写是否正确！"
    tgaction;
    exit 1;
fi
echo "Cloudflare账号验证成功";
#获取域名填写数量
num=${#hostname[*]};
#判断优选ip数量是否大于域名数，小于则让优选数与域名数相同
if [ "$CFST_DN" -le $num ] ; then
	CFST_DN=$num;
fi
fi
CFST_P=$CFST_DN;
#判断工作模式
if [ "$IP_ADDR" = "ipv6" ] ; then
    if [ ! -f "ipv6.txt" ]; then
        echo "当前工作模式为ipv6，但该目录下没有【ipv6.txt】，请配置【ipv6.txt】。下载地址：https://github.com/XIU2/CloudflareSpeedTest/releases";
        exit 2;
        else
            echo "当前工作模式为ipv6";
    fi
    else
        echo "当前工作模式为ipv4";
fi

#读取配置文件中的客户端
case $clien in
  "6") CLIEN=bypass;;
  "5") CLIEN=openclash;;
  "4") CLIEN=clash;;
  "3") CLIEN=shadowsocksr;;
  "2") CLIEN=passwall2;;
  *) CLIEN=passwall;;
esac

#判断是否停止科学上网服务
if [ "$pause" = "false" ] ; then
	echo "按要求未停止科学上网服务";
else
	/etc/init.d/$CLIEN stop;
	echo "已停止$CLIEN";
fi


if [ "$IP_ADDR" = "ipv6" ] ; then
    ./cfst -tp $point $CFST_URL_R -t $CFST_T -n $CFST_N -dn $CFST_DN -p $CFST_DN -tl $CFST_TL -tll $CFST_TLL -sl $CFST_SL -f ipv6.txt $CFST_SPD
    else
    ./cfst -tp $point $CFST_URL_R -t $CFST_T -n $CFST_N -dn $CFST_DN -p $CFST_DN -tl $CFST_TL -tll $CFST_TLL -sl $CFST_SL $CFST_SPD
fi

echo "测速完毕";
if [ "$pause" = "false" ] ; then
		echo "按要求未重启科学上网服务";
		sleep 3s;
else
                                /etc/init.d/$CLIEN start;
		sleep 5s;
		/etc/init.d/$CLIEN restart;
		echo "已重启$CLIEN";
		echo "请稍等45秒";
		sleep 45s;
fi
if [ "$ymorip" == "1" ]; then
#开始循环
echo "正在更新域名，请稍后...";
x=0;
while [[ ${x} -lt $num ]]; do
    CDNhostname=${hostname[$x]};
    #获取优选后的ip地址

    ipAddr=$(sed -n "$((x + 2)),1p" result.csv | awk -F, '{print $1}');
    echo "开始更新第$((x + 1))个---$ipAddr";
    #开始DDNS
    if [[ $ipAddr =~ $ipv4Regex ]]; then
        recordType="A";
    else
        recordType="AAAA";
    fi

    listDnsApi="https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records?type=${recordType}&name=${CDNhostname}";
    createDnsApi="https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records";

    res=$(curl -s -X GET "$listDnsApi" -H "X-Auth-Email:$x_email" -H "X-Auth-Key:$api_key" -H "Content-Type:application/json");
    recordId=$(echo "$res" | jq -r ".result[0].id");
    recordIp=$(echo "$res" | jq -r ".result[0].content");

    if [[ $recordIp = "$ipAddr" ]]; then
        echo "更新失败，获取最快的IP与云端相同";
        resSuccess=false;
    elif [[ $recordId = "null" ]]; then
        res=$(curl -s -X POST "$createDnsApi" -H "X-Auth-Email:$x_email" -H "X-Auth-Key:$api_key" -H "Content-Type:application/json" --data "{\"type\":\"$recordType\",\"name\":\"$CDNhostname\",\"content\":\"$ipAddr\",\"proxied\":$proxy}");
        resSuccess=$(echo "$res" | jq -r ".success");
    else
        updateDnsApi="https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records/${recordId}";
        res=$(curl -s -X PUT "$updateDnsApi"  -H "X-Auth-Email:$x_email" -H "X-Auth-Key:$api_key" -H "Content-Type:application/json" --data "{\"type\":\"$recordType\",\"name\":\"$CDNhostname\",\"content\":\"$ipAddr\",\"proxied\":$proxy}");
        resSuccess=$(echo "$res" | jq -r ".success");
    fi

    if [[ $resSuccess = "true" ]]; then
        echo "$CDNhostname更新成功";
    else
        echo "$CDNhostname更新失败";
    fi

    x=$((x + 1));
    sleep 3s;

done > informlog
else
echo "优选IP排名如下" > informlog
awk -F ',' 'NR > 1 {print $1}' result.csv >> informlog
fi
bash cdnac.sh
pushmessage=$(cat informlog);
tgaction
echo
echo "切记：在软路由-计划任务选项中，加入优选IP自动执行时间的cron表达式"
echo "比如每天早上三点执行：0 3 * * * cd /root/cfipopw/ && bash cdnip.sh"
echo
rm -rf informlog
exit 0;
