# frozen_string_literal: true

# Module to include in Angle that provides functionality to parse angles including lat or longs.
module ParseAngle
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    attr_reader :valid_compass_points, :negative_compass_point
  end

  private

  # Sets the objects @degree instance to the passed input which can be of type Angle (and derived), Numeric or
  # a string.
  def convert_degree_input_to_decimal(input)
    return if input.blank?

    case input
    when Numeric then @degrees = input.to_f
    when String then convert_string_to_decimal(input)
    else raise ArgumentError
    end
  end

  # rubocop: disable Lint/MixedRegexpCaptureTypes PB: the named capture groups are really useful.  The unnamed ones
  #                                               are used purely to structure the Regexp and not used for extracting
  #                                               info.  Could tag them accordingly but it makes the Regexp even less
  #                                               readable.
  SIGN = /(?<sign>[+-]?)/
  DEGREES = /(?<degrees>[0-9]{1,3})/
  MINUTES_AND_SECONDS = /(°\s*((?<minutes>[0-5]?[0-9])')(\s*(?<seconds>[0-5]?[0-9])")?)/
  DECIMAL = /((?<decimal>.[0-9]+)°?)/

  COORDINATE_REGEXP = /#{SIGN}#{DEGREES}(#{MINUTES_AND_SECONDS}|#{DECIMAL})?\s*(?<compass>[NSEW]?)/i
  # rubocop: enable Lint/MixedRegexpCaptureTypes

  # Parses the passed string and converts to a degree and decimal.  Valid formats include:
  # * '340.5'
  # * '-340 5' 15" N'
  # * '20.6°'
  # rubocop: disable Metrics/AbcSize
  def convert_string_to_decimal(string)
    match = COORDINATE_REGEXP.match(string)

    raise ArgumentError if _check_compass(match)

    @degrees = match[:degrees].to_f

    @degrees += match[:decimal].to_f if match[:decimal]
    @degrees += match[:minutes].to_f / 60.0 if match[:minutes]
    @degrees += match[:seconds].to_f / 3600.0 if match[:seconds]

    @degrees *= -1.0 if match[:sign] == '-' || match[:compass].casecmp?(self.class.negative_compass_point)
  end
  # rubocop: enable Metrics/AbcSize

  # Checks for Longitude and Latitude classes that the passed string has the correct compass point (i.e. N for
  # latitudes or W for longitudes)
  def _check_compass(match)
    match[:compass].present? && !match[:compass].in?(self.class.valid_compass_points)
  end
end
