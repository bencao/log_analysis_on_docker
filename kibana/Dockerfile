# VERSION 0.1
# DOCKER-VERSION  0.9.1
# AUTHOR:         Ben Cao <zcao@freewheel.tv>
# DESCRIPTION:    Image with kibana, the perfect UI showing data from elasticsearch
# TO_BUILD:       docker build -t loga/kibana .
# TO_RUN:         docker run -d --name kibana -p 8000:8000 loga/kibana

FROM ubuntu:13.10

# SETUP necessary packages
RUN apt-get update;

# SETUP common packages for debug
RUN apt-get install -y vim curl wget

RUN apt-get install -y python

# INSTALL kibana to /opt/kibana
RUN cd /tmp; wget --no-check-certificate https://download.elasticsearch.org/kibana/kibana/kibana-3.1.0.tar.gz -O kibana.tar.gz
RUN cd /tmp; tar -zxvf kibana.tar.gz; \
    rm kibana.tar.gz
RUN mv /tmp/kibana-* /opt/kibana

ADD ./start_kibana.sh /opt/kibana/start_kibana.sh
RUN chmod 755 /opt/kibana/start_kibana.sh

EXPOSE 8000

CMD ["/opt/kibana/start_kibana.sh"]
