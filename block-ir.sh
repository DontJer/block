sudo apt-get install jq -y


cp /root/marzban/xray_config.json /root/marzban/xray_config.json.bak
export xray=$(cat /root/marzban/xray_config.json | jq '.routing.domainStrategy = "IPIfNonMatch"')

export xray=$(echo "$xray" | jq '.routing.rules[0].ip += ["geoip:ir"]')

export xray=$(echo "$xray" | jq '.routing.rules += [{"outboundTag": "blackhole", "domain": ["regexp:.*\\.ir$", "ext:iran.dat:ir", "ext:iran.dat:other", "geosite:category-ir", "blogfa", "bank", "tebyan.net", "beytoote.com", "Film2movie.ws", "Setare.com", "downloadha.com", "Sanjesh.org"], "type": "field"}]' )

export xray=$(echo "$xray" | jq '.outbounds |= map(if .protocol == "blackhole" then .tag = "blackhole" else . end)')

echo "$xray" > /root/marzban/xray_config.json

mkdir -p /var/lib/marzban/assets/

echo -e "\nXRAY_ASSETS_PATH=\"/var/lib/marzban/assets/\"" >> /root/marzban/env

cat >/root/download-dats.sh <<EOL
wget -O /var/lib/marzban/assets/geosite.dat https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat

wget -O /var/lib/marzban/assets/geoip.dat https://github.com/v2fly/geoip/releases/latest/download/geoip.dat

wget -O /var/lib/marzban/assets/iran.dat https://github.com/bootmortis/iran-hosted-domains/releases/latest/download/iran.dat

EOL

{ crontab -l -u root; echo "0 */4 * * * /bin/bash /root/download-dats.sh >/dev/null 2>&1"; } | crontab -u root -

bash /root/download-dats.sh

cd /root/marzban

docker compose down
sleep 3
docker compose up -d

echo -e "\nDone\n"
