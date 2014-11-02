require 'listen'

class MonitordFileSystemListener
  def initialize(logger, dir_to_listen, queue)
    @logger = logger
    @dir_to_listen = dir_to_listen
    @queue = queue
  end

  def start
    listener = Listen.to(@dir_to_listen) do |modified, added, removed|
      modified.each do |file|
        @queue.push(file)
        @logger.info("=> MonitordFileSystemListener: modified file #{file} added to queue")
      end

      added.each do |file|
        @queue.push(file)
        @logger.info("=> MonitordFileSystemListener: added file #{file} added to queue")
      end

      removed.each do |file|
        @logger.info("=> MonitordFileSystemListener: removed file #{file} ignored")
      end
    end
    listener.start # not blocking
    listener.only /.gz/
  end
end
