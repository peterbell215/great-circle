# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'great-circle/version'

Gem::Specification.new do |spec|
  spec.name          = 'great-circle'
  spec.version       = GreatCircle::VERSION
  spec.authors       = ['Peter Bell']
  spec.email         = ['peter.bell215@gmail.com']
  spec.summary       = 'Provides a library to manipulate and calculate great circle headings, longitudes and latitudes.'
  spec.description   = <<~DESCRIPTION
    This originally started as a fork of the latitude-gem.  It provides a set of classes to manipulate great circle angles,
    latitudes, longitudes, and distances.
  DESCRIPTION
  spec.homepage      = 'https://github.com/peterbell215/great-circle'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.0.0'

  spec.add_development_dependency 'bundler', '~> 2.2'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop', '~> 1.7'
  spec.add_development_dependency 'rubocop-rspec'
end
