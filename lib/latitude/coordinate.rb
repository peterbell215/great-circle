# frozen_string_literal: true

require 'active_support/core_ext'

# Class to represents a location on the earth using latitude and longitude.
class Coordinate
  include LatLongCalcs
  include Math

  attr_reader :latitude, :longitude

  def initialize(latitude:, longitude:)
    self.latitude = latitude
    self.longitude = longitude

    @vincenty_solutions = {}
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

  def distance_to(final_coordinate)
    find_or_calc_vincenty_solution(final_coordinate).distance
  end

  def initial_heading_to(final_coordinate)
    find_or_calc_vincenty_solution(final_coordinate).initial_bearing
  end

  def final_heading_from(start_coordinate)
    find_or_calc_vincenty_solution(start_coordinate).final_bearing
  end

  # Given a heading and bearing from the current position, returns a new position on a great circle based on
  # the initial heading.
  # rubocop: disable Metrics/AbcSize PB: no easy way to simplify this method given complex maths involved
  def new_position(heading:, distance:)
    delta_sin, delta_cos = get_trig_trio(distance.to_f / Vincenty::WGS84_A)
    heading = to_radians(heading)
    bearing_sin = sin(heading)

    latitude_in_radians = to_radians(self.latitude)
    latitude_sin, latitude_cos = get_trig_trio(latitude_in_radians)

    longitude_in_radians = to_radians(self.longitude)

    new_latitude = asin(latitude_sin * delta_cos + latitude_cos * delta_sin * cos(heading))
    new_longitude = longitude_in_radians + atan2(bearing_sin * delta_sin * latitude_cos,
                                                 delta_cos - latitude_sin * sin(new_latitude))

    Coordinate.new(latitude: to_degrees(new_latitude), longitude: to_degrees(new_longitude))
  end
  # rubocop: enable Metrics/AbcSize

  # Comparison operator for Coordinate
  def eql?(other)
    @latitude == other.latitude && @longitude == other.longitude
  end
  alias == eql?

  private

  def find_or_calc_vincenty_solution(final_coordinate)
    @vincenty_solutions[final_coordinate] ||=
      Vincenty.solution_set(latitude, longitude, final_coordinate.latitude, final_coordinate.longitude)
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

  # rubocop: disable Metrics/CyclomaticComplexity Complex maths.  Difficult to simplify in a meaningful way.
  # rubocop: disable Metrics/AbcSize
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
  # rubocop: enable Metrics/CyclomaticComplexity
  # rubocop: enable Metrics/AbcSize
end
