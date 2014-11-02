#!/bin/bash
print_usage() {
  echo >&2 "usage: $0 [-a] [-f] [-v] [component1 component2 ...]"
  echo >&2 "  -a, redeploy all components"
  echo >&2 "  -f, clean up docker images when redeploy"
  echo >&2 "  -v, verbose mode, will output more logs"
  echo >&2 "  available components are: ${ALL_COMPONENTS[@]}"
}

exit_on_failure() {
  if [ $? -ne 0 ]
  then
    echo "=> fail to redeploy because some errors happened"
    exit 1
  fi
}

# handling command line flags
VERBOSE=off
CLEAN_UP_IMAGES=off
ALL_COMPONENTS=(elasticsearch redis logstash_redis_to_es logstash_tcp_to_redis monitord kibana schedulerd)
REDEPLOY_COMPONENTS=()
while getopts fav opt
do
  case "$opt" in
    v) VERBOSE=on;;
    a) REDEPLOY_COMPONENTS=(${ALL_COMPONENTS[@]});;
    f) CLEAN_UP_IMAGES=on;;
    \?)
      print_usage
      exit 1;;
  esac
done
shift `expr $OPTIND - 1`

# to make sure REDEPLOY_COMPONENTS is in proper order
if [ ${#REDEPLOY_COMPONENTS[@]} -eq 0 ]
then
  if [ $# -eq 0 ]
  then
    print_usage
    exit 1
  fi

  for i in ${ALL_COMPONENTS[@]}
  do
    for j in $@
    do
      if [ "$j" = "$i" ]
      then
        REDEPLOY_COMPONENTS+=($i)
      fi
    done
  done
fi

echo "=> components to redeploy: ${REDEPLOY_COMPONENTS[@]}"

if [ "$VERBOSE" = "on" ]
then
  COMMAND_OUT="/dev/stdout"
  COMMAND_ERR="/dev/stderr"
else
  COMMAND_OUT="/dev/null"
  COMMAND_ERR="/dev/stderr"
fi

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

echo "=> removing existing docker containers..."

for component in ${REDEPLOY_COMPONENTS[@]}
do
  if [ `docker ps -a | grep loga/$component:latest | wc -l` -gt 0 ]
  then
    docker ps -a | grep loga/$component:latest | awk '{print $1}' | xargs docker rm -f >$COMMAND_OUT 2>$COMMAND_ERR
  fi
done

if [ "$CLEAN_UP_IMAGES" = "on" ]
then
  echo "=> cleaning up existing docker images..."

  if [ `docker images | grep '<none>' | wc -l` -gt 0 ]
  then
    echo "   -> cleaning up <none> images"
    docker images | grep '<none>' | awk '{print $3}' | xargs docker rmi -f >$COMMAND_OUT 2>$COMMAND_ERR
  fi

  for component in ${REDEPLOY_COMPONENTS[@]}
  do
    echo "   -> cleaning up loga/$component:latest image"
    if [ `docker images | grep loga/$component | grep latest | wc -l` -gt 0 ]
    then
      docker images | grep loga/$component | grep latest | awk '{print $3}' | xargs docker rmi -f >$COMMAND_OUT 2>$COMMAND_ERR
    fi
  done
fi

echo "=> building docker images..."

for component in ${REDEPLOY_COMPONENTS[@]}
do
  echo "   -> building loga/$component:latest"
  cd $LOGA_DIR/$component
  docker build -t loga/$component . >$COMMAND_OUT 2>$COMMAND_ERR
  exit_on_failure
done

echo "=> run docker containers..."

for component in ${REDEPLOY_COMPONENTS[@]}
do
  echo "   -> run $component..."
  case "$component" in
    elasticsearch)
      docker run -d --name elasticsearch \
        -v $LOGA_EXPORT_DIR/es/data:/export/data \
        -v $LOGA_EXPORT_DIR/es/work:/export/work \
        -v $LOGA_EXPORT_DIR/es/logs:/export/logs \
        -p 9200:9200 \
        loga/elasticsearch \
        >$COMMAND_OUT 2>$COMMAND_ERR;;
    redis)
      docker run -d --name redis \
        -v $LOGA_EXPORT_DIR/redis/data:/export/data \
        -v $LOGA_EXPORT_DIR/redis/logs:/export/logs \
        loga/redis \
        >$COMMAND_OUT 2>$COMMAND_ERR;;
    logstash_redis_to_es)
      docker run -d --name logstash_redis_to_es \
        -v $LOGA_EXPORT_DIR/logstash/logs:/export/logs \
        --link=redis:redis \
        --link=elasticsearch:es \
        loga/logstash_redis_to_es \
        >$COMMAND_OUT 2>$COMMAND_ERR;;
    logstash_tcp_to_redis)
      docker run -d --name logstash_tcp_to_redis \
        -v $LOGA_EXPORT_DIR/logstash/logs:/export/logs \
        --link=redis:redis \
        loga/logstash_tcp_to_redis \
        >$COMMAND_OUT 2>$COMMAND_ERR;;
    monitord)
      docker run -d --name monitord \
        -v $LOGA_IMPORT_DIR:/import \
        -v $LOGA_EXPORT_DIR/monitord/logs:/export/logs \
        --link=logstash_tcp_to_redis:logstash_tcp_to_redis \
        -p 4567:4567 \
        loga/monitord \
        >$COMMAND_OUT 2>$COMMAND_ERR;;
    kibana)
      docker run -d --name kibana \
        -p 8000:8000 \
        loga/kibana \
        >$COMMAND_OUT 2>$COMMAND_ERR;;
    schedulerd)
      docker run -d --name schedulerd \
        -v $LOGA_EXPORT_DIR/schedulerd/logs:/export/logs \
        --link=monitord:monitord \
        --link=logstash_tcp_to_redis:logstash_tcp_to_redis \
        --link=logstash_redis_to_es:logstash_redis_to_es \
        --link=redis:redis \
        loga/schedulerd \
        >$COMMAND_OUT 2>$COMMAND_ERR;;
  esac
  exit_on_failure
done

echo "=> list current docker containers..."

docker ps
