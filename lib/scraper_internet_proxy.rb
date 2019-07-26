require 'scraper_proxy'

class ScraperInternetProxy < ScraperProxy

  def callback(mtd, *args, &block)
    url, params = @args
    options = {
      klass: @klass,
      with: mtd,
      url: url,
      params: params,
    }

    Scraper.execute(options)
  end

end
