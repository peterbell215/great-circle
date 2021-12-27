# frozen_string_literal: true

# Class to represents an angle or heading.  Internally, it stores the angle in degrees.  However, it also stores
# the angle in radians if this has been calculated.
class Angle
  include Comparable
  extend Forwardable

  attr_reader :degrees

  def_delegators :@degrees, :+, :-, :*, :/

  # Constructor
  def initialize(degrees = nil, radians: nil)
    if radians
      @radians = radians.to_f
      @degrees = radians * 180.0 / Math::PI
    else
      @degrees = degrees.to_f
    end
  end

  def arithmetic(other)
    case other
    when Angle then Angle.new(@degrees.send(caller, other.degrees))
    when Numeric then Angle.new(@degrees.send(caller, other))
    else Angle.new(@degrees.send(caller, other.to_f))
    end
  end

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
