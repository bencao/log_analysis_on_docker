require 'logger'
require_relative 'lib/monitord_monitor'
require_relative 'lib/redis_monitor'
require_relative 'lib/logstash_monitor'
require_relative 'lib/schedulerd_runner'

logger                        = Logger.new("/export/logs/schedulerd.log")
monitord_monitor              = MonitordMonitor.new(ENV["UILOGD_PORT_4567_TCP_ADDR"], ENV["UILOGD_PORT_4567_TCP_PORT"])
redis_monitor                 = RedisMonitor.new(ENV["REDIS_PORT_6379_TCP_ADDR"], ENV["REDIS_PORT_6379_TCP_PORT"], 0, "log")
logstash_tcp_to_redis_monitor = LogstashMonitor.new(ENV["LOGSTASH_TCP_TO_REDIS_PORT_7788_TCP_ADDR"], ENV["LOGSTASH_TCP_TO_REDIS_PORT_7788_TCP_PORT"])
logstash_redis_to_es_monitor  = LogstashMonitor.new(ENV["LOGSTASH_REDIS_TO_ES_PORT_7788_TCP_ADDR"], ENV["LOGSTASH_REDIS_TO_ES_PORT_7788_TCP_PORT"])

scheduler_runner = SchedulerdRunner.new(
  monitord_monitor,
  redis_monitor,
  logstash_tcp_to_redis_monitor,
  logstash_redis_to_es_monitor
)

scheduler_runner.define_high_load do |monitord_queue_size, redis_queue_size|
  redis_queue_size > 50000
end

scheduler_runner.after_pause_monitord do |monitord_queue_size, redis_queue_size|
  logger.info("=> load is high...")
  logger.info("   -> monitord_queue_size = #{monitord_queue_size}")
  logger.info("   -> redis_queue_size  = #{redis_queue_size}")
  logger.info("   -> paused monitord...")
end

scheduler_runner.after_continue_monitord do |monitord_queue_size, redis_queue_size|
  logger.info("=> load is back to normal...")
  logger.info("   -> monitord_queue_size = #{monitord_queue_size}")
  logger.info("   -> redis_queue_size  = #{redis_queue_size}")
  logger.info("   -> continue monitord...")
end

scheduler_runner.after_collect_metrics do |metrics_collected_at, metrics|
  logger.info("=> current metrics for loga are:")
  logger.info("   -> monitord_queue_size           = #{metrics[:monitord_queue_size]}")
  logger.info("   -> redis_queue_size            = #{metrics[:redis_queue_size]}")
  logger.info("   -> logstash_tcp_to_redis_total = #{metrics[:logstash_tcp_to_redis_count]}")
  logger.info("   -> logstash_redis_to_es_total  = #{metrics[:logstash_redis_to_es_count]}")
end

scheduler_runner.delta do |delta_time, delta_metrics|
  if delta_time > 0
    logger.info("=> processing speed in last #{delta_time.round(2)} seconds:")
    logger.info("   -> monitord_queue_size     = #{(delta_metrics[:monitord_queue_size]/delta_time).round(2)}/s")
    logger.info("   -> redis_queue_size      = #{(delta_metrics[:redis_queue_size]/delta_time).round(2)}/s")
    logger.info("   -> logstash_tcp_to_redis = #{(delta_metrics[:logstash_tcp_to_redis_count]/delta_time).round(2)}/s")
    logger.info("   -> logstash_redis_to_es  = #{(delta_metrics[:logstash_redis_to_es_count]/delta_time).round(2)}/s")
  end
end

scheduler_runner.sleep(10) do |sleep_time|
  logger.info("=> sleep for 10 seconds...")
  sleep sleep_time
end

scheduler_runner.start
