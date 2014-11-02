#!/bin/bash

env

mkdir -p /opt/logstash/conf

cat << EOF > /opt/logstash/conf/tcp_to_redis.conf
input {
  tcp {
    port => 33333
  }
}

filter {
  parse_json {}
  speed_counter {}
  date {
    match => [ "time", "ISO8601" ]
  }
}

output {
  redis {
    batch => true
    batch_events => 50
    batch_timeout => 5
    codec => "plain"
    congestion_interval => 1
    congestion_threshold => 0
    data_type => "list"
    db => 0
    host => ["$REDIS_PORT_6379_TCP_ADDR"]
    key => "log"
    port => $REDIS_PORT_6379_TCP_PORT
    reconnect_interval => 1
    shuffle_hosts => true
    timeout => 5
    workers => 1
  }
}
EOF

export LS_HEAP_SIZE="1200m"
/opt/logstash/bin/logstash --pluginpath /opt/logstash/conf/plugins -f /opt/logstash/conf/tcp_to_redis.conf --log /export/logs/logstash_tcp_to_redis.log
