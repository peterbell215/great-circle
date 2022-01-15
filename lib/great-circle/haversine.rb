# frozen_string_literal: true

require_relative 'wgs84_constants'

# Implements great circle calculations.  Thanks to https://www.movable-type.co.uk/scripts/latlong.html
module Haversine
  module_function

  include WGS84Constants

  # Uses the less accurate Haversine formula to calculate the distance between `point1` and `point2`.
  def distance(point1, point2)
    delta_latitude = point2.latitude.radians - point1.latitude.radians
    delta_longitude = point2.longitude.radians - point1.longitude.radians

    a = Math.sin(delta_latitude * 0.5) * Math.sin(delta_latitude * 0.5) +
        point1.latitude.cos * point2.latitude.cos * Math.sin(delta_longitude * 0.5) * Math.sin(delta_longitude * 0.5)
    c = 2.0 * Math.atan2(Math.sqrt(a), Math.sqrt(1.0 - a))
    MEAN_RADIUS * c
  end
end
