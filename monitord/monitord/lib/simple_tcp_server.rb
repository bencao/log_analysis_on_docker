require 'socket'

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
