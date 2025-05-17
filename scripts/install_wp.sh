    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras install -y mariadb10.5
    sudo amazon-linux-extras install -y php8.2
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd

    sudo usermod -a -G apache ec2-user
    sudo chown -R ec2-user:apache /var/www
    sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
    find /var/www -type f -exec sudo chmod 0664 {} \;

    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    # sudo mv wordpress/* /var/www/html/


    # Write SQL commands to a temp file
    DB_USER="${var.db_username}"
    DB_PASS="${var.db_password}"
    DB_HOST="${module.rds.endpoint}"

    cat <<SQL > /tmp/init_wp.sql
    CREATE DATABASE \`wordpress-db\`;
    GRANT ALL PRIVILEGES ON \`wordpress-db\`.* TO '$DB_USER'@'%';
    FLUSH PRIVILEGES;
    SQL

    # Run the SQL script
    mysql -u"$DB_USER" -p"$DB_PASS" -h "$DB_HOST" < /tmp/init_wp.sql


    