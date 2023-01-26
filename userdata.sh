#!/bin/bash

yum install -y httpd
systemctl start httpd
systemctl enable httpd

echo "<html><h1>$(hostname)</h1></html>" > /var/www/html/index.html