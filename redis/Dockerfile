# VERSION 0.1
# DOCKER-VERSION  0.9.1
# AUTHOR:         Ben Cao <zcao@freewheel.tv>
# DESCRIPTION:    Image with redis, middle storage queue improved the robustness of whole system
# TO_BUILD:       docker build -t loga/redis .
# TO_RUN:         docker run -d --name redis -v $LOGA_EXPORT_DIR/redis/data:/export/data -v $LOGA_EXPORT_DIR/redis/logs:/export/logs loga/redis

FROM ubuntu:13.10

RUN apt-get update

# SETUP common packages for debug
RUN apt-get install -y vim curl wget

RUN apt-get install -y redis-server

RUN mkdir -p /opt/redis /export
ADD ./redis.conf /opt/redis/redis.conf
ADD ./start_redis.sh /opt/redis/start_redis.sh

RUN chmod 775 /opt/redis/start_redis.sh

VOLUME ["/export/data", "/export/logs"]

EXPOSE 6379

CMD ["/opt/redis/start_redis.sh"]
