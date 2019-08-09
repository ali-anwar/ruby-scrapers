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

    scrapper_klass = Object.const_get(options[:klass].to_s)
    scrapper_klass.execute(options)
  end

end
