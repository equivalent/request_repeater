module RequestRepeater
  class RequestMaker
    attr_reader :endpoints
    attr_writer :sleeper

    def initialize(endpoints)
      @endpoints = endpoints
    end

    def run
      loop do
        endpoints.each do |e|
          e.execute do
            request(e.url)
          end
        end
        sleeper.call(minimum_sleep)
      end
    end

    private
      def request(url)
        uri = URI.parse(url)
        puts uri.path.nil?
        req = Net::HTTP::Get.new(uri.path.to_s == '' ?  '/' : uri.path )

        Net::HTTP.start(uri.host, uri.port,
                        :use_ssl => uri.scheme == 'https',
                        :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |https|
                          https.request(req)
                        end
                        .tap {|res| log_response(url, res) }
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
