# frozen_string_literal: true

# Class to represents an angle or heading.  Internally, it stores the angle in degrees.  However, it also stores
# the angle in radians if this has been calculated.
class Angle
  include Comparable

  attr_reader :degrees

  # Constructor
  def initialize(degrees = nil, radians: nil)
    if radians
      @radians = radians
      @degrees = radians * 180.0 / Math::PI
    else
      @degrees = degrees
    end
  end

  def <=>(other)
    self.degrees <=> other.degrees
  end

  # Convert to radians
  def radians
    @radians ||= @degrees * Math::PI / 180.0
  end

  # Add the ability to write:
  # * 1000.ft to create an Altitude object at 1000 ft
  class ::Numeric
    def degrees
      Angle.new(self)
    end

    def radians
      Angle.new(radians: self)
    end
  end
end
