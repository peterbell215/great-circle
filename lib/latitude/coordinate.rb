# frozen_string_literal: true

require 'active_support/core_ext'

# Class to represents a location on the earth using latitude and longitude.
class Coordinate
  attr_reader :latitude, :longitude

  def initialize(latitude:, longitude:)
    @latitude = latitude
    @longitude = longitude
  end

  def latitude=(val)
    @latitude = convert_degree_input_to_decimal(val, %w[N S], 'S')
  end

  def longitude=(val)
    @longitude = convert_degree_input_to_decimal(val, %w[E W], 'W')
  end

  def valid?
    latitude && longitude && (latitude.abs <= 90) && (longitude.abs <= 180)
  end

  def great_circle_distance_to(final_coordinate)
    Vincenty.great_circle_distance(latitude, longitude, final_coordinate.latitude, final_coordinate.longitude)
  end

  def initial_bearing_to(final_coordinate)
    Vincenty.initial_bearing(latitude, longitude, final_coordinate.latitude, final_coordinate.longitude)
  end

  def final_bearing_from(start_coordinate)
    Vincenty.final_bearing(start_coordinate.latitude, start_coordinate.longitude, latitude, longitude)
  end

  private

  SIGN = /(?<sign>[+-]?)/
  DEGREES = /(?<degrees>[0-9]{1,3})/
  MINUTES_AND_SECONDS = /(°\s*((?<minutes>[0-5]?[0-9])')(\s*(?<seconds>[0-5]?[0-9])")?)/
  DECIMAL = /((?<decimal>.[0-9]+)°?)/

  COORDINATE_REGEXP = /#{SIGN}#{DEGREES}(#{MINUTES_AND_SECONDS}|#{DECIMAL})?\s*(?<compass>[NSEW]?)/i

  def convert_degree_input_to_decimal(input, valid_directions, negative_direction)
    return if input.blank?

    return input.to_f if input.kind_of?(Numeric)

    match = COORDINATE_REGEXP.match(input)

    raise ArgumentError if match.nil? || match[:compass].present? && !match[:compass].in?(valid_directions)

    degrees = match[:degrees].to_f

    degrees += match[:decimal].to_f if match[:decimal]
    degrees += match[:minutes].to_f / 60.0 if match[:minutes]
    degrees += match[:seconds].to_f / 3600.0 if match[:seconds]

    degrees *= -1.0 if match[:sign] == '-' || match[:compass].casecmp?(negative_direction)
    degrees
  end
end
