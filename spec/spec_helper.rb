$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'request_repeater'

RSpec.configure do |config|
  config.before do
    RequestRepeater.logger = spy
  end
end
