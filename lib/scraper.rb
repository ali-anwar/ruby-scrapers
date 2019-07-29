# encoding: utf-8
require 'uri'
require 'json'
require 'nokogiri'
require 'chronic_duration'
require 'htmlentities'

class Scraper
  class << self
    def verify_data(rows)
      data = rows.first
      # raise if condition fails
    end

    def escape_html_characters(str)
      HTMLEntities.new.decode(str).to_s.gsub(/\r|\n|\t|  /, '')
    end

    def file_name
      self.name.underscore
    end

    def file_name_with_ext
      [self.scrape_name, 'json'].join('.')
    end

    def gzipped_file_name_with_ext
      [file_name_with_ext, 'gz'].join('.')
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

    def scrape_name
      raise "Override Scraper#scrape_name in subclass"
    end

    def execute(*args)
      klass = Object.const_get(args.first[:klass].to_s)

      Scraper.process(*args)
    end

    def run_all
      self.list.each do |scraper|
        self.execute(klass: scraper.name)
      end
    end

    def list
      ObjectSpace.each_object(Class).select { |klass| klass < self }
    end

    def fetch(url, *args)
      ScraperInternetProxy.new(self.name, url, *args)
    end

    def hard_fetch(url)
      ScraperInternetProxy.new(self.name, url, force: true)
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

    def process(*args)
      options = args.first.symbolize_keys_recursive

      Scraper.perform options.merge(response: fetch_now(options), message: options[:url])
    end

    def perform(options = {})
      options = options.symbolize_keys_recursive
      options[:with] ||= 'start'
      klass = Object.const_get(options[:klass].to_s)

      log('SCRAPER', method: :perform, message: ["Going to", options[:with], options.delete(:message)].join(' '))

      begin
        p options[:with]
        klass.send options[:with], options
      rescue
        klass.send :set_failed_flag
        raise
      end
    end

    def run(options = {})
      raise "Override Scraper#run in subclass"
    end

    def start(options = {})
      log 'SCRAPER', method: :start, time: "Scraper started at #{Time.zone.now}"
      $class = self

      return if !Scrapers.commandline? && get_jobs_count.to_i > 0 && get_failed_flag.to_i.zero?

      remove_old_files

      begin
        self.run(options)
      rescue Exception => e
        log e.message
        log e.backtrace.join("\n")
        raise e unless Scrapers.commandline?
      end
    end

  end
end