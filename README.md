## What's the architecture of this project?

The goal is simple: 
Parse json one line log files, and offer an UI which allow us to find out data trends we're interested.
Under the hood, we need to parse log, save it to index(elasticsearch), and use Kibana to query data from the index.
It's complex but we aimed to encapsulate different parts as component and make the whole app at least easy to start for everyone.

So with docker, we finally have those components:

- elasticsearch, which accept TCP request and take charge of data storage and query
- redis, which is the queue stand in middle make sure log won't be dropped when elasticsearch is temporalily not available
- logstash_redis_to_es, read data from redis queue and update elasticsearch index accordingly
- logstash_tcp_to_redis, listen on TCP port for one line json, and save it to redis queue
- monitord, monitor file changes in logs directory, parse and send those one line json to logstash_tcp_to_redis listen port
- schedulerd, monitor the whole log analysis pipeline to prevent system from over load

and all those components can work together as a whole app to achieve the origin goal we have, while keeping a relative high maintability from code perspective.

## Installation

- install [docker](https://www.docker.io/)
- config $LOGA_DIR $LOGA_IMPORT_DIR $LOGA_EXPORT_DIR(see explanation in "Why we need those *_DIR ENV variables?" section)
- run `deploy/redeploy.sh -a -v`, then the application is ready for work

## How to use it?
- copy(or touch) production_in_one_line.log.date.gz files to $LOGA_IMPORT_DIR
- open [http://localhost:8000](http://localhost:8000) in browser to see the kibana UI
- tail -f $LOGA_EXPORT_DIR/schedulerd/logs/schedulerd.logs to see health status for components

## Why we need those *_DIR ENV variables?

For everybody who will work with this project could be as easy/efficient as possible, we shipped with a few executable scripts.
And in those scripts several ENV variable are widely used which point to 3 directories(which may differ for everyone has different habit).

- $LOGA_DIR, this is the directory point to the same directory you found this README, it's used when reference code
- $LOGA_IMPORT_DIR, this is the directory contains .gz log files, which is the original input of LOGA
- $LOGA_EXPORT_DIR, this is the directory where to hold logs/persistent data/indices data

## How to rebuild indices for all .gz logs in $LOGA_IMPORT_DIR?

simply run `deploy/rebuild_index.sh`

## How should I dig deeper of how it's implemented?

Just read those Dockerfile inside each directory

## How to debug problems?

The best way is to look at log files, assuming you know how data flows in this architecture.

## TODO items

- log to stdout and route to another logd which is the single point of writing logs to file
- indexing performance tuning, currently the bottleneck is from redis to es
- possiblity to deploy on multi server
