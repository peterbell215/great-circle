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

  def to_s
    self.format
  end

  # Provides a method to format the angle in a variety of different formats, based on the passed parameters.  Options
  # are:
  # * 50.505556.degrees.format produces '50.505556'; default is six decimal places
  # * 50.505556.degrees.format(decimals: 4) produces '50.5056'
  # * 50.505556.degrees.format(sexagesimal: true) produces 50°30'20"
  #
  # The `sign` parameter is passed a two element array.  The first element specifies how a positive angle should be
  # indicated.  If nil, then no sign is provided.  If a `+` is provided, then a + sign precedes the angle.  If a
  # string is passed this is appended to the degree.  Examples:
  # * 50.505556.degrees.format(sexagesimal: true, sign: [nil, '-']) produces 50°30'20"
  # * 50.505556.degrees.format(sexagesimal: true, sign: %w[N S]) produces 50°30'20"N
  #
  # If the angle is negative, then the sign parameter is interpreted as follows: a nil, or `-` sign causes a `-` to
  # precede the angle.  Otherwise, the passed string is appended.  Examples:
  # * -50.505556.degrees.format produces -50.505556
  # * -50.505556.degrees.format(sexagesimal: true, sign: [nil, '-']) produces -50°30'20"
  # * -50.505556.degrees.format(sexagesimal: true, sign: %w[N S])) produces 50°30\'20"S
  def format(decimals: 6, sexagesimal: false, sign: [nil, '-'])
    string = format_angle(decimals, sexagesimal)

    add_sign(string, sign)
  end

  def ==(other)
    other.is_a?(self.class) && (self <=> other) == 0
  end

  def <=>(other)
    self.degrees <=> other.degrees
  end

  def minutes
    (degrees.abs * 60).floor % 60
  end

  def seconds
    (degrees.abs * 3600).floor % 60
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

  private

  def format_angle(decimals, sexagesimal)
    if sexagesimal
      '%d°%d\'%d"' % [@degrees.abs.floor.to_i, minutes, seconds]
    else
      "%0.#{decimals}f" % @degrees.abs
    end
  end

  def add_sign(string, sign)
    case [@degrees.positive?, sign[0], sign[1]]
    in true, nil, _ then string
    in true, '+', _ then "+#{string}"
    in true, String => sign, _ then "#{string}#{sign}"
    in false, _, nil | '-' then "-#{string}"
    in false, _, sign then "#{string}#{sign}"
    end
  end
end

require_relative 'latitude'
require_relative 'longitude'
