# Install LAMP Stack
sudo yum update -y
sudo amazon-linux-extras install mariadb10.5
sudo amazon-linux-extras install php8.2
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd


