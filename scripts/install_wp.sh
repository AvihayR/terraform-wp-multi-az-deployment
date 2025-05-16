#!/bin/bash

# Install LAMP Stack
sudo yum update -y
sudo amazon-linux-extras install mariadb10.5
sudo amazon-linux-extras install php8.2
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd


# Change permissions and own apache's directory
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;


# Test php works in apache's directory 
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
