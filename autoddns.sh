#!/bin/bash
# CF中转IP自动更新
# API Bearer密钥,在 https://dash.cloudflare.com/profile/api-tokens 创建编辑区域 DNS
bearer=$TOKEN
# 设置最小速度kB/s
speed=${SPEED:-1000}
# 设置数据中心
colo=${COLO:-SIN}
# 设置最大延迟ms
maxms=${MAXMS:-100}
# 设置每个域名A记录数量
num=${NUM:-4}
# TLS端口
tlsport=${TLSPORT:-443}
# 非TLS端口
notlsport=${NOTLSPORT:-80}
# 是否启用TLS,1.启用,0.禁用
tls=${TLS:-1}
# Telegram Bot Token
token=$TG_TOKEN
# Telegram Chat ID
chat_id=$CHAT_ID

chmod +x iptest
while true; do
    n=0
    m=0
    startdate=$(date +'%Y%m%d')
    if [ $tls == 1 ]; then
        ./iptest -port=$tlsport -outfile=$tlsport.csv -max=50 -tls=true -speedtest=0
        grep $colo $tlsport.csv | awk -F, '{print $1,$7}' | awk '$2 <= '$maxms' {print $1}' >$tlsport.txt
        ./iptest -file=$tlsport.txt -port=$tlsport -outfile=ip.csv -max=50 -tls=true -speedtest=2
    else
        ./iptest -port=$notlsport -outfile=$notlsport.csv -max=50 -tls=false -speedtest=0
        grep $colo $notlsport.csv | awk -F, '{print $1,$7}' | awk '$2 <= '$maxms' {print $1}' >$notlsport.txt
        ./iptest -file=$notlsport.txt -port=$notlsport -outfile=ip.csv -max=50 -tls=false -speedtest=2
    fi
    unset temp
    for i in $(grep ms ip.csv | awk -F, '{print $1,$8}' | awk '$2 >= '$speed' {print $1}'); do
        if [ "$(date +'%Y%m%d')" == "$startdate" ]; then
            if [ $tls == 1 ]; then
                http_code=$(curl -A "" --retry 2 --resolve cp.cloudflare.com:$tlsport:$i -s https://cp.cloudflare.com:$tlsport -w %{http_code} --connect-timeout 2 --max-time 3)
            else
                http_code=$(curl -A "" --retry 2 -x $i:$notlsport -s http://cp.cloudflare.com:$notlsport -w %{http_code} --connect-timeout 2 --max-time 3)
            fi
            if [ "$http_code" == "204" ]; then
                echo "$(date +'%H:%M:%S') $i 状态正常"
                for ipinfo in $(grep -w $m ddns.txt | tr -d '\r' | awk '{print $1"#"$2"#"$3"#"$4}'); do
                    echo -e "\n=============================================\n"
                    ip_array=($(echo $ipinfo | tr '#' ' '))
                    echo $ipinfo

                    id=${ip_array[0]} # 去掉 $ 符号，正确地给变量赋值
                    name=${ip_array[1]}
                    zone_id=${ip_array[2]}
                    record_id=${ip_array[3]}

                    echo $id
                    echo $name
                    echo $zone_id
                    echo $record_id

                    result=$(curl -s --retry 3 -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$record_id" -H "Authorization: Bearer $bearer" -H "Content-Type:application/json" --data '{"type":"A","name":"'"$(echo $name)"'","content":"'"$i"'","ttl":60,"proxied":false}')
                    success=$(echo $result | jq '.success')

                    if [ $success = true ]; then
                        echo "更新成功"
                        msg="更新域名\n$(echo -e "${name//\#/\\n}")\n成功"
                    else
                        echo "更新失败：$result"
                        msg="更新域名\n$(echo -e "${ipinfo//\#/\\n}")\n失败：$result"
                    fi

                    echo 故障推送telegram
                    # 这里可以自定义你的curl推送命令
                    curl -s -X POST https://api.telegram.org/bot$token/sendMessage -d chat_id=$chat_id -d text="$msg"
                    echo -e "\n=============================================\n"
                done
                temp[$m]=$(echo $m-$i)
                echo ${temp[@]}
                n=$(($n + 1))
                m=$(($m + 1))
                if [ $n == $num ]; then
                    echo 进入状态监测
                    sleep 5
                    while true; do
                        if [ $n != $num ]; then
                            break
                        else
                            for i in $(echo ${temp[@]} | sed -e 's/ /\n/g'); do
                                if [ "$(date +'%Y%m%d')" == "$startdate" ]; then
                                    if [ $tls == 1 ]; then
                                        http_code=$(curl -A "" --retry 2 --resolve cp.cloudflare.com:$tlsport:$(echo $i | awk -F- '{print $2}') -s https://cp.cloudflare.com:$tlsport -w %{http_code} --connect-timeout 2 --max-time 3)
                                    else
                                        http_code=$(curl -A "" --retry 2 -x $(echo $i | awk -F- '{print $2}'):$notlsport -s http://cp.cloudflare.com:$notlsport -w %{http_code} --connect-timeout 2 --max-time 3)
                                    fi
                                    if [ "$http_code" != "204" ]; then
                                        n=$(($n - 1))
                                        m=$(echo ${temp[@]} | sed -e 's/ /\n/g' | awk -F- '{print $1" "$2}' | grep -w $(echo $i | awk -F- '{print $2}') | awk '{print $1}')
                                        echo "$(date +'%H:%M:%S') $(echo $i | awk -F- '{print $2}') 发生故障"
                                        echo 故障推送telegram
                                        #这里可以自定义你的curl推送命令 push message to telegram
                                        curl -s -X POST https://api.telegram.org/bot$token/sendMessage -d chat_id=$chat_id -d text="CF中转IP故障\n$(echo $i | awk -F- '{print $2}')"
                                        break
                                    else
                                        echo "$(date +'%H:%M:%S') $(echo $i | awk -F- '{print $2}') 状态正常"
                                        sleep 5
                                    fi
                                else
                                    n=$(($n - 1))
                                    break
                                fi
                            done
                        fi
                    done
                fi
            fi
        else
            echo 新的一天开始了
            break
        fi
    done
done
