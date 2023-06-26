mkdir -p /usr/local/share/xray

cat >/root/download-dats.sh <<EOL
wget -O /usr/local/share/xray/geosite.dat https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat

wget -O /usr/local/share/xray/geoip.dat https://github.com/v2fly/geoip/releases/latest/download/geoip.dat

wget -O /usr/local/share/xray/iran.dat https://github.com/bootmortis/iran-hosted-domains/releases/latest/download/iran.dat

EOL

# remove cronjobs
sudo crontab -l | grep -v '/root/download-dats.sh' | crontab -

{ crontab -l -u root; echo "0 */4 * * * /bin/bash /root/download-dats.sh >/dev/null 2>&1"; } | crontab -u root -

bash /root/download-dats.sh

echo -e "\nDone\n"
