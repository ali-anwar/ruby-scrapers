require 'httparty'

class Internet
  class << self
    def httparty_options(options = {})
      o = {
        headers: {
          "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36",
        },
      }
      o[:headers]["referer"] = options[:referer] if options[:referer].present?
      o[:basic_auth] = options[:basic_auth] if options[:basic_auth].present?

      if options[:headers].present?
        o[:headers] = o[:headers].merge(options[:headers])
      elsif options[:params].present? && options[:params][:headers].present?
        o[:headers] = o[:headers].merge(options[:params][:headers])
      end

      o
    end

    def raise_error(request)
      return if request.code == 200

      request.response.error!
    end

    def get(url, options = {})
      HtmlCache.fetch(url) do
        SleepDispatch.call do
          get_online(url, options)
        end
      end
    end

    def get_online(url, options = {})
      options[:try] = options[:try].to_i + 1
      request = HTTParty.get(url, httparty_options(options)) rescue nil
      return {} unless request

      if (request.code.to_i != 200 || (request.code.to_i == 200 && request.body.to_s == "")) && options[:try].to_i < 5
        sleep 5
        return get_online(url, options)
      end

      {
        body: sanitize_string(request.body.to_s),
        headers: request.headers.to_hash,
        code: request.code.to_s
      }
    end

    def open(url, options = {})
      StringIO.new get(url, options)[:body]
    end
  end
end
