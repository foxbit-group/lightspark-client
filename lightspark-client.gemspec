# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "lightspark-client/version"

Gem::Specification.new do |spec|
  spec.name          = "lightspark-client"
  spec.version       = LightsparkClient::VERSION
  spec.authors       = ["Arthur Ferraz dos Santos"]
  spec.email         = ["arthur.santos@foxbit.com.br"]

  spec.summary       = "Lightspark Client"
  spec.description   = "A ruby client to integrate Lightspark API"
  spec.homepage      = "https://github.com/foxbit-group/lightspark-client"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "typhoeus",    "~> 1.3"
  spec.add_dependency "base64",      "~> 0.2"
  spec.add_dependency "json",        "~> 2.3"

  spec.add_development_dependency "bundler",        "~> 1.16"
  spec.add_development_dependency "byebug",         "~> 10.0"
  spec.add_development_dependency "pry-byebug",     "<= 3.6"
  spec.add_development_dependency "rake",           "~> 12.3.3"
  spec.add_development_dependency "rspec",          "~> 3.8"
  spec.add_development_dependency "rubocop",        "~> 0.53"
  spec.add_development_dependency "rubocop-github", "~> 0.10"
  spec.add_development_dependency "rubocop-rspec",  "~> 1.24"
  spec.add_development_dependency "webmock",        "~> 3.5"
end
