# VERSION 0.1
# DOCKER-VERSION  0.9.1
# AUTHOR:         Ben Cao <zcao@freewheel.tv>
# DESCRIPTION:    Image with schedulerd, which monitors the status of loga pipelines and control the pace of parsing logs to avoid system hanging
# TO_BUILD:       docker build -t loga/schedulerd .
# TO_RUN:         docker run -d --name schedulerd -v $LOGA_EXPORT_DIR/schedulerd/logs:/export/logs --link=uilogd:uilogd --link=logstash_tcp_to_redis:logstash_tcp_to_redis --link=logstash_redis_to_es:logstash_redis_to_es --link=redis:redis loga/schedulerd

FROM ubuntu:13.10

RUN apt-get update

# SETUP common packages for debug
RUN apt-get install -y vim curl wget

RUN apt-get install -y ruby ruby-dev
RUN apt-get install -y build-essential

RUN echo "gem: --no-rdoc --no-ri" > /etc/gemrc
RUN gem install bundler redis rest-client --no-ri --no-rdoc
RUN gem install pry --no-ri --no-rdoc

COPY ./schedulerd /opt/schedulerd
COPY ./start_schedulerd.sh /opt/schedulerd/start_schedulerd.sh
RUN chmod 755 /opt/schedulerd/start_schedulerd.sh

VOLUME ["/export/logs"]

CMD ["/opt/schedulerd/start_schedulerd.sh"]
