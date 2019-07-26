class ScraperProxy

  def initialize(klass, *args)
    @klass = klass
    @args = args
  end

  def method_missing(mtd, *args, &block)
    callback mtd, *args, &block
  end

  def callback(mtd, *args, &block)
    raise "Override ScraperProxy#callback in subclass"
  end

end
