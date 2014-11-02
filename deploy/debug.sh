#!/bin/bash

DEBUG_COMPONENT=$1

echo "=> checking environment variable..."

if [ -z $LOGA_DIR ]
then
  echo "please set LOGA_DIR environment variable"
  exit 1
fi

if [ -z $LOGA_IMPORT_DIR ]
then
  echo "please set LOGA_IMPORT_DIR environment variable"
  exit 1
fi

if [ -z $LOGA_EXPORT_DIR ]
then
  echo "please set LOGA_EXPORT_DIR environment variable"
  exit 1
fi

# stop running container
if [ `docker ps | grep loga/$DEBUG_COMPONENT:latest | wc -l` -gt 0 ]
then
  COMPONENT_CONTAINER_ID=`docker ps | grep loga/$DEBUG_COMPONENT:latest | awk '{print $1}'`
  echo "=> stopping running container $COMPONENT_CONTAINER_ID..."
  docker stop $COMPONENT_CONTAINER_ID
  docker rm $COMPONENT_CONTAINER_ID
fi

case "$DEBUG_COMPONENT" in
  elasticsearch)
    docker run -it --rm \
      -v $LOGA_EXPORT_DIR/es/data:/export/data \
      -v $LOGA_EXPORT_DIR/es/work:/export/work \
      -v $LOGA_EXPORT_DIR/es/logs:/export/logs \
      -p 9200:9200 \
      loga/elasticsearch \
      /bin/bash;;
  redis)
    docker run -it --rm \
      -v $LOGA_EXPORT_DIR/redis/data:/export/data \
      -v $LOGA_EXPORT_DIR/redis/logs:/export/logs \
      loga/redis \
      /bin/bash;;
  logstash_redis_to_es)
    docker run -it --rm \
      -v $LOGA_EXPORT_DIR/logstash/logs:/export/logs \
      --link=redis:redis \
      --link=elasticsearch:es \
      loga/logstash_redis_to_es \
      /bin/bash;;
  logstash_tcp_to_redis)
    docker run -it --rm \
      -v $LOGA_EXPORT_DIR/logstash/logs:/export/logs \
      --link=redis:redis \
      loga/logstash_tcp_to_redis \
      /bin/bash;;
  monitord)
    docker run -it --rm \
      -v $LOGA_IMPORT_DIR:/import \
      -v $LOGA_EXPORT_DIR/monitord/logs:/export/logs \
      --link=logstash_tcp_to_redis:logstash_tcp_to_redis \
      -p 4567:4567 \
      loga/monitord \
      /bin/bash;;
  kibana)
    docker run -it --rm \
      -p 8000:8000 \
      loga/kibana \
      /bin/bash;;
  schedulerd)
    docker run -it --rm \
      -v $LOGA_EXPORT_DIR/schedulerd/logs:/export/logs \
      --link=monitord:monitord \
      --link=logstash_tcp_to_redis:logstash_tcp_to_redis \
      --link=logstash_redis_to_es:logstash_redis_to_es \
      --link=redis:redis \
      loga/schedulerd \
      /bin/bash;;
esac
