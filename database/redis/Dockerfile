# /database\redis\Dockerfile
FROM alpine:latest

RUN apk add --no-cache redis

COPY redis.conf /etc/redis.conf

EXPOSE 6379

CMD ["redis-server", "/etc/redis.conf"]
