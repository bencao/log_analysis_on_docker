# VERSION 0.1
# DOCKER-VERSION  0.9.1
# AUTHOR:         Ben Cao <zcao@freewheel.tv>
# DESCRIPTION:    Image with monitord, which monitor the file changes and send them to logstash_tcp_to_redis port
# TO_BUILD:       docker build -t loga/monitord .
# TO_RUN:         docker run -d --name monitord -v $LOGA_IMPORT_DIR:/import -v $LOGA_EXPORT_DIR/monitord/logs:/export/logs --link=logstash_tcp_to_redis:logstash_tcp_to_redis loga/monitord

FROM ubuntu:13.10

RUN apt-get update

# SETUP common packages for debug
RUN apt-get install -y vim curl wget

RUN apt-get install -y ruby ruby-dev
RUN apt-get install -y build-essential

RUN echo "gem: --no-rdoc --no-ri" > /etc/gemrc
RUN gem install bundler listen --no-ri --no-rdoc

ADD ./monitord /opt/monitord
ADD ./start_monitord.sh /opt/monitord/start_monitord.sh
RUN chmod 755 /opt/monitord/start_monitord.sh

VOLUME ["/import", "/export/logs"]

EXPOSE 4567

CMD ["/opt/monitord/start_monitord.sh"]
