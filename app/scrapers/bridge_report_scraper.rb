# encoding: utf-8

class BridgeReportScraper < Scraper
  BASE_URL = 'https://bridgereports.com/'

  class << self

    def scrape_name
      'bridge-reports'
    end

    def generate_json_to_csv
      ScrapeJsonToCsvGenerator.new(scrape_name).process
    end

    def run(options = {})
      fetch(url).process
    end

    def process(options = {})
      # Index page

      document = Nokogiri::HTML(options[:response][:body])

      table = document.at('table')

      table.search('tr').each do |tr|
        cells = tr.search('td')
        next if cells.empty?

        response_hash = {
          carries: cells[1].text,
          crosses: cells[2].text,
          location: cells[3].text,
          design: cells[4].text,
          status: cells[5].text,
          year_build: cells[6].text.to_i,
          year_recon: cells[7].text,
          span_length: cells[8].text.to_f,
          total_length: cells[9].text.to_f,
          condition: cells[10].text,
          suff_rating: cells[11].text.to_f,
          id: cells[12].text
        }

        ScraperResponse.new([response_hash], scrape_file_name: scrape_name).process
      end

      # -- Example Code to fetch pages links

      # links = document.xpath(".//h1[@class='card-title']/a/@href")
      # links.each do |link|
      #   fetch(append_base(BASE_URL, link.to_s)).process_detail
      # end

      # Fetch page number
      # page_no = options[:url].split(':')[-2].scan(/\d+/).first.to_i + 1
      # fetch(url(page_no)).process
    end

    def process_detail(options = {})
      # Show page

      # return unless options[:response][:code] == "200"

      # html = Nokogiri::HTML(options[:response][:body])

      # Logic
      # return if 'Guard Condition'
    end

    def url(page_no = 1)
      "#{BASE_URL}/city/wichita-kansas?page=#{page_no}"
    end
  end
end
