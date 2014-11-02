require 'json'
require_relative 'simple_tcp_server'

class MonitordHttpControlHub

  def initialize(logger, host, port, queue, runner)
    @logger = logger
    @server = SimpleTCPServer.new(host, port, "text/json")
    @queue = queue
    @runner = runner
    register_handlers
  end

  def register_handlers
    @server.get(:queue_size) do
      @logger.info("=> MonitordHttpControlHub: received queue_size command, returning #{@queue.size}...")
      {:queue_size => @queue.size}.to_json
    end

    @server.get(:status) do
      status = @runner.paused? ? "paused" : "running"
      @logger.info("=> MonitordHttpControlHub: received status command, returning #{status}...")
      {:status => status}.to_json
    end

    @server.post(:pause) do
      @runner.pause
      @logger.info("=> MonitordHttpControlHub: received pause command, paused executing...")
      {:success => true}.to_json
    end

    @server.post(:continue) do
      @runner.continue
      @logger.info("=> MonitordHttpControlHub: received continue command, continued executing...")
      {:success => true}.to_json
    end
  end

  def start
    @server.start
  end
end
