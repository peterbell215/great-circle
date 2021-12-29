# frozen_string_literal: true

require_relative 'parse_angle'
require_relative 'wgs84_constants'

# Class to represents an angle or heading.  Internally, it stores the angle in degrees.  However, it also stores
# the angle in radians if this has been calculated.
class Angle
  include Comparable
  include ParseAngle
  include WGS84Constants

  attr_reader :degrees

  # Constructor
  def initialize(degrees = nil, radians: nil)
    if degrees.kind_of?(Angle)
      @degrees = degrees.degrees
      @radians = degrees.radians
    elsif radians
      @radians = radians.to_f
      @degrees = radians * 180.0 / Math::PI
    else
      convert_degree_input_to_decimal(degrees)
    end
  end

  def arithmetic(other)
    case other
    when Angle then Angle.new(@degrees.send(__callee__, other.degrees))
    when Numeric then Angle.new(@degrees.send(__callee__, other))
    else Angle.new(@degrees.send(__callee__, other.to_f))
    end
  end

  %i[+ - * /].each { |operator| alias_method operator, :arithmetic }

  def coerce(other)
    [other, self.degrees]
  end

  def <=>(other)
    self.degrees <=> other.degrees
  end

  def abs
    Angle.new(self.degrees).abs!
  end

  def abs!
    @radians = @radians % Math::PI * 2.0 if @radians
    @degrees = @degrees % 360.0
    self
  end

  # Convert to radians
  def radians
    @radians ||= @degrees * Math::PI / 180.0
  end

  def latitude
    Latitude.new(self.degrees)
  end

  def longitude
    Longitude.new(self.degrees)
  end

  def calculate_trig_trio
    unless @trig
      tan = (1 - WGS84_F) * Math.tan(self.radians)
      cos = 1 / Math.sqrt(1 + tan**2)
      sin = tan * cos
      @trig = { tan: tan, sin: sin, cos: cos }
    end
    @trig[__callee__]
  end

  alias cos calculate_trig_trio
  alias sin calculate_trig_trio
  alias tan calculate_trig_trio

  # Add the ability to write:
  # * 50.degrees to create an Angle object of 50 degrees
  # * Math::PI.radians to create an Angle object of 180 degrees
  class ::Numeric
    def degrees
      Angle.new(self)
    end

    def radians
      Angle.new(radians: self)
    end
  end
end

require_relative 'latitude'
require_relative 'longitude'
