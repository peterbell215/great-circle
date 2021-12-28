# frozen_string_literal: true

# Class to represents an angle or heading.  Internally, it stores the angle in degrees.  However, it also stores
# the angle in radians if this has been calculated.
class Latitude < Angle
  @valid_compass_points = 'NS'
  @negative_compass_point = 'S'

  def initialize(degrees = nil, radians: nil)
    super
  end
end