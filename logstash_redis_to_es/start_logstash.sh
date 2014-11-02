#!/bin/bash

env

mkdir -p /opt/logstash/conf

cat << EOF > /opt/logstash/conf/redis_to_es.conf
input {
  redis {
    host => ["$REDIS_PORT_6379_TCP_ADDR"]
    port => $REDIS_PORT_6379_TCP_PORT
    data_type => "list"
    key => "log"
    threads => 2
  }
}

filter {
  speed_counter {}
}

output {
  elasticsearch {
    host => "$ES_PORT_9200_TCP_ADDR"
    port => "$ES_PORT_9200_TCP_PORT"
    protocol => "http"
    cluster => "es01"
    index => "mrm-%{+YYYY.MM.dd}"
    flush_size => 1000
  }
}
EOF

export LS_HEAP_SIZE="1200m"
/opt/logstash/bin/logstash --pluginpath /opt/logstash/conf/plugins -f /opt/logstash/conf/redis_to_es.conf --log /export/logs/logstash_redis_to_es.log
