# GreatCircle

`great-circle` is a simple gem that provides a set of classes to make the manipulation of latitudes, longitudes,
headings, and distances straightforward.  It started life as a fork of the latitude-gem, but has changed so much
that I have decide to turn it into its own Gem.

## Installation

Add this line to your application's Gemfile:

    gem 'great-circle'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install great-circle

## Usage

### Angle

This class is used to manipulate angles efficiently without needing to worry too much whether the angle is in degrees
or in radians.  Creating an angle is simple:

```ruby
Angle.new(90)   # creates an angle at 90 degrees
Angle.new(90.0) # ditto
Angle.new('90.0')

Angle.new(radians: Math::PI)    # creates an angle at 180 degrees
Angle.new(radians: '3.14159')   # ditto
```

Internally, `Angle` always holds the angle in degree format as a Float.  If provided as a radians it also holds it as radians.
Otherwise, it converts the angle to radians only when required.

```ruby
a = Angle.new(180)
a.degrees # returns 180.0
a.radians # returns 3.14159.. 
```

It also supports converting a numeric value to an angle:

```ruby
180.degrees     # creates an Angle object of 180 degrees
Math.PI.radians # creates an Angle object again at 180 degrees.
```

The Angle class provides advanced parsing and formatting options for converting between strings and angles
(and vice-versa).  For conversion to strings, the `#format` method allows us to choose between decimal 
and sexagesimal (i.e. in degrees, minutes and seconds).  Decimal representation is the default.

For decimal representation, the number of decimals can be specified.  The default is six.

```ruby
50.505556.degrees.format                    # => '50.505556'; default is six decimal places
50.505556.degrees.format(decimals: 4)       # => '50.5056'
50.505556.degrees.format(sexagesimal: true) # => 50°30'20"
```

`#format` also supports specifying how negative angles are represented.  This is less useful for an angle, but becomes
useful when dealing with longitudes and latitudes (see below).  The parameter sign takes an array, the first element
represents how a positive value is represented, the second a negative.  The following rules apply to the first:
 * if a `'+'` then positive values are prefixed by a plus sign,
 * if `nil` then positive values are not explicitely flagged,
 * all other options are appended to the output.  Typically used for North/South or East/West.

The second sign parameter uses very similar rules:
* if a `'-'` or nil then negative values are prefixed by a minus sign,
* all other options are appended to the output.  Typically used for North/South or East/West.

The default sign parameter is `[nil, '-']` meaning positives are not marked, and negatives are prefixed with a minus
sign.

```ruby
50.505556.degrees.format(sign: [nil, '-'])                     # => 50.505556
50.505556.degrees.format(sexagesimal: true, sign: [nil, '-'])  # => 50°30'20"
50.505556.degrees.format(sexagesimal: true, sign: %w[N S])     # => 50°30'20"N

-50.505556.degrees.format                                      # => -50.505556
-50.505556.degrees.format(sexagesimal: true, sign: [nil, '-']) # => -50°30'20"
-50.505556.degrees.format(sexagesimal: true, sign: %w[N S]))   # => 50°30\'20"S
```

If a string is passed to the `Angle` constructor, then this is parsed to convert into an angle.  Parsing supports
the same formats as the `#format` specification:

```ruby
Angle.new('-10')
Angle.new('10') 
Angle.new('-10.5') 
Angle.new('10.5') 
Angle.new('50°')
Angle.new('10.5 °')
Angle.new("50° 0'")
Angle.new("50° 30' 0\"") 
Angle.new("50° 0' 36\"")
```

`Angle` includes Comparable allowing Ruby's Enumerable module to sort arrays etc using standard ruby. It also
provides standard arithmetic operators for Angles.  One operator is worth a special mention.  The `#abs` operator
converts the angle to an positive angle in the range of 0 to 359 degrees.

As sin, cos and tan are important functions to perform on an angle, these are provided as instance methods.  The
`Angle` class takes care of ensuring that degrees are converted to radians before being passed to the Ruby version
of the function.  Because it is cheap to store the results, and relatively costly to calculate, the results of the
calculation are cached in the `Angle` object.

```ruby
Angle.new(180.0).sin # => 0.0
Angle.new(180.0).cos # => 1.0
Angle.new(180.0).tan # => 0.0
```

### Latitude and Longitude

These are sub-classes for `Angle` that represent latitude and longitudes on the Earth's surface.  Apart from
providing defaults for valid compass headings and correlation of positive and negative angles to North/East and
South/West respectively, they provide no specific functionality. 

### Coordinate

The `Coordinate` class allows us to define locations on the Earth's surface represented as longitudes and
latitudes. Note that coordinates are positive for N/E and negative for S/W.

They are created using a straightforward constructor.   The parameters for the longitude and latitude are always in degrees, but can be in any format that the `Angle`
class's constructor accepts.

```ruby
Coordinate.new(longitude: 1.0, latitude: 52.0)
Coordinate.new(longitude: '1.0', latitude: '52.0')
# or even
Coordinate.new(longitude: "0° 30' 0\"W", latitude: "50° 30' 0\"N")
```

Standard instance accessors for longitude and latitude are also defined.  Again, these can be passed the same parameters
as the Angle constructor.  Alternatively, they can be passed a Latitude or Longitude parameter.

The `Coordinate` class supports various great circle calculations.

* `to_s` uses `Angle#to_s` to convert.
* `delta_x` and `delta_y` gives the offset in x and y (measured in nautical miles) from `self` to `other`. 
* `#distance_to` calculates the distance between `self` and a second `Coordinate`.  The caller has the choice of
  whether to use the more accurate Vincenty algorithm or the less accurate but much faster Haversine algorithm.
* `#initial_heading_to` calculates the initial heading from `self` to the other point on a great circle using the
  Vincenty algorithm.
* `#final_heading_to` calculates the final heading on a great circle from `self` to `other`.
* `#new_position` or `new_position!` both calculate the final position from self given a heading and distance travelling
  along a great circle.


## Contributing

1. Fork it ( https://github.com/[my-github-username]/latitude/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
