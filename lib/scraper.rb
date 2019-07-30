# encoding: utf-8
require 'uri'
require 'json'
require 'nokogiri'
require 'chronic_duration'
require 'htmlentities'
require 'logging/custom_logger'
require 'byebug'

class Scraper
  class << self
    def scrape_name
      raise "Override Scraper#scrape_name in subclass"
    end

    def escape_html_characters(str)
      HTMLEntities.new.decode(str).to_s.gsub(/\r|\n|\t|  /, '')
    end

    def file_name
      scrape_name
    end

    def file_name_with_ext
      [file_name, 'json'].join('.')
    end

    def gzipped_file_name_with_ext
      [file_name_with_ext, 'gz'].join('.')
    end

    def log_file_name
      File.join("log", "#{file_name}.log")
    end

    def scrape_file_name
      File.join('scrapes', file_name_with_ext)
    end

    def gzipped_scrape_file_name
      File.join('scrapes', gzipped_file_name_with_ext)
    end

    def compress_file
      log "Compressing file #{scrape_file_name}"
      command = "gzip #{scrape_file_name}"
      `#{command}`
    end

    def complete
      compress_file
    end

    def remove_old_files
      [log_file_name, scrape_file_name, gzipped_scrape_file_name].each do |file_path|
        FileUtils.rm_f file_path
      end
    end

    def execute(*args)
      options = args.first.symbolize_keys_recursive
      self.perform options.merge(response: fetch_now(options), message: options[:url])
    end

    def run_all
      list.each do |scraper|
        execute(klass: scraper.name)
      end
    end

    def list
      ObjectSpace.each_object(Class).select { |klass| klass < self }
    end

    def fetch(url, *args)
      ScraperInternetProxy.new(name, url, *args)
    end

    def hard_fetch(url)
      ScraperInternetProxy.new(name, url, force: true)
    end

    def fetch_now(options = {})
      return unless options[:url].present?

      params = options[:params] || {}
      response =
        if params[:force]
          Internet.get_online(options[:url], options)
        else
          Internet.get(options[:url], options)
        end
    end

    def log(*tags, **params)
      custom_logger.log(*tags, **params)
    end

    def custom_logger
      Logging::CustomLogger.new(log_file_name)
    end

    def perform(options = {})
      options = options.symbolize_keys_recursive
      options[:with] ||= 'start'
      klass = Object.const_get(options[:klass].to_s)

      log('SCRAPER', method: :perform, message: ["Going to", options[:with], options.delete(:message)].join(' '))

      begin
        log('SCRAPER', method: :perform, with: options[:with], options: options.inspect)
        klass.send options[:with], options
      rescue StandardError => e
        log('SCRAPER', 'RAISED_ERROR', method: :perform, message: e.message)
        raise
      end
    end

    def run(options = {})
      raise "Override Scraper#run in subclass"
    end

    def start(options = {})
      log 'SCRAPER', method: :start, time: "Scraper started at #{Time.now}"

      return unless Scrapers.commandline?

      remove_old_files
      begin
        run(options)
      rescue StandardError => e
        log 'SCRAPER', method: :start, message: e.message
        log 'SCRAPER', method: :start, backtrace: e.backtrace.join("\n")
        raise e unless Scrapers.commandline?
      end
    end
  end
end
