require 'socket'
require 'json'

class SimpleTCPServer
  def initialize(host, port, format)
    @host = host
    @port = port
    @format = format
    @get_handlers = {}
    @post_handlers = {}
  end

  def get(command, &block)
    @get_handlers[command.to_sym] = block
  end

  def post(command, &block)
    @post_handlers[command.to_sym] = block
  end

  def start
    server = TCPServer.new(@host, @port)

    loop {
      Thread.start(server.accept) do |client|
        # request line like "GET /queue_size" or "POST /pause"
        request_line = client.gets
        method, url, _ = request_line.split(" ")
        command = url.sub("/", "").to_sym
        handler = (method == "POST") ? @post_handlers[command] : @get_handlers[command]
        resp = handler.nil? ? "unsupported methods" : handler.call.to_s
        headers = ["HTTP/1.1 200 OK",
                   "Server: Ruby",
                   "Content-Type: #{@format}; charset=utf-8",
                   "Content-Length: #{resp.length}\r\n\r\n"].join("\r\n")
        client.puts headers
        client.puts resp
        client.close
      end
    }
  end
end

require "logstash/filters/base"
require "logstash/namespace"

class LogStash::Filters::SpeedCounter < LogStash::Filters::Base
  config_name "speed_counter"

  milestone 1

  public
  def register
    @count = 0
    @server = SimpleTCPServer.new("0.0.0.0", 7788, "text/json")
    @server.get(:count) do
      {:count => @count}.to_json
    end
    Thread.fork do
      @server.start
    end
  end

  public
  def filter(event)
    return unless filter?(event)
    @count += 1
    filter_matched(event)
  end
end
