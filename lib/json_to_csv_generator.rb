class ScrapeJsonToCsvGenerator
  attr_reader :json_file_name

  def initialize(json_file_name)
    @json_file_name = json_file_name
  end

  def process
    CSV.open(scrapes_directory("#{json_file_name}.csv"), "w") do |csv|
      File.foreach(scrapes_directory("#{json_file_name}.json")).with_index do |line, line_num|
        json = JSON.parse(line)

        csv << json.keys if line_num == 0
        csv << json.values
      end
    end
  end

  private

  def scrapes_directory(scrape_file_name)
    File.join('scrapes', scrape_file_name)
  end
end
