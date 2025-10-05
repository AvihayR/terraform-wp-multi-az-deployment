ARG SECONDARY_REPO_URL
ARG SECONDARY_REPO_BRANCH=main
ARG WP_CONTENT_PATH=wp-content

FROM alpine/git:latest AS wp_content_img
ARG SECONDARY_REPO_URL
ARG SECONDARY_REPO_BRANCH
ARG WP_CONTENT_PATH
RUN if [ -n "$SECONDARY_REPO_URL" ]; then \
         git clone --depth 1 --branch "$SECONDARY_REPO_BRANCH" "$SECONDARY_REPO_URL" /tmp/wpassets; \
       else \
         echo "SECONDARY_REPO_URL not provided; building without external wp-content"; \
       fi

FROM wordpress:php8.4-apache
ARG WP_CONTENT_PATH=wp-content
RUN apt-get update && apt-get upgrade -y && apt-get clean


COPY --from=wp_content_img /tmp/wpassets/${WP_CONTENT_PATH} /var/www/html/wp-content/

# Initialize Wordpress connection to DB
RUN sudo sed -i "s/'DB_NAME', '.*'/'DB_NAME', '${var.db_name}'/" /var/www/html/wp-config.php && \
    sudo sed -i "s/'DB_USER', '.*'/'DB_USER', '${var.db_username}'/" /var/www/html/wp-config.php && \
    sudo sed -i "s/'DB_PASSWORD', '.*'/'DB_PASSWORD', '${var.db_password}'/" /var/www/html/wp-config.php && \
    sudo sed -i "s/'DB_HOST', '.*'/'DB_HOST', '${module.rds.endpoint}'/" /var/www/html/wp-config.php && \
    sudo sed -i 's/'localhost'/'${module.rds.endpoint}'/g' /var/www/html/wp-config.php && \
    sudo sed -i "s/'DB_PASSWORD', '.*'/'DB_PASSWORD', '$DB_PASSWORD'/" /var/www/html/wp-config.php && \
    sudo sed -i "s/'DB_USER', '.*'/'DB_USER', '$DB_USERNAME'/" /var/www/html/wp-config.php