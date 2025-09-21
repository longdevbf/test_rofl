FROM docker.io/alpine:3.21.2

# Add some dependencies.
RUN apk add --no-cache curl jq

ADD app.sh /app.sh
RUN chmod +x /app.sh
ENTRYPOINT ["/app.sh"]