# CF-IP-Scan

Cloudflare IP Scan
ip.txt是存放你扫描好的IP地址列表
ddns.txt文件存放的是zone_id 和 域名ID
其中缺少 iptest 测试程序，去github下载后改名为 iptest
按照数组顺序存放，示例里面是存放了三个域名A记录

查询DNS纪录

```bash
curl --location 'https://api.cloudflare.com/client/v4/zones/你的zoneid/dns_records' --header 'Authorization: Bearer 你的bearer密钥'
```
