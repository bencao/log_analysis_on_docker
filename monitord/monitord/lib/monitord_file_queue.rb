class MonitordFileQueue

  def initialize(logger)
    @logger = logger
    @items = []
  end

  def push(item)
    @logger.info("=> MonitordFileQueue: added item #{item}")
    @items.push(item)
  end

  def size
    @items.size
  end

  def empty?
    @items.empty?
  end

  def shift
    item = @items.shift
    @logger.info("=> MonitorFileQueue: shifted item #{item}")
    item
  end
end
