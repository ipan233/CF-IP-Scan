#!/bin/bash

# This script creates multiple Cloudflare DNS records with the same name and different IP addresses.

# Import the necessary libraries.

curl=$(command -v curl)
jq=$(command -v jq)

# Check if the required libraries are installed.

if [ ! -x "$curl" ]; then
    echo "Error: The $(curl) command is not installed."
    exit 1
fi

if [ ! -x "$jq" ]; then
    echo "Error: The $(jq) command is not installed."
    exit 1
fi

# Get the Cloudflare API zone ID.

echo "Enter your Cloudflare zone ID:"
read zone_id

# Get the Cloudflare domain name.
echo "Enter your Cloudflare domain name:"
read domain

echo "Enter your Cloudflare API key:"
read key

# Get the list of IP addresses from the `ip.txt` file.

# ips=$(cat ip.txt)
ips=$(grep ms ip.csv | awk -F, '{if ($8 >= speed) print $1}')

# Create a for loop to iterate over the IP addresses.
count=0
for ip in $ips; do

    # Create a new DNS record with the specified IP address.

    record=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records" \
        -H "Authorization: Bearer $key" \
        -H "Content-Type: application/json" \
        -d '{
        "name": "'"$domain"'",
        "type": "A",
        "content": "'"$ip"'",
        "ttl": 60,
        "proxied": false
    }')
    # Check if the record was created successfully.

    if [[ $(echo "$record" | jq -r '.success') != "null" ]]; then
        id=$(echo -e $record | jq -r '.result.id')
        echo "$count $domain $zone_id $id" >>output.txt
        ((count++))
        echo "Record created successfully for IP address $ip."
    else
        echo "Error creating record for IP address $ip."
    fi

done
