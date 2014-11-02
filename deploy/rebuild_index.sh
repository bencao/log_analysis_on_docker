#!/bin/bash

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

LOGSTASH_REDIS_TO_ES_CONTAINER=`docker ps -a | grep loga/logstash_redis_to_es | awk '{print $1}'`
if [ -n $LOGSTASH_REDIS_TO_ES_CONTAINER ]
then
  echo "stopping logstash_redis_to_es container..."
  docker stop $LOGSTASH_REDIS_TO_ES_CONTAINER
fi

ES_CONTAINER=`docker ps -a | grep loga/elasticsearch | awk '{print $1}'`
if [ -n $ES_CONTAINER ]
then
  echo "stopping es container..."
  docker stop $ES_CONTAINER
fi

TIMESTAMP=`date +%Y%m%d%H%M%S`
mv $LOGA_EXPORT_DIR/es/data $LOGA_EXPORT_DIR/es/data_$TIMESTAMP
mkdir -p $LOGA_EXPORT_DIR/es/data

echo "starting es container..."
docker start $ES_CONTAINER

echo "staring logstash_redis_to_es container..."
docker start $LOGSTASH_REDIS_TO_ES_CONTAINER

echo "touch all gz files so we will start build index"
find $LOGA_IMPORT_DIR -name '*gz' -exec touch {} +
