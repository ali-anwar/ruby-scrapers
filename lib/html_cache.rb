require 'simple_disk_store'

class HtmlCache
  class << self
    def cache
      @cache ||= SimpleDiskStore.new("./tmp/html_cache")
    end

    def get(key)
      cache.read key rescue nil
    end

    def set(key, data)
      cache.write key, data
    end

    def fetch(key, &block)
      cache.fetch(key, &block)
    end
  end
end
