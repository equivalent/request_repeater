module RequestRepeater
  class RequestMaker
    InvalidURL = Class.new(StandardError)

    attr_reader :endpoints
    attr_writer :sleeper

    def initialize(endpoints)
      @endpoints = endpoints
    end

    def run
      loop do
        endpoints.each do |e|
          e.execute do
            request(e.uri)
          end
        end
        sleeper.call(minimum_sleep)
      end
    end

    private
      def request(uri)
        req = Net::HTTP::Get.new(uri)

        Net::HTTP.start(uri.host, uri.port,
                        :use_ssl => uri.scheme == 'https',
                        :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |https|
                          https.request(req)
                        end
                        .tap {|res| log_response(uri.to_s, res) }
      end

      def log_response(url, res)
        RequestRepeater.logger.info "request #{url} #{res}"
      end

      def minimum_sleep
        RequestRepeater.sleeptime((ENV['MINIMUMSLEEP'] || 500).to_i)
      end

      def sleeper
        @sleeper ||= ->(sleepfor) { sleep sleepfor }
      end
  end
end
