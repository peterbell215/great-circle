# frozen_string_literal: true

# Implements great circle calculations.  Thanks to http://www.movable-type.co.uk/scripts/latlong-vincenty.html
module LatLongCalcs
  module_function

  EARTHS_RADIUS = 6_371
  WGS84_F = 1 / 298.257223563

  def to_radians(degrees)
    degrees * Math::PI / 180.0
  end

  def to_degrees(rads)
    rads * 180.0 / Math::PI
  end

  def get_trig_trio(rads)
    tan = (1 - WGS84_F) * Math.tan(rads)
    cos = 1 / Math.sqrt(1 + tan**2)
    sin = tan * cos
    [sin, cos, tan]
  end
end
