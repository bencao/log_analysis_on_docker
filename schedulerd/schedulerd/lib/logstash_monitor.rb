require 'rest_client'
require 'json'

class LogstashMonitor
  def initialize(logstash_host, logstash_port)
    @logstash_host = logstash_host
    @logstash_port = logstash_port
  end

  def get_count
    response = RestClient.get("http://#{@logstash_host}:#{@logstash_port}/count")
    JSON.parse(response.body)["count"]
  end
end
