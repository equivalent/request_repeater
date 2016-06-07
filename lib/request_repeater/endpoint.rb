module RequestRepeater
  class Endpoint
    NoEndpointToCall = Class.new(StandardError)

    attr_reader   :sleepfor
    attr_writer   :timer
    attr_accessor :last_execution

    def initialize(url:, sleepfor:)
      @sleepfor = sleepfor.to_i
      @url = url
    end

    def execute
      if executable?
        yield
        executed
      end
    end

    def executable?
      timer.now > last_execution + RequestRepeater.sleeptime(sleepfor)
    end

    def executed
      @last_execution = timer.now
    end

    def ==(other_endpoint)
      self.url == other_endpoint.url \
        && self.sleepfor == other_endpoint.sleepfor \
        && self.last_execution == other_endpoint.last_execution
    end

    def timer
      @timer ||= Time
    end

    def url
       @url || raise(NoEndpointToCall)
    end

    def inspect
      "#<#{self.class}:#{object_id.to_s(16)} url=#{url.to_s[0..16]}... sleepfor=#{sleepfor}>"
    end
  end
end
