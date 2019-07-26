require 'rubygems'
require 'bundler/setup'

paths = ['./lib', './lib/logging', './config/initializers', './app/scrapers']

paths.each { |path| $: << path }

class Scrapers

  class << self
    def root_path
      lambda do |env|
        [200, {'Content-Type' => 'text/html'}, [File.read(File.join('public', 'index.html'))]]
      end
    end

    def application
      Rack::URLMap.new(
        '/' => root_path,
        '/scrapes' => Rack::Directory.new('./scrapes/'),
      )
    end

    def root
      Dir.pwd
    end
  end

end

paths.each {|path| Dir[File.join(path, '*.rb')].sort.each { |file| require file } }
