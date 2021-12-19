#
require 'active_support/all'

require "latitude/version"
require "latitude/vincenty"
require "latitude/coordinate"

module Latitude
  extend self
  def great_circle_distance(start_latitude, start_longitude, end_latitude, end_longitude)
    start_coordinate = Coordinate.new(:latitude => start_latitude,
                                      :longitude => start_longitude)
    end_coordinate = Coordinate.new(:latitude => end_latitude,
                                    :longitude => end_longitude)
    # in kilometers
    m_distance = start_coordinate.great_circle_distance_to(end_coordinate)

    return m_distance / 1000.0
  end

  def initial_bearing(start_latitude, start_longitude, end_latitude, end_longitude)
    start_coordinate = Coordinate.new(:latitude => start_latitude,
                                      :longitude => start_longitude)
    end_coordinate = Coordinate.new(:latitude => end_latitude,
                                    :longitude => end_longitude)

    start_coordinate.initial_bearing_to(end_coordinate)
  end

  def final_bearing(start_latitude, start_longitude, end_latitude, end_longitude)
    start_coordinate = Coordinate.new(:latitude => start_latitude,
                                      :longitude => start_longitude)
    end_coordinate = Coordinate.new(:latitude => end_latitude,
                                    :longitude => end_longitude)

    end_coordinate.final_bearing_from(start_coordinate)
  end

end
