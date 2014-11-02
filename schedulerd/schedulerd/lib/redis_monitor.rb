require 'redis'

class RedisMonitor
  def initialize(redis_host, redis_port, redis_db_index, redis_key)
    @redis_host = redis_host
    @redis_port = redis_port
    @redis_db_index = redis_db_index
    @redis_key = redis_key
    @redis = Redis.new(:host => @redis_host, :port => @redis_port, :db => @redis_db_index)
  end

  def get_queue_size
    @redis.llen(@redis_key)
  end
end
