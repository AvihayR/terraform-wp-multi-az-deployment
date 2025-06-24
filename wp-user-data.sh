<<-EOT
    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras install -y mariadb10.5
    sudo amazon-linux-extras install -y php8.2
    sudo yum install -y httpd
    sudo yum install -y git

    sudo systemctl start httpd
    sudo systemctl enable httpd

    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    sudo mv wordpress/* /var/www/html/
    git clone ${var.wp_blog_repo}
    sudo rsync -a wp-blog/wp-content/ /var/www/html/wp-content

    sudo usermod -a -G apache ec2-user
    sudo chown -R apache:apache /var/www
    sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
    find /var/www -type f -exec sudo chmod 0664 {} \;

    DB_USER="${var.db_username}"
    DB_PASS="${var.db_password}"
    DB_HOST="${module.rds.endpoint}"

    # Write SQL commands to a temp file
    cat > /tmp/init_wp.sql <<EOF
    GRANT ALL PRIVILEGES ON \`${var.db_name}\`.* TO '${var.db_username}'@'%';
    FLUSH PRIVILEGES;
    EOF

    mysql -u"${var.db_username}" -p"${var.db_password}" -h "${module.rds.endpoint}" < /tmp/init_wp.sql

    # Run the SQL script
    mysql -u"$DB_USER" -p"$DB_PASS" -h "$DB_HOST" < /tmp/init_wp.sql

    # Initialize Wordpress connection to DB
    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
    mysql -u"$DB_USER" -p"$DB_PASS" -h "$DB_HOST" < wp-blog-demo-app/wpdb.sql
    sudo sed -i "s/'DB_NAME', '.*'/'DB_NAME', '${var.db_name}'/" /var/www/html/wp-config.php
    sudo sed -i "s/'DB_USER', '.*'/'DB_USER', '${var.db_username}'/" /var/www/html/wp-config.php
    sudo sed -i "s/'DB_PASSWORD', '.*'/'DB_PASSWORD', '${var.db_password}'/" /var/www/html/wp-config.php
    sed -i "s/'DB_HOST', '.*'/'DB_HOST', '${module.rds.endpoint}'/" /var/www/html/wp-config.php
    sudo sed -i 's/'localhost'/'${module.rds.endpoint}'/g' /var/www/html/wp-config.php

    # Load wp db backup
    sudo sed -i 's/'YOUR_RDS_ENDPOINT'/'${module.rds.endpoint}'/g' wp-blog/sql/wp-db-backup.sql
    sudo sed -i "s#YOUR_ALB_DNS_NAME#http://${module.application_load_balancer.lb_dns_name}#g" wp-blog/sql/wp-db-backup.sql
    mysql -u"$DB_USER" -p"$DB_PASS" -h "$DB_HOST" < wp-blog/sql/wp-db-backup.sql
    echo "${module.application_load_balancer.lb_dns_name}" > /home/ec2-user/alb.txt

    # Create a envoirnment variable setup script
    sudo tee /usr/local/bin/wp-env-inject.sh > /dev/null <<'EOF'
    #!/bin/bash

    # Fetch values from SSM
    DB_USERNAME=$(aws ssm get-parameter --name "/wordpress/db_username" --with-decryption --query "Parameter.Value" --output text --region "${var.region}")
    DB_PASSWORD=$(aws ssm get-parameter --name "/wordpress/db_password" --with-decryption --query "Parameter.Value" --output text --region "${var.region}")

    # Export as env vars
    echo "export DB_USERNAME='$DB_USERNAME'" >> /etc/profile.d/wordpress.sh
    echo "export DB_PASSWORD='$DB_PASSWORD'" > /etc/profile.d/wordpress.sh
    chmod 600 /etc/profile.d/wordpress.sh

    # Update wp-config.php
    sed -i "s/'DB_PASSWORD', '.*'/'DB_PASSWORD', '$DB_PASSWORD'/" /var/www/html/wp-config.php
    sed -i "s/'DB_USER', '.*'/'DB_USER', '$DB_USERNAME'/" /var/www/html/wp-config.php
    EOF

    sudo chmod +x /usr/local/bin/wp-env-inject.sh

    # Create a service that uses the injection env var script
    sudo tee /etc/systemd/system/wp-env-inject.service > /dev/null <<'EOF'
    [Unit]
    Description=Inject WordPress DB credentials from SSM into wp-config
    After=network.target

    [Service]
    ExecStart=/usr/local/bin/wp-env-inject.sh
    Restart=on-failure 

    [Install]
    WantedBy=multi-user.target
    EOF

    sudo systemctl daemon-reload
    sudo systemctl start wp-env-inject.service
    sudo systemctl enable wp-env-inject.service
  EOT