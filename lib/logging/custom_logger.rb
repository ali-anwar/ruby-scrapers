module Logging
  class CustomLogger
    DEFAULTS = {
      level: :info
    }

    LEVELS = %w(debug info warn error fatal unknown).map(&:to_sym)

    class << self
      def log(*tags, **params)
        level = determine_log_level(**params)
        params.delete(:level)
        message = build_message(*tags, **params)

        logger.send(level, message)
      end

      private

      def logger
        return @logger if @logger

        @logger = Logger.new File.join('log', "#{env}.log")
        if production?
          @logger.level = Logger::ERROR
        else
          @logger.level = Logger::INFO
        end

        return @logger
      end

      def env
        ENV['RACK_ENV'] || 'development'
      end

      def commandline?
        ENV['SCRAPERS_COMMANDLINE'].present?
      end

      def production?
        env == 'production'
      end

      def determine_log_level(**params)
        params.has_key?(:level) && params[:level].to_sym.in?(LEVELS) ? params[:level].to_sym : :info
      end

      def build_message(*tags, **params)
        tags.map!{ |tag| format_tag(tag) }
        params = params.map{ |args| format_param(args[0], args[1]) }

        tags.join(' ') + ' ' + params.join(' ')
      end

      def format_tag(tag)
        tag = tag.to_s.gsub(/[^\w]/i, '').upcase
        "[#{tag}]"
      end

      def format_param(key, value)
        key = key.to_s.gsub(/[^\w]/i, '').downcase
        value = value.to_s.gsub('"','')

        "#{key}=\"#{value}\""
      end
    end
  end
end

def log(*tags, **params)
  Logging::CustomLogger.log(*tags, **params)
end

# Usage
# log('MAIN_TAG', 'SUB_TAG', key1: value1, key2: value2, error_message: e.message)
