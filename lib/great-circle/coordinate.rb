# frozen_string_literal: true

require 'active_support/core_ext'

# Class to represents a location on the earth using latitude and longitude.
class Coordinate
  include Math

  attr_reader :latitude, :longitude

  def initialize(latitude:, longitude:)
    @latitude = Latitude.new(latitude)
    @longitude = Longitude.new(longitude)

    @vincenty_solutions = {}
  end

  def to_s
    "#{latitude}, #{longitude}"
  end

  def latitude=(val)
    @latitude = val.is_a?(Latitude) ? val : Latitude.new(val)
  end

  def longitude=(val)
    @longitude = val.is_a?(Longitude) ? val : Longitude.new(val)
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
  def new_position!(heading:, distance:)
    delta = Angle.new(radians: distance.to_f / Vincenty::WGS84_A)

    _new_latitude = new_latitude(delta, heading)
    _new_longitude = new_longitude(delta, heading, _new_latitude)

    @latitude = _new_latitude
    @longitude = _new_longitude
    self
  end

  def new_position(heading:, distance:)
    copy_of_self = Coordinate.new(latitude: @latitude, longitude: @longitude)
    copy_of_self.new_position!(heading: heading, distance: distance)
  end

  # Comparison operator for Coordinate
  def eql?(other)
    @latitude == other.latitude && @longitude == other.longitude
  end
  alias == eql?

  private

  def new_latitude(delta, heading)
    new_latitude_in_radians = asin(self.latitude.sin * delta.cos + self.latitude.cos * delta.sin * heading.cos)
    Latitude.new(radians: new_latitude_in_radians)
  end

  def new_longitude(delta, heading, new_latitude)
    new_longitude_in_radians =
      self.longitude.radians +
        atan2(heading.sin * delta.sin * self.latitude.cos, delta.cos - self.latitude.sin * new_latitude.sin)
    Longitude.new(radians: new_longitude_in_radians)
  end

  def find_or_calc_vincenty_solution(final_coordinate)
    unless final_coordinate.is_a?(Coordinate)
      final_coordinate = Coordinate.new(latitude: final_coordinate.latitude, longitude: final_coordinate.longitude)
    end
    @vincenty_solutions[final_coordinate] ||= Vincenty.iterative_solver(self, final_coordinate)
  end
end
