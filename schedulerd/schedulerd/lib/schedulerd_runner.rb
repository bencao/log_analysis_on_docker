class SchedulerdRunner

  def initialize(monitord_monitor, redis_monitor, logstash_tcp_to_redis_monitor, logstash_redis_to_es_monitor)
    @monitord_monitor              = monitord_monitor
    @redis_monitor                 = redis_monitor
    @logstash_tcp_to_redis_monitor = logstash_tcp_to_redis_monitor
    @logstash_redis_to_es_monitor  = logstash_redis_to_es_monitor
    @last_metrics_collected_at     = nil
    @sleep_time                    = 10
    @callbacks                     = {}
  end

  def define_high_load(&block)
    @callbacks[:define_high_load] = block
  end

  def after_pause_monitord(&block)
    @callbacks[:after_pause_monitord] = block
  end

  def after_continue_monitord(&block)
    @callbacks[:after_continue_monitord] = block
  end

  def after_collect_metrics(&block)
    @callbacks[:after_collect_metrics] = block
  end

  def delta(&block)
    @callbacks[:delta] = block
  end

  def sleep(sleep_time, &block)
    @sleep_time = sleep_time
    @callbacks[:sleep] = block
  end

  def start
    loop do
      handle_metrics_collect
      handle_delta
      handle_metrics_save
      handle_high_load
      handle_sleep
    end
  end

  def handle_sleep
    return unless @callbacks.has_key?(:sleep)
    @callbacks[:sleep].call(@sleep_time)
  end

  def handle_delta
    if @last_metrics_collected_at.nil?
      delta_time                        = 0
      delta_monitord_queue_size         = 0
      delta_redis_queue_size            = 0
      delta_logstash_tcp_to_redis_count = 0
      delta_logstash_redis_to_es_count  = 0
    else
      delta_time                        = @metrics_collected_at - @last_metrics_collected_at
      delta_monitord_queue_size         = @monitord_queue_size - @last_monitord_queue_size
      delta_redis_queue_size            = @redis_queue_size - @last_redis_queue_size
      delta_logstash_tcp_to_redis_count = @logstash_tcp_to_redis_count - @last_logstash_tcp_to_redis_count
      delta_logstash_redis_to_es_count  = @logstash_redis_to_es_count - @last_logstash_redis_to_es_count
    end
    @callbacks[:delta].call(delta_time, {
      :monitord_queue_size           => delta_monitord_queue_size,
      :redis_queue_size            => delta_redis_queue_size,
      :logstash_tcp_to_redis_count => delta_logstash_tcp_to_redis_count,
      :logstash_redis_to_es_count  => delta_logstash_redis_to_es_count
    })
  end

  def handle_high_load
    return unless @callbacks.has_key?(:define_high_load)
    if @callbacks[:define_high_load].call(@monitord_queue_size, @redis_queue_size)
      if @monitord_monitor.get_status == "running"
        @monitord_monitor.pause_monitord
        @callbacks[:after_pause_monitord].call(@monitord_queue_size, @redis_queue_size) if @callbacks.has_key?(:after_pause_monitord)
      end
    else
      if @monitord_monitor.get_status == "paused"
        @monitord_monitor.continue_monitord
        @callbacks[:after_continue_monitord].call(@monitord_queue_size, @redis_queue_size) if @callbacks.has_key?(:after_continue_monitord)
      end
    end
  end

  def handle_metrics_save
    @last_metrics_collected_at        = @metrics_collected_at
    @last_monitord_queue_size         = @monitord_queue_size
    @last_redis_queue_size            = @redis_queue_size
    @last_logstash_tcp_to_redis_count = @logstash_tcp_to_redis_count
    @last_logstash_redis_to_es_count  = @logstash_redis_to_es_count
  end

  def handle_metrics_collect
    @monitord_queue_size         = @monitord_monitor.get_queue_size
    @redis_queue_size            = @redis_monitor.get_queue_size
    @logstash_tcp_to_redis_count = @logstash_tcp_to_redis_monitor.get_count
    @logstash_redis_to_es_count  = @logstash_redis_to_es_monitor.get_count
    @metrics_collected_at        = Time.now
    if @callbacks.has_key?(:after_collect_metrics)
      @callbacks[:after_collect_metrics].call(@metrics_collected_at, {
        :monitord_queue_size         => @monitord_queue_size,
        :redis_queue_size            => @redis_queue_size,
        :logstash_tcp_to_redis_count => @logstash_tcp_to_redis_count,
        :logstash_redis_to_es_count  => @logstash_redis_to_es_count
      })
    end
  end
end
