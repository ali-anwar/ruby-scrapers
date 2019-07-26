class ScraperResponse
  attr_reader :scrape_file_name, :out_formats

  def initialize(scrape_file_name:, out_formats: [:json])
    @scrape_file_name = scrape_file_name
    @out_formats = out_formats
  end

  def process
    generate_or_write_json_file if out_format.include?(:json)
    generate_or_write_csv_file if out_format.include?(:csv)
  end

  private

  def generate_or_write_json_file
    file = File.open(scrape_file_name, 'a')
    file.flock(File::LOCK_EX)
    file.puts rows.collect(&:to_json).join("\n")
    file.close
  end

  def generate_or_write_csv_file
    # Logic
  end
end
