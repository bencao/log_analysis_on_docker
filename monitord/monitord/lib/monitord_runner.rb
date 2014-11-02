require 'zlib'
require 'socket'

class MonitordRunner

  def initialize(logger, queue, host, port)
    @logger = logger
    @queue = queue
    @host = host
    @port = port
    @paused = false
    @pause_sleep_time = 10
    @empty_queue_sleep_time = 10
  end

  def start
    loop do
      if @paused
        @logger.info("=> MonitordRunner: paused, sleep for #{@pause_sleep_time} seconds...")
        sleep @pause_sleep_time
      elsif @queue.empty?
        @logger.info("=> MonitordRunner: queue empty, sleep for #{@empty_queue_sleep_time} seconds...")
        sleep @empty_queue_sleep_time
      else
        file = @queue.shift
        @logger.info("=> MonitordRunner: start processing #{file}...")
        unzip_and_send(@host, @port, file)
        @logger.info("=> MonitordRunner: end processing #{file}...")
      end
    end
  end

  def pause
    @paused = true
  end

  def continue
    @paused = false
  end

  def paused?
    @paused
  end

  def unzip_and_send(host, port, file)
    TCPSocket.open(host, port) do |socket|
      Zlib::GzipReader.open(file) do |reader|
        reader.each_line {|line| socket.write(line)}
      end
    end
  end

end
