require 'logging/custom_logger'

class RetryRun
  MAX_ATTEMPTS = 5

  class << self
    def call(method_name, custom_logger)
      attempts = 0

      begin
        attempts += 1
        yield
      rescue StandardError => e

        SleepDispatch.call(seconds: (2 ** attempts)) {
          custom_logger.log('SCRAPER', method: method_name, retry_count: attempts)
          custom_logger.log('SCRAPER', method: method_name, message: e.message)
          custom_logger.log('SCRAPER', method: method_name, backtrace: e.backtrace.join('\n'))
        }

        retry if attempts <= MAX_ATTEMPTS
      end
    end
  end
end
