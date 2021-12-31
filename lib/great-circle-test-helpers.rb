require 'rspec/expectations'

module GreatCircle
  module TestHelpers
    RSpec::Matchers.define :be_very_close_to do |expected|
      match do |actual|
        (expected.longitude.degrees - actual.longitude.degrees).abs < 1.0e-3 &&
          (expected.latitude.degrees - actual.latitude.degrees).abs < 1.0e-3
      end
      failure_message do |actual|
        "expected that #{actual} is close to #{expected}"
      end
    end
  end
end
