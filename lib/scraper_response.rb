class ScraperResponse
  attr_reader :rows, :scrape_file_name, :out_formats, :opts

  # @param [Hash ] opts
    # @values :sync true/false if parallel gem processes using file to write pass sync true
  def initialize(rows, scrape_file_name:, out_formats: [:json], opts: {})
    @rows = rows
    @scrape_file_name = scrape_file_name
    @out_formats = out_formats
    @opts = opts
  end

  def process
    generate_or_write_json_file if out_formats.include?(:json)
    generate_or_write_csv_file if out_formats.include?(:csv)
  end

  private

  def generate_or_write_json_file
    file = File.open(scrapes_directory("#{scrape_file_name}.json"), 'a')

    if opts[:sync]
      file.sync = true
    else
      file.flock(File::LOCK_EX)
    end

    file.puts rows.collect(&:to_json).join("\n")
    file.close
  end

  def generate_or_write_csv_file
    # Logic
  end

  def scrapes_directory(scrape_file_name)
    File.join('scrapes', scrape_file_name)
  end
end
