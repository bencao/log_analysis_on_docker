# VERSION 0.1
# DOCKER-VERSION  0.9.1
# AUTHOR:         Ben Cao <zcao@freewheel.tv>
# DESCRIPTION:    Image with logstash_redis_to_es, reading data from redis queue then update elasticsearch index accordingly
# TO_BUILD:       docker build -t loga/logstash_redis_to_es .
# TO_RUN:         docker run -d --name logstash_redis_to_es -v $LOGA_EXPORT_DIR/logstash/logs:/export/logs --link=redis:redis --link=es:es loga/logstash_redis_to_es

FROM ubuntu:13.10

# SETUP necessary packages
RUN apt-get update

# SETUP common packages for debug
RUN apt-get install -y vim curl wget

# Fake a fuse install(for jre)
RUN apt-get install -y adduser libfuse2
RUN cd /tmp ; apt-get download fuse
RUN cd /tmp ; dpkg-deb -x fuse_* .
RUN cd /tmp ; dpkg-deb -e fuse_*
RUN cd /tmp ; rm fuse_*.deb
RUN cd /tmp ; echo -en '#!/bin/bash\nexit 0\n' > DEBIAN/postinst
RUN cd /tmp ; dpkg-deb -b . /fuse.deb
RUN cd /tmp ; dpkg -i /fuse.deb

RUN apt-get install -y default-jre wget

# INSTALL logstash to /opt/logstash
RUN cd /tmp; wget --no-check-certificate https://download.elasticsearch.org/logstash/logstash/logstash-1.4.1.tar.gz -O logstash.tar.gz
RUN cd /tmp; tar -zxvf logstash.tar.gz; \
    rm logstash.tar.gz
RUN mv /tmp/logstash-* /opt/logstash

ADD ./plugins /opt/logstash/conf/plugins
ADD ./start_logstash.sh /opt/logstash/bin/start_logstash.sh
RUN chmod -R 755 /opt/logstash/bin

EXPOSE 7788

CMD ["/opt/logstash/bin/start_logstash.sh"]
