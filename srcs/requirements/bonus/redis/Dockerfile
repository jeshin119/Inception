FROM debian:bullseye

RUN apt-get update && apt-get install -y build-essential tcl curl

ENV REDIS_VERSION=7.0.0
RUN curl -O http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz \
    && tar xzvf redis-${REDIS_VERSION}.tar.gz \
    && rm redis-${REDIS_VERSION}.tar.gz

WORKDIR /redis-${REDIS_VERSION}
RUN make && make install

RUN mkdir /etc/redis
COPY redis.conf /etc/redis/redis.conf

EXPOSE 6379

CMD ["redis-server", "/etc/redis/redis.conf"]
