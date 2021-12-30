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

  # Constructor.  Passed either a number or an existing Angle.  Alternatively, passed radians as a named parameter.
  def initialize(degrees = nil, radians: nil)
    if degrees.is_a?(Angle)
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

  def to_s
    self.degrees.to_s
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

  %w[cos sin tan].each do |method|
    define_method(method) do
      instance_variable_get("@#{method}") || instance_variable_set("@#{method}", Math.send(method, self.radians))
    end
  end

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
