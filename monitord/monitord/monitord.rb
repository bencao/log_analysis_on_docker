require 'logger'
require_relative 'lib/monitord_file_queue'
require_relative 'lib/monitord_file_system_listener'
require_relative 'lib/monitord_http_control_hub'
require_relative 'lib/monitord_runner'

logger = Logger.new("/export/logs/monitord.log")

queue    = MonitordFileQueue.new(logger)
listener = MonitordFileSystemListener.new(logger, '/import', queue)
runner   = MonitordRunner.new(logger, queue, ENV['LOGSTASH_TCP_TO_REDIS_PORT_33333_TCP_ADDR'], ENV['LOGSTASH_TCP_TO_REDIS_PORT_33333_TCP_PORT'])
http_hub = MonitordHttpControlHub.new(logger, "0.0.0.0", 4567, queue, runner)

listener.start
Thread.fork do
http_hub.start
end
runner.start

