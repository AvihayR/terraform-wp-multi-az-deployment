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

FROM wordpress:php8.4-fpm-alpine
ARG WP_CONTENT_PATH=wp-content
RUN apk update && apk upgrade

COPY --from=wp_content_img /tmp/wpassets/${WP_CONTENT_PATH}/* /var/www/html/wp-content/