require "request_repeater/version"
require 'request_repeater/endpoint'
require 'request_repeater/request_maker'
require 'uri'
require 'logger'
require 'json'
require 'net/http'

module RequestRepeater
  def self.sleeptime(miliseconds)
    miliseconds / 1000.0
  end

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.logger=(logger)
    @logger = logger
  end

  def self.run
    if ENV['URL']
      endpoints = [Endpoint.new(url: ENV['URL'], sleepfor: ENV['SLEEPFOR'] || self._default_sleep)]
    elsif ENV['URLS']
      endpoints = _json_to_endpoints(ENV['URLS'])
    else
      raise ArgumentError, 'You must specify URL or URLS envirement variable'
    end

    endpoints.each { |e| e.executed }

    RequestRepeater::RequestMaker.new(endpoints).run
  end

  private
    def self._json_to_endpoints(json_string)
      JSON
        .parse(json_string)
        .fetch('urls')
        .map { |url_options| Endpoint.new(url: url_options.fetch('url'), sleepfor: url_options['sleepfor'] || url_options['sleep'] || self._default_sleep) }
    end

    def self._default_sleep
      1000
    end
end
