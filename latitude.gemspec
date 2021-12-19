# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'latitude/version'

Gem::Specification.new do |spec|
  spec.name          = "latitude"
  spec.version       = Latitude::VERSION
  spec.authors       = ["Trey Springer"]
  spec.email         = ["dfsiii@gmail.com"]
  spec.summary       = %q{Calculates distances between two geographic coordinates.}
  spec.description   = %q{Uses the great-circle distance calculation to determine the distance between two locations with just latitudes and longitudes.}
  spec.homepage      = "https://github.com/umtrey/latitude-gem"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 3.0.0'

  spec.add_development_dependency 'bundler', '~> 2.2'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop', '~> 1.7'
  spec.add_development_dependency 'rubocop-rspec'
end
