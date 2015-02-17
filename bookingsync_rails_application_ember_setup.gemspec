# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bookingsync_rails_application_ember_setup/version'

Gem::Specification.new do |spec|
  spec.name          = "bookingsync_rails_application_ember_setup"
  spec.version       = BookingsyncRailsApplicationEmberSetup::VERSION
  spec.authors       = ["BookingSync"]
  spec.email         = ["dev@bookingsync.com"]
  spec.summary       = "Generator for setting up Rails application to work with Ember in Bookingsync App Store."
  spec.description   = "Generator for setting up Rails application to work with Ember in Bookingsync App Store."
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 4.0.0"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
