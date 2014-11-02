# VERSION 0.1
# DOCKER-VERSION  0.9.1
# AUTHOR:         Ben Cao <zcao@freewheel.tv>
# DESCRIPTION:    Image with elasticsearch
# TO_BUILD:       docker build -t loga/es .
# TO_RUN:         docker run -d --name es -v $LOGA_EXPORT_DIR/es/data:/export/data -v $LOGA_EXPORT_DIR/es/work:/export/work -v $LOGA_EXPORT_DIR/es/logs:/export/logs -p 9200:9200 loga/es

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

# INSTALL Elastic Search to /opt/elasticsearch
RUN cd /tmp; wget --no-check-certificate https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.1.1.tar.gz -O elasticsearch.tar.gz
RUN cd /tmp; tar -zxvf elasticsearch.tar.gz; \
    rm elasticsearch.tar.gz
RUN mv /tmp/elasticsearch-* /opt/elasticsearch

ADD ./elasticsearch.yml /opt/elasticsearch/config/elasticsearch.yml
ADD ./logging.yml /opt/elasticsearch/config/logging.yml
ADD ./templates /opt/elasticsearch/config/templates
ADD ./start_elasticsearch.sh /opt/elasticsearch/bin/start_elasticsearch.sh
RUN chmod -R 755 /opt/elasticsearch/bin

VOLUME ["/export/data", "/export/work", "/export/logs"]

EXPOSE 9200
EXPOSE 9300

CMD ["/opt/elasticsearch/bin/start_elasticsearch.sh"]
