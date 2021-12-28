# frozen_string_literal: true

# Class to represents an angle or heading.  Internally, it stores the angle in degrees.  However, it also stores
# the angle in radians if this has been calculated.
class Angle
  include Comparable
  extend Forwardable

  attr_reader :degrees, :latlong

  # Constructor
  def initialize(degrees = nil, radians: nil, latlong: nil)
    @latlong = latlong

    if radians
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

  [:+, :-, :*, :/].each { |operator| alias_method operator, :arithmetic }

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
    @radians = @radians % Math::PI*2 if @radians
    @degrees = @degrees % 360.0
    self
  end

  # Convert to radians
  def radians
    @radians ||= @degrees * Math::PI / 180.0
  end

  private

  # rubocop: disable Lint/MixedRegexpCaptureTypes PB: the named capture groups are really useful.  The unnamed ones
  #                                               are used purely to structure the Regexp and not used for extracting
  #                                               info.  Could tag them accordingly but it makes the Regexp even less
  #                                               readable.
  SIGN = /(?<sign>[+-]?)/
  DEGREES = /(?<degrees>[0-9]{1,3})/
  MINUTES_AND_SECONDS = /(°\s*((?<minutes>[0-5]?[0-9])')(\s*(?<seconds>[0-5]?[0-9])")?)/
  DECIMAL = /((?<decimal>.[0-9]+)°?)/

  COORDINATE_REGEXP = /#{SIGN}#{DEGREES}(#{MINUTES_AND_SECONDS}|#{DECIMAL})?\s*(?<compass>[NSEW]?)/i
  LATLONG = { latitude: { valid_directions: 'NS', negative_direction: 'S'},
              longitude: { valid_directions: 'WE', negative_direction: 'W' } }.freeze
  # rubocop: enable Lint/MixedRegexpCaptureTypes

  # rubocop: disable Metrics/CyclomaticComplexity Complex maths.  Difficult to simplify in a meaningful way.
  # rubocop: disable Metrics/AbcSize
  def convert_degree_input_to_decimal(input)
    return if input.blank?

    if input.kind_of?(Numeric)
      @degrees = input.to_f
      return
    end

    match = COORDINATE_REGEXP.match(input)

    raise ArgumentError if match.nil? || check_compass(match)

    @degrees = match[:degrees].to_f

    @degrees += match[:decimal].to_f if match[:decimal]
    @degrees += match[:minutes].to_f / 60.0 if match[:minutes]
    @degrees += match[:seconds].to_f / 3600.0 if match[:seconds]

    @degrees *= -1.0 if match[:sign] == '-' || match[:compass].casecmp?(LATLONG.dig(@latlong, :negative_direction))
  end
  # rubocop: enable Metrics/CyclomaticComplexity
  # rubocop: enable Metrics/AbcSize

  def check_compass(match)
    match[:compass].present? && !match[:compass].in?(LATLONG[latlong][:valid_directions])
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
