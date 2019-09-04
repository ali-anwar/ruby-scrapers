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

You can check the `tmp` folder you will fine the html cache
