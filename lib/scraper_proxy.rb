class ScraperProxy

  def initialize(klass, url, *args)
    @klass = klass
    @url = url
    @args = args
  end

  def method_missing(mtd, *args, &block)
    callback mtd, *args, &block
  end

  def callback(mtd, *args, &block)
    raise "Override ScraperProxy#callback in subclass"
  end

end
