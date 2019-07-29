# encoding: utf-8
class DemoScraper < Scraper
  BASE_URL = "[:protocol]/[:domain]"

  class << self

    def scrape_name
      # parameterize scraper name
      'scraper-name'
    end

    def run(options = {})
      fetch(url).process_detail
    end

    def process(options = {})
      document = Nokogiri::HTML(options[:response][:body])

      # -- Example Code to fetch pages links

      links = document.xpath(".//h1[@class='card-title']/a/@href")
      links.each do |link|
        fetch(append_base(BASE_URL, link.to_s)).process_detail
      end

      # Fetch page number
      page_no = options[:url].split(':')[-2].scan(/\d+/).first.to_i + 1
      fetch(url(page_no)).process
    end

    def process_detail(options = {})
      # return unless options[:response][:code] == "200"

      # html = Nokogiri::HTML(options[:response][:body])

      response_hash = {}
      response_hash['test'] = 1
      response_hash['test2'] = 2

      # Logic
      # return if 'Guard Condition'

      ScraperResponse.new([response_hash], scrape_file_name: scrape_name).process
    end

    def url(page_no = 1)
      # URL to use in process
      "#{BASE_URL}/[:path]?page=#{page_no}"
    end
  end
end
