FROM alpine

# RUN wget https://github.com/nextcloud/notify_push/releases/download/v1.0.0/notify_push-`uname -m`-unknown-linux-musl -O /notify_push && chmod +x /notify_push && /notify_push --version
RUN wget https://github.com/nextcloud/notify_push/releases/download/v1.1.0/notify_push-x86_64-unknown-linux-musl -O /notify_push && chmod +x /notify_push && /notify_push --version

EXPOSE 7867

CMD ["/notify_push"]
