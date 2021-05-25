# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'request_repeater/version'

Gem::Specification.new do |spec|
  spec.name          = "request_repeater"
  spec.version       = RequestRepeater::VERSION
  spec.authors       = ["Tomas Valent"]
  spec.email         = ["equivalent@eq8.eu"]

  spec.summary       = %q{Request repeater on an endpoint}
  spec.description   = "Gem is a standalone Ruby executable app that will repeet " +
                       "GET requests to an endopoints in given timeout " +
                       "(e.g.: `URL=https://nginx/schedule SLEEPFOR=2000 bundle exec request_repeter` " +
                       " will do GET https://nginx/schedule every 2 seconds)"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 2.2.10"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "webmock", "~> 2.1"
end
