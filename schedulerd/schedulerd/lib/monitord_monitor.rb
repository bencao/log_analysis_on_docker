require 'rest_client'
require 'json'

class MonitordMonitor

  def initialize(hub_host, hub_port)
    @hub_host = hub_host
    @hub_port = hub_port
  end

  def get_queue_size
    response = RestClient.get("http://#{@hub_host}:#{@hub_port}/queue_size")
    JSON.parse(response.body)["queue_size"]
  end

  def get_status
    response = RestClient.get("http://#{@hub_host}:#{@hub_port}/status")
    JSON.parse(response.body)["status"]
  end

  def pause_monitord
    response = RestClient.post("http://#{@hub_host}:#{@hub_port}/pause", {})
    JSON.parse(response.body)["success"]
  end

  def continue_monitord
    response = RestClient.post("http://#{@hub_host}:#{@hub_port}/continue", {})
    JSON.parse(response.body)["success"]
  end
end
