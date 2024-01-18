#!/bin/bash
sudo apt update
sudo apt install apache2 unzip -y
sudo systemctl start apache2
mkdir -p /tmp/webfiles
sudo wget https://www.tooplate.com/zip-templates/2137_barista_cafe.zip -O /tmp/webfiles/2137_barista_cafe.zip
cd /tmp/webfiles/
unzip /tmp/webfiles/2137_barista_cafe.zip 
sudo mv /tmp/webfiles/2137_barista_cafe/* /var/www/html/
sudo systemctl restart apache2
