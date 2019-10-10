This project is developed to scrape and save data in local cache from any site by using Nokogiri in Ruby. We have provided a demo scraper BridgeReportScraper.

To run the scraper follow the following steps:
- Clone the project.
- Run the command `bundle install`.
- Run the scraper by using the command `./bin/runner BridgeReportScraper.start`

```
$ git clone https://github.com/square63/ruby_cli_scrapers.git
$ cd ruby_cli_scrapers
$ bundle install
$ ./bin/runner BridgeReportScraper.start

OR

$ ./bin/runner BridgeReportScraper.run
```

The output of the `./bin/runner BridgeReportScraper.run` will store in `ruby_cli_scrapers/scrapes/bridge-reports.json` file.

## Convert JSON to CSV

```
$ ./bin/runner BridgeReportScraper.generate_json_to_csv
```

The output of `./bin/runner BridgeReportScraper.generate_json_to_csv` will store in `ruby_cli_scrapers/scrapes/bridge-reports.csv` file.

Check the `tmp` folder for the HTML cache, which will prevent multiple re-runs to hit the actual URL, and this will only fetch the data from local cache.
