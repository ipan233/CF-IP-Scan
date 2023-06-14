# CF-IP-Scan

Cloudflare IP Scan
ip.txt 是存放你扫描好的 IP 地址列表
ddns.txt 文件存放的是 zone_id 和 域名 ID
其中缺少 iptest 测试程序，去 github 下载后改名为 iptest
按照数组顺序存放，示例里面是存放了三个域名 A 记录

查询 DNS 纪录

```bash
curl --location 'https://api.cloudflare.com/client/v4/zones/你的zoneid/dns_records' --header 'Authorization: Bearer 你的bearer密钥'
```

## Deploy Alist to Render

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

## Deploy Alist to Heroku

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

## Deploy Alist to railway

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/-zIoi9)

done
