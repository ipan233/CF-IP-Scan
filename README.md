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

## Deploy CF-IP-Scan to Render

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

## Deploy CF-IP-Scan to Heroku

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

## Deploy CF-IP-Scan to railway

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/-zIoi9)

## Deploy CF-IP-Scan to Local (Docker)

```bash
git clone https://github.com/3Kmfi6HP/CF-IP-Scan.git
cd CF-IP-Scan
docker build -t cf-ip-scan .
docker run -d --name cf-ip-scan cf-ip-scan
```

```bash
docker exec -it cf-ip-scan bash
```

## Deploy CF-IP-Scan to Local (Bash)

```bash
git clone https://github.com/3Kmfi6HP/CF-IP-Scan.git
cd CF-IP-Scan
bash entrypoint.sh
```

## Deploy CF-IP-Scan to Local (docker-compose)

```bash
git clone https://github.com/3Kmfi6HP/CF-IP-Scan.git
cd CF-IP-Scan
nano docker-compose.yml # edit your config
docker-compose up -d
```

done
