This project is developed to scrape and save data in local cache from any site by using Nokogiri in Ruby. We have provided a demo scraper BridgeReportScraper.

To run the scraper follow the following steps:
- Clone the repo.
- Install dependencies `bundle install`.
- Run the scraper by: `./bin/runner BridgeReportScraper.start`

The output will be stored in `scrapes/bridge-reports.json`.

The `tmp` folder holds the HTML cache for all pages fetched.
