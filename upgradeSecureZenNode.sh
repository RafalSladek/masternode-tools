#!/bin/bash
sudo apt-get update -y
sudo apt-get install zen -y
sudo apt -y dist-upgrade
sudo apt -y autoremove
sudo apt-get clean
sudo apt-get autoclean
sudo rkhunter --propupd
sudo rkhunter -c --enable all --disable none --sk
sudo systemctl restart zen
sleep 80s && zenstatus
/usr/bin/certbot certificates
/usr/bin/certbot renew
checkzenservices